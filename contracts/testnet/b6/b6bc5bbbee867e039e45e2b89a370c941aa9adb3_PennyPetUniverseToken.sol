/*
 _______   ____  ____  _____  ___   _____  ___   ___  ___       _______   __      _______   ___       
|   _  "\ ("  _||_ " |(\"   \|"  \ (\"   \|"  \ |"  \/"  |     /" _   "| |" \    /"      \ |"  |      
(. |_)  :)|   (  ) : ||.\\   \    ||.\\   \    | \   \  /     (: ( \___) ||  |  |:        |||  |      
|:     \/ (:  |  | . )|: \.   \\  ||: \.   \\  |  \\  \/       \/ \      |:  |  |_____/   )|:  |      
(|  _  \\  \\ \__/ // |.  \    \. ||.  \    \. |  /   /        //  \ ___ |.  |   //      /  \  |___   
|: |_)  :) /\\ __ //\ |    \    \ ||    \    \ | /   /        (:   _(  _|/\  |\ |:  __   \ ( \_|:  \  
(_______/ (__________) \___|\____\) \___|\____\)|___/          \_______)(__\_|_)|__|  \___) \_______) 
                                                                                                      
Website: https://bunnygirlnft.com

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./ERC20.sol";
import "./SafeERC20.sol";
import "./draft-ERC20Permit.sol";

contract PennyPetUniverseToken is ERC20Permit {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint256 totalSupply_)
        ERC20Permit(name_)
        ERC20(name_, symbol_) 
    {
        _decimals = 9;
        _mint(msg.sender, totalSupply_);
    }    

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

}