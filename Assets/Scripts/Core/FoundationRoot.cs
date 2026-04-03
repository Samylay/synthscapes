using SynthScapes.World;
using UnityEngine;

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
            CreateRaisedBlock(propsRoot.transform, "EastBlock", new Vector2Int(3, -1), new Vector2(1.1f, 0.6f));

            var boundsRoot = new GameObject("Bounds");
            boundsRoot.transform.SetParent(parent, false);
            CreateBoundary(boundsRoot.transform, "NorthWall", new Vector2(0f, 3.45f), new Vector2(7.5f, 0.5f));
            CreateBoundary(boundsRoot.transform, "SouthWall", new Vector2(0f, -3.45f), new Vector2(7.5f, 0.5f));
            CreateBoundary(boundsRoot.transform, "WestWall", new Vector2(-5.4f, 0f), new Vector2(0.5f, 6.5f));
            CreateBoundary(boundsRoot.transform, "EastWall", new Vector2(5.4f, 0f), new Vector2(0.5f, 6.5f));
        }

        private void CreateRaisedBlock(Transform parent, string objectName, Vector2Int gridPosition, Vector2 colliderSize)
        {
            var block = CreateTile(parent, objectName, GridToWorld(gridPosition.x, gridPosition.y), _raisedTileSprite, 0);
            block.AddComponent<YSort>();

            var collider = block.AddComponent<BoxCollider2D>();
            collider.size = colliderSize;
            collider.offset = new Vector2(0f, -0.1f);
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

            if (player.GetComponent<YSort>() == null)
            {
                player.AddComponent<YSort>();
            }

            return player;
        }
    }
}
