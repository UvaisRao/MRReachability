Pod::Spec.new do |s|
  s.name             = "MRReachability"
  s.version          = "1.0.0"
  s.summary          = "NWPathMonitor-backed reachability with legacy-style API."
  s.description      = <<-DESC
A tiny, UIKit-friendly reachability wrapper on top of NWPathMonitor,
exposing classic callbacks and a 3-state connection enum.
  DESC

  s.homepage         = "https://github.com/<your-user>/MRReachability"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Uvais Khan" => "you@example.com" }

  s.source           = { :git => "https://github.com/<your-user>/MRReachability.git",
                         :tag => s.version.to_s }

  s.ios.deployment_target  = "12.0"
  s.tvos.deployment_target = "12.0"
  s.swift_version          = "5.9"

  s.source_files = "Sources/MRReachability/**/*.{swift}"
end
