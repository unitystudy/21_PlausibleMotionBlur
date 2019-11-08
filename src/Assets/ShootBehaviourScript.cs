using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShootBehaviourScript : MonoBehaviour
{
    [SerializeField] CustomRenderTexture _velocity_map;
    [SerializeField] Material _velocitymap_material;
    [SerializeField] CustomRenderTexture _tile_max_map_tmp;
    [SerializeField] CustomRenderTexture _tile_max_map;
    [SerializeField] CustomRenderTexture _neighbor_max_map;

    const float EFFECT_END = 10.0f;
    float effect_time = 0.0f;
    Vector2 shoot_pos;

    // Start is called before the first frame update
    void Start()
    {
        update_velocity_map(effect_time, new Vector2(0,0));
    }

    // Update is called once per frame
    void Update()
    {
        // クリック
        if (Input.GetMouseButtonDown(0)){
            effect_time = float.Epsilon;
            shoot_pos = new Vector2(
                Input.mousePosition.x / _velocity_map.width, 
                Input.mousePosition.y / _velocity_map.height);
        }

        // エフェクト中
        if (0.0f < effect_time)
        {
            effect_time += Time.deltaTime;
            update_velocity_map(effect_time, shoot_pos);

            // 終了判定
            if (EFFECT_END < effect_time) effect_time = 0.0f;
        }
    }

    // 速度マップの更新
    void update_velocity_map(float time, Vector2 pos)
    {
        // 速度マップの更新
        if (_velocitymap_material.HasProperty("_X")) _velocitymap_material.SetFloat("_X", pos.x);
        if (_velocitymap_material.HasProperty("_Y")) _velocitymap_material.SetFloat("_Y", pos.y);
        if (_velocitymap_material.HasProperty("_time")) _velocitymap_material.SetFloat("_time", time);
        _velocity_map.Update(1);

        // タイルマップ等の更新
        _tile_max_map_tmp.Update(1);
        _tile_max_map.Update(1);
        _neighbor_max_map.Update(1);
    }
}
