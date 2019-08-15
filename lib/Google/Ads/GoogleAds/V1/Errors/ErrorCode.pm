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

package Google::Ads::GoogleAds::V1::Errors::ErrorCode;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    accountBudgetProposalError      => $args->{accountBudgetProposalError},
    adCustomizerError               => $args->{adCustomizerError},
    adError                         => $args->{adError},
    adGroupAdError                  => $args->{adGroupAdError},
    adGroupBidModifierError         => $args->{adGroupBidModifierError},
    adGroupCriterionError           => $args->{adGroupCriterionError},
    adGroupError                    => $args->{adGroupError},
    adGroupFeedError                => $args->{adGroupFeedError},
    adParameterError                => $args->{adParameterError},
    adSharingError                  => $args->{adSharingError},
    adxError                        => $args->{adxError},
    assetError                      => $args->{assetError},
    authenticationError             => $args->{authenticationError},
    authorizationError              => $args->{authorizationError},
    biddingError                    => $args->{biddingError},
    biddingStrategyError            => $args->{biddingStrategyError},
    billingSetupError               => $args->{billingSetupError},
    campaignBudgetError             => $args->{campaignBudgetError},
    campaignCriterionError          => $args->{campaignCriterionError},
    campaignDraftError              => $args->{campaignDraftError},
    campaignError                   => $args->{campaignError},
    campaignExperimentError         => $args->{campaignExperimentError},
    campaignFeedError               => $args->{campaignFeedError},
    campaignSharedSetError          => $args->{campaignSharedSetError},
    changeStatusError               => $args->{changeStatusError},
    collectionSizeError             => $args->{collectionSizeError},
    contextError                    => $args->{contextError},
    conversionActionError           => $args->{conversionActionError},
    conversionAdjustmentUploadError => $args->{conversionAdjustmentUploadError},
    conversionUploadError           => $args->{conversionUploadError},
    countryCodeError                => $args->{countryCodeError},
    criterionError                  => $args->{criterionError},
    customInterestError             => $args->{customInterestError},
    customerClientLinkError         => $args->{customerClientLinkError},
    customerError                   => $args->{customerError},
    customerFeedError               => $args->{customerFeedError},
    customerManagerLinkError        => $args->{customerManagerLinkError},
    databaseError                   => $args->{databaseError},
    dateError                       => $args->{dateError},
    dateRangeError                  => $args->{dateRangeError},
    distinctError                   => $args->{distinctError},
    enumError                       => $args->{enumError},
    extensionFeedItemError          => $args->{extensionFeedItemError},
    extensionSettingError           => $args->{extensionSettingError},
    feedAttributeReferenceError     => $args->{feedAttributeReferenceError},
    feedError                       => $args->{feedError},
    feedItemError                   => $args->{feedItemError},
    feedItemTargetError             => $args->{feedItemTargetError},
    feedItemValidationError         => $args->{feedItemValidationError},
    feedMappingError                => $args->{feedMappingError},
    fieldError                      => $args->{fieldError},
    fieldMaskError                  => $args->{fieldMaskError},
    functionError                   => $args->{functionError},
    functionParsingError            => $args->{functionParsingError},
    geoTargetConstantSuggestionError =>
      $args->{geoTargetConstantSuggestionError},
    headerError                     => $args->{headerError},
    idError                         => $args->{idError},
    imageError                      => $args->{imageError},
    internalError                   => $args->{internalError},
    keywordPlanAdGroupError         => $args->{keywordPlanAdGroupError},
    keywordPlanCampaignError        => $args->{keywordPlanCampaignError},
    keywordPlanError                => $args->{keywordPlanError},
    keywordPlanIdeaError            => $args->{keywordPlanIdeaError},
    keywordPlanKeywordError         => $args->{keywordPlanKeywordError},
    keywordPlanNegativeKeywordError => $args->{keywordPlanNegativeKeywordError},
    labelError                      => $args->{labelError},
    languageCodeError               => $args->{languageCodeError},
    listOperationError              => $args->{listOperationError},
    managerLinkError                => $args->{managerLinkError},
    mediaBundleError                => $args->{mediaBundleError},
    mediaFileError                  => $args->{mediaFileError},
    mediaUploadError                => $args->{mediaUploadError},
    multiplierError                 => $args->{multiplierError},
    mutateError                     => $args->{mutateError},
    mutateJobError                  => $args->{mutateJobError},
    newResourceCreationError        => $args->{newResourceCreationError},
    notEmptyError                   => $args->{notEmptyError},
    notWhitelistedError             => $args->{notWhitelistedError},
    nullError                       => $args->{nullError},
    operationAccessDeniedError      => $args->{operationAccessDeniedError},
    operatorError                   => $args->{operatorError},
    partialFailureError             => $args->{partialFailureError},
    policyFindingError              => $args->{policyFindingError},
    policyValidationParameterError  => $args->{policyValidationParameterError},
    policyViolationError            => $args->{policyViolationError},
    queryError                      => $args->{queryError},
    quotaError                      => $args->{quotaError},
    rangeError                      => $args->{rangeError},
    recommendationError             => $args->{recommendationError},
    regionCodeError                 => $args->{regionCodeError},
    requestError                    => $args->{requestError},
    resourceAccessDeniedError       => $args->{resourceAccessDeniedError},
    resourceCountLimitExceededError => $args->{resourceCountLimitExceededError},
    settingError                    => $args->{settingError},
    sharedCriterionError            => $args->{sharedCriterionError},
    sharedSetError                  => $args->{sharedSetError},
    sizeLimitError                  => $args->{sizeLimitError},
    stringFormatError               => $args->{stringFormatError},
    stringLengthError               => $args->{stringLengthError},
    urlFieldError                   => $args->{urlFieldError},
    userListError                   => $args->{userListError},
    youtubeVideoRegistrationError   => $args->{youtubeVideoRegistrationError}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
