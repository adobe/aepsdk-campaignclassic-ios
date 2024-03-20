platform :ios, '12.0'
use_frameworks!

workspace 'AEPCampaignClassic'
project 'AEPCampaignClassic.xcodeproj'

pod 'SwiftLint', '0.52.0'

def campaignclassic_dependencies
   pod 'AEPCore'
   pod 'AEPServices'
   pod 'AEPRulesEngine'
end

target 'AEPCampaignClassic' do
   campaignclassic_dependencies
end

target 'FunctionalTests' do
  campaignclassic_dependencies
end

target 'UnitTests' do
  campaignclassic_dependencies
end

target 'TestApp' do
  campaignclassic_dependencies
  pod 'AEPAssurance', :git => 'https://github.com/adobe/aepsdk-assurance-ios.git', :branch => 'staging'
end

target 'TestAppObjC' do
  campaignclassic_dependencies
  pod 'AEPAssurance', :git => 'https://github.com/adobe/aepsdk-assurance-ios.git', :branch => 'staging'
end
