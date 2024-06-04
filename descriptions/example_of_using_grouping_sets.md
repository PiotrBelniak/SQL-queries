# Differences of sales across different time periods
## Introduction
These simple queries show usage of different forms of group by clause and grouping related functions. 
All queries join fact table sales with all 3 dimensions: product, calendar and customers.
The DECODE functions along with GROUPING function allow us to identify, if the column is part of specific grouping for that row.  
When that is true, grouping function returns 0 and result of decode function is column value. Otherwise grouping function returns 1 and decode function gives us text we specified as output.
Grouping ID helps us to identify grouping applied to paricular row of result set, for example value 14 tells us the row is aggregate only to customer's country level, while 5 means row is result of grouping by year and product type.  
In our queries we would like to aggregate sales in 5 different ways:
  - two-dimensionally to product type and year level
  - two-dimensionally to product type and month level
  - two-dimensionally to product type and customer's country level
  - two-dimensionally to month and customer's country level
  - one-dimensionally to customer's country level
## Source code
Please find link to source code of query: [query code](https://github.com/PiotrBelniak/SQL-queries/blob/main/source_code/example_of_using_grouping_sets.sql)

## Description of queries
1. First query(lines 1-12) utilizes grouping sets clause to most efficiently provide necessary groups.  
   Grouping sets takes as input set of groups to compute only in those groupings we need.
2. Second query(lines 15-26) uses cube clause to calculate aggregates on all possible subsets of grouping column set we provide.
   This means with cube clause and set of n columns, we receive 2^n different groups.  
   To filter out unnecessary groups we use grouping_id function specifying the same set of columns we provided to cube clause(order is irrelevant).
   The values we are providing in having clause's IN conditional can be calculated as follows:  
   -If the rightmost column is part of our grouping we have 0, if not then 1.  
   -Next we go left 1 column and perform the same check. This time we have either 0 or 2.  
   -We continue previous step until we reach leftmost column inclusively. For each iteration we receive either 0 or twice as much as previous result: 4, 8, 16.  
   After that we sum the values from analysis - that is the grouping_id we need. We repeat this steps for each grouping we need.
3. Last version of query(lines 29-62) uses combination of unions of result set and partial rollups.
   First part of union(lines 29-37) provides two groupings: to product type-year level and product type-month level.  
   We do this by using rollup in group by clause only on month column and leaving product and year columns outside of rollup.
   Rollup performs aggregation by first using all columns in set and then using one less column until we are left with no column to divide data by.
   In other words, rollup on dimension aggregate from most detailed level up to grand total.
   Because we do not use any information from customers table, we can omit it from query completely.
   Second part of union(lines 41-49) provides another two groupings: to customer's country-month level and customer's country level.
   As previously we use the same rollup, but with customer's country column outside instead of product and year ones.
   The last part of union(lines 53-62) provide last grouping: to product type-customer's country level.
   This time we use simple group by clause specifying both columns.
   As in first part of union, we can omit unnecessary table from joining - this time calendar is not used.
