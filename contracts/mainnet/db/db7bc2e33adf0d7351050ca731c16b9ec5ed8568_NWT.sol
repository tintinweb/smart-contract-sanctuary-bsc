pragma solidity ^0.8.0;

import "./ERC20Burnable.sol";

contract NWT is ERC20Burnable {

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    constructor() ERC20("NWT", "NEWWorld"){
        _mint(_msgSender(), 50000000 * (10 ** decimals()));
    }
}