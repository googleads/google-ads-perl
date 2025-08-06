#!/usr/bin/perl -w
#
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
# This code example creates a lead form and a lead form asset for a campaign.
# Run add_campaigns.pl to create a campaign.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::CampaignAsset;
use Google::Ads::GoogleAds::V21::Resources::Asset;
use Google::Ads::GoogleAds::V21::Common::LeadFormAsset;
use Google::Ads::GoogleAds::V21::Common::LeadFormField;
use Google::Ads::GoogleAds::V21::Common::LeadFormSingleChoiceAnswers;
use Google::Ads::GoogleAds::V21::Common::LeadFormDeliveryMethod;
use Google::Ads::GoogleAds::V21::Common::WebhookDelivery;
use Google::Ads::GoogleAds::V21::Enums::AssetFieldTypeEnum qw(LEAD_FORM);
use Google::Ads::GoogleAds::V21::Enums::LeadFormCallToActionTypeEnum
  qw(BOOK_NOW);
use Google::Ads::GoogleAds::V21::Enums::LeadFormFieldUserInputTypeEnum
  qw(FULL_NAME EMAIL PHONE_NUMBER PREFERRED_CONTACT_TIME TRAVEL_BUDGET);
use Google::Ads::GoogleAds::V21::Enums::LeadFormPostSubmitCallToActionTypeEnum
  qw(VISIT_SITE);
use
  Google::Ads::GoogleAds::V21::Services::CampaignAssetService::CampaignAssetOperation;
use Google::Ads::GoogleAds::V21::Services::AssetService::AssetOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
my $campaign_id = "INSERT_CAMPAIGN_ID_HERE";

sub add_lead_form_asset {
  my ($api_client, $customer_id, $campaign_id) = @_;

  # Create a lead form asset.
  my $lead_form_asset_resource_name =
    create_lead_form_asset($api_client, $customer_id);

  # Create a lead form asset for the campaign.
  create_lead_form_campaign_asset($api_client, $customer_id, $campaign_id,
    $lead_form_asset_resource_name);

  return 1;
}

# Creates the lead form campaign asset.
# [START add_lead_form_asset_1]
sub create_lead_form_campaign_asset {
  my ($api_client, $customer_id, $campaign_id, $lead_form_asset_resource_name)
    = @_;

  # Create the campaign asset for the lead form.
  my $campaign_asset =
    Google::Ads::GoogleAds::V21::Resources::CampaignAsset->new({
      asset     => $lead_form_asset_resource_name,
      fieldType => LEAD_FORM,
      campaign  => Google::Ads::GoogleAds::V21::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
      )});

  my $campaign_asset_operation =
    Google::Ads::GoogleAds::V21::Services::CampaignAssetService::CampaignAssetOperation
    ->new({
      create => $campaign_asset
    });

  my $campaign_assets_response = $api_client->CampaignAssetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_asset_operation]});

  printf
    "Created campaign asset with resource name = '%s' for campaign ID %d.\n",
    $campaign_assets_response->{results}[0]{resourceName}, $campaign_id;
}
# [END add_lead_form_asset_1]

# Creates the lead form asset.
# [START add_lead_form_asset]
sub create_lead_form_asset {
  my ($api_client, $customer_id) = @_;

  # Create the lead form asset.
  my $lead_form_asset = Google::Ads::GoogleAds::V21::Resources::Asset->new({
      name          => "Interplanetary Cruise Lead Form #" . uniqid(),
      leadFormAsset => Google::Ads::GoogleAds::V21::Common::LeadFormAsset->new({
          # Specify the details of lead form that the users will see.
          callToActionType        => BOOK_NOW,
          callToActionDescription => "Latest trip to Jupiter!",

          # Define the form details.
          businessName => "Interplanetary Cruise",
          headline     => "Trip to Jupiter",
          description  => "Our latest trip to Jupiter is now open for booking.",
          privacyPolicyUrl => "http://example.com/privacy",

          # Define the fields to be displayed to the user.
          fields => [
            Google::Ads::GoogleAds::V21::Common::LeadFormField->new({
                inputType => FULL_NAME
              }
            ),
            Google::Ads::GoogleAds::V21::Common::LeadFormField->new({
                inputType => EMAIL
              }
            ),
            Google::Ads::GoogleAds::V21::Common::LeadFormField->new({
                inputType => PHONE_NUMBER
              }
            ),
            Google::Ads::GoogleAds::V21::Common::LeadFormField->new({
                inputType           => PREFERRED_CONTACT_TIME,
                singleChoiceAnswers =>
                  Google::Ads::GoogleAds::V21::Common::LeadFormSingleChoiceAnswers
                  ->new({
                    answers => ["Before 9 AM", "Any time", "After 5 PM"]})}
            ),
            Google::Ads::GoogleAds::V21::Common::LeadFormField->new({
                inputType => TRAVEL_BUDGET
              })
          ],

          # Optional: You can also specify a background image asset.
          # To upload an asset, see misc/upload_image_asset.pl.
          # backgroundImageAsset => "INSERT_IMAGE_ASSET_HERE",

          # Optional: Define the response page after the user signs up on the form.
          postSubmitHeadline    => "Thanks for signing up!",
          postSubmitDescription => "We will reach out to you shortly. " .
            "Visit our website to see past trip details.",
          postSubmitCallToActionType => VISIT_SITE,

          # Optional: Display a custom disclosure that displays along with the
          # Google disclaimer on the form.
          customDisclosure => "Trip may get cancelled due to meteor shower.",

          # Optional: Define a delivery method for the form response. See
          # https://developers.google.com/google-ads/webhook/docs/overview for
          # more details on how to define a webhook.
          deliveryMethods => [
            Google::Ads::GoogleAds::V21::Common::LeadFormDeliveryMethod->new({
                webhook =>
                  Google::Ads::GoogleAds::V21::Common::WebhookDelivery->new({
                    advertiserWebhookUrl => "http://example.com/webhook",
                    googleSecret         => "interplanetary google secret",
                    payloadSchemaVersion => 3
                  })})]}
      ),
      finalUrls => ["http://example.com/jupiter"]});

  # Create the operation.
  my $asset_operation =
    Google::Ads::GoogleAds::V21::Services::AssetService::AssetOperation->new({
      create => $lead_form_asset
    });

  my $assets_response = $api_client->AssetService()->mutate({
      customerId => $customer_id,
      operations => [$asset_operation]});

  my $lead_form_asset_resource_name =
    $assets_response->{results}[0]{resourceName};

  # Display the result.
  printf "Asset with resource name = '%s' was created.\n",
    $lead_form_asset_resource_name;
  return $lead_form_asset_resource_name;
}
# [END add_lead_form_asset]

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id, "campaign_id=i" => \$campaign_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $campaign_id);

# Call the example.
add_lead_form_asset($api_client, $customer_id =~ s/-//gr, $campaign_id);

=pod

=head1 NAME

add_lead_form_asset

=head1 DESCRIPTION

This code example creates a lead form and a lead form asset for a campaign.
Run add_campaigns.pl to create a campaign.

=head1 SYNOPSIS

add_lead_form_asset.pl [options]

    -help           Show the help message.
    -customer_id    The Google Ads customer ID.
    -campaign_id    ID of the campaign to which lead form assets are added.

=cut
