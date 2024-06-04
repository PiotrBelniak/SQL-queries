# Differences of sales across different time periods
## Introduction
These simple queries calculate, for each product separately, what was the sales difference both in value and percent-wise year-to-year and period-to-period, where our period is either month or quarter.
Third query additionally selects 2 years, for each month, where monthly sales year-to-year difference was the greatest.

## Source code
Please find link to source code of query: [query code](https://github.com/PiotrBelniak/SQL-queries/blob/main/source_code/differences_of_sales_across_different_time_periods.sql)

## Description of queries
1. First of our queries(lines 1-12) calculates quarterly sales along with differences year-to-year for each quarter and quarter-to-quarter.  
   To get all necessary information, we need to join our fact table with two dimensions: product and calendar. We join tables using primary key-foreign key columns.  
   Because our fact table has daily sales information, we need to aggregate to the quarter level; therefore we perform group by product name, year and quarter.  
   Since calendar table does not keep quarter number information, but year-quarter concatenation, we need to use SUBSTR function on quarter_id - this function is used multiple times across query.  
   a) Quarterly sales is simple to get - we use SUM aggregate on quantity multiplied by price, which will calculate on product and quarter levels.  
   b) To obtain quarterly sales from previous quarter, we use analytic function LAG with offset 1, where we divide our data set by product name and sort by year and quarter.
   Then we nest inside the LAG function aggregate SUM, which will calculate sales value accordingly with our group by specification.  
   c) To obtain quarterly sales from previous year, we use SUM aggregate nested inside LAG analytic function.  
   The only difference is division and sort specification: here we divide data set by both product name and quarter, our sorting is only by year.  
   Having all necessary information, we can proceed to calculate 4 new columns: year-to-year difference in value, year-to-year difference in percents,
   quarter-to-quarter difference in value and quarter-to-quarter difference in percents.
  - year-to-year difference in percent combines results a) and c) using following formula: (a-c)/c*100
  - year-to-year difference in value is result of subtracting result c) from result a)
  - quarter-to-quarter difference in percent combines results a) and b) using following formula: (a-b)/b*100
  - quarter-to-quarter difference in value is result of subtracting result b) from result a)  
  Worth noting is the fact all calculations are performed at once: that is why we cannot refer to quarterly sales and quarter number using aliases.
  If we wanted to improve query readability, we would need to use subquery, where in the inner part we would only calculate monthly sales and derive quarter number.
2. Second of our queries(lines 15-26) is very similar to first query - the only difference is we specify months instead quarters by using SUBSTR function on column month_id instead of quarter_id.
3. Third query(lines 28-51) is extension of query number 2.  
   Lines 37-48 are the copy of second query.
   In the middle level of subquery nesting we use RANK function to perform ranking of year-to-year differences of monthly sales. 
   Since we would like to know for each month, what year was best and second best compared to year before, we divide data set by product name and month.
   To properly rank our year-to-year differences, our sort specification is by that value in descending order. We want greatest positive difference to have rank 1.
   The outer query uses previous results to filter only those years that were ranked 1 or 2.  
   Due to the fact analytic functions are calculated after where clause is resolved in query we cannot use RANK function in where clause.


## Example of results
Query nr 1:  
![obraz](https://github.com/PiotrBelniak/SQL-queries/assets/169681378/cc58c464-8dd0-4883-b281-72b17de436d1)


Query nr 2:  
![obraz](https://github.com/PiotrBelniak/SQL-queries/assets/169681378/305982b1-feb1-44ee-a5c5-f9d302c1055e)


Query nr 3:  
![obraz](https://github.com/PiotrBelniak/SQL-queries/assets/169681378/8b31534b-f848-406e-9c4b-dcde7fa1f771)
