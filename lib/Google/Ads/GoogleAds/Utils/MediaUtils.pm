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
# This module contains utility methods for media processing.

package Google::Ads::GoogleAds::Utils::MediaUtils;

use strict;
use warnings;
use version;

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};

use Exporter 'import';
our @EXPORT = qw(get_base64_data_from_url);

use HTTP::Request;
use LWP::UserAgent;
use URI::Escape;
use MIME::Base64;

# Gets the image data (byte representation) from a given URL.
sub get_base64_data_from_url {
  my $url      = shift;
  my $request  = HTTP::Request->new(GET => $url);
  my $response = LWP::UserAgent->new->request($request);
  return encode_base64($response->content, '') if $response->is_success;
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Utils::MediaUtils

=head1 SYNOPSIS

  use Google::Ads::GoogleAds::Utils::MediaUtils;

  my $image_data = get_base64_data_from_url("https://gaagl.page.link/Eit5");

  if ($image_data) {
    # Make use of $image_data.
  }

=head1 DESCRIPTION

This module contains utility methods for media processing.

=head1 METHODS

=head2 get_base64_data_from_url

Gets the image data (byte representation) from a given URL.

=head3 Parameters

The URL from which the data will be retrieved.

=head3 Returns

A base64 encoded string of the image data. Or undef if the image is not found.

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
