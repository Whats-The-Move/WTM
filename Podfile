# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'WTM' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WTM
pod 'Firebase/Analytics' 
pod 'Firebase/Auth' 
pod 'Firebase/Database'
pod 'Firebase/Core'
pod 'Firebase/Storage'
pod 'GoogleSignIn'
pod 'Firebase/Firestore'
pod 'Kingfisher'
pod 'FSCalendar'
pod 'Firebase/Messaging'


  target 'WTMTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'WTMUITests' do
    # Pods for testing
  end

end
post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
               end
          end
   end
end