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
# This code example sends an invitation email to a user to manage a customer
# account with a desired access role.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::CustomerUserAccessInvitation;
use
  Google::Ads::GoogleAds::V21::Services::CustomerUserAccessInvitationService::CustomerUserAccessInvitationOperation;

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
my $customer_id   = "INSERT_CUSTOMER_ID_HERE";
my $email_address = "INSERT_EMAIL_ADDRESS_HERE";
# See Google::Ads::GoogleAds::V21::Enums::AccessRoleEnum for optional values.
my $access_role = "INSERT_ACCESS_ROLE_HERE";

# [START invite_user_with_access_role]
sub invite_user_with_access_role {
  my ($api_client, $customer_id, $email_address, $access_role) = @_;

  # Create the user access invitation.
  my $user_access_invitation =
    Google::Ads::GoogleAds::V21::Resources::CustomerUserAccessInvitation->new({
      emailAddress => $email_address,
      accessRole   => $access_role
    });

  # Create the user access invitation operation.
  my $invitation_operation =
    Google::Ads::GoogleAds::V21::Services::CustomerUserAccessInvitationService::CustomerUserAccessInvitationOperation
    ->new({create => $user_access_invitation});

  # Send the user access invitation.
  my $invitation_response =
    $api_client->CustomerUserAccessInvitationService()->mutate({
      customerId => $customer_id,
      operation  => $invitation_operation
    });

  printf "Customer user access invitation was sent for customerId = %d " .
    "to email address = '%s' and access role = '%s'. " .
    "The invitation resource name is '%s'.\n",
    $customer_id, $email_address, $access_role,
    $invitation_response->{result}{resourceName};

  return 1;
}
# [END invite_user_with_access_role]

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
  "customer_id=s"   => \$customer_id,
  "email_address=s" => \$email_address,
  "access_role=s"   => \$access_role
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $email_address, $access_role);

# Call the example.
invite_user_with_access_role($api_client, $customer_id =~ s/-//gr,
  $email_address, $access_role);

=pod

=head1 NAME

invite_user_with_access_role

=head1 DESCRIPTION

This code example sends an invitation email to a user to manage a customer
account with a desired access role.

=head1 SYNOPSIS

invite_user_with_access_role.pl [options]

    -help             Show the help message.
    -customer_id      The Google Ads customer ID.
    -email_address    Email address of the user to send the invitation to.
    -access_role      The user access role, e.g. ADMIN, STANDARD, READ_ONLY
                      and EMAIL_ONLY.
=cut
