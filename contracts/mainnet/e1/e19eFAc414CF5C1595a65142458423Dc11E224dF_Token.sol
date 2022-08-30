// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import "./ERC20.sol";

contract Token is ERC20 {
    using SafeMath for uint256;

    uint256 public maxSupply = 10000000000 * 10**18;

    constructor() {
        _initialize("Collabrx", "CLRX", 18, maxSupply);
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        if (
            !whiteListBot[sender] && !whiteListBot[recipient] && antiBotEnabled
        ) {
            revert("Anti Bot");
        }
         if(swapWhiteList && whiteListPool[recipient] && !whiteListBot[sender]) {
           revert("Anti Bot");
        }
        super._transfer(sender, recipient, amount);
    }

    // receive eth from uniswap swap
    receive() external payable {}
}