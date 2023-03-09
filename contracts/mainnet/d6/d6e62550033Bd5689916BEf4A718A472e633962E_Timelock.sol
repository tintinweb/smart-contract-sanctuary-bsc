// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./interfaces/ITimelockTarget.sol";
import "./interfaces/ITimelock.sol";
import "./interfaces/IHandlerTarget.sol";
import "../access/interfaces/IAdmin.sol";
import "../core/interfaces/IVault.sol";
import "../core/interfaces/IVaultUtils.sol";
import "../core/interfaces/IJlpManager.sol";
import "../referrals/interfaces/IReferralStorage.sol";
import "../tokens/interfaces/IMintable.sol";
import "../tokens/interfaces/IUSDJ.sol";

import "../libraries/math/SafeMath.sol";
import "../libraries/token/IERC20.sol";
import "../libraries/token/SafeERC20.sol";

contract Timelock is ITimelock {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant PRICE_PRECISION = 10**30;
    uint256 public constant MAX_BUFFER = 5 days;
    uint256 public constant MAX_FUNDING_RATE_FACTOR = 200; // 0.02%
    uint256 public constant MAX_LEVERAGE_VALIDATION = 200000; // 20x

    uint256 public buffer;
    address public admin;
    address public distributor;

    address public immutable jlpManager;

    uint256 public marginFeeBasisPoints;
    uint256 public maxMarginFeeBasisPoints;
    bool public shouldToggleIsLeverageEnabled;

    mapping(bytes32 => uint256) public pendingActions;

    mapping(address => bool) public isHandler;
    mapping(address => bool) public isKeeper;

    event SignalSetAdmin(address admin, bytes32 action);
    event SignalPendingAction(bytes32 action);
    event SignalApprove(
        address token,
        address spender,
        uint256 amount,
        bytes32 action
    );
    event SignalWithdrawToken(
        address target,
        address token,
        address receiver,
        uint256 amount,
        bytes32 action
    );
    event SignalMint(
        address token,
        address receiver,
        uint256 amount,
        bytes32 action
    );
    event SignalSetGov(address target, address gov, bytes32 action);
    event SignalSetHandler(
        address target,
        address handler,
        bool isActive,
        bytes32 action
    );
    event SignalSetPriceFeed(address vault, address priceFeed, bytes32 action);
    event SignalRedeemUsdj(address vault, address token, uint256 amount);
    event SignalVaultSetTokenConfig(
        address vault,
        address token,
        uint256 tokenDecimals,
        uint256 tokenWeight,
        uint256 minProfitBps,
        uint256 maxUsdjAmount,
        bool isStable,
        bool isShortable
    );
    event ClearAction(bytes32 action);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Timelock: forbidden");
        _;
    }

    modifier onlyAdminAndDistributor() {
        require(
            msg.sender == admin || msg.sender == distributor,
            "Timelock: forbidden"
        );
        _;
    }

    modifier onlyHandlerAndAbove() {
        require(
            msg.sender == admin || isHandler[msg.sender],
            "Timelock: forbidden"
        );
        _;
    }

    modifier onlyKeeperAndAbove() {
        require(
            msg.sender == admin ||
                isHandler[msg.sender] ||
                isKeeper[msg.sender],
            "Timelock: forbidden"
        );
        _;
    }

    constructor(
        address _admin,
        uint256 _buffer,
        address _jlpManager,
        uint256 _marginFeeBasisPoints,
        uint256 _maxMarginFeeBasisPoints
    ) public {
        require(_buffer <= MAX_BUFFER, "Timelock: invalid _buffer");
        admin = _admin;
        buffer = _buffer;
        jlpManager = _jlpManager;

        marginFeeBasisPoints = _marginFeeBasisPoints;
        maxMarginFeeBasisPoints = _maxMarginFeeBasisPoints;
        shouldToggleIsLeverageEnabled = true;
    }

    function signalSetAdmin(address _admin) external override onlyAdmin {
        require(_admin != address(0));
        bytes32 action = keccak256(abi.encodePacked("setAdmin", _admin));
        _setPendingAction(action);
        emit SignalSetAdmin(_admin, action);
    }

    function setAdmin(address _admin) external override onlyAdmin {
        bytes32 action = keccak256(abi.encodePacked("setAdmin", _admin));
        _validateAction(action);
        _clearAction(action);
        admin = _admin;
    }

    function setExternalAdmin(address _target, address _admin)
        external
        onlyAdmin
    {
        require(_target != address(this), "Timelock: invalid _target");
        IAdmin(_target).setAdmin(_admin);
    }

    function setDistributor(address _distributor) external onlyAdmin {
        require(_distributor != address(0), "Timelock: invalid _distributor");
        distributor = _distributor;
    }

    function setContractHandler(address _handler, bool _isActive)
        external
        onlyAdmin
    {
        isHandler[_handler] = _isActive;
    }

    function setKeeper(address _keeper, bool _isActive) external onlyAdmin {
        isKeeper[_keeper] = _isActive;
    }

    function setBuffer(uint256 _buffer) external onlyAdmin {
        require(_buffer <= MAX_BUFFER, "Timelock: invalid _buffer");
        require(_buffer > buffer, "Timelock: buffer cannot be decreased");
        buffer = _buffer;
    }

    function setMaxLeverage(address _vault, uint256 _maxLeverage)
        external
        onlyAdmin
    {
        require(
            _maxLeverage > MAX_LEVERAGE_VALIDATION,
            "Timelock: invalid _maxLeverage"
        );
        IVault(_vault).setMaxLeverage(_maxLeverage);
    }

    function setFundingRate(
        address _vault,
        uint256 _fundingInterval,
        uint256 _fundingRateFactor,
        uint256 _stableFundingRateFactor
    ) external onlyKeeperAndAbove {
        require(
            _fundingRateFactor < MAX_FUNDING_RATE_FACTOR,
            "Timelock: invalid _fundingRateFactor"
        );
        require(
            _stableFundingRateFactor < MAX_FUNDING_RATE_FACTOR,
            "Timelock: invalid _stableFundingRateFactor"
        );
        IVault(_vault).setFundingRate(
            _fundingInterval,
            _fundingRateFactor,
            _stableFundingRateFactor
        );
    }

    function setShouldToggleIsLeverageEnabled(
        bool _shouldToggleIsLeverageEnabled
    ) external onlyHandlerAndAbove {
        shouldToggleIsLeverageEnabled = _shouldToggleIsLeverageEnabled;
    }

    function setMarginFeeBasisPoints(
        uint256 _marginFeeBasisPoints,
        uint256 _maxMarginFeeBasisPoints
    ) external onlyHandlerAndAbove {
        marginFeeBasisPoints = _marginFeeBasisPoints;
        maxMarginFeeBasisPoints = _maxMarginFeeBasisPoints;
    }

    function setSwapFees(
        address _vault,
        uint256 _taxBasisPoints,
        uint256 _stableTaxBasisPoints,
        uint256 _mintBurnFeeBasisPoints,
        uint256 _swapFeeBasisPoints,
        uint256 _stableSwapFeeBasisPoints
    ) external onlyKeeperAndAbove {
        IVault vault = IVault(_vault);

        vault.setFees(
            _taxBasisPoints,
            _stableTaxBasisPoints,
            _mintBurnFeeBasisPoints,
            _swapFeeBasisPoints,
            _stableSwapFeeBasisPoints,
            maxMarginFeeBasisPoints,
            vault.liquidationFeeUsd(),
            vault.minProfitTime(),
            vault.hasDynamicFees()
        );
    }

    // assign _marginFeeBasisPoints to this.marginFeeBasisPoints
    // because enableLeverage would update Vault.marginFeeBasisPoints to this.marginFeeBasisPoints
    // and disableLeverage would reset the Vault.marginFeeBasisPoints to this.maxMarginFeeBasisPoints
    function setFees(
        address _vault,
        uint256 _taxBasisPoints,
        uint256 _stableTaxBasisPoints,
        uint256 _mintBurnFeeBasisPoints,
        uint256 _swapFeeBasisPoints,
        uint256 _stableSwapFeeBasisPoints,
        uint256 _marginFeeBasisPoints,
        uint256 _liquidationFeeUsd,
        uint256 _minProfitTime,
        bool _hasDynamicFees
    ) external onlyKeeperAndAbove {
        marginFeeBasisPoints = _marginFeeBasisPoints;

        IVault(_vault).setFees(
            _taxBasisPoints,
            _stableTaxBasisPoints,
            _mintBurnFeeBasisPoints,
            _swapFeeBasisPoints,
            _stableSwapFeeBasisPoints,
            maxMarginFeeBasisPoints,
            _liquidationFeeUsd,
            _minProfitTime,
            _hasDynamicFees
        );
    }

    function enableLeverage(address _vault)
        external
        override
        onlyHandlerAndAbove
    {
        IVault vault = IVault(_vault);

        if (shouldToggleIsLeverageEnabled) {
            vault.setIsLeverageEnabled(true);
        }

        vault.setFees(
            vault.taxBasisPoints(),
            vault.stableTaxBasisPoints(),
            vault.mintBurnFeeBasisPoints(),
            vault.swapFeeBasisPoints(),
            vault.stableSwapFeeBasisPoints(),
            marginFeeBasisPoints,
            vault.liquidationFeeUsd(),
            vault.minProfitTime(),
            vault.hasDynamicFees()
        );
    }

    function disableLeverage(address _vault)
        external
        override
        onlyHandlerAndAbove
    {
        IVault vault = IVault(_vault);

        if (shouldToggleIsLeverageEnabled) {
            vault.setIsLeverageEnabled(false);
        }

        vault.setFees(
            vault.taxBasisPoints(),
            vault.stableTaxBasisPoints(),
            vault.mintBurnFeeBasisPoints(),
            vault.swapFeeBasisPoints(),
            vault.stableSwapFeeBasisPoints(),
            maxMarginFeeBasisPoints, // marginFeeBasisPoints
            vault.liquidationFeeUsd(),
            vault.minProfitTime(),
            vault.hasDynamicFees()
        );
    }

    function setIsLeverageEnabled(address _vault, bool _isLeverageEnabled)
        external
        override
        onlyHandlerAndAbove
    {
        IVault(_vault).setIsLeverageEnabled(_isLeverageEnabled);
    }

    function setBufferAmount(
        address _vault,
        address _token,
        uint256 _bufferAmount
    ) external override onlyHandlerAndAbove {
        IVault(_vault).setBufferAmount(_token, _bufferAmount);
    }

    function setTokenConfig(
        address _vault,
        address _token,
        uint256 _tokenWeight,
        uint256 _minProfitBps,
        uint256 _maxUsdjAmount,
        uint256 _bufferAmount,
        uint256 _usdjAmount
    ) external onlyKeeperAndAbove {
        require(_minProfitBps <= 500, "Timelock: invalid _minProfitBps");

        IVault vault = IVault(_vault);
        require(
            vault.whitelistedTokens(_token),
            "Timelock: token not yet whitelisted"
        );

        uint256 tokenDecimals = vault.tokenDecimals(_token);
        bool isStable = vault.stableTokens(_token);
        bool isShortable = vault.shortableTokens(_token);

        IVault(_vault).setTokenConfig(
            _token,
            tokenDecimals,
            _tokenWeight,
            _minProfitBps,
            _maxUsdjAmount,
            isStable,
            isShortable
        );

        IVault(_vault).setBufferAmount(_token, _bufferAmount);

        IVault(_vault).setUsdjAmount(_token, _usdjAmount);
    }

    function setUsdjAmounts(
        address _vault,
        address[] memory _tokens,
        uint256[] memory _usdjAmounts
    ) external onlyKeeperAndAbove {
        for (uint256 i = 0; i < _tokens.length; i++) {
            IVault(_vault).setUsdjAmount(_tokens[i], _usdjAmounts[i]);
        }
    }

    function updateUsdjSupply(uint256 usdjAmount) external onlyKeeperAndAbove {
        address usdj = IJlpManager(jlpManager).usdj();
        uint256 balance = IERC20(usdj).balanceOf(jlpManager);

        IUSDJ(usdj).addVault(address(this));

        if (usdjAmount > balance) {
            uint256 mintAmount = usdjAmount.sub(balance);
            IUSDJ(usdj).mint(jlpManager, mintAmount);
        } else {
            uint256 burnAmount = balance.sub(usdjAmount);
            IUSDJ(usdj).burn(jlpManager, burnAmount);
        }

        IUSDJ(usdj).removeVault(address(this));
    }

    function setShortsTrackerAveragePriceWeight(
        uint256 _shortsTrackerAveragePriceWeight
    ) external onlyAdmin {
        IJlpManager(jlpManager).setShortsTrackerAveragePriceWeight(
            _shortsTrackerAveragePriceWeight
        );
    }

    function setJlpCooldownDuration(uint256 _cooldownDuration)
        external
        onlyAdmin
    {
        IJlpManager(jlpManager).setCooldownDuration(_cooldownDuration);
    }

    function setMaxGlobalShortSize(
        address _vault,
        address _token,
        uint256 _amount
    ) external onlyAdmin {
        IVault(_vault).setMaxGlobalShortSize(_token, _amount);
    }

    function setIsSwapEnabled(address _vault, bool _isSwapEnabled)
        external
        onlyKeeperAndAbove
    {
        IVault(_vault).setIsSwapEnabled(_isSwapEnabled);
    }

    function setTier(
        address _referralStorage,
        uint256 _tierId,
        uint256 _totalRebate,
        uint256 _discountShare
    ) external onlyKeeperAndAbove {
        IReferralStorage(_referralStorage).setTier(
            _tierId,
            _totalRebate,
            _discountShare
        );
    }

    function setReferrerTier(
        address _referralStorage,
        address _referrer,
        uint256 _tierId
    ) external onlyKeeperAndAbove {
        IReferralStorage(_referralStorage).setReferrerTier(_referrer, _tierId);
    }

    function govSetCodeOwner(
        address _referralStorage,
        bytes32 _code,
        address _newAccount
    ) external onlyKeeperAndAbove {
        IReferralStorage(_referralStorage).govSetCodeOwner(_code, _newAccount);
    }

    function setMinReward(address _referralStorage, uint256 _min)
        external
        onlyAdmin
    {
        IReferralStorage(_referralStorage).setMinReward(_min);
    }

    function setMarginFee(address _referralStorage, uint256 _fee)
        external
        onlyAdmin
    {
        IReferralStorage(_referralStorage).setMarginFee(_fee);
    }

    function setTokenReward(address _referralStorage, address _token)
        external
        onlyAdmin
    {
        IReferralStorage(_referralStorage).setTokenReward(_token);
    }

    function withdrawnToken(
        address _referralStorage,
        address _token,
        address _to,
        uint256 _amount
    ) external onlyAdmin {
        IReferralStorage(_referralStorage).withdrawnToken(_token, _to, _amount);
    }

    function removeRebate(address _referralStorage, address _user)
        external
        onlyAdmin
    {
        IReferralStorage(_referralStorage).removeRebate(_user);
    }

    function setVaultUtils(address _vault, IVaultUtils _vaultUtils)
        external
        onlyAdmin
    {
        IVault(_vault).setVaultUtils(_vaultUtils);
    }

    function setMaxGasPrice(address _vault, uint256 _maxGasPrice)
        external
        onlyAdmin
    {
        require(_maxGasPrice > 5000000000, "Invalid _maxGasPrice");
        IVault(_vault).setMaxGasPrice(_maxGasPrice);
    }

    function withdrawFees(
        address _vault,
        address _token,
        address _receiver
    ) external override onlyAdminAndDistributor {
        IVault(_vault).withdrawFees(_token, _receiver);
    }

    function batchWithdrawFees(address _vault, address[] memory _tokens)
        external
        onlyAdminAndDistributor
    {
        for (uint256 i = 0; i < _tokens.length; i++) {
            IVault(_vault).withdrawFees(_tokens[i], admin);
        }
    }

    function setInPrivateLiquidationMode(
        address _vault,
        bool _inPrivateLiquidationMode
    ) external onlyAdmin {
        IVault(_vault).setInPrivateLiquidationMode(_inPrivateLiquidationMode);
    }

    function setLiquidator(
        address _vault,
        address _liquidator,
        bool _isActive
    ) external onlyAdmin {
        IVault(_vault).setLiquidator(_liquidator, _isActive);
    }

    function transferIn(
        address _sender,
        address _token,
        uint256 _amount
    ) external onlyAdmin {
        IERC20(_token).safeTransferFrom(_sender, address(this), _amount);
    }

    function signalApprove(
        address _token,
        address _spender,
        uint256 _amount
    ) external onlyAdmin {
        bytes32 action = keccak256(
            abi.encodePacked("approve", _token, _spender, _amount)
        );
        _setPendingAction(action);
        emit SignalApprove(_token, _spender, _amount, action);
    }

    function approve(
        address _token,
        address _spender,
        uint256 _amount
    ) external onlyAdmin {
        bytes32 action = keccak256(
            abi.encodePacked("approve", _token, _spender, _amount)
        );
        _validateAction(action);
        _clearAction(action);
        IERC20(_token).approve(_spender, _amount);
    }

    function signalMint(
        address _token,
        address _receiver,
        uint256 _amount
    ) external onlyAdmin {
        bytes32 action = keccak256(
            abi.encodePacked("mint", _token, _receiver, _amount)
        );
        _setPendingAction(action);
        emit SignalMint(_token, _receiver, _amount, action);
    }

    function signalSetGov(address _target, address _gov)
        external
        override
        onlyAdmin
    {
        bytes32 action = keccak256(abi.encodePacked("setGov", _target, _gov));
        _setPendingAction(action);
        emit SignalSetGov(_target, _gov, action);
    }

    function setGov(address _target, address _gov) external onlyAdmin {
        bytes32 action = keccak256(abi.encodePacked("setGov", _target, _gov));
        _validateAction(action);
        _clearAction(action);
        ITimelockTarget(_target).setGov(_gov);
    }

    function signalSetHandler(
        address _target,
        address _handler,
        bool _isActive
    ) external onlyAdmin {
        bytes32 action = keccak256(
            abi.encodePacked("setHandler", _target, _handler, _isActive)
        );
        _setPendingAction(action);
        emit SignalSetHandler(_target, _handler, _isActive, action);
    }

    function setHandler(
        address _target,
        address _handler,
        bool _isActive
    ) external onlyAdmin {
        bytes32 action = keccak256(
            abi.encodePacked("setHandler", _target, _handler, _isActive)
        );
        _validateAction(action);
        _clearAction(action);
        IHandlerTarget(_target).setHandler(_handler, _isActive);
    }

    function signalSetPriceFeed(address _vault, address _priceFeed)
        external
        onlyAdmin
    {
        bytes32 action = keccak256(
            abi.encodePacked("setPriceFeed", _vault, _priceFeed)
        );
        _setPendingAction(action);
        emit SignalSetPriceFeed(_vault, _priceFeed, action);
    }

    function setPriceFeed(address _vault, address _priceFeed)
        external
        onlyAdmin
    {
        bytes32 action = keccak256(
            abi.encodePacked("setPriceFeed", _vault, _priceFeed)
        );
        _validateAction(action);
        _clearAction(action);
        IVault(_vault).setPriceFeed(_priceFeed);
    }

    function signalRedeemUsdj(
        address _vault,
        address _token,
        uint256 _amount
    ) external onlyAdmin {
        bytes32 action = keccak256(
            abi.encodePacked("redeemUsdj", _vault, _token, _amount)
        );
        _setPendingAction(action);
        emit SignalRedeemUsdj(_vault, _token, _amount);
    }

    function redeemUsdj(
        address _vault,
        address _token,
        uint256 _amount
    ) external onlyAdmin {
        bytes32 action = keccak256(
            abi.encodePacked("redeemUsdj", _vault, _token, _amount)
        );
        _validateAction(action);
        _clearAction(action);

        address usdj = IVault(_vault).usdj();
        IVault(_vault).setManager(address(this), true);
        IUSDJ(usdj).addVault(address(this));

        IUSDJ(usdj).mint(address(this), _amount);
        IERC20(usdj).safeTransfer(address(_vault), _amount);

        IVault(_vault).sellUSDJ(_token, admin);

        IVault(_vault).setManager(address(this), false);
        IUSDJ(usdj).removeVault(address(this));
    }

    function signalVaultSetTokenConfig(
        address _vault,
        address _token,
        uint256 _tokenDecimals,
        uint256 _tokenWeight,
        uint256 _minProfitBps,
        uint256 _maxUsdjAmount,
        bool _isStable,
        bool _isShortable
    ) external onlyAdmin {
        bytes32 action = keccak256(
            abi.encodePacked(
                "vaultSetTokenConfig",
                _vault,
                _token,
                _tokenDecimals,
                _tokenWeight,
                _minProfitBps,
                _maxUsdjAmount,
                _isStable,
                _isShortable
            )
        );

        _setPendingAction(action);

        emit SignalVaultSetTokenConfig(
            _vault,
            _token,
            _tokenDecimals,
            _tokenWeight,
            _minProfitBps,
            _maxUsdjAmount,
            _isStable,
            _isShortable
        );
    }

    function vaultSetTokenConfig(
        address _vault,
        address _token,
        uint256 _tokenDecimals,
        uint256 _tokenWeight,
        uint256 _minProfitBps,
        uint256 _maxUsdjAmount,
        bool _isStable,
        bool _isShortable
    ) external onlyAdmin {
        bytes32 action = keccak256(
            abi.encodePacked(
                "vaultSetTokenConfig",
                _vault,
                _token,
                _tokenDecimals,
                _tokenWeight,
                _minProfitBps,
                _maxUsdjAmount,
                _isStable,
                _isShortable
            )
        );

        _validateAction(action);
        _clearAction(action);

        IVault(_vault).setTokenConfig(
            _token,
            _tokenDecimals,
            _tokenWeight,
            _minProfitBps,
            _maxUsdjAmount,
            _isStable,
            _isShortable
        );
    }

    function cancelAction(bytes32 _action) external onlyAdmin {
        _clearAction(_action);
    }

    function _setPendingAction(bytes32 _action) private {
        require(
            pendingActions[_action] == 0,
            "Timelock: action already signalled"
        );
        pendingActions[_action] = block.timestamp.add(buffer);
        emit SignalPendingAction(_action);
    }

    function _validateAction(bytes32 _action) private view {
        require(pendingActions[_action] != 0, "Timelock: action not signalled");
        require(
            pendingActions[_action] < block.timestamp,
            "Timelock: action time not yet passed"
        );
    }

    function _clearAction(bytes32 _action) private {
        require(pendingActions[_action] != 0, "Timelock: invalid _action");
        delete pendingActions[_action];
        emit ClearAction(_action);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface ITimelockTarget {
    function setGov(address _gov) external;
    function withdrawToken(address _token, address _account, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface ITimelock {
    function signalSetAdmin(address _admin) external;

    function setAdmin(address _admin) external;

    function enableLeverage(address _vault) external;

    function disableLeverage(address _vault) external;

    function setIsLeverageEnabled(address _vault, bool _isLeverageEnabled)
        external;

    function signalSetGov(address _target, address _gov) external;

    function setBufferAmount(
        address _vault,
        address _token,
        uint256 _bufferAmount
    ) external;

    function withdrawFees(
        address _vault,
        address _token,
        address _receiver
    ) external;
}

//SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IAdmin {
    function setAdmin(address _admin) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IMintable {
    function mint(address _account, uint256 _amount) external;
    function burn(address _account, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IHandlerTarget {
    function isHandler(address _account) external returns (bool);
    function setHandler(address _handler, bool _isActive) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IJlpManager {
    function usdj() external view returns (address);

    function cooldownDuration() external returns (uint256);

    function getAumInUsdj(bool maximise) external view returns (uint256);

    function lastAddedAt(address _account) external returns (uint256);

    function addLiquidity(
        address _token,
        uint256 _amount,
        uint256 _minUsdj,
        uint256 _minJlp
    ) external returns (uint256);

    function addLiquidityForAccount(
        address _fundingAccount,
        address _account,
        address _token,
        uint256 _amount,
        uint256 _minUsdj,
        uint256 _minJlp
    ) external returns (uint256);

    function removeLiquidity(
        address _tokenOut,
        uint256 _jlpAmount,
        uint256 _minOut,
        address _receiver
    ) external returns (uint256);

    function removeLiquidityForAccount(
        address _account,
        address _tokenOut,
        uint256 _jlpAmount,
        uint256 _minOut,
        address _receiver
    ) external returns (uint256);

    function setShortsTrackerAveragePriceWeight(
        uint256 _shortsTrackerAveragePriceWeight
    ) external;

    function setCooldownDuration(uint256 _cooldownDuration) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IVaultUtils {
    function updateCumulativeFundingRate(
        address _collateralToken,
        address _indexToken
    ) external returns (bool);

    function validateIncreasePosition(
        address _account,
        address _collateralToken,
        address _indexToken,
        uint256 _sizeDelta,
        bool _isLong
    ) external view;

    function validateDecreasePosition(
        address _account,
        address _collateralToken,
        address _indexToken,
        uint256 _collateralDelta,
        uint256 _sizeDelta,
        bool _isLong,
        address _receiver
    ) external view;

    function validateLiquidation(
        address _account,
        address _collateralToken,
        address _indexToken,
        bool _isLong,
        bool _raise
    ) external view returns (uint256, uint256);

    function getEntryFundingRate(
        address _collateralToken,
        address _indexToken,
        bool _isLong
    ) external view returns (uint256);

    function getPositionFee(
        address _account,
        address _collateralToken,
        address _indexToken,
        bool _isLong,
        uint256 _sizeDelta
    ) external view returns (uint256);

    function getFundingFee(
        address _account,
        address _collateralToken,
        address _indexToken,
        bool _isLong,
        uint256 _size,
        uint256 _entryFundingRate
    ) external view returns (uint256);

    function getBuyUsdjFeeBasisPoints(address _token, uint256 _usdjAmount)
        external
        view
        returns (uint256);

    function getSellUsdjFeeBasisPoints(address _token, uint256 _usdjAmount)
        external
        view
        returns (uint256);

    function getSwapFeeBasisPoints(
        address _tokenIn,
        address _tokenOut,
        uint256 _usdjAmount
    ) external view returns (uint256);

    function getFeeBasisPoints(
        address _token,
        uint256 _usdjDelta,
        uint256 _feeBasisPoints,
        uint256 _taxBasisPoints,
        bool _increment
    ) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./IVaultUtils.sol";

interface IVault {
    function isInitialized() external view returns (bool);

    function isSwapEnabled() external view returns (bool);

    function isLeverageEnabled() external view returns (bool);

    function setVaultUtils(IVaultUtils _vaultUtils) external;

    function setError(uint256 _errorCode, string calldata _error) external;

    function router() external view returns (address);

    function usdj() external view returns (address);

    function gov() external view returns (address);

    function whitelistedTokenCount() external view returns (uint256);

    function maxLeverage() external view returns (uint256);

    function minProfitTime() external view returns (uint256);

    function hasDynamicFees() external view returns (bool);

    function fundingInterval() external view returns (uint256);

    function totalTokenWeights() external view returns (uint256);

    function getTargetUsdjAmount(address _token)
        external
        view
        returns (uint256);

    function inManagerMode() external view returns (bool);

    function inPrivateLiquidationMode() external view returns (bool);

    function maxGasPrice() external view returns (uint256);

    function approvedRouters(address _account, address _router)
        external
        view
        returns (bool);

    function isLiquidator(address _account) external view returns (bool);

    function isManager(address _account) external view returns (bool);

    function minProfitBasisPoints(address _token)
        external
        view
        returns (uint256);

    function tokenBalances(address _token) external view returns (uint256);

    function lastFundingTimes(address _token) external view returns (uint256);

    function setMaxLeverage(uint256 _maxLeverage) external;

    function setInManagerMode(bool _inManagerMode) external;

    function setManager(address _manager, bool _isManager) external;

    function setIsSwapEnabled(bool _isSwapEnabled) external;

    function setIsLeverageEnabled(bool _isLeverageEnabled) external;

    function setMaxGasPrice(uint256 _maxGasPrice) external;

    function setUsdjAmount(address _token, uint256 _amount) external;

    function setBufferAmount(address _token, uint256 _amount) external;

    function setMaxGlobalShortSize(address _token, uint256 _amount) external;

    function setInPrivateLiquidationMode(bool _inPrivateLiquidationMode)
        external;

    function setLiquidator(address _liquidator, bool _isActive) external;

    function setFundingRate(
        uint256 _fundingInterval,
        uint256 _fundingRateFactor,
        uint256 _stableFundingRateFactor
    ) external;

    function setFees(
        uint256 _taxBasisPoints,
        uint256 _stableTaxBasisPoints,
        uint256 _mintBurnFeeBasisPoints,
        uint256 _swapFeeBasisPoints,
        uint256 _stableSwapFeeBasisPoints,
        uint256 _marginFeeBasisPoints,
        uint256 _liquidationFeeUsd,
        uint256 _minProfitTime,
        bool _hasDynamicFees
    ) external;

    function setTokenConfig(
        address _token,
        uint256 _tokenDecimals,
        uint256 _redemptionBps,
        uint256 _minProfitBps,
        uint256 _maxUsdjAmount,
        bool _isStable,
        bool _isShortable
    ) external;

    function setPriceFeed(address _priceFeed) external;

    function withdrawFees(address _token, address _receiver)
        external
        returns (uint256);

    function directPoolDeposit(address _token) external;

    function buyUSDJ(address _token, address _receiver)
        external
        returns (uint256);

    function sellUSDJ(address _token, address _receiver)
        external
        returns (uint256);

    function swap(
        address _tokenIn,
        address _tokenOut,
        address _receiver
    ) external returns (uint256);

    function increasePosition(
        address _account,
        address _collateralToken,
        address _indexToken,
        uint256 _sizeDelta,
        bool _isLong
    ) external;

    function decreasePosition(
        address _account,
        address _collateralToken,
        address _indexToken,
        uint256 _collateralDelta,
        uint256 _sizeDelta,
        bool _isLong,
        address _receiver
    ) external returns (uint256);

    function validateLiquidation(
        address _account,
        address _collateralToken,
        address _indexToken,
        bool _isLong,
        bool _raise
    ) external view returns (uint256, uint256);

    function liquidatePosition(
        address _account,
        address _collateralToken,
        address _indexToken,
        bool _isLong,
        address _feeReceiver
    ) external;

    function tokenToUsdMin(address _token, uint256 _tokenAmount)
        external
        view
        returns (uint256);

    function priceFeed() external view returns (address);

    function fundingRateFactor() external view returns (uint256);

    function stableFundingRateFactor() external view returns (uint256);

    function cumulativeFundingRates(address _token)
        external
        view
        returns (uint256);

    function getNextFundingRate(address _token) external view returns (uint256);

    function getFeeBasisPoints(
        address _token,
        uint256 _usdjDelta,
        uint256 _feeBasisPoints,
        uint256 _taxBasisPoints,
        bool _increment
    ) external view returns (uint256);

    function liquidationFeeUsd() external view returns (uint256);

    function taxBasisPoints() external view returns (uint256);

    function stableTaxBasisPoints() external view returns (uint256);

    function mintBurnFeeBasisPoints() external view returns (uint256);

    function swapFeeBasisPoints() external view returns (uint256);

    function stableSwapFeeBasisPoints() external view returns (uint256);

    function marginFeeBasisPoints() external view returns (uint256);

    function allWhitelistedTokensLength() external view returns (uint256);

    function allWhitelistedTokens(uint256) external view returns (address);

    function whitelistedTokens(address _token) external view returns (bool);

    function stableTokens(address _token) external view returns (bool);

    function shortableTokens(address _token) external view returns (bool);

    function feeReserves(address _token) external view returns (uint256);

    function globalShortSizes(address _token) external view returns (uint256);

    function globalShortAveragePrices(address _token)
        external
        view
        returns (uint256);

    function maxGlobalShortSizes(address _token)
        external
        view
        returns (uint256);

    function tokenDecimals(address _token) external view returns (uint256);

    function tokenWeights(address _token) external view returns (uint256);

    function guaranteedUsd(address _token) external view returns (uint256);

    function poolAmounts(address _token) external view returns (uint256);

    function bufferAmounts(address _token) external view returns (uint256);

    function reservedAmounts(address _token) external view returns (uint256);

    function usdjAmounts(address _token) external view returns (uint256);

    function maxUsdjAmounts(address _token) external view returns (uint256);

    function getRedemptionAmount(address _token, uint256 _usdjAmount)
        external
        view
        returns (uint256);

    function getMaxPrice(address _token) external view returns (uint256);

    function getMinPrice(address _token) external view returns (uint256);

    function getDelta(
        address _indexToken,
        uint256 _size,
        uint256 _averagePrice,
        bool _isLong,
        uint256 _lastIncreasedTime
    ) external view returns (bool, uint256);

    function getPosition(
        address _account,
        address _collateralToken,
        address _indexToken,
        bool _isLong
    )
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            uint256
        );
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IReferralStorage {
    function codeOwners(bytes32 _code) external view returns (address);

    function getTraderReferralInfo(address _account)
        external
        view
        returns (bytes32, address);

    function setTraderReferralCode(address _account, bytes32 _code) external;

    function setTier(
        uint256 _tierId,
        uint256 _totalRebate,
        uint256 _discountShare
    ) external;

    function setReferrerTier(address _referrer, uint256 _tierId) external;

    function govSetCodeOwner(bytes32 _code, address _newAccount) external;

    function setMinReward(uint256 _min) external;

    function setMarginFee(uint256 _fee) external;

    function setTokenReward(address _token) external;

    function withdrawnToken(address _token, address _to, uint256 _amount) external;

    function removeRebate(address _user) external;

    function addReward(address _account, uint256 _sizeDelta) external;

    function getTokenReward() external view returns (address);

    function depositPending() external view returns (uint256);

    function deposit(uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IUSDJ {
    function addVault(address _vault) external;
    function removeVault(address _vault) external;
    function mint(address _account, uint256 _amount) external;
    function burn(address _account, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./IERC20.sol";
import "../math/SafeMath.sol";
import "../utils/Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
}