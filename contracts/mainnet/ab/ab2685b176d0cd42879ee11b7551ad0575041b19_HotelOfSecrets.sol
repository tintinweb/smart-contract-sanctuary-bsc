/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

pragma solidity ^0.8.18;

contract HotelOfSecrets {
string public constant name = "HotelOfSecrets";
string public constant symbol = "HOS";
uint8 public constant decimals = 10;
uint256 public totalSupply = 100000000 * (10 ** uint256(decimals));
uint256 public lockedSupply = totalSupply * 20 / 100;
uint256 public openSaleSupply = totalSupply * 29 / 100;
uint256 public preSaleSupply = totalSupply * 20 / 100;
uint256 public gameCreationSupply = totalSupply * 20 / 100;
mapping(address => uint256) public balanceOf;
mapping(address => mapping(address => uint256)) public allowance;

event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);

constructor() public {
balanceOf[msg.sender] = totalSupply;
}

function transfer(address _to, uint256 _value) public returns (bool) {
require(balanceOf[msg.sender] >= _value, "Not enough balance.");
require(balanceOf[_to] + _value >= balanceOf[_to], "Overflow.");
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
emit Transfer(msg.sender, _to, _value);
return true;
}

function approve(address _spender, uint256 _value) public returns (bool) {
allowance[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}

function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(balanceOf[_from] >= _value, "Not enough balance.");
require(balanceOf[_to] + _value >= balanceOf[_to], "Overflow.");
require(allowance[_from][msg.sender] >= _value, "Not enough allowance.");
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
allowance[_from][msg.sender] -= _value;
emit Transfer(_from, _to, _value);
return true;
}

function getTransactionFee() public view returns (uint256) {
return 2 * (10 ** uint256(decimals)) / 100;
}

function getBernPercentage() public view returns (uint256) {
return 10 * (10 ** uint256(decimals)) / 100;
}

function getProofOfStakeAmount() public view returns (uint256) {
return 5000 * (10 ** uint256(decimals));
}

function getWeb3Support() public pure returns (bool) {
return true;
}

function isPreSaleSupported() public pure returns (bool) {
return true;
}

function airDrop() public returns (bool) {
// to be implemented
return true;
}
}