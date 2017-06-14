source 'https://github.com/CocoaPods/Specs.git'
platform:ios,'8.0'

use_frameworks!

target 'TravelEasy' do
pod 'TZStackView','1.2.0'
pod 'Alamofire'
pod 'MBProgressHUD'
pod 'JLToast'
pod 'UIViewController+NavigationBar'
pod 'SwiftyJSON','2.4.0'
pod 'PopupDialog'
pod 'XCGLogger','3.6.0'
pod 'IQKeyboardManagerSwift','4.0.4'
pod 'MJRefresh'
#pod 'TabPageViewController'
end

#post_install do |installer|
#    installer.pods_project.build_configurations.each do |config|
#        # Configure Pod targets for Xcode 8 compatibility
#        config.build_settings['SWIFT_VERSION'] = '2.3'
#        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = 'YOURTEAMID/'
#        config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
#    end
#end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
 
