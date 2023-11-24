with common_table_fb_google as (
select ad_date, campaign_name, adset_name, spend, impressions, reach, 
clicks, leads, value 
from facebook_ads_basic_daily as fabd 
left join facebook_campaign as fc on fabd.campaign_id = fc.campaign_id 
left join facebook_adset as fa on fabd.adset_id = fa.adset_id 
where clicks>0
union all
select ad_date, campaign_name, adset_name, spend, impressions, reach, 
clicks, leads, value
from google_ads_basic_daily gabd )
--select ad_date, campaign_name,
--sum(spend) as total_spend,
--sum(impressions) as "total_impressions",
--sum(clicks) as "total_clicks",
--sum(value) as "total_value"
--from common_table_fb_google
--group by ad_date, campaign_name;
select adset_name,
sum(spend) as "total_spend",
sum(value) as "total_value",
round(cast(sum(value)-sum(spend) as numeric)/sum(spend),4)*100 as "ROMI"
from common_table_fb_google
group by adset_name
having sum(spend)>500000
order by round(cast(sum(value)-sum(spend) as numeric)/sum(spend),4)*100 desc
limit 1;