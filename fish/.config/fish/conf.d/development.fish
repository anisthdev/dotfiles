set ANDROID_SDK_HOME $HOME/.sdks/android
set ANDROID_AVD_HOME $ANDROID_SDK_HOME/avd
fish_add_path $ANDROID_SDK_HOME/cmdline-tools/latest/bin
fish_add_path $ANDROID_SDK_HOME/platform-tools
fish_add_path $ANDROID_SDK_HOME/emulator

set -gx GOPATH $HOME/.local/share/go
fish_add_path $GOPATH/bin
