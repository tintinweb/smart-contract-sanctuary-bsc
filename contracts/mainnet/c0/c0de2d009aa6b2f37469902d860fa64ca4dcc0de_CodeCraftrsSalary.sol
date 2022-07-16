/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.15;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract CodeCraftrsSalary {
    address private constant CRYPT0JAN = 0x00155256da642eef4764865c4Ec8fF7AcdAAA050;
    address private constant MRGREEN = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;

    modifier onlyOwner() {require(msg.sender == MRGREEN || msg.sender == CRYPT0JAN, "Only CodeCraftrs can do that"); _;}
    constructor() {}
    receive() external payable {}
    
    function getSalaryInToken(address token) external onlyOwner {
        IBEP20(token).transfer(CRYPT0JAN, IBEP20(token).balanceOf(address(this))/2);
        IBEP20(token).transfer(MRGREEN, IBEP20(token).balanceOf(address(this)));    
    }

    function getSalaryInBnb() external onlyOwner {
        payable(MRGREEN).transfer(address(this).balance/2);
        payable(CRYPT0JAN).transfer(address(this).balance);
    }
}