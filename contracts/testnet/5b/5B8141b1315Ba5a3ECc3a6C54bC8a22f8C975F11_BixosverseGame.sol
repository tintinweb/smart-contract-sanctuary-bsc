/**
 *Submitted for verification at BscScan.com on 2022-05-08
*/

pragma solidity 0.8.7;
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract BixosverseGame is AccessControl {
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");

    enum GameState {
        NewIsland,
        Created,
        Started,
        Ended,
        Canceled
    }

    struct Percentage {
        uint256 winner;
        uint256 bixos;
        uint256 burn;
        uint256 owner;
    }

    struct Game {
        string title;
        uint256 price;
        uint256 startTime;
        uint256 endTime;
        address winner;
        uint256 pool;
        address[] players;
        uint256 maxPlayers;
        uint256 minPlayers;
        Percentage percentages;
        GameState state;
    }

    struct AutoStartSettings {
        string title;
        uint256 price;
        uint256 startTime;
        uint256 maxPlayers;
        uint256 limit;
    }

    struct Island {
        bool isOccupied;
        Game[] games;
        Game activeGame;
    }

    /**
     * @notice this event is triggered when the island added
     * @param islandId id of the island
     */
    event NewIslandAdded(uint256 islandId);
    /**
     * @notice this event is triggered when the game created
     * @param title title of the game
     * @param price price of the game
     * @param startTime start time of the game
     * @param maxPlayers max players of the game
     * @param minPlayers min players of the game
     * @param percentages of the game
     */
    event GameCreated(
        uint256 nftId,
        string title,
        uint256 price,
        uint256 startTime,
        uint256 maxPlayers,
        uint256 minPlayers,
        Percentage percentages
    );
    /**
     * @notice this event is triggered when the game started
     * @param nftId id of the NFT
     * @param pool pool of the game
     * @param players all players of the game
     */
    event GameStarted(uint256 nftId, uint256 pool, address[] players);
    /**
     * @notice this event is triggered when the game ended
     * @param nftId id of the NFT
     * @param gameId id of the game
     * @param winner winner of the game
     * @param pool pool of the game
     * @param players all players of the game
     * @param percentages of the game
     */
    event GameEnded(
        uint256 nftId,
        uint256 gameId,
        address winner,
        uint256 pool,
        address[] players,
        Percentage percentages
    );
    /**
     * @notice this event is triggered when the game canceled
     * @param nftId id of the NFT
     * @param gameId id of the game
     */
    event GameCanceled(uint256 nftId, uint256 gameId);
    /**
     * @notice this event is triggered when someone joined the game
     * @param nftId id of the NFT
     * @param player address of the joined players
     * @param pool pool of the game
     */
    event GameJoined(uint256 nftId, address player, uint256 pool);
    /**
     * @notice this event is triggered when percentages are updated
     * @param winner amount the winner will win
     * @param bixos amount the bixos fee
     * @param burn amount to be burned
     * @param owner amount the owner fee
     */
    event DefaultPercentagesUpdated(uint256 winner, uint256 bixos, uint256 burn, uint256 owner);
    /**
     * @notice this event is triggered when "default min players" is updated
     * @dev related to defaultMinPlayers state
     * @param minPlayers min players of the game
     */
    event DefaultMinPlayersUpdated(uint256 minPlayers);
    /**
     * @notice this event is triggered when "default man players" is updated
     * @dev related to defaultMaxPlayers state
     * @param maxPlayers max players of the game
     */
    event DefaultMaxPlayersUpdated(uint256 maxPlayers);
    /**
     * @notice this event is triggered when "cancel time" is updated
     * @dev related to cancelTime state
     * @param cancelTime cancel time of the game
     */
    event CancelTimeUpdated(uint256 cancelTime);

    IERC20 private _ubxs;
    IERC721 private _ownershipNFT;
    address private _bixosverseFeeWallet;

    mapping(uint256 => Island) private _islands;
    mapping(uint256 => mapping(address => bool)) private userInGameExistence;
    Game[] private _games;

    Percentage public percentages;
    uint256 public defaultMinPlayers = 2;
    uint256 public defaultMaxPlayers = 25;
    uint256 public cancelTime = 1 days;
    uint256 public withdrawableAmount;
    uint256 public autoStartPrice;

    mapping(uint256 => AutoStartSettings) public autoStart;

    constructor(
        address ubxsAddress,
        address ownershipNFTAddress,
        address bixosverseFeeWallet
    ) {
        _ubxs = IERC20(ubxsAddress);
        _ownershipNFT = IERC721(ownershipNFTAddress);
        _bixosverseFeeWallet = bixosverseFeeWallet;

        percentages.winner = 80;
        percentages.bixos = 10;
        percentages.owner = 10;
        percentages.burn = 0;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    modifier onlyIslandExists(uint256 nftId) {
        require(_islands[nftId].isOccupied, "Island does not exist");
        _;
    }

    modifier onlyGreaterThanOne(uint256 value) {
        require(value > 1, "Given value must be greater than 1");
        _;
    }

    /**
     * @notice change the default percentages
     * @param _winner percentage of the winner
     * @param _bixos percentage of the bixos
     * @param _burn percentage of the burn
     * @param _owner percentage of the owner
     */
    function changePercentages(
        uint256 _winner,
        uint256 _bixos,
        uint256 _burn,
        uint256 _owner
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_winner + _bixos + _burn + _owner == 100, "Sum of percentages must be 100");

        percentages.winner = _winner;
        percentages.bixos = _bixos;
        percentages.burn = _burn;
        percentages.owner = _owner;

        emit DefaultPercentagesUpdated(
            percentages.winner,
            percentages.bixos,
            percentages.burn,
            percentages.owner
        );
    }

    /**
     * @notice change the default min players
     * @param _minPlayers new default min players
     */
    function changeDefaultMinPlayers(uint256 _minPlayers)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        onlyGreaterThanOne(_minPlayers)
    {
        defaultMinPlayers = _minPlayers;

        emit DefaultMinPlayersUpdated(defaultMinPlayers);
    }

    /**
     * @notice change the default max players
     * @param _maxPlayers new default max players
     */
    function changeDefaultMaxPlayers(uint256 _maxPlayers)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        onlyGreaterThanOne(_maxPlayers)
    {
        defaultMaxPlayers = _maxPlayers;

        emit DefaultMaxPlayersUpdated(defaultMaxPlayers);
    }

    /**
     * @notice change the cancel time
     * @param _cancelTime new cancel time
     */
    function changeCancelTime(uint256 _cancelTime) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_cancelTime > 1 hours, "Cancel time must be greater than 1 hours");

        cancelTime = _cancelTime;

        emit CancelTimeUpdated(cancelTime);
    }

    /**
     * @notice create a new island
     * @param nftId id of the NFT
     */
    function addNewIsland(uint256 nftId) public onlyRole(ORACLE_ROLE) {
        require(address(0) != _ownershipNFT.ownerOf(nftId), "Island not owned");
        require(!_islands[nftId].isOccupied, "Island already exists");

        _islands[nftId].isOccupied = true;
        _islands[nftId].activeGame.state = GameState.NewIsland;

        emit NewIslandAdded(nftId);
    }

    /**
     * @notice start an auto start process to an island
     * @param nftId id of the NFT
     * @param times how many times game will auto start.
     * @param _title title of the game
     * @param _price price of the game
     * @param _startTime start time of the game
     * @param _maxPlayers max players of the game
     */
    function startAutoStartGame(
        uint256 nftId,
        uint256 times,
        string memory _title,
        uint256 _price,
        uint256 _startTime,
        uint256 _maxPlayers
    ) public onlyIslandExists(nftId) {
        require(_msgSender() == _ownershipNFT.ownerOf(nftId), "Island not owned by you");
        require(
            _maxPlayers >= defaultMinPlayers,
            "Max players must be greater than or equal to defaultMinPlayers"
        );
        require(
            _maxPlayers <= defaultMaxPlayers,
            "Max players must be less than or equal to defaultMaxPlayers"
        );
        require(_price > 0, "Price must be greater than 0");
        require(times > 0, "Times must be greater than 0");

        uint256 _autoStartPrice = times * autoStartPrice;

        _ubxs.transferFrom(_msgSender(), address(this), _autoStartPrice);
        withdrawableAmount += _autoStartPrice;

        AutoStartSettings storage _autoStart = autoStart[nftId];

        _autoStart.title = _title;
        _autoStart.price = _price;
        _autoStart.startTime = _startTime;
        _autoStart.maxPlayers = _maxPlayers;
        _autoStart.limit += times;
    }

    /**
     * @notice start a game by oracle
     * @param nftId id of the NFT
     */
    function autoStartGame(uint256 nftId) public onlyRole(ORACLE_ROLE) {
        require(autoStart[nftId].limit > 0, "Auto start limit finished");

        require(
            _islands[nftId].activeGame.state == GameState.Ended ||
                _islands[nftId].activeGame.state == GameState.Canceled ||
                _islands[nftId].activeGame.state == GameState.NewIsland,
            "Already has a active game"
        );

        AutoStartSettings storage _autoStart = autoStart[nftId];
        _autoStart.limit--;

        Game storage game = _islands[nftId].activeGame;

        game.title = _autoStart.title;
        game.price = _autoStart.price;
        /* solhint-disable not-rely-on-time */
        game.startTime = _autoStart.startTime + block.timestamp;
        /* solhint-enable not-rely-on-time */
        game.maxPlayers = _autoStart.maxPlayers;
        game.state = GameState.Created;
        game.endTime = 0;
        game.winner = address(0);
        game.pool = 0;
        game.players = new address[](game.maxPlayers);
        game.minPlayers = defaultMinPlayers;
        game.percentages = percentages;

        emit GameCreated(
            nftId,
            game.title,
            game.price,
            game.startTime,
            game.maxPlayers,
            game.minPlayers,
            game.percentages
        );
    }

    /**
     * @notice create a new game on an island
     * @param nftId id of the NFT
     * @param _title title of the game
     * @param _price price of the game
     * @param _startTime start time of the game
     * @param _maxPlayers max players of the game
     */
    function addNewGame(
        uint256 nftId,
        string memory _title,
        uint256 _price,
        uint256 _startTime,
        uint256 _maxPlayers
    ) public onlyIslandExists(nftId) {
        require(_msgSender() == _ownershipNFT.ownerOf(nftId), "Island not owned by you");

        /* solhint-disable not-rely-on-time */
        require(_startTime > block.timestamp, "Start time must be greater than now");
        /* solhint-enable not-rely-on-time */
        require(
            _maxPlayers >= defaultMinPlayers,
            "Max players must be greater than or equal to defaultMinPlayers"
        );
        require(
            _maxPlayers <= defaultMaxPlayers,
            "Max players must be less than or equal to defaultMaxPlayers"
        );
        require(_price > 0, "Price must be greater than 0");

        require(
            _islands[nftId].activeGame.state == GameState.Ended ||
                _islands[nftId].activeGame.state == GameState.Canceled ||
                _islands[nftId].activeGame.state == GameState.NewIsland,
            "Already has a active game"
        );

        Game storage game = _islands[nftId].activeGame;

        game.title = _title;
        game.price = _price;
        game.startTime = _startTime;
        game.maxPlayers = _maxPlayers;
        game.state = GameState.Created;
        game.endTime = 0;
        game.winner = address(0);
        game.pool = 0;
        game.players = new address[](game.maxPlayers);
        game.minPlayers = defaultMinPlayers;
        game.percentages = percentages;

        emit GameCreated(
            nftId,
            game.title,
            game.price,
            game.startTime,
            game.maxPlayers,
            game.minPlayers,
            game.percentages
        );
    }

    /**
     * @notice join a game in progress
     * @param nftId id of the NFT
     */
    function joinGame(uint256 nftId) public onlyIslandExists(nftId) {
        Game storage game = _islands[nftId].activeGame;

        require(
            game.state == GameState.Created || game.state == GameState.Started,
            "Game is not in Created or Started state"
        );
        require(game.players.length < game.maxPlayers, "Game is full");

        game.players[game.players.length] = _msgSender();
        game.pool += game.price;

        userInGameExistence[nftId][_msgSender()] = true;

        _ubxs.transferFrom(_msgSender(), address(this), game.price);

        emit GameJoined(nftId, _msgSender(), game.pool);
    }

    /**
     * @notice start a game if it is not started
     * @param nftId id of the NFT
     */
    function startGame(uint256 nftId) public onlyIslandExists(nftId) onlyRole(ORACLE_ROLE) {
        Game storage game = _islands[nftId].activeGame;

        require(GameState.Created == game.state, "Game already started");
        require(game.players.length >= game.minPlayers, "Not enough players");
        /* solhint-disable not-rely-on-time */
        require(game.startTime > block.timestamp, "Start time must be greater than now");
        /* solhint-enable not-rely-on-time */
        require(game.endTime == 0, "Game already ended");

        game.state = GameState.Started;

        emit GameStarted(nftId, game.pool, game.players);
    }

    /**
     * @notice cancel a game if it is not started before the cancel time
     * @param nftId id of the NFT
     */
    function cancelGame(uint256 nftId) public onlyIslandExists(nftId) onlyRole(ORACLE_ROLE) {
        Game storage game = _islands[nftId].activeGame;

        require(GameState.Created == game.state, "Game started");
        require(game.players.length < game.minPlayers, "Game has minimum players");

        /* solhint-disable not-rely-on-time */
        require(game.startTime + cancelTime > block.timestamp, "Cancel time has not passed");
        game.endTime = block.timestamp;
        /* solhint-enable not-rely-on-time */

        game.state = GameState.Canceled;

        for (uint256 i = 0; i < game.players.length; i++) {
            if (game.players[i] != address(0)) {
                userInGameExistence[nftId][game.players[i]] = false;
                _ubxs.transfer(game.players[i], game.price);
            }
        }

        uint256 lastIndex = getIslandGamesCount(nftId);

        _islands[nftId].games.push(game);
        _games.push(game);

        emit GameCanceled(nftId, lastIndex);
    }

    /**
     * @notice end a game if it is started
     * @param nftId id of the NFT
     * @param winner winner of the game
     */
    function endGame(uint256 nftId, address winner)
        public
        onlyIslandExists(nftId)
        onlyRole(ORACLE_ROLE)
    {
        Game storage game = _islands[nftId].activeGame;

        require(GameState.Started == game.state, "Game not started");

        /* solhint-disable not-rely-on-time */
        game.endTime = block.timestamp;
        /* solhint-enable not-rely-on-time */

        game.state = GameState.Ended;
        game.winner = winner;

        uint256 lastIndex = getIslandGamesCount(nftId);

        _islands[nftId].games.push(game);
        _games.push(game);

        withdrawableAmount += (game.pool * game.percentages.bixos) / 100;

        for (uint256 i = 0; i < game.players.length; i++) {
            if (game.players[i] != address(0)) {
                userInGameExistence[nftId][game.players[i]] = false;
            }
        }

        _ubxs.transfer(game.winner, (game.pool * game.percentages.winner) / 100);
        _ubxs.transfer(_ownershipNFT.ownerOf(nftId), (game.pool * game.percentages.owner) / 100);

        emit GameEnded(nftId, lastIndex, winner, game.pool, game.players, game.percentages);
    }

    /**
     * @notice withdraw the bixos's amount
     */
    function withdraw() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _ubxs.transfer(_bixosverseFeeWallet, withdrawableAmount);
    }

    /**
     * @notice update bixos's fee wallet
     * @param bixosverseFeeWallet the bixos's fee wallet
     */
    function updateFeeWallet(address bixosverseFeeWallet) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _bixosverseFeeWallet = bixosverseFeeWallet;
    }

    /**
     * @notice get the number of players on an island active game
     * @param nftId id of the NFT
     * @return the active game player count
     */
    function getIslandActiveGamePlayerCount(uint256 nftId)
        public
        view
        onlyIslandExists(nftId)
        returns (uint256)
    {
        return _islands[nftId].activeGame.players.length;
    }

    /**
     * @notice get the player on an island active game
     * @param nftId id of the NFT
     * @param index index of the player
     * @return the player of given island and game
     */
    function getIslandActiveGamePlayer(uint256 nftId, uint256 index)
        public
        view
        onlyIslandExists(nftId)
        returns (address)
    {
        return _islands[nftId].activeGame.players[index];
    }

    /**
     * @notice get the number of games on an island
     * @param islandId id of the island
     */
    function getIslandGamesCount(uint256 islandId)
        public
        view
        onlyIslandExists(islandId)
        returns (uint256)
    {
        return _islands[islandId].games.length;
    }

    /**
     * @notice get the players count of a game
     * @param islandId id of the island
     * @param gameId index of the game
     * @return total players count of given island and game
     */
    function getIslandGamePlayersCount(uint256 islandId, uint256 gameId)
        public
        view
        onlyIslandExists(islandId)
        returns (uint256)
    {
        require(gameId < _islands[islandId].games.length, "Game does not exist");

        return _islands[islandId].games[gameId].players.length;
    }

    /**
     * @notice get the game count on system
     * @return total game count
     */
    function getGameCount() public view returns (uint256) {
        return _games.length;
    }

    /**
     * @notice get the players length of a game index on system
     * @param gameId index of the game
     * @return total players count of given game
     */
    function getGamePlayersCount(uint256 gameId) public view returns (uint256) {
        return _games[gameId].players.length;
    }
}