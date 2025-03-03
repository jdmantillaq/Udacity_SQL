# SQL for Data Analysis – Udacity Exercises

This repository contains solutions to the exercises from the [SQL for Data Analysis](https://www.udacity.com/course/sql-for-data-analysis--ud198) course on Udacity. These exercises are designed to strengthen SQL skills for data analysis.

## Database

The database used in the exercises is located at `database/parch-and-posey.sql`.

To locally install the database, follow these steps:

1. Ensure you have PostgreSQL installed on your machine. You can download it from [here](https://www.postgresql.org/download/).

2. Open your terminal and create a new database:
    ```sh
    createdb parch_and_posey
    ```

3. Import the SQL file into the newly created database:
    ```sh
    psql -d parch_and_posey -f database/parch-and-posey.sql
    ```

4. Verify the database has been imported correctly by connecting to it:
    ```sh
    psql parch_and_posey
    ```

You should now have the `parch_and_posey` database set up and ready for use with the exercises.


## Lesson

- [**Lesson1**: Basic SQL queries and operations](1.Basic_SQL.md)
- [**Lesson2**: SQL joins](2.SQL_Joins.md)
- [**Lesson3**: SQL for data aggregation and summarization.](3.SQL_Aggregation.md)
- [**Lesson4**: SQL Subqueries & Temporary Tables.](4.SQL_Subquery.md)
- [**Lesson5**: SQL Data Cleaning.](5.SQL_Data_Cleaning.md)
- [**Lesson6**: SQL Window Functions.](6.SQL_Window_Functions.md)
- [**Lesson7**: SQL Advanced JOINs & Performance Tuning.](7.SQL_Advanced_JOINs.md)



Each folder contains SQL scripts and example datasets used in the exercises.

Happy learning!