/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract LottoToken {
    address public owner;
    address payable[] public players;
    uint public lotteryId;
    mapping (uint => address payable) public lotteryHistory;
    mapping (address => uint) public balances;
    mapping (address => mapping (address => uint) ) public allowance;

    uint public totalSupply= 1000000000 * 10 ** 18;
    uint public decimals = 18;
    string public name = "DailyLottoDuck";
    string public  symbol= "DLT";
    event Transfer(address indexed from, address indexed to,uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {
      balances[msg.sender] = totalSupply;
      owner = msg.sender;
      lotteryId = 1;
    }
    function balanceOf(address _owner) public view returns (uint) {
      return balances[_owner];
    }
    function transfer(address to,uint value)public returns (bool) {
      require(balanceOf(msg.sender)>= value,'Not enough balance');
      balances[to] +=value;
      balances[msg.sender] -=value;
      emit Transfer(msg.sender,to, value);
      return true;

    }
    function transferFrom(address from,address to, uint value)public returns(bool){
      require(balanceOf(from) >= value,'to low balance');
      require(allowance[from][msg.sender] >= value, 'Allowance to low');
      balances[to] += value;
      balances[from] -=value;
      emit Transfer(from, to, value);
      return true;
    }
    function approve(address spender,uint value) public returns(bool){
      allowance[msg.sender][spender]=value;
      emit Approval(msg.sender, spender, value);
      return true;

    }
    function getWinnerByLottery(uint lottery) public view returns (address payable) {
        return lotteryHistory[lottery];
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function enter() public payable {
        require(msg.value > 5);

        // address of player entering lottery
        players.push(payable(msg.sender));
    }

    function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    function pickWinner() public onlyowner {
        uint index = getRandomNumber() % players.length;
        players[index].transfer(address(this).balance);

        lotteryHistory[lotteryId] = players[index];
        lotteryId++;


        // reset the state of the contract
        players = new address payable[](0);
    }

    modifier onlyowner() {
      require(msg.sender == owner);
      _;
    }
}