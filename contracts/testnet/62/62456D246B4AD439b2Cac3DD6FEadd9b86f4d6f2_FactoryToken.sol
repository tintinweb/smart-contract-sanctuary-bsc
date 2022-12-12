/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

/////BSC TEST
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
}

contract FactoryToken {
    //获取代币的全称
    function getName(address addr) view public returns(string memory ) {
        //实例化erc20接口
        IERC20 ERC20 = IERC20(addr);
        return  ERC20.name();
    }

     //获取代币的全称
    function getSymbol(address addr) view public returns(string memory ) {
        //实例化erc20接口
        IERC20 ERC20 = IERC20(addr);
        return  ERC20.symbol();
    }
     //获取代币的精度
    function getDecimal(address addr) view public returns(uint8) {
        //实例化erc20接口
        IERC20 ERC20 = IERC20(addr);
        return ERC20.decimals();
    }

      //获取代币的余额
    function getBalance(address addr , address wallet) view public returns(uint256) {
        //实例化erc20接口
        IERC20 ERC20 = IERC20(addr);
        return ERC20.balanceOf(wallet);
    }
}