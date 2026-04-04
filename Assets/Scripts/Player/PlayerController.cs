using SynthScapes.Core;
using SynthScapes.Props;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Serialization;

namespace SynthScapes.Player
{
    [RequireComponent(typeof(Rigidbody2D))]
    public sealed class PlayerController : MonoBehaviour
    {
        private static readonly int Walk = Animator.StringToHash("Walk");
        private static readonly int Run = Animator.StringToHash("Run");
        private static readonly int Horizontal = Animator.StringToHash("Horizontal");
        private static readonly int Vertical = Animator.StringToHash("Vertical");

        [FormerlySerializedAs("speed")]
        [SerializeField] private float walkSpeed = 2.5f;
        [SerializeField] private float sprintMultiplier = 1.75f;

        private Rigidbody2D _body;
        private Animator _animator;
        private InputAction _moveAction;
        private InputAction _sprintAction;
        private InputAction _interactAction;
        private Vector2 _moveInput;
        private Vector2 _facing = Vector2.down;
        private bool _sprintHeld;
        private InteractableBase _currentInteractable;

        private void Awake()
        {
            _body = GetComponent<Rigidbody2D>();
            _animator = GetComponent<Animator>();
            _body.gravityScale = 0f;
            _body.freezeRotation = true;
            _body.interpolation = RigidbodyInterpolation2D.Interpolate;

            var map = new InputActionMap("SynthScapesPlayer");
            _moveAction = map.AddAction("Move", InputActionType.Value);
            _moveAction.AddCompositeBinding("2DVector")
                .With("Up", "<Keyboard>/w")
                .With("Up", "<Keyboard>/upArrow")
                .With("Down", "<Keyboard>/s")
                .With("Down", "<Keyboard>/downArrow")
                .With("Left", "<Keyboard>/a")
                .With("Left", "<Keyboard>/leftArrow")
                .With("Right", "<Keyboard>/d")
                .With("Right", "<Keyboard>/rightArrow");
            _moveAction.AddBinding("<Gamepad>/leftStick");

            _sprintAction = map.AddAction("Sprint", InputActionType.Button);
            _sprintAction.AddBinding("<Keyboard>/leftShift");
            _sprintAction.AddBinding("<Gamepad>/leftStickPress");

            _interactAction = map.AddAction("Interact", InputActionType.Button);
            _interactAction.AddBinding("<Keyboard>/e");
            _interactAction.AddBinding("<Gamepad>/buttonWest");

            map.Enable();
        }

        private void OnDestroy()
        {
            _moveAction?.actionMap?.Disable();
        }

        private void Update()
        {
            if (_interactAction.WasPressedThisFrame() && _currentInteractable != null)
            {
                _currentInteractable.Interact(this);
            }
        }

        private void FixedUpdate()
        {
            _moveInput = _moveAction.ReadValue<Vector2>();
            _sprintHeld = _sprintAction.IsPressed();

            Vector2 input = _moveInput;
            if (input.sqrMagnitude > 1f)
            {
                input.Normalize();
            }

            UpdateFacing(input);

            if (input != Vector2.zero)
            {
                var iso = new Vector2(input.x - input.y, (input.x + input.y) * 0.5f);
                float speed = _sprintHeld ? walkSpeed * sprintMultiplier : walkSpeed;
                _body.linearVelocity = iso * speed;
            }
            else
            {
                _body.linearVelocity = Vector2.zero;
            }

            UpdateAnimator(input);
        }

        private void OnMove(InputValue value)
        {
            _moveInput = value.Get<Vector2>();
        }

        private void OnSprint(InputValue value)
        {
            _sprintHeld = value.isPressed;
        }

        private void OnTriggerEnter2D(Collider2D other)
        {
            var interactable = other.GetComponent<InteractableBase>();
            if (interactable == null)
            {
                return;
            }

            _currentInteractable = interactable;
            if (HudController.Instance != null)
            {
                HudController.Instance.ShowPrompt(interactable.PromptText);
            }
        }

        private void OnTriggerExit2D(Collider2D other)
        {
            var interactable = other.GetComponent<InteractableBase>();
            if (interactable == null || interactable != _currentInteractable)
            {
                return;
            }

            _currentInteractable = null;
            if (HudController.Instance != null)
            {
                HudController.Instance.HidePrompt();
            }
        }

        private void UpdateFacing(Vector2 input)
        {
            if (input == Vector2.zero)
            {
                return;
            }

            if (Mathf.Abs(input.x) > Mathf.Abs(input.y))
            {
                _facing = new Vector2(Mathf.Sign(input.x), 0f);
                return;
            }

            _facing = new Vector2(0f, Mathf.Sign(input.y));
        }

        private void UpdateAnimator(Vector2 input)
        {
            if (_animator == null)
            {
                return;
            }

            bool moving = input != Vector2.zero;
            _animator.SetBool(Walk, moving && !_sprintHeld);
            _animator.SetBool(Run, moving && _sprintHeld);
            _animator.SetFloat(Horizontal, _facing.x);
            _animator.SetFloat(Vertical, _facing.y);
        }

        // Imported animation clips fire this event, but the project does not use it yet.
        public void AnimationEventHandler()
        {
        }
    }
}
