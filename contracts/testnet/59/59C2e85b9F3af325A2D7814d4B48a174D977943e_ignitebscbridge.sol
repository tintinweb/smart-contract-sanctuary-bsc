/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface BEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract ignitebscbridge {
    using SafeMath for uint256;
    BEP20 public token;
    address admin;
    struct Users {
        address _address;
        uint256 _value;
        uint _timestamp;
    }
    Users[]  public userW;
    Users[] public userD;
    constructor(BEP20 _token) {
        require(_token != BEP20(address(0)));
        token = _token;
        admin = msg.sender;
    }
    receive () external payable {}

    function withdrawlIGT(address _receiver,uint256 _value) public payable{
        require(msg.sender == admin,"require owner");
        userW.push(
            Users({
                _address : _receiver,
                _value : _value,
                _timestamp : block.timestamp
            })
        );
        token.transfer(_receiver,_value);
    }
    function depositIGT(uint256 _value) public payable{
        userD.push(
            Users({
                _address : msg.sender,
                _value : _value,
                _timestamp : block.timestamp
            })
        );
        token.transferFrom(msg.sender,address(this),_value);
    }
    function checkBalance() public view returns(uint256){
        return token.balanceOf(address(this)); 
    }
    function totalUsersW() public view returns(uint){
        return userW.length;
    }
    function totalUsersD() public view returns(uint){
        return userD.length;
    }
}