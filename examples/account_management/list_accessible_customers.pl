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
# This example lists the resource names for the customers that the
# authenticating user has access to.
#
# The customer IDs retrieved from the resource names can be used to set
# the login_customer_id configuration. For more information, see this
# documentation: https://developers.google.com/google-ads/api/docs/concepts/call-structure#login-customer-id

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;

use Getopt::Long qw(:config auto_help);
use Cwd qw(abs_path);

sub list_accessible_customers {
  my ($api_client) = @_;

  my $list_accessible_customers_response =
    $api_client->CustomerService()->list_accessible_customers();

  printf "Total results: %d.\n",
    scalar @{$list_accessible_customers_response->{resourceNames}};

  foreach
    my $resource_name (@{$list_accessible_customers_response->{resourceNames}})
  {
    printf "Customer resource name: '%s'.\n", $resource_name;
  }

  return 1;
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new({version => "V2"});

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions();

# Call the example.
list_accessible_customers($api_client);

=pod

=head1 NAME

list_accessible_customers

=head1 DESCRIPTION

This example lists the resource names for the customers that the authenticating
user has access to.

The customer IDs retrieved from the resource names can be used to set the
login_customer_id configuration. For more information, see this documentation:
https://developers.google.com/google-ads/api/docs/concepts/call-structure#login-customer-id

=head1 SYNOPSIS

list_accessible_customers.pl [options]

    -help                       Show the help message.

=cut
