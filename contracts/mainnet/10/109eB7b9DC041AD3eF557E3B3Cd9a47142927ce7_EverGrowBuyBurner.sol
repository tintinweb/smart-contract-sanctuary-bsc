//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";
import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

contract EverGrowBuyBurner is Ownable {

    // constants
    address public constant EGC = 0xC001BBe2B87079294C63EcE98BdD0a88D761434e;
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant dead = 0x000000000000000000000000000000000000dEaD;
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address[] private path;

    // last trigger
    uint256 public lastTrigger;

    // time interval in blocks
    uint256 public timeInterval = 1200;

    // amount of BUSD to buy back
    uint256 public amountToBuyBack = 500 * 10**18;

    constructor() {
        lastTrigger = block.number;
        path = new address[](3);
        path[0] = BUSD;
        path[1] = router.WETH();
        path[2] = EGC;
    }

    function resetTimer() external onlyOwner {
        lastTrigger = block.number;
    }

    function setTimerInPast(uint nBlocks) external onlyOwner {
        lastTrigger = block.number - nBlocks;
    }

    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    function withdrawETH() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function setAmountToBuyBack(uint256 amountToBuyBackPerTimePeriod) external onlyOwner {
        amountToBuyBack = amountToBuyBackPerTimePeriod;
    }

    function setTimeInterval(uint256 newTimeInterval) external onlyOwner {
        timeInterval = newTimeInterval;
    }

    function trigger() external {
        require(
            timePassed() >= timeInterval,
            'Too Soon'
        );

        // reset trigger
        lastTrigger = block.number;

        // amount to purchase
        uint256 amountToPurchase = amountToBuyBack;

        // sanity check
        uint256 balance = IERC20(BUSD).balanceOf(address(this));
        if (amountToPurchase > balance) {
            amountToPurchase = balance;
        }
        require(
            amountToPurchase > 0,
            'Zero Tokens'
        );

        // buy back and burn
        IERC20(BUSD).approve(address(router), amountToPurchase);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountToPurchase, 0, path, dead, block.timestamp + 1000);
    }

    function timePassed() public view returns (uint256) {
        return lastTrigger < block.number ? block.number - lastTrigger : 0;
    }

    receive() external payable {}
}