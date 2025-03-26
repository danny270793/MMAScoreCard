const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const reactBuildDir = path.join(__dirname, '..', '..', 'web', 'dist');
const cordovaWWWDir = path.join(__dirname, '..', 'www');

function main() {
  try {
    console.log(`cordovaWWWDir=${cordovaWWWDir}`)
    if(fs.existsSync(cordovaWWWDir)) {
        console.log('delete already existing folder')
        fs.rmSync(cordovaWWWDir, { recursive: true });
    }

    console.log('creating cordova folder')
    fs.mkdirSync(cordovaWWWDir)

    console.log('copying files')
    execSync(`cp -r ${reactBuildDir}/* ${cordovaWWWDir}`);

    execSync(`sed -i '' 's|</title>|</title><script type="text/javascript" src="cordova.js"></script>|' ${path.join(cordovaWWWDir, 'index.html')}`);
    console.log('cordova ready')
  } catch (error) {
    console.error('Error copying React build files to Cordova:', error)
  }
}

main()
