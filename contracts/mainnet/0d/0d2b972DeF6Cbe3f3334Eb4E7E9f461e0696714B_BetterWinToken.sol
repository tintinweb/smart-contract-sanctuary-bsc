// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20PresetMinterPauser.sol";
import "./Ownable.sol";

contract BetterWinToken is Ownable, ERC20PresetMinterPauser  {
    
    mapping(address => bool) public lockup;

    uint256 public lockupTimer = 1711918800; //Sun Mar 31 2024 21:00:00 GMT+0000

    constructor() ERC20PresetMinterPauser("BetterWinToken", "BWIN") {
        uint256 initialSupply = 1000000000000000000000000000;
        _mint(msg.sender, initialSupply);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!lockup[from] || block.timestamp>lockupTimer , "Address is on the lockup list");
    }

    // lockup - true, unlock - false
    function changeAddressState(address[] memory users, bool state) public onlyOwner{
        for (uint i = 0; i < users.length; i++) {
            lockup[users[i]]=state;
        }
    }
    // set unlock timestamp
    function changelockupTimer(uint256 _lockupTimer) public onlyOwner{
        lockupTimer = _lockupTimer;
    }

}