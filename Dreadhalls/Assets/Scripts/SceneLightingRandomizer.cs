using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class SceneLightingRandomizer : MonoBehaviour
{
    public static float red;

    public static float green;

    public static float blue;

    public static float hue;

    public static float saturation;

    public static float brightness;

    void Start()
    {

        red = Random.value;
        green = Random.value;
        blue = Random.value;

        RenderSettings.ambientLight = new Color(red, green, blue);

        Color.RGBToHSV(RenderSettings.ambientLight, out hue, out saturation, out brightness);

        RenderSettings.fogColor = new Color(red - 0.15f, green - 0.15f, blue - 0.15f);

    }

    void Update()
    {

    }
}
