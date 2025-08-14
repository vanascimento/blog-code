-- Create exporter user for mysqld_exporter
CREATE USER 'exporter'@'%' IDENTIFIED BY 'exporterpass' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';
FLUSH PRIVILEGES;

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS bank_db;
USE bank_db;

-- Create bank transactions table
CREATE TABLE IF NOT EXISTS TB_BANK_TRANSACTIONS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(36) NOT NULL UNIQUE,
    account_number VARCHAR(20) NOT NULL,
    account_holder VARCHAR(100) NOT NULL,
    transaction_type ENUM('DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'PAYMENT', 'REFUND') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    description TEXT,
    merchant_name VARCHAR(100),
    transaction_date DATETIME NOT NULL,
    status ENUM('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED') DEFAULT 'COMPLETED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_account_number (account_number),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_status (status)
);

-- Insert 50 dummy bank transactions
INSERT INTO TB_BANK_TRANSACTIONS (transaction_id, account_number, account_holder, transaction_type, amount, currency, description, merchant_name, transaction_date, status) VALUES
('TXN-001-2024-001', '1234-5678-9012-3456', 'John Smith', 'DEPOSIT', 2500.00, 'USD', 'Salary deposit', 'ABC Company', '2024-01-15 09:30:00', 'COMPLETED'),
('TXN-001-2024-002', '1234-5678-9012-3456', 'John Smith', 'WITHDRAWAL', 200.00, 'USD', 'ATM withdrawal', 'Bank ATM', '2024-01-16 14:20:00', 'COMPLETED'),
('TXN-001-2024-003', '1234-5678-9012-3456', 'John Smith', 'PAYMENT', 150.00, 'USD', 'Grocery store payment', 'Walmart', '2024-01-17 16:45:00', 'COMPLETED'),
('TXN-002-2024-001', '9876-5432-1098-7654', 'Maria Garcia', 'DEPOSIT', 3200.00, 'USD', 'Monthly salary', 'XYZ Corp', '2024-01-15 10:15:00', 'COMPLETED'),
('TXN-002-2024-002', '9876-5432-1098-7654', 'Maria Garcia', 'TRANSFER', 500.00, 'USD', 'Transfer to savings', 'Internal Transfer', '2024-01-16 11:00:00', 'COMPLETED'),
('TXN-002-2024-003', '9876-5432-1098-7654', 'Maria Garcia', 'PAYMENT', 89.99, 'USD', 'Online shopping', 'Amazon', '2024-01-17 20:30:00', 'COMPLETED'),
('TXN-003-2024-001', '5555-6666-7777-8888', 'David Johnson', 'DEPOSIT', 1800.00, 'USD', 'Freelance payment', 'Client ABC', '2024-01-15 12:00:00', 'COMPLETED'),
('TXN-003-2024-002', '5555-6666-7777-8888', 'David Johnson', 'WITHDRAWAL', 300.00, 'USD', 'Cash withdrawal', 'Bank Branch', '2024-01-16 15:30:00', 'COMPLETED'),
('TXN-003-2024-003', '5555-6666-7777-8888', 'David Johnson', 'PAYMENT', 75.50, 'USD', 'Restaurant payment', 'McDonald\'s', '2024-01-17 19:15:00', 'COMPLETED'),
('TXN-004-2024-001', '1111-2222-3333-4444', 'Sarah Wilson', 'DEPOSIT', 2800.00, 'USD', 'Salary deposit', 'Tech Solutions', '2024-01-15 08:45:00', 'COMPLETED'),
('TXN-004-2024-002', '1111-2222-3333-4444', 'Sarah Wilson', 'TRANSFER', 1000.00, 'USD', 'Investment transfer', 'Investment Account', '2024-01-16 13:20:00', 'COMPLETED'),
('TXN-004-2024-003', '1111-2222-3333-4444', 'Sarah Wilson', 'PAYMENT', 120.00, 'USD', 'Gas station', 'Shell', '2024-01-17 17:00:00', 'COMPLETED'),
('TXN-005-2024-001', '9999-8888-7777-6666', 'Michael Brown', 'DEPOSIT', 1500.00, 'USD', 'Part-time salary', 'Retail Store', '2024-01-15 16:30:00', 'COMPLETED'),
('TXN-005-2024-002', '9999-8888-7777-6666', 'Michael Brown', 'WITHDRAWAL', 100.00, 'USD', 'ATM withdrawal', 'Bank ATM', '2024-01-16 10:45:00', 'COMPLETED'),
('TXN-005-2024-003', '9999-8888-7777-6666', 'Michael Brown', 'PAYMENT', 45.99, 'USD', 'Movie tickets', 'AMC Theaters', '2024-01-17 21:00:00', 'COMPLETED'),
('TXN-006-2024-001', '7777-8888-9999-0000', 'Lisa Davis', 'DEPOSIT', 4200.00, 'USD', 'Monthly salary', 'Law Firm', '2024-01-15 09:00:00', 'COMPLETED'),
('TXN-006-2024-002', '7777-8888-9999-0000', 'Lisa Davis', 'TRANSFER', 800.00, 'USD', 'Emergency fund', 'Savings Account', '2024-01-16 14:15:00', 'COMPLETED'),
('TXN-006-2024-003', '7777-8888-9999-0000', 'Lisa Davis', 'PAYMENT', 200.00, 'USD', 'Medical bill', 'City Hospital', '2024-01-17 11:30:00', 'COMPLETED'),
('TXN-007-2024-001', '4444-5555-6666-7777', 'Robert Taylor', 'DEPOSIT', 1900.00, 'USD', 'Consulting fee', 'Business Client', '2024-01-15 13:45:00', 'COMPLETED'),
('TXN-007-2024-002', '4444-5555-6666-7777', 'Robert Taylor', 'WITHDRAWAL', 250.00, 'USD', 'Cash withdrawal', 'Bank Branch', '2024-01-16 16:00:00', 'COMPLETED'),
('TXN-007-2024-003', '4444-5555-6666-7777', 'Robert Taylor', 'PAYMENT', 95.75, 'USD', 'Hardware store', 'Home Depot', '2024-01-17 18:45:00', 'COMPLETED'),
('TXN-008-2024-001', '2222-3333-4444-5555', 'Jennifer Lee', 'DEPOSIT', 3100.00, 'USD', 'Salary deposit', 'Marketing Agency', '2024-01-15 10:30:00', 'COMPLETED'),
('TXN-008-2024-002', '2222-3333-4444-5555', 'Jennifer Lee', 'TRANSFER', 600.00, 'USD', 'Vacation fund', 'Travel Account', '2024-01-16 12:00:00', 'COMPLETED'),
('TXN-008-2024-003', '2222-3333-4444-5555', 'Jennifer Lee', 'PAYMENT', 85.00, 'USD', 'Coffee shop', 'Starbucks', '2024-01-17 08:15:00', 'COMPLETED'),
('TXN-009-2024-001', '8888-9999-0000-1111', 'Thomas Anderson', 'DEPOSIT', 2200.00, 'USD', 'Monthly salary', 'IT Company', '2024-01-15 11:15:00', 'COMPLETED'),
('TXN-009-2024-002', '8888-9999-0000-1111', 'Thomas Anderson', 'WITHDRAWAL', 180.00, 'USD', 'ATM withdrawal', 'Bank ATM', '2024-01-16 15:45:00', 'COMPLETED'),
('TXN-009-2024-003', '8888-9999-0000-1111', 'Thomas Anderson', 'PAYMENT', 65.50, 'USD', 'Bookstore', 'Barnes & Noble', '2024-01-17 20:00:00', 'COMPLETED'),
('TXN-010-2024-001', '6666-7777-8888-9999', 'Emily White', 'DEPOSIT', 2600.00, 'USD', 'Salary deposit', 'Design Studio', '2024-01-15 08:00:00', 'COMPLETED'),
('TXN-010-2024-002', '6666-7777-8888-9999', 'Emily White', 'TRANSFER', 400.00, 'USD', 'Charity donation', 'Red Cross', '2024-01-16 13:45:00', 'COMPLETED'),
('TXN-010-2024-003', '6666-7777-8888-9999', 'Emily White', 'PAYMENT', 110.00, 'USD', 'Pharmacy', 'CVS', '2024-01-17 16:30:00', 'COMPLETED'),
('TXN-011-2024-001', '3333-4444-5555-6666', 'Christopher Martin', 'DEPOSIT', 1700.00, 'USD', 'Part-time work', 'Restaurant', '2024-01-15 17:00:00', 'COMPLETED'),
('TXN-011-2024-002', '3333-4444-5555-6666', 'Christopher Martin', 'WITHDRAWAL', 120.00, 'USD', 'Cash withdrawal', 'Bank ATM', '2024-01-16 09:30:00', 'COMPLETED'),
('TXN-011-2024-003', '3333-4444-5555-6666', 'Christopher Martin', 'PAYMENT', 55.25, 'USD', 'Fast food', 'Burger King', '2024-01-17 19:30:00', 'COMPLETED'),
('TXN-012-2024-001', '0000-1111-2222-3333', 'Amanda Clark', 'DEPOSIT', 3500.00, 'USD', 'Monthly salary', 'Healthcare Corp', '2024-01-15 09:45:00', 'COMPLETED'),
('TXN-012-2024-002', '0000-1111-2222-3333', 'Amanda Clark', 'TRANSFER', 700.00, 'USD', 'Investment deposit', 'Stock Account', '2024-01-16 14:30:00', 'COMPLETED'),
('TXN-012-2024-003', '0000-1111-2222-3333', 'Amanda Clark', 'PAYMENT', 180.00, 'USD', 'Dental appointment', 'Dental Clinic', '2024-01-17 10:15:00', 'COMPLETED'),
('TXN-013-2024-001', '5555-6666-7777-8888', 'Daniel Rodriguez', 'DEPOSIT', 2000.00, 'USD', 'Freelance payment', 'Web Client', '2024-01-15 12:30:00', 'COMPLETED'),
('TXN-013-2024-002', '5555-6666-7777-8888', 'Daniel Rodriguez', 'WITHDRAWAL', 150.00, 'USD', 'ATM withdrawal', 'Bank Branch', '2024-01-16 16:15:00', 'COMPLETED'),
('TXN-013-2024-003', '5555-6666-7777-8888', 'Daniel Rodriguez', 'PAYMENT', 90.00, 'USD', 'Electronics store', 'Best Buy', '2024-01-17 21:45:00', 'COMPLETED'),
('TXN-014-2024-001', '1111-2222-3333-4444', 'Jessica Moore', 'DEPOSIT', 2800.00, 'USD', 'Salary deposit', 'Finance Company', '2024-01-15 10:00:00', 'COMPLETED'),
('TXN-014-2024-002', '1111-2222-3333-4444', 'Jessica Moore', 'TRANSFER', 500.00, 'USD', 'Emergency fund', 'Savings Account', '2024-01-16 11:30:00', 'COMPLETED'),
('TXN-014-2024-003', '1111-2222-3333-4444', 'Jessica Moore', 'PAYMENT', 75.00, 'USD', 'Hair salon', 'Beauty Salon', '2024-01-17 15:00:00', 'COMPLETED'),
('TXN-015-2024-001', '9999-8888-7777-6666', 'Kevin Thompson', 'DEPOSIT', 1600.00, 'USD', 'Monthly salary', 'Construction Co', '2024-01-15 14:15:00', 'COMPLETED'),
('TXN-015-2024-002', '9999-8888-7777-6666', 'Kevin Thompson', 'WITHDRAWAL', 200.00, 'USD', 'Cash withdrawal', 'Bank ATM', '2024-01-16 17:00:00', 'COMPLETED'),
('TXN-015-2024-003', '9999-8888-7777-6666', 'Kevin Thompson', 'PAYMENT', 125.50, 'USD', 'Hardware store', 'Lowe\'s', '2024-01-17 12:45:00', 'COMPLETED'),
('TXN-016-2024-001', '7777-8888-9999-0000', 'Nicole Garcia', 'DEPOSIT', 3200.00, 'USD', 'Salary deposit', 'Education Dept', '2024-01-15 08:30:00', 'COMPLETED'),
('TXN-016-2024-002', '7777-8888-9999-0000', 'Nicole Garcia', 'TRANSFER', 600.00, 'USD', 'Retirement fund', '401k Account', '2024-01-16 13:00:00', 'COMPLETED'),
('TXN-016-2024-003', '7777-8888-9999-0000', 'Nicole Garcia', 'PAYMENT', 95.00, 'USD', 'Gym membership', 'Fitness Center', '2024-01-17 18:00:00', 'COMPLETED'),
('TXN-017-2024-001', '4444-5555-6666-7777', 'Ryan Wilson', 'DEPOSIT', 1800.00, 'USD', 'Part-time salary', 'Retail Store', '2024-01-15 15:45:00', 'COMPLETED'),
('TXN-017-2024-002', '4444-5555-6666-7777', 'Ryan Wilson', 'WITHDRAWAL', 100.00, 'USD', 'ATM withdrawal', 'Bank Branch', '2024-01-16 10:00:00', 'COMPLETED'),
('TXN-017-2024-003', '4444-5555-6666-7777', 'Ryan Wilson', 'PAYMENT', 60.00, 'USD', 'Pizza delivery', 'Domino\'s', '2024-01-17 22:15:00', 'COMPLETED'),
('TXN-018-2024-001', '2222-3333-4444-5555', 'Stephanie Brown', 'DEPOSIT', 2900.00, 'USD', 'Monthly salary', 'Tech Startup', '2024-01-15 11:00:00', 'COMPLETED'),
('TXN-018-2024-002', '2222-3333-4444-5555', 'Stephanie Brown', 'TRANSFER', 800.00, 'USD', 'Investment fund', 'Mutual Fund', '2024-01-16 14:45:00', 'COMPLETED'),
('TXN-018-2024-003', '2222-3333-4444-5555', 'Stephanie Brown', 'PAYMENT', 140.00, 'USD', 'Car wash', 'Auto Spa', '2024-01-17 09:30:00', 'COMPLETED'),
('TXN-019-2024-001', '8888-9999-0000-1111', 'Brandon Davis', 'DEPOSIT', 2100.00, 'USD', 'Salary deposit', 'Sales Company', '2024-01-15 12:00:00', 'COMPLETED'),
('TXN-019-2024-002', '8888-9999-0000-1111', 'Brandon Davis', 'WITHDRAWAL', 180.00, 'USD', 'Cash withdrawal', 'Bank ATM', '2024-01-16 15:30:00', 'COMPLETED'),
('TXN-019-2024-003', '8888-9999-0000-1111', 'Brandon Davis', 'PAYMENT', 85.75, 'USD', 'Clothing store', 'Macy\'s', '2024-01-17 16:45:00', 'COMPLETED'),
('TXN-020-2024-001', '6666-7777-8888-9999', 'Rachel Green', 'DEPOSIT', 2400.00, 'USD', 'Monthly salary', 'Hospital', '2024-01-15 09:15:00', 'COMPLETED'),
('TXN-020-2024-002', '6666-7777-8888-9999', 'Rachel Green', 'TRANSFER', 400.00, 'USD', 'Savings deposit', 'Savings Account', '2024-01-16 11:45:00', 'COMPLETED'),
('TXN-020-2024-003', '6666-7777-8888-9999', 'Rachel Green', 'PAYMENT', 70.00, 'USD', 'Pharmacy', 'Walgreens', '2024-01-17 14:00:00', 'COMPLETED');

-- Grant permissions to exporter user for the new database and table
GRANT SELECT ON bank_db.* TO 'exporter'@'%';
FLUSH PRIVILEGES;

