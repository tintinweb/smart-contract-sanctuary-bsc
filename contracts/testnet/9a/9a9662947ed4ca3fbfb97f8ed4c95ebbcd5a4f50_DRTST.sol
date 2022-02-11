pragma solidity ^0.8.11;

import "./Ownable.sol";
import "./ERC20.sol";

contract DRTST is ERC20, Ownable { 
    uint256 private _totalSupply = 10000000;
    
    constructor() public ERC20("DRTST", "DRTST") { 
        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), _totalSupply * (10**18));
    }
 
    receive() external payable {
 
  	}
 
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._transfer(from, to, amount);
    }
}