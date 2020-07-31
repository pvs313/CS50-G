using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pickup : MonoBehaviour
{

    public AudioSource audioLoop;
    public AudioSource audioTail;
    void Start()
    {
        audioLoop = GetComponent<AudioSource>();
        audioLoop.loop = true;
        audioLoop.playOnAwake = false;
        audioLoop.mute = false;

        GameObject tailSource = this.transform.Find("TailSound").gameObject;
        audioTail = tailSource.GetComponent<AudioSource>();
        audioTail.loop = false;
        audioTail.playOnAwake = false;


        StartCoroutine(loopAudio());
    }

    void Update()
    {
        transform.Rotate(0, 5f, 0, Space.World);
    }

    IEnumerator loopAudio()
    {
        audioLoop.Play();
        while (true)
        {
            yield return new WaitForSeconds(audioLoop.clip.length);
            audioTail.PlayOneShot(audioTail.clip, 0.5f);
        }
    }
}
