#!/bin/bash

# Newgrounds
mv newgrounds/advanced-invasion.html newgrounds/index.html
zip distribute/advanced-invasion-newgrounds.zip newgrounds/*

# Game Jolt
mv gamejolt/html5/advanced-invasion.html gamejolt/html5/index.html
zip distribute/advanced-invasion-gj-html5.zip gamejolt/html5/*
zip distribute/advanced-invasion-gj-linux32.zip gamejolt/linux32/*
zip distribute/advanced-invasion-gj-linux64.zip gamejolt/linux64/*
zip distribute/advanced-invasion-gj-win32.zip gamejolt/win32/*
zip distribute/advanced-invasion-gj-win64.zip gamejolt/win64/*
cp gamejolt/macos/advanced-invasion.zip distribute/advanced-invasion-gj-macos.zip

# Global
mv global/html5/advanced-invasion.html global/html5/index.html
zip distribute/advanced-invasion-html5.zip global/html5/*
zip distribute/advanced-invasion-linux32.zip global/linux32/*
zip distribute/advanced-invasion-linux64.zip global/linux64/*
zip distribute/advanced-invasion-macos.zip global/macos/*
zip distribute/advanced-invasion-win32.zip global/win32/*
zip distribute/advanced-invasion-win64.zip global/win64/*
cp global/macos/advanced-invasion.zip distribute/advanced-invasion-macos.zip
