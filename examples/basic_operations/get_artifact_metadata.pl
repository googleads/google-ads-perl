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
# This example gets the metadata, such as whether the artifact is selectable,
# filterable and sortable, of an artifact. The artifact can be either a
# resource (such as customer, campaign) or a field (such as metrics.impressions,
# campaign.id). It'll also show the data type and artifacts that are selectable
# with the artifact.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::GoogleAdsClient;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

use Getopt::Long qw(:config auto_help);
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
my $artifact_name = "campaign";

sub get_artifact_metadata {
  my ($client, $artifact_name) = @_;

  # Create the search query.
  my $search_query =
    "SELECT name, category, selectable, filterable, sortable, selectable_with, "
    . "data_type, is_repeated WHERE name = '$artifact_name'";

  my $search_google_ads_fields_response =
    $client->GoogleAdsFieldService()->search({
      query => $search_query
    });

  if (!$search_google_ads_fields_response->{results}) {
    printf "The specified artifact '%s' doesn't exist.", $artifact_name;
    return;
  }

  # Get all returned artifacts and print out their metadata.
  foreach
    my $google_ads_field (@{$search_google_ads_fields_response->{results}})
  {
    printf "An artifact named '%s' with category '%s' and data type '%s' " .
      "%s selectable, %s filterable, %s sortable and %s repeated.\n\n",
      $google_ads_field->{name},
      $google_ads_field->{category},
      $google_ads_field->{dataType},
      is_or_not($google_ads_field->{selectable}),
      is_or_not($google_ads_field->{filterable}),
      is_or_not($google_ads_field->{sortable}),
      is_or_not($google_ads_field->{isRepeated});

    if ($google_ads_field->{selectableWith}) {
      print "The artifact can be selected with the following artifacts:\n";
      foreach my $selectable_field (@{$google_ads_field->{selectableWith}}) {
        print $selectable_field, "\n";
      }
    }
  }

  return 1;
}

# Returns "is" when the specified value is true and "is not" when the
# specified value is false.
sub is_or_not {
  shift ? "is" : "is not";
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $client = Google::Ads::GoogleAds::GoogleAdsClient->new({version => "V1"});

# By default examples are set to die on any server returned fault.
$client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("artifact_name=s" => \$artifact_name);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($artifact_name);

# Call the example.
get_artifact_metadata($client, $artifact_name);

=pod

=head1 NAME

get_artifact_metadata

=head1 DESCRIPTION

This example gets the metadata, such as whether the artifact is selectable, filterable
and sortable, of an artifact. The artifact can be either a resource (such as customer,
campaign) or a field (such as metrics.impressions, campaign.id). It'll also show the data
type and artifacts that are selectable with the artifact.

=head1 SYNOPSIS

get_artifact_metadata.pl [options]

    -help                       Show the help message.
    -artifact_name              [optional] The artifact name, e.g. a resource such as customer,
                                campaign or a field such as metrics.impressions, campaign.id.

=cut
