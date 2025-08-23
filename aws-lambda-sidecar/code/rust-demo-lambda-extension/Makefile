APP_NAME := rust-demo-lambda-extension
TARGET := aarch64-unknown-linux-musl
RELEASE_DIR := target/$(TARGET)/release
ZIP_FILE := lambda-extension-$(shell date +%Y%m%d%H%M%S).zip
S3_BUCKET := lambda-extensions-rust

.PHONY: all install build package clean

all: install build package upload deploy clean

install:
	@which zig > /dev/null || (echo "🔧 Installing Zig..." && brew install zig)
	@which cargo-zigbuild > /dev/null || (echo "🔧 Installing cargo-zigbuild..." && cargo install cargo-zigbuild)
	@rustup target add $(TARGET)

build:
	@echo "🚀 Compiling for $(TARGET)..."
	cargo zigbuild --release --target $(TARGET)
	@echo "✅ Binary generated: $(RELEASE_DIR)/$(APP_NAME)"

package:
	@echo "📦 Packaging Lambda extension..."
	rm -rf extensions $(ZIP_FILE)
	mkdir -p extensions
	cp $(RELEASE_DIR)/$(APP_NAME) extensions/
	chmod +x extensions/$(APP_NAME)
	zip -r $(ZIP_FILE) extensions
	@echo "✅ Package generated: $(ZIP_FILE)"

upload:
	@echo "📤 Uploading package to S3..."
	aws s3 cp $(ZIP_FILE) s3://$(S3_BUCKET)/$(ZIP_FILE)
	@echo "✅ Package uploaded to S3"

deploy:
	@echo "📦 Deploying Lambda extension..."
	sam build
	sam deploy --parameter-overrides Bucket=$(S3_BUCKET) Key=$(ZIP_FILE)
	@echo "✅ Lambda extension deployed"

clean:
	cargo clean
	rm -rf extensions $(ZIP_FILE)
	rm -rf .aws-sam
