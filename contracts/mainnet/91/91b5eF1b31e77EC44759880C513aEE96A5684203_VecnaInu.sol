// SPDX-License-Identifier: UNLICENSED
//
// Vecna Inu Official
// Website:  https://www.vecnainu.com
// Telegram: https://t.me/VecnaInuPortal
// Twitter:  https://twitter.com/Vecna_inu
//
// Vecna inu is a meme token based on the Stranger Things season 4 character vecna.
// His mission is to become the Ruler of all Meme coins.

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/**
 * @title Vecna Inu contract.
 * @author Vecna Inu team.
 */
contract VecnaInu is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => uint256) private _supplyOwned;
    mapping(address => uint256) private _rewardPointsOwned;

    mapping(address => bool) private _excludedFromRewards;
    mapping(address => bool) private _excludedFromTaxes;

    mapping(address => bool) private _distributionAddress;
    mapping(address => bool) private _pair;

    address private _treasuryStakingAddress =
        0x50635e16872b8C0c997B59eab9bB6900E8f85Fbe;
    address private _marketingTaxAddress =
        0x50635e16872b8C0c997B59eab9bB6900E8f85Fbe;
    address private _teamTaxAddress =
        0x50635e16872b8C0c997B59eab9bB6900E8f85Fbe;
    address private constant _factoryAddress =
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private constant _routerAddress =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant _deadAddress =
        0x000000000000000000000000000000000000dEaD;

    uint256 private _totalSupply;
    uint256 private _excludedSupply;

    uint256 private _rewardPoints;
    uint256 private _excludedRewardPoints;

    string private _name;
    string private _symbol;

    uint256 private _burnedSupply;
    uint256 private _distributedSupply;

    uint256 private _treasuryTax = 0;
    uint256 private _rewardsTax = 0;
    uint256 private _marketingTax = 0;
    uint256 private _teamTax = 0;
    uint256 private _taxSwapThreshold;
    uint256 private _distributionBurnRate = 10;

    uint256 private constant _MAX_UINT = type(uint256).max;
    uint256 private _maxTransferLimit;

    IUniswapV2Factory private _factory;
    IUniswapV2Router02 private _router;

    bool private _inSwap;

    event TreasuryStakingAddressChange(
        address indexed from,
        address indexed to
    );
    event MarketingTaxAddressChange(address indexed from, address indexed to);
    event TeamTaxAddressChange(address indexed from, address indexed to);
    event IncludeInRewards(address indexed account);
    event ExcludeFromRewards(address indexed account);
    event IncludeInTaxes(address indexed account);
    event ExcludeFromTaxes(address indexed account);
    event AddDistributor(address indexed account);
    event RemoveDistributor(address indexed account);
    event Distribution(address indexed from, uint256 amount);
    event AddPair(address indexed pairAddress);
    event EnableTransferLimit(uint256 limit);
    event DisableTransferLimit(uint256 limit);
    event TaxSwapThresholdChange(uint256 threshold);
    event DistributionBurnRateChange(uint256 rate);
    event Burn(address indexed from, uint256 amount);
    event FundsExtract(uint256 amount);
    event TaxesChange(
        uint256 treasuryTax,
        uint256 rewardsTax,
        uint256 marketingTax,
        uint256 teamTax
    );

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_ * 10**decimals();
        _rewardPoints = _MAX_UINT - (_MAX_UINT % _totalSupply);
        _maxTransferLimit = _totalSupply;
        _taxSwapThreshold = 1;
        _router = IUniswapV2Router02(_routerAddress);
        _factory = IUniswapV2Factory(_factoryAddress);

        _rewardPointsOwned[_msgSender()] = _rewardPoints;

        excludeFromRewards(address(this));
        excludeFromTaxes(address(this));

        excludeFromRewards(_msgSender());
        excludeFromTaxes(_msgSender());

        excludeFromRewards(_treasuryStakingAddress);

        excludeFromRewards(_marketingTaxAddress);
        excludeFromTaxes(_marketingTaxAddress);

        excludeFromRewards(_teamTaxAddress);
        excludeFromTaxes(_teamTaxAddress);

        excludeFromRewards(_deadAddress);
        excludeFromTaxes(_deadAddress);

        addPair(_factory.createPair(address(this), _router.WETH()));

        transfer(address(this), 1);
    }

    modifier swapLock() {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * Returns the total burned supply from distributions.
     */
    function burnedSupply() public view returns (uint256) {
        return _burnedSupply;
    }

    /**
     * Returns the total distributed supply.
     */
    function distributedSupply() public view returns (uint256) {
        return _distributedSupply;
    }

    /**
     * Returns the current treasury tax.
     */
    function treasuryTax() public view returns (uint256) {
        return _treasuryTax;
    }

    /**
     * Returns the current rewards tax.
     */
    function rewardsTax() public view returns (uint256) {
        return _rewardsTax;
    }

    /**
     * Returns the current marketing tax.
     */
    function marketingTax() public view returns (uint256) {
        return _marketingTax;
    }

    /**
     * Returns the current team tax.
     */
    function teamTax() public view returns (uint256) {
        return _teamTax;
    }

    /**
     * Returns the current total taxes.
     */
    function totalTaxes() external view returns (uint256) {
        return _treasuryTax + _rewardsTax + _marketingTax + _teamTax;
    }

    /**
     * Returns the current tax swap threshold.
     */
    function taxSwapThreshold() public view returns (uint256) {
        return _taxSwapThreshold;
    }

    /**
     * Returns the current distribution burn rate.
     */
    function distributionBurnRate() public view returns (uint256) {
        return _distributionBurnRate;
    }

    /**
     * Returns true if an address is excluded from rewards.
     * @param account The address to ckeck.
     */
    function excludedFromRewards(address account) public view returns (bool) {
        return _excludedFromRewards[account];
    }

    /**
     * Returns true if an address is excluded from taxes.
     * @param account The address to ckeck.
     */
    function excludedFromTaxes(address account) public view returns (bool) {
        return _excludedFromTaxes[account];
    }

    /**
     * Returns true if an address is a distribution address.
     * @param account The address to ckeck.
     */
    function distributionAddress(address account) public view returns (bool) {
        return _distributionAddress[account];
    }

    /**
     * Returns true if an address is a pair address.
     * @param account The address to ckeck.
     */
    function pair(address account) public view returns (bool) {
        return _pair[account];
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_excludedFromRewards[account]) return _supplyOwned[account];
        uint256 rate = _getRewardsRate();
        return _getBalanceFromRewardPoints(_rewardPointsOwned[account], rate);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * Updates the treasury staking address.
     * @param treasuryStakingAddress The new treasury staking address.
     */
    function setTreasuryStakingAddress(address treasuryStakingAddress)
        external
        onlyOwner
    {
        address _oldTreasuryStakingAddress = _treasuryStakingAddress;
        _treasuryStakingAddress = treasuryStakingAddress;

        emit TreasuryStakingAddressChange(
            _oldTreasuryStakingAddress,
            _treasuryStakingAddress
        );
    }

    /**
     * Updates the marketing tax address.
     * @param marketingTaxAddress The new marketing tax address.
     */
    function setMarketingTaxAddress(address marketingTaxAddress)
        external
        onlyOwner
    {
        address _oldMarketingTaxAddress = _marketingTaxAddress;

        includeInRewards(_oldMarketingTaxAddress);
        includeInTaxes(_oldMarketingTaxAddress);

        excludeFromRewards(marketingTaxAddress);
        excludeFromTaxes(marketingTaxAddress);

        _marketingTaxAddress = marketingTaxAddress;

        emit MarketingTaxAddressChange(
            _oldMarketingTaxAddress,
            _marketingTaxAddress
        );
    }

    /**
     * Updates the team tax address.
     * @param teamTaxAddress The new team tax address.
     */
    function setTeamTaxAddress(address teamTaxAddress) external onlyOwner {
        address _oldTeamTaxAddress = _teamTaxAddress;

        includeInRewards(_oldTeamTaxAddress);
        includeInTaxes(_oldTeamTaxAddress);

        excludeFromRewards(teamTaxAddress);
        excludeFromTaxes(teamTaxAddress);

        _teamTaxAddress = teamTaxAddress;

        emit TeamTaxAddressChange(_oldTeamTaxAddress, _teamTaxAddress);
    }

    /**
     * Updates the taxes. Makes sure total taxes are never above 10% and
     * reward tax is always 2% or more.
     * @param rewardsTax_ The new rewardTax value.
     * @param marketingTax_ The new marketingTax value.
     * @param teamTax_ The new teamTax value.
     */
    function setTaxes(
        uint256 treasuryTax_,
        uint256 rewardsTax_,
        uint256 marketingTax_,
        uint256 teamTax_
    ) external onlyOwner {
        require(
            treasuryTax_ + rewardsTax_ + marketingTax_ + teamTax_ <= 12,
            "Total taxes should never be more than 12%."
        );

        _treasuryTax = treasuryTax_;
        _rewardsTax = rewardsTax_;
        _marketingTax = marketingTax_;
        _teamTax = teamTax_;

        emit TaxesChange(_treasuryTax, _rewardsTax, _marketingTax, _teamTax);
    }

    /**
     * Distributes an amount from the sender's wallet to all holders.
     * Can only be called by Owner, or an address that is a distributor.
     * @param amount The amount of tokens to be distributed.
     */
    function distribute(uint256 amount) external {
        require(
            _distributionAddress[_msgSender()] || owner() == _msgSender(),
            "Only owner and distribution addresses can call this function."
        );

        uint256 balance = balanceOf(_msgSender());

        require(balance >= amount, "Distribution amount exceeds balance");

        uint256 burnAmount = (amount * _distributionBurnRate) / 100;
        uint256 distributionAmount = amount - burnAmount;

        if (burnAmount > 0) {
            transfer(_deadAddress, burnAmount);
            balance = balanceOf(_msgSender());
            _burnedSupply += burnAmount;
            emit Burn(_msgSender(), burnAmount);
        }

        uint256 rate = _getRewardsRate();
        uint256 amountRewardPoints = _getRewardPointsFromBalance(
            distributionAmount,
            rate
        );

        if (_excludedFromRewards[_msgSender()]) {
            _supplyOwned[_msgSender()] -= distributionAmount;
            _excludedSupply -= distributionAmount;
            _excludedRewardPoints -= amountRewardPoints;
        } else {
            uint256 balanceRewardPoints = _getRewardPointsFromBalance(
                balance,
                rate
            );

            _rewardPointsOwned[_msgSender()] =
                balanceRewardPoints -
                amountRewardPoints;
        }

        _rewardPoints -= amountRewardPoints;
        _distributedSupply += distributionAmount;

        emit Distribution(_msgSender(), distributionAmount);
    }

    /**
     * Calculates and sends treasury, marketing, and team funds to
     * the correct addresses.
     */
    function extractFunds() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        uint256 extractionTaxes = _treasuryTax + _marketingTax + _teamTax;

        if (extractionTaxes == 0) return;

        uint256 treasuryFunds = (contractBalance * _treasuryTax) /
            extractionTaxes;
        uint256 marketingFunds = (contractBalance * _marketingTax) /
            extractionTaxes;
        uint256 teamFunds = (contractBalance * _teamTax) / extractionTaxes;

        payable(_treasuryStakingAddress).transfer(treasuryFunds);
        payable(_marketingTaxAddress).transfer(marketingFunds);
        payable(_teamTaxAddress).transfer(teamFunds);

        emit FundsExtract(contractBalance);
    }

    /**
     * Adds an address to distributors.
     * @param account The address to be added to distributors.
     */
    function addDistributor(address account) external onlyOwner {
        require(
            !_distributionAddress[account],
            "Address is already a distributor"
        );
        _distributionAddress[account] = true;

        emit AddDistributor(account);
    }

    /**
     * Removes an address from distributors.
     * @param account The address to be removed from distributors.
     */
    function removeDistributor(address account) external onlyOwner {
        require(_distributionAddress[account], "Address is not a distributor");
        _distributionAddress[account] = false;

        emit RemoveDistributor(account);
    }

    /**
     * Includes an address in rewards. Calculates new reward points from
     * current balance to avoid pulling rewards from existing holders.
     * @param account The address to be excluded from rewards.
     */
    function includeInRewards(address account) public onlyOwner {
        if (!_excludedFromRewards[account]) return;

        uint256 rate = _getRewardsRate();
        uint256 accountSupplyBalance = balanceOf(account);
        uint256 accountRewardPoints = _getRewardPointsFromBalance(
            accountSupplyBalance,
            rate
        );

        _rewardPointsOwned[account] = accountRewardPoints;
        _excludedSupply -= accountSupplyBalance;
        _excludedRewardPoints -= accountRewardPoints;

        _excludedFromRewards[account] = false;

        emit IncludeInRewards(account);
    }

    /**
     * Excludes an address from rewards. Calculates new Balance from current
     * reward points.
     * @param account The address to be included in rewards.
     */
    function excludeFromRewards(address account) public onlyOwner {
        if (_excludedFromRewards[account]) return;

        uint256 rate = _getRewardsRate();
        uint256 accountSupplyBalance = balanceOf(account);
        uint256 accountRewardPoints = _getRewardPointsFromBalance(
            accountSupplyBalance,
            rate
        );

        _supplyOwned[account] = accountSupplyBalance;
        _excludedSupply += accountSupplyBalance;
        _excludedRewardPoints += accountRewardPoints;

        _excludedFromRewards[account] = true;

        emit ExcludeFromRewards(account);
    }

    /**
     * Includces an address in taxes.
     * @param account The address to be included in taxes.
     */
    function includeInTaxes(address account) public onlyOwner {
        if (!_excludedFromTaxes[account]) return;
        _excludedFromTaxes[account] = false;

        emit IncludeInTaxes(account);
    }

    /**
     * Excludes an address from taxes.
     * @param account The address to be excluded from taxes.
     */
    function excludeFromTaxes(address account) public onlyOwner {
        if (_excludedFromTaxes[account]) return;
        _excludedFromTaxes[account] = true;

        emit ExcludeFromTaxes(account);
    }

    /**
     * Enables the 0.2% transfer amount limit.
     */
    function enableTransferLimit() public onlyOwner {
        require(
            _maxTransferLimit == _totalSupply,
            "Transfer limit already enabled"
        );
        _maxTransferLimit = _totalSupply / 500;

        emit EnableTransferLimit(_maxTransferLimit);
    }

    /**
     * Disables the 0.2% transfer amount limit.
     */
    function disableTransferLimit() external onlyOwner {
        require(
            _maxTransferLimit != _totalSupply,
            "Transfer limit already disabled"
        );
        _maxTransferLimit = _totalSupply;

        emit DisableTransferLimit(_maxTransferLimit);
    }

    /**
     * Adds new pair address and excludes it from rewards distribution.
     * @param pairAddress The new pair address to be added.
     */
    function addPair(address pairAddress) public onlyOwner {
        _pair[pairAddress] = true;
        excludeFromRewards(pairAddress);

        emit AddPair(pairAddress);
    }

    /**
     * Updates the tax swap threshold.
     * @param threshold The new tax swap threshold.
     */
    function setTaxSwapThreshold(uint256 threshold) external onlyOwner {
        _taxSwapThreshold = threshold;

        emit TaxSwapThresholdChange(_taxSwapThreshold);
    }

    /**
     * Updates the distribution burn rate.
     * @param rate The new distribution burn rate.
     */
    function setDistributionBurnRate(uint256 rate) external onlyOwner {
        _distributionBurnRate = rate;

        emit DistributionBurnRateChange(_distributionBurnRate);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (_inSwap) return _swapTransfer(sender, recipient, amount);
        if (_pair[recipient] && !Address.isContract(sender)) _swapTaxes();

        uint256 rate = _getRewardsRate();

        uint256 afterTaxAmount = amount;
        uint256 rewardsTaxAmount;
        uint256 taxesToExclude;

        uint256 amountRewardPoints = _getRewardPointsFromBalance(amount, rate);
        uint256 afterTaxAmountRewardPoints = amountRewardPoints;

        // Take taxes only if both sender and recepient are not excluded
        // and if one of them is the liquidity pool address.
        // This doesn't exclude the taxes from _rewardPoints and _totalSupply.
        if (
            !_excludedFromTaxes[sender] &&
            !_excludedFromTaxes[recipient] &&
            (_pair[sender] || _pair[recipient])
        ) {
            require(
                amount <= _maxTransferLimit,
                "Transfer amount exceeds max transfer limit"
            );

            (afterTaxAmount, rewardsTaxAmount, taxesToExclude) = _takeTaxes(
                amount
            );

            afterTaxAmountRewardPoints = _getRewardPointsFromBalance(
                afterTaxAmount,
                rate
            );
        }

        if (_excludedFromRewards[sender]) {
            _supplyOwned[sender] -= amount;
            _excludedSupply -= amount;
            _excludedRewardPoints -= amountRewardPoints;
        } else {
            // We should already have the sender's _ownedRewardPoints, but
            // due to the rate changes we should recalculate it for more
            // precision.
            _rewardPointsOwned[sender] =
                _getRewardPointsFromBalance(balanceOf(sender), rate) -
                amountRewardPoints;
        }

        // Exclude the taxes from _rewardPoints and _totalSupply, if any.
        if (taxesToExclude != 0) {
            _excludedSupply += taxesToExclude;
            _excludedRewardPoints += _getRewardPointsFromBalance(
                taxesToExclude,
                rate
            );
        }

        // Update rewards rate before concluding the transfer so that the
        // senders get their part of the reward taxes paid. (Sent to recipient)
        if (rewardsTaxAmount != 0) {
            _rewardPoints -= _getRewardPointsFromBalance(
                rewardsTaxAmount,
                rate
            );
            rate = _getRewardsRate();

            afterTaxAmount = _getBalanceFromRewardPoints(
                afterTaxAmountRewardPoints,
                rate
            );
        }

        if (_excludedFromRewards[recipient]) {
            _supplyOwned[recipient] += afterTaxAmount;
            _excludedSupply += afterTaxAmount;
            _excludedRewardPoints += afterTaxAmountRewardPoints;
        } else {
            _rewardPointsOwned[recipient] += afterTaxAmountRewardPoints;
        }

        emit Transfer(sender, recipient, afterTaxAmount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * Lightweight version of _transfer. Used only during tax swapping to keep
     * gas fees low.
     */
    function _swapTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(
            _excludedFromRewards[sender] && _excludedFromRewards[recipient],
            "Both Contract and Pair should be excluded from rewards for tax swaps to work"
        );
        _supplyOwned[sender] -= amount;
        _supplyOwned[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /**
     * Swaps the accumulated marketing and team taxes to ETH and sends
     * the corresponding amounts to the marketing and team tax wallets.
     */
    function _swapTaxes() internal swapLock {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance < _taxSwapThreshold) return;

        _approve(address(this), address(_router), contractBalance);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _router.swapExactTokensForETH(
            contractBalance,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    /**
     * Calculates and assigns tax amounts to the contract.
     * @param amount The amount to take taxes from.
     */
    function _takeTaxes(uint256 amount)
        internal
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 treasuryTaxAmount = (amount * _treasuryTax) / 100;
        uint256 rewardsTaxAmount = (amount * _rewardsTax) / 100;
        uint256 marketingTaxAmount = (amount * _marketingTax) / 100;
        uint256 teamTaxAmount = (amount * _teamTax) / 100;

        uint256 afterTaxAmount = amount -
            treasuryTaxAmount -
            rewardsTaxAmount -
            marketingTaxAmount -
            teamTaxAmount;

        _supplyOwned[address(this)] +=
            treasuryTaxAmount +
            marketingTaxAmount +
            teamTaxAmount;

        return (
            afterTaxAmount,
            rewardsTaxAmount,
            treasuryTaxAmount + marketingTaxAmount + teamTaxAmount
        );
    }

    /**
     * Calculates current rewards rate.
     */
    function _getRewardsRate() internal view returns (uint256) {
        uint256 remainingRewardPoints = _rewardPoints - _excludedRewardPoints;
        uint256 remainingTotalSupply = _totalSupply - _excludedSupply;

        if (remainingRewardPoints == 0 || remainingTotalSupply == 0)
            return _rewardPoints / _totalSupply;

        return remainingRewardPoints / remainingTotalSupply;
    }

    /**
     * Calculates reward points from balance.
     * @param balance The balance to calculate from.
     */
    function _getRewardPointsFromBalance(uint256 balance, uint256 rate)
        internal
        pure
        returns (uint256)
    {
        return balance * rate;
    }

    /**
     * Calculates balance from reward points.
     * @param rewardPoints The amount of reward points to calculate from.
     */
    function _getBalanceFromRewardPoints(uint256 rewardPoints, uint256 rate)
        internal
        pure
        returns (uint256)
    {
        return rewardPoints / rate;
    }

    receive() external payable {}
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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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