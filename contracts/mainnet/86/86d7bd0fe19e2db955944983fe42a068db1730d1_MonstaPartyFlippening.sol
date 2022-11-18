/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// Sources flattened with hardhat v2.1.1 https://hardhat.org

// File @openzeppelin/contracts/utils/introspection/[email protected]

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

// File @openzeppelin/contracts/token/ERC721/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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

// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

// solhint-disable-next-line compiler-version

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
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
    require(_initializing || !_initialized, 'Initializable: contract is already initialized');

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

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

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
abstract contract ContextUpgradeable is Initializable {
  function __Context_init() internal initializer {
    __Context_init_unchained();
  }

  function __Context_init_unchained() internal initializer {}

  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }

  uint256[50] private __gap;
}

// File @openzeppelin/contracts-upgradeable/access/[email protected]

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  function __Ownable_init() internal initializer {
    __Context_init_unchained();
    __Ownable_init_unchained();
  }

  function __Ownable_init_unchained() internal initializer {
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
    require(owner() == _msgSender(), 'Ownable: caller is not the owner');
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
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  uint256[49] private __gap;
}

// File @api3/airnode-protocol/contracts/rrp/interfaces/[email protected]

interface IAuthorizationUtilsV0 {
  function checkAuthorizationStatus(
    address[] calldata authorizers,
    address airnode,
    bytes32 requestId,
    bytes32 endpointId,
    address sponsor,
    address requester
  ) external view returns (bool status);

  function checkAuthorizationStatuses(
    address[] calldata authorizers,
    address airnode,
    bytes32[] calldata requestIds,
    bytes32[] calldata endpointIds,
    address[] calldata sponsors,
    address[] calldata requesters
  ) external view returns (bool[] memory statuses);
}

// File @api3/airnode-protocol/contracts/rrp/interfaces/[email protected]

interface ITemplateUtilsV0 {
  event CreatedTemplate(
    bytes32 indexed templateId,
    address airnode,
    bytes32 endpointId,
    bytes parameters
  );

  function createTemplate(
    address airnode,
    bytes32 endpointId,
    bytes calldata parameters
  ) external returns (bytes32 templateId);

  function getTemplates(bytes32[] calldata templateIds)
    external
    view
    returns (
      address[] memory airnodes,
      bytes32[] memory endpointIds,
      bytes[] memory parameters
    );

  function templates(bytes32 templateId)
    external
    view
    returns (
      address airnode,
      bytes32 endpointId,
      bytes memory parameters
    );
}

// File @api3/airnode-protocol/contracts/rrp/interfaces/[email protected]

interface IWithdrawalUtilsV0 {
  event RequestedWithdrawal(
    address indexed airnode,
    address indexed sponsor,
    bytes32 indexed withdrawalRequestId,
    address sponsorWallet
  );

  event FulfilledWithdrawal(
    address indexed airnode,
    address indexed sponsor,
    bytes32 indexed withdrawalRequestId,
    address sponsorWallet,
    uint256 amount
  );

  function requestWithdrawal(address airnode, address sponsorWallet) external;

  function fulfillWithdrawal(
    bytes32 withdrawalRequestId,
    address airnode,
    address sponsor
  ) external payable;

  function sponsorToWithdrawalRequestCount(address sponsor)
    external
    view
    returns (uint256 withdrawalRequestCount);
}

// File @api3/airnode-protocol/contracts/rrp/interfaces/[email protected]

interface IAirnodeRrpV0 is IAuthorizationUtilsV0, ITemplateUtilsV0, IWithdrawalUtilsV0 {
  event SetSponsorshipStatus(
    address indexed sponsor,
    address indexed requester,
    bool sponsorshipStatus
  );

  event MadeTemplateRequest(
    address indexed airnode,
    bytes32 indexed requestId,
    uint256 requesterRequestCount,
    uint256 chainId,
    address requester,
    bytes32 templateId,
    address sponsor,
    address sponsorWallet,
    address fulfillAddress,
    bytes4 fulfillFunctionId,
    bytes parameters
  );

  event MadeFullRequest(
    address indexed airnode,
    bytes32 indexed requestId,
    uint256 requesterRequestCount,
    uint256 chainId,
    address requester,
    bytes32 endpointId,
    address sponsor,
    address sponsorWallet,
    address fulfillAddress,
    bytes4 fulfillFunctionId,
    bytes parameters
  );

  event FulfilledRequest(address indexed airnode, bytes32 indexed requestId, bytes data);

  event FailedRequest(address indexed airnode, bytes32 indexed requestId, string errorMessage);

  function setSponsorshipStatus(address requester, bool sponsorshipStatus) external;

  function makeTemplateRequest(
    bytes32 templateId,
    address sponsor,
    address sponsorWallet,
    address fulfillAddress,
    bytes4 fulfillFunctionId,
    bytes calldata parameters
  ) external returns (bytes32 requestId);

  function makeFullRequest(
    address airnode,
    bytes32 endpointId,
    address sponsor,
    address sponsorWallet,
    address fulfillAddress,
    bytes4 fulfillFunctionId,
    bytes calldata parameters
  ) external returns (bytes32 requestId);

  function fulfill(
    bytes32 requestId,
    address airnode,
    address fulfillAddress,
    bytes4 fulfillFunctionId,
    bytes calldata data,
    bytes calldata signature
  ) external returns (bool callSuccess, bytes memory callData);

  function fail(
    bytes32 requestId,
    address airnode,
    address fulfillAddress,
    bytes4 fulfillFunctionId,
    string calldata errorMessage
  ) external;

  function sponsorToRequesterToSponsorshipStatus(address sponsor, address requester)
    external
    view
    returns (bool sponsorshipStatus);

  function requesterToRequestCountPlusOne(address requester)
    external
    view
    returns (uint256 requestCountPlusOne);

  function requestIsAwaitingFulfillment(bytes32 requestId)
    external
    view
    returns (bool isAwaitingFulfillment);
}

// File contracts/Flippening/QrngRequester.sol

abstract contract QrngRequester is Initializable, OwnableUpgradeable {
  IAirnodeRrpV0 public airnodeRrp;

  address public airnode;
  bytes32 public endpointIdUint256;
  address public sponsorWallet;

  mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;

  event RequestedUint256(bytes32 indexed requestId);
  event ReceivedUint256(bytes32 indexed requestId, uint256 response);

  function __QrngRequester_init(address _airnodeRrp) internal initializer {
    __Ownable_init();

    airnodeRrp = IAirnodeRrpV0(_airnodeRrp);
    IAirnodeRrpV0(_airnodeRrp).setSponsorshipStatus(address(this), true);
  }

  modifier onlyAirnodeRrp() {
    require(msg.sender == address(airnodeRrp), 'Caller not Airnode RRP');
    _;
  }

  function setRequestParameters(
    address _airnode,
    bytes32 _endpointIdUint256,
    address _sponsorWallet
  ) external onlyOwner {
    airnode = _airnode;
    endpointIdUint256 = _endpointIdUint256;
    sponsorWallet = _sponsorWallet;
  }

  function makeRequestUint256() internal {
    bytes32 requestId = airnodeRrp.makeFullRequest(
      airnode,
      endpointIdUint256,
      address(this),
      sponsorWallet,
      address(this),
      this.fulfillUint256.selector,
      ''
    );
    // Store the requestId
    expectingRequestWithIdToBeFulfilled[requestId] = true;
    emit RequestedUint256(requestId);
  }

  // AirnodeRrp will call back with a response
  function fulfillUint256(bytes32 requestId, bytes calldata data) external onlyAirnodeRrp {
    // Verify the requestId exists
    require(expectingRequestWithIdToBeFulfilled[requestId], 'Request ID not known');
    expectingRequestWithIdToBeFulfilled[requestId] = false;
    uint256 qrngUint256 = abi.decode(data, (uint256));

    fulfillQrng(qrngUint256);

    emit ReceivedUint256(requestId, qrngUint256);
  }

  function fulfillQrng(uint256 result) internal virtual;
}

// File contracts/Flippening/MonstaPartyFlippening.sol

// import 'hardhat/console.sol';

struct NftInfo {
  uint256 xp;
  uint256 rewards;
  uint256 generation;
  uint256 hatchTime;
  uint256 lastFeedTime;
  uint256 lastXpUpdateTime;
  uint256 lastRewardsClaimTime;
  mapping(uint256 => uint256) dailyFeedCount;
  uint256 totalFeedBNB;
  uint256 rewardTracker;
  uint256 random;
  uint256 extraRobberies;
  uint256 lastEnergyDrinkTime;
}

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  function burn(uint256 amount) external;

  function approve(address spender, uint256 amount) external returns (bool);
}

interface IMonstaPartyP2E {
  function infos(uint256 tokenId)
    external
    view
    returns (
      uint256 xp,
      uint256 rewards,
      uint256 generation,
      uint256 hatchTime,
      uint256 lastFeedTime
    );
}

struct FlipGameInfo {
  uint256 betAmount;
  uint256 totalBetAmount;
  uint256 totalPlayersLightSide;
  uint256 totalPlayersDarkSide;
  uint256[] darkSidePlayerTokenIds;
  uint256[] lightSidePlayerTokenIds;
  mapping(uint256 => uint256) playerSide; // 0 = INIT, 1 = LIGHT, 2 = DARK
  mapping(uint256 => bool) playerClaimed;
  uint256 startTime;
  uint256 endTime;
  uint256 finishTime;
  uint256 winningSide; // 0 = INIT, 1 = LIGHT, 2 = DARK
  bool fulfilling;
  uint256 gameStartedTokenId;
}

struct FlipGameHistory {
  uint256 betAmount;
  uint256 totalBetAmount;
  uint256 totalPlayersLightSide;
  uint256 totalPlayersDarkSide;
  uint256 startTime;
  uint256 endTime;
  uint256 finishTime;
  uint256 winningSide;
}

contract MonstaPartyFlippening is OwnableUpgradeable {
  address public ADDRESS_MONSTA_PARTY_NFT;
  address public ADDRESS_MONSTA_PARTY_P2E;
  address public ADDRESS_CAKE_MONSTER;
  address public ADDRESS_FULFILLER;

  uint256 public minBetAmount;
  uint256 public maxBetAmount;
  uint256 public waitTimeBetweenGames;
  uint256 public maxPlayers;
  uint256 public maxGameDuration;

  uint256 public currentRound;
  uint256 public nextGameStartTime;
  mapping(uint256 => FlipGameInfo) public games;

  event FlipJoined(address indexed player, uint256 indexed playerTokenId, bool isDarkSide);

  event FlipStarted(
    address indexed player,
    uint256 indexed playerTokenId,
    uint256 indexed betAmount,
    bool isDarkSide
  );

  event FlipClaimed(address indexed player, uint256 indexed playerTokenId, uint256 indexed amount);

  event FlipFinished(bool indexed isDarkSideUp);

  function initialize(
    address _ADDRESS_MONSTA_PARTY_NFT,
    address _ADDRESS_MONSTA_PARTY_P2E,
    address _ADDRESS_CAKE_MONSTER,
    address _ADDRESS_FULFILLER
  ) external initializer {
    __Ownable_init();

    ADDRESS_MONSTA_PARTY_NFT = _ADDRESS_MONSTA_PARTY_NFT;
    ADDRESS_MONSTA_PARTY_P2E = _ADDRESS_MONSTA_PARTY_P2E;
    ADDRESS_CAKE_MONSTER = _ADDRESS_CAKE_MONSTER;
    ADDRESS_FULFILLER = _ADDRESS_FULFILLER;

    minBetAmount = 5000 ether;
    maxBetAmount = 100000 ether;

    maxPlayers = 30;
    maxGameDuration = 20 minutes;
    waitTimeBetweenGames = 10 minutes;
  }

  modifier onlyFulfiller() {
    require(_msgSender() == ADDRESS_FULFILLER, 'Caller not authorized');
    _;
  }

  /* OWNER */

  function upgrade() public onlyOwner {
    maxGameDuration = 10 minutes;
    waitTimeBetweenGames = 10 minutes;
    minBetAmount = 5000 ether;
    maxBetAmount = 100000 ether;
  }

  /** PUBLIC **/

  function startNewGame(
    uint256 _tokenId,
    uint256 _betAmount,
    bool _chooseDarkSide
  ) external {
    require(isTokenOwner(_tokenId), 'Token not owned by caller');
    require(
      currentRound == 0 || games[currentRound].winningSide > 0,
      'Wait for previous game result'
    );
    require(
      block.timestamp > games[currentRound].finishTime + waitTimeBetweenGames,
      'Wait before starting a new game'
    );

    require(_betAmount >= minBetAmount, 'Bet amount too low');
    require(_betAmount <= maxBetAmount, 'Bet amount too high');

    (
      uint256 __,
      uint256 ___,
      uint256 ____,
      uint256 hatchTime,
      uint256 lastFeedTime
    ) = IMonstaPartyP2E(ADDRESS_MONSTA_PARTY_P2E).infos(_tokenId);

    require(hatchTime > 0, 'Feed at least once to start playing');
    require(
      lastFeedTime > block.timestamp - 10 days,
      'Inactive for more than 10 days, feed at least once to play'
    );

    currentRound++;

    FlipGameInfo storage currentGame = games[currentRound];

    currentGame.betAmount = _betAmount;
    currentGame.totalBetAmount = _betAmount + IERC20(ADDRESS_CAKE_MONSTER).balanceOf(address(this));
    currentGame.startTime = block.timestamp;
    currentGame.endTime = 0;
    currentGame.gameStartedTokenId = _tokenId;

    if (_chooseDarkSide) {
      currentGame.totalPlayersDarkSide++;
      currentGame.darkSidePlayerTokenIds.push(_tokenId);
      currentGame.playerSide[_tokenId] = 2;
    } else {
      currentGame.totalPlayersLightSide++;
      currentGame.lightSidePlayerTokenIds.push(_tokenId);
      currentGame.playerSide[_tokenId] = 1;
    }

    // Transfer bet amount from caller to contract (needs approval)
    IERC20(ADDRESS_CAKE_MONSTER).transferFrom(_msgSender(), address(this), currentGame.betAmount);

    emit FlipStarted(_msgSender(), _tokenId, _betAmount, _chooseDarkSide);
  }

  function withdrawGame() external {
    require(canWithdrawGame(), 'Withdrawing not possible');

    FlipGameInfo storage currentGame = games[currentRound];
    currentGame.finishTime = block.timestamp - waitTimeBetweenGames;
    currentGame.winningSide = 3;

    // Transfer inital bet amount to caller
    IERC20(ADDRESS_CAKE_MONSTER).transfer(_msgSender(), currentGame.betAmount);
  }

  function joinCurrentGame(uint256 _tokenId, bool _chooseDarkSide) external {
    require(isTokenOwner(_tokenId), 'Token not owned by caller');

    FlipGameInfo storage currentGame = games[currentRound];

    require(currentGame.winningSide == 0, 'Wait for new game to start');
    require(
      currentGame.endTime == 0 || block.timestamp < currentGame.endTime,
      'Wait for new game to start'
    );
    require(currentGame.playerSide[_tokenId] == 0, 'Already playing');

    (
      uint256 __,
      uint256 ___,
      uint256 ____,
      uint256 hatchTime,
      uint256 lastFeedTime
    ) = IMonstaPartyP2E(ADDRESS_MONSTA_PARTY_P2E).infos(_tokenId);

    require(hatchTime > 0, 'Feed at least once to start playing');
    require(
      lastFeedTime > block.timestamp - 10 days,
      'Inactive for more than 10 days, feed at least once to play'
    );

    if (_chooseDarkSide) {
      currentGame.totalPlayersDarkSide++;
      currentGame.darkSidePlayerTokenIds.push(_tokenId);
      currentGame.playerSide[_tokenId] = 2;
    } else {
      currentGame.totalPlayersLightSide++;
      currentGame.lightSidePlayerTokenIds.push(_tokenId);
      currentGame.playerSide[_tokenId] = 1;
    }

    currentGame.totalBetAmount += currentGame.betAmount;

    if (
      currentGame.endTime == 0 &&
      currentGame.totalPlayersDarkSide > 0 &&
      currentGame.totalPlayersLightSide > 0
    ) {
      currentGame.endTime = block.timestamp + maxGameDuration;
    }

    // Transfer bet amount from caller to contract (needs approval)
    IERC20(ADDRESS_CAKE_MONSTER).transferFrom(_msgSender(), address(this), currentGame.betAmount);

    emit FlipJoined(_msgSender(), _tokenId, _chooseDarkSide);
  }

  function fulfillRnd(uint256 result) external onlyFulfiller {
    FlipGameInfo storage currentGame = games[currentRound];

    require(currentGame.finishTime == 0, 'Already fulfilled');
    require(currentGame.endTime > 0 && block.timestamp > currentGame.endTime, 'Game in progress');

    currentGame.finishTime = block.timestamp;
    currentGame.winningSide = (result % 2) + 1;

    emit FlipFinished(currentGame.winningSide == 2);
  }

  function claim(uint256 _tokenId) external {
    require(isTokenOwner(_tokenId), 'Token not owned by caller');

    FlipGameInfo storage currentGame = games[currentRound];

    require(currentGame.winningSide > 0, 'Wait for game result');
    require(currentGame.playerSide[_tokenId] == currentGame.winningSide, 'Not a winner');
    require(!currentGame.playerClaimed[_tokenId], 'Already claimed');

    // Set claimed
    currentGame.playerClaimed[_tokenId] = true;

    // Determine win amount
    uint256 winAmount;

    if (currentGame.winningSide == 2) {
      winAmount =
        (currentGame.totalBetAmount / currentGame.totalPlayersDarkSide) -
        currentGame.betAmount;
    } else {
      winAmount =
        (currentGame.totalBetAmount / currentGame.totalPlayersLightSide) -
        currentGame.betAmount;
    }

    // Burn 20% MONSTA
    uint256 burnAmount = _pct100(2000, winAmount);

    IERC20(ADDRESS_CAKE_MONSTER).burn(burnAmount);

    // Transfer MONSTA to player
    uint256 playerWinAmount = currentGame.betAmount + (winAmount - burnAmount);

    IERC20(ADDRESS_CAKE_MONSTER).transfer(_msgSender(), playerWinAmount);

    emit FlipClaimed(_msgSender(), _tokenId, playerWinAmount);
  }

  function getCurrentGameInfo()
    external
    view
    returns (
      uint256 betAmount,
      uint256 totalBetAmount,
      uint256 totalPlayersLightSide,
      uint256 totalPlayersDarkSide,
      uint256[] memory darkSidePlayerTokenIds,
      uint256[] memory lightSidePlayerTokenIds,
      uint256 startTime,
      uint256 endTime,
      uint256 finishTime,
      uint256 winningSide,
      bool fulfilling
    )
  {
    betAmount = games[currentRound].betAmount;
    totalBetAmount = games[currentRound].totalBetAmount;
    totalPlayersLightSide = games[currentRound].totalPlayersLightSide;
    totalPlayersDarkSide = games[currentRound].totalPlayersDarkSide;
    darkSidePlayerTokenIds = games[currentRound].darkSidePlayerTokenIds;
    lightSidePlayerTokenIds = games[currentRound].lightSidePlayerTokenIds;
    startTime = games[currentRound].startTime;
    endTime = games[currentRound].endTime;
    finishTime = games[currentRound].finishTime;
    winningSide = games[currentRound].winningSide;
    fulfilling = games[currentRound].fulfilling;
  }

  function getGameHistory() external view returns (FlipGameHistory[] memory) {
    FlipGameHistory[] memory history = new FlipGameHistory[](20);

    uint256 c = 0;
    for (uint256 i = currentRound; i > 0 && i > currentRound - 20; i--) {
      history[c++] = FlipGameHistory({
        betAmount: games[i].betAmount,
        totalBetAmount: games[i].totalBetAmount,
        totalPlayersLightSide: games[i].totalPlayersLightSide,
        totalPlayersDarkSide: games[i].totalPlayersDarkSide,
        startTime: games[i].startTime,
        endTime: games[i].endTime,
        finishTime: games[i].finishTime,
        winningSide: games[i].winningSide
      });
    }

    return history;
  }

  function hasClaimed(uint256 _tokenId) external view returns (bool) {
    return games[currentRound].playerClaimed[_tokenId];
  }

  function canWithdrawGame() public view returns (bool) {
    FlipGameInfo storage currentGame = games[currentRound];

    if (block.timestamp - currentGame.startTime < 20 minutes) {
      return false;
    }

    uint256 totalPlayers = games[currentRound].totalPlayersLightSide +
      games[currentRound].totalPlayersDarkSide;

    if (isTokenOwner(currentGame.gameStartedTokenId) && totalPlayers == 1) {
      return true;
    }

    return false;
  }

  /** PRIVATE/INTERNAL/OVERRIDES **/

  function isTokenOwner(uint256 tokenId) private view returns (bool) {
    return IERC721(ADDRESS_MONSTA_PARTY_NFT).ownerOf(tokenId) == _msgSender();
  }

  /** UTILS **/

  function _pct100(uint256 pct100, uint256 amount) internal pure returns (uint256) {
    return (pct100 * amount) / 10000;
  }

  function _share(
    uint256 a,
    uint256 b,
    uint256 c
  ) private pure returns (uint256) {
    return (((a * 10000) / b) * c) / 10000;
  }
}