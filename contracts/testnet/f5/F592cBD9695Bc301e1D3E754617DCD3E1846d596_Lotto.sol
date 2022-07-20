/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

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

interface ILotto {
    function deposit(address token, uint256 amount) external;
    function register(address user, uint256 amount) external;
}

interface IOwnable {
    function getOwner() external view returns (address);
}

contract Lotto is ILotto, VRFConsumerBaseV2 {

    // Lotto Constants
    uint256 public constant day   = 28800;
    uint256 public constant month = day * 30;
    uint32 public constant MONTHLY_WINNERS = 2;
    uint32 public constant DAILY_WINNERS   = 3;

    // Miner Contract
    address public immutable Miner;

    // Treasury Address
    address public treasury;

    // Burn GameFi Constants
    address public immutable AMES; // = 0xb9E05B4C168B56F73940980aE6EF366354357009;
    address public immutable ASHARE; // = 0xFa4b16b0f63F5A6D0651592620D585D308F749A4;

    // Burn GameFi Amounts
    uint256 public AMES_BURNED_PER_TEN_TICKETS = 50 * 10**18;
    uint256 public ASHARE_BURNED_PER_TEN_TICKETS = 1 * 10**18;

    // Largest Daily Depositor Structure
    struct DailyDeposit {
        address depositor;
        uint256 amount;
    }

    // minimum LP register to get one ticket
    uint256 public LP_Per_Ticket = 5 * 10**18;

    // Ticket Ranges
    struct TicketRange {
        uint lower;
        uint upper;
        address user;
    }
    // Ticket Range ID => TicketRange
    mapping ( uint => TicketRange ) public ticketRanges;
    uint256 public currentTicketRangeID;

    // number of tickets currently issued
    uint256 public currentTicketID;

    // User -> Tokens Won In Lotto
    mapping ( address => uint256 ) public userWinnings;
    
    // Lotto User Data
    address[] public monthlyWinners;   // 2 random winners per month - only winners of daily deposits
    DailyDeposit public largestDaily;  // largest depositor per day

    // Data Tracking
    address public lastLargestDailyWinner;
    address[] public lastMonthlyWinners;
    
    // Block Times
    uint256 public lastDay;    // time block of the last recorded day
    uint256 public lastMonth;  // time block of the last recorded month

    // percent of balance that rolls over to next lotto cycle
    uint256 public rollOverPercentage = 10;

    // token reward allocations
    uint256 public largestDailyPercent   = 55;
    uint256 public dailyDepositPercent   = 40;
    uint256 public monthlyWinnersPercent = 5;
    uint256 public percentDenominator    = 100;

    // Gas For Lottery Trigger
    uint32 public dailyGas   = 1_000_000;
    uint32 public monthlyGas = 1_000_000;

    // lotto reward token
    address public rewardToken;
    uint256 public largestDailyPot;
    uint256 public dailyDepositPot;
    uint256 public monthlyWinnersPot;

    // Governance
    modifier onlyOwner(){
        require(
            msg.sender == IOwnable(Miner).getOwner(),
            'Only Miner Owner Can Call'
        );
        _;
    }

    ////////////////////////////////////////////////
    ///////////   CHAINLINK VARIABLES    ///////////
    ////////////////////////////////////////////////

    // VRF Coordinator
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // testnet BNB coordinator
    address private immutable vrfCoordinator;// = 0x2eD832Ba664535e5886b75D64C46EB9a228C2610;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    bytes32 private immutable keyHash;// = 0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61;

    // chainlink request IDs
    uint256 private newDayRequestId;
    uint256 private newMonthRequestId;

    constructor(
        address Miner_, 
        address treasury_, 
        address rewardToken_,
        address AMES_,
        address ASHARE_,
        uint64 subscriptionId, 
        address vrfCoordinator_,
        bytes32 keyHash_
    ) VRFConsumerBaseV2(vrfCoordinator_) {

        // setup chainlink
        keyHash = keyHash_;
        vrfCoordinator = vrfCoordinator_;
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator_);
        s_subscriptionId = subscriptionId;

        // set state
        Miner = Miner_;
        treasury = treasury_;
        rewardToken = rewardToken_;
        AMES = AMES_;
        ASHARE = ASHARE_;
    }

    ////////////////////////////////////////////////
    ///////////   RESTRICTED FUNCTIONS   ///////////
    ////////////////////////////////////////////////

    /**
        Checks eligibility for `user` to be largest daily depositor
        And gifts tickets to `user` based on the amount specified
     */
    function register(address user, uint256 amount) external override {
        require(
            msg.sender == Miner,
            'Only Miner Can Register Users'
        );

        // register largest depositor
        if (amount > largestDaily.amount) {
            largestDaily.amount = amount;
            largestDaily.depositor = user;
        }

        // if deposited enough to get tickets
        if (amount >= LP_Per_Ticket) {
            // number of tickets
            uint nTickets = amount / LP_Per_Ticket;

            if (nTickets > 0) {
                _addTickets(user, nTickets);
            }
        }
    }

    /**
        Sets Gas Limits for VRF Callback
     */
    function setGasLimits(uint32 dailyGas_, uint32 monthlyGas_) external onlyOwner {
        dailyGas = dailyGas_;
        monthlyGas = monthlyGas_;
    }

    /**
        Sets Subscription ID for VRF Callback
     */
    function setSubscriptionId(uint64 subscriptionId_) external onlyOwner {
       s_subscriptionId = subscriptionId_;
    }

    /**
        Starts The Timer For Days And Months For Lotto Enrollment
     */
    function startTime() external onlyOwner {
        require(
            lastDay == 0 && lastMonth == 0,
            'Already Started'
        );

        lastDay = block.number;
        lastMonth = block.number;
    }

    /**
        Resets The Day And Month For Lotto Winners To The Current Block Number
     */
    function hardResetLottoTimers() external onlyOwner {
        require(
            lastDay > 0 && lastMonth > 0,
            'Call startTime()'
        );

        lastDay = block.number;
        lastMonth = block.number;
    }

    /**
        Forcefully Registers The Current Block Number As A New Day
        Runs The Lotto, Delivering Rewards To Daily Winners As Intended
        Should Be Used VERY Carefully
        This is a dangerous function, as it changes the timing and frequency of lotto rewards
     */
    function forceNewDay() external onlyOwner {
        _newDay();
    }

    /**
        Forcefully Registers The Current Block Number As A New Month
        Runs The Lotto, Delivering Rewards To Monthly Winners As Intended
        Should Be Used VERY Carefully
        This is a dangerous function, as it changes the timing and frequency of lotto rewards
     */
    function forceNewMonth() external onlyOwner {
        _newMonth();
    }

    /**
        Forcefully Registers The Current Block Number As A New Day And Month
        Runs The Lotto, Delivering Rewards To Daily And Monthly Winners As Intended
        Should Be Used VERY Carefully
        This is a dangerous function, as it changes the timing and frequency of lotto rewards
     */
    function forceNewDayAndMonth() external onlyOwner {
        _newDay();
        _newMonth();
    }

    /**
        Gifts Tickets For External User
        Should be called carefully and with open transparency to community
        Allows team to host special events and do games to win tickets
        @param user - user to receive the tickets
        @param nTickets - number of tickets to gift to `user`
     */
    function giftTickets(address user, uint nTickets) external onlyOwner {
        _addTickets(user, nTickets);
    }

    /**
        Resets The Token Pot Percentages Based On Current Balance Within Contract
        Useful For When Tokens Are Withdrawn Or Sent In Without Calling `deposit()`
     */
    function hardResetRewardTokenPot() external onlyOwner {
        // fetch token balance
        uint bal = IERC20(rewardToken).balanceOf(address(this));

        // divvy up balance
        uint ldp = bal * largestDailyPercent / percentDenominator;
        uint ddp = bal * dailyDepositPercent / percentDenominator;
        uint mwp = bal - (ldp + ddp);

        // set pot size to be reset balances
        largestDailyPot = ldp;
        dailyDepositPot = ddp;
        monthlyWinnersPot = mwp;
    }

    /**
        Sets The Percentages For Reward Token Pool Distributions
     */
    function setRewardPotPercentages(
        uint largestDaily_,
        uint daily_,
        uint monthly_
    ) external onlyOwner {
        largestDailyPercent   = largestDaily_;
        dailyDepositPercent   = daily_;
        monthlyWinnersPercent = monthly_;
        percentDenominator = largestDaily_ + daily_ + monthly_;
    }

    /**
        Withdraws BNB That Is Stuck In This Contract
        Contract does not have receive function, so bnb can only enter
        via an external selfdestruct() function call
     */
    function withdrawBNB() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }
    
    /**
        Withdraws Tokens Held Within Contract
            Dangerous If Withdrawing RewardToken
            If A Reward Token Is Withdrawn, Immediately Call `hardResetRewardTokenPot()`
     */
    function withdrawTokens(IERC20 token_) external onlyOwner {
        token_.transfer(msg.sender, token_.balanceOf(address(this)));
    }

    /**
        Sets The Roll Over Percentage For Lotto Games
        A `newPercent` value of 10 will roll over 10% of all remaining funds to the next lotto
        @param newPercent - new percentage of winnings to roll over to next lotto
     */
    function setRollOverPercentage(uint newPercent) external onlyOwner {
        require(
            newPercent >= 0 && newPercent < 100,
            'Percent Out Of Bounds'
        );
        rollOverPercentage = newPercent;
    }

    /**
        Sets Rate For How Many LPs Should Be Deposited To Register 1 Ticket
        @param newLPPerTicketValue - number of LPs per ticket registered, cannot be zero
     */
    function setLPPerTicket(uint newLPPerTicketValue) external onlyOwner {
        require(
            newLPPerTicketValue > 0,
            'Cannot Be Zero'
        );

        LP_Per_Ticket = newLPPerTicketValue;
    }

    /**
        Sets The Number Of Ames To Burn To Create Ten Tickets For The User
        @param burnedPerTen number of AMES, cannot be zero
     */
    function setAMESBurnedPerTenTickets(uint burnedPerTen) external onlyOwner {
        require(
            burnedPerTen > 0,
            'Cannot Be Zero'
        );

        AMES_BURNED_PER_TEN_TICKETS = burnedPerTen;
    }

    /**
        Sets The Number Of ASHARE To Burn To Create Ten Tickets For The User
        @param burnedPerTen number of ASHARE, cannot be zero
     */
    function setASHAREBurnedPerTenTickets(uint burnedPerTen) external onlyOwner {
        require(
            burnedPerTen > 0,
            'Cannot Be Zero'
        );
        
        ASHARE_BURNED_PER_TEN_TICKETS = burnedPerTen;
    }

    /**
        Sets The Address Of The Treasury
        @param treasury_ treasury address - cannot be 0
     */
    function setTreasury(address treasury_) external onlyOwner {
        require(
            treasury_ != address(0),
            'Zero Address'
        );
        treasury = treasury_;
    }

    ////////////////////////////////////////////////
    ///////////    PUBLIC FUNCTIONS      ///////////
    ////////////////////////////////////////////////

    /**
        Deposits `amount` of `token` into contract
        If `token` is a registered rewardToken, it will add it
        to the lotto pools as determined by their percentages
        NOTE: Must Have Prior Approval of token for address(this) before calling
        @param token - the token to deposit
        @param amount - amount of `token` to deposit
     */
    function deposit(address token, uint256 amount) external override {
        uint received = _transferIn(IERC20(token), amount);

        if (token == rewardToken) {

            uint ldp = received * largestDailyPercent / percentDenominator;
            uint ddp = received * dailyDepositPercent / percentDenominator;
            uint mwp = received - (ldp + ddp);

            largestDailyPot += ldp;
            dailyDepositPot += ddp;
            monthlyWinnersPot += mwp;
        }
    }

    /**
        Burns ASHARE For Tickets
        The amount transferred in depends on ASHARE_BURNED_PER_TEN_TICKETS
        NOTE: Must Have Prior Approval of ASHARE for address(this) before calling
        @param batches - number of batches of ten tickets to mint
     */
    function burnASHARE(uint batches) external {

        // transfer in ASHARE
        uint received = _transferIn(IERC20(ASHARE), ASHARE_BURNED_PER_TEN_TICKETS * batches);
        require(
            received == ASHARE_BURNED_PER_TEN_TICKETS * batches,
            'Invalid Tokens Received'
        );

        // burn ASHARE
        IERC20(ASHARE).transfer(treasury, received);

        // Add Tickets For Sender
        _addTickets(msg.sender, batches*10);
    }

    /**
        Burns AMES For Tickets
        The amount transferred in depends on AMES_BURNED_PER_TEN_TICKETS
        NOTE: Must Have Prior Approval of AMES for address(this) before calling
        @param batches - number of batches of ten tickets to mint
     */
    function burnAMES(uint batches) external {

        // transfer in AMES
        uint received = _transferIn(IERC20(AMES), AMES_BURNED_PER_TEN_TICKETS * batches);
        require(
            received == AMES_BURNED_PER_TEN_TICKETS * batches,
            'Invalid Tokens Received'
        );

        // burn AMES
        IERC20(AMES).transfer(treasury, received);

        // Add Tickets For Sender
        _addTickets(msg.sender, batches*10);
    }

    /**
        Public Function To Trigger Daily And Monthly Lotto Results
        If The Correct Amount Of Time Has Passed
     */
    function newDay() public {
        
        if (isNewDay()) {
            _newDay();
        }

        if (isNewMonth()) {
            _newMonth();
        }
    }



    ////////////////////////////////////////////////
    ///////////   INTERNAL FUNCTIONS     ///////////
    ////////////////////////////////////////////////

    /**
        Registers A New Day
        Changes The Day Timer
        Distributes Daily Winnings And Largest Daily Deposit Winnings
     */
    function _newDay() internal {

        // reset day timer
        lastDay = block.number;

        // get random number and send rewards when callback is executed
        // the callback is called "fulfillRandomWords"
        // this will revert if VRF subscription is not set and funded.
        newDayRequestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            3, // number of block confirmations before returning random value
            dailyGas, // callback gas limit is dependent num of random values & gas used in callback
            DAILY_WINNERS // the number of random results to return
        );
    }

    /**
        Registers A New Month, Changing The Timer And Distributing Monthly Lotto Winnings
     */
    function _newMonth() internal {

        // reset month timer
        lastMonth = block.number;

        // get random number and send rewards when callback is executed
        // the callback is called "fulfillRandomWords"
        // this will revert if VRF subscription is not set and funded.
        newMonthRequestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            3, // number of block confirmations before returning random value
            monthlyGas, // callback gas limit is dependent num of random values & gas used in callback
            MONTHLY_WINNERS // the number of random results to reeturn
        );
    }

    /**
        Chainlink's callback to provide us with randomness
     */
    function fulfillRandomWords(
        uint256 requestId, /* requestId */
        uint256[] memory randomWords
    ) internal override {

        if (requestId == newDayRequestId) {
            // process largest daily rewards
            _sendLargestDailyRewards();

            // process 3 daily reward winners
            _sendDailyRewards(randomWords);
            
            // reset ticket IDs back to 0
            for (uint i = 0; i < currentTicketRangeID;) {
                delete ticketRanges[i];
                unchecked { ++i; }
            }
            delete currentTicketID;
            delete currentTicketRangeID;

        } else if (requestId == newMonthRequestId) {
            _sendMonthlyRewards(randomWords);
        }

    }

    function _addTickets(address user, uint nTickets) internal {

        // use upper bound of old range as lower bound of new range
        uint lower = currentTicketRangeID == 0 ? 0 : ticketRanges[currentTicketRangeID - 1].upper;

        // set state for new range
        ticketRanges[currentTicketRangeID].lower = lower;
        ticketRanges[currentTicketRangeID].upper = lower + nTickets;
        ticketRanges[currentTicketRangeID].user = user;

        // increment current Ticket ID
        currentTicketID += nTickets;

        // increment ticket range
        currentTicketRangeID++;
    }

    function _fetchTicketOwner(uint256 id) internal view returns (address) {

        for (uint i = 0; i < currentTicketRangeID;) {
            if (
                ticketRanges[i].lower <= id &&
                ticketRanges[i].upper > id
            ) {
                return ticketRanges[i].user;
            }

            unchecked { ++i; }
        }
        return address(0);
    }

    /**
        Processes Daily Reward Lotto
     */
    function _sendDailyRewards(uint256[] memory random) internal {

        if (currentTicketID == 0 || currentTicketRangeID == 0) {
            return;
        }

        // load daily winners number into memory for gas optimization
        uint256 numDailyWinners = uint256(DAILY_WINNERS);

        // create winner array
        address[] memory addr = new address[](numDailyWinners);
        for (uint i = 0; i < numDailyWinners;) {
            address winner = _fetchTicketOwner(random[i] % currentTicketID);
            addr[i] = winner;
            // add to monthly winners list
            if (winner != address(0)) {
                monthlyWinners.push(winner);
            }
            unchecked{ ++i; }
        }

        // calculate reward pot size
        uint rewardPot = ( dailyDepositPot * (100 - rollOverPercentage) ) / 100;

        // send reward pot to winners
        if (rewardPot > 0) {
            // decrement rewards from the dailyDepositPot tracker
            dailyDepositPot -= rewardPot;

            // distribute rewards to winning addresses
            _distributeRewards(addr, rewardPot);
        }

        // clear data
        delete random;
        delete addr;
    }

    /**
        Processes Monthly Reward Lotto
     */
    function _sendMonthlyRewards(uint256[] memory random) internal {

        if (monthlyWinners.length == 0) {
            return;
        }

        // delete last monthly winners
        delete lastMonthlyWinners;

        // load monthly winners into memory for gas optimization
        uint256 numMonthlyWinners = uint256(MONTHLY_WINNERS);

        // create winner array
        address[] memory addr = new address[](numMonthlyWinners);
        for (uint i = 0; i < numMonthlyWinners;) {
            addr[i] = monthlyWinners[random[i] % monthlyWinners.length];
            lastMonthlyWinners.push(addr[i]);
            unchecked{ ++i; }
        }

        // decrement pot
        uint rewardPot = ( monthlyWinnersPot * (100 - rollOverPercentage) ) / 100;

        // send reward to winner
        if (rewardPot > 0) {
            // decrement rewards from the monthlyWinnersPot tracker
            monthlyWinnersPot -= rewardPot;

            // distribute rewards to winning addresses
            _distributeRewards(addr, rewardPot);
        }

        // clear data
        delete monthlyWinners;
        delete random;
        delete addr;
    }

    /**
        Processes Largest Daily Reward Lotto
     */
    function _sendLargestDailyRewards() internal {

        // process largest daily deposit
        if (largestDaily.amount > 0 && largestDaily.depositor != address(0)) {
            
            // Reward Pot
            uint rewardPot = ( largestDailyPot * (100 - rollOverPercentage) ) / 100;

            // send reward
            if (rewardPot > 0) {
                largestDailyPot -= rewardPot;
                _sendToken(largestDaily.depositor, rewardPot);
            }

            // save last winner
            lastLargestDailyWinner = largestDaily.depositor;
        }

        // clear data
        delete largestDaily;
    }

    /**
        Distributes `rewardPot` amongst `recipients` in the reward token
     */
    function _distributeRewards(address[] memory recipients, uint rewardPot) internal {
        
        // length
        uint256 length = recipients.length;

        // calculate rewards per user -- avoiding round off error
        uint r0 = rewardPot / length;
        uint r1 = rewardPot - ( r0 * (length - 1));

        // transfer winnings to users
        for (uint j = 0; j < length;) {
            if (recipients[j] != address(0)) {
                uint amt = j == (length - 1) ? r1 : r0;
                _sendToken(recipients[j], amt);
            }
            unchecked{ ++j; }
        }
    }

    /**
        Transfers in `amount` of `token` to address(this)
        NOTE: Must have prior approval for `token` for address(this)
     */
    function _transferIn(IERC20 token, uint amount) internal returns (uint256) {
        uint before = token.balanceOf(address(this));
        bool s = token.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        uint received = token.balanceOf(address(this)) - before;
        require(
            s &&
            received > 0 &&
            received <= amount,
            'Error TransferFrom'
        );
        return received;
    }

    /**
        Sends `amount` of `token` to `to` 
     */
    function _sendToken(address to, uint amount) internal {
        if (to == address(0)) {
            return;
        }
        uint balance = IERC20(rewardToken).balanceOf(address(this));
        if (amount > balance) {
            amount = balance;
        }
        if (amount == 0) {
            return;
        }
        // update user winnings
        userWinnings[to] += amount;
        // send reward
        require(
            IERC20(rewardToken).transfer(
                to,
                amount
            ),
            'Failure On Token Transfer'
        );
    }


    ////////////////////////////////////////////////
    ///////////      READ FUNCTIONS      ///////////
    ////////////////////////////////////////////////

    /**
        Returns True If It Is A New Day And _newDay() Can Be Called, False Otherwise
     */
    function isNewDay() public view returns (bool) {
        return (block.number - lastDay) >= day;
    }
    
    /**
        Returns True If It Is A New Month And _newMonth() Can Be Called, False Otherwise
     */
    function isNewMonth() public view returns (bool) {
        return (block.number - lastMonth) >= month;
    }

    function timeLeftUntilNewDay() public view returns (uint256) {
        return isNewDay() ? 0 : day - ( block.number - lastDay );
    }

    function timeLeftUntilNewMonth() public view returns (uint256) {
        return isNewMonth() ? 0 : month - ( block.number - lastMonth );
    }

    /**
        Returns The Number Of Tickets Associated With `user`
        @param user - user whose ticket balance is being returned
     */
    function balanceOf(address user) public view returns (uint256 nTickets) {
        uint256 id = currentTicketRangeID;
        for (uint i = 0; i < id;) {
            if (ticketRanges[i].user == user) {
                nTickets += ( ticketRanges[i].upper - ticketRanges[i].lower);
            }
            unchecked{ ++i; }
        }
    }

    /**
        Returns The Ticket Balance Of `user` As Well As The Total Tickets In This Round
        @param user - user whose ticket balance is being returned
     */
    function chanceToWinDaily(address user) public view returns (uint, uint) {
        return (balanceOf(user), currentTicketID);
    }

    function fetchMonthlyWinners() external view returns (address[] memory) {
        return monthlyWinners;
    }

    function fetchLastMonthlyWinners() external view returns (address[] memory) {
        return lastMonthlyWinners;
    }

    function fetchMonthlyWinnersLength() external view returns (uint256) {
        return monthlyWinners.length;
    }

    function fetchChanceToWinMonthly(address user) external view returns (uint256, uint256) {
        return (entriesInMonthly(user), monthlyWinners.length);
    }

    function entriesInMonthly(address user) public view returns (uint256) {

        uint count = 0;
        uint length = monthlyWinners.length;
        for (uint i = 0; i < length;) {
            if (monthlyWinners[i] == user) {
                count++;
            }
            unchecked {
                ++i;
            }
        }
        return count;
    }
}