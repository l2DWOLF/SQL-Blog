CREATE EXTENSION IF NOT EXISTS pgcrypto;
---------------------------------------------
-------------Users Management----------------
---------------------------------------------
DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS UserProfiles CASCADE;

CREATE TABLE Users(
	UserID SERIAL PRIMARY KEY,
	Username varchar(33) NOT NULL UNIQUE,
	CREATED_AT DATE DEFAULT NOW() NOT NULL
);

CREATE TABLE UserProfiles(
	UserProfileID SERIAL PRIMARY KEY,
	UserFullName VARCHAR(32) NOT NULL,
	Phone VARCHAR(20) NULL UNIQUE,
	Email VARCHAR(128) NOT NULL UNIQUE, 
	UserPassword VARCHAR(64) NOT NULL,
	UserID INTEGER UNIQUE,
	FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

--------CREATE - Data Input--------
INSERT INTO Users(Username)
VALUES ('Moderator-Admin-Jill'), ('EditorJoe'), ('AdminJack'), ('UserBill'), ('DeletedJames');

INSERT INTO UserProfiles(UserID, Email, UserPassword, UserFullName)
VALUES (1, 'Jill@blog.com', crypt('HashedPass123', gen_salt('bf')), 'Simple Jill'), 
		(2, 'Joe@blog.com', crypt('HashedPass123', gen_salt('bf')), 'Every Joe'),
		(3, 'Jack@blog.com', crypt('HashedPass123', gen_salt('bf')), 'Complex Jack'),
		(4, 'Bill@blog.com', crypt('HashedPass123', gen_salt('bf')), 'Average Bill'),
		(5, 'DeletedJames@blog.com', '000', 'Deleted James');

------READ - Viewing Queries------
SELECT UserID, UserFullName, Username, Email, Phone, UserProfileID, 
		CREATED_AT, UserPassword AS Hashed_Password
FROM Users 
JOIN UserProfiles USING(UserID) 
ORDER BY UserID ASC;

------UPDATE - Update Queries------
UPDATE UserProfiles
SET Email = 'SimplyJill@blog.com'
WHERE UserID = 1;

------DELETE - Delete Queries------
DELETE FROM Users
WHERE UserID = 5;

---------------------------------------------
--------------Blog Management----------------
---------------------------------------------
DROP TABLE IF EXISTS Posts CASCADE;
DROP TABLE IF EXISTS BlogComments CASCADE;
DROP TABLE IF EXISTS BlogGroups CASCADE;
DROP TABLE IF EXISTS UserGroups CASCADE;

CREATE TABLE Posts(
	PostID SERIAL PRIMARY KEY,
	PostTitle VARCHAR(64) NOT NULL,
	PostContent VARCHAR(1028) NOT NULL UNIQUE,
	UserID INTEGER NOT NULL,
	Created TIMESTAMP DEFAULT Now() NOT NULL,
	FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

CREATE TABLE BlogComments(
	CommentID SERIAL PRIMARY KEY,
	CommentContent VARCHAR(256) NOT NULL,
	PostID INTEGER NOT NULL,
	UserID INTEGER NOT NULL,
	Created TIMESTAMP DEFAULT Now() NOT NULL,
	FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE,
	FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

CREATE TABLE BlogGroups(
	GroupID SERIAL PRIMARY KEY,
	GroupName VARCHAR(25) NOT NULL UNIQUE
);

CREATE TABLE UserGroups(
	UserGroupID SERIAL PRIMARY KEY,
	UserID INTEGER NOT NULL,
	GroupID INTEGER NOT NULL,
	FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
	FOREIGN KEY (GroupID) REFERENCES BlogGroups(GroupID) ON DELETE CASCADE
);

--------CREATE - Data Input--------
INSERT INTO BlogGroups(GroupName)
VALUES ('User'), ('Moderator'), ('Editor'), ('Admin');

INSERT INTO Posts(PostTitle, PostContent, UserID)
VALUES ('First Post', 'This is the First Post', 2),
		('First Post', 'This is a Duplicate of the First Post, Same Title, Unique Content Constraint', 2),
		('Third Post', 'The 3rd Post Content', 3), 
		('1st Author Post', '4th Post Content', 1),
		('5th Post', '5th Post', 3), ('6th Post', '6th 327', 4);

INSERT INTO BlogComments(CommentContent, PostID, UserID)
VALUES ('1st Comment - 1st Post, 1st User', 1, 1), ('2nd Comment - 1st Post, 1st User', 1, 1),
		('3rd Comment - 2nd Post, 1st User', 2, 1), ('4th Comment - 2nd Post, 2nd User', 2, 2),
		('5th Comment - 3rd Post, 1st User', 3, 1), ('6th Comment - 3rd Post, 2nd User', 3, 2),
		('7th Comment - 3rd Post, 3rd User', 3, 3), ('8th Short Comment', 4, 2),
		('9th Short', 5, 2), ('10th Deleted', 5, 4);

INSERT INTO UserGroups(UserID, GroupID)
VALUES (1, 2), (1, 4), (2, 3), (3, 4), (4, 1); 

------READ - Viewing Queries------

--Display All Blog Users & Assigned Groups--
SELECT * FROM UserGroups
JOIN Users USING (UserID)
JOIN BlogGroups USING (GroupID)
JOIN UserProfiles USING (UserID);

--Display All Blog Posts-- 
SELECT * FROM Posts
JOIN BlogComments USING(PostID);

--Display All Blog Comments-- 
SELECT CommentID, UserID AS Commenter_ID, PostID AS Post_ID,
		CommentContent AS Comment_Content, Created AS Comment_Date,
		Username AS Commenter_Username
FROM BlogComments
JOIN Users USING (UserID)
ORDER BY CommentID;

--Search Posts--
SELECT *
FROM Posts
WHERE PostTitle LIKE '%SearchQuery%'
OR PostContent LIKE '%6th%';

------UPDATE - Update Queries------
UPDATE Posts
SET PostTitle = 'The 4th'
WHERE PostID = 5;

------DELETE - Delete Queries------
DELETE FROM BlogComments
WHERE CommentID = 10;

-------------Aggregation Functions---------------
----Display All Posts, Comments + Aggregation Functions----
-----------COUNT, MIN, MAX, AVG, SUM-------------
SELECT  
		Posts.PostID, BlogComments.CommentID, Posts.UserID AS PostAuthorID, 
		BlogComments.UserID AS CommenterUserID,
		Users.Username AS CommenterUserName, Posts.PostTitle, Posts.PostContent, 
		BlogComments.CommentContent,
		(SELECT COUNT (DISTINCT PostID) FROM Posts) AS TotalPosts,
		MIN(LENGTH(Posts.PostContent)) OVER () AS ShortestPostLength,
		MAX(LENGTH(Posts.PostContent)) OVER () AS LongestPostLength,
		ROUND(COALESCE(AVG(LENGTH(BlogComments.CommentContent)) 
		OVER (PARTITION BY Posts.PostID), 0), 2) AS AverageCommentLength_PerPost,
		SUM(LENGTH(Posts.PostContent)) OVER () AS TotalCharsInAllPosts,
		Posts.Created AS Post_Date, BlogComments.Created AS Comment_Date
FROM Posts
LEFT JOIN BlogComments ON Posts.PostID = BlogComments.PostID
JOIN Users ON Users.UserID = Posts.UserID
ORDER BY Posts.PostID, BlogComments.CommentID, Posts.UserID;

------------------------------------------------------------------