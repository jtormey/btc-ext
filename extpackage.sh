export BUILD_NAME="btc-ext"

rm -rf build
yarn build
mkdir -p dist
zip -r dist/$BUILD_NAME-$(date +%s).zip build
