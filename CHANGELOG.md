31.0.0 - 2026-02-25
-------------------
- Added support for Google Ads API v23_1.
- Added support for Google Ads API v20_2, v21_1, and v22_1, which contain
  EU political advertising-related changes.
- Added code examples: fetch_incentives, apply_incentive.

30.0.0 - 2026-01-28
-------------------
- Added support for Google Ads API v23.
- Removed support for Google Ads API v19.
- Renamed campaign start_date and end_date fields to start_date_time and
  end_date_time.
- Removed add_call_add example.

29.0.0 - 2025-10-15
-------------------
- Added support for Google Ads API v22.
- Fixed a typo in the BudgetPerDayMinimumErrorDetails.minimum_budget_amount_micros
  field.
- Updated PMax-related examples to remove the use of urlExpansionOptOut.

28.0.0 - 2025-08-06
-------------------
- Added support for Google Ads API v21.
- Added support for Google Ads API v19_2 and v20_1, which contain EU
  political advertising-related changes.
- Removed support for Google Ads API v18.
- Added code example: add_demand_gen_campaign.
- Updated campaign-related examples to set the containsEuPoliticalAdvertising
  field.

27.0.1 - 2025-07-07
-------------------
- Fixed bug in Google::Ads::GoogleAds::V20::Resources::CampaignBudget.

27.0.0 - 2025-06-04
-------------------
- Added support for Google Ads API v20.
- Removed support for Google Ads API v17.

26.1.0 - 2024-04-16
-------------------
- Added support for Google Ads API v19_1.
- Updated upload_enhanced_conversions_for_leads example to use session attributes.

26.0.0 - 2024-02-26
-------------------
- Added support for Google Ads API v19.
- Removed support for Google Ads API v16.
- Removed feed-related examples.
- Updated PMax campaign creation examples to use brand guidelines.
- Updated add_shopping_product_ad example to remove usage of enhancedCpc.

25.0.1 - 2024-12-18
-------------------
- Fixed bug in Google::Ads::GoogleAds::V18::Resources::CampaignBudget.

25.0.0 - 2024-10-16
-------------------
- Added support for Google Ads API v18.
- Updated example get_all_disapproved_ads to set returnTotalResultsCount
  on new searchSettings request field.

24.0.0 - 2024-08-08
-------------------
- Added support for Google Ads API v17_1.
- Removed support for Google Ads API v15.

23.0.0 - 2024-06-07
-------------------
- Added support for Google Ads API v17.
- Updated examples to remove usage of the page size parameter in Search
  requests.

22.0.0 - 2024-04-24
-------------------
- Added support for Google Ads API v16.1.
- Removed support for Google Ads API v14.
- Removed examples: approve_merchant_center_link, reject_merchant_center_link,
  remove_flights_feed_item_attribute_value, update_flights_feed_item_string_attribute_value,
  add_real_estate_feed, add_flights_feed.

21.0.0 - 2024-02-22
-------------------
- Added support for Google Ads API v16.0.
- Updated examples to remove references to extensions.
- Added support for a flag on the client that allows making requests
  without a developer token. This is in preparation for the pilot
  that uses Google Cloud orgs for API Access levels.
- Added local_services_lead.contact_details and
  local_services_lead_conversation.message_details.text to the fields
  to mask from logs.

20.0.0 - 2024-01-22
-------------------
- Removed support for Google Ads API v13.

19.0.0 - 2023-10-19
-------------------
- Added support for Google Ads API v15.0.
- Renamed upload_conversion_with_identifiers to
  upload_enhanced_conversions_for_leads and upload_conversion_enhancement to
  upload_enhanced_conversions_for_web, and updated these examples.
- Renamed get_product_bidding_category_constant to
  get_product_category_constants and updated.
- Updated examples: upload_offline_conversion, add_customer_match_user_list,
  upload_call_conversion, upload_store_sales_transactions,
  add_merchant_center_dynamic_remarketing_campaign, add_performance_max_product_listing_group_tree, add_performance_max_retail_campaign, add_shopping_product_ad.

18.0.0 - 2023-08-08
-------------------
- Added support for Google Ads API v14.1.
- Removed support for Google Ads API v12.
- Removed add_keyword_plan code example.
- Added code examples: generate_forecast_metrics, generate_historical_metrics.

17.0.0 - 2023-06-08
-------------------
- Added support for Google Ads API v14.
- Removed examples: generate_forecast_metrics, generate_historical_metrics,
  get_campaign_criterion_bid_modifier_simulations.

16.1.2 - 2023-05-17
-------------------
- Mark namespaces as no_index to avoid PAUSE indexing issues.

16.1.0 - 2023-04-28
-------------------
- Added support for Google Ads API v13.1.
- Added code example: add_things_to_do_ad.
- Renamed hotel directory to travel.
- Updated examples: upload_conversion_enhancement, add_call_ad,
  add_smart_campaign, add_call, add_customer_match_user_list,
  upload_call_conversion, upload_conversion_enhancement,
  upload_store_sales_transactions.

16.0.0 - 2023-03-31
-------------------
- Removed support for Google Ads API v11.
- Added code example: add_performance_max_for_travel_goals_campaign.
- Updated code example: create_experiment.

15.0.1 - 2023-03-08
-------------------
- Fixed bug in v13 CampaignBudget object.

15.0.0 - 2023-02-22
-------------------
- Added support for Google Ads API v13.
- Removed support for Google Ads API v10.
- Reworked code examples to address the deprecation of combined rule user lists
and expression rule user lists:
  - Edited set_up_advanced_remarketing and set_up_remarketing
  - Renamed add_combined_rule_user_list to add_flexible_rule_user_list
  - Removed add_expression_rule_user_list

14.0.1 - 2022-12-08
-------------------
- Decreased minimum perl version to 5.28.1.

14.0.0 - 2022-11-02
-------------------
- Added support for Google Ads API v12.
- Removed code examples: add_local_campaign, add_dynamic_page_feed,
  add_smart_display_ad, add_shopping_smart_ad, and migration folder.
- Bump perl version to 5.32.1.
- Updated examples: add_performance_max_retail_campaign, add_smart_campaign,
  create_experiment, forecast_reach.
- Replace handle_expanded_text_ad_policy_violations example with
  handle_responsive_search_ad_policy_violations.

13.1.1 - 2022-09-15
-------------------
- Updated the default redirect_uri, used in generate_user_credentials example,
  to remove OOB redirect. See relevant blog post:
  https://developers.googleblog.com/2022/02/making-oauth-flows-safer.html.

13.1.0 - 2022-08-22
-------------------
- Added support for Google Ads API v11_1.
- Added code examples: generate_historical_metrics.
- Improved code examples: set_custom_client_timeouts.
- Updated examples to remove references to expanded text ads.

13.0.0 - 2022-07-06
-------------------
- Removed support for Google Ads API v9.

12.0.0 - 2022-06-16
-------------------
- Added support for Google Ads API v11_0.
- Added code examples: create_experiment, detect_and_apply_recommendations.
- Removed code examples: create_campaign_experiment, graduate_campaign_experiment.
- Updated add_smart_campaign example.
- Updated the FieldMasks utility to better handle empty object fields. See updated guide:
  https://developers.google.com/google-ads/api/docs/client-libs/perl/field-masks.

11.0.0 - 2022-04-28
-------------------
- Added support for Google Ads API v10_1.
- Removed support for Google Ads API v8_0.
- Renamed authenticate_in_web_application to generate_user_credentials and updated
  to support the desktop application flow, since OAuth OOB is being deprecated.
- Removed authenticate_in_desktop_application code example.
- Updated add_customer_match_user_list code example.

10.0.1 - 2022-03-30
-------------------
- Added code examples: add_performance_max_product_listing_group_tree,
  navigate_search_result_pages_caching_tokens.
- Updated code examples: add_campaigns, add_performance_max_campaign,
  add_performance_max_retail_campaign, upload_offline_conversion.

10.0.0 - 2022-02-18
-------------------
- Added support for Google Ads API v10_0.
- Removed support for Google Ads API v7.
- Added code examples: add_call, add_call_ad, add_dynamic_page_feed_asset,
  add_dynamic_remarketing_asset.
- Updated code examples: get_account_information, add_display_upload_ad, upload_image_asset,
  add_performance_max_campaign, add_performance_max_retail_campaign, get_keywords.

9.3.0 - 2021-12-15
-------------------
- Supported HTTP agent version in the "x-goog-api-client" request header.
- Updated the references of “Google My Business/GMB” in code examples to
  “Business Profile”.
- Added code examples: add_performance_max_campaign, add_performance_max_retail_campaign,
  add_responsive_search_ad_with_ad_customizer, upload_conversion_enhancement,
  upload_conversion_with_identifiers.
- Updated code examples: add_app_campaign, add_smart_campaign.
- Renamed code examples: add_google_my_business_location_extensions to
  add_business_profile_location_extensions, setup_advanced_remarketing to
  set_up_advanced_remarketing, setup_remarketing to set_up_remarketing.

9.2.0 - 2021-11-12
-------------------
- Added support for Google Ads API v9_0.
- Supported client library version in the "x-goog-api-client" request header.
- Improved code examples: add_smart_campaign, upload_store_sales_transactions,
  create_customer_match_user_list.
- Updated code examples to the asset based extensions: add_hotel_callout,
  add_sitelinks_using_assets, add_prices.

9.1.0 - 2021-09-30
-------------------
- Added code examples: add_bidding_data_exclusion, add_bidding_seasonality_adjustment.
- Fixed code examples: add_display_upload_ad, add_local_campaign, add_smart_display_ad,
  upload_image, upload_image_asset, upload_media_bundle,
  add_merchant_center_dynamic_remarketing_campaign.

9.0.0 - 2021-08-13
-------------------
- Added support for Google Ads API v8_1.
- Removed support for Google Ads API v6.
- Removed add_gmail_ad code example.
- Added new services: BiddingDataExclusionService,
  BiddingSeasonalityAdjustmentService.
- Updated code examples for Google Ads API v8_1: add_smart_campaign,
  get_change_details.

8.0.1 - 2021-07-05
-------------------
- Improved code examples: get_ad_group_bid_modifiers, upload_call_conversion,
  upload_offline_conversion.

8.0.0 - 2021-06-11
-------------------
- Added support for Google Ads API v8_0.
- Removed support for Google Ads API v5.
- Added support for logging the request IDs for search stream API.
- Added new services: AccessibleBiddingStrategyService,
  AssetFieldTypeViewService, ConversionValueRuleService,
  ConversionValueRuleSetService, DetailedDemographicService,
  KeywordThemeConstantService, SmartCampaignSearchTermViewService,
  SmartCampaignSettingService, SmartCampaignSuggestService.
- Added code examples: add_smart_campaign, use_cross_account_bidding_strategy.
- Updated upload_store_sales_transactions code example.

7.0.0 - 2021-05-06
-------------------
- Added support for Google Ads API v7_0.
- Removed support for Google Ads API v4.
- Added code examples: migrate_promotion_feed_to_asset.
- Improved code examples: get_ad_group_bid_modifiers.

6.1.1 - 2021-04-07
-------------------
- Supported HTTP requests retry mechanism on error responses.
- Improved code examples: create_customer, add_dynamic_page_feed, etc.
- Updated all code examples to link to Google Ads API documentation instead of
  AdWords API documentation.

6.1.0 - 2021-02-15
-------------------
- Added support for Google Ads API v6_1.
- Removed support for Google Ads API v3.
- Added support for authenticating with service accounts.
- Added code examples: get_pending_invitations, invite_user_with_access_role,
  add_image_extension, etc.

6.0.1 - 2020-12-09
-------------------
- Extended the FieldMasks utility to retrieve a field value given the fieldmask.
- Made the update_user_access code example more robust by using 'LIKE' query
  instead of '='.

6.0.0 - 2020-11-11
-------------------
- Added support for Google Ads API v6_0.
- Removed support for Google Ads API v2.
- Added support of client configuration from environment variables.
- Refactored GoogleAdsLogger to redact email addresses present in the requests
  and responses.
- Added new services: CustomerUserAccessService, CustomAudienceService,
  CombinedAudienceService, FeedItemSetService, etc.
- Added code examples: get_change_details, update_user_access, add_lead_form_extension,
  update_audience_target_restriction, etc.
- Renamed code example authenticate_in_standalone_application to
  authenticate_in_desktop_application.

5.0.0 - 2020-08-31
-------------------
- Added support for Google Ads API v5_0.
- Added code examples: add_logical_user_list, add_combined_rule_user_list,
  add_expression_rule_user_list, add_conversion_based_user_list, add_geo_target,
  add_billing_setup, etc.

4.0.0 - 2020-07-13
-------------------
- Added support for Google Ads API v4_0.
- Renamed MutateJobService to BatchJobService.
- Added code examples: add_merchant_center_dynamic_remarketing_campaign,
  add_sitelinks_using_feeds, parallel_report_download, add_display_upload_ad, etc.

3.1.0 - 2020-05-07
-------------------
- Added support for Google Ads API v3_1.
- Added code examples: upload_conversion_adjustment, upload_call_conversion,
  approve_merchant_center_link, search_for_language_and_carrier_constants,
  add_customer_match_user_list, etc.
- Improved code examples: add_complete_campaigns_using_mutate_job,
  get_account_hierarchy, get_account_budgets.

3.0.0 - 2020-02-26
-------------------
- Added support for Google Ads API v3_0.
- Added SearchStreamHandler to support the search stream API.
- Added code examples: add_app_campaign, update_campaign_criterion_bid_modifier,
  add_listing_scope.
- Updated code examples get_campaigns and get_keyword_stats to use the search
  stream API.

2.2.0 - 2019-09-16
-------------------
- Added support for Google Ads API v2_2.
- Added code examples: get_account_hierarchy, add_smart_display_ad, add_prices,
  add_sitelinks, forecast_reach, upload_offline_conversion, etc.

2.1.0 - 2019-08-15
-------------------
- Added support for Google Ads API v2_1.
- Added examples for campaign experiments and mutate jobs.
- Added OperationService to support long running operations.

2.0.0 - 2019-06-28
-------------------
- Added support for Google Ads API v2_0.

1.0.0 - 2019-06-24
-------------------
- Initial release with support for Google Ads API v1_3.
