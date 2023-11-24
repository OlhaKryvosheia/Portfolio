with common_table_fb_google as (
select ad_date, url_parameters, campaign_name, adset_name, spend, impressions, reach, 
clicks, leads, value,
coalesce (spend, impressions, reach, 
clicks, leads, value,0) as new
from facebook_ads_basic_daily as fabd
left join facebook_campaign as fc on fabd.campaign_id = fc.campaign_id 
left join facebook_adset as fa on fabd.adset_id = fa.adset_id
where ad_date is not null 
union all
select ad_date, url_parameters, campaign_name, adset_name, spend, impressions, reach, 
clicks, leads, value,
coalesce (spend, impressions, reach, 
clicks, leads, value,0) as new
from google_ads_basic_daily gabd )
select ad_date, url_parameters, sum(spend) as total_spend, sum(impressions) as total_impressions, 
sum(clicks) as total_clicks, sum(value) as total_value,
case 
	when lower(substring(url_parameters, 'utm_campaign=([^&#$]+)'))='nan' then 'null'
	else lower(substring(url_parameters, 'utm_campaign=([^&#$]+)')) 
end as "utm_campaign",
case 
	when sum(clicks)>0 then round(cast(sum(spend) as numeric)/sum(clicks),2)
end as "CPC",
case 
	when sum(impressions)>0 then round(cast(sum(spend) as numeric)/sum(impressions),3)*1000
end as "CPM",
case 
	when sum(impressions)>0 then round(cast(sum(clicks) as numeric)/sum(impressions),4)*100
end as "CTR",
case 
	when sum(spend)>0 then round(cast(sum(value)-sum(spend) as numeric)/sum(spend),3)*100
end as "ROMI"
from common_table_fb_google
group by ad_date, url_parameters;