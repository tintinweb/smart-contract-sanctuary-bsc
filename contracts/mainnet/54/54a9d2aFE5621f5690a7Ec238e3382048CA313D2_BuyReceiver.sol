//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IToken is IERC20 {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

interface IStaking {
    function distributor() external view returns (address);
}

contract BuyReceiver {

    // Main Token
    IToken public immutable token;

    // Dev Fee Address
    address public treasury;

    // Allocations
    uint256 public treasuryCut = 1;
    uint256 public burnCut     = 3;
    uint256 private DENOM      = 4;

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
        token = IToken(token_);
        treasury = treasury_;
    }

    function trigger() external {
        
        // ensure there is balance to distribute
        uint256 balance = token.balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        // send treasury cut to treasury
        _send(treasury, ( balance * treasuryCut ) / DENOM);    

        // burn the rest of the tokens
        uint burnAmount = token.balanceOf(address(this));
        if (burnAmount > 0) {
            token.burn(burnAmount);
        }
    }

    function setTreasury(address treasury_) external onlyOwner {
        treasury = treasury_;
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function withdrawToken(IERC20 token_) external onlyOwner {
        require(
            address(token_) != address(token),
            'Cannot Withdraw PTX Tokens'
        );
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
        // set amounts
        treasuryCut = treasury_;
        burnCut = burn_;

        // set denominator
        DENOM = treasury_ + burn_;
    }

    function _send(address to, uint amount) internal {
        if (to == address(0)) {
            return;
        }
        if (amount > token.balanceOf(address(this))) {
            amount = token.balanceOf(address(this));
        }
        if (amount == 0) {
            return;
        }
        token.transfer(to, amount);
    }

    receive() external payable {}
}