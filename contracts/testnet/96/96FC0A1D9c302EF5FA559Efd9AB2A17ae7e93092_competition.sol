/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: GPL-3.0

/*
PR: 
1. tambah entry per akun
2. pakai stab coin
3. program diskon
4. auto send saat kuota terpenuhi
5. sediakan pool platform fee
6. 

*/
pragma solidity >=0.7.0 <0.9.0;

contract competition {
    uint256 public constant ticketPrice = 0.1 ether;
    uint256 public constant maxTickets = 3; // maximum tickets per competition
    uint256 public constant PlatformFee = 0.0005 ether; // 0.5% platform fee 
	uint256 public constant OwnerFee = 0.002 ether; // 2% owner fee 
    uint256 public constant duration = 3 minutes; // competition duration

    uint256 public expiration; // Timeout in case That the competition was not carried out.
    address payable public competitionOperator; // the crator of the competition
    uint256 public PlatformTotalFee = 0; // the total cSommission balance
	uint256 public OwnerTotalFee = 0; // the total cSommission balance
    address public lastWinner; // the last winner of the competitionS
    uint256 public lastWinnerAmount; // the last winner amount of the competition

    address payable public PoolPlatformFee =
        payable(address(0x7FF9aE5F8ab0af2b6Bee60be9a4EB5f48604323D));


    mapping(address => uint256) winnings; // maps the winners to there winnings
    address[] public tickets; //array of purchased Tickets

    // modifier to check if caller is the competition operator
    modifier isOperator() {
        require(
            (msg.sender == competitionOperator),
            "Caller is not the competition operator"
        );
        _;
    }

    // modifier to check if caller is a winner
    modifier isWinner() {
        require(IsWinner(), "Caller is not a winner");
        _;
    }

    constructor() {
        competitionOperator = payable (msg.sender);
        expiration = block.timestamp + duration;
    }

    // return all the tickets
    function getTickets() public view returns (address[] memory) {
        return tickets;
    }

    function BuyTickets() public payable {
        require(msg.value >= ticketPrice, "Not enough eth available.");
        uint256 numOfTicketsToBuy = msg.value / ticketPrice;

        require(
            numOfTicketsToBuy <= RemainingTickets(),
            "Not enough tickets available."
        );

        require(
            block.timestamp <= expiration,
            "Competition is expired."
        );

        require(msg.sender!= competitionOperator , 'Landlord cannot buy Ticket');

        for (uint256 i = 0; i < numOfTicketsToBuy; i++) {
            tickets.push(msg.sender);
        }
    }

    function DrawWinnerTicket() public isOperator {
        require(tickets.length > 0, "No tickets were purchased");

        bytes32 blockHash = blockhash(block.number - tickets.length);
        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(block.timestamp, blockHash))
        );
        uint256 winningTicket = randomNumber % tickets.length;

        address winner = tickets[winningTicket];

        lastWinner = winner;
        winnings[winner] += (tickets.length * (ticketPrice - PlatformFee - OwnerFee));
        lastWinnerAmount = winnings[winner];
        PlatformTotalFee += (tickets.length * PlatformFee);
        OwnerTotalFee += (tickets.length * OwnerFee);		
        delete tickets;
        expiration = block.timestamp + duration;

    }

    function checkWinningsAmountForPlayer() public view returns (uint256) {
        address winner = msg.sender;

        return winnings[winner];
    }

    function WithdrawWinnings() public isWinner {
        address payable winner = payable(msg.sender);

        uint256 reward2Transfer = winnings[winner];
        winnings[winner] = 0;

        winner.transfer(reward2Transfer);

        uint256 Platform2Transfer = PlatformTotalFee;
        PlatformTotalFee = 0;

        PoolPlatformFee.transfer(Platform2Transfer);

        uint256 Owner2Transfer = OwnerTotalFee;
        OwnerTotalFee = 0;
        competitionOperator.transfer(Owner2Transfer);


    }

    function RefundAll() public {
        require(block.timestamp >= expiration, "the competition not expired yet");
        require(tickets.length < maxTickets, "competition met condition");

        for (uint256 i = 0; i < tickets.length; i++) {
            address payable to = payable(tickets[i]);
            tickets[i] = address(0);
            to.transfer(ticketPrice);
        }
        delete tickets;
    }

    function IsWinner() public view returns (bool) {
        return winnings[msg.sender] > 0;
    }

    function CurrentWinningReward() public view returns (uint256) {
        return tickets.length * ticketPrice;
    }

    function RemainingTickets() public view returns (uint256) {
        return maxTickets - tickets.length;
    }

    //delete this nanti
    function withdraw()  public {
        payable(msg.sender).transfer(address(this).balance);
    }


}