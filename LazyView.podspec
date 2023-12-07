#
# Be sure to run `pod lib lint LazyView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LazyView'
  s.version          = '0.2.0'
  s.summary          = 'A lightweight wrapper for lazily initializing UIViews'
  s.description      = 'A lightweight wrapper for lazily initializing UIViews that can improve rendering speed for your complex views and screens. Follow an example in the README.'
  s.swift_versions   = '5.0'
  s.homepage         = 'https://github.com/qstrnd/LazyView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andy' => 'a.iakovlev@proton.me' }
  s.source           = { :git => 'https://github.com/qstrnd/LazyView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.source_files = 'LazyView/Sources/**/*'
end
