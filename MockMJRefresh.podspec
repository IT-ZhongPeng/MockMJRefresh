#
# Be sure to run `pod lib lint MockMJRefresh.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'MockMJRefresh'
    s.version          = '0.1.0'
    s.summary          = 'MJRefreshOC版改写成Swift版本'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    TODO: MJRefresh OC 代码苦力搬运
    
    s.homepage         = 'https://github.com/zhaozp/MockMJRefresh'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'zhaozp' => '2825605856@qq.com' }
    s.source           = { :git => 'https://github.com/zhaozp/MockMJRefresh.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '8.0'
    
    s.source_files = 'MockMJRefresh/Classes/**/*'
    s.resource = 'MockMJRefresh/Assets/*.bundle'
    s.frameworks = 'UIKit', 'Foundation'
    s.require_arc = true
    #  s.resource_bundles = {
    #    'MockMJRefresh' => ['MockMJRefresh/Assets/*']
    #}
   
    # s.public_header_files = 'Pod/Classes/**/*.h'
    
    # s.dependency 'AFNetworking', '~> 2.3'
end
