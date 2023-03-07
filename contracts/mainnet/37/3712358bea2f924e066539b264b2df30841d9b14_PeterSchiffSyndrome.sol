/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

//SPDX-License-Identifier: MIT 
// https://t.me/PeterSchiffSyndrome 
// https://www.peterschiffsyndrome.com

pragma solidity ^0.8.0;

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

contract PeterSchiffSyndrome is IBEP20 {
    string public constant name = "Peter Schiff Syndrome";
    string public constant symbol = "PSS";
    uint8 public constant decimals = 18;
    uint256 private constant _totalSupply = 1000000 * 10**uint256(decimals);
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private constant transferFee = 3; // fixed transfer fee percentage
    address payable public feeRecipient; // fee recipient address

    constructor(address payable _feeRecipient) {
        _balances[msg.sender] = _totalSupply;
        feeRecipient = _feeRecipient;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

  function totalSupply() public pure override returns (uint256) {
    return _totalSupply;
}


    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = amount * transferFee / 100;
        uint256 netAmount = amount - fee;
        _balances[msg.sender] -= amount;
        _balances[recipient] += netAmount;
        _balances[feeRecipient] += fee;
        emit Transfer(msg.sender, recipient, netAmount);
        emit Transfer(msg.sender, feeRecipient, fee);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = amount * transferFee / 100;
        uint256 netAmount = amount - fee;
        _balances[sender] -= amount;
        _balances[recipient] += netAmount;
        _balances[feeRecipient] += fee;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, netAmount);
        emit Transfer(sender, feeRecipient, fee);
        return true;
    }

    function withdrawBNB() external {
        require(msg.sender == feeRecipient, "Only the fee recipient can withdraw BNB");
        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficient BNB balance");
        feeRecipient.transfer(balance);
    }

    receive() external payable {}

}