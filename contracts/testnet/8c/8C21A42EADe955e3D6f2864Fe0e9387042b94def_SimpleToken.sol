/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

contract SimpleToken {
    bool public pause;

    mapping (address => uint256) private _balances;

    string public constant _name = "simple";
    string public constant _symbol = "SPE";
    uint256 public constant _decimals = 18;
    uint256 public constant _totalSupply = 1000000 * 18 ** _decimals;

    constructor() {
        _balances[msg.sender] = _totalSupply;
    } 

    function getPause() public view returns(bool) {
        return pause;
    }

    function setPause(bool _status) public {
        pause = _status;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
}