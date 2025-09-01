Pod::Spec.new do |s|
  s.name         = "MRReachability"
  s.version      = "1.0.1"   
  s.summary      = "NWPathMonitor-backed reachability with a legacy-style API."
  s.description  = <<-DESC
  MRReachability wraps Apple's NWPathMonitor to provide a simple 3-state
  (wifi/cellular/unavailable) API with legacy-style callbacks & notifications.
  DESC

  s.homepage     = "https://github.com/UvaisRao/MRReachability"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Uvais Khan" => "rao.khan@mrsool.in" }

  s.source       = { :git => "https://github.com/UvaisRao/MRReachability.git",
                     :tag => s.version.to_s }   # ← uses "1.0.1"

  s.swift_versions = ["5.7", "5.8", "5.9", "6.0"]

  s.platform     = :ios, "12.0"
  s.ios.deployment_target      = "12.0"
  s.tvos.deployment_target     = "12.0"
  s.watchos.deployment_target  = "5.0"
  s.osx.deployment_target      = "10.14"

  s.source_files = "Sources/MRReachability/**/*.swift"
  s.frameworks   = ["Network", "SystemConfiguration", "UIKit"]
end
