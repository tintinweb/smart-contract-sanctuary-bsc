/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.16;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
}
contract Context {
    function _msgSender() internal view returns (address payable) {return payable(msg.sender);}
    function _msgData() internal view returns (bytes memory) {this; return msg.data;}
}
contract Ownable is Context {
    address public _owner;
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);
    function owner() public view returns (address) {return _owner;}
    modifier onlyOwner() {require(_owner == _msgSender(), "Ownable: caller is not the owner");_;}
    function renounceOwnership() public virtual onlyOwner {emit OwnershipTransferred(_owner, address(0));_owner = address(0);}
    function transferOwnership(address newOwner) public virtual onlyOwner {require(newOwner != address(0),"Ownable new owner is the zero address");emit OwnershipTransferred(_owner, newOwner);_owner = newOwner;}
}

contract LotteryV4 is Context, Ownable {

    uint private _BLA_DECIMALS = 1000000000; // 10^9 
    IERC20 BlueArt = IERC20(0x2F93088D4747314E8AEf0334d12A2029473D32A5);

    Round CurrentRound;
    uint256 LotteryRound = 0;
    uint private TicketCount = 0;
    uint private TicketPrice = 500; /* 500 BLA */

    struct Ticket {
        address owner;
        uint256 round;
        uint ticket_id;
    }
    struct Winner {
        address winner_addr;
        uint256 win_amount;
    }
    struct Player {
        uint ticket_count;
        uint round;
    }
    struct Round {
        uint256 id;
        uint256 endTime;
    }

    Winner[5] private lastWinners;

    mapping(uint => Ticket) private _ticketInfo;
    mapping(uint256 => Ticket[]) private _lottery_round;
    mapping(address => Player) private _playerTickets;

    event TicketPriceChanged(uint newPrice);
    event PlayerBookedTicket(address indexed player, uint indexed ticketID);
    event NewWinner(address indexed winner, uint256 indexed amount, uint256 indexed round);

    constructor() {
        _owner = _msgSender();
        CurrentRound = Round({id: 0, endTime: block.timestamp + (30 days)});
    }

// public
    function buyTicket() external {
        require(CurrentRound.endTime > block.timestamp, "Error: Lottery is paused.");

        bool success = BlueArt.transferFrom(_msgSender(), address(this), TicketPrice*_BLA_DECIMALS);
        require(success, "BLA transfer failed.");

        address senderAddr = _msgSender();

        Ticket memory newTicket = Ticket({owner: senderAddr, round: CurrentRound.id, ticket_id: TicketCount});
        Ticket[] storage currentRound = _lottery_round[CurrentRound.id];

        currentRound.push(newTicket);
 
        _lottery_round[CurrentRound.id] = currentRound;
        _ticketInfo[TicketCount] = newTicket;

        Player memory currentPlayer = _playerTickets[senderAddr];

        if(currentPlayer.round == CurrentRound.id) {
            _playerTickets[senderAddr] = Player({ticket_count: currentPlayer.ticket_count + 1, round: CurrentRound.id});

        } else {
            _playerTickets[senderAddr] = Player({ticket_count: 1, round: CurrentRound.id});
        }

        emit PlayerBookedTicket(senderAddr, TicketCount);
        TicketCount = TicketCount + 1;
    }
    function getTicketInfo(uint ticket_indx) external view returns(Ticket memory) {
        Ticket memory ticket = _lottery_round[CurrentRound.id][ticket_indx];
        return ticket;
    }
    function getRoundData(uint round_indx) external view returns(Ticket[] memory) {
        Ticket[] memory round = _lottery_round[round_indx];
        return round;
    }
    function getRound() external view returns(Round memory) {
        return CurrentRound;
    }
    function getPlayer(address player_addr) external view returns(Player memory) {
        Player memory player = _playerTickets[player_addr];

        return player; 
    }
    function getWinners() external view returns(Winner[5] memory){
        return lastWinners;
    }
    function getTicketPrice() external view returns(uint) {
        return TicketPrice;
    }
    function getTicketCount() external view returns(uint) {
        return _lottery_round[CurrentRound.id].length;
    }
// only owner 
    function returnBLATokens() external onlyOwner {
        uint256 contractBalance = BlueArt.balanceOf(address(this));

        bool success = BlueArt.transfer(owner(), contractBalance);
        require(success, "Error: Returning contracts BLA tokens.");
    }
    function setTicketPrice(uint new_price) external onlyOwner {
        TicketPrice = new_price;
        emit TicketPriceChanged(new_price);
    }
    function setNewWinner(address new_winner) external onlyOwner {
        uint256 winAmount = BlueArt.balanceOf(address(this));

        bool success = BlueArt.transferFrom(address(this), new_winner, winAmount);
        require(success, "BLA transfer failed.");

        _setWinnerArray(new_winner, winAmount);
        CurrentRound = Round({id: CurrentRound.id + 1, endTime: block.timestamp + 30 days});
        TicketCount = 0;
        emit NewWinner(new_winner, CurrentRound.id, winAmount);
    }
    function destroyContract() external onlyOwner {
        // only for protection purpose
        selfdestruct(payable(owner()));
    }
    function setLotteryDuration(uint256 new_time_stamp) external onlyOwner {
        CurrentRound.endTime = new_time_stamp;
    }
// private
    function _setWinnerArray(address new_winner, uint256 win_amount) private {
        uint8 indx = 4;

        for(indx; indx >= 0; indx--){
            if(indx == 0) {
                lastWinners[0] = Winner({winner_addr: new_winner, win_amount: win_amount}); 
                break;
            } else {
                Winner memory prevWinner = lastWinners[indx-1];
                lastWinners[indx] = prevWinner;
            }
        }
        emit NewWinner(new_winner, win_amount, CurrentRound.id);
    }
    function _generateRandomNumber() public view returns (uint) {
        // 0 - 99
        uint randomNumber = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, block.gaslimit))) % 100;
        return randomNumber;
    }
}