// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20PresetMinterPauser.sol";
import "./Ownable.sol";

contract BitFightToken is Ownable, ERC20PresetMinterPauser  {
    
    mapping(address => bool) public wl;
    mapping(address => bool) public frozen_list;

    uint256 public lockupTimer = 1681851600; //Apr 18 2023 21:00:00 GMT+0000
    
    constructor() ERC20PresetMinterPauser("BitFightToken", "$BFT") {
         wl[msg.sender] = true;

        uint256 initialSupply = 1e7 * 1e18;
        _mint(msg.sender, initialSupply);
       
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(wl[to] || wl[from] || block.timestamp>lockupTimer , "locked");
        require(!frozen_list[from] , "blacklisted");
    }

    
     // lockup - true, unlock - false
    function changeWLState(address[] memory users, bool state) public onlyOwner{
        for (uint i = 0; i < users.length; i++) {
            wl[users[i]]=state;
        }
    }
    
    // lockup - true, unlock - false
    function changeFrozenState(address[] memory users, bool state) public onlyOwner{
        for (uint i = 0; i < users.length; i++) {
            frozen_list[users[i]]=state;
        }
    }

    // set unlock timestamp
    function changelockupTimer(uint256 _lockupTimer) public onlyOwner{
        lockupTimer = _lockupTimer;
    }

}