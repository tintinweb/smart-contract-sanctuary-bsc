//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IToken is IERC20 {
    function getOwner() external view returns (address);
}

interface IStaking {
    function distributor() external view returns (address);
}

contract SellReceiver {

    // Main Token
    IToken public immutable token;

    // Router
    IUniswapV2Router02 public router;
    address[] private path;

    // Dev Fee Address
    address public dev;

    // Staking Token Address
    address public staking;

    // Allocations
    uint256 public devCut     = 10;
    uint256 public stakingCut = 50;
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
        address staking_,
        address router_
    ) {
        token = IToken(token_);
        router = IUniswapV2Router02(router_);
        dev = dev_;
        staking = staking_;

        path = new address[](2);
        path[0] = token_;
        path[1] = router.WETH();
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

        // sell remainder of tokens
        uint256 tokensToSell = token.balanceOf(address(this));
        if (tokensToSell > 0) {
            token.approve(address(router), tokensToSell);
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokensToSell, 0, path, address(this), block.timestamp + 100
            );
        }
        if (address(this).balance > 0) {
            address distributor = IStaking(staking).distributor();
            if (distributor != address(0)) {
                (bool s,) = payable(distributor).call{value: address(this).balance}("");
                require(s);
            }
        }
    }

    function setDev(address dev_) external onlyOwner {
        dev = dev_;
    }

    function setStaking(address staking_) external onlyOwner {
        staking = staking_;
    }

    function setAllocations(
        uint dev_,
        uint staking_,
        uint reflection_
    ) external onlyOwner {

        // set amounts
        devCut = dev_;
        stakingCut = staking_;

        // set denominator
        DENOM = dev_ + staking_ + reflection_;
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