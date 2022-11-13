/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;
 
// 定义ERC-20标准接口
interface ERC20Interface {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    // 实现代币交易，用于给某个地址转移代币
    function transfer(address to, uint tokens) external returns (bool success);
 
    // 实现代币用户之间的交易，从一个地址转移代币到另一个地址
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
 
    // 允许spender多次从你的账户取款，并且最多可取tokens个，主要用于某些场景下授权委托其他用户从你的账户上花费代币
    function approve(address spender, uint tokens) external returns (bool success);
 
    // 查询spender允许从tokenOwner上花费的代币数量
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
 
    // 代币交易时触发的事件，即调用transfer方法时触发
    event Transfer(address indexed from, address indexed to, uint tokens);
 
    // 允许其他用户从你的账户上花费代币时触发的事件，即调用approve方法时触发
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
 
 
 
// 实现ERC-20标准接口
 
contract EULA is ERC20Interface {
    // 代币名称
    string public override name;
 
    // 代币符号或者说简写
    string public override symbol;

    // 代币小数点位数，代币的最小单位
    uint256 public override decimals;
 
    // 代币的发行总量
    uint256 public override totalSupply;

    // 存储每个地址的余额（因为是public的所以会自动生成balanceOf方法）
    mapping (address => uint256) public balanceOf;
 
    // 存储每个地址可操作的地址及其可操作的金额
    mapping (address => mapping (address => uint256)) internal allowed;
 
 
 
    // 初始化属性
    constructor() {
        name = "EULA";
        symbol = "EULA";
        decimals = 18;
 
        // 代币总量
        totalSupply = 100000000 * 10 ** uint256(decimals);
 
        // 初始化该代币的账户会拥有所有的代币
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint tokens) external override returns (bool success) {
        // 检验发送者账户余额是否足够
        require(balanceOf[msg.sender] >= tokens);
 
        // 检验是否会发生溢出
        require(balanceOf[to] + tokens >= balanceOf[to]);
 
        // 扣除发送者账户余额
        balanceOf[msg.sender] -= tokens;
 
        // 增加接收者账户余额
        balanceOf[to] += tokens;

        success = true;
        // 触发相应的事件 
        emit Transfer(msg.sender, to, tokens);
    }
 
    function transferFrom(address from, address to, uint tokens) external override returns (bool success) {
        // 检验地址是否合法
        require(to != address(0) && from != address(0));
 
        // 检验发送者账户余额是否足够
        require(balanceOf[from] >= tokens);
 
        // 检验操作的金额是否是被允许的
        require(allowed[from][to] >= tokens);
 
        // 检验是否会发生溢出
        require(balanceOf[to] + tokens >= balanceOf[to]);

        // 扣除发送者账户余额 
        balanceOf[from] -= tokens;
 
        // 增加接收者账户余额
        balanceOf[to] += tokens;
 
        allowed[from][to] -= tokens;

        // 触发相应的事件
        emit Transfer(from, to, tokens);  
 
        success = true;
    }

    function approve(address spender, uint tokens) external override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
 
        // 触发相应的事件
        emit Approval(msg.sender, spender, tokens);
        success = true;
    }

    function allowance(address tokenOwner, address spender) external override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
}