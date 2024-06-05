# Various simple relational analytics queries
## Introduction
These small collection of queries performs simple operations on data.

## Source code
Please find link to source code of queries: [query code](https://github.com/PiotrBelniak/SQL-queries/blob/main/source_code/relational_analitycs_queries.sql)

## Description of queries
1. First query(lines 1-7) performs approximated ranking based on approximated sum of sales value.
   To perform this query, we need to join our fact table with two dimensions: time and product.
   Next, we will group by name and month to obtain monthly sales for each product separately.
   To get approximated sum, we use APPROX_SUM function. It is aggregate function as SUM, but it sacrifices exactness for performance.
   Last step is select only 10 best months. To do it, we include having clause and use approx_rank function as condition.  
   On the right side of condition we write down the number we want, but the condition must be of <= type.
   In approx_rank function we specify partition by clause - here we use name and sort specification - here we use approximate aggregate function APPROX_SUM.
2. Second query(lines 9-17) divides quarterly sales of single products into tertiles.
   We perform the same joins as in previous query. Grouping is different: instead of grouping by month, here we group by quarter.  
   To divide quarters into tertiles, we need to use NTILE(10) function. Since we want each product to be treated separately, we specify partition by name.  
   For NTILE to work correctly we need sort specification: here we use aggregate function SUM and we sort in descending order.
   Last thing we do is select name column, derive quarter number from quarter identifier using SUBSTR function and calculate quarterly sales using SUM function.
3. Last query(lines 19-35) calculate percentages of product group monthly sales over all products groups and tells us, what was the sales contribution of every product group for the month it had best sales.  
   We perform the same join as previously. The group by clause consists of product type and month. 
   To get best month sales, we will nest SUM within MAX. In MAX, we specify only parition by clause - this is called reporting function. Here we divide data set by product type.
   The most important function we use is ratio_to_report, which calculate percentage of column value against specified grouping.  
   Because we want to know, how product group contributed for a month, we include month_id in partition by clause.
   In the outer query we select product type, month, monthly sales value and calculate retrieve in inner query percentage rounded to 2 decimal points.  
   Since we want contribution shown only for best sales month for each product type, we include where clause with condition monthly sales = best months sales.

## Example of results
Query nr 1:  
![obraz](https://github.com/PiotrBelniak/SQL-queries/assets/169681378/f144b98d-41c7-4e0e-bbb9-2961e3445a7b)  
Query nr 2:  
![obraz](https://github.com/PiotrBelniak/SQL-queries/assets/169681378/c718bb0c-1fe1-47dc-a951-9a56b6279e58)  
Query nr 3:  
![obraz](https://github.com/PiotrBelniak/SQL-queries/assets/169681378/871cb52a-dabc-4f69-8926-38f6223e5371)




