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
# The logger for outgoing and incoming REST messages as API calls.

package Google::Ads::GoogleAds::Logging::GoogleAdsLogger;

use strict;
use warnings;
use version;

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};
use Google::Ads::GoogleAds::Logging::SummaryStats;
use Google::Ads::GoogleAds::Logging::DetailStats;

use File::HomeDir;
use File::Spec;
use Log::Log4perl qw(get_logger :levels);
use JSON::XS;

# Module initialization.
# This is the log4perl configuration format.
my $logs_folder = File::Spec->catfile(File::HomeDir->my_home, "logs");
my $summary_log_file = File::Spec->catfile($logs_folder, "summary.log");
my $detail_log_file  = File::Spec->catfile($logs_folder, "detail.log");
my $default_conf     = <<TEXT;
  log4perl.category.Google.Ads.GoogleAds.Summary = INFO, SummaryFile
  log4perl.appender.SummaryFile = Log::Log4perl::Appender::File
  log4perl.appender.SummaryFile.filename = ${summary_log_file}
  log4perl.appender.SummaryFile.create_at_logtime = 1
  log4perl.appender.SummaryFile.mkpath = 1
  log4perl.appender.SummaryFile.layout = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.SummaryFile.layout.ConversionPattern = [%d{DATE} - %-5p] %m%n

  log4perl.category.Google.Ads.GoogleAds.Detail = INFO, DetailFile
  log4perl.appender.DetailFile = Log::Log4perl::Appender::File
  log4perl.appender.DetailFile.filename = ${detail_log_file}
  log4perl.appender.DetailFile.create_at_logtime = 1
  log4perl.appender.DetailFile.mkpath = 1
  log4perl.appender.DetailFile.layout = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.DetailFile.layout.ConversionPattern = [%d{DATE} - %-5p] %m%n
TEXT

# Static module-level variables.
my ($summary_logger, $detail_logger);

# Initializes Log4Perl infrastructure.
sub initialize_logging {
  # Only initialize once.
  unless (Log::Log4perl->initialized()) {
    my $log4perl_conf = shift;
    # Trying to read from the ~/log4perl.conf file if no .conf file is specified as a parameter.
    $log4perl_conf =
      File::Spec->catfile(File::HomeDir->my_home, "log4perl.conf")
      unless defined $log4perl_conf;
    if (-r $log4perl_conf) {
      Log::Log4perl->init($log4perl_conf);
    } else {
      mkdir ${logs_folder} unless -d ${logs_folder};
      Log::Log4perl->init(\$default_conf);
    }
  }

  # Log4Perl may be initialized by another package; check if the loggers are set up.
  unless ($summary_logger and $detail_logger) {
    $summary_logger = get_logger("Google::Ads::GoogleAds::Summary");
    $detail_logger  = get_logger("Google::Ads::GoogleAds::Detail");
  }
}

# Enables the summary logging. Takes one boolean parameter, to enable the logging
# in debug (more verbose) mode when set to true.
sub enable_summary_logging {
  initialize_logging();
  if ($_[0]) {
    $summary_logger->level($DEBUG);
  } else {
    $summary_logger->level($INFO);
  }
}

# Disables all summary logging.
sub disable_summary_logging {
  $summary_logger->level($OFF);
}

# Enables the traffic detail (request and responses) logging. Takes one boolean
# parameter, to enable the logging in debug (more verbose) mode when set to true.
sub enable_detail_logging {
  initialize_logging();
  if ($_[0]) {
    $detail_logger->level($DEBUG);
  } else {
    $detail_logger->level($INFO);
  }
}

# Disables all traffic detail logging.
sub disable_detail_logging {
  $detail_logger->level($OFF);
}

# Enables all logging including summary logging and traffic detail logging.
sub enable_all_logging {
  initialize_logging();
  if ($_[0]) {
    $summary_logger->level($DEBUG);
    $detail_logger->level($DEBUG);
  } else {
    $summary_logger->level($INFO);
    $detail_logger->level($INFO);
  }
}

# Disables all logging including summary logging and traffic detail logging.
sub disable_all_logging {
  $summary_logger->level($OFF);
  $detail_logger->level($OFF);
}

# Retrieves the summary logger used to log the one-line summary.
sub get_summary_logger {
  initialize_logging();
  return $summary_logger;
}

# Retrieves the detail logger used to log the traffic detail.
sub get_detail_logger {
  initialize_logging();
  return $detail_logger;
}

# Logs the one-line summary for each REST API request.
sub log_summary {
  my ($http_request, $http_response) = @_;

  # Validate the response status and log level.
  return
    unless ($http_response->is_success and $summary_logger->is_info)
    or (!$http_response->is_success and $summary_logger->is_warn);

  my $summary_stats = Google::Ads::GoogleAds::Logging::SummaryStats->new({
      host        => __parse_host($http_request),
      customer_id => $http_request->uri =~ /customers\/\d+/
      ? $http_request->uri =~ /customers\/(\d+)/
      : "",
      # The service method name in which the logger is invoked.
      method     => (caller(3))[3],
      request_id => $http_response->header("request-id")
      ? $http_response->header("request-id")
      : ""
    });

  if ($http_response->is_success) {
    $summary_logger->info($summary_stats);
  } else {
    $summary_stats->set_is_fault(1);
    $summary_stats->set_fault_message(
      __parse_fault_message($http_response->decoded_content));
    $summary_logger->warn($summary_stats);
  }
}

# Full log of REST API traffic detail.
sub log_detail {
  my ($http_request, $http_response) = @_;

  # Validate the response status and log level.
  return
    unless ($http_response->is_success and $detail_logger->is_debug)
    or (!$http_response->is_success and $detail_logger->is_info);

  my $detail_stats = Google::Ads::GoogleAds::Logging::DetailStats->new({
    host => __parse_host($http_request),
    # The service method name in which the logger is invoked.
    method           => (caller(3))[3],
    request_headers  => $http_request->headers,
    request_content  => $http_request->content,
    response_headers => $http_response->headers
  });

  if ($http_response->is_success) {
    $detail_stats->set_response_content($http_response->decoded_content);
    $detail_logger->debug($detail_stats);
  } else {
    $detail_stats->set_fault(__parse_faults($http_response->decoded_content));
    $detail_logger->info($detail_stats);
  }
}

# Parses the host name from a HTTP request.
sub __parse_host {
  my $http_request = shift;
  my $uri          = $http_request->uri;
  return $uri->scheme . "://" . $uri->host;
}

# Parses the fault message from the HTTP response JSON payload.
sub __parse_fault_message {
  my $response_content = shift;
  my $response_body    = decode_json($response_content);

  # When the fault is a GoogleAdsFailure.
  my $fault_message =
    $response_body->{error}{details}[0]{errors}[0]{message};

  # When the fault is a GRPC error, e.g. BadRequest, PreconditionFailure, QuotaFailure.
  $fault_message = $response_body->{error}{message} if not $fault_message;

  $fault_message = $response_content if not $fault_message;

  return $fault_message;
}

# Parses all the faults from the HTTP response JSON payload.
sub __parse_faults {
  my $response_content = shift;
  my $json_coder       = JSON::XS->new->utf8->pretty;
  my $response_body    = $json_coder->decode($response_content);

  my $faults = $response_body->{error}{details}[0];
  return $json_coder->encode($faults) if $faults;

  return $response_content;
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Logging::GoogleAdsLogger

=head1 SYNOPSIS

  use Google::Ads::GoogleAds::Logging::GoogleAdsLogger;

  Google::Ads::GoogleAds::Logging::GoogleAdsLogger::enable_all_logging(1);

  Google::Ads::GoogleAds::Logging::GoogleAdsLogger::log_summary($http_request, $http_response);

  Google::Ads::GoogleAds::Logging::GoogleAdsLogger::log_detail($http_request, $http_response);

=head1 DESCRIPTION

This class allows logging of outgoing and incoming REST messages as executed API
calls. It initializes the loggers based on a provided F<log4perl.conf> file or
default parameters if the file is not found. It contains methods to retrieve the
summary and detail loggers.

=head1 METHODS

=head2 initialize_logging

Initializes the loggers based on the default F<log4perl.conf> file or default
parameters if the file is not found.

=head2 enable_summary_logging

Enables the logging for the one-line summary.

=head3 Parameters

A boolean value of whether to include the DEBUG level messages.

=head2 disable_summary_logging

Disables the one-line summary logging.

=head2 enable_detail_logging

Enables the logging for traffic detail of HTTP request and response.

=head3 Parameters

A boolean value of whether to include the DEBUG level messages.

=head2 disable_detail_logging

Disables the traffic detail logging.

=head2 enable_all_logging

Enables all logging for the one-line summary and the traffic detail.

=head3 Parameters

A boolean value of whether to include the DEBUG level messages.

=head2 disable_all_logging

Stops all logging.

=head2 get_summary_logger

Retrieves the summary logger used to log the one-line summary.

=head3 Returns

A L<Log::Log4perl> logger for the one-line summary.

=head2 get_detail_logger

Retrieves the detail logger used to log the traffic detail.

=head3 Returns

A L<Log::Log4perl> logger for the traffic detail.

=head2 log_summary

Logs a one-line summary for each REST API request.

=head3 Parameters

=over

=item *

I<http_request>: The REST HTTP request sent to Google Ads API server.

=item *

I<http_response>: The HTTP response received from Google Ads API server.

=back

=head2 log_detail

Full log of the traffic detail about the request/response payload.

=head3 Parameters

=over

=item *

I<http_request>: The REST HTTP request sent to Google Ads API server.

=item *

I<http_response>: The HTTP response received from Google Ads API server.

=back

=head2 __parse_host

The private method to parse the hostname from a HTTP request.

=head3 Parameters

=over

=item *

I<http_request>: The REST HTTP request sent to Google Ads API server.

=back

=head3 Returns

The parsed hostname in the format of <scheme>://<domain>.

=head2 __parse_fault_message

The private method to parse the fault message from the HTTP response, if an error
has occurred at the server side. This message can be used to construct a
L<Google::Ads::GoogleAds::Logging::SummaryStats>.

=head2 __parse_faults

The private method to parse all the faults from the HTTP response, and C<encode>
them in the JSON format. These faults will be used to construct a
L<Google::Ads::GoogleAds::Logging::DetailStats>.

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
