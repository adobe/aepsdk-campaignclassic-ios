platform :ios, '15.0'
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
  pod 'AEPAssurance'
end

target 'TestAppObjC' do
  campaignclassic_dependencies
  pod 'AEPAssurance'
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |bc|
      bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
