/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// contracts/Version1-Safe.sol
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function transfer(address to, uint256 value) external returns(bool);
}

contract Bank {
    mapping(address => uint256) public depositAmount;

    function deposit(uint256 amount) public {
        IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56).transferFrom(msg.sender, address(this), amount);
        depositAmount[msg.sender] += amount;
    }

    function withdraw() public {
        IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56).transfer(msg.sender, depositAmount[msg.sender]);
        depositAmount[msg.sender] = 0;
    }
}