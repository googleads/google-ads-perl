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
# The base class for all Google Ads API services, e.g. CampaignService,
# AdGroupService, etc.

package Google::Ads::GoogleAds::BaseService;

use strict;
use warnings;
use version;

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};
use Google::Ads::GoogleAds::Logging::GoogleAdsLogger;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::GoogleAdsException;

use Class::Std::Fast;
use LWP::UserAgent::Determined;
use HTTP::Status qw(:constants);
use JSON::XS;
use URI::Query;
use utf8;

use constant GET  => "GET";
use constant POST => "POST";

# Class::Std-style attributes. Need to be kept in the same line.
# These need to go in the same line for older Perl interpreters to understand.
my %api_client_of : ATTR(:name<api_client> :default<>);
my %__lwp_agent_of : ATTR(:name<__lwp_agent> :default<>);
my %__json_coder_of : ATTR(:name<__json_coder> :default<>);

# Automatically called by Class::Std after the values for all the attributes
# have been populated but before the constructor returns the new object.
sub START {
  my ($self, $ident) = @_;

  $__lwp_agent_of{$ident} ||= LWP::UserAgent::Determined->new();
  # The 'pretty' attribute should be enabled for more readable form in the log.
  # The 'convert_blessed' attributed should be enabled to convert blessed objects.
  $__json_coder_of{$ident} ||= JSON::XS->new->utf8->pretty->convert_blessed;
}

# Sends a HTTP request to Google Ads API server and handles the response.
sub call {
  my ($self, $http_method, $request_path, $request_body, $response_type,
    $content_callback)
    = @_;

  my $api_client = $self->get_api_client();

  ##############################################################################
  # Step 1: Prepare for the request URL and request content.
  ##############################################################################
  if ($http_method eq GET) {
    # HTTP GET request scenarios:
    #  GET: v23/customers:listAccessibleCustomers
    #  GET: v23/{+resourceName}
    #  GET: v23/{+resourceName}:listResults
    #  GET: v23/customers/{+customerId}/paymentsAccounts
    #  GET: v23/customers/{+customerId}/merchantCenterLinks
    $request_path = expand_path_template($request_path, $request_body);

    # GET: When the $request_body is a hash reference, use the path parameters
    # in the hash to expand the $request_path, and add all the other key-value
    # pairs to the URL query parameters if there is any. e.g.
    #
    #  GET: CampaignExperimentService.list_async_errors
    #  GET: CampaignDraftService.list_async_errors
    #  GET: BatchJobService.list_results
    if (ref $request_body and (keys %$request_body) > 0) {
      $request_path .= ("?" . URI::Query->new($request_body));
    }
  } elsif ($http_method eq POST) {
    # HTTP POST request scenarios:
    #  POST: v23/geoTargetConstants:suggest
    #  POST: v23/googleAdsFields:search
    #  POST: v23/customers/{+customerId}/googleAds:search
    #  POST: v23/customers/{+customerId}/campaigns:mutate
    #  POST: v23/{+keywordPlan}:generateForecastMetrics
    #  POST: v23/{+campaignDraft}:promote
    #  POST: v23/{+resourceName}:addOperations

    # POST: Retain the 'customerId' variable in the $request_body hash
    # reference after the $request_path is expanded.
    my $customer_id = $request_body->{customerId} if ref $request_body;

    $request_path = expand_path_template($request_path, $request_body);

    $request_body->{customerId} = $customer_id if defined $customer_id;
  } else {
    # Other HTTP request scenarios:
    #  DELETE: v23/{+name} for OperationService
    $request_path = expand_path_template($request_path, $request_body);
  }

  # Generate the request URL from the API service address and the request path.
  my $request_url = $api_client->get_service_address() . $request_path;

  my $json_coder = $self->get___json_coder();

  # Encode the JSON request content for POST request.
  my $request_content = undef;
  if ($http_method eq POST) {
    $request_content =
      defined $request_body
      ? $json_coder->encode($request_body)
      : '{}';
  }

  ##############################################################################
  # Step 2: Send the authorized HTTP request and handle the HTTP response.
  ##############################################################################
  my $auth_handler = $api_client->_get_auth_handler();
  if (!$auth_handler) {
    $api_client->get_die_on_faults()
      ? die(Google::Ads::GoogleAds::Constants::NO_AUTH_HANDLER_SETUP_MESSAGE)
      : warn(Google::Ads::GoogleAds::Constants::NO_AUTH_HANDLER_SETUP_MESSAGE);
    return;
  }

  my $http_headers = $self->_get_http_headers();
  my $http_request =
    $auth_handler->prepare_request($http_method, $request_url, $http_headers,
    $request_content);

  utf8::is_utf8 $http_request and utf8::encode $http_request;

  my $lwp_agent = $self->get___lwp_agent();

  # Set up HTTP timeout, retry and proxy for the lwp agent.
  my $http_timeout = $api_client->get_http_timeout();
  $lwp_agent->timeout(
      $http_timeout
    ? $http_timeout
    : Google::Ads::GoogleAds::Constants::DEFAULT_HTTP_TIMEOUT
  );

  my $http_retry_timing = $api_client->get_http_retry_timing();
  $lwp_agent->timing(
      $http_retry_timing
    ? $http_retry_timing
    : Google::Ads::GoogleAds::Constants::DEFAULT_HTTP_RETRY_TIMING
  );
  # Retry for status codes 503 & 504 to be parity with gRPC.
  $lwp_agent->codes_to_determinate(
    {HTTP_SERVICE_UNAVAILABLE => 1, HTTP_GATEWAY_TIMEOUT => 1});

  my $proxy = $api_client->get_proxy();
  $proxy
    ? $lwp_agent->proxy(['http', 'https'], $proxy)
    : $lwp_agent->env_proxy;

  # Keep track of the last sent HTTP request.
  $api_client->set_last_request($http_request);

  # Send HTTP request with optional content callback handler (for search stream).
  my $http_response = undef;
  if ($content_callback) {
    $http_response = $lwp_agent->request($http_request, $content_callback);
    # The callback handler is not invoked when the response status is error.
    if ($http_response->is_error) {
      # The error response content returned by the search stream interface is
      # enclosed in square brackets, deviating from normal GoogleAdsException.
      # Remove the leading and trailing square brackets in the response content,
      # to make it operable in the subsequent steps (logging, exception handling).
      $http_response->content($http_response->decoded_content =~ s/^\[|\]$//gr);
    }
  } else {
    $http_response = $lwp_agent->request($http_request);
  }

  # Keep track of the last received HTTP response.
  $api_client->set_last_response($http_response);

  my $response_content = $http_response->decoded_content();

  ##############################################################################
  # Step 3: Log the one-line summary and the traffic detail. Error may occur
  # when the response content is not in JSON format.
  ##############################################################################
  eval {
    Google::Ads::GoogleAds::Logging::GoogleAdsLogger::log_summary($http_request,
      $http_response);
    Google::Ads::GoogleAds::Logging::GoogleAdsLogger::log_detail($http_request,
      $http_response);
  };
  if ($@) {
    $api_client->get_die_on_faults()
      ? die($response_content . "\n")
      : warn($response_content . "\n");
    return;
  }

  ##############################################################################
  # Step 4: Return the decoded object or exception from the response content.
  ##############################################################################
  my $response_body =
    $response_content ? $json_coder->decode($response_content) : {};

  if ($http_response->is_success) {
    # Bless the JSON format response to the response type class.
    bless $response_body, $response_type if $response_type;
    return $response_body;
  } else {
    $api_client->get_die_on_faults()
      ? die_with_code(1, $response_content)
      : warn($response_content);

    return Google::Ads::GoogleAds::GoogleAdsException->new($response_body);
  }
}

# Protected method to generate the appropriate REST request headers.
sub _get_http_headers {
  my $self = shift;

  my $api_client = $self->get_api_client();

  my $headers = [
    "Content-Type",
    "application/json; charset=utf-8",
    "user-agent",
    $api_client->get_user_agent(),
    "x-goog-api-client",
    join(' ',
      Google::Ads::GoogleAds::Constants::DEFAULT_USER_AGENT,
      "gccl/" . Google::Ads::GoogleAds::BaseService->VERSION,
      "rest/" . $LWP::UserAgent::Determined::VERSION)];

  # Add the developer-token header if the client is not configured to
  # use Google Cloud Organization for API access.
  push @$headers, ("developer-token", $api_client->get_developer_token())
    if !$api_client->get_use_cloud_org_for_api_access();

  my $login_customer_id = $api_client->get_login_customer_id();
  push @$headers, ("login-customer-id", $login_customer_id =~ s/-//gr)
    if $login_customer_id;

  my $linked_customer_id = $api_client->get_linked_customer_id();
  push @$headers, ("linked-customer-id", $linked_customer_id =~ s/-//gr)
    if $linked_customer_id;

  return $headers;
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::BaseService

=head1 DESCRIPTION

The abstract base class for all Google Ads API services, e.g. CampaignService,
AdGroupService, etc.

=head1 SYNOPSIS

  use Google::Ads::GoogleAds::Client;

  my $api_client = Google::Ads::GoogleAds::Client->new();

  my $campaign_service = $api_client->CampaignService();

=head1 ATTRIBUTES

Each service instance is initialized by L<Google::Ads::GoogleAds::Client>, and
these attributes are set automatically.

Alternatively, there is a get_ and set_ method associated with each attribute
for retrieving or setting them dynamically.

  my %api_client_of : ATTR(:name<api_client> :default<>);

=head2 api_client

A reference to the L<Google::Ads::GoogleAds::Client>, holding the API credentials
and configurations.

=head1 METHODS

=head2 call

Sends REST HTTP requests to Google Ads API server and handles the responses.

=head3 Parameters

=over

=item *

I<http_method>: The HTTP request method, e.g. GET, POST.

=item *

I<request_path>: The relative request URL which may contain wildcards to expand,
e.g. {+resourceName}, {+customerId}.

=item *

I<request_body>: A Perl object representing the HTTP request payload, which will
be used to expand the {+resourceName} or any other expression in the request path
and encoded into JSON string for a HTTP POST request.

=item *

I<response_type>: The class name of the expected response. An instance of this class
will be returned if the request succeeds.

=item *

I<content_callback>: The optional streaming content callback method.

=back

=head3 Returns

An instance of the class defined by the C<response_type> parameter, or a
L<Google::Ads::GoogleAds::GoogleAdsException> object if an error has occurred at
the server side by default. However if the C<die_on_faults> flag is set to true
in L<Google::Ads::GoogleAds::Client>, the service will issue a die() with error
message on API errors.

=head2 _get_http_headers

Prepare the basic HTTP request headers including Content-Type, user-agent,
developer-token, login-customer-id, linked-customer-id - if needed. The headers
will be consolidated with access token in the method of
L<Google::Ads::GoogleAds::Common::OAuth2BaseHandler/prepare_request>.

=head3 Returns

The basic HTTP headers including Content-Type, user-agent, developer-token,
login-customer-id, linked-customer-id - if needed.

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
