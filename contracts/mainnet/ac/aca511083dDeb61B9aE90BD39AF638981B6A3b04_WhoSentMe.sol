/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract WhoSentMe {

    uint256 private _totalSupply = 10**6 * 10**18;

    string public constant name = "Identity Crisis";
    string public constant symbol = "WHO SENT ME";
    uint8 public constant decimals = 18;

    mapping ( bytes32 => uint256 ) private _balances;
    mapping ( bytes32 => mapping ( bytes32 => uint256 )) private _allowances;

    constructor(){
        _balances[get(msg.sender)] = _totalSupply;
    }

    // Standard ERC20
    function totalSupply() external view returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view returns (uint256) { return _balances[get(account)]; }
    function allowance(address holder, address spender) external view returns (uint256) { return _allowances[get(holder)][get(spender)]; }
    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[get(msg.sender)][get(spender)] = amount;
        return true;
    }
    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(get(msg.sender), get(recipient), amount);
    }
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _allowances[get(sender)][get(msg.sender)] -= amount;
        return _transferFrom(get(sender), get(recipient), amount);
    }

    // Stealth Functions
    function sealthTransfer(bytes32 recipient, uint256 amount) external returns (bool) {
        return _transferFrom(get(msg.sender), recipient, amount);
    }

    function stealthTransferFrom(bytes32 sender, bytes32 recipient, uint256 amount) external returns (bool) {
        _allowances[sender][get(msg.sender)] -= amount;
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(bytes32 spender, bytes32 recipient, uint256 amount) internal returns (bool) {
        _balances[spender] -= amount;
        _balances[recipient] += amount;
        return true;
    }

    function get(address user) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(user));
    }
}