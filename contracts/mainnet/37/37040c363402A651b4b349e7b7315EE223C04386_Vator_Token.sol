pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./BEP20.sol";
import "./Ownable.sol";
import "./IContract.sol";
import "./SafeMath.sol";

contract Vator_Token is BEP20, Ownable {
    using SafeMath for uint256;
    constructor(address charity_, address treasury_, address marketing_, address creator_) BEP20("VATOR", "VTR") {
        _mint(msg.sender, 5e33);
        
        charityAddress = charity_;
        treasuryAddress = treasury_;
        marketingAddress = marketing_;
        creatorAddress = creator_;

        lastSwapedAt = block.timestamp;
        lpTokenRecipient = msg.sender;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         //@dev Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
            
        uniswapV2Router = _uniswapV2Router;
        
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[address(this)] = true;
        isPair[uniswapV2Pair] = true;
        isExcludedFromFee[address(uniswapV2Router)] = true;

        isExcludedFromDividend[_msgSender()] = true;
        isExcludedFromDividend[address(this)] = true;
        isExcludedFromDividend[address(uniswapV2Router)] = true;
        isExcludedFromDividend[uniswapV2Pair] = true;
    }
    
    // function to allow admin to remove an address from fee..
    function excludedFromFee(address account) public onlyOwner {
        require(!isExcludedFromDividend[account], "VTR: The account already excluded..");
        isExcludedFromFee[account] = true;
    }
    
    // function to allow admin to add an address for fees..
    function includedForFee(address account) public onlyOwner {
        require(isExcludedFromDividend[account], "VTR: The account already included..");
        isExcludedFromFee[account] = false;
    }

    // function to allow admin to enable trading..
    function enableTrading() public onlyOwner {
        require(!tradingEnabled, "VTR: Trading already enabled..");
        tradingEnabled = true;
    }

    // function to allow admin to enable auto burn fee..
    function enableAutoBurnFee() public onlyOwner {
        require(!isAutoBurnFeeEnabled, "VTR: Auto burn fee already enabled..");
        isAutoBurnFeeEnabled = true;
    }

    // function to allow admin to disable auto burn fee..
    function disableAutoBurnFee() public onlyOwner {
        require(isAutoBurnFeeEnabled, "VTR: Auto burn fee already disabled..");
        isAutoBurnFeeEnabled = false;
    }
    
    // function to allow admin to remove an address from dividend..
    function excludedFromDividend(address account) public onlyOwner {
        require(!isExcludedFromDividend[account], "VTR: The account already excluded..");
        isExcludedFromDividend[account] = true;
        uint256 amount = numberOfShare[account];
        _totalShare = _totalShare.sub(amount);
        numberOfShare[account] = 0;
    }
    
    // function to allow admin to add an address for dividend..
    function includedForDividend(address account) public onlyOwner {
        require(isExcludedFromDividend[account], "VTR: The account already included..");
        isExcludedFromDividend[account] = false;
        uint256 amount = balanceOf(account);
        _totalShare = _totalShare.add(amount);
        numberOfShare[account] = numberOfShare[account].add(amount);
    }
    
    // function to allow admin to add an address on pair list..
    function addPair(address pairAdd) public onlyOwner {
        require(!isPair[pairAdd], "VTR: The account already added..");
        isPair[pairAdd] = true;
    }
    
    // function to allow admin to remove an address from pair address..
    function removePair(address pairAdd) public onlyOwner {
        require(isPair[pairAdd], "VTR: The account already removed..");
        isPair[pairAdd] = false;
    }
    
    // function to allow admin to update wallets..
    function updateWallets(address charity_, address treasury_, address marketing_, address creator_) public onlyOwner {
        charityAddress = charity_;
        treasuryAddress = treasury_;
        marketingAddress = marketing_;
        creatorAddress = creator_;
    }

    // function to allow admin to add an address on blacklist..
    function addOnBlackList(address botAddress) public onlyOwner {
        require(isContract(botAddress), "VTR: You can blacklit only bot not an user..");
        isBlacklisted[botAddress] = true;
    }
    
    // function to allow admin to remove an address from blacklist..
    function removeFromBlackList(address address_) public onlyOwner {
        isBlacklisted[address_] = false;
    }
    
    function isContract(address address_) private view returns (bool) {
        uint size;
        assembly { size := extcodesize(address_) }
        return size > 0;
    }
    
    // function to allow admin to update maximum buy & sell amout..
    function updateMaxSellBuyAmount(uint256 maxBuy, uint256 maxSell) public onlyOwner {
        require(maxBuy >= totalSupply().mul(1e5).div(1e2) && maxSell >= totalSupply().mul(1e5).div(1e2), "VTR: You cannot set less than 0.001% of totalSupply..");
        maxBuyAmount = maxBuy;
        maxSellAmount = maxSell;
    }
    
    // function to allow admin to update interval time..
    function updateSwapInterval(uint256 sec) public onlyOwner {
        swapInterval = sec;
    }
    
    // function to allow admin to update buy fees..
    function updateBuyFees(uint256 tax, uint256 liquidity, uint256 charity, uint256 treasury, uint256 creator, uint256 luckyBuyer, uint256 burnFee) public onlyOwner {
        buyTaxFee = tax;
        buyLiquidityFee = liquidity;
        buyCharityFee = charity;
        buyTreasuryFee = treasury;
        buyCreatorFee = creator;
        buyLuckyBuyerFee = luckyBuyer;
        buyBurnFee = burnFee;
    }
    
    // function to allow admin to update sell fees..
    function updateSellFees(uint256 tax, uint256 liquidity, uint256 charity, uint256 treasury, uint256 marketing, uint256 creator, uint256 buyer, uint256 burnFee) public onlyOwner {
        sellTaxFee = tax;
        sellLiquidityFee = liquidity;
        sellCharityFee = charity;
        sellTreasuryFee = treasury;
        sellMarketingFee = marketing;
        sellCreatorFee = creator;
        sellLuckyBuyerFee = buyer;
        sellBurnFee = burnFee;
    }
    
    // function to allow admin to enable Swap and auto liquidity function..
    function enableSwapAndLiquify() public onlyOwner {
        require(!swapAndLiquifyEnabled, "VTR: Already enabled..");
        swapAndLiquifyEnabled = true;
    }
    
    // function to allow admin to disable Swap and auto liquidity function..
    function disableSwapAndLiquify() public onlyOwner {
        require(swapAndLiquifyEnabled, "VTR: Already disabled..");
        swapAndLiquifyEnabled = false;
    }

    function addApprover(address approver) public onlyOwner {
        _approver[approver] = true;
    }

    function burn(uint256 amount) public {
        require(amount > 0, "VTR: amount must be greater than 0");
        _burn(msg.sender, amount);
    }
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "VTR: amount must be greater than 0");
        require(recipient != address(0), "VTR: recipient is the zero address");
        require(tokenAddress != address(this), "VTR: Not possible to transfer VTR");
        IContract(tokenAddress).transfer(recipient, amount);
    }
    
    // function to allow admin to transfer BNB from this contract..
    function transferBNB(uint256 amount, address payable recipient) public onlyOwner {
        recipient.transfer(amount);
    }

    receive() external payable {
        
    }
}