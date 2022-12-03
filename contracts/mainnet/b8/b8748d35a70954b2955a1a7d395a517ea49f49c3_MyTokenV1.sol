// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import './Initializable.sol';
import './ERC20Upgradeable.sol';
import './UUPSUpgradeable.sol';
import './OwnableUpgradeable.sol';

contract MyTokenV1 is Initializable, ERC20Upgradeable, UUPSUpgradeable, OwnableUpgradeable {
    function initialize() initializer public {
      __ERC20_init("TEST12", "TEST12");
      __Ownable_init();
      __UUPSUpgradeable_init();

      _mint(msg.sender, 1000 * 10 ** decimals());
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function _authorizeUpgrade(address) internal override onlyOwner {}

    
}