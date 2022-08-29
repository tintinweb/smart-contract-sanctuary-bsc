// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "./interfaces/IRewardsDistribution.sol";
import "./interfaces/IUserInfoRegistry.sol";
import "./interfaces/tokens/IDBNB.sol";

import "./abstract/AbstractPool.sol";

contract LiquidityPool is ILiquidityPool, AbstractPool, ERC20Upgradeable {
    using SafeERC20 for IERC20;
    using DecimalsConverter for uint256;
    using MathHelper for uint256;

    IRewardsDistribution private rewardsDistribution;
    IUserInfoRegistry private userInfoRegistry;

    mapping(address => UserLastLiquidity) public override lastLiquidity;

    function liquidityPoolInitialize(
        address _assetAddr,
        bytes32 _assetKey,
        string calldata _tokenSymbol
    ) external override initializer {
        __ERC20_init(
            string(abi.encodePacked("DeFaino ", _tokenSymbol)),
            string(abi.encodePacked("lp", _tokenSymbol))
        );
        _abstractPoolInitialize(_assetAddr, _assetKey);
    }

    function setDependencies(address _contractsRegistry) public virtual override dependant {
        super.setDependencies(_contractsRegistry);

        rewardsDistribution = IRewardsDistribution(
            IRegistry(_contractsRegistry).getRewardsDistributionContract()
        );
        userInfoRegistry = IUserInfoRegistry(
            IRegistry(_contractsRegistry).getUserInfoRegistryContract()
        );
    }

    receive() external payable {}

    function addLiquidity(address _userAddr, uint256 _liquidityAmount)
        external
        payable
        override
        onlyDefiCore
    {
        _ifNativePoolCheck(_userAddr, _liquidityAmount);

        uint256 _assetAmount = _convertToUnderlyingAsset(_liquidityAmount);

        require(
            IERC20(assetAddr).balanceOf(_userAddr) >= _assetAmount,
            "LiquidityPool: Not enough tokens on account."
        );

        updateCompoundRate(true);

        uint256 _mintAmount = convertAssetToLPTokens(_liquidityAmount);

        _updateUserLastLiquidity(_userAddr, _mintAmount, true);

        _mint(_userAddr, _mintAmount);

        IERC20(assetAddr).safeTransferFrom(_userAddr, address(this), _assetAmount);
    }

    function withdrawLiquidity(
        address _userAddr,
        uint256 _liquidityAmount,
        bool _isMaxWithdraw
    ) external override onlyDefiCore {
        if (!_isMaxWithdraw) {
            require(
                getAggregatedLiquidityAmount() >= _liquidityAmount,
                "LiquidityPool: Not enough liquidity available on the contract."
            );
        }

        uint256 _toBurnLP = convertAssetToLPTokens(_liquidityAmount);

        if (_isMaxWithdraw) {
            uint256 _userLPBalance = balanceOf(_userAddr);

            /// @dev Needed to withdraw all funds without a balance
            if (convertLPTokensToAsset(_userLPBalance) <= _liquidityAmount) {
                _toBurnLP = _userLPBalance;
            }
        } else {
            require(
                balanceOf(_userAddr) - getCurrentLastLiquidity(_userAddr) >= _toBurnLP,
                "LiquidityPool: Not enough lpTokens to withdraw liquidity."
            );
        }

        _burn(_userAddr, _toBurnLP);

        _sendAssetTokens(_userAddr, _liquidityAmount);

        if (!_isMaxWithdraw) {
            require(
                getBorrowPercentage() <= assetParameters.getMaxUtilizationRatio(assetKey),
                "LiquidityPool: Utilization ratio after withdraw cannot be greater than the maximum."
            );
        }
    }

    function liquidate(
        address _userAddr,
        address _liquidatorAddr,
        uint256 _liquidityAmount
    ) external override onlyDefiCore {
        updateCompoundRate(true);

        _burn(_userAddr, convertAssetToLPTokens(_liquidityAmount));

        _sendAssetTokens(_liquidatorAddr, _liquidityAmount);
    }

    function getAPY() external view override returns (uint256) {
        uint256 _totalBorrowedAmount = aggregatedBorrowedAmount;

        if (totalSupply() == 0) {
            return 0;
        }

        uint256 _currentInterest = _totalBorrowedAmount.mulWithPrecision(
            DECIMAL + getAnnualBorrowRate()
        ) - _totalBorrowedAmount;

        return
            _currentInterest.mulDiv(
                DECIMAL - assetParameters.getReserveFactor(assetKey),
                getTotalLiquidity()
            );
    }

    function getTotalLiquidity() public view override returns (uint256) {
        return convertLPTokensToAsset(totalSupply());
    }

    function getAggregatedLiquidityAmount() public view override returns (uint256) {
        return
            _convertFromUnderlyingAsset(IERC20(assetAddr).balanceOf(address(this))) -
            totalReserves;
    }

    function getBorrowPercentage() public view override returns (uint256) {
        return _getBorrowPercentage(0);
    }

    function getAvailableToBorrowLiquidity() public view override returns (uint256) {
        uint256 _absoluteBorrowAmount = aggregatedBorrowedAmount;
        uint256 _maxAvailableLiquidity = (_absoluteBorrowAmount + getAggregatedLiquidityAmount())
            .mulWithPrecision(assetParameters.getMaxUtilizationRatio(assetKey));

        if (_maxAvailableLiquidity <= _absoluteBorrowAmount) return 0;

        return _maxAvailableLiquidity - _absoluteBorrowAmount;
    }

    function getAnnualBorrowRate()
        public
        view
        override(IBasicPool, AbstractPool)
        returns (uint256)
    {
        uint256 _utilizationRatio = getBorrowPercentage();

        if (_utilizationRatio == 0) {
            return 0;
        }

        IAssetParameters.InterestRateParams memory _params = assetParameters.getInterestRateParams(
            assetKey
        );
        uint256 _utilizationBreakingPoint = _params.utilizationBreakingPoint;

        if (_utilizationRatio < _utilizationBreakingPoint) {
            return
                AnnualRatesConverter.getAnnualRate(
                    0,
                    _params.firstSlope,
                    _utilizationRatio,
                    0,
                    _utilizationBreakingPoint,
                    DECIMAL
                );
        } else {
            return
                AnnualRatesConverter.getAnnualRate(
                    _params.firstSlope,
                    _params.secondSlope,
                    _utilizationRatio,
                    _utilizationBreakingPoint,
                    DECIMAL,
                    DECIMAL
                );
        }
    }

    function convertAssetToLPTokens(uint256 _assetAmount) public view override returns (uint256) {
        return _assetAmount.divWithPrecision(exchangeRate());
    }

    function convertLPTokensToAsset(uint256 _lpTokensAmount)
        public
        view
        override
        returns (uint256)
    {
        return _lpTokensAmount.mulWithPrecision(exchangeRate());
    }

    function exchangeRate() public view override returns (uint256) {
        uint256 _totalSupply = totalSupply();

        if (_totalSupply == 0) {
            return DECIMAL;
        }

        uint256 _aggregatedBorrowedAmount = aggregatedBorrowedAmount;
        uint256 _totalBorrowedAmount = getTotalBorrowedAmount();
        uint256 _currentBorrowInterest = _totalBorrowedAmount > _aggregatedBorrowedAmount
            ? (_totalBorrowedAmount - _aggregatedBorrowedAmount).mulWithPrecision(
                DECIMAL - assetParameters.getReserveFactor(assetKey)
            )
            : 0;

        return
            (_currentBorrowInterest + _aggregatedBorrowedAmount + getAggregatedLiquidityAmount())
                .divWithPrecision(_totalSupply);
    }

    function getCurrentLastLiquidity(address _userAddr) public view override returns (uint256) {
        UserLastLiquidity storage userLastLiquidity = lastLiquidity[_userAddr];

        return userLastLiquidity.blockNumber == block.number ? userLastLiquidity.liquidity : 0;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (from != address(0) && to != address(0)) {
            IDefiCore _defiCore = defiCore;
            IRewardsDistribution _rewardsDistribution = rewardsDistribution;

            if (_defiCore.isCollateralAssetEnabled(from, assetKey)) {
                uint256 _newBorrowLimit = _defiCore.getNewBorrowLimitInUSD(
                    from,
                    assetKey,
                    amount,
                    false
                );
                require(
                    _newBorrowLimit >= _defiCore.getTotalBorrowBalanceInUSD(from),
                    "LiquidityPool: Borrow limit used after transfer greater than 100%."
                );
            }

            uint256 _freeLiquidity = balanceOf(from) - getCurrentLastLiquidity(from);

            if (amount > _freeLiquidity) {
                uint256 _lastLiquidityNeeded = amount - _freeLiquidity;

                _updateUserLastLiquidity(to, _lastLiquidityNeeded, true);
                _updateUserLastLiquidity(from, _lastLiquidityNeeded, false);
            }

            userInfoRegistry.updateAssetsAfterTransfer(assetKey, from, to, amount);

            _rewardsDistribution.updateCumulativeSums(from, address(this));
            _rewardsDistribution.updateCumulativeSums(to, address(this));
        }
    }

    function _borrowAssetTokens(uint256 _amountToBorrow, address _recipient) internal override {
        _sendAssetTokens(_recipient, _amountToBorrow);
    }

    function _repayAssetTokens(uint256 _repayAmount, address _payerAddr) internal override {
        IERC20(assetAddr).safeTransferFrom(
            _payerAddr,
            address(this),
            _convertToUnderlyingAsset(_repayAmount)
        );
    }

    function _beforeBorrowCheck(uint256 _amountToBorrow, address _borrowerAddr) internal override {
        require(
            getAggregatedLiquidityAmount() >= _amountToBorrow,
            "LiquidityPool: Not enough available to borrow amount."
        );

        require(
            _getBorrowPercentage(_amountToBorrow) <=
                assetParameters.getMaxUtilizationRatio(assetKey),
            "LiquidityPool: Utilization ratio after borrow cannot be greater than the maximum."
        );
    }

    function _beforeRepayCheck(uint256 _repayAmount, address _payerAddr) internal override {
        _ifNativePoolCheck(_payerAddr, _repayAmount);
    }

    function _ifNativePoolCheck(address _userAddr, uint256 _neededAmount) internal {
        if (assetKey == systemPoolsRegistry.nativeAssetKey()) {
            IDBNB _nativeToken = IDBNB(assetAddr);
            uint256 _userTokenBalance = _nativeToken.balanceOf(_userAddr).to18(
                _nativeToken.decimals()
            );

            if (_neededAmount > _userTokenBalance) {
                uint256 _toDepositAmount = _neededAmount - _userTokenBalance;
                require(
                    msg.value >= _toDepositAmount,
                    "LiquidityPool: Wrong native currency amount."
                );

                _nativeToken.depositTo{value: _toDepositAmount}(_userAddr);

                uint256 _extraCurrency = msg.value - _toDepositAmount;

                if (_extraCurrency > 0) {
                    (bool _success, ) = _userAddr.call{value: _extraCurrency}("");
                    require(_success, "LiquidityPool: Failed to return extra currency.");
                }
            } else {
                require(
                    msg.value == 0,
                    "LiquidityPool: There are enough tokens to deposit the entire amount."
                );
            }
        } else {
            require(msg.value == 0, "LiquidityPool: Unable to add currency to a nonnative pool.");
        }
    }

    function _sendAssetTokens(address _recipient, uint256 _amountToSend) internal {
        if (assetKey != systemPoolsRegistry.nativeAssetKey()) {
            IERC20(assetAddr).safeTransfer(_recipient, _convertToUnderlyingAsset(_amountToSend));
        } else {
            IDBNB(assetAddr).withdrawTo(_recipient, _convertToUnderlyingAsset(_amountToSend));
        }
    }

    function _updateUserLastLiquidity(
        address _userAddr,
        uint256 _liquidityAmount,
        bool _isAdding
    ) internal {
        UserLastLiquidity storage userLastLiquidity = lastLiquidity[_userAddr];

        if (_isAdding) {
            userLastLiquidity.liquidity = getCurrentLastLiquidity(_userAddr) + _liquidityAmount;
        } else {
            userLastLiquidity.liquidity -= _liquidityAmount;
        }

        userLastLiquidity.blockNumber = block.number;
    }

    function _getBorrowPercentage(uint256 _additionalBorrowAmount)
        internal
        view
        returns (uint256)
    {
        uint256 _absoluteBorrowAmount = aggregatedBorrowedAmount + _additionalBorrowAmount;
        uint256 _aggregatedLiquidityAmount = getAggregatedLiquidityAmount() -
            _additionalBorrowAmount;

        if (_aggregatedLiquidityAmount == 0 && _absoluteBorrowAmount == 0) {
            return 0;
        }

        return
            _absoluteBorrowAmount.divWithPrecision(
                _absoluteBorrowAmount + _aggregatedLiquidityAmount
            );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "./IBasicPool.sol";

/**
 * This contract calculates and stores information about the distribution of rewards to users for deposits and credits
 */
interface IRewardsDistribution {
    /// @notice The structure that contains information about the pool, which is necessary for the allocation of tokens
    /// @param rewardPerBlock reward for the block in tokens. Is common for deposits and credits
    /// @param supplyCumulativeSum cumulative sum on deposits
    /// @param borrowCumulativeSum cumulative sum on borrows
    /// @param lastUpdate time of the last cumulative sum update
    struct LiquidityPoolInfo {
        uint256 rewardPerBlock;
        uint256 supplyCumulativeSum;
        uint256 borrowCumulativeSum;
        uint256 lastUpdate;
    }

    /// @notice A structure that contains information about the user's cumulative amounts and his reward
    /// @param lastSupplyCumulativeSum cumulative sum on the deposit at the time of the last update
    /// @param lastBorrowCumulativeSum cumulative sum on the borrow at the time of the last update
    /// @param aggregatedReward aggregated user reward during the last update
    struct UserDistributionInfo {
        uint256 lastSupplyCumulativeSum;
        uint256 lastBorrowCumulativeSum;
        uint256 aggregatedReward;
    }

    /// @notice The system structure, which is needed to avoid stack overflow and stores the pool stats
    /// @param supplyRewardPerBlock current reward for the block, which will go to users who deposited tokens
    /// @param borrowRewardPerBlock the current reward for the block, which will go to users that took on credit
    /// @param totalSupplyPool total pool of tokens on deposit
    /// @param totalBorrowPool total pool of tokens borrowed
    struct LiquidityPoolStats {
        uint256 supplyRewardPerBlock;
        uint256 borrowRewardPerBlock;
        uint256 totalSupplyPool;
        uint256 totalBorrowPool;
    }

    /// @notice Function to update the cumulative sums for a particular user in the passed pool
    /// @dev Can call only by eligible contracts (DefiCore and LiquidityPools)
    /// @param _userAddr address of the user to whom the cumulative sums will be updated
    /// @param _liquidityPool required liquidity pool
    function updateCumulativeSums(address _userAddr, address _liquidityPool) external;

    /// @notice Function for withdraw accumulated user rewards. Rewards are updated before withdrawal
    /// @dev Can call only by eligible contracts (DefiCore and LiquidityPools)
    /// @param _assetKey the key of the desired pool, which will be used to calculate the reward
    /// @param _userAddr the address of the user for whom the reward will be counted
    /// @param _liquidityPool required liquidity pool
    /// @return _userReward total user reward from the passed pool
    function withdrawUserReward(
        bytes32 _assetKey,
        address _userAddr,
        address _liquidityPool
    ) external returns (uint256 _userReward);

    /// @notice Function to update block rewards for desired pools
    /// @dev Can call only by contract owner. The passed arrays must be of the same length
    /// @param _assetKeys array of pool identifiers
    /// @param _rewardsPerBlock array of new rewards per block
    function setupRewardsPerBlockBatch(
        bytes32[] calldata _assetKeys,
        uint256[] calldata _rewardsPerBlock
    ) external;

    /// @notice Returns the annual distribution rates for the desired pool
    /// @param _assetKey required liquidity pool identifier
    /// @return _supplyAPY annual distribution rate for users who deposited in the passed pool
    /// @return _borrowAPY annual distribution rate for users who took credit in the passed pool
    function getAPY(bytes32 _assetKey)
        external
        view
        returns (uint256 _supplyAPY, uint256 _borrowAPY);

    /// @notice Returns current total user reward from the passed pool
    /// @param _assetKey the key of the desired pool, which will be used to calculate the reward
    /// @param _userAddr the address of the user for whom the reward will be counted
    /// @param _liquidityPool required liquidity pool
    /// @return _userReward current total user reward from the passed pool
    function getUserReward(
        bytes32 _assetKey,
        address _userAddr,
        address _liquidityPool
    ) external view returns (uint256 _userReward);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

/**
 * This is a contract that can be used to obtain information for a specific user.
 * Available information: the keys of the assets that the user has deposited and borrowed;
 * information about the user's rewards, the user's basic information, detailed information about deposits and credits
 */
interface IUserInfoRegistry {
    /// @notice The main pool parameters
    /// @param assetKey the key of the current pool. Can be thought of as a pool identifier
    /// @param assetAddr the address of the pool underlying asset
    struct MainPoolInfo {
        bytes32 assetKey;
        address assetAddr;
    }

    /// @notice The base pool parameters
    /// @param mainInfo element type MainPoolInfo structure
    /// @param utilizationRatio the current percentage of how much of the pool was borrowed for liquidity
    /// @param isCollateralEnabled shows whether the current asset is enabled as a collateral for a particular user
    struct BasePoolInfo {
        MainPoolInfo mainInfo;
        uint256 utilizationRatio;
        bool isCollateralEnabled;
    }

    /// @notice Main user information
    /// @param userCurrencyBalance total amount of the user's native currency balance
    /// @param totalSupplyBalanceInUSD total amount of the user's deposit for all assets in dollars
    /// @param totalBorrowBalanceInUSD total amount of user credits for all assets in dollars
    /// @param borrowLimitInUSD the total amount in dollars for which the user can take credit
    /// @param borrowLimitUsed current percentage of available collateral use
    struct UserMainInfo {
        uint256 userCurrencyBalance;
        uint256 totalSupplyBalanceInUSD;
        uint256 totalBorrowBalanceInUSD;
        uint256 borrowLimitInUSD;
        uint256 borrowLimitUsed;
    }

    /// @notice Structure, which contains information about user rewards for credits and deposits
    /// @param assetAddr the address of the token that is given out as a reward
    /// @param distributionReward the number of tokens the user can currently receive
    /// @param distributionRewardInUSD the equivalent of distributionReward param in dollars
    /// @param userBalance current balance of the user in tokens, which are issued as a reward
    /// @param distributionRewardInUSD the equivalent of userBalance param in dollars
    struct RewardsDistributionInfo {
        address assetAddr;
        uint256 distributionReward;
        uint256 distributionRewardInUSD;
        uint256 userBalance;
        uint256 userBalanceInUSD;
    }

    /// @notice Structure, which contains information about the pool, in which the user has made a deposit
    /// @param basePoolInfo element type BasePoolInfo structure
    /// @param marketSize the total number of pool tokens that all users have deposited
    /// @param marketSizeInUSD the equivalent of marketSize param in dollars
    /// @param userDeposit the number of tokens that the user has deposited
    /// @param userDepositInUSD the equivalent of userDeposit param in dollars
    /// @param supplyAPY annual interest rate on the deposit in the current pool
    /// @param distrSupplyAPY annual distribution rate for users who deposited in the current pool
    struct UserSupplyPoolInfo {
        BasePoolInfo basePoolInfo;
        uint256 marketSize;
        uint256 marketSizeInUSD;
        uint256 userDeposit;
        uint256 userDepositInUSD;
        uint256 supplyAPY;
        uint256 distrSupplyAPY;
    }

    /// @notice Structure, which contains information about the pool, in which the user has made a borrow
    /// @param basePoolInfo element type BasePoolInfo structure
    /// @param availableToBorrow available amount of tokens in the pool for borrows
    /// @param availableToBorrowInUSD the equivalent of availableToBorrow param in dollars
    /// @param userBorrowAmount the number of tokens that the user has borrowed in this pool
    /// @param userBorrowAmountInUSD the equivalent of userBorrowAmount param in dollars
    /// @param borrowAPY the annual interest rate on the loan, which is received by users who have taken a loan in the current pool
    /// @param distrBorrowAPY annual distribution rate for users who took credit in the current pool
    struct UserBorrowPoolInfo {
        BasePoolInfo basePoolInfo;
        uint256 availableToBorrow;
        uint256 availableToBorrowInUSD;
        uint256 userBorrowAmount;
        uint256 userBorrowAmountInUSD;
        uint256 borrowAPY;
        uint256 distrBorrowAPY;
    }

    /// @notice A structure that contains information about the user's credit and deposit in the current pool
    /// @param userWalletBalance current user balance in pool underlying tokens (token balance + currency balance, if native pool)
    /// @param userWalletBalanceInUSD the equivalent of userWalletBalance param in dollars
    /// @param userSupplyBalance the number of tokens that the user has deposited
    /// @param userSupplyBalanceInUSD the equivalent of userSupplyBalance param in dollars
    /// @param userBorrowBalance the number of tokens that the user has borrowed in this pool
    /// @param userBorrowBalanceInUSD the equivalent of userBorrowBalance param in dollars
    /// @param isCollateralEnabled shows whether the current asset is enabled as a collateral for a particular user
    struct UserPoolInfo {
        uint256 userWalletBalance;
        uint256 userWalletBalanceInUSD;
        uint256 userSupplyBalance;
        uint256 userSupplyBalanceInUSD;
        uint256 userBorrowBalance;
        uint256 userBorrowBalanceInUSD;
        bool isCollateralEnabled;
    }

    /// @notice Structure, which contains the maximum values of deposit/withdrawal, borrow/repay for a particular user
    /// @param maxToSupply maximum possible value for the deposit into the current pool
    /// @param maxToWithdraw maximum possible value to withdraw from the current pool
    /// @param maxToBorrow the maximum possible value for taking credit in the current pool
    /// @param maxToRepay the maximum possible value for the repayment of the loan in the current pool
    struct UserMaxValues {
        uint256 maxToSupply;
        uint256 maxToWithdraw;
        uint256 maxToBorrow;
        uint256 maxToRepay;
    }

    /// @notice A structure that contains general information about the user for liquidation
    /// @param borrowAssetKeys an array of keys from the pools where the user took credit
    /// @param supplyAssetKeys array of keys from pools where user deposited
    /// @param totalBorrowedAmount total amount of user credits for all assets in dollars
    struct UserLiquidationInfo {
        address userAddr;
        MainPoolInfo[] borrowPoolsInfo;
        MainPoolInfo[] sypplyPoolsInfo;
        uint256 totalBorrowedAmount;
    }

    /// @notice Structure, which contains detailed information on liquidation
    /// @param borrowAssetPrice the price of the token that the user took on credit
    /// @param receiveAssetPrice the price of the token that the liquidator will receive
    /// @param bonusReceiveAssetPrice discounted token price that the liquidator will receive
    /// @param borrowedAmount number of tokens, which the user took on credit
    /// @param supplyAmount the number of tokens that the user has deposited
    /// @param maxQuantity the maximum amount by which a liquidator can repay a user's debt
    struct UserLiquidationData {
        uint256 borrowAssetPrice;
        uint256 receiveAssetPrice;
        uint256 bonusReceiveAssetPrice;
        uint256 borrowedAmount;
        uint256 supplyAmount;
        uint256 maxQuantity;
    }

    /// @notice A system function that is needed to update users' assets after LP token transfers
    /// @dev Only LiquidityPools contracts can call this function
    /// @param _assetKey the key of the specific liquidity pool
    /// @param _from the address of the user who sends the tokens
    /// @param _to the address of the user to whom the tokens are sent
    /// @param _amount number of LP tokens that are transferred
    function updateAssetsAfterTransfer(
        bytes32 _assetKey,
        address _from,
        address _to,
        uint256 _amount
    ) external;

    /// @notice System function, which is needed to update the list of keys of pools of the user, in which he put a deposit
    /// @dev Only DefiCore contracts can call this function
    /// @param _userAddr the address of the user for whom the pool key list will be updated
    /// @param _assetKey the key of the specific liquidity pool
    function updateUserSupplyAssets(address _userAddr, bytes32 _assetKey) external;

    /// @notice System function required to update the list of keys of pools the user has taken credit from
    /// @dev Only DefiCore contracts can call this function
    /// @param _userAddr the address of the user for whom the pool key list will be updated
    /// @param _assetKey the key of the specific liquidity pool
    function updateUserBorrowAssets(address _userAddr, bytes32 _assetKey) external;

    /// @notice The function that returns for a particular user a list of keys from pools where he has deposited
    /// @param _userAddr user address
    /// @return an array of keys of pools, in which the user has made a deposit
    function getUserSupplyAssets(address _userAddr) external view returns (bytes32[] memory);

    /// @notice A function that returns, for a specific user, a list of keys from the pools where he took credit
    /// @param _userAddr user address
    /// @return an array of keys of pools, in which the user took credit
    function getUserBorrowAssets(address _userAddr) external view returns (bytes32[] memory);

    /// @notice A function that returns a structure with main user parameters
    /// @param _userAddr user address
    /// @return an UserMainInfo structure
    function getUserMainInfo(address _userAddr) external view returns (UserMainInfo memory);

    /// @notice A function that returns a structure with information about user awards
    /// @param _userAddr user address
    /// @return a RewardsDistributionInfo structure
    function getUserDistributionRewards(address _userAddr)
        external
        view
        returns (RewardsDistributionInfo memory);

    /// @notice The function that returns an array of structures with information about the pool where the user has made a deposit
    /// @param _userAddr user address
    /// @return _supplyPoolsInfo an array of UserSupplyPoolInfo structures
    function getUserSupplyPoolsInfo(address _userAddr, bytes32[] calldata _assetKeys)
        external
        view
        returns (UserSupplyPoolInfo[] memory _supplyPoolsInfo);

    /// @notice A function that returns an array of structures with information about the pool where the user took credit
    /// @param _userAddr user address
    /// @param _assetKeys an array of pool keys for which you want to get information
    /// @return _borrowPoolsInfo an array of UserBorrowPoolInfo structures
    function getUserBorrowPoolsInfo(address _userAddr, bytes32[] calldata _assetKeys)
        external
        view
        returns (UserBorrowPoolInfo[] memory _borrowPoolsInfo);

    /// @notice The function that returns information about the deposit and credit of the user in the pool
    /// @param _userAddr user address
    /// @param _assetKey pool key for which you want to get information
    /// @return an UserPoolInfo structure
    function getUserPoolInfo(address _userAddr, bytes32 _assetKey)
        external
        view
        returns (UserPoolInfo memory);

    /// @notice A function that returns information about the maximum values for the user
    /// @param _userAddr user address
    /// @param _assetKey pool key for which you want to get information
    /// @return an UserMaxValues structure
    function getUserMaxValues(address _userAddr, bytes32 _assetKey)
        external
        view
        returns (UserMaxValues memory);

    /// @notice A function that returns general information for the liquidation of a specific user
    /// @param _accounts accounts for which you need to get information
    /// @return _resultArr an array of UserLiquidationInfo structures
    function getUsersLiquidiationInfo(address[] calldata _accounts)
        external
        view
        returns (UserLiquidationInfo[] memory _resultArr);

    /// @notice Function for getting detailed liquidation information for a particular user
    /// @param _userAddr user address
    /// @param _borrowAssetKey key of the pool where the user took the credit
    /// @param _receiveAssetKey the key of the pool in which the user has deposited
    /// @return an UserLiquidationData structure
    function getUserLiquidationData(
        address _userAddr,
        bytes32 _borrowAssetKey,
        bytes32 _receiveAssetKey
    ) external view returns (UserLiquidationData memory);

    /// @notice Function for obtaining the maximum possible amount for liquidation
    /// @param _userAddr user address
    /// @param _supplyAssetKey the key of the pool in which the user has deposited
    /// @param _borrowAssetKey key of the pool where the user took the credit
    /// @return _maxQuantityInUSD maximum amount for liquidation in dollars
    function getMaxLiquidationQuantity(
        address _userAddr,
        bytes32 _supplyAssetKey,
        bytes32 _borrowAssetKey
    ) external view returns (uint256 _maxQuantityInUSD);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

interface IDBNB is IERC20Metadata, IERC20Permit {
    function deposit() external payable;

    function depositTo(address _recipient) external payable;

    function withdraw(uint256 _amount) external;

    function withdrawTo(address _recipient, uint256 _amount) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";
import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "../interfaces/IDefiCore.sol";
import "../interfaces/IAssetParameters.sol";
import "../interfaces/ISystemParameters.sol";
import "../interfaces/ISystemPoolsRegistry.sol";
import "../interfaces/IBasicPool.sol";
import "../interfaces/IPriceManager.sol";
import "../interfaces/IInterestRateLibrary.sol";

import "../libraries/AnnualRatesConverter.sol";
import "../libraries/MathHelper.sol";

import "../Registry.sol";
import "../CompoundRateKeeper.sol";

abstract contract AbstractPool is IBasicPool, Initializable, AbstractDependant {
    using SafeERC20 for IERC20;
    using DecimalsConverter for uint256;
    using MathHelper for uint256;

    uint256 public constant UPDATE_RATE_INTERVAL = 1 hours;

    IDefiCore internal defiCore;
    IAssetParameters internal assetParameters;
    ISystemParameters internal systemParameters;
    ISystemPoolsRegistry internal systemPoolsRegistry;
    IPriceManager internal priceManager;
    IInterestRateLibrary internal interestRateLibrary;

    CompoundRateKeeper public compoundRateKeeper;

    address public override assetAddr;
    bytes32 public override assetKey;

    uint256 public override aggregatedBorrowedAmount;
    uint256 public aggregatedNormalizedBorrowedAmount;
    uint256 public override totalReserves;

    mapping(address => BorrowInfo) public override borrowInfos;
    mapping(address => mapping(address => uint256)) public borrowAllowances;

    modifier onlyDefiCore() {
        require(address(defiCore) == msg.sender, "AbstractPool: Caller not a DefiCore.");
        _;
    }

    function setDependencies(address _contractsRegistry) public virtual override dependant {
        IRegistry _registry = IRegistry(_contractsRegistry);

        defiCore = IDefiCore(_registry.getDefiCoreContract());
        assetParameters = IAssetParameters(_registry.getAssetParametersContract());
        systemParameters = ISystemParameters(_registry.getSystemParametersContract());
        systemPoolsRegistry = ISystemPoolsRegistry(_registry.getSystemPoolsRegistryContract());
        priceManager = IPriceManager(_registry.getPriceManagerContract());
        interestRateLibrary = IInterestRateLibrary(_registry.getInterestRateLibraryContract());
    }

    function approveToBorrow(
        address _userAddr,
        uint256 _approveAmount,
        address _delegateeAddr,
        uint256 _currentAllowance
    ) external override onlyDefiCore {
        require(
            borrowAllowances[_userAddr][_delegateeAddr] == _currentAllowance,
            "AbstractPool: The current allowance is not the same as expected."
        );
        borrowAllowances[_userAddr][_delegateeAddr] = _approveAmount;
    }

    function borrowFor(
        address _userAddr,
        address _recipient,
        uint256 _amountToBorrow
    ) external override onlyDefiCore {
        _borrowFor(_userAddr, _recipient, _amountToBorrow);
    }

    function delegateBorrow(
        address _userAddr,
        address _delegatee,
        uint256 _amountToBorrow
    ) external override onlyDefiCore {
        uint256 borrowAllowance = borrowAllowances[_userAddr][_delegatee];

        require(
            borrowAllowance >= _amountToBorrow,
            "AbstractPool: Not enough allowed to borrow amount."
        );

        borrowAllowances[_userAddr][_delegatee] = borrowAllowance - _amountToBorrow;

        _borrowFor(_userAddr, _delegatee, _amountToBorrow);
    }

    function repayBorrowFor(
        address _userAddr,
        address _closureAddr,
        uint256 _repayAmount,
        bool _isMaxRepay
    ) external payable override onlyDefiCore returns (uint256) {
        RepayBorrowVars memory _repayBorrowVars = _getRepayBorrowVars(
            _userAddr,
            _repayAmount,
            _isMaxRepay
        );

        _beforeRepayCheck(_repayBorrowVars.repayAmount, _closureAddr);

        if (_repayBorrowVars.currentAbsoluteAmount == 0) {
            return 0;
        }

        BorrowInfo storage borrowInfo = borrowInfos[_userAddr];

        uint256 _currentInterest = _repayBorrowVars.currentAbsoluteAmount -
            borrowInfo.borrowAmount;

        if (_repayBorrowVars.repayAmount > _currentInterest) {
            borrowInfo.borrowAmount =
                _repayBorrowVars.currentAbsoluteAmount -
                _repayBorrowVars.repayAmount;
            aggregatedBorrowedAmount -= _repayBorrowVars.repayAmount - _currentInterest;
        }

        aggregatedNormalizedBorrowedAmount = MathHelper.getNormalizedAmount(
            aggregatedBorrowedAmount,
            aggregatedNormalizedBorrowedAmount,
            _repayBorrowVars.repayAmount,
            _repayBorrowVars.currentRate,
            false
        );

        borrowInfo.normalizedAmount = MathHelper.getNormalizedAmount(
            borrowInfo.borrowAmount,
            _repayBorrowVars.normalizedAmount,
            _repayBorrowVars.repayAmount,
            _repayBorrowVars.currentRate,
            false
        );

        uint256 _reserveFunds = Math
            .min(_currentInterest, _repayBorrowVars.repayAmount)
            .mulWithPrecision(assetParameters.getReserveFactor(assetKey));

        totalReserves += _reserveFunds;

        _repayAssetTokens(_repayBorrowVars.repayAmount, _closureAddr);

        return _repayBorrowVars.repayAmount;
    }

    function withdrawReservedFunds(
        address _recipientAddr,
        uint256 _amountToWithdraw,
        bool _isAllFunds
    ) external override onlyDefiCore returns (uint256) {
        uint256 _currentReserveAmount = totalReserves;

        if (_currentReserveAmount == 0) {
            return 0;
        }

        if (_isAllFunds) {
            _amountToWithdraw = _currentReserveAmount;
        } else {
            require(
                _amountToWithdraw <= _currentReserveAmount,
                "LiquidityPool: Not enough reserved funds."
            );
        }

        totalReserves = _currentReserveAmount - _amountToWithdraw;

        IERC20(assetAddr).safeTransfer(
            _recipientAddr,
            _convertToUnderlyingAsset(_amountToWithdraw)
        );

        return getAmountInUSD(_amountToWithdraw);
    }

    function updateCompoundRate(bool _withInterval) public override returns (uint256) {
        CompoundRateKeeper _cr = compoundRateKeeper;

        if (_withInterval && _cr.getLastUpdate() + UPDATE_RATE_INTERVAL > block.timestamp) {
            return _cr.getCurrentRate();
        } else {
            return
                _cr.update(
                    AnnualRatesConverter.convertToRatePerSecond(
                        interestRateLibrary,
                        getAnnualBorrowRate(),
                        ONE_PERCENT
                    )
                );
        }
    }

    function getTotalBorrowedAmount() public view override returns (uint256) {
        /**
         * @dev In this section of code we have an integer division, which loses 1 wei.
         * It is critical in some functions of the system (for example, in exchangeRate when calculating the interest that has accrued in the pool)
         */
        return
            aggregatedNormalizedBorrowedAmount.mulWithPrecision(
                compoundRateKeeper.getCurrentRate()
            ) + 1;
    }

    function getAmountInUSD(uint256 _assetAmount) public view override returns (uint256) {
        return _assetAmount.mulDiv(getAssetPrice(), ONE_TOKEN);
    }

    function getAmountFromUSD(uint256 _usdAmount) public view override returns (uint256) {
        return _usdAmount.mulDiv(ONE_TOKEN, getAssetPrice());
    }

    function getAssetPrice() public view override returns (uint256) {
        (uint256 _price, uint8 _currentPriceDecimals) = priceManager.getPrice(assetKey);

        return _price.convert(_currentPriceDecimals, PRICE_DECIMALS);
    }

    function getUnderlyingDecimals() public view override returns (uint8) {
        return IERC20Metadata(assetAddr).decimals();
    }

    function getCurrentRate() public view override returns (uint256) {
        return compoundRateKeeper.getCurrentRate();
    }

    function getNewCompoundRate() public view override returns (uint256) {
        return
            compoundRateKeeper.getNewCompoundRate(
                AnnualRatesConverter.convertToRatePerSecond(
                    interestRateLibrary,
                    getAnnualBorrowRate(),
                    ONE_PERCENT
                )
            );
    }

    function getAnnualBorrowRate() public view virtual override returns (uint256);

    function _borrowFor(
        address _userAddr,
        address _recipient,
        uint256 _amountToBorrow
    ) internal {
        uint256 _currentRate = updateCompoundRate(true);

        _beforeBorrowCheck(_amountToBorrow, _userAddr);

        aggregatedBorrowedAmount += _amountToBorrow;
        aggregatedNormalizedBorrowedAmount = MathHelper.getNormalizedAmount(
            0,
            aggregatedNormalizedBorrowedAmount,
            _amountToBorrow,
            _currentRate,
            true
        );

        BorrowInfo storage borrowInfo = borrowInfos[_userAddr];

        borrowInfo.borrowAmount += _amountToBorrow;
        borrowInfo.normalizedAmount = MathHelper.getNormalizedAmount(
            0,
            borrowInfo.normalizedAmount,
            _amountToBorrow,
            _currentRate,
            true
        );

        _borrowAssetTokens(_amountToBorrow, _recipient);
    }

    function _getRepayBorrowVars(
        address _userAddr,
        uint256 _repayAmount,
        bool _isMaxRepay
    ) internal returns (RepayBorrowVars memory _repayBorrowVars) {
        _repayBorrowVars.userAddr = _userAddr;
        _repayBorrowVars.currentRate = updateCompoundRate(false);
        _repayBorrowVars.normalizedAmount = borrowInfos[_userAddr].normalizedAmount;
        _repayBorrowVars.currentAbsoluteAmount = _repayBorrowVars
            .normalizedAmount
            .mulWithPrecision(_repayBorrowVars.currentRate);

        if (_isMaxRepay) {
            uint256 _userBalance = _convertFromUnderlyingAsset(
                IERC20(assetAddr).balanceOf(_userAddr)
            );

            if (assetKey == systemPoolsRegistry.nativeAssetKey()) {
                _userBalance += msg.value;
            }

            _repayBorrowVars.repayAmount = Math.min(
                _userBalance,
                _repayBorrowVars.currentAbsoluteAmount
            );

            require(
                _repayBorrowVars.repayAmount > 0,
                "AbstractPool: Repay amount cannot be a zero."
            );
        } else {
            _repayBorrowVars.repayAmount = Math.min(
                _repayBorrowVars.currentAbsoluteAmount,
                _repayAmount
            );
        }
    }

    function _abstractPoolInitialize(address _assetAddr, bytes32 _assetKey)
        internal
        onlyInitializing
    {
        compoundRateKeeper = new CompoundRateKeeper();
        assetAddr = _assetAddr;
        assetKey = _assetKey;
    }

    function _borrowAssetTokens(uint256 _amountToBorrow, address _recipient) internal virtual;

    function _repayAssetTokens(uint256 _repayAmount, address _payerAddr) internal virtual;

    function _beforeBorrowCheck(uint256 _amountToBorrow, address _borrowerAddr) internal virtual {}

    function _beforeRepayCheck(uint256 _repayAmount, address _payerAddr) internal virtual {}

    function _convertToUnderlyingAsset(uint256 _amountToConvert)
        internal
        view
        returns (uint256 _assetAmount)
    {
        _assetAmount = _amountToConvert.from18(getUnderlyingDecimals());

        require(_assetAmount > 0, "AbstractPool: Incorrect asset amount after conversion.");
    }

    function _convertFromUnderlyingAsset(uint256 _amountToConvert)
        internal
        view
        returns (uint256 _assetAmount)
    {
        return _amountToConvert.to18(getUnderlyingDecimals());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

/**
 * This is the basic abstract loan pool.
 * Needed to inherit from it all the custom pools of the system
 */
interface IBasicPool {
    /// @notice A structure that contains information about user borrows
    /// @param borrowAmount absolute amount of borrow in tokens
    /// @param normalizedAmount normalized user borrow amount
    struct BorrowInfo {
        uint256 borrowAmount;
        uint256 normalizedAmount;
    }

    /// @notice System structure, which is needed to avoid stack overflow and stores the information to repay the borrow
    /// @param repayAmount amount in tokens for repayment
    /// @param currentAbsoluteAmount user debt with interest
    /// @param normalizedAmount normalized user borrow amount
    /// @param currentRate current pool compound rate
    /// @param userAddr address of the user who will repay the debt
    struct RepayBorrowVars {
        uint256 repayAmount;
        uint256 currentAbsoluteAmount;
        uint256 normalizedAmount;
        uint256 currentRate;
        address userAddr;
    }

    /// @notice The function is needed to allow addresses to borrow against your address for the desired amount
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user who makes the approval
    /// @param _approveAmount the amount for which the approval is made
    /// @param _delegateeAddr address who is allowed to borrow the passed amount
    /// @param _currentAllowance allowance before function execution
    function approveToBorrow(
        address _userAddr,
        uint256 _approveAmount,
        address _delegateeAddr,
        uint256 _currentAllowance
    ) external;

    /// @notice The function that allows you to take a borrow and send borrowed tokens to the desired address
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user to whom the credit will be taken
    /// @param _recipient the address that will receive the borrowed tokens
    /// @param _amountToBorrow amount to borrow in tokens
    function borrowFor(
        address _userAddr,
        address _recipient,
        uint256 _amountToBorrow
    ) external;

    /// @notice A function by which you can take credit for the address that gave you permission to do so
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user to whom the credit will be taken
    /// @param _delegator the address that will receive the borrowed tokens
    /// @param _amountToBorrow amount to borrow in tokens
    function delegateBorrow(
        address _userAddr,
        address _delegator,
        uint256 _amountToBorrow
    ) external;

    /// @notice Function for repayment of a specific user's debt
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user from whom the funds will be deducted to repay the debt
    /// @param _closureAddr address of the user to whom the debt will be repaid
    /// @param _repayAmount the amount to repay the debt
    /// @param _isMaxRepay a flag that shows whether or not to repay the debt by the maximum possible amount
    /// @return repayment amount
    function repayBorrowFor(
        address _userAddr,
        address _closureAddr,
        uint256 _repayAmount,
        bool _isMaxRepay
    ) external payable returns (uint256);

    /// @notice Function for withdrawal of reserve funds from the pool
    /// @dev Only SystemPoolsRegistry contract can call this function. The function takes the amount with 18 decimals
    /// @param _recipientAddr the address of the user who will receive the reserve tokens
    /// @param _amountToWithdraw number of reserve funds for withdrawal
    /// @param _isAllFunds flag that shows whether to withdraw all reserve funds or not
    function withdrawReservedFunds(
        address _recipientAddr,
        uint256 _amountToWithdraw,
        bool _isAllFunds
    ) external returns (uint256);

    /// @notice Function to update the compound rate with or without interval
    /// @param _withInterval flag that shows whether to update the rate with or without interval
    /// @return new compound rate
    function updateCompoundRate(bool _withInterval) external returns (uint256);

    /// @notice Function to get the underlying asset address
    /// @return an address of the underlying asset
    function assetAddr() external view returns (address);

    /// @notice Function to get a pool key
    /// @return a pool key
    function assetKey() external view returns (bytes32);

    /// @notice Function to get the pool total number of tokens borrowed without interest
    /// @return total borrowed amount without interest
    function aggregatedBorrowedAmount() external view returns (uint256);

    /// @notice Function to get the total amount of reserve funds
    /// @return total reserve funds
    function totalReserves() external view returns (uint256);

    /// @notice Function to get information about the user's borrow
    /// @param _userAddr address of the user for whom you want to get information
    /// @return borrowAmount absolute amount of borrow in tokens
    /// @return normalizedAmount normalized user borrow amount
    function borrowInfos(address _userAddr)
        external
        view
        returns (uint256 borrowAmount, uint256 normalizedAmount);

    /// @notice Function to get the total borrowed amount with interest
    /// @return total borrowed amount with interest
    function getTotalBorrowedAmount() external view returns (uint256);

    /// @notice Function to convert the amount in tokens to the amount in dollars
    /// @param _assetAmount amount in asset tokens
    /// @return an amount in dollars
    function getAmountInUSD(uint256 _assetAmount) external view returns (uint256);

    /// @notice Function to convert the amount in dollars to the amount in tokens
    /// @param _usdAmount amount in dollars
    /// @return an amount in asset tokens
    function getAmountFromUSD(uint256 _usdAmount) external view returns (uint256);

    /// @notice Function to get the price of an underlying asset
    /// @return an underlying asset price
    function getAssetPrice() external view returns (uint256);

    /// @notice Function to get the underlying token decimals
    /// @return an underlying token decimals
    function getUnderlyingDecimals() external view returns (uint8);

    /// @notice Function to get the last updated compound rate
    /// @return a last updated compound rate
    function getCurrentRate() external view returns (uint256);

    /// @notice Function to get the current compound rate
    /// @return a current compound rate
    function getNewCompoundRate() external view returns (uint256);

    /// @notice Function to get the current annual interest rate on the borrow
    /// @return a current annual interest rate on the borrow
    function getAnnualBorrowRate() external view returns (uint256);
}

/**
 * Pool contract only for loans with a fixed annual rate
 */
interface IStablePool is IBasicPool {
    /// @notice Function to initialize a new stable pool
    /// @param _assetAddr address of the underlying pool asset
    /// @param _assetKey pool key of the current liquidity pool
    function stablePoolInitialize(address _assetAddr, bytes32 _assetKey) external;
}

/**
 * This is the central contract of the protocol, which is the pool for liquidity.
 * All interaction takes place through the DefiCore contract
 */
interface ILiquidityPool is IBasicPool {
    /// @notice A structure that contains information about user last added liquidity
    /// @param liquidity a total amount of the last liquidity
    /// @param blockNumber block number at the time of the last liquidity entry
    struct UserLastLiquidity {
        uint256 liquidity;
        uint256 blockNumber;
    }

    /// @notice The function that is needed to initialize the pool after it is created
    /// @dev This function can call only once
    /// @param _assetAddr address of the underlying pool asset
    /// @param _assetKey pool key of the current liquidity pool
    /// @param _tokenSymbol symbol of the underlying pool asset
    function liquidityPoolInitialize(
        address _assetAddr,
        bytes32 _assetKey,
        string memory _tokenSymbol
    ) external;

    /// @notice Function for adding liquidity to the pool
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user to whom the liquidity will be added
    /// @param _liquidityAmount amount of liquidity to add
    function addLiquidity(address _userAddr, uint256 _liquidityAmount) external payable;

    /// @notice Function for withdraw liquidity from the passed address
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user from which the liquidity will be withdrawn
    /// @param _liquidityAmount amount of liquidity to withdraw
    /// @param _isMaxWithdraw the flag that shows whether to withdraw the maximum available amount or not
    function withdrawLiquidity(
        address _userAddr,
        uint256 _liquidityAmount,
        bool _isMaxWithdraw
    ) external;

    /// @notice Function for writing off the collateral from the address of the person being liquidated during liquidation
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user from whom the collateral will be debited
    /// @param _liquidatorAddr address of the liquidator to whom the tokens will be sent
    /// @param _liquidityAmount number of tokens to send
    function liquidate(
        address _userAddr,
        address _liquidatorAddr,
        uint256 _liquidityAmount
    ) external;

    /// @notice Function for getting the liquidity entered by the user in a certain block
    /// @param _userAddr address of the user for whom you want to get information
    /// @return liquidity amount
    function lastLiquidity(address _userAddr) external view returns (uint256, uint256);

    /// @notice Function to get the annual rate on the deposit
    /// @return annual deposit interest rate
    function getAPY() external view returns (uint256);

    /// @notice Function to get the total liquidity in the pool with interest
    /// @return total liquidity in the pool with interest
    function getTotalLiquidity() external view returns (uint256);

    /// @notice Function to get the current amount of liquidity in the pool without reserve funds
    /// @return aggregated liquidity amount without reserve funds
    function getAggregatedLiquidityAmount() external view returns (uint256);

    /// @notice Function to get the current percentage of how many tokens were borrowed
    /// @return an borrow percentage (utilization ratio)
    function getBorrowPercentage() external view returns (uint256);

    /// @notice Function for obtaining available liquidity for credit
    /// @return an available to borrow liquidity
    function getAvailableToBorrowLiquidity() external view returns (uint256);

    /// @notice Function to convert from the amount in the asset to the amount in lp tokens
    /// @param _assetAmount amount in asset tokens
    /// @return an amount in lp tokens
    function convertAssetToLPTokens(uint256 _assetAmount) external view returns (uint256);

    /// @notice Function to convert from the amount amount in lp tokens to the amount in the asset
    /// @param _lpTokensAmount amount in lp tokens
    /// @return an amount in asset tokens
    function convertLPTokensToAsset(uint256 _lpTokensAmount) external view returns (uint256);

    /// @notice Function to get the exchange rate between asset tokens and lp tokens
    /// @return current exchange rate
    function exchangeRate() external view returns (uint256);

    /// @notice Function for getting the last liquidity by current block
    /// @param _userAddr address of the user for whom you want to get information
    /// @return a last liquidity amount (if current block number != last block number returns zero)
    function getCurrentLastLiquidity(address _userAddr) external view returns (uint256);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 *  @notice The ContractsRegistry module
 *
 *  This is a contract that must be used as dependencies accepter in the dependency injection mechanism.
 *  Upon the injection, the Injector (ContractsRegistry most of the time) will call the `setDependencies()` function.
 *  The dependant contract will have to pull the required addresses from the supplied ContractsRegistry as a parameter.
 *
 *  The AbstractDependant is fully compatible with proxies courtesy of custom storage slot.
 */
abstract contract AbstractDependant {
    /**
     *  @notice The slot where the dependency injector is located.
     *  @dev keccak256(AbstractDependant.setInjector(address)) - 1
     *
     *  Only the injector is allowed to inject dependencies.
     *  The first to call the setDependencies() (with the modifier applied) function becomes an injector
     */
    bytes32 private constant _INJECTOR_SLOT =
        0xd6b8f2e074594ceb05d47c27386969754b6ad0c15e5eb8f691399cd0be980e76;

    modifier dependant() {
        _checkInjector();
        _;
        _setInjector(msg.sender);
    }

    /**
     *  @notice The function that will be called from the ContractsRegistry (or factory) to inject dependencies.
     *  @param contractsRegistry the registry to pull dependencies from
     *
     *  The Dependant must apply dependant() modifier to this function
     */
    function setDependencies(address contractsRegistry) external virtual;

    /**
     *  @notice The function is made external to allow for the factories to set the injector to the ContractsRegistry
     *  @param _injector the new injector
     */
    function setInjector(address _injector) external {
        _checkInjector();
        _setInjector(_injector);
    }

    /**
     *  @notice The function to get the current injector
     *  @return _injector the current injector
     */
    function getInjector() public view returns (address _injector) {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            _injector := sload(slot)
        }
    }

    /**
     *  @notice Internal function that checks the injector credentials
     */
    function _checkInjector() internal view {
        address _injector = getInjector();

        require(_injector == address(0) || _injector == msg.sender, "Dependant: Not an injector");
    }

    /**
     *  @notice Internal function that sets the injector
     */
    function _setInjector(address _injector) internal {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            sstore(slot, _injector)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 *  @notice This library is used to convert numbers that use token's N decimals to M decimals.
 *  Comes extremely handy with standardizing the business logic that is intended to work with many different ERC20 tokens
 *  that have different precision (decimals). One can perform calculations with 18 decimals only and resort to convertion
 *  only when the payouts (or interactions) with the actual tokes have to be made.
 *
 *  The best usage scenario involves accepting and calculating values with 18 decimals throughout the project, despite the tokens decimals.
 *
 *  Also it is recommended to call `round18()` function on the first execution line in order to get rid of the
 *  trailing numbers if the destination decimals are less than 18
 *
 *  Example:
 *
 *  contract Taker {
 *      ERC20 public USDC;
 *      uint256 public paid;
 *
 *      . . .
 *
 *      function pay(uint256 amount) external {
 *          uint256 decimals = USDC.decimals();
 *          amount = amount.round18(decimals);
 *
 *          paid += amount;
 *          USDC.transferFrom(msg.sender, address(this), amount.from18(decimals));
 *      }
 *  }
 */
library DecimalsConverter {
    function convert(
        uint256 amount,
        uint256 baseDecimals,
        uint256 destDecimals
    ) internal pure returns (uint256) {
        if (baseDecimals > destDecimals) {
            amount = amount / 10**(baseDecimals - destDecimals);
        } else if (baseDecimals < destDecimals) {
            amount = amount * 10**(destDecimals - baseDecimals);
        }

        return amount;
    }

    function to18(uint256 amount, uint256 baseDecimals) internal pure returns (uint256) {
        return convert(amount, baseDecimals, 18);
    }

    function from18(uint256 amount, uint256 destDecimals) internal pure returns (uint256) {
        return convert(amount, 18, destDecimals);
    }

    function round18(uint256 amount, uint256 decimals) internal pure returns (uint256) {
        return to18(from18(amount, decimals), decimals);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

/**
 * The central contract of the protocol, through which the main interaction goes.
 * Through this contract, liquidity is deposited, withdrawn, borrowed, repaid, claim distribution rewards, liquidated, and much more
 */
interface IDefiCore {
    /// @notice This event is emitted when a user update collateral value for specific pool
    /// @param _userAddr address of the user who updated the collateral value
    /// @param _assetKey key of the pool where the collateral value was updated
    /// @param _newValue a new collateral value
    event CollateralUpdated(address indexed _userAddr, bytes32 indexed _assetKey, bool _newValue);

    /// @notice This event is emitted when a user deposits liquidity into the pool
    /// @param _userAddr address of the user who deposited the liquidity
    /// @param _assetKey key of the pool where the liquidity was deposited
    /// @param _liquidityAmount number of tokens that were deposited
    event LiquidityAdded(
        address indexed _userAddr,
        bytes32 indexed _assetKey,
        uint256 _liquidityAmount
    );

    /// @notice This event is emitted when a user withdraws liquidity from the pool
    /// @param _userAddr address of the user who withdrawn the liquidity
    /// @param _assetKey key of the pool where the liquidity was withdrawn
    /// @param _liquidityAmount number of tokens that were withdrawn
    event LiquidityWithdrawn(
        address indexed _userAddr,
        bytes32 indexed _assetKey,
        uint256 _liquidityAmount
    );

    /// @notice This event is emitted when a user takes tokens on credit
    /// @param _borrower address of the user on whom the borrow is taken
    /// @param _recipient the address of the user to which the taken tokens will be sent
    /// @param _assetKey the key of the pool, the tokens of which will be taken on credit
    /// @param _borrowedAmount number of tokens to be taken on credit
    event Borrowed(
        address indexed _borrower,
        address _recipient,
        bytes32 indexed _assetKey,
        uint256 _borrowedAmount
    );

    /// @notice This event is emitted during the repayment of credit by the user
    /// @param _userAddr address of the user whose credit will be repaid
    /// @param _assetKey key of the pool in which the loan will be repaid
    /// @param _repaidAmount the amount of tokens for which the loan will be repaid
    event BorrowRepaid(
        address indexed _userAddr,
        bytes32 indexed _assetKey,
        uint256 _repaidAmount
    );

    /// @notice This event is emitted during the approve for delegated credit
    /// @param _userAddr address of the user who approved delegated borrow
    /// @param _assetKey the key of the pool in which the approve will be made
    /// @param _delegateeAddr address who is allowed to borrow the passed amount
    /// @param _newAmount the amount for which the approval is made
    event DelegateBorrowApproved(
        address indexed _userAddr,
        bytes32 indexed _assetKey,
        address _delegateeAddr,
        uint256 _newAmount
    );

    /// @notice This event is emitted after a successful donation
    /// @param _recipient an address of the donation recipient
    /// @param _amountInUSD a donation amount in USD
    event DonationCompleted(address _recipient, uint256 _amountInUSD);

    /// @notice This event is emitted when the user receives their distribution rewards
    /// @param _userAddr address of the user who receives distribution rewards
    /// @param _rewardAmount the amount of rewards the user will receive
    event DistributionRewardWithdrawn(address indexed _userAddr, uint256 _rewardAmount);

    /// @notice Function for pausing all user interactions with the system
    /// @dev Only contract owner can call this function
    function pause() external;

    /// @notice Function for unpausing all user interactions with the system
    /// @dev Only contract owner can call this function
    function unpause() external;

    /// @notice With this function you can change the value of the disabled of the asset as a collateral
    /// @param _assetKey pool key to update the value
    /// @param _isDisabled a flag that shows whether the asset will be disabled as a collateral
    function updateCollateral(bytes32 _assetKey, bool _isDisabled) external;

    /// @notice Function to update the compound rate with or without interval by pool key
    /// @param _assetKey key of the pool for which the compound rate will be updated
    /// @param _withInterval flag that shows whether to update the rate with or without interval
    /// @return new pool compound rate
    function updateCompoundRate(bytes32 _assetKey, bool _withInterval) external returns (uint256);

    /// @notice Function for adding liquidity by the user to a certain pool
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey key of the pool to which the liquidity will be added
    /// @param _liquidityAmount amount of tokens to add liquidity
    function addLiquidity(bytes32 _assetKey, uint256 _liquidityAmount) external payable;

    /// @notice Function for withdrawal of liquidity by the user from a certain pool
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey key of the pool from which the liquidity will be withdrawn
    /// @param _liquidityAmount the amount of tokens to withdraw liquidity
    /// @param _isMaxWithdraw the flag that shows whether to withdraw the maximum available amount or not
    function withdrawLiquidity(
        bytes32 _assetKey,
        uint256 _liquidityAmount,
        bool _isMaxWithdraw
    ) external;

    /// @notice The function is needed to allow addresses to borrow against your address for the desired amount
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey the key of the pool in which the approve will be made
    /// @param _approveAmount the amount for which the approval is made
    /// @param _delegateeAddr address who is allowed to borrow the passed amount
    /// @param _currentAllowance allowance before function execution
    function approveToDelegateBorrow(
        bytes32 _assetKey,
        uint256 _approveAmount,
        address _delegateeAddr,
        uint256 _currentAllowance
    ) external;

    /// @notice Function for taking credit tokens by the user in the desired pool
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey the key of the pool, the tokens of which will be taken on credit
    /// @param _borrowAmount the amount of tokens to be borrowed
    /// @param _recipientAddr token recipient address
    function borrowFor(
        bytes32 _assetKey,
        uint256 _borrowAmount,
        address _recipientAddr
    ) external;

    /// @notice Function for taking credit for the address that allowed you to do this
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey the key of the pool, the tokens of which will be taken on credit
    /// @param _borrowAmount the amount of tokens to be borrowed
    /// @param _borrowerAddr address to which the borrow will be taken
    function delegateBorrow(
        bytes32 _assetKey,
        uint256 _borrowAmount,
        address _borrowerAddr
    ) external;

    /// @notice Function for repayment of credit by the user in the desired pool
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey key of the pool in which the debt will be repaid
    /// @param _repayAmount the amount of tokens for which the borrow will be repaid
    /// @param _isMaxRepay a flag that shows whether or not to repay the debt by the maximum possible amount
    function repayBorrow(
        bytes32 _assetKey,
        uint256 _repayAmount,
        bool _isMaxRepay
    ) external payable;

    /// @notice Function for repayment of the desired user's credit
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey key of the pool in which the debt will be repaid
    /// @param _repayAmount the amount of tokens for which the borrow will be repaid
    /// @param _recipientAddr the address of the user whose credit will be repaid
    /// @param _isMaxRepay a flag that shows whether or not to repay the debt by the maximum possible amount
    function delegateRepayBorrow(
        bytes32 _assetKey,
        uint256 _repayAmount,
        address _recipientAddr,
        bool _isMaxRepay
    ) external payable;

    /// @notice Function for liquidation users who must protocols funds
    /// @dev The function takes the amount with 18 decimals
    /// @param _userAddr address of the user to be liquidated
    /// @param _supplyAssetKey the pool key, which is the user's collateral
    /// @param _borrowAssetKey key of the pool where the user took the credit
    /// @param _liquidationAmount the amount of tokens that will go to pay off the debt of the liquidated user
    function liquidation(
        address _userAddr,
        bytes32 _supplyAssetKey,
        bytes32 _borrowAssetKey,
        uint256 _liquidationAmount
    ) external payable;

    /// @notice Function for getting the distribution reward from a specific pools or from the all pools
    /// @param _assetKeys an array of the keys of the pools from which the reward will be received
    /// @param _isAllPools the flag that shows whether all pools should be claimed
    /// @return _totalReward the amount of the total reward received
    function claimDistributionRewards(bytes32[] memory _assetKeys, bool _isAllPools)
        external
        returns (uint256 _totalReward);

    /// @notice Donates a certain amount of reserve funds from a certain pool
    /// @param _assetKey key of the required pool
    /// @param _amountToWithdraw amount for donate of reserve funds
    /// @param _isAllFunds flag to donate all reserve funds
    function donateReservedFunds(
        bytes32 _assetKey,
        uint256 _amountToWithdraw,
        bool _isAllFunds
    ) external;

    /// @notice Donate from all reserved funds from pools with pagination
    /// @param _offset offset for pagination
    /// @param _limit maximum number of elements for pagination
    /// @param _isAllPools flag for donate from all pools or not
    function donateAllReservedFunds(
        uint256 _offset,
        uint256 _limit,
        bool _isAllPools
    ) external;

    /// @notice Function to get information about the total amount of donations in dollars
    /// @return a total amount of donations in dollars
    function totalDonationInUSD() external view returns (uint256);

    /// @notice Function for getting information about the user's assets that are disabled as collateral
    /// @param _userAddr the address of the user for whom the information will be obtained
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return true, if the asset disabled as collateral, false otherwise
    function disabledCollateralAssets(address _userAddr, bytes32 _assetKey)
        external
        view
        returns (bool);

    /// @notice Function to get the total amount of the user's deposit in dollars to all pools
    /// @param _userAddr address of the user for whom you want to get information
    /// @return _totalSupplyBalance total amount of the user's deposit in dollars
    function getTotalSupplyBalanceInUSD(address _userAddr)
        external
        view
        returns (uint256 _totalSupplyBalance);

    /// @notice Function for obtaining the amount that the user can maximally take on borrow
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return the amount of tokens that a user can maximal take on borrow
    function getMaxToBorrow(address _userAddr, bytes32 _assetKey) external view returns (uint256);

    /// @notice Function to get the amount by which the user can maximally repay the borrow
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return the amount of tokens by which the user can repay the debt at most
    function getMaxToRepay(address _userAddr, bytes32 _assetKey) external view returns (uint256);

    /// @notice Function for obtaining the amount that the user can maximally deposit
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return the number of tokens a user can deposit at most
    function getMaxToSupply(address _userAddr, bytes32 _assetKey) external view returns (uint256);

    /// @notice Function to get the maximum amount that the user can withdraw from the pool
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return the number of tokens that the user can withdraw from the pool at most
    function getMaxToWithdraw(address _userAddr, bytes32 _assetKey)
        external
        view
        returns (uint256);

    /// @notice Function to check if an asset is enabled as a collateral for a particular user
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return true, if passed asset enabled as collateral, false otherwise
    function isCollateralAssetEnabled(address _userAddr, bytes32 _assetKey)
        external
        view
        returns (bool);

    /// @notice Function to get the deposit amount with interest for the desired user in the passed pool
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return _userLiquidityAmount deposit amount with interest
    function getUserLiquidityAmount(address _userAddr, bytes32 _assetKey)
        external
        view
        returns (uint256 _userLiquidityAmount);

    /// @notice Function to get the borrow amount with interest for the desired user in the passed pool
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return _userBorrowedAmount borrow amount with interest
    function getUserBorrowedAmount(address _userAddr, bytes32 _assetKey)
        external
        view
        returns (uint256 _userBorrowedAmount);

    /// @notice Function to get the total amount of the user's borrows in dollars to all pools
    /// @param _userAddr address of the user for whom you want to get information
    /// @return _totalBorrowBalance total amount of the user's borrows in dollars
    function getTotalBorrowBalanceInUSD(address _userAddr)
        external
        view
        returns (uint256 _totalBorrowBalance);

    /// @notice Function for obtaining the current amount for which the user can take credit at most
    /// @param _userAddr address of the user for whom you want to get information
    /// @return _currentBorrowLimit a current user borrow limit in dollars
    function getCurrentBorrowLimitInUSD(address _userAddr)
        external
        view
        returns (uint256 _currentBorrowLimit);

    /// @notice Function for obtaining a new amount for which the user can take the maximum credit
    /// @dev The function takes the amount with 18 decimals
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey key of the pool for which the new deposit amount will be applied
    /// @param _tokensAmount the number of tokens by which the calculation will be changed borrow limit
    /// @param _isAdding true, if the amount of tokens will be added, false otherwise
    /// @return a new user borrow limit in dollars
    function getNewBorrowLimitInUSD(
        address _userAddr,
        bytes32 _assetKey,
        uint256 _tokensAmount,
        bool _isAdding
    ) external view returns (uint256);

    /// @notice Function for obtaining available liquidity of the user and his debt
    /// @param _userAddr address of the user for whom you want to get information
    /// @return first parameter is available user liquidity is dollarse, second is a user debt
    function getAvailableLiquidity(address _userAddr) external view returns (uint256, uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

/**
 * This is a contract for storage and convenient retrieval of asset parameters
 */
interface IAssetParameters {
    /// @notice This structure contains the main parameters of the pool
    /// @param collateralizationRatio percentage that shows how much collateral will be added from the deposit
    /// @param reserveFactor the percentage of the platform's earnings that will be deducted from the interest on the borrows
    /// @param liquidationDiscount percentage of the discount that the liquidator will receive on the collateral
    /// @param maxUtilizationRatio maximum possible utilization ratio
    struct MainPoolParams {
        uint256 collateralizationRatio;
        uint256 reserveFactor;
        uint256 liquidationDiscount;
        uint256 maxUtilizationRatio;
    }

    /// @notice This structure contains the pool parameters for the borrow percentage curve
    /// @param basePercentage annual rate on the borrow, if utilization ratio is equal to 0%
    /// @param firstSlope annual rate on the borrow, if utilization ratio is equal to utilizationBreakingPoint
    /// @param secondSlope annual rate on the borrow, if utilization ratio is equal to 100%
    /// @param utilizationBreakingPoint percentage at which the graph breaks
    struct InterestRateParams {
        uint256 basePercentage;
        uint256 firstSlope;
        uint256 secondSlope;
        uint256 utilizationBreakingPoint;
    }

    /// @notice This structure contains the pool parameters that are needed to calculate the distribution
    /// @param minSupplyDistrPart percentage, which indicates the minimum part of the reward distribution for users who deposited
    /// @param minBorrowDistrPart percentage, which indicates the minimum part of the reward distribution for users who borrowed
    struct DistributionMinimums {
        uint256 minSupplyDistrPart;
        uint256 minBorrowDistrPart;
    }

    /// @notice This structure contains all the parameters of the pool
    /// @param mainParams element type MainPoolParams structure
    /// @param interestRateParams element type InterestRateParams structure
    /// @param distrMinimums element type DistributionMinimums structure
    struct AllPoolParams {
        MainPoolParams mainParams;
        InterestRateParams interestRateParams;
        DistributionMinimums distrMinimums;
    }

    /// @notice This event is emitted when the pool's main parameters are set
    /// @param _assetKey the key of the pool for which the parameters are set
    /// @param _colRatio percentage that shows how much collateral will be added from the deposit
    /// @param _reserveFactor the percentage of the platform's earnings that will be deducted from the interest on the borrows
    /// @param _liquidationDiscount percentage of the discount that the liquidator will receive on the collateral
    /// @param _maxUR maximum possible utilization ratio
    event MainParamsUpdated(
        bytes32 _assetKey,
        uint256 _colRatio,
        uint256 _reserveFactor,
        uint256 _liquidationDiscount,
        uint256 _maxUR
    );

    /// @notice This event is emitted when the pool's interest rate parameters are set
    /// @param _assetKey the key of the pool for which the parameters are set
    /// @param _basePercentage annual rate on the borrow, if utilization ratio is equal to 0%
    /// @param _firstSlope annual rate on the borrow, if utilization ratio is equal to utilizationBreakingPoint
    /// @param _secondSlope annual rate on the borrow, if utilization ratio is equal to 100%
    /// @param _utilizationBreakingPoint percentage at which the graph breaks
    event InterestRateParamsUpdated(
        bytes32 _assetKey,
        uint256 _basePercentage,
        uint256 _firstSlope,
        uint256 _secondSlope,
        uint256 _utilizationBreakingPoint
    );

    /// @notice This event is emitted when the pool's distribution minimums are set
    /// @param _assetKey the key of the pool for which the parameters are set
    /// @param _supplyDistrPart percentage, which indicates the minimum part of the reward distribution for users who deposited
    /// @param _borrowDistrPart percentage, which indicates the minimum part of the reward distribution for users who borrowed
    event DistributionMinimumsUpdated(
        bytes32 _assetKey,
        uint256 _supplyDistrPart,
        uint256 _borrowDistrPart
    );

    event AnnualBorrowRateUpdated(bytes32 _assetKey, uint256 _newAnnualBorrowRate);

    /// @notice This event is emitted when the pool freeze parameter is set
    /// @param _assetKey the key of the pool for which the parameter is set
    /// @param _newValue new value of the pool freeze parameter
    event FreezeParamUpdated(bytes32 _assetKey, bool _newValue);

    /// @notice This event is emitted when the pool collateral parameter is set
    /// @param _assetKey the key of the pool for which the parameter is set
    /// @param _isCollateral new value of the pool collateral parameter
    event CollateralParamUpdated(bytes32 _assetKey, bool _isCollateral);

    /// @notice System function needed to set parameters during pool creation
    /// @dev Only SystemPoolsRegistry contract can call this function
    /// @param _assetKey the key of the pool for which the parameters are set
    /// @param _isCollateral a flag that indicates whether a pool can even be a collateral
    function setPoolInitParams(bytes32 _assetKey, bool _isCollateral) external;

    /// @notice Function for setting the annual borrow rate of the stable pool
    /// @dev Only contract owner can call this function. Only for stable pools
    /// @param _assetKey pool key for which parameters will be set
    /// @param _newAnnualBorrowRate new annual borrow rate parameter
    function setupAnnualBorrowRate(bytes32 _assetKey, uint256 _newAnnualBorrowRate) external;

    /// @notice Function for setting the main parameters of the pool
    /// @dev Only contract owner can call this function
    /// @param _assetKey pool key for which parameters will be set
    /// @param _mainParams structure with the main parameters of the pool
    function setupMainParameters(bytes32 _assetKey, MainPoolParams calldata _mainParams) external;

    /// @notice Function for setting the interest rate parameters of the pool
    /// @dev Only contract owner can call this function
    /// @param _assetKey pool key for which parameters will be set
    /// @param _interestParams structure with the interest rate parameters of the pool
    function setupInterestRateModel(bytes32 _assetKey, InterestRateParams calldata _interestParams)
        external;

    /// @notice Function for setting the distribution minimums of the pool
    /// @dev Only contract owner can call this function
    /// @param _assetKey pool key for which parameters will be set
    /// @param _distrMinimums structure with the distribution minimums of the pool
    function setupDistributionsMinimums(
        bytes32 _assetKey,
        DistributionMinimums calldata _distrMinimums
    ) external;

    /// @notice Function for setting all pool parameters
    /// @dev Only contract owner can call this function
    /// @param _assetKey pool key for which parameters will be set
    /// @param _poolParams structure with all pool parameters
    function setupAllParameters(bytes32 _assetKey, AllPoolParams calldata _poolParams) external;

    /// @notice Function for freezing the pool
    /// @dev Only contract owner can call this function
    /// @param _assetKey pool key to be frozen
    function freeze(bytes32 _assetKey) external;

    /// @notice Function to enable the pool as a collateral
    /// @dev Only contract owner can call this function
    /// @param _assetKey the pool key to be enabled as a collateral
    function enableCollateral(bytes32 _assetKey) external;

    /// @notice Function for getting information about whether the pool is frozen
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return true if the liquidity pool is frozen, false otherwise
    function isPoolFrozen(bytes32 _assetKey) external view returns (bool);

    /// @notice Function for getting information about whether a pool can be a collateral
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return true, if the pool is available as a collateral, false otherwise
    function isAvailableAsCollateral(bytes32 _assetKey) external view returns (bool);

    /// @notice Function for getting annual borrow rate
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return an annual borrow rate
    function getAnnualBorrowRate(bytes32 _assetKey) external view returns (uint256);

    /// @notice Function for getting the main parameters of the pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return a structure with the main parameters of the pool
    function getMainPoolParams(bytes32 _assetKey) external view returns (MainPoolParams memory);

    /// @notice Function for getting the interest rate parameters of the pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return a structure with the interest rate parameters of the pool
    function getInterestRateParams(bytes32 _assetKey)
        external
        view
        returns (InterestRateParams memory);

    /// @notice Function for getting the distribution minimums of the pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return a structure with the distribution minimums of the pool
    function getDistributionMinimums(bytes32 _assetKey)
        external
        view
        returns (DistributionMinimums memory);

    /// @notice Function to get the collateralization ratio for the desired pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return current collateralization ratio value
    function getColRatio(bytes32 _assetKey) external view returns (uint256);

    /// @notice Function to get the reserve factor for the desired pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return current reserve factor value
    function getReserveFactor(bytes32 _assetKey) external view returns (uint256);

    /// @notice Function to get the liquidation discount for the desired pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return current liquidation discount value
    function getLiquidationDiscount(bytes32 _assetKey) external view returns (uint256);

    /// @notice Function to get the max utilization ratio for the desired pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return maximum possible utilization ratio value
    function getMaxUtilizationRatio(bytes32 _assetKey) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

/**
 * This is a contract for storage and convenient retrieval of system parameters
 */
interface ISystemParameters {
    /// @notice The event that is emmited after updating of the rewards token address parameter
    /// @param _rewardsToken a new rewards token address value
    event RewardsTokenUpdated(address _rewardsToken);

    /// @notice The event that is emmited after updating of the donation address parameter
    /// @param _newDonationAddress a new donation address value
    event DonationAddressUpdated(address _newDonationAddress);

    /// @notice The event that is emmited after updating the parameter with the same name
    /// @param _newValue new liquidation boundary parameter value
    event LiquidationBoundaryUpdated(uint256 _newValue);

    /// @notice The event that is emmited after updating the parameter with the same name
    /// @param _newValue new stable pools availability parameter value
    event StablePoolsAvailabilityUpdated(bool _newValue);

    /// @notice The event that is emmited after updating the parameter with the same name
    /// @param _newValue new min currency amount parameter value
    event MinCurrencyAmountUpdated(uint256 _newValue);

    /// @notice The function that updates the rewards token address. Can update only if current rewards token address is zero address
    /// @dev Only owner of this contract can call this function
    /// @param _rewardsToken new value of the rewards token parameter
    function setRewardsTokenAddress(address _rewardsToken) external;

    /// @notice The function that updates the donation address
    /// @dev Only owner of this contract can call this function
    /// @param _newDonationAddress new value of the donation address parameter
    function setDonationAddress(address _newDonationAddress) external;

    /// @notice The function that updates the parameter of the same name to a new value
    /// @dev Only owner of this contract can call this function
    /// @param _newValue new value of the liquidation boundary parameter
    function setupLiquidationBoundary(uint256 _newValue) external;

    /// @notice The function that updates the parameter of the same name to a new value
    /// @dev Only owner of this contract can call this function
    /// @param _newValue new value of the stable pools availability parameter
    function setupStablePoolsAvailability(bool _newValue) external;

    /// @notice The function that updates the parameter of the same name
    /// @dev Only owner of this contract can call this function
    /// @param _newMinCurrencyAmount new value of the min currency amount parameter
    function setupMinCurrencyAmount(uint256 _newMinCurrencyAmount) external;

    ///@notice The function that returns the values of rewards token parameter
    ///@return current rewards token address
    function getRewardsTokenAddress() external view returns (address);

    ///@notice The function that returns the values of donation address parameter
    ///@return current donation address
    function getDonationAddress() external view returns (address);

    ///@notice The function that returns the values of liquidation boundary parameter
    ///@return current liquidation boundary parameter value
    function getLiquidationBoundary() external view returns (uint256);

    ///@notice The function that returns the values of stable pools availability parameter
    ///@return current stable pools availability parameter value
    function getStablePoolsAvailability() external view returns (bool);

    ///@notice The function that returns the value of the min currency amount parameter
    ///@return current min currency amount parameter value
    function getMinCurrencyAmount() external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./IAssetParameters.sol";

/**
 * This contract is needed to add new pools, store and retrieve information about already created pools
 */
interface ISystemPoolsRegistry {
    /// @notice Enumeration with the types of pools that are available in the system
    /// @param LIQUIDITY_POOL a liquidity pool type
    /// @param STABLE_POOL a stable pool type
    enum PoolType {
        LIQUIDITY_POOL,
        STABLE_POOL
    }

    /// @notice This structure contains system information about the pool
    /// @param poolAddr an address of the pool
    /// @param poolType stored pool type
    struct PoolInfo {
        address poolAddr;
        PoolType poolType;
    }

    /// @notice This structure contains system information a certain type of pool
    /// @param poolBeaconAddr beacon contract address for a certain type of pools
    /// @param supportedAssetKeys storage of keys, which are supported by a certain type of pools
    struct PoolTypeInfo {
        address poolBeaconAddr;
        EnumerableSet.Bytes32Set supportedAssetKeys;
    }

    /// @notice This structure contains basic information about the pool
    /// @param assetKey key of the pool for which the information was obtained
    /// @param assetAddr address of the pool underlying asset
    /// @param borrowAPY annual borrow rate in the current
    /// @param distrBorrowAPY annual distribution rate for users who took credit in the current pool
    /// @param totalBorrowBalance the total number of tokens that have been borrowed in the current pool
    /// @param totalBorrowBalanceInUSD the equivalent of totalBorrowBalance param in dollars
    struct BasePoolInfo {
        bytes32 assetKey;
        address assetAddr;
        uint256 borrowAPY;
        uint256 distrBorrowAPY;
        uint256 totalBorrowBalance;
        uint256 totalBorrowBalanceInUSD;
    }

    /// @notice This structure contains main information about the liquidity pool
    /// @param baseInfo element type BasePoolInfo structure
    /// @param supplyAPY annual supply rate in the current pool
    /// @param distrSupplyAPY annual distribution rate for users who deposited in the current pool
    /// @param marketSize the total number of pool tokens that all users have deposited
    /// @param marketSizeInUSD the equivalent of marketSize param in dollars
    /// @param utilizationRatio the current percentage of how much of the pool was borrowed for liquidity
    /// @param isAvailableAsCollateral can an asset even be a collateral
    struct LiquidityPoolInfo {
        BasePoolInfo baseInfo;
        uint256 supplyAPY;
        uint256 distrSupplyAPY;
        uint256 marketSize;
        uint256 marketSizeInUSD;
        uint256 utilizationRatio;
        bool isAvailableAsCollateral;
    }

    /// @notice This structure contains main information about the liquidity pool
    /// @param baseInfo element type BasePoolInfo structure
    struct StablePoolInfo {
        BasePoolInfo baseInfo;
    }

    /// @notice This structure contains detailed information about the pool
    /// @param poolInfo element type LiquidityPoolInfo structure
    /// @param mainPoolParams element type IAssetParameters.MainPoolParams structure
    /// @param availableLiquidity available liquidity for borrowing
    /// @param availableLiquidityInUSD the equivalent of availableLiquidity param in dollars
    /// @param totalReserve total amount of reserves in the current pool
    /// @param totalReserveInUSD the equivalent of totalReserve param in dollars
    /// @param distrSupplyAPY annual distribution rate for users who deposited in the current pool
    /// @param distrBorrowAPY annual distribution rate for users who took credit in the current pool
    struct DetailedLiquidityPoolInfo {
        LiquidityPoolInfo poolInfo;
        IAssetParameters.MainPoolParams mainPoolParams;
        uint256 availableLiquidity;
        uint256 availableLiquidityInUSD;
        uint256 totalReserve;
        uint256 totalReserveInUSD;
        uint256 distrSupplyAPY;
        uint256 distrBorrowAPY;
    }

    struct DonationInfo {
        uint256 totalDonationInUSD;
        uint256 availableToDonateInUSD;
        address donationAddress;
    }

    /// @notice This event is emitted when a new pool is added
    /// @param _assetKey new pool identification key
    /// @param _assetAddr the pool underlying asset address
    /// @param _poolAddr the added pool address
    /// @param _poolType the type of the added pool
    event PoolAdded(bytes32 _assetKey, address _assetAddr, address _poolAddr, PoolType _poolType);

    /// @notice Function to add a beacon contract for the desired type of pools
    /// @dev Only contract owner can call this function
    /// @param _poolType the type of pool for which the beacon contract will be added
    /// @param _poolImpl the implementation address for the desired pool type
    function addPoolsBeacon(PoolType _poolType, address _poolImpl) external;

    /// @notice The function is needed to add new liquidity pools
    /// @dev Only contract owner can call this function
    /// @param _assetAddr address of the underlying liquidity pool asset
    /// @param _assetKey pool key of the added liquidity pool
    /// @param _chainlinkOracle the address of the chainlink oracle for the passed asset
    /// @param _tokenSymbol symbol of the underlying liquidity pool asset
    /// @param _isCollateral is it possible for the new liquidity pool to be a collateral
    function addLiquidityPool(
        address _assetAddr,
        bytes32 _assetKey,
        address _chainlinkOracle,
        string calldata _tokenSymbol,
        bool _isCollateral
    ) external;

    /// @notice The function is needed to add new stable pools
    /// @dev Only contract owner can call this function
    /// @param _assetAddr address of the underlying stable pool asset
    /// @param _assetKey pool key of the added stable pool
    /// @param _chainlinkOracle the address of the chainlink oracle for the passed asset
    function addStablePool(
        address _assetAddr,
        bytes32 _assetKey,
        address _chainlinkOracle
    ) external;

    /// @notice The function is needed to update the implementation of the pools
    /// @dev Only contract owner can call this function
    /// @param _poolType needed pool type from PoolType enum
    /// @param _newPoolsImpl address of the new pools implementation
    function upgradePoolsImpl(PoolType _poolType, address _newPoolsImpl) external;

    /// @notice The function inject dependencies to existing liquidity pools
    /// @dev Only contract owner can call this function
    function injectDependenciesToExistingPools() external;

    /// @notice The function inject dependencies with pagination
    /// @dev Only contract owner can call this function
    function injectDependencies(uint256 _offset, uint256 _limit) external;

    /// @notice The function returns the native asset key
    /// @return a native asset key
    function nativeAssetKey() external view returns (bytes32);

    /// @notice The function returns the asset key, which will be credited as a reward for distribution
    /// @return a rewards asset key
    function rewardsAssetKey() external view returns (bytes32);

    /// @notice The function returns system information for the desired pool
    /// @param _assetKey pool key for which you want to get information
    /// @return poolAddr an address of the pool
    /// @return poolType a pool type
    function poolsInfo(bytes32 _assetKey)
        external
        view
        returns (address poolAddr, PoolType poolType);

    /// @notice Indicates whether the address is a liquidity pool
    /// @param _poolAddr address of the liquidity pool to check
    /// @return true if the passed address is a liquidity pool, false otherwise
    function existingLiquidityPools(address _poolAddr) external view returns (bool);

    /// @notice A function that returns an array of structures with liquidity pool information
    /// @param _assetKeys an array of pool keys for which you want to get information
    /// @return _poolsInfo an array of LiquidityPoolInfo structures
    function getLiquidityPoolsInfo(bytes32[] calldata _assetKeys)
        external
        view
        returns (LiquidityPoolInfo[] memory _poolsInfo);

    /// @notice A function that returns an array of structures with stable pool information
    /// @param _assetKeys an array of pool keys for which you want to get information
    /// @return _poolsInfo an array of StablePoolInfo structures
    function getStablePoolsInfo(bytes32[] calldata _assetKeys)
        external
        view
        returns (StablePoolInfo[] memory _poolsInfo);

    /// @notice A function that returns a structure with detailed pool information
    /// @param _assetKey pool key for which you want to get information
    /// @return a DetailedLiquidityPoolInfo structure
    function getDetailedLiquidityPoolInfo(bytes32 _assetKey)
        external
        view
        returns (DetailedLiquidityPoolInfo memory);

    function getDonationInfo() external view returns (DonationInfo memory);

    /// @notice Returns the address of the liquidity pool for the rewards token
    /// @return liquidity pool address for the rewards token
    function getRewardsLiquidityPool() external view returns (address);

    /// @notice A system function that returns the address of liquidity pool beacon
    /// @param _poolType needed pool type from PoolType enum
    /// @return a required pool beacon address
    function getPoolsBeacon(PoolType _poolType) external view returns (address);

    /// @notice A function that returns the address of liquidity pools implementation
    /// @param _poolType needed pool type from PoolType enum
    /// @return a required pools implementation address
    function getPoolsImpl(PoolType _poolType) external view returns (address);

    /// @notice Function to check if the pool exists by the passed pool key
    /// @param _assetKey pool identification key
    /// @return true if the liquidity pool for the passed key exists, false otherwise
    function onlyExistingPool(bytes32 _assetKey) external view returns (bool);

    /// @notice The function returns the number of all supported assets in the system
    /// @return an all supported assets count
    function getAllSupportedAssetKeysCount() external view returns (uint256);

    /// @notice The function returns the number of all supported assets in the system by types
    /// @param _poolType type of pools, the number of which you want to get
    /// @return an all supported assets count for passed pool type
    function getSupportedAssetKeysCountByType(PoolType _poolType) external view returns (uint256);

    /// @notice The function returns the keys of all the system pools
    /// @return an array of all system pool keys
    function getAllSupportedAssetKeys() external view returns (bytes32[] memory);

    /// @notice The function returns the keys of all pools by type
    /// @param _poolType the type of pool, the keys for which you want to get
    /// @return an array of all pool keys by passed type
    function getAllSupportedAssetKeysByType(PoolType _poolType)
        external
        view
        returns (bytes32[] memory);

    /// @notice The function returns keys of created pools with pagination
    /// @param _offset offset for pagination
    /// @param _limit maximum number of elements for pagination
    /// @return an array of pool keys
    function getSupportedAssetKeys(uint256 _offset, uint256 _limit)
        external
        view
        returns (bytes32[] memory);

    /// @notice The function returns keys of created pools with pagination by pool type
    /// @param _poolType the type of pool, the keys for which you want to get
    /// @param _offset offset for pagination
    /// @param _limit maximum number of elements for pagination
    /// @return an array of pool keys by passed type
    function getSupportedAssetKeysByType(
        PoolType _poolType,
        uint256 _offset,
        uint256 _limit
    ) external view returns (bytes32[] memory);

    /// @notice Returns an array of addresses of all created pools
    /// @return an array of all pool addresses
    function getAllPools() external view returns (address[] memory);

    /// @notice The function returns an array of all pools of the desired type
    /// @param _poolType the pool type for which you want to get an array of all pool addresses
    /// @return an array of all pool addresses by passed type
    function getAllPoolsByType(PoolType _poolType) external view returns (address[] memory);

    /// @notice Returns addresses of created pools with pagination
    /// @param _offset offset for pagination
    /// @param _limit maximum number of elements for pagination
    /// @return an array of pool addresses
    function getPools(uint256 _offset, uint256 _limit) external view returns (address[] memory);

    /// @notice Returns addresses of created pools with pagination by type
    /// @param _poolType the pool type for which you want to get an array of pool addresses
    /// @param _offset offset for pagination
    /// @param _limit maximum number of elements for pagination
    /// @return an array of pool addresses by passed type
    function getPoolsByType(
        PoolType _poolType,
        uint256 _offset,
        uint256 _limit
    ) external view returns (address[] memory);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV2V3Interface.sol";

/**
 * This contract is responsible for obtaining asset prices from trusted oracles.
 * The contract code provides for a main oracle and a backup oracle, as well as the ability to switch all price fetches to a backup oracle
 */
interface IPriceManager {
    /// @notice The structure that contains the oracle address token for this token
    /// @param assetAddr address of the asset for which the oracles will be saved
    /// @param chainlinkOracle Chainlink oracle address for the desired asset
    struct PriceFeed {
        address assetAddr;
        AggregatorV2V3Interface chainlinkOracle;
    }

    /// @notice This event is emitted when a new oracle is added
    /// @param _assetKey the pool key for which oracles are added
    /// @param _chainlinkOracle Chainlink oracle address for the pool underlying asset
    event OracleAdded(bytes32 _assetKey, address _chainlinkOracle);

    /// @notice The function you need to add oracles for assets
    /// @dev Only SystemPoolsRegistry contract can call this function
    /// @param _assetKey the pool key for which oracles are added
    /// @param _assetAddr address of the asset for which the oracles will be added
    /// @param _chainlinkOracle the address of the chainlink oracle for the passed asset
    function addOracle(
        bytes32 _assetKey,
        address _assetAddr,
        address _chainlinkOracle
    ) external;

    /// @notice The function that returns the price for the asset for which oracles are saved
    /// @param _assetKey the key of the pool, for the asset for which the price will be obtained
    /// @return answer - the resulting token price, decimals - resulting token price decimals
    function getPrice(bytes32 _assetKey) external view returns (uint256, uint8);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

/**
 * This contract is needed to store and obtain the second rates of their annual rates
 */
interface IInterestRateLibrary {
    /// @notice The function returns the library precision
    /// @dev For default library precision equals to 10^1
    /// @return a current library precision
    function LIBRARY_PRECISION() external view returns (uint256);

    /// @notice The function returns the current max supported percentage
    /// @return a max supported percentage with library precision
    function MAX_SUPPORTED_PERCENTAGE() external view returns (uint256);

    /// @notice The function returns the second rate for the passed annual rate
    /// @dev The passed annual rate must be with the precision of the library
    /// @param _annualRate annual rate to be converted
    /// @return a converted second rate
    function getRatePerSecond(uint256 _annualRate) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/IInterestRateLibrary.sol";

/**
 * This library is needed to convert annual rates and work with them
 */
library AnnualRatesConverter {
    /// @notice Function to get the annual percentage
    /// @param _lowInterestPercentage lower boundary of annual interest
    /// @param _highInterestPercentage upper boundary of annual interest
    /// @param _currentUR current utilization ratio
    /// @param _lowURPercentage lower boundary of utilization ratio
    /// @param _highURPercentage upper boundary of utilization ratio
    /// @param _decimal current decimal
    /// @return a calculated annual percentage
    function getAnnualRate(
        uint256 _lowInterestPercentage,
        uint256 _highInterestPercentage,
        uint256 _currentUR,
        uint256 _lowURPercentage,
        uint256 _highURPercentage,
        uint256 _decimal
    ) internal pure returns (uint256) {
        uint256 _interestPerPercent = ((_highInterestPercentage - _lowInterestPercentage) *
            _decimal) / (_highURPercentage - _lowURPercentage);

        return
            (_interestPerPercent * (_currentUR - _lowURPercentage)) /
            _decimal +
            _lowInterestPercentage;
    }

    /// @notice Function to convert annual rate to second rate
    /// @param _library address of the InterestRateLibrary
    /// @param _interestRatePerYear annual rate to be converted to a second rate
    /// @param _onePercent current one percentage value
    /// @return a calculated second rate
    function convertToRatePerSecond(
        IInterestRateLibrary _library,
        uint256 _interestRatePerYear,
        uint256 _onePercent
    ) internal view returns (uint256) {
        uint256 _libraryPrecision = _library.LIBRARY_PRECISION();

        _interestRatePerYear *= _libraryPrecision;

        require(
            _interestRatePerYear <= _library.MAX_SUPPORTED_PERCENTAGE() * _onePercent,
            "AnnualRatesConverter: Interest rate is not supported."
        );

        uint256 _leftBorder = _interestRatePerYear / _onePercent;
        uint256 _rightBorder = _leftBorder + 1;

        if (_interestRatePerYear % _onePercent == 0) {
            return _library.getRatePerSecond(_leftBorder);
        }

        uint256 _firstRatePerSecond = _library.getRatePerSecond(_leftBorder);
        uint256 _secondRatePerSecond = _library.getRatePerSecond(_rightBorder);

        return
            ((_secondRatePerSecond - _firstRatePerSecond) *
                (_interestRatePerYear - (_leftBorder * _onePercent))) /
            _onePercent +
            _firstRatePerSecond;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../common/Globals.sol";

/**
 * It is a library with handy math functions that simplifies calculations
 */
library MathHelper {
    /// @notice Function for calculating a new normalized value from the passed data
    /// @param _amountWithoutInterest the amount without interest. Needed to correctly calculate the normalized value at 0
    /// @param _normalizedAmount current normalized amount
    /// @param _additionalAmount the amount by which the normalized value will change
    /// @param _currentRate current compound rate
    /// @param _isAdding true if the amount will be added, false otherwise
    /// @return _newNormalizedAmount new calculated normalized value
    function getNormalizedAmount(
        uint256 _amountWithoutInterest,
        uint256 _normalizedAmount,
        uint256 _additionalAmount,
        uint256 _currentRate,
        bool _isAdding
    ) internal pure returns (uint256 _newNormalizedAmount) {
        if (_isAdding || _amountWithoutInterest != 0) {
            uint256 _normalizedAdditionalAmount = divWithPrecision(
                _additionalAmount,
                _currentRate
            );

            _newNormalizedAmount = _isAdding
                ? _normalizedAmount + _normalizedAdditionalAmount
                : _normalizedAmount - _normalizedAdditionalAmount;
        }
    }

    /// @notice Function for division with precision
    /// @param _number the multiplicand
    /// @param _denominator the divisor
    /// @return a type uint256 calculation result
    function divWithPrecision(uint256 _number, uint256 _denominator)
        internal
        pure
        returns (uint256)
    {
        return mulDiv(_number, DECIMAL, _denominator);
    }

    /// @notice Function for multiplication with precision
    /// @param _number the multiplicand
    /// @param _numerator the multiplier
    /// @return a type uint256 calculation result
    function mulWithPrecision(uint256 _number, uint256 _numerator)
        internal
        pure
        returns (uint256)
    {
        return mulDiv(_number, _numerator, DECIMAL);
    }

    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        // Make sure the result is less than 2**256.
        // Also prevents denominator == 0
        require(denominator > prod1);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1.
        uint256 twos = (~denominator + 1) & denominator;
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson iteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@dlsl/dev-modules/contracts-registry/AbstractContractsRegistry.sol";

import "./interfaces/IRegistry.sol";

contract Registry is IRegistry, AbstractContractsRegistry {
    string public constant DEFI_CORE_NAME = "DEFI_CORE";

    string public constant SYSTEM_PARAMETERS_NAME = "SYSTEM_PARAMETERS";
    string public constant ASSET_PARAMETERS_NAME = "ASSET_PARAMETERS";

    string public constant REWARDS_DISTRIBUTION_NAME = "REWARDS_DISTRIBUTION";

    string public constant USER_INFO_REGISTRY_NAME = "USER_INFO_REGISTRY";
    string public constant SYSTEM_POOLS_REGISTRY_NAME = "LIQUIDITY_POOL_REGISTRY";

    string public constant LIQUIDITY_POOL_FACTORY_NAME = "LIQUIDITY_POOL_FACTORY";
    string public constant PRICE_MANAGER_NAME = "PRICE_MANAGER";

    string public constant INTEREST_RATE_LIBRARY_NAME = "INTEREST_RATE_LIBRARY";

    function getSystemOwner() external view override returns (address) {
        return owner();
    }

    function getDefiCoreContract() external view override returns (address) {
        return getContract(DEFI_CORE_NAME);
    }

    function getSystemParametersContract() external view override returns (address) {
        return getContract(SYSTEM_PARAMETERS_NAME);
    }

    function getAssetParametersContract() external view override returns (address) {
        return getContract(ASSET_PARAMETERS_NAME);
    }

    function getRewardsDistributionContract() external view override returns (address) {
        return getContract(REWARDS_DISTRIBUTION_NAME);
    }

    function getUserInfoRegistryContract() external view override returns (address) {
        return getContract(USER_INFO_REGISTRY_NAME);
    }

    function getSystemPoolsRegistryContract() external view override returns (address) {
        return getContract(SYSTEM_POOLS_REGISTRY_NAME);
    }

    function getSystemPoolsFactoryContract() external view override returns (address) {
        return getContract(LIQUIDITY_POOL_FACTORY_NAME);
    }

    function getPriceManagerContract() external view override returns (address) {
        return getContract(PRICE_MANAGER_NAME);
    }

    function getInterestRateLibraryContract() external view override returns (address) {
        return getContract(INTEREST_RATE_LIBRARY_NAME);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@dlsl/dev-modules/libs/math/DSMath.sol";

import "./common/Globals.sol";

contract CompoundRateKeeper is Ownable {
    struct CompoundRate {
        uint256 rate;
        uint256 lastUpdate;
    }

    CompoundRate public compoundRate;

    constructor() {
        compoundRate = CompoundRate(DECIMAL, block.timestamp);
    }

    function getCurrentRate() external view returns (uint256) {
        return compoundRate.rate;
    }

    function getLastUpdate() external view returns (uint256) {
        return compoundRate.lastUpdate;
    }

    function update(uint256 _interestRate) external onlyOwner returns (uint256 _newRate) {
        _newRate = getNewCompoundRate(_interestRate);

        compoundRate.rate = _newRate;
        compoundRate.lastUpdate = block.timestamp;
    }

    function getNewCompoundRate(uint256 _interestRate) public view returns (uint256 _newRate) {
        uint256 _period = block.timestamp - compoundRate.lastUpdate;
        _newRate =
            (compoundRate.rate * (DSMath.rpow(_interestRate + DECIMAL, _period, DECIMAL))) /
            DECIMAL;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AggregatorInterface.sol";
import "./AggregatorV3Interface.sol";

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface {}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

uint256 constant ONE_PERCENT = 10**25;
uint256 constant DECIMAL = ONE_PERCENT * 100;

uint8 constant STANDARD_DECIMALS = 18;
uint256 constant ONE_TOKEN = 10**STANDARD_DECIMALS;

uint256 constant BLOCKS_PER_DAY = 4900;
uint256 constant BLOCKS_PER_YEAR = BLOCKS_PER_DAY * 365;

uint8 constant PRICE_DECIMALS = 8;

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/transparent/TransparentUpgradeableProxy.sol)

pragma solidity ^0.8.0;

import "../ERC1967/ERC1967Proxy.sol";

/**
 * @dev This contract implements a proxy that is upgradeable by an admin.
 *
 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
 * clashing], which can potentially be used in an attack, this contract uses the
 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
 * things that go hand in hand:
 *
 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
 * that call matches one of the admin functions exposed by the proxy itself.
 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says
 * "admin cannot fallback to proxy target".
 *
 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
 * to sudden errors when trying to call a function from the proxy implementation.
 *
 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
 * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.
 */
contract TransparentUpgradeableProxy is ERC1967Proxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {ERC1967Proxy-constructor}.
     */
    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        _changeAdmin(admin_);
    }

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyAdmin}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _getAdmin();
    }

    /**
     * @dev Returns the current implementation.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyImplementation}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function implementation() external ifAdmin returns (address implementation_) {
        implementation_ = _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external virtual ifAdmin {
        _changeAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {
        _upgradeToAndCall(newImplementation, data, true);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view virtual returns (address) {
        return _getAdmin();
    }

    /**
     * @dev Makes sure the admin cannot access the fallback function. See {Proxy-_beforeFallback}.
     */
    function _beforeFallback() internal virtual override {
        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import "./AbstractDependant.sol";
import "./ProxyUpgrader.sol";

/**
 *  @notice The ContractsRegistry module
 *
 *  The purpose of this module is to provide an organized registry of the project's smartcontracts
 *  together with the upgradeability and dependency injection mechanisms.
 *
 *  The ContractsRegistry should be used as the highest level smartcontract that is aware of any other
 *  contract present in the system. The contracts that demand other system's contracts would then inherit
 *  special `AbstractDependant` contract and override `setDependencies()` function to enable ContractsRegistry
 *  to inject dependencies into them.
 *
 *  The ContractsRegistry will help with the following usecases:
 *
 *  1) Making the system upgradeable
 *  2) Making the system contracts-interchangeable
 *  3) Simplifying the contracts management and deployment
 *
 *  The ContractsRegistry acts as a Transparent proxy deployer. One can add proxy-compatible implementations to the registry
 *  and deploy proxies to them. Then these proxies can be upgraded easily using the ContractsRegistry.
 *  The ContractsRegistry itself can be deployed behind a proxy as well.
 *
 *  The dependency injection system may come in handy when one wants to substitute a contract `A` with a contract `B`
 *  (for example contract `A` got exploited) without a necessity of redeploying the whole system. One would just add
 *  a new `B` contract to a ContractsRegistry and re-inject all the required dependencies. Dependency injection mechanism
 *  also works with factories.
 *
 *  The management is simplified because all of the contracts are now located in a single place.
 */
abstract contract AbstractContractsRegistry is OwnableUpgradeable {
    ProxyUpgrader internal _proxyUpgrader;

    mapping(string => address) private _contracts;
    mapping(address => bool) private _isProxy;

    /**
     *  @notice The proxy initializer function
     */
    function __ContractsRegistry_init() external initializer {
        __Ownable_init();

        _proxyUpgrader = new ProxyUpgrader();
    }

    /**
     *  @notice The function that returns an associated contract with the name
     *  @param name the name of the contract
     *  @return the address of the contract
     */
    function getContract(string memory name) public view returns (address) {
        address contractAddress = _contracts[name];

        require(contractAddress != address(0), "ContractsRegistry: This mapping doesn't exist");

        return contractAddress;
    }

    /**
     *  @notice The function that check if a contract with a given name has been added
     *  @param name the name of the contract
     *  @return true if the contract is present in the registry
     */
    function hasContract(string calldata name) external view returns (bool) {
        return _contracts[name] != address(0);
    }

    /**
     *  @notice The function that injects the dependencies into the given contract
     *  @param name the name of the contract
     */
    function injectDependencies(string calldata name) external onlyOwner {
        address contractAddress = _contracts[name];

        require(contractAddress != address(0), "ContractsRegistry: This mapping doesn't exist");

        AbstractDependant dependant = AbstractDependant(contractAddress);
        dependant.setDependencies(address(this));
    }

    /**
     *  @notice The function that returns the admin of the added proxy contracts
     *  @return the proxy admin address
     */
    function getProxyUpgrader() external view returns (address) {
        require(address(_proxyUpgrader) != address(0), "ContractsRegistry: Bad ProxyUpgrader");

        return address(_proxyUpgrader);
    }

    /**
     *  @notice The function that returns an implementation of the given proxy contract
     *  @param name the name of the contract
     *  @return the implementation address
     */
    function getImplementation(string calldata name) external view returns (address) {
        address contractProxy = _contracts[name];

        require(contractProxy != address(0), "ContractsRegistry: This mapping doesn't exist");
        require(_isProxy[contractProxy], "ContractsRegistry: Not a proxy contract");

        return _proxyUpgrader.getImplementation(contractProxy);
    }

    /**
     *  @notice The function to upgrade added proxy contract with a new implementation
     *  @param name the name of the proxy contract
     *  @param newImplementation the new implementation the proxy should be upgraded to
     *
     *  It is the Owner's responsibility to ensure the compatibility between implementations
     */
    function upgradeContract(string calldata name, address newImplementation) external onlyOwner {
        _upgradeContract(name, newImplementation, bytes(""));
    }

    /**
     *  @notice The function to upgrade added proxy contract with a new implementation, providing data
     *  @param name the name of the proxy contract
     *  @param newImplementation the new implementation the proxy should be upgraded to
     *  @param data the data that the new implementation will be called with. This can be an ABI encoded function call
     *
     *  It is the Owner's responsibility to ensure the compatibility between implementations
     */
    function upgradeContractAndCall(
        string calldata name,
        address newImplementation,
        bytes memory data
    ) external onlyOwner {
        _upgradeContract(name, newImplementation, data);
    }

    /**
     *  @notice Internal upgrade function
     */
    function _upgradeContract(
        string calldata name,
        address newImplementation,
        bytes memory data
    ) internal {
        address contractToUpgrade = _contracts[name];

        require(contractToUpgrade != address(0), "ContractsRegistry: This mapping doesn't exist");
        require(_isProxy[contractToUpgrade], "ContractsRegistry: Not a proxy contract");

        _proxyUpgrader.upgrade(contractToUpgrade, newImplementation, data);
    }

    /**
     *  @notice The function to add pure contracts to the ContractsRegistry. These should either be
     *  the contracts the system does not have direct upgradeability control over, or the contracts that are not upgradeable
     *  @param name the name to associate the contract with
     *  @param contractAddress the address of the contract
     */
    function addContract(string calldata name, address contractAddress) external onlyOwner {
        require(contractAddress != address(0), "ContractsRegistry: Null address is forbidden");

        _contracts[name] = contractAddress;
    }

    /**
     *  @notice The function to add the contracts and deploy the proxy above them. It should be used to add
     *  contract that the ContractsRegistry should be able to upgrade
     *  @param name the name to associate the contract with
     *  @param contractAddress the address of the implementation
     */
    function addProxyContract(string calldata name, address contractAddress) external onlyOwner {
        require(contractAddress != address(0), "ContractsRegistry: Null address is forbidden");

        address proxyAddr = address(
            new TransparentUpgradeableProxy(contractAddress, address(_proxyUpgrader), "")
        );

        AbstractDependant(proxyAddr).setInjector(address(this));

        _contracts[name] = proxyAddr;
        _isProxy[proxyAddr] = true;
    }

    /**
     *  @notice The function to add the already deployed proxy to the ContractsRegistry. This might be used
     *  when the system migrates to a new ContractRegistry. This means that the new ProxyUpgrader must have the
     *  credentials to upgrade the added proxies
     *  @param name the name to associate the contract with
     *  @param contractAddress the address of the proxy
     */
    function justAddProxyContract(string calldata name, address contractAddress)
        external
        onlyOwner
    {
        require(contractAddress != address(0), "ContractsRegistry: Null address is forbidden");

        _contracts[name] = contractAddress;
        _isProxy[contractAddress] = true;
    }

    /**
     *  @notice The function to remove the contract from the ContractsRegistry
     *  @param name the associated name with the contract
     */
    function removeContract(string calldata name) external onlyOwner {
        require(_contracts[name] != address(0), "ContractsRegistry: This mapping doesn't exist");

        delete _isProxy[_contracts[name]];
        delete _contracts[name];
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

/**
 * This is the main register of the system, which stores the addresses of all the necessary contracts of the system.
 * With this contract you can add new contracts, update the implementation of proxy contracts
 */
interface IRegistry {
    /// @notice Function to get the address of the system owner
    /// @return a system owner address
    function getSystemOwner() external view returns (address);

    /// @notice Function to get the address of the DefiCore contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return DefiCore contract address
    function getDefiCoreContract() external view returns (address);

    /// @notice Function to get the address of the SystemParameters contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return SystemParameters contract address
    function getSystemParametersContract() external view returns (address);

    /// @notice Function to get the address of the AssetParameters contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return AssetParameters contract address
    function getAssetParametersContract() external view returns (address);

    /// @notice Function to get the address of the RewardsDistribution contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return RewardsDistribution contract address
    function getRewardsDistributionContract() external view returns (address);

    /// @notice Function to get the address of the UserInfoRegistry contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return UserInfoRegistry contract address
    function getUserInfoRegistryContract() external view returns (address);

    /// @notice Function to get the address of the SystemPoolsRegistry contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return SystemPoolsRegistry contract address
    function getSystemPoolsRegistryContract() external view returns (address);

    /// @notice Function to get the address of the SystemPoolsFactory contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return SystemPoolsFactory contract address
    function getSystemPoolsFactoryContract() external view returns (address);

    /// @notice Function to get the address of the PriceManager contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return PriceManager contract address
    function getPriceManagerContract() external view returns (address);

    /// @notice Function to get the address of the InterestRateLibrary contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return InterestRateLibrary contract address
    function getInterestRateLibraryContract() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^0.8.0;

import "../Proxy.sol";
import "./ERC1967Upgrade.sol";

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializing the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
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
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
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
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
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
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
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
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

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
library StorageSlot {
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
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 *  @notice The ContractsRegistry module
 *
 *  This is the helper contract that is used by an AbstractContractsRegistry as a proxy admin.
 *  It is essential to distinguish between the admin and the registry due to the Transparent proxies nature
 */
contract ProxyUpgrader {
    using Address for address;

    address private immutable _owner;

    event Upgraded(address indexed proxy, address indexed implementation);

    modifier onlyOwner() {
        require(_owner == msg.sender, "ProxyUpgrader: Not an owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function upgrade(
        address what,
        address to,
        bytes calldata data
    ) external onlyOwner {
        require(to.isContract(), "ProxyUpgrader: not a contract");

        if (data.length > 0) {
            TransparentUpgradeableProxy(payable(what)).upgradeToAndCall(to, data);
        } else {
            TransparentUpgradeableProxy(payable(what)).upgradeTo(to);
        }

        emit Upgraded(what, to);
    }

    function getImplementation(address what) external view onlyOwner returns (address) {
        // bytes4(keccak256("implementation()")) == 0x5c60da1b
        (bool success, bytes memory returndata) = address(what).staticcall(hex"5c60da1b");
        require(success);

        return abi.decode(returndata, (address));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: ALGPL-3.0-or-later-or-later
// from https://github.com/makerdao/dss/blob/master/src/jug.sol
pragma solidity ^0.8.0;

library DSMath {
    /**
     * @dev github.com/makerdao/dss implementation of exponentiation by squaring
     * @dev nth power of x where x is decimal number with b precision
     */
    function rpow(
        uint256 x,
        uint256 n,
        uint256 b
    ) internal pure returns (uint256 z) {
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    z := b
                }
                default {
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    z := b
                }
                default {
                    z := x
                }
                let half := div(b, 2) // for rounding.
                for {
                    n := div(n, 2)
                } n {
                    n := div(n, 2)
                } {
                    let xx := mul(x, x)
                    if iszero(eq(div(xx, x), x)) {
                        revert(0, 0)
                    }
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }
                    x := div(xxRound, b)
                    if mod(n, 2) {
                        let zx := mul(z, x)
                        if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) {
                            revert(0, 0)
                        }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }
                        z := div(zxRound, b)
                    }
                }
            }
        }
    }
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