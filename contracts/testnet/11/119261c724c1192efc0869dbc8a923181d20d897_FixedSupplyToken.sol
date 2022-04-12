/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

pragma solidity ^0.4.24;


// ----------------------------------------------------------------------------
// Safe maths 維持正整數
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface 定義事件跟查詢/交易方法/動作
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    //查詢
    function transfer(address to, uint tokens) public returns (bool success);
    //轉帳
    function approve(address spender, uint tokens) public returns (bool success);
    //同意轉帳 別人用我的錢包
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    //被同意的人使用此法轉出，他人錢包中可花的金額
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    //事件:轉幣. 同意
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// 一鍵功能，確認後執行
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


// ----------------------------------------------------------------------------
// Owned contract  持有者規則
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and a
// fixed supply 添加了符號、名稱和小數點以及一個
// 固定供應
// ----------------------------------------------------------------------------
contract FixedSupplyToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor-代幣設定代幣設定
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "SAcake";
        name = "cake sasa Supply Token";
        decimals = 18;
        _totalSupply = 10000 * 10**uint(decimals);
        //帶入小數點精度18
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
        //開始發行
    }


    // ------------------------------------------------------------------------
    // Total supply 供應方法讀取起始地址
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`獲取賬戶 `tokenOwner` 的代幣餘額
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account將餘額從代幣所有者的賬戶轉移到`to`賬戶
    // - Owner's account must have sufficient balance to transfer所有者的賬戶必須有足夠的餘額才能轉賬
    // - 0 value transfers are allowed允許 0 值傳輸
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        //減少
        balances[to] = balances[to].add(tokens);
        //增加
        emit Transfer(msg.sender, to, tokens);
        //紀錄
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account 從持有者帳戶授權，給spender利用"transferFrom(...)"來花他的錢
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack// 建議不檢查批准雙花攻擊
    // as this should be implemented in user interfaces  // 因為這應該在用戶界面中實現
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
        //紀錄授權事件-同意
    }


    // ------------------------------------------------------------------------
    // Transfer 【`tokens` from】 the `from` account to the `to` account
    // 被授權的人要花錢/提錢了
    // The calling account must already have sufficient tokens approve(...)-d 授權的錢要夠【此時才驗證授權】
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer 原地址錢要夠
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        //A地址的餘額
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        //B使A地址扣錢
        balances[to] = balances[to].add(tokens);
        //B的目標地址
        emit Transfer(from, to, tokens);
        return true;
        //紀錄轉幣事件
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    //返回所有者批准給消費者賬戶 可以轉移的代幣數量
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed //B接到A授權的指令觸發
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        //bytes data 交易參數陣列
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        //紀錄事件-同意
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ETH 不能收幣
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
        //當次交易直接拒絕
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens所有者可以轉出任意別人發送的 ERC20 代幣
    // AnyERC20Token
    //------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}