# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'CoupDate' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CoupDate
  pod 'Firebase/Firestore'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Functions'
  pod 'Firebase/Messaging'
  pod 'lottie-ios'
  pod 'GoogleSignIn'
  pod 'SwiftMessages'
  pod 'NotificationBannerSwift'
  pod 'Typist'
  pod 'BugfenderSDK', '~> 1.10'
  pod 'HorizonCalendar', '~> 1.16.0'
  pod 'CardTabBar'

end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
        end
    end
end
