// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.5;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

import './CoreV2.sol';
import '../interfaces/IAsset.sol';
import './PausableAssets.sol';

/**
 * @title Pool
 * @notice Manages deposits, withdrawals and swaps. Holds a mapping of assets and parameters.
 * @dev The main entry-point of Wombat protocol
 * Note: All variables are 18 decimals, except from th amount of underlying token
 * There are 2 operating mode. Either set shouldMaintainGlobalEquil to true and maintain global cov ratio (r*) at 1.
 * Or set shouldMaintainGlobalEquil to false, and allow r* to be any value > 1.
 */
contract Pool is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    PausableAssets,
    CoreV2
{
    using DSMath for uint256;
    using SafeERC20 for IERC20;
    using SignedSafeMath for int256;

    /// @notice Asset Map struct holds assets
    struct AssetMap {
        address[] keys;
        mapping(address => IAsset) values;
        mapping(address => uint256) indexOf;
    }

    /* Storage */

    /// @notice Amplification factor
    uint256 public ampFactor;

    /// @notice Haircut rate
    uint256 public haircutRate;

    /// @notice Retention ratio: the ratio of haircut that should stay in the pool
    uint256 public retentionRatio;

    /// @notice LP dividend ratio : the ratio of haircut that should distribute to LP
    uint256 public lpDividendRatio;

    /// @notice The threshold to mint fee (unit: WAD)
    uint256 public mintFeeThreshold;

    /// @notice Dev address
    address public dev;

    address public feeTo;

    bool public shouldMaintainGlobalEquil;

    /// @notice Dividend collected by each asset (unit: WAD)
    mapping(IAsset => uint256) private _feeCollected;

    /// @notice A record of assets inside Pool
    AssetMap private _assets;

    /* Events */

    /// @notice An event thats emitted when an asset is added to Pool
    event AssetAdded(address indexed token, address indexed asset);

    /// @notice An event thats emitted when asset is removed from Pool
    event AssetRemoved(address indexed token, address indexed asset);

    /// @notice An event thats emitted when a deposit is made to Pool
    event Deposit(address indexed sender, address token, uint256 amount, uint256 liquidity, address indexed to);

    /// @notice An event thats emitted when a withdrawal is made from Pool
    event Withdraw(address indexed sender, address token, uint256 amount, uint256 liquidity, address indexed to);

    /// @notice An event thats emitted when a swap is made in Pool
    event Swap(
        address indexed sender,
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address indexed to
    );

    /* Errors */

    error WOMBAT_FORBIDDEN();
    error WOMBAT_EXPIRED();

    error WOMBAT_ASSET_NOT_EXISTS();
    error WOMBAT_ASSET_ALREADY_EXIST();

    error WOMBAT_ZERO_ADDRESS();
    error WOMBAT_ZERO_AMOUNT();
    error WOMBAT_ZERO_LIQUIDITY();
    error WOMBAT_INVALID_VALUE();
    error WOMBAT_SAME_ADDRESS();
    error WOMBAT_AMOUNT_TOO_LOW();
    error WOMBAT_CASH_NOT_ENOUGH();
    error WOMBAT_INTERPOOL_SWAP_NOT_SUPPORTED();

    /* Pesudo modifiers to safe gas */

    function _checkLiquidity(uint256 liquidity) private view {
        if (liquidity == 0) revert WOMBAT_ZERO_LIQUIDITY();
    }

    function _checkAddress(address to) private view {
        if (to == address(0)) revert WOMBAT_ZERO_ADDRESS();
    }

    function _checkSameAddress(address from, address to) private view {
        if (from == to) revert WOMBAT_SAME_ADDRESS();
    }

    function _checkAmount(uint256 minAmt, uint256 amt) private view {
        if (minAmt > amt) revert WOMBAT_AMOUNT_TOO_LOW();
    }

    function _checkAccount(address from, address to) private view {
        if (from != to) revert WOMBAT_INTERPOOL_SWAP_NOT_SUPPORTED();
    }

    function _ensure(uint256 deadline) private view {
        if (deadline < block.timestamp) revert WOMBAT_EXPIRED();
    }

    function _onlyDev() private view {
        if (dev != msg.sender) revert WOMBAT_FORBIDDEN();
    }

    /* Construtor and setters */

    /**
     * @notice Initializes pool. Dev is set to be the account calling this function.
     */
    function initialize(uint256 ampFactor_, uint256 haircutRate_) external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init_unchained();
        __ReentrancyGuard_init_unchained();
        __Pausable_init_unchained();

        ampFactor = ampFactor_;
        haircutRate = haircutRate_;

        lpDividendRatio = WAD;
        shouldMaintainGlobalEquil = true;

        dev = msg.sender;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    /**
     * @dev pause pool, restricting certain operations
     */
    function pause() external nonReentrant {
        _onlyDev();
        _pause();
    }

    /**
     * @dev unpause pool, enabling certain operations
     */
    function unpause() external nonReentrant {
        _onlyDev();
        _unpause();
    }

    /**
     * @dev pause asset, restricting deposit and swap operations
     */
    function pauseAsset(address asset) external nonReentrant {
        _onlyDev();
        _pauseAsset(asset);
    }

    /**
     * @dev unpause asset, enabling deposit and swap operations
     */
    function unpauseAsset(address asset) external nonReentrant {
        _onlyDev();
        _unpauseAsset(asset);
    }

    // Setters //
    /**
     * @notice Changes the contract dev. Can only be set by the contract owner.
     * @param dev_ new contract dev address
     */
    function setDev(address dev_) external onlyOwner {
        _checkAddress(dev_);
        dev = dev_;
    }

    /**
     * @notice Changes the pools amplification factor. Can only be set by the contract owner.
     * @param ampFactor_ new pool's amplification factor
     */
    function setAmpFactor(uint256 ampFactor_) external onlyOwner {
        if (ampFactor_ > WAD) revert WOMBAT_INVALID_VALUE(); // ampFactor_ should not be set bigger than 1
        ampFactor = ampFactor_;
    }

    /**
     * @notice Changes the pools haircutRate. Can only be set by the contract owner.
     * @param haircutRate_ new pool's haircutRate_
     */
    function setHaircutRate(uint256 haircutRate_) external onlyOwner {
        if (haircutRate_ > WAD) revert WOMBAT_INVALID_VALUE(); // haircutRate_ should not be set bigger than 1
        haircutRate = haircutRate_;
    }

    /**
     * @notice Changes the pools retentionRatio. Can only be set by the contract owner.
     * @param retentionRatio_ new pool's retentionRatio
     */
    function setRetentionRatio(uint256 retentionRatio_) external onlyOwner {
        if (retentionRatio_ + lpDividendRatio > WAD) revert WOMBAT_INVALID_VALUE();
        mintAllFee();
        retentionRatio = retentionRatio_;
    }

    function setLpDividendRatio(uint256 lpDividendRatio_) external onlyOwner {
        if (retentionRatio + lpDividendRatio_ > WAD) revert WOMBAT_INVALID_VALUE();
        mintAllFee();
        lpDividendRatio = lpDividendRatio_;
    }

    /**
     * @notice Changes the fee beneficiary. Can only be set by the contract owner.
     * This value cannot be set to 0 to avoid unsettled fee.
     * @param feeTo_ new fee beneficiary
     */
    function setFeeTo(address feeTo_) external onlyOwner {
        if (feeTo_ == address(0)) revert WOMBAT_INVALID_VALUE();
        feeTo = feeTo_;
    }

    /**
     * @notice Enable exact deposit
     * Should only be enabled when r* = 1
     */
    function setShouldMaintainGlobalEquil(bool shouldMaintainGlobalEquil_) external onlyOwner {
        mintAllFee();
        shouldMaintainGlobalEquil = shouldMaintainGlobalEquil_;
    }

    /**
     * @notice Set min fee to mint
     */
    function setMintFeeThreshold(uint256 mintFeeThreshold_) external onlyOwner {
        mintFeeThreshold = mintFeeThreshold_;
    }

    /* Assets */

    /**
     * @notice Adds asset to pool, reverts if asset already exists in pool
     * @param token The address of token
     * @param asset The address of the Wombat Asset contract
     */
    function addAsset(address token, address asset) external onlyOwner nonReentrant {
        _checkAddress(asset);
        _checkAddress(token);

        if (_containsAsset(token)) revert WOMBAT_ASSET_ALREADY_EXIST();
        _assets.values[token] = IAsset(asset);
        _assets.indexOf[token] = _assets.keys.length;
        _assets.keys.push(token);

        emit AssetAdded(token, asset);
    }

    /**
     * @notice Removes asset from asset struct
     * @dev Can only be called by owner
     * @param key The address of token to remove
     */
    function removeAsset(address key) external onlyOwner {
        if (!_containsAsset(key)) revert WOMBAT_ASSET_NOT_EXISTS();

        address asset = address(_getAsset(key));
        delete _assets.values[key];

        uint256 index = _assets.indexOf[key];
        uint256 lastIndex = _assets.keys.length - 1;
        address lastKey = _assets.keys[lastIndex];

        _assets.indexOf[lastKey] = index;
        delete _assets.indexOf[key];

        _assets.keys[index] = lastKey;
        _assets.keys.pop();

        emit AssetRemoved(key, asset);
    }

    /**
     * @notice get length of asset list
     * @return the size of the asset list
     */
    function _sizeOfAssetList() private view returns (uint256) {
        return _assets.keys.length;
    }

    /**
     * @notice Gets asset with token address key
     * @param key The address of token
     * @return the corresponding asset in state
     */
    function _getAsset(address key) private view returns (IAsset) {
        return _assets.values[key];
    }

    /**
     * @notice Gets key (address) at index
     * @param index the index
     * @return the key of index
     */
    function _getKeyAtIndex(uint256 index) private view returns (address) {
        return _assets.keys[index];
    }

    /**
     * @notice Looks if the asset is contained by the list
     * @param token The address of token to look for
     * @return bool true if the asset is in asset list, false otherwise
     */
    function _containsAsset(address token) private view returns (bool) {
        return _assets.values[token] != IAsset(address(0));
    }

    /**
     * @notice Gets Asset corresponding to ERC20 token. Reverts if asset does not exists in Pool.
     * @param token The address of ERC20 token
     */
    function _assetOf(address token) private view returns (IAsset) {
        if (!_containsAsset(token)) revert WOMBAT_ASSET_NOT_EXISTS();
        return _assets.values[token];
    }

    /**
     * @notice Gets Asset corresponding to ERC20 token. Reverts if asset does not exists in Pool.
     * @dev to be used externally
     * @param token The address of ERC20 token
     */
    function assetOf(address token) external view returns (address) {
        return address(_assetOf(token));
    }

    /* Deposit */

    /**
     * This functinos approximate the amount of liquidity of the deposit regardless of value of r*.
     * Fee could be positive of negative
     */
    function _depositTo(IAsset asset, uint256 amount)
        internal
        view
        returns (
            uint256 liquidity,
            uint256 liabilityToMint,
            int256 fee
        )
    {
        int256 reward = _depositReward(int256(amount), asset);
        // revert if value doesn't make sense in case of overflow
        if (reward > int256(amount) || reward < -int256(amount)) {
            revert WOMBAT_INVALID_VALUE();
        }

        // we don't distribute deposit reward if reward > 0
        if (reward < 0) {
            fee = -reward;
        }

        liabilityToMint = uint256(int256(amount) - fee);

        // Calculate amount of LP to mint : ( deposit + reward ) * TotalAssetSupply / Liability
        uint256 liability = asset.liability();
        liquidity = (liability == 0 ? liabilityToMint : (liabilityToMint * asset.totalSupply()) / liability);
    }

    /**
     * This function calculate the exactly amount of liquidity of the deposit. Assumes r* = 1
     */
    function _exactDepositToInEquil(IAsset asset, uint256 amount)
        internal
        view
        returns (
            uint256 liquidity,
            uint256 liabilityToMint,
            int256 fee
        )
    {
        fee = -exactDepositRewardInEquilImpl(
            int256(amount),
            int256(uint256(asset.cash())),
            int256(uint256(asset.liability())),
            int256(ampFactor)
        );
        // revert if value doesn't make sense in case of overflow
        if (fee >= int256(10**asset.underlyingTokenDecimals() / 1000000) || fee < -int256(amount)) {
            revert WOMBAT_INVALID_VALUE();
        }

        liabilityToMint = uint256(int256(amount) - fee);

        // Calculate amount of LP to mint : ( deposit + reward ) * TotalAssetSupply / Liability
        uint256 liability = asset.liability();
        liquidity = (liability == 0 ? liabilityToMint : (liabilityToMint * asset.totalSupply()) / liability);
    }

    /**
     * @notice Deposits asset in Pool
     * @param asset The asset to be deposited
     * @param amount The amount to be deposited
     * @param to The user accountable for deposit, receiving the Wombat assets (lp)
     * @return liquidity Total asset liquidity minted
     */
    function _deposit(
        IAsset asset,
        uint256 amount,
        address to
    ) internal returns (uint256 liquidity) {
        // collect fee before deposit
        _mintFee(asset);

        uint256 liabilityToMint;
        (liquidity, liabilityToMint, ) = shouldMaintainGlobalEquil
            ? _exactDepositToInEquil(asset, amount)
            : _depositTo(asset, amount);

        _checkLiquidity(liquidity);

        asset.addCash(amount);
        asset.addLiability(liabilityToMint);
        asset.mint(to, liquidity);
    }

    /**
     * @notice Deposits amount of tokens into pool ensuring deadline
     * @dev Asset needs to be created and added to pool before any operation
     * @param token The token address to be deposited
     * @param amount The amount to be deposited
     * @param to The user accountable for deposit, receiving the Wombat assets (lp)
     * @param deadline The deadline to be respected
     * @return liquidity Total asset liquidity minted
     */
    function deposit(
        address token,
        uint256 amount,
        address to,
        uint256 deadline
    ) external nonReentrant whenNotPaused returns (uint256 liquidity) {
        if (amount == 0) revert WOMBAT_ZERO_AMOUNT();
        _checkAddress(to);
        _ensure(deadline);
        requireAssetNotPaused(token);

        IAsset asset = _assetOf(token);
        IERC20(token).safeTransferFrom(address(msg.sender), address(asset), amount);
        liquidity = _deposit(asset, amount.toWad(asset.underlyingTokenDecimals()), to);

        emit Deposit(msg.sender, token, amount, liquidity, to);
    }

    /**
     * @notice Quotes potential deposit from pool
     * @dev To be used by frontend
     * @param token The token to deposit by user
     * @param amount The amount to deposit
     * @return liquidity The potential liquidity user would receive
     * @return fee The fee that would be applied
     */
    function quotePotentialDeposit(address token, uint256 amount)
        external
        view
        returns (uint256 liquidity, int256 fee)
    {
        IAsset asset = _assetOf(token);
        (liquidity, , fee) = _depositTo(asset, amount.toWad(asset.underlyingTokenDecimals()));
    }

    /* Withdraw */

    /**
     * @notice Calculates fee and liability to burn in case of withdrawal
     * @param asset The asset willing to be withdrawn
     * @param liquidity The liquidity willing to be withdrawn
     * @return amount Total amount to be withdrawn from Pool
     * @return liabilityToBurn Total liability to be burned by Pool
     * @return fee
     * @return enoughCash
     */
    function _withdrawFrom(IAsset asset, uint256 liquidity)
        private
        view
        returns (
            uint256 amount,
            uint256 liabilityToBurn,
            int256 fee,
            bool enoughCash
        )
    {
        liabilityToBurn = (asset.liability() * liquidity) / asset.totalSupply();
        _checkLiquidity(liabilityToBurn);

        // overflow is unrealistic
        int256 L_i = int256(liabilityToBurn);
        fee = _withdrawalFee(L_i, asset);

        // As it is possible to have fee greater than the amount, we don't revert here
        // revert if value doesn't make sense in case of overflow
        // if (fee > L_i || fee < -L_i || (shouldMaintainGlobalEquil && fee <= -int256(10**asset.decimals() / 1000000))) {
        //     revert WOMBAT_INVALID_VALUE();
        // }

        // Prevent underflow in case withdrawal fees >= liabilityToBurn, user would only burn his underlying liability
        if (L_i > fee) {
            if (asset.cash() < uint256(L_i - fee)) {
                amount = asset.cash(); // When asset does not contain enough cash, just withdraw the remaining cash
                fee = 0;
                enoughCash = false;
            } else {
                amount = uint256(L_i - fee); // There is enough cash, standard withdrawal
                enoughCash = true;
            }
        } else {
            fee = L_i;
            amount = 0;
            enoughCash = false;
        }
    }

    /**
     * @notice Withdraws liquidity amount of asset to `to` address ensuring minimum amount required
     * @param asset The asset to be withdrawn
     * @param liquidity The liquidity to be withdrawn
     * @param minimumAmount The minimum amount that will be accepted by user
     * @return amount The total amount withdrawn
     */
    function _withdraw(
        IAsset asset,
        uint256 liquidity,
        uint256 minimumAmount
    ) private returns (uint256 amount) {
        // collect fee before withdraw
        _mintFee(asset);

        // calculate liabilityToBurn and Fee
        uint256 liabilityToBurn;
        (amount, liabilityToBurn, , ) = _withdrawFrom(asset, liquidity);
        _checkAmount(minimumAmount, amount);

        asset.burn(address(asset), liquidity);
        asset.removeCash(amount);
        asset.removeLiability(liabilityToBurn);
    }

    /**
     * @notice Withdraws liquidity amount of asset to `to` address ensuring minimum amount required
     * @param token The token to be withdrawn
     * @param liquidity The liquidity to be withdrawn
     * @param minimumAmount The minimum amount that will be accepted by user
     * @param to The user receiving the withdrawal
     * @param deadline The deadline to be respected
     * @return amount The total amount withdrawn
     */
    function withdraw(
        address token,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external nonReentrant whenNotPaused returns (uint256 amount) {
        _checkLiquidity(liquidity);
        _checkAddress(to);
        _ensure(deadline);

        IAsset asset = _assetOf(token);
        // request lp token from user
        IERC20(asset).safeTransferFrom(address(msg.sender), address(asset), liquidity);
        amount = _withdraw(asset, liquidity, minimumAmount).fromWad(asset.underlyingTokenDecimals());
        asset.transferUnderlyingToken(to, amount);

        emit Withdraw(msg.sender, token, amount, liquidity, to);
    }

    /**
     * @notice Enables withdrawing liquidity from an asset using LP from a different asset
     * @param fromToken The corresponding token user holds the LP (Asset) from
     * @param toToken The token wanting to be withdrawn (needs to be well covered)
     * @param liquidity The liquidity to be withdrawn (in fromToken decimal)
     * @param minimumAmount The minimum amount that will be accepted by user
     * @param to The user receiving the withdrawal
     * @param deadline The deadline to be respected
     * @dev Also, coverage ratio of toAsset must be higher than 1 after withdrawal for this to be accepted
     * @return toAmount The total amount withdrawn
     */
    function withdrawFromOtherAsset(
        address fromToken,
        address toToken,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external nonReentrant whenNotPaused returns (uint256 toAmount) {
        _checkAddress(to);
        _checkLiquidity(liquidity);
        _ensure(deadline);
        requireAssetNotPaused(fromToken);

        // Withdraw and swap
        IAsset fromAsset = _assetOf(fromToken);
        IERC20(fromAsset).safeTransferFrom(address(msg.sender), address(fromAsset), liquidity);
        uint256 fromAmountInWad = _withdraw(fromAsset, liquidity, 0);
        (toAmount, ) = _swap(fromToken, toToken, fromAmountInWad, minimumAmount, to);
        toAmount = toAmount.fromWad(_assetOf(toToken).underlyingTokenDecimals());
        _assetOf(toToken).transferUnderlyingToken(to, toAmount);
        emit Withdraw(msg.sender, toToken, toAmount, liquidity, to);
    }

    /**
     * @notice Quotes potential withdrawal from pool
     * @dev To be used by frontend
     * @param token The token to be withdrawn by user
     * @param liquidity The liquidity (amount of lp assets) to be withdrawn
     * @return amount The potential amount user would receive
     * @return fee The fee that would be applied
     * @return enoughCash does the pool have enough cash? (cash >= liabilityToBurn - fee)
     */
    function quotePotentialWithdraw(address token, uint256 liquidity)
        external
        view
        returns (
            uint256 amount,
            int256 fee,
            bool enoughCash
        )
    {
        _checkLiquidity(liquidity);
        IAsset asset = _assetOf(token);
        (amount, , fee, enoughCash) = _withdrawFrom(asset, liquidity);
        amount = amount.fromWad(asset.underlyingTokenDecimals());
    }

    /* Swap */

    /**
     * @notice Quotes the ideal amount in case of swap
     * @dev Does not take into haircut or other fees
     * @param fromAsset The initial asset
     * @param toAsset The asset wanted by user
     * @param fromAmount The amount to quote
     * @return idealToAmount The ideal amount user would receive
     */
    function _quoteIdealToAmount(
        IAsset fromAsset,
        IAsset toAsset,
        int256 fromAmount
    ) private view returns (uint256 idealToAmount) {
        uint256 Lx = fromAsset.liability();
        uint256 Ly = toAsset.liability();

        // in case div of 0
        _checkLiquidity(Lx);
        _checkLiquidity(Ly);

        idealToAmount = _swapQuoteFunc(
            int256(uint256(fromAsset.cash())),
            int256(uint256(toAsset.cash())),
            int256(Lx),
            int256(Ly),
            fromAmount,
            int256(ampFactor)
        );
    }

    /**
     * @notice Quotes the actual amount user would receive in a swap, taking in account slippage and haircut
     * @param fromAsset The initial asset
     * @param toAsset The asset wanted by user
     * @param fromAmount The amount to quote
     * @return actualToAmount The actual amount user would receive
     * @return haircut The haircut that will be applied
     */
    function _quoteFrom(
        IAsset fromAsset,
        IAsset toAsset,
        int256 fromAmount
    ) private view returns (uint256 actualToAmount, uint256 haircut) {
        uint256 idealToAmount = _quoteIdealToAmount(fromAsset, toAsset, fromAmount);
        if (toAsset.cash() < idealToAmount) revert WOMBAT_CASH_NOT_ENOUGH();

        haircut = idealToAmount.wmul(haircutRate);
        // exact output swap quote has added haircut already
        if (fromAmount > 0) {
            actualToAmount = idealToAmount - haircut;
        } else {
            actualToAmount = idealToAmount;
        }
    }

    /**
     * @notice Swap fromToken for toToken, ensures deadline and minimumToAmount and sends quoted amount to `to` address
     * @param fromToken The token being inserted into Pool by user for swap
     * @param toToken The token wanted by user, leaving the Pool
     * @param fromAmount The amount of from token inserted
     * @param minimumToAmount The minimum amount that will be accepted by user as result
     * @param to The user receiving the result of swap
     * @param deadline The deadline to be respected
     */
    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    ) external nonReentrant whenNotPaused returns (uint256 actualToAmount, uint256 haircut) {
        _checkSameAddress(fromToken, toToken);
        if (fromAmount == 0) revert WOMBAT_ZERO_AMOUNT();
        _checkAddress(to);
        _ensure(deadline);
        requireAssetNotPaused(fromToken);

        uint8 fromDecimal = _assetOf(fromToken).underlyingTokenDecimals();
        uint8 toDecimal = _assetOf(toToken).underlyingTokenDecimals();

        (actualToAmount, haircut) = _swap(
            fromToken,
            toToken,
            fromAmount.toWad(fromDecimal),
            minimumToAmount.toWad(toDecimal),
            to
        );

        actualToAmount = actualToAmount.fromWad(toDecimal);
        haircut = haircut.fromWad(toDecimal);

        IERC20(fromToken).safeTransferFrom(address(msg.sender), address(_assetOf(fromToken)), fromAmount);
        _assetOf(toToken).transferUnderlyingToken(to, actualToAmount);

        emit Swap(msg.sender, fromToken, toToken, fromAmount, actualToAmount, to);
    }

    /**
     * expect fromAmount and minimumToAmount to be in WAD
     */
    function _swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to
    ) internal returns (uint256 actualToAmount, uint256 haircut) {
        IAsset fromAsset = _assetOf(fromToken);
        IAsset toAsset = _assetOf(toToken);

        (actualToAmount, haircut) = _quoteFrom(fromAsset, toAsset, int256(fromAmount));
        _checkAmount(minimumToAmount, actualToAmount);

        _feeCollected[toAsset] += haircut;

        fromAsset.addCash(fromAmount);

        if (shouldMaintainGlobalEquil) {
            // haircut is removed from cash to maintain r* = 1. It is distributed during _mintFee()
            toAsset.removeCash(actualToAmount + haircut);
        } else {
            // haircut is distributed in the form of LP token to beneficiary during _mintFee()
            toAsset.removeCash(actualToAmount);
        }
    }

    /**
     * @notice Quotes potential outcome of a swap given current state, taking in account slippage and haircut
     * @dev To be used by frontend
     * @param fromToken The initial ERC20 token
     * @param toToken The token wanted by user
     * @param fromAmount The amount to quote
     * @return potentialOutcome The potential amount user would receive
     * @return haircut The haircut that would be applied
     */
    function quotePotentialSwap(
        address fromToken,
        address toToken,
        int256 fromAmount
    ) external view returns (uint256 potentialOutcome, uint256 haircut) {
        _checkSameAddress(fromToken, toToken);
        if (fromAmount == 0) revert WOMBAT_ZERO_AMOUNT();

        IAsset fromAsset = _assetOf(fromToken);
        IAsset toAsset = _assetOf(toToken);

        // exact output swap quote adds haircut
        if (fromAmount < 0) {
            uint256 haircut = uint256(-fromAmount).wmul(haircutRate);
            fromAmount -= int256(haircut);
        }

        fromAmount = fromAmount.toWad(fromAsset.underlyingTokenDecimals());
        (potentialOutcome, haircut) = _quoteFrom(fromAsset, toAsset, fromAmount);
        potentialOutcome = potentialOutcome.fromWad(toAsset.underlyingTokenDecimals());
        haircut = haircut.fromWad(toAsset.underlyingTokenDecimals());
    }

    /* Queries */

    /**
     * @notice Returns the exchange rate of the LP token
     * @param token The address of the token
     * @return exchangeRate
     */
    function exchangeRate(address token) external view returns (uint256 exchangeRate) {
        IAsset asset = _assetOf(token);
        if (asset.totalSupply() == 0) return WAD;
        return exchangeRate = uint256(asset.liability()).wdiv(uint256(asset.totalSupply()));
    }

    function globalEquilCovRatio() external view returns (uint256 equilCovRatio, uint256 invariant) {
        uint256 SL;
        (invariant, SL) = _globalInvariantFunc();
        equilCovRatio = uint256(_equilCovRatio(int256(invariant), int256(SL), int256(ampFactor)));
    }

    function tipBucketBalance(address token) external view returns (uint256 balance) {
        IAsset asset = _assetOf(token);
        return
            asset.underlyingTokenBalance().toWad(asset.underlyingTokenDecimals()) - asset.cash() - _feeCollected[asset];
    }

    /* Utils */

    function _depositReward(int256 amount, IAsset asset) internal view returns (int256 v) {
        if (shouldMaintainGlobalEquil) {
            v = depositRewardInEquilImpl(
                amount,
                int256(uint256(asset.cash())),
                int256(uint256(asset.liability())),
                int256(ampFactor)
            );
        } else {
            (uint256 D, uint256 SL) = _globalInvariantFunc();
            v = depositRewardImpl(
                int256(D),
                int256(SL),
                amount,
                int256(uint256(asset.cash())),
                int256(uint256(asset.liability())),
                int256(ampFactor)
            );
        }
    }

    function _withdrawalFee(int256 amount, IAsset asset) internal view returns (int256 fee) {
        fee = -_depositReward(-amount, asset);
    }

    function _globalInvariantFunc() internal view returns (uint256 D, uint256 SL) {
        uint256 A = ampFactor;

        for (uint256 i = 0; i < _sizeOfAssetList(); i++) {
            IAsset asset = _getAsset(_getKeyAtIndex(i));

            // overflow is unrealistic
            uint256 A_i = asset.cash();
            uint256 L_i = asset.liability();

            // Assume when L_i == 0, A_i always == 0
            if (L_i == 0) {
                // avoid division of 0
                continue;
            }

            uint256 r_i = A_i.wdiv(L_i);
            SL += L_i;
            D += L_i.wmul(r_i - A.wdiv(r_i));
        }
    }

    /**
     * @notice Private function to send fee collected to the fee beneficiary
     * @param asset The address of the asset to collect fee
     */
    function _mintFee(IAsset asset) private {
        uint256 feeCollected = _feeCollected[asset];
        if (feeCollected == 0 || feeCollected < mintFeeThreshold) {
            // early return
            return;
        }

        // dividend to veWOM
        uint256 dividend = feeCollected.wmul(WAD - lpDividendRatio - retentionRatio);
        // dividend to LP
        uint256 lpDividend = feeCollected.wmul(lpDividendRatio);

        if (shouldMaintainGlobalEquil) {
            if (dividend > 0) {
                asset.transferUnderlyingToken(feeTo, dividend.fromWad(asset.underlyingTokenDecimals()));
            }
            if (lpDividend > 0) {
                // exact deposit to maintain r* = 1
                // increase the value of the LP token, i.e. assetsPerShare
                (, uint256 liabilityToMint, ) = _exactDepositToInEquil(asset, lpDividend);
                asset.addLiability(liabilityToMint);
                asset.addCash(lpDividend);
            }
            // feeCollected.wmul(retentionRatio) remains in the tip bucket
        } else {
            if (dividend > 0) {
                // call totalSupply() and liability() before mint()
                asset.mint(feeTo, (dividend * asset.totalSupply()) / asset.liability());
                asset.addLiability(dividend);
            }
            if (lpDividend > 0) {
                asset.addLiability(lpDividend);
            }
        }

        _feeCollected[asset] = 0;
    }

    function mintAllFee() internal {
        for (uint256 i = 0; i < _sizeOfAssetList(); i++) {
            IAsset asset = _getAsset(_getKeyAtIndex(i));
            _mintFee(asset);
        }
    }

    /**
     * @notice Send fee collected to the fee beneficiary
     * @param token The address of the token to collect fee
     */
    function mintFee(address token) external {
        _mintFee(_assetOf(token));
    }
}

// SPDX-License-Identifier: MIT

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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT

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
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
    }
    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, bytes(""), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual {
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

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

import "../IERC20.sol";
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.5;

import '../libraries/DSMath.sol';
import '../libraries/SignedSafeMath.sol';

/**
 * @title CoreV2
 * @notice Handles math operations of Wombat protocol. Assume all params are signed integer with 18 decimals
 * @dev Uses OpenZeppelin's SignedSafeMath and DSMath's WAD for calculations.
 */
contract CoreV2 {
    using DSMath for uint256;
    using SignedSafeMath for int256;
    int256 public constant WAD_I = 10**18;
    uint256 public constant WAD = 10**18;

    error CORE_UNDERFLOW();

    /**
     * @notice Core Wombat stableswap equation
     * @dev This function always returns >= 0
     * @param Ax asset of token x
     * @param Ay asset of token y
     * @param Lx liability of token x
     * @param Ly liability of token y
     * @param Dx delta x, i.e. token x amount inputted
     * @param A amplification factor
     * @return quote The quote for amount of token y swapped for token x amount inputted
     */
    function _swapQuoteFunc(
        int256 Ax,
        int256 Ay,
        int256 Lx,
        int256 Ly,
        int256 Dx,
        int256 A
    ) internal pure returns (uint256 quote) {
        int256 D = _invariantFunc(Lx, Ax.wdiv(Lx), Ly, Ay.wdiv(Ly), A);
        int256 rx_ = (Ax + Dx).wdiv(Lx);
        int256 b = _coefficientFunc(Lx, Ly, rx_, D, A);
        int256 ry_ = _solveQuad(b, A);
        int256 Dy = Ly.wmul(ry_) - Ay;
        if (Dy < 0) {
            quote = uint256(-Dy);
        } else {
            quote = uint256(Dy);
        }
    }

    /**
     * @notice Solve quadratic equation
     * @dev This function always returns >= 0
     * @param b quadratic equation b coefficient
     * @param c quadratic equation c coefficient
     * @return x
     */
    function _solveQuad(int256 b, int256 c) internal pure returns (int256) {
        int256 sqrtResult = ((b * b) + (c * 4 * WAD_I)).sqrt();
        return (sqrtResult - b) / 2;
    }

    /**
     * @notice Equation to get invariant constant between token x and token y
     * @dev This function always returns >= 0
     * @param Lx liability of token x
     * @param rx cov ratio of token x
     * @param Ly liability of token x
     * @param ry cov ratio of token y
     * @param A amplification factor
     * @return The invariant constant between token x and token y ("D")
     */
    function _invariantFunc(
        int256 Lx,
        int256 rx,
        int256 Ly,
        int256 ry,
        int256 A
    ) internal pure returns (int256) {
        int256 a = Lx.wmul(rx) + Ly.wmul(ry);
        int256 b = A.wmul(Lx.wdiv(rx) + Ly.wdiv(ry));
        return a - b;
    }

    /**
     * @notice Equation to get quadratic equation b coefficient
     * @dev This function can return >= 0 or <= 0
     * @param Lx liability of token x
     * @param Ly liability of token y
     * @param rx_ new asset coverage ratio of token x
     * @param D invariant constant
     * @param A amplification factor
     * @return The quadratic equation b coefficient ("b")
     */
    function _coefficientFunc(
        int256 Lx,
        int256 Ly,
        int256 rx_,
        int256 D,
        int256 A
    ) internal pure returns (int256) {
        return Lx.wmul(rx_ - A.wdiv(rx_)).wdiv(Ly) - D.wdiv(Ly);
    }

    /**
     * @return v positive value indicates a reward and negative value indicates a fee
     */
    function depositRewardImpl(
        int256 D,
        int256 SL,
        int256 delta_i,
        int256 A_i,
        int256 L_i,
        int256 A
    ) internal pure returns (int256 v) {
        if (L_i == 0) {
            // early return in case of div of 0
            return 0;
        }
        if (delta_i + SL == 0) {
            return L_i - A_i;
        }

        int256 r_i_ = _targetedCovRatio(SL, delta_i, A_i, L_i, D, A);
        v = A_i + delta_i - (L_i + delta_i).wmul(r_i_);
    }

    /**
     * @dev should be used only when r* = 1
     * @return v positive value indicates a reward and negative value indicates a fee
     */
    function depositRewardInEquilImpl(
        int256 delta_i,
        int256 A_i,
        int256 L_i,
        int256 A
    ) internal pure returns (int256 v) {
        if (L_i == 0) {
            // early return in case of div of 0
            return 0;
        }

        int256 L_i_ = L_i + delta_i;
        int256 r_i = A_i.wdiv(L_i);
        int256 rho = L_i.wmul(r_i - A.wdiv(r_i));
        int256 beta = (rho + delta_i.wmul(WAD_I - A)) / 2;
        int256 A_i_ = beta + (beta * beta + A.wmul(L_i_ * L_i_)).sqrt();
        v = delta_i + A_i - A_i_;
    }

    /**
     * @notice return the deposit reward in token amount when target liquidity (LP amount) is known
     */
    function exactDepositRewardInEquilImpl(
        int256 D_i,
        int256 A_i,
        int256 L_i,
        int256 A
    ) internal pure returns (int256 v) {
        if (L_i == 0) {
            // if this is a deposit, there is no reward/fee
            // if this is a withdrawal, it should have been reverted
            return 0;
        }
        if (A_i + D_i < 0) {
            // impossible
            revert CORE_UNDERFLOW();
        }

        int256 r_i = A_i.wdiv(L_i);
        int256 k = D_i + A_i;
        int256 b = k.wmul(WAD_I - A) + 2 * A.wmul(L_i);
        int256 c = k.wmul(A_i - (A * L_i) / r_i) - k.wmul(k) + A.wmul(L_i).wmul(L_i);
        int256 l = b * b - 4 * A * c;
        return (-b + (l).sqrt()).wdiv(A) / 2 - D_i;
    }

    function _targetedCovRatio(
        int256 SL,
        int256 delta_i,
        int256 A_i,
        int256 L_i,
        int256 D,
        int256 A
    ) internal pure returns (int256 r_i_) {
        int256 r_i = A_i.wdiv(L_i);
        int256 er = _equilCovRatio(D, SL, A);
        int256 er_ = _newEquilCovRatio(er, SL, delta_i);
        int256 D_ = _newInvariantFunc(er_, A, SL, delta_i);

        // Summation of k∈T\{i} is D - L_i.wmul(r_i - A.wdiv(r_i))
        int256 b_ = (D - A_i + (L_i * A) / r_i - D_).wdiv(L_i + delta_i);
        r_i_ = _solveQuad(b_, A);
    }

    function _equilCovRatio(
        int256 D,
        int256 SL,
        int256 A
    ) internal pure returns (int256 er) {
        int256 b = -(D.wdiv(SL));
        er = _solveQuad(b, A);
    }

    function _newEquilCovRatio(
        int256 er,
        int256 SL,
        int256 delta_i
    ) internal pure returns (int256 er_) {
        er_ = (delta_i + SL.wmul(er)).wdiv(delta_i + SL);
    }

    function _newInvariantFunc(
        int256 er_,
        int256 A,
        int256 SL,
        int256 delta_i
    ) internal pure returns (int256 D_) {
        D_ = (SL + delta_i).wmul(er_ - A.wdiv(er_));
    }

    /**
     * @notice TODO (if any) from Yellow Paper (Haircut).
     * @dev Applies haircut rate to amount
     * @param amount The amount that will receive the discount
     * @param rate The rate to be applied
     * @return The result of operation.
     */
    function _haircut(uint256 amount, uint256 rate) internal pure returns (uint256) {
        return amount.wmul(rate);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.5;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

interface IAsset is IERC20 {
    function underlyingToken() external view returns (address);

    function pool() external view returns (address);

    function cash() external view returns (uint128);

    function liability() external view returns (uint128);

    function decimals() external view returns (uint8);

    function underlyingTokenDecimals() external view virtual returns (uint8);

    function setPool(address pool_) external;

    function underlyingTokenBalance() external view returns (uint256);

    function transferUnderlyingToken(address to, uint256 amount) external;

    function mint(address to, uint256 amount) external;

    function burn(address to, uint256 amount) external;

    function addCash(uint256 amount) external;

    function removeCash(uint256 amount) external;

    function addLiability(uint256 amount) external;

    function removeLiability(uint256 amount) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.5;

/**
 * @title PausableAssets
 * @notice Handles assets pause and unpause of Wombat protocol.
 * @dev Allows pausing and unpausing of deposit and swap operations
 */
contract PausableAssets {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event PausedAsset(address asset, address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event UnpausedAsset(address asset, address account);

    mapping(address => bool) private _pausedAssets;

    error WOMBAT_ASSET_ALREADY_PAUSED();
    error WOMBAT_ASSET_NOT_PAUSED();

    /**
     * @dev Function to make a function callable only when the asset is not paused.
     *
     * Requirements:
     *
     * - The asset must not be paused.
     */
    function requireAssetNotPaused(address asset) internal {
        if (_pausedAssets[asset]) revert WOMBAT_ASSET_ALREADY_PAUSED();
    }

    /**
     * @dev Function to make a function callable only when the asset is paused.
     *
     * Requirements:
     *
     * - The asset must be paused.
     */
    function requireAssetPaused(address asset) internal {
        if (!_pausedAssets[asset]) revert WOMBAT_ASSET_NOT_PAUSED();
    }

    /**
     * @dev Triggers paused state.
     *
     * Requirements:
     *
     * - The asset must not be paused.
     */
    function _pauseAsset(address asset) internal {
        requireAssetNotPaused(asset);
        _pausedAssets[asset] = true;
        emit PausedAsset(asset, msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The asset must be paused.
     */
    function _unpauseAsset(address asset) internal {
        requireAssetPaused(asset);
        _pausedAssets[asset] = false;
        emit UnpausedAsset(asset, msg.sender);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/*
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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
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
    function __ERC1967Upgrade_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal initializer {
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
        return _verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// SPDX-License-Identifier: GPL-3.0

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity 0.8.5;

library DSMath {
    uint256 public constant WAD = 10**18;

    // Babylonian Method
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    //rounds to zero if x*y < WAD / 2
    function wmul(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((x * y) + (WAD / 2)) / WAD;
    }

    //rounds to zero if x*y < WAD / 2
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((x * WAD) + (y / 2)) / y;
    }

    // Convert x to WAD (18 decimals) from d decimals.
    function toWad(uint256 x, uint8 d) internal pure returns (uint256) {
        if (d < 18) {
            return x * 10**(18 - d);
        } else if (d > 18) {
            return (x / (10**(d - 18)));
        }
        return x;
    }

    // Convert x from WAD (18 decimals) to d decimals.
    function fromWad(uint256 x, uint8 d) internal pure returns (uint256) {
        if (d < 18) {
            return (x / (10**(18 - d)));
        } else if (d > 18) {
            return x * 10**(d - 18);
        }
        return x;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (utils/math/SignedSafeMath.sol)

pragma solidity 0.8.5;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SignedSafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SignedSafeMath {
    int256 public constant WAD = 10**18;

    //rounds to zero if x*y < WAD / 2
    function wdiv(int256 x, int256 y) internal pure returns (int256) {
        return ((x * WAD) + (y / 2)) / y;
    }

    //rounds to zero if x*y < WAD / 2
    function wmul(int256 x, int256 y) internal pure returns (int256) {
        return ((x * y) + (WAD / 2)) / WAD;
    }

    // Babylonian Method (typecast as int)
    function sqrt(int256 y) internal pure returns (int256 z) {
        if (y > 3) {
            z = y;
            int256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    // Convert x to WAD (18 decimals) from d decimals.
    function toWad(int256 x, uint8 d) internal pure returns (int256) {
        if (d < 18) {
            return x * int256(10**(18 - d));
        } else if (d > 18) {
            return (x / int256(10**(d - 18)));
        }
        return x;
    }

    // Convert x from WAD (18 decimals) to d decimals.
    function fromWad(int256 x, uint8 d) internal pure returns (int256) {
        if (d < 18) {
            return (x / int256(10**(18 - d)));
        } else if (d > 18) {
            return x * int256(10**(d - 18));
        }
        return x;
    }
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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