cask "test-cask_redemption" do
  version "2021.3.8f1"
  sha256 "be65592c9219757468065fe5945ac5500fbd84fcc069d7b13b077c0d663642ef"

  _buildtools_version = '30.0.2'
  url "https://dl.google.com/android/repository/5a6ceea22103d8dec989aefcef309949c0c42f1d.build-tools_r#{_buildtools_version}-macosx.zip"
  name "Android SDK Build Tools #{_buildtools_version}"
  desc "Android SDK Build Tools for use specifically with Unity"
  homepage "https://unity.com/products"

  _buildtools_path = "/Applications/Unity.#{version}/PlaybackEngines/AndroidPlayer/SDK/build-tools/#{_buildtools_version}"
  installer script: {
    executable: "/usr/bin/whoami"
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
end
