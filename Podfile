platform :ios, '10.0'
use_frameworks!

workspace 'AEPCampaignClassic'
project 'AEPCampaignClassic.xcodeproj'

pod 'SwiftLint', '0.44.0'

def campaignclassic_dependencies
   pod 'AEPCore'
   pod 'AEPServices'
   pod 'AEPLifecycle'
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
  pod 'AEPAssurance'
end

target 'TestAppObjC' do
  campaignclassic_dependencies
  pod 'AEPAssurance'
end
