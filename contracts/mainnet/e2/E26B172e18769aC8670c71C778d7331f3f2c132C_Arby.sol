//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./IUniswapV2Router02.sol";
import "./IERC20.sol";
import "./Ownable.sol";

interface IXUSD {
    function sell(uint256 amount) external returns (uint256);
}

contract Arby is Ownable {

    // token info    
    IUniswapV2Router02 constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant xUSD = 0x9f8BB16f49393eeA4331A39B69071759e54e16ea;
    address constant busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public ARBY = 0x80A124fBBC1fE3860B29fa1f9824d85216854D07;
    address public Recipient = 0x45F8F3a7A91e302935eB644f371bdE63D0b1bAc6;
    
    // paths
    address[] buyPath;
    address[] sellPath;

    // BUSD -> BNB
    address[] busdBNB;
    
    // cost to run cycle + incentive
    uint256 public gasCost = 24 * 10**14;
    
    constructor() {
        buyPath = new address[](2);
        buyPath[0] = router.WETH();
        buyPath[1] = xUSD;
        sellPath = new address[](2);
        sellPath[0] = xUSD;
        sellPath[1] = router.WETH();
        busdBNB = new address[](2);
        busdBNB[0] = busd;
        busdBNB[1] = router.WETH();
    }

    function setArby(address ARBY_) external onlyOwner {
        ARBY = ARBY_;
    }

    function setRecipient(address recipient_) external onlyOwner {
        Recipient = recipient_;
    }

    function setGasCost(uint256 gasCost_) external onlyOwner {
        gasCost = gasCost_;
    }

    function withdraw(address token) external onlyOwner {
        uint256 bal = IERC20(token).balanceOf(address(this));
        require(bal > 0, 'Zero Tokens');
        IERC20(token).transfer(msg.sender, bal);
    }
    
    function withdrawBNB() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value:address(this).balance}("");
        require(s, 'Failure on BNB Withdrawal');
    }
    
    function buyCycle() external payable {
        _buyCycle(msg.value);
    }
    
    function sellCycle() external payable {
        _sellCycle(msg.value);
    }

    function _buyCycle(uint256 amountBNB) private {
        _buyXUSD(amountBNB, true);
        _sellXUSD(IERC20(xUSD).balanceOf(address(this)), false);
        _swapBUSDForBNB(IERC20(busd).balanceOf(address(this)));
        (bool s,) = payable(ARBY).call{value: amountBNB + gasCost}("");
        require(s, 'F0');
        (bool s1,) = payable(Recipient).call{value: address(this).balance}("");
        require(s1, 'F1');
    }
    
    function _sellCycle(uint256 amount) private {
        _buyXUSD(amount, false);
        _sellXUSD(IERC20(xUSD).balanceOf(address(this)), true);
        (bool s,) = payable(ARBY).call{value: amount + gasCost}("");
        require(s, 'F0');
        (bool s1,) = payable(Recipient).call{value: address(this).balance}("");
        require(s1, 'F1');
    }

    function _swapBUSDForBNB(uint256 nBUSD) internal {
        IERC20(busd).approve(address(router), nBUSD);
        router.swapExactTokensForETH(
            nBUSD,
            0,
            busdBNB,
            address(this),
            block.timestamp + 30
        );
    }
    
    function _buyXUSD(uint256 amountBNB, bool PCS) internal {
        if (PCS) {
            // buy XUSD on PCS
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountBNB}(
                0,
                buyPath,
                address(this),
                block.timestamp + 30
            );
        } else {
            // buy XUSD with BNB
            (bool s,) = payable(xUSD).call{value: amountBNB}("");
            require(s, 'Failure on XUSD Purchase');
        }
    }

    function _sellXUSD(uint256 amount, bool PCS) internal {
        if (PCS) {
            IERC20(xUSD).approve(address(router), amount);
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amount,
                0,
                sellPath,
                address(this),
                block.timestamp + 30
            );
        } else {
            // sell XUSD
            IXUSD(xUSD).sell(amount);
        }
    }
    
    receive() external payable {}
    
}