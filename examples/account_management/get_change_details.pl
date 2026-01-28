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
# This example gets specific details about the most recent changes in your
# account, including which field changed and the old and new values.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V23::Enums::ResourceChangeOperationEnum
  qw(CREATE UPDATE);
use Google::Ads::GoogleAds::V23::Enums::ChangeEventResourceTypeEnum
  qw(AD AD_GROUP AD_GROUP_AD AD_GROUP_ASSET AD_GROUP_CRITERION AD_GROUP_BID_MODIFIER ASSET ASSET_SET ASSET_SET_ASSET CAMPAIGN CAMPAIGN_ASSET CAMPAIGN_ASSET_SET CAMPAIGN_BUDGET CAMPAIGN_CRITERION CUSTOMER_ASSET);
use
  Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest;

use Getopt::Long qw(:config auto_help);
use JSON::XS;
use Pod::Usage;
use Cwd qw(abs_path);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

# [START get_change_details]
sub get_change_details {
  my ($api_client, $customer_id) = @_;

  # Construct a query to find details for recent changes in your account.
  # The LIMIT clause is required for the change_event resource.
  # The maximum size is 10000, but a low limit was set here for demonstrative
  # purposes.
  # The WHERE clause on change_date_time is also required. It must specify a
  # window of at most 30 days within the past 30 days.
  my $search_query =
    "SELECT change_event.resource_name, change_event.change_date_time, " .
    "change_event.change_resource_name, change_event.user_email, " .
    "change_event.client_type, change_event.change_resource_type, " .
    "change_event.old_resource, change_event.new_resource, " .
    "change_event.resource_change_operation, change_event.changed_fields " .
    "FROM change_event " .
    "WHERE change_event.change_date_time DURING LAST_14_DAYS " .
    "ORDER BY change_event.change_date_time DESC LIMIT 5";

  # Create a search Google Ads request that will retrieve all change events using
  # pages of the specified page size.
  my $search_request =
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  # Iterate over all rows in all pages and print the requested field values for
  # the change event in each row.
  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;

    my $change_event = $google_ads_row->{changeEvent};
    printf "On %s, user %s used interface %s to perform a(n) %s operation " .
      "on a %s with resource name '%s'.\n", $change_event->{changeDateTime},
      $change_event->{userEmail}, $change_event->{clientType},
      $change_event->{resourceChangeOperation},
      $change_event->{changeResourceType}, $change_event->{changeResourceName};

    if (grep /$change_event->{resourceChangeOperation}/, (CREATE, UPDATE)) {
      my ($old_resource, $new_resource) =
        _get_changed_resources_for_resource_type($change_event);

      foreach my $changed_field (split /,/, $change_event->{changedFields}) {
        my $new_value =
          _convert_to_string(get_field_value($new_resource, $changed_field))
          || "";
        if ($change_event->{resourceChangeOperation} eq CREATE) {
          print "\t$changed_field set to '$new_value'.\n";
        } else {
          my $old_value =
            _convert_to_string(get_field_value($old_resource, $changed_field))
            || "";
          print "\t$changed_field changed from '$old_value' to '$new_value'.\n";
        }
      }
    }
  }

  return 1;
}

# This method converts the specified value to a string.
sub _convert_to_string {
  my $value        = shift;
  my $string_value = "";

  if (ref($value) eq "ARRAY") {
    $string_value .= "[";
    foreach my $item (@$value) {
      if (is_hash_ref($item)) {
        $string_value .= (JSON::XS->new->utf8->encode($item) . ",");
      } else {
        $string_value .= ($item . ",");
      }
    }
    $string_value .= "]";
  } elsif (is_hash_ref($value)) {
    $string_value .= JSON::XS->new->utf8->encode($value);
  } else {
    $string_value = $value;
  }
  return $string_value;
}

# This method returns the old resource and new resource based on the change
# resource type of a change event.
sub _get_changed_resources_for_resource_type {
  my $change_event  = shift;
  my $resource_type = $change_event->{changeResourceType};
  if ($resource_type eq AD) {
    return $change_event->{oldResource}{ad}, $change_event->{newResource}{ad};
  } elsif ($resource_type eq AD_GROUP) {
    return $change_event->{oldResource}{adGroup},
      $change_event->{newResource}{adGroup};
  } elsif ($resource_type eq AD_GROUP_AD) {
    return $change_event->{oldResource}{adGroupAd},
      $change_event->{newResource}{adGroupAd};
  } elsif ($resource_type eq AD_GROUP_ASSET) {
    return $change_event->{oldResource}{adGroupAsset},
      $change_event->{newResource}{adGroupAsset};
  } elsif ($resource_type eq AD_GROUP_CRITERION) {
    return $change_event->{oldResource}{adGroupCriterion},
      $change_event->{newResource}{adGroupCriterion};
  } elsif ($resource_type eq AD_GROUP_BID_MODIFIER) {
    return $change_event->{oldResource}{adGroupBidModifier},
      $change_event->{newResource}{adGroupBidModifier};
  } elsif ($resource_type eq ASSET) {
    return $change_event->{oldResource}{asset},
      $change_event->{newResource}{asset};
  } elsif ($resource_type eq ASSET_SET) {
    return $change_event->{oldResource}{assetSet},
      $change_event->{newResource}{assetSet};
  } elsif ($resource_type eq ASSET_SET_ASSET) {
    return $change_event->{oldResource}{assetSetAsset},
      $change_event->{newResource}{assetSetAsset};
  } elsif ($resource_type eq CAMPAIGN) {
    return $change_event->{oldResource}{campaign},
      $change_event->{newResource}{campaign};
  } elsif ($resource_type eq CAMPAIGN_ASSET) {
    return $change_event->{oldResource}{campaignAsset},
      $change_event->{newResource}{campaignAsset};
  } elsif ($resource_type eq CAMPAIGN_ASSET_SET) {
    return $change_event->{oldResource}{campaignAssetSet},
      $change_event->{newResource}{campaignAssetSet};
  } elsif ($resource_type eq CAMPAIGN_BUDGET) {
    return $change_event->{oldResource}{campaignBudget},
      $change_event->{newResource}{campaignBudget};
  } elsif ($resource_type eq CAMPAIGN_CRITERION) {
    return $change_event->{oldResource}{campaignCriterion},
      $change_event->{newResource}{campaignCriterion};
  } elsif ($resource_type eq CUSTOMER_ASSET) {
    return $change_event->{oldResource}{customerAsset},
      $change_event->{newResource}{customerAsset};
  } else {
    print "Unknown change_resource_type $resource_type.\n";
  }
}
# [END get_change_details]

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
get_change_details($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

get_change_details

=head1 DESCRIPTION

This example gets specific details about the most recent changes in your
account, including which field changed and the old and new values.

=head1 SYNOPSIS

get_change_details.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
