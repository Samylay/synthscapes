using UnityEngine;

namespace SynthScapes.World
{
    public sealed class CameraFollow : MonoBehaviour
    {
        public Transform Target { get; set; }

        [SerializeField] private float smoothing = 8f;
        [SerializeField] private Vector3 offset = new(0f, 0f, -10f);

        private void LateUpdate()
        {
            if (Target == null)
            {
                return;
            }

            Vector3 targetPosition = Target.position + offset;
            transform.position = Vector3.Lerp(transform.position, targetPosition, 1f - Mathf.Exp(-smoothing * Time.deltaTime));
        }
    }
}
