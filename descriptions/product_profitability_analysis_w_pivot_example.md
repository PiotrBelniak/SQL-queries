# SQL queries
## Introduction
This repository is small collection of SQL queries that use advanced techniques, such as approximation functions,  
analytic functions in reporting/cumulative/window versions, nested aggregates within analytic functions,  
different forms of group by clause: cube, rollup, grouping sets, concatenated groupings, group identifiers,  
creation of hierarchical cubes, pattern matching mechanism, pivot clause and uasge of CTEs.

## List of queries:

  1. Product profitability analysis with pivoting: [query code](https://github.com/PiotrBelniak/SQL-queries/blob/main/source_code/product_profitability_analysis_w_pivot_example.sql)    [explanation]()
  2. Queries showing sales change(in value and percentage) across different type periods, also showing two periods with best profit difference: [query code](https://github.com/PiotrBelniak/SQL-queries/blob/main/source_code/differences_of_sales_across_different_time_periods.sql)   [explanation]()
  3. Queries showing, how to obtain 5 specific groupings in 3 different ways: [query code](https://github.com/PiotrBelniak/SQL-queries/blob/main/source_code/example_of_using_grouping_sets.sql)   [explanation]()
  4. Period to period comparison across multiple time levels on densified data: [query code](https://github.com/PiotrBelniak/SQL-queries/blob/main/source_code/period_to_period_multiple_time_levels_comparison.sql)   [explanation]()
  5. Advanced pattern matching example showing, how much time product needs to have best sales day : [query code](https://github.com/PiotrBelniak/SQL-queries/blob/main/source_code/advanced_pattern_matching_example.sql)   [explanation]()
  6. Various relational analytics SQL queries: [query code](https://github.com/PiotrBelniak/SQL-queries/blob/main/source_code/relational_analitycs_queries.sql)   [explanation]()

## Data model:
In all queries we use combination of four tables: sales, product, calendar and customers.
![obraz](https://github.com/PiotrBelniak/SQL-queries/assets/169681378/6eb02b76-52d1-4eef-91da-9d71367cf91c)

The tables created simple star schema, where sales is fact table and three remaining tables are dimensions.  
In this case sales table has their own primary key, but the key could be created via combination of the foreign key columns.  
All of dimensions present here are denormalized, so less tables are required for star schema.  
Other things worth noting are: 
- product price being in dimension table instead of additional column in fact table containing sales value for transaction
- customer address is one object column with three attributes: street address, city and country
