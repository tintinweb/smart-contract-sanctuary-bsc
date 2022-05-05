/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract CryptoLottery {

    string   private _name;
    address  private _owner;
    address  private _system;

    address payable[] internal players;

    mapping(uint256 => address payable) internal loterryHistory;

    uint internal playerLimit = 100;
    uint internal _lotteryID;

    string internal info = "The lottery winner receives 90% of the accumulated amount and 10% will be allocated to _system maintenance";
    string internal rule01 = "The draw takes place automatically, according to the limit of participants predetermined in each round";
    string internal rule02 = "Amounts invested in lottery are non-refundable";
    string internal rule03 = "The amount paid to enter the lottery must be greater than or equal to the ticket price";
    string internal powered = "https://github.com/cryptorug";

    uint256 internal decValue = 10**18;
    uint256 internal ticketValue = 0.05 ether;

    event enterLottery(address indexed account, uint256 indexed _lotteryID_numer);
    event newWinner(address indexed winner, uint256 indexed _lotteryID_numer);

    modifier only_system(){
        checkAccount();
        _;
    }
 
constructor() payable {
        _name = "Satoshi's Lottery";
        _owner = address(0);
        _system = msg.sender;
        _lotteryID = 1;
    }

    function checkAccount() internal view {
        require(msg.sender == _system,"access denied");
    }

    function getNumber() internal view returns (uint256){
        return uint256(keccak256(abi.encodePacked(_system,block.timestamp)));
    }

    function Winner() internal {
    require(players.length >= playerLimit,"low participants");
        getNumber();

        uint256 index = getNumber() % players.length;
        players[index].transfer(address(this).balance*90/100);
        payable(_system).transfer(address(this).balance);
        emit newWinner(players[index], _lotteryID);

        loterryHistory[_lotteryID] = players[index];
        _lotteryID++;
        
        players = new address payable[](0);
    }

    function totalSupply() external view returns(uint256){
        return address(this).balance/decValue;
    }

    function name() external view returns(string memory){
        return _name;
    }

    function get_owner() external view returns(address){
        return _owner;
    }

    function Pay_info() external view returns(string memory){
        return info;
    }

    function Rule_1() external view returns(string memory){
        return rule01;
    }

    function Rule_2() external view returns(string memory){
        return rule02;
    }

    function Rule_3() external view returns(string memory){
        return rule03;
    }

    function Powered_By() external view returns(string memory){
        return powered;
    }

    function previousWinners(uint256 _lottoID) public view returns(address payable){
        return loterryHistory[_lottoID];
    }

    function setpriceTiket(uint256 _value) external only_system returns(bool){
        ticketValue = _value *decValue;
        return true;
    }

    function limitPlayers(uint256 _number) external only_system returns(bool){
        playerLimit = _number;
        return true;
    }

    function PayTheWinner() external only_system returns(bool){
        Winner();
        return true;
    }

    function Buy_ticket() public payable {
        require(msg.sender != _system,"access denied");
        require(msg.value >= ticketValue,"insufficient funds");
        players.push(payable(msg.sender));
        emit enterLottery(msg.sender, _lotteryID);
        if (players.length >= playerLimit){
            Winner();
        }
    }

    function Lottery_Info() public view returns
    (uint256 CurrentLottery_ID, uint256 Ticket_value, uint256 Participants, uint256 Limit_participants, uint256 Accumulated_lottery){
        CurrentLottery_ID = _lotteryID;
        Ticket_value = ticketValue/decValue;
        Participants = players.length;
        Limit_participants = playerLimit;
        Accumulated_lottery = address(this).balance/decValue;
        return (CurrentLottery_ID, Ticket_value, Participants, Limit_participants, Accumulated_lottery);
    }
}