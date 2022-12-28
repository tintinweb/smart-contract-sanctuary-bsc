//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IToken is IERC20 {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

contract BuyReceiver {

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
        
        // ensure there is balance to burn
        uint256 balance = token.balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        // burn token balance
        token.burn(balance);
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function withdrawToken(IERC20 token_) external onlyOwner {
        require(
            address(token_) != address(token),
            'Cannot Withdraw CRE Tokens'
        );
        token_.transfer(msg.sender, token_.balanceOf(address(this)));
    }

    receive() external payable {}
}