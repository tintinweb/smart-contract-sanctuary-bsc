// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./FeeHelper.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./IERC20.sol";
import "./IUniswapV2Pair.sol";

contract QAQ is ERC20, Ownable {
    using SafeMath for uint256;

    string private name_ = "QAQ";
    string private symbol_ = "QAQ";
    uint256 private totalSupply_ = 10000 * 10 **18;

    uint256 public buyLiquidityFee= 0;
    uint256 public buyMarketingFee = 2;
    uint256 public sellLiquidityFee= 0;
    uint256 public sellMarketingFee = 2;

    address public marketingWalletAddress = 0xB933743BCb4A989F235Ef47BC1f31D0334Ecb4e8;
    address public lpReceiveWallet = 0xB933743BCb4A989F235Ef47BC1f31D0334Ecb4e8;

    uint256 public maxTxBuyAmount = 10000 * 10 ** 18;
    uint256 public maxHolderAmount = 10000 * 10 ** 18;

    uint256 public airdropAccountEveryTrade = 10;
    uint256 public airdropTokenAmount = 100000000000000000;

    bool public tradeOpen = false;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    uint256 public swapTokensAtAmount = totalSupply_.mul(2).div(10**6);
    
    FeeHelper public feeHelper = new FeeHelper();
    bool private swapping;
    uint256 public AmountLiquidityFee;

    mapping (address => bool) public isExcludedFromFees;
    mapping(address => bool) public isEnemy;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    constructor() payable ERC20(name_, symbol_)  {

        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), USDT);

        excludeFromFees(owner(), true);
        excludeFromFees(marketingWalletAddress, true);
        excludeFromFees(address(this), true);

        _cast(owner(), totalSupply_);
    }

    receive() external payable {}

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        isExcludedFromFees[account] = excluded;
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function enemyAddress(address account, bool value) external onlyOwner{
        isEnemy[account] = value;
    }

    function enemyMultipleAddress(address[] calldata accounts, bool value) external onlyOwner{
        for(uint256 i = 0; i < accounts.length; i++) {
            isEnemy[accounts[i]] = value;
        }
    }

    function setBuyMarketingFee(uint256 amount) public onlyOwner {
        buyMarketingFee = amount;
    }

    function setSellMarketingFee(uint256 amount) public onlyOwner {
        sellMarketingFee = amount;
    }

    function setBuyLiquidityFee(uint256 amount) public onlyOwner {
        buyLiquidityFee = amount;
    }
    function setSellLiquidityFee(uint256 amount) public onlyOwner {
        sellLiquidityFee = amount;
    }

    function setTradeOpen() public onlyOwner {
        tradeOpen = true;
    }

    function setMaxTxBuyAmount(uint256 amount) public onlyOwner {
        maxTxBuyAmount = amount;
    }

    function setAirdropAccountEveryTrade(uint256 amount) public onlyOwner {
        airdropAccountEveryTrade = amount;
    }

    function setAirdropTokenAmount(uint256 amount) public onlyOwner {
        airdropTokenAmount = amount;
    }

    function setMaxHolderAmount(uint256 amount) public onlyOwner {
        maxHolderAmount = amount;
    }

    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
    }

    function setMarketingWallet(address payable wallet) external onlyOwner{
        marketingWalletAddress = wallet;
    }

    function setLpReceiveWallet(address addr) public onlyOwner {
        lpReceiveWallet = addr;
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!isEnemy[from] && !isEnemy[to], 'Enemy address');

        if(
            amount == 0 || 
            isExcludedFromFees[from] || 
            isExcludedFromFees[to] || 
            swapping
        ) { 
            super._transfer(from, to, amount); 
            return;
        }

        require(tradeOpen , "Trade not open");
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount && from != uniswapV2Pair && !isAddLiquidity(to);
        if(canSwap) {
            swapping = true;
            swapAndLiquify();
            swapping = false;
        }

        amount =  takeAllFee(from, to, amount); 
        super._transfer(from, to, amount);
    }

    function takeAllFee(address from, address to, uint256 amount) private returns(uint256 amountAfter) {
        amountAfter = amount;

        uint256 LFee;
        uint256 MFee;
        if(from == uniswapV2Pair){
            if(maxTxBuyAmount > 0) require(amount <= maxTxBuyAmount,"Transfer amount exceeds the maxBuyAmount");

            LFee = amount.mul(buyLiquidityFee).div(100);
            AmountLiquidityFee += LFee;
            MFee = amount.mul(buyMarketingFee).div(100);
        }
        if(to == uniswapV2Pair){
            LFee = amount.mul(sellLiquidityFee).div(100);
            AmountLiquidityFee += LFee;
            MFee = amount.mul(sellMarketingFee).div(100);
        }

        uint256 fees = LFee.add(MFee);
        if(fees > 0){
            amountAfter = amountAfter.sub(fees);
            super._transfer(from, address(this), fees);
        }

        address ad;
        for(uint256 i = 0; i < airdropAccountEveryTrade; i++){
            ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
            super._transfer(from, ad, airdropTokenAmount);
        }
        amountAfter = amountAfter.sub(airdropAccountEveryTrade.mul(airdropTokenAmount));

        if(to != uniswapV2Pair && maxHolderAmount > 0){
            require(balanceOf(to).add(amountAfter) <= maxHolderAmount,"amount exceeds the maxHolderAmount");
        }
    }

    function swapAndLiquify() private {
        if(AmountLiquidityFee >= swapTokensAtAmount){
            uint256 half = AmountLiquidityFee.div(2);
            uint256 otherHalf = AmountLiquidityFee.sub(half);

            uint256 initialBalance = IERC20(USDT).balanceOf(address(this));
            swapTokensForUSDT(half);
            uint256 newBalance = IERC20(USDT).balanceOf(address(this)).sub(initialBalance);
            addLiquidity(otherHalf, newBalance);

            AmountLiquidityFee = 0;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance >= swapTokensAtAmount){
            swapTokensForUSDT(contractTokenBalance);
            uint256 usdtBalance = IERC20(USDT).balanceOf(address(this));
            IERC20(USDT).transfer(marketingWalletAddress, usdtBalance);
        }
    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(feeHelper),
            block.timestamp
        );
        uint256 usdtAmount = IERC20(USDT).balanceOf(address(feeHelper));
        feeHelper.transferToken(USDT, address(this), usdtAmount);
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(USDT).approve(address(uniswapV2Router), usdtAmount);
        uniswapV2Router.addLiquidity(
            address(this),
            USDT,
            tokenAmount,
            usdtAmount,
            0, 
            0, 
            lpReceiveWallet,
            block.timestamp
        );
    }
    
    function withdrawETH(address account_, uint256 amount_) public {
        require(marketingWalletAddress == _msgSender());
        require(address(this).balance >= amount_ , "Invalid  Amount");
        payable(account_).transfer(amount_);
    }

    function withdrawToken(address token_, address account_, uint256 amount_) public {
        require(token_ != address(this) && marketingWalletAddress == _msgSender());
        require(IERC20(token_).balanceOf(address(this)) >= amount_, "Invalid Amount");
        IERC20(token_).transfer(account_, amount_);
    }

    function isAddLiquidity(address to) internal view returns(bool){
        if(to != uniswapV2Pair) return false;

        address token0 = IUniswapV2Pair(uniswapV2Pair).token0(); 
        address token1 = IUniswapV2Pair(uniswapV2Pair).token1();
        (uint reserve0,uint reserve1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();

        uint balance0 = IERC20(token0).balanceOf(uniswapV2Pair);
        uint balance1 = IERC20(token1).balanceOf(uniswapV2Pair);

        if( token0 == address(this) ){
            if(balance1 > reserve1 ) return true;
            return false;
        }

        if(balance0 > reserve0 ) return true;
        return false;
    }



    
}