using SynthScapes.Core;
using SynthScapes.Player;
using UnityEngine;

namespace SynthScapes.Props
{
    public sealed class TerminalInteractable : InteractableBase
    {
        private SpriteRenderer _renderer;

        private void Awake()
        {
            PromptText = "Press E to restore access";
            _renderer = GetComponent<SpriteRenderer>();
        }

        public override void Interact(PlayerController player)
        {
            GameSession.ActivateTerminal();

            if (_renderer != null)
            {
                _renderer.color = new Color(0.55f, 1f, 0.72f);
            }
        }
    }
}
