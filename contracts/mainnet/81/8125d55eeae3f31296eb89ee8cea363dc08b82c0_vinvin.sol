pragma solidity ^0.8.0;

import "./ERC20.sol";

contract vinvin is ERC20{

    constructor(string memory _name, string memory _symbol) ERC20( _name, _symbol){

        _mint(msg.sender, 1_000_000_000 * 1e18);
    }


}