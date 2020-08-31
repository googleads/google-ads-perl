# Copyright 2020, Google LLC
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
# This module provides methods to generate resource names.

package Google::Ads::GoogleAds::V5::Utils::ResourceNames;

use strict;
use warnings;

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

# Returns the account_budget resource name for the specified components.
sub account_budget {
  my ($customer_id, $account_budget_id) = @_;

  my $path_template =
    'customers/{customer_id}/accountBudgets/{account_budget_id}';

  return expand_path_template($path_template,
    [$customer_id, $account_budget_id]);
}

# Returns the account_budget_proposal resource name for the specified components.
sub account_budget_proposal {
  my ($customer_id, $account_budget_proposal_id) = @_;

  my $path_template =
'customers/{customer_id}/accountBudgetProposals/{account_budget_proposal_id}';

  return expand_path_template($path_template,
    [$customer_id, $account_budget_proposal_id]);
}

# Returns the account_link resource name for the specified components.
sub account_link {
  my ($customer_id, $account_link_id) = @_;

  my $path_template = 'customers/{customer_id}/accountLinks/{account_link_id}';

  return expand_path_template($path_template, [$customer_id, $account_link_id]);
}

# Returns the ad resource name for the specified components.
sub ad {
  my ($customer_id, $ad_id) = @_;

  my $path_template = 'customers/{customer_id}/ads/{ad_id}';

  return expand_path_template($path_template, [$customer_id, $ad_id]);
}

# Returns the ad_group resource name for the specified components.
sub ad_group {
  my ($customer_id, $ad_group_id) = @_;

  my $path_template = 'customers/{customer_id}/adGroups/{ad_group_id}';

  return expand_path_template($path_template, [$customer_id, $ad_group_id]);
}

# Returns the ad_group_ad resource name for the specified components.
sub ad_group_ad {
  my ($customer_id, $ad_group_id, $ad_id) = @_;

  my $path_template =
    'customers/{customer_id}/adGroupAds/{ad_group_id}~{ad_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $ad_id]);
}

# Returns the ad_group_ad_asset_view resource name for the specified components.
sub ad_group_ad_asset_view {
  my ($customer_id, $ad_group_id, $ad_id, $asset_id, $field_type) = @_;

  my $path_template =
'customers/{customer_id}/adGroupAdAssets/{ad_group_id}~{ad_id}~{asset_id}~{field_type}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $ad_id, $asset_id, $field_type]);
}

# Returns the ad_group_ad_label resource name for the specified components.
sub ad_group_ad_label {
  my ($customer_id, $ad_group_id, $ad_id, $label_id) = @_;

  my $path_template =
    'customers/{customer_id}/adGroupAdLabels/{ad_group_id}~{ad_id}~{label_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $ad_id, $label_id]);
}

# Returns the ad_group_audience_view resource name for the specified components.
sub ad_group_audience_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/adGroupAudienceViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the ad_group_bid_modifier resource name for the specified components.
sub ad_group_bid_modifier {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/adGroupBidModifiers/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the ad_group_criterion resource name for the specified components.
sub ad_group_criterion {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/adGroupCriteria/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the ad_group_criterion_label resource name for the specified components.
sub ad_group_criterion_label {
  my ($customer_id, $ad_group_id, $criterion_id, $label_id) = @_;

  my $path_template =
'customers/{customer_id}/adGroupCriterionLabels/{ad_group_id}~{criterion_id}~{label_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id, $label_id]);
}

# Returns the ad_group_criterion_simulation resource name for the specified components.
sub ad_group_criterion_simulation {
  my ($customer_id, $ad_group_id, $criterion_id, $type, $modification_method,
    $start_date, $end_date)
    = @_;

  my $path_template =
'customers/{customer_id}/adGroupCriterionSimulations/{ad_group_id}~{criterion_id}~{type}~{modification_method}~{start_date}~{end_date}';

  return expand_path_template(
    $path_template,
    [
      $customer_id,         $ad_group_id, $criterion_id, $type,
      $modification_method, $start_date,  $end_date
    ]);
}

# Returns the ad_group_extension_setting resource name for the specified components.
sub ad_group_extension_setting {
  my ($customer_id, $ad_group_id, $extension_type) = @_;

  my $path_template =
'customers/{customer_id}/adGroupExtensionSettings/{ad_group_id}~{extension_type}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $extension_type]);
}

# Returns the ad_group_feed resource name for the specified components.
sub ad_group_feed {
  my ($customer_id, $ad_group_id, $feed_id) = @_;

  my $path_template =
    'customers/{customer_id}/adGroupFeeds/{ad_group_id}~{feed_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $feed_id]);
}

# Returns the ad_group_label resource name for the specified components.
sub ad_group_label {
  my ($customer_id, $ad_group_id, $label_id) = @_;

  my $path_template =
    'customers/{customer_id}/adGroupLabels/{ad_group_id}~{label_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $label_id]);
}

# Returns the ad_group_simulation resource name for the specified components.
sub ad_group_simulation {
  my ($customer_id, $ad_group_id, $type, $modification_method, $start_date,
    $end_date)
    = @_;

  my $path_template =
'customers/{customer_id}/adGroupSimulations/{ad_group_id}~{type}~{modification_method}~{start_date}~{end_date}';

  return expand_path_template(
    $path_template,
    [
      $customer_id,         $ad_group_id, $type,
      $modification_method, $start_date,  $end_date
    ]);
}

# Returns the ad_parameter resource name for the specified components.
sub ad_parameter {
  my ($customer_id, $ad_group_id, $criterion_id, $parameter_index) = @_;

  my $path_template =
'customers/{customer_id}/adParameters/{ad_group_id}~{criterion_id}~{parameter_index}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id, $parameter_index]);
}

# Returns the ad_schedule_view resource name for the specified components.
sub ad_schedule_view {
  my ($customer_id, $campaign_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/adScheduleViews/{campaign_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $criterion_id]);
}

# Returns the age_range_view resource name for the specified components.
sub age_range_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/ageRangeViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the asset resource name for the specified components.
sub asset {
  my ($customer_id, $asset_id) = @_;

  my $path_template = 'customers/{customer_id}/assets/{asset_id}';

  return expand_path_template($path_template, [$customer_id, $asset_id]);
}

# Returns the batch_job resource name for the specified components.
sub batch_job {
  my ($customer_id, $batch_job_id) = @_;

  my $path_template = 'customers/{customer_id}/batchJobs/{batch_job_id}';

  return expand_path_template($path_template, [$customer_id, $batch_job_id]);
}

# Returns the bidding_strategy resource name for the specified components.
sub bidding_strategy {
  my ($customer_id, $bidding_strategy_id) = @_;

  my $path_template =
    'customers/{customer_id}/biddingStrategies/{bidding_strategy_id}';

  return expand_path_template($path_template,
    [$customer_id, $bidding_strategy_id]);
}

# Returns the billing_setup resource name for the specified components.
sub billing_setup {
  my ($customer_id, $billing_setup_id) = @_;

  my $path_template =
    'customers/{customer_id}/billingSetups/{billing_setup_id}';

  return expand_path_template($path_template,
    [$customer_id, $billing_setup_id]);
}

# Returns the campaign resource name for the specified components.
sub campaign {
  my ($customer_id, $campaign_id) = @_;

  my $path_template = 'customers/{customer_id}/campaigns/{campaign_id}';

  return expand_path_template($path_template, [$customer_id, $campaign_id]);
}

# Returns the campaign_asset resource name for the specified components.
sub campaign_asset {
  my ($customer_id, $campaign_id, $asset_id, $field_type) = @_;

  my $path_template =
'customers/{customer_id}/campaignAssets/{campaign_id}~{asset_id}~{field_type}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $asset_id, $field_type]);
}

# Returns the campaign_audience_view resource name for the specified components.
sub campaign_audience_view {
  my ($customer_id, $campaign_id, $criterion_id) = @_;

  my $path_template =
'customers/{customer_id}/campaignAudienceViews/{campaign_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $criterion_id]);
}

# Returns the campaign_bid_modifier resource name for the specified components.
sub campaign_bid_modifier {
  my ($customer_id, $campaign_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignBidModifiers/{campaign_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $criterion_id]);
}

# Returns the campaign_budget resource name for the specified components.
sub campaign_budget {
  my ($customer_id, $budget_id) = @_;

  my $path_template = 'customers/{customer_id}/campaignBudgets/{budget_id}';

  return expand_path_template($path_template, [$customer_id, $budget_id]);
}

# Returns the campaign_criterion resource name for the specified components.
sub campaign_criterion {
  my ($customer_id, $campaign_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignCriteria/{campaign_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $criterion_id]);
}

# Returns the campaign_criterion_simulation resource name for the specified components.
sub campaign_criterion_simulation {
  my ($customer_id, $campaign_id, $criterion_id, $type, $modification_method,
    $start_date, $end_date)
    = @_;

  my $path_template =
'customers/{customer_id}/campaignCriterionSimulations/{campaign_id}~{criterion_id}~{type}~{modification_method}~{start_date}~{end_date}';

  return expand_path_template(
    $path_template,
    [
      $customer_id,         $campaign_id, $criterion_id, $type,
      $modification_method, $start_date,  $end_date
    ]);
}

# Returns the campaign_draft resource name for the specified components.
sub campaign_draft {
  my ($customer_id, $base_campaign_id, $draft_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignDrafts/{base_campaign_id}~{draft_id}';

  return expand_path_template($path_template,
    [$customer_id, $base_campaign_id, $draft_id]);
}

# Returns the campaign_experiment resource name for the specified components.
sub campaign_experiment {
  my ($customer_id, $campaign_experiment_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignExperiments/{campaign_experiment_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_experiment_id]);
}

# Returns the campaign_extension_setting resource name for the specified components.
sub campaign_extension_setting {
  my ($customer_id, $campaign_id, $extension_type) = @_;

  my $path_template =
'customers/{customer_id}/campaignExtensionSettings/{campaign_id}~{extension_type}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $extension_type]);
}

# Returns the campaign_feed resource name for the specified components.
sub campaign_feed {
  my ($customer_id, $campaign_id, $feed_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignFeeds/{campaign_id}~{feed_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $feed_id]);
}

# Returns the campaign_label resource name for the specified components.
sub campaign_label {
  my ($customer_id, $campaign_id, $label_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignLabels/{campaign_id}~{label_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $label_id]);
}

# Returns the campaign_shared_set resource name for the specified components.
sub campaign_shared_set {
  my ($customer_id, $campaign_id, $shared_set_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignSharedSets/{campaign_id}~{shared_set_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $shared_set_id]);
}

# Returns the carrier_constant resource name for the specified components.
sub carrier_constant {
  my ($criterion_id) = @_;

  my $path_template = 'carrierConstants/{criterion_id}';

  return expand_path_template($path_template, [$criterion_id]);
}

# Returns the change_status resource name for the specified components.
sub change_status {
  my ($customer_id, $change_status_id) = @_;

  my $path_template = 'customers/{customer_id}/changeStatus/{change_status_id}';

  return expand_path_template($path_template,
    [$customer_id, $change_status_id]);
}

# Returns the click_view resource name for the specified components.
sub click_view {
  my ($customer_id, $date_yyyy_MM_dd, $gclid) = @_;

  my $path_template =
    'customers/{customer_id}/clickViews/{date_yyyy_MM_dd}~{gclid}';

  return expand_path_template($path_template,
    [$customer_id, $date_yyyy_MM_dd, $gclid]);
}

# Returns the conversion_action resource name for the specified components.
sub conversion_action {
  my ($customer_id, $conversion_action_id) = @_;

  my $path_template =
    'customers/{customer_id}/conversionActions/{conversion_action_id}';

  return expand_path_template($path_template,
    [$customer_id, $conversion_action_id]);
}

# Returns the currency_constant resource name for the specified components.
sub currency_constant {
  my ($currency_code) = @_;

  my $path_template = 'currencyConstants/{currency_code}';

  return expand_path_template($path_template, [$currency_code]);
}

# Returns the custom_interest resource name for the specified components.
sub custom_interest {
  my ($customer_id, $custom_interest_id) = @_;

  my $path_template =
    'customers/{customer_id}/customInterests/{custom_interest_id}';

  return expand_path_template($path_template,
    [$customer_id, $custom_interest_id]);
}

# Returns the customer resource name for the specified components.
sub customer {
  my ($customer_id) = @_;

  my $path_template = 'customers/{customer_id}';

  return expand_path_template($path_template, [$customer_id]);
}

# Returns the customer_client resource name for the specified components.
sub customer_client {
  my ($customer_id, $client_customer_id) = @_;

  my $path_template =
    'customers/{customer_id}/customerClients/{client_customer_id}';

  return expand_path_template($path_template,
    [$customer_id, $client_customer_id]);
}

# Returns the customer_client_link resource name for the specified components.
sub customer_client_link {
  my ($customer_id, $client_customer_id, $manager_link_id) = @_;

  my $path_template =
'customers/{customer_id}/customerClientLinks/{client_customer_id}~{manager_link_id}';

  return expand_path_template($path_template,
    [$customer_id, $client_customer_id, $manager_link_id]);
}

# Returns the customer_extension_setting resource name for the specified components.
sub customer_extension_setting {
  my ($customer_id, $extension_type) = @_;

  my $path_template =
    'customers/{customer_id}/customerExtensionSettings/{extension_type}';

  return expand_path_template($path_template, [$customer_id, $extension_type]);
}

# Returns the customer_feed resource name for the specified components.
sub customer_feed {
  my ($customer_id, $feed_id) = @_;

  my $path_template = 'customers/{customer_id}/customerFeeds/{feed_id}';

  return expand_path_template($path_template, [$customer_id, $feed_id]);
}

# Returns the customer_label resource name for the specified components.
sub customer_label {
  my ($customer_id, $label_id) = @_;

  my $path_template = 'customers/{customer_id}/customerLabels/{label_id}';

  return expand_path_template($path_template, [$customer_id, $label_id]);
}

# Returns the customer_manager_link resource name for the specified components.
sub customer_manager_link {
  my ($customer_id, $manager_customer_id, $manager_link_id) = @_;

  my $path_template =
'customers/{customer_id}/customerManagerLinks/{manager_customer_id}~{manager_link_id}';

  return expand_path_template($path_template,
    [$customer_id, $manager_customer_id, $manager_link_id]);
}

# Returns the customer_negative_criterion resource name for the specified components.
sub customer_negative_criterion {
  my ($customer_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/customerNegativeCriteria/{criterion_id}';

  return expand_path_template($path_template, [$customer_id, $criterion_id]);
}

# Returns the detail_placement_view resource name for the specified components.
sub detail_placement_view {
  my ($customer_id, $ad_group_id, $base64_placement) = @_;

  my $path_template =
'customers/{customer_id}/detailPlacementViews/{ad_group_id}~{base64_placement}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $base64_placement]);
}

# Returns the display_keyword_view resource name for the specified components.
sub display_keyword_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/displayKeywordViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the distance_view resource name for the specified components.
sub distance_view {
  my ($customer_id, $distance_bucket) = @_;

  my $path_template =
    'customers/{customer_id}/distanceViews/1~{distance_bucket}';

  return expand_path_template($path_template, [$customer_id, $distance_bucket]);
}

# Returns the domain_category resource name for the specified components.
sub domain_category {
  my ($customer_id, $campaign_id, $category_base64, $language_code) = @_;

  my $path_template =
'customers/{customer_id}/domainCategories/{campaign_id}~{category_base64}~{language_code}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $category_base64, $language_code]);
}

# Returns the dynamic_search_ads_search_term_view resource name for the specified components.
sub dynamic_search_ads_search_term_view {
  my (
    $customer_id, $ad_group_id,     $search_term_fp,
    $headline_fp, $landing_page_fp, $page_url_fp
  ) = @_;

  my $path_template =
'customers/{customer_id}/dynamicSearchAdsSearchTermViews/{ad_group_id}~{search_term_fp}~{headline_fp}~{landing_page_fp}~{page_url_fp}';

  return expand_path_template(
    $path_template,
    [
      $customer_id, $ad_group_id,     $search_term_fp,
      $headline_fp, $landing_page_fp, $page_url_fp
    ]);
}

# Returns the expanded_landing_page_view resource name for the specified components.
sub expanded_landing_page_view {
  my ($customer_id, $expanded_final_url_fingerprint) = @_;

  my $path_template =
'customers/{customer_id}/expandedLandingPageViews/{expanded_final_url_fingerprint}';

  return expand_path_template($path_template,
    [$customer_id, $expanded_final_url_fingerprint]);
}

# Returns the extension_feed_item resource name for the specified components.
sub extension_feed_item {
  my ($customer_id, $feed_item_id) = @_;

  my $path_template =
    'customers/{customer_id}/extensionFeedItems/{feed_item_id}';

  return expand_path_template($path_template, [$customer_id, $feed_item_id]);
}

# Returns the feed resource name for the specified components.
sub feed {
  my ($customer_id, $feed_id) = @_;

  my $path_template = 'customers/{customer_id}/feeds/{feed_id}';

  return expand_path_template($path_template, [$customer_id, $feed_id]);
}

# Returns the feed_item resource name for the specified components.
sub feed_item {
  my ($customer_id, $feed_id, $feed_item_id) = @_;

  my $path_template =
    'customers/{customer_id}/feedItems/{feed_id}~{feed_item_id}';

  return expand_path_template($path_template,
    [$customer_id, $feed_id, $feed_item_id]);
}

# Returns the feed_item_target resource name for the specified components.
sub feed_item_target {
  my ($customer_id, $feed_id, $feed_item_id, $feed_item_target_type,
    $feed_item_target_id)
    = @_;

  my $path_template =
'customers/{customer_id}/feedItemTargets/{feed_id}~{feed_item_id}~{feed_item_target_type}~{feed_item_target_id}';

  return expand_path_template(
    $path_template,
    [
      $customer_id,           $feed_id, $feed_item_id,
      $feed_item_target_type, $feed_item_target_id
    ]);
}

# Returns the feed_mapping resource name for the specified components.
sub feed_mapping {
  my ($customer_id, $feed_id, $feed_mapping_id) = @_;

  my $path_template =
    'customers/{customer_id}/feedMappings/{feed_id}~{feed_mapping_id}';

  return expand_path_template($path_template,
    [$customer_id, $feed_id, $feed_mapping_id]);
}

# Returns the feed_placeholder_view resource name for the specified components.
sub feed_placeholder_view {
  my ($customer_id, $placeholder_type) = @_;

  my $path_template =
    'customers/{customer_id}/feedPlaceholderViews/{placeholder_type}';

  return expand_path_template($path_template,
    [$customer_id, $placeholder_type]);
}

# Returns the gender_view resource name for the specified components.
sub gender_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/genderViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the geo_target_constant resource name for the specified components.
sub geo_target_constant {
  my ($geo_target_constant_id) = @_;

  my $path_template = 'geoTargetConstants/{geo_target_constant_id}';

  return expand_path_template($path_template, [$geo_target_constant_id]);
}

# Returns the geographic_view resource name for the specified components.
sub geographic_view {
  my ($customer_id, $country_criterion_id, $location_type) = @_;

  my $path_template =
'customers/{customer_id}/geographicViews/{country_criterion_id}~{location_type}';

  return expand_path_template($path_template,
    [$customer_id, $country_criterion_id, $location_type]);
}

# Returns the google_ads_field resource name for the specified components.
sub google_ads_field {
  my ($name) = @_;

  my $path_template = 'googleAdsFields/{name}';

  return expand_path_template($path_template, [$name]);
}

# Returns the group_placement_view resource name for the specified components.
sub group_placement_view {
  my ($customer_id, $ad_group_id, $base64_placement) = @_;

  my $path_template =
'customers/{customer_id}/groupPlacementViews/{ad_group_id}~{base64_placement}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $base64_placement]);
}

# Returns the hotel_group_view resource name for the specified components.
sub hotel_group_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/hotelGroupViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the hotel_performance_view resource name for the specified components.
sub hotel_performance_view {
  my ($customer_id) = @_;

  my $path_template = 'customers/{customer_id}/hotelPerformanceView';

  return expand_path_template($path_template, [$customer_id]);
}

# Returns the income_range_view resource name for the specified components.
sub income_range_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/incomeRangeViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the invoice resource name for the specified components.
sub invoice {
  my ($customer_id, $invoice_id) = @_;

  my $path_template = 'customers/{customer_id}/invoices/{invoice_id}';

  return expand_path_template($path_template, [$customer_id, $invoice_id]);
}

# Returns the keyword_plan resource name for the specified components.
sub keyword_plan {
  my ($customer_id, $kp_plan_id) = @_;

  my $path_template = 'customers/{customer_id}/keywordPlans/{kp_plan_id}';

  return expand_path_template($path_template, [$customer_id, $kp_plan_id]);
}

# Returns the keyword_plan_ad_group resource name for the specified components.
sub keyword_plan_ad_group {
  my ($customer_id, $kp_ad_group_id) = @_;

  my $path_template =
    'customers/{customer_id}/keywordPlanAdGroups/{kp_ad_group_id}';

  return expand_path_template($path_template, [$customer_id, $kp_ad_group_id]);
}

# Returns the keyword_plan_ad_group_keyword resource name for the specified components.
sub keyword_plan_ad_group_keyword {
  my ($customer_id, $kp_ad_group_keyword_id) = @_;

  my $path_template =
'customers/{customer_id}/keywordPlanAdGroupKeywords/{kp_ad_group_keyword_id}';

  return expand_path_template($path_template,
    [$customer_id, $kp_ad_group_keyword_id]);
}

# Returns the keyword_plan_campaign resource name for the specified components.
sub keyword_plan_campaign {
  my ($customer_id, $kp_campaign_id) = @_;

  my $path_template =
    'customers/{customer_id}/keywordPlanCampaigns/{kp_campaign_id}';

  return expand_path_template($path_template, [$customer_id, $kp_campaign_id]);
}

# Returns the keyword_plan_campaign_keyword resource name for the specified components.
sub keyword_plan_campaign_keyword {
  my ($customer_id, $kp_campaign_keyword_id) = @_;

  my $path_template =
'customers/{customer_id}/keywordPlanCampaignKeywords/{kp_campaign_keyword_id}';

  return expand_path_template($path_template,
    [$customer_id, $kp_campaign_keyword_id]);
}

# Returns the keyword_view resource name for the specified components.
sub keyword_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/keywordViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the label resource name for the specified components.
sub label {
  my ($customer_id, $label_id) = @_;

  my $path_template = 'customers/{customer_id}/labels/{label_id}';

  return expand_path_template($path_template, [$customer_id, $label_id]);
}

# Returns the landing_page_view resource name for the specified components.
sub landing_page_view {
  my ($customer_id, $unexpanded_final_url_fingerprint) = @_;

  my $path_template =
'customers/{customer_id}/landingPageViews/{unexpanded_final_url_fingerprint}';

  return expand_path_template($path_template,
    [$customer_id, $unexpanded_final_url_fingerprint]);
}

# Returns the language_constant resource name for the specified components.
sub language_constant {
  my ($criterion_id) = @_;

  my $path_template = 'languageConstants/{criterion_id}';

  return expand_path_template($path_template, [$criterion_id]);
}

# Returns the location_view resource name for the specified components.
sub location_view {
  my ($customer_id, $campaign_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/locationViews/{campaign_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $criterion_id]);
}

# Returns the managed_placement_view resource name for the specified components.
sub managed_placement_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
'customers/{customer_id}/managedPlacementViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the media_file resource name for the specified components.
sub media_file {
  my ($customer_id, $media_file_id) = @_;

  my $path_template = 'customers/{customer_id}/mediaFiles/{media_file_id}';

  return expand_path_template($path_template, [$customer_id, $media_file_id]);
}

# Returns the merchant_center_link resource name for the specified components.
sub merchant_center_link {
  my ($customer_id, $merchant_center_id) = @_;

  my $path_template =
    'customers/{customer_id}/merchantCenterLinks/{merchant_center_id}';

  return expand_path_template($path_template,
    [$customer_id, $merchant_center_id]);
}

# Returns the mobile_app_category_constant resource name for the specified components.
sub mobile_app_category_constant {
  my ($mobile_app_category_id) = @_;

  my $path_template = 'mobileAppCategoryConstants/{mobile_app_category_id}';

  return expand_path_template($path_template, [$mobile_app_category_id]);
}

# Returns the mobile_device_constant resource name for the specified components.
sub mobile_device_constant {
  my ($criterion_id) = @_;

  my $path_template = 'mobileDeviceConstants/{criterion_id}';

  return expand_path_template($path_template, [$criterion_id]);
}

# Returns the offline_user_data_job resource name for the specified components.
sub offline_user_data_job {
  my ($customer_id, $offline_user_data_job_id) = @_;

  my $path_template =
    'customers/{customer_id}/offlineUserDataJobs/{offline_user_data_job_id}';

  return expand_path_template($path_template,
    [$customer_id, $offline_user_data_job_id]);
}

# Returns the operating_system_version_constant resource name for the specified components.
sub operating_system_version_constant {
  my ($criterion_id) = @_;

  my $path_template = 'operatingSystemVersionConstants/{criterion_id}';

  return expand_path_template($path_template, [$criterion_id]);
}

# Returns the paid_organic_search_term_view resource name for the specified components.
sub paid_organic_search_term_view {
  my ($customer_id, $campaign_id, $ad_group_id, $URL_base64_search_term) = @_;

  my $path_template =
'customers/{customer_id}/paidOrganicSearchTermViews/{campaign_id}~{ad_group_id}~{URL_base64_search_term}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $ad_group_id, $URL_base64_search_term]);
}

# Returns the parental_status_view resource name for the specified components.
sub parental_status_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/parentalStatusViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the payments_account resource name for the specified components.
sub payments_account {
  my ($customer_id, $payments_account_id) = @_;

  my $path_template =
    'customers/{customer_id}/paymentsAccounts/{payments_account_id}';

  return expand_path_template($path_template,
    [$customer_id, $payments_account_id]);
}

# Returns the product_bidding_category_constant resource name for the specified components.
sub product_bidding_category_constant {
  my ($country_code, $level, $id) = @_;

  my $path_template =
    'productBiddingCategoryConstants/{country_code}~{level}~{id}';

  return expand_path_template($path_template, [$country_code, $level, $id]);
}

# Returns the product_group_view resource name for the specified components.
sub product_group_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/productGroupViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the recommendation resource name for the specified components.
sub recommendation {
  my ($customer_id, $recommendation_id) = @_;

  my $path_template =
    'customers/{customer_id}/recommendations/{recommendation_id}';

  return expand_path_template($path_template,
    [$customer_id, $recommendation_id]);
}

# Returns the remarketing_action resource name for the specified components.
sub remarketing_action {
  my ($customer_id, $remarketing_action_id) = @_;

  my $path_template =
    'customers/{customer_id}/remarketingActions/{remarketing_action_id}';

  return expand_path_template($path_template,
    [$customer_id, $remarketing_action_id]);
}

# Returns the search_term_view resource name for the specified components.
sub search_term_view {
  my ($customer_id, $campaign_id, $ad_group_id, $URL_base64_search_term) = @_;

  my $path_template =
'customers/{customer_id}/searchTermViews/{campaign_id}~{ad_group_id}~{URL_base64_search_term}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $ad_group_id, $URL_base64_search_term]);
}

# Returns the shared_criterion resource name for the specified components.
sub shared_criterion {
  my ($customer_id, $shared_set_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/sharedCriteria/{shared_set_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $shared_set_id, $criterion_id]);
}

# Returns the shared_set resource name for the specified components.
sub shared_set {
  my ($customer_id, $shared_set_id) = @_;

  my $path_template = 'customers/{customer_id}/sharedSets/{shared_set_id}';

  return expand_path_template($path_template, [$customer_id, $shared_set_id]);
}

# Returns the shopping_performance_view resource name for the specified components.
sub shopping_performance_view {
  my ($customer_id) = @_;

  my $path_template = 'customers/{customer_id}/shoppingPerformanceView';

  return expand_path_template($path_template, [$customer_id]);
}

# Returns the third_party_app_analytics_link resource name for the specified components.
sub third_party_app_analytics_link {
  my ($customer_id, $account_link_id) = @_;

  my $path_template =
    'customers/{customer_id}/thirdPartyAppAnalyticsLinks/{account_link_id}';

  return expand_path_template($path_template, [$customer_id, $account_link_id]);
}

# Returns the topic_constant resource name for the specified components.
sub topic_constant {
  my ($topic_id) = @_;

  my $path_template = 'topicConstants/{topic_id}';

  return expand_path_template($path_template, [$topic_id]);
}

# Returns the topic_view resource name for the specified components.
sub topic_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/topicViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the user_interest resource name for the specified components.
sub user_interest {
  my ($customer_id, $user_interest_id) = @_;

  my $path_template =
    'customers/{customer_id}/userInterests/{user_interest_id}';

  return expand_path_template($path_template,
    [$customer_id, $user_interest_id]);
}

# Returns the user_list resource name for the specified components.
sub user_list {
  my ($customer_id, $user_list_id) = @_;

  my $path_template = 'customers/{customer_id}/userLists/{user_list_id}';

  return expand_path_template($path_template, [$customer_id, $user_list_id]);
}

# Returns the user_location_view resource name for the specified components.
sub user_location_view {
  my ($customer_id, $country_criterion_id, $targeting_location) = @_;

  my $path_template =
'customers/{customer_id}/userLocationViews/{country_criterion_id}~{targeting_location}';

  return expand_path_template($path_template,
    [$customer_id, $country_criterion_id, $targeting_location]);
}

# Returns the video resource name for the specified components.
sub video {
  my ($customer_id, $video_id) = @_;

  my $path_template = 'customers/{customer_id}/videos/{video_id}';

  return expand_path_template($path_template, [$customer_id, $video_id]);
}

1;
