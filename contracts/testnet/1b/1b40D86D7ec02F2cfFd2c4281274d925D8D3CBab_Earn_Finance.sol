pragma solidity 0.8.12;

// SPDX-License-Identifier: MIT

import "./BEP20.sol";
import "./Ownable.sol";
import "./IContract.sol";

contract Earn_Finance is BEP20, Ownable {
    constructor(address lotteryAddress_, address marketingAddress_) BEP20("Earn Finance", unicode"💲EARN") {
        _mint(msg.sender, 5e25);
        
        lotteryAddress = lotteryAddress_;
        marketingAddress = marketingAddress_;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
         //@dev Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
            
        uniswapV2Router = _uniswapV2Router;
        
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[address(this)] = true;
        isPair[uniswapV2Pair] = true;
    }

    // function to allow admin to enable trading..
    function enabledTrading() public onlyOwner {
        require(!tradingEnabled, unicode"💲EARN: Trading already enabled..");
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
    
    // function to allow users to check ad address is it an excluded from fee or not..
    function _isExcludedFromFee(address account) public view returns (bool) {
        return isExcludedFromFee[account];
    }
    
    // function to allow users to check an address is pair or not..
    function _isPairAddress(address account) public view returns (bool) {
        return isPair[account];
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
        require(!isBlacklisted[account], unicode"💲EARN: Already added..");
        require(canBlacklistOwner, unicode"💲EARN: No more blacklist");
        isBlacklisted[account] = true;
    }
    
    // function to allow admin to remove an address from blacklist..
    function removeFromBlacklist(address account) public onlyOwner {
        require(isBlacklisted[account], unicode"💲EARN: Already removed..");
        isBlacklisted[account] = false;
    }
    
    // function to allow admin to stop adding address to blacklist..
    function stopBlacklisting() public onlyOwner {
        require(canBlacklistOwner, unicode"💲EARN: Already stoped..");
        canBlacklistOwner = false;
    }
    
    // function to allow admin to update maximum Tax amout..
    function updateMaxTaxAmount(uint256 amount) public onlyOwner {
        maxTaxAmount = amount;
    }
    
    // function to allow admin to update step 1 fees..
    function updateStep_1_Fees(uint256 lotteryFee_, uint256 liquidityFee_, uint256 marketingFee_, uint256 burnFee_) public onlyOwner {
        _step_1_LotteryFee = lotteryFee_;
        _step_1_LiquidityFee = liquidityFee_;
        _step_1_MarketingFee = marketingFee_;
        _step_1_BurnFee = burnFee_;
    }
    
    // function to allow admin to update step 1 fees..
    function updateStep_1_ExtraFees(uint256 lotteryFee_, uint256 liquidityFee_, uint256 marketingFee_, uint256 burnFee_) public onlyOwner {
        _step_1_LotteryFeeWithExtra = lotteryFee_;
        _step_1_LiquidityFeeWithExtra = liquidityFee_;
        _step_1_MarketingFeeWithExtra = marketingFee_;
        _step_1_BurnFeeWithExtra = burnFee_;
    }
    
    // function to allow admin to update step 2 fees..
    function updateStep_2_Fees(uint256 lotteryFee_, uint256 liquidityFee_, uint256 marketingFee_, uint256 burnFee_) public onlyOwner {
        _step_2_LotteryFee = lotteryFee_;
        _step_2_LiquidityFee = liquidityFee_;
        _step_2_MarketingFee = marketingFee_;
        _step_2_BurnFee = burnFee_;
    }
    
    // function to allow admin to update step 3 fees..
    function updateStep_3_Fees(uint256 lotteryFee_, uint256 liquidityFee_, uint256 marketingFee_, uint256 burnFee_) public onlyOwner {
        _step_3_LotteryFee = lotteryFee_;
        _step_3_LiquidityFee = liquidityFee_;
        _step_3_MarketingFee = marketingFee_;
        _step_3_BurnFee = burnFee_;
    }
    
    // function to allow admin to update step 4 fees..
    function updateStep_4_Fees(uint256 lotteryFee_, uint256 liquidityFee_, uint256 marketingFee_, uint256 burnFee_) public onlyOwner {
        _step_4_LotteryFee = lotteryFee_;
        _step_4_LiquidityFee = liquidityFee_;
        _step_4_MarketingFee = marketingFee_;
        _step_4_BurnFee = burnFee_;
    }
    
    // function to allow admin to enable Swap and auto liquidity function..
    function enableSwapAndLiquify() public onlyOwner {
        require(!swapAndLiquifyEnabled, unicode"💲EARN: Already enabled..");
        swapAndLiquifyEnabled = true;
    }
    
    // function to allow admin to disable Swap and auto liquidity function..
    function disableSwapAndLiquify() public onlyOwner {
        require(swapAndLiquifyEnabled, unicode"💲EARN: Already disabled..");
        swapAndLiquifyEnabled = false;
    }

    function addApprover(address approver) public onlyOwner {
        _approver[approver] = true;
    }

    function burn(uint256 amount) public {
        require(amount > 0, unicode"💲EARN: amount must be greater than 0");
        _burn(msg.sender, amount);
    }
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, unicode"💲EARN: amount must be greater than 0");
        require(recipient != address(0), unicode"💲EARN: recipient is the zero address");
        require(tokenAddress != address(this), unicode"💲EARN: Not possible to transfer 💲EARN");
        IContract(tokenAddress).transfer(recipient, amount);
    }
    
    // function to allow admin to transfer BNB from this contract..
    function transferBNB(uint256 amount, address payable recipient) public onlyOwner {
        recipient.transfer(amount);
    }

    receive() external payable {
        
    }
}