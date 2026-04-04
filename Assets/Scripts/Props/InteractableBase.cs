using SynthScapes.Player;
using UnityEngine;

namespace SynthScapes.Props
{
    public abstract class InteractableBase : MonoBehaviour
    {
        [field: SerializeField] public string PromptText { get; protected set; } = "Press E";

        public abstract void Interact(PlayerController player);
    }
}
