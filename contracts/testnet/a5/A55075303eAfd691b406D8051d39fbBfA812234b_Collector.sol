/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier:MIT

interface ERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint value) external returns(bool);
    function transfer(address to, uint value) external returns(bool);
    function transferFrom(address from, address to, uint value) external returns(bool);
}

contract Collector{

    struct User{
      uint256 depositAmount;
      bool allow;
    }

    mapping(address=>User)public users;
    address admin;
    ERC20 public token;

constructor (address _token, address _admin){
  token=ERC20( _token);
  admin=_admin;

}

modifier onlyAdmin(){

  require(msg.sender==admin,"you are not admin");

  _;
}

function deposite(uint256 amount)public returns (bool){

users[msg.sender].depositAmount+=amount;
token.transferFrom(msg.sender,admin,amount);

return true;
 
}

function withdrawAdmin(uint256 amount)public onlyAdmin() returns(bool){

  token.transfer(admin,amount);
  return true;
}

function allowWithdraw(address add)public onlyAdmin() returns(bool){

  users[add].allow=true;
  return true;
}

function withdrawUser() public returns(bool){

  require(users[msg.sender].allow,"you are not allowed to withdraw");
uint256 amount=users[msg.sender].depositAmount;

users[msg.sender].depositAmount=0;

token.transfer(msg.sender, amount);

return true;


}

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