# Advance pattern matching
## Introduction
The query provides information on how long each monitor sold needed to break daily sales record and how many V or U type shapes in sales plot were needed to achieve new sales record.

## Source code
Please find link to source code of query: [query code](https://github.com/PiotrBelniak/SQL-queries/blob/main/source_code/advanced_pattern_matching_example.sql)

## Description of query
1. First we need to prepare our base. Because we are looking for sales on daily level, we do not need to consider calendar table, since salesdate column gives date information.  
   We join sales table with product table, filter by monitor product type and perform SUM aggregation of quantity*price expression, where grouping columns are salesdate and product name.(lines 30-36)
2. To perform pattern matching we use match_recognize clause(lines 37-54). Specification is as follows:  
   - since we want each product to be treated separately, we use partition by clause specifying product name column.  
     This way pattern matching clause will treat different products as logically separate data sets
   - to work across data set chronologically, we specify salesdate in order by clause
   - next is measures clause, where we specify what information pattern matching clause should give us after processing.
     In our specification we need to know, when previous record was achieved, day it was broken, classifier(it specifies what pattern variable was assigned to row of match)
     , match number(the identifier of match along the data set) and the new sales record. 
     Because we want date and value of new record to be assigned to the row identified as starting point, we use FINAL in combination with LAST.  
     LAST is logical placement within pattern variable and FINAL means we need placement as it is from point of last row of the match.
   - at this point we can choose, if we want every row of match or only one summary row.
     We need all of them, so we write all rows per match clause.     
   - after match skip to specifies, where should query continue to look for next match after one was found.  
     Since we look from record to record, we want to start looking for new match at the same row previous match ended
   - pattern keyword is specification of what conditions in ordered set of row need to be satisfied to consider it a match  
     We do this using row pattern variables(which is boolean condition), regular expressions and special characters.  
     Let's break down pattern from our example: strt ((decrease+ {-no_change-}*)+ (increase+ {-no_change-}*)+)+ ((decrease+ {-no_change-}*)+ break_point|break_point)
     - strt is any row, since we do not define any condition for row to be assigned strt variable
     - decrease+ means we are looking for rows, where previous day/row sales were greater. + means we are looking for at least 1 such row in succession
     - {-no_change-}* is every row, for which previous day/row sales are exactly the same. * means any number of rows in succession can be assigned this variable, none as well.
       {- -} means we do not include rows with this variable in query result
     - (decrease+ {-no_change-}*)+ means we are treating decrease and no_change as a set and that we want group of decrease pattern variables followed by group of no_change variables to occur at least once
     - increase+ means we are looking for rows, where previous day/row sales were less and current rows sales are at most the same as strt variable's row. + means we are looking for at least 1 such row               in succession
     - (increase+ {-no_change-}*)+ means we are treating increase and no_change as a set and that we want group of increase pattern variables followed by group of no_change variables to occur at least once
     - ((decrease+ {-no_change-}*)+ (increase+ {-no_change-}*)+)+ states we are looking for set of decreases/no_changes followed by set of increases/no_changes.  
       This makes a V or U-type shape. We are looking to get as many V/U-type shape as possible.
     - break_point pattern variable simply states that the daily sales of row with this variable is greater than sales of strt variable's row. Reaching this point is end of our pattern; therefore query can           start looking for new match
     - ((decrease+ {-no_change-}*)+ break_point|break_point) has "|" character, which means alternation. We look for either record being broken after series of decrease(which can be understood as sales               explosion) or as last day of continuous sales increases
   - subset clause let us define new pattern variable as union of other pattern variables. Here we define new variable called PAT as union of decrease,increase and break_point variables
   - define keyword is where we set the conditions for the pattern variables that row need to satisfy for assignment.  
     Since increase means previous sales were less than current and we do not want this sales to be more than start value, we define increase as
     increase.sales_amt>prev(increase.sales_amt) AND increase.sales_amt<=strt.sales_amt, where increase can be thought of as current row, prev() is navigation function, which returns value of previous row of       chosen pattern variable's last occurence.  
     The second condition in conjuction is simple inequality between current row's value against value of row, that was assigned with strt variable.  
     Decrease is defined using less than inequality between current row's value against value of previous row.
     Break point is defined as inequality between current row's value against value of row, that was assigned with strt variable.
     No_change is equality of sales value's between adjacent rows.
   After the match_recognize clause is done we can start analyzing results
3. In this step we use the fact pattern matching is performed right after from clause(which here is subquery from point 1) and before select clause.(lines 18-29)
   We select all columns from our subquery, all measures we received from pattern matching and additionally we perform two calculations: we look for pattern variable assigned to row with latest date before       current row - for that purpose we use LAG function on match_var column logically dividing data by product name and match number sorting by date of sales.
   Second calculation we perform here is MAX function on final_sales_amt with logical division by product name and sort by date of sales - for this column we want to retrieve the record sales for our products    as it is for the sales date of current row.
4. On this level of subquery nesting(lines 9-17) we will select product name, the first date of current sales record(start_point), difference in days between last and first day of that record, current pattern    variable assignment, current's date sales value, new record as of the current row. To retrieve number of V/U-type shapes we use analytic SUM function along with CASE expression. CASE expression returns 1,     if current pattern variable is different than previous one and 0 otherwise. That values are summed for each product and each match separately - that is specified via partition by clause.  
   Because each V/U-type shape requires 2 changes in variable assignment, we divide that sum by 2 and then we get floor value, becuase number of changes can be a odd number.
   In line 55 we filter out rows, where record produced by pattern matching clause does not equal correct record. This occurs due to how pattern matching works. After last record was found, no more matches       were found; therefore query moved to next row and started looking for match from there - that is repeated until query reaches end of data set. That creates "new" record value, which is not true record -       that is why these matches need to be filtered out.
5. Query in lines 1-8 and line 57 performs summary of our current analysis. We select here product name, the first date of current sales record(start_point), difference in days between last and first day of      that record, current and new record along with number of V/U-type shapes calculated in step 4. To get summary, we filter only those rows, where strt pattern variable is assigned.

## Example of results
![obraz](https://github.com/PiotrBelniak/SQL-queries/assets/169681378/e2b14066-6545-49c1-b332-87ce71025c63)

