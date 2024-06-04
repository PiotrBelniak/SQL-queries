# Advance pattern matching
## Introduction
The query provides information on how long each monitor sold needed to break daily sales record and how many V or U shapes in sales plot were needed to achieve new sales record.

## Source code
Please find link to source code of query: [query code](https://github.com/PiotrBelniak/SQL-queries/blob/main/source_code/advanced_pattern_matching_example.sql)

## Description of query
1. First we need to prepare our base. Because we are looking on daily level, we do not need to consider calendar table, since salesdate column gives date information.  
   We join sales table with product table, filter by monitor product type and perform SUM aggregation of quantity*price expression, where grouping columns are salesdate and product name.(lines 32-38)
2. To perform pattern matching we use match_recognize clause. Specification is as follows:  
   - since we want each product to be treated separately, we use partition by clause specifying product name column.  
     This way pattern matching clause will treat different products as separate data sets
   - to work across data set chronologically, we specify salesdate in order by clause
   - next is measures clause, where we specify what information pattern matching clause should give us after processing.
     In our specification we need to know, when previous record was achieved, day it was broken, classifier(it specifies what pattern variable was assigned to row of match)
     , match number(the identifier of match along the data set) and the new sales record. 
     Because we want date and value of new record to be assigned to the row identified as starting point, we use FINAL in combination with LAST.  
     LAST is logical placement within pattern variable and FINAL means we need placement as it is from point of last row of the match.
   - at this point we can choose, if we want every row of match or only one summary row.
     We need all of them, so we write all rows per match clause.     
   - after match skip to specifies, where should database continue to look for next match after one was found.  
     Since we look from record to record, we want to find new match at the same row previous match ended
   - pattern keyword is specification of what relation between ordered rows in data set needs to be in order to consider such subset a match  
     We do this using row pattern variables(which is boolean condition), regular expressions and special character.
     In our situation we look for set of rows, that some arbitrary point, then we look for as much 
   - 

  

## Example of results

