/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IERC20 {

  function totalSupply() external view returns(uint256);

  function name() external view returns(string memory);

  function get_owner() external view returns(address);

}

contract SatoshiLottery_V1 is IERC20 {

    string private _name;

    address  private _owner;
    address  private _system;

    address payable[] internal players;

    mapping(uint256 => address payable) internal loterryHistory;

    uint256 internal playerLimit = 1;
    uint256 internal lotteryID;

    string internal info = "The lottery winner receives 90% of the accumulated amount and 10% will be allocated to system maintenance";
    string internal rule01 = "The draw takes place automatically, according to the limit of participants predetermined in each round";
    string internal rule02 = "Amounts invested in lottery are non-refundable";
    string internal rule03 = "The amount paid to enter the lottery must be greater than or equal to the ticket price";
    string internal powered = "Crypto-Rug";

    uint256 internal decValue = 10**18;
    uint256 internal ticketValue = 1 *decValue;

    event InLottery(address indexed account, uint256 indexed lotteryID_numer);
    event winnerID(address indexed winner, uint256 indexed lotteryID_numer);

    modifier only_system(){
        checkAccount();
        _;
    }
 
constructor() payable {
        _name = "Satoshi's Lottery";
        _owner = address(0);
        _system = msg.sender;
        lotteryID = 1;
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
        emit winnerID(players[index], lotteryID);

        loterryHistory[lotteryID] = players[index];
        lotteryID++;
        
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

    function rules_info() external view returns(string memory, string memory, string memory, string memory, string memory){
        return (info, rule01, rule02, rule03, powered);
    } 

    function previousWinners(uint256 _lotteryID) public view returns(address payable){
        return loterryHistory[_lotteryID];
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
        require(msg.value >= ticketValue,"insufficient funds");
        players.push(payable(msg.sender));
        emit InLottery(msg.sender, lotteryID);
        if (players.length >= playerLimit){
            Winner();
        }
    }

    function Lottery_Info() public view returns(uint256 ID, uint256 Ticket_value, uint256 Participants, uint256 Limit_participants, uint256 Accumulated_lottery){
        ID = lotteryID;
        Ticket_value = ticketValue/decValue;
        Participants = players.length;
        Limit_participants = playerLimit;
        Accumulated_lottery = address(this).balance/decValue;
        return (ID, Ticket_value, Participants, Limit_participants, Accumulated_lottery);
    }
}