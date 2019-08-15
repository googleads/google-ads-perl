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

package Google::Ads::GoogleAds::Logging::SummaryStats;

use strict;
use warnings;
use version;

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};

use Class::Std::Fast;
use Encode qw( encode_utf8 decode_utf8 );

my %host_of : ATTR(:name<host> :default<>);
my %customer_id_of : ATTR(:name<customer_id> :default<>);
my %method_of : ATTR(:name<method> :default<>);
my %request_id_of : ATTR(:name<request_id> :default<>);
my %is_fault_of : ATTR(:name<is_fault> :default<0>);
my %fault_message_of : ATTR(:name<fault_message> :default<>);

sub as_str : STRINGIFY {
  my $self          = shift;
  my $host          = $self->get_host() || "";
  my $customer_id   = $self->get_customer_id() || "";
  my $method        = $self->get_method() || "";
  my $request_id    = $self->get_request_id() || "";
  my $is_fault      = $self->get_is_fault() ? "True" : "False";
  my $fault_message = $self->get_fault_message() || "";

  # Convert the fault message to one less than 16K characters.
  $fault_message =~ s/\r?\n/ /g;
  my $utf8        = encode_utf8($fault_message);
  my @utf8_chunks = $utf8 =~ /\G(.{1,16000})(?![\x80-\xBF])/sg;
  $fault_message = decode_utf8($_) for @utf8_chunks;

  return " Host=${host}" . " ClientCustomerId=${customer_id}" .
    " Method=${method}" . " RequestId=${request_id}" .
    " IsFault=${is_fault}" . " FaultMessage=${fault_message}";
}

return 1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Logging::SummaryStats

=head1 DESCRIPTION

Class that wraps API request statistics such as client customer ID,
request id, API method and others.

=head1 ATTRIBUTES

=head2 host

The Google Ads API server endpoint.

=head2 customer_id

The client customer id against which the API call was made .

=head2 method

The name of the service method that was called.

=head2 request_id

Request id of the call.

=head2 is_fault

Whether the request returned as a fault or not.

=head2 fault_message

The stack trace of up to 16K characters if a fault occurs.

=head1 LICENSE AND COPYRIGHT

Copyright 2019 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=head1 REPOSITORY INFORMATION

 $Rev: $
 $LastChangedBy: $
 $Id: $

=cut
