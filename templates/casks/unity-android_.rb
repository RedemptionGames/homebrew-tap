cask "unity-android_{{ unity_version }}" do
  _package_name = 'UnitySetup-Android-Support-for-Editor'

  version "{{ unity_version }},{{ unity_version_hash }}"
  sha256 "{{ package_sha }}"

  url "https://download.unity3d.com/download_unity/#{version.after_comma}/MacEditorTargetInstaller/#{_package_name}-#{version.before_comma}.pkg",
      verified: "download.unity3d.com/download_unity/"
  name "Android Build Support"
  desc "Allows building your Unity projects for the Android platform"
  homepage "https://unity.com/products"

  livecheck do
    url "https://public-cdn.cloud.unity3d.com/hub/prod/releases-darwin.json"
    strategy :page_match do |page|
      page.scan(%r{/download_unity/(\h+)/MacEditorInstaller/#{_package_name}-(\d+(?:\.\d+)*[a-z]*\d*)\.pkg}i).map do |match|
        "#{match[1]},#{match[0]}"
      end
    end
  end

  pkg "#{_package_name}-#{version.before_comma}.pkg"

  depends_on cask: "unity_#{version.before_comma}"

  preflight do
    if File.exist? "/Applications/Unity"
      system_command "/bin/mv",
        args: [
          '/Applications/Unity',
          '/Applications/Unity.temp'
        ],
        sudo: true
    end

    if File.exist? "/Applications/Unity.#{version.before_comma}"
      system_command "/bin/mv",
        args: [
          "/Applications/Unity.#{version.before_comma}",
          '/Applications/Unity'
        ],
        sudo: true
    end
  end

  postflight do
    if File.exist? '/Applications/Unity'
      system_command "/bin/mv",
        args: [
          '/Applications/Unity',
          "/Applications/Unity.#{version.before_comma}",
        ],
        sudo: true
    end

    if File.exist? '/Applications/Unity.temp'
      system_command "/bin/mv",
        args: [
          '/Applications/Unity.temp',
          '/Applications/Unity',
        ],
        sudo: true
    end

    set_ownership("/Applications/Unity.#{version.before_comma}", user: 'root', group: 'wheel')

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

  uninstall quit:    "com.unity3d.UnityEditor5.x",
            pkgutil: "com.unity3d.UnityEditor5.x",
            delete:  "/Applications/Unity.#{version.before_comma}/PlaybackEngines/AndroidPlayer"
end
