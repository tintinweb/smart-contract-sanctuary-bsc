/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// Sources flattened with hardhat v2.11.2 https://hardhat.org

// File @openzeppelin/contracts/access/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
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


// File @openzeppelin/contracts/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/utils/[email protected]


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}


// File @openzeppelin/contracts/utils/introspection/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
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


// File @openzeppelin/contracts/utils/introspection/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


// File @openzeppelin/contracts/access/[email protected]


// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;




/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
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
        _checkRole(role);
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
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
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
     *
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleRevoked} event.
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
     *
     * May emit a {RoleRevoked} event.
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
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


// File contracts/Treasury.sol


pragma solidity 0.8.17;

contract Treasury is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant TREASURER_ROLE = keccak256("TREASURER_ROLE");

    event TreasuryFundsWithdrawn(address to, uint256 amount);
    event FundsReceived(address from, uint256 amount);

    constructor() {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(TREASURER_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(TREASURER_ROLE, _msgSender());
    }

    receive() external payable {
        emit FundsReceived(_msgSender(), msg.value);
    }

    function withdrawFunds(uint256 amount) public onlyRole(TREASURER_ROLE) {
        uint256 balance = address(this).balance;
        require(balance >= amount, "Treasury: Insufficient Balance");
        payable(_msgSender()).transfer(amount);
        emit TreasuryFundsWithdrawn(_msgSender(), amount);
    }

    function grantRoletoAddress(address _address, bytes32 role)
        public
        onlyRole(ADMIN_ROLE)
    {
        _grantRole(role, _address);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}


// File @openzeppelin/contracts/security/[email protected]


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


// File @chainlink/contracts/src/v0.8/interfaces/[email protected]


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}


// File contracts/Head2Head.sol


pragma solidity 0.8.17;




contract Head2Head is AccessControl, Pausable {
    /**
     *  CUSTOM ERRORS OF HEAD 2 HEAD GAME
     */
    error Head2Head__WrongGameStatus();
    error Head2Head__GameNotEnded();
    error Head2Head__InvalidBetAmount();
    error Head2Head__ResultsNotUpdated();
    error Head2Head__RewardsAlreadyDistributed();
    error Head2Head__ArrayLengthsMismatch();
    error Head2Head__GameDraw();
    error Head2Head__WrongTimestamps();
    error Head2Head__StockIdNotInGame(uint256 gameId, bytes12 stockId);
    error Head2Head__WrongIdxs(uint256 startIdx, uint256 endIdx);
    error Head2Head__BNBTransferFailed(address to, uint256 value);

    //enum for GameStatus
    enum GameStatus {
        NONEXISTENT,
        CREATED,
        STARTED,
        ENDED
    }
    /**
     * @notice HEAD 2 HEAD player BET Info
     */
    struct Head2HeadBet {
        address better;
        uint256 betAmount;
        bytes12 stockId;
        uint256 timestamp;
        uint256 winAmount;
        uint256 multiplier;
        bool win;
    }
    /**
     * @notice HEAD 2 HEAD Game Info
     */
    struct Head2HeadGame {
        bytes12[2] stockIds; // stock IDs listed in this game
        string[2] stockSymbols; // stock symbols of respective stockIDs
        uint256[3] timestamps; // 0= createTimestamp, 1=startTimestamp, 2=endTimestamp
        uint256[2] minMaxBetsInWei; //0= minBet, 1=MaxBet
        uint256 initialMultiplierInWei; // initial multiplier in wei
        uint256 updateMulAfterAmountInWei; // update Odds at this interval amount in USD
        uint256 curUpdateMulAtAmountInWei; // cur amount after which new odds will be calculated
        bool isGameDraw; // Is this Game Drawn ?
        mapping(bytes12 => uint256) startGameStockPricesInWei; // stockId => price before game start in wei uints
        mapping(bytes12 => uint256) endGameStockPricesInWei; // stockId => price after game start in wei uints
        bytes12 winningStockId; // Stock ID of winning stock
        bool rewardsDistributed; // Is Reward Distributed in this game ?
        address payable[] betters; // address array of all the betters
        uint256 totalBetsPooled; // total amount pooled in this game
        uint256[2] totalBetsInStocks; // total amount of bet pooled in this game for stock 0 and 1
        uint256[2] curMultiplierStocks; // current winning multiplier for stock 0 and stock 1
    }

    // CURRENT GAME ID
    uint256 public gameId;
    // USING CHAINLINK PRICEFEED
    AggregatorV3Interface internal priceFeed;
    Treasury public treasuryContract;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    /**
     *  MAPPINGS FOR HEAD 2 HEAD GAME
     */

    /**
     * @notice Game Info For This Game Id  (gameID -> GameInfo)
     */
    mapping(uint256 => Head2HeadGame) public head2headGames;
    /**
     * @notice Bet Info for a given gameID and better address (gameid -> better -> Bet)
     */
    mapping(uint256 => mapping(address => Head2HeadBet[])) public bets;
    /**
     * @notice gameIds of all the games, the better has participated in head2head game ( betterAddress -> gameId[] )
     */
    mapping(address => uint256[]) public betterGameIds;

    /**
     * For Fetching winning bets only using static call not chaing state 
     */
    address[] internal temp_winners;
    uint[][] internal temp_winningBetsIndexes;

    /**
     *  HEAD 2 HEAD GAME EVENTS
     */

    event Head2HeadGameCreated(
        uint256 indexed gameId,
        bytes12[2] stocks,
        string[2] stockSymbols,
        uint256 initialMultiplierInWei,
        uint256 startGameTimestamp,
        uint256 endGameTimeStamp,
        uint256 minBetAmountInWei,
        uint256 maxBetAmountInWei
    );
    event Head2HeadBetPlaced(
        uint256 indexed gameId,
        address better,
        bytes12 stockId,
        uint256 betAmount
    );
    event Head2HeadBetUpdated(
        uint256 indexed gameId,
        address better,
        bytes12 stockId,
        uint256 prevBetAmount,
        uint256 newBetAmount
    );
    event Head2HeadBetCancelled(
        uint256 indexed gameId,
        address better,
        bytes12 stockId
    );
    event Head2HeadGameWinAmountSent(
        uint256 indexed gameId,
        address winner,
        bytes12 winningStockId,
        uint256 multiplier,
        uint256 amountSent
    );
    event Head2HeadUpdateOrCancelBetAmountReturned(
        uint256 indexed gameId,
        address better,
        bytes12 stockId,
        uint256 returnBetAmount
    );
    event Head2HeadGameDrawRevertBets(
        uint256 indexed gameId,
        address better,
        bytes12 stockId,
        uint256 betAmt
    );
    event Head2HeadPricesUpdated(
        uint256 indexed gameId,
        bytes12[2] stockIds,
        uint256[2] startGameStockPricesInWei,
        uint256[2] endGameStockPricesInWei
    );
    event Head2HeadWinningStockUpdated(
        uint256 indexed gameId,
        bytes12 winningStockId
    );
    event Head2HeadOddsUpdated(
        uint256 gameId,
        uint256 newOddsStock0,
        uint256 newOddsStock1
    );
    event Head2HeadReceivedBNB(address from, uint256 value);

    constructor(address payable treasury, address bnbUsdOracle) {
        treasuryContract = Treasury(treasury);
        priceFeed = AggregatorV3Interface(bnbUsdOracle);
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(OPERATOR_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(OPERATOR_ROLE, _msgSender());
    }

    receive() external payable {
        emit Head2HeadReceivedBNB(msg.sender, msg.value);
    }

    /**
     * @notice Create Game With Given Info
     * @dev Reverts when
     * BOTH OF STOCK IDs ARE SAME
     * ANY OF THE STOCK IDs ARE ZERO
     * @param _stockIds integer array of stock IDs
     * @param _minBetAmountInWei minimum bet amount
     * @param _initialMultiplierInWei winning multiplier for winning betters
     * @param _startGameTimeStamp timestamp when game will start
     * @param _endGameTimestamp timestamp when game will end
     */
    function createGame(
        bytes12[2] memory _stockIds,
        string[2] memory _stockSymbols,
        uint256 _minBetAmountInWei,
        uint256 _maxBetAmountInWei,
        uint256 _initialMultiplierInWei,
        uint256 _updateMulAfterAmountInWei,
        uint256 _startGameTimeStamp,
        uint256 _endGameTimestamp
    ) external onlyRole(OPERATOR_ROLE) whenNotPaused {
        if (_startGameTimeStamp >= _endGameTimestamp) {
            revert Head2Head__WrongTimestamps();
        }
        uint256 currentTimestamp = block.timestamp;

        // INCREMENT GAME ID
        gameId += 1;

        // UPDATE HEAD 2 HEAD CREATION GAME INFO
        head2headGames[gameId].timestamps[0] = currentTimestamp;
        head2headGames[gameId].timestamps[1] = _startGameTimeStamp;
        head2headGames[gameId].timestamps[2] = _endGameTimestamp;
        head2headGames[gameId].minMaxBetsInWei[0] = _minBetAmountInWei;
        head2headGames[gameId].minMaxBetsInWei[1] = _maxBetAmountInWei;
        head2headGames[gameId].stockIds = _stockIds;
        head2headGames[gameId].stockSymbols = _stockSymbols;
        head2headGames[gameId].initialMultiplierInWei = _initialMultiplierInWei;
        head2headGames[gameId]
            .updateMulAfterAmountInWei = _updateMulAfterAmountInWei;
        head2headGames[gameId].curMultiplierStocks[0] = _initialMultiplierInWei;
        head2headGames[gameId].curMultiplierStocks[1] = _initialMultiplierInWei;
        head2headGames[gameId]
            .curUpdateMulAtAmountInWei = _updateMulAfterAmountInWei;

        // EMIT EVENT WHEN HEAD 2 HEAD GAME IS CREATED WIT STOCK IDS, START ANND END TIME, MIN BET AMOUNT
        emit Head2HeadGameCreated(
            gameId,
            _stockIds,
            _stockSymbols,
            _initialMultiplierInWei,
            _startGameTimeStamp,
            _endGameTimestamp,
            _minBetAmountInWei,
            _maxBetAmountInWei
        );
    }

    /**
     * @notice Place Bet For Given game ID and stock ID
     * @dev Reverts when
     * (Game Is Not Created ||
     *  Game Is Ended ||
     *  Game Is Forfeited ||
     *  Given stock Not Listed In This Game ||
     *  Caller has already Bet In This Game ||
     *  Caller bet is less than minimum bet value)
     * @param _gameId Game ID of the game to place Bet
     * @param _stockId ID of the stock on which bet is placed
     */
    function placeBet(uint256 _gameId, bytes12 _stockId)
        external
        payable
        whenNotPaused
    {
        //BET AMOUNT
        uint256 betAmount = msg.value;

        // SUFFICIENT CHECKS TO CHECK BET IS VALID OR NOT
        if (!isStockInGame(_gameId, _stockId)) {
            revert Head2Head__StockIdNotInGame(_gameId, _stockId);
        }
        if (getGameStatus(_gameId) != GameStatus.CREATED) {
            revert Head2Head__WrongGameStatus();
        } else if (
            betAmount < head2headGames[_gameId].minMaxBetsInWei[0] ||
            betAmount > head2headGames[_gameId].minMaxBetsInWei[1]
        ) {
            revert Head2Head__InvalidBetAmount();
        }

        if (bets[_gameId][_msgSender()].length == 0) {
            betterGameIds[_msgSender()].push(_gameId);
            head2headGames[_gameId].betters.push(payable(_msgSender()));
        }

        // UPDATE TOTAL AMOUNT POOLED IN THIS BET IN THIS GAME
        head2headGames[_gameId].totalBetsPooled += betAmount;
        uint256 multiplier;
        if (_stockId == head2headGames[_gameId].stockIds[0]) {
            head2headGames[_gameId].totalBetsInStocks[0] += betAmount;
            multiplier = head2headGames[_gameId].curMultiplierStocks[0];
        } else {
            head2headGames[_gameId].totalBetsInStocks[1] += betAmount;
            multiplier = head2headGames[_gameId].curMultiplierStocks[1];
        }

        bets[_gameId][_msgSender()].push(
            Head2HeadBet(
                _msgSender(),
                betAmount,
                _stockId,
                block.timestamp,
                0,
                multiplier,
                false
            )
        );
        uint256 totalBetsPooled = head2headGames[_gameId].totalBetsPooled;
        uint256 bnbPrice = uint256(getLatestPrice());
        uint256 totalBetsPooledInUsd = (totalBetsPooled * (bnbPrice)) / 1e8;
        uint256 curUpdateMulAtAmountInWei = head2headGames[_gameId]
            .curUpdateMulAtAmountInWei;
        if (totalBetsPooledInUsd > curUpdateMulAtAmountInWei) {
            updateCurrentOdds(
                _gameId,
                head2headGames[_gameId].totalBetsInStocks[0],
                head2headGames[_gameId].totalBetsInStocks[1]
            );
            uint256 updateMulAfterAmountInWei = head2headGames[_gameId]
                .updateMulAfterAmountInWei;
            head2headGames[_gameId].curUpdateMulAtAmountInWei =
                ((totalBetsPooledInUsd / updateMulAfterAmountInWei) + 1) *
                updateMulAfterAmountInWei;
        }
        // EMIT BET PLACED EVENT FOR GAME ID, BETTER, STOCK ID, BET AMOUNT
        emit Head2HeadBetPlaced(_gameId, _msgSender(), _stockId, betAmount);
    }

    /**
     * @notice Update Results for this game ID
     * @dev Revert
     * When stock ID is not present in this game ,
     * Revert if game is forfeited ,
     * Revert if sender is not the owner ,
     * Revert when length is mismatch for given arrays ,
     * Revert when game is not ended ,
     * Revert when rewards are already distributed ,
     * Emit event
     * @param _gameId Game Id of which results has to be updated
     * @param _stockIds stock IDs in this game
     * @param _startGameStockPricesInWei Start Game Prices
     * @param _endGameStockPricesInWei End Game Prices
     * @param _winningStockId  if _winningStockId=0, consider game drawn, else it will be either _stockIds[0] or _stockIds[1]
     */
    function updateResults(
        uint256 _gameId,
        bytes12[2] memory _stockIds,
        uint256[2] memory _startGameStockPricesInWei,
        uint256[2] memory _endGameStockPricesInWei,
        bytes12 _winningStockId
    ) external onlyRole(OPERATOR_ROLE) {
        // CHECKS FOR UPDATING THE RESULTS

        if (head2headGames[_gameId].isGameDraw) {
            revert Head2Head__GameDraw();
        } else if (getGameStatus(_gameId) != GameStatus.ENDED) {
            revert Head2Head__GameNotEnded();
        } else if (
            _winningStockId != bytes12(0) &&
            !isStockInGame(_gameId, _winningStockId)
        ) {
            revert Head2Head__StockIdNotInGame(_gameId, _winningStockId);
        } else if (
            _startGameStockPricesInWei.length != 2 ||
            _endGameStockPricesInWei.length != 2 ||
            _stockIds.length != 2
        ) {
            revert Head2Head__ArrayLengthsMismatch();
        } else if (head2headGames[_gameId].rewardsDistributed) {
            revert Head2Head__RewardsAlreadyDistributed();
        }

        Head2HeadGame storage _head2headGames = head2headGames[_gameId];

        //UPDATE START AND END GAME STOCK PRICES AND WINNING STOCK ID
        for (uint256 i = 0; i < _stockIds.length; ++i) {
            _head2headGames.startGameStockPricesInWei[
                    _stockIds[i]
                ] = _startGameStockPricesInWei[i];
            _head2headGames.endGameStockPricesInWei[
                _stockIds[i]
            ] = _endGameStockPricesInWei[i];
        }

        _head2headGames.winningStockId = _winningStockId;

        emit Head2HeadPricesUpdated(
            _gameId,
            _stockIds,
            _startGameStockPricesInWei,
            _endGameStockPricesInWei
        );
        emit Head2HeadWinningStockUpdated(_gameId, _winningStockId);
    }

    /**
     * @notice Distribute Rewards for this game ID
     * @dev Revert
     * Revert if game is forfeited ,
     * Revert when rewards are already distributed ,
     * Revert when winning stock is not calculated for this game ID ,
     * Revert when length is mismatch for given arrays ,
     * Revert when game is not ended ,
     * Emit event
     * @param _gameId Game ID of which rewards has to be distributed
     */
    function rewardDistribution(uint256 _gameId)
        external
        onlyRole(OPERATOR_ROLE)
    {
        bytes12 winningStockId = head2headGames[_gameId].winningStockId;
        bytes12[2] memory stockIds = getInGameStockIds(_gameId);
        // SUFFICIEND CHECK FOR DISTRIBUTING REWARDS
        if (
            head2headGames[_gameId].startGameStockPricesInWei[stockIds[0]] == 0
        ) {
            revert Head2Head__ResultsNotUpdated();
        } else if (head2headGames[_gameId].isGameDraw) {
            revert Head2Head__GameDraw();
        } else if (head2headGames[_gameId].rewardsDistributed) {
            revert Head2Head__RewardsAlreadyDistributed();
        } else if (winningStockId == bytes12(0)) {
            gameDrawRevertBets(_gameId);
            return;
        }

        // UPDATE REWARD DISTRIBUTED STATUS FOR THIS GAME ID
        address payable[] memory betters = head2headGames[_gameId].betters;
        uint256 len = betters.length;
        head2headGames[_gameId].rewardsDistributed = true;

        // UPDATE BETTER'S INFO IF THEY WIN AND DISTRIBUTE REWARDS
        for (uint256 i = 0; i < len; ++i) {
            uint256 numOfBetsPlaced = bets[_gameId][betters[i]].length;
            for (uint256 j = 0; j < numOfBetsPlaced; ++j) {
                if (
                    (bets[_gameId][betters[i]][j].stockId) == (winningStockId)
                ) {
                    uint256 _betAmount = bets[_gameId][betters[i]][j].betAmount;
                    uint256 multiplier = bets[_gameId][betters[i]][j]
                        .multiplier;
                    uint256 _winAmount = (_betAmount * multiplier) / 1e18;
                    bets[_gameId][betters[i]][j].win = true;
                    bets[_gameId][betters[i]][j].winAmount = _winAmount;

                    // betters[i].transfer(_winAmount);
                    _safeTransferBNB(betters[i], _winAmount);
                    emit Head2HeadGameWinAmountSent(
                        _gameId,
                        betters[i],
                        winningStockId,
                        multiplier,
                        _winAmount
                    );
                }
            }
        }
    }

    // [address1 , address2] , [[1,2],[0,3,4]]
    function getWinParameters(uint256 _gameId, bytes12 winningStockId)
        external
        returns (address[] memory, uint256[][] memory)
    {
        // UPDATE REWARD DISTRIBUTED STATUS FOR THIS GAME ID
        address payable[] memory betters = head2headGames[_gameId].betters;
        uint256 len = betters.length;

        delete (temp_winners);
        delete (temp_winningBetsIndexes);

        for (uint256 i = 0; i < len; ++i) {
            uint256 numOfBetsPlaced = bets[_gameId][betters[i]].length;

            bool win = false;

            for (uint256 j = 0; j < numOfBetsPlaced; ++j) {
                if (
                    (bets[_gameId][betters[i]][j].stockId == winningStockId) &&
                    (!bets[_gameId][betters[i]][j].win)
                ) {
                    if (!win) {
                        win = true;
                        temp_winners.push(betters[i]);
                    }
                    temp_winningBetsIndexes[temp_winners.length].push(j);
                }
            }
        }

        return (temp_winners, temp_winningBetsIndexes);
    }

    /**
     * @notice Distribute Rewards for this game ID
     * @dev Revert
     * Revert if game is forfeited ,
     * Revert when rewards are already distributed ,
     * Revert when winning stock is not calculated for this game ID ,
     * Revert when length is mismatch for given arrays ,
     * Revert when game is not ended ,
     * Emit event
     * @param _gameId Game ID of which rewards has to be distributed
     * @param winners Array of winner addresses
     * @param _gameId winning Bets indexex of bets mapping
     */
    function distRewardParams(
        uint256 _gameId,
        address[] memory winners,
        uint256[][] memory winningBetsIndexes
    ) external {
        bytes12 winningStockId = head2headGames[_gameId].winningStockId;
        bytes12[2] memory stockIds = getInGameStockIds(_gameId);

        // SUFFICIEND CHECK FOR DISTRIBUTING REWARDS
        if (
            head2headGames[_gameId].startGameStockPricesInWei[stockIds[0]] == 0
        ) {
            revert Head2Head__ResultsNotUpdated();
        }
        if (head2headGames[_gameId].isGameDraw) {
            revert Head2Head__GameDraw();
        }

        // UPDATE BETTER'S INFO IF THEY WIN AND DISTRIBUTE REWARDS
        for (uint256 i = 0; i < winners.length; ++i) {
            uint256 numOfBetsPlaced = winningBetsIndexes[i].length;
            uint256[] memory winningBetsIndexes_ = winningBetsIndexes[i];

            for (uint256 j = 0; j < numOfBetsPlaced; ++j) {
                Head2HeadBet storage bet = bets[_gameId][winners[i]][
                    winningBetsIndexes_[j]
                ];

                if (bet.stockId == winningStockId && !bet.win) {
                    uint256 _betAmount = bet.betAmount;
                    uint256 multiplier = bet.multiplier;
                    uint256 _winAmount = (_betAmount * multiplier) / 1e18;
                    bet.win = true;
                    bet.winAmount = _winAmount;

                    // betters[i].transfer(_winAmount);
                    _safeTransferBNB(winners[i], _winAmount);
                    emit Head2HeadGameWinAmountSent(
                        _gameId,
                        winners[i],
                        winningStockId,
                        multiplier,
                        _winAmount
                    );
                }
            }
        }
    }

    /**
     * @notice when game drawn and return back bet amount of betters of given _gameId
     * @dev marks the gameId as draw
     * returns all the betters their betAmount
     * this function can be used when a game is drawn
     * @param _gameId Game id to be forfeited.
     */
    function gameDrawRevertBets(uint256 _gameId) public onlyRole(ADMIN_ROLE) {
        address payable[] memory betters = head2headGames[_gameId].betters;
        uint256 len = betters.length;
        // MARKING THE GAME AS DRAWN
        head2headGames[_gameId].isGameDraw = true;

        for (uint256 i = 0; i < len; ++i) {
            uint256 numOfBetsPlaced = bets[_gameId][betters[i]].length;
            for (uint256 j = 0; j < numOfBetsPlaced; ++j) {
                uint256 betAmount = bets[_gameId][betters[i]][j].betAmount;
                bytes12 stockId = bets[_gameId][betters[i]][j].stockId;
                // CHANGING BET AMOUNT TO 0
                bets[_gameId][betters[i]][j].betAmount = 0;
                // TRANSFERRING THE BETAMOUNT TO THE BETTER
                _safeTransferBNB(betters[i], betAmount);

                // EMIT EVENT FOR FUNDS WITHDRAWAL OF GAMEID, BETTER, BETTINGSTOCK, BETAMOUNT
                emit Head2HeadGameDrawRevertBets(
                    _gameId,
                    betters[i],
                    stockId,
                    betAmount
                );
            }
        }
    }

    function transferFundsToTreasury(uint256 amount)
        public
        onlyRole(ADMIN_ROLE)
    {
        uint256 balance = address(this).balance;
        require(balance >= amount, "Head2Head: Insufficient Balance");
        payable(address(treasuryContract)).transfer(amount);
    }

    function grantRole(address _address, bytes32 role)
        public
        onlyRole(ADMIN_ROLE)
    {
        _grantRole(role, _address);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    //** getter functions*/

    /**
     * @notice Return Game Status
     * @param _gameId Game ID to return status
     * @return status GameStatus Status of the game for given game ID
     */
    function getGameStatus(uint256 _gameId)
        public
        view
        returns (GameStatus status)
    {
        /**
         *  IF START__TIME IS ZERO THEN RETURN GAME STATUS AS NONEXISTENT
         *  ELSE IF CURR__TIME IS LESS THAN START__GAME THEN RETURN GAME STATUS AS CREATED
         *  ELSE IF CURR__TIME IS LESS THAN END__TIME THEN RETURN GAME STATUS AS STARTED
         *  ELSE RETURN GAMESTATUS AS ENDED
         */

        uint256 currentTimestamp = block.timestamp;
        uint256 startGameTimestamp = head2headGames[_gameId].timestamps[1];
        uint256 endGameTimestamp = head2headGames[_gameId].timestamps[2];

        if (startGameTimestamp == 0) {
            return GameStatus.NONEXISTENT;
        } else if (currentTimestamp < startGameTimestamp) {
            return GameStatus.CREATED;
        } else if (currentTimestamp < endGameTimestamp) {
            return GameStatus.STARTED;
        } else {
            return GameStatus.ENDED;
        }
    }

    /**
     * @notice Returns array of Bet struct of Better in given gameId
     * @param _gameId Game ID to return status
     * @param _better address of the better
     * @return Return Bet struct of Better
     */
    function getBetsOfUserInGameId(uint256 _gameId, address _better)
        public
        view
        returns (Head2HeadBet[] memory)
    {
        return bets[_gameId][_better];
    }

    /**
     * @notice Return end game stock price of given stockId
     * @param _gameId Game ID to return status
     * @param _stockId Id of the stock
     * @return Return end game stock price of given stockId
     */
    function getEndGameStockPriceOfStockId(uint256 _gameId, bytes12 _stockId)
        public
        view
        returns (uint256)
    {
        return head2headGames[_gameId].endGameStockPricesInWei[_stockId];
    }

    /**
     * @notice Return start game stock price of given stockId
     * @param _gameId Game ID to return status
     * @param _stockId Id of the stock
     * @return Return start game stock price of given stockId
     */
    function getStartGameStockPriceOfStockId(uint256 _gameId, bytes12 _stockId)
        public
        view
        returns (uint256)
    {
        return head2headGames[_gameId].startGameStockPricesInWei[_stockId];
    }

    /**
     * @notice Return if better in GameID
     * @param _gameId Game ID to return status
     * @param _better address of the better
     * @return Return if better in given GameID
     */

    function isBetterInGame(uint256 _gameId, address _better)
        public
        view
        returns (bool)
    {
        return bets[_gameId][_better].length > 0 ? true : false;
    }

    function getBetterGameIds(address _better)
        public
        view
        returns (uint256[] memory)
    {
        return betterGameIds[_better];
    }

    function getIndividualBetsInStocksOfGame(uint256 _gameId)
        public
        view
        returns (uint256[2] memory)
    {
        return head2headGames[_gameId].totalBetsInStocks;
    }

    function getGameBetters(
        uint256 _gameId,
        uint256 startIdx,
        uint256 endIdx
    ) public view returns (address payable[] memory) {
        // We have Dead Address at betters[0]
        uint256 totalNumberOfBetters = getTotalBettersInGame(_gameId);
        if (startIdx > endIdx || startIdx >= totalNumberOfBetters) {
            revert Head2Head__WrongIdxs(startIdx, endIdx);
        }
        address payable[] memory _betters = head2headGames[_gameId].betters;
        if (totalNumberOfBetters == 0) {
            return _betters;
        }
        if (totalNumberOfBetters - 1 < endIdx) {
            endIdx = totalNumberOfBetters - 1;
        }
        uint256 requiredLength = totalNumberOfBetters;
        address payable[] memory requiredBetters = new address payable[](
            requiredLength
        );
        uint256 curIdx = 0;
        for (uint256 i = startIdx; i <= endIdx; ++i) {
            requiredBetters[curIdx] = _betters[i];
            curIdx += 1;
        }
        return requiredBetters;
    }

    // function getGameBets(
    //     uint256 _gameId,
    //     uint256 startIdx,
    //     uint256 endIdx
    // ) public view returns (Head2HeadBet[] memory) {
    //     if (startIdx > endIdx) {
    //         revert Head2Head__WrongIdxs(startIdx, endIdx);
    //     }
    //     address payable[] memory _betters = head2headGames[_gameId].betters;
    //     uint256 totalNumberOfBetters = getTotalBettersInGame(_gameId);
    //     if (totalNumberOfBetters - 1 < endIdx) {
    //         endIdx = totalNumberOfBetters - 1;
    //     }
    //     uint256 requiredLength = endIdx - startIdx + 1;
    //     Head2HeadBet[] memory requiredBets = new Head2HeadBet[](requiredLength);
    //     uint256 curIdx = 0;
    //     for (uint256 i = startIdx; i <= endIdx; ++i) {
    //         requiredBets[curIdx] = bets[_gameId][_betters[i]];
    //         curIdx += 1;
    //     }
    //     return requiredBets;
    // }
    function getTimestampsOfGame(uint256 _gameId)
        public
        view
        returns (uint256[3] memory)
    {
        return head2headGames[_gameId].timestamps;
    }

    function getMinMaxBetsOfGame(uint256 _gameId)
        public
        view
        returns (uint256[2] memory)
    {
        return head2headGames[_gameId].minMaxBetsInWei;
    }

    function getTotalBetsOfBetter(uint256 _gameId, address _better)
        public
        view
        returns (uint256)
    {
        return bets[_gameId][_better].length;
    }

    function isStockInGame(uint256 _gameId, bytes12 _stockId)
        public
        view
        returns (bool)
    {
        bytes12[2] memory stocksInGame = head2headGames[_gameId].stockIds;
        if (_stockId == stocksInGame[0] || _stockId == stocksInGame[1]) {
            return true;
        }
        return false;
    }

    function getTotalBettersInGame(uint256 _gameId)
        public
        view
        returns (uint256)
    {
        return head2headGames[_gameId].betters.length;
    }

    function getInGameStockIds(uint256 _gameId)
        public
        view
        returns (bytes12[2] memory)
    {
        return head2headGames[_gameId].stockIds;
    }

    function getInGameStockSymbols(uint256 _gameId)
        public
        view
        returns (string[2] memory)
    {
        return head2headGames[_gameId].stockSymbols;
    }

    function getCurrentMulOfStock(uint256 _gameId, bytes12 _stockId)
        public
        view
        returns (uint256)
    {
        if (head2headGames[_gameId].stockIds[0] == _stockId) {
            return head2headGames[_gameId].curMultiplierStocks[0];
        } else {
            return head2headGames[_gameId].curMultiplierStocks[1];
        }
    }

    // INTERNAL FUNCTIONS

    /**
     * @notice Transfer BNB in a safe way
     * @param to: address to transfer BNB to
     * @param value: BNB amount to transfer (in wei)
     */
    function _safeTransferBNB(address to, uint256 value) internal {
        uint256 contractBalance = address(this).balance;
        if (value > contractBalance) {
            treasuryContract.withdrawFunds(value - contractBalance);
        }
        (bool success, ) = to.call{value: value}("");
        if (!success) {
            revert Head2Head__BNBTransferFailed(to, value);
        }
    }

    /**
     * @notice Returns the latest price of BNB in USD
     */
    function getLatestPrice() internal view returns (int256) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
        // return 303 * 1e8;
    }

    /**
     * @notice Update the new Odds for both the stocks
     * @param _gameId GameId to update
     * @param totalBetsInStock0 total bets pooled in stock0
     * @param totalBetsInStock1 total bets pooled in stock1
     */
    function updateCurrentOdds(
        uint256 _gameId,
        uint256 totalBetsInStock0,
        uint256 totalBetsInStock1
    ) internal {
        uint256 totalBets = totalBetsInStock0 + totalBetsInStock1;
        uint256 stock0Percent = ((totalBetsInStock0 * 1e18) / totalBets);
        uint256 stock1Percent = ((totalBetsInStock1 * 1e18) / totalBets);
        uint256 newOddsStock0 = ((24 * 1e18) - (13 * stock0Percent)) / 10;
        uint256 newOddsStock1 = ((24 * 1e18) - (13 * stock1Percent)) / 10;

        head2headGames[_gameId].curMultiplierStocks[0] = newOddsStock0;
        head2headGames[_gameId].curMultiplierStocks[1] = newOddsStock1;
        emit Head2HeadOddsUpdated(_gameId, newOddsStock0, newOddsStock1);
    }
}