/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

/**
    ***********************************************************
    * Copyright (c) Avara Dev. 2022. (Telegram: @avara_cc)  *
    ***********************************************************

     ▄▄▄·  ▌ ▐· ▄▄▄· ▄▄▄   ▄▄▄·
    ▐█ ▀█ ▪█·█▌▐█ ▀█ ▀▄ █·▐█ ▀█
    ▄█▀▀█ ▐█▐█•▄█▀▀█ ▐▀▀▄ ▄█▀▀█
    ▐█ ▪▐▌ ███ ▐█ ▪▐▌▐█•█▌▐█ ▪▐▌
     ▀  ▀ . ▀   ▀  ▀ .▀  ▀ ▀  ▀  - Binance Smart Chain

    Avara - Always Vivid, Always Rising Above
    https://avara.cc/
    https://github.com/avara-cc
    https://github.com/avara-cc/Avara/wiki
*/

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.4;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data.
 */
abstract contract Context {
    /**
     * @dev Returns the value of the msg.sender variable.
     */
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @dev Returns the value of the msg.data variable.
     */
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
abstract contract Ownable is Context {
    // Current owner address
    address private _owner;
    // Previous owner address
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the given address as the initial owner.
     */
    constructor(address initOwner) {
        _setOwner(initOwner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the previous owner.
     */
    function previousOwner() public view virtual returns (address) {
        return _previousOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: The caller is not the owner!");
        _;
    }

    /**
     * @dev Leaves the contract without an owner. It won't be possible to call `onlyOwner` functions anymore.
     * Can only be called by the current owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: The new owner is now, the zero address!");
        _setOwner(newOwner);
    }

    /**
     * @dev Sets the owner of the token to the given address.
     *
     * Emits an {OwnershipTransferred} event.
     */
    function _setOwner(address newOwner) private {
        _previousOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(_previousOwner, newOwner);
    }
}

contract AvaraLottery is Context, Ownable {
    event Received(address sender, uint value);
    event FallBack(address sender, uint value);

    /**
    * @dev Executed on a call to the contract with empty call data.
    */
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /**
    * @dev Executed on a call to the contract that does not match any of the contract functions.
    */
    fallback() external payable {
        emit FallBack(msg.sender, msg.value);
    }

    /**
    * @dev Information about the lottery.
    */
    struct LotteryMeta {
        bool endTsEnabled;
        uint256 endTs;

        bool startTsEnabled;
        uint256 startTs;

        bool ticketNumberLimitEnabled;
        uint256 ticketNumberLimit;

        uint256 ticketPriceInWei;
        uint256 numberOfWinners;

        bool multipleTicketsAllowed;

        string lotteryName;
        string lotteryDescription;
    }

    struct Ticket {
        address ticketOwner;
        bytes32 ticketId;
    }

    event LotteryCreated(address indexed lotteryOwner, LotteryMeta metaData);
    event LotteryEnded(uint256 timestamp);
    event LotteryResults(Ticket[] lotteryWinnerTickets);
    event TicketClaimed(address indexed ticketOwner, bytes32 ticketId);
    event TicketsBought(address indexed buyer, uint256 numberOfTickets, uint256 totalValue);
    event WinnerDrawn(address indexed winnerAddress, bytes32 ticketId);

    Ticket[] public tickets;
    Ticket[] public winnerTickets;

    bool public isLotteryEnded;

    LotteryMeta private lotteryMeta;
    uint private _ticketCounter;
    uint private _participantCounter;
    uint private _randNonce;

    constructor (address lotteryOwner, LotteryMeta memory metaData) Ownable(lotteryOwner) {
        require(!metaData.ticketNumberLimitEnabled || metaData.ticketNumberLimit > 0, "Invalid ticket number limit!");
        require(!metaData.endTsEnabled || metaData.endTs > 0 && metaData.endTs > block.timestamp, "Invalid end ts!");
        require(!metaData.startTsEnabled || metaData.startTs > 0, "Invalid start ts!");
        lotteryMeta = metaData;
        emit LotteryCreated(lotteryOwner, metaData);
    }

    /**
    * @dev Creates an unique identifier for a Ticket.
    */
    function createTicketId() internal returns (bytes32) {
        _ticketCounter++;
        return keccak256(abi.encodePacked(_ticketCounter));
    }

    /**
    * @dev A function used to buy tickets.
    */
    function buyTickets(uint256 numberOfTickets) public payable {
        require(!isLotteryEnded, "The Lottery has already ended!");
        require(!lotteryMeta.startTsEnabled || block.timestamp >= lotteryMeta.startTs, "You cannot buy tickets until the Lottery Start Time!");
        require(!lotteryMeta.endTsEnabled || block.timestamp <= lotteryMeta.endTs || tickets.length < lotteryMeta.numberOfWinners, "You cannot buy tickets after the Lottery End Time!");
        require(!lotteryMeta.ticketNumberLimitEnabled || (tickets.length + numberOfTickets) <= lotteryMeta.ticketNumberLimit, "The Lottery either ran out of buyable tickets or you are trying to buy too many tickets!");

        uint256 totalPrice = numberOfTickets * lotteryMeta.ticketPriceInWei;
        require(msg.value >= totalPrice, "The message value should be more or equal to the total price! (The overhead is returned to you.)");

        bool hasTicket = false;

        for (uint256 i = 0; i < tickets.length; i++) {
            if (tickets[i].ticketOwner == _msgSender()) {
                hasTicket = true;
            }
        }

        require(lotteryMeta.multipleTicketsAllowed || !hasTicket, "You have already bought a ticket! (Only one ticket allowed per address!)");

        if (!hasTicket) {
            _participantCounter++;
        }

        if (msg.value > totalPrice) {
            payable(_msgSender()).transfer(msg.value - totalPrice);
        }

        for (uint256 i = 0; i < numberOfTickets; i++) {
            Ticket memory ticket;
            ticket.ticketOwner = _msgSender();
            ticket.ticketId = createTicketId();

            tickets.push(ticket);

            emit TicketClaimed(ticket.ticketOwner, ticket.ticketId);
        }

        emit TicketsBought(_msgSender(), numberOfTickets, totalPrice);
    }

    /**
    * @dev Retrieves the price of one Lottery Ticket.
    */
    function ticketPriceInWei() external view returns (uint256) {
        return lotteryMeta.ticketPriceInWei;
    }

    /**
    * @dev Retrieves the number of winners that is going to be drawn when the Lottery ends.
    */
    function numberOfPossibleWinners() external view returns (uint256) {
        return lotteryMeta.numberOfWinners;
    }

    /**
    * @dev Retrieves the name of the Lottery.
    */
    function lotteryName() external view returns (string memory) {
        return lotteryMeta.lotteryName;
    }

    /**
    * @dev Retrieves the description of the Lottery.
    */
    function lotteryDescription() external view returns (string memory) {
        return lotteryMeta.lotteryDescription;
    }

    /**
    * @dev Retrieves the start time of the Lottery in Epoch Unix Timestamp format. (if any)
    */
    function startTime() external view returns (uint256) {
        require(lotteryMeta.startTsEnabled, "The lottery does not have a start time! You can buy tickets anytime while the Lottery is running!");
        return lotteryMeta.startTs;
    }

    /**
    * @dev Retrieves the end time of the Lottery in Epoch Unix Timestamp format. (if any)
    */
    function endTime() external view returns (uint256) {
        require(lotteryMeta.endTsEnabled, "The lottery does not have an end time! It will be running until it is concluded by the owner.");
        return lotteryMeta.endTs;
    }

    /**
    * @dev Retrieves the maximum amount of tickets. (if any)
    */
    function ticketNumberLimit() external view returns (uint256) {
        require(lotteryMeta.ticketNumberLimitEnabled, "The number of buyable tickets are not limited!");
        return lotteryMeta.ticketNumberLimit;
    }

    /**
    * @dev Retrieves true if the checked address is a winner.
    */
    function isAddressWinner(address a) external view returns (bool) {
        require(isLotteryEnded, "The Lottery is still in progress!");
        for (uint256 i = 0; i < winnerTickets.length; i++) {
            if (winnerTickets[i].ticketOwner == a) {
                return true;
            }
        }
        return false;
    }

    /**
    * @dev Retrieves the winner tickets.
    */
    function getWinners() external view returns (Ticket[] memory) {
        require(isLotteryEnded, "The Lottery is still in progress!");
        return winnerTickets;
    }

    /**
    * @dev Retrieves the number of tickets bought to date.
    */
    function getNumberOfTickets() external view returns (uint256) {
        return _ticketCounter;
    }

    /**
    * @dev Retrieves the number of participants to date.
    */
    function getNumberOfParticipants() external view returns (uint256) {
        return _participantCounter;
    }

    /**
    * @dev A function used to conclude the lottery and draw the winners.
    */
    function concludeLottery() external onlyOwner {
        require(tickets.length >= lotteryMeta.numberOfWinners, "Not enough tickets!");
        require(!lotteryMeta.endTsEnabled || block.timestamp >= lotteryMeta.endTs, "The Lottery is still in progress!");
        isLotteryEnded = true;

        for (uint256 i = 0; i < lotteryMeta.numberOfWinners; i++) {
            uint256 idx = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _randNonce))) % tickets.length;
            _randNonce++;

            Ticket memory winnerTicket = tickets[idx];

            winnerTickets.push(winnerTicket);

            tickets[idx] = tickets[tickets.length - 1];
            delete tickets[tickets.length - 1];
            tickets.pop();

            emit WinnerDrawn(winnerTicket.ticketOwner, winnerTicket.ticketId);
        }

        emit LotteryEnded(block.timestamp);
        emit LotteryResults(winnerTickets);
    }

    /**
    * @dev A function used to retrieve the lottery reserves.
    */
    function getReserves() external onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }
}