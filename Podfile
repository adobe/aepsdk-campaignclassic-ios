platform :ios, '12.0'
use_frameworks!

workspace 'AEPCampaignClassic'
project 'AEPCampaignClassic.xcodeproj'

pod 'SwiftLint', '0.52.0'

def campaignclassic_dependencies
   pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
   pod 'AEPServices', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
   pod 'AEPRulesEngine', :git => 'https://github.com/adobe/aepsdk-rulesengine-ios.git', :branch => 'dev-v5.0.0'
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
#  pod 'AEPAssurance', '~> 4.0'
end

target 'TestAppObjC' do
  campaignclassic_dependencies
#  pod 'AEPAssurance', '~> 4.0'
end
