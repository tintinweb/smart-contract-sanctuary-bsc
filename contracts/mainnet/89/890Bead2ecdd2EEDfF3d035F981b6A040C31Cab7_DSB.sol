// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "./IDex.sol";
import "./OpenZeppelin.sol";


contract DSB is ERC20, AccessControlEnumerable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 public constant BUY_TAX = 200;
    uint256 public constant SELL_TAX = 200;
    uint256 public constant TRANSFER_TAX = 75;
    uint256 private constant TAX_DENOMINATOR = 10000;

    IDexRouter public constant ROUTER = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public immutable pair;
    address public marketingWallet;
    address public pinksaleAddress;

    uint256 public marketingShare = 1000;
    uint256 public liquidityShare;
    uint256 private totalShares = 1000;

    uint256 public transferGas = 25000;
    uint256 public swapThreshold = 1;
    bool public swapWholeStorage = true;
    bool public swapEnabled = true;
    bool private inSwap;
    bool private tradingEnabled;

    mapping (address => bool) public isTaxExempt;
    mapping (address => bool) public isWhitelisted;

    event MarketingDeposited(address marketingWallet, uint256 marketingBNB);
    event BNBRecovered(uint256 amount);
    event ERC20Recovered(IERC20 token, address recipient, uint256 amount);
    event PinksalePrepared(address pinksaleAddress);
    event TradingEnabled();
    event WhitelistUpdated(address account, bool exempt);
    event TaxExemptUpdated(address account, bool exempt);
    event SharesUpdated(uint256 liquidityShare, uint256 marketingShare);
    event SwapBackSettingsUpdated(bool enabled, bool swapAll, uint256 tokenAmount);
    event TransferGasUpdated(uint256 transferGas);
    event MarketingWalletUpdated(address marketingWallet);

    modifier swapping() { 
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address marketing, address presaleHost) ERC20("Degen Street Bets", "$DSB") {
        require(presaleHost != address(0) && marketing != address(0), "Parameters can't be zero address");

        pair = IDexFactory(ROUTER.factory()).createPair(address(this), ROUTER.WETH());
        marketingWallet = marketing;

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(ADMIN_ROLE, _msgSender());

        isWhitelisted[_msgSender()] = true;
        isWhitelisted[presaleHost] = true;

        isTaxExempt[_msgSender()] = true;
        isTaxExempt[presaleHost] = true;

        _mint(_msgSender(), 10**7 * 10**18);
    }

    receive() external payable {
        require(inSwap, "Can't receive BNB");
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (inSwap) {
            super._transfer(sender, recipient, amount);
            return;
        }

        if (!tradingEnabled) {
            require(isWhitelisted[sender], "Trading is disabled");
        }

        uint256 amountReceived = _takeTax(sender, recipient, amount);

        if (_shouldSwapBack(recipient)) {
            uint256 swapAmount = swapWholeStorage ? balanceOf(address(this)) : swapThreshold;
            _swapBack(swapAmount);
        }

        super._transfer(sender, recipient, amountReceived);
    }

    function _takeTax(address sender, address recipient, uint256 amount) private returns (uint256) {
        if (isTaxExempt[sender] || isTaxExempt[recipient] || amount == 0) {
            return amount;
        }

        uint256 taxAmount = amount * _getTotalTax(sender, recipient) / TAX_DENOMINATOR;
        if (taxAmount > 0) {
            super._transfer(sender, address(this), taxAmount);
        }

        return amount - taxAmount;
    }

    function _getTotalTax(address sender, address recipient) private view returns (uint256) {
        if (sender == pair) {
            return BUY_TAX;
        } else if (recipient == pair) {
            return SELL_TAX;
        } else {
            return TRANSFER_TAX;
        }
    }

    function _shouldSwapBack(address recipient) private view returns (bool) {
        return recipient == pair && swapEnabled && balanceOf(address(this)) >= swapThreshold;
    }

    function _swapBack(uint256 amount) private swapping {
        uint256 liquidityTokens = amount * liquidityShare / totalShares / 2;
        uint256 amountToSwap = amount - liquidityTokens;

        uint256 receivedBNB = _swapTokens(amountToSwap);
        uint256 totalBNBShares = totalShares - liquidityShare / 2;

        uint256 liquidityBNB = receivedBNB * liquidityShare / totalBNBShares / 2;
        uint256 marketingBNB = receivedBNB * marketingShare / totalBNBShares;

        if (marketingBNB > 0) {
            (bool success,) = payable(marketingWallet).call{value: marketingBNB, gas: transferGas}("");
            if (success) {
                emit MarketingDeposited(marketingWallet, marketingBNB);
            }
        }

        if (liquidityTokens > 0) {
            _addLiquidity(liquidityTokens, liquidityBNB);
        }
    }

    function _swapTokens(uint256 amount) private returns (uint256) {
        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ROUTER.WETH();

        _approve(address(this), address(ROUTER), amount);
        try ROUTER.swapExactTokensForETH(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {}

        return address(this).balance - balanceBefore;
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(ROUTER), tokenAmount);
        try ROUTER.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            0x000000000000000000000000000000000000dEaD,
            block.timestamp
        ) {} catch {}
    }

    // Maintenance

    function recoverBNB() external onlyRole(ADMIN_ROLE) {
        uint256 amount = address(this).balance;
        (bool sent,) = payable(_msgSender()).call{value: amount}("");
        require(sent, "Tx failed");
        emit BNBRecovered(amount);
    }

    function recoverERC20(IERC20 token) external onlyRole(ADMIN_ROLE) {
        require(address(token) != address(this), "Can't withdraw this token");
        uint256 amount = token.balanceOf(address(this));
        token.transfer(_msgSender(), amount);
        emit ERC20Recovered(token, _msgSender(), amount);
    }

    function preparePinksale(address pinksale) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(pinksaleAddress == address(0), "Pinksale already initialised");
        pinksaleAddress = pinksale;
        isWhitelisted[pinksaleAddress] = true;
        isTaxExempt[pinksaleAddress] = true;
        emit PinksalePrepared(pinksaleAddress);
    }

    function enableTrading() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
        emit TradingEnabled();
    }

    function setIsWhitelisted(address account, bool exempt) external onlyRole(ADMIN_ROLE) {
        isWhitelisted[account] = exempt;
        emit WhitelistUpdated(account, exempt);
    }

    function setIsTaxExempt(address account, bool exempt) external onlyRole(ADMIN_ROLE) {
        require(account != pinksaleAddress, "Pinksale must be tax free");
        isTaxExempt[account] = exempt;
        emit TaxExemptUpdated(account, exempt);
    }

    function setShares(
        uint256 newLiquidityShare,
        uint256 newMarketingShare
    ) external onlyRole(ADMIN_ROLE) {
        liquidityShare = newLiquidityShare;
        marketingShare = newMarketingShare;
        totalShares = liquidityShare + marketingShare;
        require(totalShares > 0, "totalShares must be a positive number");
        emit SharesUpdated(liquidityShare, marketingShare);
    }

    function setSwapBackSettings(
        bool enabled,
        bool swapAll,
        uint256 amount
    ) external onlyRole(ADMIN_ROLE) {
        uint256 tokenAmount = amount * 10**decimals();
        swapEnabled = enabled;
        swapWholeStorage = swapAll;
        swapThreshold = tokenAmount;
        emit SwapBackSettingsUpdated(enabled, swapAll, tokenAmount);
    }

    function triggerSwapBack(bool swapAll, uint256 amount) external onlyRole(ADMIN_ROLE) {
        uint256 tokenAmount = swapAll ? balanceOf(address(this)) : amount * 10**decimals();
        _swapBack(tokenAmount);
    }

    function setTransferGas(uint256 newGas) external onlyRole(ADMIN_ROLE) {
        require(newGas >= 21000 && newGas <= 50000, "New gas out of bounds");
        transferGas = newGas;
        emit TransferGasUpdated(transferGas);
    }

    function setMarketingWallet(address newMarketingWallet) external onlyRole(ADMIN_ROLE) {
        require(newMarketingWallet != address(0), "Marketing can't be zero address");
        marketingWallet = newMarketingWallet;
        emit MarketingWalletUpdated(marketingWallet);
    }
}