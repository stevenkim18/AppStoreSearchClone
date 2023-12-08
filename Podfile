# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

post_install do |installer|
  installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
             end
        end
 end
end

platform :ios, '16.0'

target 'AppStoreClone' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for AppStoreClone
  pod 'ReactorKit'

	# Reactive
	pod 'RxSwift'
	pod 'RxCocoa'
	pod 'RxDataSources'
	pod 'RxViewController'
	pod 'RxOptional'
	pod 'RxSwiftExt'
	pod 'ReusableKit'

  pod 'SnapKit'
	pod 'Then'
  
  pod 'Kingfisher'

  target 'AppStoreCloneTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'AppStoreCloneUITests' do
    # Pods for testing
  end

end
