//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IToken is IERC20 {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
    function sell(uint256 amount) external returns (bool);
}

contract SellReceiver {

    // Main Token
    IToken public immutable token;

    // Dev Fee Address
    address public treasury;

    // Allocations
    uint256 public treasuryCut = 6;
    uint256 public burnCut     = 4;

    modifier onlyOwner() {
        require(
            msg.sender == token.getOwner(),
            'Only Owner'
        );
        _;
    }

    constructor(
        address token_,
        address treasury_
    ) {
        require(
            token_ != address(0) &&
            treasury_ != address(0),
            'Zero Check'
        );
        token = IToken(token_);
        treasury = treasury_;
    }

    function trigger() external {
        
        // ensure there is balance to distribute
        uint256 balance = token.balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        // split up dev and staking
        uint256 burnAmount = ( balance * burnCut ) / ( treasuryCut + burnCut );

        // burn remainder of tokens
        if (burnAmount > 0) {
            token.burn(burnAmount);
        }

        // sell remainder of tokens
        uint256 sellAmount = token.balanceOf(address(this));
        if (sellAmount > 0) {
            token.sell(sellAmount);
        }

        // send ETH to treasury
        _sendETH(treasury, address(this).balance);
    }

    function setTreasury(address treasury_) external onlyOwner {
        require(
            treasury_ != address(0),
            'Zero Check'
        );
        treasury = treasury_;
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function withdrawToken(IERC20 token_) external onlyOwner {
        token_.transfer(msg.sender, token_.balanceOf(address(this)));
    }

    function setAllocations(
        uint treasury_,
        uint burn_
    ) external onlyOwner {
        require(
            treasury_ > 0 || burn_ > 0,
            'Zero Check'
        );
        treasuryCut = treasury_;
        burnCut = burn_;
    }


    function _sendETH(address to, uint amount) internal {
        if (to == address(0)) {
            return;
        }
        if (amount > address(this).balance) {
            amount = address(this).balance;
        }
        if (amount == 0) {
            return;
        }
        (bool s,) = payable(to).call{value: amount}("");
        require(s, 'FAILURE ON SENDETH');
    }

    receive() external payable {}
}