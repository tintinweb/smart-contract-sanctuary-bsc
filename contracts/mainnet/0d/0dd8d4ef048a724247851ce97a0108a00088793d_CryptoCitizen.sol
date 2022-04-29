// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

contract CryptoCitizen is ERC20, Ownable {
    mapping(address => bool) public isBlacklisted;

    constructor() ERC20("Crypto Citizen", "CC") {
        _mint(msg.sender, 100000000 * (10**18));
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(!isBlacklisted[from], "Sender is blacklisted.");
        require(!isBlacklisted[to], "Receiver is blacklisted.");
        super._transfer(from, to, amount);
    }

    function blacklist(address _user, bool _value) public onlyOwner {
        isBlacklisted[_user] = _value;
    }
}