/*
Retro Neko

Total Supply:
    100,000,000,000 $RNK

Taxes:
    Buy Tax:  8.0%
        1.0% Auto Liquidity
        2.0% Team
        3.0% Marketing
        0.0% Staking
        2.0% War

    Sell Tax: 10.0%
        1.0% Auto Liquidity
        2.0% Team
        3.0% Marketing
        0.0% Staking
        4.0% War

Features:
    Manual Blacklist Function
    
 *
 */
 
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract RetroNeko is ERC20, Ownable {
    struct Fees {
        uint256 liquidityFeesPerTenThousand;
        uint256 teamFeesPerTenThousand;
        uint256 providerFeesPerTenThousand;
        uint256 marketingFeesPerTenThousand;
        uint256 stakingFeesPerTenThousand;
        uint256 warFeesPerTenThousand;
    }
    
    address private _router;

    mapping (address => bool) private _isAutomatedMarketMakerPairs;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isBlacklisted;
    
    bool private _isBuying;
    Fees private _buyFees;
    Fees private _sellFees;

    uint256 private _swapThreshold;
    uint256 private _gasForProcessing;

    address private _teamWallet;
    address private _marketingWallet;
    address private _stakingWallet;
    address private _warWallet;

    bool private _inSwap;
    modifier swapping()
    {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    bool private _tradingEnabled;
    bool private _takeFeesEnabled;
    bool private _swapEnabled;

    uint256 private _deadBlocks;
    uint256 private _launchedAt;
    
    mapping (address => bool) private _isExcludedFromSwap;

    event TradingEnabled(bool isEnabled);
    event TakeFeesEnabled(bool isEnabled);
    event SwapEnabled(bool isEnabled);
    event UniswapV2RouterUpdated(address indexed previousAddress, address indexed newAddress);
    event TeamWalletUpdated(address indexed previousWallet, address indexed newWallet);
    event MarketingWalletUpdated(address indexed previousWallet, address indexed newWallet);
    event StakingWalletUpdated(address indexed previousWallet, address indexed newWallet);
    event WarWalletUpdated(address indexed previousWallet, address indexed newWallet);
    event LiquidityBuyFeesUpdated(uint256 previousFeesPerTenThousand, uint256 newFeesPerTenThousand);
    event TeamBuyFeesUpdated(uint256 previousFeesPerTenThousand, uint256 newFeesPerTenThousand);
    event MarketingBuyFeesUpdated(uint256 previousFeesPerTenThousand, uint256 newFeesPerTenThousand);
    event StakingBuyFeesUpdated(uint256 previousFeesPerTenThousand, uint256 newFeesPerTenThousand);
    event WarBuyFeesUpdated(uint256 previousFeesPerTenThousand, uint256 newFeesPerTenThousand);
    event BuyFeesUpdated(
        uint256 previousLiquidityFeesPerTenThousand, uint256 newLiquidityFeesPerTenThousand,
        uint256 previousTeamFeesPerTenThousand, uint256 newTeamFeesPerTenThousand,
        uint256 previousMarketingFeesPerTenThousand, uint256 newMarketingFeesPerTenThousand,
        uint256 previousStakingFeesPerTenThousand, uint256 newStakingFeesPerTenThousand,
        uint256 previousWarFeesPerTenThousand, uint256 newWarFeesPerTenThousand);
    event LiquiditySellFeesUpdated(uint256 previousFeesPerTenThousand, uint256 newFeesPerTenThousand);
    event TeamSellFeesUpdated(uint256 previousFeesPerTenThousand, uint256 newFeesPerTenThousand);
    event MarketingSellFeesUpdated(uint256 previousFeesPerTenThousand, uint256 newFeesPerTenThousand);
    event StakingSellFeesUpdated(uint256 previousFeesPerTenThousand, uint256 newFeesPerTenThousand);
    event WarSellFeesUpdated(uint256 previousFeesPerTenThousand, uint256 newFeesPerTenThousand);
    event SellFeesUpdated(
        uint256 previousLiquidityFeesPerTenThousand, uint256 newLiquidityFeesPerTenThousand,
        uint256 previousTeamFeesPerTenThousand, uint256 newTeamFeesPerTenThousand,
        uint256 previousMarketingFeesPerTenThousand, uint256 newMarketingFeesPerTenThousand,
        uint256 previousStakingFeesPerTenThousand, uint256 newStakingFeesPerTenThousand,
        uint256 previousWarFeesPerTenThousand, uint256 newWarFeesPerTenThousand);
    event FeesSentToWallet(address indexed wallet, uint256 amount);
    event ExcludedFromFees(address indexed account, bool isExcluded);
    event ExcludedFromSwap(address indexed account, bool isExcluded);
    event AutomatedMarketMakerPairSet(address indexed pair, bool indexed value);
    event GasForProcessingUpdated(uint256 indexed oldValue, uint256 indexed newValue);
    event SwappedAndLiquified(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    
    constructor(
        address newRouter,
        address newTeamWallet,
        address newMarketingWallet,
        address newStakingWallet,
        address newWarWallet) ERC20("RetroNeko", "RNK") {
        _tradingEnabled = false;
        _takeFeesEnabled = true;
        _swapEnabled = true;
        
        _router = newRouter;
    	_teamWallet = newTeamWallet;
    	_marketingWallet = newMarketingWallet;
    	_stakingWallet = newStakingWallet;
    	_warWallet = newWarWallet;

        // Create a uniswap pair for this new token
        IUniswapV2Router02 routerObject = IUniswapV2Router02(_router);
        address pair = IUniswapV2Factory(routerObject.factory()).createPair(address(this), routerObject.WETH());
        _setAutomatedMarketMakerPair(pair, true);
        
        _swapThreshold = 50_000_000 * 10 ** decimals(); // 50M $RNK ( 0.05% )
        _gasForProcessing = 300_000; // 300K

        // Buy fees
        _buyFees.liquidityFeesPerTenThousand = 100; // 1.00%
        _buyFees.teamFeesPerTenThousand = 200; // 2.00%
        _buyFees.marketingFeesPerTenThousand = 300; // 3.00%
        _buyFees.stakingFeesPerTenThousand = 0; // 0.00%
        _buyFees.warFeesPerTenThousand = 200; // 2.00%

        // Sell fees
        _sellFees.liquidityFeesPerTenThousand = 100; // 1.00%
        _sellFees.teamFeesPerTenThousand = 200; // 2.00%
        _sellFees.marketingFeesPerTenThousand = 300; // 3.00%
        _sellFees.stakingFeesPerTenThousand = 0; // 0.00%
        _sellFees.warFeesPerTenThousand = 400; // 4.00%
        
        _mint(owner(), 100_000_000_000 * 10 ** decimals()); // 100B $RNK
    }
    
    receive() external payable {
  	}

    function isTradingEnabled() external view returns (bool) {
        return _tradingEnabled;
    }

    function isTakeFeesEnabled() external view returns (bool) {
        return _takeFeesEnabled;
    }

    function isSwapEnabled() external view returns (bool) {
        return _swapEnabled;
    }

    function router() external view returns (address) {
        return _router;
    }

    function isAutomatedMarketMakerPair(address account) external view returns (bool) {
        return _isAutomatedMarketMakerPairs[account];
    }

    function isExcludedFromFees(address account) external view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function isExcludedFromSwap(address account) external view returns (bool) {
        return _isExcludedFromSwap[account];
    }

    function isBlacklisted(address account) external view returns (bool) {
        return _isBlacklisted[account];
    }

    function buyFees() public view returns (
        uint256 liquidityFeesPerTenThousand,
        uint256 teamFeesPerTenThousand,
        uint256 marketingFeesPerTenThousand,
        uint256 stakingFeesPerTenThousand,
        uint256 warFeesPerTenThousand,
        uint256 totalFeesPerTenThousand) {
        return (
            _buyFees.liquidityFeesPerTenThousand,
            _buyFees.teamFeesPerTenThousand,
            _buyFees.marketingFeesPerTenThousand,
            _buyFees.stakingFeesPerTenThousand,
            _buyFees.warFeesPerTenThousand,
            _totalBuyFees());
    }

    function sellFees() public view returns (
        uint256 liquidityFeesPerTenThousand,
        uint256 teamFeesPerTenThousand,
        uint256 marketingFeesPerTenThousand,
        uint256 stakingFeesPerTenThousand,
        uint256 warFeesPerTenThousand,
        uint256 totalFeesPerTenThousand) {
        return (
            _sellFees.liquidityFeesPerTenThousand,
            _sellFees.teamFeesPerTenThousand,
            _sellFees.marketingFeesPerTenThousand,
            _sellFees.stakingFeesPerTenThousand,
            _sellFees.warFeesPerTenThousand,
            _totalSellFees());
    }
    
    function swapThreshold() external view returns (uint256) {
        return _swapThreshold;
    }

    function gasForProcessing() external view returns (uint256) {
        return _gasForProcessing;
    }
    
    function teamWallet() external view returns (address) {
        return _teamWallet;
    }

    function marketingWallet() external view returns (address) {
        return _marketingWallet;
    }

    function stakingWallet() external view returns (address) {
        return _stakingWallet;
    }

    function warWallet() external view returns (address) {
        return _warWallet;
    }

    function enableTrading(bool isEnabled) external onlyOwner {
        require(_tradingEnabled != isEnabled, "RetroNeko: Trading enabled is already the value of 'isEnabled'");

        _tradingEnabled = isEnabled;
        if (isEnabled) {
            _launchedAt = block.number;
        }

        emit TradingEnabled(isEnabled);
    }

    function enableTakeFees(bool isEnabled) external onlyOwner {
        require(_takeFeesEnabled != isEnabled, "RetroNeko: Take fees enabled is already the value of 'isEnabled'");

        _takeFeesEnabled = isEnabled;

        emit TakeFeesEnabled(isEnabled);
    }

    function enableSwap(bool isEnabled) external onlyOwner {
        require(_swapEnabled != isEnabled, "RetroNeko: Swap enabled is already the value of 'isEnabled'");

        _swapEnabled = isEnabled;

        emit SwapEnabled(isEnabled);
    }

    function updateUniswapV2Router(address newRouter) external onlyOwner {
        require(newRouter != _router, "RetroNeko: The router already has that address");

        address previousRouter = _router;
        IUniswapV2Router02 routerObject = IUniswapV2Router02(newRouter);
        address newPair = IUniswapV2Factory(routerObject.factory()).createPair(address(this), routerObject.WETH());
        _setAutomatedMarketMakerPair(newPair, true);
        _router = newRouter;
        
        emit UniswapV2RouterUpdated(previousRouter, newRouter);
    }

    function updateTeamWallet(address payable newWallet) external onlyOwner {
        require(newWallet != _teamWallet, "RetroNeko: The team wallet already has that address");

        address previousWallet = _teamWallet;
        _teamWallet = newWallet;

        emit TeamWalletUpdated(previousWallet, newWallet);
    }

    function updateMarketingWallet(address payable newWallet) external onlyOwner {
        require(newWallet != _marketingWallet, "RetroNeko: The marketing wallet already has that address");

        address previousWallet = _marketingWallet;
        _marketingWallet = newWallet;

        emit MarketingWalletUpdated(previousWallet, newWallet);
    }

    function updateStakingWallet(address payable newWallet) external onlyOwner {
        require(newWallet != _stakingWallet, "RetroNeko: The staking wallet already has that address");

        address previousWallet = _stakingWallet;
        _stakingWallet = newWallet;

        emit StakingWalletUpdated(previousWallet, newWallet);
    }

    function updateWarWallet(address payable newWallet) external onlyOwner {
        require(newWallet != _warWallet, "RetroNeko: The war wallet already has that address");

        address previousWallet = _warWallet;
        _warWallet = newWallet;

        emit WarWalletUpdated(previousWallet, newWallet);
    }

    function setAutomatedMarketMakerPair(address newPair, bool value) external onlyOwner {
        _setAutomatedMarketMakerPair(newPair, value);
    }

    function excludeFromFees(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "RetroNeko: Account is already the value of 'excluded'");

        _isExcludedFromFees[account] = excluded;

        emit ExcludedFromFees(account, excluded);
    }

    function excludeFromSwap(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromSwap[account] != excluded, "RetroNeko: Account is already the value of 'excluded'");

        _isExcludedFromSwap[account] = excluded;

        emit ExcludedFromSwap(account, excluded);
    }

    function blacklistAddress(address account, bool value) external onlyOwner {
        _isBlacklisted[account] = value;
    }

    function updateGasForProcessing(uint256 newValue) external onlyOwner {
        require(newValue >= 200_000 && newValue <= 500_000, "RetroNeko: gas must be between 200,000 and 500,000");
        require(newValue != _gasForProcessing, "RetroNeko: Cannot update gas to same value");

        emit GasForProcessingUpdated(_gasForProcessing, newValue);
        _gasForProcessing = newValue;
    }

    function updateSwapThreshold(uint256 threshold) external onlyOwner {
        _swapThreshold = threshold * 10 ** decimals();
    }

    function updateBuyFees (
        uint256 liquidityFeesPerTenThousand,
        uint256 teamFeesPerTenThousand,
        uint256 marketingFeesPerTenThousand,
        uint256 stakingFeesPerTenThousand,
        uint256 warFeesPerTenThousand) external onlyOwner {
        require(
            liquidityFeesPerTenThousand != _buyFees.liquidityFeesPerTenThousand ||
            teamFeesPerTenThousand != _buyFees.teamFeesPerTenThousand ||
            marketingFeesPerTenThousand != _buyFees.marketingFeesPerTenThousand ||
            stakingFeesPerTenThousand != _buyFees.stakingFeesPerTenThousand ||
            warFeesPerTenThousand != _buyFees.warFeesPerTenThousand, "RetroNeko: Buy fees has already the same values");
        
        uint256 previousLiquidityFeesPerTenThousand = _buyFees.liquidityFeesPerTenThousand;
        _buyFees.liquidityFeesPerTenThousand = liquidityFeesPerTenThousand;

        uint256 previousTeamFeesPerTenThousand = _buyFees.teamFeesPerTenThousand;
        _buyFees.teamFeesPerTenThousand = teamFeesPerTenThousand;

        uint256 previousMarketingFeesPerTenThousand = _buyFees.marketingFeesPerTenThousand;
        _buyFees.marketingFeesPerTenThousand = marketingFeesPerTenThousand;

        uint256 previousStakingFeesPerTenThousand = _buyFees.stakingFeesPerTenThousand;
        _buyFees.stakingFeesPerTenThousand = stakingFeesPerTenThousand;

        uint256 previousWarFeesPerTenThousand = _buyFees.warFeesPerTenThousand;
        _buyFees.warFeesPerTenThousand = warFeesPerTenThousand;

        emit BuyFeesUpdated(
            previousLiquidityFeesPerTenThousand, liquidityFeesPerTenThousand,
            previousTeamFeesPerTenThousand, teamFeesPerTenThousand,
            previousMarketingFeesPerTenThousand, marketingFeesPerTenThousand,
            previousStakingFeesPerTenThousand, stakingFeesPerTenThousand,
            previousWarFeesPerTenThousand, warFeesPerTenThousand);
    }

    function updateLiquidityBuyFees(uint256 feesPerTenThousand) external onlyOwner {
        require(feesPerTenThousand != _buyFees.liquidityFeesPerTenThousand, "RetroNeko: Liquidity buy fees has already the same value");

        uint256 previousfeesPerTenThousand = _buyFees.liquidityFeesPerTenThousand;
        _buyFees.liquidityFeesPerTenThousand = feesPerTenThousand;

        emit LiquidityBuyFeesUpdated(previousfeesPerTenThousand, feesPerTenThousand);
    }

    function updateTeamBuyFees(uint256 feesPerTenThousand) external onlyOwner {
        require(feesPerTenThousand != _buyFees.teamFeesPerTenThousand, "RetroNeko: Team buy fees has already the same value");

        uint256 previousfeesPerTenThousand = _buyFees.teamFeesPerTenThousand;
        _buyFees.teamFeesPerTenThousand = feesPerTenThousand;

        emit TeamBuyFeesUpdated(previousfeesPerTenThousand, feesPerTenThousand);
    }

    function updateMarketingBuyFees(uint256 feesPerTenThousand) external onlyOwner {
        require(feesPerTenThousand != _buyFees.marketingFeesPerTenThousand, "RetroNeko: Marketing buy fees has already the same value");

        uint256 previousfeesPerTenThousand = _buyFees.marketingFeesPerTenThousand;
        _buyFees.marketingFeesPerTenThousand = feesPerTenThousand;

        emit MarketingBuyFeesUpdated(previousfeesPerTenThousand, feesPerTenThousand);
    }

    function updateStakingBuyFees(uint256 feesPerTenThousand) external onlyOwner {
        require(feesPerTenThousand != _buyFees.stakingFeesPerTenThousand, "RetroNeko: Staking buy fees has already the same value");

        uint256 previousfeesPerTenThousand = _buyFees.stakingFeesPerTenThousand;
        _buyFees.stakingFeesPerTenThousand = feesPerTenThousand;

        emit StakingBuyFeesUpdated(previousfeesPerTenThousand, feesPerTenThousand);
    }

    function updateWarBuyFees(uint256 feesPerTenThousand) external onlyOwner {
        require(feesPerTenThousand != _buyFees.warFeesPerTenThousand, "RetroNeko: War buy fees has already the same value");

        uint256 previousfeesPerTenThousand = _buyFees.warFeesPerTenThousand;
        _buyFees.warFeesPerTenThousand = feesPerTenThousand;

        emit WarBuyFeesUpdated(previousfeesPerTenThousand, feesPerTenThousand);
    }

    function updateSellFees (
        uint256 liquidityFeesPerTenThousand,
        uint256 teamFeesPerTenThousand,
        uint256 marketingFeesPerTenThousand,
        uint256 stakingFeesPerTenThousand,
        uint256 warFeesPerTenThousand) external onlyOwner {
        require(
            liquidityFeesPerTenThousand != _sellFees.liquidityFeesPerTenThousand ||
            teamFeesPerTenThousand != _sellFees.teamFeesPerTenThousand ||
            marketingFeesPerTenThousand != _sellFees.marketingFeesPerTenThousand ||
            stakingFeesPerTenThousand != _sellFees.stakingFeesPerTenThousand ||
            warFeesPerTenThousand != _sellFees.warFeesPerTenThousand, "RetroNeko: Sell fees has already the same values");
        
        uint256 previousLiquidityFeesPerTenThousand = _sellFees.liquidityFeesPerTenThousand;
        _sellFees.liquidityFeesPerTenThousand = liquidityFeesPerTenThousand;

        uint256 previousTeamFeesPerTenThousand = _sellFees.teamFeesPerTenThousand;
        _sellFees.teamFeesPerTenThousand = teamFeesPerTenThousand;

        uint256 previousMarketingFeesPerTenThousand = _sellFees.marketingFeesPerTenThousand;
        _sellFees.marketingFeesPerTenThousand = marketingFeesPerTenThousand;

        uint256 previousStakingFeesPerTenThousand = _sellFees.stakingFeesPerTenThousand;
        _sellFees.stakingFeesPerTenThousand = stakingFeesPerTenThousand;

        uint256 previousWarFeesPerTenThousand = _sellFees.warFeesPerTenThousand;
        _sellFees.warFeesPerTenThousand = warFeesPerTenThousand;

        emit SellFeesUpdated(
            previousLiquidityFeesPerTenThousand, liquidityFeesPerTenThousand,
            previousTeamFeesPerTenThousand, teamFeesPerTenThousand,
            previousMarketingFeesPerTenThousand, marketingFeesPerTenThousand,
            previousStakingFeesPerTenThousand, stakingFeesPerTenThousand,
            previousWarFeesPerTenThousand, warFeesPerTenThousand);
    }

    function updateLiquiditySellFees(uint256 feesPerTenThousand) external onlyOwner {
        require(feesPerTenThousand != _sellFees.liquidityFeesPerTenThousand, "RetroNeko: Liquidity sell fees has already the same value");

        uint256 previousfeesPerTenThousand = _sellFees.liquidityFeesPerTenThousand;
        _sellFees.liquidityFeesPerTenThousand = feesPerTenThousand;

        emit LiquiditySellFeesUpdated(previousfeesPerTenThousand, feesPerTenThousand);
    }

    function updateTeamSellFees(uint256 feesPerTenThousand) external onlyOwner {
        require(feesPerTenThousand != _sellFees.teamFeesPerTenThousand, "RetroNeko: Team sell fees has already the same value");

        uint256 previousfeesPerTenThousand = _sellFees.teamFeesPerTenThousand;
        _sellFees.teamFeesPerTenThousand = feesPerTenThousand;

        emit TeamSellFeesUpdated(previousfeesPerTenThousand, feesPerTenThousand);
    }

    function updateMarketingSellFees(uint256 feesPerTenThousand) external onlyOwner {
        require(feesPerTenThousand != _sellFees.marketingFeesPerTenThousand, "RetroNeko: Marketing sell fees has already the same value");

        uint256 previousfeesPerTenThousand = _sellFees.marketingFeesPerTenThousand;
        _sellFees.marketingFeesPerTenThousand = feesPerTenThousand;

        emit MarketingSellFeesUpdated(previousfeesPerTenThousand, feesPerTenThousand);
    }

    function updateStakingSellFees(uint256 feesPerTenThousand) external onlyOwner {
        require(feesPerTenThousand != _sellFees.stakingFeesPerTenThousand, "RetroNeko: Staking sell fees has already the same value");

        uint256 previousfeesPerTenThousand = _sellFees.stakingFeesPerTenThousand;
        _sellFees.stakingFeesPerTenThousand = feesPerTenThousand;

        emit StakingSellFeesUpdated(previousfeesPerTenThousand, feesPerTenThousand);
    }

    function updateWarSellFees(uint256 feesPerTenThousand) external onlyOwner {
        require(feesPerTenThousand != _sellFees.warFeesPerTenThousand, "RetroNeko: War sell fees has already the same value");

        uint256 previousfeesPerTenThousand = _sellFees.warFeesPerTenThousand;
        _sellFees.warFeesPerTenThousand = feesPerTenThousand;

        emit WarSellFeesUpdated(previousfeesPerTenThousand, feesPerTenThousand);
    }

    function manualSwapSendFeesAndLiquify(
        uint256 amount,
        uint256 liquidityFeesPerTenThousand,
        uint256 teamFeesPerTenThousand,
        uint256 marketingFeesPerTenThousand,
        uint256 stakingFeesPerTenThousand,
        uint256 warFeesPerTenThousand) external onlyOwner swapping {
        uint256 totalFeesPerTenThousand =
            liquidityFeesPerTenThousand +
            teamFeesPerTenThousand +
            marketingFeesPerTenThousand +
            stakingFeesPerTenThousand +
            warFeesPerTenThousand;
        uint256 tokenBalance = amount * 10 ** decimals();
        
        uint256 liquidityTokenAmount = tokenBalance * liquidityFeesPerTenThousand / totalFeesPerTenThousand / 2;
        uint256 tokenAmountToSwap = tokenBalance - liquidityTokenAmount;

        _swapTokensForEth(tokenAmountToSwap);
        uint256 ethAmount = address(this).balance;

        uint256 teamEthAmount = ethAmount * teamFeesPerTenThousand / totalFeesPerTenThousand;
        _sendFeesToWallet(_teamWallet, teamEthAmount);
        
        uint256 marketingEthAmount = ethAmount * marketingFeesPerTenThousand / totalFeesPerTenThousand;
        _sendFeesToWallet(_marketingWallet, marketingEthAmount);
        
        uint256 stakingEthAmount = ethAmount * stakingFeesPerTenThousand / totalFeesPerTenThousand;
        _sendFeesToWallet(_stakingWallet, stakingEthAmount);

        uint256 warEthBalance = ethAmount * warFeesPerTenThousand / totalFeesPerTenThousand;
        _sendFeesToWallet(_warWallet, warEthBalance);

        uint256 liquidityEthAmount = ethAmount - teamEthAmount - marketingEthAmount - stakingEthAmount - warEthBalance;
        _liquify(liquidityTokenAmount, liquidityEthAmount);
    }

    function _currentFees() private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        return _isBuying ? buyFees() : sellFees();
    }

    function _currentTotalFees() private view returns (uint256) {
        return _isBuying ? _totalBuyFees() : _totalSellFees();
    }

    function _totalBuyFees() private view returns (uint256) {
        return (
            _buyFees.liquidityFeesPerTenThousand +
            _buyFees.teamFeesPerTenThousand +
            _buyFees.marketingFeesPerTenThousand +
            _buyFees.stakingFeesPerTenThousand +
            _buyFees.warFeesPerTenThousand);
    }

    function _totalSellFees() private view returns (uint256) {
        return (
            _sellFees.liquidityFeesPerTenThousand +
            _sellFees.teamFeesPerTenThousand +
            _sellFees.marketingFeesPerTenThousand +
            _sellFees.stakingFeesPerTenThousand +
            _sellFees.warFeesPerTenThousand);
    }

    function _setAutomatedMarketMakerPair(address newPair, bool value) private {
        require(_isAutomatedMarketMakerPairs[newPair] != value, "RetroNeko: Automated market maker pair is already set to that value");
        _isAutomatedMarketMakerPairs[newPair] = value;

        emit AutomatedMarketMakerPairSet(newPair, value);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        address presaleAddress = 0xAEEA45f0FeDE1f6EB18AB492Be78b55D41E04a61;
        require(_msgSender() == owner() || sender == presaleAddress || _tradingEnabled, "RetroNeko: Trading is not enabled");
        require(sender != address(0), "RetroNeko: Transfer from the zero address");
        require(recipient != address(0), "RetroNeko: Transfer to the zero address");
        require(amount > 0, "RetroNeko: Transfer zero token");
        require(!_isBlacklisted[sender] && !_isBlacklisted[recipient], "RetroNeko: Blacklisted address");

        if (_shouldPerformBasicTransfer(sender, recipient)) {
            _basicTransfer(sender, recipient, amount);
        } else {
            _customTransfer(sender, recipient, amount);
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        super._transfer(sender, recipient, amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _customTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        address presaleAddress = 0xAEEA45f0FeDE1f6EB18AB492Be78b55D41E04a61;
        _isBuying = _isAutomatedMarketMakerPairs[sender];
        
        if (sender != presaleAddress) {
            if (_shouldTakeFees(sender, recipient)) {
                uint256 totalFeesPerTenThousand = _currentTotalFees();
        	    uint256 feesAmount = amount * totalFeesPerTenThousand / 10_000;
        	    amount -= feesAmount;

                if (feesAmount > 0) {
                    super._transfer(sender, address(this), feesAmount);
                }
            }
        }

        if (_shouldSwap(sender, recipient)) {
            _swapSendFeesAndLiquify();
        }

        if (amount > 0) {
            super._transfer(sender, recipient, amount);
        }
        
        return true;
    }

    function _shouldPerformBasicTransfer(address sender, address recipient) private view returns (bool) {
        return
            _inSwap ||
            sender == owner() || recipient == owner() ||
            sender == _teamWallet || recipient == _teamWallet ||
            sender == _marketingWallet || recipient == _marketingWallet ||
            sender == _stakingWallet || recipient == _stakingWallet ||
            sender == _warWallet || recipient == _warWallet;
    }

    function _shouldTakeFees(address sender, address recipient) private view returns (bool) {
        return
            _takeFeesEnabled &&
            !_isExcludedFromFees[sender] && !_isExcludedFromFees[recipient];
    }
    
    function _shouldSwap(address sender, address recipient) private view returns (bool) {
        return
            _swapEnabled &&
            balanceOf(address(this)) >= _swapThreshold &&
            !_isAutomatedMarketMakerPairs[sender] &&
            !_isExcludedFromSwap[sender] && !_isExcludedFromSwap[recipient];
    }

    function _swapSendFeesAndLiquify() private swapping {
        uint256 tokenBalance = _swapThreshold;
        (
            uint256 liquidityFeesPerTenThousand,
            uint256 teamFeesPerTenThousand,
            uint256 marketingFeesPerTenThousand,
            uint256 stakingFeesPerTenThousand,
            uint256 warFeesPerTenThousand,
            uint256 totalFeesPerTenThousand) = _currentFees();
        
        uint256 liquidityTokenAmount = tokenBalance * liquidityFeesPerTenThousand / totalFeesPerTenThousand / 2;
        uint256 tokenAmountToSwap = tokenBalance - liquidityTokenAmount;

        _swapTokensForEth(tokenAmountToSwap);
        uint256 ethAmount = address(this).balance;

        uint256 teamEthAmount = ethAmount * teamFeesPerTenThousand / totalFeesPerTenThousand;
        _sendFeesToWallet(_teamWallet, teamEthAmount);
        
        uint256 marketingEthAmount = ethAmount * marketingFeesPerTenThousand / totalFeesPerTenThousand;
        _sendFeesToWallet(_marketingWallet, marketingEthAmount);
        
        uint256 stakingEthAmount = ethAmount * stakingFeesPerTenThousand / totalFeesPerTenThousand;
        _sendFeesToWallet(_stakingWallet, stakingEthAmount);

        uint256 warEthBalance = ethAmount * warFeesPerTenThousand / totalFeesPerTenThousand;
        _sendFeesToWallet(_warWallet, warEthBalance);

        uint256 liquidityEthAmount = ethAmount - teamEthAmount - marketingEthAmount - stakingEthAmount - warEthBalance;
        _liquify(liquidityTokenAmount, liquidityEthAmount);
    }

    function _sendFeesToWallet(address wallet, uint256 ethAmount) private {
        if (ethAmount > 0) {
            (bool success, /* bytes memory data */) = wallet.call{value: ethAmount}("");
            if (success) {
                emit FeesSentToWallet(wallet, ethAmount);
            }
        }
    }

    function _swapTokensForEth(uint256 tokenAmount) private {
        if (tokenAmount > 0) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = IUniswapV2Router02(_router).WETH();

            _approve(address(this), _router, tokenAmount);
            IUniswapV2Router02(_router).swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp);
        }
    }

    function _liquify(uint256 tokenAmount, uint256 ethAmount) private {
        if (tokenAmount > 0 && ethAmount > 0) {
            _addLiquidity(tokenAmount, ethAmount);

            emit SwappedAndLiquified(tokenAmount, ethAmount, tokenAmount);
        }
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), _router, tokenAmount);
        IUniswapV2Router02(_router).addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}