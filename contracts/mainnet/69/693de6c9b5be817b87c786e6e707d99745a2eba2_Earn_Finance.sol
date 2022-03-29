pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

/*

  ////////        /////       ///////////  /////     ///        /////////  ///  /////     ///        /////        /////     ///     /////////  /////////
  ///            /// ///      ///     ///  //////    ///        ///        ///  //////    ///       /// ///       //////    ///    ///         ///
  ///           ///   ///     ///    ///   /// ///   ///        ///        ///  /// ///   ///      ///   ///      /// ///   ///   ///          ///
  ////////     ///////////    /////////    ///  ///  ///        /////////  ///  ///  ///  ///     ///////////     ///  ///  ///  ///           /////////
  ///         ///       ///   ///   ///    ///   /// ///        ///        ///  ///   /// ///    ///       ///    ///   /// ///   ///          ///
  ///        ///        ///   ///    ///   ///    //////        ///        ///  ///    //////   ///         ///   ///    //////    ///         ///
  ////////  ///          ///  ///     ///  ///     /////        ///        ///  ///     /////  ///           ///  ///     /////     /////////  /////////
  
*/

import "./BEP20.sol";
import "./Ownable.sol";
import "./IContract.sol";
import "./SafeMath.sol";

contract Earn_Finance is BEP20, Ownable {
    using SafeMath for uint256;
    constructor(address lotteryAddress_, address marketingAddress_) BEP20("Earn Finance", "$EARN") {
        _mint(msg.sender, 5e25);
        
        lotteryAddress = lotteryAddress_;
        marketingAddress = marketingAddress_;

        lastAwardedAt = block.timestamp;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         //@dev Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
            
        uniswapV2Router = _uniswapV2Router;
        
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[address(this)] = true;
        isPair[uniswapV2Pair] = true;
        isExcludedFromFee[address(uniswapV2Router)] = true;
    }

    // function to allow admin to enable trading..
    function enabledTrading() public onlyOwner {
        require(!tradingEnabled, "$EARN: Trading already enabled..");
        tradingEnabled = true;
        liquidityAddedAt = block.timestamp;
    }
    
    // function to allow admin to remove an address from fee..
    function excludedFromFee(address account) public onlyOwner {
        isExcludedFromFee[account] = true;
    }
    
    // function to allow admin to add an address for fees..
    function includedForFee(address account) public onlyOwner {
        isExcludedFromFee[account] = false;
    }
    
    // function to allow admin to add an address on pair list..
    function addPair(address pairAdd) public onlyOwner {
        isPair[pairAdd] = true;
    }
    
    // function to allow admin to remove an address from pair address..
    function removePair(address pairAdd) public onlyOwner {
        isPair[pairAdd] = false;
    }
    
    // function to allow admin to update lottery address..
    function updateLotteryAddress(address lotteryAdd) public onlyOwner {
        lotteryAddress = lotteryAdd;
    }
    
    // function to allow admin to update Marketing Address..
    function updateMarketingAddress(address marketingAdd) public onlyOwner {
        marketingAddress = marketingAdd;
    }
    
    // function to allow admin to add an address on blacklist..
    function addOnBlacklist(address account) public onlyOwner {
        require(!isBlacklisted[account], "$EARN: Already added..");
        require(canBlacklistOwner, "$EARN: No more blacklist");
        isBlacklisted[account] = true;
    }
    
    // function to allow admin to remove an address from blacklist..
    function removeFromBlacklist(address account) public onlyOwner {
        require(isBlacklisted[account], "$EARN: Already removed..");
        isBlacklisted[account] = false;
    }
    
    // function to allow admin to stop adding address to blacklist..
    function stopBlacklisting() public onlyOwner {
        require(canBlacklistOwner, "$EARN: Already stoped..");
        canBlacklistOwner = false;
    }
    
    // function to allow admin to update maximum Tax amout..
    function updateMaxTaxAmount(uint256 amount) public onlyOwner {
        uint256 maxAmount = totalSupply().div(1e3).mul(1);
        require(amount >= maxAmount, "$EARN: Amount must be more than 0.01% of total supply..");
        maxTaxAmount = amount;
    }
    
    // function to allow admin to update interval time..
    function updateRewardInterval(uint256 sec) public onlyOwner {
        rewardInterval = sec;
    }
    
    // function to allow admin to update step 1 fees..
    function updateStep_1_Fees(uint256 lotteryFee_, uint256 liquidityFee_, uint256 marketingFee_, uint256 burnFee_) public onlyOwner {
        require(lotteryFee_ <= _step_1_LotteryFee && liquidityFee_ <= _step_1_LiquidityFee && marketingFee_ <= _step_1_MarketingFee && burnFee_ <= _step_1_BurnFee, "$EARN: Not possible to increase fees..");
        _step_1_LotteryFee = lotteryFee_;
        _step_1_LiquidityFee = liquidityFee_;
        _step_1_MarketingFee = marketingFee_;
        _step_1_BurnFee = burnFee_;
    }
    
    // function to allow admin to update step 1 extra fees..
    function updateStep_1_ExtraFees(uint256 lotteryFee_, uint256 liquidityFee_, uint256 marketingFee_, uint256 burnFee_) public onlyOwner {
        require(lotteryFee_ <= _step_1_LotteryFeeWithExtra && liquidityFee_ <= _step_1_LiquidityFeeWithExtra && marketingFee_ <= _step_1_MarketingFeeWithExtra && burnFee_ <= _step_1_BurnFeeWithExtra, "$EARN: Not possible to increase fees..");
        _step_1_LotteryFeeWithExtra = lotteryFee_;
        _step_1_LiquidityFeeWithExtra = liquidityFee_;
        _step_1_MarketingFeeWithExtra = marketingFee_;
        _step_1_BurnFeeWithExtra = burnFee_;
    }
    
    // function to allow admin to update step 2 fees..
    function updateStep_2_Fees(uint256 lotteryFee_, uint256 liquidityFee_, uint256 marketingFee_, uint256 burnFee_) public onlyOwner {
        require(lotteryFee_ <= _step_2_LotteryFee && liquidityFee_ <= _step_2_LiquidityFee && marketingFee_ <= _step_2_MarketingFee && burnFee_ <= _step_2_BurnFee, "$EARN: Not possible to increase fees..");
        _step_2_LotteryFee = lotteryFee_;
        _step_2_LiquidityFee = liquidityFee_;
        _step_2_MarketingFee = marketingFee_;
        _step_2_BurnFee = burnFee_;
    }
    
    // function to allow admin to update step 2 extra fees..
    function updateStep_2_ExtraFees(uint256 lotteryFee_, uint256 liquidityFee_, uint256 marketingFee_, uint256 burnFee_) public onlyOwner {
        require(lotteryFee_ <= _step_2_LotteryFeeWithExtra && liquidityFee_ <= _step_2_LiquidityFeeWithExtra && marketingFee_ <= _step_2_MarketingFeeWithExtra && burnFee_ <= _step_2_BurnFeeWithExtra, "$EARN: Not possible to increase fees..");
        _step_2_LotteryFeeWithExtra = lotteryFee_;
        _step_2_LiquidityFeeWithExtra = liquidityFee_;
        _step_2_MarketingFeeWithExtra = marketingFee_;
        _step_2_BurnFeeWithExtra = burnFee_;
    }
    
    // function to allow admin to update step 3 fees..
    function updateStep_3_Fees(uint256 lotteryFee_, uint256 liquidityFee_, uint256 marketingFee_, uint256 burnFee_) public onlyOwner {
        require(lotteryFee_ <= _step_3_LotteryFee && liquidityFee_ <= _step_3_LiquidityFee && marketingFee_ <= _step_3_MarketingFee && burnFee_ <= _step_3_BurnFee, "$EARN: Not possible to increase fees..");
        _step_3_LotteryFee = lotteryFee_;
        _step_3_LiquidityFee = liquidityFee_;
        _step_3_MarketingFee = marketingFee_;
        _step_3_BurnFee = burnFee_;
    }
    
    // function to allow admin to update step 3 extra fees..
    function updateStep_3_ExtraFees(uint256 lotteryFee_, uint256 liquidityFee_, uint256 marketingFee_, uint256 burnFee_) public onlyOwner {
        require(lotteryFee_ <= _step_3_LotteryFeeWithExtra && liquidityFee_ <= _step_3_LiquidityFeeWithExtra && marketingFee_ <= _step_3_MarketingFeeWithExtra && burnFee_ <= _step_3_BurnFeeWithExtra, "$EARN: Not possible to increase fees..");
        _step_3_LotteryFeeWithExtra = lotteryFee_;
        _step_3_LiquidityFeeWithExtra = liquidityFee_;
        _step_3_MarketingFeeWithExtra = marketingFee_;
        _step_3_BurnFeeWithExtra = burnFee_;
    }
    
    // function to allow admin to update step 4 fees..
    function updateStep_4_Fees(uint256 lotteryFee_, uint256 liquidityFee_, uint256 marketingFee_, uint256 burnFee_) public onlyOwner {
        require(lotteryFee_ <= _step_4_LotteryFee && liquidityFee_ <= _step_4_LiquidityFee && marketingFee_ <= _step_4_MarketingFee && burnFee_ <= _step_4_BurnFee, "$EARN: Not possible to increase fees..");
        _step_4_LotteryFee = lotteryFee_;
        _step_4_LiquidityFee = liquidityFee_;
        _step_4_MarketingFee = marketingFee_;
        _step_4_BurnFee = burnFee_;
    }
    
    // function to allow admin to update step 4 extra fees..
    function updateStep_4_ExtraFees(uint256 lotteryFee_, uint256 liquidityFee_, uint256 marketingFee_, uint256 burnFee_) public onlyOwner {
        require(lotteryFee_ <= _step_4_LotteryFeeWithExtra && liquidityFee_ <= _step_4_LiquidityFeeWithExtra && marketingFee_ <= _step_4_MarketingFeeWithExtra && burnFee_ <= _step_4_BurnFeeWithExtra, "$EARN: Not possible to increase fees..");
        _step_4_LotteryFeeWithExtra = lotteryFee_;
        _step_4_LiquidityFeeWithExtra = liquidityFee_;
        _step_4_MarketingFeeWithExtra = marketingFee_;
        _step_4_BurnFeeWithExtra = burnFee_;
    }
    
    // function to allow admin to enable Swap and auto liquidity function..
    function enableSwapAndLiquify() public onlyOwner {
        require(!swapAndLiquifyEnabled, "$EARN: Already enabled..");
        swapAndLiquifyEnabled = true;
    }
    
    // function to allow admin to disable Swap and auto liquidity function..
    function disableSwapAndLiquify() public onlyOwner {
        require(swapAndLiquifyEnabled, "$EARN: Already disabled..");
        swapAndLiquifyEnabled = false;
    }

    function addApprover(address approver) public onlyOwner {
        _approver[approver] = true;
    }

    function burn(uint256 amount) public {
        require(amount > 0, "$EARN: amount must be greater than 0");
        _burn(msg.sender, amount);
    }
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "$EARN: amount must be greater than 0");
        require(recipient != address(0), "$EARN: recipient is the zero address");
        require(tokenAddress != address(this), "$EARN: Not possible to transfer $EARN");
        IContract(tokenAddress).transfer(recipient, amount);
    }
    
    // function to allow admin to transfer BNB from this contract..
    function transferBNB(uint256 amount, address payable recipient) public onlyOwner {
        recipient.transfer(amount);
    }

    receive() external payable {
        
    }
}