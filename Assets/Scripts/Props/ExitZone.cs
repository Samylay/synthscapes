using SynthScapes.Core;
using SynthScapes.Player;
using UnityEngine;

namespace SynthScapes.Props
{
    [RequireComponent(typeof(BoxCollider2D))]
    public sealed class ExitZone : MonoBehaviour
    {
        private void Awake()
        {
            var collider = GetComponent<BoxCollider2D>();
            collider.isTrigger = true;
        }

        private void OnTriggerEnter2D(Collider2D other)
        {
            if (!GameSession.DoorUnlocked || other.GetComponent<PlayerController>() == null)
            {
                return;
            }

            GameSession.CompleteDemo();
        }
    }
}
