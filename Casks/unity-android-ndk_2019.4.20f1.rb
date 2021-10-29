cask "unity-android-ndk_2019.4.20f1" do
  version "2019.4.20f1"
  sha256 "04159ade2fc5c7d055248cf65664039b8596f4b9ee3fbc44a9bf2ce2ee28d95d"

  url "https://dl.google.com/android/repository/android-ndk-r19-darwin-x86_64.zip"
  name "Android NDK"
  desc "Android NDK for use specifically with Unity"
  homepage "https://unity.com/products"

  _ndk_path = "/Applications/Unity.#{version}/PlaybackEngines/AndroidPlayer/NDK"
  installer script: {
    executable: "/bin/cp",
    args:       ["-pr", "#{caskroom_path}/#{version}/android-ndk-r19/", "#{_ndk_path}"],
    sudo:       true,
  }

  preflight do
    system '/usr/bin/sudo', '-E', '--', 'mkdir', "#{_ndk_path}"
  end

  postflight do
    set_ownership("#{_ndk_path}", user: 'root', group: 'wheel')

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

  depends_on cask: "unity-android_#{version.before_comma}"
end
