/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
abstract contract BEP20Interface {
    function totalSupply() public virtual view returns (uint);
    function balanceOf(address tokenOwnermNSD) public virtual view returns (uint balance);
    function allowance(address tokenOwnermNSD, address spendermNSD) public virtual view returns (uint remaining);
    function transfer(address to, uint tokens) public virtual returns (bool success);
    function approve(address spendermNSD, uint tokens) public virtual returns (bool success);
    function transferFrom(address from, address to, uint tokens) public virtual returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwnermNSD, address indexed spendermNSD, uint tokens);
}
contract Math {
    function safeAdd(uint x, uint b) public pure returns (uint y) {
        y = x + b;
        require(y >= x);
    }
    function safeSub(uint x, uint b) public pure returns (uint y) {
        require(b <= x);
        y = x - b;
    }
    function safeMul(uint x, uint b) public pure returns (uint y) {
        y = x * b;
        require(x == 0 || y / x == b);
    }
    function safeDiv(uint x, uint b) public pure returns (uint y) {
        require(b > 0);
        y = x / b;
    }
}
contract NewsDapp is BEP20Interface, Math {
    string public tokenNamemNSD = "NewsDapp";
    string public tokenSymbolmNSD = "$NSD";
    uint public _tokenSupplymNSD = 10000000000*10**9 * 10**9;
    mapping(address => uint) _balances;
    mapping(address => mapping(address => uint)) allowed;
    constructor() {
        _balances[msg.sender] = _tokenSupplymNSD;
        emit Transfer(address(0), msg.sender, _tokenSupplymNSD);
    }
     function name() public view virtual returns (string memory) {
        return tokenNamemNSD;
    }
    function symbol() public view virtual returns (string memory) {
        return tokenSymbolmNSD;
    }
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
    function totalSupply() public override view returns (uint) {
        return _tokenSupplymNSD;
    }
    function balanceOf(address tokenOwnermNSD) public override view returns (uint balance) {
        return _balances[tokenOwnermNSD];
    }
    function allowance(address tokenOwnermNSD, address spendermNSD) public override view returns (uint remaining) {
        return allowed[tokenOwnermNSD][spendermNSD];
    }
   function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function transfer(address to, uint tokens) public override returns (bool success) {
        _transfer(msg.sender, to, tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    function approve(address spendermNSD, uint tokens) public override returns (bool success) {
        allowed[msg.sender][spendermNSD] = tokens;
        emit Approval(msg.sender, spendermNSD, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        _transfer(from, to, tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    }