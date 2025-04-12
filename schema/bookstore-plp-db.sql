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