
@echo off

REM Defina o caminho para o diretorio onde você deseja executar o script
cd /d "C:\Program Files\MariaDB 10.6\bin"

REM Pergunta ao usuario sobre o nome de usuário e senha da conexão
set /p "db_user=Digite o nome de usuario do MySQL: "
set /p "db_password=Digite a senha do MySQL: "

REM Pergunta ao usuario se deseja acessar o cliente MySQL
set /p "access_mysql=Voce deseja acessar o cliente MySQL para ajustes? (S/N): "
if /i "%access_mysql%"=="S" (
    REM Acessa o cliente MySQL pelo CMD
    start cmd.exe /k "mysql.exe -u%db_user% -p%db_password%"
)


REM Pergunta ao usuário se o arquivo SQL está disponível para seleção
set /p "sql_available=O arquivo SQL esta disponivel para selecao? (S/N): "
if /i "%sql_available%"=="N" (
    echo Por favor, ajuste o arquivo SQL e execute o script novamente.
    pause
    exit /b
)

REM Abrir uma tela de seleção de arquivo para que o usuário escolha o arquivo SQL
setlocal enabledelayedexpansion
for /f "delims=" %%a in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $FileDialog = New-Object System.Windows.Forms.OpenFileDialog; $FileDialog.Filter = 'Arquivos SQL (*.sql)|*.sql'; $FileDialog.ShowDialog() | Out-Null; $FileDialog.FileName"') do (
    set "selected_file=%%a"
)

REM Verifica se o arquivo SQL foi selecionado
if "%selected_file%"=="" (
    echo Nenhum arquivo SQL foi selecionado.
    pause
    exit /b
)

REM Pasta para a restauração do arquivo SQL (criada apenas se um arquivo for selecionado)
set "restore_folder=C:\Restauracao"
mkdir "%restore_folder%" 2>nul

REM Copia o arquivo selecionado para a pasta de restauração
copy "%selected_file%" "%restore_folder%"

REM Extrai o nome do arquivo SQL da seleção do usuário
for %%i in ("%selected_file%") do (
    set "sql_file_name=%%~nxi"
)

set "sql_file=%restore_folder%\%sql_file_name%"

REM Pergunta ao usuário se deseja informar o nome do banco de dados a ser restaurado
set /p "ask_db_name=Deseja informar o nome do banco de dados a ser restaurado? (S/N): "
if /i "%ask_db_name%"=="S" (
    REM Pergunta ao usuário o nome do banco de dados a ser restaurado
    set /p "db_to_restore=Digite o nome do banco de dados a ser restaurado (Caso no arquivo nao tenha o comando Create):"
) else (
    set "db_to_restore="
)

REM Restauração do banco de dados
echo Iniciando restauracao do banco de dados "%db_to_restore%"...

REM Execute o comando para restaurar o banco de dados
mysql -u%db_user% -p%db_password% %db_to_restore% < "%sql_file%"

REM Verifica se houve erro na restauração
IF %ERRORLEVEL% NEQ 0 (
    echo Houve um erro ao restaurar o banco de dados.
) else (
    echo O banco de dados "%db_to_restore%" foi restaurado com sucesso.
)

REM Pergunta ao usuário se deseja abrir o arquivo Config.ini agora
set /p "open_config=Voce deseja abrir o arquivo Config.ini agora? (S/N): "
if /i "%open_config%"=="S" (
    start notepad "C:\Visual Software\MyCommerce\Config.ini"
)

REM Pergunta ao usuário se deseja executar o arquivo AtualizarDB.exe agora
set /p "run_atualizar=Voce deseja executar o arquivo AtualizarDB.exe agora? (S/N): "
if /i "%run_atualizar%"=="S" (
    start "" "C:\Visual Software\MyCommerce\AtualizarDB.exe"
)

pause
