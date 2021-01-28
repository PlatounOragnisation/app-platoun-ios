source 'https://github.com/CocoaPods/Specs.git'
# source 'https://cdn.cocoapods.org/'

# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

abstract_target 'PlatounAbs' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Performance'
  pod 'Firebase/Auth'
  pod 'GoogleSignIn'
  pod 'Firebase/Messaging'
  pod 'Firebase/Storage'
  pod 'FirebaseUI/Storage'
  pod 'Firebase/Firestore'
  pod 'FirebaseUI/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'Firebase/DynamicLinks'


  # For Marketplace
  pod 'MultiSlider', '~> 1.10.8'
  pod 'Alamofire', '~> 5.1'
  pod 'ImageIOUIKit'

  pod 'netfox', :configurations => ['Debug']
  
  # For View
  pod 'DropDown'
  pod 'PopBounceButton'
  
  target 'Platoun' do
    target 'PlatounTests' do
      inherit! :search_paths
      # Pods for testing
    end

    target 'PlatounUITests' do
      # Pods for testing
    end
  end
  target 'PlatounDev' do
    
  end
end
