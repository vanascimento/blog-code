# PostgreSQL Database with Docker Compose

Este projeto configura uma base de dados PostgreSQL usando Docker Compose, incluindo pgAdmin para gestão da base de dados.

## Serviços Incluídos

- **PostgreSQL 15**: Base de dados principal

## Configuração

### Credenciais da Base de Dados

- **Database**: `netflix`
- **User**: `postgres`
- **Password**: `postgrespassword`

### Portas

- **PostgreSQL**: 5432

## Como Usar

### 1. Iniciar os Serviços

```bash
docker-compose up -d
```

### 2. Aceder à Base de Dados

#### Via Linha de Comandos

```bash
docker exec -it postgres_database psql -U postgres -d netflix
```

#### Via Aplicação

```bash
Host: localhost
Port: 5432
Database: netflix
Username: postgres
Password: postgrespassword
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

### Base de Dados Criada

- **netflix**: Base de dados principal para a aplicação Netflix

### Script de Inicialização

A base de dados é inicializada com o script `netflix.sql` localizado no diretório `init/`.

## Volumes

- `postgres_data`: Dados persistentes da base de dados
- `./init`: Scripts de inicialização

## Redes

- `postgres_network`: Rede isolada para comunicação entre serviços

## Troubleshooting

### Verificar Logs

```bash
docker-compose logs postgres
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
