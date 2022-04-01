pragma solidity ^0.8.0;

import "ERC20.sol";

contract BNBae_Coin is ERC20 {
    constructor(uint256 initialSupply) public ERC20 ("BNBae Coin", "BNBae"){
        _mint(msg.sender,initialSupply);
    }
}