#!/bin/zsh

# Format: "AVD_NAME|DEVICE_ID|FRIENDLY_NAME"
# Note: For iOS, AVD_NAME and DEVICE_ID are usually the same UUID.
DEVICES=(
    "Pixel_9|emulator-5554|Pixel 9"
    "Pixel_Tablet|emulator-5556|Pixel Tablet"
    "67EEA910-1808-4B2D-B78E-9ADF267AF477|67EEA910-1808-4B2D-B78E-9ADF267AF477|iPhone 14 Plus"
    "A4796C80-6E60-4329-9127-85069D75DCC7|A4796C80-6E60-4329-9127-85069D75DCC7|iPad Pro 13-inch (M4)"
)

for ENTRY in "${DEVICES[@]}"
do
    # Extract variables
    AVD_NAME=${ENTRY%%|*}
    REMAINDER=${ENTRY#*|}
    ID=${REMAINDER%%|*}
    NAME=${REMAINDER##*|}

    echo "----------------------------------------------------"
    echo "🏗️  Preparing: $NAME ($ID)"
    echo "----------------------------------------------------"

    # 1. BOOTING
    if [[ "$ID" == "emulator-"* ]]; then
        echo "🤖 Starting Android ($AVD_NAME) in HEADLESS mode..."
        # -no-window is the key for headless Android
        emulator -avd "$AVD_NAME" -no-window -no-audio -no-snapshot-load > /dev/null 2>&1 &
        
        # Wait for the specific ID to appear in adb
        echo "Waiting for ADB connection..."
        adb -s "$ID" wait-for-device
        
        # Ensure the Android "boot completed" flag is set
        while [ "`adb -s \"$ID\" shell getprop sys.boot_completed | tr -d '\r' `" != "1" ] ; do 
            sleep 2
        done
        echo "Android Boot Complete."
    else
        echo "🍎 Booting iOS Simulator ($ID) in background..."
        # iOS 'boot' is natively headless unless you run 'open -a Simulator'
        xcrun simctl boot "$ID"
        sleep 10
        echo "iOS Simulator Ready."
    fi

    # 2. RUNNING THE TEST
    echo "🚀 Running Flutter Drive..."
    flutter drive \
      --driver=test_driver/integration_driver.dart \
      --target=integration_test/app_test.dart \
      -d "$ID" \
      --dart-define-from-file=.env \
      --dart-define=DEVICE_NAME="$NAME"

    TEST_RESULT=$?

    # 3. SHUTTING DOWN (To free up RAM)
    echo "🧹 Cleaning up $NAME..."
    if [[ "$ID" == "emulator-"* ]]; then
        adb -s "$ID" emu kill > /dev/null 2>&1
    else
        xcrun simctl shutdown "$ID"
    fi

    if [ $TEST_RESULT -ne 0 ]; then
        echo "❌ Tests FAILED on $NAME. Stopping suite."
        exit 1
    fi

    echo "✅ Finished $NAME."
    sleep 3 # Small breather for the OS
done

echo "----------------------------------------------------"
echo "🏁 ALL TESTS PASSED SUCCESSFULLY"
echo "----------------------------------------------------"
