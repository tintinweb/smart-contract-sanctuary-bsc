// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";

contract PayGateway is Ownable {
    function withdrawEth(address payable add) public onlyOwner {
        uint256 amount = address(this).balance;
        add.transfer(amount);
    }

    function withdrawErc20(address token, address add) public onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(add, amount);
    }

    function payOrderEth(uint256 tgid, uint256 amount)
        external
        returns (uint256, uint256)
    {
        require(amount > 0xa, "too little payment...");
        uint256 amountTo = (amount * 8) / 10;
        to.transfer(amountTo);
        return (tgid, amount);
    }

    function changeTo(address payable add) public onlyOwner {
        to = add;
    }

    address payable public to;

    constructor(address payable _to) {
        to = _to;
    }
}