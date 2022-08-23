cask "unity_2021.3.8f1" do
  version "2021.3.8f1,b30333d56e81"
  sha256 "8cb5bbc4e8af2c4c3638e7e4289b18d55badb917dab9af41f049afe5eec69a07"

  url "https://download.unity3d.com/download_unity/#{version.after_comma}/MacEditorInstaller/Unity-#{version.before_comma}.pkg",
      verified: "download.unity3d.com/download_unity/"
  name "Unity Editor"
  desc "Platform for 3D content"
  homepage "https://unity.com/products"

  livecheck do
    url "https://public-cdn.cloud.unity3d.com/hub/prod/releases-darwin.json"
    strategy :page_match do |page|
      page.scan(%r{/download_unity/(\h+)/MacEditorInstaller/Unity-(\d+(?:\.\d+)*[a-z]*\d*)\.pkg}i).map do |match|
        "#{match[1]},#{match[0]}"
      end
    end
  end

  pkg "Unity-#{version.before_comma}.pkg"

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

    system_command "/bin/rm",
      args: [
        "-f",
        "/Applications/Unity.#{version.before_comma}/Unity.app/Contents/Documentation"
      ],
      sudo: true
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
            delete:  "/Applications/Unity.#{version.before_comma}"
end
