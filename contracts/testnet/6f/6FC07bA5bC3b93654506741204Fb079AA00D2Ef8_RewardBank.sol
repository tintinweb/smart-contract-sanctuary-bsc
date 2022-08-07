/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface recaiver{
    function recaive() external payable;
}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) { owner = _owner; }
    modifier onlyOwner() { require(isOwner(msg.sender), "!OWNER"); _; }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract RewardBank is Ownable {
  using SafeMath for uint256;

  mapping (address=>bool) private allowance;

  address private recaiver1;
  address private recaiver2;
  uint256 public periodamount;
  uint256 public periodcooldown;

  uint256 private wait;

  uint256 public depositid;
  mapping (uint256=>address) public recipe_depositor;
  mapping (uint256=>uint256) public recipe_amount;
  mapping (uint256=>uint256) public recipe_block;

  uint256 public depositfee;
  uint256 public denominator;
  
  constructor(uint256 _periodamount,uint256 _periodcooldown) Ownable(msg.sender) {
    recaiver1 = 0xb44403bC446f0EdBeC0310Fb553EF1a9a8D9641c; //account 5
    recaiver2 = 0x3F6861d865301d64e8C37A53Cb42378B46FA9D1e; //account 6
    periodamount = _periodamount;
    periodcooldown = _periodcooldown;
    depositfee = 50;
    denominator = 1000;
  }

  function deposit() external payable returns (bool) {
    uint256 fee = msg.value.mul(depositfee).div(denominator);
    (bool success1, ) = recaiver1.call{ value : fee }("");
    require(success1,"transfer fail!");
    (bool success2, ) = recaiver2.call{ value : fee }("");
    require(success2,"transfer fail!");
    generaterecipe(msg.sender,msg.value,block.timestamp);
    return true;
  }

  function grantAllowance(address account,bool flag) external onlyOwner returns (bool) {
    allowance[account] = flag;
    return true;
  }

  function configBank(address _recaiver1,address _recaiver2,uint256 _amountETH,uint256 _cooldown) external onlyOwner returns (bool) {
    recaiver1 = _recaiver1;
    recaiver2 = _recaiver2;
    periodamount = _amountETH;
    periodcooldown = _cooldown;
    return true;
  }

  function isAllowance(address account) external view returns (bool) { return allowance[account]; }
  function getrecavier1() external view returns (address) { return recaiver1; }
  function getrecavier2() external view returns (address) { return recaiver2; }
  function getperiodamount() external view returns (uint256) { return periodamount; }
  function getperiodcooldown() external view returns (uint256) { return periodcooldown; }
  function getwait() external view returns (uint256) { return wait; }

  function reserve() external returns (bool) {
    require(allowance[msg.sender],"IBANL : revert allowance");
    require(block.timestamp>wait,"IBANK : revert by transfer wait");

    recaiver a = recaiver(msg.sender);
    a.recaive{ value : periodamount }();
    wait = block.timestamp.add(periodcooldown);

    return true;
  }

  function getlastdeposit() external view returns (uint256 id,address txowner,uint256 amount,uint256 when){
    return (
      depositid,
      recipe_depositor[depositid],
      recipe_amount[depositid],
      recipe_block[depositid]
    );
  }

  function getrecipe(uint256 recipeid) external view returns (uint256 id,address txowner,uint256 amount,uint256 when){
    return (
      recipeid,
      recipe_depositor[recipeid],
      recipe_amount[recipeid],
      recipe_block[recipeid]
    );
  }

  function generaterecipe(address _depositor,uint256 _amount,uint256 _when) internal returns (bool) {
    depositid = depositid.add(1);
    recipe_depositor[depositid] = _depositor;
    recipe_amount[depositid] = _amount;
    recipe_block[depositid] = _when;
    return true;
  }

  function purge() external onlyOwner() returns (bool) {
    (bool success, ) = msg.sender.call{ value : address(this).balance }("");
    require(success,"purge fail!");
    return true;
  }
  
  function recaive() public payable {}
  function balance() public view returns (uint256) { return address(this).balance; }

}