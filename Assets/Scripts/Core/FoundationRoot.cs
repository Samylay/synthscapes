using SynthScapes.Props;
using SynthScapes.World;
using UnityEngine;
using UnityEngine.InputSystem;

namespace SynthScapes.Core
{
    public sealed class FoundationRoot : MonoBehaviour
    {
        private const string GroundSpritePath = "Imported/Map/ground";
        private const string RaisedSpritePath = "Imported/Map/raised";
        private const string AccentSpritePath = "Imported/Map/accent";

        [SerializeField] private Transform spawnPoint;
        [SerializeField] private GameObject playerPrefab;

        private Sprite _groundTileSprite;
        private Sprite _raisedTileSprite;
        private Sprite _accentTileSprite;

        private void Awake()
        {
            if (!ValidateConfiguration())
            {
                enabled = false;
                return;
            }

            BuildFoundation();
        }

        private bool ValidateConfiguration()
        {
            if (spawnPoint == null)
            {
                Debug.LogError($"{nameof(FoundationRoot)} requires a spawn point.", this);
                return false;
            }

            if (playerPrefab == null)
            {
                Debug.LogError($"{nameof(FoundationRoot)} requires a player prefab.", this);
                return false;
            }

            _groundTileSprite = Resources.Load<Sprite>(GroundSpritePath);
            _raisedTileSprite = Resources.Load<Sprite>(RaisedSpritePath);
            _accentTileSprite = Resources.Load<Sprite>(AccentSpritePath);

            if (_groundTileSprite == null || _raisedTileSprite == null || _accentTileSprite == null)
            {
                Debug.LogError($"{nameof(FoundationRoot)} requires map sprites.", this);
                return false;
            }

            return true;
        }

        private void BuildFoundation()
        {
            var worldRoot = new GameObject("World");
            worldRoot.transform.SetParent(transform, false);

            BuildHud();
            GameSession.Reset();
            BuildStarterMap(worldRoot.transform);

            var player = BuildPlayer(worldRoot.transform);
            var follow = Camera.main != null ? Camera.main.GetComponent<CameraFollow>() : null;
            if (follow != null)
            {
                follow.Target = player.transform;
            }
        }

        private void BuildStarterMap(Transform parent)
        {
            var floorRoot = new GameObject("Floor");
            floorRoot.transform.SetParent(parent, false);

            int radius = 5;
            for (int y = -radius; y <= radius; y++)
            {
                for (int x = -radius; x <= radius; x++)
                {
                    if (Mathf.Abs(x) + Mathf.Abs(y) > radius + 1)
                    {
                        continue;
                    }

                    var sprite = (x + y) % 3 == 0 ? _accentTileSprite : _groundTileSprite;
                    CreateTile(floorRoot.transform, $"Floor_{x}_{y}", GridToWorld(x, y), sprite, -1000);
                }
            }

            var propsRoot = new GameObject("Props");
            propsRoot.transform.SetParent(parent, false);

            CreateRaisedBlock(propsRoot.transform, "NorthBlock", new Vector2Int(0, 3), new Vector2(1.1f, 0.6f));
            CreateRaisedBlock(propsRoot.transform, "WestBlock", new Vector2Int(-3, 0), new Vector2(1.1f, 0.6f));
            CreateRaisedBlock(propsRoot.transform, "CenterBlock", new Vector2Int(0, -1), new Vector2(1.1f, 0.6f));
            CreateTerminal(propsRoot.transform);
            CreateDoor(propsRoot.transform);
            CreateExitZone(propsRoot.transform);

            var boundsRoot = new GameObject("Bounds");
            boundsRoot.transform.SetParent(parent, false);
            CreateBoundary(boundsRoot.transform, "NorthWall", new Vector2(0f, 3.45f), new Vector2(7.5f, 0.5f));
            CreateBoundary(boundsRoot.transform, "SouthWall", new Vector2(0f, -3.45f), new Vector2(7.5f, 0.5f));
            CreateBoundary(boundsRoot.transform, "WestWall", new Vector2(-5.4f, 0f), new Vector2(0.5f, 6.5f));
            CreateBoundary(boundsRoot.transform, "EastWallUpper", new Vector2(5.4f, 1.9f), new Vector2(0.5f, 2.7f));
            CreateBoundary(boundsRoot.transform, "EastWallLower", new Vector2(5.4f, -2.1f), new Vector2(0.5f, 2.5f));
        }

        private static void BuildHud()
        {
            if (HudController.Instance != null)
            {
                return;
            }

            new GameObject("HudController").AddComponent<HudController>();
        }

        private void CreateRaisedBlock(Transform parent, string objectName, Vector2Int gridPosition, Vector2 colliderSize)
        {
            var block = CreateTile(parent, objectName, GridToWorld(gridPosition.x, gridPosition.y), _raisedTileSprite, 0);
            block.AddComponent<YSort>();

            var collider = block.AddComponent<BoxCollider2D>();
            collider.size = colliderSize;
            collider.offset = new Vector2(0f, -0.1f);
        }

        private void CreateTerminal(Transform parent)
        {
            var terminal = CreateTile(parent, "Terminal", GridToWorld(-4, 1), _accentTileSprite, 5);
            terminal.transform.localScale = new Vector3(0.9f, 0.9f, 1f);
            terminal.AddComponent<YSort>();
            terminal.GetComponent<SpriteRenderer>().color = new Color(0.32f, 0.95f, 1f);

            var collider = terminal.AddComponent<BoxCollider2D>();
            collider.isTrigger = true;
            collider.size = new Vector2(0.9f, 0.55f);
            collider.offset = new Vector2(0f, -0.05f);

            terminal.AddComponent<TerminalInteractable>();
        }

        private void CreateDoor(Transform parent)
        {
            var door = CreateTile(parent, "Door", new Vector3(4.95f, -0.2f, 0f), _raisedTileSprite, 8);
            door.transform.localScale = new Vector3(0.95f, 1.35f, 1f);
            door.AddComponent<YSort>();
            door.GetComponent<SpriteRenderer>().color = new Color(0.95f, 0.45f, 0.4f);

            var blocker = door.AddComponent<BoxCollider2D>();
            blocker.size = new Vector2(0.75f, 1.6f);
            blocker.offset = new Vector2(0f, -0.1f);

            var interactionTrigger = door.AddComponent<BoxCollider2D>();
            interactionTrigger.size = new Vector2(1.6f, 1.9f);
            interactionTrigger.offset = new Vector2(0f, -0.1f);
            interactionTrigger.isTrigger = true;

            var interactable = door.AddComponent<LockedDoorInteractable>();
            interactable.SetDoorCollider(blocker);
        }

        private static void CreateExitZone(Transform parent)
        {
            var marker = new GameObject("ExitMarker");
            marker.transform.SetParent(parent, false);
            marker.transform.localPosition = new Vector3(6.05f, -0.2f, 0f);

            var renderer = marker.AddComponent<SpriteRenderer>();
            renderer.sprite = Resources.Load<Sprite>(AccentSpritePath);
            renderer.color = new Color(1f, 0.95f, 0.35f);
            renderer.sortingOrder = 3;

            var exit = new GameObject("ExitZone");
            exit.transform.SetParent(parent, false);
            exit.transform.localPosition = new Vector3(6.4f, -0.2f, 0f);

            var collider = exit.AddComponent<BoxCollider2D>();
            collider.size = new Vector2(1.6f, 2.2f);
            collider.isTrigger = true;

            exit.AddComponent<ExitZone>();
        }

        private GameObject CreateTile(Transform parent, string objectName, Vector3 position, Sprite sprite, int sortingOrder)
        {
            var tile = new GameObject(objectName);
            tile.transform.SetParent(parent, false);
            tile.transform.localPosition = position;

            var renderer = tile.AddComponent<SpriteRenderer>();
            renderer.sprite = sprite;
            renderer.sortingOrder = sortingOrder;
            return tile;
        }

        private static Vector3 GridToWorld(int x, int y)
        {
            return new Vector3((x - y) * 0.5f, (x + y) * 0.25f, 0f);
        }

        private static void CreateBoundary(Transform parent, string name, Vector2 position, Vector2 size)
        {
            var wall = new GameObject(name);
            wall.transform.SetParent(parent, false);
            wall.transform.localPosition = position;

            var collider = wall.AddComponent<BoxCollider2D>();
            collider.size = size;
        }

        private GameObject BuildPlayer(Transform parent)
        {
            var player = Instantiate(playerPrefab, parent);
            player.name = "Player";
            player.transform.position = spawnPoint.position;
            player.transform.rotation = Quaternion.identity;
            player.transform.localScale = Vector3.one;

            var playerInput = player.GetComponent<PlayerInput>();
            if (playerInput != null)
            {
                Destroy(playerInput);
            }

            var interactionTrigger = player.AddComponent<CircleCollider2D>();
            interactionTrigger.isTrigger = true;
            interactionTrigger.radius = 1.1f;

            if (player.GetComponent<YSort>() == null)
            {
                player.AddComponent<YSort>();
            }

            return player;
        }
    }
}
