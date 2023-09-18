@echo off

REM Defina o caminho para o diretório onde você deseja executar o script
cd /d "C:\Program Files\MariaDB *\bin"

REM Defina as variáveis de conexão
set "db_user=root"
set "db_password=1234"

REM Pergunta ao usuário se deseja acessar o cliente MySQL
set /p "access_mysql=Voce deseja acessar o client MySQL para ajustes? (S/N): "
if /i "%access_mysql%"=="S" (
    REM Acessa o cliente MySQL pelo CMD
    start cmd.exe /k "mysql.exe -u%db_user% -p%db_password%"
)

REM Pasta para a restauração do arquivo SQL
set "restore_folder=C:\Restauracao"

REM Pergunta ao usuário o nome do banco de dados a ser restaurado
set /p "db_to_restore=Digite o nome do banco de dados a ser restaurado: "

REM Pergunta ao usuário o nome do arquivo SQL a ser restaurado
set /p "sql_file_name=Digite o nome do arquivo SQL a ser restaurado (com extensao .sql): "
set "sql_file=%restore_folder%\%sql_file_name%"

REM Verifica se o arquivo SQL existe na pasta de restauração
if not exist "%sql_file%" (
    echo O arquivo SQL "%sql_file%" não foi encontrado.
    pause
    exit /b
)

REM Restauração do banco de dados
echo Iniciando restauracao...

REM Execute o comando para restaurar o banco de dados
mysql -u%db_user% -p%db_password% %db_to_restore% < "%sql_file%"

REM Verifica se houve erro na restauração
IF %ERRORLEVEL% NEQ 0 (
    echo Houve um erro ao restaurar o banco de dados.
) else (
    echo O banco de dados %db_to_restore% foi restaurado com sucesso.
)

pause