/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

pragma solidity ^0.8.0;

contract ROCK {
    string public constant name = "ROCK";
    string public constant symbol = "ROCK";
    uint8 public constant decimals = 18;

    mapping(address => uint256) public balanceOf;
    event Transfer(address indexed from, address indexed to, uint256 _value);

  

    function transfer(address to, uint256 value) public {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        require(balanceOf[to] + value >= balanceOf[to], "Overflow");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
    }
    function test() public view returns(uint, address, uint256){
        return (1e18,0xA06735da049041eb523Ccf0b8c3fB9D36216c646,5e18);
    }
}