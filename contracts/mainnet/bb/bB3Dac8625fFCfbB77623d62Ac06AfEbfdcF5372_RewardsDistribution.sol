// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";

import "./interfaces/IRegistry.sol";
import "./interfaces/IAssetParameters.sol";
import "./interfaces/IRewardsDistribution.sol";
import "./interfaces/ISystemPoolsRegistry.sol";
import "./interfaces/IBasicPool.sol";

import "./libraries/MathHelper.sol";

import "./common/Globals.sol";

contract RewardsDistribution is IRewardsDistribution, AbstractDependant {
    using MathHelper for uint256;

    address private systemOwnerAddr;
    address private defiCoreAddr;
    IAssetParameters private assetParameters;
    ISystemPoolsRegistry private systemPoolsRegistry;

    mapping(bytes32 => LiquidityPoolInfo) public liquidityPoolsInfo;
    mapping(bytes32 => mapping(address => UserDistributionInfo)) public usersDistributionInfo;

    modifier onlyEligibleContracts() {
        require(
            defiCoreAddr == msg.sender || systemPoolsRegistry.existingLiquidityPools(msg.sender),
            "RewardsDistribution: Caller not an eligible contract."
        );
        _;
    }

    modifier onlySystemOwner() {
        require(
            msg.sender == systemOwnerAddr,
            "RewardsDistribution: Only system owner can call this function."
        );
        _;
    }

    function setDependencies(address _contractsRegistry) external override dependant {
        IRegistry _registry = IRegistry(_contractsRegistry);

        systemOwnerAddr = _registry.getSystemOwner();
        defiCoreAddr = _registry.getDefiCoreContract();
        assetParameters = IAssetParameters(_registry.getAssetParametersContract());
        systemPoolsRegistry = ISystemPoolsRegistry(_registry.getSystemPoolsRegistryContract());
    }

    function updateCumulativeSums(address _userAddr, address _liquidityPool)
        external
        override
        onlyEligibleContracts
    {
        if (_onlyExistingRewardsAssetKey()) {
            _updateSumsWithUserReward(
                _userAddr,
                IBasicPool(_liquidityPool).assetKey(),
                _liquidityPool
            );
        }
    }

    function withdrawUserReward(
        bytes32 _assetKey,
        address _userAddr,
        address _liquidityPool
    ) external override onlyEligibleContracts returns (uint256 _userReward) {
        if (_onlyExistingRewardsAssetKey()) {
            _updateSumsWithUserReward(_userAddr, _assetKey, _liquidityPool);

            UserDistributionInfo storage userInfo = usersDistributionInfo[_assetKey][_userAddr];

            _userReward = userInfo.aggregatedReward;

            if (_userReward > 0) {
                delete userInfo.aggregatedReward;
            }
        }
    }

    function setupRewardsPerBlockBatch(
        bytes32[] calldata _assetKeys,
        uint256[] calldata _rewardsPerBlock
    ) external override onlySystemOwner {
        require(
            _onlyExistingRewardsAssetKey(),
            "RewardsDistributionL Unable to setup rewards per block."
        );

        require(
            _assetKeys.length == _rewardsPerBlock.length,
            "RewardsDistribution: Length mismatch."
        );

        ISystemPoolsRegistry _poolsRegistry = systemPoolsRegistry;

        for (uint256 i = 0; i < _assetKeys.length; i++) {
            bytes32 _currentKey = _assetKeys[i];

            if (liquidityPoolsInfo[_currentKey].rewardPerBlock != 0) {
                (address _poolAddr, ISystemPoolsRegistry.PoolType _poolType) = _poolsRegistry
                    .poolsInfo(_currentKey);

                _updateCumulativeSums(_currentKey, _poolAddr, _poolType);
            } else {
                liquidityPoolsInfo[_currentKey].lastUpdate = block.number;
            }

            liquidityPoolsInfo[_currentKey].rewardPerBlock = _rewardsPerBlock[i];
        }
    }

    function getAPY(bytes32 _assetKey)
        external
        view
        override
        returns (uint256 _supplyAPY, uint256 _borrowAPY)
    {
        IBasicPool _rewardsLP = IBasicPool(systemPoolsRegistry.getRewardsLiquidityPool());

        if (address(_rewardsLP) == address(0)) {
            return (_supplyAPY, _borrowAPY);
        }

        (address _liquidityPoolAddr, ISystemPoolsRegistry.PoolType _poolType) = systemPoolsRegistry
            .poolsInfo(_assetKey);
        ILiquidityPool _liquidityPool = ILiquidityPool(_liquidityPoolAddr);

        LiquidityPoolStats memory _stats = _getLiquidityPoolStats(
            _assetKey,
            _liquidityPoolAddr,
            _poolType
        );

        if (_stats.supplyRewardPerBlock != 0) {
            uint256 _annualSupplyReward = _rewardsLP.getAmountInUSD(_stats.supplyRewardPerBlock) *
                BLOCKS_PER_YEAR *
                DECIMAL;
            uint256 _totalSupplyPoolInUSD = _liquidityPool.getAmountInUSD(
                _liquidityPool.convertLPTokensToAsset(_stats.totalSupplyPool)
            );

            if (_totalSupplyPoolInUSD != 0) {
                _supplyAPY = _annualSupplyReward / _totalSupplyPoolInUSD;
            }
        }

        uint256 _annualBorrowReward = _rewardsLP.getAmountInUSD(_stats.borrowRewardPerBlock) *
            BLOCKS_PER_YEAR *
            DECIMAL;
        uint256 _totalBorrowPoolInUSD = _liquidityPool.getAmountInUSD(_stats.totalBorrowPool);

        if (_totalBorrowPoolInUSD != 0) {
            _borrowAPY = _annualBorrowReward / _totalBorrowPoolInUSD;
        }
    }

    function getUserReward(
        bytes32 _assetKey,
        address _userAddr,
        address _liquidityPool
    ) external view override returns (uint256 _userReward) {
        if (_onlyExistingRewardsAssetKey()) {
            (, ISystemPoolsRegistry.PoolType _poolType) = systemPoolsRegistry.poolsInfo(_assetKey);

            (
                uint256 _newSupplyCumulativeSum,
                uint256 _newBorrowCumulativeSum
            ) = _getNewCumulativeSums(_assetKey, _liquidityPool, _poolType);
            _userReward = _getNewUserReward(
                _userAddr,
                _assetKey,
                _liquidityPool,
                _newSupplyCumulativeSum,
                _newBorrowCumulativeSum,
                _poolType
            );
        }
    }

    function _updateSumsWithUserReward(
        address _userAddr,
        bytes32 _assetKey,
        address _liquidityPool
    ) internal {
        (, ISystemPoolsRegistry.PoolType _poolType) = systemPoolsRegistry.poolsInfo(_assetKey);

        (uint256 _newSupplyCumulativeSum, uint256 _newBorrowCumulativeSum) = _updateCumulativeSums(
            _assetKey,
            _liquidityPool,
            _poolType
        );
        uint256 _newReward = _getNewUserReward(
            _userAddr,
            _assetKey,
            _liquidityPool,
            _newSupplyCumulativeSum,
            _newBorrowCumulativeSum,
            _poolType
        );

        usersDistributionInfo[_assetKey][_userAddr] = UserDistributionInfo(
            _newSupplyCumulativeSum,
            _newBorrowCumulativeSum,
            _newReward
        );
    }

    function _updateCumulativeSums(
        bytes32 _assetKey,
        address _liquidityPool,
        ISystemPoolsRegistry.PoolType _poolType
    ) internal returns (uint256 _newSupplyCumulativeSum, uint256 _newBorrowCumulativeSum) {
        (_newSupplyCumulativeSum, _newBorrowCumulativeSum) = _getNewCumulativeSums(
            _assetKey,
            _liquidityPool,
            _poolType
        );

        LiquidityPoolInfo storage liquidityPoolInfo = liquidityPoolsInfo[_assetKey];

        if (liquidityPoolInfo.lastUpdate != block.number) {
            liquidityPoolInfo.supplyCumulativeSum = _newSupplyCumulativeSum;
            liquidityPoolInfo.borrowCumulativeSum = _newBorrowCumulativeSum;
            liquidityPoolInfo.lastUpdate = block.number;
        }
    }

    function _getNewUserReward(
        address _userAddr,
        bytes32 _assetKey,
        address _liquidityPool,
        uint256 _newSupplyCumulativeSum,
        uint256 _newBorrowCumulativeSum,
        ISystemPoolsRegistry.PoolType _poolType
    ) internal view returns (uint256 _newAggregatedReward) {
        UserDistributionInfo storage userInfo = usersDistributionInfo[_assetKey][_userAddr];

        _newAggregatedReward = userInfo.aggregatedReward;

        uint256 _liquidityAmount;

        if (_poolType == ISystemPoolsRegistry.PoolType.LIQUIDITY_POOL) {
            _liquidityAmount = ERC20(_liquidityPool).balanceOf(_userAddr);
        }

        (uint256 _borrowAmount, ) = IBasicPool(_liquidityPool).borrowInfos(_userAddr);

        if (_liquidityAmount > 0) {
            _newAggregatedReward += (_newSupplyCumulativeSum - userInfo.lastSupplyCumulativeSum)
                .mulWithPrecision(_liquidityAmount);
        }

        if (_borrowAmount > 0) {
            _newAggregatedReward += (_newBorrowCumulativeSum - userInfo.lastBorrowCumulativeSum)
                .mulWithPrecision(_borrowAmount);
        }
    }

    function _getNewCumulativeSums(
        bytes32 _assetKey,
        address _liquidityPool,
        ISystemPoolsRegistry.PoolType _poolType
    ) internal view returns (uint256 _newSupplyCumulativeSum, uint256 _newBorrowCumulativeSum) {
        LiquidityPoolInfo storage liquidityPoolInfo = liquidityPoolsInfo[_assetKey];

        uint256 _lastUpdate = liquidityPoolInfo.lastUpdate;
        _lastUpdate = _lastUpdate == 0 ? block.number : _lastUpdate;

        uint256 _blocksDelta = block.number - _lastUpdate;

        _newSupplyCumulativeSum = liquidityPoolInfo.supplyCumulativeSum;
        _newBorrowCumulativeSum = liquidityPoolInfo.borrowCumulativeSum;

        if (_blocksDelta != 0) {
            LiquidityPoolStats memory _stats = _getLiquidityPoolStats(
                _assetKey,
                _liquidityPool,
                _poolType
            );

            if (_stats.totalSupplyPool != 0) {
                _newSupplyCumulativeSum = _countNewCumulativeSum(
                    _stats.supplyRewardPerBlock,
                    _stats.totalSupplyPool,
                    _newSupplyCumulativeSum,
                    _blocksDelta
                );
            }

            if (_stats.totalBorrowPool != 0) {
                _newBorrowCumulativeSum = _countNewCumulativeSum(
                    _stats.borrowRewardPerBlock,
                    _stats.totalBorrowPool,
                    _newBorrowCumulativeSum,
                    _blocksDelta
                );
            }
        }
    }

    function _getLiquidityPoolStats(
        bytes32 _assetKey,
        address _liquidityPool,
        ISystemPoolsRegistry.PoolType _poolType
    ) internal view returns (LiquidityPoolStats memory) {
        uint256 _supplyRewardPerBlock;
        uint256 _borrowRewardPerBlock;
        uint256 _totalSupplyPool;

        if (_poolType == ISystemPoolsRegistry.PoolType.LIQUIDITY_POOL) {
            (_supplyRewardPerBlock, _borrowRewardPerBlock) = _getRewardsPerBlock(
                _assetKey,
                ILiquidityPool(_liquidityPool).getBorrowPercentage()
            );

            _totalSupplyPool = ERC20(_liquidityPool).totalSupply();
        } else {
            _borrowRewardPerBlock = liquidityPoolsInfo[_assetKey].rewardPerBlock;
        }

        uint256 _totalBorrowPool = IBasicPool(_liquidityPool).aggregatedBorrowedAmount();

        return
            LiquidityPoolStats(
                _supplyRewardPerBlock,
                _borrowRewardPerBlock,
                _totalSupplyPool,
                _totalBorrowPool
            );
    }

    function _getRewardsPerBlock(bytes32 _assetKey, uint256 _currentUR)
        internal
        view
        returns (uint256 _supplyRewardPerBlock, uint256 _borrowRewardPerBlock)
    {
        uint256 _totalRewardPerBlock = liquidityPoolsInfo[_assetKey].rewardPerBlock;

        if (_totalRewardPerBlock == 0) {
            return (_supplyRewardPerBlock, _borrowRewardPerBlock);
        }

        IAssetParameters.DistributionMinimums memory _distrMinimums = assetParameters
            .getDistributionMinimums(_assetKey);

        uint256 _supplyRewardPerBlockPart = (DECIMAL -
            _distrMinimums.minBorrowDistrPart -
            _distrMinimums.minSupplyDistrPart).mulWithPrecision(_currentUR) +
            _distrMinimums.minSupplyDistrPart;

        _supplyRewardPerBlock = _totalRewardPerBlock.mulWithPrecision(_supplyRewardPerBlockPart);
        _borrowRewardPerBlock = _totalRewardPerBlock - _supplyRewardPerBlock;
    }

    function _onlyExistingRewardsAssetKey() internal view returns (bool) {
        return systemPoolsRegistry.rewardsAssetKey() != bytes32(0);
    }

    function _countNewCumulativeSum(
        uint256 _rewardPerBlock,
        uint256 _totalPool,
        uint256 _prevCumulativeSum,
        uint256 _blocksDelta
    ) internal pure returns (uint256) {
        uint256 _newPrice = _rewardPerBlock.divWithPrecision(_totalPool);
        return _blocksDelta * _newPrice + _prevCumulativeSum;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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