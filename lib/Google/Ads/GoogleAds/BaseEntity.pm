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
# The base class for all Google Ads API entities, e.g. common, resource,
# request, response, etc.

package Google::Ads::GoogleAds::BaseEntity;

use strict;
use warnings;
use version;

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};

# Called by JSON::XS to convert a blessed object to JSON.
sub TO_JSON {
  return {%{shift()}};
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::BaseEntity

=head1 DESCRIPTION

The abstract base class for all Google Ads API entities, e.g. common, resource,
request, response, etc.

=head1 METHODS

=head2 TO_JSON

The C<TO_JSON> method is invoked by L<JSON::XS> in scalar context, to convert a
blessed object into JSON. As JSON cannot directly represent Perl objects, we have
to enable the C<convert_blessed> attribute in L<JSON::XS> and define the C<TO_JSON>
method for each entity class to convert.

=head3 Returns

A scalar as the reference to the hash to convert based off current object.

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
