/*use grouping sets to check for specific aggregations of sales(in this case we want to know how products were sold across 5 groupings)*/
select  DECODE(GROUPING(c.year), 1,'All years',c.year) as year
        ,DECODE(GROUPING(c.month), 1,'All months',c.month) as month
        ,DECODE(GROUPING(p.prod_typ), 1,'All product types',p.prod_typ) as prod_typ
        ,DECODE(GROUPING(cu.address.country), 1,'All customers',cu.address.country) as country
        , SUM(s.quantity*p.price) as sales_amt
        , SUM(s.quantity) as sales_volume
        , grouping_id(c.year,c.month,p.prod_typ,cu.address.country) group_id
from sales s, product p,calendar c, customers cu
where s.prodid=p.id AND s.salesdate=c.data AND s.custid=cu.id
group by grouping sets((p.prod_typ,c.year),(p.prod_typ,c.year,c.month),(p.prod_typ,cu.address.country),(c.month, cu.address.country), (cu.address.country))
order by group_id desc, year,month, prod_typ, country;

/*alternative solution using cube and filtering the required groups*/
select  DECODE(GROUPING(c.year), 1,'All years',c.year) as year
        ,DECODE(GROUPING(c.month), 1,'All months',c.month) as month
        ,DECODE(GROUPING(p.prod_typ), 1,'All product types',p.prod_typ) as prod_typ
        ,DECODE(GROUPING(cu.address.country), 1,'All customers',cu.address.country) as country
        , SUM(s.quantity*p.price) as sales_amt
        , SUM(s.quantity) as sales_volume
        , grouping_id(c.year,c.month,p.prod_typ,cu.address.country) group_id
from sales s, product p,calendar c, customers cu
where s.prodid=p.id AND s.salesdate=c.data AND s.custid=cu.id
group by  cube(c.year, p.prod_typ,cu.address.country,c.month)
having grouping_id(c.year,c.month,p.prod_typ,cu.address.country) IN (14,12,10,5,1)
order by group_id desc, year,month, prod_typ, country;

/*second alternative solution using only rollup and unions*/
select  DECODE(GROUPING(c.year), 1,'All years',c.year) as year
        ,DECODE(GROUPING(c.month), 1,'All months',c.month) as month
        ,DECODE(GROUPING(p.prod_typ), 1,'All product types',p.prod_typ) as prod_typ
        ,'All customers' as country
        , SUM(s.quantity*p.price) as sales_amt
        , SUM(s.quantity) as sales_volume
from sales s, product p,calendar c
where s.prodid=p.id AND s.salesdate=c.data
group by p.prod_typ,c.year,ROLLUP(c.month)

UNION ALL

select  'All years' as year
        ,DECODE(GROUPING(c.month), 1,'All months',c.month) as month
        ,'All products' as prod_typ
        ,DECODE(GROUPING(cu.address.country), 1,'All customers',cu.address.country) as country
        , SUM(s.quantity*p.price) as sales_amt
        , SUM(s.quantity) as sales_volume
from sales s, product p,calendar c, customers cu
where s.prodid=p.id AND s.salesdate=c.data AND s.custid=cu.id
group by cu.address.country,ROLLUP(c.month)

UNION ALL

select  'All years' as year
        ,'All months' as month
        ,DECODE(GROUPING(p.prod_typ), 1,'All product types',p.prod_typ) as prod_typ
        ,DECODE(GROUPING(cu.address.country), 1,'All customers',cu.address.country) as country
        , SUM(s.quantity*p.price) as sales_amt
        , SUM(s.quantity) as sales_volume
from sales s, product p,customers cu
where s.prodid=p.id AND s.custid=cu.id
group by p.prod_typ,cu.address.country
order by year,month, prod_typ,country
