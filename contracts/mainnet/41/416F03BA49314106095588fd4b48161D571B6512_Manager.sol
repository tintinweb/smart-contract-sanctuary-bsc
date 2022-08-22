/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

// File: @chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol


pragma solidity ^0.8.4;

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

// File: @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol


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

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
}

// File: contracts/Manager.sol

/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;





interface NFT {
    function addAirdrop(address to, uint256 quantity) external;

    function totalSupply() external view returns (uint256);

    function mint(
        address to,
        string memory nodeName,
        uint256 tier,
        uint256 value
    ) external;

    function ownerOf(uint256 tokenId) external view returns (address);

    function updateValue(uint256 id, uint256 rewards) external;

    function balanceOf(address owner) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    function updateClaimTimestamp(uint256 id) external;

    function updateName(uint256 id, string memory nodeName) external;

    function updateTotalClaimed(uint256 id, uint256 rewards) external;

    function players(address user)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function _nodes(uint256 id)
        external
        view
        returns (
            uint256,
            string memory,
            uint8,
            uint256,
            uint256,
            uint256,
            uint256
        );
}

abstract contract Manageable is Ownable {
    mapping(address => bool) private _managers;

    event ManagerRemoved(address indexed manager_);
    event ManagerAdded(address indexed manager_);

    constructor() {}

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

interface ITeams {
    function getReferrer(address) external view returns (address);

    function addRewards(address user, uint256 amount) external;
}

contract Manager is Ownable, Manageable, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    address constant vrfCoordinator =
        0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    address constant link_token_contract =
        0x404460C6A5EdE2D891e8297795264fDe62ADBB75;

    bytes32 constant keyHash =
        0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    uint16 constant requestConfirmations = 3;
    uint32 constant callbackGasLimit = 2e6;
    uint32 constant numWords = 1;
    uint64 subscriptionId;

    struct Request {
        uint256 result;
        uint256 depositAmount;
        address userAddress;
        string nodeName;
    }

    mapping(address => bool) public pendingMint;
    mapping(uint256 => Request) public requests;

    uint256[2] public tierTwoExtremas = [300, 500];
    uint256[2] public tierThreeExtremas = [500, 1000];

    uint256 public tierTwoProbs = 20;
    uint256 public tierThreeProbs = 20;

    uint256 public maxTierTwo = 300;
    uint256 public currentTierTwo = 0;

    uint256 public maxTierThree = 200;
    uint256 public currentTierThree = 0;

    NFT public NFT_CONTRACT;
    IERC20 public TOKEN_CONTRACT;
    ITeams public TEAMS_CONTRACT;
    address public POOL;
    address public BANK;

    uint256 public startingPrice = 10e18;

    uint16[] public tiers = [100, 150, 200];

    mapping(address => bool) public isBlacklisted;

    struct Fees {
        uint8 create;
        uint8 compound;
        uint8 claim;
    }

    Fees public fees = Fees({create: 10, compound: 5, claim: 10});

    struct FeesDistribution {
        uint8 bank;
        uint8 rewards;
        uint8 upline;
    }

    FeesDistribution public createFeesDistribution =
        FeesDistribution({bank: 20, rewards: 30, upline: 50});

    FeesDistribution public claimFeesDistribution =
        FeesDistribution({bank: 20, rewards: 80, upline: 0});

    FeesDistribution public compoundFeesDistribution =
        FeesDistribution({bank: 0, rewards: 50, upline: 50});

    uint256 public priceStep = 100;
    uint256 public difference = 0;
    uint256 public maxDeposit = 4110e18;
    uint256 public maxPayout = 15000e18;

    event GeneratedRandomNumber(uint256 requestId, uint256 randomNumber);
    event TierResult(address indexed player, uint256 tier, uint256 chances);

    constructor(
        address TOKEN_CONTRACT_,
        address POOL_,
        address BANK_,
        uint64 _subscriptionId
    ) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        TOKEN_CONTRACT = IERC20(TOKEN_CONTRACT_);
        POOL = POOL_;
        BANK = BANK_;
        subscriptionId = _subscriptionId;
    }

    function updateTokenContract(address value) public onlyOwner {
        TOKEN_CONTRACT = IERC20(value);
    }

    function updateNftContract(address value) public onlyOwner {
        NFT_CONTRACT = NFT(value);
    }

    function updateTeamsContract(address value) public onlyOwner {
        TEAMS_CONTRACT = ITeams(value);
    }

    function updatePool(address value) public onlyOwner {
        POOL = value;
    }

    function updateBank(address value) public onlyOwner {
        BANK = value;
    }

    function updateMaxDeposit(uint256 value) public onlyOwner {
        maxDeposit = value;
    }

    function updateMaxPayout(uint256 value) public onlyOwner {
        maxPayout = value;
    }

    function updatePriceStep(uint256 value) public onlyOwner {
        priceStep = value;
    }

    function updateDifference(uint256 value) public onlyOwner {
        difference = value;
    }

    function updateTierTwoExtremas(uint256[2] memory value) public onlyOwner {
        tierTwoExtremas = value;
    }

    function updateTierThreeExtremas(uint256[2] memory value) public onlyOwner {
        tierThreeExtremas = value;
    }

    function updateTierTwoProbs(uint256 value) public onlyOwner {
        tierTwoProbs = value;
    }

    function updateTierThreeProbs(uint256 value) public onlyOwner {
        tierThreeProbs = value;
    }

    function updateMaxTierTwo(uint256 value) public onlyOwner {
        maxTierTwo = value;
    }

    function updateMaxTierThree(uint256 value) public onlyOwner {
        maxTierThree = value;
    }

    function updateCurrentTierTwo(uint256 value) public onlyOwner {
        currentTierTwo = value;
    }

    function updateCurrentTierThree(uint256 value) public onlyOwner {
        currentTierThree = value;
    }

    function currentPrice() public view returns (uint256) {
        return
            startingPrice +
            ((1 * NFT_CONTRACT.totalSupply()) / priceStep) *
            1e18 -
            difference;
    }

    function mintNode(string memory nodeName, uint256 amount) public payable {
        require(amount >= currentPrice(), "MINT: Amount too low");
        require(amount <= maxDeposit, "MINT: Amount too high");
        require(!pendingMint[_msgSender()], "MINT: You have an ongoing mint");

        TOKEN_CONTRACT.transferFrom(_msgSender(), POOL, amount);
        uint256 fees_ = (amount * fees.create) / 100;
        amount -= fees_;
        TOKEN_CONTRACT.transferFrom(
            POOL,
            BANK,
            (fees_ * createFeesDistribution.bank) / 100
        );
        address ref = TEAMS_CONTRACT.getReferrer(_msgSender());
        TEAMS_CONTRACT.addRewards(
            ref,
            (fees_ * createFeesDistribution.upline) / 100
        );
        if (
            amount < tierTwoExtremas[0] * 1e18 ||
            (amount <= tierTwoExtremas[1] * 1e18 &&
                currentTierTwo + 1 >= maxTierTwo) ||
            (amount > tierThreeExtremas[0] * 1e18 &&
                currentTierThree + 1 >= maxTierThree)
        ) {
            NFT_CONTRACT.mint(_msgSender(), nodeName, 0, amount);
        } else {
            require(msg.value >= 0.01 ether, "MINT: Please fund the LINK");
            pendingMint[_msgSender()] = true;
            uint256 requestId = requestRandomWords();
            requests[requestId].userAddress = _msgSender();
            requests[requestId].depositAmount = amount + fees_;
            requests[requestId].nodeName = nodeName;
        }
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
        uint256 randomResult = _randomWords[0] % 10000;
        requests[_requestId].result = randomResult;

        emit GeneratedRandomNumber(_requestId, randomResult);
        checkResult(_requestId);
    }

    function checkResult(uint256 _requestId) private returns (uint256) {
        Request memory request = requests[_requestId];
        address user = requests[_requestId].userAddress;
        uint256 tier;
        uint256[2] memory extremas;
        uint256 probability;

        if (request.depositAmount < tierTwoExtremas[1] * 1e18) {
            tier = 1;
            extremas = tierTwoExtremas;
            probability = tierTwoProbs;
        } else {
            tier = 2;
            extremas = tierThreeExtremas;
            probability = tierThreeProbs;
        }

        uint256 gap = request.depositAmount - extremas[0] * 1e18;
        uint256 diff = (extremas[1] - extremas[0]) * 1e18;
        uint256 chances;
        if (gap >= diff) {
            chances = probability * 100;
        } else {
            chances = ((gap * 100) / diff) * probability;
        }

        if (request.result > chances) {
            tier = 0;
        }

        uint256 fees_ = (request.depositAmount * fees.create) / 100;

        emit TierResult(user, tier, chances);
        NFT_CONTRACT.mint(
            user,
            request.nodeName,
            tier,
            request.depositAmount - fees_
        );

        pendingMint[user] = false;

        delete (requests[_requestId]);
        return tier;
    }

    function depositMore(uint256 id, uint256 amount) public {
        require(
            NFT_CONTRACT.ownerOf(id) == _msgSender(),
            "CLAIMALL: Not your NFT"
        );
        compound(id);
        (, , , uint256 value, , , ) = NFT_CONTRACT._nodes(id);
        require(value + amount <= maxDeposit, "DEPOSITMORE: Amount too high");
        uint256 fees_ = (amount * fees.create) / 100;
        amount -= fees_;
        TOKEN_CONTRACT.transferFrom(
            _msgSender(),
            BANK,
            (fees_ * createFeesDistribution.bank) / 100
        );
        address ref = TEAMS_CONTRACT.getReferrer(_msgSender());
        TEAMS_CONTRACT.addRewards(
            ref,
            (fees_ * createFeesDistribution.upline) / 100
        );
        TOKEN_CONTRACT.transferFrom(_msgSender(), POOL, amount);
        NFT_CONTRACT.updateValue(id, amount);
    }

    function availableRewards(uint256 id) public view returns (uint256) {
        (
            ,
            ,
            uint8 tier,
            uint256 value,
            uint256 totalClaimed,
            ,
            uint256 claimTimestamp
        ) = NFT_CONTRACT._nodes(id);
        uint256 rewards = (value *
            (block.timestamp - claimTimestamp) *
            tiers[tier]) /
            86400 /
            10000;
        if (totalClaimed + rewards > maxPayout) {
            rewards = maxPayout - totalClaimed;
        } else if (totalClaimed + rewards > (value * 365) / 100) {
            rewards = (value * 365) / 100 - totalClaimed;
        }
        return rewards;
    }

    function availableRewardsOfUser(address user)
        public
        view
        returns (uint256)
    {
        uint256 balance = NFT_CONTRACT.balanceOf(user);
        if (balance == 0) return 0;
        uint256 sum = 0;
        for (uint256 i = 0; i < balance; i++) {
            uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(user, i);
            sum += availableRewards(id);
        }
        return sum;
    }

    function _claimRewards(
        uint256 id,
        address recipient,
        bool skipFees
    ) private {
        if (!managers(_msgSender())) {
            require(
                NFT_CONTRACT.ownerOf(id) == _msgSender(),
                "CLAIMALL: Not your NFT"
            );
        }
        uint256 rewards_ = availableRewards(id);
        require(rewards_ > 0, "CLAIM: No rewards available yet");
        NFT_CONTRACT.updateClaimTimestamp(id);
        uint256 fees_ = 0;
        if (!skipFees) {
            fees_ = (rewards_ * fees.claim) / 100;
            TOKEN_CONTRACT.transferFrom(
                POOL,
                BANK,
                (fees_ * claimFeesDistribution.bank) / 100
            );
        }
        NFT_CONTRACT.updateTotalClaimed(id, rewards_);
        TOKEN_CONTRACT.transferFrom(POOL, recipient, rewards_ - fees_);
    }

    function claimRewards(uint256 id) public {
        require(
            NFT_CONTRACT.balanceOf(_msgSender()) > 0,
            "CLAIMALL: You don't own a NFT"
        );
        _claimRewards(id, _msgSender(), false);
    }

    function claimRewards() public {
        uint256 balance = NFT_CONTRACT.balanceOf(_msgSender());
        require(balance > 0, "CLAIMALL: You don't own a NFT");
        for (uint256 i = 0; i < balance; i++) {
            uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(_msgSender(), i);
            _claimRewards(id, _msgSender(), false);
        }
    }

    function claimRewardsHelper(
        uint256 id,
        address recipient,
        bool skipFees
    ) public onlyManager {
        _claimRewards(id, recipient, skipFees);
    }

    function claimRewardsHelper(
        address user,
        address recipient,
        bool skipFees
    ) public onlyManager {
        uint256 balance = NFT_CONTRACT.balanceOf(user);
        require(balance > 0, "CLAIMALL: You don't own a NFT");
        for (uint256 i = 0; i < balance; i++) {
            uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(user, i);
            _claimRewards(id, recipient, skipFees);
        }
    }

    function compoundHelper(
        uint256 id,
        uint256 externalRewards,
        address user
    ) public onlyManager {
        require(NFT_CONTRACT.ownerOf(id) == user, "CH: Not your NFT");
        uint256 rewards_ = availableRewards(id);
        require(rewards_ > 0, "CH: No rewards available yet");
        _compound(id, rewards_, _msgSender());
        (, , , uint256 value, , , ) = NFT_CONTRACT._nodes(id);
        require(value + externalRewards <= maxDeposit, "CH: Amount too high");
        NFT_CONTRACT.updateValue(id, externalRewards);
    }

    function _compound(
        uint256 id,
        uint256 rewards_,
        address user
    ) internal {
        require(NFT_CONTRACT.ownerOf(id) == user, "COMPOUND: Not your NFT");
        (, , , uint256 value, , , ) = NFT_CONTRACT._nodes(id);
        uint256 fees_ = (rewards_ * fees.compound) / 100;
        rewards_ -= fees_;
        require(value + rewards_ <= maxDeposit, "COMPOUND: Amount too high");
        NFT_CONTRACT.updateClaimTimestamp(id);
        NFT_CONTRACT.updateTotalClaimed(id, rewards_);
        TOKEN_CONTRACT.transferFrom(
            POOL,
            BANK,
            (fees_ * compoundFeesDistribution.bank) / 100
        );
        address ref = TEAMS_CONTRACT.getReferrer(user);
        TEAMS_CONTRACT.addRewards(
            ref,
            (fees_ * createFeesDistribution.upline) / 100
        );
        NFT_CONTRACT.updateValue(id, rewards_);
    }

    function compound(uint256 id) public {
        require(
            NFT_CONTRACT.balanceOf(_msgSender()) > 0,
            "COMPOUND: You don't own a NFT"
        );
        uint256 rewards_ = availableRewards(id);
        require(rewards_ > 0, "COMPOUND: No rewards available yet");
        _compound(id, rewards_, _msgSender());
    }

    function compoundAll() public {
        uint256 balance = NFT_CONTRACT.balanceOf(_msgSender());
        require(balance > 0, "COMPOUNDALL: You don't own a NFT");
        for (uint256 i = 0; i < balance; i++) {
            uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(_msgSender(), i);
            uint256 rewards_ = availableRewards(id);
            if (rewards_ > 0) {
                _compound(id, rewards_, _msgSender());
            }
        }
    }

    function compoundAllToSpecific(uint256 toId) public {
        uint256 balance = NFT_CONTRACT.balanceOf(_msgSender());
        require(balance > 0, "CTS: You don't own a NFT");
        require(
            NFT_CONTRACT.ownerOf(toId) == _msgSender(),
            "CTS: Not your NFT"
        );
        uint256 sum = 0;
        for (uint256 i = 0; i < balance; i++) {
            uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(_msgSender(), i);
            uint256 rewards_ = availableRewards(id);
            if (rewards_ > 0) {
                NFT_CONTRACT.updateClaimTimestamp(id);
            }
        }
        uint256 fees_ = (sum * fees.compound) / 100;
        NFT_CONTRACT.updateValue(toId, sum - fees_);
    }

    function updateName(uint256 id, string memory name) public {
        require(
            NFT_CONTRACT.ownerOf(id) == _msgSender(),
            "CLAIMALL: Not your NFT"
        );
        NFT_CONTRACT.updateName(id, name);
    }

    function aidrop(uint256 quantity, address[] memory receivers) public {
        TOKEN_CONTRACT.transferFrom(_msgSender(), POOL, quantity);
        NFT_CONTRACT.addAirdrop(_msgSender(), quantity);
        for (uint256 i = 0; i < receivers.length; i++) {
            TEAMS_CONTRACT.addRewards(
                receivers[i],
                quantity / receivers.length
            );
        }
    }

    function getNetDeposit(address user) public view returns (int256) {
        (
            uint256 totalDeposit,
            uint256 totalAirdrop,
            uint256 totalClaimed
        ) = NFT_CONTRACT.players(user);
        return
            int256(totalDeposit) + int256(totalAirdrop) - int256(totalClaimed);
    }

    /***********************************|
  |         Owner Functions           |
  |__________________________________*/

    function setStartingPrice(uint256 value) public onlyOwner {
        startingPrice = value;
    }

    function setTiers(uint8[] memory tiers_) public onlyOwner {
        tiers = tiers_;
    }

    function setIsBlacklisted(address user, bool value) public onlyOwner {
        isBlacklisted[user] = value;
    }

    function setFees(
        uint8 create_,
        uint8 compound_,
        uint8 claim_
    ) public onlyOwner {
        fees = Fees({create: create_, compound: compound_, claim: claim_});
    }

    function setCreateFeesDistribution(
        uint8 bank_,
        uint8 rewards_,
        uint8 upline_
    ) public onlyOwner {
        createFeesDistribution = FeesDistribution({
            bank: bank_,
            rewards: rewards_,
            upline: upline_
        });
    }

    function setClaimFeesDistribution(
        uint8 bank_,
        uint8 rewards_,
        uint8 upline_
    ) public onlyOwner {
        claimFeesDistribution = FeesDistribution({
            bank: bank_,
            rewards: rewards_,
            upline: upline_
        });
    }

    function setCompoundFeesDistribution(
        uint8 bank_,
        uint8 rewards_,
        uint8 upline_
    ) public onlyOwner {
        compoundFeesDistribution = FeesDistribution({
            bank: bank_,
            rewards: rewards_,
            upline: upline_
        });
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

    function changeSubId(uint64 id) public onlyOwner {
        subscriptionId = id;
    }
}