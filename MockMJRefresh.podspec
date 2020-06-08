
Pod::Spec.new do |s|
    s.name             = 'MockMJRefresh'
    s.version          = '0.1.0'
    s.summary          = 'MJRefreshOC版改写成Swift版本'
    s.description      =  '刷新控件'
    s.homepage         = 'https://github.com/IT-ZhongPeng/MockMJRefresh.git'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'zhaozp' => '2825605856@qq.com' }
    s.source           = { :git => 'https://github.com/IT-ZhongPeng/MockMJRefresh.git', :tag => s.version.to_s }
    s.swift_version = '5.0'
    s.source_files = 'MockMJRefresh/Classes/**/*'
    s.resource = 'MockMJRefresh/Assets/*.bundle'
    s.frameworks = 'UIKit', 'Foundation'
    s.requires_arc = true
   
end
