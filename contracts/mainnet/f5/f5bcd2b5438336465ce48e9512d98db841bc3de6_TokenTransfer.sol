/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

interface token {
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
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
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract TokenTransfer{
    using SafeMath for uint256;
    token public wowToken;
    address private _tokenaddress;
    uint256 private _olduse = 0;
    uint256 private _total = 2500000 * 10 ** 18;
    uint256 private startTime = block.timestamp;
    uint256 private zq = 30*24*3600;
    // uint256 private zq = 60;
    
    function tokenTransfer(address _to, uint _amt) public {
        wowToken = token(_tokenaddress);
        wowToken.transfer(_to,_amt); //调用token的transfer方法
    }

    function getMoney(address _token) external{
        uint256 money = _total.div(1).mul(60);
        uint256 _canuse =0;
        for(uint i=0;i<=60;i++){
           if(startTime.add(zq.mul(i)) < block.timestamp){
              _canuse = money*i;
           } 
        }
        _canuse = _canuse.sub(_olduse);
        require(_canuse>0,"error");
        _olduse = _olduse.add(_canuse);
        wowToken = token(_token);
        wowToken.transfer(0x67069dffAE22E80D75F01Ba450304e30d7aF0e42,_canuse);
    }

    function setTokenaddress(address acc) external{
        _tokenaddress = acc;
    }
}