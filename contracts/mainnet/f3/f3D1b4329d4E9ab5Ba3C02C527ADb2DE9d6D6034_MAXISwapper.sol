//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IUniswapV2Router02.sol";
import "./IERC20.sol";

interface IToken {
    function sellFeeRecipient() external view returns (address);
    function getOwner() external view returns (address);
}

/**
    PTX MAXI Swapper Contract
 */
contract MAXISwapper {

    // Token
    address public immutable token;
    address public immutable maxi;

    // DEX Router
    IUniswapV2Router02 public router;
    address[] private buyPath;

    // Buy Fee
    uint256 public buyFee = 4;

    modifier onlyOwner() {
        require(msg.sender == IToken(token).getOwner(), 'Only Token Owner');
        _;
    }

    constructor(
        address token_,
        address maxi_,
        address router_
    ) {
        require(
            token_ != address(0) &&
            maxi_ != address(0) &&
            router_ != address(0),
            'Zero Check'
        );
        
        // initialize token
        token = token_;
        maxi = maxi_;

        // initialize router
        router = IUniswapV2Router02(router_);

        // initialize buy path
        buyPath = new address[](2);
        buyPath[0] = router.WETH();
        buyPath[1] = token_;
    }

    function setBuyFee(uint newFee) external onlyOwner {
        require(
            newFee <= 20,
            'Fee Too High'
        );
        buyFee = newFee;
    }

    receive() external payable {
        uint fee = ( msg.value * buyFee ) / 100;

        (bool s,) = payable(IToken(token).sellFeeRecipient()).call{value: fee}("");
        require(s, 'Failure On MAXI Swapper BNB Transfer');

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(
            0, buyPath, maxi, block.timestamp + 10
        );
    }
}