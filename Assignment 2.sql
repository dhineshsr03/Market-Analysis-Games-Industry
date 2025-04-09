CREATE DATABASE DA_Assignment_2

USE DA_Assignment_2

--Tasks
--1. Complec Queries
-- A. Write a query to find the top 5 platforms with the highest average user ratings

SELECT TOP 5 Platform, AVG(User_Rating) AS Avg_Rating
FROM dbo.games_dataset
GROUP BY Platform
ORDER BY Avg_Rating DESC;

--B. Use Common Table Expressions (CTEs) to calculate the average user rating for each
--genre and identify genres with an average rating above a certain threshold.

WITH GenreRatings AS (
    SELECT Genre, AVG(User_Rating) AS Avg_Rating
    FROM dbo.games_dataset
    GROUP BY Genre
)
SELECT Genre, Avg_Rating
FROM GenreRatings
WHERE Avg_Rating > 4.0;  

--2. Stored Procedures:
--Create a stored procedure to categorize games into 'High', 'Medium', and 'Low' ratings
--based on their user ratings and update the dataset accordingly.--Creating column named Rating category ALTER TABLE dbo.games_dataset 
ADD Rating_Category NVARCHAR(20);  



-- Create the stored procedure
CREATE PROCEDURE dbo.Categorize_Games
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Ensure the column exists before updating
    IF COL_LENGTH('dbo.games_dataset', 'Rating_Category') IS NOT NULL
    BEGIN
        UPDATE dbo.games_dataset
        SET Rating_Category = 
            CASE 
                WHEN User_Rating >= 4.5 THEN 'High'
                WHEN User_Rating >= 3.0 THEN 'Medium'
                ELSE 'Low'
            END;
    END
END;
GO

--Execute stored Procedure
EXEC dbo.Categorize_Games;



SELECT *
FROM 
dbo.games_dataset;

/*
Drop the procedure if it exists
IF OBJECT_ID('dbo.Categorize_Games', 'P') IS NOT NULL
    DROP PROCEDURE dbo.Categorize_Games;
GO
*/


--3. Triggers:
--Write a trigger to automatically update the 'User Rating' column to a default value when
--a new game is inserted into the table without a specified rating.
CREATE TRIGGER dbo.Set_Default_Rating
ON dbo.games_dataset
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update rows where User_Rating is NULL
    UPDATE g
    SET g.User_Rating = 3.5 -- Default value
    FROM dbo.games_dataset g
    INNER JOIN inserted i ON g.Game_Name = i.Game_Name
    WHERE i.User_Rating IS NULL;
END;
GO
--With User_Rating=Null Value
INSERT INTO dbo.games_dataset (Game_Name, Genre,Platform, Release_Year, User_Rating)
VALUES ('New Game', 'Action', 'PC', 2024, NULL);

--Output: 
--Cannot insert the value NULL into column 'User_Rating', table 'DA_Assignment_2.dbo.games_dataset'; column does not allow nulls. INSERT fails.

--With User_Rating=Value
INSERT INTO dbo.games_dataset (Game_Name, Genre,Platform, Release_Year, User_Rating)
VALUES ('New Game', 'Action', 'PC', 2024, 3.5);

SELECT * FROM dbo.games_dataset WHERE Game_Name = 'New Game'

--Deleting Added Rows
DELETE FROM dbo.games_dataset
WHERE Game_Name = 'New Game' AND Platform = 'PC';

--Drop the trigger if it already exists to avoid conflicts
/*
IF OBJECT_ID('dbo.Set_Default_Rating', 'TR') IS NOT NULL
    DROP TRIGGER dbo.Set_Default_Rating;
GO
*/


--4. Views:
--Create a view to display games with complete rating information and filter out games
--with missing data.

CREATE VIEW dbo.Complete_Ratings AS
SELECT * 
FROM dbo.games_dataset
WHERE User_Rating IS NOT NULL;
GO


--Execute View
SELECT * FROM dbo.Complete_Ratings;

/*
IF OBJECT_ID('dbo.Complete_Ratings', 'V') IS NOT NULL
    DROP VIEW dbo.Complete_Ratings;
GO
*/