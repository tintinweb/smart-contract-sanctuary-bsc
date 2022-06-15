// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20Prismatic.sol";

/// @custom:security-contact [email protected]
contract CurvedMoney is ERC20Prismatic {
   constructor(address easing_, address repo_, address oracle_) ERC20Prismatic("Curved.Money", "CURVED", easing_, repo_, oracle_) { }
}