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

package Google::Ads::GoogleAds::Common::FieldMask;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

sub new {
  my ($class, $args) = @_;

  my $self = {paths => $args->{paths}};

  bless $self, $class;
  return $self;
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Common::FieldMask

=head1 SYNOPSIS

  use Google::Ads::GoogleAds::Common::FieldMask;

  my $field_mask = Google::Ads::GoogleAds::Common::FieldMask->new({paths => $paths});

=head1 DESCRIPTION

Determines which resource fields are modified in an update operartion.

=head1 ATTRIBUTES

=head2 paths

The set of field mask paths.

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
