/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract GenSlots is VRFConsumerBaseV2 {
    /*
    TODO
    set spin price in dollars or tokens
    get dollar value of payout
    pay with approved tokens
    */


    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // Rinkeby coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;  //200 for mainnet

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000; //100k for mainnet

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // Number of random numbers
    uint32 numWords =  1;

    address owner;

    uint256 public idsFulfilled;

    mapping (address => uint256[]) private roundsPlayed;
 
    Roll[] public rolls; // Array of all rolls in order

    mapping (uint256 => Roll) idToRoll; // Map each ID to a roll

    struct Roll{
        uint256 id; // id for VRF
        uint256 payout; // amount won
        uint256 round; // round number
        uint8[3] symbols; // symbols
        bool paid; // payout paid
        address roller; // user address 
    }
    
    event Spin(address roller, uint256 round, uint8[3] symbols, uint256 payout);

    /*
    0 - Best -> worst
    */
    uint8[][] wheels = [[0,1,2,3,4,5,6,7,8],
                        [0,1,2,3,4,5,6,7,8],
                        [0,1,2,3,4,5,6,7,8]];

    uint256 public prizePool = 0; // amount of tokens to win
    uint256 private unclaimedPrizes = 0; // amount of tokens won but not withdrawn

    uint256 public ethSpinPrice;
    uint256 public tokenSpinPrice;

    uint256 public maxPayout = 10000;
    uint256[] public payouts = [10,20,30,40,50,60,70,80,90];


    // Roll fee division
    uint256 public devFee;
    uint256 public gasFee;
    uint256 public liqFee;
    uint256 public potFee;

    // eth and tokens from fees
    uint256 public devETH;
    uint256 public gasETH;
    uint256 public liqETH;
    uint256 public potETH;

    uint256 public devTokens;
    uint256 public gasTokens;
    uint256 public liqTokens;

    address public tokenAddress;

    bool public tokenSpinning = true;

    mapping (address => bool) public freeSpin;
    mapping (address => uint256) public lastFreeSpinTime;
    uint256 [] public freeSpins; // Rounds that were free spins

    constructor(uint64 subscriptionId, address _token) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        owner = msg.sender;
        s_subscriptionId = subscriptionId;
        tokenAddress = _token;
    }

    function spinFree() public { // For users whom are granted a free spin
        require(freeSpin[msg.sender], "User does not have a free spin available.");
        freeSpin[msg.sender] = false;
        freeSpins.push(rolls.length);
        spin();
    }

    function tokenSpin() public { // Play with tokens
        require(tokenSpinning, "Token not approved for spinning.");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenSpinPrice);

        devTokens += tokenSpinPrice * devFee / 100;
        gasTokens += tokenSpinPrice * gasFee / 100;
        liqTokens += tokenSpinPrice * liqFee / 100;
        prizePool += tokenSpinPrice * potFee / 100;

        spin();
    }

    function ethSpin() public payable{ // Play with eth
        require(msg.value >= ethSpinPrice, "Insufficient value to roll");

        devETH += ethSpinPrice * devFee / 100;
        gasETH += ethSpinPrice * gasFee / 100;
        liqETH += ethSpinPrice * liqFee / 100;
        potETH += ethSpinPrice * potFee / 100;

        spin();
    }

    // Assumes the subscription is funded sufficiently.
    function spin() internal {        
        uint256 id;

        // Will revert if subscription is not set and funded.
        id = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );
        
        idToRoll[id].round = rolls.length;
        idToRoll[id].roller = msg.sender;
        idToRoll[id].id = id;

        roundsPlayed[msg.sender].push(rolls.length);

        // Push roll to master roll array
        rolls.push(idToRoll[id]);
    }
    
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override { // Callback from LINK and play game
        // assign symbols to roll
        for(uint8 i; i < wheels.length; i++){
            idToRoll[requestId].symbols[i] = wheels[i][uint256(keccak256(abi.encode(randomWords[0], i))) % wheels[i].length];
        } 

        idsFulfilled++;
        
        game(requestId);
    }

    function game(uint256 requestId) internal { 
        if(idToRoll[requestId].symbols[0] == idToRoll[requestId].symbols[1] &&
            idToRoll[requestId].symbols[1] == idToRoll[requestId].symbols[2]) { // all 3 match

            idToRoll[requestId].payout = symbolPrize(idToRoll[requestId].symbols[0]);
            unclaimedPrizes += symbolPrize(idToRoll[requestId].symbols[0]); // gas not tested
            prizePool -= symbolPrize(idToRoll[requestId].symbols[0]); // decrease prizepool to prevent giving away already won tokens
        }
        else{
            idToRoll[requestId].paid = true;
        }

        emit Spin(idToRoll[requestId].roller, idToRoll[requestId].round, idToRoll[requestId].symbols, idToRoll[requestId].payout);
        rolls[idToRoll[requestId].round] = idToRoll[requestId]; // copy
    }

    /*
    Get round info and symbols
    */

    function symbolsOfRound(uint256 _round) public view returns(uint8[3] memory){
        return(rolls[_round].symbols);
    }

    function roundInfo(uint256 _round) public view returns(Roll memory) {
        return(rolls[_round]);
    }

    function getRoundsPlayed (address player) public view returns(uint256[] memory) {
        return(roundsPlayed[player]);
    }

    /* 
    Prize clacluations and payout 
    */
    
    function claimPrizes() public { // Send all prizes to contestant
        uint256 payout = pendingWinnings(msg.sender);
        unclaimedPrizes -= payout;
        IERC20(tokenAddress).transfer(msg.sender, payout);
    }
    
    function totalWinnings(address player) public view returns(uint256){ // Total winnings of contestant, including already paid
        uint256 payout;
        uint256[] memory _rounds = roundsPlayed[player];

        for(uint256 i; i < _rounds.length; i++){
            payout += rolls[_rounds[i]].payout;
        }

        return(payout);
    }

    function pendingWinnings(address player) public view returns(uint256) { // Pending winnings of contestant
        uint256 payout;
        uint256[] memory _rounds = roundsPlayed[player];

        for(uint256 i; i < _rounds.length; i++){
            // add 0 if already paid, else add payout amount
            payout += rolls[_rounds[i]].paid ? 0 : rolls[_rounds[i]].payout;
        }

        return(payout);
    }

    function symbolPrize(uint8 _symbol) public view returns(uint256) { // Gets amount won if symbol is matched.
        return(prizePool * payouts[_symbol] / 1000 > maxPayout ? maxPayout : prizePool * payouts[_symbol] / 1000);
    }

    /*
    Setters
    */

    function setCallbackGasLimit(uint32 gas) public onlyOwner {
        callbackGasLimit = gas;
    }

    function setPayouts(uint256[] memory _payouts) public onlyOwner { // Set the payout % of each symbol. Also can add new symbols.
        payouts = _payouts;
    }

    function setEthSpinPrice(uint256 _ethSpinPrice) public onlyOwner {
        ethSpinPrice = _ethSpinPrice;
    }

    function setTokenSpinPrice(uint256 _tokenSpinPrice) public onlyOwner { // Set price of a spin
        tokenSpinPrice = _tokenSpinPrice;
    }

    function setMaxPayout(uint256 _maxPayout) public onlyOwner { // Set the max jackpot
        maxPayout = _maxPayout;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function setWheels(uint8[][] memory _wheels) public onlyOwner { // Set the number of each symbol per wheel.
        wheels = _wheels;
    }

    function setPrizePool(uint256 _prizePool) public onlyOwner { // Set number of tokens to be won. Must have desired amount deposited.
        require(_prizePool + devTokens + gasTokens + liqTokens - unclaimedPrizes<= IERC20(tokenAddress).balanceOf(address(this)), "Not enough tokens deposited.");
        prizePool = _prizePool;
    }

    function setTokenSpinning(bool _tokenSpinning) public onlyOwner { // Enable or disable spinning with tokens
        tokenSpinning = _tokenSpinning;
    }

    function setFees(uint256 _potFee, uint256 _devFee, uint256 _liqFee, uint256 _gasFee) public onlyOwner {
        require(_potFee + _devFee + _liqFee + _gasFee == 100, "Total fees must equal 100%");
        potFee = _potFee;
        devFee = _devFee;
        liqFee = _liqFee;
        gasFee = _gasFee;
    }

    function giveFreeSpin(address user) public onlyOwner {
        require(!freeSpin[user], "User already has a free spin.");
        require(lastFreeSpinTime[user] + 1 days < block.timestamp, "User was given a free spin within the last 24 hours!");
        lastFreeSpinTime[user] = block.timestamp;
        freeSpin[user] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    receive() external payable {}
}