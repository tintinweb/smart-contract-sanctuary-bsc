// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import './Address.sol';
import './SafeMath.sol';
import './SafeERC20.sol';
import './ERC20.sol';

/**
 * 发布的token
 */
contract CodeToken is BEP20{

    // 引入SafeERC20库，其内部函数用于安全外部ERC20合约转账相关操作
    using SafeERC20 for IERC20;
    // 使用Address库中函数检查指定地址是否为合约地址
    using Address for address;
    // 引入SafeMath安全数学运算库，避免数学运算整型溢出
    using SafeMath for uint;
   string private _name;  // 代币的名字
    string private _symbol; // 代币的简称
    uint8 private _decimals=18; // 代币的精度，例如：为2的话，则精确到小数点后面两位

    /** 
     * 获取代币的名称
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /** 
     * 获取代币的简称
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /** 
     * 获取代币的精度
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    
    constructor(string memory name_, string memory symbol_)
    {
        sGM();
        _name = name_;
        _symbol = symbol_;
    }
    
}