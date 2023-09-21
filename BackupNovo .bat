@echo off
chcp 65001 >nul

REM Solicitar o endereço IP da máquina onde está o banco de dados (com padrão para localhost)
set /p "db_host=Digite o endereço IP da máquina onde está o banco de dados (ou pressione Enter para localhost): "
if "%db_host%"=="" set "db_host=localhost"

REM Solicitar a porta do MySQL
set /p "db_port=Digite a porta do MySQL (pressione Enter para usar a porta padrão 3306): "
if "%db_port%"=="" set "db_port=3306"

REM Defina o caminho para o diretório onde o mysqldump está localizado
cd /d "C:\Program Files\MariaDB 10.6\bin"

REM Solicitar o nome do backup
set /p "backup_name=Digite o nome do backup: "

REM Solicitar o caminho da pasta de destino para o backup
set "backup_folder="
echo Por favor, navegue até a pasta de destino para o backup.
echo Pressione Enter quando estiver na pasta.
pause
for /f "delims=" %%a in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $FolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog; $FolderDialog.ShowDialog() | Out-Null; $FolderDialog.SelectedPath"') do (
    set "backup_folder=%%a"
)

REM Verificar se o caminho da pasta de destino é válido
if not exist "%backup_folder%" (
    echo O caminho da pasta de destino não é válido. Certifique-se de que o caminho existe.
    pause
    exit /b
)

REM Solicitar informações de conexão MySQL
set /p "db_user=Digite o nome de usuário do MySQL: "
set /p "db_password=Digite a senha do MySQL: "

REM Listar os bancos de dados disponíveis e permitir que o usuário escolha
echo Listando bancos de dados disponíveis:
mysqlshow -h %db_host% -P %db_port% -u %db_user% -p%db_password%
set /p "selected_db=Digite o nome do banco de dados a ser backup: "

REM Definir o nome do arquivo de backup com base no nome do backup e na data/hora
for /f "delims=" %%a in ('wmic os get LocalDateTime ^| find "."') do set "current_datetime=%%a"
set "current_datetime=!current_datetime:~0,4!!current_datetime:~4,2!!current_datetime:~6,2!_!current_datetime:~8,2!!current_datetime:~10,2!!current_datetime:~12,2!"
set "backup_file_name=%backup_name%.sql"

echo Realizando backup...

REM Realizar o backup com mysqldump
mysqldump -h %db_host% -P %db_port% -u %db_user% -p%db_password% %selected_db% > "%backup_folder%\%backup_file_name%"

REM Verificar se o backup foi bem-sucedido
if %errorlevel% neq 0 (
    echo Houve um erro ao fazer o backup do banco de dados.
) else (
    echo Backup do banco de dados %selected_db% concluído com sucesso.
    echo O arquivo de backup está em: "%backup_folder%\%backup_file_name%"
)

REM Compactar o arquivo de backup com 7-Zip
set "zip_file_name=%backup_name%.zip"
"C:\Program Files\7-Zip\7z.exe" a "%backup_folder%\%zip_file_name%" "%backup_folder%\%backup_file_name%"

REM Verificar se a compactação foi bem-sucedida e, em seguida, excluir o arquivo SQL original
if %errorlevel% neq 0 (
    echo Houve um erro ao compactar o arquivo de backup.
) else (
    echo Arquivo de backup compactado com sucesso em: "%backup_folder%\%zip_file_name%"
    del "%backup_folder%\%backup_name%"
)

pause
