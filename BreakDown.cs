using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BreakDown : MonoBehaviour
{

    float burnAmounting;
    bool burningFlag;
    public float burningSpeed; 
    public Animation anim;
    public Vector3 speed;
    public GameObject material;

    // Use this for initialization
    void Start()
    {
        burnAmounting = 0;
    }

    // Update is called once per frame
    void Update()
    {
        if (burningFlag)
        {
            burnAmounting += Time.deltaTime * burningSpeed;
            material.GetComponent<Renderer>().material.SetFloat("_BurnAmount", burnAmounting);
            if (burnAmounting >= 1)
            {
                burningFlag = false;
                if (GetComponent<Rigidbody>())
                {
                    GetComponent<Rigidbody>().constraints = RigidbodyConstraints.None;
                }
                else {
                    Destroy(gameObject);
                }

                if (transform.position.z <= -7f)
                {
                    Destroy(gameObject);
                }
            }

        


        }
        if (transform.position.z <= -7f) {
            attack();
        }

        transform.Translate(Time.deltaTime * speed);


    }

    void breakDown()
    {
        burnAmounting = 0;
        burningFlag = true;
        if (anim) {
            anim.Stop();
        }
        
        speed = new Vector3(0, 0, 0);
    }

    void OnMouseDown()
    {
        breakDown();
    }

    void attack() {
        speed = new Vector3();
        if (anim)
        {
            anim.Play("attack");
        }
    }
}
