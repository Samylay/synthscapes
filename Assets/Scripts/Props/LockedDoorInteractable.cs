using SynthScapes.Core;
using SynthScapes.Player;
using UnityEngine;

namespace SynthScapes.Props
{
    [RequireComponent(typeof(BoxCollider2D))]
    public sealed class LockedDoorInteractable : InteractableBase
    {
        private BoxCollider2D _collider;
        private SpriteRenderer _renderer;
        private bool _open;

        private void Awake()
        {
            PromptText = "Press E to use door";
            _collider = GetComponent<BoxCollider2D>();
            _renderer = GetComponent<SpriteRenderer>();
        }

        public override void Interact(PlayerController player)
        {
            if (_open)
            {
                GameSession.RequestFeedback("The door is already open.");
                return;
            }

            if (!GameSession.TerminalActivated)
            {
                GameSession.RequestFeedback("Access denied. Terminal authorization required.");
                return;
            }

            _open = true;
            _collider.enabled = false;
            if (_renderer != null)
            {
                _renderer.color = new Color(0.35f, 0.95f, 0.62f);
            }

            GameSession.UnlockDoor();
        }

        public void SetDoorCollider(BoxCollider2D doorCollider)
        {
            _collider = doorCollider;
        }
    }
}
