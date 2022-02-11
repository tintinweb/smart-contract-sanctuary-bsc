// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* Contract Imports */

//Remix style import
import { ERC20 } from "./ERC20.sol";
import { ERC20Burnable } from "./ERC20Burnable.sol";
import { SafeMath } from "./SafeMath.sol";
//Brownie style import
//import { ERC20 } from "./ERC20.sol";
//import { ERC20Burnable } from "./ERC20Burnable.sol";

contract FrostyChild is ERC20, ERC20Burnable {
    using SafeMath for uint;

    address bridge;

    constructor (address _bridge) ERC20("FROSTY", "FRST") {
        bridge = _bridge;
    }

    /**
    * @dev Only callable by account with access (gateway role)
    */

    function mint(
        address recipient,
        uint256 amount
        )
        public
        virtual
        onlyBridge
        {
        
        _mint(recipient, amount);
    }

    /**
    * @dev Only callable by account with access (gateway role)
    * @inheritdoc ERC20Burnable
    */
    function burn(
        uint256 amount
        )
        public
        override(ERC20Burnable)
        virtual
        onlyBridge
        {
        super.burn(amount);
    }

    /**
    * @dev Only callable by account with access (gateway role)
    * @inheritdoc ERC20Burnable
    */
    function burnFrom(
        address account,
        uint256 amount
        )
        public
        override(ERC20Burnable)
        virtual
        onlyBridge
        {
        super.burnFrom(account, amount);
    }

    modifier onlyBridge {
      require(msg.sender == bridge, "only bridge has access to Frosty child token function");
      _;
    }




}