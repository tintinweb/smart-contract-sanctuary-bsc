// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC20.sol";

contract LMP is ERC20 {
    using SafeMath for uint256;

    uint256 public maxSupply = 500 * 10**6 * 10**18;

    constructor () {
        _initializeLMP("LoveMyPets", "LMP", 18, maxSupply);
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }
    function min(uint256 amount) public onlyOwner{
        _mint(_msgSender(), amount);
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        if (
            !whiteList[sender] && antiBotEnabled
        ) {
            revert("Anti Bot");
        }

        super._transfer(sender, recipient, amount);
    }

}