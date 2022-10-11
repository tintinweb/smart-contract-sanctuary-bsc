/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT
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

// File: gist-36e9df864574cc1249ad09b7c75b5e1a/gamebalance.sol



pragma solidity ^0.8.0;

abstract contract gamebalances {
    address private dsbAddress;
    mapping(address => uint256) private game_player_blacklist;
    mapping(address => int256[1010]) private game_player_balances;
    mapping(address => uint256) internal player_wins;
    mapping(address => uint256) internal player_timesPlayed;


    struct  userPlays {
        address playerAddress;
        uint256 vrfID;
        int256 winAmount;
        uint256 currencyIndex;
        uint256 wager;
        uint256 timestamp;
        uint256 outcome;    
    }
    /*
        outcome values
        0   waiting
        1   won
        2   lost
        3   refund
    */
    struct receivedResults {
        uint256 vrfID;
        uint256 vrfNumber;
    }

   
    receivedResults[] internal vrfOutcomes;
    uint256 vrfOutcomesIndex=0;

    mapping(address => userPlays[]) internal playerPlaysHistory;

    event blacklistPlayer(address playerAddress, bool blacklisted);

    constructor(address deposits) {
        dsbAddress=deposits;
        vrfOutcomes.push(receivedResults(0,0));
    }

    function game_dsbAddress() external view returns (address) {
        return dsbAddress;
    }

    function viewGameBalance(address accountAddress, uint256 selectedCurrency) public view returns (int256) {  
        return game_player_balances[accountAddress][selectedCurrency] + getUnpaidWinnings(accountAddress,selectedCurrency);
    }

    function game_get_player_blacklist(address senderAddress) public view returns (uint256) {
       return game_player_blacklist[senderAddress];
    }
    function game_blacklistPlayer(address senderAddress, bool b) internal {
       uint256 n = 0;
       if(b) { n=1; }
       game_player_blacklist[senderAddress]=n;
       emit blacklistPlayer(senderAddress, b);

    }
    function game_updateBlacklist(address playerAddress, bool allowed) internal {
        game_blacklistPlayer(playerAddress, allowed);
    }
    function game_alterPlayerBalance(int256 bChange, address playerAddress, uint256 selectedCurrency ) internal {
        game_player_balances[playerAddress][selectedCurrency]+=bChange;
    }

    function updatePlayerHistory(address playerAddress) internal returns (uint256) {
        
        uint256 txnCount=0;
        for(uint256 i=0;i<playerPlaysHistory[playerAddress].length;i++) {
            if(playerPlaysHistory[playerAddress][i].outcome==0) {
                uint256 vIndex = getReceivedVrfIndexByVrfId(playerPlaysHistory[playerAddress][i].vrfID);
                    if(vIndex>0) {
                        uint256 n = vrfOutcomes[vIndex].vrfNumber%2==0 ? 1 : 2;
                        playerPlaysHistory[playerAddress][i].outcome=n;
                        uint256 lastIndex = vrfOutcomes.length-1;
                        vrfOutcomes[vIndex] = vrfOutcomes[lastIndex];
                        vrfOutcomes.pop();
                        if(n==1) { 
                            game_alterPlayerBalance(playerPlaysHistory[playerAddress][i].winAmount, playerAddress,playerPlaysHistory[playerAddress][i].currencyIndex ); 
                            
                            player_wins[playerAddress]++;
                        }
                        uint256 lastIndexPlayerHistory = playerPlaysHistory[playerAddress].length-1;
                        playerPlaysHistory[playerAddress][i] = playerPlaysHistory[playerAddress][lastIndexPlayerHistory];
                        playerPlaysHistory[playerAddress].pop();
                        txnCount++;
                        if(txnCount>3) { break; }
                    }
            }
        }
        return txnCount;
    }
    function getUnpaidWinnings(address playerAddress, uint256 selectedCurrency ) public view returns (int256) {
        int256 unpaidWinnings=0;
        for(uint256 i=0;i<playerPlaysHistory[playerAddress].length;i++) {
            if(playerPlaysHistory[playerAddress][i].outcome==0 && playerPlaysHistory[playerAddress][i].currencyIndex==selectedCurrency) {
                uint256 vIndex = getReceivedVrfIndexByVrfId(playerPlaysHistory[playerAddress][i].vrfID);
                    if(vIndex>0) {
                        uint256 n = vrfOutcomes[vIndex].vrfNumber%2==0 ? 1 : 2;
                        if(n==1){ unpaidWinnings+=playerPlaysHistory[playerAddress][i].winAmount ;}
                        
                    }
            }
        }
        return unpaidWinnings;
    }
    function getOverallPlayerWins(address playerAddress) public view returns(uint256){
        return player_wins[playerAddress];
    }
    function getHistorySlice(address playerAddress, uint256 selectedCurrency, uint256 historyIndex) external view returns (userPlays memory) {
        uint256 n=0;
        userPlays memory up;
        for(uint256 i=0;i<playerPlaysHistory[playerAddress].length;i++) {
            if(playerPlaysHistory[playerAddress][i].currencyIndex==selectedCurrency ) {
                if(n==historyIndex) {
                    up= playerPlaysHistory[playerAddress][i];
                    break;
                }
                n++;
            }
        }
        return up;
    }

    function getReceivedVrfIndexByVrfId(uint256 vrfID) internal view returns (uint256) {
        for(uint256 i=0;i<vrfOutcomes.length;i++) {
            if(vrfOutcomes[i].vrfID == vrfID) {
                return i;
            }
        }
        return 0;
    }
    function getReceivedVRFbyIndex(uint256 vIndex) internal view returns (receivedResults memory) {
        if(vIndex<vrfOutcomes.length) {
            return vrfOutcomes[vIndex];
        }
        return vrfOutcomes[0];
    }
    function getReceivedVrfNumByVrfId(uint256 vrfID) public view returns (uint256) {
        for(uint256 i=0;i<vrfOutcomes.length;i++) {
            if(vrfOutcomes[i].vrfID == vrfID) {
                return vrfOutcomes[i].vrfNumber;
            }
        }
        return 0;
    }
    function getVRFoutcomesSize() public view returns(uint256) {
        return vrfOutcomes.length;
    }

    function _purgeVRF(uint256 amountToRemove) internal returns (uint256) {
        uint256 lastIndex=vrfOutcomes.length-1;
        if(vrfOutcomes.length>amountToRemove) {
            for(uint256 i=0;i<amountToRemove;i++) {
                vrfOutcomes[i]=vrfOutcomes[lastIndex-i];
                vrfOutcomes.pop();
            }
        }
        return vrfOutcomes.length;
    }

}
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

// File: gist-36e9df864574cc1249ad09b7c75b5e1a/vrf.sol



pragma solidity ^0.8.0;




abstract contract VRFv2Consumer is VRFConsumerBaseV2, Ownable {
    VRFCoordinatorV2Interface COORDINATOR;

    //bsc
    uint64 s_subscriptionId=535;
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;


    uint32 callbackGasLimit = 900000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  1;
    uint256[] internal s_randomWords;
    uint256 public s_requestId;
    address s_owner;

    constructor() VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
    }

    function requestRandomWords() internal returns (uint256) {
    // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords( keyHash, s_subscriptionId, requestConfirmations, callbackGasLimit, numWords);   
        return s_requestId; 
    }

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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: gist-36e9df864574cc1249ad09b7c75b5e1a/DSBbalances.sol





pragma solidity ^0.8.0;


abstract contract DSBbalances is Ownable {
    address private dsb_adminWallet;

    ERC20[] private dsb_acceptedCurrencies; 
    uint256[] private dsb_acceptedCurrenciesStatus;
    uint256[] private dsb_acceptedCurrenciesConversionFactor;

    gamebalances[] internal dsb_gameDeposits;
    uint256[] private dsb_gamePlayStatus;


    mapping(address => int256[1010]) private dsb_player_balances;
    mapping(address => uint256) private dsb_player_blacklist;

    event currencyAdded(address currencyAddress, address admin);
    event gameAdded(address gameAddress, address admin);
    event isPlayerBlacklisted(address account, bool blStatus, address admin);
    event deposit(address account, uint256 amount, address currency);
    event withdraw(address account, uint256 amount, address currency);
    event appStatusChanged(address app,uint256 status,address admin);
    event currencyStatusChanged(address currency,uint256 status,address admin);
    event currencyFactorChanged(address currency,uint256 status,address admin);


    function dsb_setAdminWallet(address newWallet) public onlyOwner {    
        require(newWallet != address(0), "New admin wallet is the zero address");
        dsb_adminWallet = newWallet;
    }
    function dsb_get_adminWallet() external view returns (address) {
        return dsb_adminWallet;
    }

    //platform apps
    function dsb_addPlatformApp(gamebalances gameApp) internal {
        require(msg.sender==dsb_adminWallet,"Denied.");
        require(gameApp.game_dsbAddress()==address(this),"app not compatible");
        dsb_gameDeposits.push(gameApp);
        dsb_gamePlayStatus.push(0);
        emit gameAdded(address(gameApp), msg.sender);
    }
    function getAppIndex(address appAddress) public view returns (int256) {
        int256 gIndex=-1;
        for(uint256 i=0;i<dsb_gameDeposits.length;i++) {
            if(address(dsb_gameDeposits[i])==appAddress) {
                gIndex = int256(i);
                break;
            }
        }
        return gIndex;
    }
    /*
        app status, index of dsb_gamePlayStatus
        0   enabled, include game balance
        1   disabled, include game balance
        2   disabled, exclude game balance
    */
    function getPlatformAppStatus(address appAddress) public view returns (int256) {
        int256 gIndex = getAppIndex(appAddress);
        int256 status=-1;
        if(gIndex>=0) {
            status = int256(dsb_gamePlayStatus[uint256(gIndex)]);
        }
        return status;
    }
    function setPlatformAppStatus(address appAddress, uint256 status) public {
        require(msg.sender==dsb_adminWallet,"Denied.");    
        int256 gIndex=getAppIndex(appAddress);
        require (gIndex>0); 
        dsb_gamePlayStatus[uint256(gIndex)] = status;
        emit appStatusChanged(appAddress,status,msg.sender);
    }


    //currencies 
    function dsb_addCurrency(ERC20 token) internal  {
        require(msg.sender==dsb_adminWallet,"Denied.");  
        require(token.totalSupply()>0,"Currency not compatible."); 
        dsb_acceptedCurrencies.push(token);
        dsb_acceptedCurrenciesStatus.push(0);
        dsb_acceptedCurrenciesConversionFactor.push(10000000000000000);
        emit currencyAdded(address(token), msg.sender);
    }
    function dsb_getAcceptedCurrenciesCount() public view returns (uint256) {
        uint256 counter=0;
        for(uint256 i=0;i<dsb_acceptedCurrencies.length;i++) {
            if(dsb_acceptedCurrenciesStatus[i]==0) { counter++; }
        }
        return counter;
    }
    function dsb_getTokenAddressByIndex(uint256 tokenIndex) public view returns (ERC20) {
        return dsb_acceptedCurrencies[tokenIndex];
    }
    function dsb_getListOfCurrencies() external view returns (ERC20[] memory) {
        return (dsb_acceptedCurrencies);
    }
    function dsb_getListOfCurrenciesStatus() external view returns (uint256[] memory) {
        return (dsb_acceptedCurrenciesStatus);
    }
    function dsb_getacceptedCurrenciesConversionFactor() external view returns (uint256[] memory) {
        return (dsb_acceptedCurrenciesConversionFactor);
    }
    function dsb_getacceptedCurrenciesConversionFactorByCurrency(uint256 selectedCurrency) external view returns (uint256) {
        return (dsb_acceptedCurrenciesConversionFactor[selectedCurrency]);
    }
    function getTokenIndexByAddress(address tokenAddress) public view returns (int256) {
        int256 cIndex=-1;
        for(uint256 i=0;i<dsb_acceptedCurrencies.length;i++) {
            if(address(dsb_acceptedCurrencies[i])==tokenAddress) {
                cIndex = int256(i);
                break;
            }
        }
        return cIndex;
    }
    /*
        currency accepted, index of dsb_acceptedCurrenciesStatus
        0   enabled
        1   disabled
    */
    function dsb_update_acceptedCurrenciesConversionFactor(address tokenAddress,uint256 factor) external  {
        require(msg.sender==dsb_adminWallet,"Denied."); 
        int256 cIndex = getTokenIndexByAddress(tokenAddress);
        require (cIndex>=0);
        dsb_acceptedCurrenciesConversionFactor[uint256(cIndex)] = factor;
        emit currencyFactorChanged(tokenAddress, factor, msg.sender);
    }
    function dsb_update_acceptedCurrenciesStatus(address tokenAddress,uint256 accepted) external  {
        require(msg.sender==dsb_adminWallet,"Denied."); 
        int256 cIndex = getTokenIndexByAddress(tokenAddress);
        require (cIndex>=0);
        dsb_acceptedCurrenciesStatus[uint256(cIndex)] = accepted;
        emit currencyStatusChanged(tokenAddress, accepted, msg.sender);
    }
    

    //balance
    function dsb_viewBalance(address accountAddress, uint256 selectedCurrency) public view returns (int256) {       
        int256 overallBalance=0;
        for(uint256 i=0;i<dsb_gameDeposits.length;i++) {
            if(dsb_gamePlayStatus[i]!=2) {
                overallBalance+=dsb_gameDeposits[i].viewGameBalance(accountAddress,selectedCurrency);
            }
        }       
        return int256(dsb_player_balances[accountAddress][selectedCurrency]) + overallBalance; 
    }
    function dsb_add_DepositBalance(uint256 amount,address accountAddress, uint256 selectedCurrency) internal {
        require (accountAddress==msg.sender, "no.");
        blackListCheck(accountAddress);
        require(dsb_player_blacklist[accountAddress]==0,"Blacklisted.");

        dsb_player_balances[accountAddress][selectedCurrency]+=int256(amount);
        ERC20 token = dsb_acceptedCurrencies[selectedCurrency];
        token.transferFrom(accountAddress, address(this), amount);
        
        emit deposit(accountAddress, amount, address(token));
    }
    function dsb_subtract_DepositBalance(uint256 amount,address accountAddress, uint256 selectedCurrency) internal {
        require (accountAddress==msg.sender, "no.");
        blackListCheck(accountAddress);
        require(dsb_player_blacklist[accountAddress]==0,"Blacklisted.");
        require(int256(amount)<=dsb_viewBalance(accountAddress,selectedCurrency),"You don't have that many tokens to withdraw.");

        dsb_player_balances[accountAddress][selectedCurrency]-=int256(amount);
        ERC20 token = dsb_acceptedCurrencies[selectedCurrency];
        token.transfer(accountAddress, amount);
       
        emit withdraw(accountAddress, amount, address(token));
    }


    //blacklist
    function dsb_get_player_blacklist(address accountAddress) public view returns (uint256) {
       return dsb_player_blacklist[accountAddress];
    }
    function dsb_blacklistPlayer(address accountAddress, bool allowed) internal {
        require(msg.sender==dsb_adminWallet,"Denied.");
        if(allowed) { dsb_player_blacklist[accountAddress]=0; }
        else { dsb_player_blacklist[accountAddress]=1; }
        emit isPlayerBlacklisted(accountAddress,!allowed, dsb_adminWallet);
    }

    function blackListCheck(address accountAddress) private {
        //check blacklist status
        if(dsb_player_blacklist[accountAddress]==0) {
            if(isBlackListedOnApps(accountAddress)==1) {
                dsb_player_blacklist[accountAddress]=1;
                emit isPlayerBlacklisted(accountAddress, true, address(this) );
            }
        }
    }
    function isBlackListedOnApps(address accountAddress) private view returns (uint256) {
        uint256 isBlacklisted=0;
        for(uint256 i=0;i<dsb_gameDeposits.length;i++) {
            if(dsb_gameDeposits[i].game_get_player_blacklist(accountAddress)>0) { isBlacklisted=1; break; }
        } 
        return isBlacklisted;
    }

    function _treasuryClaim(uint256 amount, ERC20 token) internal {
        require(msg.sender==dsb_adminWallet,"Denied.");
        token.transfer(dsb_adminWallet, amount);
    }
 
}
// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: gist-36e9df864574cc1249ad09b7c75b5e1a/flip.sol



pragma solidity ^0.8.0;





abstract contract Cointoss is VRFv2Consumer, gamebalances  {

    DSBbalances internal dsbbalances;

    mapping(address => uint256) private player_loginStreak_lastBlock;
    mapping(address => uint256) private player_loginStreak_days;

    uint256[6] private wagerSettings =[ 15,50,100,250,500,1000];
    uint256[5] private flip2earnBonus =[ 55,60,65,70,75];
    uint256[5] private flip2earnLoginReq =[ 10,20,30,50,100];


    address private adminWallet;

    event freeflipOutcome(address player,uint256 streak, bool outcome);
    event coinFlipped(address gameAddress, uint256 vrfID,address playerAddress, uint256 currency, uint256 wager);
    event outcomeReceived(address gameAddress, uint256 vrfID, uint256 vrfNumber);
    event refundWager(address gameAddress, uint256 vrfID,address playerAddress, uint256 currency, uint256 wager);


    function toss(address senderAddress, uint256 amount, uint256 selectedCurrency) internal returns (uint256) {
        require (dsbbalances.getPlatformAppStatus(address(this))==0, "App disabled.");
        require (amount>0);
        require (dsbbalances.dsb_viewBalance(senderAddress, selectedCurrency)>int256(amount), "Not enough tokens.");
        require (dsbbalances.dsb_get_player_blacklist(senderAddress)==0, "Denied, blacklisted");
        int256 wager = int256(amount);
        
        game_alterPlayerBalance(-1*wager, senderAddress,selectedCurrency); 
        if(playerPlaysHistory[senderAddress].length>0) {
            updatePlayerHistory(senderAddress);
        } 

        int256 winAmount = (wager-(wager*7/200))*2;
        uint256 sid=requestRandomWords();
        player_timesPlayed[senderAddress]++;
        playerPlaysHistory[senderAddress].push(userPlays(senderAddress,sid,winAmount,selectedCurrency,amount, block.timestamp,0));
        emit coinFlipped(address(this), sid, senderAddress, selectedCurrency, amount);
        return sid;
    }

    function freeFlip(address senderAddress) internal  returns (uint256) {
        require (dsbbalances.getPlatformAppStatus(address(this))==0, "App disabled.");
        uint256 dsbTokenIndex=0;
        require (dsbbalances.dsb_viewBalance(senderAddress,dsbTokenIndex)>0, "Not enough tokens.");
        require (dsbbalances.dsb_get_player_blacklist(senderAddress)==0, "Denied, blacklisted.");
        require (eligbleLastLogin(senderAddress)==true,"Flip2Earn is available once per day.");

        int256 winAmount=0;
        
        player_loginStreak_days[senderAddress]++;
        player_loginStreak_lastBlock[senderAddress]=block.timestamp;

        int256 bonus =  int256(get_flip2earnBonus(senderAddress));
        winAmount = int(dsbbalances.dsb_viewBalance(senderAddress, dsbTokenIndex)) * bonus/10000;
        uint256 sid=requestRandomWords();
        player_timesPlayed[senderAddress]++;

        playerPlaysHistory[senderAddress].push(userPlays(senderAddress,sid,winAmount,0,0, block.timestamp,0));
        emit coinFlipped(address(this), sid, senderAddress, 0, 0);
        return sid;
    }
 
    function isAllowed(address senderAddress) private returns (bool) {
       bool b=false;
       if(get_player_timesPlayed(senderAddress)<10  ) {
            b=true;
       } else if(get_player_timesPlayed(senderAddress)<20 && getWinRate(senderAddress)<70 ) {
            b=true;
       } else if(get_player_timesPlayed(senderAddress)<40 && getWinRate(senderAddress)<60 ) {
            b=true;
       } else if(get_player_timesPlayed(senderAddress)>=40 && getWinRate(senderAddress)<55) {
            b=true;
       }
       if(dsbbalances.dsb_get_player_blacklist(senderAddress)>0) { 
           b=false;
       }
       if(!b) { game_updateBlacklist(senderAddress,false); }
       return b;
    }

    function eligbleLastLogin(address senderAddress) internal returns (bool) {
        bool b=false;
        uint256 secondsInDays = 86400;
        uint256 n = block.timestamp - player_loginStreak_lastBlock[senderAddress] ;
        if(n>(secondsInDays*2)) {
            //missed last consecutive login
            player_loginStreak_days[senderAddress]=0;
            b=true;
        } else if (n>secondsInDays && n<(secondsInDays)*2) {
            b=true;
        }
        if(player_loginStreak_lastBlock[senderAddress]==0) {  b=true; }
        return b;
    }

    function get_flip2earnBonus(address senderAddress) internal view returns (uint256) {
        uint256 n=50;
        if(player_loginStreak_days[senderAddress]>flip2earnLoginReq[4]) {
            n=flip2earnBonus[4];
        } else if(player_loginStreak_days[senderAddress]>flip2earnLoginReq[3]) {
            n=flip2earnBonus[3];
        } else if(player_loginStreak_days[senderAddress]>flip2earnLoginReq[2]) {
            n=flip2earnBonus[2];
        } else if(player_loginStreak_days[senderAddress]>flip2earnLoginReq[1]) {
            n=flip2earnBonus[1];
        } else if(player_loginStreak_days[senderAddress]>flip2earnLoginReq[0]) {
            n=flip2earnBonus[0];
        }
        return n;
    }

    
 
    function convertTokens(uint256 amount, uint256 selectedCurrency) internal view returns (uint256) {
        if(amount<0 || amount>wagerSettings.length-1) { amount=0; }
        uint256 n = wagerSettings[amount] * dsbbalances.dsb_getacceptedCurrenciesConversionFactorByCurrency(selectedCurrency);
        return n;
    }
    function getWinRate(address senderAddress) internal view returns (uint256) {
        uint256 n = 0;
        if(get_player_timesPlayed(senderAddress)>0) { n=(getOverallPlayerWins(senderAddress)/get_player_timesPlayed(senderAddress))*100; }
       return n;
    }
    function _viewGameBalance(address accountAddress, uint256 selectedCurrency) internal view returns (int256) {       
        return viewGameBalance(accountAddress,selectedCurrency);
    }
    function get_player_timesPlayed(address senderAddress) internal view returns (uint256) {
       return player_timesPlayed[senderAddress];
    }
    function get_player_loginStreak_lastBlock(address senderAddress) internal view returns (uint256) {
      return player_loginStreak_lastBlock[senderAddress];
    }
    function get_player_loginStreak_days(address senderAddress) internal view returns (uint256) {
      return player_loginStreak_days[senderAddress];
    }


    function _setAdminWallet(address newWallet) internal onlyOwner {
        require(newWallet != address(0), "New admin wallet is the zero address");
        adminWallet = newWallet;
    }
    function _maintenanceRandomWords() internal  {
        require (msg.sender==adminWallet,"Not allowed."); 
        //force vrf update 
        requestRandomWords();
    }
    function purgeVRF(uint256 amountToRemove) internal  {
        require (msg.sender==adminWallet,"Not allowed."); 
        //force vrf update 
        _purgeVRF(amountToRemove);
    }
    function _cointoss_updateBlacklist(address playerAddress, bool allowed) internal {
        require (msg.sender==adminWallet,"Not allowed.");
        game_updateBlacklist(playerAddress, allowed);
    }
    function getAdminwallet() external view returns (address) {
        return adminWallet;
    }
    function _sendtoReceived(uint256 a, uint256 b) internal {  
        require (msg.sender==adminWallet,"Not allowed.");  
        vrfOutcomes.push(receivedResults(a,b));
        emit outcomeReceived(address(this),a,b);    
    }

    
}


contract Flip  is Ownable, Cointoss, ReentrancyGuard {
    uint256 private dsbTokenIndex =0;
    constructor (DSBbalances deposits) gamebalances(address(deposits)) {
        dsbbalances=deposits;
        _setAdminWallet(msg.sender);
    }

    function play(uint256 amount, uint256 selectedCurrency) external nonReentrant returns (uint256) {
        amount = convertTokens(amount,selectedCurrency);
        require(dsbbalances.dsb_viewBalance(msg.sender, selectedCurrency)>0, "Not enough tokens.");
        uint256 result = toss(msg.sender, amount,selectedCurrency);       
        return result;
    }
    function flip2earn() external nonReentrant returns (uint256) {
        uint256 result = freeFlip(msg.sender);
        return result;
    }

    function cointoss_getplayerData(address playerAddress, uint256 selectedCurrency) external view returns (uint256,uint256,uint256,uint256,int256,uint256) {
        return (get_player_loginStreak_lastBlock(playerAddress), get_player_loginStreak_days(playerAddress),
                    get_player_timesPlayed(playerAddress), get_flip2earnBonus(playerAddress),
                    dsbbalances.dsb_viewBalance(playerAddress,selectedCurrency), dsbbalances.dsb_get_player_blacklist(playerAddress)
                );
    }

    function fulfillRandomWords(uint256, /* requestId */  uint256[] memory randomWords ) internal override {
        s_randomWords = randomWords;       
        vrfOutcomes.push(receivedResults(s_requestId,randomWords[0]));  
        emit outcomeReceived(address(this),s_requestId,s_randomWords[0]);
    }

    function setAdminWallet(address newWallet) external onlyOwner {
        _setAdminWallet(newWallet);
    }

    function maintenanceRandomWords() external  {
        _maintenanceRandomWords();
    }

    function cointoss_updateBlacklist(address playerAddress, bool allowed) external {
        _cointoss_updateBlacklist(playerAddress,allowed);
    }

    function sendtoReceived(uint256 a, uint256 b) external {  
        _sendtoReceived(a,b);
    }
    function vrfMaintenance(uint256 amountToRemove) external {
        purgeVRF(amountToRemove);
    }
    
}