//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IToken is IERC20 {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

contract SellReceiver {

    // Main Token
    IToken public constant token = IToken(0x080BdCfaCB80552b9D68eB797712D7091f4C55F7);

    // PCS
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // Dev Fee Address
    address public treasury = 0x6D1CF0CDC893BDA9F742f3A7CD76Fa2dA8a8FCA5;

    // Entry Check
    bool public hasEntered;

    // Trigger Threshold
    uint256 public threshold = 3; // 1 = 0.01%, 10 = 0.1%

    modifier onlyOwner() {
        require(
            msg.sender == token.getOwner(),
            'Only Owner'
        );
        _;
    }

    function trigger() external {
        
        // ensure there is balance to distribute
        uint256 balance = token.balanceOf(address(this));
        uint256 _threshold = token.totalSupply() / (10_000 / threshold);
        if (balance < _threshold) {
            return;
        }

        // check for double entry
        if (hasEntered) {
            return;
        }
        hasEntered = true;

        // split up dev and staking
        uint256 burnAmount = balance / 2;

        // burn remainder of tokens
        if (burnAmount > 0) {
            token.burn(burnAmount);
        }

        // sell remainder of tokens
        uint256 sellAmount = token.balanceOf(address(this));
        if (sellAmount > 0) {
            
            address[] memory path = new address[](2);
            path[0] = address(token);
            path[1] = router.WETH();
            
            token.approve(address(router), sellAmount);
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                sellAmount, 1, path, treasury, block.timestamp + 100
            );

            delete path;
        }

        // reset entry
        hasEntered = false;
    }

    function setThreshold(uint newThreshold) external onlyOwner {
        require(
            newThreshold >= 1 && newThreshold <= 10,
            'Threshold Out Of Bounds'
        );
        threshold = newThreshold;
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

    function resetEntry(bool hasEntered_) external onlyOwner {
        hasEntered = hasEntered_;
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