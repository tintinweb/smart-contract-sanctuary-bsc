/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IERC20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint256);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

}

contract Satoshi_LotteryV1 is IERC20 {

    string private _name = "Satoshi's Lottery";
    string private _symbol = "LOTTERY";
    address private owner;
    address private system;

    address payable[] internal players;

    mapping(uint256 => address payable) internal loterryHistory;

    uint256 internal lotteryID;
    string internal information = "The winner receives 90% of the accumulated value, 10% return for system maintenance";

    uint256 internal decValue = 10**18;
    uint256 internal payValue = 0.1 ether;

    event InLottery(address indexed account, uint256 indexed lotteryID_numer);
    event winnerID(address indexed winner, uint256 indexed lotteryID_numer);

    modifier onlySystem(){
        checkAccount();
        _;
    }
 
constructor() payable {
        owner = address(0);
        system = msg.sender;
        lotteryID = 0;
    }

    function checkAccount() internal view {
        require(msg.sender == system,"access denied");
    }

    function totalSupply() external view returns (uint256) {
        return address(this).balance/decValue;
    }

    function decimals() external view returns (uint256) {
        return lotteryID;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function getNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(system,block.timestamp)));
    }

    function getWinnerByLottery(uint256 _id) public view returns(address payable) {
        return loterryHistory[_id];
    }

    function Lottery_Info() public view returns(uint256 ID, uint256 Ticket_value, uint256 Participants, uint256 Accumulated_lottery, string memory) {
        ID = lotteryID;
        Ticket_value = payValue/decValue;
        Participants = players.length;
        Accumulated_lottery = address(this).balance/decValue;
        return (ID, Ticket_value, Participants, Accumulated_lottery, information);
    }

    function set_price(uint256 _value) external onlySystem returns(bool) {
        payValue = _value *decValue;
        return true;
    }

    function Buy_ticket() public payable {
        require(msg.value >= payValue,"insufficient funds");
        players.push(payable(msg.sender));
        emit InLottery(msg.sender, lotteryID);
    }

    function Paythe_Winner() public onlySystem {
        getNumber();
        // require(players.length > 10,"low participants");
        uint256 index = getNumber() % players.length;
        players[index].transfer(address(this).balance*90/100);
        payable(system).transfer(address(this).balance);
        emit winnerID(players[index], lotteryID);

        loterryHistory[lotteryID] = players[index];
        lotteryID++;
        
        players = new address payable[](0);
    }
}