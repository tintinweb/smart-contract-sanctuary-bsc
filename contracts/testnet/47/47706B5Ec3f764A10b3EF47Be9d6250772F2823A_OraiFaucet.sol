/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

pragma solidity 0.5.16;

interface IBEP20 {

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);

}

contract OraiFaucet {
  IBEP20 public oraiToken;
  address public owner;
  uint256 public amount;
  uint256 public waitedTime;
    event Faucet(address indexed recipient, uint256 _amount);
  mapping(address => uint256) lastAccessTime;

  constructor(address _orai, uint256 _amount) public{
    require(_orai != address(0));
    oraiToken = IBEP20(_orai);
    waitedTime = 5 minutes;
    amount = _amount;
    owner = msg.sender;
  }

  function requestToken(address recipient) public {
    require(oraiToken.balanceOf(address(this)) > amount);
    if (lastAccessTime[recipient]>0){
      require(lastAccessTime[recipient]<block.timestamp);
    }
    oraiToken.transfer(recipient,amount);
    lastAccessTime[recipient] = block.timestamp + waitedTime;
    emit Faucet(recipient,amount);
  }
}