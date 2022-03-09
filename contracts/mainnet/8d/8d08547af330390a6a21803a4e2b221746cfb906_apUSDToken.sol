// SPDX-License-Identifier: MIT

//     ___                         __ 
//    /   |  _____________  ____  / /_
//   / /| | / ___/ ___/ _ \/ __ \/ __/
//  / ___ |(__  |__  )  __/ / / / /_  
// /_/  |_/____/____/\___/_/ /_/\__/  
// 
// 2022 - Assent Protocol

pragma solidity 0.8.11;

import "./ERC20Permit.sol";
import "./ERC20Burnable.sol";
import "./AccessControl.sol";
import "./Pausable.sol";
import "./SafeERC20.sol";

contract apUSDToken is
    ERC20Burnable,
    ERC20Permit,
    AccessControl,
    Pausable
{
    using SafeERC20 for IERC20;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant RESCUER_ROLE = keccak256("RESCUER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor() ERC20("Assent Protocol USD Token", "APUSD") ERC20Permit("Assent Protocol") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(RESCUER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address account, uint256 amount) public returns (bool) {
        _burn(account, amount);
        return true;
    }    

    function rescueTokens(IERC20 token, uint256 value)
        external
        onlyRole(RESCUER_ROLE)
    {
        token.transfer(msg.sender, value);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
}