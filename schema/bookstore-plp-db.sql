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

-- Create the Database Tables
-- Book Related Tables
    -- publisher
    -- book_language
    -- book
    -- author
    -- book_author


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
