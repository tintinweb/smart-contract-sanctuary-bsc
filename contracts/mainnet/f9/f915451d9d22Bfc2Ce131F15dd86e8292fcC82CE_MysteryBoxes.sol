/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is OwnableInterface {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() public view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}


/**
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}



interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface ITicket {
    function mintTicketByPermission(address _owner, uint8 _ticketType, uint8 _parity, uint8 _zone, uint256 _startRange, uint256 _endRange) external;
    function burnTicketByPermission(address _owner,uint256 _tokenId) external;
    function getTicket(uint256 _tokenId) external view returns (uint8 ticketType, uint8 parity, uint8 _zone, uint256 startRange, uint256 endRange);
}

interface IMysteryBoxes {
    function getAllBoxPrize() external view returns (uint256 allBoxPrize);
    function getJackpotBox() external view returns(uint256 jackpotBox);
}

contract MysteryBoxes is VRFConsumerBaseV2, ConfirmedOwner, IMysteryBoxes {
    using EnumerableSet for EnumerableSet.UintSet;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }


    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    bytes32 immutable keyHash;
    address public immutable linkToken;

    uint32 callbackGasLimit = 150000;

    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint public randomWordsNum;

    uint256 private nonce = 0;
    uint256 public jackpotBox = 5550;
    uint256 public allBoxPrize = 17531000000000000000000;
    address public busdAddress = 0x55d398326f99059fF775485246999027B3197955;
    address public ticketAddress = 0xb6B65255b938095539C3c594E6aAB92b2850De4f;
    uint256 public numberBoxChain = 1;
    uint256 initPrize = 330000000000000000;

    mapping(uint256 => uint256) public boxPrize;
    mapping(uint256 => uint256) public zonePrize;
    mapping(uint256 => uint256) public amountWithdrawedFromZone;
    mapping(uint256 => uint256) public chainForBox;
    mapping(uint256 => bool) public isInitPrize;
    mapping(uint256 => EnumerableSet.UintSet) boxChains;
    mapping(address => bool) private permission;


    event DonateBox(address addr, uint256 boxIndex, uint256 amount);
    event OpenBox(address indexed sender, uint256 prize, uint256[] boxIndex);
    event ChainReaction(uint256 chain, uint256 boxIndex);
    event RandomChainReaction(uint256 newChain, uint256[] boxIndex, uint256[] burnChain);
    event OpenJackpotBox(uint256 newJackpotBox, uint256 oldJackpotBox);
    event DistributePrizeToBox(uint256 indexed zoneIndex, uint256 amount);

    constructor(
    uint64 subscriptionId,
    address _linkToken
    )
        VRFConsumerBaseV2(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE)
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0xc587d9053cd1118f25F645F9E08BB98c9712A4EE
        );
        s_subscriptionId = subscriptionId;

        keyHash = 0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7; // we alread set this
        linkToken = _linkToken;
    }


    modifier onlyPermission() {
        require(permission[msg.sender], "NOT_THE_PERMISSION");
        _;
    }

    function openBox(uint256[] memory _ticketID) public {
        require(_ticketID.length <= 10, "over max");

        uint256 prize;
        uint256[] memory listWinBox = new uint256[](_ticketID.length);

        for(uint256 i=0; i< _ticketID.length; i++){
            (uint8 ticketType, uint8 parity, uint8 zone, uint256 startRange, uint256 endRange) = ITicket(ticketAddress).getTicket(_ticketID[i]);
            ITicket(ticketAddress).burnTicketByPermission(msg.sender , _ticketID[i]);

            uint256 boxIndex = _getRandomBox(ticketType, parity, zone, startRange, endRange);
            listWinBox[i] = boxIndex;
            prize += _getPrizeFromZone(boxIndex);

            if(isInitPrize[boxIndex] == false){
                prize += initPrize;
                isInitPrize[boxIndex] = true;
            }

            if (boxIndex == jackpotBox){
                uint256 newJackpotBox = _randomBox();
                prize += (boxPrize[boxIndex] * 70) / 100;
                boxPrize[newJackpotBox] = (boxPrize[boxIndex] * 30) / 100;
                boxPrize[boxIndex] = 0; // reset
                jackpotBox = newJackpotBox;

                emit OpenJackpotBox(newJackpotBox, boxIndex);
            } else {
                prize += boxPrize[boxIndex]; 
                boxPrize[boxIndex] = 0;
            }
            
            if (chainForBox[boxIndex] > 0){
                uint256 chain = chainForBox[boxIndex];
                for(uint256 j=0; j<boxChains[chain].length(); j++){
                    prize += boxPrize[boxChains[chain].at(j)];
                    // reset
                    boxPrize[boxChains[chain].at(j)] = 0;
                    chainForBox[boxChains[chain].at(j)] = 0;
                }

                delete boxChains[chain];
                emit ChainReaction(chain, boxIndex);
            }

        }

        allBoxPrize = allBoxPrize - prize;

        emit OpenBox(msg.sender, prize, listWinBox);

        IERC20(busdAddress).transfer(msg.sender, prize);
    }


    function donateBox(uint256 _boxIndex, uint256 _amount) external {
        require(_amount > 0, "INVALID AMOUNT");
        require(IERC20(busdAddress).transferFrom(msg.sender, address(this), _amount), "TransferFrom fail");

        boxPrize[_boxIndex] += _amount;

        emit DonateBox(msg.sender, _boxIndex, _amount);
    }

    function distributePrizeToBox(uint256 _amount) external onlyPermission {
        allBoxPrize += _amount;
        uint256 zoneIndex = _randomZone();
        uint256 jackpotPrize  = (30 * _amount) / 100;
        boxPrize[jackpotBox] +=  jackpotPrize;
        zonePrize[zoneIndex] += _amount - jackpotPrize;

        emit DistributePrizeToBox(zoneIndex,  zonePrize[zoneIndex]);
    }

    function _getRandomBox(uint8 _ticketType, uint8 _parity, uint8 _zone, uint256 _startRange, uint256 _endRange) private returns (uint256) {
        if (_ticketType == 1){
            requestRandomWords();
            uint256 boxIndex = randomWordsNum % 10000 + 1;

            return boxIndex;
        } else if (_ticketType == 2){
            uint256 boxIndex;
            if (_parity == 1){ // odd
                requestRandomWords();
                boxIndex = (randomWordsNum % 5000) * 2 + 1;
            } else if (_parity == 2){ // even
                requestRandomWords();
                boxIndex = (randomWordsNum % 5000) * 2;
            }

            return boxIndex;
        } else if (_ticketType == 3){
            requestRandomWords();
            uint256 boxIndex = randomWordsNum % 1000 + (_zone - 1) * 1000 + 1;

            return boxIndex;
        } else if (_ticketType == 4){
            requestRandomWords();
            uint256 boxIndex = randomWordsNum % (_endRange - _startRange) + _startRange;

            return boxIndex;
        }

        return 0;
    }

    function _getPrizeFromZone(uint256 _boxIndex) private returns(uint256){
        uint256 prize;
        uint256 amountWithdraw;
        if(_boxIndex <= 1000){
            prize = zonePrize[1] / 1000;
            amountWithdraw = prize - amountWithdrawedFromZone[_boxIndex];
            amountWithdrawedFromZone[_boxIndex] += amountWithdraw;
            return amountWithdraw; 
        } else if(_boxIndex > 1000 && _boxIndex <= 2000){
            prize = zonePrize[2] / 1000;
            amountWithdraw = prize - amountWithdrawedFromZone[_boxIndex];
            amountWithdrawedFromZone[_boxIndex] += amountWithdraw;
            return amountWithdraw;  
        } else if(_boxIndex > 2000 && _boxIndex <= 3000){
            prize = zonePrize[3] / 1000;
            amountWithdraw = prize - amountWithdrawedFromZone[_boxIndex];
            amountWithdrawedFromZone[_boxIndex] += amountWithdraw;
            return amountWithdraw; 
        } else if (_boxIndex > 3000 && _boxIndex <= 4000){
            prize = zonePrize[4] / 1000;
            amountWithdraw = prize - amountWithdrawedFromZone[_boxIndex];
            amountWithdrawedFromZone[_boxIndex] += amountWithdraw;
            return amountWithdraw; 
        } else if (_boxIndex > 4000 && _boxIndex <= 5000){
            prize = zonePrize[5] / 1000;
            amountWithdraw = prize - amountWithdrawedFromZone[_boxIndex];
            amountWithdrawedFromZone[_boxIndex] += amountWithdraw;
            return amountWithdraw; 
        } else if (_boxIndex > 5000 && _boxIndex <= 6000){
            prize = zonePrize[6] / 1000;
            amountWithdraw = prize - amountWithdrawedFromZone[_boxIndex];
            amountWithdrawedFromZone[_boxIndex] += amountWithdraw;
            return amountWithdraw; 
        } else if (_boxIndex > 6000 && _boxIndex <= 7000){
            prize = zonePrize[7] / 1000;
            amountWithdraw = prize - amountWithdrawedFromZone[_boxIndex];
            amountWithdrawedFromZone[_boxIndex] += amountWithdraw;
            return amountWithdraw; 
        } else if (_boxIndex > 7000 && _boxIndex <= 8000){
            prize = zonePrize[8] / 1000;
            amountWithdraw = prize - amountWithdrawedFromZone[_boxIndex];
            amountWithdrawedFromZone[_boxIndex] += amountWithdraw;
            return amountWithdraw; 
        } else if (_boxIndex > 8000 && _boxIndex <= 9000){
            prize = zonePrize[9] / 1000;
            amountWithdraw = prize - amountWithdrawedFromZone[_boxIndex];
            amountWithdrawedFromZone[_boxIndex] += amountWithdraw;
            return amountWithdraw; 
        } else if (_boxIndex > 9000 && _boxIndex <= 10000){
            prize = zonePrize[10] / 1000;
            amountWithdraw = prize - amountWithdrawedFromZone[_boxIndex];
            amountWithdrawedFromZone[_boxIndex] += amountWithdraw;
            return amountWithdraw; 
        }
        return 0;
    }


    function randomChainReaction() external onlyOwner {
        uint256 box1 = _randomBox();
        uint256 box2 = _randomBox();
        uint256[] memory burnChains = new uint256[](2);

        if (chainForBox[box1] == 0 && chainForBox[box2] == 0){
            uint256[] memory boxs = new uint256[](2);
            chainForBox[box1] = numberBoxChain;
            chainForBox[box2] = numberBoxChain;
            boxChains[numberBoxChain].add(box1);
            boxChains[numberBoxChain].add(box2);
            boxs[0] = box1;
            boxs[1] = box2;

            emit RandomChainReaction(numberBoxChain, boxs, burnChains);
            numberBoxChain += 1;
        } 
        else if (chainForBox[box1] > 0 && chainForBox[box2] == 0){
            uint256[] memory boxs = new uint256[](1);

            boxChains[chainForBox[box1]].add(box2);
            chainForBox[box2] = chainForBox[box1];
            boxs[0] = box2;
            emit RandomChainReaction(chainForBox[box1], boxs, burnChains);
        } 
        
        else if (chainForBox[box1] == 0 && chainForBox[box2] > 0){
            uint256[] memory boxs = new uint256[](1);

            boxChains[chainForBox[box2]].add(box1);
            chainForBox[box1] = chainForBox[box2];
            boxs[0] = box1;
            emit RandomChainReaction(chainForBox[box2], boxs, burnChains);
        } 
        else if (chainForBox[box1] > 0 && chainForBox[box2] > 0 && chainForBox[box1] != chainForBox[box2]){
            uint256 boxChain1 = chainForBox[box1];
            uint256 boxChain2 = chainForBox[box2];
            uint256[] memory boxs = new uint256[](boxChains[boxChain1].length() + boxChains[boxChain2].length());
            uint256 j = 0;


            for(uint256 i=0; i<boxChains[boxChain1].length(); i++){
                chainForBox[boxChains[boxChain1].at(i)] = numberBoxChain;
                boxChains[numberBoxChain].add(boxChains[boxChain1].at(i));
                boxs[j] = boxChains[boxChain1].at(i);
                j+=1;
            }

            for(uint256 i=0; i<boxChains[boxChain2].length(); i++){
                chainForBox[boxChains[boxChain2].at(i)] = numberBoxChain;
                boxChains[numberBoxChain].add(boxChains[boxChain2].at(i));
                boxs[j] = boxChains[boxChain2].at(i);
                j+=1;
            }
            burnChains[0] = boxChain1;
            burnChains[1] = boxChain2;

            emit RandomChainReaction(numberBoxChain, boxs, burnChains);

            delete boxChains[boxChain1];
            delete boxChains[boxChain2];
            numberBoxChain += 1;
        }
    }

    function requestRandomWords() private returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId; // requestID is a uint.
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
        ) internal override {
            require(s_requests[_requestId].exists, "request not found");
            s_requests[_requestId].fulfilled = true;
            s_requests[_requestId].randomWords = _randomWords;
            randomWordsNum = _randomWords[0]; // Set array-index to variable, easier to play with
            emit RequestFulfilled(_requestId, _randomWords);
    }

    // to check the request status of random number call.
    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    function getBoxChains(uint256 _numberBoxchain) public view returns(uint256[] memory, uint256[] memory){
        uint256 totalBox = boxChains[_numberBoxchain].length();
        uint256[] memory boxs = new uint256[](totalBox);
        uint256[] memory prize = new uint256[](totalBox);

        for(uint256 i=0; i<totalBox; i++){
            boxs[i] = boxChains[_numberBoxchain].at(i);
            prize[i] = boxPrize[boxChains[_numberBoxchain].at(i)];
        }

        return(boxs, prize);
    }

    function getAllBoxPrize() public view returns(uint256){
        return allBoxPrize;
    }

    function getJackpotBox() public view returns(uint256){
        return jackpotBox;
    }

    function _randomBox() private returns (uint256) {
        uint256 randomN = uint256(blockhash(block.number));
        uint256 index = uint256(keccak256(abi.encodePacked(randomN, block.timestamp, nonce))) % 10000 + 1;
        nonce++;

        return index;
    }

    function _randomZone() private returns (uint256) {
        uint256 randomN = uint256(blockhash(block.number));
        uint256 index = uint256(keccak256(abi.encodePacked(randomN, block.timestamp, nonce))) % 10 + 1;
        nonce++;

        return index;
    }
    
    function initPrizeToBox(uint256[] memory _box, uint256[] memory _prize) external onlyOwner {
        for(uint256 i=0; i<_box.length; i++){
            boxPrize[_box[i]] = _prize[i];
            isInitPrize[_box[i]] = true;
        }
        jackpotBox = _box[0];
    }

    function setPermission(address _permission, bool _enabled) external onlyOwner {
        permission[_permission] = _enabled;
    }

    function isPermission(address _permission) public view returns (bool) {
        return permission[_permission];
    }

    function setTicketAddress(address _addr) external onlyOwner {
        ticketAddress = _addr;
    }

    function setBusdAddress(address _addr) external onlyOwner {
        busdAddress = _addr;
    }


}