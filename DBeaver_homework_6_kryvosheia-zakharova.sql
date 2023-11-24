with common_table_fb_google as (
select
	ad_date, url_parameters, campaign_name, adset_name, spend,
	impressions, reach, clicks, leads, value,
	coalesce (spend, impressions, reach, clicks, leads, value, 0) as new
from
	facebook_ads_basic_daily as fabd
left join facebook_campaign as fc on fabd.campaign_id = fc.campaign_id
left join facebook_adset as fa on fabd.adset_id = fa.adset_id
where
	ad_date is not null
union all
select
	ad_date, url_parameters, campaign_name, adset_name,
	spend, impressions, reach, clicks, leads, value,
	coalesce (spend, impressions, reach, clicks, leads, value, 0) as new
from
	google_ads_basic_daily gabd ),
common_table_fb_google_2 as (
select
	ad_date, url_parameters,
	sum(spend) as "total_spend",
	sum(impressions) as "total_impressions",
	sum(clicks) as "total_clicks",
	sum(value) as "total_value",
	date_trunc('month', ad_date) as "ad_month",
	case
		when lower(substring(url_parameters, 'utm_campaign=([^&#$]+)'))= 'nan' then null
		else lower(substring(url_parameters, 'utm_campaign=([^&#$]+)'))
	end as "utm_campaign",
	case
		when sum(clicks)>0 then round(cast(sum(spend) as numeric)/ sum(clicks),2)
	end as "CPC",
	case
		when sum(impressions)>0 then round(cast(sum(spend) as numeric)/ sum(impressions),3)* 1000
	end as "CPM",
	case
		when sum(impressions)>0 then round(cast(sum(clicks) as numeric)/ sum(impressions),4)* 100
	end as "CTR",
	case
		when sum(spend)>0 then round(cast(sum(value)-sum(spend) as numeric)/ sum(spend),3)* 100
	end as "ROMI"
from
	common_table_fb_google
group by
	ad_date, url_parameters )
select *,
	round (("CPM" - lag ("CPM") over (partition by "utm_campaign" order by "ad_month"))/ 
	nullif (lag ("CPM") over (partition by "utm_campaign" order by "ad_month"), 0)* 100, 2) as "CPM_month",
	round (("CTR" - lag ("CTR") over (partition by "utm_campaign" order by "ad_month"))/ 
	nullif (lag ("CTR") over (partition by "utm_campaign" order by "ad_month"), 0)* 100, 2) as "CTR_month",
	round (("ROMI" - lag ("ROMI") over (partition by "utm_campaign" order by "ad_month"))/ 
	nullif (lag ("ROMI") over (partition by "utm_campaign" order by "ad_month"), 0)* 100, 2) as "ROMI_month"
from
	common_table_fb_google_2;
