/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

// The lottery contract is not a token. We only use the IERC20 interface so that any tokens sent to this contract can be accessed.

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol"
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

// Chainlink VRF contracts.

// import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
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
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);
    function transferFrom(address from, address to, uint256 value) external returns (bool success);
}

// import "@chainlink/contracts/src/v0.8/interfaces/VRFV2WrapperInterface.sol";
interface VRFV2WrapperInterface {
    function lastRequestId() external view returns (uint256);
    function calculateRequestPrice(uint32 _callbackGasLimit) external view returns (uint256);
    function estimateRequestPrice(uint32 _callbackGasLimit, uint256 _requestGasPriceWei) external view returns (uint256);
}

// import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
abstract contract VRFV2WrapperConsumerBase {
    LinkTokenInterface internal immutable LINK;
    VRFV2WrapperInterface internal immutable VRF_V2_WRAPPER;

    constructor(address _link, address _vrfV2Wrapper) {
        LINK = LinkTokenInterface(_link);
        VRF_V2_WRAPPER = VRFV2WrapperInterface(_vrfV2Wrapper);
    }

    function requestRandomness(uint32 _callbackGasLimit, uint16 _requestConfirmations, uint32 _numWords) internal returns (uint256 requestId) {
        LINK.transferAndCall(address(VRF_V2_WRAPPER), VRF_V2_WRAPPER.calculateRequestPrice(_callbackGasLimit), abi.encode(_callbackGasLimit, _requestConfirmations, _numWords));
        return VRF_V2_WRAPPER.lastRequestId();
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal virtual;

    function rawFulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) external {
        require(msg.sender == address(VRF_V2_WRAPPER), "only VRF V2 wrapper can fulfill");
        fulfillRandomWords(_requestId, _randomWords);
    }
}

/**
 * @title The Musicslayer Lottery
 * @author Musicslayer
 */
contract MusicslayerLottery is VRFV2WrapperConsumerBase {
    /// @notice The current lottery is not active and tickets purchases are not allowed.
    error LotteryInactiveError();

    /// @notice The current lottery is active and is not ready to be ended.
    error LotteryActiveError();

    /// @notice The calling address is not the contract owner.
    error NotOwnerError(address _address, address ownerAddress);

    /// @notice The calling address is not the operator.
    error NotOperatorError(address _address, address operatorAddress);

    /// @notice The calling address is not an eligible player.
    error NotPlayerError(address _address);

    /// @notice This contract does not have the funds requested.
    error InsufficientFundsError(uint requestedValue, uint contractBalance);

    /// @notice The token contract could not be found.
    error TokenContractError(address tokenAddress);

    /// @notice The token transfer failed.
    error TokenTransferError(address tokenAddress, address _address, uint requestedValue);

    /// @notice Withdrawing any Chainlink would violate the minimum reserve requirement.
    error ChainlinkMinimumReserveError(uint chainlinkMinimumReserve);

    /// @notice The requestId of the VRF request does not match the requestId of the callback.
    error ChainlinkVRFRequestIdMismatch(uint callbackRequestId, uint expectedRequestId);

    /// @notice The VRF request was initiated during a previous lottery.
    error ChainlinkVRFRequestStale(uint requestLotteryNumber, uint currentLotteryNumber);

    /// @notice Drawing a winning ticket is not allowed at this time.
    error DrawWinningTicketError();

    /// @notice A winning ticket has not been drawn yet.
    error NoWinningTicketDrawnError();

    /// @notice A winning ticket has already been drawn.
    error WinningTicketDrawnError();

    /// @notice The required penalty has not been paid.
    error PenaltyNotPaidError(uint value, uint penalty);

    /// @notice This transaction is purchasing too many tickets.
    error MaxTicketPurchaseError(uint requestedTicketPurchase, uint maxTicketPurchase);

    /// @notice This contract is not corrupt.
    error NotCorruptContractError();

    /// @notice This contract is corrupt.
    error CorruptContractError();

    /// @notice The self-destruct is not ready.
    error SelfDestructNotReadyError();

    /// @notice A record of the owner address changing.
    event OwnerChanged(address indexed oldOwnerAddress, address indexed newOwnerAddress);

    /// @notice A record of the operator address changing.
    event OperatorChanged(address indexed oldOperatorAddress, address indexed newOperatorAddress);

    /// @notice A record of a lottery starting.
    event LotteryStart(uint indexed lotteryNumber, uint indexed lotteryBlockNumberStart, uint indexed lotteryBlockDuration, uint ticketPrice);

    /// @notice A record of a lottery ending.
    event LotteryEnd(uint indexed lotteryNumber, uint indexed lotteryBlockNumberStart, address indexed winningAddress, uint winnerPrize);

    /// @notice A record of a lottery being canceled.
    event LotteryCancel(uint indexed lotteryNumber, uint indexed lotteryBlockNumberStart);

    /// @notice A record of a winning ticket being drawn.
    event WinningTicketDrawn(uint indexed winningTicket, uint indexed totalTickets);

    /// @notice A record of the contract becoming corrupt.
    event Corruption(uint indexed blockNumber);

    /// @notice A record of the contract becoming uncorrupt.
    event CorruptionReset(uint indexed blockNumber);

    // An integer between 0 and 100 representing the percentage of the "playerPrizePool" amount that the operator takes every game.
    // Note that the player always receives the entire "bonusPrizePool" amount.
    uint private constant OPERATOR_CUT = 10;

    // This is the maximum number of tickets that can be purchased in a single transaction.
    // Note that players can use additional transactions to purchase more tickets.
    uint private constant MAX_TICKET_PURCHASE = 10000;

    // A lock variable to prevent reentrancy. Note that the lock is global, so a function using the lock cannot call another function that is also using the lock.
    bool private lockFlag;

    // If the contract is in a bad state, the owner is allowed to take emergency actions. This is designed to allow emergencies to be remedied without allowing anyone to steal the contract funds.
    // Currently, the only known possible bad state would be caused by Chainlink being permanently down.
    bool private corruptContractFlag;
    uint private corruptContractBlockNumber;
    uint private constant CORRUPT_CONTRACT_GRACE_PERIOD_BLOCKS = 864000; // About 30 days.

    // The current lottery number.
    uint private lotteryNumber;

    // Block number where the lottery started.
    uint private lotteryBlockNumberStart;

    // The number of blocks where the lottery is active and players may purchase tickets.
    // If the amount is changed, the new amount will only apply to future lotteries, not the current one.
    uint private lotteryActiveBlocks;
    uint private currentLotteryActiveBlocks;

    // The owner is the original operator and is able to assign themselves the operator role at any time.
    address private ownerAddress;

    // The operator is responsible for running the lottery. In return, they will receive a cut of each prize.
    address private operatorAddress;

    // The price of each ticket. If the price is changed, the new price will only apply to future lotteries, not the current one.
    uint private ticketPrice;
    uint private currentTicketPrice;

    /* To ensure the safety of player funds, the contract balance is accounted for by splitting it into different places:
        // contractFunds - The general funds owned by the contract. The operator can add or withdraw funds at will.
        // playerPrizePool - The funds players have paid to purchase tickets. The operator cannot add or withdraw funds.
        // bonusPrizePool - The funds that have optionally been added to "sweeten the pot" and provide a bigger prize. The operator can add funds but cannot withdraw them.
        // claimableBalancePool - The funds that have not yet been claimed. The operator takes their cut from here, but otherwise they cannot add or withdraw funds.
        // refundPool - The funds that were in the playerPrizePool for a lottery that was canceled. Players can manually request refunds for any tickets they have purchased.
       Anything else not accounted for is considered to be "extra" funds that are treated the same as contract funds.
    */
    uint private contractFunds;
    uint private playerPrizePool;
    uint private bonusPrizePool;
    uint private claimableBalancePool;
    uint private refundPool;

    // Variables to keep track of who is playing and how many tickets they have.
    uint private currentTicketNumber;
    mapping(uint => address) private map_ticket2Address;
    mapping(uint => mapping(address => uint)) private map_lotteryNum2Address2NumTickets;
    mapping(uint => bool) private map_lotteryNum2IsRefundable;

    // Mapping of addresses to claimable balances.
    // For players, this balance is from winnings or from leftover funds after purchasing tickets.
    // For the operator, this balance is from their cut of the prize.
    mapping(address => uint) private map_address2ClaimableBalance;

    // Mappings that show the winning addresses and prizes for each lottery.
    mapping(uint => address) private map_lotteryNum2WinningAddress;
    mapping(uint => uint) private map_lotteryNum2WinnerPrize;

    // Chainlink token and VRF info.
    address private constant CHAINLINK_TOKEN_ADDRESS = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;
    address private constant CHAINLINK_WRAPPER_ADDRESS = 0x699d428ee890d55D56d5FC6e26290f3247A762bd;

    uint private constant CHAINLINK_TOKEN_DECIMALS = 18;
    uint private constant CHAINLINK_MINIMUM_RESERVE = 40 * 10 ** CHAINLINK_TOKEN_DECIMALS; // 40 LINK

    uint32 private constant CHAINLINK_CALLBACK_GAS_LIMIT = 2000000; // This was chosen experimentally.
    uint16 private constant CHAINLINK_REQUEST_CONFIRMATION_BLOCKS = 200; // About 10 minutes. Use the maximum allowed value of 200 blocks to be extra secure.
    uint16 private constant CHAINLINK_REQUEST_RETRY_BLOCKS = 600; // About 30 minutes. If we request a random number but don't get it after 600 blocks, we can make a new request.

    uint private chainlinkRetryCounter;
    uint private constant CHAINLINK_RETRY_MAX = 10;

    bool private chainlinkRequestIdFlag;
    uint private chainlinkRequestIdBlockNumber;
    uint private chainlinkRequestIdLotteryNumber;
    uint private chainlinkRequestId;

    bool private winningTicketFlag;
    uint private winningTicket;

    /*
        Contract Functions
    */

    constructor(uint initialLotteryActiveBlocks, uint initialTicketPrice) VRFV2WrapperConsumerBase(CHAINLINK_TOKEN_ADDRESS, CHAINLINK_WRAPPER_ADDRESS) payable {
        addContractFunds(msg.value);

        setOwnerAddress(msg.sender);
        setOperatorAddress(msg.sender);

        lotteryActiveBlocks = initialLotteryActiveBlocks;
        ticketPrice = initialTicketPrice;

        startNewLottery();
    }

    receive() external payable {
        // Funds received from a player will be used to buy tickets. Funds received from the operator will be counted as contract funds.
        lock_start();

        if(isOperatorAddress(msg.sender)) {
            addContractFunds(msg.value);
        }
        else {
            requireLotteryActive();
            requireNotCorruptContract();

            buyTickets(msg.sender, msg.value);
        }

        lock_end();
    }

    fallback() external payable {
        // There is no legitimate reason for this fallback function to be called.
        punish();
    }

    /*
        Lottery Functions
    */

    function buyTickets(address _address, uint value) private {
        // Purchase as many tickets as possible for the address with the provided value. Note that tickets can only be purchased in whole number quantities.
        // After spending all the funds on tickets, anything left over will be added to the address's claimable balance.
        uint numTickets = value / currentTicketPrice;
        if(numTickets > MAX_TICKET_PURCHASE) {
            revert MaxTicketPurchaseError(numTickets, MAX_TICKET_PURCHASE);
        }

        uint totalTicketValue = numTickets * currentTicketPrice;
        uint unspentValue = value - totalTicketValue;

        addPlayerPrizePool(totalTicketValue);
        addAddressClaimableBalance(_address, unspentValue);
        
        // To save gas, only write the information for the first purchased ticket, and then every 100 afterwards.
        uint lastTicketNumber = currentTicketNumber + numTickets;
        for(uint i = currentTicketNumber; i < lastTicketNumber; i += 100) {
            map_ticket2Address[i] = _address;
        }

        map_lotteryNum2Address2NumTickets[lotteryNumber][_address] += numTickets;
        currentTicketNumber = lastTicketNumber;
    }

    function startNewLottery() private {
        // Reset lottery state and begin a new lottery. The contract is designed so that we don't need to clear any of the mappings, something that saves a lot of gas.
        currentTicketNumber = 0;

        // If any of these values have been changed by the operator, update them now before starting the next lottery.
        currentLotteryActiveBlocks = lotteryActiveBlocks;
        currentTicketPrice = ticketPrice;

        lotteryNumber++;
        lotteryBlockNumberStart = block.number;

        chainlinkRetryCounter = 0;

        chainlinkRequestIdFlag = false;
        winningTicketFlag = false;

        emit LotteryStart(lotteryNumber, lotteryBlockNumberStart, lotteryActiveBlocks, ticketPrice);
    }

    function endCurrentLottery() private {
        // End the current lottery, credit any prizes rewarded, and then start a new lottery.
        address winningAddress;
        uint operatorPrize;
        uint winnerPrize;

        if(isZeroPlayerGame()) {
            // No one played. For recordkeeping purposes, the winner is the zero address and the prize is zero.
        }
        else if(isOnePlayerGame()) {
            // Since only one person has played, just give them the entire prize.
            winningAddress = map_ticket2Address[0];
            winnerPrize = bonusPrizePool + playerPrizePool;
        }
        else {
            // Give the lottery operator their cut of the pot, and then give the rest to the randomly chosen winner.
            winningAddress = findWinningAddress(winningTicket);
            operatorPrize = playerPrizePool * OPERATOR_CUT / 100;
            winnerPrize = playerPrizePool + bonusPrizePool - operatorPrize;
        }

        addAddressClaimableBalance(getOperatorAddress(), operatorPrize);
        addAddressClaimableBalance(winningAddress, winnerPrize);

        playerPrizePool = 0;
        bonusPrizePool = 0;

        map_lotteryNum2WinningAddress[lotteryNumber] = winningAddress;
        map_lotteryNum2WinnerPrize[lotteryNumber] = winnerPrize;

        emit LotteryEnd(lotteryNumber, lotteryBlockNumberStart, winningAddress, winnerPrize);

        startNewLottery();
    }

    function cancelCurrentLottery(uint value) private {
        // Mark the current lottery as refundable and start a new lottery.
        map_lotteryNum2IsRefundable[lotteryNumber] = true;
        emit LotteryCancel(lotteryNumber, lotteryBlockNumberStart);

        // Move funds in the player prize pool to the refund pool. Players who have purchased tickets may request a refund manually.
        addRefundPool(playerPrizePool);
        playerPrizePool = 0;

        // Carry over the existing bonus prize pool and add in the penalty value.
        addBonusPrizePool(value);

        // For recordkeeping purposes, the winner is the zero address and the prize is zero.
        map_lotteryNum2WinningAddress[lotteryNumber] = address(0);
        map_lotteryNum2WinnerPrize[lotteryNumber] = 0;

        startNewLottery();
    }

    function findWinningAddress(uint ticket) private view returns (address) {
        address winningAddress = map_ticket2Address[ticket];

        // Because "map_ticket2Address" potentially has gaps, we may have to search until we find the winning address.
        // Note that because of the way "map_ticket2Address" is filled in, element 0 is guaranteed to have a nonzero address.
        while(winningAddress == address(0)) {
            winningAddress = map_ticket2Address[--ticket];
        }

        return winningAddress;
    }

    function getLotteryNumber() private view returns (uint) {
        return lotteryNumber;
    }

    function getRemainingLotteryActiveBlocks() private view returns (uint) {
        uint numBlocksPassed = block.number - lotteryBlockNumberStart;
        if(numBlocksPassed <= currentLotteryActiveBlocks) {
            return currentLotteryActiveBlocks - numBlocksPassed;
        }
        else {
            return 0;
        }
    }

    function isLotteryActive() private view returns (bool) {
        return getRemainingLotteryActiveBlocks() > 0;
    }

    function requireLotteryActive() private view {
        if(!isLotteryActive()) {
            revert LotteryInactiveError();
        }
    }

    function requireLotteryInactive() private view {
        if(isLotteryActive()) {
            revert LotteryActiveError();
        }
    }

    function isWinningTicketDrawn() private view returns (bool) {
        return winningTicketFlag;
    }

    function requireWinningTicketDrawn() private view {
        if(!isWinningTicketDrawn()) {
            revert NoWinningTicketDrawnError();
        }
    }

    function requireNoWinningTicketDrawn() private view {
        if(isWinningTicketDrawn()) {
            revert WinningTicketDrawnError();
        }
    }

    function totalAddressTickets(address _address) private view returns (uint) {
        return map_lotteryNum2Address2NumTickets[lotteryNumber][_address];
    }

    function totalTickets() private view returns (uint) {
        return currentTicketNumber;
    }

    function isZeroPlayerGame() private view returns (bool) {
        // Check to see if there are no players.
        return currentTicketNumber == 0;
    }

    function isOnePlayerGame() private view returns (bool) {
        // Check to see if there is only one player who has purchased all the tickets.
        return currentTicketNumber != 0 && (totalAddressTickets(map_ticket2Address[0]) == totalTickets());
    }

    function isAddressPlaying(address _address) private view returns (bool) {
        return map_lotteryNum2Address2NumTickets[lotteryNumber][_address] != 0;
    }

    function getLotteryBlockNumberStart() private view returns (uint) {
        return lotteryBlockNumberStart;
    }

    function getLotteryActiveBlocks() private view returns (uint) {
        return currentLotteryActiveBlocks;
    }

    function setLotteryActiveBlocks(uint newLotteryActiveBlocks) private {
        // Do not set the current active lottery blocks here. When the next lottery starts, the current active lottery blocks will be updated.
        lotteryActiveBlocks = newLotteryActiveBlocks;
    }

    function getTicketPrice() private view returns (uint) {
        // Return the current ticket price.
        return currentTicketPrice;
    }

    function setTicketPrice(uint newTicketPrice) private {
        // Do not set the current ticket price here. When the next lottery starts, the current ticket price will be updated.
        ticketPrice = newTicketPrice;
    }

    function getPenaltyPayment() private view returns (uint) {
        // The base penalty is 0.1 of the native coin, but if the lottery is inactive and there are at least two players, then the penalty is multiplied by 5.
        uint penalty = 0.1 ether;
        if(!isLotteryActive() && !isZeroPlayerGame() && !isOnePlayerGame()) {
            penalty *= 5;
        }
        return penalty;
    }

    function requirePenaltyPayment(uint value) private view {
        if(value < getPenaltyPayment()) {
            revert PenaltyNotPaidError(value, getPenaltyPayment());
        }
    }

    function getLotteryWinningAddress(uint _lotteryNumber) private view returns (address) {
        return map_lotteryNum2WinningAddress[_lotteryNumber];
    }

    function getLotteryWinnerPrize(uint _lotteryNumber) private view returns (uint) {
        return map_lotteryNum2WinnerPrize[_lotteryNumber];
    }

    /*
        RNG Functions
    */

    function drawWinningTicket() private {
        if(winningTicketFlag || (chainlinkRequestIdFlag && !isRetryPermitted())) {
            revert DrawWinningTicketError();
        }

        // At a certain point we must conclude that Chainlink is down and give up. Don't allow for additional attempts because they cost Chainlink tokens.
        if(chainlinkRetryCounter > CHAINLINK_RETRY_MAX) {
            setCorruptContract(true);
            return;
        }

        chainlinkRetryCounter++;

        chainlinkRequestIdFlag = true;
        chainlinkRequestIdBlockNumber = block.number;
        chainlinkRequestIdLotteryNumber = lotteryNumber;
        chainlinkRequestId = requestRandomness(CHAINLINK_CALLBACK_GAS_LIMIT, CHAINLINK_REQUEST_CONFIRMATION_BLOCKS, 1);
    }

    function isRetryPermitted() private view returns (bool) {
        // We allow for a redraw if the random number has not been received after a certain number of blocks. This would be needed if Chainlink ever experiences an outage.
        return block.number - chainlinkRequestIdBlockNumber > CHAINLINK_REQUEST_RETRY_BLOCKS;
    }

    function fulfillRandomWords(uint requestId, uint[] memory randomWords) internal override {
        // This is the Chainlink VRF callback that will give us the random number we requested. We use this to choose a winning ticket.
        if(chainlinkRequestId != requestId) {
            revert ChainlinkVRFRequestIdMismatch(requestId, chainlinkRequestId);
        }

        if(chainlinkRequestIdLotteryNumber != lotteryNumber) {
            revert ChainlinkVRFRequestStale(chainlinkRequestIdLotteryNumber, lotteryNumber);
        }

        winningTicketFlag = true;
        uint randomNumber = randomWords[0];
        //winningTicket = randomNumber % currentTicketNumber;
        winningTicket = 0;

        emit WinningTicketDrawn(winningTicket, currentTicketNumber);
    }

    /*
        Address Functions
    */

    function getOwnerAddress() private view returns (address) {
        return ownerAddress;
    }

    function setOwnerAddress(address _address) private {
        emit OwnerChanged(ownerAddress, _address);
        ownerAddress = _address;
    }

    function isOwnerAddress(address _address) private view returns (bool) {
        return _address == getOwnerAddress();
    }

    function requireOwnerAddress(address _address) private view {
        if(!isOwnerAddress(_address)) {
            revert NotOwnerError(_address, getOwnerAddress());
        }
    }

    function getOperatorAddress() private view returns (address) {
        return operatorAddress;
    }

    function setOperatorAddress(address newOperatorAddress) private {
        emit OperatorChanged(operatorAddress, newOperatorAddress);
        operatorAddress = newOperatorAddress;
    }

    function isOperatorAddress(address _address) private view returns (bool) {
        return _address == getOperatorAddress();
    }

    function requireOperatorAddress(address _address) private view {
        if(!isOperatorAddress(_address)) {
            revert NotOperatorError(_address, getOperatorAddress());
        }
    }

    function isPlayerAddress(address _address) private view returns (bool) {
        // The only ineligible player is the operator.
        //return _address != getOperatorAddress();
        return true;
    }

    function requirePlayerAddress(address _address) private view {
        if(!isPlayerAddress(_address)) {
            revert NotPlayerError(_address);
        }
    }

    /*
        Funding Functions
    */

    function getContractBalance() private view returns (uint) {
        // This is the true and complete contract balance.
        return address(this).balance;
    }

    function getTokenBalance(address tokenAddress) private view returns (uint) {
        IERC20 tokenContract = IERC20(tokenAddress);
        return tokenContract.balanceOf(address(this));
    }

    function withdrawTokenBalance(address tokenAddress, address _address) private {
        // For Chainlink, we honor the minimum reserve requirement. For any other token, just withdraw the entire balance.
        uint tokenBalance = getTokenBalance(tokenAddress);

        if(tokenAddress == CHAINLINK_TOKEN_ADDRESS) {
            if(tokenBalance >= CHAINLINK_MINIMUM_RESERVE) {
                tokenBalance -= CHAINLINK_MINIMUM_RESERVE;
            }
            else {
                revert ChainlinkMinimumReserveError(CHAINLINK_MINIMUM_RESERVE);
            }
        }

        tokenTransferToAddress(tokenAddress, _address, tokenBalance);
    }

    function withdrawAllChainlink(address _address) private {
        // Withdraw all Chainlink, including the minimum reserve.
        tokenTransferToAddress(CHAINLINK_TOKEN_ADDRESS, _address, getTokenBalance(CHAINLINK_TOKEN_ADDRESS));
    }

    function getAccountedContractBalance() private view returns (uint) {
        return contractFunds + playerPrizePool + bonusPrizePool + claimableBalancePool + refundPool;
    }

    function getExtraContractBalance() private view returns (uint) {
        // Returns the amount of "extra" funds this contract has. This should usually be zero, but may be more if funds are sent here in ways that cannot be accounted for.
        // For example, a coinbase transaction or another contract calling "selfdestruct" could send funds here without passing through the "receive" function for proper accounting.
        return getContractBalance() - getAccountedContractBalance();
    }

    function getOperatorContractBalance() private view returns (uint) {
        // This is the balance that the operator has access to.
        return contractFunds + getExtraContractBalance();
    }

    function getContractFunds() private view returns (uint) {
        return contractFunds;
    }

    function addContractFunds(uint value) private {
        contractFunds += value;
    }

    function withdrawContractFunds(address _address, uint value) private {
        // Withdraw an amount from the contract funds. For the purposes of this function, extra funds are treated as contract funds.
        uint operatorContractBalance = getOperatorContractBalance();

        if(value > operatorContractBalance) {
            revert InsufficientFundsError(value, operatorContractBalance);
        }

        // Only if the value is higher than the extra funds do we subtract from "contractFunds". This accounting makes it so extra funds are spent first.
        if(value > getExtraContractBalance()) {
            contractFunds -= (value - getExtraContractBalance());
        }
        transferToAddress(_address, value);
    }

    function withdrawAllContractFunds(address _address) private {
        // Withdraw the entire contract funds. For the purposes of this function, extra funds are treated as contract funds.
        contractFunds = 0;
        transferToAddress(_address, getOperatorContractBalance());
    }

    function getPlayerPrizePool() private view returns (uint) {
        return playerPrizePool;
    }

    function addPlayerPrizePool(uint value) private {
        playerPrizePool += value;
    }

    function getBonusPrizePool() private view returns (uint) {
        return bonusPrizePool;
    }

    function addBonusPrizePool(uint value) private {
        bonusPrizePool += value;
    }

    function getClaimableBalancePool() private view returns (uint) {
        return claimableBalancePool;
    }

    function getAddressClaimableBalance(address _address) private view returns (uint) {
        return map_address2ClaimableBalance[_address];
    }

    function addAddressClaimableBalance(address _address, uint value) private {
        map_address2ClaimableBalance[_address] += value;
        claimableBalancePool += value;
    }

    function withdrawAddressClaimableBalance(address _address) private {
        // We only allow the entire balance to be withdrawn.
        uint balance = getAddressClaimableBalance(_address);

        map_address2ClaimableBalance[_address] = 0;
        claimableBalancePool -= balance;

        transferToAddress(_address, balance);
    }

    function getRefundPool() private view returns (uint) {
        return refundPool;
    }

    function addRefundPool(uint value) private {
        refundPool += value;
    }

    function getAddressRefund(uint _lotteryNumber, address _address) private view returns (uint) {
        if(map_lotteryNum2IsRefundable[_lotteryNumber]) {
            return map_lotteryNum2Address2NumTickets[_lotteryNumber][_address];
        }
        else {
            // The lottery was not canceled so no one can get a refund.
            return 0;
        }
    }

    function withdrawAddressRefund(uint _lotteryNumber, address _address) private {
        // We only allow the entire balance to be withdrawn.
        uint balance = getAddressRefund(_lotteryNumber, _address);

        map_lotteryNum2Address2NumTickets[_lotteryNumber][_address] = 0;
        refundPool -= balance;

        transferToAddress(_address, balance);
    }

    /*
        Reentrancy Functions
    */

    function setLocked(bool _isLocked) private {
        lockFlag = _isLocked;
    }

    function isLocked() private view returns (bool) {
        return lockFlag;
    }

    function lock_start() private {
        // Call this at the start of each external function that can change state to protect against reentrancy.
        if(isLocked()) {
            punish();
        }
        setLocked(true);
    }

    function lock_end() private {
        // Call this at the end of each external function.
        setLocked(false);
    }

    /*
        Utility Functions
    */

    function punish() private pure {
        // This operation will cause a revert but also consume all the gas. This will punish those who are trying to attack the contract.
        //assembly("memory-safe") { invalid() }
    }

    function transferToAddress(address _address, uint value) private {
        payable(_address).transfer(value);
    }

    function tokenTransferToAddress(address tokenAddress, address _address, uint value) private {
        // Take extra care to account for tokens that don't revert on failure or that don't return a value.
        // A return value is optional, but if it is present then it must be true.
        if(tokenAddress.code.length == 0) {
            revert TokenContractError(tokenAddress);
        }

        bytes memory callData = abi.encodeWithSelector(IERC20(tokenAddress).transfer.selector, _address, value);
        (bool success, bytes memory returnData) = tokenAddress.call(callData);

        if(!success || (returnData.length > 0 && !abi.decode(returnData, (bool)))) {
            revert TokenTransferError(tokenAddress, _address, value);
        }
    }

    /*
        Self-Destruct Functions
    */

    function isCorruptContract() private view returns (bool) {
        return corruptContractFlag;
    }

    function setCorruptContract(bool _isCorruptContract) private {
        if(_isCorruptContract) {
            // Do not allow "isCorruptBlock" to keep increasing or multiple events to be issued.
            if(!corruptContractFlag) {
                corruptContractFlag = true;
                corruptContractBlockNumber = block.number;

                emit Corruption(block.number);
            }
        }
        else {
            corruptContractFlag = false;
            corruptContractBlockNumber = 0;

            emit CorruptionReset(block.number);
        }
    }

    function requireCorruptContract() private view {
        if(!isCorruptContract()) {
            revert NotCorruptContractError();
        }
    }

    function requireNotCorruptContract() private view {
        if(isCorruptContract()) {
            revert CorruptContractError();
        }
    }

    function getRemainingCorruptContractGracePeriodBlocks() private view returns (uint) {
        uint numBlocksPassed = block.number - corruptContractBlockNumber;
        if(numBlocksPassed <= CORRUPT_CONTRACT_GRACE_PERIOD_BLOCKS) {
            return CORRUPT_CONTRACT_GRACE_PERIOD_BLOCKS - numBlocksPassed;
        }
        else {
            return 0;
        }
    }

    function isCorruptContractGracePeriod() private view returns (bool) {
        return getRemainingCorruptContractGracePeriodBlocks() > 0;
    }

    function isSelfDestructReady() private view returns (bool) {
        // If this function returns true, the owner is allowed to call "selfdestruct" and withdraw the entire contract balance.
        // To ensure the owner cannot just run away with prize money, we require all of the following to be true:
        // -> The contract must be corrupt.
        // -> After the contract became corrupt, the owner must wait for a grace period to pass. This gives everyone a chance to withdraw any funds owed to them.
        return isCorruptContract() && !isCorruptContractGracePeriod();
    }

    function requireSelfDestructReady() private view {
        if(!isSelfDestructReady()) {
            revert SelfDestructNotReadyError();
        }
    }

    function selfDestruct(address _address) private {
        // Destroy this contract and give any native coin balance to the address.
        // The owner is responsible for withdrawing tokens before this contract is destroyed.
        selfdestruct(payable(_address));
    }

    /*
        External Functions
    */

    /// @notice Returns an integer between 0 and 100 representing the percentage of the "playerPrizePool" amount that the operator takes every game.
    /// @return An integer between 0 and 100 representing the percentage of the "playerPrizePool" amount that the operator takes every game.
    function constant_operatorCut() external pure returns (uint) {
        return OPERATOR_CUT;
    }

    /// @notice Returns the maximum number of tickets that can be purchased in a single transaction.
    /// @return The maximum number of tickets that can be purchased in a single transaction.
    function constant_maxTicketPurchase() external pure returns (uint) {
        return MAX_TICKET_PURCHASE;
    }

    /// @notice Returns the total grace period blocks.
    /// @return The total grace period blocks.
    function constant_corruptContractGracePeriodBlocks() external pure returns (uint) {
        return CORRUPT_CONTRACT_GRACE_PERIOD_BLOCKS;
    }

    /// @notice Returns whether the contract is currently locked.
    /// @return Whether the contract is currently locked.
    function query_isLocked() external view returns (bool) {
        return isLocked();
    }

    /// @notice Returns whether the contract is currently corrupt.
    /// @return Whether the contract is currently corrupt.
    function query_isCorruptContract() external view returns (bool) {
        return isCorruptContract();
    }

    /// @notice Returns whether we are in the corrupt contract grace period. This value is meaningless unless the contract is corrupt.
    /// @return Whether we are in the corrupt contract grace period.
    function query_isCorruptContractGracePeriod() external view returns (bool) {
        return isCorruptContractGracePeriod();
    }

    /// @notice Returns whether the self-destruct is ready.
    /// @return Whether the self-destruct is ready.
    function query_isSelfDestructReady() external view returns (bool) {
        return isSelfDestructReady();
    }

    /// @notice Returns whether the address is playing in the current lottery.
    /// @param _address The address that we are checking whether it is playing or not.
    /// @return Whether the address is playing or not.
    function query_isAddressPlaying(address _address) external view returns (bool) {
        return isAddressPlaying(_address);
    }

    /// @notice Returns whether the current lottery is active or not.
    /// @return Whether the current lottery is active or not.
    function query_isLotteryActive() external view returns (bool) {
        return isLotteryActive();
    }

    /// @notice Returns whether a winning ticket has been drawn for the current lottery.
    /// @return Whether a winning ticket has been drawn for the current lottery.
    function query_isWinningTicketDrawn() external view returns (bool) {
        return isWinningTicketDrawn();
    }

    /// @notice Returns the remaining grace period blocks. This value is meaningless unless the contract is corrupt.
    /// @return The remaining grace period blocks.
    function get_remainingCorruptContractGracePeriodBlocks() external view returns (uint) {
        return getRemainingCorruptContractGracePeriodBlocks();
    }

    /// @notice Returns the entire contract balance. This includes all funds, even those that are unaccounted for.
    /// @return The entire contract balance.
    function get_contractBalance() external view returns (uint) {
        return getContractBalance();
    }

    /// @notice Returns the number of tickets an address has in the current lottery.
    /// @param _address The address that we are checking the number of tickets for.
    /// @return The number of tickets the address has in the current lottery.
    function get_totalAddressTickets(address _address) external view returns (uint) {
        return totalAddressTickets(_address);
    }

    /// @notice Returns the total number of tickets in the current lottery.
    /// @return The total number of tickets in the current lottery.
    function get_totalTickets() external view returns (uint) {
        return totalTickets();
    }

    /// @notice Returns the claimable balance of the address.
    /// @param _address The address that we are checking the claimable balance for.
    /// @return The claimable balance of the address.
    function get_addressClaimableBalance(address _address) external view returns (uint) {
        return getAddressClaimableBalance(_address);
    }

    /// @notice Returns the refund an address is entitled to.
    /// @param _lotteryNumber The number of a lottery that was canceled.
    /// @param _address The address that we are checking the refund for.
    /// @return The claimable balance of the address.
    function get_addressRefund(uint _lotteryNumber, address _address) external view returns (uint) {
        return getAddressRefund(_lotteryNumber, _address);
    }

    /// @notice Returns the predicted number of times that the address will win out of 100 times, truncated to an integer. This is equivalent to the percentage probability of the address winning.
    /// @param _address The address that we are checking the win chance for.
    /// @return The predicted number of times that the address will win out of 100 times.
    function get_addressWinChance(address _address) external view returns (uint) {
        return totalAddressTickets(_address) * 100 / totalTickets();
    }

    /// @notice Returns the predicted number of times that the address will win out of N times, truncated to an integer. This function can be used to get extra digits in the answer that would normally get truncated.
    /// @param _address The address that we are checking the win chance for.
    /// @param N The total number of times that we want to know how many times the address will win out of.
    /// @return The predicted number of times that the address will win out of N times.
    function get_addressWinChanceOutOf(address _address, uint N) external view returns (uint) {
        return totalAddressTickets(_address) * N / totalTickets();
    }

    /// @notice Returns the current owner address.
    /// @return The current owner address.
    function get_ownerAddress() external view returns (address) {
        return getOwnerAddress();
    }

    /// @notice Returns the current operator address.
    /// @return The current operator address.
    function get_operatorAddress() external view returns (address) {
        return getOperatorAddress();
    }

    /// @notice Returns the amount of funds accounted for as contract funds. Note that the actual contract balance may be higher.
    /// @return The amount of contract funds.
    function get_contractFunds() external view returns (uint) {
        return getContractFunds();
    }

    /// @notice Returns the player prize pool. This is the amount of funds used to purchase tickets in the current lottery.
    /// @return The player prize pool.
    function get_playerPrizePool() external view returns (uint) {
        return getPlayerPrizePool();
    }

    /// @notice Returns the bonus prize pool. This is the amount of bonus funds that anyone can donate to "sweeten the pot".
    /// @return The bonus prize pool.
    function get_bonusPrizePool() external view returns (uint) {
        return getBonusPrizePool();
    }

    /// @notice Returns the claimable balance pool. This is the total amount of funds that can currently be claimed.
    /// @return The claimable balance pool.
    function get_claimableBalancePool() external view returns (uint) {
        return getClaimableBalancePool();
    }

    /// @notice Returns the refund pool. This is the total amount of funds that can currently be refunded from canceled lotteries.
    /// @return The refund pool.
    function get_refundPool() external view returns (uint) {
        return getRefundPool();
    }

    /// @notice Returns the current lottery number.
    /// @return The current lottery number.
    function get_lotteryNumber() external view returns (uint) {
        return getLotteryNumber();
    }

    /// @notice Returns the start block number of the current lottery
    /// @return The start block number of the current lottery
    function get_lotteryBlockNumberStart() external view returns (uint) {
        return getLotteryBlockNumberStart();
    }

    /// @notice Returns the total number of active blocks for the current lottery.
    /// @return The total number of active blocks for the current lottery.
    function get_lotteryActiveBlocks() external view returns (uint) {
        return getLotteryActiveBlocks();
    }

    /// @notice Returns the remaining number of active blocks for the current lottery.
    /// @return The remaining number of active blocks for the current lottery.
    function get_remainingLotteryActiveBlocks() external view returns (uint) {
        return getRemainingLotteryActiveBlocks();
    }

    /// @notice Returns the ticket price of the current lottery.
    /// @return The ticket price of the current lottery.
    function get_ticketPrice() external view returns (uint) {
        return getTicketPrice();
    }

    /// @notice Returns the balance of a token.
    /// @param tokenAddress The address where the token's contract lives.
    /// @return The token balance.
    function get_tokenBalance(address tokenAddress) external view returns (uint) {
        return getTokenBalance(tokenAddress);
    }

    /// @notice Returns the winning address of a lottery.
    /// @param _lotteryNumber The number of a lottery that has already finished.
    /// @return The address that won the lottery.
    function get_lotteryWinningAddress(uint _lotteryNumber) external view returns (address) {
        return getLotteryWinningAddress(_lotteryNumber);
    }

    /// @notice Returns the winner's prize of a lottery.
    /// @param _lotteryNumber The number of a lottery that has already finished.
    /// @return The prize that was won for the lottery.
    function get_lotteryWinnerPrize(uint _lotteryNumber) external view returns (uint) {
        return getLotteryWinnerPrize(_lotteryNumber);
    }

    /// @notice The operator can call this to give funds to the contract.
    function action_addContractFunds() external payable {
        lock_start();

        requireOperatorAddress(msg.sender);

        addContractFunds(msg.value);

        lock_end();
    }

    /// @notice Anyone can call this to add funds to the bonus prize pool, but only if the contract is not corrupt.
    function action_addBonusPrizePool() external payable {
        lock_start();

        requireNotCorruptContract();

        addBonusPrizePool(msg.value);

        lock_end();
    }

    /// @notice Players can call this to buy tickets for the current lottery, but only if it is still active and the contract is not corrupt.
    function action_buyTickets() external payable {
        lock_start();

        requireLotteryActive();
        requireNotCorruptContract();
        requirePlayerAddress(msg.sender);

        buyTickets(msg.sender, msg.value);

        lock_end();
    }

    /// @notice Anyone can call this to draw the winning ticket, but only if the current lottery is no longer active.
    function action_drawWinningTicket() external {
        lock_start();

        requireLotteryInactive();

        drawWinningTicket();

        lock_end();
    }

    /// @notice Anyone can call this to end the current lottery, but only if a winning ticket has been drawn.
    function action_endCurrentLottery() external {
        lock_start();

        requireWinningTicketDrawn();

        endCurrentLottery();

        lock_end();
    }

    /// @notice The operator can call this before a winning ticket is drawn to cancel the current lottery and refund everyone. The operator gives up their cut and must pay a penalty fee to do this.
    function action_cancelCurrentLottery() external payable {
        lock_start();

        requireOperatorAddress(msg.sender);
        requireNoWinningTicketDrawn();
        requirePenaltyPayment(msg.value);
        
        cancelCurrentLottery(msg.value);

        lock_end();
    }

    /// @notice Anyone can call this before a winning ticket is drawn to cancel the current lottery and refund everyone, but only if the contract is corrupt. There is no penalty fee in this case.
    function action_cancelCurrentLotteryCorrupt() external {
        lock_start();

        requireNoWinningTicketDrawn();
        requireCorruptContract();
        
        cancelCurrentLottery(0);

        lock_end();
    }

    /// @notice The operator can call this to withdraw an amount of the contract funds.
    /// @param value The amounts of contract funds to withdraw.
    function action_withdrawContractFunds(uint value) external {
        lock_start();

        requireOperatorAddress(msg.sender);

        withdrawContractFunds(msg.sender, value);

        lock_end();
    }

    /// @notice The operator can call this to withdraw all contract funds.
    function action_withdrawAllContractFunds() external {
        lock_start();

        requireOperatorAddress(msg.sender);

        withdrawAllContractFunds(msg.sender);

        lock_end();
    }

    /// @notice The owner can call this to make themselves the operator.
    function action_takeOperatorRole() external {
        lock_start();

        requireOwnerAddress(msg.sender);

        setOperatorAddress(msg.sender);

        lock_end();
    }

    /// @notice Anyone can call this to withdraw any claimable balance they have.
    function action_withdrawAddressClaimableBalance() external {
        lock_start();

        withdrawAddressClaimableBalance(msg.sender);

        lock_end();
    }

    /// @notice The operator can trigger a claimable balance withdraw for someone else.
    /// @param _address The address that the operator is triggering the claimable balance withdraw for.
    function action_withdrawOtherAddressClaimableBalance(address _address) external {
        lock_start();

        requireOperatorAddress(msg.sender);

        withdrawAddressClaimableBalance(_address);

        lock_end();
    }

    /// @notice Anyone can call this to withdraw a refund.
    /// @param _lotteryNumber The number of a lottery that was canceled.
    function action_withdrawAddressRefund(uint _lotteryNumber) external {
        lock_start();

        withdrawAddressRefund(_lotteryNumber, msg.sender);

        lock_end();
    }

    /// @notice The operator can trigger a refund withdraw for someone else.
    /// @param _lotteryNumber The number of a lottery that was canceled.
    /// @param _address The address that the operator is triggering the refund withdraw for.
    function action_withdrawOtherAddressRefund(uint _lotteryNumber, address _address) external {
        lock_start();

        requireOperatorAddress(msg.sender);

        withdrawAddressRefund(_lotteryNumber, _address);

        lock_end();
    }

    /// @notice The operator can withdraw all of one kind of token. Note that Chainlink is subject to a minimum reserve requirement.
    /// @param tokenAddress The address where the token's contract lives.
    function action_withdrawTokenBalance(address tokenAddress) external {
        lock_start();

        requireOperatorAddress(msg.sender);

        withdrawTokenBalance(tokenAddress, msg.sender);

        lock_end();
    }

    /// @notice The owner can transfer ownership to a new address.
    /// @param newOwnerAddress The new owner address.
    function set_ownerAddress(address newOwnerAddress) external {
        lock_start();

        requireOwnerAddress(msg.sender);

        setOwnerAddress(newOwnerAddress);

        lock_end();
    }

    /// @notice The operator can assign the operator role to a new address.
    /// @param newOperatorAddress The new operator address.
    function set_operatorAddress(address newOperatorAddress) external {
        lock_start();

        requireOperatorAddress(msg.sender);

        setOperatorAddress(newOperatorAddress);

        lock_end();
    }

    /// @notice The operator can change the total number of active blocks for the lottery. This change will go into effect starting from the next lottery.
    /// @param newLotteryActiveBlocks The new total number of active blocks for the lottery.
    function set_lotteryActiveBlocks(uint newLotteryActiveBlocks) external {
        lock_start();

        requireOperatorAddress(msg.sender);

        setLotteryActiveBlocks(newLotteryActiveBlocks);

        lock_end();
    }

    /// @notice The operator can change the ticket price of the lottery. This change will go into effect starting from the next lottery.
    /// @param newTicketPrice The new ticket price of the lottery.
    function set_ticketPrice(uint newTicketPrice) external {
        lock_start();

        requireOperatorAddress(msg.sender);

        setTicketPrice(newTicketPrice);

        lock_end();
    }
    
    /// @notice The owner can call this to get information about the internal state of the contract.
    function diagnostic_getInternalInfo1() external view returns (bool _lockFlag, bool _corruptContractFlag, uint _corruptContractBlockNumber, uint _lotteryNumber, uint _lotteryBlockNumberStart, uint _lotteryActiveBlocks, uint _currentLotteryActiveBlocks, address _ownerAddress, address _operatorAddress, uint _ticketPrice, uint _currentTicketPrice, uint _contractFunds) {
        requireOwnerAddress(msg.sender);

        return(lockFlag, corruptContractFlag, corruptContractBlockNumber, lotteryNumber, lotteryBlockNumberStart, lotteryActiveBlocks, currentLotteryActiveBlocks, ownerAddress, operatorAddress, ticketPrice, currentTicketPrice, contractFunds);
    }

    /// @notice The owner can call this to get information about the internal state of the contract.
    function diagnostic_getInternalInfo2() external view returns (uint _playerPrizePool, uint _bonusPrizePool, uint _claimableBalancePool, uint _refundPool, uint _currentTicketNumber, uint _chainlinkRetryCounter, bool _chainlinkRequestIdFlag, uint _chainlinkRequestIdBlockNumber, uint _chainlinkRequestIdLotteryNumber, uint _chainlinkRequestId, bool _winningTicketFlag, uint _winningTicket) {
        requireOwnerAddress(msg.sender);

        return(playerPrizePool, bonusPrizePool, claimableBalancePool, refundPool, currentTicketNumber, chainlinkRetryCounter, chainlinkRequestIdFlag, chainlinkRequestIdBlockNumber, chainlinkRequestIdLotteryNumber, chainlinkRequestId, winningTicketFlag, winningTicket);
    }

    /// @notice The owner can call this to unlock the contract.
    function failsafe_unlock() external {
        requireOwnerAddress(msg.sender);

        setLocked(false);
    }

    /// @notice The owner can call this to uncorrupt the contract. This should only be done if the currupt flag being set was a false positive.
    function failsafe_uncorrupt() external {
        requireOwnerAddress(msg.sender);

        setCorruptContract(false);
    }

    /// @notice The owner can call this to withdraw all Chainlink, including the minimum reserve. This can only be used if the contract is ready to be destroyed.
    function failsafe_withdrawAllChainlink() external {
        requireOwnerAddress(msg.sender);
        requireSelfDestructReady();

        withdrawAllChainlink(msg.sender);
    }

    /// @notice The owner can call this to destroy a corrupt contract.
    function failsafe_selfdestruct() external {
        requireOwnerAddress(msg.sender);
        requireSelfDestructReady();

        selfDestruct(msg.sender);
    }
}