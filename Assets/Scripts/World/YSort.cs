using UnityEngine;

namespace SynthScapes.World
{
    [RequireComponent(typeof(SpriteRenderer))]
    public sealed class YSort : MonoBehaviour
    {
        private SpriteRenderer _renderer;
        private int _baseSortingOrder;

        private void Awake()
        {
            _renderer = GetComponent<SpriteRenderer>();
            _baseSortingOrder = _renderer.sortingOrder;
        }

        private void LateUpdate()
        {
            _renderer.sortingOrder = _baseSortingOrder + Mathf.RoundToInt(-transform.position.y * 100f);
        }
    }
}
