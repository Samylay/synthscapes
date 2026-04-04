using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace SynthScapes.Core
{
    public sealed class HudController : MonoBehaviour
    {
        public static HudController Instance { get; private set; }

        private Text _objectiveLabel;
        private Text _promptLabel;
        private Text _feedbackLabel;
        private Coroutine _feedbackRoutine;

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }

            Instance = this;
            DontDestroyOnLoad(gameObject);
            BuildUi();
        }

        private void OnEnable()
        {
            GameSession.ObjectiveChanged += SetObjective;
            GameSession.FeedbackRequested += ShowFeedback;
        }

        private void OnDisable()
        {
            GameSession.ObjectiveChanged -= SetObjective;
            GameSession.FeedbackRequested -= ShowFeedback;
        }

        public void SetObjective(string objective)
        {
            _objectiveLabel.text = objective;
        }

        public void ShowPrompt(string prompt)
        {
            _promptLabel.text = prompt;
            _promptLabel.enabled = true;
        }

        public void HidePrompt()
        {
            _promptLabel.enabled = false;
        }

        public void ShowFeedback(string message)
        {
            if (_feedbackRoutine != null)
            {
                StopCoroutine(_feedbackRoutine);
            }

            _feedbackLabel.text = message;
            _feedbackLabel.enabled = true;
            _feedbackRoutine = StartCoroutine(HideFeedbackAfterDelay());
        }

        private void BuildUi()
        {
            var canvasObject = new GameObject("HudCanvas");
            canvasObject.transform.SetParent(transform, false);

            var canvas = canvasObject.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.pixelPerfect = true;

            canvasObject.AddComponent<CanvasScaler>().uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            canvasObject.AddComponent<GraphicRaycaster>();

            var font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");

            _objectiveLabel = CreateText("ObjectiveLabel", canvasObject.transform, font, new Vector2(0f, 1f), new Vector2(0f, 1f), new Vector2(24f, -24f), new Vector2(520f, 56f), 18, TextAnchor.UpperLeft);
            _objectiveLabel.color = Color.white;

            _promptLabel = CreateText("PromptLabel", canvasObject.transform, font, new Vector2(0.5f, 0f), new Vector2(0.5f, 0f), new Vector2(0f, 28f), new Vector2(320f, 40f), 18, TextAnchor.MiddleCenter);
            _promptLabel.color = Color.white;
            _promptLabel.enabled = false;

            _feedbackLabel = CreateText("FeedbackLabel", canvasObject.transform, font, new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), new Vector2(0f, -24f), new Vector2(520f, 40f), 18, TextAnchor.MiddleCenter);
            _feedbackLabel.color = new Color(0.83f, 0.95f, 1f);
            _feedbackLabel.enabled = false;
        }

        private static Text CreateText(string objectName, Transform parent, Font font, Vector2 anchorMin, Vector2 anchorMax, Vector2 anchoredPosition, Vector2 sizeDelta, int fontSize, TextAnchor alignment)
        {
            var textObject = new GameObject(objectName);
            textObject.transform.SetParent(parent, false);

            var rect = textObject.AddComponent<RectTransform>();
            rect.anchorMin = anchorMin;
            rect.anchorMax = anchorMax;
            rect.anchoredPosition = anchoredPosition;
            rect.sizeDelta = sizeDelta;

            var text = textObject.AddComponent<Text>();
            text.font = font;
            text.fontSize = fontSize;
            text.alignment = alignment;
            text.horizontalOverflow = HorizontalWrapMode.Wrap;
            text.verticalOverflow = VerticalWrapMode.Overflow;
            return text;
        }

        private IEnumerator HideFeedbackAfterDelay()
        {
            yield return new WaitForSeconds(2.5f);
            _feedbackLabel.enabled = false;
        }
    }
}
