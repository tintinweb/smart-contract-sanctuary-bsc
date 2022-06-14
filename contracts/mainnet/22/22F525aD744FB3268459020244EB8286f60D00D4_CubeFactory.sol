/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract CubeFactory {
    function getName(address _tokens) public view returns(string memory) { return IERC20(_tokens).name(); }
    function getSymbol(address _tokens) public view returns(string memory) { return IERC20(_tokens).symbol();  }
    function getDecimals(address _tokens) public view returns(uint8) { return IERC20(_tokens).decimals();  }
    function getTotal(address _tokens) public view returns(uint256) { return IERC20(_tokens).totalSupply();  }
    function getBalance(address _tokens , address holder) public view returns(uint256 balance) { return IERC20(_tokens). balanceOf(holder);}
}