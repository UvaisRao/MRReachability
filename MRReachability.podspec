Pod::Spec.new do |s|
  s.name         = "MRReachability"
  s.version      = "1.0.0"
  s.summary      = "NWPathMonitor-backed Reachability with legacy-like API."
  s.description  = <<-DESC
  MRReachability wraps Apple's NWPathMonitor to expose a simple 3-state
  (wifi/cellular/unavailable) surface, with legacy-style callbacks and
  NotificationCenter integration.
  DESC
  s.homepage     = "https://github.com/UvaisRao/MRReachability"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Uvais Khan" => "rao.khan@mrsool.in" }
  s.source       = { :git => "https://github.com/UvaisRao/MRReachability.git", :tag => s.version.to_s }

  s.swift_versions = ["5.7", "5.8", "5.9", "6.0"]
  s.platform     = :ios, "12.0"
  s.ios.deployment_target = "12.0"

  s.source_files = "Sources/MRReachability/**/*.swift"
  s.frameworks   = ["Network", "SystemConfiguration", "UIKit"]

  # If you also want tvOS/watchOS/macOS, add:
  s.tvos.deployment_target   = "12.0"
  s.watchos.deployment_target= "5.0"
  s.osx.deployment_target    = "10.14"
end
