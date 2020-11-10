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

package Google::Ads::GoogleAds::Logging::DetailStats;

use strict;
use warnings;
use version;

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};

use Class::Std::Fast;
use JSON::XS;
use Encode qw( encode_utf8 decode_utf8 );

# A list of fields in HTTP headers, content and GAQL that need to be scrubbed
# before logging for privacy reasons.
use constant REDACTED_STRING  => "REDACTED";
use constant SCRUBBED_HEADERS => qw(developer-token Authorization);
# Below fields will be scrubbed in the HTTP request and response content.
#   CustomerUserAccess.emailAddress
#   CustomerUserAccess.inviterUserEmailAddress
#   ChangeEvent.userEmail
#   PlacesLocationFeedData.emailAddress
#   CreateCustomerClientRequest.emailAddress
use constant SCRUBBED_CONTENT_FIELDS =>
  qw(emailAddress inviterUserEmailAddress userEmail);
# Below fields will be scrubbed in the GAQL statement of SearchGoogleAdsRequest
# and SearchGoogleAdsStreamRequest.
use constant SCRUBBED_GAQL_FIELDS => qw(customer_user_access\.email_address
  customer_user_access\.inviter_user_email_address change_event\.user_email
  feed\.places_location_feed_data\.email_address
);

my %host_of : ATTR(:name<host> :default<>);
my %method_of : ATTR(:name<method> :default<>);
my %request_headers_of : ATTR(:name<request_headers> :default<>);
my %request_content_of : ATTR(:name<request_content> :default<>);
my %response_headers_of : ATTR(:name<response_headers> :default<>);
my %response_content_of : ATTR(:name<response_content> :default<>);
my %fault_of : ATTR(:name<fault> :default<>);

sub as_str : STRINGIFY {
  my $self             = shift;
  my $host             = $self->get_host()             || "";
  my $method           = $self->get_method()           || "";
  my $request_headers  = $self->get_request_headers()  || {};
  my $request_content  = $self->get_request_content()  || "";
  my $response_headers = $self->get_response_headers() || {};
  my $response_content = $self->get_response_content();
  my $fault            = $self->get_fault();

  # Scrub the sensitive HTTP headers.
  foreach my $header (SCRUBBED_HEADERS) {
    $request_headers->header($header => REDACTED_STRING);
  }

  # Delete the unuseful "::std_case" header from request headers and response headers.
  delete $request_headers->{"::std_case"};
  delete $response_headers->{"::std_case"};

  # Scrub the sensitive fields in the HTTP request and response.
  $request_content  = _scrub_content($request_content);
  $request_content  = _scrub_gaql($request_content);
  $response_content = _scrub_content($response_content) if $response_content;

  my $json_coder     = JSON::XS->new->utf8->pretty;
  my $detail_message = sprintf(
    "Request\n" .
      "-------\n" . "MethodName: %s\n" . "Host: %s\n" . "Headers: %s\n" .
      "Request: %s\n" . "\nResponse\n" . "-------\n" . "Headers: %s\n",
    $method,          $host, $json_coder->encode({%$request_headers}),
    $request_content, $json_coder->encode({%$response_headers}));

  $detail_message .= "Response: ${response_content}\n" if $response_content;
  $detail_message .= "Fault: ${fault}\n"               if $fault;

  return $detail_message;
}

# Scrubs the sensitive fields in HTTP content.
sub _scrub_content {
  my $content = shift;
  foreach my $field (SCRUBBED_CONTENT_FIELDS) {
    $content =~ s/("$field"\s?:\s?)".+?"/$1"${\REDACTED_STRING}"/g;
  }

  return $content;
}

# Scrubs the sensitive fields in GAQL statement.
sub _scrub_gaql {
  my $content = shift;

  return $content if $content !~ /"query"/;
  foreach my $field (SCRUBBED_GAQL_FIELDS) {
    $content =~
      s/(SELECT.+WHERE.+$field.+?['"])\S+?(['"])/$1${\REDACTED_STRING}$2/i;
  }

  return $content;
}

return 1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Logging::DetailStats

=head1 DESCRIPTION

Class that wraps the detailed HTTP request and response like host, method,
headers, payload.

=head1 ATTRIBUTES

=head2 host

The Google Ads API server endpoint.

=head2 method

The name of the service method that was called.

=head2 request_headers

The REST HTTP request headers.

=head2 request_content

The REST HTTP request payload.

=head2 response_headers

The REST HTTP response headers.

=head2 response_content

The REST HTTP response payload.

=head2 fault

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
