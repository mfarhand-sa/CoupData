# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'
source 'https://github.com/CocoaPods/Specs.git'

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
  pod 'BugfenderSDK'
  pod 'HorizonCalendar', '~> 1.16.0'
  pod 'FittedSheets'
  pod 'CountryPickerView'
  pod 'DGCharts'
  pod "KRProgressHUD"


end

target 'CoupDateWatch Watch App' do
  # Specify the platform for watchOS
  platform :watchos, '7.0'

  # Pods for CoupDateWatch (watchOS app)

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

    # Bitcode stripping
    bitcode_strip_path = `xcrun --find bitcode_strip`.chop!
    
    def strip_bitcode_from_framework(bitcode_strip_path, framework_relative_path)
        framework_path = File.join(Dir.pwd, framework_relative_path)
        command = "#{bitcode_strip_path} #{framework_path} -r -o #{framework_path}"
        puts "Stripping bitcode: #{command}"
        system(command)
    end
    
    # Replace this path with the correct path from the find command
    framework_paths = [
        "Pods/BugfenderSDK/BugfenderSDK.xcframework/ios-arm64/BugfenderSDK.framework/BugfenderSDK"
    ]
    
    framework_paths.each do |framework_relative_path|
        strip_bitcode_from_framework(bitcode_strip_path, framework_relative_path)
    end
end

