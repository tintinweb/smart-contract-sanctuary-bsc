/**
 *Submitted for verification at BscScan.com on 2023-03-05
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

interface IPancakeRouter01 {
    function WETH() external pure returns (address);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

contract GenSlots is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    IPancakeRouter02 pancakeRouter;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // Rinkeby coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;  //200 for mainnet

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 250000; //100k for mainnet

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
        uint256 cost;
        uint8[3] symbols; // symbols
        bool finished; // Spin completely finished
        address roller; // user address 
    }
    
    event Spin(address roller, uint256 indexed round, uint8[3] symbols, uint256 payout);

    /*
    0 - Best -> worst
    */
    uint8[][] s_wheels = [[0,1,2,3,4,5,6,7,8],
                        [0,1,2,3,4,5,6,7,8],
                        [0,1,2,3,4,5,6,7,8]];

    uint256[] s_symbolOdds = [1900, 1800, 1600, 1400, 1400, 900, 700, 250, 50];
    uint256 public maxRelativePayout = 1000;
    uint256[] s_payouts = [800, 1500, 4000, 5000, 10000, 25000, 40000, 90000, 100];

    uint256 public sameSymbolOdds = 6000;

    uint256 public prizePool = 0; // amount of tokens to win

    uint256 public ethSpinPrice;
    uint256 public tokenSpinPrice;

    // Roll fee division
    uint256 public potFee;

    address payable public teamAddress;
    address public immutable tokenAddress;

    bool public tokenSpinning = true;

    mapping (address => bool) public freeSpin;
    mapping (address => uint256) public lastFreeSpinTime;
    uint256 [] public freeSpins; // Rounds that were free spins

    constructor(uint64 subscriptionId, address _token, address payable _teamAddress) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        owner = msg.sender;
        s_subscriptionId = subscriptionId;
        tokenAddress = _token;
        potFee = 50;
        teamAddress = _teamAddress;
        pancakeRouter = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // Change for mainnet to 0x10ED43C718714eb63d5aA57B78B54704E256024E
    }

    function spinFree() public { // For users whom are granted a free spin
        require(freeSpin[msg.sender], "User does not have a free spin available.");
        freeSpin[msg.sender] = false;
        freeSpins.push(rolls.length);
        spin(tokenSpinPrice);
    }

    function tokenSpin() public { // Play with tokens
        require(tokenSpinning, "Token not approved for spinning.");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenSpinPrice);

        prizePool += tokenSpinPrice * potFee / 100;
        IERC20(tokenAddress).transfer(teamAddress, tokenSpinPrice * (100 - potFee) / 100); 

        spin(tokenSpinPrice);
    }

    function ethSpin() public payable{ // Play with eth
        require(msg.value >= ethSpinPrice, "Insufficient value to roll");

        uint256 swapETH = ethSpinPrice * potFee / 100;
        teamAddress.transfer(ethSpinPrice * (100 - potFee) / 100);

        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = tokenAddress;
        uint deadline = block.timestamp + 180;
        uint256 tokenBalanceBefore = IERC20(tokenAddress).balanceOf(address(this));
        pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: swapETH}(0, path, address(this), deadline);
        uint256 swappedTokens = IERC20(tokenAddress).balanceOf(address(this)) - tokenBalanceBefore;

        prizePool += swappedTokens;
        spin(swappedTokens);
    }

    // Assumes the subscription is funded sufficiently.
    function spin(uint256 spinPrice) internal {        
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
        idToRoll[id].cost = spinPrice;
        idToRoll[id].finished = false;

        roundsPlayed[msg.sender].push(rolls.length);

        // Push roll to master roll array
        rolls.push(idToRoll[id]);
    }
    
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override { // Callback from LINK and play game
        uint8 symbol = 0;
        uint8[] memory wheel = s_wheels[0];
        uint256[] memory _symbolOdds = s_symbolOdds;
        uint256 oddsCounter = _symbolOdds[0];
        uint256 randomNumber = randomWords[0];
        for(uint8 i; i < _symbolOdds.length; i++){
            if((randomNumber % 10000) + 1 <= oddsCounter){
                symbol = wheel[i];
                break;
            }else{
                oddsCounter += _symbolOdds[i+1];
            }
        }

        idToRoll[requestId].symbols[0] = symbol;
        if((uint256(keccak256(abi.encode(randomNumber, 1))) % 10000) + 1 <= sameSymbolOdds){
            idToRoll[requestId].symbols[1] = symbol;
        }else{
            idToRoll[requestId].symbols[1] = wheel[uint256(keccak256(abi.encode(randomNumber, 2))) % wheel.length];
        }

        if((uint256(keccak256(abi.encode(randomNumber, 3))) % 10000) + 1 <= sameSymbolOdds){
            idToRoll[requestId].symbols[2] = symbol;
        }else{
            idToRoll[requestId].symbols[2] = wheel[uint256(keccak256(abi.encode(randomWords[0], 4))) % wheel.length];
        }

        

        idsFulfilled++;
        
        game(requestId);
    }

    function game(uint256 requestId) internal { 
        if(idToRoll[requestId].symbols[0] == idToRoll[requestId].symbols[1] &&
            idToRoll[requestId].symbols[1] == idToRoll[requestId].symbols[2]) { // all 3 match

            uint256 prize = calculatePrize(idToRoll[requestId].symbols[0], idToRoll[requestId].cost);
            idToRoll[requestId].payout = prize;
            IERC20(tokenAddress).transfer(idToRoll[requestId].roller, prize);
            prizePool -= prize; // decrease prizepool to prevent giving away already won tokens
        }
        
        idToRoll[requestId].finished = true;
        rolls[idToRoll[requestId].round] = idToRoll[requestId]; // copy
        emit Spin(idToRoll[requestId].roller, idToRoll[requestId].round, idToRoll[requestId].symbols, idToRoll[requestId].payout);
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
    
    function totalWinnings(address player) public view returns(uint256){ // Total winnings of contestant, including already paid
        uint256 payout;
        uint256[] memory _rounds = roundsPlayed[player];

        for(uint256 i; i < _rounds.length; i++){
            payout += rolls[_rounds[i]].payout;
        }

        return(payout);
    }

    function calculatePrize(uint8 _symbol, uint256 amountPaid) public view returns(uint256) {
        uint256 currentMaxPayout = prizePool * maxRelativePayout / 10000;
        uint256 prize = amountPaid * s_payouts[_symbol] / 10000;
        prize = prize > currentMaxPayout ? currentMaxPayout : prize;
        prize = _symbol == s_wheels[0].length - 1 ? currentMaxPayout : prize; // jackpot
        return prize;
    }

    function addTokensToPot(uint256 amount) public {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        prizePool += amount;
    }

    /*
    Setters
    */

    function setCallbackGasLimit(uint32 gas) public onlyOwner {
        callbackGasLimit = gas;
    }

    function setSymbolOdds(uint256[] memory _symbolOdds) public onlyOwner {
        s_symbolOdds = _symbolOdds;
    }

    function setSameSymbolOdds(uint256 _sameSymbolOdds) public onlyOwner {
        sameSymbolOdds = _sameSymbolOdds;
    }

    function setPayouts(uint256[] memory _payouts) public onlyOwner { // Set the payout % of each symbol. Also can add new symbols.
        s_payouts = _payouts;
    }

    function setEthSpinPrice(uint256 _ethSpinPrice) public onlyOwner {
        ethSpinPrice = _ethSpinPrice;
    }

    function setTokenSpinPrice(uint256 _tokenSpinPrice) public onlyOwner { // Set price of a spin
        tokenSpinPrice = _tokenSpinPrice;
    }

    function setMaxRelativePayout(uint256 _maxRelativePayout) public onlyOwner { // Set the max jackpot
        maxRelativePayout = _maxRelativePayout;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function setWheels(uint8[][] memory _wheels) public onlyOwner { // Set the number of each symbol per wheel.
        s_wheels = _wheels;
    }

    function setPrizePool(uint256 _prizePool) public onlyOwner { // Set number of tokens to be won. Must have desired amount deposited.
        require(_prizePool <= IERC20(tokenAddress).balanceOf(address(this)), "Not enough tokens deposited.");
        prizePool = _prizePool;
    }

    function setTokenSpinning(bool _tokenSpinning) public onlyOwner { // Enable or disable spinning with tokens
        tokenSpinning = _tokenSpinning;
    }

    function setPotFee(uint256 _potFee) public onlyOwner {
        require(_potFee <= 100, "Pot fee must equal 100% or less");
        potFee = _potFee;
    }

    function setTeamAddress(address _newTeamAddress) public onlyOwner {
        teamAddress = payable(_newTeamAddress);
    }

    function giveFreeSpinPerDay(address user) public onlyOwner {
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