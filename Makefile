GODOT_PATH := godot


all: linux-x86_64 linux-x86_32 linux-arm64 windows-64 windows-32 windows-arm64 macos-universal

linux-x86_64:
	mkdir -p build/linux-x86_64; $(GODOT_PATH) --headless --export-release linux-x86_64 "build/linux-x86_64/advanced-invasion.x86_64"

linux-x86_32:
	mkdir -p build/linux-x86_32; $(GODOT_PATH) --headless --export-release linux-x86_32 "build/linux-x86_32/advanced-invasion.x86_32"

linux-arm64:
	mkdir -p build/linux-arm64; $(GODOT_PATH) --headless --export-release linux-arm64 "build/linux-arm64/advanced-invasion.arm64"

windows-64:
	mkdir -p build/windows-64; $(GODOT_PATH) --headless --export-release windows-64 "build/windows-64/advanced-invasion.exe"

windows-32:
	mkdir -p build/windows-32; $(GODOT_PATH) --headless --export-release windows-32 "build/windows-32/advanced-invasion.exe"

windows-arm64:
	mkdir -p build/windows-arm64; $(GODOT_PATH) --headless --export-release windows-arm64 "build/windows-arm64/advanced-invasion.exe"

macos-universal:
	mkdir -p build/macos-universal; $(GODOT_PATH) --headless --export-release macos-universal "build/macos-universal/advanced-invasion.app"
