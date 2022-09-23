/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IVRFCoordinatorV2 is VRFCoordinatorV2Interface {
    function getFeeConfig()
        external
        view
        returns (
            uint32,
            uint32,
            uint32,
            uint32,
            uint32,
            uint24,
            uint24,
            uint24,
            uint24
        );
}

abstract contract VRFConsumerBaseV2Upgradeable is Initializable {
    error OnlyCoordinatorCanFulfill(address have, address want);
    address private vrfCoordinator;

    function __VRFConsumerBaseV2_init(address _vrfCoordinator)
        internal
        initializer
    {
        vrfCoordinator = _vrfCoordinator;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        virtual;

    function rawFulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) external {
        if (msg.sender != vrfCoordinator) {
            revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        }
        fulfillRandomWords(requestId, randomWords);
    }
}

abstract contract ManageableUpgradeable is OwnableUpgradeable {
    mapping(address => bool) private _managers;
    event ManagerAdded(address indexed manager_);
    event ManagerRemoved(address indexed manager_);

    function managers(address manager_) public view virtual returns (bool) {
        return _managers[manager_];
    }

    modifier onlyManager() {
        require(_managers[_msgSender()], "Manageable: caller is not the owner");
        _;
    }

    function removeManager(address manager_) public virtual onlyOwner {
        _managers[manager_] = false;
        emit ManagerRemoved(manager_);
    }

    function addManager(address manager_) public virtual onlyOwner {
        require(
            manager_ != address(0),
            "Manageable: new owner is the zero address"
        );
        _managers[manager_] = true;
        emit ManagerAdded(manager_);
    }
}

interface IWBNB is IERC20Upgradeable {
    function deposit() external payable;
}

interface IBank {
    function addRewards(address token, uint256 amount) external;
}

contract DiceRoll is
    Initializable,
    OwnableUpgradeable,
    ManageableUpgradeable,
    VRFConsumerBaseV2Upgradeable
{
    address constant priceFeed = 0xB38722F6A608646a538E882Ee9972D15c86Fc597;
    address constant vrfCoordinator =
        0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    address constant link_token_contract =
        0x404460C6A5EdE2D891e8297795264fDe62ADBB75;

    bytes32 constant keyHash =
        0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    uint16 constant requestConfirmations = 3;
    uint32 constant numWords = 1;
    uint32 callbackGasLimit;
    uint64 subscriptionId;

    IVRFCoordinatorV2 COORDINATOR;
    AggregatorV3Interface PRICE_FEED;

    struct Bet {
        uint256 id;
        bool resolved;
        address payable user;
        address token;
        uint256 amount;
        bool even;
        uint256 multiplier;
        uint256 timestamp;
        uint256 payout;
        uint256 result;
    }

    address public TOKEN;
    address public WBNB;
    address public BUSD;
    address public SENTINEL;
    address public GAME_POOL;
    address public BANK;

    uint256[] public distribution;
    uint256 public multiplier;
    uint256 public houseEdge;

    mapping(uint256 => Bet) public bets;
    mapping(address => uint256[]) public userBets;
    mapping(address => bool) public acceptedTokens;
    mapping(address => uint256[]) public extremums;
    mapping(address => uint256) public minJackpotEntry;
    mapping(address => uint256) public currentJackpots;

    bool public isJackpotActive;

    event betPlaced(
        uint256 id,
        address indexed user,
        address indexed token,
        uint256 amount,
        bool even
    );
    event rollReceived(uint256 id, uint256 result);
    event betResolved(
        uint256 id,
        address indexed user,
        address indexed token,
        uint256 amount,
        bool even,
        uint256 result,
        uint256 payout
    );

    event JackpotWinner(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    function initialize(
        address token,
        address wbnb,
        address busd,
        address sentinel,
        address pool,
        address bank,
        uint32 _callbackGasLimit,
        uint64 _subscriptionId
    ) public initializer {
        __Ownable_init();
        __VRFConsumerBaseV2_init(vrfCoordinator);
        COORDINATOR = IVRFCoordinatorV2(vrfCoordinator);
        PRICE_FEED = AggregatorV3Interface(priceFeed);
        TOKEN = token;
        WBNB = wbnb;
        BUSD = busd;
        SENTINEL = sentinel;
        GAME_POOL = pool;
        BANK = bank;
        callbackGasLimit = _callbackGasLimit;
        subscriptionId = _subscriptionId;

        distribution = [5000, 5000];
        multiplier = 20000;
        houseEdge = 400;

        acceptedTokens[token] = true;
        acceptedTokens[wbnb] = true;
        acceptedTokens[busd] = true;
        acceptedTokens[sentinel] = true;
    }

    function updateTokenAddress(address value) public onlyOwner {
        TOKEN = value;
    }

    function updateWBNBAddress(address value) public onlyOwner {
        WBNB = value;
    }

    function updateBUSDAddress(address value) public onlyOwner {
        BUSD = value;
    }

    function updateSentinelAddress(address value) public onlyOwner {
        SENTINEL = value;
    }

    function updatePool(address value) public onlyOwner {
        GAME_POOL = value;
    }

    function updateBank(address value) public onlyOwner {
        BANK = value;
    }

    function updateCallbackGasLimit(uint32 value) public onlyOwner {
        callbackGasLimit = value;
    }

    function updateSubscriptionId(uint64 id) public onlyOwner {
        subscriptionId = id;
    }

    function updateDistribution(uint256[] memory value) public onlyOwner {
        distribution = value;
    }

    function updateMultiplier(uint256 value) public onlyOwner {
        multiplier = value;
    }

    function updateHouseEdge(uint256 value) public onlyOwner {
        houseEdge = value;
    }

    function updateAcceptedToken(address token, bool value) public onlyOwner {
        acceptedTokens[token] = value;
    }

    function updateExtremums(address token, uint256[] memory value)
        public
        onlyOwner
    {
        extremums[token] = value;
    }

    function updateCurrentJackpot(address token, uint256 value)
        public
        onlyOwner
    {
        currentJackpots[token] += value;
    }

    function updateMinJackpotEntry(address token, uint256 value)
        public
        onlyOwner
    {
        minJackpotEntry[token] = value;
    }

    function updateIsJackpotActive(bool value) public onlyOwner {
        isJackpotActive = value;
    }

    function getExtremums(address token)
        public
        view
        returns (uint256[] memory)
    {
        return extremums[token];
    }

    function getUserBets(
        address user,
        uint256 start,
        uint256 end
    ) public view returns (Bet[] memory) {
        uint256[] memory userBets_ = userBets[user];
        end = end > userBets_.length ? userBets_.length : end;
        Bet[] memory bets_ = new Bet[](end - start);
        for (uint256 i = start; i < end; i++) {
            bets_[i - start] = (bets[userBets_[i]]);
        }
        return bets_;
    }

    function getLastUserBets(address user, uint256 quantity)
        public
        view
        returns (Bet[] memory)
    {
        uint256[] memory userBets_ = userBets[user];
        uint256 start = quantity > userBets_.length
            ? 0
            : userBets_.length - quantity;
        Bet[] memory bets_ = new Bet[](userBets_.length - start);
        for (uint256 i = start; i < userBets_.length; i++) {
            bets_[i - start] = (bets[userBets_[i]]);
        }
        return bets_;
    }

    function initiateRoll(
        address token,
        uint256 amount,
        bool even
    ) public payable {
        require(acceptedTokens[token], "INITATEROLL: Token not accepted");
        bool isNative = token == SENTINEL;
        uint256 fee = isNative ? msg.value - amount : msg.value;

        uint256 chainlinkVRFCost = getChainlinkVRFCost();
        require(
            fee > (chainlinkVRFCost - ((10 * chainlinkVRFCost) / 100)),
            "INITIATEROLL: Invalid gas fee value"
        );
        require(
            amount >= extremums[token][0],
            "INTIATEROLL: Below minimum bet"
        );
        require(
            amount <= extremums[token][1],
            "INTIATEROLL: Above maximum bet"
        );

        if (!isNative) {
            IERC20Upgradeable(token).transferFrom(
                _msgSender(),
                address(this),
                amount
            );
        }

        uint256 id = requestRandomWords();
        Bet memory newBet = Bet(
            id,
            false,
            payable(_msgSender()),
            token,
            amount,
            even,
            multiplier,
            block.timestamp,
            0,
            0
        );
        userBets[_msgSender()].push(id);
        bets[id] = newBet;
        emit betPlaced(id, _msgSender(), token, amount, even);
    }

    function requestRandomWords() public returns (uint256) {
        return
            COORDINATOR.requestRandomWords(
                keyHash,
                subscriptionId,
                requestConfirmations,
                callbackGasLimit,
                numWords
            );
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(!bets[_requestId].resolved, "FULFILL: Already resolved");
        uint256 randomResult = (_randomWords[0] % 6) + 1;
        bool isEven = randomResult % 2 == 0;

        emit rollReceived(_requestId, randomResult);

        bets[_requestId].resolved = true;
        Bet memory bet = bets[_requestId];
        bet.result = randomResult;

        bool isNative = bet.token == SENTINEL;

        bool isWinner = (isEven && bet.even) || (!isEven && !bet.even);
        bet.payout = (isWinner) ? (bet.amount * bet.multiplier) / 10000 : 0;

        if (isWinner) {
            uint256 houseFee = (bet.payout * houseEdge) / 10000;
            uint256 bankFee = (houseFee * distribution[0]) / 10000;
            uint256 gameFee = (houseFee * distribution[1]) / 10000;
            uint256 payment = bet.payout - houseFee;
            if (isNative) {
                {
                    (bool success, ) = bet.user.call{value: payment}("");
                    require(success, "FULFILL: Failed to send winnings");
                }

                {
                    IWBNB(WBNB).deposit{value: bankFee}();
                    IWBNB(WBNB).transfer(BANK, bankFee);
                    IBank(BANK).addRewards(WBNB, bankFee);
                }

                {
                    (bool success, ) = GAME_POOL.call{value: gameFee}("");
                    require(success, "FULFILL: Failed to send game pool fees");
                }
            } else {
                IERC20Upgradeable(bet.token).transfer(bet.user, payment);
                IERC20Upgradeable(bet.token).transfer(BANK, bankFee);
                IBank(BANK).addRewards(bet.token, bankFee);
                IERC20Upgradeable(bet.token).transfer(GAME_POOL, gameFee);
            }
        } else {
            uint256 houseFee = (bet.amount * 3000) / 10000;
            uint256 bankFee = (houseFee * 1667) / 10000;
            uint256 gameFee = (houseFee * 1667) / 10000;
            uint256 jackpotFee = (houseFee * 6666) / 10000;
            if (isNative) {
                {
                    currentJackpots[bet.token] += jackpotFee;
                }

                {
                    IWBNB(WBNB).deposit{value: bankFee}();
                    IWBNB(WBNB).transfer(BANK, bankFee);
                    IBank(BANK).addRewards(WBNB, bankFee);
                }

                {
                    (bool success, ) = GAME_POOL.call{value: gameFee}("");
                    require(success, "FULFILL: Failed to send game pool fees");
                }
            } else {
                IERC20Upgradeable(bet.token).transfer(BANK, bankFee);
                IBank(BANK).addRewards(bet.token, bankFee);
                IERC20Upgradeable(bet.token).transfer(GAME_POOL, gameFee);
                currentJackpots[bet.token] += jackpotFee;
            }
        }

        if (isJackpotActive && bet.amount >= minJackpotEntry[bet.token]) {
            uint256 jpResult = (_randomWords[0] % 5000) + 1;
            if (jpResult <= 5) {
                if (isNative) {
                    (bool success, ) = bet.user.call{
                        value: currentJackpots[bet.token]
                    }("");
                    require(success, "FULFILL: Failed to send winnings");
                } else {
                    IERC20Upgradeable(bet.token).transfer(
                        bet.user,
                        currentJackpots[bet.token]
                    );
                }

                emit JackpotWinner(
                    bet.user,
                    bet.token,
                    currentJackpots[bet.token]
                );

                currentJackpots[bet.token] = 0;
            }
        }

        bets[_requestId] = bet;
        emit betResolved(
            _requestId,
            bet.user,
            bet.token,
            bet.amount,
            bet.even,
            bet.result,
            bet.payout
        );
    }

    function withdrawNative() public onlyOwner {
        (bool sent, ) = payable(owner()).call{
            value: (payable(address(this))).balance
        }("");
        require(sent, "Failed to send Ether to growth");
    }

    function withdrawNativeTwo() public onlyOwner {
        payable(owner()).transfer((payable(address(this))).balance);
    }

    function withdraweErc20(address token) public onlyOwner {
        IERC20Upgradeable(token).transfer(
            owner(),
            IERC20Upgradeable(token).balanceOf(address(this))
        );
    }

    function getChainlinkVRFCost() public view returns (uint256) {
        (, int256 weiPerUnitLink, , , ) = PRICE_FEED.latestRoundData();
        require(weiPerUnitLink > 0, "Invalid price feed value");
        (uint32 fulfillmentFlatFeeLinkPPMTier1, , , , , , , , ) = COORDINATOR
            .getFeeConfig();
        return
            (tx.gasprice * (115000 + callbackGasLimit)) +
            ((1e12 *
                uint256(fulfillmentFlatFeeLinkPPMTier1) *
                uint256(weiPerUnitLink)) / 1e18);
    }

    receive() external payable {}

    fallback() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20Upgradeable.sol";

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

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
}