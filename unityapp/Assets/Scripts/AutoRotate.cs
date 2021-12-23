using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoRotate : MonoBehaviour
{
    // Update is called once per frame
    void Update()
    {
        if (Input.touchCount == 0)
        {
            transform.Rotate(0.0f, Time.deltaTime * 50.0f, 0.0f);
        }
    }
}
