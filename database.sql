-- ==============================================================================
-- TELECOM CUSTOMER DATABASE MANAGEMENT SYSTEM
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS telecom_db;
USE telecom_db;

-- ------------------------------------------------------------------------------
-- 1. TABLES CREATION
-- ------------------------------------------------------------------------------

-- Admins Table
CREATE TABLE admins (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'Admin'
);

-- Regions Table
CREATE TABLE regions (
    region_id INT PRIMARY KEY AUTO_INCREMENT,
    region_name VARCHAR(100) NOT NULL UNIQUE,
    state VARCHAR(100) NOT NULL
);

-- Towers Table (Many-to-One with Regions)
CREATE TABLE towers (
    tower_id INT PRIMARY KEY AUTO_INCREMENT,
    region_id INT,
    tower_location VARCHAR(255) NOT NULL,
    signal_strength VARCHAR(50) DEFAULT 'Good',
    status ENUM('Active', 'Maintenance', 'Down') DEFAULT 'Active',
    downtime_minutes INT DEFAULT 0,
    FOREIGN KEY (region_id) REFERENCES regions(region_id) ON DELETE SET NULL
);

-- Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    email VARCHAR(100) UNIQUE,
    address TEXT,
    aadhar_number VARCHAR(12) UNIQUE NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Active', 'Inactive') DEFAULT 'Active'
);

-- SIM Cards Table (Many-to-One with Customers)
CREATE TABLE sim_cards (
    sim_number VARCHAR(20) PRIMARY KEY,
    customer_id INT,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    sim_type ENUM('Prepaid', 'Postpaid') NOT NULL,
    network_type ENUM('4G', '5G') DEFAULT '4G',
    issue_date DATE NOT NULL,
    status ENUM('Active', 'Blocked', 'Deactivated') DEFAULT 'Active',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- Recharge Plans Table
CREATE TABLE recharge_plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(100) NOT NULL,
    plan_type ENUM('Prepaid', 'Postpaid') NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    validity_days INT NOT NULL,
    data_limit_gb DECIMAL(10, 2),
    sms_limit INT,
    call_limit_minutes INT
);

-- Recharges History Table
CREATE TABLE recharges (
    recharge_id INT PRIMARY KEY AUTO_INCREMENT,
    sim_number VARCHAR(20),
    plan_id INT,
    recharge_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATE NOT NULL,
    payment_mode ENUM('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Cash') NOT NULL,
    status ENUM('Success', 'Failed', 'Pending') DEFAULT 'Success',
    FOREIGN KEY (sim_number) REFERENCES sim_cards(sim_number),
    FOREIGN KEY (plan_id) REFERENCES recharge_plans(plan_id)
);

-- Call Records Table
CREATE TABLE call_records (
    call_id INT PRIMARY KEY AUTO_INCREMENT,
    caller_sim VARCHAR(20),
    receiver_number VARCHAR(15) NOT NULL,
    call_type ENUM('Incoming', 'Outgoing') NOT NULL,
    duration_seconds INT NOT NULL,
    call_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    call_charge DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (caller_sim) REFERENCES sim_cards(sim_number)
);

-- Data Usage Table
CREATE TABLE data_usage (
    usage_id INT PRIMARY KEY AUTO_INCREMENT,
    sim_number VARCHAR(20),
    usage_date DATE NOT NULL,
    data_consumed_mb DECIMAL(10, 2) NOT NULL,
    speed_category ENUM('2G', '3G', '4G', '5G') DEFAULT '4G',
    FOREIGN KEY (sim_number) REFERENCES sim_cards(sim_number)
);

-- Bills Table (For Postpaid)
CREATE TABLE bills (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    sim_number VARCHAR(20),
    billing_month VARCHAR(20) NOT NULL,
    amount_due DECIMAL(10, 2) NOT NULL,
    gst_amount DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    due_date DATE NOT NULL,
    status ENUM('Paid', 'Unpaid', 'Overdue') DEFAULT 'Unpaid',
    FOREIGN KEY (sim_number) REFERENCES sim_cards(sim_number)
);

-- Payments Table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    bill_id INT,
    amount_paid DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('UPI', 'Credit Card', 'Debit Card', 'Net Banking') NOT NULL,
    FOREIGN KEY (bill_id) REFERENCES bills(bill_id)
);

-- ------------------------------------------------------------------------------
-- 2. VIEWS (Advanced SQL)
-- ------------------------------------------------------------------------------

-- View: Customer detailed information
CREATE VIEW view_customer_details AS
SELECT 
    c.customer_id, c.first_name, c.last_name, c.status AS customer_status,
    s.phone_number, s.sim_type, s.network_type, s.status AS sim_status
FROM 
    customers c
LEFT JOIN 
    sim_cards s ON c.customer_id = s.customer_id;

-- View: Region-wise network performance
CREATE VIEW view_region_performance AS
SELECT 
    r.region_name,
    COUNT(t.tower_id) AS total_towers,
    SUM(CASE WHEN t.status = 'Active' THEN 1 ELSE 0 END) AS active_towers,
    SUM(t.downtime_minutes) AS total_downtime
FROM 
    regions r
LEFT JOIN 
    towers t ON r.region_id = t.region_id
GROUP BY 
    r.region_id;

-- ------------------------------------------------------------------------------
-- 3. STORED PROCEDURES
-- ------------------------------------------------------------------------------

-- Procedure: Generate Bill for Postpaid Customer
DELIMITER //
CREATE PROCEDURE GeneratePostpaidBill(
    IN p_sim_number VARCHAR(20),
    IN p_month VARCHAR(20),
    IN p_base_amount DECIMAL(10,2)
)
BEGIN
    DECLARE v_gst DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    
    SET v_gst = p_base_amount * 0.18; -- 18% GST
    SET v_total = p_base_amount + v_gst;
    
    INSERT INTO bills (sim_number, billing_month, amount_due, gst_amount, total_amount, due_date)
    VALUES (p_sim_number, p_month, p_base_amount, v_gst, v_total, DATE_ADD(CURDATE(), INTERVAL 15 DAY));
END //
DELIMITER ;

-- ------------------------------------------------------------------------------
-- 4. TRIGGERS
-- ------------------------------------------------------------------------------

-- Trigger: Automatically update customer status if all their SIMs are deactivated
DELIMITER //
CREATE TRIGGER AfterSimDeactivation
AFTER UPDATE ON sim_cards
FOR EACH ROW
BEGIN
    DECLARE active_sims INT;
    
    IF NEW.status = 'Deactivated' THEN
        SELECT COUNT(*) INTO active_sims FROM sim_cards 
        WHERE customer_id = NEW.customer_id AND status = 'Active';
        
        IF active_sims = 0 THEN
            UPDATE customers SET status = 'Inactive' WHERE customer_id = NEW.customer_id;
        END IF;
    END IF;
END //
DELIMITER ;

-- ------------------------------------------------------------------------------
-- 5. SAMPLE DATA INSERTION
-- ------------------------------------------------------------------------------

-- Admin
INSERT INTO admins (username, password, role) VALUES ('admin', 'admin123', 'SuperAdmin');

-- Regions
INSERT INTO regions (region_name, state) VALUES 
('Mumbai Central', 'Maharashtra'),
('Bangalore South', 'Karnataka'),
('Delhi NCR', 'Delhi');

-- Towers
INSERT INTO towers (region_id, tower_location, signal_strength, status) VALUES 
(1, 'Andheri West', 'Excellent', 'Active'),
(2, 'Koramangala', 'Good', 'Active'),
(3, 'Connaught Place', 'Excellent', 'Active');

-- Plans
INSERT INTO recharge_plans (plan_name, plan_type, price, validity_days, data_limit_gb, sms_limit, call_limit_minutes) VALUES 
('Hero Unlimited', 'Prepaid', 299.00, 28, 1.5, 100, 99999),
('Data Saver', 'Prepaid', 199.00, 28, 1.0, 100, 99999),
('Family Postpaid', 'Postpaid', 999.00, 30, 100.0, 3000, 99999);

-- Customers
INSERT INTO customers (first_name, last_name, dob, email, address, aadhar_number) VALUES 
('Rahul', 'Sharma', '1995-05-14', 'rahul@example.com', 'Mumbai, MH', '123456789012'),
('Priya', 'Singh', '1998-08-22', 'priya@example.com', 'Bangalore, KA', '987654321098');

-- SIM Cards
INSERT INTO sim_cards (sim_number, customer_id, phone_number, sim_type, network_type, issue_date) VALUES 
('8991000000000001', 1, '9876543210', 'Prepaid', '5G', '2023-01-10'),
('8991000000000002', 2, '8765432109', 'Postpaid', '4G', '2023-02-15');

-- Recharges
INSERT INTO recharges (sim_number, plan_id, expiry_date, payment_mode) VALUES 
('8991000000000001', 1, '2024-06-15', 'UPI');

-- Call Records
INSERT INTO call_records (caller_sim, receiver_number, call_type, duration_seconds) VALUES 
('8991000000000001', '9999999999', 'Outgoing', 120),
('8991000000000002', '8888888888', 'Incoming', 300);

-- Data Usage
INSERT INTO data_usage (sim_number, usage_date, data_consumed_mb, speed_category) VALUES 
('8991000000000001', CURDATE(), 500.5, '5G'),
('8991000000000002', CURDATE(), 200.0, '4G');
