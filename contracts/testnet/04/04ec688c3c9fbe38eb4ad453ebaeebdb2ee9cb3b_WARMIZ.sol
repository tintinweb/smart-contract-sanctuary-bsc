/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor(address newOwner) {
        _owner = newOwner;
        emit OwnershipTransferred(address(0), _owner);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function owner() internal view returns (address) {
        return _owner;
    }
}
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract BEP20 is IBEP20, Ownable {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private constant NAME = "WARMIZ";
    string private constant SYMBOL = "WARMIZ";
    uint8 private constant DECIMALS = 18;
    uint256 private constant TOTAL_SUPPLY = 10**9 * 10**DECIMALS;

    constructor(address owner, address recipient) Ownable(owner) {
        require(recipient != address(0), "Transfer to zero address");
        _balances[recipient] = TOTAL_SUPPLY;
        emit Transfer(address(0), recipient, TOTAL_SUPPLY);
    }

    function getOwner() public view returns (address) {
        return owner();
    }

    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }

    function symbol() external pure returns (string memory) {
        return SYMBOL;
    }

    function name() external pure returns (string memory) {
        return NAME;
    }

    function totalSupply() public pure returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, msg.sender, currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract WARMIZ is BEP20 {
    IDEXRouter public constant ROUTER = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //0x10ED43C718714eb63d5aA57B78B54704E256024E   0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    address public immutable pair;

    address public marketingWallet = 0x07c91b9A1F77da0976a09579CfEEa9F50dA3BfCB;
    address public developmentWallet = 0x292EBEc90386a0272104762BA4976820af9cF338;
    address public stakingWallet = 0x9cc4f951efc481868B81eA839A45ea1157D0EeFD;

    uint256 public swapThreshold = 1;
    bool public swapWholeStorage = true;
    bool public swapEnabled = true;
    bool inSwap;

    bool tradingEnabled;
    bool dynamicBuyTaxEnabled = true;
    bool dynamicSellTaxEnabled = true;

    uint256 public buyTax = 800;
    uint256 public sellTax = 1200;
    uint256 public transferTax = 0;

    uint256 public liquidityShare = 170;
    uint256 public marketingShare = 530;
    uint256 public developmentShare = 150;
    uint256 public stakingShare = 150;
    uint256 totalShares = 1000;
    uint256 constant TAX_DENOMINATOR = 10000;

    uint256 public transferGas = 25000;
    uint256 public launchTime;

    mapping (address => bool) public isWhitelisted;
    mapping (address => bool) public isCEX;
    mapping (address => bool) public isMarketMaker;

    event EnableTrading();
    event DisableDynamicBuyTax();
    event DisableDynamicSellTax();
    event TriggerSwapBack(uint256 amount);
    event RecoverBNB(address recipient, uint256 amount);
    event RecoverBEP20(address indexed token, address recipient, uint256 amount);
    event SetIsWhitelisted(address indexed account, bool indexed status);
    event SetIsCEX(address indexed account, bool indexed exempt);
    event SetIsMarketMaker(address indexed account, bool indexed isMM);
    event SetTaxes(uint256 buy, uint256 sell, uint256 transfer);
    event SetShares(uint256 liquidityShare, uint256 marketingShare, uint256 developmentShare, uint256 stakingShare);
    event SetSwapBackSettings(bool enabled, bool swapAll, uint256 amount);
    event SetTransferGas(uint256 newGas, uint256 oldGas);
    event SetMarketingWallet(address newWallet, address oldWallet);
    event SetStakingWallet(address newAddress, address oldAddress);
    event SetDevelopmentWallet(address newAddress, address oldAddress);
    event AutoLiquidity(uint256 pair, uint256 tokens);
    event DepositMarketing(address indexed wallet, uint256 amount);
    event DepositStaking(address indexed wallet, uint256 amount);
    event DepositDevelopment(address indexed wallet, uint256 amount);

    constructor(address owner, address saleHost) BEP20(owner, saleHost) {
        pair = IDEXFactory(ROUTER.factory()).createPair(ROUTER.WETH(), address(this));
        _approve(address(this), address(ROUTER), type(uint256).max);
        isMarketMaker[pair] = true;

        isWhitelisted[saleHost] = true;
    }

    // Override

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (isWhitelisted[sender] || isWhitelisted[recipient] || inSwap) {
            super._transfer(sender, recipient, amount);
            return;
        }
        require(tradingEnabled, "Trading is disabled");

        if (_shouldSwapBack(recipient)) {
            uint256 swapAmount = swapWholeStorage ? balanceOf(address(this)) : swapThreshold;
            _swapBack(swapAmount);
        }
        uint256 amountAfterTaxes = _takeTax(sender, recipient, amount);

        super._transfer(sender, recipient, amountAfterTaxes);
    }

    // Public

    /**
     * @dev Decrease the buy tax from 99% to normal rate within 3 minutes.
     * Returns buy tax percentage
     */
    function getDynamicBuyTax() public view returns (uint256) {
        uint256 endingTime = launchTime + 3 minutes;

        if (endingTime > block.timestamp) {
            uint256 remainingTime = endingTime - block.timestamp;
            return buyTax + 9100 * remainingTime / 3 minutes;
        } else {
            return buyTax;
        }
    }

    /**
     * @dev Decrease the sell tax from 30% to normal rate within 5 hours.
     * Returns sell tax percentage
     */
    function getDynamicSellTax() public view returns (uint256) {
        uint256 endingTime = launchTime + 5 hours;

        if (endingTime > block.timestamp) {
            uint256 remainingTime = endingTime - block.timestamp;
            return sellTax + 1800 * remainingTime / 5 hours;
        } else {
            return sellTax;
        }
    }

    receive() external payable {}

    // Private

    function _takeTax(address sender, address recipient, uint256 amount) private returns (uint256) {
        if (amount == 0) { return amount; }

        uint256 taxAmount = amount * _getTotalTax(sender, recipient) / TAX_DENOMINATOR;
        if (taxAmount > 0) { super._transfer(sender, address(this), taxAmount); }

        return amount - taxAmount;
    }

    function _getTotalTax(address sender, address recipient) private view returns (uint256) {
        if (isCEX[recipient]) { return 0; }
        if (isCEX[sender]) { return buyTax; }

        if (isMarketMaker[sender]) {
            return dynamicBuyTaxEnabled ? getDynamicBuyTax() : buyTax;
        } else if (isMarketMaker[recipient]) {
            return dynamicSellTaxEnabled ? getDynamicSellTax() : sellTax;
        } else {
            return transferTax;
        }
    }

    function _shouldSwapBack(address recipient) private view returns (bool) {
        return isMarketMaker[recipient] && swapEnabled && balanceOf(address(this)) >= swapThreshold;
    }

    function _swapBack(uint256 tokenAmount) private {
        inSwap = true;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ROUTER.WETH();

        uint256 liquidityTokens = tokenAmount * liquidityShare / totalShares / 2;
        uint256 amountToSwap = tokenAmount - liquidityTokens;
        uint256 balanceBefore = address(this).balance;

        ROUTER.swapExactTokensForETH(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance - balanceBefore;
        uint256 totalBNBShares = totalShares - liquidityShare / 2;

        uint256 amountBNBLiquidity = amountBNB * liquidityShare / totalBNBShares / 2;
        uint256 amountBNBMarketing = amountBNB * marketingShare / totalBNBShares;
        uint256 amountBNBStaking = amountBNB * stakingShare / totalBNBShares;
        uint256 amountBNBDevelopment = amountBNB * developmentShare / totalBNBShares;

        (bool marketingSuccess,) = payable(marketingWallet).call{value: amountBNBMarketing, gas: transferGas}("");
        if (marketingSuccess) { emit DepositMarketing(marketingWallet, amountBNBMarketing); }
        (bool stakingSuccess,) = payable(stakingWallet).call{value: amountBNBStaking, gas: transferGas}("");
        if (stakingSuccess) { emit DepositStaking(stakingWallet, amountBNBStaking); }
        (bool devSuccess,) = payable(developmentWallet).call{value: amountBNBDevelopment, gas: transferGas}("");
        if (devSuccess) { emit DepositDevelopment(developmentWallet, amountBNBDevelopment); }

        if (liquidityTokens > 0) {
            ROUTER.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                liquidityTokens,
                0,
                0,
                address(this),
                block.timestamp
            );

            emit AutoLiquidity(amountBNBLiquidity, liquidityTokens);
        }

        inSwap = false;
    }

    // Owner

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
        launchTime = block.timestamp;
        emit EnableTrading();
    }

    function disableDynamicBuyTax() external onlyOwner {
        dynamicBuyTaxEnabled = false;
        emit DisableDynamicBuyTax();
    }

    function disableDynamicSellTax() external onlyOwner {
        dynamicSellTaxEnabled = false;
        emit DisableDynamicSellTax();
    }

    function triggerSwapBack(bool swapAll, uint256 amount) external onlyOwner {
        uint256 tokenAmount = swapAll ? balanceOf(address(this)) : amount * 10**decimals();
        require(balanceOf(address(this)) >= tokenAmount, "Insufficient balance");
        _swapBack(tokenAmount);
        emit TriggerSwapBack(tokenAmount);
    }

    function recoverBNB(address recipient) external onlyOwner {
        uint256 amount = address(this).balance;
        (bool sent,) = payable(recipient).call{value: amount, gas: transferGas}("");
        require(sent, "Tx failed");
        emit RecoverBNB(recipient, amount);
    }

    function recoverBEP20(IBEP20 token, address recipient) external onlyOwner {
        require(address(token) != address(this), "Can't withdraw WARMIZ");
        uint256 amount = token.balanceOf(address(this));
        token.transfer(recipient, amount);
        emit RecoverBEP20(address(token), recipient, amount);
    }

    function setIsWhitelisted(address account, bool value) external onlyOwner {
        isWhitelisted[account] = value;
        emit SetIsWhitelisted(account, value);
    }

    function setIsCEX(address account, bool value) external onlyOwner {
        isCEX[account] = value;
        emit SetIsCEX(account, value);
    }

    function setIsMarketMaker(address account, bool value) external onlyOwner {
        require(account != pair, "Can't modify pair");
        isMarketMaker[account] = value;
        emit SetIsMarketMaker(account, value);
    }

    function setTaxes(uint256 newBuyTax, uint256 newSellTax, uint256 newTransferTax) external onlyOwner {
        require(newBuyTax <= 1500 && newSellTax <= 2000 && newTransferTax <= 7500, "Too high taxes");
        buyTax = newBuyTax;
        sellTax = newSellTax;
        transferTax = newTransferTax;
        emit SetTaxes(buyTax, sellTax, transferTax);
    }

    function setShares(
        uint256 newLiquidityShare,
        uint256 newMarketingShare,
        uint256 newDevelopmentShare,
        uint256 newStakingShare
    ) external onlyOwner {
        uint256 currentStakingRatio = 1e18 * stakingShare / totalShares;
        uint256 newStakingRatio = 1e18 * newStakingShare / (newLiquidityShare + newMarketingShare + newDevelopmentShare + newStakingShare);
        require(newStakingRatio <= currentStakingRatio, "Can't increase Staking ratio");

        liquidityShare = newLiquidityShare;
        marketingShare = newMarketingShare;
        developmentShare = newDevelopmentShare;
        stakingShare = newStakingShare;
        totalShares = liquidityShare + marketingShare + developmentShare + stakingShare;
        emit SetShares(liquidityShare, marketingShare, developmentShare, stakingShare);
    }

    function setSwapBackSettings(bool enabled, bool swapAll, uint256 amount) external onlyOwner {
        uint256 tokenAmount = amount * 10**decimals();
        swapEnabled = enabled;
        swapWholeStorage = swapAll;
        swapThreshold = tokenAmount;
        emit SetSwapBackSettings(enabled, swapAll, tokenAmount);
    }

    function setTransferGas(uint256 newGas) external onlyOwner {
        require(newGas >= 21000 && newGas <= 50000, "Invalid gas parameter");
        emit SetTransferGas(newGas, transferGas);
        transferGas = newGas;
    }

    function setMarketingWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "New marketing wallet is the zero address");
        emit SetMarketingWallet(newWallet, marketingWallet);
        marketingWallet = newWallet;
    }

    function setDevelopmentWallet(address newWallet) external {
        require(msg.sender == developmentWallet, "Only development team can change this wallet.");
        require(newWallet != address(0), "New development wallet is the zero address");
        emit SetDevelopmentWallet(newWallet, developmentWallet);
        developmentWallet = newWallet;
    }

    function setStakingWallet(address newAddress) external onlyOwner {
        require(newAddress != address(0), "New staking wallet is the zero address");
        emit SetStakingWallet(newAddress, stakingWallet);
        stakingWallet = newAddress;
    }
}