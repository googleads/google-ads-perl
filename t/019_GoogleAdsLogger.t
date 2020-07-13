#!/usr/bin/perl -w
#
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
# Unit tests for the Google::Ads::GoogleAds::Logging::GoogleAdsLogger module.

use strict;
use warnings;

use lib qw(lib t/utils);
use TestUtils qw(read_file_content);
use Google::Ads::GoogleAds::Logging::GoogleAdsLogger;

use File::Basename;
use File::Spec;
use HTTP::Request::Common;
use JSON::XS;
use Log::Log4perl qw(get_logger :levels);
use Test::More(tests => 26);

# Tests use Google::Ads::GoogleAds::Logging::GoogleAdsLogger.
use_ok("Google::Ads::GoogleAds::Logging::GoogleAdsLogger");

# Initializes the log4perl module with the log4per_test.conf file, in which the
# string appender is enabled.
my $log4perl_test_conf =
  File::Spec->catdir(dirname($0), qw(testdata log4perl_test.conf));

Google::Ads::GoogleAds::Logging::GoogleAdsLogger::initialize_logging(
  $log4perl_test_conf);

# Tests if the log4perl module is initialized.
ok(Log::Log4perl->initialized(), "Log::Log4perl is initialized.");

my $summary_logger =
  Google::Ads::GoogleAds::Logging::GoogleAdsLogger::get_summary_logger;
my $detail_logger =
  Google::Ads::GoogleAds::Logging::GoogleAdsLogger::get_detail_logger;

is($summary_logger->level, $INFO,
  "Default log level for summary_logger is INFO.");
is($detail_logger->level, $INFO,
  "Default log level for detail_logger is INFO.");

# Tests the disable_all_logging() method.
Google::Ads::GoogleAds::Logging::GoogleAdsLogger::disable_all_logging();
is($summary_logger->level, $OFF,
  "disable_all_logging(): Log level for summary_logger changed to OFF.");
is($detail_logger->level, $OFF,
  "disable_all_logging(): Log level for detail_logger changed to OFF.");

# Tests the enable_all_logging() method.
Google::Ads::GoogleAds::Logging::GoogleAdsLogger::enable_all_logging();
is($summary_logger->level, $INFO,
  "enable_all_logging(): Log level for summary_logger changed to INFO.");
is($detail_logger->level, $INFO,
  "enable_all_logging(): Log level for detail_logger changed to INFO.");

# Gets the string appender for summary_logger and detail_logger.
my $summary_string_appender =
  Log::Log4perl->appender_by_name("summary_string_appender");
my $detail_string_appender =
  Log::Log4perl->appender_by_name("detail_string_appender");

# Tests the summary and detail log content with HTTP requests and responses
# defined in "logger_tests.json".
my $json_text   = read_file_content("testdata", "logger_tests.json");
my $json_object = decode_json($json_text);

# Tests the success logging.
GoogleAdsLogger::Test::Service::test_logging(
  $json_object->{success_logging}{request},
  $json_object->{success_logging}{response});

my $summary_log = $summary_string_appender->string;
my $detail_log  = $detail_string_appender->string;

ok($summary_log, "Test success logging: summary log is OK.");
is(
  __extract_summary_log_value($summary_log, "Host"),
  "https://googleads.googleapis.com",
  "Test success logging: summary - Host."
);
is(__extract_summary_log_value($summary_log, "ClientCustomerId"),
  1234567890, "Test success logging: summary - ClientCustomerId.");
is(
  __extract_summary_log_value($summary_log, "Method"),
  "GoogleAdsLogger::Test::Service::test_logging",
  "Test success logging: summary - Method."
);
is(__extract_summary_log_value($summary_log, "RequestId"),
  "cdor20UpKmPLPFR60DhuMQ", "Test success logging: summary - RequestId.");
is(__extract_summary_log_value($summary_log, "IsFault"),
  "False", "Test success logging: summary - IsFault.");
is(__extract_summary_log_value($summary_log, "FaultMessage"),
  "", "Test success logging: summary - FaultMessage.");
ok(!$detail_log, "Test success logging: detail log is empty.");

# Tests the error logging.
$summary_string_appender->string("");
$detail_string_appender->string("");

GoogleAdsLogger::Test::Service::test_logging(
  $json_object->{error_logging}{request},
  $json_object->{error_logging}{response});

$summary_log = $summary_string_appender->string;
$detail_log  = $detail_string_appender->string;

ok($summary_log, "Test error logging: summary log is OK.");
is(
  __extract_summary_log_value($summary_log, "Method"),
  "GoogleAdsLogger::Test::Service::test_logging",
  "Test error logging: summary - Method."
);
is(__extract_summary_log_value($summary_log, "RequestId"),
  "p6RN_upPmz3xn8xR9Z-ARg", "Test error logging: summary - RequestId.");
is(__extract_summary_log_value($summary_log, "IsFault"),
  "True", "Test error logging: summary - IsFault.");
is(
  __extract_summary_log_value($summary_log, "FaultMessage"),
  "Unrecognized field in the query: 'campaign.invalid_key'.",
  "Test error logging: summary - FaultMessage."
);

ok($detail_log, "Test error logging: detail log is OK.");
my $request_headers = __extract_detail_log_json($detail_log, "Headers");
is($request_headers->{"user-agent"},
  "gl-perl/5.24.1", "Test error logging: detail header - user-agent.");
is($request_headers->{"x-goog-api-client"},
  "gl-perl/5.24.1", "Test error logging: detail header - x-goog-api-client.");
is($request_headers->{"developer-token"},
  "REDACTED", "Test error logging: detail - developer token header REDACTED.");
is($request_headers->{authorization},
  "REDACTED", "Test error logging: detail - authorization header REDACTED.");

# The private method to extract the value for a specific key in the summary log.
sub __extract_summary_log_value {
  my ($log, $key) = @_;

  # The last key "FaultMessage" in the summary log.
  return $1 if $key eq "FaultMessage" and $log =~ /$key=(.+)/;
  return $1 if $log                            =~ /$key=(\S+)/;
}

# The private method to extract the JSON object for a specific key in the detail log.
sub __extract_detail_log_json {
  my ($log, $key) = @_;
  return decode_json($1) if $log =~ /$key: (\{[^{}]+})/;
}

# The GoogleAdsLogger::Test::Base and GoogleAdsLogger::Test::Service modules
# are to simulate the class hierarchy of concrete Google Ads services and the
# Google::Ads::GoogleAds::BaseService.
#
# In Google::Ads::GoogleAds::Logging::GoogleAdsLogger, we use the
#         method  => (caller(2))[3]
# approach to detect the service method name where the logger is invoked.

{
  # This module is to simulate the concrete Google Ads services layer.
  package GoogleAdsLogger::Test::Service;

  sub test_logging {
    my ($request_body, $response_body) = @_;
    GoogleAdsLogger::Test::Base::test_logging($request_body, $response_body);
  }
}

{
  # This module is to simulate the Google::Ads::GoogleAds::BaseService layer.
  package GoogleAdsLogger::Test::Base;

  use JSON::XS;

  sub test_logging {
    my ($request_body, $response_body) = @_;
    my $http_request  = __wrap_http_request($request_body);
    my $http_response = __wrap_http_response($response_body);

    eval {
      Google::Ads::GoogleAds::Logging::GoogleAdsLogger::log_summary(
        $http_request, $http_response);
      Google::Ads::GoogleAds::Logging::GoogleAdsLogger::log_detail(
        $http_request, $http_response);
    };
  }

  # The private method to wrap a HTTP request from a JSON object.
  sub __wrap_http_request {
    my $request_body = shift;
    return HTTP::Request->new(
      $request_body->{method},  $request_body->{url},
      $request_body->{headers}, encode_json($request_body->{content}));
  }

  # The private method to wrap a HTTP response from a JSON object.
  sub __wrap_http_response {
    my $response_body = shift;
    return HTTP::Response->new(
      $response_body->{code},    $response_body->{url},
      $response_body->{headers}, encode_json($response_body->{content}));
  }
}
