// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./AccessControl.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./ERC20Burnable.sol";

contract HOGToken is ERC20Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("HOGToken", "HOG") {
        _mint(_msgSender(), 10000000 * (10**decimals()));
    }

    function mint(address to, uint256 amount) public virtual {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "HOGToken: must have minter role to mint"
        );
        _mint(to, amount);
    }
}