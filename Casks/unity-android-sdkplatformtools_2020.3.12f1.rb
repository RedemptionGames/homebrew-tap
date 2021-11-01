cask "unity-android-sdkplatformtools_2020.3.12f1" do
  version "2020.3.12f1"
  sha256 "3bc833ae3f4bd831af03811f2d1be540c2eb2eb9a17de9398b0a06dc5af6fa84"

  _platformtools_version = '28.0.1'
  url "https://dl.google.com/android/repository/platform-tools_r#{_platformtools_version}-darwin.zip"
  name "Android SDK Platform Tools #{_platformtools_version}"
  desc "Android SDK Platform Tools for use specifically with Unity"
  homepage "https://unity.com/products"

  _platformtools_path = "/Applications/Unity.#{version}/PlaybackEngines/AndroidPlayer/SDK"
  installer script: {
    executable: "/bin/cp",
    args:       ["-pr", "#{caskroom_path}/#{version}/", "#{_platformtools_path}"],
    sudo:       true,
  }

  postflight do
    set_ownership("#{_platformtools_path}", user: 'root', group: 'wheel')

    system_command "/bin/chmod",
      args: [
        '-R',
        'o+rX',
        "/Applications/Unity.#{version.before_comma}"
      ],
      sudo: true
    system_command "/usr/bin/xattr",
      args: [
        '-rd',
        'com.apple.quarantine',
        "/Applications/Unity.#{version.before_comma}"
      ],
      sudo: true
  end

  depends_on cask: "unity-android-sdkndktools_#{version.before_comma}"
end
