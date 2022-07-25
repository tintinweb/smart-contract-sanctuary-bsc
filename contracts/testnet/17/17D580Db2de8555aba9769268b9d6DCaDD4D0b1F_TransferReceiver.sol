//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IToken is IERC20 {
    function getOwner() external view returns (address);
    function sell(uint256 amount) external returns (bool);
}

contract TransferReceiver {

    // Main Token
    IToken public immutable token;

    // Dev Fee Address
    address public dev;

    // Staking Token Address
    address public staking;

    // Allocations
    uint256 public devCut     = 10;
    uint256 public stakingCut = 100;
    uint256 private DENOM     = 110;

    modifier onlyOwner() {
        require(
            msg.sender == token.getOwner(),
            'Only Owner'
        );
        _;
    }

    constructor(
        address token_,
        address dev_,
        address staking_
    ) {
        token = IToken(token_);
        dev = dev_;
        staking = staking_;
    }

    function trigger() external {
        
        // ensure there is balance to distribute
        uint256 balance = token.balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        // split up dev and staking
        uint256 devAmount = ( balance * devCut ) / DENOM;
        uint256 stakingAmount = ( balance * stakingCut ) / DENOM;

        // send to dev and staking
        _send(dev, devAmount);    
        _send(staking, stakingAmount);
    }

    function setDev(address dev_) external onlyOwner {
        dev = dev_;
    }

    function setStaking(address staking_) external onlyOwner {
        staking = staking_;
    }

    function setAllocations(
        uint dev_,
        uint staking_
    ) external onlyOwner {

        // set amounts
        devCut = dev_;
        stakingCut = staking_;

        // set denominator
        DENOM = dev_ + staking_;
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
}