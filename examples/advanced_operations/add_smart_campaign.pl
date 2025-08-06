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
# This example shows how to create a Smart campaign.
#
# More details on Smart campaigns can be found here:
# https://support.google.com/google-ads/answer/7652860

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V21::Resources::Ad;
use Google::Ads::GoogleAds::V21::Resources::AdGroup;
use Google::Ads::GoogleAds::V21::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V21::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V21::Resources::Campaign;
use Google::Ads::GoogleAds::V21::Resources::CampaignCriterion;
use Google::Ads::GoogleAds::V21::Resources::PhoneNumber;
use Google::Ads::GoogleAds::V21::Resources::SmartCampaignSetting;
use Google::Ads::GoogleAds::V21::Common::AdScheduleInfo;
use Google::Ads::GoogleAds::V21::Common::KeywordThemeInfo;
use Google::Ads::GoogleAds::V21::Common::LocationInfo;
use Google::Ads::GoogleAds::V21::Common::SmartCampaignAdInfo;
use Google::Ads::GoogleAds::V21::Common::AdTextAsset;
use Google::Ads::GoogleAds::V21::Enums::AdGroupTypeEnum qw(SMART_CAMPAIGN_ADS);
use Google::Ads::GoogleAds::V21::Enums::AdTypeEnum      qw(SMART_CAMPAIGN_AD);
use Google::Ads::GoogleAds::V21::Enums::AdvertisingChannelTypeEnum qw(SMART);
use Google::Ads::GoogleAds::V21::Enums::AdvertisingChannelSubTypeEnum;
use Google::Ads::GoogleAds::V21::Enums::BudgetTypeEnum;
use Google::Ads::GoogleAds::V21::Enums::CampaignStatusEnum       qw(PAUSED);
use Google::Ads::GoogleAds::V21::Enums::DayOfWeekEnum            qw(MONDAY);
use Google::Ads::GoogleAds::V21::Enums::MinuteOfHourEnum         qw(ZERO);
use Google::Ads::GoogleAds::V21::Enums::ProximityRadiusUnitsEnum qw(MILES);
use Google::Ads::GoogleAds::V21::Enums::EuPoliticalAdvertisingStatusEnum
  qw(DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING);
use Google::Ads::GoogleAds::V21::Services::AdGroupService::AdGroupOperation;
use Google::Ads::GoogleAds::V21::Services::AdGroupAdService::AdGroupAdOperation;
use
  Google::Ads::GoogleAds::V21::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V21::Services::CampaignService::CampaignOperation;
use
  Google::Ads::GoogleAds::V21::Services::CampaignCriterionService::CampaignCriterionOperation;
use Google::Ads::GoogleAds::V21::Services::GoogleAdsService::MutateOperation;
use
  Google::Ads::GoogleAds::V21::Services::KeywordThemeConstantService::SuggestKeywordThemeConstantsRequest;
use
  Google::Ads::GoogleAds::V21::Services::SmartCampaignSettingService::SmartCampaignSettingOperation;
use
  Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::BusinessContext;
use
  Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::KeywordTheme;
use
  Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::LocationList;
use
  Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::SmartCampaignSuggestionInfo;
use
  Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::SuggestKeywordThemesRequest;
use
  Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::SuggestSmartCampaignAdRequest;
use
  Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::SuggestSmartCampaignBudgetOptionsRequest;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

# Geo target constant for New York City.
use constant GEO_TARGET_CONSTANT => 1023191;
# Country code is a two-letter ISO-3166 code, for a list of all codes see:
# https://developers.google.com/google-ads/api/reference/data/codes-formats#expandable-16
use constant COUNTRY_CODE => "US";
# For a list of all language codes, see:
# https://developers.google.com/google-ads/api/reference/data/codes-formats#expandable-7
use constant LANGUAGE_CODE               => "en";
use constant LANDING_PAGE_URL            => "http://www.example.com";
use constant PHONE_NUMBER                => "800-555-0100";
use constant BUDGET_TEMPORARY_ID         => -1;
use constant SMART_CAMPAIGN_TEMPORARY_ID => -2;
use constant AD_GROUP_TEMPORARY_ID       => -3;
# These define the minimum number of headlines and descriptions that are
# required to create an AdGroupAd in a Smart campaign.
use constant REQUIRED_NUM_HEADLINES    => 3;
use constant REQUIRED_NUM_DESCRIPTIONS => 2;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id               = undef;
my $keyword_text              = undef;
my $free_form_keyword_text    = undef;
my $business_profile_location = undef;
my $business_name             = undef;

sub add_smart_campaign {
  my ($api_client, $customer_id, $keyword_text, $free_form_keyword_text,
    $business_profile_location, $business_name)
    = @_;

  # [START add_smart_campaign_12]
  # The SmartCampaignSuggestionInfo object acts as the basis for many of the
  # entities necessary to create a Smart campaign. It will be reused a number
  # of times to retrieve suggestions for keyword themes, budget amount,
  # ad creatives, and campaign criteria.
  my $suggestion_info =
    _get_smart_campaign_suggestion_info($business_profile_location,
    $business_name);

  # After creating a SmartCampaignSuggestionInfo object we first use it to
  # generate a list of keyword themes using the SuggestKeywordThemes method
  # on the SmartCampaignSuggestService. It is strongly recommended that you
  # use this strategy for generating keyword themes.
  my $keyword_themes =
    _get_keyword_theme_suggestions($api_client, $customer_id, $suggestion_info);

  # If a keyword text is given, retrieve keyword theme constant suggestions
  # from the KeywordThemeConstantService, map them to KeywordThemes, and
  # append them to the existing list. This logic should ideally only be used
  # if the suggestions from the get_keyword_theme_suggestions funtion are
  # insufficient.
  if (defined $keyword_text) {
    push @$keyword_themes,
      @{_get_keyword_text_auto_completions($api_client, $keyword_text)};
  }

  # Map the KeywordThemeConstants retrieved by the previous two steps to
  # KeywordThemeInfo instances.
  my $keyword_theme_infos =
    _map_keyword_themes_to_keyword_infos($keyword_themes);

  # If a free-form keyword text is given we create a KeywordThemeInfo instance
  # from it and add it to the existing list.
  if (defined $free_form_keyword_text) {
    push @$keyword_theme_infos,
      _get_free_form_keyword_theme_info($free_form_keyword_text);
  }

  # Now add the generated keyword themes to the suggestion info instance.
  $suggestion_info->{keywordThemes} = $keyword_theme_infos;
  # [END add_smart_campaign_12]

  # Retrieve a budget amount suggestion.
  my $suggested_budget_amount =
    _get_budget_suggestion($api_client, $customer_id, $suggestion_info);

  # Retrieve Smart campaign ad creative suggestions.
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
    $business_profile_location, $business_name);
  my $campaign_criterion_operations =
    _create_campaign_criterion_operations($customer_id, $keyword_theme_infos,
    $suggestion_info);
  my $ad_group_operation = _create_ad_group_operation($customer_id);
  my $ad_group_ad_operation =
    _create_ad_group_ad_operation($customer_id, $ad_suggestions);

  # It's important to create these entities in this order because they depend on
  # each other. For example, the SmartCampaignSetting and ad group depend on the
  # campaign and the ad group ad depends on the ad group.
  my $mutate_operations = [
    $campaign_budget_operation, $smart_campaign_operation,
    $smart_campaign_setting_operation,
    # Expand the list of campaign criterion operations into the list of
    # other mutate operations.
    @$campaign_criterion_operations,
    $ad_group_operation, $ad_group_ad_operation
  ];

  # Send the operations in a single mutate request.
  my $mutate_google_ads_response = $api_client->GoogleAdsService()->mutate({
    customerId       => $customer_id,
    mutateOperations => $mutate_operations
  });

  _print_response_details($mutate_google_ads_response);
  # [END add_smart_campaign_7]

  return 1;
}

# [START add_smart_campaign_11]
# Retrieves KeywordThemes using the given suggestion info.
# Here we use the SuggestKeywordThemes method, which uses all of the business
# details included in the given SmartCampaignSuggestionInfo instance to generate
# keyword theme suggestions. This is the recommended way to generate keyword themes
# because it uses detailed information about your business, its location, and
# website content to generate keyword themes.
sub _get_keyword_theme_suggestions {
  my ($api_client, $customer_id, $suggestion_info) = @_;

  my $response =
    $api_client->SmartCampaignSuggestService()->suggest_keyword_themes(
    Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::SuggestKeywordThemesRequest
      ->new({
        customerId     => $customer_id,
        suggestionInfo => $suggestion_info
      }));

  printf "Retrieved %d keyword theme suggestions from the SuggestKeywordThemes"
    . "method.\n",
    scalar @{$response->{keywordThemes}};

  return $response->{keywordThemes};
}
# [END add_smart_campaign_11]

# [START add_smart_campaign]
# Retrieves KeywordThemeConstants for the given keyword text.
# These KeywordThemeConstants are derived from autocomplete data for the given
# keyword text. They are mapped to KeywordThemes before being returned.
sub _get_keyword_text_auto_completions {
  my ($api_client, $keyword_text) = @_;

  my $response = $api_client->KeywordThemeConstantService()->suggest(
    Google::Ads::GoogleAds::V21::Services::KeywordThemeConstantService::SuggestKeywordThemeConstantsRequest
      ->new({
        queryText    => $keyword_text,
        countryCode  => COUNTRY_CODE,
        languageCode => LANGUAGE_CODE
      }));

  printf "Retrieved %d keyword theme constants using the keyword '%s'.\n",
    scalar @{$response->{keywordThemeConstants}}, $keyword_text;

  # Map the keyword theme constants to KeywordTheme instances for consistency
  # with the response from SmartCampaignSuggestService.SuggestKeywordThemes.
  my $keyword_themes = [];
  foreach my $keyword_theme_constant (@{$response->{keywordThemeConstants}}) {
    push @$keyword_themes,
      Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::KeywordTheme
      ->new({
        keywordThemeConstant => $keyword_theme_constant
      });
  }

  return $keyword_themes;
}
# [END add_smart_campaign]

# [START add_smart_campaign_13]
# Creates a KeywordInfo instance using the given free-form keyword text.
sub _get_free_form_keyword_theme_info {
  my ($free_form_keyword_text) = @_;

  return Google::Ads::GoogleAds::V21::Common::KeywordThemeInfo->new({
    freeFormKeywordTheme => $free_form_keyword_text
  });
}
# [END add_smart_campaign_13]

# Maps a list of KeywordThemes to KeywordThemeInfos.
sub _map_keyword_themes_to_keyword_infos {
  my ($keyword_themes) = @_;

  my $keyword_theme_infos = [];
  foreach my $keyword_theme (@$keyword_themes) {
    if (defined $keyword_theme->{keywordThemeConstant}) {
      push @$keyword_theme_infos,
        Google::Ads::GoogleAds::V21::Common::KeywordThemeInfo->new({
          keywordThemeConstant =>
            $keyword_theme->{keywordThemeConstant}{resourceName}});
    } elsif (defined $keyword_theme->{freeFormKeywordTheme}) {
      push @$keyword_theme_infos,
        Google::Ads::GoogleAds::V21::Common::KeywordThemeInfo->new({
          freeFormKeywordTheme => $keyword_theme->{freeFormKeywordTheme}});
    } else {
      die "A malformed KeywordTheme was encountered: $keyword_theme";
    }
  }

  return $keyword_theme_infos;
}

# [START add_smart_campaign_9]
# Builds a SmartCampaignSuggestionInfo object with business details.
# The details are used by the SmartCampaignSuggestService to suggest a budget
# amount as well as creatives for the ad.
# Note that when retrieving ad creative suggestions you must set the
# "final_url", "language_code" and "keyword_themes" fields on the
# SmartCampaignSuggestionInfo instance.
sub _get_smart_campaign_suggestion_info {
  my ($business_profile_location, $business_name) = @_;

  my $suggestion_info =
    Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::SmartCampaignSuggestionInfo
    ->new({
      # Add the URL of the campaign's landing page.
      finalUrl => LANDING_PAGE_URL,
      # Add the language code for the campaign.
      languageCode => LANGUAGE_CODE,
      # Construct location information using the given geo target constant.
      # It's also possible to provide a geographic proximity using the
      # "proximity" field on suggestion_info, for example:
      #
      # proximity => Google::Ads::GoogleAds::V21::Common::ProximityInfo->new({
      #     address => Google::Ads::GoogleAds::V21::Common::AddressInfo->new({
      #         postalCode     => "INSERT_POSTAL_CODE",
      #         provinceCode   => "INSERT_PROVINCE_CODE",
      #         countryCode    => "INSERT_COUNTRY_CODE",
      #         provinceName   => "INSERT_PROVINCE_NAME",
      #         streetAddress  => "INSERT_STREET_ADDRESS",
      #         streetAddress2 => "INSERT_STREET_ADDRESS_2",
      #         cityName       => "INSERT_CITY_NAME"
      #       }
      #     ),
      #     radius      => "INSERT_RADIUS",
      #     radiusUnits => MILES
      #   }
      # ),
      #
      # For more information on proximities see:
      # https://developers.google.com/google-ads/api/reference/rpc/latest/ProximityInfo
      locationList =>
        Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::LocationList
        ->new(
        )});

  # Add the LocationInfo object to the list of locations on the SuggestionInfo
  # object. You have the option of providing multiple locations when using
  # location-based suggestions.
  push @{$suggestion_info->{locationList}{locations}},
    Google::Ads::GoogleAds::V21::Common::LocationInfo->new({
      # Set the location to the resource name of the given geo target constant.
      geoTargetConstant =>
        Google::Ads::GoogleAds::V21::Utils::ResourceNames::geo_target_constant(
        GEO_TARGET_CONSTANT)});

  # Set one of the business_profile_location or business_name, whichever is provided.
  if (defined $business_profile_location) {
    $suggestion_info->{businessProfileLocation} =
      _convert_business_profile_location($business_profile_location);
  } else {
    $suggestion_info->{businessContext} =
      Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::BusinessContext
      ->new({
        businessName => $business_name
      });
  }

  # Add a schedule detailing which days of the week the business is open. This
  # example schedule describes a business that is open on Mondays from 9:00 AM
  # to 5:00 PM.
  push @{$suggestion_info->{adSchedules}},
    Google::Ads::GoogleAds::V21::Common::AdScheduleInfo->new({
      # Set the day of this schedule as Monday.
      dayOfWeek => MONDAY,
      # Set the start hour to 9 AM.
      startHour => 9,
      # Set the end hour to 5 PM.
      endHour => 17,
      # Set the start and end minutes to zero.
      startMinute => ZERO,
      endMinute   => ZERO
    });

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
    Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::SuggestSmartCampaignBudgetOptionsRequest
    ->new({
      customerId => $customer_id,
      # You can retrieve suggestions for an existing campaign by setting the
      # "campaign" field of the request to the resource name of a campaign and
      # leaving the rest of the request fields below unset:
      # campaign => "INSERT_CAMPAIGN_RESOURCE_NAME_HERE",
      #
      # Since these suggestions are for a new campaign, we're going to use the
      # "suggestion_info" field instead.
      suggestionInfo => $suggestion_info
    });

  # Issue a request to retrieve a budget suggestion.
  my $response = $api_client->SmartCampaignSuggestService()
    ->suggest_smart_campaign_budget_options($request);

  # Three tiers of options will be returned: "low", "high", and "recommended".
  # Here we will use the "recommended" option. The amount is specified in micros,
  # where one million is equivalent to one currency unit.
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
    Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::SuggestSmartCampaignAdRequest
      ->new({
        customerId => $customer_id,
        # Unlike the SuggestSmartCampaignBudgetOptions method, it's only
        # possible to use suggestion_info to retrieve ad creative suggestions.
        suggestionInfo => $suggestion_info
      }));

  # The SmartCampaignAdInfo object in the response contains a list of up to
  # three headlines and two descriptions. Note that some of the suggestions
  # may have empty strings as text. Before setting these on the ad you should
  # review them and filter out any empty values.
  my $ad_suggestions = $response->{adInfo};
  printf "The following headlines were suggested:\n";
  foreach my $headline (@{$ad_suggestions->{headlines}}) {
    printf "\t%s\n", defined $headline->{text} ? $headline->{text} : "<None>";
  }
  printf "And the following descriptions were suggested:\n";
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
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::MutateOperation->
    new({
      campaignBudgetOperation =>
        Google::Ads::GoogleAds::V21::Services::CampaignBudgetService::CampaignBudgetOperation
        ->new({
          create =>
            Google::Ads::GoogleAds::V21::Resources::CampaignBudget->new({
              name => "Smart campaign budget #" . uniqid(),
              # A budget used for Smart campaigns must have the type SMART_CAMPAIGN.
              type =>
                Google::Ads::GoogleAds::V21::Enums::BudgetTypeEnum::SMART_CAMPAIGN,
              # The suggested budget amount from the SmartCampaignSuggestService is
              # a daily budget. We don't need to specify that here, because the
              # budget period already defaults to DAILY.
              amountMicros => $suggested_budget_amount,
              # Set a temporary ID in the budget's resource name so it can be
              # referenced by the campaign in later steps.
              resourceName =>
                Google::Ads::GoogleAds::V21::Utils::ResourceNames::campaign_budget(
                $customer_id, BUDGET_TEMPORARY_ID
                )})})});
}
# [END add_smart_campaign_2]

# [START add_smart_campaign_3]
# Creates a MutateOperation that creates a new Smart campaign.
# A temporary ID will be assigned to this campaign so that it can be referenced
# by other objects being created in the same Mutate request.
sub _create_smart_campaign_operation {
  my ($customer_id) = @_;

  return
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::MutateOperation->
    new({
      campaignOperation =>
        Google::Ads::GoogleAds::V21::Services::CampaignService::CampaignOperation
        ->new({
          create => Google::Ads::GoogleAds::V21::Resources::Campaign->new({
              name => "Smart campaign #" . uniqid(),
              # Set the campaign status as PAUSED. The campaign is the only
              # entity in the mutate request that should have its status set.
              status => PAUSED,
              # AdvertisingChannelType must be SMART.
              advertisingChannelType => SMART,
              # AdvertisingChannelSubType must be SMART_CAMPAIGN.
              advertisingChannelSubType =>
                Google::Ads::GoogleAds::V21::Enums::AdvertisingChannelSubTypeEnum::SMART_CAMPAIGN,
              # Assign the resource name with a temporary ID.
              resourceName =>
                Google::Ads::GoogleAds::V21::Utils::ResourceNames::campaign(
                $customer_id, SMART_CAMPAIGN_TEMPORARY_ID
                ),
              # Declare whether or not this campaign serves political ads targeting the EU.
              # Valid values are CONTAINS_EU_POLITICAL_ADVERTISING and
              # DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING.
              containsEuPoliticalAdvertising =>
                DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING,
              # Set the budget using the given budget resource name.
              campaignBudget =>
                Google::Ads::GoogleAds::V21::Utils::ResourceNames::campaign_budget(
                $customer_id, BUDGET_TEMPORARY_ID
                )})})});
}
# [END add_smart_campaign_3]

# [START add_smart_campaign_4]
# Creates a MutateOperation to create a new SmartCampaignSetting.
# SmartCampaignSettings are unique in that they only support UPDATE operations,
# which are used to update and create them. Below we will use a temporary ID in
# the resource name to associate it with the campaign created in the previous step.
sub _create_smart_campaign_setting_operation {
  my ($customer_id, $business_profile_location, $business_name) = @_;

  my $smart_campaign_setting =
    Google::Ads::GoogleAds::V21::Resources::SmartCampaignSetting->new({
      # Set a temporary ID in the campaign setting's resource name to associate it
      # with the campaign created in the previous step.
      resourceName =>
        Google::Ads::GoogleAds::V21::Utils::ResourceNames::smart_campaign_setting(
        $customer_id, SMART_CAMPAIGN_TEMPORARY_ID
        ),
      # Below we configure the SmartCampaignSetting using many of the same
      # details used to generate a budget suggestion.
      phoneNumber => Google::Ads::GoogleAds::V21::Resources::PhoneNumber->new({
          countryCode => COUNTRY_CODE,
          phoneNumber => PHONE_NUMBER
        }
      ),
      finalUrl                => LANDING_PAGE_URL,
      advertisingLanguageCode => LANGUAGE_CODE
    });

  # It's required that either a business profile location or a business name is
  # added to the SmartCampaignSetting.
  if (defined $business_profile_location) {
    $smart_campaign_setting->{businessProfileLocation} =
      $business_profile_location;
  } else {
    $smart_campaign_setting->{businessName} = $business_name;
  }

  return
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::MutateOperation->
    new({
      smartCampaignSettingOperation =>
        Google::Ads::GoogleAds::V21::Services::SmartCampaignSettingService::SmartCampaignSettingOperation
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
  my ($customer_id, $keyword_theme_infos, $suggestion_info) = @_;

  my $campaign_criterion_operations = [];

  foreach my $keyword_theme_info (@$keyword_theme_infos) {
    push @$campaign_criterion_operations,
      Google::Ads::GoogleAds::V21::Services::GoogleAdsService::MutateOperation
      ->new({
        campaignCriterionOperation =>
          Google::Ads::GoogleAds::V21::Services::CampaignCriterionService::CampaignCriterionOperation
          ->new({
            create =>
              Google::Ads::GoogleAds::V21::Resources::CampaignCriterion->new({
                # Set the campaign ID to a temporary ID.
                campaign =>
                  Google::Ads::GoogleAds::V21::Utils::ResourceNames::campaign(
                  $customer_id, SMART_CAMPAIGN_TEMPORARY_ID
                  ),
                # Set the keyword theme to the given KeywordThemeInfo.
                keywordTheme => $keyword_theme_info
              })})});
  }

  # Create a location criterion for each location in the suggestion info object
  # to add corresponding location targeting to the Smart campaign.
  foreach my $location_info (@{$suggestion_info->{locationList}{locations}}) {
    push @$campaign_criterion_operations,
      Google::Ads::GoogleAds::V21::Services::GoogleAdsService::MutateOperation
      ->new({
        campaignCriterionOperation =>
          Google::Ads::GoogleAds::V21::Services::CampaignCriterionService::CampaignCriterionOperation
          ->new({
            create =>
              Google::Ads::GoogleAds::V21::Resources::CampaignCriterion->new({
                # Set the campaign ID to a temporary ID.
                campaign =>
                  Google::Ads::GoogleAds::V21::Utils::ResourceNames::campaign(
                  $customer_id, SMART_CAMPAIGN_TEMPORARY_ID
                  ),
                # Set the location to the given location.
                location => $location_info
              })})});
  }

  return $campaign_criterion_operations;
}
# [END add_smart_campaign_8]

# [START add_smart_campaign_5]
# Creates a MutateOperation that creates a new ad group.
# A temporary ID will be used in the campaign resource name for this ad group to
# associate it with the Smart campaign created in earlier steps. A temporary ID
# will also be used for its own resource name so that we can associate an ad group ad
# with it later in the process.
# Only one ad group can be created for a given Smart campaign.
sub _create_ad_group_operation {
  my ($customer_id) = @_;

  return
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::MutateOperation->
    new({
      adGroupOperation =>
        Google::Ads::GoogleAds::V21::Services::AdGroupService::AdGroupOperation
        ->new({
          create => Google::Ads::GoogleAds::V21::Resources::AdGroup->new({
              # Set the ad group ID to a temporary ID.
              resourceName =>
                Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
                $customer_id, AD_GROUP_TEMPORARY_ID
                ),
              name => "Smart campaign ad group #" . uniqid(),
              # Set the campaign ID to a temporary ID.
              campaign =>
                Google::Ads::GoogleAds::V21::Utils::ResourceNames::campaign(
                $customer_id, SMART_CAMPAIGN_TEMPORARY_ID
                ),
              # The ad group type must be set to SMART_CAMPAIGN_ADS.
              type => SMART_CAMPAIGN_ADS
            })})});
}
# [END add_smart_campaign_5]

# [START add_smart_campaign_6]
# Creates a MutateOperation that creates a new ad group ad.
# A temporary ID will be used in the ad group resource name for this ad group ad
# to associate it with the ad group created in earlier steps.
sub _create_ad_group_ad_operation {
  my ($customer_id, $ad_suggestions) = @_;

  my $mutate_operation =
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::MutateOperation->
    new({
      adGroupAdOperation =>
        Google::Ads::GoogleAds::V21::Services::AdGroupAdService::AdGroupAdOperation
        ->new({
          create => Google::Ads::GoogleAds::V21::Resources::AdGroupAd->new({
              adGroup =>
                # Set the ad group ID to a temporary ID.
                Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
                $customer_id, AD_GROUP_TEMPORARY_ID
                ),
              ad => Google::Ads::GoogleAds::V21::Resources::Ad->new({
                  # Set the type to SMART_CAMPAIGN_AD.
                  type            => SMART_CAMPAIGN_AD,
                  smartCampaignAd =>
                    Google::Ads::GoogleAds::V21::Common::SmartCampaignAdInfo->
                    new({
                      headlines    => [],
                      descriptions => []})})})})});

  # The SmartCampaignAdInfo object includes headlines and descriptions
  # retrieved from the SmartCampaignSuggestService.SuggestSmartCampaignAd
  # method. It's recommended that users review and approve or update these
  # creatives before they're set on the ad. It's possible that some or all of
  # these assets may contain empty texts, which should not be set on the ad
  # and instead should be replaced with meaningful texts from the user. Below
  # we just accept the creatives that were suggested while filtering out empty
  # assets. If no headlines or descriptions were suggested, then we manually
  # add some, otherwise this operation will generate an INVALID_ARGUMENT
  # error. Individual workflows will likely vary here.
  my $smart_campaign_ad =
    $mutate_operation->{adGroupAdOperation}{create}{ad}{smartCampaignAd};

  foreach my $asset (@{$ad_suggestions->{headlines}}) {
    push @{$smart_campaign_ad->{headlines}}, $asset
      if defined $asset->{text};
  }
  # If there are fewer headlines than are required, we manually add additional
  # headlines to make up for the difference.
  my $num_missing_headlines =
    REQUIRED_NUM_HEADLINES - scalar @{$smart_campaign_ad->{headlines}};
  for (my $i = 0 ; $i < $num_missing_headlines ; $i++) {
    push @{$smart_campaign_ad->{headlines}},
      Google::Ads::GoogleAds::V21::Common::AdTextAsset->new({
        text => "placeholder headline " . $i
      });
  }

  foreach my $asset (@{$ad_suggestions->{descriptions}}) {
    push @{$smart_campaign_ad->{descriptions}}, $asset
      if defined $asset->{text};
  }
  # If there are fewer descriptions than are required, we manually add
  # additional descriptions to make up for the difference.
  my $num_missing_descriptions =
    REQUIRED_NUM_DESCRIPTIONS - scalar @{$smart_campaign_ad->{descriptions}};
  for (my $i = 0 ; $i < $num_missing_descriptions ; $i++) {
    push @{$smart_campaign_ad->{descriptions}},
      Google::Ads::GoogleAds::V21::Common::AdTextAsset->new({
        text => "placeholder description " . $i
      });
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
  "customer_id=s"               => \$customer_id,
  "keyword_text=s"              => \$keyword_text,
  "free_form_keyword_text=s"    => \$free_form_keyword_text,
  "business_profile_location=i" => \$business_profile_location,
  "business_name=s"             => \$business_name
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
add_smart_campaign($api_client, $customer_id =~ s/-//gr,
  $keyword_text, $free_form_keyword_text, $business_profile_location,
  $business_name);

=pod

=head1 NAME

add_smart_campaign

=head1 DESCRIPTION

This example shows how to create a Smart campaign.

More details on Smart campaigns can be found here:
https://support.google.com/google-ads/answer/7652860

=head1 SYNOPSIS

add_smart_campaign.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -keyword_text               [optional] A keyword text used to retrieve keyword theme constant
                                suggestions from the KeywordThemeConstantService. These keyword
                                theme suggestions are generated using auto-completion data for the
                                given text and may help improve the performance of the Smart campaign.
    -free_form_keyword_text      [optional] A keyword text used to create a free-form keyword theme,
                                which is entirely user-specified and not derived from any suggestion
                                service. Using free-form keyword themes is typically not recommended
                                because they are less effective than suggested keyword themes, however
                                they are useful in situations where a very specific term needs to be targeted.
    -business_profile_location  [optional] The resource name of a Business Profile location.
                                This is required if a business name is not provided.
                                This ID can be retrieved using the Business Profile API, for details see:
                                https://developers.google.com/my-business/reference/businessinformation/rest/v1/accounts.locations
                                or from the Business Profile UI (https://support.google.com/business/answer/10737668).
    -business_name              [optional] The name of a business in Business Profile.
                                This is required if a business profile location is not provided.

=cut
