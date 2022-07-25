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
# This example searches for GoogleAdsFields that match a given prefix, retrieving
# metadata such as whether the field is selectable, filterable, or sortable, along
# with the data type and the fields that are selectable with the field. Each
# GoogleAdsField represents either a resource (such as customer or campaign) or
# a field (such as metrics.impressions or campaign.id).

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

my $name_prefix = undef;

sub search_for_google_ads_fields {
  my ($api_client, $name_prefix) = @_;

  # Create the search query.
  # A single % is the wildcard token in the Google Ads Query language.
  my $search_query =
    "SELECT name, category, selectable, filterable, sortable, selectable_with, "
    . "data_type, is_repeated WHERE name LIKE '${name_prefix}%'";

  my $search_google_ads_fields_response =
    $api_client->GoogleAdsFieldService()->search({
      query => $search_query
    });

  if (!$search_google_ads_fields_response->{results}) {
    printf "No GoogleAdsField found with a name that begins with '%s'.\n",
      $name_prefix;
    return;
  }

  # Retrieves each matching GoogleAdsField and prints its metadata.
  foreach
    my $google_ads_field (@{$search_google_ads_fields_response->{results}})
  {
    printf "%s:\n",        $google_ads_field->{name};
    printf "  %-16s %s\n", "category:",   $google_ads_field->{category};
    printf "  %-16s %s\n", "data type:",  $google_ads_field->{dataType};
    printf "  %-16s %s\n", "selectable:", $google_ads_field->{selectable};
    printf "  %-16s %s\n", "filterable:", $google_ads_field->{filterable};
    printf "  %-16s %s\n", "sortable:",   $google_ads_field->{sortable};
    printf "  %-16s %s\n", "repeated:",   $google_ads_field->{isRepeated};

    # Prints the list of fields that are selectable with the field.
    if ($google_ads_field->{selectableWith}) {
      # Sorts and then prints the list.
      my $sorted_selectable_field = $google_ads_field->{selectableWith};
      @$sorted_selectable_field = sort @$sorted_selectable_field;
      printf "  %s\n", "selectable with:";
      foreach my $selectable_field (@{$google_ads_field->{selectableWith}}) {
        printf "    %s\n", $selectable_field;
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
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("name_prefix=s" => \$name_prefix);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($name_prefix);

# Call the example.
search_for_google_ads_fields($api_client, $name_prefix);

=pod

=head1 NAME

search_for_google_ads_fields

=head1 DESCRIPTION

This example searches for GoogleAdsFields that match a given prefix, retrieving
metadata such as whether the field is selectable, filterable, or sortable, along
with the data type and the fields that are selectable with the field. Each
GoogleAdsField represents either a resource (such as customer or campaign) or
a field (such as metrics.impressions or campaign.id).

=head1 SYNOPSIS

search_for_google_ads_fields.pl [options]

    -help                       Show the help message.
    -name_prefix				The name prefix to use in the query.

=cut
