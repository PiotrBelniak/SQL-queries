CREATE OR REPLACE FORCE NONEDITIONABLE VIEW PROD_TIME_CUBE (HIERARCHICAL_TIME, YEAR, QUARTER_ID, MONTH_ID, DATA, SUPERTYP, PROD_TYP, NAME, GID, GID_P, GID_T, REVENUE, SOLD_PIECES, REVENUE_CNT, NUM_OF_TRANS, CNT) AS 
  SELECT (CASE 
            WHEN ((GROUPING(c.year)=0) AND (GROUPING(c.quarter_id)=1)) THEN (TO_CHAR(c.year) || '_0')
            WHEN ((GROUPING(c.quarter_id)=0) AND (GROUPING(c.month_id)=1)) THEN (TO_CHAR(c.quarter_id) || '_1')
            WHEN ((GROUPING(c.month_id)=0) AND (GROUPING(c.data)=1)) THEN (TO_CHAR(c.month_id) || '_2')
            ELSE (TO_CHAR(c.data) || '_3') END) as Hierarchical_time
        ,c.year
        , c.quarter_id
        , c.month_id
        , c.data
        , p.supertyp
        ,p.prod_typ
        ,p.name
        ,GROUPING_ID(p.supertyp,p.prod_typ,p.name,c.year, c.quarter_id, c.month_id, c.data) as gid
        ,GROUPING_ID(p.supertyp,p.prod_typ,p.name) as gid_p
        ,GROUPING_ID(c.year, c.quarter_id, c.month_id, c.data) as gid_t
        ,SUM(s.quantity*p.price) as revenue
        ,SUM(s.quantity) as sold_pieces
        ,COUNT(s.quantity*p.price) as revenue_cnt
        ,COUNT(s.quantity) as num_of_trans
        ,COUNT(*) cnt
FROM sales s,product p, calendar c
WHERE s.prodid=p.id AND c.data=s.salesdate AND c.year IN (2021,2022,2023) AND p.id IN (1,19,187,259,304,343,463,433,577,610,751,787,901,937)
group by
    rollup(c.year, c.quarter_id, c.month_id, c.data),
    rollup(p.supertyp,p.prod_typ,p.name);

CREATE OR REPLACE FORCE NONEDITIONABLE VIEW COMPLETE_TIMELINE (HIERARCHICAL_TIME, YEAR, QUARTER_ID, QUARTER_NUM, MONTH_ID, MONTH_NUM, DATA, DAY_NUM, GID_T) AS 
  SELECT (CASE 
            WHEN ((GROUPING(year)=0) AND (GROUPING(quarter_id)=1)) THEN (TO_CHAR(year) || '_0')
            WHEN ((GROUPING(quarter_id)=0) AND (GROUPING(month_id)=1)) THEN (TO_CHAR(quarter_id) || '_1')
            WHEN ((GROUPING(month_id)=0) AND (GROUPING(data)=1)) THEN (TO_CHAR(month_id) || '_2')
            ELSE (TO_CHAR(data) || '_3') END) as Hierarchical_time
        ,year
        ,quarter_id 
        ,SUBSTR(quarter_id,5,1) quarter_num
        ,month_id
        ,SUBSTR(month_id,5,2) month_num
        ,data 
        ,data - TRUNC(data, 'YEAR')+1 day_num
        ,GROUPING_ID(year, quarter_id, month_id, data) as gid_t
FROM calendar
WHERE year IN (2021,2022,2023)
group by
    rollup(year, quarter_id, month_id, data);    
    
select name
      ,hierarchical_time
      ,year
      ,quarter_id
      ,month_id
      ,data
      ,sales
      ,sales_prior_period
      ,sales_yty
      ,gid
from
(
    select name
          ,hierarchical_time
          ,year
          ,quarter_id
          ,month_id
          , data
          ,gid
          ,sales
          , LAG(sales,1) OVER (PARTITION BY gid_p,supertyp,prod_typ,name, gid_t ORDER BY year,quarter_id,month_id,data) sales_prior_period
          ,LAG(sales,1) OVER (PARTITION BY gid_p,supertyp,prod_typ,name, gid_t,quarter_num,month_num,day_num ORDER BY year) sales_yty
    from
    (
        select t.hierarchical_time
              ,t.year
              ,t.quarter_id
              ,t.quarter_num
              ,t.month_id
              ,t.month_num
              ,t.data
              ,t.day_num
              ,t.gid_t
              ,c.supertyp
              ,c.prod_typ
              ,c.name
              ,c.gid
              ,c.gid_p
              ,NVL(c.revenue,0) sales
        from
        prod_time_cube c
        PARTITION BY (c.gid_p,c.supertyp,c.prod_typ,c.name)
        RIGHT OUTER JOIN complete_timeline t ON c.gid_t=t.gid_t AND c.hierarchical_time=t.hierarchical_time
        order by c.name,t.year,t.quarter_id,t.month_id,t.data
    )
)
where year=2022 and name='Acer GM7000 (Predator)'
