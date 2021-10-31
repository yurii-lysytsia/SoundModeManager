fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### update_version
```
fastlane update_version
```
Update project version and push all changes after
### build_and_test
```
fastlane build_and_test
```
Build project and run unit tests
### prepare_to_deploy
```
fastlane prepare_to_deploy
```
Get Xcode project version, add git tag and push changes to trunk

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
