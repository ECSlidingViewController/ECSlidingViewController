desc "Run tests"
task :test do
  system 'xcodebuild -workspace Tests/ECSlidingViewController.xcworkspace -scheme ECSlidingViewController -sdk iphonesimulator test'
  exit($?.exitstatus)
end

namespace :travis do
  task :script => 'test'
end
