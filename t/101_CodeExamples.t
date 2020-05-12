#!/usr/bin/perl -w
#
# Copyright 2019, Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Functional test for the code examples, to make sure the examples run
# with no exceptions.

use strict;
use warnings;

use lib qw(. lib t/utils);
use TestAPIUtils;
use TestUtils qw(get_test_client read_client_properties);

use Test::More (tests => 79);

# Get the API client for the functional tests.
my $api_client = get_test_client();
if (!$api_client) {
  plan skip_all => "Can't create test API client, make sure your " .
    "'t/testdata/googleads_test.properties' is properly set. " .
    "Skipping functional tests.";
}

# Read the 'customerId' and 'managerCustomerId' values from the
# 'testdata/googleads_test.properties' configuration file.
my $properties          = read_client_properties();
my $customer_id         = $properties->getProperty("customerId");
my $manager_customer_id = $properties->getProperty("managerCustomerId");

############################## Test Dependencies ##############################
# Set up the objects that are required to run all the examples.

# Objects for search campaigns.
my $search_campaign_id =
  TestAPIUtils::create_campaign($api_client, $customer_id, "SEARCH");
my $search_ad_group_id =
  TestAPIUtils::create_ad_group($api_client, $customer_id, $search_campaign_id);
my $search_text_ad_id =
  TestAPIUtils::create_text_ad($api_client, $customer_id, $search_ad_group_id);
my $search_keyword_id =
  TestAPIUtils::create_keyword($api_client, $customer_id, $search_ad_group_id);

# Objects for display campaigns.
my $display_campaign_id =
  TestAPIUtils::create_campaign($api_client, $customer_id, "DISPLAY");
my $display_ad_group_id =
  TestAPIUtils::create_ad_group($api_client, $customer_id,
  $display_campaign_id);

# Objects for Gmail campaigns.
my $gmail_campaign_id =
  TestAPIUtils::create_campaign_with_sub_type($api_client, $customer_id,
  "DISPLAY", "DISPLAY_GMAIL_AD");
my $gmail_ad_group_id =
  TestAPIUtils::create_ad_group($api_client, $customer_id, $gmail_campaign_id);

# Objects for DSA campaigns.
my $dsa_campaign_id = TestAPIUtils::create_campaign(
  $api_client,
  $customer_id,
  "SEARCH",
  {
    dynamicSearchAdsSetting => {
      domainName   => "example.com",
      languageCode => "en"
    }});
my $dsa_ad_group_id = TestAPIUtils::create_ad_group(
  $api_client,
  $customer_id,
  $dsa_campaign_id,
  {
    type => "SEARCH_DYNAMIC_ADS",
    trackingUrlTemplate =>
      "http://tracker.examples.com/traveltracker/{escapedlpurl}",
  });

# Objects for labels.
my $label_id = TestAPIUtils::create_label($api_client, $customer_id);

###############################################################################

################################## Examples ##################################

# account_management
require qw(examples/account_management/approve_merchant_center_link.pl);
ok(
  approve_merchant_center_link($api_client, $customer_id),
  "Test of approve_merchant_center_link example."
);
require qw(examples/account_management/create_customer.pl);
ok(create_customer($api_client, $manager_customer_id),
  "Test of create_customer example.");
require qw(examples/account_management/get_account_changes.pl);
ok(
  get_account_changes($api_client, $customer_id),
  "Test of get_account_changes example."
);
require qw(examples/account_management/get_account_hierarchy.pl);
ok(get_account_hierarchy($api_client, $manager_customer_id),
  "Test of get_account_hierarchy example.");
require qw(examples/account_management/get_account_information.pl);
ok(
  get_account_information($api_client, $customer_id),
  "Test of get_account_information example."
);
# NOTE: Skip the link_manager_to_client.pl since $customer_id and
# $manager_customer_id might have already been linked together.
require qw(examples/account_management/list_accessible_customers.pl);
ok(
  list_accessible_customers($api_client),
  "Test of list_accessible_customers example."
);

# advanced_operations
require qw(examples/advanced_operations/add_ad_customizer.pl);
ok(
  add_ad_customizer(
    $api_client, $customer_id, $search_ad_group_id, $display_ad_group_id
  ),
  "Test of add_ad_customizer example."
);
require qw(examples/advanced_operations/add_ad_group_bid_modifier.pl);
ok(
  add_ad_group_bid_modifier(
    $api_client, $customer_id, $display_ad_group_id, 1.5
  ),
  "Test of add_ad_group_bid_modifier example."
);
require qw(examples/advanced_operations/add_app_campaign.pl);
ok(
  add_app_campaign($api_client, $customer_id),
  "Test of add_app_campaign example."
);
require qw(examples/advanced_operations/add_dynamic_page_feed.pl);
ok(
  add_dynamic_page_feed(
    $api_client, $customer_id, $dsa_campaign_id, $dsa_ad_group_id
  ),
  "Test of add_dynamic_page_feed example."
);
require qw(examples/advanced_operations/add_dynamic_search_ads.pl);
ok(
  add_dynamic_search_ads($api_client, $customer_id),
  "Test of add_dynamic_search_ads example."
);
require
  qw(examples/advanced_operations/add_expanded_text_ad_with_upgraded_urls.pl);
ok(
  add_expanded_text_ad_with_upgraded_urls(
    $api_client, $customer_id, $display_ad_group_id
  ),
  "Test of add_expanded_text_ad_with_upgraded_urls example."
);
require qw(examples/advanced_operations/add_gmail_ad.pl);
ok(add_gmail_ad($api_client, $customer_id, $gmail_ad_group_id),
  "Test of add_gmail_ad example.");
# NOTE: Skip the add_smart_display_ad.pl as it requires additional setup.
require
  qw(examples/advanced_operations/create_and_attach_shared_keyword_set.pl);
ok(
  create_and_attach_shared_keyword_set(
    $api_client, $customer_id, $display_campaign_id
  ),
  "Test of create_and_attach_shared_keyword_set example."
);
require
  qw(examples/advanced_operations/find_and_remove_criteria_from_shared_set.pl);
ok(
  find_and_remove_criteria_from_shared_set(
    $api_client, $customer_id, $display_campaign_id
  ),
  "Test of find_and_remove_criteria_from_shared_set example."
);
require qw(examples/advanced_operations/get_ad_group_bid_modifiers.pl);
ok(get_ad_group_bid_modifiers($api_client, $customer_id, undef),
  "Test of get_ad_group_bid_modifiers example.");
require qw(examples/advanced_operations/use_portfolio_bidding_strategy.pl);
ok(use_portfolio_bidding_strategy($api_client, $customer_id, undef),
  "Test of use_portfolio_bidding_strategy example.");

# basic_operations
require qw(examples/basic_operations/add_ad_groups.pl);
ok(add_ad_groups($api_client, $customer_id, $search_campaign_id),
  "Test of add_ad_groups example.");
require qw(examples/basic_operations/add_campaigns.pl);
ok(add_campaigns($api_client, $customer_id), "Test of add_campaigns example.");
require qw(examples/basic_operations/add_expanded_text_ads.pl);
ok(add_expanded_text_ads($api_client, $customer_id, $search_ad_group_id),
  "Test of add_expanded_text_ads example.");
require qw(examples/basic_operations/add_keywords.pl);
ok(add_keywords($api_client, $customer_id, $search_ad_group_id, "mars cruise"),
  "Test of add_keywords example.");
require qw(examples/basic_operations/add_responsive_search_ad.pl);
ok(add_responsive_search_ad($api_client, $customer_id, $search_ad_group_id),
  "Test of add_responsive_search_ad example.");
require qw(examples/basic_operations/get_ad_groups.pl);
ok(get_ad_groups($api_client, $customer_id, $search_campaign_id),
  "Test of get_ad_groups example.");
require qw(examples/basic_operations/get_artifact_metadata.pl);
ok(
  get_artifact_metadata($api_client, "campaign"),
  "Test of get_artifact_metadata example."
);
require qw(examples/basic_operations/get_campaigns.pl);
ok(get_campaigns($api_client, $customer_id), "Test of get_campaigns example.");
require qw(examples/basic_operations/get_expanded_text_ads.pl);
ok(get_expanded_text_ads($api_client, $customer_id, $search_ad_group_id),
  "Test of get_expanded_text_ads example.");
require qw(examples/basic_operations/get_keywords.pl);
ok(get_keywords($api_client, $customer_id, $search_ad_group_id),
  "Test of get_keywords example.");
require qw(examples/basic_operations/get_responsive_search_ads.pl);
ok(
  get_responsive_search_ads($api_client, $customer_id),
  "Test of get_responsive_search_ads example."
);
require qw(examples/basic_operations/pause_ad.pl);
ok(
  pause_ad($api_client, $customer_id, $search_ad_group_id, $search_text_ad_id),
  "Test of pause_ad example."
);
# NOTE: Examples that remove objects will be executed in the end to
# clean up the test dependencies.
require qw(examples/basic_operations/update_ad_group.pl);
ok(update_ad_group($api_client, $customer_id, $search_ad_group_id, 600000),
  "Test of update_ad_group example.");
require qw(examples/basic_operations/update_campaign.pl);
ok(update_campaign($api_client, $customer_id, $search_campaign_id),
  "Test of update_campaign example.");
require qw(examples/basic_operations/update_expanded_text_ad.pl);
ok(update_expanded_text_ad($api_client, $customer_id, $search_text_ad_id),
  "Test of update_expanded_text_ad example.");
require qw(examples/basic_operations/update_keyword.pl);
ok(
  update_keyword(
    $api_client, $customer_id, $search_ad_group_id, $search_keyword_id
  ),
  "Test of update_keyword example."
);

# billing
# NOTE: Skip the add_account_budget_proposal.pl as it requires additional setup.
require qw(examples/billing/get_account_budget_proposals.pl);
ok(
  get_account_budget_proposals($api_client, $customer_id),
  "Test of get_account_budget_proposals example."
);
require qw(examples/billing/get_account_budgets.pl);
ok(
  get_account_budgets($api_client, $customer_id),
  "Test of get_account_budgets example."
);
require qw(examples/billing/get_billing_setup.pl);
ok(
  get_billing_setup($api_client, $customer_id),
  "Test of get_billing_setup example."
);
# NOTE: Skip the remove_billing_setup.pl as it requires additional setup.

# campaign_management
require qw(
  examples/campaign_management/add_campaign_bid_modifier.pl);
ok(
  add_campaign_bid_modifier(
    $api_client, $customer_id, $search_campaign_id, 1.5
  ),
  "Test of add_campaign_bid_modifier example."
);
require qw(
  examples/campaign_management/add_campaign_draft.pl);
ok(add_campaign_draft($api_client, $customer_id, $display_campaign_id),
  "Test of add_campaign_draft example.");
require qw(
  examples/campaign_management/add_campaign_labels.pl);
ok(
  add_campaign_labels(
    $api_client,
    $customer_id,
    [
      $search_campaign_id, $display_campaign_id,
      $gmail_campaign_id,  $dsa_campaign_id
    ],
    $label_id
  ),
  "Test of add_campaign_labels example."
);
require qw(
  examples/campaign_management/add_complete_campaigns_using_mutate_job.pl);
ok(
  add_complete_campaigns_using_mutate_job($api_client, $customer_id),
  "Test of add_complete_campaigns_using_mutate_job example."
);
# NOTE: Skip the create_campaign_experiment.pl as it requires additional setup.
require qw(
  examples/campaign_management/get_all_disapproved_ads.pl);
ok(get_all_disapproved_ads($api_client, $customer_id, $search_campaign_id),
  "Test of get_all_disapproved_ads example.");
require qw(
  examples/campaign_management/get_campaigns_by_label.pl);
ok(get_campaigns_by_label($api_client, $customer_id, $label_id),
  "Test of get_campaigns_by_label example.");
# NOTE: Skip the graduate_campaign_experiment.pl as it requires additional setup.
require qw(examples/campaign_management/set_ad_parameters.pl);
ok(
  set_ad_parameters(
    $api_client, $customer_id, $search_ad_group_id, $search_keyword_id
  ),
  "Test of set_ad_parameters example."
);
require
  qw(examples/campaign_management/update_campaign_criterion_bid_modifier.pl);
ok(
  # Criterion ID 30002 is for Tablet platform.
  update_campaign_criterion_bid_modifier(
    $api_client, $customer_id, $search_campaign_id, 30002
  ),
  "Test of update_campaign_criterion_bid_modifier example."
);
require qw(examples/campaign_management/validate_text_ad.pl);
ok(validate_text_ad($api_client, $customer_id, $search_ad_group_id),
  "Test of validate_text_ad example.");

# error_handling
$api_client->set_die_on_faults(0);
require
  qw(examples/error_handling/handle_expanded_text_ad_policy_violations.pl);
ok(
  handle_expanded_text_ad_policy_violations(
    $api_client, $customer_id, $search_ad_group_id
  ),
  "Test of handle_expanded_text_ad_policy_violations example."
);
require qw(examples/error_handling/handle_keyword_policy_violations.pl);
ok(
  handle_keyword_policy_violations(
    $api_client, $customer_id, $search_ad_group_id, "abortion"
  ),
  "Test of handle_keyword_policy_violations example."
);
require qw(examples/error_handling/handle_partial_failure.pl);
ok(handle_partial_failure($api_client, $customer_id, $search_ad_group_id),
  "Test of handle_partial_failure example.");
require qw(examples/error_handling/handle_rate_exceeded_error.pl);
ok(handle_rate_exceeded_error($api_client, $customer_id, $search_ad_group_id),
  "Test of handle_rate_exceeded_error example.");
$api_client->set_die_on_faults(1);

# extensions
require qw(examples/extensions/add_affiliate_location_extensions.pl);
ok(
  add_affiliate_location_extensions(
    $api_client, $customer_id, 100074, $search_campaign_id, 1
  ),
  "Test of add_affiliate_location_extensions example."
);
# NOTE: Skip the add_google_my_business_location_extensions.pl as it requires additional setup.
require qw(examples/extensions/add_hotel_callout.pl);
ok(
  add_hotel_callout(
    $api_client,          $customer_id,
    $search_campaign_id,  $search_ad_group_id,
    "hotel callout text", "en"
  ),
  "Test of add_hotel_callout example."
);
require qw(examples/extensions/add_prices.pl);
ok(add_prices($api_client, $customer_id, $search_campaign_id),
  "Test of add_prices example.");
require qw(examples/extensions/add_sitelinks.pl);
ok(add_sitelinks($api_client, $customer_id, $search_campaign_id),
  "Test of add_sitelinks example.");
require qw(examples/extensions/add_sitelinks_using_feeds.pl);
ok(
  add_sitelinks_using_feeds(
    $api_client, $customer_id, $display_campaign_id, $display_ad_group_id
  ),
  "Test of add_sitelinks_using_feeds example."
);

# hotel_ads
# NOTE: Skip the ad_hotel_ad.pl as it requires additional setup.
# NOTE: Skip the add_hotel_ad_group_bid_modifiers.pl as it requires additional setup.
# NOTE: Skip the add_hotel_listing_group_tree.pl as it requires additional setup.

# misc
require qw(examples/misc/get_all_image_assets.pl);
ok(
  get_all_image_assets($api_client, $customer_id),
  "Test of get_all_image_assets example."
);
require qw(examples/misc/get_all_videos_and_images.pl);
ok(
  get_all_videos_and_images($api_client, $customer_id),
  "Test of get_all_videos_and_images example."
);
require qw(examples/misc/upload_image.pl);
ok(upload_image($api_client, $customer_id), "Test of upload_image example.");
require qw(examples/misc/upload_image_asset.pl);
ok(
  upload_image_asset($api_client, $customer_id),
  "Test of upload_image_asset example."
);
require qw(examples/misc/upload_media_bundle.pl);
ok(
  upload_media_bundle($api_client, $customer_id),
  "Test of upload_media_bundle example."
);

# planning
require qw(examples/planning/add_keyword_plan.pl);
ok(
  add_keyword_plan($api_client, $customer_id),
  "Test of add_keyword_plan example."
);
# NOTE: Skip the forecast_reach.pl as it requires additional setup.
# NOTE: Skip the generate_forecast_metrics.pl as it requires additional setup.
require qw(examples/planning/generate_keyword_ideas.pl);
ok(
  generate_keyword_ideas(
    $api_client, $customer_id, [21167, 20321],
    1000, ["cars", "volvo"]
  ),
  "Test of generate_keyword_ideas example."
);

# recommendations
# NOTE: Skip the apply_recommendation.pl as it requires additional setup.
# NOTE: Skip the dismiss_recommendation.pl as it requires additional setup.
require qw(examples/recommendations/get_text_ad_recommendations.pl);
ok(
  get_text_ad_recommendations($api_client, $customer_id),
  "Test of get_text_ad_recommendations example."
);

# remarketing
require qw(examples/remarketing/add_conversion_action.pl);
ok(
  add_conversion_action($api_client, $customer_id),
  "Test of add_conversion_action example."
);
# NOTE: Skip the add_customer_match_user_list.pl as it requires additional setup.
require qw(examples/remarketing/add_flights_feed.pl);
ok(
  add_flights_feed($api_client, $customer_id),
  "Test of add_flights_feed example."
);
# NOTE: Skip the add_merchant_center_dynamic_remarketing_campaign.pl as it requires additional setup.
require qw(examples/remarketing/add_real_estate_feed.pl);
ok(
  add_real_estate_feed($api_client, $customer_id),
  "Test of add_real_estate_feed example."
);
require qw(examples/remarketing/add_remarketing_action.pl);
ok(
  add_remarketing_action($api_client, $customer_id),
  "Test of add_remarketing_action example."
);
# NOTE: Skip the remove_feed_items.pl as it requires additional setup.
# NOTE: Skip the remove_flights_feed_item_string_attribute_value.pl as it requires additional setup.
# NOTE: Skip the update_flights_feed_item_string_attribute_value.pl as it requires additional setup.
# NOTE: Skip the upload_call_conversion.pl as it requires additional setup.
# NOTE: Skip the upload_conversion_adjustment.pl as it requires additional setup.
# NOTE: Skip the upload_offline_conversion.pl as it requires additional setup.

# reporting
require qw(examples/reporting/get_hotel_ads_performance.pl);
ok(
  get_hotel_ads_performance($api_client, $customer_id),
  "Test of get_hotel_ads_performance example."
);
require qw(examples/reporting/get_keyword_stats.pl);
ok(
  get_keyword_stats($api_client, $customer_id),
  "Test of get_keyword_stats example."
);

# shopping_ads
# NOTE: Skip the add_listing_scope.pl as it requires a merchant account.
# NOTE: Skip the add_shopping_product_ad.pl as it requires a merchant account.
# NOTE: Skip the add_shopping_product_listing_group_tree.pl as it requires a merchant account.
# NOTE: Skip the add_shopping_smart_ad.pl as it requires a merchant account.
require qw(examples/shopping_ads/get_product_bidding_category_constant.pl);
ok(
  get_product_bidding_category_constant($api_client, $customer_id),
  "Test of get_product_bidding_category_constant example."
);

# targeting
require qw(examples/targeting/add_campaign_targeting_criteria.pl);
ok(
  add_campaign_targeting_criteria(
    $api_client, $customer_id, $display_campaign_id, "jupiter cruise", 21167
  ),
  "Test of add_campaign_targeting_criteria example."
);
require qw(examples/targeting/add_customer_negative_criteria.pl);
ok(
  add_customer_negative_criteria($api_client, $customer_id),
  "Test of add_customer_negative_criteria example."
);
require qw(examples/targeting/add_demographic_targeting_criteria.pl);
ok(
  add_demographic_targeting_criteria(
    $api_client, $customer_id, $display_ad_group_id
  ),
  "Test of add_demographic_targeting_criteria example."
);
require qw(examples/targeting/get_campaign_targeting_criteria.pl);
ok(
  get_campaign_targeting_criteria(
    $api_client, $customer_id, $display_campaign_id
  ),
  "Test of get_campaign_targeting_criteria example."
);
require qw(examples/targeting/get_geo_target_constants_by_names.pl);
ok(
  get_geo_target_constants_by_names(
    $api_client, ["Paris", "Quebec", "Spain", "Deutschland"],
    "en", "FR"
  ),
  "Test of get_geo_target_constants_by_names example."
);
require qw(examples/targeting/search_for_language_and_carrier_constants.pl);
ok(
  search_for_language_and_carrier_constants(
    $api_client, $customer_id, "eng", "US"
  ),
  "Test of search_for_language_and_carrier_constants example."
);

###############################################################################

############################## Test Dependencies ##############################
# Cleaning up the test dependencies.

# Objects for search campaigns.
require qw(examples/basic_operations/remove_keyword.pl);
ok(
  remove_keyword(
    $api_client, $customer_id, $search_ad_group_id, $search_keyword_id
  ),
  "Test of remove_keyword example."
);
require qw(examples/basic_operations/remove_ad.pl);
ok(
  remove_ad($api_client, $customer_id, $search_ad_group_id, $search_text_ad_id),
  "Test of remove_ad example."
);
require qw(examples/basic_operations/remove_ad_group.pl);
ok(remove_ad_group($api_client, $customer_id, $search_ad_group_id),
  "Test of remove_ad_group example.");
require qw(examples/basic_operations/remove_campaign.pl);
ok(remove_campaign($api_client, $customer_id, $search_campaign_id),
  "Test of remove_campaign example.");

# Objects for display campaigns.
remove_ad_group($api_client, $customer_id, $display_ad_group_id);
remove_campaign($api_client, $customer_id, $display_campaign_id);

# Objects for Gmail campaigns.
remove_ad_group($api_client, $customer_id, $gmail_ad_group_id);
remove_campaign($api_client, $customer_id, $gmail_campaign_id);

# Objects for DSA campaigns.
remove_ad_group($api_client, $customer_id, $dsa_ad_group_id);
remove_campaign($api_client, $customer_id, $dsa_campaign_id);

# Objects for labels.
TestAPIUtils::delete_label($api_client, $customer_id, $label_id);
###############################################################################
