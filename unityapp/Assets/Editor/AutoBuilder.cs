using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using System.Collections;
using System.Collections.Generic;
using System.IO;

/// <summary>
/// This class will update the generated XCode configuration.
///
/// This is used to automate some manual steps that we keep
/// doing over-and-over when building.
/// </summary>
public static class AutoBuilder
{
    private static string MODULE_MAP = "UnityFramework.modulemap";
    private static string INTERFACE_HEADER = "NativeCallProxy.h";

    /// <summary>
    /// Retrieves the name of the project
    /// </summary>
    static string GetProjectName()
    {
        string[] s = Application.dataPath.Split('/');
        return s[s.Length - 2];
    }

    static string[] GetScenePaths()
    {
        string[] scenes = new string[EditorBuildSettings.scenes.Length];
        for(int i = 0; i < scenes.Length; i++)
        {
            scenes[i] = EditorBuildSettings.scenes[i].path;
        }
        return scenes;
    }
    [MenuItem("File/AutoBuilder/iOS")]
    static void PerformiOSBuild()
    {
        EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.iOS, BuildTarget.iOS);
        BuildPipeline.BuildPlayer(GetScenePaths(), "Build/iOS", BuildTarget.iOS, BuildOptions.None);
    }

    [PostProcessBuild]
    public static void OnPostProcessBuild(BuildTarget buildTarget, string path)
    {
        switch (buildTarget)
        {
            case BuildTarget.iOS:
            {
                var xcodePath = path + "/Unity-Iphone.xcodeproj/project.pbxproj";
                var proj = new PBXProject();
                proj.ReadFromFile(xcodePath);

                var targetGuid = proj.GetUnityFrameworkTargetGuid();

                proj.SetBuildProperty(targetGuid, "COREML_CODEGEN_LANGUAGE", "Swift");
                proj.SetBuildProperty(targetGuid, "SWIFT_VERSION", "5.0");
                proj.AddBuildProperty(targetGuid, "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES", "NO");
                proj.SetBuildProperty(targetGuid, "EMBEDDED_CONTENT_CONTAINS_SWIFT", "YES");
                proj.SetBuildProperty(
                    targetGuid,
                    "FRAMERWORK_SEARCH_PATHS",
                    "$(inherited) $(PROJECT_DIR) $(PROJECT_DIR)/Frameworks"
                );
                proj.SetBuildProperty(targetGuid, "DEFINES_MODULE", "YES");

                // Adds the data folder to the Unity target.
                // This is basically the manual step we were doing before!
                var dataGUID = proj.FindFileGuidByProjectPath("Data");
                proj.AddFileToBuild(targetGuid, dataGUID);

                /**
                 * Module Map
                 */

                var moduleFileName = "UnityFramework/UnityFramework.modulemap";
                var moduleFile = path + "/" + moduleFileName;
                if (!File.Exists(moduleFile))
                {
                    FileUtil.CopyFileOrDirectory("Assets/Plugins/iOS/" + AutoBuilder.MODULE_MAP, moduleFile);
                    proj.AddFile(moduleFile, moduleFileName);
                    proj.AddBuildProperty(targetGuid, "MODULEMAP_FILE", "$(SRCROOT)/" + moduleFileName);
                }

                /**
                 * Headers
                 */

                // Sets the visiblity of our native API header.
                // This is basically the manual step we were doing before!
                var unityInterfaceGuid = proj.FindFileGuidByProjectPath("Libraries/Plugins/iOS/" + AutoBuilder.INTERFACE_HEADER);
                proj.AddPublicHeaderToBuild(targetGuid, unityInterfaceGuid);

                proj.WriteToFile(xcodePath);
                break;
            }
        }
    }
}
