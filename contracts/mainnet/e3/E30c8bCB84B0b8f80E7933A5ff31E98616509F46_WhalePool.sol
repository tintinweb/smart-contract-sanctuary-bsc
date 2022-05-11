// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../includes/access/Ownable.sol";
import "../includes/interfaces/IRugZombieNft.sol";
import "../includes/interfaces/IPriceConsumerV3.sol";
import "../includes/utils/ReentrancyGuard.sol";
import "../includes/vrf/VRFConsumerBaseV2.sol";
import "../includes/vrf/VRFCoordinatorV2Interface.sol";

contract WhalePool is Ownable, ReentrancyGuard, VRFConsumerBaseV2 {
    uint32 public vrfGasLimit = 50000;  // Gas limit for VRF callbacks
    uint16 public vrfConfirms = 3;      // Number of confirmations for VRF randomness returns
    uint32 public vrfWords    = 1;      // Number of random words to get back from VRF

    struct UserInfo {
        address stakedNft;      // Address of the NFT the user has staked
        uint    stakedId;       // Token ID of the NFT the user has staked
        uint    lastNftMint;    // The timestamp of the last minting/time user started staking
        bool    isStaked;       // Flag for if the user is staked
        bool    isMinting;      // Flag for if the user has an active minting request
        bool    hasRandom;      // Flag for if we have gotten back a random number from Chainlink
        uint    randomNumber;   // The random number used to determine which reward to give user
    }

    IRugZombieNft               public stakeNft;            // The current staking NFT
    IRugZombieNft               public consolationPrize;    // The consolation prize NFT
    IPriceConsumerV3            public priceConsumer;       // The price consumer for doing BUSD - BNB conversion
    VRFCoordinatorV2Interface   public vrfCoordinator;      // Coordinator for requesting randomness

    uint        public  mintingTime;    // How long a user must be staked to be eligiable to claim NFT
    uint        public  mintingFee;     // The fee charged to cover Chainlink VRF
    address     payable treasury;       // The treasury address to send minting fees to
    address[]   public  rewardNfts;     // Array of potential reward NFTs
    uint        public  totalStakers;   // Count of how many users are currently staked in the pool
    bytes32     public  keyHash;        // Chainlink VRF key hash
    uint64      public  vrfSubId;       // Chainlink VRF subscription ID

    mapping(address => UserInfo)    public userInfo;            // Mapping of user requests
    mapping(uint256 => address)     public randomRequests;      // Mapping of random requsts to the user making it

    // Zero address for clearing address values
    address public zeroAddress = address(0x0000000000000000000000000000000000000000);

    // Events for doing any off chain tracking
    event MintReward(address indexed to, uint date, address nft, uint indexed id, uint random);
    event MintConsolation(address indexed to, uint date, address nft, uint indexed id);
    event Deposit(address indexed user, address indexed nft, uint indexed id);
    event Withdraw(address indexed user, address indexed nft, uint indexed id);

    // Constructor for creating the contract with initial values
    constructor(
        address _treasury,
        address _priceConsumer,
        address _stakeNft,
        uint _mintingTime, 
        uint _mintingFee,
        address _consolationPrize,
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _vrfSubId
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        treasury = payable(_treasury);
        priceConsumer = IPriceConsumerV3(_priceConsumer);
        stakeNft = IRugZombieNft(_stakeNft);
        mintingTime = _mintingTime;
        mintingFee = _mintingFee;
        consolationPrize = IRugZombieNft(_consolationPrize);
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        keyHash = _keyHash;
        vrfSubId = _vrfSubId;
    }

    // Function for the owner to update the treasury address
    function setTreasury(address _treasury) public onlyOwner() {
        treasury = payable(_treasury);
    }

    // Function for the owner to update the staking details
    function setStakeInfo(address _stakeNft, uint _mintingTime, uint _mintingFee) public onlyOwner() {
        stakeNft = IRugZombieNft(_stakeNft);
        mintingTime = _mintingTime;
        mintingFee = _mintingFee;
    }

    // Function for the owner to update the consolation prize
    function setConsolationPrize(address _consolationPrize) public onlyOwner() {
        consolationPrize = IRugZombieNft(_consolationPrize);
    }

    // Function for the owner to add a NFT reward
    function addReward(address _nft) public onlyOwner() {
        rewardNfts.push(_nft);
    }

    // Function for the owner to set the rewards array
    function setRewards(address[] memory _nfts) public onlyOwner() {
        rewardNfts = _nfts;
    }

    // Function for the owner to update the price consumer address
    function setPriceConsumer(address _priceConsumer) public onlyOwner() {
        priceConsumer = IPriceConsumerV3(_priceConsumer);
    }

    // Function to check if a given user is staked with the current whale pool NFT
    function checkUserStaked(address _user) public view returns(bool) {
        if (!userInfo[_user].isStaked) return false;
        return userInfo[_user].stakedNft == address(stakeNft);
    }

    // Function to get the current minting fee in BNB
    function mintingFeeInBnb() public view returns(uint) {
        return priceConsumer.usdToBnb(mintingFee);
    }

    // Function to get a user's NFT minting timer
    function nftMintTime(address _user) public view returns(uint) {
        UserInfo memory user = userInfo[_user];
        uint256 mintTime = user.lastNftMint + mintingTime;
        if (!user.isStaked) return 2**256 - 1;
        else if (block.timestamp > mintTime) return 0;
        else return (userInfo[_user].lastNftMint + mintingTime) - block.timestamp;
    }

    // Function for a user to enter staking in the contract
    function stake(uint _tokenId) public {
        require(!userInfo[msg.sender].isStaked, 'You are already staked in the pool');
        require(_tokenId > 0, 'Invalid token ID');

        stakeNft.transferFrom(msg.sender, address(this), _tokenId);
        require(stakeNft.ownerOf(_tokenId) == address(this), 'Stake NFT transfer failed');

        userInfo[msg.sender].stakedNft = address(stakeNft);
        userInfo[msg.sender].stakedId = _tokenId;
        userInfo[msg.sender].lastNftMint = block.timestamp;
        userInfo[msg.sender].isStaked = true;
        userInfo[msg.sender].isMinting = false;
        userInfo[msg.sender].hasRandom = false;

        totalStakers++;
        
        emit Deposit(msg.sender, address(stakeNft), _tokenId);
    }

    // Function for a user to unstake and claim a consolation prize if eligable
    function unstake() public {
        require(userInfo[msg.sender].isStaked, 'You are not staked in the pool');
        require(!userInfo[msg.sender].isMinting, 'You have an active minting that must be finished first');

        if ((userInfo[msg.sender].lastNftMint + mintingTime) <= block.timestamp) {
            require(userInfo[msg.sender].stakedNft != address(stakeNft), 'You have an available NFT to claim before unstaking');
            uint tokenId = consolationPrize.reviveRug(msg.sender);
            emit MintConsolation(msg.sender, block.timestamp, address(consolationPrize), tokenId);
        }

        IRugZombieNft nft = IRugZombieNft(userInfo[msg.sender].stakedNft);
        nft.transferFrom(address(this), msg.sender, userInfo[msg.sender].stakedId);
        require(nft.ownerOf(userInfo[msg.sender].stakedId) == msg.sender, 'NFT unstaking failed');

        userInfo[msg.sender].stakedNft = zeroAddress;
        userInfo[msg.sender].stakedId = 0;
        userInfo[msg.sender].isStaked = false;
        userInfo[msg.sender].isMinting = false;
        userInfo[msg.sender].hasRandom = false;

        totalStakers--;

        emit Withdraw(msg.sender, userInfo[msg.sender].stakedNft, userInfo[msg.sender].stakedId);
    }

    // Function for a user to unstake their NFT in an emergency without any regards for rewards
    function emergencyUnstake() public {
        require(userInfo[msg.sender].isStaked, 'You are not staked in the pool');

        IRugZombieNft nft = IRugZombieNft(userInfo[msg.sender].stakedNft);
        nft.transferFrom(address(this), msg.sender, userInfo[msg.sender].stakedId);
        require(nft.ownerOf(userInfo[msg.sender].stakedId) == msg.sender, 'NFT unstaking failed');

        userInfo[msg.sender].stakedNft = zeroAddress;
        userInfo[msg.sender].stakedId = 0;
        userInfo[msg.sender].isStaked = false;
        userInfo[msg.sender].isMinting = false;
        userInfo[msg.sender].hasRandom = false;

        totalStakers--;

        emit Withdraw(msg.sender, userInfo[msg.sender].stakedNft, userInfo[msg.sender].stakedId);
    }

    // Function for a user to start minting
    function startMinting() public payable nonReentrant() returns (uint256) {
        require(userInfo[msg.sender].isStaked, 'You are not staked in the pool');
        require((userInfo[msg.sender].lastNftMint + mintingTime) <= block.timestamp, 'NFT minting is not ready');
        require(!userInfo[msg.sender].isMinting, 'You already have an active minting request');
        require(userInfo[msg.sender].stakedNft == address(stakeNft), 'You are staked with previous season NFT, must unstake');
        require(msg.value >= mintingFeeInBnb(), 'Insufficient BNB sent for minting fee');

        _safeTransfer(treasury, msg.value);
        
        userInfo[msg.sender].isMinting = true;
        userInfo[msg.sender].hasRandom = false;
        uint256 id = vrfCoordinator.requestRandomWords(keyHash, vrfSubId, vrfConfirms, vrfGasLimit, vrfWords);
        randomRequests[id] = msg.sender;
        return id;
    }

    // Function for a user to finish the minting process and claim their reward
    function finishMinting() public returns(uint) {
        require(userInfo[msg.sender].isMinting, 'You do not have an active minting request');
        require(userInfo[msg.sender].hasRandom, 'Minting has not yet finished');

        IRugZombieNft reward = IRugZombieNft(rewardNfts[userInfo[msg.sender].randomNumber]);
        uint tokenId = reward.reviveRug(msg.sender);

        userInfo[msg.sender].lastNftMint = block.timestamp;
        userInfo[msg.sender].isMinting = false;
        userInfo[msg.sender].hasRandom = false;

        emit MintReward(msg.sender, block.timestamp, address(reward), tokenId, userInfo[msg.sender].randomNumber);

        return tokenId;
    }

    // Function for the Chainlink VRF to return a random number to us
    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomNumbers) internal override {
        uint randomNumber = _randomNumbers[0] % rewardNfts.length;
        address user = randomRequests[_requestId];
        userInfo[user].randomNumber = randomNumber;
        userInfo[user].hasRandom = true;
        randomRequests[_requestId] = zeroAddress;
    }

    // Function to safely transfer BNB received to the treasury
    function _safeTransfer(address _recipient, uint _amount) private {
        (bool _success, ) = _recipient.call{value: _amount}("");
        require(_success, "Transfer failed.");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
     * by making the `nonReentrant` function external, and make it call a
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

pragma solidity ^0.8.4;

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

    function _msgData() internal view virtual returns ( bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IRugZombieNft {
    function totalSupply() external view returns (uint256);
    function reviveRug(address _to) external returns(uint);
    function transferOwnership(address newOwner) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
    function owner() external view returns (address);
    function approve(address to, uint256 tokenId) external;
    function balanceOf(address _owner) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IPriceConsumerV3 {
    function getLatestPrice() external view returns (uint);
    function unlockFeeInBnb(uint) external view returns (uint);
    function usdToBnb(uint) external view returns (uint);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
    constructor()  {
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