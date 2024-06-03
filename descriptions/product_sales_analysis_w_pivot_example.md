# Product sales analysis with pivoting
## Introduction
The query provides insights on sales across years of laptop product group sub-groups created as equiheight buckets,  
providing information such as gross sales value range of products in each bucket, the price range of products within them,  
their average monthly transactional contribution across the year 
and how much more/less transaction were made with most/least expensive products bucket-wise.

## Source code
Please find link to source code of query: [query code](https://github.com/PiotrBelniak/SQL-queries/blob/main/source_code/product_sales_analysis_w_pivot_example.sql)

## Description of query elements
1. Our base of operations is monthly sales of each product, value, volume, transaction count - query in lines 1-13  
   We select from three tables: calendar, product and our fact table choosing only one group of products.
   Then we perform group by singular product, year and month of that year.  
   To obtain month number we perform convertion of month name into date and then extract month part from it.
   Because we want to keep product price for operations, we use function ANY_VALUE, which allows us to keep product price regardless of aggregation.
2. Next step is to aggregate data received from previous step by product and year, which is performed in lines 14-25.
3. Query performed in lines 26-33 divides products into 5 equiheight buckets.  
   To perform this operation we take data from step 2 and use NTILE analytic function, using yearly sales value to determine the correct bucket.
   Since we want to include different products for different years, we include partition by year clause to divide data set into logical partitions.
4. Query in lines 34-45 obtains information about sales value and product price ranges.
   It joins the results from steps 2 and 3 and uses aggregate functions MIN, MAX on both sales_value and price.  
   This query aggregates across years and buckets.
5. Query in lines 46-54 provides the average number of monthly transactions of each bucket's products for a year.  
   In this particular query instead of results from step 2 we use our basis from step 1, join it with bucket assignment sub-query and nest SUM aggregate within analytical AVG function.
6. Query from lines 55-71 needs to be broken down into inner and outer parts.  
   Inner query joins results from step 2 and 3 to calculate the average yearly product sales volumes across buckets along with sales volume of least/most expensive product of that bucket.  
   Here we use KEEP clause along with MAX aggregate, which allows us to get information from sales_volume column while ranking on different column - here we use price column.
   Outer query performs simple subtractions to receive differences of sales volumes.
7. The last necessary step of our analysis is to join together results from steps 4, 5 and 6 using inner joins and select all relevant columns.(lines 73-85)
8. As an addition we can choose to perform pivot operation on data from step 7. The query is in lines 87-101.
   In subquery we select from joined steps 4, 5 and 6 results bucket identifier, sales amount and products price range.
   In main query we pivot data looking for the absolute minimum and maximum that was required for product to be in particular bucket and what was the least/most expensive product that ever was in it.

## Example of results
Without pivot:
![obraz](https://github.com/PiotrBelniak/SQL-queries/assets/169681378/5af35aa2-9427-4f1c-9857-38b0dd738586)

With pivot:
![obraz](https://github.com/PiotrBelniak/SQL-queries/assets/169681378/99029614-3cf7-4605-a3be-a9ad850475b1)
