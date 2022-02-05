// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;



import "./VRFConsumerBase.sol";



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function ownership() public view virtual returns (address) {
        return owner;
    }
    modifier onlyOwner() {
        require(ownership() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the 0x0 address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeRouter01 {
    function WETH() external pure returns (address);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {}

interface IPancakeRouter is IPancakeRouter02 {}


contract Lottery is Ownable, VRFConsumerBase {

//  Chainlink VRF variables
    bytes32 internal keyHash; // adjustable
    uint256 internal fee; // adjustable

    uint256 public randomResult;

    bytes32 public latestRequestId;

    address private pancakeRouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address private rewardTokenAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address public supportAddress = tx.origin;

//  Entry data - adjustable
    uint256 public ENTRY_INCREMENT = 1 * 10 ** 16; // entries must be in .01 BNB increments
    uint256 public MAXIMIUM_POOL_SIZE = 100 * 10 ** 18; // 1000 BNB max pool size
    uint256 public MAXIMUM_ENTRIES = 5000; // 5000 entrants max as a precaution
    uint256 public SUPPORT_DENOMINATOR = 20; // Default = 20, this means 5% for the supportAddress --> 1/20 of the total balance

    struct Winner {
        address playerAddress;
        uint256 bnbAmount;
    }

    event WinnerResult(
        address indexed winner,
        uint256 indexed totalStake
    );

    event WaitingForRandom();

    enum LOTTERY_STATE { OPEN, PICKING_WINNER, WAITING_RANDOM, REWARDING_WINNER }
    LOTTERY_STATE public lotteryState;


    IERC20 private tokenContract;
    address[] private players;
    uint256 private numPlayers;
    Winner[] private winners;
    uint256 private openTimestamp;
    uint256 private lotteryPoolSize;

    // Pancake
    IPancakeRouter public immutable pancakeRouter;

    // uint public LOTTERY_RUN_TIME = 60 * 60 * 24 * 1; // 1 day in seconds, adjustable
    uint256 public LOTTERY_RUN_TIME = 60 * 10; // 10 minutes in seconds, adjustable

    // BogRNG Oracle
    //  IBogRandOracle private oracle;
    //  address private constant oracleAddress = 0x3886F3f047ec3914E12b5732222603f7E962f5Eb; // must be changed to Chainlink - 200 days ago last work
    //  address private constant bog = 0xD7B729ef857Aa773f47D37088A1181bB3fbF0099; //BOG token contract
    //  uint256 public MAXIMUM_ORACLE_FEE = 1 * 10 ** 18; // 1 BOG maximum fee per winning pick
    //  uint256 private ORACLE_WAIT_TIME = 60 * 60 * 2; // 2 hours in seconds
      bool public oracleDoReward = false;

 /**
    constructor()
        VRFConsumerBase(
            0xa555fC018435bef5A13C6c6870a9d4C11DEC329C, // VRF Coordinator - BSC Testnet
            0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06  // LINK Token - BSC Testnet
    //        0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31, // VRF Coordinator - BSC Mainnet
    //        0x404460C6A5EdE2D891e8297795264fDe62ADBB75  // LINK Token - BSC Mainnet
        )
    {
    // Chainlink data
        keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186; // keyHash - BSC Testnet
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network - BSC Testnet)
    //    keyHash = 0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c; // keyHash - BSC Mainnet
    //    fee = 0.2 * 10 ** 18; // 0.2 LINK (Varies by network - BSC Mainnet)

*/

    constructor(address _vrfCoordinator, address _link, bytes32 _keyHash, uint256 _fee)
        VRFConsumerBase(_vrfCoordinator, _link)
    {
        keyHash = _keyHash;
        fee = _fee;

        tokenContract = IERC20(rewardTokenAddress);

//        oracle = _vrfCoordinator;

        pancakeRouter = IPancakeRouter(pancakeRouterAddress);

        resetPool();
        lotteryState = LOTTERY_STATE.OPEN;
    }

    /**
     * Reset lottery pool. The lottery state should be set to OPEN right after.
     */
    function resetPool() private {
        clearPlayers();
        openTimestamp = block.timestamp;
        lotteryPoolSize = 0;
//        random = 0;
        randomResult = 0;
    }

    function updateEntryConstants(uint maxPoolSize, uint maxEntries) public onlyOwner {
        if (maxPoolSize > 0) {
            MAXIMIUM_POOL_SIZE = maxPoolSize;
        }
        if (maxEntries > 0) {
            MAXIMUM_ENTRIES = maxEntries;
        }
    }

    function updateEntryIncrement(uint increment) public onlyOwner {
        require(increment > 0, "increment must be greater than 0.");
        ENTRY_INCREMENT = increment;
    }

    function updateOracleFee(uint oracleFee) public onlyOwner {
        require(oracleFee > 0, "Chainlink fee must be greater than 0.");
        fee = oracleFee;
    }

    function updateLotteryRunTime(uint runtime) public onlyOwner {
        require(runtime > 0, "Runtime must be greater than 0.");
        LOTTERY_RUN_TIME = runtime;
    }

    function updateSupportDenominator(uint denominator) public onlyOwner {
        require(denominator > 0, "Support denominator must be greater than 0.");
        SUPPORT_DENOMINATOR = denominator;
    }

    function updatePancakeRouterAddress(address _pancakeRouterAddress) private onlyOwner {
        pancakeRouterAddress = _pancakeRouterAddress;
    }

    function updateRewardTokenAddress(address _rewardTokenAddress) private onlyOwner {
        rewardTokenAddress = _rewardTokenAddress;
    }

    function updateSupportAddress(address _supportAddress) private onlyOwner {
        supportAddress = _supportAddress;
    }

    /**
     * Helper function to avoid expensive array deletion
     */
    function addPlayer(address player) private {
        assert(numPlayers <= players.length);
        if (numPlayers == players.length) {
            players.push(player);
        } else {
            players[numPlayers] = player;
        }
        numPlayers++;
    }

    /**
     * Helper function to avoid expensive array deletion
     */
    function clearPlayers() private {
        numPlayers = 0;
    }

    /**
     * Enter the lottery.
     * The caller must have approved this contract to spend BLOWF tokens in advance.
     * This can cause a state transition to PICKING_WINNER if the current timestamp passes the lottery run time.
     */
    function enter() external payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "The lottery is not open.");
        require(lotteryPoolSize < MAXIMIUM_POOL_SIZE, "The lottery has reached max pool size.");
        require(players.length <= MAXIMUM_ENTRIES, "The lottery has reached max number of entries.");

        // restrict to entry increments to prevent massive arrays
        require(msg.value >= ENTRY_INCREMENT, "Entry amount less than minimum.");
        require(msg.value % (ENTRY_INCREMENT) == 0, "Entry must be in increments of ENTRY_INCREMENT.");

        for (uint i = 0; i < msg.value / (ENTRY_INCREMENT); i++) {
            addPlayer(msg.sender);
        }

        lotteryPoolSize = lotteryPoolSize + msg.value;

        if (block.timestamp > openTimestamp + LOTTERY_RUN_TIME) {
            lotteryState = LOTTERY_STATE.PICKING_WINNER;
            pickWinner();
        }
    }

    /**
     * Pick the winner by requesting a random number.
     * The PICKING_WINNER state can be triggered by enter() or by calling pickWinner() directly.
     * This method calls the BogRNG Oracle to generate a new random number. rewardWinner() must be called
     * manually after the BogRNG Oracle supplies the random number.
     */

    /**
     * Chainlink - Requests randomness
     */
    //function getRandomNumber() public returns (bytes32 requestId) {
    function getRandomNumber() private returns (bytes32 requestId) {
        require(keyHash != bytes32(0), "Must have valid key hash");
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - send LINK tokens to the contract");

        latestRequestId = requestRandomness(keyHash, fee);

        return latestRequestId;
    }

    /**
     * Chainlink - Callback function used by VRF Coordinator
     */
    //function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    //    randomResult = randomness;
    //}

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
    function withdrawLink() external onlyOwner {
        LINK.transfer(msg.sender, LINK.balanceOf(address(this)));
    }

    function getBalanceBEP20(address customTokenAddress) external view returns (uint256) {
        return IERC20(customTokenAddress).balanceOf(address(this));
    }

    // Owner can withdraw any accidentally sent BEP20 tokens
    function withdrawAnyBEP20Token(address customTokenAddress, uint tokens) external onlyOwner returns (bool success) {
        return IERC20(customTokenAddress).transfer(tx.origin, tokens);
    }

    function updateChainlinkKeyHash(bytes32 updatedKeyHash) public onlyOwner {
        keyHash = updatedKeyHash;
    }

    function updateChainlinkFee(uint256 updatedFee) public onlyOwner {
        fee = updatedFee;
    }

    function pickWinner() public {
        if (lotteryState == LOTTERY_STATE.OPEN && block.timestamp > openTimestamp + LOTTERY_RUN_TIME) {
            lotteryState = LOTTERY_STATE.PICKING_WINNER;
        }
        require(lotteryState == LOTTERY_STATE.PICKING_WINNER, "The lottery is not picking winner.");
        require(LINK.balanceOf(address(this)) > fee, "Contract address balance needs more LINK tokens.");

        // Do not allow state transition to WAITING_RANDOM if no players
        if (numPlayers == 0) {
            resetPool();
            lotteryState = LOTTERY_STATE.OPEN;
            return;
        }

    //    refreshRandomNumber();
        getRandomNumber();
        emit WaitingForRandom();
        lotteryState = LOTTERY_STATE.WAITING_RANDOM;
    }

    /**
     * Refresh the random number by requesting a new random number from the BogRNG oracle
     */
    //function refreshRandomNumber() private {
        //IBogRandOracle(oracle).requestRandomness();
    //    getRandomNumber();

    //}

    /**
     * Randomness callback function by the BogRNG oracle
     */
    //function receiveRandomness(uint256 random_) external override {
    //    require(msg.sender == oracleAddress); // Ensure the sender is the oracle

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {

        // lottery already received a random number (maybe an override), ignore callback
        if (lotteryState != LOTTERY_STATE.WAITING_RANDOM) {
            return;
        }

        require(latestRequestId == requestId, "Wrong requestId");

        randomResult = randomness; // Store random number

        lotteryState = LOTTERY_STATE.REWARDING_WINNER;
        // Be wary of max gas usage of BogRNG Oracle callback.
        if (oracleDoReward) {
            rewardWinner();
        }
    }

    /**
     * Fallback mechanism if BogRNG oracle has not called back after a 2 hour waiting period or if callback fails for other reason.
     * This is not ideal, but the winning index is a hash of supplied random, block.timestamp, and block.difficulty.
     * This should be sufficiently difficult to game. Contract owner cannot predict exact timestamp/difficulty,
     * and miners can't predict the supplied random.
     * TODO: a decentralized way of handling this scenario
     */
    /**function receiveRandomnessOverride(uint256 randomness) external onlyOwner {
        require(lotteryState == LOTTERY_STATE.WAITING_RANDOM, "Lottery is not waiting for a random number.");
        // wait 2 hours minimum for oracle callback
        require(block.timestamp > openTimestamp + LOTTERY_RUN_TIME + ORACLE_WAIT_TIME, "Minimum wait time for Oracle not met.");

        randomResult = randomness; // Store random number

        lotteryState = LOTTERY_STATE.REWARDING_WINNER;
    }
    */
    /**
     * Select and reward the winner.
     * This can only be executed after the BogRNG Oracle has called back to receiveRandomness().
     */
    function rewardWinner() public {
        require(lotteryState == LOTTERY_STATE.REWARDING_WINNER, "The lottery is not rewarding winner.");

        // 256 bit wide result of keccak256 is always greater than the number of players
        uint index = uint256(keccak256(abi.encodePacked(randomResult, block.timestamp, block.difficulty))) % numPlayers;

        address winningAddress = players[index];

        // Use 5% of the contract to buy BLOWF and burn
        // uint contractBalance = address(this).balance;
        // uint256 tokens = swapEthForTokens(contractBalance / 20);
        // require(tokenContract.transfer(BURN_ADDRESS, tokens));

        // Send remaining pool to winner
        // contractBalance = address(this).balance;
        // payable(winningAddress).transfer(contractBalance);



        // Send 95% of pool to the winner in form of reward tokens
        uint contractBalance = address(this).balance;
        uint supportAmount = contractBalance / 20;
        uint256 tokens = swapEthForTokens(contractBalance - supportAmount);
        require(tokenContract.transfer(winningAddress, tokens));

        // Use remaining 5% of the contract balance as owner's cut / project support / donation
        contractBalance = address(this).balance;
        payable(supportAddress).transfer(contractBalance);

        // Winning address and pool amount saved
        // winners.push(Winner(winningAddress, contractBalance));
        // emit WinnerResult(winningAddress, contractBalance);

        // Winning address and pool amount saved
        winners.push(Winner(winningAddress, tokens));
        emit WinnerResult(winningAddress, tokens);


        resetPool();
        lotteryState = LOTTERY_STATE.OPEN;
    }

    function swapEthForTokens(uint256 ethAmount) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = rewardTokenAddress;

        uint256[] memory amounts = pancakeRouter.swapExactETHForTokens{value: ethAmount}(
            0,
            path,
            address(this),
            block.timestamp + 300
        );

        return amounts[1];
    }

    // GETTERS

    function getChainlinkKeyHash() public view returns (bytes32) {
        return keyHash;
    }

    function getChainlinkFee() public view returns (uint256) {
        return fee;
    }

    function getNumPlayers() public view returns (uint256) {
        return numPlayers;
    }

    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    function getWinners() public view returns (Winner[] memory) {
        return winners; // historical winners
    }

    function getPool() public view returns (uint256) {
        return lotteryPoolSize;
    }

    function getOpenTimestamp() public view returns (uint256) {
        return openTimestamp;
    }

    function getLatestRequestId() public view returns (bytes32) {
        return latestRequestId;
    }

    function getRandomResult() external view returns (uint256) {
        return randomResult;
    }
}