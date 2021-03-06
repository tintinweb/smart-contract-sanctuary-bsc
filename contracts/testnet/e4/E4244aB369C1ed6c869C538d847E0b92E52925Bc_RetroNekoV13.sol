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

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract RetroNekoV13 is Initializable, ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
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

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(
        address newRouter,
        address newTeamWallet,
        address newMarketingWallet,
        address newStakingWallet,
        address newWarWallet) public initializer {
        __ERC20_init("RetroNeko", "RNK");
        __Ownable_init();
        __UUPSUpgradeable_init();

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
    
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {
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
        require(!_isBlacklisted[sender] && !_isBlacklisted[recipient], 'RetroNeko: Blacklisted address');

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

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
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
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
    uint256[45] private __gap;
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
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        // Initial upgrade and setup call
        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }

        // Perform rollback test if not already in progress
        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            // Trigger rollback using upgradeTo from the new implementation
            rollbackTesting.value = true;
            _functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            // Check rollback was effective
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            // Finally reset to the new implementation and log the upgrade
            _upgradeTo(newImplementation);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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