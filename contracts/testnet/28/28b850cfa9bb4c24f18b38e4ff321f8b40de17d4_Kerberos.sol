/**
 *Submitted for verification at BscScan.com on 2022-04-13
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Kerberos {
    mapping(address => uint256) private _balances;

    function credit(address to, uint256 amount) public virtual returns (bool) {
        // todo: only for the owner
        address owner = _msgSender();
        require(owner != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeCredit(to, amount);
        _balances[to] += amount;
        emit Credit(to, amount);
        _afterCredit(to, amount);
        return true;
    }

    function balanceOf(address account)
        public
        view
        virtual
        returns (uint256)
    {
        return _balances[account];
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _beforeCredit(address to, uint256 amount) internal virtual {}
    function _afterCredit(address to, uint256 amount) internal virtual {}
    event Credit(address indexed to, uint256 value);
}