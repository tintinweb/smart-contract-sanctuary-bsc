/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface taxController {
    function getTaxPercent() external view returns (uint);
}

contract CDT_Token  {
    using SafeMath for uint256;

    string public constant name = "CDT-Token";
    string public constant symbol = "CDT";
    uint8 public constant decimals = 18;
    uint256 public total_Supply =10000000 * 10 ** decimals;
    address public taxContadd = 0x7dB66Fc62Af9c292fe252a2F4a5D2B24E7442dB1;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    mapping (address => bool) internal adminsList;
    mapping (address => bool) internal poolsList;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {
        adminsList[msg.sender] = true;
        poolsList[0x10ED43C718714eb63d5aA57B78B54704E256024E] = true;
        balances[msg.sender] = total_Supply;
        emit Transfer(address(0), msg.sender, total_Supply);
    }
    function totalSupply() public view returns (uint256) {
        return total_Supply;
    }
    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }
    function executeTransfer(address sender, address reciver, uint256 numTokens) internal  returns (bool) {
        balances[sender] = balances[sender].sub(numTokens);
        uint burnAmount = 0;
        if(!adminsList[sender] && !poolsList[sender]){
            uint selltax =taxController(taxContadd).getTaxPercent();
            burnAmount = numTokens * selltax / 100;
        }
        balances[reciver] = balances[reciver].add(numTokens.sub(burnAmount));
        emit Transfer(sender, reciver, numTokens.sub(burnAmount));
        
        if(burnAmount>0){
            balances[address(0)] = balances[address(0)].add(burnAmount);
            emit Transfer(sender, address(0), burnAmount);
        }
        return true;
    }
    function transfer(address reciver, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        return executeTransfer(msg.sender, reciver, numTokens);
    }
    function transferFrom(address sender, address reciver, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[sender]);
        require(numTokens <= allowed[sender][msg.sender]);
        allowed[sender][msg.sender] = allowed[sender][msg.sender].sub(numTokens);
        return executeTransfer(sender, reciver, numTokens);
    }
    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }
    function setAddressByList(uint listType, address setAddress,bool state) external returns (bool) {
        require(adminsList[msg.sender] , "UN");
        require(listType>=0 && listType<=1 , "Wrong list Id");
        if(listType==0) adminsList[setAddress] = state;
        if(listType==1) poolsList[setAddress] = state;
        return true;
    }
    function inquire(uint listType, address inqAddress) public view returns (bool) {
        if(listType==0) return adminsList[inqAddress];
        if(listType==1) return poolsList[inqAddress];
        return false;
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}