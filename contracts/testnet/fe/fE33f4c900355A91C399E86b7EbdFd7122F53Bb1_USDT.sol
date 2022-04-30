// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ReentrancyGuard.sol";
import "./Ownable.sol";
import "./ERC20.sol";
contract USDT is Ownable, ERC20
{
    
    constructor() ERC20("Tether USD", "USDT" ) {
        
    }

    function mint(address account, uint256 amount) public onlyOwner{
        _mint(account, amount);
    }
    function burn(address account, uint256 share) public onlyOwner{
        _burn(account, share);
    }
}