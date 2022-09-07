cask "unity-android-buildtools_2020.3.38f1" do
  version "2020.3.38f1"
  sha256 "368c9a617abefcd16d9fb5fe94c9c10466335ad5d5ff02d3e76ae5098ed060bd"

  _buildtools_version = '29.0.3'
  url "https://dl.google.com/android/repository/build-tools_r#{_buildtools_version}-macosx.zip"
  name "Android SDK Build Tools #{_buildtools_version}"
  desc "Android SDK Build Tools for use specifically with Unity"
  homepage "https://unity.com/products"

  _buildtools_path = "/Applications/Unity.#{version}/PlaybackEngines/AndroidPlayer/SDK/build-tools/#{_buildtools_version}"
  installer script: {
    executable: "/bin/cp",
    args:       ["-pr", "#{caskroom_path}/#{version}/android-9/", "#{_buildtools_path}"],
    sudo:       true,
  }

  preflight do
    system '/usr/bin/sudo', '-E', '--', 'mkdir', '-p', "#{_buildtools_path}"
  end

  postflight do
    set_ownership("#{_buildtools_path}", user: 'root', group: 'wheel')

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
