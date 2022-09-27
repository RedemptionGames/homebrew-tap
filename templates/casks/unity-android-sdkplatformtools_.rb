cask "unity-android-sdkplatformtools_{{ unity_version }}" do
  version "{{ unity_version }}"
  sha256 "84acbbd2b2ccef159ae3e6f83137e44ad18388ff3cc66bb057c87d761744e595"

  _platformtools_version = '33.0.3'
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
