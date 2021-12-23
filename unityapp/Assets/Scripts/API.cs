using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine.UI;
using UnityEngine;
using AOT;
using Newtonsoft.Json;

/// <summary>
/// C-API exposed by the Host, i.e., Unity -> Host API.
/// </summary>
public class HostNativeAPI {
    public delegate void TestDelegate(string name);

    [DllImport("__Internal")]
    public static extern void sendUnityStateUpdate(string state);

    [DllImport("__Internal")]
    public static extern void setTestDelegate(TestDelegate cb);
}

/// <summary>
/// C-API exposed by Unity, i.e., Host -> Unity API.
/// </summary>
public class UnityNativeAPI {

    [MonoPInvokeCallback(typeof(HostNativeAPI.TestDelegate))]
    public static void test(string name) {
        Debug.Log("This static function has been called from iOS!");
        Debug.Log(name);
    }

}

/// <summary>
/// This structure holds the type of an incoming message.
/// Based on the type, we will parse the extra provided data.
/// </summary>
public struct Message
{
    public string type;
}

/// <summary>
/// This structure holds the type of an incoming message, as well
/// as some data.
/// </summary>
public struct MessageWithData<T>
{
    [JsonProperty(Required = Newtonsoft.Json.Required.AllowNull)]
    public string type;

    [JsonProperty(Required = Newtonsoft.Json.Required.AllowNull)]
    public T data;
}

public class API : MonoBehaviour
{
    public GameObject cube;

    void Start()
    {
        #if UNITY_IOS
        if (Application.platform == RuntimePlatform.IPhonePlayer) {
            HostNativeAPI.setTestDelegate(UnityNativeAPI.test);
            HostNativeAPI.sendUnityStateUpdate("ready");
        }
        #endif
    }

    void ReceiveMessage(string serializedMessage)
    {
        var header = JsonConvert.DeserializeObject<Message>(serializedMessage);
        switch (header.type) {
            case "change-color":
                _UpdateCubeColor(serializedMessage);
                break;
            default:
                Debug.LogError("Unrecognized message '" + header.type + "'");
                break;
        }
    }

    private void _UpdateCubeColor(string serialized)
    {
        var msg = JsonConvert.DeserializeObject<MessageWithData<float[]>>(serialized);
        if (msg.data != null && msg.data.Length >= 3)
        {
            var color = new Color(msg.data[0], msg.data[1], msg.data[2]);
            Debug.Log("Setting Color = " + color);
            var material = cube.GetComponent<MeshRenderer>()?.sharedMaterial;
            material?.SetColor("_Color", color);
        }
    }
}
