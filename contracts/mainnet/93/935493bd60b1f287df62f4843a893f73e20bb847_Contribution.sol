/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

/**
 * Contribution contract for AscentPad
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

contract AscentLock {
    constructor(address _owner, address _tokenContractAddress, uint256 _apr, uint256 _tier1, uint256 _tier2, uint256 _tier3, uint256 _tier4) {
        owner = _owner;
        tokenContractAddress = _tokenContractAddress;
        apr = _apr;
        tier1 = _tier1;
        tier2 = _tier2;
        tier3 = _tier3;
        tier4 = _tier4;
        stakeholders.push();
    }

    receive() payable external {
        
    }

    address owner;
    address tokenContractAddress;
    uint256 apr;
    uint256 tier1;
    uint256 tier2;
    uint256 tier3;
    uint256 tier4;

    struct Stakeholder {
        address user;
        uint256 amount;
        uint8 tier;
        uint256 since;
    }

    Stakeholder[] public stakeholders;

    mapping(address => uint256) internal stakes;

    event Stake(address indexed user, uint256 index, uint256 old_amount, uint256 new_amount, uint256 stake_amount, uint8 tier, uint256 old_timestamp, uint256 new_timestamp);
    event Withdraw(address indexed user, uint256 amount, uint256 reward, uint256 withdraw, uint8 tier, uint256 index, uint256 since, uint256 timestamp);
    
    function _addStakeholder(address _user) private returns (uint256) {
        stakeholders.push();
        uint256 index = stakeholders.length - 1;
        stakeholders[index].user = _user;
        stakes[_user] = index;
        return index; 
    }

    function isInTier(uint8 tier, address userToCheck)
        public
        view
        returns(bool) {
        uint256 index = stakes[userToCheck];
        bool result = false;
        if((stakeholders[index].tier == tier) && (stakeholders[index].amount > 0)) {
            result = true;
        }
        return result;
    }

    function stake(uint256 _amount) public payable returns (bool) {
        if(_getDeposit(msg.sender, _amount) == true) {
            _stake(msg.sender, _amount);
            return true;
        } else {
            revert("Transaction is failed");
        }
    }

    function _getDeposit(address _from, uint256 _amount) private returns (bool) {
        IERC20 token = IERC20(tokenContractAddress);
        return token.transferFrom(_from, address(this), _amount);
    }

    function _stake(address _sender, uint256 _amount) private {        
        uint256 index = stakes[_sender];
        if(index == 0) {
            index = _addStakeholder(_sender);
        }

        uint256 old_amount = stakeholders[index].amount;
        uint256 new_amount = getStakeReward(stakeholders[index].user) + _amount;

        uint8 _tier = 0;
        if(new_amount >= tier4) {
            _tier = 4;
        }
        if(new_amount >= tier3) {
            _tier = 3;
        }
        if(new_amount >= tier2) {
            _tier = 2;
        }
        if(new_amount >= tier1) {
            _tier = 1;
        }

        uint256 old_timestamp = stakeholders[index].since;
        uint256 new_timestamp = block.timestamp;

        stakeholders[index].amount = new_amount;
        stakeholders[index].tier = _tier;
        stakeholders[index].since = new_timestamp;
        emit Stake(_sender, index, old_amount, new_amount, _amount, _tier, old_timestamp, new_timestamp);
    }


    function withdrawStake(uint256 amount) public payable returns (bool) {
        return _withdrawStake(msg.sender, amount);
    }

    function _withdrawStake(address _sender, uint256 _amount) private returns (bool) {
        uint256 index = stakes[_sender];

        require(index > 0, "Stake is not found");
        if(stakeholders[index].tier == 1 && ((block.timestamp - stakeholders[index].since) / 60 / 60 / 24 / 7) < 3) {
            revert("Stake not completed (3 weeks)");
        } else if(stakeholders[index].tier == 2 && ((block.timestamp - stakeholders[index].since) / 60 / 60 / 24 / 7) < 2) {
            revert("Stake not completed (2 weeks)");
        } else if(stakeholders[index].tier == 3 && ((block.timestamp - stakeholders[index].since) / 60 / 60) < 252) {
            revert("Stake not completed (1.5 weeks)");
        } else if(stakeholders[index].tier == 4 && ((block.timestamp - stakeholders[index].since) / 60 / 60 / 24 / 7) < 1) {
            revert("Stake not completed (1 week)");
        } else {
            uint256 reward = getStakeReward(stakeholders[index].user);
            require(reward >= _amount, "You have not this amount to withdraw");
            emit Withdraw(_sender, stakeholders[index].amount, reward, _amount, stakeholders[index].tier, index, stakeholders[index].since, block.timestamp);
            
            stakeholders[index].amount = reward - _amount;
            stakeholders[index].since = block.timestamp;
            stakeholders[index].tier = 0;
            
            IERC20 token = IERC20(tokenContractAddress);
            token.transfer(_sender, _amount);

            return true;
        }
    }


    function getStakeReward(address _user) public view returns (uint256) {
        uint256 index = stakes[_user];
        require(index != 0, "Yo do not have an active stake now");

        uint256 _amount = stakeholders[index].amount;
        uint256 _timestamp = stakeholders[index].since;

        uint256 reward;
        uint256 get_days = (block.timestamp - _timestamp) / 60 / 60 / 24;

        uint256 apr_converted = apr * 10000000 / 365;
        reward = _amount + get_days * _amount / 1000000000 * apr_converted;
        return reward;
    }



    function withdrawTokens(uint256 amount) public payable returns (bool) {
        IERC20 token = IERC20(tokenContractAddress);

        if(msg.sender != owner) {
            revert("You are not an owner of this contract");
        } else if(token.balanceOf(address(this)) < amount) {
            revert("Balance of this contract is less then amount of withdraw");
        } else {
            _withdrawTokens(amount);
            return true;
        }
    }

    function _withdrawTokens(uint256 amount) private {
        IERC20 token = IERC20(tokenContractAddress);
        token.transfer(owner, amount);
    }

    function getUserStake(address user) public view returns (uint256 amount, uint8 tier, uint256 since) {
        uint256 index = stakes[user];
        require(index > 0, "Stake is not found");
        return (stakeholders[index].amount, stakeholders[index].tier, stakeholders[index].since);
    }

    function setParams(
        uint256 new_apr, uint256 new_tier1, uint256 new_tier2, uint256 new_tier3, uint256 new_tier4
    ) public payable returns (bool) {
        if(msg.sender == owner) {
            apr = new_apr;
            tier1 = new_tier1 * 1000000000000000000;
            tier2 = new_tier2 * 1000000000000000000;
            tier3 = new_tier3 * 1000000000000000000;
            tier4 = new_tier4 * 1000000000000000000;
            return true;
        } else {
            revert("You are not an owner of this contract");
        }
    }

}

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}


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

/**
 * The main lottery contract. It is constructed with an application.
 */
contract Lottery is VRFConsumerBaseV2 {

    // The address of the ascent token.
    address tokenContractAddress = 0x7A66eBFD6Ef9e74213119717A3d03758A4A5891e;

    // The participant structure to keep track of participants.
    struct PlayerIndex {
        uint256 idx;
        uint32 numberOfTickets;
    }

    // The current index;
    uint256 public currentIndex;

    // The owner of the contract
    address owner;

    // The address mapping capturing the different players who have
    // participated so far in the lottery. We are setting this up
    // as a mapping to get O(1) access complexity.
    mapping(address => PlayerIndex) playerIndices;

    // The array of different player addresses so that we can iterate
    // later.
    address[] public players;

    // The opening time of the lottery, i.e. when the lottery begins,
    // in epoch time.
    uint256 public openingTime;

    // The end time of the lottery, i.e. when the lottery ends.
    uint256 public endTime;

    // The price of the ticket;
    uint256 public ticketPrice;

    // The number of winning slots
    uint32 public winningSlotNumber;

    // The final winner array
    address[] public winners;

    // The indicator that the random number generation has been
    // kicked off.
    bool randomNumbersGenerationKickedOff;

    // The maximum number of tickets per wallet.
    uint32 public maxNumberOfTicketsPerWallet;

    //////////////////////////////////////////////////
    // This section is initializing the needed
    // variables for chainlink
    //////////////////////////////////////////////////
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;

    // The chainlink subscription id
    uint64 s_subscriptionId;

    address vrfCoordinator;

    // Rinkeby LINK token contract. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    // TODO: Set this address correctly
    address link = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    // TODO: Get this value
    bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    // The interface does not expose MAX_NUM_WORDS, so we have to put it here.
    uint32 public constant MAX_NUM_WORDS = 500;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    // TODO: Check this limit as well.
    uint32 callbackGasLimit = MAX_NUM_WORDS * 30000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    mapping(uint256 => uint256[]) public requestIdToRandomWords;
    uint256[] requestIdsInOrder;
    uint256 public s_requestId;
    address s_owner;

    // The value of calls that we will need to make to the vrf
    uint32 numberOfCallsToVrfNeeded;

    // End of chainlink variables.
    //////////////////////////////////////////////////

    constructor(
        uint256 _openingTime,
        uint256 _endTime,
        uint256 _ticketPrice,
        uint32 _winningSlotNumber,
        uint32 _maxNumberOfTicketsPerWallet,
        address _ascTokenContractAddress,
        uint64 _subscriptionId,
        address _vrfCoordinator,
        bytes32 _gasLane,
        address _linkTokenAddress,
        address _owner) VRFConsumerBaseV2(_vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
        tokenContractAddress = _ascTokenContractAddress;
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        owner = _owner;
        currentIndex = 0;
        ticketPrice = _ticketPrice;
        openingTime = _openingTime;
        endTime = _endTime;
        keyHash = _gasLane;
        link = _linkTokenAddress;
        winningSlotNumber = _winningSlotNumber;
        require(_maxNumberOfTicketsPerWallet > 0);
        maxNumberOfTicketsPerWallet = _maxNumberOfTicketsPerWallet;
        require(winningSlotNumber <= MAX_NUM_WORDS);
        s_subscriptionId = _subscriptionId;
        randomNumbersGenerationKickedOff = false;
        uint32 maxNumWords = MAX_NUM_WORDS;
        uint32 div = winningSlotNumber/maxNumWords;
        uint32 rem = winningSlotNumber % maxNumWords;
        numberOfCallsToVrfNeeded =  div + (rem > 0 ? 1 : 0);
    }

    // The modifier to let people enter the lottery only while
    // the lottery is open.
    modifier onlyWhileOpen() {
        require(isOpen());
        _;
    }

    // The modifier to check that the address of the
    modifier didNotMaxOutTicketBuy() {
        require(playerIndices[msg.sender].numberOfTickets < maxNumberOfTicketsPerWallet);
        _;
    }

    // The function to figure out if the lottery is still open.
    function isOpen() public view returns (bool) {
        return (block.timestamp >= openingTime) && (block.timestamp < endTime);
    }

    // The event emitted whenever a ticket is being bought.
    event TicketBought(address indexed user, uint256 timestamp);

    // Random number generation finished
    event RandomNumberGenerationFinished(uint256 timestamp);

    // The event emitted for each user after the lottery is completed.
    event WinnerEvent(address indexed user);

    /**
     * The function to buy a ticket for the lottery
     */
    function buyTicket()
        public
        payable
        onlyWhileOpen
        didNotMaxOutTicketBuy
        returns (bool) {
        IERC20 token = IERC20(tokenContractAddress);
        address from_address = msg.sender;
        token.transferFrom(from_address, address(this), ticketPrice);
        currentIndex = currentIndex + 1;
        if (playerIndices[from_address].numberOfTickets == 0) {
            PlayerIndex memory playerIndex = PlayerIndex(currentIndex, 1);
            playerIndices[from_address] = playerIndex;
        } else {
            playerIndices[from_address].numberOfTickets++;
        }
        players.push(from_address);
        emit TicketBought(from_address, block.timestamp);
        return true;
    }

    /**
     * The function to buy a certain number of tickets for the lottery
     */
    function buyTickets(uint32 numberOfTickets)
        public
        payable
        onlyWhileOpen
        didNotMaxOutTicketBuy
        returns (bool) {
        require(numberOfTickets > 0);
        require(
            playerIndices[msg.sender].numberOfTickets + numberOfTickets <= maxNumberOfTicketsPerWallet
            );
        IERC20 token = IERC20(tokenContractAddress);
        address from_address = msg.sender;
        token.transferFrom(from_address, address(this), numberOfTickets * ticketPrice);
        uint32 i;
        for (i = 0; i < numberOfTickets; i++) {
            currentIndex = currentIndex + 1;
            if (playerIndices[from_address].numberOfTickets == 0) {
                PlayerIndex memory playerIndex = PlayerIndex(currentIndex, 1);
                playerIndices[from_address] = playerIndex;
            } else {
                playerIndices[from_address].numberOfTickets++;
            }
            players.push(from_address);
            emit TicketBought(from_address, block.timestamp);
        }
        return true;
    }

    // The function for the owner to withdraw their tokens.
    function withdrawTokens(uint256 amount)
        public
        payable
        onlyOwner
        returns (bool) {
        IERC20 token = IERC20(tokenContractAddress);
        if(token.balanceOf(address(this)) < amount) {
            revert("Balance of this contract is less then amount of withdraw");
        }
        token.transfer(owner, amount);
        return true;
    }

    // Ensuring that only the owner is able to call a specific function
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // The modifier to check that the lottery is finished to check the
    modifier afterFinished () {
        require (block.timestamp >= endTime);
        _;
    }

    // This function generates the needed random numbers
    // before the calculateWinners function can be called.
    function generateNeededRandomNumbers()
        public
        afterFinished
        onlyOwner {
        require(randomNumbersGenerationKickedOff == false);
        randomNumbersGenerationKickedOff = true;
        uint32 maxNumWords = MAX_NUM_WORDS;
        uint32 rem = winningSlotNumber % maxNumWords;
        uint32 i = 0;
        for(i = 0; i < numberOfCallsToVrfNeeded; i++) {
            uint32 numWords = ((i == numberOfCallsToVrfNeeded - 1) && (rem != 0)) ? rem : maxNumWords;
            COORDINATOR.requestRandomWords(
                keyHash,
                s_subscriptionId,
                requestConfirmations,
                callbackGasLimit,
                numWords);
        }
    }

    // overriding the requested method by chainlink to fulfill
    // the random numbers.
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
        ) internal override {
        requestIdToRandomWords[requestId] = randomWords;
        requestIdsInOrder.push(requestId);
        if (requestIdsInOrder.length == numberOfCallsToVrfNeeded) {
            emit RandomNumberGenerationFinished(block.timestamp);
        }
    }

    // This is a modifier ensuring that we are only calling a
    // specific function after the call to all random numbers
    // is finished.
    modifier afterRandomNumbersAreGenerated() {
        require(requestIdsInOrder.length == numberOfCallsToVrfNeeded);
        _;
    }

    // After the lottery period is done, the winners can be calculated
    // and finalized.
    function calculateWinners()
        public
        onlyOwner
        afterFinished
        afterRandomNumbersAreGenerated {
        require(randomNumbersGenerationKickedOff);
        require(winners.length == 0);
        if (players.length <= winningSlotNumber) {
            winners = players;
        } else {
            _fillWinnerArrayFromPlayers();
        }
        _announceWinners();
    }

    function _announceWinners()
        private
        afterFinished {
        require (winners.length == (players.length <= winningSlotNumber ? players.length : winningSlotNumber));
        uint32 i;
        for (i = 0; i < winners.length; i++) {
            emit WinnerEvent(winners[i]);
        }
    }

    struct UniqueHashIndex {
        uint256 idx;
        bool isValue;
    }

    mapping(uint256 => UniqueHashIndex) hash;

    // The function to fill the array of winners from players.
    function _fillWinnerArrayFromPlayers()
        private {
        require(players.length > winningSlotNumber); // Just in case
        uint256[] memory randomNumbers = new uint256[](winningSlotNumber);
        uint256 i;
        uint256 j;
        uint256 randomNumbersCurrentIndex = 0;
        for (i = 0; i < requestIdsInOrder.length; i++) {
            uint256[] memory randomNumbersForRequestId = requestIdToRandomWords[requestIdsInOrder[i]];
            for (j = 0; j < randomNumbersForRequestId.length; j++) {
                randomNumbers[randomNumbersCurrentIndex] = randomNumbersForRequestId[j];
                randomNumbersCurrentIndex = randomNumbersCurrentIndex + 1;
            }
        }
        require(randomNumbers.length == winningSlotNumber); // Sanity check
        for (i = 0; i < winningSlotNumber; i++) {
            j = randomNumbers[i] % (players.length - i);
            uint256 nextWinnerIdx;
            if (hash[j].isValue) {
                nextWinnerIdx = hash[j].idx;
                hash[j].idx = 0;
                hash[j].isValue = false;
            } else {
                nextWinnerIdx = j;
            }
            winners.push(players[nextWinnerIdx]);
            if (j > i) {
                if (hash[i].isValue) {
                    hash[j] = hash[i];
                    hash[i].idx = 0;
                    hash[i].isValue = false;
                } else {
                    hash[j].idx = i;
                    hash[j].isValue = true;
                }
            }
        }
    }

    /**
     * The modifier to ensure that the winners have been completely added
     * by the randomizer.
     */
    modifier afterWinnerDeterminationComplete() {
        require(winners.length >= winningSlotNumber);
        _;
    }

    function addOtherWinners(address winnerAddress)
        public
        onlyOwner
        afterWinnerDeterminationComplete {
        winners.push(winnerAddress);
        winningSlotNumber++;
    }

    function isWinner(address addressToCheck)
        public
        view
        afterWinnerDeterminationComplete
        returns (bool) {
        uint32 i;
        for (i = 0; i < winners.length; i++) {
            if (addressToCheck == winners[i]) {
                return true;
            }
        }
        return false;
    }

    /**
     * This function returns how many tickets the current user has bought
     * in total.
     */
    function myPurchasedTickets()
        public
        view
        returns (uint32) {
        return playerIndices[msg.sender].numberOfTickets;
    }
}

contract Contribution is Ownable {

    // The opening time of the contribution period.
    uint256 public beginTime;

    // The end tiume of the contribution period.
    uint256 public endTime;

    // The variable holding the phase end times.
    mapping (uint8 => uint256) public phaseEndTimes;

    // The contribution amount which is aimed to be raised
    uint256 public contributionAmount;

    // The remaining contributionAmount still to be filled
    uint256 public remainingContributionAmount;

    // Contribution token address, which is by default set to BUSD.
    address contributionTokenAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // The structure to hold minimum or maximum contributions
    // for a specific phase
    struct ContributionMinMax {
        uint256 jupiter;
        uint256 mercury;
        uint256 mars;
        uint256 apollo;
        uint256 venus;
    }

    // The structure to capture min and max contribution for each phase
    struct ContributionMinMaxByPhase {
        ContributionMinMax min;
        ContributionMinMax max;
    }

    // The mapping that holds minimum and maximum value by phase.
    // In our code logic, we control that there is never more than 4
    // phases.
    mapping (uint8 => ContributionMinMaxByPhase) internal contributionMinMaxByPhase;

    // Looking inside the internals for the owner
    function getContributionMinByPhase(uint8 phase, uint8 tier) public view onlyOwner returns (uint256) {
        require((tier > 0) && (tier <=5));
        if (tier == 1) {
            return contributionMinMaxByPhase[phase].min.jupiter;
        } else if (tier == 2) {
            return contributionMinMaxByPhase[phase].min.mercury;
        } else if (tier == 3) {
            return contributionMinMaxByPhase[phase].min.mars;
        } else if (tier == 4) {
            return contributionMinMaxByPhase[phase].min.apollo;
        } else {
            return contributionMinMaxByPhase[phase].min.venus;
        }
    }

    // Looking inside the internals for the owner
    function getContributionMaxByPhase(uint8 phase, uint8 tier) public view onlyOwner returns (uint256) {
        require((tier > 0) && (tier <= 5));
        if (tier == 1) {
            return contributionMinMaxByPhase[phase].max.jupiter;
        } else if (tier == 2) {
            return contributionMinMaxByPhase[phase].max.mercury;
        } else if (tier == 3) {
            return contributionMinMaxByPhase[phase].max.mars;
        } else if (tier == 4) {
            return contributionMinMaxByPhase[phase].max.apollo;
        } else {
            return contributionMinMaxByPhase[phase].max.venus;
        }
    }

    // Since Solidity does not support floating point numbers yet, we need
    // to define our factors using numerator and denominator.
    // We are using 1M as a divisor to allow up to 6 digits after the comma.
    uint256 constant internal factorDivisor = 1000 * 1000;

    // The structure to capture all factors for each phase
    struct PhaseFactorNumerators {
        uint256 jupiter;
        uint256 mercury;
        uint256 mars;
        uint256 apollo;
        uint256 venus;
    }

    // We will get the tier holder numbers through the constructor as
    // a starting point.
    struct CurrentTierHolderNumbers {
        uint32 jupiter;
        uint32 mercury;
        uint32 mars;
        uint32 apollo;
        uint32 venus;
    }

    // The mapping that maps factors to each phase.
    mapping (uint8 => PhaseFactorNumerators) internal factorsByPhase;

    // The enum that takes us through the different phases.
    enum ContributionStatus {
        NOT_STARTED,
        PHASE_1,
        PHASE_2,
        PHASE_3,
        ENDED_AND_PENDING_DECISION,
        FAILED_TO_RAISE,
        SUCCESSFUL
    }

    // Looking inside the internals for the owner
    function getFactorByPhase(uint8 phase, uint8 tier) public view onlyOwner returns (uint256) {
        require((tier > 0) && (tier <= 5));
        if (tier == 1) {
            return factorsByPhase[phase].jupiter;
        } else if (tier == 2) {
            return factorsByPhase[phase].mercury;
        } else if (tier == 3) {
            return factorsByPhase[phase].mars;
        } else if (tier == 4) {
            return factorsByPhase[phase].apollo;
        } else {
            return factorsByPhase[phase].venus;
        }
    }

    // Holding the information about the current contribution status.
    ContributionStatus internal contributionStatus = ContributionStatus.NOT_STARTED;

    // The contract to access the staking
    AscentLock internal ascentLock;

    // The contract to access the lottery
    Lottery internal lottery;

    struct ContributionInformation {
        mapping(uint8 => mapping(uint8 => uint256)) contributionByPhaseAndTier;
        uint256 totalContribution;
        uint256 index;
    }

    function getTotalContributionForPhase(uint8 phase) public view returns (uint256) {
        uint8 i;
        uint256 result = 0;
        for (i = 1; i <= 5; i++) {
            result += totalContributionByPhaseAndTier[phase][i];
        }
        return result;
    }

    mapping(uint8 => mapping(uint8 => uint256)) public totalContributionByPhaseAndTier;

    mapping(address => ContributionInformation) public contributionInformation;

    function getTotalContributionForUser(address userAddress) public view returns (uint256) {
        return contributionInformation[userAddress].totalContribution;
    }

    address[] contributors;

    constructor(uint256 _beginTime,
                uint256 _endTime,
                uint256 _contributionAmount,
                CurrentTierHolderNumbers memory _currentTierHolderNumbers,
                address payable stakingAddress,
                address payable lotteryAddress) {
        require (_endTime > _beginTime);
        beginTime = _beginTime;
        endTime = _endTime;
        contributionAmount = _contributionAmount;
        remainingContributionAmount = _contributionAmount;
        ascentLock = AscentLock(stakingAddress);
        lottery = Lottery(lotteryAddress);
        _initializePhases();
        _initializeFactors();
        _initializeContributionMinMax(_currentTierHolderNumbers);
    }

    // Initializing phase divisors assuming equal distribution.
    function _initializePhases() private {
        uint256 phaseLength = (endTime - beginTime)/3;
        uint8 i;
        for (i = 1; i < 3; i++) {
            uint256 phaseEndTime = beginTime + uint256(i) * phaseLength;
            require (phaseEndTime < endTime);
            phaseEndTimes[i] = phaseEndTime;
        }
    }

    // Initializing the factors for each phase.
    function _initializeFactors() private {
        PhaseFactorNumerators memory phaseOne = PhaseFactorNumerators({
            jupiter: 700000,
            mercury: 175000,
            mars:     75000,
            apollo:   35000,
            venus:    15000
            });
        PhaseFactorNumerators memory phaseTwo = PhaseFactorNumerators({
            jupiter: 500000,
            mercury: 250000,
            mars:    125000,
            apollo:   62500,
            venus:    62500
            });
        factorsByPhase[1] = phaseOne;
        factorsByPhase[2] = phaseTwo;
    }

    function _initializeContributionMinMax(CurrentTierHolderNumbers memory tierHolderNumbers) internal {
        ContributionMinMax memory contributionMaxPhaseOne = ContributionMinMax({
            jupiter: (contributionAmount * factorsByPhase[1].jupiter)/(factorDivisor * tierHolderNumbers.jupiter),
            mercury: (contributionAmount * factorsByPhase[1].mercury)/(factorDivisor * tierHolderNumbers.mercury),
            mars:    (contributionAmount * factorsByPhase[1].mars)/(factorDivisor * tierHolderNumbers.mars),
            apollo:  (contributionAmount * factorsByPhase[1].apollo)/(factorDivisor * tierHolderNumbers.apollo),
            venus:   (contributionAmount * factorsByPhase[1].venus)/(factorDivisor * tierHolderNumbers.venus)
            });
        ContributionMinMax memory contributionMinPhaseOne = ContributionMinMax({
            jupiter: (contributionAmount * factorsByPhase[1].jupiter)/(3 * factorDivisor * tierHolderNumbers.jupiter),
            mercury: (contributionAmount * factorsByPhase[1].mercury)/(3 * factorDivisor * tierHolderNumbers.mercury),
            mars:    (contributionAmount * factorsByPhase[1].mars)/(3 * factorDivisor * tierHolderNumbers.mars),
            apollo:  (contributionAmount * factorsByPhase[1].apollo)/(3 * factorDivisor * tierHolderNumbers.apollo),
            venus:   (contributionAmount * factorsByPhase[1].venus)/(3 * factorDivisor * tierHolderNumbers.venus)
            });
        // We assume that we made half in phase 1 as a simplified model
        ContributionMinMax memory contributionMaxPhaseTwo = ContributionMinMax({
            jupiter: (2 * contributionAmount * factorsByPhase[2].jupiter)/(factorDivisor * tierHolderNumbers.jupiter),
            mercury: (2 * contributionAmount * factorsByPhase[2].mercury)/(factorDivisor * tierHolderNumbers.mercury),
            mars:    (2 * contributionAmount * factorsByPhase[2].mars)/(factorDivisor * tierHolderNumbers.mars),
            apollo:  (2 * contributionAmount * factorsByPhase[2].apollo)/(factorDivisor * tierHolderNumbers.apollo),
            venus:   (2 * contributionAmount * factorsByPhase[2].venus)/(factorDivisor * tierHolderNumbers.venus)
            });
        ContributionMinMax memory contributionMinPhaseTwo = ContributionMinMax({
            jupiter: (contributionAmount * factorsByPhase[2].jupiter)/(4 * factorDivisor * tierHolderNumbers.jupiter),
            mercury: (contributionAmount * factorsByPhase[2].mercury)/(4 * factorDivisor * tierHolderNumbers.mercury),
            mars:    (contributionAmount * factorsByPhase[2].mars)/(4 * factorDivisor * tierHolderNumbers.mars),
            apollo:  (contributionAmount * factorsByPhase[2].apollo)/(4 * factorDivisor * tierHolderNumbers.apollo),
            venus:   (contributionAmount * factorsByPhase[2].venus)/(4 * factorDivisor * tierHolderNumbers.venus)
            });
        // Adding phase 3
        ContributionMinMax memory contributionMaxPhaseThree = ContributionMinMax({
            jupiter: (4 * contributionAmount)/(tierHolderNumbers.jupiter),
            mercury: (4 * contributionAmount)/(tierHolderNumbers.mercury),
            mars:    (4 * contributionAmount)/(tierHolderNumbers.mars),
            apollo:  (4 * contributionAmount)/(tierHolderNumbers.apollo),
            venus:   (4 * contributionAmount)/(tierHolderNumbers.venus)
            });
        ContributionMinMax memory contributionMinPhaseThree = ContributionMinMax({
            jupiter: (contributionAmount)/(8 * tierHolderNumbers.jupiter),
            mercury: (contributionAmount)/(8 * tierHolderNumbers.mercury),
            mars:    (contributionAmount)/(8 * tierHolderNumbers.mars),
            apollo:  (contributionAmount)/(8 * tierHolderNumbers.apollo),
            venus:   (contributionAmount)/(8 * tierHolderNumbers.venus)
            });
        // Putting it all into the mapping
        contributionMinMaxByPhase[1] = ContributionMinMaxByPhase({
            min: contributionMinPhaseOne,
            max: contributionMaxPhaseOne
            });
        contributionMinMaxByPhase[2] = ContributionMinMaxByPhase({
            min: contributionMinPhaseTwo,
            max: contributionMaxPhaseTwo
            });
        contributionMinMaxByPhase[3] = ContributionMinMaxByPhase({
            min: contributionMinPhaseThree,
            max: contributionMaxPhaseThree
            });
    }

    // The modifier to check if the contribution period is active.
    modifier isActiveModifier {
        require(isActive());
        _;
    }

    //The function to verify that the contribution period is active.
    function isActive() public view returns (bool) {
        return ((contributionStatus != ContributionStatus.SUCCESSFUL)
                && (contributionStatus != ContributionStatus.FAILED_TO_RAISE)
                && (block.timestamp >= beginTime)
                && (block.timestamp <= endTime));
    }

    // The event that is emitted any time a contribution is being made.
    event ContributionRecorded(address contributor,
                               uint8 tier,
                               uint256 amount,
                               uint256 remainingContribution);

    // The power button to end contribution on command if needed.
    function declareSuccessfulOrFail(bool success) public onlyOwner {
        if (success) {
            contributionStatus = ContributionStatus.SUCCESSFUL;
        } else {
            contributionStatus = ContributionStatus.FAILED_TO_RAISE;
        }
    }

    /**
     * It is important that
     * jupiterFactor + mercuryFactor + marsFactor + apolloFactor + venusFactor = 1000000
     * or more precisely, the denominator.
     */
    function alterFactorsByPhase(uint8 phase,
                                 uint256 jupiterFactor,
                                 uint256 mercuryFactor,
                                 uint256 marsFactor,
                                 uint256 apolloFactor,
                                 uint256 venusFactor) public onlyOwner {
        require((phase > 0) && (phase < 3));
        require(jupiterFactor + mercuryFactor + marsFactor + apolloFactor + venusFactor == factorDivisor);
        PhaseFactorNumerators memory newFactors = PhaseFactorNumerators({
            jupiter: jupiterFactor,
            mercury: mercuryFactor,
            mars: marsFactor,
            apollo: apolloFactor,
            venus: venusFactor
            });
        factorsByPhase[phase] = newFactors;
    }

    /**
     * This sets a new endtime for a phase provided as argument.
     */
    function setPhaseEndTime(uint8 phase, uint256 newTime) public onlyOwner {
        require((phase > 0) && (phase < 3));
        require((newTime > beginTime) && (newTime < endTime));
        uint8 i;
        for (i = 1; i < phase; i++) {
            require(phaseEndTimes[i] < newTime);
        }
        phaseEndTimes[phase] = newTime;
    }

    // Alters the minimumcontribution for a specific tier
    function alterContributionMin(uint8 phase, uint8 tier, uint256 contributionMin) public onlyOwner {
        require((tier >= 1) && (tier <= 5));
        require(contributionMin > 0);
        require((phase > 0) && (phase < 4));
        if (tier == 1) {
            contributionMinMaxByPhase[phase].min.jupiter = contributionMin;
        } else if (tier == 2) {
            contributionMinMaxByPhase[phase].min.mercury = contributionMin;
        } else if (tier == 3) {
            contributionMinMaxByPhase[phase].min.mars = contributionMin;
        } else if (tier == 4) {
            contributionMinMaxByPhase[phase].min.apollo = contributionMin;
        } else {
            contributionMinMaxByPhase[phase].min.venus = contributionMin;
        }
    }

    // Alters the maxiumum contribution for a specific phase
    function alterContributionMax(uint8 phase, uint8 tier, uint256 contributionMax) public onlyOwner {
        require((tier >= 1) && (tier <= 5));
        require(contributionMax > 0);
        require((phase > 0) && (phase < 4));
        if (tier == 1) {
            contributionMinMaxByPhase[phase].max.jupiter = contributionMax;
        } else if (tier == 2) {
            contributionMinMaxByPhase[phase].max.mercury = contributionMax;
        } else if (tier == 3) {
            contributionMinMaxByPhase[phase].max.mars = contributionMax;
        } else if (tier == 4) {
            contributionMinMaxByPhase[phase].max.apollo = contributionMax;
        } else {
            contributionMinMaxByPhase[phase].max.venus = contributionMax;
        }
    }

    function _userIsInTier(uint8 tier) internal view returns (bool) {
        bool result = false;
        if (tier < 5) {
            result = ascentLock.isInTier(tier, msg.sender);
        } else {
            // Lottery case
            if (lottery.isWinner(msg.sender)) {
                result = true;
            }
        }
        return result;
    }

    function getCurrentPhase()
        public
        view
        returns (ContributionStatus) {
        if ((contributionStatus == ContributionStatus.SUCCESSFUL)
            || (contributionStatus == ContributionStatus.FAILED_TO_RAISE)) {
            return contributionStatus;
        }
        if (block.timestamp < beginTime) {
            return ContributionStatus.NOT_STARTED;
        } else if (block.timestamp < phaseEndTimes[1]) {
            return ContributionStatus.PHASE_1;
        } else if (block.timestamp < phaseEndTimes[2]) {
            return ContributionStatus.PHASE_2;
        } else if (block.timestamp <= endTime) {
            return ContributionStatus.PHASE_3;
        } else {
            return ContributionStatus.ENDED_AND_PENDING_DECISION;
        }
    }

    modifier isWithinContributionMinMax(uint256 amount, uint8 tier) {
        ContributionStatus phase = getCurrentPhase();
        if (phase == ContributionStatus.PHASE_1) {
            uint256 alreadyContributed = contributionInformation[msg.sender].contributionByPhaseAndTier[1][tier];
            require((amount >= getContributionMinByPhase(1, tier))
                    && (amount + alreadyContributed <= getContributionMaxByPhase(1, tier)));
        } else if (phase == ContributionStatus.PHASE_2) {
            uint256 alreadyContributed = contributionInformation[msg.sender].contributionByPhaseAndTier[2][tier];
            require((amount >= getContributionMinByPhase(2, tier))
                    && (amount + alreadyContributed <= getContributionMaxByPhase(2, tier)));
        } else if (phase == ContributionStatus.PHASE_3) {
            uint256 alreadyContributed = contributionInformation[msg.sender].contributionByPhaseAndTier[3][tier];
            require((amount >= getContributionMinByPhase(3, tier))
                    && (amount + alreadyContributed <= getContributionMaxByPhase(3, tier)));
        }
        _;
    }

    modifier tierForPhaseNotMaxedOutAfter(uint256 amount, uint8 tier) {
        ContributionStatus phase = getCurrentPhase();
        if (phase == ContributionStatus.PHASE_1) {
            uint256 maxAmount = (getFactorByPhase(1, tier) * contributionAmount)/factorDivisor;
            require((amount + totalContributionByPhaseAndTier[1][tier]) < maxAmount);
        } else if (phase == ContributionStatus.PHASE_2) {
            uint256 maxAmount = (getFactorByPhase(2, tier) * (contributionAmount - getTotalContributionForPhase(2)))/factorDivisor;
            require((amount + totalContributionByPhaseAndTier[2][tier]) < maxAmount);
        }
        _;
    }

    function contribute(uint256 amount, uint8 tier)
        public
        isActiveModifier
        isWithinContributionMinMax(amount, tier)
        tierForPhaseNotMaxedOutAfter(amount, tier)
        payable {
        if (!_userIsInTier(tier)) {
            revert("user was not in the tier that was assigned.");
        }
        require(amount <= remainingContributionAmount);
        IERC20 token = IERC20(contributionTokenAddress);
        token.transferFrom(msg.sender, address(this), amount);
        uint8 phase;
        ContributionStatus currentPhaseEnum = getCurrentPhase();
        if (currentPhaseEnum == ContributionStatus.PHASE_1) {
            phase = 1;
        } else if (currentPhaseEnum == ContributionStatus.PHASE_2) {
            phase = 2;
        } else {
            phase = 3;
        }
        if (contributionInformation[msg.sender].totalContribution == 0) {
            contributionInformation[msg.sender].index = contributors.length;
            contributors.push(msg.sender);
        }
        contributionInformation[msg.sender].contributionByPhaseAndTier[phase][tier] += amount;
        contributionInformation[msg.sender].totalContribution += amount;
        totalContributionByPhaseAndTier[phase][tier] += amount;
        remainingContributionAmount -= amount;
        emit ContributionRecorded(msg.sender, tier, amount, remainingContributionAmount);
    }

    function refundByAdmin() public onlyOwner payable {
        uint32 i;
        IERC20 token = IERC20(contributionTokenAddress);
        for (i = 0 ; i < contributors.length; i++) {
            uint256 refundAmount = 0;
            address walletAddress = contributors[i];
            refundAmount = contributionInformation[walletAddress].totalContribution;
            if (refundAmount > 0) {
                token.transfer(walletAddress, refundAmount);
            }
            delete contributionInformation[walletAddress];
        }
        delete contributors;
        uint8 phase;
        uint8 tier;
        for (phase = 1; phase <= 3; phase++) {
            for (tier = 1; tier <= 5; tier++) {
                delete totalContributionByPhaseAndTier[phase][tier];
            }
        }
    }

    modifier ifContributionFailed {
        require(contributionStatus == ContributionStatus.FAILED_TO_RAISE);
        _;
    }

    // The function to be called by individuals to get a refund in the case when
    // the contribution failed.
    function refundMe() public ifContributionFailed {
        IERC20 token = IERC20(contributionTokenAddress);
        address wallet_address = msg.sender;
        uint256 totalContribution = contributionInformation[wallet_address].totalContribution;
        require(totalContribution > 0);
        uint256 idx = contributionInformation[wallet_address].index;
        token.transfer(wallet_address, totalContribution);
        delete contributionInformation[wallet_address];
        delete contributors[idx];
    }

    // A way for the owner to withdraw funds.
    function withdrawFunds(uint256 amount) public onlyOwner returns(bool) {
        IERC20 token = IERC20(contributionTokenAddress);
        if(token.balanceOf(address(this)) < amount) {
            revert("Balance of this contract is less then amount of withdraw");
        }
        token.transfer(owner(), amount);
        return true;
    }

    // Helper function, mainly for testing, to set the contribution token address.
    function setContributionTokenAddress(address tokenAddress) public onlyOwner {
        contributionTokenAddress = tokenAddress;
    }
}