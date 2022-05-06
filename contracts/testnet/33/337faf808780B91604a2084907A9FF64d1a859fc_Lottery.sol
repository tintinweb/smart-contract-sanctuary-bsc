/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

/**
 * @title Lottery
 * @dev Lottery game
 */
contract Lottery {

    struct Ticket {
        address payable owner;
        uint start;
        uint amount;
    }

    struct Winner {
        address owner;
        uint ticket;
    }

    address private owner;
    uint256 private minDeposit;
    uint256 private autoStartLimit;
    uint private commissionPercent;

    uint private gameId;
    uint private latestTicket;
    Ticket[] private tickets;
    mapping(uint => Winner) public results;

    uint private gameControlAllowedFor;


    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event DepositAdded(address owner, uint256 value, uint firstTicket, uint lastTicket);
    event MinDepositSet(uint256 value);
    event AutoStartLimitSet(uint256 value);
    event GameFinished(uint gameId, Winner winner, uint256 prize);
    
    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set initial parameters
     */
    constructor() {
        owner = msg.sender;
        minDeposit = 10000000000000000; // 0.01 bnb
        autoStartLimit = 50000000000000000; // 0.05 bnb
        commissionPercent = 10;
        
        emit OwnerSet(address(0), owner);

        // ??
        gameId = 0;
        resetGame();
    }

    function resetGame() private {
        gameId++;
        latestTicket = 1;
        delete tickets;
    }

    function startGame() public payable returns (bool) {

        require(gameControlAllowedFor == block.number, "You're not allowed to start game");

        // select winning ticket
        uint winningTicket = random(latestTicket - 1) + 1;

        Ticket memory playerTicket;

        uint256 prize = address(this).balance;
        bool payedOut = false;

        for (uint i = 0; i < tickets.length; i++) {
            playerTicket = tickets[i];
            if(winningTicket >= playerTicket.start && playerTicket.start + playerTicket.amount > winningTicket) {
                // pay reward excl. commission
                uint256 commission = prize / commissionPercent;
                bool result = playerTicket.owner.send(prize - commission);
                require(result, "Can't make payout for winner");
                result = payable(owner).send(commission);
                payedOut = true;
                break;
            }
        }

        require(payedOut, "Can't find winner");

        Winner memory winner = Winner(playerTicket.owner, winningTicket);
        emit GameFinished(gameId, winner, prize);
        results[gameId] = winner;

        resetGame();

        return true;
    }

    function random(uint maxValue) public view returns(uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));

        return (seed - ((seed / maxValue) * maxValue));
    }

    function checkAutoStart() private {
        if (address(this).balance >= autoStartLimit) {
            gameControlAllowedFor = block.number;
            startGame();
        }
    }


    /**
     * @dev Add deposit to current game
     */
    function deposit() public payable returns (bool) {
        require(msg.value >= minDeposit, "Deposit is too small");

        // create tickets
        uint startTicket = latestTicket;
        uint amount = msg.value / minDeposit;

        latestTicket = startTicket + amount;

        emit DepositAdded(msg.sender, msg.value, startTicket, latestTicket - 1);

        tickets.push(Ticket(
            payable(msg.sender),
            startTicket,
            amount
        ));


        // check auto-start conditions
        checkAutoStart();

        return true;
    }

    /**
     * @dev Manually launch lottery
     */
    function launchGame() public isOwner {
        gameControlAllowedFor = block.number;
        startGame();
    }


    /**
     * @dev Set minimum deposit
     * @param amount minimum amount to deposit
     */
    function setMinDeposit(uint256 amount) public isOwner {
        emit MinDepositSet(amount);
        minDeposit = amount;
    }


    /**
     * @dev Set minimum amount to start lottery
     * @param amount amount to start game
     */
    function setAutoStartLimit(uint256 amount) public isOwner {
        emit AutoStartLimitSet(amount);
        autoStartLimit = amount;
    }

    /**
     * @dev Set new contract owner
     * @param newOwner address of new owner
     */
    function setOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }


    /**
     * @dev Return minimum amount to start lottery
     * @return value of 'autoStartLimit'
     */
    function getMinDeposit() external view returns (uint256){
        return minDeposit;
    }

    /**
     * @dev Return minimum amount to start lottery
     * @return value of 'autoStartLimit'
     */
    function getAutoStart() external view returns (uint256){
        return autoStartLimit;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}