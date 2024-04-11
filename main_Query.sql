#we create the sum of amount spent by each user on zomato
select a.userid , sum(b.price) as TotalExpenditure from sales a 
inner join product b using(product_id)
group by a.userid
order by a.userid;

#distinct dates when customer visited zomato
select userid, count(distinct(created_date)) as 'Distinct Date'
 from sales 
 group by userid;
 
 #first profuct purchased by the customer after joining
 select * from
 (select *,rank() 
 over (partition by userid order by created_date) 
 rnk from sales )
 a where rnk =1;
 
 #what is the most purchased item on the menu? 
 #And how many times purchased by user?
 
 select product_id from sales
 group by product_id
 order by count(product_id) desc
 limit 1;
 
 select userid, count(product_id) as numberoftimepurchased from sales where product_id = (
 select product_id from sales
 group by product_id
 order by count(product_id) desc
 limit 1)
 group by userid;
 
 # which item was popular for each of the customer
 select * from(
 select *,rank() over (partition by userid 
 order by cmt desc) as rnk from(
 select userid, product_id, count(product_id) as cmt from sales 
 group by userid, product_id) as a)as b where rnk=1;

 #which iterm was purchased first when they bacame a gold member?
 select * from(
 select c.*,rank() over( partition by userid order by created_date) as rnk from
 (select a.userid, a.product_id, a.created_date, b.gold_signup_date 
 from sales a inner join goldusers_signup b on a.userid = b.userid and created_date>= gold_signup_date) as c) as d
 where rnk = 1;
 
 # which item was purchased before the user just became a member?
  select * from(
 select c.*,rank() over( partition by userid order by created_date desc) as rnk from
 (select a.userid, a.product_id, a.created_date, b.gold_signup_date 
 from sales a inner join goldusers_signup b on a.userid = b.userid and created_date<= gold_signup_date) as c) as d
 where rnk = 1;
 
 # what is the total amount on order spent by user before becomming a member
 
 select userid, count(current_date) as 'Order Purchased' , sum(price) as 'Total Amount' from
 (select e.* , p.price from
 (select a.userid, a.product_id, a.created_date, b.gold_signup_date 
 from sales a inner join goldusers_signup b on a.userid = b.userid and created_date<= gold_signup_date)e
 inner join product p on e.product_id = p.product_id)f
 group by userid;
 
#If buying each product generates points for eg 5 rs spent gives 2 pts
# and each profuct has different purchasing points
# for eg p1 5rs 1 pt , p2 10rs = 5 pts, p3 5rs = 1 pt

#1st we have to calculate the total points collected by each customer and for which products most points have been given

# for most cashback by user
select f.userid, sum(TotalPoints)*2.5 as Total_Cashback_Earner from
(select e.*, TotalAmount/point_per_product as TotalPoints from
(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 
else 0 end as point_per_product from
(select e.userid, e.product_id, sum(price) as TotalAmount from 
(select a.*, b.price from sales a inner join product b on a.product_id=b.product_id) as e
 group by userid,product_id)as d)e)f group by userid
 order by userid;
 
 
 # for most cashback based on products
 select f.product_id, sum(TotalPoints)*2.5 as Total_Cashback_Earner from
(select e.*, TotalAmount/point_per_product as TotalPoints from
(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 
else 0 end as point_per_product from
(select e.userid, e.product_id, sum(price) as TotalAmount from 
(select a.*, b.price from sales a inner join product b on a.product_id=b.product_id) as e
 group by userid,product_id)as d)e)f group by product_id
 order by product_id;
 
 # to extract just the top one customer, 
 select f.userid, sum(TotalPoints)*2.5 as Total_Cashback_Earner from
(select e.*, TotalAmount/point_per_product as TotalPoints from
(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 
else 0 end as point_per_product from
(select e.userid, e.product_id, sum(price) as TotalAmount from 
(select a.*, b.price from sales a inner join product b on a.product_id=b.product_id) as e
 group by userid,product_id)as d)e)f group by userid
 order by Total_Cashback_Earner
 Limit 1;
 
 # to extrat top product
 select f.product_id, sum(TotalPoints)*2.5 as Total_Cashback_Earner from
(select e.*, TotalAmount/point_per_product as TotalPoints from
(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 
else 0 end as point_per_product from
(select e.userid, e.product_id, sum(price) as TotalAmount from 
(select a.*, b.price from sales a inner join product b on a.product_id=b.product_id) as e
 group by userid,product_id)as d)e)f group by product_id
 order by Total_Cashback_Earner desc
 Limit 1;
 
 
 #in the first year the customer joins the gold membership, (even the date) irrespective of 
 # what they have purchased, they will earn 5 pts for every 10 rs spent (who earned more pts)
 # Also, what was their earnings in the first year

 select e.*,  p.price*0.5 as Total_Price_Earned from
 (select a.userid, a.product_id, a.created_date, b.gold_signup_date from sales a 
 inner join goldusers_signup b on a.userid = b.userid 
 and created_date >= adddate(gold_signup_date,365))as e 
 inner join product p on e.product_id = p.product_id;
 
 #rank all the transactions of the customers
 select *,rank() over(partition by userid order by created_date)rnk from sales ;
 
 #rank all gold member trasactions and for non gold rank them as na
 
 
 select d.*, case when rnk = 0 then 'NA' else rnk end as rnkk from
 (select e.*, cast((case when gold_signup_date is null then 0 else 
 rank() over (partition by userid order by created_date desc) end) as varchar) from
 (select a.*,b.gold_signup_date from sales a left join goldusers_signup b
 on a.userid = b.userid and created_date>= gold_user_signup)e)d;