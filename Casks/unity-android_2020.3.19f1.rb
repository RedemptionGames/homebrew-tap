cask "unity-android_2020.3.19f1" do
  _package_name = 'UnitySetup-Android-Support-for-Editor'

  version "2020.3.19f1,68f137dc9bbe"
  sha256 "d7d7c4aecf75fbefd75e130b843ad4ae5894896b4a0dfee1f7c69faf64669a9f"

  url "https://netstorage.unity3d.com/unity/#{version.after_comma}/MacEditorTargetInstaller/#{_package_name}-#{version.before_comma}.pkg",
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
      FileUtils.move "/Applications/Unity", "/Applications/Unity.temp"
    end

    if File.exist? "/Applications/Unity.#{version.before_comma}"
      FileUtils.move "/Applications/Unity.#{version.before_comma}", '/Applications/Unity'
    end
  end

  postflight do
    if File.exist? '/Applications/Unity'
      FileUtils.move '/Applications/Unity', "/Applications/Unity.#{version.before_comma}"
    end

    if File.exist? '/Applications/Unity.temp'
      FileUtils.move '/Applications/Unity.temp', '/Applications/Unity'
    end
  end

  uninstall quit:    "com.unity3d.UnityEditor5.x",
            pkgutil: "com.unity3d.UnityEditor5.x",
            delete:  "/Applications/Unity.#{version.before_comma}/PlaybackEngines/AndroidPlayer"
end
