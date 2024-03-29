cask "unity-android-ndk_2021.3.8f1" do
  version "2021.3.8f1"
  sha256 "5851115c6fc4cce26bc320295b52da240665d7ff89bda2f5d5af1887582f5c48"

  url "https://dl.google.com/android/repository/android-ndk-r21d-darwin-x86_64.zip"
  name "Android NDK"
  desc "Android NDK for use specifically with Unity"
  homepage "https://unity.com/products"

  _ndk_path = "/Applications/Unity.#{version}/PlaybackEngines/AndroidPlayer/NDK"
  installer script: {
    executable: "/bin/cp",
    args:       ["-pr", "#{caskroom_path}/#{version}/android-ndk-r21d/", "#{_ndk_path}"],
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
