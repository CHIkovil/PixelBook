# Uncomment the next line to define a global platform for your project
 platform :ios, '16.0'

install! 'cocoapods', :warn_for_unused_master_specs_repo => false

def rx_pods
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxGesture'
  pod 'RxKeyboard'
  pod 'RxViewController'
end

target 'BlackBook' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BlackBook
  rx_pods
  pod 'SnapKit'
end
