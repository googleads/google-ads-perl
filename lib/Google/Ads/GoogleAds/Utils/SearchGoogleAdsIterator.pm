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
# The iterator class to access all rows that match the search query.

package Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;

use strict;
use warnings;
use version;

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};

use Class::Std::Fast;

# Class::Std-style attributes. Most values are read from googleads.properties file.
# These need to go in the same line for older Perl interpreters to understand.
my %service_of : ATTR(:name<service> :default<>);
my %request_of : ATTR(:name<request> :default<>);
my %current_response_of : ATTR(:name<current_response> :default<>);
my %current_cursor_of : ATTR(:name<current_cursor> :default<0>);

# Automatically called by Class::Std after the values for all the attributes
# have been populated but before the constructor returns the new object.
sub START {
  my ($self, $ident) = @_;

  my $response = $service_of{$ident}->search($request_of{$ident});
  $current_response_of{$ident} = $response;
  $current_cursor_of{$ident}   = 0;
}

# Checks whether the iteration has more elements.
sub has_next {
  my $self = shift;

  my $current_response = $self->get_current_response();
  return 0 if !$current_response or !$current_response->{results};

  my $current_cursor = $self->get_current_cursor();
  return 0
    unless $current_response->{nextPageToken}
    or scalar @{$current_response->{results}} > $current_cursor;

  return 1;
}

# Returns the next element in the iteration.
sub next {
  my $self = shift;
  return undef if !$self->has_next();

  my $current_response = $self->get_current_response();
  my $current_cursor   = $self->get_current_cursor();

  if (scalar @{$current_response->{results}} == $current_cursor) {
    my $request = $self->get_request();
    $request->{pageToken} = $current_response->{nextPageToken};

    my $response = $self->get_service()->search($request);
    $self->set_current_response($response);

    $self->set_current_cursor(1);
    return $response->{results}[0];
  } else {
    $self->set_current_cursor($current_cursor + 1);
    return $current_response->{results}[$current_cursor];
  }
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator

=head1 SYNOPSIS

  my $search_request =
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query => "SELECT campaign.id, campaign.name FROM campaign ORDER BY campaign.id",
      pageSize => 100
    });

  my $google_ads_service = $api_client->GoogleAdsService();

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;
    # Do something with each GooglerAdsRow object.
  }

=head1 DESCRIPTION

The iterator class to access all rows that match the search query. The iterator
should be constructed with a L<Google::Ads::GoogleAds::V23::Services::GoogleAdsService>
and a L<Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest>.

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

=head1 METHODS

=head2 has_next

Checks whether the iteration has more elements.

=head3 Returns

True, if the iteration has more elements. False, otherwise.

=head2 next

Returns the next element in the iteration.

=head3 Returns

The next element in the iteration if there's any, otherwise undef.

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
