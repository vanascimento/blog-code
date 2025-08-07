# Rust Lambda Extension

Uma Lambda Extension em Rust que expõe um servidor HTTP para gerar tokens JWT.

## 🚀 Deploy com SAM

Use o script `deploy.sh` para automatizar todo o processo:

```bash
# Deploy com nome do bucket (stack name opcional)
./deploy.sh meu-bucket-extensions-123

# Ou especificar também o nome da stack
./deploy.sh meu-bucket-extensions-123 minha-stack-extensions
```

## 📋 O que o script faz:

1. **Build** da extensão em modo release
2. **Criação** do pacote da extensão (`lambda-extension.zip`)
3. **Upload** do arquivo para o S3
4. **Deploy** usando SAM CLI
5. **Exibe** o ARN da Layer criada

## 🛠️ Deploy Manual

Se preferir fazer manualmente:

### 1. Build da extensão:

```bash
cargo build --release
```

### 2. Criar o pacote da extensão:

```bash
mkdir -p extension-package
cp target/release/rust-demo-lambda-extension extension-package/bootstrap
cd extension-package
zip -r ../lambda-extension.zip .
cd ..
rm -rf extension-package
```

### 3. Upload para S3:

```bash
aws s3 cp lambda-extension.zip s3://meu-bucket-extensions-123/lambda-extension.zip
```

### 4. Deploy com SAM:

```bash
sam deploy \
  --template-file template.yaml \
  --stack-name rust-extension-layer \
  --parameter-overrides \
    BucketName=meu-bucket-extensions-123 \
  --capabilities CAPABILITY_NAMED_IAM
```

## 📦 Estrutura da Extensão

A extensão:

- **Registra-se** como Lambda Extension
- **Expõe servidor HTTP** na porta 3003
- **Gera tokens JWT** via endpoint `/token`
- **Escuta eventos** `INVOKE` e `SHUTDOWN`

## 🔧 Como usar a Layer

Após o deploy, use o ARN da Layer em suas Lambda Functions:

```yaml
Layers:
  - arn:aws:lambda:us-east-1:123456789012:layer:CustomRustExtension:1
```

## 🧪 Teste Local

Para testar localmente:

```bash
# Executar a extensão
./target/release/rust-demo-lambda-extension

# Em outro terminal, testar o endpoint
curl http://localhost:3003/token
```

## 📋 Pré-requisitos

- AWS CLI configurado
- SAM CLI instalado
- Rust toolchain
- Bucket S3 (será criado automaticamente)

