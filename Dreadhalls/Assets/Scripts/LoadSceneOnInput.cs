using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadSceneOnInput : MonoBehaviour
{

    public static string sceneName;
    void Start()
    {

    }

    void Update()
    {
        if (Input.GetAxis("Submit") == 1)
        {
            sceneName = SceneManager.GetActiveScene().name;
            if (sceneName == "Title")
            {
                SceneManager.LoadScene("Play");
            }
            else if (sceneName == "GameOver")
            {
                SceneManager.LoadScene("Title");
            }
        }
    }
}
