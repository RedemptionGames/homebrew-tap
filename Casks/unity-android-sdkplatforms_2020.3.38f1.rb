cask "unity-android-sdkplatforms_2020.3.38f1" do
  version "2020.3.38f1"
  sha256 "8452dbbf9668a428abb243c4f02a943b7aa83af3cca627629a15c4c09f28e7bd"

  _platforms_version = '31_r01'
  url "https://dl.google.com/android/repository/platform-#{_platforms_version}.zip"
  name "Android SDK Build Tools #{_platforms_version}"
  desc "Android SDK Build Tools for use specifically with Unity"
  homepage "https://unity.com/products"

  _platforms_path = "/Applications/Unity.#{version}/PlaybackEngines/AndroidPlayer/SDK/platforms/android-31"
  installer script: {
    executable: "/bin/cp",
    args:       ["-pr", "#{caskroom_path}/#{version}/android-12/", "#{_platforms_path}"],
    sudo:       true,
  }

  preflight do
    system '/usr/bin/sudo', '-E', '--', 'mkdir', '-p', "#{_platforms_path}"
  end

  postflight do
    set_ownership("#{_platforms_path}", user: 'root', group: 'wheel')

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
