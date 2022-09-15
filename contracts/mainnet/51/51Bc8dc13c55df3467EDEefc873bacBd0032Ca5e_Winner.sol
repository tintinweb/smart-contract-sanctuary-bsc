/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
   
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IWinner{
    function withdraw(uint256 amount) external;

    function withdrawToken(IERC20 __token, uint256 amount) external;

    function transferOwnership(address newOwner) external;
}

contract Winner{

    address public __owner;

    constructor()
        payable
    {
        __owner = msg.sender;
    }

    modifier onlyOwner() {
        require(__owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function withdraw(uint256 amount) 
        external
        onlyOwner
    {
        payable(msg.sender).transfer(amount);
    }

    function withdrawToken(IERC20 __token, uint256 amount) 
        external 
        onlyOwner
    {
        IERC20(__token).transfer(msg.sender, amount);
    }

    function transferOwnership(address newOwner) 
        external
        onlyOwner 
    {
        __owner = newOwner;
    }

}