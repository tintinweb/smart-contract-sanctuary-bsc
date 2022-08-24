pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./INoftToken.sol";
import "./INoftExp.sol";
import "./INoftPrizePool.sol";

contract NoftGameManagerV5  is Initializable, AccessControl {
    using SafeMath for uint256;
    bytes32 public constant OWNER_ROLE = keccak256("OWNER");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER");
    bytes32 public constant SERVER_ROLE = keccak256("SERVER");

    address payable wallet;
    address manager;
    address token;
    address rentAddress;
    address serverAddress;
    INoftToken tokenContract;
    INoftExp expContract;
    INoftPrizePool prizePoolContract;

    uint incrementPlayerId;

    struct Player {
        uint playerId;
        address payable account;
        uint tokenId;
        bool isRent;
        uint strategyId;
    }

    enum GameStatus {
        STARTED,
        ENDED,
        CANCELLED,
        PICKED
    }

    struct Game {
        uint gameId;
        GameStatus status;
        uint[] playerIds;
        uint gameFee;
        uint[] winnerIds;
        uint bank;
        uint playersCount;
        uint seed;
        bool onlyOwn;
        uint[] winPercentages;
        uint minLvl;
        uint maxLvl;
    }

    mapping(uint => Game) games;
    mapping(uint => Player) players;
    mapping(uint => uint) levelsMap;

    modifier onlyOwnerOrManager() {
        require(hasRole(MANAGER_ROLE, _msgSender()) || hasRole(OWNER_ROLE, _msgSender()));
        _;
    }


    modifier onlyOwnerOrManagerOrServer() {
        require(hasRole(MANAGER_ROLE, _msgSender()) || hasRole(OWNER_ROLE, _msgSender()) || hasRole(SERVER_ROLE, _msgSender()));
        _;
    }

    modifier onlyOwner {
        require(hasRole(OWNER_ROLE, _msgSender()));
        _;
    }

    event GameStatusChanged(uint indexed gameId, GameStatus indexed status);

    event PlayerChanged(address indexed account, uint indexed gameId, uint indexed playerId);

    constructor(

    ) {

    }

    function initialize(
        address _token,
        address payable _wallet,
        address _manager,
        address _rentAddress,
        address _expAddress,
        address _prizePoolAddress,
        address _server
    ) public initializer {
        wallet = _wallet;
        manager = _manager;
        token = _token;
        rentAddress = _rentAddress;
        tokenContract = INoftToken(_token);
        expContract = INoftExp(_expAddress);
        prizePoolContract = INoftPrizePool(_prizePoolAddress);
        _setupRole(OWNER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, manager);
        _setupRole(SERVER_ROLE, _server);
        serverAddress = _server;
        incrementPlayerId = 1;

        levelsMap[0] = 0;
        levelsMap[1] = 1500;
        levelsMap[2] = 6000;
        levelsMap[3] = 10000;
        levelsMap[4] = 15000;
        levelsMap[5] = 20000;
    }


    function startGame(
        uint gameId,
        uint playersCount,
        uint fee,
        uint bank,
        bool onlyOwn,
        uint[] calldata winPercentages,
        uint minLvl,
        uint maxLvl
    ) external onlyOwnerOrManagerOrServer {
        require(gameId > 0 && games[gameId].gameId == 0);
        require((fee == 0 && bank > 0) || (fee > 0 && bank == 0));

        games[gameId] = Game(
            gameId,
            GameStatus.STARTED,
            new uint[](0),
            fee,
            new uint[](0),
            bank,
            playersCount,
            bytesToUint(keccak256(abi.encodePacked(blockhash(block.number - 1), gameId))),
            onlyOwn,
            winPercentages,
            minLvl,
            maxLvl
        );

        emit GameStatusChanged(gameId, GameStatus.STARTED);
    }

    function addPlayer(uint tokenId, uint gameId, uint strategyId) external payable returns (uint playerId) {
        require(gameId != 0);
        Game memory game = games[gameId];
        bool isRent = tokenContract.ownerOf(tokenId) == rentAddress;
        bool isOwn = tokenContract.ownerOf(tokenId) == _msgSender();
        (, , , , , , INoftToken.Ranks rank) = tokenContract.getToken(tokenId);
        uint exp = expContract.getTokenExp(tokenId);

        require(game.playerIds.length < game.playersCount);
        require(game.onlyOwn ? isOwn : (isOwn || isRent));
        require(game.gameFee == msg.value);
        require(game.status == GameStatus.STARTED);
        require(exp >= levelsMap[game.minLvl] && exp < levelsMap[game.maxLvl]);
        require(!isRent || uint(rank) < 3);

        for (uint i = 0; i < game.playerIds.length; i++) {
            require(players[game.playerIds[i]].tokenId != tokenId);
        }

        playerId = incrementPlayerId++;

        players[playerId] = Player(playerId, payable(_msgSender()), tokenId, isRent, strategyId);

        games[gameId].playerIds.push(playerId);
        games[gameId].bank = games[gameId].bank.add(msg.value);

        emit PlayerChanged(_msgSender(), gameId, playerId);
    }

    function stopPick(uint gameId) external onlyOwnerOrManagerOrServer {
        Game memory game = games[gameId];
        require(game.status == GameStatus.STARTED);
        require(game.playerIds.length >= 3);

        games[gameId].status = GameStatus.PICKED;
        emit GameStatusChanged(gameId, GameStatus.PICKED);
    }

    function endGame(
        uint gameId,
        uint[] calldata winnerIds
    ) external {
        Game memory game = games[gameId];
        require(game.status == GameStatus.PICKED);
        require(winnerIds.length == game.winPercentages.length);

        uint bank = game.bank;

        for (uint i = 0; i < winnerIds.length; i++) {
            Player memory winner = players[winnerIds[i]];

            uint winnerPrize = game.bank.div(100).mul(game.winPercentages[i]);

            bank = bank.sub(winnerPrize);
            if (game.gameFee == 0) {
                prizePoolContract.sendPrize(winner.account, winnerPrize);
            } else {
                winner.account.transfer(winnerPrize);
            }

            games[gameId].winnerIds.push(winnerIds[i]);
            games[gameId].status = GameStatus.ENDED;

            emit PlayerChanged(_msgSender(), gameId, winnerIds[i]);
        }

        if (game.gameFee > 0) {
            wallet.transfer(bank);
        }

        emit GameStatusChanged(gameId, GameStatus.ENDED);
    }

    function removePlayer(uint gameId, uint playerId) internal {
        Player memory player = players[playerId];
        Game memory game = games[gameId];

        uint playersCount = game.playerIds.length;
        uint playerIdx = playersCount;

        for (uint i = 0; i < playersCount - 1; i++) {
            if (game.playerIds[i] == playerId) {
                playerIdx = i;
            }
            if (playerIdx < playersCount) {
                game.playerIds[i] = game.playerIds[i + 1];
            }
        }

        games[gameId].playerIds.pop();

        if (game.gameFee > 0) {
            payable(address(this)).transfer(game.gameFee);
        }

        emit PlayerChanged(player.account, gameId, playerId);
    }

    function cancelGame(uint gameId) external onlyOwnerOrManagerOrServer {
        Game memory game = games[gameId];
        require(game.status != GameStatus.ENDED && game.status != GameStatus.CANCELLED);
        require(game.gameId != 0);
        if (game.gameFee > 0) {
            uint playersCount = game.playerIds.length;
            if (playersCount > 0) {
                for (uint i = playersCount - 1; i > 0; i--) {
                    removePlayer(gameId, game.playerIds[i]);
                }
                removePlayer(gameId, game.playerIds[0]);
            }
        }

        games[gameId].status = GameStatus.CANCELLED;

        emit GameStatusChanged(gameId, GameStatus.CANCELLED);
    }

    function setWallet(address payable newWallet) external onlyOwnerOrManager {
        wallet = newWallet;
    }

    function setManager(address _manager) external onlyOwner {
        manager = _manager;
        grantRole(MANAGER_ROLE, manager);
    }

    function setToken(address _token) external onlyOwnerOrManager {
        token = _token;
        tokenContract = INoftToken(token);
    }

    function setExpContract(address _address) external onlyOwnerOrManager {
        expContract = INoftExp(_address);
    }

    function setPrizePoolContract(address _address) external onlyOwnerOrManager {
        prizePoolContract = INoftPrizePool(_address);
    }

    function setServer(address _server) external onlyOwnerOrManager {
        serverAddress = _server;
        grantRole(SERVER_ROLE, serverAddress);
    }

    function setLevel(uint level, uint exp) external onlyOwnerOrManager {
        levelsMap[level] = exp;
    }

    function getGameWinner(uint _gameId, uint index) external view returns (uint) {
        return games[_gameId].winnerIds[index];
    }

    function getGameWinPercentage(uint _gameId, uint index) external view returns (uint) {
        return games[_gameId].winPercentages[index];
    }

    function getGame(uint _gameId) external view returns (
        uint gameId,
        GameStatus status,
        uint gameFee,
        uint bank,
        uint playersCount,
        uint currentPlayerCount,
        uint seed,
        bool onlyOwn,
        uint minLvl,
        uint maxLvl
    ) {
        Game memory game = games[_gameId];

        gameId = game.gameId;
        status = game.status;
        gameFee = game.gameFee;
        bank = game.bank;
        playersCount = game.playersCount;
        currentPlayerCount = game.playerIds.length;
        seed = game.seed;
        onlyOwn = game.onlyOwn;
        minLvl = game.minLvl;
        maxLvl = game.maxLvl;
    }

    function getPlayer(uint _playerId) external view returns (
        uint playerId,
        address account,
        uint tokenId,
        bool isRent,
        uint strategyId
    ) {
        Player memory player = players[_playerId];

        playerId = player.playerId;
        account = player.account;
        tokenId = player.tokenId;
        isRent = player.isRent;
        strategyId = player.strategyId;
    }

    function getGamePlayer(uint gameId, uint index) external view returns (
        uint playerId,
        address account,
        uint tokenId,
        bool isRent,
        uint strategyId
    ) {
        Game memory game = games[gameId];
        Player memory player = players[game.playerIds[index]];

        playerId = player.playerId;
        account = player.account;
        tokenId = player.tokenId;
        isRent = player.isRent;
        strategyId = player.strategyId;
    }

    function getWallet() external view returns (address) {
        return wallet;
    }

    function getManager() external view returns (address) {
        return manager;
    }

    function getTokenAddress() external view returns (address) {
        return token;
    }

    function getServerAddress() external view returns (address) {
        return serverAddress;
    }

    function getRentAddress() external view returns (address) {
        return rentAddress;
    }

    function bytesToUint(bytes32 b) internal pure returns (uint number){
        number = 0;
        for (uint i = 0; i < b.length; i++) {
            number = number.add(uint(uint8(b[i])) * (2 ** (8 * (b.length - (i + 1)))));
        }
    }
}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INoftToken is IERC721 {

    struct Application {
        address sender;
        uint code;
        bool approved;
        bool created;
        uint genes;
        uint attempt;
    }

    struct TokenData {
        uint id;
        uint exp;
        uint genes;
        uint generation;
        bool custom;
    }

    enum Ranks {
        CIVILIAN, RECRUIT, WARRIOR, HERO, LEGENDARY_HERO, MYSTICAL_HERO
    }

    function getToken(uint tokenId) external view returns (uint id, uint exp, uint genes, uint generation, bool custom, uint rating, Ranks rank);

    function getGeneration() external view returns (uint);

    function getLastTokenId() external view returns (uint);

    function mint(address to, uint count) external;

    function nextGeneration() external;

    function updateExp(uint[] calldata tokenIds, uint[] calldata values) external;

    function setManager(address _manager) external;

    function setMatchManager(address _matchManager) external;

    function setMarketplace(address _marketplace) external;

    function getTokenRating(uint genes) external view returns (uint rate);

    function getTokenRank(uint rate) external view returns (Ranks);

    function setBaseURI(string memory uri) external;

    function getManager() external view returns (address);

    function getMatchManager() external view returns (address);

    function getMarketplace() external view returns (address);

    function getRankRate(uint rank) external view returns (uint);

    function getGenerationTokenMin() external view returns (uint);

    function getGenerationTokenMax() external view returns (uint);

    function tokensInCurrentGeneration() external view returns (uint);

    function getApplication(uint applicationCode) external view returns (
        address sender,
        uint code,
        bool approved,
        bool created,
        uint genes,
        uint attempt
    );

    function generateGenesByApplication(uint code, address from) external;

    function approveApplication(uint code, bool approved) external;

    function createApplication(uint code, address from) external;

    function mintByApplication(uint code, bool custom, address from) external;
}

pragma solidity ^0.8.0;

interface INoftPrizePool {
    function addPrizePool() external;

    function returnPrizePool() external;

    function sendPrize(address payable receiver, uint value) external;

    function getManager() external view returns (address);

    function getGameManager() external view returns (address);

    function getBank() external view returns (uint);

    function setManager(address _manager) external;

    function setGameManagerAddress(address _gameManagerAddress) external;
}

pragma solidity ^0.8.0;

interface INoftExp {
    event ExpUpdated(uint indexed id);

    function updateExp(uint[] calldata tokenIds, uint[] calldata values) external;

    function getTokenExp(uint tokenId) external view returns (uint);

    function setManager(address _manager) external;

    function setServer(address _server) external;

    function getManager() external view returns (address);

    function getServerAddress() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.0;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

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
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

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
     * bearer except when using {_setupRole}.
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
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");

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
    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}