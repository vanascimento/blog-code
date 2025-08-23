.PHONY: deploy clean

deploy:
	@echo "📦 Deploying Lambda function..."
	sam build && sam deploy
	@echo "✅ Lambda function deployed"

clean:
	rm -rf .aws-sam