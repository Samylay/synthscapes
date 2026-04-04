using System;

namespace SynthScapes.Core
{
    public static class GameSession
    {
        public static bool TerminalActivated { get; private set; }
        public static bool DoorUnlocked { get; private set; }
        public static bool DemoComplete { get; private set; }

        public static event Action<string> ObjectiveChanged;
        public static event Action<string> FeedbackRequested;

        public static void Reset()
        {
            TerminalActivated = false;
            DoorUnlocked = false;
            DemoComplete = false;
            ObjectiveChanged?.Invoke("Reach the terminal and restore door access.");
        }

        public static void ActivateTerminal()
        {
            if (TerminalActivated)
            {
                FeedbackRequested?.Invoke("The terminal is already online.");
                return;
            }

            TerminalActivated = true;
            ObjectiveChanged?.Invoke("Use the unlocked eastern door.");
            FeedbackRequested?.Invoke("Access restored. Eastern door unlocked.");
        }

        public static void UnlockDoor()
        {
            if (DoorUnlocked)
            {
                return;
            }

            DoorUnlocked = true;
            FeedbackRequested?.Invoke("Door unlocked.");
        }

        public static void RequestFeedback(string message)
        {
            FeedbackRequested?.Invoke(message);
        }

        public static void CompleteDemo()
        {
            if (DemoComplete)
            {
                return;
            }

            DemoComplete = true;
            ObjectiveChanged?.Invoke("Slice complete.");
            FeedbackRequested?.Invoke("Demo complete. You escaped the room.");
        }
    }
}
