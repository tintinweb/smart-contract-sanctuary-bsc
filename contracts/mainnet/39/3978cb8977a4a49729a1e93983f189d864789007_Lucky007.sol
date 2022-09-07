// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

/// @title Lucky007
/// @author This has been forked from FreezyEx ( https://github.com/FreezyEx )
/// @notice This contract is a lottery game based on PRNG. 
///         The admin have to generate a random string and hash it offchain for each lottery.
///         This hash is set at ther start of the lottery to guarantee a fair game.
///         To be able to pick a winner, the admin must provide the random string to the contract to
///         prove the fairness of the game.

contract Lucky007 {

    mapping(uint256 => WinnerInfo) lotteryWinner;
    mapping(uint256 => LotteryInfo) lotteryInfo;
    mapping(address => mapping(uint256 => uint256)) playerTickets;
    
    mapping(address => bool) public isAdmin;

    struct WinnerInfo {
        address winner;
        uint256 payout;
    }

    struct LotteryInfo {
        uint256 price;
        uint256 numOfTickets;
        bytes32 randomHash;
    }

    address[] tickets;

    address public feeRecipient;
    address public manager;
    uint256 public immutable FEE;
    uint256 public immutable MAX_TICKETS;
    uint256 public lotteryId;
    uint256 public totalPayout;

    bool public refundAllowed;
    uint256 public refundAmount;

    modifier isManager() {
        require(msg.sender == manager);
        _;
    }

    event LotteryCreated(uint256 lotteryId, uint256 price);
    event TicketsBought(address player, uint256 numOfTicket);
    event WinnerPicked(uint256 lotteryId, address indexed winner, uint256 payout);
    event RefundEmitted(address player, uint256 refunedAmount);
    event EmergencyCalled();

    constructor(address _feeRecipient) {
        isAdmin[msg.sender] = true;
        manager = msg.sender;
        feeRecipient = _feeRecipient;
        FEE = 20;
        MAX_TICKETS = 100;
        lotteryId = 1;
    }

    function sendBNB(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /// @notice Create a new lottery
    /// @param randomHash The hash of a random string (you can use https://emn178.github.io/online-tools/keccak_256.html )
    /// @param ticketPrice The price of a ticket
    function startLottery(bytes32 randomHash, uint256 ticketPrice) external {
        require(isAdmin[msg.sender], "You are not authorized to start a lottery");
        require(!refundAllowed, "Emergency refund is active");
        require(lotteryInfo[lotteryId].numOfTickets == 0, "Lottery already started");
        require(ticketPrice > 0, "Ticket price must be greater than 0");
        require(feeRecipient != address(0), "Fee recipient must be set");
        require(lotteryInfo[lotteryId].numOfTickets == 0, "Lottery already started");
        require(randomHash != 0, "Winner hash must be set");
        lotteryInfo[lotteryId] = LotteryInfo(ticketPrice, 0, randomHash);
        emit LotteryCreated(lotteryId, ticketPrice);
    }

    /// @notice Buy tickets for the current lottery
    /// @param ticketsNumber The number of tickets to buy
    function buyTicket(uint256 ticketsNumber) external payable {
        require(!refundAllowed, "Emergency refund is active");
        require(msg.sender.code.length == 0, "Address must be a EOA");
        require(lotteryInfo[lotteryId].price > 0, "Lottery not started");
        require(ticketsNumber > 0, "Number of tickets must be greater than 0");
        require(msg.value == lotteryInfo[lotteryId].price * ticketsNumber, "Ticket price not met");
        require(MAX_TICKETS >= lotteryInfo[lotteryId].numOfTickets + ticketsNumber, "Too many tickets");
        lotteryInfo[lotteryId].numOfTickets += ticketsNumber;
        playerTickets[msg.sender][lotteryId] += ticketsNumber;
        for(uint256 i; i < ticketsNumber; ){
            tickets.push(msg.sender);
            unchecked{
                ++i;
            }
        }
        emit TicketsBought(msg.sender, ticketsNumber);
    }

    /// @notice Pick a winner for the current lottery
    /// @param seed The random string used to compute the hash at the start
    /// @dev VRF is is not necessary since the extraction is handled by the staff
    function pickWinner(string calldata seed) external{
        require(isAdmin[msg.sender] == true, "You are not admin");
        require(lotteryInfo[lotteryId].numOfTickets > 0, "No winner to pick");
        require(lotteryInfo[lotteryId].randomHash ==  keccak256(abi.encodePacked(seed)), "Seed is not correct");
        require(lotteryInfo[lotteryId].price * lotteryInfo[lotteryId].numOfTickets <= address(this).balance, "Missing funds");
        uint256 winnerIndex = random(seed) % tickets.length;
        uint256 payout = lotteryInfo[lotteryId].price * lotteryInfo[lotteryId].numOfTickets;
        uint256 feeAmount = payout * FEE / 100;
        lotteryWinner[lotteryId].winner = tickets[winnerIndex];
        lotteryWinner[lotteryId].payout = payout - feeAmount;
        totalPayout += (payout - feeAmount);
        tickets = new address[](0);
        sendBNB(payable(lotteryWinner[lotteryId].winner), payout - feeAmount);
        sendBNB(payable(feeRecipient), feeAmount);
        emit WinnerPicked(lotteryId, lotteryWinner[lotteryId].winner, payout - feeAmount);
        lotteryId++;
    }

    function random(string calldata seed) internal view returns(uint256){
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, seed)));
    }

    function emergency() external {
        require(isAdmin[msg.sender] == true, "You are not admin");
        require(!refundAllowed, "Emergency refund is active");
        require(lotteryInfo[lotteryId].numOfTickets > 0, "No user to refund");
        refundAllowed = true;
        refundAmount = lotteryInfo[lotteryId].price;
        delete lotteryInfo[lotteryId];
        emit EmergencyCalled();
    }

    function askRefund() external {
        require(refundAllowed == true, "Refund not allowed");
        require(playerTickets[msg.sender][lotteryId] > 0, "No ticket to refund");
        uint256 refund = playerTickets[msg.sender][lotteryId] * refundAmount;
        playerTickets[msg.sender][lotteryId] = 0;
        sendBNB(payable(msg.sender), refund);
        emit RefundEmitted(msg.sender, refund);
    }

    function setManager(address _manager) external isManager {
        manager = _manager;
    }

    function setAdmin(address _admin, bool _isAdmin) external isManager {
        isAdmin[_admin] = _isAdmin;
    }

    function setMultiAdmin(address[] calldata _admins, bool _isAdmin) external isManager {
        for(uint256 i; i < _admins.length; ){
            isAdmin[_admins[i]] = _isAdmin;
            unchecked{
                ++i;
            }
        }
    }

    function setFeeRecipient(address _feeRecipient) external isManager {
        feeRecipient = _feeRecipient;
    }

    function getTicketsBought() external view returns(address[] memory){
        return tickets;
    }

    function getPlayerTicketsPerLottery(address player, uint256 id) external view returns(uint256){
        return playerTickets[player][id];
    }

    function getPlayerAtIndex(uint256 index) external view returns(address){
        return tickets[index];
    }

    function getLotteryInfo(uint256 _lotteryId) external view returns (LotteryInfo memory) {
        return lotteryInfo[_lotteryId];
    }

    function getLotteryWinnerById(uint256 _lotteryId) public view returns (WinnerInfo memory) {
        return lotteryWinner[_lotteryId];
    }
}