cask "unity-android-buildtools_2020.3.12f1" do
  version "2020.3.12f1"
  sha256 "b87ab894b33c160e56869dab70165a3d5e8ef923806ce3d31774a102ce4b2ceb"

  _buildtools_version = '28.0.3'
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
