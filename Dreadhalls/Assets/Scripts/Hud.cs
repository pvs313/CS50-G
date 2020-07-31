using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Hud : MonoBehaviour
{
    public static Text levelText;

    public static Color levelContrast;

    void Start()
    {
        GameObject levelCount = GameObject.Find("Level Count");
        levelText = levelCount.GetComponent<Text>();

        levelText.text = "Lv. " + PlayerStats.level.ToString();

        levelContrast = Color.HSVToRGB(
                            (SceneLightingRandomizer.hue + 0.5f) % 1,
                            Mathf.Max(SceneLightingRandomizer.saturation, 0.2f),
                            Mathf.Max(SceneLightingRandomizer.brightness, 0.5f));

        levelText.color = levelContrast;
    }

    void Update()
    {

    }
}
