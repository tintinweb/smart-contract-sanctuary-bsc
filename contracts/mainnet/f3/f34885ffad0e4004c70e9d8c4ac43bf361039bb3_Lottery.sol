/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;


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

    function subz(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b >= a) {
            return 0;
        }
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract Lottery{
    using SafeMath for uint256;

    uint256 constant public PERCENTS_DIVIDER = 1000;
    uint256 constant public WINNER_SHARE = 600;
	uint256 constant public AIR_NETWORK_SHARE = 200;	
	uint256 public constant TICKET_PRICE = 0.05 ether;

    uint256 public LOTTERY_STEP = 1 days; 
    uint256 public MAX_TICKETS = 100;
    uint256 public LOTTERY_START_TIME;
    uint256 public roundId = 1;
    uint256 public totalPool = 0;
    uint256 public totalTickets = 0;

    address payable AirNetwork;

    struct User {
        uint256 totalTickets;
        uint256 totalReward;
        uint256 totalWins;
    }

    mapping (address => User) public users;
    mapping(uint256 => mapping(uint256 => address)) public ticketsUsers;
    mapping(uint256 => mapping(address => uint256)) public usersTickets;
    
    event Winner(address indexed winnerAddress, uint256 winnerPrize, uint256 roundId, uint256 totalPool, uint256 totalTickets, uint256 time);
    event BuyTicket(address indexed user, uint256 roundId, uint256 totalTickets, uint256 time);

    constructor(address payable airNetworkAddr, uint256 startDate){
        AirNetwork = airNetworkAddr;
        if(startDate > 0){
            LOTTERY_START_TIME = startDate;
        }
        else{
            LOTTERY_START_TIME = block.timestamp;
        }
    }

    function buyTicket(uint256 cnt) public payable {
        require(cnt <= MAX_TICKETS, "max ticket numbers is 100");
        require(block.timestamp > LOTTERY_START_TIME, "round does not start yet");
        require(cnt.mul(TICKET_PRICE) == msg.value, "wrong payment amount");

        for(uint256 i=0; i < cnt; i++){
            ticketsUsers[roundId][totalTickets+i] = msg.sender;
        }
        usersTickets[roundId][msg.sender] += cnt;
        totalTickets += cnt;
        totalPool += msg.value;
        users[msg.sender].totalTickets += cnt;

        emit BuyTicket(msg.sender, roundId, cnt, block.timestamp);

        if(LOTTERY_START_TIME.add(LOTTERY_STEP) < block.timestamp){
            draw();
        }       
    }
    
    function draw() public {
        require(LOTTERY_START_TIME.add(LOTTERY_STEP) < block.timestamp , "round is not finish yet" );

        if(totalTickets>0){

            uint256 winnerPrize   = totalPool.mul(WINNER_SHARE).div(PERCENTS_DIVIDER);
            uint256 airNetworkShare = totalPool.mul(AIR_NETWORK_SHARE).div(PERCENTS_DIVIDER);

            uint256 random = (_getRandom()).mod(totalTickets); 
            address winnerAddress = ticketsUsers[roundId][random];
            users[winnerAddress].totalWins = users[winnerAddress].totalWins.add(1);
            users[winnerAddress].totalReward = users[winnerAddress].totalReward.add(winnerPrize);

            payable(winnerAddress).transfer(winnerPrize);
            AirNetwork.transfer(airNetworkShare);
        
            emit Winner(winnerAddress, winnerPrize, roundId, totalPool, totalTickets, block.timestamp);
        }
        else{
            emit Winner(address(0), 0, roundId, totalPool, totalTickets, block.timestamp);
        }
        
        // Reset Round
        totalPool = address(this).balance;
        roundId = roundId.add(1);
        totalTickets = 0;
        LOTTERY_START_TIME = block.timestamp;
    }
    
    function _getRandom() private view returns(uint256){
        return uint256(keccak256(abi.encode(block.timestamp,totalTickets,block.difficulty, address(this).balance)));
    }
    
    function getUserTickets(address _userAddress, uint256 round) public view returns(uint256) {
         return usersTickets[round][_userAddress];
    }
    
    function getRoundStats() public view returns(uint256, uint256, uint256, uint256) {
        return (
            roundId,
            LOTTERY_START_TIME.add(LOTTERY_STEP),
            totalPool,
            totalTickets
            );
    }
    
}