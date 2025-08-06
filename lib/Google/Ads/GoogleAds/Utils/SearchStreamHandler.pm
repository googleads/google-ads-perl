# Copyright 2020, Google LLC
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
# The handler class to process the response of stream search.

package Google::Ads::GoogleAds::Utils::SearchStreamHandler;

use strict;
use warnings;
use version;

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};

use Class::Std::Fast;
use JSON::SL;

use constant JSON_POINTER_RESULTS    => "/^/results";
use constant JSON_POINTER_REQUEST_ID => "/^/requestId";

# Class::Std-style attributes. Most values are read from googleads.properties file.
# These need to go in the same line for older Perl interpreters to understand.
my %service_of : ATTR(:name<service> :default<>);
my %request_of : ATTR(:name<request> :default<>);
my %json_sl_of : ATTR(:name<json_sl> :default<>);

# Automatically called by Class::Std after the values for all the attributes
# have been populated but before the constructor returns the new object.
sub START {
  my ($self, $ident) = @_;

  $json_sl_of{$ident} ||= JSON::SL->new();
  # Set the query path to "results" for the JSON::SL object.
  $json_sl_of{$ident}
    ->set_jsonpointer([JSON_POINTER_RESULTS, JSON_POINTER_REQUEST_ID]);
}

# Processes the response content of stream search.
# The $for_each_callback is invoked as a subroutine reference for each parsed GoogleAdsRow.
sub process_contents {
  my ($self, $for_each_callback) = @_;

  $self->get_service()->search_stream(
    $self->get_request(),
    # The $content_callback subroutine defined below takes two arguments:
    #   $data     - the chunk of data
    #   $response - the HTTP::Response
    sub {
      my ($data, $response) = @_;

      my $json_sl = $self->get_json_sl();
      # Append the returned data chunk to the JSON input stream.
      $json_sl->feed($data);

      # The fetch() method returns the remaining decoded JSON objects specified
      # by the JSON pointers.
      while (my $fetched = $json_sl->fetch()) {
        if ($fetched->{JSONPointer} eq JSON_POINTER_RESULTS) {
          foreach my $google_ads_row (@{$fetched->{Value}}) {
            # Call the $for_each_callback subroutine for each parsed row.
            $for_each_callback->($google_ads_row) if $for_each_callback;
          }
        } elsif ($fetched->{JSONPointer} eq JSON_POINTER_REQUEST_ID) {
          # Add the request id from the JSON payload to the HTTP response header
          # to be logged properly.
          $response->header("request-id" => $fetched->{Value});
        }
      }
    });
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Utils::SearchStreamHandler

=head1 SYNOPSIS

  my $search_stream_request =
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query => "SELECT campaign.id, campaign.name FROM campaign ORDER BY campaign.id"
    });

  my $google_ads_service = $api_client->GoogleAdsService();

  my $search_stream_handler = Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
    service => $google_ads_service,
    request => $search_stream_request
  });

  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      # Do something with each GooglerAdsRow object.
    });

=head1 DESCRIPTION

The handler class to process the response of stream search. The handler should be
constructed with a L<Google::Ads::GoogleAds::V21::Services::GoogleAdsService> and a
L<Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest>.

  my $search_stream_handler = Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
    service => $google_ads_service,
    request => $search_stream_request
  });

=head1 METHODS

=head2 process_contents

Processes the response content of stream search.

=head3 Parameters

=over

=item *

I<for_each_callback>: The callback subroutine which is invoked to process each
parsed L<Google::Ads::GoogleAds::V21::Services::GoogleAdsService::GoogleAdsRow>.

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2020 Google LLC

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
