#!/usr/bin/perl -w
#
# Copyright 2024, Google LLC
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
# This code example illustrates how to retrieve the status of the advertiser
# identity verification program and, if required and not already started, how
# to start the verification process.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Enums::IdentityVerificationProgramEnum
  qw (ADVERTISER_IDENTITY_VERIFICATION);
use
  Google::Ads::GoogleAds::V23::Services::IdentityVerificationService::StartIdentityVerificationRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

sub verify_advertiser_identity {
  my ($api_client, $customer_id) = @_;

  # Retrieve the current advertiser identity verification status.
  my $identity_verification =
    get_identity_verification($api_client, $customer_id);

  if (defined $identity_verification) {
    if (!defined $identity_verification->{verificationProgress}{actionUrl}) {
      start_identity_verification($api_client, $customer_id);

      # Call get_identity_verification again to retrieve the verification progress
      # after starting an identity verification session.
      get_identity_verification($api_client, $customer_id);
    } else {
      # If there is an identity verification session in progress, there is no need
      # to start another one by calling StartIdentityVerification.
      printf "There is an advertiser identity verification session in " .
        "progress.\n The URL for the verification process is: %s and it " .
        "will expire at %s",
        $identity_verification->{verificationProgress}{actionUrl},
        $identity_verification->{verificationProgress}
        {invitationLinkExpirationTime};
    }
  } else {
    # If get_identity_verification returned an empty response, the account is not
    # enrolled in mandatory identity verification.
    printf "Account $customer_id is not required to perform identity " .
      "verification.\n See https://support.google.com/adspolicy/answer/9703665 "
      . "for details on how and when an account is required to undergo the "
      . "advertiser identity verification program.";
  }
  return 1;
}

# Retrieves the status of the advertiser identity verification process.
# [START verify_advertiser_identity_1]
sub get_identity_verification {
  my ($api_client, $customer_id) = @_;

  my $response = $api_client->IdentityVerificationService()->get({
    customerId => $customer_id
  });

  if (!defined $response->{identityVerification}) {
    printf "Account %s does not require advertiser identity verification.",
      $customer_id;
    return;
  }

  my $identity_verification = $response->{identityVerification}[0];
  my $deadline = $identity_verification->{identityVerificationRequirement}
    {verificationCompletionDeadlineTime};
  my $identity_verification_progress =
    $identity_verification->{verificationProgress};

  printf "Account %s has a verification completion deadline of %s and status " .
    "%s for advertiser identity verification.", $customer_id, $deadline,
    $identity_verification_progress->{programStatus};
  return $identity_verification;
}
# [END verify_advertiser_identity_1]

# Starts the identity verification process.
# [START verify_advertiser_identity_2]
sub start_identity_verification {
  my ($api_client, $customer_id) = @_;

  my $request =
    Google::Ads::GoogleAds::V23::Services::IdentityVerificationService::StartIdentityVerificationRequest
    ->new({
      customerId          => $customer_id,
      verificationProgram => ADVERTISER_IDENTITY_VERIFICATION
    });

  $api_client->AdvertiserIdentityVerificationService()
    ->start_identity_verification($request);
}
# [END verify_advertiser_identity_2]

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

my $customer_id;

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
verify_advertiser_identity($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

verify_advertiser_identity

=head1 DESCRIPTION

This code example retrieves the status of the advertiser identity verification
program and, if required and not already started, starts the verification process.

=head1 SYNOPSIS

verify_advertiser_identity.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
