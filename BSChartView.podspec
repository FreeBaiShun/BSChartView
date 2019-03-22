Pod::Spec.new do |s|
s.name         = "BSChartView"
s.version      = "0.1.0"
s.summary      = "A short description of BSChartView."
s.description  = <<-DESC
折线图，柱状图，圆饼图工具
DESC
s.homepage     = "https://github.com/FreeBaiShun"
s.license      = "MIT"
s.author             = { "FreeBaiShun" => "851083075@qq.com" }
s.platform     = :ios, "8.0"
s.requires_arc = true
s.source       = { :git => "https://github.com/FreeBaiShun/BSChartView.git", :tag => "#{s.version}" }

s.subspec 'Core' do |s1|
s1.source_files  = "BSChartView", "BSChartView/*.{h,m}"

end
end
