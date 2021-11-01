cask "unity-android-openjdk_2020.3.12f1" do
  version "2020.3.12f1"
  sha256 "01c8518f34d083b6adf57f1a3a7cff76e78dc0a2523b6332d10a0f30fcb8d308"

  url "http://download.unity3d.com/download_unity/open-jdk/open-jdk-mac-x64/jdk8u172-b11_4be8440cc514099cfe1b50cbc74128f6955cd90fd5afe15ea7be60f832de67b4.zip"
  name "OpenJDK for Android Build Support"
  desc "OpenJDK specifically for use with Unity"
  homepage "https://unity.com/products"

  _openjdk_path = "/Applications/Unity.#{version}/PlaybackEngines/AndroidPlayer/OpenJDK"
  installer script: {
    executable: "/bin/cp",
    args:       ["-pr", "#{caskroom_path}/#{version}/", "#{_openjdk_path}"],
    sudo:       true,
  }

  preflight do
    system '/usr/bin/sudo', '-E', '--', 'mkdir', "#{_openjdk_path}"
  end

  postflight do
    set_ownership("#{_openjdk_path}", user: 'root', group: 'wheel')

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
