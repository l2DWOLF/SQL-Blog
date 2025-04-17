# Simple SQL Blog Management - PostgreSQL

This repository contains SQL scripts for managing a simple blog using PostgreSQL. 
It includes user management, post management, and comment functionality.

## Features

* **User Management:**
    * User registration and profiles.
    * Password hashing using `pgcrypto`'s `crypt()` and `gen_salt()`.
    * Users CRUD
* **Blog Management:**
    * Post creation and management.
    * Comment creation and management.
    * User groups and permissions.
* **Queries:**
    * Various SELECT CRUD queries for viewing users, posts, and comments.
    * Search function for posts.
    * Aggregation functions for post and comment statistics.
* **Data Integrity:**
    * Foreign key constraints to maintain relationships between tables.
    * Unique constraints to prevent duplicate data.

## Requires 

* PostgreSQL installed and running.
* `pgcrypto` extension enabled (run `CREATE EXTENSION IF NOT EXISTS pgcrypto;` in your database).

## Setup

1.  **Clone the Repository:**
    ```bash
    git clone [repository URL]
    cd [repository directory]
    ```
2.  **Create the Database:**
    * Create a new PostgreSQL database.
3.  **Run the SQL Scripts:**
    * Use `psql` or your preferred PostgreSQL client to execute the SQL scripts in the following order:
        1.  Run the main SQL script.
        2.  You may run the queries separately.
    * Example using `psql`:
        ```bash
        psql -d [your_database_name] -f [your_sql_file.sql]
        ```
## Usage

* The SQL scripts provide examples of creating, reading, updating, and deleting data.
* Use the provided SELECT queries to view data.
* Modify the UPDATE and DELETE queries as needed.
* The aggregation query provides useful statistics about the blog posts and comments.

## Security Notes

* Passwords are hashed using `pgcrypto`'s `crypt()` and `gen_salt()`.
* Always use strong passwords and secure your database.
* Input sanitization and parameterized queries are recommended for any application using this database.

## Future Improvements

* Implement application-level password hashing for better security.
* Add indexes to improve query performance.
* Add more comprehensive error handling.
* Input sanitization and parameterized queries.
* Add more robust search functionality using PostgreSQL's full-text search.
* Refactor and normalize the database schema further.
* Add a test suite.

## Database Schema

* **Users:**
    * `UserID` (SERIAL PRIMARY KEY)
    * `Username` (VARCHAR(33) UNIQUE NOT NULL)
    * `CREATED_AT` (DATE DEFAULT NOW() NOT NULL)
* **UserProfiles:**
    * `UserProfileID` (SERIAL PRIMARY KEY)
    * `UserFullName` (VARCHAR(32) NOT NULL)
    * `Phone` (VARCHAR(20) UNIQUE)
    * `Email` (VARCHAR(128) UNIQUE NOT NULL)
    * `UserPassword` (VARCHAR(64) NOT NULL) - Hashed password.
    * `UserID` (INTEGER UNIQUE, FOREIGN KEY to Users)
* **Posts:**
    * `PostID` (SERIAL PRIMARY KEY)
    * `PostTitle` (VARCHAR(64) NOT NULL)
    * `PostContent` (VARCHAR(1028) UNIQUE NOT NULL)
    * `UserID` (INTEGER NOT NULL, FOREIGN KEY to Users)
    * `Created` (TIMESTAMP DEFAULT NOW() NOT NULL)
* **BlogComments:**
    * `CommentID` (SERIAL PRIMARY KEY)
    * `CommentContent` (VARCHAR(256) NOT NULL)
    * `PostID` (INTEGER NOT NULL, FOREIGN KEY to Posts)
    * `UserID` (INTEGER NOT NULL, FOREIGN KEY to Users)
    * `Created` (TIMESTAMP DEFAULT NOW() NOT NULL)
* **BlogGroups:**
    * `GroupID` (SERIAL PRIMARY KEY)
    * `GroupName` (VARCHAR(25) UNIQUE NOT NULL)
* **UserGroups:**
    * `UserGroupID` (SERIAL PRIMARY KEY)
    * `UserID` (INTEGER NOT NULL, FOREIGN KEY to Users)
    * `GroupID` (INTEGER NOT NULL, FOREIGN KEY to BlogGroups)


## License

[Your License (e.g., MIT, Apache 2.0)]