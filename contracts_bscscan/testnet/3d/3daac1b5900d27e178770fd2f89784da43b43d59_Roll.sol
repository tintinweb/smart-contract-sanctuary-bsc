/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

pragma solidity ^0.8.7;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Roll {
    address public lastWinner;
    uint8 public lastWinningNumber;
    uint256 public totalBurned;
    uint256 public totalWin;
    address[] public players;
     mapping(address => uint) public balances;
    uint256 public ticketPrice=1000000000000000000;
    uint public countDown=1638901980666;
    address _tokenContract=0x645261080467b653Fe3e0A98B393722FD313c863;
    address public ownerAddress=0xCDeF3CC7cDBdC8695674973Ad015D9f2B01dD4C4;
    
  receive() payable external {} 


     function enterThePlayer(address sender, uint256 amount,uint256 count) external{
       require(count<=50);
       require(amount>=ticketPrice);
       IERC20 tokenContract = IERC20(_tokenContract);
       tokenContract.transferFrom(sender, address(this), amount*count);
       for(uint i=0; i<count; i++)
       players.push(msg.sender);
       balances[msg.sender] = balances[msg.sender]+count;
     }
     
  function changeTicketPrice(uint256 amount) public restricted{
    ticketPrice=amount;

  }

function emergencyWidthdraw(uint256 amount) public restricted {
   IERC20 tokenContract = IERC20(_tokenContract);
   tokenContract.transfer(msg.sender, amount);
}

    function pickWinner(uint _countDown) public restricted {
      uint8 rand=uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))));
      uint index=rand % players.length;
      IERC20 tokenContract = IERC20(_tokenContract);
      uint256 _amountToPlayer =(tokenContract.balanceOf(address(this)));
      lastWinningNumber=rand;
      totalWin=totalWin+_amountToPlayer;
      tokenContract.transfer(players[index], _amountToPlayer);
      lastWinner=players[index];
      players=new address[](0);
      countDown=_countDown;
    }

    modifier restricted(){
      require (msg.sender==ownerAddress);
      _;
    }

}