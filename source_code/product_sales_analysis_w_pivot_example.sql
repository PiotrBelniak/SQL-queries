with basis(year,month,product_name,sales_value,sales_volume, transaction_cnt,price)
AS
(select c.year
        ,EXTRACT(MONTH FROM TO_DATE(c.month,'MONTH')) as month
        ,p.name product_name
        ,SUM(s.quantity*p.price) sales_value
        ,SUM(s.quantity) sales_volume
        ,COUNT(*) as transaction_cnt
        ,ANY_VALUE(p.price) price
    from calendar c,product p, sales s
    where s.prodid=p.id AND s.salesdate=c.data AND p.prod_typ='laptop'
    group by p.name,c.year,EXTRACT(MONTH FROM TO_DATE(c.month,'MONTH'))
),
yearly_product_sales(product_name,year, price,sales_value,sales_volume, transaction_cnt)
AS
(
select product_name
        ,year
        , ANY_VALUE(price)
        ,SUM(sales_value) as yearly_sales_value
        , SUM(sales_volume) as yearly_sales_amt
        , SUM(transaction_cnt) as transaction_cnt
from basis
group by product_name,year
),
product_bucket_assignment(year,product_name,bucket_nr)
as
(
select year
        ,product_name
        , NTILE(5) OVER (PARTITION BY year ORDER BY sales_value desc)
from yearly_product_sales
),
bucket_min_max_sales_value(year,bucket_nr,minimum_sales_val,maximum_sales_val, least_expensive_product, most_expensive_product)
as
(
select year
        , bucket_nr
        ,MIN(sales_value) as minimum_val
        , MAX(sales_value) as maximum_val
        , MIN(price) as least_expensive_product
        , MAX(price) as most_expensive_product
from yearly_product_sales JOIN product_bucket_assignment USING(product_name,year)
group by year, bucket_nr
),
bucket_avg_monthly_transactions(year,bucket_nr,avg_monthly_transaction_cnt)
as
(
select distinct year
        ,bucket_nr
        , ROUND(AVG(SUM(transaction_cnt)) OVER (PARTITION BY year,bucket_nr),3)
from basis JOIN product_bucket_assignment USING(product_name,year)
group by year,bucket_nr, month
),
bucket_avg_sales_diff_against_most_least_expensive(year,bucket_nr,most_expensive_avg_diff, least_expensive_avg_diff)
as
(
select year
        , bucket_nr
        , most_expensive_sales_volume-avg_sales_volume most_expensive_avg_diff
        , least_expensive_sales_volume-avg_sales_volume least_expensive_avg_diff
from
(
select year
        , bucket_nr
        , ROUND(AVG(sales_volume)) avg_sales_volume
        , MAX(sales_volume) KEEP (DENSE_RANK FIRST ORDER BY price desc) most_expensive_sales_volume
        , MAX(sales_volume) KEEP (DENSE_RANK FIRST ORDER BY price asc) least_expensive_sales_volume
from yearly_product_sales JOIN product_bucket_assignment USING(product_name,year)
group by year, bucket_nr
))

select year
        ,bucket_nr
        ,minimum_sales_val
        ,maximum_sales_val
        , least_expensive_product
        , most_expensive_product
        ,avg_monthly_transaction_cnt
        ,most_expensive_avg_diff
        , least_expensive_avg_diff
from
    bucket_min_max_sales_value 
    JOIN bucket_avg_monthly_transactions USING(year,bucket_nr) 
    JOIN bucket_avg_sales_diff_against_most_least_expensive USING(year,bucket_nr) ;

/*pivoting part of analysis*/
select * 
from
(
    select bucket_nr,minimum_sales_val,maximum_sales_val, least_expensive_product, most_expensive_product
    from 
        bucket_min_max_sales_value 
        JOIN bucket_avg_monthly_transactions USING(year,bucket_nr) 
        JOIN bucket_avg_sales_diff_against_most_least_expensive USING(year,bucket_nr) 
)
PIVOT (
        MIN(minimum_sales_val) as minimal_of_minimum_sales
        ,MAX(maximum_sales_val) as maximum_of_maximum_sales
        ,MIN(least_expensive_product) as buckets_least_expensive_product
        ,MAX(most_expensive_product) as buckets_most_expensive_product
        FOR bucket_nr IN(1,2,3,4,5))

