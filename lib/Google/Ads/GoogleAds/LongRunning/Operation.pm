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
# Represents a long-running operation that is the result of a network
# API call.

package Google::Ads::GoogleAds::LongRunning::Operation;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    name     => $args->{name},
    metadata => $args->{metadata},
    done     => $args->{done},
    error    => $args->{error},
    response => $args->{response}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::LongRunning::Operation

=head1 DESCRIPTION

Represents a long-running operation that is the result of a network API call.

=head1 ATTRIBUTES

=head2 name

The server-assigned name, which is only unique within the same service that
originally returns it.

=head2 metadata

Service-specific metadata associated with the operation. It typically contains
progress information and common metadata such as create time.

=head2 done

If the value is "false", it means the operation is still in progress. If "true",
the operation is completed.

=head2 error

The error result of the operation in case of failure or cancellation.

=head2 response

The normal response of the operation in case of success.

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
