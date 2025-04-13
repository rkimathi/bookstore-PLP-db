-- PLP Database class Project by:
    -- Roy
    -- Daniel
    -- David

-- Create the Bookstore Database
CREATE DATABASE IF NOT EXISTS bookstore_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- use the bookstore_db
USE bookstore_db;


-- ***********************************************************
-- Create the Database Tables								 *
-- Book Related Tables										 *
    -- publisher											 *		
    -- book_language										 *
    -- book													 *
    -- author												 *
    -- book_author											 *
-- ***********************************************************

-- Publisher Table
CREATE TABLE IF NOT EXISTS publisher (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL,
    established_date DATE,
    website VARCHAR(255),
    CONSTRAINT uk_publisher_name UNIQUE (publisher_name)
) ENGINE=InnoDB COMMENT='Book publishers information';

-- Book Language Table
CREATE TABLE IF NOT EXISTS book_language (
    language_id INT AUTO_INCREMENT PRIMARY KEY,
    language_code CHAR(2) NOT NULL COMMENT 'ISO 639-1 language code',
    language_name VARCHAR(50) NOT NULL,
    CONSTRAINT uk_language_code UNIQUE (language_code),
    CONSTRAINT uk_language_name UNIQUE (language_name)
) ENGINE=InnoDB COMMENT='Supported languages for books';

-- Book Table
CREATE TABLE IF NOT EXISTS book (
    book_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    title  VARCHAR(100) NOT NULL,
    isbn VARCHAR(13) NOT NULL COMMENT 'International Standard Book Number',
    publisher_id INT NOT NULL,
    language_id INT NOT NULL,
    num_pages SMALLINT UNSIGNED,
    publication_date DATE,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    description TEXT,
    cover_image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_isbn UNIQUE (isbn),
    CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id)
        REFERENCES publisher(publisher_id) ON DELETE RESTRICT,
    CONSTRAINT fk_book_language FOREIGN KEY (language_id)
        REFERENCES book_language(language_id) ON DELETE RESTRICT,
    INDEX idx_book_title (title),
    INDEX idx_book_price (price)
) ENGINE=InnoDB COMMENT='Core book information';

-- Author Table
CREATE TABLE IF NOT EXISTS author (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    biography TEXT,
    INDEX idx_author_name (last_name, first_name)
) ENGINE = InnoDB COMMENT ='Authors Information';

-- book_author
CREATE TABLE IF NOT EXISTS book_author (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_book_author_book FOREIGN KEY (book_id)
        REFERENCES book(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_book_author_author FOREIGN KEY (author_id)
        REFERENCES  author(author_id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Relationship between books and authors';


-- *****************************************************
-- customer and Address tables
    -- country
    -- address
    -- address_status
    -- customer
    -- customer_address
-- ****************************************************

-- country table
CREATE  TABLE IF NOT EXISTS country(
    country_id  INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    country_code CHAR(3) NOT NULL COMMENT 'Alpha-2 code eg. KE, US, UG',
    CONSTRAINT uk_country_name UNIQUE (country_name),
    CONSTRAINT uk_country_code UNIQUE (country_code)
) ENGINE=InnoDB COMMENT='Countries for Address Information';

-- address table
CREATE TABLE IF NOT EXISTS address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    street_number VARCHAR(10),
    street_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country_id INT NOT NULL,
    CONSTRAINT fk_address_country FOREIGN KEY (country_id)
        REFERENCES country(country_id) ON DELETE RESTRICT,
    INDEX idx_address_city (city),
    INDEX idx_address_street (street_name)
) ENGINE=InnoDB COMMENT='Physical Address Information'

-- address_status table
CREATE TABLE IF NOT EXISTS address_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL COMMENT 'e.g Active, Inactive, Primary'
) ENGINE=InnoDB COMMENT='Address Status';

-- customer table
CREATE TABLE IF NOT EXISTS customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    password_hash VARCHAR(255) NOT NULL COMMENT 'stores the users hashed password for security',
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_customer_email UNIQUE (email),
    INDEX idx_customer_name (last_name,first_name),
    INDEX idx_customer_phone (phone)
) ENGINE=InnoDB COMMENT='customer Information';

-- customer_address table
-- A list of addresses for customers. Each customer can have multiple addresses.
CREATE TABLE IF NOT EXISTS customer_address (
    customer_id INT NOT NULL,
    address_id INT NOT NULL,
    status_id INT NOT NULL,
    date_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_to TIMESTAMP NULL COMMENT 'Null denotes current address',
    PRIMARY KEY (customer_id, address_id,status_id),
    CONSTRAINT fk_customer_address_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_customer_address_address FOREIGN KEY (address_id)
        REFERENCES address(address_id) on DELETE CASCADE,
    CONSTRAINT fk_customer_address_status FOREIGN KEY (status_id)
        REFERENCES address_status(status_id) ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='Relationship between Customer and their addresses';

-- Orders Management Tables
    -- shipping_method
    -- order_status
    -- cust_order
    -- order_line
    -- order_history
    -- order_status


-- shipping method table
CREATE TABLE IF NOT EXISTS shipping_method (
    method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name ENUM('Uber Parcel','Bus Drop','Courier Service','Pickup from Shop')  NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    delivery_type ENUM ('same day delivery','following day delivery','pickup') NOT NULL COMMENT 'Same day delivery, Following day delivery,pickup',
    CONSTRAINT uk_method_name UNIQUE (method_name)
) ENGINE=InnoDB COMMENT='Available Shipping Methods';

-- order status table
CREATE TABLE IF NOT EXISTS order_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_value ENUM('received','pending','confirmed','processing','shipped','delivered','collected','cancelled'),
    CONSTRAINT uk_status_value UNIQUE (status_value)
) ENGINE InnoDB COMMENT='Order Statuses'

-- customer order table
CREATE TABLE IF NOT EXISTS cust_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipping_method_id INT NOT NULL,
    shipping_address_id INT NOT NULL,
    order_total DECIMAL(12,2) NOT NULL COMMENT 'Calculated total amount',
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_shipping_method FOREIGN KEY (shipping_method_id)
        REFERENCES shipping_method(method_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_shipping_address FOREIGN KEY (shipping_address_id)
        REFERENCES address(address_id) ON DELETE RESTRICT,
    INDEX idx_order_date (order_date),
    INDEX idx_order_customer (customer_id,order_date)
) ENGINE=InnoDB COMMENT='Customer Order Information';

-- order line table
CREATE TABLE IF NOT EXISTS order_line (
    line_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity SMALLINT NOT NULL DEFAULT 1,
    price DECIMAL(10,2) NOT NULL COMMENT 'Price at time of order',
    CONSTRAINT fk_order_line_order FOREIGN KEY (order_id)
        REFERENCES cust_order(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_order_line_book FOREIGN KEY (book_id)
        REFERENCES book(book_id) ON DELETE RESTRICT,
    INDEX idx_order_line_order (order_id),
    INDEX idx_order_line_book (book_id)
) ENGINE=InnoDB COMMENT='Individual Items within an Order';

-- Order History TABLE
CREATE TABLE IF NOT EXISTS order_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status_id INT NOT NULL,
    status_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    CONSTRAINT fk_order_history_order FOREIGN KEY (order_id)
        REFERENCES cust_order(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_order_history_status FOREIGN KEY (status_id)
        REFERENCES order_status(status_id) ON DELETE RESTRICT,
    INDEX idx_order_history_order(order_id, status_date)
) ENGINE=InnoDB COMMENT='Audit Trail of order status changes';

-- user Management
-- Create application roles
CREATE ROLE 'bookstore_admin', 'bookstore_staff', 'bookstore_customer';

-- Admin user with full access
CREATE USER 'bookstore_admin_user'@'localhost' IDENTIFIED BY 'BookStoreAdmin@123!';
GRANT ALL PRIVILEGES ON bookstore_db.* TO 'bookstore_admin_user'@'localhost';
GRANT 'bookstore_admin' TO 'bookstore_admin_user'@'localhost';

-- Staff user with limited access
CREATE USER 'bookstore_staff_user'@'localhost' IDENTIFIED BY 'SecureStaffPassword456!';
GRANT SELECT, INSERT, UPDATE ON bookstore_db.* TO 'bookstore_staff_user'@'localhost';
GRANT SELECT ON bookstore_db.customer TO 'bookstore_staff_user'@'localhost'; -- Limited customer access
REVOKE DELETE ON bookstore_db.* FROM 'bookstore_staff_user'@'localhost';
GRANT 'bookstore_staff' TO 'bookstore_staff_user'@'localhost';

-- Application user (read/write for orders)
CREATE USER 'bookstore_app'@'%' IDENTIFIED BY 'AppPassword789!';
GRANT SELECT, INSERT, UPDATE ON bookstore_db.cust_order TO 'bookstore_app'@'%';
GRANT SELECT, INSERT, UPDATE ON bookstore_db.order_line TO 'bookstore_app'@'%';
GRANT SELECT, INSERT ON bookstore_db.order_history TO 'bookstore_app'@'%';
GRANT SELECT ON bookstore_db.* TO 'bookstore_app'@'%'; -- Read access to all tables
GRANT 'bookstore_customer' TO 'bookstore_app'@'%';

-- Read-only reporting user
CREATE USER 'bookstore_reporting'@'%' IDENTIFIED BY 'ReportingPassword101!';
GRANT SELECT ON bookstore_db.* TO 'bookstore_reporting'@'%';

-- Set default roles
SET DEFAULT ROLE 'bookstore_admin' TO 'bookstore_admin_user'@'localhost';
SET DEFAULT ROLE 'bookstore_staff' TO 'bookstore_staff_user'@'localhost';
SET DEFAULT ROLE 'bookstore_customer' TO 'bookstore_app'@'%';

FLUSH PRIVILEGES;


-- Insert sample languages
INSERT INTO book_language (language_code, language_name) VALUES
    ('en', 'English'),
    ('sw', 'Swahili');

-- Insert Kenyan publishers
INSERT INTO publisher (publisher_name, established_date, website) VALUES
    ('East African Educational Publishers', '1965-01-01', 'https://www.eastafricanpublishers.com/'),
    ('Longhorn Kenya', '1949-01-01', 'https://www.longhornpublishers.com/'),
    ('Jomo Kenyatta Foundation', '1966-01-01', 'https://www.jkf.co.ke/'),
    ('Mvule Africa Publishers', '2008-01-01', 'https://www.mvuleafricapublishers.com/'),
    ('Storymoja Publishers', '2007-01-01', 'https://storymojaafrica.co.ke/');

-- Insert Kenyan and East African authors
INSERT INTO author (first_name, last_name, birth_date) VALUES
    ('Ngũgĩ', 'wa Thiong''o', '1938-01-05'),      -- Kenya (Renowned novelist & playwright)
    ('Grace', 'Ogot', '1930-05-15'),             -- Kenya (Pioneering female writer)
    ('Meja', 'Mwangi', '1948-12-02'),            -- Kenya (Award-winning novelist)
    ('Okot', 'p''Bitek', '1931-06-07'),          -- Uganda (Poet & cultural critic)
    ('Mariama', 'Ba', '1929-04-17'),             -- Senegal (Though not East African, influential in African lit)
    ('Chimamanda', 'Ngozi Adichie', '1977-09-15'),-- Nigeria (Widely read across Africa)
    ('Petina', 'Gappah', '1971-01-01'),          -- Zimbabwe (Contemporary author)
    ('Binyavanga', 'Wainaina', '1971-01-18'),    -- Kenya (Essayist & memoirist)
    ('Yvonne', 'Adhiambo Owuor', '1968-01-01'),  -- Kenya (Award-winning novelist)
    ('Abdulrazak', 'Gurnah', '1948-12-20');      -- Tanzania (Nobel Prize winner, based in UK)

-- Insert books by Kenyan and East African authors
INSERT INTO book (title, isbn, publisher_id, language_id, num_pages, publication_date, price, stock_quantity) VALUES
    ('Petals of Blood', '9780143106764', 1, 1, 384, '1977-01-01', 14.99, 30),               -- Ngũgĩ wa Thiong'o
    ('Weep Not, Child', '9780143106696', 1, 1, 160, '1964-01-01', 10.99, 40),              -- Ngũgĩ wa Thiong'o
    ('The Promised Land', '9789966255031', 2, 1, 180, '1966-01-01', 12.50, 25),            -- Grace Ogot
    ('Song of Lawino', '9780852555532', 3, 1, 192, '1966-01-01', 11.99, 35),               -- Okot p'Bitek
    ('Dust', '9781476773912', 4, 1, 368, '2014-01-01', 16.00, 20),                        -- Yvonne Adhiambo Owuor
    ('One Day I Will Write About This Place', '9781555975913', 5, 1, 256, '2011-01-01', 13.95, 30), -- Binyavanga Wainaina
    ('Paradise', '9781565841635', 1, 1, 256, '1994-01-01', 15.99, 25),                     -- Abdulrazak Gurnah
    ('The River and The Source', '9780195737757', 2, 1, 320, '1994-01-01', 12.75, 40),      -- Margaret Ogola (Bonus Kenyan author)
    ('Kintu', '9781941920263', 3, 1, 446, '2014-01-01', 18.50, 20);                       -- Jennifer Nansubuga Makumbi (Ugandan)


-- Assign authors to their books (matching Kenyan/East African works)
INSERT INTO book_author (book_id, author_id) VALUES
    (1, 1),   -- 'Petals of Blood' → Ngũgĩ wa Thiong'o
    (2, 1),   -- 'Weep Not, Child' → Ngũgĩ wa Thiong'o
    (3, 2),   -- 'The Promised Land' → Grace Ogot
    (4, 4),   -- 'Song of Lawino' → Okot p'Bitek
    (5, 9),   -- 'Dust' → Yvonne Adhiambo Owuor
    (6, 8),   -- 'One Day I Will Write...' → Binyavanga Wainaina
    (7, 10),  -- 'Paradise' → Abdulrazak Gurnah
    (8, 11),  -- 'The River and The Source' → Margaret Ogola (assuming author_id 11 was added)
    (9, 12);  -- 'Kintu' → Jennifer Nansubuga Makumbi (assuming author_id 12 was added)

-- Active customer view
CREATE VIEW active_customers AS
SELECT customer_id, first_name, last_name, email, registration_date
FROM customer
WHERE is_active = TRUE;

-- Book inventory view
CREATE VIEW book_inventory AS
SELECT b.book_id, b.title, b.isbn, a.first_name, a.last_name,
       b.price, b.stock_quantity,
       CASE
           WHEN b.stock_quantity > 10 THEN 'In Stock'
           WHEN b.stock_quantity > 0 THEN 'Low Stock'
           ELSE 'Out of Stock'
           END AS stock_status
FROM book b
         LEFT JOIN book_author ba ON b.book_id = ba.book_id
         LEFT JOIN author a ON ba.author_id = a.author_id;

-- Order summary view
CREATE VIEW order_summary AS
SELECT o.order_id, c.first_name, c.last_name, o.order_date,
       o.order_total, os.status_value AS current_status,
       sm.method_name AS shipping_method
FROM cust_order o
         JOIN customer c ON o.customer_id = c.customer_id
         JOIN order_history oh ON o.order_id = oh.order_id
         JOIN order_status os ON oh.status_id = os.status_id
         JOIN shipping_method sm ON o.shipping_method_id = sm.method_id
WHERE oh.status_date = (
    SELECT MAX(status_date)
    FROM order_history
    WHERE order_id = o.order_id
);