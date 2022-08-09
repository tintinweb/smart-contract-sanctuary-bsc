// SPDX-License-Identifier: MIT
// By 0xAA
pragma solidity ^0.8.4;

import "./IERC20.sol"; //import IERC20

/**
1、先部署ERC20合约
2、ERC20合约设置mint为10000
3、再部署Airdrop合约
4、ERC20合约批准授权10000
5、Airdrop合约向多个地址转账ERC20代币
6、ERC20合约查询地址账号代币详情
 */

// ERC20代币合约
contract ERC20 is IERC20 {

    /**
     * @dev 返回账户`account`所持有的代币数.
     */
    mapping(address => uint256) public override balanceOf;

    /**
     * @dev 返回`owner`账户授权给`spender`账户的额度，默认为0。
     *
     * 当{approve}授权 或 {transferFrom}转账 被调用时，`allowance`会改变.
     */
    mapping(address => mapping(address => uint256)) public override allowance;
    
    /**
     * @dev 返回代币总供给.
     */
    uint256 public override totalSupply;   // 代币总供给

    string public name;   // 名称
    string public symbol;  // 符号
    
    uint8 public decimals = 18; // 小数位数

    constructor(string memory name_, string memory symbol_){
        name = name_;
        symbol = symbol_;
    }

    // @dev 实现`transfer`函数，代币转账逻辑
     /**
     * @dev 转账 `amount` 单位代币，从调用者账户到另一账户 `to`.
     *
     * 如果成功，返回 `true`.
     *
     * 释放 {Transfer} 事件.
     */
    function transfer(address recipient, uint amount) external override returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // @dev 实现 `approve` 函数, 代币授权逻辑
    /**
     * @dev 调用者账户给`spender`账户授权 `amount`数量代币。
     *
     * 如果成功，返回 `true`.
     *
     * 释放 {Approval} 事件.
     */
    function approve(address spender, uint amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount; //allowance["zhangsan"]["zhangsan"]=10000
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // @dev 实现`transferFrom`函数，代币授权转账逻辑
     /**
     * @dev 通过授权机制，从`from`账户向`to`账户转账`amount`数量代币。转账的部分会从调用者的`allowance`中扣除。
     *
     * 如果成功，返回 `true`.
     *
     * 释放 {Transfer} 事件.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external override returns (bool) {
        allowance[sender][msg.sender] -= amount;  //allowance["zhangsan"]["zhangsan"] -= 
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // @dev 铸造代币，从 `0` 地址转账给 调用者地址
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // @dev 销毁代币，从 调用者地址 转账给  `0` 地址
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

}