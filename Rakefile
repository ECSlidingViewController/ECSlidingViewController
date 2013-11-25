desc "Run tests"
task :test do
  system 'xctool -workspace Tests/ECSlidingViewController.xcworkspace -scheme ECSlidingViewController -sdk iphonesimulator -reporter Tests/ao-kiwi-progress test'
  exit($?.exitstatus)
end

namespace :travis do
  task :before_install do
    system 'brew update'
  end

  task :install do
    system 'brew uninstall xctool'
    system 'brew install xctool --HEAD'
    system 'bundle install'
  end

  task :script => 'test'
end
