//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Cloneable.sol";
import "./IERC20.sol";
import "./Ownable.sol";
import "./IVRF.sol";

interface ILotteryClone {
    function setWinner(address winner_) external;
    function __init__() external;
}

interface IRoyaltyDatabase {
    function getRoyaltyRecipient() external view returns (address);
    function getPlatformRecipient() external view returns (address);
}

contract LotteryManager is Cloneable, Ownable, VRFConsumerBaseV2 {

    // Funding Receivers
    IRoyaltyDatabase public constant royaltyDatabase = IRoyaltyDatabase(0x12EF041Ef3a504463AE25ACAFC0C1288aCb1Cf4b);

    // current lottery clone implementation
    address public implementation;

    // current lotto contract
    address public currentLotto;

    // Lotto History
    struct History {
        address winner;
        address lottoClone;
    }

    // Lotto ID => Lotto History
    mapping ( uint256 => History ) public lottoHistory;

    // Current Lotto ID
    uint256 public currentLottoID;

    // Lotto Details
    uint256 public startingCostPerTicket     = 2 * 10**16;
    uint256 public costIncreasePerTimePeriod = 1 * 10**16;
    uint256 public timePeriodForCostIncrease = 1 days;
    uint256 public lottoDuration             = 7 days;

    // When Last Lotto Began
    uint256 public lastLottoStartTime;

    // current ticket ID
    uint256 public currentTicketID;
    mapping ( uint256 => address ) public ticketToUser;

    // House Wallet
    address public houseWallet;

    // House Edge
    uint256 public houseEdge      = 10;
    uint256 public nobodyWinsEdge = 10;

    // VRF Coordinator
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 private s_subscriptionId;

    // testnet BNB coordinator
    address private immutable vrfCoordinator;// = 0x2eD832Ba664535e5886b75D64C46EB9a228C2610;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    bytes32 private immutable keyHash;// = 0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61;

    // chainlink request IDs
    uint256 private newLottoRequestID;

    // gas limit to call function
    uint32 public gasToCallRandom = 1_000_000;

    // Events
    event WinnerChosen(address winner, address lotto);
    event HouseWins(address lotto);
    event LotteryRolledOver();

    constructor(
        uint64 subscriptionId,   // 1815 testnet
        address vrfCoordinator_, // 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f testnet
        bytes32 keyHash_,        // 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314 testnet
        address house_,
        address implementation_
    ) VRFConsumerBaseV2(vrfCoordinator_) {
        // setup chainlink
        keyHash = keyHash_;
        vrfCoordinator = vrfCoordinator_;
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator_);
        s_subscriptionId = subscriptionId;
        houseWallet = house_;
        implementation = implementation_;
    }

    /**
        Sets Gas Limits for VRF Callback
     */
    function setGasLimits(uint32 gasToCallRandom_) external onlyOwner {
        gasToCallRandom = gasToCallRandom_;
    }

    /**
        Sets Subscription ID for VRF Callback
     */
    function setSubscriptionId(uint64 subscriptionId_) external onlyOwner {
       s_subscriptionId = subscriptionId_;
    }

    function setImplementation(address newImplementation) external onlyOwner {
        implementation = newImplementation;
    }

    function init() external onlyOwner {
        require(
            currentLotto == address(0) && lastLottoStartTime == 0,
            'Lotto Already Set'
        );

        // generate new lotto clone
        currentLotto = Cloneable(implementation).clone();
        ILotteryClone(currentLotto).__init__();
        lastLottoStartTime = block.timestamp;
    }

    function setStartingTicketCost(uint256 newCost) external onlyOwner {
        startingCostPerTicket = newCost;
    }

    function setLottoDuration(uint256 newDuration) external onlyOwner {
        lottoDuration = newDuration;
    }

    function setCostIncreasePerTimePeriod(uint256 increasePerPeriod) external onlyOwner {
        costIncreasePerTimePeriod = increasePerPeriod;
    }

    function setTimePeriodForCostIncrease(uint256 newTimePeriod) external onlyOwner {
        timePeriodForCostIncrease = newTimePeriod;
    }

    function setHouseWallet(address newWallet) external onlyOwner {
        houseWallet = newWallet;
    }

    function setHouseEdge(uint256 newEdge) external onlyOwner {
        require(
            newEdge <= 10,
            'House Edge Too Large'
        );
        houseEdge = newEdge;
    }

    function setNobodyWinsEdge(uint256 nobodyWinsEdge_) external onlyOwner {
        require(
            nobodyWinsEdge_ <= 10,
            'House Edge Too Large'
        );
        nobodyWinsEdge = nobodyWinsEdge_;
    }

    function buyTickets(uint256 numTickets) external payable {
        require(
            numTickets * currentTicketCost() <= msg.value,
            'Incorrect Value Sent'
        );
        address user = msg.sender;

        for (uint i = 0; i < numTickets;) {

            ticketToUser[currentTicketID] = user;
            currentTicketID++;

            unchecked {
                ++i;
            }
        }

        // platform fees
        _send(royaltyDatabase.getRoyaltyRecipient(), ( address(this).balance * 4 ) / 10);
        _send(royaltyDatabase.getPlatformRecipient(), address(this).balance);
    }

    function newLotto() external {
        require(
            lastLottoStartTime > 0,
            'Lotto Has Not Been Initialized'
        );
        require(
            timeUntilNewLotto() == 0,
            'Not Time For New Lotto'
        );

        _newLotto();        
    }


    /**
        Registers A New Lotto
        Changes The Day Timer
        Distributes Winnings
     */
    function _newLotto() internal {

        // reset day timer
        lastLottoStartTime = block.timestamp;

        // get random number and send rewards when callback is executed
        // the callback is called "fulfillRandomWords"
        // this will revert if VRF subscription is not set and funded.
        newLottoRequestID = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            3, // number of block confirmations before returning random value
            gasToCallRandom, // callback gas limit is dependent num of random values & gas used in callback
            2 // the number of random results to return
        );
    }

    /**
        Chainlink's callback to provide us with randomness
     */
    function fulfillRandomWords(
        uint256 requestId, /* requestId */
        uint256[] memory randomWords
    ) internal override {

        if (requestId == newLottoRequestID) {

            // determine if house wins or no one wins
            uint winIndex = randomWords[1] % 100;
            bool houseWins = winIndex < houseEdge;
            bool noOneWins = winIndex >= houseEdge && winIndex < (houseEdge + nobodyWinsEdge);

            // select the winner based on edge, or the random number generated
            address winner;
            if (houseWins) {
                winner = houseWallet;
            } else if (noOneWins) {
                winner = address(0);
            } else {
                winner = currentTicketID > 0 ? ticketToUser[randomWords[0] % currentTicketID] : address(0);
            }
            
            // set winner
            if (winner != address(0)) {

                // Emit Winning Event
                if (winner == houseWallet) {
                    emit HouseWins(currentLotto);
                } else {
                    emit WinnerChosen(winner, currentLotto);
                }

                // save history
                lottoHistory[currentLottoID].winner = winner;
                lottoHistory[currentLottoID].lottoClone = currentLotto;

                // set lotto winner
                ILotteryClone(currentLotto).setWinner(winner);

                // generate new lotto clone
                currentLotto = Cloneable(implementation).clone();
                ILotteryClone(currentLotto).__init__();

                // reset lotto time again
                lastLottoStartTime = block.timestamp;
                
                // increment the current lotto ID
                currentLottoID++;           
            } else {
                emit LotteryRolledOver();
            }
            
            // reset ticket IDs back to 0
            delete currentTicketID;

        }
    }


    function currentTicketCost() public view returns (uint256) {
        uint256 epochsSinceLastLotto = block.timestamp > lastLottoStartTime ? ( block.timestamp - lastLottoStartTime ) / timePeriodForCostIncrease : 0;
        return startingCostPerTicket + ( epochsSinceLastLotto * costIncreasePerTimePeriod );
    }

    function timeUntilNewLotto() public view returns (uint256) {
        uint endTime = lastLottoStartTime + lottoDuration;
        return block.timestamp >= endTime ? 0 : endTime - block.timestamp;
    }

    function getOdds(address user) public view returns (uint256, uint256, uint256, uint256) {

        uint nTickets;
        for (uint i = 0; i < currentTicketID;) {

            if (ticketToUser[i] == user) {
                nTickets++;
            }

            unchecked {
                ++i;
            }
        }
        return (nTickets, currentTicketID, houseEdge, nobodyWinsEdge);
    }

    function getPastWinners(uint256 numWinners) external view returns (address[] memory) {
        address[] memory winners = new address[](numWinners);
        if (currentLottoID < numWinners || numWinners == 0) {
            return winners;
        }
        for (uint i = currentLottoID - 1; i > currentLottoID - ( 1 + numWinners);) {
            winners[i] = lottoHistory[i].winner;
            unchecked { --i; }
        }
        return winners;
    }

    receive() external payable{
        (bool s,) = payable(currentLotto).call{value: address(this).balance}("");
        require(s);
    }

    function sendToLotto(address token, uint256 amount) external {
        IERC20(token).transferFrom(
            msg.sender,
            currentLotto,
            amount
        );
    }

    function _send(address to, uint256 amount) internal {
        if (to == address(this) || to == address(0)) {
            return;
        }
        (bool s,) = payable(to).call{value: amount}("");
        require(s, 'ETH Transfer Failure');
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 */
contract Cloneable {

    /**
        @dev Deploys and returns the address of a clone of address(this
        Created by DeFi Mark To Allow Clone Contract To Easily Create Clones Of Itself
        Without redundancy
     */
    function clone() external returns(address) {
        return _clone(address(this));
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function _clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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