pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./INoftToken.sol";
import "./INoftExp.sol";
import "./INoftPrizePool.sol";

contract NoftGameManagerV3 is Ownable {
    using SafeMath for uint256;

    address payable wallet;
    address manager;
    address token;
    address rentAddress;
    address serverAddress;
    INoftToken tokenContract;
    INoftExp expContract;
    INoftPrizePool prizePoolContract;

    uint RENT_EXP_THRESHOLD = 100000;
    uint incrementPlayerId = 1;

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
    }

    mapping(uint => Game) games;
    mapping(uint => Player) players;

    modifier onlyOwnerOrManager() {
        require(_msgSender() == owner() || manager == _msgSender());
        _;
    }

    modifier onlyOwnerOrManagerOrServer() {
        require(_msgSender() == owner() || manager == _msgSender() || serverAddress == _msgSender());
        _;
    }

    event GameStatusChanged(uint indexed gameId, GameStatus indexed status);

    event PlayerChanged(address indexed account, uint indexed gameId, uint indexed playerId);

    constructor(
        address _token,
        address payable _wallet,
        address _manager,
        address _rentAddress,
        address _expAddress,
        address _prizePoolAddress
    ) {
        wallet = _wallet;
        manager = _manager;
        token = _token;
        rentAddress = _rentAddress;
        tokenContract = INoftToken(_token);
        expContract = INoftExp(_expAddress);
        prizePoolContract = INoftPrizePool(_prizePoolAddress);
    }

    function startGame(
        uint gameId,
        uint playersCount,
        uint fee,
        uint bank,
        bool onlyOwn,
        uint[] calldata winPercentages
    ) external onlyOwnerOrManagerOrServer {
        require(gameId > 0 && games[gameId].gameId == 0);
        require(fee == 0 || bank == 0);

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
            winPercentages
        );

        emit GameStatusChanged(gameId, GameStatus.STARTED);
    }

    function addPlayer(uint tokenId, uint gameId, uint strategyId) external payable returns (uint playerId) {
        require(gameId != 0);
        Game memory game = games[gameId];
        uint tokenExp = expContract.getTokenExp(tokenId);
        bool isRent = tokenContract.ownerOf(tokenId) == rentAddress;
        bool isOwn = tokenContract.ownerOf(tokenId) == _msgSender();
        (, , , , , , INoftToken.Ranks rank) = tokenContract.getToken(tokenId);

        require(game.onlyOwn ? isOwn : (isOwn || isRent));
        require(game.gameFee == msg.value);
        require(game.status == GameStatus.STARTED);
        require(!isRent || (uint(rank) <= 2 && tokenExp <= RENT_EXP_THRESHOLD));

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
        uint[] calldata winnerIds,
        uint[]  calldata tokenIds,
        uint[] calldata exps
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

        require(exps.length == tokenIds.length);
        expContract.updateExp(tokenIds, exps);

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
        payable(address(this)).transfer(game.gameFee);

        emit PlayerChanged(player.account, gameId, playerId);
    }

    function cancelGame(uint gameId) external onlyOwnerOrManagerOrServer {
        Game memory game = games[gameId];
        require(game.status != GameStatus.ENDED && game.status != GameStatus.CANCELLED);

        uint playersCount = game.playerIds.length;
        if (playersCount > 0) {
            for (uint i = playersCount - 1; i > 0; i--) {
                removePlayer(gameId, game.playerIds[i]);
            }
            removePlayer(gameId, game.playerIds[0]);
        }

        games[gameId].status = GameStatus.CANCELLED;

        emit GameStatusChanged(gameId, GameStatus.CANCELLED);
    }

    function setWallet(address payable newWallet) external onlyOwnerOrManager {
        wallet = newWallet;
    }

    function setManager(address _manager) external onlyOwner {
        manager = _manager;
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
    }

    function setRentThreshold(uint _threshold) external onlyOwnerOrManager {
        RENT_EXP_THRESHOLD = _threshold;
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
        bool onlyOwn
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

    function getRentThreshold() external view returns (uint) {
        return RENT_EXP_THRESHOLD;
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

pragma solidity ^0.8.0;

import "../utils/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}