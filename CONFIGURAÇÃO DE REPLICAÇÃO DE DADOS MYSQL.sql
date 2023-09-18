# Passo 1: CONFIGURANDO SERVIDOR MESTRE:

/*
		Abra o arquivo de configuração do MariaDB no 
				servidor mestre (normalmente chamado de my.cnf ou my.ini) 
						e adicione ou modifique as seguintes configuraçõe

[mysqld]
server-id=1
log_bin=master-bin

# O server-id é um valor único para cada servidor no ambiente de replicação.

*/

# Criar um Usuário de Replicação no Servidor Mestre:

/*
		Faça login no servidor mestre com um cliente MariaDB como 
				administrador e execute o seguinte comando:

*/

CREATE USER 'nome_do_usuario'@'endereco_ip_escravo' IDENTIFIED BY 'sua_senha';

#Substitua 'nome_do_usuario', 'endereco_ip_escravo' e 'sua_senha' pelos valores apropriados.

#Conceda as permissões necessárias ao usuário para a replicação:

GRANT REPLICATION SLAVE ON *.* TO 'nome_do_usuario'@'endereco_ip_escravo';

#Executa o comando para salvar e aplicar as permissões

FLUSH PRIVILEGES;

# CONFIGURANDO SERVIDOR ESCRAVO

# Abra o arquivo my.ini

# Adicione o server-id=2. No caso, cada um tem o server-id seu
/*
[mysqld]
datadir=C:/Program Files/MariaDB 11.1/data
port=3306
server-id=2
*/

# Passo 5: Iniciar a Replicação no Servidor Escravo (Slave):

# Conect ao servidor escravo usando um cliente MariaDB
# Execute o seguinte comando

CHANGE MASTER TO
    MASTER_HOST='endereco_ip_mestre', #IP DA MAQUINA MESTRE QUE VAI REPLICAR OS DADOS
    MASTER_USER='nome_do_usuario', # NOME DO USUSARIO CRAIDO NO PASSO ACIMA
    MASTER_PASSWORD='sua_senha', # SENHA DO NOME CRIADO
    MASTER_LOG_FILE='master-bin.000001', # GERALMENTE É PADRAO MAS PODE SER VISTO A PARTIR DO COMANDO ABAIXO
    MASTER_LOG_POS=1; # PADRAO


#Ver o MASTER_LOG_FILE
    SHOW MASTER STATUS

# Inicie a replicação no servidor escravo com o seguinte comando:

START SLAVE;

# Verifique o status da replicação com:

SHOW SLAVE STATUS\G

/*
	Se o status mostrar "Slave_IO_Running" e "Slave_SQL_Running" como "Yes" 
			A replicação está funcionando corretamente.
*/

# ATENÇÃO

# A REPLICAÇÃO SÓ E FEITA APÓS ELA SER CONFIGURADAS, DADOS ANTERIORES ÃO SAO REPLICADOS, NECESSARIO REALIZAR BACKUP ANTES
				# RESTAURAR E APÓS ISSO COMEÇAR AS REPLICAÇÕES

# PARA O SERVIÇO DE REPLICAÇÃO NO ESCRAVO

STOP SLAVE;

# PARA O SERVIO DE REPLICAÇÃO NO MESTRE

STOP MASTER;

