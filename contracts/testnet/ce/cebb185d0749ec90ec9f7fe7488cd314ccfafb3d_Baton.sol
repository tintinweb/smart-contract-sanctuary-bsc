// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;
import "./w-ERC20.sol";
import "./Ownable.sol";

contract Baton is ERC20, Ownable {

    constructor() ERC20("Wand-Baton", "BTON") {
           
    }

     //Uses w-IERC20 to mint and burn

    /**
     * enables an address to mint / burn
     * @param controller the address to enable
   */
    function addController(address controller) external onlyOwner {

        _addController(controller);
    }

    /**
     * disables an address from minting / burning
     * @param controller the address to disbale
   */
    function removeController(address controller) external onlyOwner {
        
        _removeController(controller);
    }


    
           
}