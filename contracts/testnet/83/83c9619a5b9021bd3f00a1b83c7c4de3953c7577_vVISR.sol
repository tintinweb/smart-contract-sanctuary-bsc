// SPDX-License-Identifier: Unlicense

pragma solidity 0.7.6;

import "./ERC20Permit.sol";
import "./ERC20Snapshot.sol";

contract vVISR is ERC20Permit, ERC20Snapshot {

    address public owner;
    modifier onlyOwner {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) ERC20Permit(name) ERC20(name, symbol){
      owner = msg.sender;
      _setupDecimals(decimals);
    }

    function mint(address account, uint256 amount) onlyOwner external {
      _mint(account, amount);
    }

    function burn(address account, uint256 amount) onlyOwner external {
      _burn(account, amount);
    }

    function snapshot() onlyOwner external {
      _snapshot();
    }

    function transferOwnership(address newOwner) external onlyOwner {
      owner = newOwner;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
      super._beforeTokenTransfer(from, to, amount);
    }

}