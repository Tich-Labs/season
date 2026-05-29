#!/usr/bin/env python3
"""Regenerate SeasonApp.xcodeproj with fresh UUIDs."""
import os, shutil, subprocess, sys

def uu():
    return subprocess.check_output(['uuidgen']).decode().strip().lower().replace('-', '')[:24]

P = {
    'APP': uu(), 'PRJ': uu(), 'MGRP': uu(), 'PGRP': uu(),
    'TGT': uu(), 'SRC': uu(), 'FWK': uu(), 'RSC': uu(),
    'SPM': uu(), 'SPMP': uu(),
    'SYNC': uu(), 'SYNCE': uu(), 'BF': uu(),
    'DPROJ': uu(), 'RPROJ': uu(),
    'DTGT': uu(), 'RTGT': uu(),
    'PCL': uu(), 'TCL': uu(),
}

xcodeproj = "SeasonApp.xcodeproj"
if os.path.exists(xcodeproj):
    shutil.rmtree(xcodeproj)

os.makedirs(f"{xcodeproj}/project.xcworkspace/xcshareddata")
os.makedirs(f"{xcodeproj}/xcshareddata/xcschemes")

# project.pbxproj
PBXPROJ = f'''// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{}};
	objectVersion = 70;
	objects = {{

/* Begin PBXBuildFile section */
		{P["BF"]} /* HotwireNative in Frameworks */ = {{isa = PBXBuildFile; productRef = {P["SPMP"]} /* HotwireNative */; }};
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		{P["APP"]} /* SeasonApp.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = SeasonApp.app; sourceTree = BUILT_PRODUCTS_DIR; }};
/* End PBXFileReference section */

/* Begin PBXFileSystemSynchronizedBuildFileExceptionSet section */
		{P["SYNCE"]} /* PBXFileSystemSynchronizedBuildFileExceptionSet */ = {{
			isa = PBXFileSystemSynchronizedBuildFileExceptionSet;
			membershipExceptions = (Info.plist,);
			target = {P["TGT"]} /* SeasonApp */;
		}};
/* End PBXFileSystemSynchronizedBuildFileExceptionSet section */

/* Begin PBXFileSystemSynchronizedRootGroup section */
		{P["SYNC"]} /* SeasonApp */ = {{isa = PBXFileSystemSynchronizedRootGroup; exceptions = ({P["SYNCE"]} /* PBXFileSystemSynchronizedBuildFileExceptionSet */,); explicitFileTypes = {{}}; explicitFolders = (); path = SeasonApp; sourceTree = "<group>"; }};
/* End PBXFileSystemSynchronizedRootGroup section */

/* Begin PBXFrameworksBuildPhase section */
		{P["FWK"]} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = ({P["BF"]} /* HotwireNative in Frameworks */,);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		{P["MGRP"]} = {{
			isa = PBXGroup;
			children = ({P["SYNC"]} /* SeasonApp */, {P["PGRP"]} /* Products */,);
			sourceTree = "<group>";
		}};
		{P["PGRP"]} /* Products */ = {{
			isa = PBXGroup;
			children = ({P["APP"]} /* SeasonApp.app */,);
			name = Products;
			sourceTree = "<group>";
		}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{P["TGT"]} /* SeasonApp */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {P["TCL"]} /* Build configuration list for PBXNativeTarget "SeasonApp" */;
			buildPhases = ({P["SRC"]} /* Sources */, {P["FWK"]} /* Frameworks */, {P["RSC"]} /* Resources */,);
			buildRules = ();
			dependencies = ();
			name = SeasonApp;
			packageProductDependencies = ({P["SPMP"]} /* HotwireNative */,);
			productName = SeasonApp;
			productReference = {P["APP"]} /* SeasonApp.app */;
			productType = "com.apple.product-type.application";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{P["PRJ"]} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{BuildIndependentTargetsInParallel = 1; LastSwiftUpdateCheck = 1600; LastUpgradeCheck = 1600;}};
			buildConfigurationList = {P["PCL"]} /* Build configuration list for PBXProject "SeasonApp" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = "en-US";
			hasScannedForEncodings = 0;
			knownRegions = (en, Base,);
			mainGroup = {P["MGRP"]};
			packageReferences = ({P["SPM"]} /* XCRemoteSwiftPackageReference "hotwire-native-ios" */,);
			productRefGroup = {P["PGRP"]} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = ({P["TGT"]} /* SeasonApp */,);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		{P["RSC"]} /* Resources */ = {{isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		{P["SRC"]} /* Sources */ = {{isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		{P["DPROJ"]} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = ("DEBUG=1", "$(inherited)",);
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				ONLY_ACTIVE_ARCH = YES;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			}};
			name = Debug;
		}};
		{P["RPROJ"]} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_OPTIMIZATION_LEVEL = s;
				MTL_ENABLE_DEBUG_INFO = NO;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				VALIDATE_PRODUCT = YES;
			}};
			name = Release;
		}};
		{P["DTGT"]} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_ENTITLEMENTS = SeasonApp/SeasonApp.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 59;
				DEVELOPMENT_TEAM = CH4G9T6ZHP;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = SeasonApp/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 17.2;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.season-app.ios;
				PRODUCT_NAME = SeasonApp;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{P["RTGT"]} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_ENTITLEMENTS = SeasonApp/SeasonApp.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 59;
				DEVELOPMENT_TEAM = CH4G9T6ZHP;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = SeasonApp/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 17.2;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.season-app.ios;
				PRODUCT_NAME = SeasonApp;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{P["PCL"]} /* Build configuration list for PBXProject "SeasonApp" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = ({P["DPROJ"]} /* Debug */, {P["RPROJ"]} /* Release */,);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{P["TCL"]} /* Build configuration list for PBXNativeTarget "SeasonApp" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = ({P["DTGT"]} /* Debug */, {P["RTGT"]} /* Release */,);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */

/* Begin XCRemoteSwiftPackageReference section */
		{P["SPM"]} /* XCRemoteSwiftPackageReference "hotwire-native-ios" */ = {{
			isa = XCRemoteSwiftPackageReference;
			repositoryURL = "https://github.com/hotwired/hotwire-native-ios";
			requirement = {{kind = upToNextMajorVersion; minimumVersion = 1.2.0;}};
		}};
/* End XCRemoteSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
		{P["SPMP"]} /* HotwireNative */ = {{
			isa = XCSwiftPackageProductDependency;
			package = {P["SPM"]} /* XCRemoteSwiftPackageReference "hotwire-native-ios" */;
			productName = HotwireNative;
		}};
/* End XCSwiftPackageProductDependency section */

	}};
	rootObject = {P["PRJ"]} /* Project object */;
}}
'''

# xcscheme
SCHEME = f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1600"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{P["TGT"]}"
               BuildableName = "SeasonApp.app"
               BlueprintName = "SeasonApp"
               ReferencedContainer = "container:SeasonApp.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{P["TGT"]}"
            BuildableName = "SeasonApp.app"
            BlueprintName = "SeasonApp"
            ReferencedContainer = "container:SeasonApp.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{P["TGT"]}"
            BuildableName = "SeasonApp.app"
            BlueprintName = "SeasonApp"
            ReferencedContainer = "container:SeasonApp.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
'''

# Write files
with open(f"{xcodeproj}/project.pbxproj", "w") as f:
    f.write(PBXPROJ)

with open(f"{xcodeproj}/project.xcworkspace/contents.xcworkspacedata", "w") as f:
    f.write('<?xml version="1.0" encoding="UTF-8"?>\n<Workspace version = "1.0">\n<FileRef location = "self:">\n</FileRef>\n</Workspace>\n')

with open(f"{xcodeproj}/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist", "w") as f:
    f.write('<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0"><dict><key>IDEDidComputeMac32BitWarning</key><true/></dict></plist>\n')

with open(f"{xcodeproj}/xcshareddata/xcschemes/SeasonApp.xcscheme", "w") as f:
    f.write(SCHEME)

print("✅ Generated SeasonApp.xcodeproj with scheme")
print(f"   Project UUID: {P['PRJ']}")
print(f"   Target UUID:  {P['TGT']}")
