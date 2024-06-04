select p.name
        , c.year as year
        ,SUBSTR(c.quarter_id,5,1) as quarter
        ,SUM(s.quantity*p.price) as monthly_sum
        , ROUND(NVL((SUM(s.quantity*p.price)-LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,SUBSTR(c.quarter_id,5,1) ORDER BY c.year))/LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,SUBSTR(c.quarter_id,5,1) ORDER BY c.year),0),4)*100 as yty_percent_diff
        , NVL(SUM(s.quantity*p.price)-LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,SUBSTR(c.quarter_id,5,1) ORDER BY c.year),0) as yty_diff
        , ROUND(NVL((SUM(s.quantity*p.price)-LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,c.year ORDER BY SUBSTR(c.quarter_id,5,1)))/LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,c.year ORDER BY SUBSTR(c.quarter_id,5,1)),0),4)*100 as qtq_percent_diff
        , NVL(SUM(s.quantity*p.price)-LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,c.year ORDER BY SUBSTR(c.quarter_id,5,1)),0) as qtq_diff
from sales s, product p, calendar c
where s.prodid=p.id AND c.data=s.salesdate
group by p.name, c.year, SUBSTR(c.quarter_id,5,1)
order by p.name, quarter, year;


select p.name
        , c.year as year
        ,SUBSTR(c.month_id,5,2) as month
        ,SUM(s.quantity*p.price) as monthly_sum
        , ROUND(NVL((SUM(s.quantity*p.price)-LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,SUBSTR(c.month_id,5,2) ORDER BY c.year))/LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,SUBSTR(c.month_id,5,2) ORDER BY c.year),0),4)*100 as yty_percent_diff
        , NVL(SUM(s.quantity*p.price)-LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,SUBSTR(c.month_id,5,2) ORDER BY c.year),0) as yty_diff
        , ROUND(NVL((SUM(s.quantity*p.price)-LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,c.year ORDER BY SUBSTR(c.month_id,5,2)))/LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,c.year ORDER BY SUBSTR(c.month_id,5,2)),0),4)*100 as mtm_percent_diff
        , NVL(SUM(s.quantity*p.price)-LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,c.year ORDER BY SUBSTR(c.month_id,5,2)),0) as mtm_diff
from sales s, product p, calendar c
where s.prodid=p.id AND c.data=s.salesdate
group by p.name, c.year, SUBSTR(c.month_id,5,2)
order by p.name, month, year;

select * from
(
select product_name, year, month,yty_percent_diff, RANK() OVER (PARTITION BY product_name,month ORDER BY yty_percent_diff desc) as ranking from
(   
    select p.name as product_name
        , c.year as year
        ,SUBSTR(c.month_id,5,2) as month
        ,SUM(s.quantity*p.price) as monthly_sum
        , ROUND(NVL((SUM(s.quantity*p.price)-LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,SUBSTR(c.month_id,5,2) ORDER BY c.year))/LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,SUBSTR(c.month_id,5,2) ORDER BY c.year),0),4)*100 as yty_percent_diff
        , NVL(SUM(s.quantity*p.price)-LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,SUBSTR(c.month_id,5,2) ORDER BY c.year),0) as yty_diff
        , ROUND(NVL((SUM(s.quantity*p.price)-LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,c.year ORDER BY SUBSTR(c.month_id,5,2)))/LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,c.year ORDER BY SUBSTR(c.month_id,5,2)),0),4)*100 as qtq_percent_diff
        , NVL(SUM(s.quantity*p.price)-LAG(SUM(s.quantity*p.price),1) OVER (PARTITION BY p.name,c.year ORDER BY SUBSTR(c.month_id,5,2)),0) as qtq_diff
    from sales s, product p, calendar c
    where s.prodid=p.id AND c.data=s.salesdate
    group by p.name, c.year, SUBSTR(c.month_id,5,2)
    order by p.name, month, year
)
)
where ranking<=2;
