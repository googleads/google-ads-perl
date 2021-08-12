#!/usr/bin/perl -w
#
# Copyright 2021, Google LLC
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
# This example shows how to create a Smart Campaign.
#
# More details on Smart Campaigns can be found here:
# https://support.google.com/google-ads/answer/7652860

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V8::Resources::Ad;
use Google::Ads::GoogleAds::V8::Resources::AdGroup;
use Google::Ads::GoogleAds::V8::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V8::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V8::Resources::Campaign;
use Google::Ads::GoogleAds::V8::Resources::CampaignCriterion;
use Google::Ads::GoogleAds::V8::Resources::PhoneNumber;
use Google::Ads::GoogleAds::V8::Resources::SmartCampaignSetting;
use Google::Ads::GoogleAds::V8::Common::AdTextAsset;
use Google::Ads::GoogleAds::V8::Common::AdScheduleInfo;
use Google::Ads::GoogleAds::V8::Common::KeywordThemeInfo;
use Google::Ads::GoogleAds::V8::Common::LocationInfo;
use Google::Ads::GoogleAds::V8::Common::SmartCampaignAdInfo;
use Google::Ads::GoogleAds::V8::Enums::AdGroupTypeEnum qw(SMART_CAMPAIGN_ADS);
use Google::Ads::GoogleAds::V8::Enums::AdTypeEnum qw(SMART_CAMPAIGN_AD);
use Google::Ads::GoogleAds::V8::Enums::AdvertisingChannelTypeEnum qw(SMART);
use Google::Ads::GoogleAds::V8::Enums::AdvertisingChannelSubTypeEnum;
use Google::Ads::GoogleAds::V8::Enums::BudgetTypeEnum;
use Google::Ads::GoogleAds::V8::Enums::CampaignStatusEnum qw(PAUSED);
use Google::Ads::GoogleAds::V8::Enums::CriterionTypeEnum qw(KEYWORD_THEME);
use Google::Ads::GoogleAds::V8::Enums::DayOfWeekEnum qw(MONDAY);
use Google::Ads::GoogleAds::V8::Enums::MinuteOfHourEnum qw(ZERO);
use Google::Ads::GoogleAds::V8::Enums::ProximityRadiusUnitsEnum qw(MILES);
use Google::Ads::GoogleAds::V8::Services::AdGroupService::AdGroupOperation;
use Google::Ads::GoogleAds::V8::Services::AdGroupAdService::AdGroupAdOperation;
use
  Google::Ads::GoogleAds::V8::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V8::Services::CampaignService::CampaignOperation;
use
  Google::Ads::GoogleAds::V8::Services::CampaignCriterionService::CampaignCriterionOperation;
use Google::Ads::GoogleAds::V8::Services::GoogleAdsService::MutateOperation;
use
  Google::Ads::GoogleAds::V8::Services::GoogleAdsService::MutateOperationResponse;
use
  Google::Ads::GoogleAds::V8::Services::KeywordThemeConstantService::SuggestKeywordThemeConstantsRequest;
use
  Google::Ads::GoogleAds::V8::Services::SmartCampaignSettingService::SmartCampaignSettingOperation;
use Google::Ads::GoogleAds::V8::Services::SmartCampaignSuggestService;
use
  Google::Ads::GoogleAds::V8::Services::SmartCampaignSuggestService::BusinessContext;
use
  Google::Ads::GoogleAds::V8::Services::SmartCampaignSuggestService::LocationList;
use
  Google::Ads::GoogleAds::V8::Services::SmartCampaignSuggestService::SmartCampaignSuggestionInfo;
use
  Google::Ads::GoogleAds::V8::Services::SmartCampaignSuggestService::SuggestSmartCampaignAdRequest;
use
  Google::Ads::GoogleAds::V8::Services::SmartCampaignSuggestService::SuggestSmartCampaignBudgetOptionsRequest;
use Google::Ads::GoogleAds::V8::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);
use Data::Dumper;

use constant DEFAULT_KEYWORD_TEXT => "travel";

# Geo target constant for New York City.
use constant GEO_TARGET_CONSTANT         => 1023191;
use constant COUNTRY_CODE                => "US";
use constant LANGUAGE_CODE               => "en";
use constant LANDING_PAGE_URL            => "http://www.example.com";
use constant PHONE_NUMBER                => "555-555-5555";
use constant BUDGET_TEMPORARY_ID         => -1;
use constant SMART_CAMPAIGN_TEMPORARY_ID => -2;
use constant AD_GROUP_TEMPORARY_ID       => -3;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id          = "INSERT_CUSTOMER_ID_HERE";
my $keyword_text         = DEFAULT_KEYWORD_TEXT;
my $business_location_id = undef;
my $business_name        = undef;

sub add_smart_campaign {
  my ($api_client, $customer_id, $keyword_text, $business_location_id,
    $business_name)
    = @_;

  my $keyword_theme_constants =
    _get_keyword_theme_constants($api_client, $keyword_text);

  # Map the KeywordThemeConstants to KeywordThemeInfo objects.
  my $keyword_theme_infos = [];
  foreach my $keyword_theme_constant (@$keyword_theme_constants) {
    push @$keyword_theme_infos,
      Google::Ads::GoogleAds::V8::Common::KeywordThemeInfo->new({
        keywordThemeConstant => $keyword_theme_constant->{resourceName}});
  }

  my $suggestion_info =
    _get_smart_campaign_suggestion_info($business_location_id, $business_name,
    $keyword_theme_infos);
  my $suggested_budget_amount =
    _get_budget_suggestion($api_client, $customer_id, $suggestion_info);
  my $ad_suggestions =
    _get_ad_suggestions($api_client, $customer_id, $suggestion_info);

  # [START add_smart_campaign_7]
  # The below methods create and return MutateOperations that we later provide to the
  # GoogleAdsService.Mutate method in order to create the entities in a single
  # request. Since the entities for a Smart campaign are closely tied to one-another
  # it's considered a best practice to create them in a single Mutate request; the
  # entities will either all complete successfully or fail entirely, leaving no
  # orphaned entities. See:
  # https://developers.google.com/google-ads/api/docs/mutating/overview
  my $campaign_budget_operation =
    _create_campaign_budget_operation($customer_id, $suggested_budget_amount);
  my $smart_campaign_operation = _create_smart_campaign_operation($customer_id);
  my $smart_campaign_setting_operation =
    _create_smart_campaign_setting_operation($customer_id,
    $business_location_id, $business_name);
  my @campaign_criterion_operations =
    _create_campaign_criterion_operations($customer_id, $keyword_theme_infos);
  my $ad_group_operation = _create_ad_group_operation($customer_id);
  my $ad_group_ad_operation =
    _create_ad_group_ad_operation($customer_id, $ad_suggestions);

  # It's important to create these entities in this order because they depend on
  # each other. For example, the SmartCampaignSetting and ad group depend on the
  # campaign and the ad group ad depends on the ad group.
  my $mutate_operations = [
    $campaign_budget_operation, $smart_campaign_operation,
    $smart_campaign_setting_operation
  ];
  push @$mutate_operations, @campaign_criterion_operations;
  push @$mutate_operations, $ad_group_operation;
  push @$mutate_operations, $ad_group_ad_operation;

  # Send the operations in a single mutate request.
  my $mutate_google_ads_response = $api_client->GoogleAdsService()->mutate({
    customerId       => $customer_id,
    mutateOperations => $mutate_operations
  });

  _print_response_details($mutate_google_ads_response);
  # [END add_smart_campaign_7]

  return 1;
}

# [START add_smart_campaign]
# Retrieves keyword theme constants for the given criteria.
sub _get_keyword_theme_constants {
  my ($api_client, $keyword_text) = @_;

  my $response = $api_client->KeywordThemeConstantService()->suggest(
    Google::Ads::GoogleAds::V8::Services::KeywordThemeConstantService::SuggestKeywordThemeConstantsRequest
      ->new({
        queryText    => $keyword_text,
        countryCode  => COUNTRY_CODE,
        languageCode => LANGUAGE_CODE
      }));

  printf "Retrieved %d keyword theme constants using the keyword '%s'.\n",
    scalar(@{$response->{keywordThemeConstants}}), $keyword_text;

  return $response->{keywordThemeConstants};
}
# [END add_smart_campaign]

# [START add_smart_campaign_9]
# Builds a SmartCampaignSuggestionInfo object with business details.
# The details are used by the SmartCampaignSuggestService to suggest a budget
# amount as well as creatives for the ad.
# Note that when retrieving ad creative suggestions you must set the
# "final_url", "language_code" and "keyword_themes" fields on the
# SmartCampaignSuggestionInfo instance.
sub _get_smart_campaign_suggestion_info {
  my ($business_location_id, $business_name, $keyword_theme_infos) = @_;

  my $suggestion_info =
    Google::Ads::GoogleAds::V8::Services::SmartCampaignSuggestService::SmartCampaignSuggestionInfo
    ->new({
      # Add the URL of the campaign's landing page.
      finalUrl => LANDING_PAGE_URL,
      # Add the language code for the campaign.
      languageCode => LANGUAGE_CODE,
      # Construct location information using the given geo target constant.
      # It's also possible to provide a geographic proximity using the
      # "proximity" field on suggestion_info, for example:
      #
      # proximity => Google::Ads::GoogleAds::V8::Common::ProximityInfo->new({
      #   address => Google::Ads::GoogleAds::V8::Common::AddressInfo->new({
      #     postalCode     => "INSERT_POSTAL_CODE",
      #     provinceCode   => "INSERT_PROVINCE_CODE",
      #     countryCode    => "INSERT_COUNTRY_CODE",
      #     provinceName   => "INSERT_PROVINCE_NAME",
      #     streetAddress  => "INSERT_STREET_ADDRESS",
      #     streetAddress2 => "INSERT_STREET_ADDRESS_2",
      #     cityName       => "INSERT_CITY_NAME"
      #   }),
      #   radius      => "INSERT_RADIUS",
      #   radiusUnits => MILES
      # }),
      #
      # For more information on proximities see:
      # https://developers.google.com/google-ads/api/reference/rpc/latest/ProximityInfo
      locationList =>
        Google::Ads::GoogleAds::V8::Services::SmartCampaignSuggestService::LocationList
        ->new(
        ),
    });

  # Add the LocationInfo object to the list of locations on the SuggestionInfo
  # object. You have the option of providing multiple locations when using
  # location-based suggestions.
  push
    @{$suggestion_info->{locationList}{locations}},
    Google::Ads::GoogleAds::V8::Common::LocationInfo->new({
      # Set the location to the resource name of the given geo target constant.
      geoTargetConstant =>
        Google::Ads::GoogleAds::V8::Utils::ResourceNames::geo_target_constant(
        GEO_TARGET_CONSTANT)});

  # Add the KeywordThemeInfo objects to the SuggestionInfo object.
  push @{$suggestion_info->{keywordThemes}}, $keyword_theme_infos;

  # Set one of the business_location_id or business_name, whichever is provided.
  if (defined $business_location_id) {
    $suggestion_info->{businessLocationId} = $business_location_id;
  } else {
    $suggestion_info->{businessContext} =
      Google::Ads::GoogleAds::V8::Services::SmartCampaignSuggestService::BusinessContext
      ->new({
        businessName => $business_name
      });
  }

  # Add a schedule detailing which days of the week the business is open. This
  # example schedule describes a business that is open on Mondays from 9:00 AM
  # to 5:00 PM.
  push(
    @{$suggestion_info->{adSchedules}},
    Google::Ads::GoogleAds::V8::Common::AdScheduleInfo->new({
        # Set the day of this schedule as Monday.
        dayOfWeek => MONDAY,
        # Set the start hour to 9 AM.
        startHour => 9,
        # Set the end hour to 5 PM.
        endHour => 17,
        # Set the start and end minutes to zero.
        startMinute => ZERO,
        endMinute   => ZERO
      }));

  return $suggestion_info;
}
# [END add_smart_campaign_9]

# [START add_smart_campaign_1]
# Retrieves a suggested budget amount for a new budget.
# Using the SmartCampaignSuggestService to determine a daily budget for new and
# existing Smart campaigns is highly recommended because it helps the campaigns
# achieve optimal performance.
sub _get_budget_suggestion {
  my ($api_client, $customer_id, $suggestion_info) = @_;

  my $request =
    Google::Ads::GoogleAds::V8::Services::SmartCampaignSuggestService::SuggestSmartCampaignBudgetOptionsRequest
    ->new({
      customerId => $customer_id,
      # You can retrieve suggestions for an existing campaign by setting the
      # "Campaign" field of the request to the resource name of a campaign and
      # leaving the rest of the request fields below unset:
      # campaign   => "INSERT_CAMPAIGN_RESOURCE_NAME_HERE",
      #
      # Since these suggestions are for a new campaign, we're going to
      # use the suggestion_info field instead.
      suggestionInfo => $suggestion_info
    });

  # Issue a request to retrieve a budget suggestion.
  my $response = $api_client->SmartCampaignSuggestService()
    ->suggest_smart_campaign_budget_options($request);

  # Three tiers of options will be returned: "low", "high", and "recommended".
  # Here we will use the "recommended" option. The amount is specified in
  # micros, where one million is equivalent to one currency unit.
  printf "A daily budget amount of %d was suggested, garnering an estimated " .
    "minimum of %d clicks and an estimated maximum of %d clicks per day.\n",
    $response->{recommended}{dailyAmountMicros},
    $response->{recommended}{metrics}{minDailyClicks},
    $response->{recommended}{metrics}{maxDailyClicks};

  return $response->{recommended}{dailyAmountMicros};
}
# [END add_smart_campaign_1]

# [START add_smart_campaign_10]
# Retrieves creative suggestions for a Smart campaign ad.
# Using the SmartCampaignSuggestService to suggest creatives for new and
# existing Smart campaigns is highly recommended because it helps the campaigns
# achieve optimal performance.
sub _get_ad_suggestions {
  my ($api_client, $customer_id, $suggestion_info) = @_;

  # Issue a request to retrieve ad creative suggestions.
  my $response =
    $api_client->SmartCampaignSuggestService()->suggest_smart_campaign_ad(
    Google::Ads::GoogleAds::V8::Services::SmartCampaignSuggestService::SuggestSmartCampaignAdRequest
      ->new({
        customerId => $customer_id,
        # Unlike the SuggestSmartCampaignBudgetOptions method, it's only
        # possible to use suggestion_info to retrieve ad creative suggestions.
        suggestionInfo => $suggestion_info
      }));

  # The SmartCampaignAdInfo object in the response contains a list of up to
  # three headlines and two descriptions. Note that some of the suggestions
  # may have empty strings as text.
  my $ad_suggestions = $response->{adInfo};
  printf "The following headlines were suggested:\n";
  foreach my $headline (@{$ad_suggestions->{headlines}}) {
    printf "\t%s\n", defined $headline->{text} ? $headline->{text} : "<None>";
  }
  printf "The following descriptions were suggested:\n";
  foreach my $description (@{$ad_suggestions->{descriptions}}) {
    printf "\t%s\n",
      defined $description->{text} ? $description->{text} : "<None>";
  }

  return $ad_suggestions;
}
# [END add_smart_campaign_10]

# [START add_smart_campaign_2]
# Creates a MutateOperation that creates a new CampaignBudget.
# A temporary ID will be assigned to this campaign budget so that it can be
# referenced by other objects being created in the same Mutate request.
sub _create_campaign_budget_operation {
  my ($customer_id, $suggested_budget_amount) = @_;

  return
    Google::Ads::GoogleAds::V8::Services::GoogleAdsService::MutateOperation->
    new({
      campaignBudgetOperation =>
        Google::Ads::GoogleAds::V8::Services::CampaignBudgetService::CampaignBudgetOperation
        ->new({
          create => Google::Ads::GoogleAds::V8::Resources::CampaignBudget->new({
              name => "Smart campaign budget #" . uniqid(),
              # A budget used for Smart campaigns must have the type SMART_CAMPAIGN.
              type =>
                Google::Ads::GoogleAds::V8::Enums::BudgetTypeEnum::SMART_CAMPAIGN,
              # The suggested budget amount from the SmartCampaignSuggestService is
              # a daily budget. We don't need to specify that here, because the
              # budget period already defaults to DAILY.
              amountMicros => $suggested_budget_amount,
              # Set a temporary ID in the budget's resource name so it can be
              # referenced by the campaign in later steps.
              resourceName =>
                Google::Ads::GoogleAds::V8::Utils::ResourceNames::campaign_budget(
                $customer_id, BUDGET_TEMPORARY_ID
                )})})});
}
# [END add_smart_campaign_2]

# [START add_smart_campaign_3]
# Creates a MutateOperation that creates a new Smart campaign. A temporary ID
# will be assigned to this campaign so that it can be referenced by other
# objects being created in the same Mutate request.
sub _create_smart_campaign_operation {
  my ($customer_id) = @_;

  return
    Google::Ads::GoogleAds::V8::Services::GoogleAdsService::MutateOperation->
    new({
      campaignOperation =>
        Google::Ads::GoogleAds::V8::Services::CampaignService::CampaignOperation
        ->new({
          create => Google::Ads::GoogleAds::V8::Resources::Campaign->new({
              name => "Smart campaign #" . uniqid(),
              # Set the campaign status as PAUSED. The campaign is the only
              # entity in the mutate request that should have its status set.
              status => PAUSED,
              # AdvertisingChannelType must be SMART.
              advertisingChannelType => SMART,
              # AdvertisingChannelSubType must be SMART_CAMPAIGN.
              advertisingChannelSubType =>
                Google::Ads::GoogleAds::V8::Enums::AdvertisingChannelSubTypeEnum::SMART_CAMPAIGN,
              # Assign the resource name with a temporary ID.
              resourceName =>
                Google::Ads::GoogleAds::V8::Utils::ResourceNames::campaign(
                $customer_id, SMART_CAMPAIGN_TEMPORARY_ID
                ),
              # Set the budget using the given budget resource name.
              campaignBudget =>
                Google::Ads::GoogleAds::V8::Utils::ResourceNames::campaign_budget(
                $customer_id, BUDGET_TEMPORARY_ID
                )})})});
}
# [END add_smart_campaign_3]

# [START add_smart_campaign_4]
# Creates a MutateOperation to create a new SmartCampaignSetting.
# SmartCampaignSettings are unique in that they only support UPDATE operations,
# which are used to update and create them. Below we will use a temporary ID in
# the resource name to associate it with the campaign created in the previous
# step.
sub _create_smart_campaign_setting_operation {
  my ($customer_id, $business_location_id, $business_name) = @_;

  my $smart_campaign_setting =
    Google::Ads::GoogleAds::V8::Resources::SmartCampaignSetting->new({
      # Set a temporary ID in the campaign setting's resource name to associate it
      # with the campaign created in the previous step.
      resourceName =>
        Google::Ads::GoogleAds::V8::Utils::ResourceNames::smart_campaign_setting(
        $customer_id, SMART_CAMPAIGN_TEMPORARY_ID
        ),
      # Below we configure the SmartCampaignSetting using many of the same
      # details used to generate a budget suggestion.
      phoneNumber => Google::Ads::GoogleAds::V8::Resources::PhoneNumber->new({
          countryCode => COUNTRY_CODE,
          phoneNumber => PHONE_NUMBER
        }
      ),
      finalUrl                => LANDING_PAGE_URL,
      advertisingLanguageCode => LANGUAGE_CODE
    });

  # Either a business location ID or a business name must be added to the
  # SmartCampaignSetting.
  if (defined($business_location_id)) {
    $smart_campaign_setting->{businessLocationId} = $business_location_id;
  } else {
    $smart_campaign_setting->{businessName} = $business_name;
  }

  return
    Google::Ads::GoogleAds::V8::Services::GoogleAdsService::MutateOperation->
    new({
      smartCampaignSettingOperation =>
        Google::Ads::GoogleAds::V8::Services::SmartCampaignSettingService::SmartCampaignSettingOperation
        ->new({
          update => $smart_campaign_setting,
          # Set the update mask on the operation. This is required since the
          # smart campaign setting is created in an UPDATE operation. Here the
          # update mask will be a list of all the fields that were set on the
          # SmartCampaignSetting.
          updateMask => all_set_fields_of($smart_campaign_setting)})});
}
# [END add_smart_campaign_4]

# [START add_smart_campaign_8]
# Creates a list of MutateOperations that create new campaign criteria.
sub _create_campaign_criterion_operations {
  my ($customer_id, $keyword_theme_infos) = @_;

  my $campaign_criterion_operations = [];

  foreach my $keyword_theme_info (@$keyword_theme_infos) {
    push @$campaign_criterion_operations,
      Google::Ads::GoogleAds::V8::Services::GoogleAdsService::MutateOperation->
      new({
        campaignCriterionOperation =>
          Google::Ads::GoogleAds::V8::Services::CampaignCriterionService::CampaignCriterionOperation
          ->new({
            create =>
              Google::Ads::GoogleAds::V8::Resources::CampaignCriterion->new({
                # Set the campaign ID to a temporary ID.
                campaign =>
                  Google::Ads::GoogleAds::V8::Utils::ResourceNames::campaign(
                  $customer_id, SMART_CAMPAIGN_TEMPORARY_ID
                  ),
                # Set the criterion type to KEYWORD_THEME.
                type => KEYWORD_THEME,
                # Set the keyword theme to each KeywordThemeInfo in turn.
                keywordTheme => $keyword_theme_info
              })})});
  }

  return @$campaign_criterion_operations;
}
# [END add_smart_campaign_8]

# [START add_smart_campaign_5]
# Creates a MutateOperation that creates a new ad group. A temporary ID will be
# used in the campaign resource name for this ad group to associate it with the
# Smart campaign created in earlier steps. A temporary ID will also be used for
# its own resource name so that we can associate an ad group ad with it later in
# the process. Only one ad group can be created for a given Smart campaign.
sub _create_ad_group_operation {
  my ($customer_id) = @_;

  return
    Google::Ads::GoogleAds::V8::Services::GoogleAdsService::MutateOperation->
    new({
      adGroupOperation =>
        Google::Ads::GoogleAds::V8::Services::AdGroupService::AdGroupOperation
        ->new({
          create => Google::Ads::GoogleAds::V8::Resources::AdGroup->new({
              # Set the ad group ID to a temporary ID.
              resourceName =>
                Google::Ads::GoogleAds::V8::Utils::ResourceNames::ad_group(
                $customer_id, AD_GROUP_TEMPORARY_ID
                ),
              name => "Smart campaign ad group #" . uniqid(),
              # Set the campaign ID to a temporary ID.
              campaign =>
                Google::Ads::GoogleAds::V8::Utils::ResourceNames::campaign(
                $customer_id, SMART_CAMPAIGN_TEMPORARY_ID
                ),
              # The ad group type must be SMART_CAMPAIGN_ADS.
              type => SMART_CAMPAIGN_ADS
            })})});
}
# [END add_smart_campaign_5]

# [START add_smart_campaign_6]
# Creates a MutateOperation that creates a new ad group ad.
# A temporary ID will be used in the ad group resource name for this ad group
# ad to associate it with the ad group created in earlier steps.
sub _create_ad_group_ad_operation {
  my ($customer_id, $ad_suggestions) = @_;

  my $mutate_operation =
    Google::Ads::GoogleAds::V8::Services::GoogleAdsService::MutateOperation->
    new({
      adGroupAdOperation =>
        Google::Ads::GoogleAds::V8::Services::AdGroupAdService::AdGroupAdOperation
        ->new({
          create => Google::Ads::GoogleAds::V8::Resources::AdGroupAd->new({
              adGroup =>
                # Set the ad group ID to a temporary ID.
                Google::Ads::GoogleAds::V8::Utils::ResourceNames::ad_group(
                $customer_id, AD_GROUP_TEMPORARY_ID
                ),
              ad => Google::Ads::GoogleAds::V8::Resources::Ad->new({
                  # Set the type to SMART_CAMPAIGN_AD.
                  type            => SMART_CAMPAIGN_AD,
                  smartCampaignAd =>
                    Google::Ads::GoogleAds::V8::Common::SmartCampaignAdInfo->
                    new(
                    )})})})});

  # The SmartCampaignAdInfo object includes headlines and descriptions
  # retrieved from the SmartCampaignSuggestService.SuggestSmartCampaignAd
  # method. It's recommended that users review and approve or update these
  # creatives before they're set on the ad. It's possible that some or all of
  # these assets may contain empty texts, which should not be set on the ad
  # and instead should be replaced with meaninful texts from the user. Below
  # we just accept the creatives that were suggested while filtering out empty
  # assets, but individual workflows will vary here.
  foreach my $asset (@{$ad_suggestions->{headlines}}) {
    push @{$mutate_operation->{adGroupAdOperation}{create}{ad}{smartCampaignAd}
        {headlines}}, $asset
      if defined $asset->{text};
  }
  foreach my $asset (@{$ad_suggestions->{descriptions}}) {
    push @{$mutate_operation->{adGroupAdOperation}{create}{ad}{smartCampaignAd}
        {descriptions}}, $asset
      if defined $asset->{text};
  }

  return $mutate_operation;
}
# [END add_smart_campaign_6]

# Prints the details of a MutateGoogleAdsResponse.
sub _print_response_details {
  my ($response) = @_;

  my $mutate_operation_responses = $response->{mutateOperationResponses};

  foreach my $operation_response (@$mutate_operation_responses) {
    my $resource_name = "<not found>";
    my $entity_name   = "unknown";

    if ($operation_response->{adGroupResult}) {
      $entity_name   = "AdGroup";
      $resource_name = $operation_response->{adGroupResult}{resourceName};
    } elsif ($operation_response->{adGroupAdResult}) {
      $entity_name   = "AdGroupAd";
      $resource_name = $operation_response->{adGroupAdResult}{resourceName};
    } elsif ($operation_response->{campaignResult}) {
      $entity_name   = "Campaign";
      $resource_name = $operation_response->{campaignResult}{resourceName};
    } elsif ($operation_response->{campaignBudgetResult}) {
      $entity_name = "CampaignBudget";
      $resource_name =
        $operation_response->{campaignBudgetResult}{resourceName};
    } elsif ($operation_response->{campaignCriterionResult}) {
      $entity_name = "CampaignCriterion";
      $resource_name =
        $operation_response->{campaignCriterionResult}{resourceName};
    } elsif ($operation_response->{smartCampaignSettingResult}) {
      $entity_name = "SmartCampaignSetting";
      $resource_name =
        $operation_response->{smartCampaignSettingResult}{resourceName};
    }

    printf "Created a(n) $entity_name with resource name '$resource_name'.\n";
  }
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"          => \$customer_id,
  "keyword_text=s"         => \$keyword_text,
  "business_location_id=s" => \$business_location_id,
  "business_name=s"        => \$business_name
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
add_smart_campaign(
  $api_client,           $customer_id =~ s/-//gr, $keyword_text,
  $business_location_id, $business_name
);

=pod

=head1 NAME

add_smart_campaign

=head1 DESCRIPTION

This example shows how to create a Smart Campaign.

More details on Smart Campaigns can be found here:
https://support.google.com/google-ads/answer/7652860

=head1 SYNOPSIS

add_smart_campaign.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -keyword_text               A keyword text used to generate a set of keyword themes,
                                which are used to improve the budget recommendation and
                                performance of the Smart Campaign. Default value is defined
                                in the DEFAULT_KEYWORD_TEXT constant.
    -business_location_id       The ID of a Google My Business (GMB) location.
                                This is required if a business name is not provided.
                                This ID can be retrieved using the GMB API, for details see:
                                https://developers.google.com/my-business/reference/rest/v4/accounts.locations
    -business_name              The name of a Google My Business (GMB) business.
                                This is required if a business location ID is not provided.

=cut
