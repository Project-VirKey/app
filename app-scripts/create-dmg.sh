# sudo bash ./create-dmg.sh
cp -r "../build/macos/Build/Products/Release/VirKey.app" ./
rm -f VirKey.dmg
create-dmg \
  --volicon "VIK_Icon.icns" \
  --hide-extension "VirKey.app" \
  --window-size 575 380 \
  --background "VIK_App_DMG-Backgroundimage.png" \
  --icon "VirKey.app" 140 200 \
  --icon-size 100 \
  --app-drop-link 433 200 \
  "VirKey.dmg" \
  "VirKey.app"