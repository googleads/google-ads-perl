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

package Google::Ads::GoogleAds::V11::Errors::ErrorCode;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    accessInvitationError           => $args->{accessInvitationError},
    accountBudgetProposalError      => $args->{accountBudgetProposalError},
    accountLinkError                => $args->{accountLinkError},
    adCustomizerError               => $args->{adCustomizerError},
    adError                         => $args->{adError},
    adGroupAdError                  => $args->{adGroupAdError},
    adGroupBidModifierError         => $args->{adGroupBidModifierError},
    adGroupCriterionCustomizerError => $args->{adGroupCriterionCustomizerError},
    adGroupCriterionError           => $args->{adGroupCriterionError},
    adGroupCustomizerError          => $args->{adGroupCustomizerError},
    adGroupError                    => $args->{adGroupError},
    adGroupFeedError                => $args->{adGroupFeedError},
    adParameterError                => $args->{adParameterError},
    adSharingError                  => $args->{adSharingError},
    adxError                        => $args->{adxError},
    assetError                      => $args->{assetError},
    assetGroupAssetError            => $args->{assetGroupAssetError},
    assetGroupError                 => $args->{assetGroupError},
    assetGroupListingGroupFilterError =>
      $args->{assetGroupListingGroupFilterError},
    assetLinkError                  => $args->{assetLinkError},
    assetSetAssetError              => $args->{assetSetAssetError},
    assetSetError                   => $args->{assetSetError},
    assetSetLinkError               => $args->{assetSetLinkError},
    audienceError                   => $args->{audienceError},
    authenticationError             => $args->{authenticationError},
    authorizationError              => $args->{authorizationError},
    batchJobError                   => $args->{batchJobError},
    biddingError                    => $args->{biddingError},
    biddingStrategyError            => $args->{biddingStrategyError},
    billingSetupError               => $args->{billingSetupError},
    campaignBudgetError             => $args->{campaignBudgetError},
    campaignConversionGoalError     => $args->{campaignConversionGoalError},
    campaignCriterionError          => $args->{campaignCriterionError},
    campaignCustomizerError         => $args->{campaignCustomizerError},
    campaignDraftError              => $args->{campaignDraftError},
    campaignError                   => $args->{campaignError},
    campaignExperimentError         => $args->{campaignExperimentError},
    campaignFeedError               => $args->{campaignFeedError},
    campaignSharedSetError          => $args->{campaignSharedSetError},
    changeEventError                => $args->{changeEventError},
    changeStatusError               => $args->{changeStatusError},
    collectionSizeError             => $args->{collectionSizeError},
    contextError                    => $args->{contextError},
    conversionActionError           => $args->{conversionActionError},
    conversionAdjustmentUploadError => $args->{conversionAdjustmentUploadError},
    conversionCustomVariableError   => $args->{conversionCustomVariableError},
    conversionGoalCampaignConfigError =>
      $args->{conversionGoalCampaignConfigError},
    conversionUploadError            => $args->{conversionUploadError},
    conversionValueRuleError         => $args->{conversionValueRuleError},
    conversionValueRuleSetError      => $args->{conversionValueRuleSetError},
    countryCodeError                 => $args->{countryCodeError},
    criterionError                   => $args->{criterionError},
    currencyCodeError                => $args->{currencyCodeError},
    customAudienceError              => $args->{customAudienceError},
    customConversionGoalError        => $args->{customConversionGoalError},
    customInterestError              => $args->{customInterestError},
    customerClientLinkError          => $args->{customerClientLinkError},
    customerCustomizerError          => $args->{customerCustomizerError},
    customerError                    => $args->{customerError},
    customerFeedError                => $args->{customerFeedError},
    customerManagerLinkError         => $args->{customerManagerLinkError},
    customerUserAccessError          => $args->{customerUserAccessError},
    customizerAttributeError         => $args->{customizerAttributeError},
    databaseError                    => $args->{databaseError},
    dateError                        => $args->{dateError},
    dateRangeError                   => $args->{dateRangeError},
    distinctError                    => $args->{distinctError},
    enumError                        => $args->{enumError},
    experimentArmError               => $args->{experimentArmError},
    experimentError                  => $args->{experimentError},
    extensionFeedItemError           => $args->{extensionFeedItemError},
    extensionSettingError            => $args->{extensionSettingError},
    feedAttributeReferenceError      => $args->{feedAttributeReferenceError},
    feedError                        => $args->{feedError},
    feedItemError                    => $args->{feedItemError},
    feedItemSetError                 => $args->{feedItemSetError},
    feedItemSetLinkError             => $args->{feedItemSetLinkError},
    feedItemTargetError              => $args->{feedItemTargetError},
    feedItemValidationError          => $args->{feedItemValidationError},
    feedMappingError                 => $args->{feedMappingError},
    fieldError                       => $args->{fieldError},
    fieldMaskError                   => $args->{fieldMaskError},
    functionError                    => $args->{functionError},
    functionParsingError             => $args->{functionParsingError},
    geoTargetConstantSuggestionError =>
      $args->{geoTargetConstantSuggestionError},
    headerError                     => $args->{headerError},
    idError                         => $args->{idError},
    imageError                      => $args->{imageError},
    internalError                   => $args->{internalError},
    invoiceError                    => $args->{invoiceError},
    keywordPlanAdGroupError         => $args->{keywordPlanAdGroupError},
    keywordPlanAdGroupKeywordError  => $args->{keywordPlanAdGroupKeywordError},
    keywordPlanCampaignError        => $args->{keywordPlanCampaignError},
    keywordPlanCampaignKeywordError => $args->{keywordPlanCampaignKeywordError},
    keywordPlanError                => $args->{keywordPlanError},
    keywordPlanIdeaError            => $args->{keywordPlanIdeaError},
    labelError                      => $args->{labelError},
    languageCodeError               => $args->{languageCodeError},
    listOperationError              => $args->{listOperationError},
    managerLinkError                => $args->{managerLinkError},
    mediaBundleError                => $args->{mediaBundleError},
    mediaFileError                  => $args->{mediaFileError},
    mediaUploadError                => $args->{mediaUploadError},
    merchantCenterError             => $args->{merchantCenterError},
    multiplierError                 => $args->{multiplierError},
    mutateError                     => $args->{mutateError},
    newResourceCreationError        => $args->{newResourceCreationError},
    notAllowlistedError             => $args->{notAllowlistedError},
    notEmptyError                   => $args->{notEmptyError},
    nullError                       => $args->{nullError},
    offlineUserDataJobError         => $args->{offlineUserDataJobError},
    operationAccessDeniedError      => $args->{operationAccessDeniedError},
    operatorError                   => $args->{operatorError},
    partialFailureError             => $args->{partialFailureError},
    paymentsAccountError            => $args->{paymentsAccountError},
    policyFindingError              => $args->{policyFindingError},
    policyValidationParameterError  => $args->{policyValidationParameterError},
    policyViolationError            => $args->{policyViolationError},
    queryError                      => $args->{queryError},
    quotaError                      => $args->{quotaError},
    rangeError                      => $args->{rangeError},
    reachPlanError                  => $args->{reachPlanError},
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
    thirdPartyAppAnalyticsLinkError => $args->{thirdPartyAppAnalyticsLinkError},
    timeZoneError                   => $args->{timeZoneError},
    urlFieldError                   => $args->{urlFieldError},
    userDataError                   => $args->{userDataError},
    userListError                   => $args->{userListError},
    youtubeVideoRegistrationError   => $args->{youtubeVideoRegistrationError}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
