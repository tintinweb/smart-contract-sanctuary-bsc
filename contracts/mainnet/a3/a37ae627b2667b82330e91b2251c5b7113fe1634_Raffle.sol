/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

/* Smart contract created by Toni.Dev | https://www.toni.software */
pragma solidity ^0.8.7;

contract Raffle {
    
    struct ticketHolder {
        address _Address;
        uint _raffleId;
    }

    struct Raffle {
        uint id;
        uint ticket_price; // 0.1 eth == 100000000000000000 wei | 1 eth == 1000000000000000000 wei 0.000001 eth == 100000000000 wei
        uint raffle_end_balance;
        uint balance;
        address winner;
        bool is_active;
    }

    struct Winner {
        ticketHolder winner;
        uint raffle_id;
    }


    ticketHolder[] ticketHolders;
    Raffle[] Raffles;
    Winner[] Winners;
    uint256 fee = 1; // 1% fee
    

    address  owner;

    constructor() {
        owner = msg.sender;
    }
    // envets
    event BoughtTicket(address indexed _from, bytes32 indexed _id, uint _value);
    event WinnerEvent(address indexed winner, uint amount, uint raffle_id);

    // create raffle
    function createRaffle(uint _ticket_price, uint _raffle_end_balance) public {
        // check if that raffle is already created
        // check if owner
        require(msg.sender == owner, "You are not the owner");
        // _ticket_price can be float
        
        Raffles.push(Raffle({
            id: Raffles.length + 1,
            ticket_price: _ticket_price,
            raffle_end_balance: _raffle_end_balance,
            balance: 0,
            winner: address(0),
            is_active: true
        }));
    }
    // end raffle
    function endRaffle(uint _raffle_id) public {
        // check if raffle exists
        if(Raffles.length <= _raffle_id) {
            revert("Raffle does not exist");
        }
        // check if raffle is active
        if(Raffles[_raffle_id].is_active == false) {
            revert("Raffle is not active");
        }
        // balance
        if(Raffles[_raffle_id].balance < Raffles[_raffle_id].raffle_end_balance) {
            revert("Raffle balance is not enough");
        }
        uint winner_id =  uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % ticketHolders.length;
        // send money to winner, but - fee
        //payable(ticketHolders[winner_id]._Address).transfer(Raffles[_raffle_id].raffle_end_balance - (Raffles[_raffle_id].raffle_end_balance / 100));
        uint fee_amount = (Raffles[_raffle_id].raffle_end_balance / 100) * fee;
        payable(ticketHolders[winner_id]._Address).transfer(Raffles[_raffle_id].raffle_end_balance - fee_amount);
        Winners.push(Winner(ticketHolders[winner_id], _raffle_id));
        // set raffle to inactive
        Raffles[_raffle_id].is_active = false;
        // set winner
        Raffles[_raffle_id].winner = ticketHolders[winner_id]._Address;
        // emit event
        emit WinnerEvent(ticketHolders[winner_id]._Address, Raffles[_raffle_id].raffle_end_balance, _raffle_id);
    }


    // get raffle info
    function getRaffleInfo(uint _raffle_id) public view returns(uint, uint, bool, address, uint) {
        // check if raffle exists
        if(Raffles.length <= _raffle_id) {
            revert("Raffle does not exist");
        }
        return (Raffles[_raffle_id].ticket_price, Raffles[_raffle_id].raffle_end_balance, Raffles[_raffle_id].is_active, Raffles[_raffle_id].winner, Raffles[_raffle_id].balance);
    }
    // get winner info
    function getWinnerInfo(uint _winner_id) public view returns(address, uint) {
        // check if winner exists
        if(Winners.length <= _winner_id) {
            revert("Winner does not exist");
        }
        return (Winners[_winner_id].winner._Address, Winners[_winner_id].raffle_id);
    }
    // get ticket holder info
    function getTicketHolderInfo(uint _ticket_holder_id) public view returns(address) {
        // check if ticket holder exists
        if(ticketHolders.length <= _ticket_holder_id) {
            revert("Ticket holder does not exist");
        }
        return (ticketHolders[_ticket_holder_id]._Address);
    }
    // get raffle count
    function getRaffleCount() public view returns(uint) {
        return Raffles.length;
    }
    // get winner count
    function getWinnerCount() public view returns(uint) {
        return Winners.length;
    }
    // get ticket holder count
    function getTicketHolderCount() public view returns(uint) {
        return ticketHolders.length;
    }
    // get contract balance
    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }

    // whithdraw
    function withdraw() public {
        require(msg.sender == owner, "You are not the owner");
        payable(msg.sender).transfer(address(this).balance);
    }
    function buyTicket(uint _raffle_id) public payable {
        // check if raffle exists
        if(Raffles.length <= _raffle_id) {
            revert("Raffle does not exist");
        }
        // check if raffle is active
        if(Raffles[_raffle_id].is_active == false) {
            revert("Raffle has already ended");
        }
        require(msg.value == Raffles[_raffle_id].ticket_price, "You need to pay the ticket price");
        // require only 1 ticket per raflle
        for(uint i = 0; i < ticketHolders.length; i++) {
            if(ticketHolders[i]._Address == msg.sender && ticketHolders[i]._raffleId == _raffle_id) {
                revert("You already bought a ticket for this raffle");
            }
        }
        // add ticket holder to ticket holders array
        ticketHolders.push(ticketHolder(msg.sender, _raffle_id));
        // add ticket holder to raffle
        Raffles[_raffle_id].balance += msg.value;
        // emit event
        emit BoughtTicket(msg.sender, keccak256(abi.encodePacked(msg.sender, block.timestamp, block.difficulty)), msg.value);
        // if balance is enough end raffle
        if(Raffles[_raffle_id].balance >= Raffles[_raffle_id].raffle_end_balance) {
            endRaffle(_raffle_id);
        }
    }
    // get all raffles
    function getAllRaffles() public view returns(Raffle[] memory) {
        return Raffles;
    }
    // get all winners
    function getAllWinners() public view returns(Winner[] memory) {
        return Winners;
    }
    // get all ticket holders
    function getAllTicketHolders() public view returns(ticketHolder[] memory) {
        return ticketHolders;
    }
    // get tickets per address
    function getTicketsPerAddress(address _address) public view returns(ticketHolder[] memory) {
        ticketHolder[] memory tickets = new ticketHolder[](ticketHolders.length);
        uint counter = 0;
        for(uint i = 0; i < ticketHolders.length; i++) {
            if(ticketHolders[i]._Address == _address) {
                tickets[counter] = ticketHolders[i];
                counter++;
            }
        }
        return tickets;
    }
    // change owner
    function changeOwner(address _newOwner) public {
        require(msg.sender == owner, "You are not the owner");
        owner = _newOwner;
    }
    // changhe fee
    function changeFee(uint _newFee) public {
        require(msg.sender == owner, "You are not the owner");
        fee = _newFee;
    }
    // get fee
    function getFee() public view returns(uint) {
        return fee;
    }
    // fee test, retreves fee amount from 100 
    function feeTest(uint _amount) public view returns(uint) {
        return (_amount / 100) * fee;
    }
    // fallback function
    fallback() external payable {}
}