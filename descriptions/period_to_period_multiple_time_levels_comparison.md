# Period-to-period comparison on multiple time levels
## Introduction
These 2 view definitions and query prepare data for period-to-period comparative analysis of sales across different time levels for year 2022 and one product.  
The important feature of query is data densification, which is process of filling information for missing dimension(s) values.
We will use GROUPING functions to identify on what level of aggregation along dimension row is and assign appropriate hierarchical identifier.
When dimension column is part of current aggregation level, grouping function returns 0. Otherwise grouping function returns 1.
Grouping ID helps us to identify grouping applied to paricular row of result set.  

## Source code
Please find link to source code of query: [query code](https://github.com/PiotrBelniak/SQL-queries/blob/main/source_code/period_to_period_multiple_time_levels_comparison.sql)

## Description of queries
1. View number 1(lines 1-26) prepares the hierarchical cube across two dimensions: products and time.  
   Hierarchical cube is data set created by aggregating along rollups of multiple dimensions combined across dimensions.  
   First rollup across time consists of grand total, year, quarter, month and day.
   Second rollup across products consists of grand total, supertype, type and singular products.
   These rollups will be cross-producted to create 20 different groupings.  
   In our example dimensions are filtered: only 3 years and 14 different products were chosen.  
   To easily differentiate, at what time level rows are, we create hierarchical identifier column using case expression with grouping function.
   We create three grouping ids: two-dimension ID for both product and time hierarchy, ID for product hierarchy and ID for time hierarchy.  
   The only thing left is to select all dimensional columns and sum sales value, sales volume and transaction count.  
2. View number 2(lines 28-45) prepares full set of time identifiers.  
   As in view 1 we create hierarchical identifier column the same way as previously.  
   In addition to standard time dimension information such as year, quarter and month identifier and date, we need quarter, month and day number.  
   Quarter number is derived using SUBSTR function on quarter identifier. Month number is obtained the same method as quarter number.
   To retrieve day number we need substract date of first year's day from every date and add 1.  
   Here we filter 3 years and perform rollup group by - this time using only time dimension.
3. Query(lines 47-93) consists of 2 levels of subquery nesting.  
   Innermost query(lines 71-90) performs data densification using previously created views.  
   To perform densification we use PARITION BY OUTER JOIN. In partition by part we specify the column, by which query performs logical data division.
   This way, for every single product all missing dates, months, quarters or years will be added with sales value specified in select clause.  
   We then choose all columns from both views. On revenue column we use NVL function, which allows to specify value, if we have null in column.  
   Query in the middle(lines 59-70) selects form previous subquery only relevant columns: product name, hierarchical time identifier, year, quarter identifier, month identifier, date, general grouping identifier, daily sales.  
   Two additional columns are calculated: sales from prior period(previous day, previous month, previous quarter or previous year) and sales from year before for each level of time hierarchy.
   For both columns we use LAG function with offset 1. The difference is in data set division and sorting specification.
   To get previous period's sales we divide set by single product and by time hierarchy grouping id and sort by time. Since we have full product hierarchy and full time hierarchy to select from,
   we need to include product grouping identifier along with whole product hierarchy in partition by clause, in order by we use all time identifier(year, quarter_id, month_id, date).
   To get sales from year ago we divide set by full product hierarchy, product grouping identifier, time grouping identifier, quarter number, month number, day number and we sort by year.
   This way, on daily level every single day number will be a part of own set with only year being a difference. The same goes for months and quarter.  
   Outermost query(lines 47-58 and line 93) filters times, product and/or hierarchy levels along with selection of columns of our interest.
   Here we filter by year 2022 and single product.  
   As of selection, we only need name, hierarchical identifier, year, quarter and month identifiers, date, time hierarchy grouping id and all sales values we received from subquery.
   

## Example of results
![obraz](https://github.com/PiotrBelniak/SQL-queries/assets/169681378/d13ba92c-13b6-4091-a5dc-aba3df01b206)


