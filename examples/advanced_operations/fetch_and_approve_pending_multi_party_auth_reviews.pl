#!/usr/bin/perl -w
#
# Copyright 2026, Google LLC
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
# This code example fetches pending multi-party approvals and approves the first
# pending review request.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::PartialFailureUtils
  qw(get_google_ads_failure_from_status);
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use Google::Ads::GoogleAds::V24::Enums::MultiPartyAuthReviewStatusEnum
  qw(APPROVED);
use Google::Ads::GoogleAds::V24::Enums::MultiPartyAuthReviewTargetResourceEnum
  qw(CUSTOMER_USER_ACCESS CUSTOMER_USER_ACCESS_INVITATION);
use Google::Ads::GoogleAds::V24::Enums::MultiPartyAuthOperationTypeEnum
  qw(UPDATE REMOVE);
use
  Google::Ads::GoogleAds::V24::Services::GoogleAdsService::SearchGoogleAdsRequest;
use
  Google::Ads::GoogleAds::V24::Services::MultiPartyAuthReviewService::ResolveMultiPartyAuthReviewRequest;
use
  Google::Ads::GoogleAds::V24::Services::MultiPartyAuthReviewService::ResolveMultiPartyAuthReviewOperation;

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
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub fetch_and_approve_pending_multi_party_auth_reviews {
  my ($api_client, $customer_id) = @_;

  # Retrieve the list of MPA auth reviews.
  my $pending_reviews = fetch_pending_mpa_reviews($api_client, $customer_id);

  if (scalar @$pending_reviews > 0) {
    # Multi party auth reviews can only be resolved one at a time. In this code
    # example, we illustrate approving the first pending review request.
    approve_mpa_review($api_client, $customer_id, $pending_reviews->[0]);
  }

  return 1;
}

# Approves the MPA auth review.
# [START approve_mpa_review]
sub approve_mpa_review {
  my ($api_client, $customer_id, $pending_review) = @_;

  # Create the resolve operation.
  my $operation =
    Google::Ads::GoogleAds::V24::Services::MultiPartyAuthReviewService::ResolveMultiPartyAuthReviewOperation
    ->new({
      multiPartyAuthReview => $pending_review,
      newStatus            => APPROVED
    });

  # Send the resolution request.
  my $response = $api_client->MultiPartyAuthReviewService()->resolve({
      customerId => $customer_id,
      operations => [$operation]});

  my $result_or_error = $response->{resultOrError}[0];
  if ($result_or_error->{result}) {
    my $result = $result_or_error->{result};
    printf "Approved multi-party auth review: '%s'.\n",
      $result->{multiPartyAuthReview};
    if ($result->{customerUserAccessInvitation}) {
      printf "New user invitation created: '%s'\n",
        $result->{customerUserAccessInvitation};
    } elsif ($result->{customerUserAccess}) {
      printf "Affected customer user access resource: '%s'\n",
        $result->{customerUserAccess};
    }
  } else {
    my $failure =
      get_google_ads_failure_from_status(
      $result_or_error->{partialFailureError});
    if ($failure) {
      printf "%d partial failure error(s) occurred.\n",
        scalar @{$failure->{errors}};
    } else {
      print "An unknown partial failure error occurred.\n";
    }
  }
}
# [END approve_mpa_review]

# Fetches the pending MPA reviews.
# [START fetch_mpa_review]
sub fetch_pending_mpa_reviews {
  my ($api_client, $customer_id) = @_;

  my $pending_reviews = [];

  # Create a query that will retrieve all the pending MPA reviews.
  my $search_query =
    "SELECT " .
    "multi_party_auth_review.resource_name, " .
    "multi_party_auth_review.multi_party_auth_review_id, " .
    "multi_party_auth_review.creation_date_time, " .
    "multi_party_auth_review.request_user_email, " .
    "multi_party_auth_review.operation_type, " .
    "multi_party_auth_review.justification, " .
    "multi_party_auth_review.target_resource, " .
"multi_party_auth_review.customer_user_access_review.old_customer_user_access, "
    . "multi_party_auth_review.customer_user_access_review.new_customer_user_access, "
    . "multi_party_auth_review.customer_user_access_invitation_review.new_customer_user_access_invitation "
    . "FROM multi_party_auth_review "
    . "WHERE multi_party_auth_review.review_status = 'PENDING'";

  # Create a search Google Ads request.
  my $search_request =
    Google::Ads::GoogleAds::V24::Services::GoogleAdsService::SearchGoogleAdsRequest
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

  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;
    my $mpa_review     = $google_ads_row->{multiPartyAuthReview};

    printf "%s created a pending multi-party auth review with ID %s at %s. " .
      "This request is for target resource type = %s and operation type = %s. "
      . "The justification is \"%s\".\n",
      $mpa_review->{requestUserEmail},
      $mpa_review->{multiPartyAuthReviewId},
      $mpa_review->{creationDateTime},
      $mpa_review->{targetResource},
      $mpa_review->{operationType},
      $mpa_review->{justification};

    if ($mpa_review->{targetResource} eq CUSTOMER_USER_ACCESS) {
      my $access_review = $mpa_review->{customerUserAccessReview};
      if ($mpa_review->{operationType} eq UPDATE) {
        # When updating a customer user access, only the new access level
        # is populated.
        printf "Old resource name: %s, new access role: %s.\n",
          $access_review->{oldCustomerUserAccess},
          $access_review->{newCustomerUserAccess}{accessRole};
      } elsif ($mpa_review->{operationType} eq REMOVE) {
        printf "Old resource name: %s.\n",
          $access_review->{oldCustomerUserAccess};
      }
    } elsif ($mpa_review->{targetResource} eq CUSTOMER_USER_ACCESS_INVITATION) {
      my $new_invite =
        $mpa_review->{customerUserAccessInvitationReview}
        {newCustomerUserAccessInvitation};
      printf "Invitation email address: %s, Role: %s.\n",
        $new_invite->{emailAddress}, $new_invite->{accessRole};
    }

    push @$pending_reviews, $mpa_review->{resourceName};
  }

  return $pending_reviews;
}
# [END fetch_mpa_review]

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
fetch_and_approve_pending_multi_party_auth_reviews($api_client,
  $customer_id =~ s/-//gr);

=pod

=head1 NAME

fetch_and_approve_pending_multi_party_auth_reviews

=head1 DESCRIPTION

This code example fetches pending multi-party approvals and approves the first
pending review request.

=head1 SYNOPSIS

fetch_and_approve_pending_multi_party_auth_reviews.pl [options]

    -help             Show the help message.
    -customer_id      The Google Ads customer ID.

=cut
