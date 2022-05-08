/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IERC20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);
}

contract CryptoLottery is IERC20 {

    string   private _name;
    string   private _symbol;
    address  private _owner;
    address  private _system;

    address payable[] internal _players;

    mapping(uint256 => address payable) internal _loterryHistory;

    uint internal _playerLimit = 100;
    uint internal _lotteryID;

    string internal info = "The lottery winner receives 80% of the accumulated amount, 10% of the current round is accumulated for the subsequent round and 10% will go towards the maintenance of the system, website and charges";
    string internal rule01 = "The draw takes place automatically, according to the limit of participants predetermined in each round";
    string internal rule02 = "Amounts invested in lottery are non-refundable";
    string internal rule03 = "The amount paid to enter the lottery must be greater than or equal to the ticket price";
    string internal powered = "https://github.com/cryptorug";

    uint256 internal decValue = 10**18;
    uint256 internal ticketValue = 1 ether;

    event enterLottery(address indexed account, uint256 indexed lotteryID_numer);
    event newWinner(address indexed winner, uint256 indexed lotteryID_numer);
    event emergency(address indexed sender, uint256 indexed withdrawal);

    modifier only_system(){
        checkAccount();
        _;
    }
 
constructor() payable {
        _name = "Crypto Lottery";
        _symbol = "LOTTO";
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
        getNumber();

        uint256 index = getNumber() % _players.length;
        _players[index].transfer(address(this).balance*80/100);
        payable(_system).transfer(address(this).balance*10/100);
        emit newWinner(_players[index], _lotteryID);

        _loterryHistory[_lotteryID] = _players[index];
        _lotteryID++;
        
        _players = new address payable[](0);
    }

    function totalSupply() external view returns(uint256){
        return address(this).balance/decValue;
    }

    function decimals() external view returns (uint){
        return _lotteryID;
    }

    function symbol() external view returns (string memory){
        return _symbol;
    }

    function name() external view returns (string memory){
        return _name;
    }

    function getOwner() external view returns (address){
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

    function Previous_Winners(uint256 _lottoID) public view returns(address payable){
        return _loterryHistory[_lottoID];
    }

    function Setprice_Tiket(uint256 _value) external only_system returns(bool){
        ticketValue = _value *decValue;
        return true;
    }

    function limit_players(uint256 _number) external only_system returns(bool){
        _playerLimit = _number;
        return true;
    }

    function Paythe_Winner() external only_system returns(bool){
        Winner();
        return true;
    }

    function Emergency_Withdrawal() external only_system returns(bool){
        require(address(this).balance > 0,"insufficient funds");
        emit emergency(msg.sender, address(this).balance);
        payable(_system).transfer(address(this).balance);
        _lotteryID++;
        _players = new address payable[](0);
        return true;
    }

    function Buy_ticket() public payable {
        require(msg.sender != _system,"access denied");
        require(msg.value >= ticketValue,"insufficient funds");
        _players.push(payable(msg.sender));
        emit enterLottery(msg.sender, _lotteryID);
        if (_players.length >= _playerLimit){
            Winner();
        }
    }

    function Lottery_Info() public view returns
    (uint256 CurrentLottery_ID, uint256 Ticket_value, uint256 Participants, uint256 Limit_participants, uint256 Accumulated_lottery){
        CurrentLottery_ID = _lotteryID;
        Ticket_value = ticketValue/decValue;
        Participants = _players.length;
        Limit_participants = _playerLimit;
        Accumulated_lottery = address(this).balance/decValue;
        return (CurrentLottery_ID, Ticket_value, Participants, Limit_participants, Accumulated_lottery);
    }
}