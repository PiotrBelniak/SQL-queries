select p.name as product_name
        ,c.month_id
        ,APPROX_SUM(s.quantity*p.price) approximation_of_sum
from sales s,product p, calendar c
where s.prodid=p.id AND c.data=s.salesdate
group by p.name, c.month_id
having approx_rank(partition by p.name order by APPROX_SUM(s.quantity*p.price) desc)<=10;

select p.name
        ,c.year as rok
        ,SUBSTR(c.quarter_id,5,1) as kwartal
        ,SUM(s.quantity*p.price) as monthly_sum
        ,NTILE(10) OVER (partition by p.name order by SUM(s.quantity*p.price) desc) as ntile10
from sales s, product p, calendar c
where s.prodid=p.id AND c.data=s.salesdate
group by p.name, c.year, SUBSTR(c.quarter_id,5,1)
order by p.name, kwartal, rok;

select prod_typ
        ,month_id
        , monthly_sales
        , ROUND(percentage_of_sales,4)*100
from
(
        select p.prod_typ
                ,c.month_id
                ,SUM(s.quantity*p.price) monthly_sales
                ,MAX(SUM(s.quantity*p.price)) OVER (partition by prod_typ) as best_month
                ,ratio_to_report(SUM(s.quantity*p.price)) OVER (partition by month_id) as percentage_of_sales
        from sales s,product p, calendar c
        where p.id=s.prodid and c.data=s.salesdate
        group by p.prod_typ, c.month_id
        order by p.prod_typ, c.month_id
)
where monthly_sales=best_month;
