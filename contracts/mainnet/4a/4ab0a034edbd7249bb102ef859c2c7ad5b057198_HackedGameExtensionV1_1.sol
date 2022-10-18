// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HackedGameV1.sol";

contract HackedGameExtensionV1_1 is HackedGameV1, HackedGameExtension {

    constructor() HackedGameV1(address(0),address(0),address(0),address(0), 0, "", 0, 0) {
    }

    function onRoundRequested(uint256 tokenId, address user) external virtual override {}

    function onRoundFinished(uint256) external virtual override {
        (
            uint256 gameId,
            uint256 roundId,
            uint256 pattern,
            uint256 patternMask,
            uint256 lastPattern,
            uint256 lastPatternMask,
            uint256 lastSymbols,
            uint256 roundStartedAt
        ) = _decodeGameState();

        // fix roundStartedAt in first round
        if (roundId == 1) {
            roundStartedAt -= roundDuration;
            _encodeGameState(gameId, roundId, pattern, patternMask, lastPattern, lastPatternMask, lastSymbols, roundStartedAt);
        }
    }

    function onReentered(uint256 tokenId) external virtual override {
        // allow 1-1 to reenter for free
        if (tokenId == 291 || tokenId == 542 || tokenId == 659 || tokenId == 702 || tokenId == 868 
            || tokenId == 1072 || tokenId == 1197 || tokenId == 1848 || tokenId == 1991 || tokenId == 2013) {
            address user = _ownerOfToken(tokenId);
            (uint256 tier,) = _getTierAndReentries(user);
            uint256 fees = _getFees(user, tokenId, tier);
            payable(user).transfer(fees);
        }
    }

    function onGameStarted() external virtual override {}

    function onGameCompleted(uint256 tokenId) external virtual override {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

import "./HackedGameBase.sol";
import "./StakingTierProvider.sol";
import "./ReentryProvider.sol";
import "../utils/Recoverable.sol";


contract HackedGameV1 is HackedGameBase, StakingTierProvider, ReentryProvider, VRFConsumerBaseV2, Recoverable, Pausable {

    event GameComplete(uint256 indexed gameId, uint256 indexed tokenId, address indexed winner, uint256 prize);
    event GameStarted(uint256 indexed gameId);
    event RoundRequested(uint256 indexed gameId, uint256 indexed roundId, address indexed executor, uint256 tokenId);
    event RoundCompleted(uint256 indexed gameId, uint256 indexed roundId);

    struct VRFConfig {
        bytes32 keyHash;
        uint16 requestConfirmations;
        uint32 callbackGasLimit;
        uint64 subscriptionId;
    }

    VRFCoordinatorV2Interface private immutable vrfCoordinator;
    VRFConfig private vrfConfig;

    address immutable public hacked;
    address immutable public hackedStaked;
    address immutable public stakingContract;
    uint256 public feeReenterStaked = 0.005 ether;
    uint256 public feeReenterStakedTier4 = 0.01 ether;
    uint256 public feeReenter = 0.01 ether;
    uint256 public feeReenterTier4 = 0.015 ether;
    uint256 public feePercent = 10;
    address public feeWallet = 0x86EC34C96D006e99433909dAc627B747BED372e5;
    uint256 public roundDuration = 24 hours;

    mapping(uint256 => uint256) public requestIds;
    mapping(uint256 => mapping(uint256 => uint256)) public roundRequests;
    mapping(address => bool) public authorized;


    modifier onlyAuthorized() {
        require(msg.sender == owner() || authorized[msg.sender], "Not authorized");
        _;
    }

    modifier isInitialized() {
        ( ,uint256 defaultSymbols,,) = _decodeTokenState(LAST_TOKEN_ID);
        require(defaultSymbols != 0, "Not initialized");
        _;
    }

    constructor(
        address _hacked, 
        address _hackedStaked, 
        address _stakingContract,
        address _vrfCoordinator,
        uint64 _vrfSubscriptionId,
        bytes32 _vrfKeyHash,
        uint32 _vrfCallbackGasLimit,
        uint16 _vrfRequestConfirmations
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        hacked = _hacked;
        hackedStaked = _hackedStaked;
        stakingContract = _stakingContract;

        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        vrfConfig = VRFConfig({
            subscriptionId: _vrfSubscriptionId,
            keyHash: _vrfKeyHash,
            callbackGasLimit: _vrfCallbackGasLimit,
            requestConfirmations: _vrfRequestConfirmations
        });
    }

    // solhint-disable no-empty-blocks
    receive() external payable {} 

    function initializeState(uint256 tokenId, uint256 length) external onlyOwner {
        uint256 limit = tokenId + length;
        if (limit > LAST_TOKEN_ID + 1) {
            limit = LAST_TOKEN_ID + 1;
        }

        uint256 lastSymbol = 0;
        if (tokenId != 1) {
            ( ,uint256 _defaultSymbols,,) = _decodeTokenState(tokenId-1);
            require(_defaultSymbols != 0, "Previous state not set");
            lastSymbol = _defaultSymbols;
        } 
        ( ,uint256 defaultSymbols,,) = _decodeTokenState(tokenId);
        require(defaultSymbols == 0, "State already set");

        for (; tokenId < limit; ++tokenId) {
            lastSymbol = _nextRandom(lastSymbol);
            _encodeTokenState(tokenId, 0, lastSymbol, 0, 0);
            _encodeSymbolState(lastSymbol, type(uint16).max, tokenId);
        }
    }

    function configureVRF(
        uint64 _vrfSubscriptionId,
        bytes32 _vrfKeyHash,
        uint16 _vrfRequestConfirmations,
        uint32 _vrfCallbackGasLimit
    ) external onlyOwner {
        VRFConfig storage vrf = vrfConfig;
        vrf.subscriptionId = _vrfSubscriptionId;
        vrf.keyHash = _vrfKeyHash;
        vrf.requestConfirmations = _vrfRequestConfirmations;
        vrf.callbackGasLimit = _vrfCallbackGasLimit;
    }

    function setFees(uint256 _feeReenterStaked, uint256 _feeReenterStakedTier4, uint256 _feeReenter, uint256 _feeReenterTier4) external onlyOwner {
        feeReenterStaked = _feeReenterStaked;
        feeReenterStakedTier4 = _feeReenterStakedTier4;
        feeReenter = _feeReenter;
        feeReenterTier4 = _feeReenterTier4;
    }

    function setRoundDuration(uint256 duration) external onlyOwner {
        roundDuration = duration;
    }

    function setFeeReceiver(uint256 _feePercent, address _feeWallet) external onlyOwner {
        require(_feePercent <= 100, "Invalid fees");
        feePercent = _feePercent;
        feeWallet = _feeWallet;
    }

    function pause() external whenNotPaused onlyAuthorized {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }

    function authorize(address user) external onlyOwner {
        authorized[user] = true;
    }

    function revokeAuthorization(address user) external onlyOwner {
        authorized[user] = false;
    }

    function upgradeTierProvider(address provider) external onlyOwner {
        _upgradeTierProvider(provider);
    }

    function upgrateReentriesProvider(address provider) external onlyOwner {
        _upgradeReentriesProvider(provider);
    }
    
    function upgrateExtension(address extension) external onlyOwner {
        _setExtension(extension);
    }


    function startGame(uint256 startAt) external onlyAuthorized isInitialized {
        (
            uint256 gameId, uint256 roundId,,,,,,
        ) = _decodeGameState();

        require(gameId == 0 || roundId == BITS+1, "Game not complete");
        _initializeGame(startAt);

        emit GameStarted(gameId+1);
    }

    function drawRound(uint256 tokenId) external whenNotPaused {
        (uint256 gameId,uint256 roundId,,,,,,uint256 roundStartedAt) = _decodeGameState();
        require(gameId != 0, "No game yet");
        require(tokenId == 0 || _ownerOfToken(tokenId) == msg.sender, "Not owner of token");
        require(block.timestamp > roundStartedAt + (roundId == 0 ? 0 : roundDuration), "Round no finished");
        emit RoundRequested(gameId, roundId, msg.sender, tokenId);
        _requestRandomness(gameId, roundId);

        _onRoundRequested(tokenId, msg.sender);
    }

    function reenter(uint256[] calldata tokenIds) external payable whenNotPaused {
        (
            uint256 gameId,
            uint256 roundId,
            uint256 pattern,
            uint256 patternMask,
            uint256 lastPattern,
            uint256 lastPatternMask,
            uint256 lastSymbols,
            uint256 roundStartedAt
        ) = _decodeGameState();
        require(gameId != 0, "No game yet");

        uint256 tokenId;
        (uint256 tier, uint256 reentriesMax) = _getTierAndReentries(msg.sender);
        uint256 fees;

        require(tokenIds.length > 0, "Invalid length");
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            tokenId = tokenIds[i];
            fees += _getFees(msg.sender, tokenId, tier);
            lastSymbols = _reenter(tokenId, reentriesMax, gameId, pattern, patternMask, lastPatternMask, lastSymbols);
        }
        require(fees == msg.value, "Invalid fees");

        _encodeGameState(gameId, roundId, pattern, patternMask, lastPattern, lastPatternMask, lastSymbols, roundStartedAt);
    }

    function completeGame() external whenNotPaused {
        (uint256 tokenId, uint256 matches) = _getMatchingTokenTokenIds();
        require(matches == 1, "No winner yet");

        (
            uint256 gameId,
            ,
            uint256 pattern,
            uint256 patternMask,
            uint256 lastPattern,
            uint256 lastPatternMask,
            uint256 lastSymbols,
            uint256 roundStartedAt
        ) = _decodeGameState();
        require(gameId != 0, "No game yet");

        _encodeGameState(gameId, BITS+1, pattern, patternMask, lastPattern, lastPatternMask, lastSymbols, roundStartedAt);

        address winner = _ownerOfToken(tokenId);
        uint256 prize = address(this).balance;
        uint256 fee = prize * feePercent / 100;

        payable(feeWallet).transfer(fee);
        payable(winner).transfer(prize - fee);

        _onGameCompleted(tokenId);

        emit GameComplete(gameId, tokenId, winner, prize-fee);
    }

    // In case of some erronous state, let admin complete the current game.
    function forceCompleteGame() external onlyOwner {
        (
            uint256 gameId,
            ,
            uint256 pattern,
            uint256 patternMask,
            uint256 lastPattern,
            uint256 lastPatternMask,
            uint256 lastSymbols,
            uint256 roundStartedAt
        ) = _decodeGameState();
        require(gameId != 0, "No game yet");

        _encodeGameState(gameId, BITS+1, pattern, patternMask, lastPattern, lastPatternMask, lastSymbols, roundStartedAt);

        _onGameCompleted(0);

        emit GameComplete(gameId, 0, address(0), 0);
    }

    function matchingTokensLeft() external view returns (uint256) {
        (,uint256 matches) = _getMatchingTokenTokenIds();
        return matches;
    }

    function allMatchingTokensLeft() external view returns (uint256[] memory, uint256) {
        return _getAllMatchingTokenTokenIds();
    }

    function nextRoundAt() external view returns (uint256) {
        (,uint256 roundId,,,,,,uint256 roundStartedAt) = _decodeGameState();
        return (roundStartedAt + (roundId == 0 ? 0 : roundDuration));
    }

    function canRequestDraw() external view returns (bool) {
        (uint256 gameId, uint256 roundId,,,,,,uint256 roundStartedAt) = _decodeGameState();
        return block.timestamp > (roundStartedAt + (roundId == 0 ? 0 : roundDuration))
            && roundRequests[gameId][roundId] == 0;
    }

    function drawRequested() external view returns (bool) {
        (uint256 gameId, uint256 roundId,,,,,,) = _decodeGameState();
        return roundRequests[gameId][roundId] != 0;
    }

    function canReenter(address owner, uint256[] calldata tokenIds) external view returns (bool[] memory possible, string[] memory reason, uint256[] memory fees) {
        (
            uint256 gameId,
            ,
            uint256 pattern,
            uint256 patternMask,
            ,
            uint256 lastPatternMask,
            uint256 symbols,
        ) = _decodeGameState();

        uint256 tokenId;
        (uint256 tier, uint256 reentriesMax) = _getTierAndReentries(owner);

        possible = new bool[](tokenIds.length);
        reason = new string[](tokenIds.length);
        fees = new uint256[](tokenIds.length);

        require(tokenIds.length > 0, "Invalid length");
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            tokenId = tokenIds[i];
            fees[i] += _getFees(owner, tokenId, tier);
            (bool _canEnter, uint256 _nextSymbols, string memory _reason) = _canReenter(tokenId, reentriesMax, gameId, pattern, patternMask, lastPatternMask, symbols);
            if (_canEnter) {
                symbols = _nextSymbols;
            }
            possible[i] = _canEnter;
            reason[i] = _reason;
        }
    }

    function fulfillRandomWordsFallback(uint256 requestId, uint256[] memory randomWords)
        external
        onlyOwner
    {
        require(randomWords.length == 1, "Invalid length");
        _drawRound(requestId, randomWords[0]);
    }

    function _requestRandomness(uint256 gameId, uint256 roundId) internal {
        require(roundRequests[gameId][roundId] == 0, "Already requested");
        VRFConfig memory vrf = vrfConfig;
        uint256 vrfRequestId = vrfCoordinator.requestRandomWords(
            vrf.keyHash,
            vrf.subscriptionId,
            vrf.requestConfirmations,
            vrf.callbackGasLimit,
            1
        );
        roundRequests[gameId][roundId] = vrfRequestId;
        requestIds[vrfRequestId] = roundId;
    }

    /**
     * @notice Callback function used by VRF Coordinator
     * @dev The VRF Coordinator will only send this function verified responses.
     * @dev The VRF Coordinator will not pass randomness that could not be verified.
     */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        require(randomWords.length == 1, "Invalid length");
        _drawRound(requestId, randomWords[0]);
    }

    function _drawRound(uint256 requestId, uint256 random) internal {
        (uint256 gameId, uint256 roundId,,,,,,uint256 roundStartedAt) = _decodeGameState();
        uint256 _roundId = requestIds[requestId];
        require(_roundId == roundId, "round missmatch");
        requestIds[requestId] = 0;
        _round(random, roundStartedAt+roundDuration);
        emit RoundCompleted(gameId, roundId);
    }

    function _ownerOfToken(uint256 tokenId) internal view returns (address) {
        address owner = IERC721(hacked).ownerOf(tokenId);
        return owner == stakingContract ? IERC721(hackedStaked).ownerOf(tokenId) : owner;
    }

    function _getFees(address user, uint256 tokenId, uint256 tier) internal view returns (uint256) {
        address owner = IERC721(hacked).ownerOf(tokenId);
        if (user == owner) {
            return tier == 4 ? feeReenterTier4 : feeReenter;
        } else if (owner == stakingContract && IERC721(hackedStaked).ownerOf(tokenId) == user) {
            return tier == 4 ? feeReenterStakedTier4 : feeReenterStaked;
        }
        revert("Not owner of token");
    }

    function _getTierAndReentries(address owner) internal view returns (uint256 tier, uint256 reentriesMax) {
        tier = getTier(owner);
        reentriesMax = getReentries(owner, tier);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./HackedGameState.sol";
import "./RandomSequence.sol";

interface HackedGameExtension {
    function onRoundRequested(uint256 tokenId, address user) external;
    function onRoundFinished(uint256 random) external;
    function onReentered(uint256 tokenId) external;
    function onGameStarted() external;
    function onGameCompleted(uint256 tokenId) external;
}

contract HackedGameBase is HackedGameState, RandomSequence {
    using Address for address;

    address private extension;

    function _setExtension(address _extension) internal {
        extension = _extension;
    }

    function _initializeGame(uint256 startsAt) internal {
        (uint256 gameId,,,,,,,) = _decodeGameState();
        (,uint256 defaultSymbols,,) = _decodeTokenState(LAST_TOKEN_ID);
        _encodeGameState(gameId+1, 0, 0, 0, 0, 0, defaultSymbols, startsAt);

        if (extension != address(0)) extension.functionDelegateCall(abi.encodeWithSelector(HackedGameExtension(extension).onGameStarted.selector));
    }

    function _round(uint256 random, uint256 roundStartedAt) internal {
        (
            uint256 gameId,
            uint256 roundId,
            uint256 pattern,
            uint256 patternMask,
            uint256 lastPattern,
            uint256 lastPatternMask,
            uint256 lastSymbols,
        ) = _decodeGameState();
        require(roundId < BITS, "Game finished");

        roundId += 1;
        lastPattern = (random & 0x01) << (BITS - roundId);
        lastPatternMask = 1 << (BITS - roundId);
        pattern |= lastPattern;
        patternMask |= lastPatternMask;

        _encodeGameState(gameId, roundId, pattern, patternMask, lastPattern, lastPatternMask, lastSymbols, roundStartedAt);

        if (extension != address(0)) extension.functionDelegateCall(abi.encodeWithSelector(HackedGameExtension(extension).onRoundFinished.selector, random));
    }

    function _canReenter(
            uint256 tokenId, 
            uint256 reentriesMax, 
            uint256 gameId,
            uint256 pattern,
            uint256 patternMask,
            uint256 lastPatternMask,
            uint256 symbols) internal view returns (bool, uint256, string memory) {
        if (symbols == 0) return (false, 0, "No symbols left");

        (
            uint256 _gameId,
            uint256 defaultSymbols,
            uint256 _symbols,
            uint256 reentriesUsed
        ) = _decodeTokenState(tokenId);
        _symbols = _gameId == gameId ? _symbols : defaultSymbols;
        if(_matches(_symbols, patternMask, pattern)) return (false, 0, "Token not hacked");
        if(!_matches(_symbols, patternMask ^ lastPatternMask, pattern)) return (false, 0, "Too late");

        reentriesUsed = _gameId == gameId ? reentriesUsed+1 : 1;
        if(reentriesUsed > reentriesMax) return (false, 0, "Max reentries reached");

        symbols = _nextSymbols(symbols, pattern, patternMask);
        if(!_matches(symbols, patternMask, pattern)) return (false, 0, "No symbols left");

        return (true, symbols, "");
    }

    function _reenter(uint256 tokenId, uint256 reentriesMax, uint256 gameId, uint256 pattern, uint256 patternMask, uint256 lastPatternMask, uint256 lastSymbols) internal returns (uint256) {
        require(lastSymbols != 0, "No symbols left");

        (
            uint256 _gameId,
            uint256 defaultSymbols,
            uint256 _symbols,
            uint256 reentriesUsed
        ) = _decodeTokenState(tokenId);
        _symbols = _gameId == gameId ? _symbols : defaultSymbols;
        require(!_matches(_symbols, patternMask, pattern), "Token not hacked");
        require(_matches(_symbols, patternMask ^ lastPatternMask, pattern), "Too late");

        reentriesUsed = _gameId == gameId ? reentriesUsed+1 : 1;
        require(reentriesUsed <= reentriesMax, "Max reentries reached");

        lastSymbols = _nextSymbols(lastSymbols, pattern, patternMask);
        require(_matches(lastSymbols, patternMask, pattern), "No symbols left");

        _encodeSymbolState(lastSymbols, gameId, tokenId);
        _encodeTokenState(tokenId, gameId, defaultSymbols, lastSymbols, reentriesUsed);

        if (extension != address(0)) extension.functionDelegateCall(abi.encodeWithSelector(HackedGameExtension(extension).onReentered.selector, tokenId));

        return lastSymbols;
    }

    function _onGameCompleted(uint256 tokenId) internal {
        if (extension != address(0)) extension.functionDelegateCall(abi.encodeWithSelector(HackedGameExtension(extension).onGameCompleted.selector, tokenId));
    }

    function _onRoundRequested(uint256 tokenId, address user) internal {
        if (extension != address(0)) extension.functionDelegateCall(abi.encodeWithSelector(HackedGameExtension(extension).onRoundRequested.selector, tokenId, user));
    }

    function _nextSymbols(uint256 symbols, uint256 pattern, uint256 patternMask) internal pure returns (uint256) {
        do {
            symbols = _nextRandom(symbols);
        } while (!_matches(symbols, patternMask, pattern) && symbols != 0);
        
        return symbols;
    }

    function _matches(uint256 symbols, uint256 patternMask, uint256 pattern) internal pure returns (bool) {
        return (symbols & patternMask) == (pattern & patternMask);
    }

    function _getMatchingTokenTokenIds() internal view returns (uint256 tokenId, uint256 matches) {
        (
            uint256 gameId,
            uint256 roundId,
            uint256 pattern,,,,,
        ) = _decodeGameState();
        
        uint256 limit = 1 << (BITS - roundId);
        if(limit > 128) {
            return (0, limit);
        }

        for (uint256 i = 0; i < limit; ++i) {
            uint256 symbol = pattern + i;
            (
                uint256 _gameId,
                uint256 _tokenId
            ) = _decodeSymbolState(symbol);
            if (_gameId == gameId || _gameId == type(uint16).max) {
                tokenId = _tokenId;
                matches++;
            }
        }
    }

    function _getAllMatchingTokenTokenIds() internal view returns (uint256[] memory tokenIds, uint256 matches) {
        (
            uint256 gameId,
            uint256 roundId,
            uint256 pattern,,,,,
        ) = _decodeGameState();
        
        uint256 limit = 1 << (BITS - roundId);
        tokenIds = new uint256[](limit);

        for (uint256 i = 0; i < limit; ++i) {
            uint256 symbol = pattern + i;
            (
                uint256 _gameId,
                uint256 _tokenId
            ) = _decodeSymbolState(symbol);
            if (_gameId == gameId || _gameId == type(uint16).max) {
                tokenIds[matches] = _tokenId;
                matches++;
            }
        }
    }


    function tokenStates(uint256 _cursor, uint256 _length) external view returns (
        uint256 length,
        uint256[] memory symbols,
        uint256[] memory reentriesUsed,
        bool[] memory hacked
    ) {
        require(_cursor > 0 && _cursor <= LAST_TOKEN_ID, "Invalid cursor");
        length = _length;
        if (_cursor + length > LAST_TOKEN_ID + 1) {
            length = LAST_TOKEN_ID - _cursor + 1;
        }

        (uint256 _gameId,,uint256 pattern, uint256 patternMask,,,,) = _decodeGameState();

        symbols = new uint256[](length);
        reentriesUsed = new uint256[](length);
        hacked = new bool[](length);
        for (uint256 i = 0; i < length; ++i) {
            (
                uint256 gameId,
                uint256 defaultSymbols,
                uint256 _symbols,
                uint256 _reentriesUsed
            ) = _decodeTokenState(_cursor + i);
            symbols[i] = _gameId == gameId ? _symbols : defaultSymbols;
            reentriesUsed[i] = _gameId == gameId ? _reentriesUsed : 0;
            hacked[i] = !_matches(symbols[i], patternMask, pattern);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface IStakingTierProvider {
    function getTier(address user) external view returns (uint256);
}

abstract contract StakingTierProvider {
    using Address for address;

    address private _provider;

    function _upgradeTierProvider(address provider_) internal {
        _provider = provider_;
    }

    function getTier(address user) public view returns (uint256) {
        if (_provider == address(0)) return 4;
        
        bytes memory data = _provider.functionStaticCall(abi.encodeWithSelector(IStakingTierProvider.getTier.selector, user));
        return abi.decode(data, (uint256));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface IReentryProvider {
    function getReentries(address user, uint256 tier) external view returns (uint256);
}

abstract contract ReentryProvider {
    using Address for address;

    address private _provider;

    function _upgradeReentriesProvider(address provider_) internal {
        _provider = provider_;
    }

    function getReentries(address user, uint256 tier) public view returns (uint256) {
        if (_provider == address(0)) return (tier == 4) ? 1 : (4 - tier);
        
        bytes memory data = _provider.functionStaticCall(abi.encodeWithSelector(IReentryProvider.getReentries.selector, user, tier));
        return abi.decode(data, (uint256));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract Recoverable is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Recover NFT tokens sent by accident
    event NonFungibleTokenRecovery(address indexed token, uint256 indexed tokenId);

    // Recover ERC20 tokens sent by accident
    event TokenRecovery(address indexed token, uint256 amount);
    
   
    /**
     * @notice Allows the owner to recover tokens sent to the contract by mistake
     * @param _token: token address
     * @dev Callable by owner
     */
    function recoverFungibleTokens(address _token) external onlyOwner {
        uint256 amountToRecover = IERC20(_token).balanceOf(address(this));
        require(amountToRecover != 0, "Operations: No token to recover");

        IERC20(_token).safeTransfer(address(msg.sender), amountToRecover);

        emit TokenRecovery(_token, amountToRecover);
    }

    /**
     * @notice Allows the owner to recover NFTs sent to the contract by mistake
     * @param _token: NFT token address
     * @param _tokenId: tokenId
     * @dev Callable by owner
     */
    function recoverNonFungibleToken(address _token, uint256 _tokenId) external onlyOwner nonReentrant {
        IERC721(_token).safeTransferFrom(address(this), address(msg.sender), _tokenId);

        emit NonFungibleTokenRecovery(_token, _tokenId);
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract HackedGameState {

    uint256 internal constant LAST_TOKEN_ID = 2222;

    mapping(uint256 => uint256) private _tokenState;
    mapping(uint256 => uint256) private _symbolState;

    uint256 private _gameState;


    function _decodeSymbolState(uint256 symbols) internal view returns (
        uint256 gameId,
        uint256 tokenId
    ) {
        uint256 state = _symbolState[symbols]; 
        gameId  = uint256(uint16(state      ));
        tokenId = uint256(uint16(state >> 16));
    }

    function _encodeSymbolState(
        uint256 symbols, 
        uint256 gameId, 
        uint256 tokenId) internal 
    {
        _symbolState[symbols] = gameId
            | (tokenId << 16);
    }
   
    function _decodeTokenState(uint256 tokenId) internal view returns (
        uint256 gameId,
        uint256 defaultSymbols,
        uint256 symbols,
        uint256 reentriesUsed
    ) {
        uint256 state = _tokenState[tokenId]; 
        gameId         = uint256(uint16(state      ));
        defaultSymbols = uint256(uint16(state >> 16));
        symbols        = uint256(uint16(state >> 32));
        reentriesUsed  = uint256(uint16(state >> 48));
    }

    function _encodeTokenState(
        uint256 tokenId, 
        uint256 gameId,
        uint256 defaultSymbols,
        uint256 symbols,
        uint256 reentriesUsed) internal 
    {
        _tokenState[tokenId] = gameId
            | (defaultSymbols << 16)
            | (symbols        << 32)
            | (reentriesUsed  << 48);
    }

    function _decodeGameState() internal view returns (
        uint256 gameId,
        uint256 roundId,
        uint256 pattern,
        uint256 patternMask,
        uint256 lastPattern,
        uint256 lastPatternMask,
        uint256 lastSymbol,
        uint256 roundStartedAt
    ) {
        uint256 state = _gameState; 
        gameId          = uint256(uint16(state       ));
        roundId         = uint256(uint16(state >>  16));
        pattern         = uint256(uint16(state >>  32));
        patternMask     = uint256(uint16(state >>  48));
        lastPattern     = uint256(uint16(state >>  64));
        lastPatternMask = uint256(uint16(state >>  80));
        lastSymbol      = uint256(uint16(state >>  96));
        roundStartedAt  = uint256(uint32(state >> 112));
    }

    function _encodeGameState(
        uint256 gameId,
        uint256 roundId,
        uint256 pattern,
        uint256 patternMask,
        uint256 lastPattern,
        uint256 lastPatternMask,
        uint256 lastSymbols,
        uint256 roundStartedAt) internal 
    {
        _gameState = gameId
            | (roundId         <<  16)
            | (pattern         <<  32)
            | (patternMask     <<  48)
            | (lastPattern     <<  64)
            | (lastPatternMask <<  80)
            | (lastSymbols     <<  96)
            | (roundStartedAt  << 112);
    }

    function gameState() external view returns (
        uint256 gameId,
        uint256 roundId,
        uint256 pattern,
        uint256 patternMask,
        uint256 lastPattern,
        uint256 lastPatternMask,
        uint256 lastSymbol,
        uint256 roundStartedAt
    ) {
        return _decodeGameState();
    }

    function tokenState(uint256 tokenId) external view returns (
        uint256 gameId,
        uint256 defaultSymbols,
        uint256 symbols,
        uint256 reentriesUsed
    ) {
        return _decodeTokenState(tokenId);
    }

    function symbolsState(uint256 symbols) external view returns (
        uint256 gameId,
        uint256 tokenId
    ) {
        return _decodeSymbolState(symbols);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract RandomSequence {
    uint256 internal constant BITS = 15;
    uint256 private constant MASK = (1 << BITS) - 1;
    uint256 private constant B = 8891;
    uint256 private constant A = 32769;

    function _nextRandom(uint256 current) internal pure returns (uint256) {
        return (A * current + B) & MASK;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}