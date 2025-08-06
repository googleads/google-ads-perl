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

package Google::Ads::GoogleAds::V21::Utils::ResourceNames;

use strict;
use warnings;

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

# Returns the accessible_bidding_strategy resource name for the specified components.
sub accessible_bidding_strategy {
  my ($customer_id, $bidding_strategy_id) = @_;

  my $path_template =
    'customers/{customer_id}/accessibleBiddingStrategies/{bidding_strategy_id}';

  return expand_path_template($path_template,
    [$customer_id, $bidding_strategy_id]);
}

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

# Returns the ad_group_ad_asset_combination_view resource name for the specified components.
sub ad_group_ad_asset_combination_view {
  my ($customer_id, $ad_group_id, $ad_id, $asset_combination_id_low,
    $asset_combination_id_high)
    = @_;

  my $path_template =
'customers/{customer_id}/adGroupAdAssetCombinationViews/{ad_group_id}~{ad_id}~{asset_combination_id_low}~{asset_combination_id_high}';

  return expand_path_template(
    $path_template,
    [
      $customer_id, $ad_group_id,
      $ad_id,       $asset_combination_id_low,
      $asset_combination_id_high
    ]);
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

# Returns the ad_group_asset resource name for the specified components.
sub ad_group_asset {
  my ($customer_id, $ad_group_id, $asset_id, $field_type) = @_;

  my $path_template =
'customers/{customer_id}/adGroupAssets/{ad_group_id}~{asset_id}~{field_type}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $asset_id, $field_type]);
}

# Returns the ad_group_asset_set resource name for the specified components.
sub ad_group_asset_set {
  my ($customer_id, $ad_group_id, $asset_set_id) = @_;

  my $path_template =
    'customers/{customer_id}/adGroupAssetSets/{ad_group_id}~{asset_set_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $asset_set_id]);
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

# Returns the ad_group_criterion_customizer resource name for the specified components.
sub ad_group_criterion_customizer {
  my ($customer_id, $ad_group_id, $criterion_id, $customizer_attribute_id) = @_;

  my $path_template =
'customers/{customer_id}/adGroupCriterionCustomizers/{ad_group_id}~{criterion_id}~{customizer_attribute_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id, $customizer_attribute_id]);
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

# Returns the ad_group_customizer resource name for the specified components.
sub ad_group_customizer {
  my ($customer_id, $ad_group_id, $customizer_attribute_id) = @_;

  my $path_template =
'customers/{customer_id}/adGroupCustomizers/{ad_group_id}~{customizer_attribute_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $customizer_attribute_id]);
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

# Returns the ai_max_search_term_ad_combination_view resource name for the specified components.
sub ai_max_search_term_ad_combination_view {
  my ($customer_id, $ad_group_id, $URL_base64_search_term,
    $URL_base64_landing_page, $URL_base64_headline)
    = @_;

  my $path_template =
'customers/{customer_id}/aiMaxSearchTermAdCombinationViews/{ad_group_id}~{URL_base64_search_term}~{URL_base64_landing_page}~{URL_base64_headline}';

  return expand_path_template(
    $path_template,
    [
      $customer_id,            $ad_group_id,
      $URL_base64_search_term, $URL_base64_landing_page,
      $URL_base64_headline
    ]);
}

# Returns the android_privacy_shared_key_google_ad_group resource name for the specified components.
sub android_privacy_shared_key_google_ad_group {
  my (
    $customer_id,
    $campaign_id,
    $ad_group_id,
    $android_privacy_interaction_type,
    $android_privacy_network_type,
    $android_privacy_interaction_dateyyyy_mm_dd
  ) = @_;

  my $path_template =
'customers/{customer_id}/androidPrivacySharedKeyGoogleAdGroups/{campaign_id}~{ad_group_id}~{android_privacy_interaction_type}~{android_privacy_network_type}~{android_privacy_interaction_dateyyyy_mm_dd}';

  return expand_path_template(
    $path_template,
    [
      $customer_id,
      $campaign_id,
      $ad_group_id,
      $android_privacy_interaction_type,
      $android_privacy_network_type,
      $android_privacy_interaction_dateyyyy_mm_dd
    ]);
}

# Returns the android_privacy_shared_key_google_campaign resource name for the specified components.
sub android_privacy_shared_key_google_campaign {
  my (
    $customer_id, $campaign_id,
    $android_privacy_interaction_type,
    $android_privacy_interaction_dateyyyy_mm_dd
  ) = @_;

  my $path_template =
'customers/{customer_id}/androidPrivacySharedKeyGoogleCampaigns/{campaign_id}~{android_privacy_interaction_type}~{android_privacy_interaction_dateyyyy_mm_dd}';

  return expand_path_template(
    $path_template,
    [
      $customer_id,
      $campaign_id,
      $android_privacy_interaction_type,
      $android_privacy_interaction_dateyyyy_mm_dd
    ]);
}

# Returns the android_privacy_shared_key_google_network_type resource name for the specified components.
sub android_privacy_shared_key_google_network_type {
  my ($customer_id, $campaign_id, $android_privacy_interaction_type,
    $android_privacy_network_type, $android_privacy_interaction_dateyyyy_mm_dd)
    = @_;

  my $path_template =
'customers/{customer_id}/androidPrivacySharedKeyGoogleNetworkTypes/{campaign_id}~{android_privacy_interaction_type}~{android_privacy_network_type}~{android_privacy_interaction_dateyyyy_mm_dd}';

  return expand_path_template(
    $path_template,
    [
      $customer_id,
      $campaign_id,
      $android_privacy_interaction_type,
      $android_privacy_network_type,
      $android_privacy_interaction_dateyyyy_mm_dd
    ]);
}

# Returns the asset resource name for the specified components.
sub asset {
  my ($customer_id, $asset_id) = @_;

  my $path_template = 'customers/{customer_id}/assets/{asset_id}';

  return expand_path_template($path_template, [$customer_id, $asset_id]);
}

# Returns the asset_field_type_view resource name for the specified components.
sub asset_field_type_view {
  my ($customer_id, $field_type) = @_;

  my $path_template =
    'customers/{customer_id}/assetFieldTypeViews/{field_type}';

  return expand_path_template($path_template, [$customer_id, $field_type]);
}

# Returns the asset_group resource name for the specified components.
sub asset_group {
  my ($customer_id, $asset_group_id) = @_;

  my $path_template = 'customers/{customer_id}/assetGroups/{asset_group_id}';

  return expand_path_template($path_template, [$customer_id, $asset_group_id]);
}

# Returns the asset_group_asset resource name for the specified components.
sub asset_group_asset {
  my ($customer_id, $asset_group_id, $asset_id, $field_type) = @_;

  my $path_template =
'customers/{customer_id}/assetGroupAssets/{asset_group_id}~{asset_id}~{field_type}';

  return expand_path_template($path_template,
    [$customer_id, $asset_group_id, $asset_id, $field_type]);
}

# Returns the asset_group_listing_group_filter resource name for the specified components.
sub asset_group_listing_group_filter {
  my ($customer_id, $asset_group_id, $listing_group_filter_id) = @_;

  my $path_template =
'customers/{customer_id}/assetGroupListingGroupFilters/{asset_group_id}~{listing_group_filter_id}';

  return expand_path_template($path_template,
    [$customer_id, $asset_group_id, $listing_group_filter_id]);
}

# Returns the asset_group_product_group_view resource name for the specified components.
sub asset_group_product_group_view {
  my ($customer_id, $asset_group_id, $listing_group_filter_id) = @_;

  my $path_template =
'customers/{customer_id}/assetGroupProductGroupViews/{asset_group_id}~{listing_group_filter_id}';

  return expand_path_template($path_template,
    [$customer_id, $asset_group_id, $listing_group_filter_id]);
}

# Returns the asset_group_signal resource name for the specified components.
sub asset_group_signal {
  my ($customer_id, $asset_group_id, $signal_id) = @_;

  my $path_template =
    'customers/{customer_id}/assetGroupSignals/{asset_group_id}~{signal_id}';

  return expand_path_template($path_template,
    [$customer_id, $asset_group_id, $signal_id]);
}

# Returns the asset_group_top_combination_view resource name for the specified components.
sub asset_group_top_combination_view {
  my ($customer_id, $asset_group_id, $asset_combination_category) = @_;

  my $path_template =
'&quot;customers/{customer_id}/assetGroupTopCombinationViews/{asset_group_id}~{asset_combination_category}&quot;';

  return expand_path_template($path_template,
    [$customer_id, $asset_group_id, $asset_combination_category]);
}

# Returns the asset_set resource name for the specified components.
sub asset_set {
  my ($customer_id, $asset_set_id) = @_;

  my $path_template = 'customers/{customer_id}/assetSets/{asset_set_id}';

  return expand_path_template($path_template, [$customer_id, $asset_set_id]);
}

# Returns the asset_set_asset resource name for the specified components.
sub asset_set_asset {
  my ($customer_id, $asset_set_id, $asset_id) = @_;

  my $path_template =
    'customers/{customer_id}/assetSetAssets/{asset_set_id}~{asset_id}';

  return expand_path_template($path_template,
    [$customer_id, $asset_set_id, $asset_id]);
}

# Returns the asset_set_type_view resource name for the specified components.
sub asset_set_type_view {
  my ($customer_id, $asset_set_type) = @_;

  my $path_template =
    'customers/{customer_id}/assetSetTypeViews/{asset_set_type}';

  return expand_path_template($path_template, [$customer_id, $asset_set_type]);
}

# Returns the audience resource name for the specified components.
sub audience {
  my ($customer_id, $audience_id) = @_;

  my $path_template = 'customers/{customer_id}/audiences/{audience_id}';

  return expand_path_template($path_template, [$customer_id, $audience_id]);
}

# Returns the batch_job resource name for the specified components.
sub batch_job {
  my ($customer_id, $batch_job_id) = @_;

  my $path_template = 'customers/{customer_id}/batchJobs/{batch_job_id}';

  return expand_path_template($path_template, [$customer_id, $batch_job_id]);
}

# Returns the bidding_data_exclusion resource name for the specified components.
sub bidding_data_exclusion {
  my ($customer_id, $data_exclusion_id) = @_;

  my $path_template =
    'customers/{customer_id}/biddingDataExclusions/{data_exclusion_id}';

  return expand_path_template($path_template,
    [$customer_id, $data_exclusion_id]);
}

# Returns the bidding_seasonality_adjustment resource name for the specified components.
sub bidding_seasonality_adjustment {
  my ($customer_id, $seasonality_adjustment_id) = @_;

  my $path_template =
'customers/{customer_id}/biddingSeasonalityAdjustments/{seasonality_adjustment_id}';

  return expand_path_template($path_template,
    [$customer_id, $seasonality_adjustment_id]);
}

# Returns the bidding_strategy resource name for the specified components.
sub bidding_strategy {
  my ($customer_id, $bidding_strategy_id) = @_;

  my $path_template =
    'customers/{customer_id}/biddingStrategies/{bidding_strategy_id}';

  return expand_path_template($path_template,
    [$customer_id, $bidding_strategy_id]);
}

# Returns the bidding_strategy_simulation resource name for the specified components.
sub bidding_strategy_simulation {
  my ($customer_id, $bidding_strategy_id, $type, $modification_method,
    $start_date, $end_date)
    = @_;

  my $path_template =
'customers/{customer_id}/biddingStrategySimulations/{bidding_strategy_id}~{type}~{modification_method}~{start_date}~{end_date}';

  return expand_path_template(
    $path_template,
    [
      $customer_id,         $bidding_strategy_id, $type,
      $modification_method, $start_date,          $end_date
    ]);
}

# Returns the billing_setup resource name for the specified components.
sub billing_setup {
  my ($customer_id, $billing_setup_id) = @_;

  my $path_template =
    'customers/{customer_id}/billingSetups/{billing_setup_id}';

  return expand_path_template($path_template,
    [$customer_id, $billing_setup_id]);
}

# Returns the call_view resource name for the specified components.
sub call_view {
  my ($customer_id, $call_detail_id) = @_;

  my $path_template = 'customers/{customer_id}/callViews/{call_detail_id}';

  return expand_path_template($path_template, [$customer_id, $call_detail_id]);
}

# Returns the campaign resource name for the specified components.
sub campaign {
  my ($customer_id, $campaign_id) = @_;

  my $path_template = 'customers/{customer_id}/campaigns/{campaign_id}';

  return expand_path_template($path_template, [$customer_id, $campaign_id]);
}

# Returns the campaign_aggregate_asset_view resource name for the specified components.
sub campaign_aggregate_asset_view {
  my ($customer_id, $campaign_id, $asset_id, $asset_link_source, $field_type) =
    @_;

  my $path_template =
'customers/{customer_id}/campaignAggregateAssetViews/{campaign_id}~{asset_id}~{asset_link_source}~{field_type}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $asset_id, $asset_link_source, $field_type]);
}

# Returns the campaign_asset resource name for the specified components.
sub campaign_asset {
  my ($customer_id, $campaign_id, $asset_id, $field_type) = @_;

  my $path_template =
'customers/{customer_id}/campaignAssets/{campaign_id}~{asset_id}~{field_type}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $asset_id, $field_type]);
}

# Returns the campaign_asset_set resource name for the specified components.
sub campaign_asset_set {
  my ($customer_id, $campaign_id, $asset_set_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignAssetSets/{campaign_id}~{asset_set_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $asset_set_id]);
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
  my ($customer_id, $campaign_budget_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignBudgets/{campaign_budget_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_budget_id]);
}

# Returns the campaign_conversion_goal resource name for the specified components.
sub campaign_conversion_goal {
  my ($customer_id, $campaign_id, $category, $origin) = @_;

  my $path_template =
'customers/{customer_id}/campaignConversionGoals/{campaign_id}~{category}~{origin}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $category, $origin]);
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

# Returns the campaign_customizer resource name for the specified components.
sub campaign_customizer {
  my ($customer_id, $campaign_id, $customizer_attribute_id) = @_;

  my $path_template =
'customers/{customer_id}/campaignCustomizers/{campaign_id}~{customizer_attribute_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $customizer_attribute_id]);
}

# Returns the campaign_draft resource name for the specified components.
sub campaign_draft {
  my ($customer_id, $base_campaign_id, $draft_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignDrafts/{base_campaign_id}~{draft_id}';

  return expand_path_template($path_template,
    [$customer_id, $base_campaign_id, $draft_id]);
}

# Returns the campaign_group resource name for the specified components.
sub campaign_group {
  my ($customer_id, $campaign_group_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignGroups/{campaign_group_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_group_id]);
}

# Returns the campaign_label resource name for the specified components.
sub campaign_label {
  my ($customer_id, $campaign_id, $label_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignLabels/{campaign_id}~{label_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $label_id]);
}

# Returns the campaign_lifecycle_goal resource name for the specified components.
sub campaign_lifecycle_goal {
  my ($customer_id, $campaign_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignLifecycleGoal/{campaign_id}';

  return expand_path_template($path_template, [$customer_id, $campaign_id]);
}

# Returns the campaign_search_term_insight resource name for the specified components.
sub campaign_search_term_insight {
  my ($customer_id, $campaign_id, $category_id) = @_;

  my $path_template =
'customers/{customer_id}/campaignSearchTermInsights/{campaign_id}~{category_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $category_id]);
}

# Returns the campaign_search_term_view resource name for the specified components.
sub campaign_search_term_view {
  my ($customer_id, $campaign_id, $URL_base64_search_term) = @_;

  my $path_template =
'customers/{customer_id}/campaignSearchTermViews/{campaign_id}~{URL_base64_search_term}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $URL_base64_search_term]);
}

# Returns the campaign_shared_set resource name for the specified components.
sub campaign_shared_set {
  my ($customer_id, $campaign_id, $shared_set_id) = @_;

  my $path_template =
    'customers/{customer_id}/campaignSharedSets/{campaign_id}~{shared_set_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $shared_set_id]);
}

# Returns the campaign_simulation resource name for the specified components.
sub campaign_simulation {
  my ($customer_id, $campaign_id, $type, $modification_method, $start_date,
    $end_date)
    = @_;

  my $path_template =
'customers/{customer_id}/campaignSimulations/{campaign_id}~{type}~{modification_method}~{start_date}~{end_date}';

  return expand_path_template(
    $path_template,
    [
      $customer_id,         $campaign_id, $type,
      $modification_method, $start_date,  $end_date
    ]);
}

# Returns the carrier_constant resource name for the specified components.
sub carrier_constant {
  my ($criterion_id) = @_;

  my $path_template = 'carrierConstants/{criterion_id}';

  return expand_path_template($path_template, [$criterion_id]);
}

# Returns the change_event resource name for the specified components.
sub change_event {
  my ($customer_id, $timestamp_micros, $command_index, $mutate_index) = @_;

  my $path_template =
'customers/{customer_id}/changeEvents/{timestamp_micros}~{command_index}~{mutate_index}';

  return expand_path_template($path_template,
    [$customer_id, $timestamp_micros, $command_index, $mutate_index]);
}

# Returns the change_status resource name for the specified components.
sub change_status {
  my ($customer_id, $change_status_id) = @_;

  my $path_template = 'customers/{customer_id}/changeStatus/{change_status_id}';

  return expand_path_template($path_template,
    [$customer_id, $change_status_id]);
}

# Returns the channel_aggregate_asset_view resource name for the specified components.
sub channel_aggregate_asset_view {
  my ($customer_id, $advertising_channel_type, $asset_id, $asset_source,
    $field_type)
    = @_;

  my $path_template =
'customers/{customer_id}/channelAggregateAssetViews/{advertising_channel_type}~{asset_id}~{asset_source}~{field_type}&quot;';

  return expand_path_template(
    $path_template,
    [
      $customer_id,  $advertising_channel_type, $asset_id,
      $asset_source, $field_type
    ]);
}

# Returns the click_view resource name for the specified components.
sub click_view {
  my ($customer_id, $date_yyyy_MM_dd, $gclid) = @_;

  my $path_template =
    'customers/{customer_id}/clickViews/{date_yyyy_MM_dd}~{gclid}';

  return expand_path_template($path_template,
    [$customer_id, $date_yyyy_MM_dd, $gclid]);
}

# Returns the combined_audience resource name for the specified components.
sub combined_audience {
  my ($customer_id, $combined_audience_id) = @_;

  my $path_template =
    'customers/{customer_id}/combinedAudience/{combined_audience_id}';

  return expand_path_template($path_template,
    [$customer_id, $combined_audience_id]);
}

# Returns the content_criterion_view resource name for the specified components.
sub content_criterion_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
'customers/{customer_id}/contentCriterionViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the conversion_action resource name for the specified components.
sub conversion_action {
  my ($customer_id, $conversion_action_id) = @_;

  my $path_template =
    'customers/{customer_id}/conversionActions/{conversion_action_id}';

  return expand_path_template($path_template,
    [$customer_id, $conversion_action_id]);
}

# Returns the conversion_custom_variable resource name for the specified components.
sub conversion_custom_variable {
  my ($customer_id, $conversion_custom_variable_id) = @_;

  my $path_template =
'customers/{customer_id}/conversionCustomVariables/{conversion_custom_variable_id}';

  return expand_path_template($path_template,
    [$customer_id, $conversion_custom_variable_id]);
}

# Returns the conversion_goal_campaign_config resource name for the specified components.
sub conversion_goal_campaign_config {
  my ($customer_id, $campaign_id) = @_;

  my $path_template =
    'customers/{customer_id}/conversionGoalCampaignConfigs/{campaign_id}';

  return expand_path_template($path_template, [$customer_id, $campaign_id]);
}

# Returns the conversion_value_rule resource name for the specified components.
sub conversion_value_rule {
  my ($customer_id, $conversion_value_rule_id) = @_;

  my $path_template =
    'customers/{customer_id}/conversionValueRules/{conversion_value_rule_id}';

  return expand_path_template($path_template,
    [$customer_id, $conversion_value_rule_id]);
}

# Returns the conversion_value_rule_set resource name for the specified components.
sub conversion_value_rule_set {
  my ($customer_id, $conversion_value_rule_set_id) = @_;

  my $path_template =
'customers/{customer_id}/conversionValueRuleSets/{conversion_value_rule_set_id}';

  return expand_path_template($path_template,
    [$customer_id, $conversion_value_rule_set_id]);
}

# Returns the currency_constant resource name for the specified components.
sub currency_constant {
  my ($code) = @_;

  my $path_template = 'currencyConstants/{code}';

  return expand_path_template($path_template, [$code]);
}

# Returns the custom_audience resource name for the specified components.
sub custom_audience {
  my ($customer_id, $custom_audience_id) = @_;

  my $path_template =
    'customers/{customer_id}/customAudiences/{custom_audience_id}';

  return expand_path_template($path_template,
    [$customer_id, $custom_audience_id]);
}

# Returns the custom_conversion_goal resource name for the specified components.
sub custom_conversion_goal {
  my ($customer_id, $goal_id) = @_;

  my $path_template = 'customers/{customer_id}/customConversionGoals/{goal_id}';

  return expand_path_template($path_template, [$customer_id, $goal_id]);
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

# Returns the customer_asset resource name for the specified components.
sub customer_asset {
  my ($customer_id, $asset_id, $field_type) = @_;

  my $path_template =
    'customers/{customer_id}/customerAssets/{asset_id}~{field_type}';

  return expand_path_template($path_template,
    [$customer_id, $asset_id, $field_type]);
}

# Returns the customer_asset_set resource name for the specified components.
sub customer_asset_set {
  my ($customer_id, $asset_set_id) = @_;

  my $path_template =
    'customers/{customer_id}/customerAssetSets/{asset_set_id}';

  return expand_path_template($path_template, [$customer_id, $asset_set_id]);
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

# Returns the customer_conversion_goal resource name for the specified components.
sub customer_conversion_goal {
  my ($customer_id, $category, $origin) = @_;

  my $path_template =
    'customers/{customer_id}/customerConversionGoals/{category}~{origin}';

  return expand_path_template($path_template,
    [$customer_id, $category, $origin]);
}

# Returns the customer_customizer resource name for the specified components.
sub customer_customizer {
  my ($customer_id, $customizer_attribute_id) = @_;

  my $path_template =
    'customers/{customer_id}/customerCustomizers/{customizer_attribute_id}';

  return expand_path_template($path_template,
    [$customer_id, $customizer_attribute_id]);
}

# Returns the customer_label resource name for the specified components.
sub customer_label {
  my ($customer_id, $label_id) = @_;

  my $path_template = 'customers/{customer_id}/customerLabels/{label_id}';

  return expand_path_template($path_template, [$customer_id, $label_id]);
}

# Returns the customer_lifecycle_goal resource name for the specified components.
sub customer_lifecycle_goal {
  my ($customer_id) = @_;

  my $path_template = 'customers/{customer_id}/customerLifecycleGoal';

  return expand_path_template($path_template, [$customer_id]);
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

# Returns the customer_search_term_insight resource name for the specified components.
sub customer_search_term_insight {
  my ($customer_id, $category_id) = @_;

  my $path_template =
    'customers/{customer_id}/customerSearchTermInsights/{category_id}';

  return expand_path_template($path_template, [$customer_id, $category_id]);
}

# Returns the customer_user_access resource name for the specified components.
sub customer_user_access {
  my ($customer_id, $user_id) = @_;

  my $path_template = 'customers/{customer_id}/customerUserAccesses/{user_id}';

  return expand_path_template($path_template, [$customer_id, $user_id]);
}

# Returns the customer_user_access_invitation resource name for the specified components.
sub customer_user_access_invitation {
  my ($customer_id, $invitation_id) = @_;

  my $path_template =
    'customers/{customer_id}/customerUserAccessInvitations/{invitation_id}';

  return expand_path_template($path_template, [$customer_id, $invitation_id]);
}

# Returns the customizer_attribute resource name for the specified components.
sub customizer_attribute {
  my ($customer_id, $customizer_attribute_id) = @_;

  my $path_template =
    'customers/{customer_id}/customizerAttributes/{customizer_attribute_id}';

  return expand_path_template($path_template,
    [$customer_id, $customizer_attribute_id]);
}

# Returns the data_link resource name for the specified components.
sub data_link {
  my ($customer_id, $product_link_id, $data_link_id) = @_;

  my $path_template =
    'customers/{customer_id}/datalinks/{product_link_id}~{data_link_id}}';

  return expand_path_template($path_template,
    [$customer_id, $product_link_id, $data_link_id]);
}

# Returns the detail_content_suitability_placement_view resource name for the specified components.
sub detail_content_suitability_placement_view {
  my ($customer_id, $placement_fingerprint) = @_;

  my $path_template =
'customers/{customer_id}/detailContentSuitabilityPlacementViews/{placement_fingerprint}';

  return expand_path_template($path_template,
    [$customer_id, $placement_fingerprint]);
}

# Returns the detail_placement_view resource name for the specified components.
sub detail_placement_view {
  my ($customer_id, $ad_group_id, $base64_placement) = @_;

  my $path_template =
'customers/{customer_id}/detailPlacementViews/{ad_group_id}~{base64_placement}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $base64_placement]);
}

# Returns the detailed_demographic resource name for the specified components.
sub detailed_demographic {
  my ($customer_id, $detailed_demographic_id) = @_;

  my $path_template =
    'customers/{customer_id}/detailedDemographics/{detailed_demographic_id}';

  return expand_path_template($path_template,
    [$customer_id, $detailed_demographic_id]);
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
  my ($customer_id, $ad_group_id, $search_term_fingerprint,
    $headline_fingerprint, $landing_page_fingerprint, $page_url_fingerprint)
    = @_;

  my $path_template =
'customers/{customer_id}/dynamicSearchAdsSearchTermViews/{ad_group_id}~{search_term_fingerprint}~{headline_fingerprint}~{landing_page_fingerprint}~{page_url_fingerprint}';

  return expand_path_template(
    $path_template,
    [
      $customer_id,              $ad_group_id,
      $search_term_fingerprint,  $headline_fingerprint,
      $landing_page_fingerprint, $page_url_fingerprint
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

# Returns the experiment resource name for the specified components.
sub experiment {
  my ($customer_id, $experiment_id) = @_;

  my $path_template = 'customers/{customer_id}/experiments/{experiment_id}';

  return expand_path_template($path_template, [$customer_id, $experiment_id]);
}

# Returns the experiment_arm resource name for the specified components.
sub experiment_arm {
  my ($customer_id, $trial_id, $trial_arm_id) = @_;

  my $path_template =
    'customers/{customer_id}/experimentArms/{trial_id}~{trial_arm_id}';

  return expand_path_template($path_template,
    [$customer_id, $trial_id, $trial_arm_id]);
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

# Returns the group_content_suitability_placement_view resource name for the specified components.
sub group_content_suitability_placement_view {
  my ($customer_id, $placement_fingerprint) = @_;

  my $path_template =
'customers/{customer_id}/groupContentSuitabilityPlacementViews/{placement_fingerprint}';

  return expand_path_template($path_template,
    [$customer_id, $placement_fingerprint]);
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

# Returns the hotel_reconciliation resource name for the specified components.
sub hotel_reconciliation {
  my ($customer_id, $commission_id) = @_;

  my $path_template =
    'customers/{customer_id}/hotelReconciliations/{commission_id}';

  return expand_path_template($path_template, [$customer_id, $commission_id]);
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

# Returns the keyword_theme_constant resource name for the specified components.
sub keyword_theme_constant {
  my ($keyword_theme_id, $sub_keyword_theme_id) = @_;

  my $path_template =
    'keywordThemeConstants/{keyword_theme_id}~{sub_keyword_theme_id}';

  return expand_path_template($path_template,
    [$keyword_theme_id, $sub_keyword_theme_id]);
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

# Returns the lead_form_submission_data resource name for the specified components.
sub lead_form_submission_data {
  my ($customer_id, $lead_form_submission_data_id) = @_;

  my $path_template =
'customers/{customer_id}/leadFormSubmissionData/{lead_form_submission_data_id}';

  return expand_path_template($path_template,
    [$customer_id, $lead_form_submission_data_id]);
}

# Returns the life_event resource name for the specified components.
sub life_event {
  my ($customer_id, $life_event_id) = @_;

  my $path_template = 'customers/{customer_id}/lifeEvents/{life_event_id}';

  return expand_path_template($path_template, [$customer_id, $life_event_id]);
}

# Returns the local_services_employee resource name for the specified components.
sub local_services_employee {
  my ($customer_id, $gls_employee_id) = @_;

  my $path_template =
    'customers/{customer_id}/localServicesEmployees/{gls_employee_id}';

  return expand_path_template($path_template, [$customer_id, $gls_employee_id]);
}

# Returns the local_services_lead resource name for the specified components.
sub local_services_lead {
  my ($customer_id, $local_services_lead_id) = @_;

  my $path_template =
    'customers/{customer_id}/localServicesLead/{local_services_lead_id}';

  return expand_path_template($path_template,
    [$customer_id, $local_services_lead_id]);
}

# Returns the local_services_lead_conversation resource name for the specified components.
sub local_services_lead_conversation {
  my ($customer_id, $local_services_lead_conversation_id) = @_;

  my $path_template =
'customers/{customer_id}/localServicesLeadConversation/{local_services_lead_conversation_id}';

  return expand_path_template($path_template,
    [$customer_id, $local_services_lead_conversation_id]);
}

# Returns the local_services_verification_artifact resource name for the specified components.
sub local_services_verification_artifact {
  my ($customer_id, $verification_artifact_id) = @_;

  my $path_template =
'customers/{customer_id}/localServicesVerificationArtifacts/{verification_artifact_id}';

  return expand_path_template($path_template,
    [$customer_id, $verification_artifact_id]);
}

# Returns the location_interest_view resource name for the specified components.
sub location_interest_view {
  my ($customer_id, $campaign_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
'customers/{customer_id}/locationInterestViews/{campaign_id}~{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $ad_group_id, $criterion_id]);
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

# Returns the offline_conversion_upload_client_summary resource name for the specified components.
sub offline_conversion_upload_client_summary {
  my ($customer_id, $client) = @_;

  my $path_template =
    'customers/{customer_id}/offlineConversionUploadClientSummaries/{client}';

  return expand_path_template($path_template, [$customer_id, $client]);
}

# Returns the offline_conversion_upload_conversion_action_summary resource name for the specified components.
sub offline_conversion_upload_conversion_action_summary {
  my ($customer_id, $conversion_action_id, $client) = @_;

  my $path_template =
'customers/{customer_id}/offlineConversionUploadConversionActionSummaries/{conversion_action_id}~{client}';

  return expand_path_template($path_template,
    [$customer_id, $conversion_action_id, $client]);
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

# Returns the per_store_view resource name for the specified components.
sub per_store_view {
  my ($customer_id, $place_id) = @_;

  my $path_template = 'customers/{customer_id}/perStoreViews/{place_id}';

  return expand_path_template($path_template, [$customer_id, $place_id]);
}

# Returns the performance_max_placement_view resource name for the specified components.
sub performance_max_placement_view {
  my ($customer_id, $base_64_placement) = @_;

  my $path_template =
    'customers/{customer_id}/performanceMaxPlacementViews/{base_64_placement}';

  return expand_path_template($path_template,
    [$customer_id, $base_64_placement]);
}

# Returns the product_category_constant resource name for the specified components.
sub product_category_constant {
  my ($level, $category_id) = @_;

  my $path_template = 'productCategoryConstants/{level}~{category_id}';

  return expand_path_template($path_template, [$level, $category_id]);
}

# Returns the product_group_view resource name for the specified components.
sub product_group_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/productGroupViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the product_link resource name for the specified components.
sub product_link {
  my ($customer_id, $product_link_id) = @_;

  my $path_template = 'customers/{customer_id}/productLinks/{product_link_id}_';

  return expand_path_template($path_template, [$customer_id, $product_link_id]);
}

# Returns the product_link_invitation resource name for the specified components.
sub product_link_invitation {
  my ($customer_id, $product_link_invitation_id) = @_;

  my $path_template =
'customers/{customer_id}/productLinkInvitations/{product_link_invitation_id}';

  return expand_path_template($path_template,
    [$customer_id, $product_link_invitation_id]);
}

# Returns the recommendation resource name for the specified components.
sub recommendation {
  my ($customer_id, $recommendation_id) = @_;

  my $path_template =
    'customers/{customer_id}/recommendations/{recommendation_id}';

  return expand_path_template($path_template,
    [$customer_id, $recommendation_id]);
}

# Returns the recommendation_subscription resource name for the specified components.
sub recommendation_subscription {
  my ($customer_id, $recommendation_type) = @_;

  my $path_template =
    'customers/{customer_id}/recommendationSubscriptions/{recommendation_type}';

  return expand_path_template($path_template,
    [$customer_id, $recommendation_type]);
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

# Returns the shopping_product resource name for the specified components.
sub shopping_product {
  my ($customer_id, $merchant_center_id, $channel, $language_code, $feed_label,
    $item_id)
    = @_;

  my $path_template =
'customers/{customer_id}/shoppingProducts/{merchant_center_id}~{channel}~{language_code}~{feed_label}~{item_id}';

  return expand_path_template(
    $path_template,
    [
      $customer_id,   $merchant_center_id, $channel,
      $language_code, $feed_label,         $item_id
    ]);
}

# Returns the smart_campaign_search_term_view resource name for the specified components.
sub smart_campaign_search_term_view {
  my ($customer_id, $campaign_id, $URL_base64_search_term) = @_;

  my $path_template =
'customers/{customer_id}/smartCampaignSearchTermViews/{campaign_id}~{URL_base64_search_term}';

  return expand_path_template($path_template,
    [$customer_id, $campaign_id, $URL_base64_search_term]);
}

# Returns the smart_campaign_setting resource name for the specified components.
sub smart_campaign_setting {
  my ($customer_id, $campaign_id) = @_;

  my $path_template =
    'customers/{customer_id}/smartCampaignSettings/{campaign_id}';

  return expand_path_template($path_template, [$customer_id, $campaign_id]);
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

# Returns the travel_activity_group_view resource name for the specified components.
sub travel_activity_group_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
'customers/{customer_id}/travelActivityGroupViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

# Returns the travel_activity_performance_view resource name for the specified components.
sub travel_activity_performance_view {
  my ($customer_id) = @_;

  my $path_template = 'customers/{customer_id}/travelActivityPerformanceView';

  return expand_path_template($path_template, [$customer_id]);
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

# Returns the user_list_customer_type resource name for the specified components.
sub user_list_customer_type {
  my ($customer_id, $user_list_id, $customer_type_category) = @_;

  my $path_template =
'customers/{customer_id}/userListCustomerTypes/{user_list_id}~{customer_type_category}';

  return expand_path_template($path_template,
    [$customer_id, $user_list_id, $customer_type_category]);
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

# Returns the webpage_view resource name for the specified components.
sub webpage_view {
  my ($customer_id, $ad_group_id, $criterion_id) = @_;

  my $path_template =
    'customers/{customer_id}/webpageViews/{ad_group_id}~{criterion_id}';

  return expand_path_template($path_template,
    [$customer_id, $ad_group_id, $criterion_id]);
}

1;
