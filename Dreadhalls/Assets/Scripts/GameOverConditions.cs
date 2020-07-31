using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameOverConditions : MonoBehaviour
{
    public static Vector3 cameraPosition;
    void Start()
    {

    }

    void Update()
    {
        cameraPosition = Camera.main.gameObject.transform.position;
        if (cameraPosition.y < -2500)
        {
            SceneManager.LoadScene("GameOver");
        }
    }
}
