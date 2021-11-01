cask "unity-android-sdkndktools_2020.3.12f1" do
  version "2020.3.12f1"
  sha256 "ecb29358bc0f13d7c2fa0f9290135a5b608e38434aad9bf7067d0252c160853e"

  url "https://dl.google.com/android/repository/sdk-tools-darwin-4333796.zip"
  name "Android SDK & NDK Tools"
  desc "Android SDK & NDK Tools for use specifically with Unity"
  homepage "https://unity.com/products"

  _sdkndktools_path = "/Applications/Unity.#{version}/PlaybackEngines/AndroidPlayer/SDK/"
  installer script: {
    executable: "/bin/cp",
    args:       ["-pr", "#{caskroom_path}/#{version}/", "#{_sdkndktools_path}"],
    sudo:       true,
  }

  preflight do
    system '/usr/bin/sudo', '-E', '--', 'mkdir', "#{_sdkndktools_path}"
  end

  postflight do
    set_ownership("#{_sdkndktools_path}", user: 'root', group: 'wheel')

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
