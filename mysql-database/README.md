# MySQL Database with Docker Compose

Este projeto configura uma base de dados MySQL usando Docker Compose, incluindo phpMyAdmin para gestão da base de dados.

## Serviços Incluídos

- **MySQL 8.0**: Base de dados principal
- **phpMyAdmin**: Interface web para gestão da base de dados

## Configuração

### Credenciais da Base de Dados

- **Root Password**: `rootpassword`
- **Database**: `myapp`
- **User**: `appuser`
- **Password**: `userpassword`

### Portas

- **MySQL**: 3306
- **phpMyAdmin**: 8080

## Como Usar

### 1. Iniciar os Serviços

```bash
docker-compose up -d
```

### 2. Aceder à Base de Dados

#### Via phpMyAdmin

- Abra o browser e vá para: `http://localhost:8080`
- Login com:
  - Username: `root`
  - Password: `rootpassword`

#### Via Linha de Comandos

```bash
docker exec -it mysql_database mysql -u root -p
# Password: rootpassword
```

#### Via Aplicação

```bash
Host: localhost
Port: 3306
Database: myapp
Username: appuser
Password: userpassword
```

### 3. Parar os Serviços

```bash
docker-compose down
```

### 4. Parar e Remover Volumes

```bash
docker-compose down -v
```

## Estrutura da Base de Dados

### Tabelas Criadas

- **users**: Gestão de utilizadores
- **products**: Catálogo de produtos

### Dados de Exemplo

A base de dados é inicializada com dados de exemplo para facilitar os testes.

## Volumes

- `mysql_data`: Dados persistentes da base de dados
- `./init`: Scripts de inicialização

## Redes

- `mysql_network`: Rede isolada para comunicação entre serviços

## Troubleshooting

### Verificar Logs

```bash
docker-compose logs mysql
docker-compose logs phpmyadmin
```

### Reiniciar Serviços

```bash
docker-compose restart
```

### Verificar Status

```bash
docker-compose ps
```

## Segurança

⚠️ **Nota**: As passwords neste exemplo são apenas para desenvolvimento. Para produção, use passwords fortes e variáveis de ambiente.
