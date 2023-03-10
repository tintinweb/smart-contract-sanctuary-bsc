// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Library.sol";


contract Eneftiverse is ERC20, ERC20Burnable, Ownable, Pausable {

    constructor() ERC20("Eneftiverse", "EVR") {
        _mint(msg.sender, 650000000 * 10 ** decimals());
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function notPausable() public onlyOwner {
        _notPausable();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal whenNotPaused override {
        super._beforeTokenTransfer(from, to, amount);
    }    
}