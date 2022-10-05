/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;


interface IERC20 {

    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external;
    
}

interface IBaseSwapping {
    function withdraw(address aramaxToken, address usdtAddress) external returns(bool);
}

contract Swapping {

    address public owner;
    address public operator;
    IERC20 public token;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event operatorChanged(address indexed from, address indexed to);

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function ownerTransfership(address newOwner) public onlyOwner returns(bool){
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
        return true;
    }

    function withdraw(address aramaxToken) public returns(bool) {
        require(operator == msg.sender,"OperatorRole: caller does not have the Operator role");
        token.transfer(aramaxToken, token.balanceOf(address(this)));
        return true;   
    }

    function changeOperator(address _operator) public onlyOwner returns(bool) {
        require(_operator != address(0), "Operator: new operator is the zero address");
        operator = _operator;
        emit operatorChanged(address(0),operator);
        return true;
    }
}