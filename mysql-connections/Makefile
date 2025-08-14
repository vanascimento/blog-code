# MySQL Connections Load Test Makefile

.PHONY: help test test-proxy clean clean-proxy logs logs-proxy test-connection test-connection-proxy proxysql-status mysql-status mysql-status-proxy

# Default target
help:
	@echo "🚀 MySQL Connections Load Test"
	@echo "================================"
	@echo ""
	@echo "Available targets:"
	@echo "  test                - Run standard MySQL test (docker-compose.yml + main.py)"
	@echo "  test-proxy          - Run MySQL test with ProxySQL (docker-compose-with-proxy.yml + main.py)"
	@echo "  test-connection     - Quick connection test (standard MySQL)"
	@echo "  test-connection-proxy - Quick connection test (through ProxySQL)"
	@echo "  clean               - Stop and remove standard containers"
	@echo "  clean-proxy         - Stop and remove proxy containers"
	@echo "  logs                - Show logs from standard containers"
	@echo "  logs-proxy          - Show logs from proxy containers"
	@echo "  mysql-status        - Show MySQL status (standard)"
	@echo "  mysql-status-proxy  - Show MySQL status (through ProxySQL)"
	@echo "  proxysql-status     - Show ProxySQL configuration and stats"
	@echo "  help                - Show this help message"
	@echo ""

# Standard MySQL test (without proxy)
test: clean
	@echo "🚀 Starting standard MySQL test..."
	@echo "📦 Starting MySQL containers..."
	docker-compose up -d
	@echo "⏳ Waiting for MySQL to be ready..."
	@echo "   (This may take a few seconds...)"
	@until docker-compose exec mysql mysqladmin ping -h localhost --silent; do \
		echo "   Waiting for MySQL..."; \
		sleep 2; \
	done
	@echo "✅ MySQL is ready!"
	@echo "🧪 Running load test on port 3306..."
	cd test-app && python main.py --port 3306

# MySQL test with ProxySQL
test-proxy: clean-proxy
	@echo "🚀 Starting MySQL test with ProxySQL..."
	@echo "📦 Starting MySQL + ProxySQL containers..."
	docker-compose -f docker-compose-with-proxy.yml up -d
	@echo "⏳ Waiting for services to be ready..."
	@echo "   (This may take a few seconds...)"
	@until docker-compose -f docker-compose-with-proxy.yml exec mysql mysqladmin ping -h localhost --silent; do \
		echo "   Waiting for MySQL..."; \
		sleep 2; \
	done
	@echo "⏳ Waiting for ProxySQL..."
	@until docker-compose -f docker-compose-with-proxy.yml exec proxysql mysql -h localhost -P 6032 -u admin -padmin -e "SELECT 1" >/dev/null 2>&1; do \
		echo "   Waiting for ProxySQL..."; \
		sleep 2; \
	done
	@echo "🔧 Configuring ProxySQL..."
	@docker-compose -f docker-compose-with-proxy.yml exec proxysql mysql -h localhost -P 6032 -u admin -padmin -e "LOAD MYSQL SERVERS TO RUNTIME; LOAD MYSQL USERS TO RUNTIME; LOAD MYSQL VARIABLES TO RUNTIME; SAVE MYSQL SERVERS TO MEMORY; SAVE MYSQL USERS TO MEMORY; SAVE MYSQL VARIABLES TO MEMORY;"
	@echo "✅ All services are ready and configured!"
	@echo "🧪 Running load test through ProxySQL on port 6033..."
	cd test-app && python main.py --port 6033

# Clean up standard containers
clean:
	@echo "🧹 Cleaning up standard containers..."
	docker-compose down -v
	@echo "✅ Cleanup complete!"

# Clean up proxy containers
clean-proxy:
	@echo "🧹 Cleaning up proxy containers..."
	docker-compose -f docker-compose-with-proxy.yml down -v
	@echo "✅ Cleanup complete!"

# Show logs from standard containers
logs:
	@echo "📋 Showing logs from standard containers..."
	docker-compose logs -f

# Show logs from proxy containers
logs-proxy:
	@echo "📋 Showing logs from proxy containers..."
	docker-compose -f docker-compose-with-proxy.yml logs -f

# Quick connection test
test-connection:
	@echo "🔌 Testing MySQL connection on port 3306..."
	cd test-app && python test_connection.py --port 3306

# Quick connection test with proxy
test-connection-proxy:
	@echo "🔌 Testing MySQL connection through ProxySQL on port 6033..."
	cd test-app && python test_connection.py --port 6033

# Show ProxySQL status
proxysql-status:
	@echo "📊 ProxySQL Status:"
	docker-compose -f docker-compose-with-proxy.yml exec proxysql mysql -h localhost -P 6032 -u admin -padmin -e "SELECT * FROM mysql_servers; SELECT * FROM mysql_users; SELECT * FROM stats.stats_mysql_connection_pool;"

# Show MySQL status
mysql-status:
	@echo "📊 MySQL Status:"
	docker-compose exec mysql mysql -h localhost -u root -prootpass -e "SHOW PROCESSLIST; SHOW STATUS LIKE 'Threads_connected';"

# Show ProxySQL MySQL status
mysql-status-proxy:
	@echo "📊 MySQL Status (through ProxySQL):"
	docker-compose -f docker-compose-with-proxy.yml exec proxysql mysql -h localhost -P 6032 -u admin -padmin -e "SHOW PROCESSLIST; SHOW STATUS LIKE 'Threads_connected';"
