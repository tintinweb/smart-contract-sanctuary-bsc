//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IToken is IERC20 {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

contract FeeReceiver {

    // Main Token
    IToken public immutable token;

    modifier onlyOwner() {
        require(
            msg.sender == token.getOwner(),
            'Only Owner'
        );
        _;
    }

    constructor(
        address token_
    ) {
        token = IToken(token_);
    }

    function trigger() external {
        
        // ensure there is balance to distribute
        uint256 balance = token.balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        token.burn(balance);
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function withdrawToken(IERC20 token_) external onlyOwner {
        token_.transfer(msg.sender, token_.balanceOf(address(this)));
    }

    receive() external payable {}
}