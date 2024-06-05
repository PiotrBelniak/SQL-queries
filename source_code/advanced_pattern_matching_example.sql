select  product_name
        ,start_point
        ,days_to_new_best_sales
        ,sales_amt previous_best_sales
        ,final_sales_amt new_best_sales
        ,number_of_V_shapes 
from
(
    select  product_name
            ,start_point
            , end_point-start_point as days_to_new_best_sales
            , match_var
            , sales_amt
            , final_sales_amt
            ,FLOOR(SUM(CASE WHEN match_var != prev_match_var THEN 1 ELSE 0 END) OVER (PARTITION BY product_name,seq_num)/2) as number_of_V_shapes 
    from
    (
        select  product_name
                ,date_of_sales
                ,start_point
                , end_point
                , match_var
                , LAG(match_var,1) OVER (PARTITION BY product_name,seq_num ORDER BY date_of_sales) as prev_match_var
                , MAX(final_sales_amt) OVER (PARTITION BY product_name ORDER BY date_of_sales) as actual_best
                ,seq_num
                , sales_amt
                ,final_sales_amt 
        from
        (
            select  s.salesdate as date_of_sales
                    ,p.name as product_name
                    ,SUM(s.quantity*p.price) as sales_amt
            from sales s JOIN product p ON s.prodid=p.id
            where p.prod_typ='monitor'
            group by s.salesdate,p.name
            order by p.name,s.salesdate
        ) MATCH_RECOGNIZE
        (partition by product_name
        order by date_of_sales
        measures STRT.date_of_sales as start_point
                ,FINAL LAST(PAT.date_of_sales) as end_point
                ,classifier() as match_var
                ,match_number() as seq_num
                ,FINAL LAST(break_point.sales_amt) as final_sales_amt
        all rows per match
        after match skip to last PAT
        pattern (strt ((decrease+ {-no_change-}*)+ (increase+ {-no_change-}*)+)+ ((decrease+ {-no_change-}*)+ break_point|break_point))
        subset PAT=(decrease,increase,break_point)
        define
            increase as increase.sales_amt>prev(increase.sales_amt) AND increase.sales_amt<=strt.sales_amt
            ,decrease as decrease.sales_amt<prev(decrease.sales_amt) 
            ,break_point as break_point.sales_amt>strt.sales_amt
            ,no_change as no_change.sales_amt=prev(no_change.sales_amt)
        ) MR
    ) where final_sales_amt = actual_best
) 
where match_var='STRT'
