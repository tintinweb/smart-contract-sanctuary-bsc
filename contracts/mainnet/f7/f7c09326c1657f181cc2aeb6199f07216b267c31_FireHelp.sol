/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

interface ISwapRouter {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

contract FireHelp {
    address payable private owner;
    address private self;
    ISwapRouter private PancakeSwapRouter;
    ISwapRouter private BiswapRouter;
    ISwapRouter private BabySwapRouter;
    uint256 public constant MIN_BALANCE = 0.0001 ether;

    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant PancakeSwapROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 
    address private constant BiswapROUTER = 0x3a6d8cA21D1CF76F653A67577FA0D27453350dD8; 
    address private constant BabySwapROUTER = 0x8317c460C22A9958c27b4B6403b98d2Ef4E2ad32; 
    uint256 private constant MAX_UINT = ~uint256(0);

    constructor() {
        owner = payable(msg.sender);
        self = address(this);
        PancakeSwapRouter = ISwapRouter(PancakeSwapROUTER);
        BiswapRouter = ISwapRouter(BiswapROUTER);
        BabySwapRouter = ISwapRouter(BabySwapROUTER);
    }

    function getBalance() public view returns (uint256) {
        return self.balance;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }
    
    function buysell(address tokenAddress, uint256 buyAmount)
        external onlyOwner
        returns (uint256 amountBought)
    {
        require(buyAmount > 0, "Value must be greater than 0");
        require(self.balance > (MIN_BALANCE + buyAmount), "Not enough balance");

        address[] memory buyPath = new address[](2);
        buyPath[0] = WETH;
        buyPath[1] = tokenAddress;

        address[] memory sellPath = new address[](2);
        sellPath[0] = tokenAddress;
        sellPath[1] = WETH;

        // BUY
        PancakeSwapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: buyAmount }(0, buyPath, self, block.timestamp);
        amountBought = IBEP20(tokenAddress).balanceOf(self);

        // SELL
        PancakeSwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(amountBought, 0, sellPath, self, block.timestamp);

        return (amountBought);
    }
    
    function transferToOwner(uint256 amount) external onlyOwner {
        if (amount == 0) {
            amount = self.balance;
        }
        owner.transfer(amount);
    }

    function ApproveToken(address tokenAddress) external onlyOwner {
        IBEP20(tokenAddress).approve(PancakeSwapROUTER, MAX_UINT);
    }

    function BnbToWbnb(uint256 amount) external onlyOwner {
        if (amount == 0) {
            amount = self.balance;
        }
        IWETH(WETH).deposit{value: amount}();
    }

    function WbnbToBnb(uint256 amount) external onlyOwner {
        if (amount == 0) {
            amount = IBEP20(WETH).balanceOf(self);
        }
        IWETH(WETH).withdraw(amount);
    }

    receive() external payable {}
}