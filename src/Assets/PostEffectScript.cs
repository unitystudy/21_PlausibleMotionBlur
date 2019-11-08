using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostEffectScript : MonoBehaviour
{
    public Material _reconstruction_material;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, _reconstruction_material);
    }
}
