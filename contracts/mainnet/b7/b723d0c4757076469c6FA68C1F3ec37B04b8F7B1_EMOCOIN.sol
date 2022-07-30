//  ______ __  __  ____   _____ ____ _____ _   _ 
// |  ____|  \/  |/ __ \ / ____/ __ \_   _| \ | |
// | |__  | \  / | |  | | |   | |  | || | |  \| |
// |  __| | |\/| | |  | | |   | |  | || | | . ` |
// | |____| |  | | |__| | |___| |__| || |_| |\  |
// |______|_|  |_|\____/ \_____\____/_____|_| \_|
// website: https://www.emocoin.org/
// twitter: https://twitter.com/EMOCoinOrg
// telegram: https://t.me/EmoCoinOrg

// SPDX-License-Identifier: MIT

import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IUniswapV2Router02.sol";
import "./EMOCOINDividendTracker.sol";
import "./IUniswapV2Factory.sol";
import "./IAntiBot.sol";

pragma solidity ^0.8.0;

contract EMOCOIN is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    EMOCOINDividendTracker public dividendTracker;
    IAntiBot antibot;
    bool antibotEnabled = true;

    address public uniswapV2Pair;
    address public rewardToken = 0x2859e4544C4bB03966803b044A93563Bd2D0DD4D;
    address public marketingWalletAddress1 = 0x4388DDbF359e9211beCbd5114227FE887e73CeEC;
    address public marketingWalletAddress2 = 0xF37B53b28B5AD9B4f79f545b751Ad3cc3b40faf5;

    uint256 public gasForProcessing;
    uint256 public swapTokensAtAmount;
    uint256 public tokenRewardsFee = 2;
    uint256 public liquidityFee = 1;
    uint256 public marketingFee = 2;
    uint256 public burnFee = 1;
    uint256 public totalFees;

    bool private swapping;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        uint256 minimumTokenBalanceForDividends_
    ) payable ERC20(name_, symbol_) {
        totalFees = tokenRewardsFee.add(liquidityFee).add(marketingFee).add(burnFee);
        swapTokensAtAmount = totalSupply_.mul(2).div(10**6); // 0.002%
        gasForProcessing = 300000;

        dividendTracker = new EMOCOINDividendTracker();
        dividendTracker.initialize(rewardToken,minimumTokenBalanceForDividends_);

        
        // create  pancake pair
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(address(0xdead));
        dividendTracker.excludeFromDividends(address(uniswapV2Router));

        excludeFromFees(owner(), true);
        excludeFromFees(marketingWalletAddress1, true);
        excludeFromFees(marketingWalletAddress2, true);
        excludeFromFees(address(this), true);
        
        _mint(owner(), totalSupply_);
    }

    receive() external payable {}

    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
        swapTokensAtAmount = amount;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "EMOCOIN: Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function setMarketingWallet(address payable wallet1,address payable wallet2) external onlyOwner {
        marketingWalletAddress1 = wallet1;
        marketingWalletAddress2 = wallet2;
    }

    function setTokenRewardsFee(uint256 value) external onlyOwner {
        tokenRewardsFee = value;
        totalFees = tokenRewardsFee.add(liquidityFee).add(marketingFee).add(burnFee);
        require(totalFees <= 25, "Total fee is over 25%");
    }

    function setLiquiditFee(uint256 value) external onlyOwner {
        liquidityFee = value;
        totalFees = tokenRewardsFee.add(liquidityFee).add(marketingFee).add(burnFee);
        require(totalFees <= 25, "Total fee is over 25%");
    }

    function setMarketingFee(uint256 value) external onlyOwner {
        marketingFee = value;
        totalFees = tokenRewardsFee.add(liquidityFee).add(marketingFee).add(burnFee);
        require(totalFees <= 25, "Total fee is over 25%");
    }
    function setBurnFee(uint256 value) external onlyOwner {
        burnFee = value;
        totalFees = burnFee.add(tokenRewardsFee).add(liquidityFee).add(marketingFee);
        require(totalFees <= 25, "Total fee is over 25%");
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "EMOCOIN: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        if (value) {
            dividendTracker.excludeFromDividends(pair);
        }
    }

    function setAnitbotEnabled(bool enabled) public onlyOwner {
        antibotEnabled = enabled;
    }
    
    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(
            newValue >= 200000 && newValue <= 600000,
            "EMOCOIN: gasForProcessing must be between 200,000 and 500,000"
        );
        gasForProcessing = newValue;
    }
    function updateAnitbot(address newAddress) external onlyOwner {
        antibot = IAntiBot(newAddress);
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function updateMinimumTokenBalanceForDividends(uint256 amount) external onlyOwner {
        dividendTracker.updateMinimumTokenBalanceForDividends(amount);
    }

    function getMinimumTokenBalanceForDividends() external view returns (uint256) {
        return dividendTracker.minimumTokenBalanceForDividends();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account) public view returns (uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    function isExcludedFromDividends(address account) public view returns (bool) {
        return dividendTracker.isExcludedFromDividends(account);
    }

    function getAccountDividendsInfo(address account) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) public {
        dividendTracker.process(gas);
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        if (antibotEnabled) {
            antibot.check(from,to,amount);
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap && !swapping && !automatedMarketMakerPairs[from] && from != owner() && to != owner()) {

            swapping = true;
            uint256 marketingTokens = contractTokenBalance.mul(marketingFee).div(totalFees);
            swapAndSendToFee(marketingTokens);

            uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
            swapAndLiquify(swapTokens);

            uint256 dividendTokens = contractTokenBalance.mul(tokenRewardsFee).div(totalFees);
            swapAndSendDividends(dividendTokens);

            _burn(address(this),balanceOf(address(this)));
            swapping = false;
        }

        bool takeFee = !swapping;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 fees = amount.mul(totalFees).div(100);
            amount = amount.sub(fees);
            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if (!swapping) {
            uint256 gas = gasForProcessing;
            try dividendTracker.process(gas) {} catch {}
        }
    }

    function swapAndSendToFee(uint256 tokens) private {
        uint256 initialCAKEBalance = IERC20(rewardToken).balanceOf(address(this));

        swapTokensForCake(tokens);
        uint256 newBalance = (IERC20(rewardToken).balanceOf(address(this))).sub(initialCAKEBalance);

        uint256 halfBalance = newBalance.div(2);
        IERC20(rewardToken).transfer(marketingWalletAddress1, halfBalance);
        IERC20(rewardToken).transfer(marketingWalletAddress2, newBalance - halfBalance);
    }

    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForCake(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = rewardToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }

    function swapAndSendDividends(uint256 tokens) private {
        swapTokensForCake(tokens);
        uint256 dividends = IERC20(rewardToken).balanceOf(address(this));
        bool success = IERC20(rewardToken).transfer(address(dividendTracker), dividends);

        if (success) {
            dividendTracker.distributeCAKEDividends(dividends);
        }
    }
}