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
# This example demonstrates how to request an exemption for policy violations
# of a keyword. Note that the example uses an exemptible policy-violating
# keyword by default. If you use a keyword that contains non-exemptible policy
# violations, they will not be sent for exemption request and you will still
# fail to create a keyword.
# If you specify a keyword that doesn't violate any policies, this example will
# just add the keyword as usual, similar to what the add_keywords.pl example does.
#
# Note that once you've requested policy exemption for a keyword, when you send
# a request for adding it again, the request will pass like when you add a
# non-violating keyword.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V21::Common::KeywordInfo;
use Google::Ads::GoogleAds::V21::Enums::KeywordMatchTypeEnum       qw(EXACT);
use Google::Ads::GoogleAds::V21::Enums::AdGroupCriterionStatusEnum qw(ENABLED);
use
  Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

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
my $customer_id  = "INSERT_CUSTOMER_ID_HERE";
my $ad_group_id  = "INSERT_AD_GROUP_ID_HERE";
my $keyword_text = "medication";

sub handle_keyword_policy_violations {
  my ($api_client, $customer_id, $ad_group_id, $keyword_text) = @_;

  # Configure the keyword text and match type settings.
  my $keyword_info = Google::Ads::GoogleAds::V21::Common::KeywordInfo->new({
    text      => $keyword_text,
    matchType => EXACT
  });

  # Construct an ad group criterion using the keyword info above.
  my $ad_group_criterion =
    Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion->new({
      adGroup => Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      status  => ENABLED,
      keyword => $keyword_info
    });

  # Create an ad group criterion operation.
  my $ad_group_criterion_operation =
    Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({create => $ad_group_criterion});

  # Try sending a mutate request to add the keyword.
  my $response = $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_criterion_operation]});

  if ($response->isa("Google::Ads::GoogleAds::GoogleAdsException")) {
    my $exempt_policy_violation_keys =
      fetch_exempt_policy_violation_keys($response);

    # Try sending exemption requests for creating a keyword. However, if your
    # keyword contains many policy violations, but not all of them are exemptible,
    # the request will not be sent.
    if (@$exempt_policy_violation_keys ==
      @{$response->get_google_ads_failure()->{errors}})
    {
      request_exemption($api_client, $customer_id,
        $ad_group_criterion_operation, $exempt_policy_violation_keys);
    } else {
      print "No exemption request is sent because 1) your keyword contained " .
        "some non-exemptible policy violations or 2) there are other " .
        "non-policy related errors thrown.\n";
    }
  } else {
    printf "Added a keyword with resource name '%s'.\n",
      $response->{results}[0]{resourceName};
  }

  return 1;
}

# Collects all policy violation keys that can be exempted for sending a exemption
# request later.
# [START handle_keyword_policy_violations]
sub fetch_exempt_policy_violation_keys {
  my $google_ads_exception = shift;

  my $exempt_policy_violation_keys = [];

  print "Google Ads failure details:\n";
  foreach
    my $error (@{$google_ads_exception->get_google_ads_failure()->{errors}})
  {
    printf "\t%s: %s\n", [keys %{$error->{errorCode}}]->[0], $error->{message};

    if ($error->{details}{policyViolationDetails}) {
      my $policy_violation_details = $error->{details}{policyViolationDetails};
      printf "\tPolicy violation details:\n";
      printf "\t\tExternal policy name: '%s'\n",
        $policy_violation_details->{externalPolicyName};
      printf
        "\t\tExternal policy description: '%s'\n",
        $policy_violation_details->{externalPolicyDescription};
      printf
        "\t\tIs exemptible? '%s'\n",
        $policy_violation_details->{isExemptible} ? "yes" : "no";

      if (  $policy_violation_details->{isExemptible}
        and $policy_violation_details->{key})
      {
        my $policy_violation_details_key = $policy_violation_details->{key};
        push @$exempt_policy_violation_keys, $policy_violation_details_key;

        printf "\t\tPolicy violation key:\n";
        printf "\t\t\tName: '%s'\n",
          $policy_violation_details_key->{policyName};
        printf
          "\t\t\tViolating text: '%s'\n",
          $policy_violation_details_key->{violatingText};
      }
    }
  }

  return $exempt_policy_violation_keys;
}
# [END handle_keyword_policy_violations]

# Sends exemption requests for creating a keyword.
# [START handle_keyword_policy_violations_1]
sub request_exemption {
  my ($api_client, $customer_id, $ad_group_criterion_operation,
    $exempt_policy_violation_keys)
    = @_;

  print "Try adding a keyword again by requesting exemption for its " .
    "policy violations.\n";

  $ad_group_criterion_operation->{exemptPolicyViolationKeys} =
    $exempt_policy_violation_keys;

  my $ad_group_criteria_response =
    $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_criterion_operation]});

  printf "Successfully added a keyword with resource name '%s' by requesting " .
    "for policy violation exemption.\n",
    $ad_group_criteria_response->{results}[0]{resourceName};
}
# [END handle_keyword_policy_violations_1]

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(0);

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"  => \$customer_id,
  "ad_group_id=i"  => \$ad_group_id,
  "keyword_text=s" => \$keyword_text
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $ad_group_id, $keyword_text);

# Call the example.
handle_keyword_policy_violations($api_client, $customer_id =~ s/-//gr,
  $ad_group_id, $keyword_text);

=pod

=head1 NAME

handle_keyword_policy_violations

=head1 DESCRIPTION

This example demonstrates how to request an exemption for policy violations of a keyword.
Note that the example uses an exemptible policy-violating keyword by default. If you use
a keyword that contains non-exemptible policy violations, they will not be sent for
exemption request and you will still fail to create a keyword.
If you specify a keyword that doesn't violate any policies, this example will just add the
keyword as usual, similar to what the add_keywords.pl example does.

Note that once you've requested policy exemption for a keyword, when you send a request for
adding it again, the request will pass like when you add a non-violating keyword.

=head1 SYNOPSIS

handle_keyword_policy_violations.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID.
    -keyword_text               [optional] The keyword to be added to the ad group.

=cut
