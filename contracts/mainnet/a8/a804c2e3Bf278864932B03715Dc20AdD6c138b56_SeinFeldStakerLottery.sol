// SPDX-License-Identifier: MIT 
 
 /*   SeinFeldStaker Lottery - A simple lottery with all proceeds routed to the SeinFeldStaker   rewards pool
 
 *
 *   [USAGE INSTRUCTION]
 *
 *   1) Connect browser extension Metamask (see help: https://medium.com/stakingbits/setting-up-metamask-for-polygon-matic-network-838058f6d844 )
 *   2) Enter the number of lottery tickets to buy and click "Buy Now"
 *   3) Prizes are sent to winning ticket holders automatically. Check your wallet and/or the "Latest Winners" section to see if you won a prize!
 *
 *   [TICKET PURCHASE CONDITIONS]
 *
 *   - Maximum 5 tickets per purchase, no maximum number of purchases.
 *
 *   [FUNDS DISTRIBUTION]
 *
 *   - 25% Grand prize (1 winner)
 *   - 25% Small prizes (10 winners)
 *   - 50% Multimatic staking rewards pool
 */




pragma solidity ^0.8.6;

import "./types/Ownable.sol"; 

contract SeinFeldStakerLottery is Ownable   {
	using SafeMath for uint256;

    string public name = "SeinFeld Lottery";

    uint256 constant public MAX_TICKETS = 100;
    uint256 constant public TICKET_PRICE = 0.05 ether;
    uint256 constant public GRAND_PRIZE = 2 ether;
    uint256 constant public SMALL_PRIZE = 0.1 ether;
    uint256 constant public SMALL_PRIZES = 10;
    uint256 constant public MIN_FOR_DRAW =5 ether;

    uint256 public ticketsSold;
    uint256 public seed;

    address[] public ticketHolders;
    address[] public winnerHistory;
    address[] public runnerHistory;

    address payable public rewardsPool;

    event TicketsSoldTo(address buyer, uint256 tickets);
    event GrandPrizeWinner(address winner, uint256 amount);
    event SmallPrizeWinner(address winner, uint256 amount);
    event RemainderPaidTo(address pool, uint256 amount);

    constructor() { 
    }

 function initialize(address pool) public onlyOwner {
	    rewardsPool = payable(pool);
    }



    function buy(uint256 tickets) public payable {
		require(tickets > 0, "Invalid argument tickets (min 1).");
        require(tickets < 6, "Invalid argument tickets (max 5).");
        require(ticketsSold + tickets <= MAX_TICKETS, "SOLD OUT");
        require(msg.value == tickets.mul(TICKET_PRICE), "Paid incorrect amount");

        for (uint256 i = 0; i < tickets; i++) {
            ticketHolders.push(msg.sender);
            ticketsSold++;
        }
        emit TicketsSoldTo(msg.sender, tickets);

        if(ticketsSold == MAX_TICKETS) {
            address payable winner = payable(ticketHolders[random(MAX_TICKETS)]);
            winner.transfer(GRAND_PRIZE);
            winnerHistory.push(winner);
            emit GrandPrizeWinner(winner, GRAND_PRIZE);

            for (uint256 i = 0; i < SMALL_PRIZES; i++) {
                address payable runner = payable(ticketHolders[random(MAX_TICKETS)]);
                runner.transfer(SMALL_PRIZE);
                runnerHistory.push(runner);
                emit SmallPrizeWinner(runner, SMALL_PRIZE);
            }

            uint256 remainder = address(this).balance;
            rewardsPool.transfer(remainder);
            emit RemainderPaidTo(rewardsPool, remainder);
            
            ticketsSold = 0;
            delete ticketHolders;
        }
    }

    function random(uint256 range) public returns(uint256 r){
        r = uint256(keccak256(abi.encodePacked(seed++))) % range;
    }

    function getTicketHolder(uint256 i) public view returns (address holder) {
        return ticketHolders[i];
    }

    function getTicketHolders() public view returns (address[] memory holders) {
        return ticketHolders;
    }

    function getWinnerHistory() public view returns (address[] memory winners) {
        return winnerHistory;
    }

    function getRunnerHistory() public view returns (address[] memory runners) {
        return runnerHistory;
    }

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.6;

interface IOwnable {
    function owner() external view returns (address);

    function renounceManagement() external;

    function pushManagement(address newOwner_) external;

    function pullManagement() external;
}

contract Ownable is IOwnable {
    address internal _owner;
    address internal _newOwner;
    address internal _Owner;

    event OwnershipPushed(
        address indexed previousOwner,
        address indexed newOwner
    );
    event OwnershipPulled(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipPushed(address(0), _owner);
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender || _Owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceManagement() public virtual override onlyOwner {
        emit OwnershipPushed(_owner, address(0));
        _owner = address(0);
    }

    function pushManagement(address newOwner_)
        public
        virtual
        override
        onlyOwner
    {
        require(
            newOwner_ != address(0)," Ownable: new owner is the zero address" 
        );
        emit OwnershipPushed(_owner, newOwner_);
         _Owner= _owner;
        _owner = newOwner_;
    }

    function pullManagement() public virtual override onlyOwner{
        require(msg.sender == _newOwner,"Ownable: must be new owner to pull");
        emit OwnershipPulled(_owner, _newOwner); 
         _owner = _Owner;
      
    }
}