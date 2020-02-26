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
# This module manages long-running operations with an API service.

package Google::Ads::GoogleAds::LongRunning::OperationService;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseService);

use Google::Ads::GoogleAds::Constants;

use Time::HiRes qw(sleep);

use constant DEFAULT_POLL_FREQUENCY_SECONDS => 5;
use constant DEFAULT_POLL_TIMEOUT_SECONDS   => 60;

# Class::Std-style attributes. Need to be kept in the same line.
# These need to go in the same line for older Perl interpreters to understand.
my %version_of : ATTR(:name<version> :default<>);

# Automatically called by Class::Std after the values for all the attributes
# have been populated but before the constructor returns the new object.
sub START {
  my ($self, $ident) = @_;

  $version_of{$ident} =
    lc Google::Ads::GoogleAds::Constants::OPERATION_SERVICE_VERSION;
}

# Gets the latest state of a long-running operation.
sub get {
  my $self          = shift;
  my $request_body  = shift;
  my $http_method   = 'GET';
  my $request_path  = sprintf '%s/{+name}', $self->get_version();
  my $response_type = 'Google::Ads::GoogleAds::LongRunning::Operation';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

# Deletes a long-running operation.
sub delete {
  my $self          = shift;
  my $request_body  = shift;
  my $http_method   = 'DELETE';
  my $request_path  = sprintf '%s/{+name}', $self->get_version();
  my $response_type = '';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

# Starts asynchronous cancellation on a long-running operation.
sub cancel {
  my $self          = shift;
  my $request_body  = shift;
  my $http_method   = 'POST';
  my $request_path  = sprintf '%s/{+name}:cancel', $self->get_version();
  my $response_type = '';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

# Polls the specified long-running operation until it is done or reaches at most
# a specified timeout.
sub poll_until_done {
  my $self         = shift;
  my $request_body = shift;

  my $poll_frequency_seconds =
      $request_body->{pollFrequencySeconds}
    ? $request_body->{pollFrequencySeconds}
    : DEFAULT_POLL_FREQUENCY_SECONDS;

  my $poll_timeout_seconds =
      $request_body->{pollTimeoutSeconds}
    ? $request_body->{pollTimeoutSeconds}
    : DEFAULT_POLL_TIMEOUT_SECONDS;

  my $lro;
  my $elapsed_seconds = 0;
  while ($elapsed_seconds < $poll_timeout_seconds) {
    $lro = $self->get({name => $request_body->{name}});

    last if $lro->{done};

    sleep($poll_frequency_seconds);
    $elapsed_seconds += $poll_frequency_seconds;
  }

  return $lro;
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::LongRunning::OperationService

=head1 SYNOPSIS

  my $operation_service = $api_client->OperationService();

  $operation_service->poll_until_complete({
    name                 => $lro_name,
    pollFrequencySeconds => 5,
    pollTimeoutSeconds   => 60
  });

=head1 DESCRIPTION

This module manages long-running operations with an API service.

=head1 METHODS

=head2 get

Gets the latest state of a long-running operation.

=head3 Parameters

=over

=item *

I<request_body>: a L<Google::Ads::GoogleAds::LongRunning::GetOperationRequest> object.

=back

=head2 delete

Deletes a long-running operation.

=head3 Parameters

=over

=item *

I<request_body>: a L<Google::Ads::GoogleAds::LongRunning::DeleteOperationRequest> object.

=back

=head2 cancel

Starts asynchronous cancellation on a long-running operation.

=head3 Parameters

=over

=item *

I<request_body>: a L<Google::Ads::GoogleAds::LongRunning::CancelOperationRequest> object.

=back

=head2 poll_until_done

Polls the specified long-running operation until it is done or reaches at most a
specified timeout.

=head3 Parameters

=over

=item *

I<request_body>: a L<Google::Ads::GoogleAds::LongRunning::PollOperationRequest> object.

=back

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
