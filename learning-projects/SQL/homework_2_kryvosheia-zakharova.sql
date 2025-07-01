--select ad_date, campaign_id, sum(spend) as "total_spend", sum(impressions) as "total_impressions", 
--sum(clicks) as "total_clicks", sum(value) as "total_value", 
--round(cast(sum(spend) as numeric)/nullif(sum(clicks),0),3) as "CPC",
--round(cast(sum(spend) as numeric)/nullif(sum(impressions),0),3)*1000 as "CPM",
--round(cast(sum(clicks) as numeric)/nullif(sum(impressions),0),3)*100 as "CTR",
--round(cast(sum(value)-sum(spend) as numeric)/nullif(sum(spend),0),3)*100 as "ROMI"
--from facebook_ads_basic_daily fabd 
--where campaign_id is not null
--group by ad_date, campaign_id;

select campaign_id, sum(spend) as "total_spend", sum(value) as "total_value",
round(cast(sum(value)-sum(spend) as numeric)/nullif(sum(spend),0),3)*100 as "ROMI"
from facebook_ads_basic_daily fabd
where campaign_id is not null 
group by campaign_id
having sum(spend)>500000 and round(cast(sum(value)-sum(spend) as numeric)/nullif(sum(spend),0),3)*100>24
order by round(cast(sum(value)-sum(spend) as numeric)/nullif(sum(spend),0),3)*100 desc; 
