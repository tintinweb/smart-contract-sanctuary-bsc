// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../../../common/Errors.sol";
import "../../../common/Ownable.sol";

import "../../interfaces/IProxyAdmin.sol";
import "../../interfaces/IDABot.sol";
import "../../interfaces/IDABotManager.sol";
import "../../interfaces/ILendingAdapter.sol";
import "../../interfaces/IDABotFarmingModule.sol";
import "../../interfaces/IBotWorker.sol";
import "../../interfaces/ILendingBotWorker.sol";
import "../../interfaces/IExchangeAdapter.sol";
import "../../../libs/atlantis/ExponentialNoError.sol";

pragma solidity ^0.8.0;

uint16 constant COLLATERAL_ASSETS = 1;
uint16 constant LEVERAGE_ASSET = 2;
uint16 constant LENDING_ADAPTER = 3;
uint16 constant EXCHANGE_ADAPTER = 4;
uint16 constant TARGET_HEALTH_FACTOR = 5;
uint16 constant PRECISION = 6;
uint16 constant ADD_COLLATERAL = 0x11;
uint16 constant REMOVE_COLLATERAL = 0x12;

uint constant ACTION_IDLE = 0;
uint constant ACTION_LEVERAGE_BORROW = 1;
uint constant ACTION_LEVERAGE_REPAY = 2;

library AdapterUtils {

    function fnCall(address adapter, bytes memory data) internal {
        (bool success, bytes memory result) = adapter.delegatecall(data);
        require(success, string(result));
    }
}


abstract contract AbstractBotWorker is Ownable, IBotWorker, ExponentialNoError {
    address constant BNB_ADDRESS = address(0x1E1e1E1E1e1e1e1e1e1E1E1E1E1e1e1E1e1e1E1E);
    bytes32 constant PROXY_ADMIN_SLOT = keccak256("proxy-admin.address");

    WorkerStatus internal _status;

    modifier onlyBotOrOperator() {
        address _owner = owner();
        require(_owner == msg.sender || IDABotFarmingModule(_owner).isOperator(msg.sender),
            Errors.CM_UNAUTHORIZED_CALLER);
        _;
    }

    modifier onlyBotOrCreator() {
        address _owner = owner();
        require(_owner == msg.sender || IDABot(_owner).owner() == msg.sender, Errors.CM_UNAUTHORIZED_CALLER);
        _;
    }
   
    function configureEx(uint16[] calldata pIds, bytes[] calldata values) external override {
        require(pIds.length == values.length, Errors.MLF_CONFIG_TOPICS_AND_VALUES_MISMATCHED);
        for(uint i = 0; i < pIds.length; i++) 
            __configure(pIds[i], values[i]);
    }

    function configure(uint16 pId, bytes calldata data) external override onlyOwner {
        __configure(pId, data);
    }

    function property(uint16 pId) external override view returns(bytes memory) {
        return _property(pId);
    }

    function __configure(uint16 pId, bytes calldata data) private {
        _configure(pId, data);
        emit Configure(pId, data);
    }

    function bot() public view returns(IDABot) {
        return IDABot(owner());
    }

    function configurator() public view returns(IConfigurator) {
        IDABotManager manager = IDABotManager(bot().metadata().botManager);
        return manager.configurator();
    }

    function _property(uint16 pId) internal virtual view returns(bytes memory);

    function _configure(uint16 pId, bytes calldata data) internal virtual;

    function _isNativeAsset(address asset) public pure returns(bool) {
        return asset == BNB_ADDRESS;
    }

    function status() external view override returns(WorkerStatus) {
        return _status;
    }

    function getImpl(address adapter) public view returns(address) {
        IProxyAdmin proxyAdmin = IProxyAdmin(configurator().addressOf(PROXY_ADMIN_SLOT));
        if (address(proxyAdmin) != address(0) && proxyAdmin.isAdminOf(adapter))
            return proxyAdmin.getProxyImplementation(adapter);
        return adapter;
    }

    /**
    @dev Allows owner to withdraw tokens that mistakenly tranfered to this contract.
        All token amount will be transfered to the contract owner.
     */
    function rescureToken(IERC20 asset, address receiver) external payable onlyOwner {
        if (address(asset) == address(0))
            payable(receiver).transfer(address(this).balance);
        else {
            asset.transfer(receiver, asset.balanceOf(address(this)));
        }
    }
}

contract MarginalLendingWorker is AbstractBotWorker, ILendingBotWorker { 

    uint constant DEFAULT_PRECISION = 2;

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    using AdapterUtils for address;

    EnumerableSet.AddressSet internal _collaterals;
    
    address internal _leverageToken;
    ILendingAdapter internal _adapter;
    IExchangeAdapter internal _exchange;

    mapping(IERC20 => uint) _deposits;

    uint internal _targetHealthFactor;
    uint internal _precision;

    modifier requireAdapter() {
        require(address(_adapter) != address(0), Errors.MLF_ADAPTER_IS_NOT_CONFIGURED);
        _;
    }

    modifier onlyCertToken(address platformToken) {
        address asset = _adapter.underlying(platformToken);
        require(IDABot(owner()).certificateOf(asset) == msg.sender, Errors.CM_UNAUTHORIZED_CALLER);
        _;
    }

    function revision() external pure returns(uint) {
        return 0x20220816;
    }

    function initialize() external override { 
        require(owner() == address(0), Errors.CM_CONTRACT_HAS_BEEN_INITIALIZED);
        _transferOwnership(msg.sender);
    }

    function properties() external override view returns(WorkerProperty[] memory props) {
        props = new WorkerProperty[](6);
        props[0] = WorkerProperty(COLLATERAL_ASSETS, 
                     WorkerPropertyDataType.ASSETS,  
                     'collateral_assets',
                     _property(COLLATERAL_ASSETS)); 

        props[1] = WorkerProperty(LEVERAGE_ASSET, 
                     WorkerPropertyDataType.ASSET,  
                     'leverage_asset',
                     _property(LEVERAGE_ASSET)); 

        props[2] = WorkerProperty(LENDING_ADAPTER, 
                     WorkerPropertyDataType.LENDING_PLATFORM,  
                     'lending_platform',
                     _property(LENDING_ADAPTER));

        props[3] = WorkerProperty(EXCHANGE_ADAPTER, 
                     WorkerPropertyDataType.EXCHANGE_PLATFORM,  
                     'swap',
                     _property(EXCHANGE_ADAPTER)); 

        props[4] = WorkerProperty(TARGET_HEALTH_FACTOR,
                     WorkerPropertyDataType.NUMBER,
                     'target_health_factor',
                     _property(TARGET_HEALTH_FACTOR));
        
        props[5] = WorkerProperty(PRECISION,
                     WorkerPropertyDataType.NUMBER,
                     'precision',
                     _property(PRECISION));
    }

    function accept(address asset) public view returns(bool) {
        if (_leverageToken == asset) return true;
        return _collaterals.contains(asset);
    }

    function _configure(uint16  pId, bytes calldata data) internal override  {
        if (pId == COLLATERAL_ASSETS) {
            address[] memory collaterals = abi.decode(data, (address[]));
            for (uint i = 0; i < collaterals.length; i++)
                _addCollateral(collaterals[i]);
        } else if (pId == LEVERAGE_ASSET) {
            _setLeverageAsset(abi.decode(data, (address)));
        } else if (pId == LENDING_ADAPTER) {
            require(address(_adapter) == address(0), Errors.MLF_CANNOT_CHANGE_LENDING_ADAPTER);
            _adapter = abi.decode(data, (ILendingAdapter));
        } else if (pId == EXCHANGE_ADAPTER) {
            _exchange = abi.decode(data, (IExchangeAdapter));
        } else if (pId == TARGET_HEALTH_FACTOR) {
            _setTargetHealthFactor(abi.decode(data, (uint)));
        } else if (pId == PRECISION) {
            _setPrecision(abi.decode(data, (uint)));
        } else if (pId == ADD_COLLATERAL) {
            _addCollateral(abi.decode(data, (address)));
        } else if (pId == REMOVE_COLLATERAL) {
            _removeCollateral(abi.decode(data, (address)));
        } else
            revert(Errors.MLF_UNKNOWN_CONFIG_TOPIC);
        
        emit Configure(pId, data);
    }

    function _property(uint16 pId) internal override view returns(bytes memory) {
        if (pId == COLLATERAL_ASSETS) 
            return abi.encode(_collaterals.values());
        if (pId == LEVERAGE_ASSET)
            return abi.encode(_leverageToken);
        if (pId == LENDING_ADAPTER)
            return abi.encode(_adapter);
        if (pId == EXCHANGE_ADAPTER)
            return abi.encode(_exchange);
        if (pId == TARGET_HEALTH_FACTOR)
            return abi.encode(_targetHealthFactor);
        if (pId == PRECISION)
            return abi.encode(_precision);

        revert(Errors.MLF_UNKNOWN_CONFIG_TOPIC);
    }

    function accountInfo() external view override  
        returns(uint initDeposit, uint totalReward, uint healthFactor) 
    {
        initDeposit = 0;
        (,,,healthFactor) = _adapter.accountInfo(address(this));
        totalReward = _adapter.rewardAccrued(address(this));
    }

    function lendingAccountInfo() public view requireAdapter
        returns(uint initDeposit, uint totalDeposit, uint collateral, uint borrow, uint reward, uint healthFactor)
    {
        (totalDeposit, collateral, borrow, healthFactor) = _adapter.accountInfo(address(this));

        AccountDetailInfo[] memory details = _adapter.accountDetailInfo(address(this));
        for (uint i = 0; i < details.length; i++) {
            AccountDetailInfo memory detail = details[i];
            uint oraclePriceMantissa = _adapter.priceUnderlying(detail.platformToken);
            Exp memory oraclePrice = Exp({mantissa: oraclePriceMantissa});
            initDeposit = mul_ScalarTruncateAddUInt(oraclePrice, _deposits[IERC20(detail.asset)], initDeposit);
        }
        reward = _adapter.rewardAccrued(address(this));
    }

    function collateralInfo() public view override requireAdapter returns(CollateralInfo[] memory result) {
        AccountDetailInfo[] memory details = _adapter.accountDetailInfo(address(this));
        result = new CollateralInfo[](details.length);
        
        for (uint i = 0; i < details.length; i++) {
            AccountDetailInfo memory detail = details[i];
            result[i] = CollateralInfo(
                detail.platformToken, 
                detail.asset,
                _deposits[IERC20(detail.asset)],
                detail.deposit,
                detail.borrow,
                detail.depositValue,
                detail.borrowValue,
                0
                );
        }
    }

    // should only call from CertToken
    function deposit(address platformToken, uint amount) external payable override requireAdapter onlyCertToken(platformToken) {
        // require(accept(platformToken), Errors.MLF_REGISTERED_COLLATERAL_ID_EXPECTED);
        if (amount == 0)
            return;
        _internalDeposit(platformToken, amount, true);
        emit Deposit(platformToken, _adapter.underlying(platformToken), msg.sender, amount);
    }

    // should only call from CertToken
    function withdraw(address platformToken, uint amount) external override requireAdapter onlyCertToken(platformToken) {
        if (amount == 0)
            return;
        address asset = _adapter.underlying(platformToken);
        address cToken = IDABot(owner()).certificateOf(asset);
        _internalWithdraw(platformToken, amount, cToken, false);
        emit Withdraw(platformToken, asset, cToken, amount);
    }

    function claimReward() external override onlyOwner {
        _adapter.harvestReward(address(this));
    }

    function harvestReward(bool platformBonus, HarvestReward[] calldata details) external override onlyBotOrCreator requireAdapter {
        uint bonusAccrued;
        if (platformBonus) {
            bonusAccrued = _adapter.rewardAccrued(address(this));
            _adapter.harvestReward(address(this));
            IERC20(_adapter.rewardTokens()[0]).safeTransfer(owner(), bonusAccrued);
        }
        
        HarvestedRewardDetail[] memory harvestedDetails = new HarvestedRewardDetail[](details.length);
        for (uint i = 0; i < details.length; i++) {
            IERC20 asset = IERC20(_adapter.underlying(details[i].platformToken));
            (uint depositToken, uint borrowToken) = _adapter.accountInfo(address(this), details[i].platformToken);
            uint currentDeposit = _adapter.amountUnderlying(details[i].platformToken, depositToken);
            uint currentBorrow = _adapter.amountUnderlying(details[i].platformToken, borrowToken);
            if (currentDeposit > _deposits[asset] + currentBorrow) {
                uint interest = currentDeposit - _deposits[asset] - currentBorrow;
                _internalWithdraw(details[i].platformToken, interest, owner(), true);
                harvestedDetails[i] = HarvestedRewardDetail(details[i].platformToken, address(asset), currentDeposit, interest);
            }
        }

        emit HarvestedReward(bonusAccrued, harvestedDetails);
    }


    function start() external override onlyBotOrCreator {
        _status = WorkerStatus.ACTIVE;
        emit Started();
    }

    function stop() external override onlyBotOrCreator {
        _status = WorkerStatus.INACTIVE;
        emit Stopped();
    }

    function monitor(bytes memory data) external override view returns(uint action, bytes memory actionData) { 
        uint target = _targetHealthFactor;
        if (data.length > 0) {
            target = abi.decode(data, (uint));
        }
        require(target > 1 ether, Errors.MLF_INVALID_EXPECTED_HEALTH_FACTOR);
        (,,, uint health) = _adapter.accountInfo(address(this));
        return (compare(health, target, _precision > 0 ? _precision: DEFAULT_PRECISION), 
                abi.encode(target));
    }

    function execute(uint action, bytes calldata data) external override {
        if (action == ACTION_LEVERAGE_BORROW) {
            uint target = abi.decode(data, (uint));
            _leverageBorrow(target, 10);
        } else if (action == ACTION_LEVERAGE_REPAY) {
            uint target = abi.decode(data, (uint));
            _leverageRepay(target, 10);
        }
        emit Executed(action, data);
    }

    function targetBorrowAmount(address account, address leverageToken, uint expectedHealthFactor) 
        public view returns(uint) 
    {
        (, uint collateral, uint borrowBalance, uint healthFactor) = _adapter.accountInfo(account);
        if (expectedHealthFactor <= 1 ether || (expectedHealthFactor >= healthFactor && healthFactor != 0))
            return 0;
        uint collateralFactor = _adapter.collateralFactor(leverageToken);
        uint targetValue = (collateral - borrowBalance * expectedHealthFactor / 1 ether) 
                * 1 ether 
                / (expectedHealthFactor - collateralFactor);
        uint price = _adapter.priceUnderlying(leverageToken);
        return targetValue * 1 ether / price;
    }

    function targetRepayAmount(address account, address leverageToken, uint expectedHealthFactor)
        public view returns(uint)
    {
        (, uint collateral, uint borrowBalance, uint healthFactor) = _adapter.accountInfo(account);
        if ((expectedHealthFactor <= healthFactor && expectedHealthFactor > 0) || 
            borrowBalance == 0)
            return 0;
        
        if (expectedHealthFactor <= 1 ether && expectedHealthFactor > 0)
            return 0;

        uint price = _adapter.priceUnderlying(leverageToken);
        uint targetValue;

        if (expectedHealthFactor == 0) {
            targetValue = borrowBalance;
        } else {
            uint collateralFactor = _adapter.collateralFactor(leverageToken);
            targetValue = (borrowBalance * expectedHealthFactor / 1 ether - collateral) 
                          * 1 ether 
                          / (expectedHealthFactor - collateralFactor);
        }
        return targetValue * 1 ether / price;
    }

    function leverageBorrow(uint targetHealthFactor, uint maxLoop) external onlyBotOrCreator requireAdapter {
        _leverageBorrow(targetHealthFactor, maxLoop);
    }

    function leverageRepay(uint targetHealthFactor, uint maxLoop) public onlyBotOrCreator requireAdapter {
        _leverageRepay(targetHealthFactor, maxLoop);
    }

    function repay(address platformToken, uint amount) external override onlyBotOrCreator requireAdapter {
        _repay(platformToken, amount);
    }

    function _setLeverageAsset(address platformToken) internal {
        if (_leverageToken != platformToken) {
            require(platformToken != address(0), Errors.MLF_INVALID_PLATFORM_TOKEN);
            if (_leverageToken != address(0)) {
                (, uint borrowToken) = _adapter.accountInfo(address(this), _leverageToken);
                require(borrowToken == 0, Errors.MLF_CANNOT_CHANGE_IN_USED_LEVERAGE_ASSET);
            }
            _leverageToken = platformToken;
        }
    }

    function _setTargetHealthFactor(uint value) internal {
        require(value > 1 ether, Errors.MLF_INVALID_EXPECTED_HEALTH_FACTOR);
        if (value != _targetHealthFactor)
            _targetHealthFactor = value;
    }

    function _setPrecision(uint value) internal {
        require(value >= 1 && value < 18, Errors.MLF_INVALID_PRECISION);
        if (value != _precision)
            _precision = value;
    }

    function _addCollateral(address platformToken) internal {
        require(platformToken != address(0), Errors.MLF_INVALID_PLATFORM_TOKEN);
        _enableCollateral(platformToken);
        _collaterals.add(platformToken);    
    }

    function _removeCollateral(address platformToken) internal {
        (uint depositToken, uint borrowToken) = _adapter.accountInfo(address(this), platformToken);
        require(depositToken == 0 && borrowToken == 0, Errors.MLF_CANNOT_REMOVE_IN_USED_COLLATERAL);
        _collaterals.remove(platformToken);
    }

    function _leverageBorrow(uint targetHealthFactor, uint maxLoop) internal {
        require(_leverageToken != address(0), Errors.MLF_LEVERAGE_ASSET_IS_NOT_SET);
        uint borrowAmount = targetBorrowAmount(address(this), _leverageToken, targetHealthFactor);
        if (borrowAmount > 0)
            _leverageBorrow(_leverageToken, borrowAmount, maxLoop);
    }

    function _leverageRepay(uint targetHealthFactor, uint maxLoop) internal {
        require(_leverageToken != address(0), Errors.MLF_LEVERAGE_ASSET_IS_NOT_SET);
        uint repayAmount = targetRepayAmount(address(this), _leverageToken, targetHealthFactor);
        if (repayAmount > 0)
            _leverageRepay(_leverageToken, repayAmount, maxLoop);
    }

    function _leverageBorrow(address platformToken, uint targetAmount, uint maxLoop) internal {
        while (maxLoop > 0 && targetAmount > 0) {
            uint borrowAmount = _adapter.getBorrowableToken(address(this), platformToken, 1 ether);
            if (borrowAmount > targetAmount)
                borrowAmount = targetAmount;
            if (borrowAmount == 0)
                break;
            _borrow(platformToken, borrowAmount);
            _internalDeposit(platformToken, borrowAmount, false);
            targetAmount -= borrowAmount;
            maxLoop--;
        }
    }

    function _leverageRepay(address platformToken, uint targetAmount, uint maxLoop) internal {
        while (maxLoop > 0 && targetAmount > 0) {
            uint amount = _adapter.getWithdrawableToken(address(this), platformToken, 1 ether);
            if (amount > targetAmount)
                amount = targetAmount;
            if (amount < 1000 gwei)
                break;
            _internalWithdraw(platformToken, amount, address(0), false);
            _repay(platformToken, amount);
            targetAmount -= amount;
            maxLoop--;
        }
    }

    function _enableCollateral(address platformToken) private {
        address adapterImpl = getImpl(address(_adapter));
        
        if (!_adapter.isCollateral(address(this), platformToken)) 
            adapterImpl.fnCall(
                abi.encodeWithSelector(ILendingAdapter.enableCollateral.selector, platformToken)
            );
    }

    function _internalDeposit(address platformToken, uint amount, bool acquiredTokenFromSender) internal {
        if (amount == 0)
            return;

        address adapterImpl = getImpl(address(_adapter));
        
        if (!_adapter.isCollateral(address(this), platformToken)) 
            adapterImpl.fnCall(
                abi.encodeWithSelector(ILendingAdapter.enableCollateral.selector, platformToken)
            );
        
        IERC20 asset = IERC20(_adapter.underlying(platformToken));

        if (acquiredTokenFromSender) {
            if (!_isNativeAsset(address(asset))) {
                asset.safeTransferFrom(msg.sender, address(this), amount); 
            }
            _deposits[asset] += amount;
        }

        adapterImpl.fnCall(
            abi.encodeWithSelector(ILendingAdapter.deposit.selector, platformToken, amount)
        );
    }

    function _internalWithdraw(address platformToken, uint amount, address to, bool isHarvestReward) internal {
        if (amount == 0)
            return;

        IERC20 asset = IERC20(_adapter.underlying(platformToken));
        address adapterImpl = getImpl(address(_adapter));

        if (_isNativeAsset(address(asset))) {
            // TODO: withdraw native token
        } else {
            // due to math calculation, the actual amount of withdrawal might be different
            // from the input amount. That causes the subsequent of safe transfer might be fail
            uint beforeBalance = asset.balanceOf(address(this));
            adapterImpl.fnCall(
                abi.encodeWithSelector(ILendingAdapter.withdraw.selector, platformToken, amount)
            );

            if (to != address(0)) {
                uint afterBalance = asset.balanceOf(address(this));
                require(afterBalance >= beforeBalance, Errors.MLF_INTERNAL_ERROR);
                amount = afterBalance - beforeBalance;
                if (amount == 0)
                    return;
                if (!isHarvestReward)
                    _deposits[asset] = _deposits[asset] > amount ? _deposits[asset] - amount : 0;
                asset.safeTransfer(to, amount);
            }
        }
    }

    function _borrow(address platformToken, uint amount) internal {
        if (amount == 0)
            return;
        
        address adapterImpl = getImpl(address(_adapter));
        adapterImpl.fnCall(
            abi.encodeWithSelector(ILendingAdapter.borrow.selector, platformToken, amount)
        );
    }

    function _repay(address platformToken, uint amount) internal {
        if (amount == 0)
            return;
        
        address adapterImpl = getImpl(address(_adapter));
        adapterImpl.fnCall(
            abi.encodeWithSelector(ILendingAdapter.repay.selector, platformToken, amount)
        );
    }

    function round(uint mantisa, uint precision) internal pure returns(uint) {
        return mantisa / (10 ** (18 - precision));
    }

    function compare(uint a, uint b, uint precision) internal pure returns(uint) {
        a = round(a, precision);
        b = round(b, precision);
        if (a > b) return 1;
        if (a < b) return 2;
        return 0;
    }

    function underlying(address platformToken) external view requireAdapter override returns(address asset) {
        return _adapter.underlying(platformToken);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Errors {
    /// Common error
    string constant CM_CONTRACT_HAS_BEEN_INITIALIZED = "CM-01"; 
    string constant CM_FACTORY_ADDRESS_IS_NOT_CONFIGURED = "CM-02";
    string constant CM_VICS_ADDRESS_IS_NOT_CONFIGURED = "CM-03";
    string constant CM_VICS_EXCHANGE_IS_NOT_CONFIGURED = "CM-04";
    string constant CM_CEX_FUND_MANAGER_IS_NOT_CONFIGURED = "CM-05";
    string constant CM_TREASURY_MANAGER_IS_NOT_CONFIGURED = "CM-06";
    string constant CM_CEX_DEFAULT_MASTER_ACCOUNT_IS_NOT_CONFIGURED = "CM-07";
    string constant CM_ADDRESS_IS_NOT_ICEXDABOTCERTTOKEN = "CM-08";
    string constant CM_INDEX_OUT_OF_RANGE = "CM-09";
    string constant CM_UNAUTHORIZED_CALLER = "CM-10";
    string constant CM_PROXY_ADMIN_IS_NOT_CONFIGURED = "CM-11";
    

    /// IBCertToken error  (Bot Certificate Token)
    string constant BCT_CALLER_IS_NOT_OWNER = "BCT-01"; 
    string constant BCT_REQUIRE_ALL_TOKENS_BURNT = "BCT-02";
    string constant BCT_UNLOCK_AMOUNT_EXCEEDS_TOTAL_LOCKED = "BCT-03";
    string constant BCT_INSUFFICIENT_LIQUID_FOR_UNLOCKING = "BCT-04a";
    string constant BCT_INSUFFICIENT_LIQUID_FOR_LOCKING = "BCT-04b";
    string constant BCT_AMOUNT_EXCEEDS_TOTAL_STAKE = "BCT-05";
    string constant BCT_CANNOT_MINT_TO_ZERO_ADDRESS = "BCT-06";
    string constant BCT_INSUFFICIENT_LIQUID_FOR_BURN = "BCT-07";
    string constant BCT_INSUFFICIENT_ACCOUNT_FUND = "BCT-08";
    string constant BCT_CALLER_IS_NEITHER_BOT_NOR_CERTLOCKER = "BCT-09";
    string constant BCT_VALUE_MISMATCH_ASSET_AMOUNT = "BCT-10";

    /// IBCEXCertToken error (Cex Bot Certificate Token)
    string constant CBCT_CALLER_IS_NOT_FUND_MANAGER = "CBCT-01";

    /// GovernToken error (Bot Governance Token)
    string constant BGT_CALLER_IS_NOT_OWNED_BOT = "BGT-01";
    string constant BGT_CANNOT_MINT_TO_ZERO_ADDRESS = "BGT-02";
    string constant BGT_CALLER_IS_NOT_GOVERNANCE = "BGT-03";

    // VaultBase error (VB)
    string constant VB_CALLER_IS_NOT_DABOT = "VB-01a";
    string constant VB_CALLER_IS_NOT_OWNER_BOT = "VB-01b";
    string constant VB_INVALID_VAULT_ID = "VB-02";
    string constant VB_INVALID_VAULT_TYPE = "VB-03";
    string constant VB_INVALID_SNAPSHOT_ID = "VB-04";

    // RegularVault Error (RV)
    string constant RV_VAULT_IS_RESTRICTED = "RV-01";
    string constant RV_DEPOSIT_LOCKED = "RV-02";
    string constant RV_WITHDRAWL_AMOUNT_EXCEED_DEPOSIT = "RV-03";

    // BotVaultManager (VM)
    string constant VM_VAULT_EXISTS = "VM-01";

    // BotManager (BM)
    string constant BM_DOES_NOT_SUPPORT_IDABOT = "BM-01";
    string constant BM_DUPLICATED_BOT_QUALIFIED_NAME = "BM-02";
    string constant BM_TEMPLATE_IS_NOT_REGISTERED = "BM-03";
    string constant BM_GOVERNANCE_TOKEN_IS_NOT_DEPLOYED = "BM-04";
    string constant BM_BOT_IS_NOT_REGISTERED = "BM-05";

    // DABotModule (BMOD)
    string constant BMOD_CALLER_IS_NOT_OWNER = "BMOD-01";
    string constant BMOD_CALLER_IS_NOT_BOT_MANAGER = "BMOD-02";
    string constant BMOD_BOT_IS_ABANDONED = "BMOD-03";

    // DABotControllerLib (BCL)
    string constant BCL_DUPLICATED_MODULE = "BCL-01";
    string constant BCL_CERT_TOKEN_IS_NOT_CONFIGURED = "BCL-02";
    string constant BCL_GOVERN_TOKEN_IS_NOT_CONFIGURED = "BCL-03";
    string constant BCL_GOVERN_TOKEN_IS_NOT_DEPLOYED = "BCL-04";
    string constant BCL_WARMUP_LOCKER_IS_NOT_CONFIGURED = "BCL-05";
    string constant BCL_COOLDOWN_LOCKER_IS_NOT_CONFIGURED = "BCL-06";
    string constant BCL_UKNOWN_MODULE_ID = "BCL-07";
    string constant BCL_BOT_MANAGER_IS_NOT_CONFIGURED = "BCL-08";

    // DABotController (BCMOD)
    string constant BCMOD_CANNOT_CALL_TEMPLATE_METHOD_ON_BOT_INSTANCE = "BCMOD-01";
    string constant BCMOD_CALLER_IS_NOT_OWNER = "BCMOD-02";
    string constant BCMOD_MODULE_HANDLER_NOT_FOUND_FOR_METHOD_SIG = "BCMOD-03";
    string constant BCMOD_NEW_OWNER_IS_ZERO = "BCMOD-04";

    // CEXFundManagerModule (CFMOD)
    string constant CFMOD_DUPLICATED_BENEFITCIARY = "CFMOD-01";
    string constant CFMOD_INVALID_CERTIFICATE_OF_ASSET = "CFMOD-02";
    string constant CFMOD_CALLER_IS_NOT_FUND_MANAGER = "CFMOD-03";

    // DABotSettingLib (BSL)
    string constant BSL_CALLER_IS_NOT_OWNER = "BSL-01";
    string constant BSL_CALLER_IS_NOT_GOVERNANCE_EXECUTOR = "BSL-02";
    string constant BSL_IBO_ENDTIME_IS_SOONER_THAN_IBO_STARTTIME = "BSL-03";
    string constant BSL_BOT_IS_ABANDONED = "BSL-04";

    // DABotSettingModule (BSMOD)
    string constant BSMOD_IBO_ENDTIME_IS_SOONER_THAN_IBO_STARTTIME =  "BSMOD-01";
    string constant BSMOD_INIT_DEPOSIT_IS_LESS_THAN_CONFIGURED_THRESHOLD = "BSMOD-02";
    string constant BSMOD_FOUNDER_SHARE_IS_ZERO = "BSMOD-03";
    string constant BSMOD_INSUFFICIENT_MAX_SHARE = "BSMOD-04";
    string constant BSMOD_FOUNDER_SHARE_IS_GREATER_THAN_IBO_SHARE = "BSMOD-05";

    // DABotCertLocker (LOCKER)
    string constant LOCKER_CALLER_IS_NOT_OWNER_BOT = "LOCKER-01";

    // DABotStakingModule (BSTMOD)
    string constant BSTMOD_PRE_IBO_REQUIRED = "BSTMOD-01";
    string constant BSTMOD_AFTER_IBO_REQUIRED = "BSTMOD-02";
    string constant BSTMOD_INVALID_PORTFOLIO_ASSET = "BSTMOD-03";
    string constant BSTMOD_PORTFOLIO_FULL = "BSTMOD-04";
    string constant BSTMOD_INVALID_CERTIFICATE_ASSET = "BSTMOD-05";
    string constant BSTMOD_PORTFOLIO_ASSET_NOT_FOUND = "BSTMOD-06";
    string constant BSTMOD_ASSET_IS_ZERO = "BSTMOD-07";
    string constant BSTMOD_INVALID_STAKING_CAP = "BSTMOD-08";
    string constant BSTMOD_INSUFFICIENT_FUND = "BSTMOD-09";
    string constant BSTMOD_CAP_IS_ZERO = "BSTMOD-10";
    string constant BSTMOD_CAP_IS_LESS_THAN_STAKED_AND_IBO_CAP = "BSTMOD-11";
    string constant BSTMOD_WERIGHT_IS_ZERO = "BSTMOD-12";

    // CEX FundManager (CFM)
    string constant CFM_REQ_TYPE_IS_MISMATCHED = "CFM-01";
    string constant CFM_INVALID_REQUEST_ID = "CFM-02";
    string constant CFM_CALLER_IS_NOT_BOT_TOKEN = "CFM-03";
    string constant CFM_CLOSE_TYPE_VALUE_IS_NOT_SUPPORTED = "CFM-04";
    string constant CFM_UNKNOWN_REQUEST_TYPE = "CFM-05";
    string constant CFM_CALLER_IS_NOT_REQUESTER = "CFM-06";
    string constant CFM_CALLER_IS_NOT_APPROVER = "CFM-07";
    string constant CFM_CEX_CERTIFICATE_IS_REQUIRED = "CFM-08";
    string constant CFM_TREASURY_ASSET_CERTIFICATE_IS_REQUIRED = "CFM-09";
    string constant CFM_FAIL_TO_TRANSFER_VALUE = "CFM-10";
    string constant CFM_AWARDED_ASSET_IS_NOT_TREASURY = "CFM-11";
    string constant CFM_INSUFFIENT_ASSET_TO_MINT_STOKEN = "CFM-12";

    // FarmBot Module (FBM)  string constant FBM_ = "FBM-";
    string constant FBM_CANNOT_REMOVE_WORKER = "FBM-01";
    string constant FBM_NULL_OPERATOR_ACCOUNT = "FBM-02";
    string constant FBM_INVALID_WORKER = "FBM-03";
    string constant FBM_REPAY_ERROR = "FBM-04";
    string constant FBM_INVALID_SWAP_ADAPTER = "FBM-05";
    string constant FBM_INVALID_SWAP_PATH = "FBM-06";
    string constant FBM_INSUFFICIENT_FUND = "FBM-07";

    // TreasuryAsset (TA)
    string constant TA_MINT_ZERO_AMOUNT = "TA-01";
    string constant TA_LOCK_AMOUNT_EXCEED_BALANCE = "TA-02";
    string constant TA_UNLOCK_AMOUNT_AND_PASSED_VALUE_IS_MISMATCHED = "TA-03";
    string constant TA_AMOUNT_EXCEED_AVAILABLE_BALANCE = "TA-04";
    string constant TA_AMOUNT_EXCEED_VALUE_BALANCE = "TA-05";
    string constant TA_FUND_MANAGER_IS_NOT_SET = "TA-06";
    string constant TA_FAIL_TO_TRANSFER_VALUE = "TA-07";

    // Governance (GOV)
    string constant GOV_DEFAULT_STRATEGY_IS_NOT_SET = "GOV-01";
    string constant GOV_INSUFFICIENT_POWER_TO_CREATE_PROPOSAL = "GOV-02";
    string constant GOV_INSUFFICIENT_VICS_TO_CREATE_PROPOSAL = "GOV-03";
    string constant GOV_INVALID_PROPOSAL_ID = "GOV-04";
    string constant GOV_REQUIRED_PROPOSER_OR_GUARDIAN = "GOV-05";
    string constant GOV_TARGET_SHOULD_BE_ZERO_OR_REGISTERED_BOT = "GOV-06";
    string constant GOV_INSUFFICIENT_POWER_TO_VOTE = "GOV-07";
    string constant GOV_INVALID_NEW_STATE = "GOV-08";
    string constant GOV_CANNOT_CHANGE_STATE_OF_CLOSED_PROPOSAL = "GOV-08";
    string constant GOV_INVALID_CREATION_DATA = "GOV-09";
    string constant GOV_CANNOT_CHANGE_STATE_OF_ON_CHAIN_PROPOSAL = "GOV-10";
    string constant GOV_PROPOSAL_DONT_ACCEPT_VOTE = "GOV-11";
    string constant GOV_DUPLICATED_VOTE = "GOV-12";
    string constant GOV_CAN_ONLY_QUEUE_PASSED_PROPOSAL = "GOV-13";
    string constant GOV_DUPLICATED_ACTION = "GOV-14";
    string constant GOV_INVALID_VICS_ADDRESS = "GOV-15";

    // Timelock Executor (TLE)
    string constant TLE_DELAY_SHORTER_THAN_MINIMUM = "TLE-01";
    string constant TLE_DELAY_LONGER_THAN_MAXIMUM = "TLE-02";
    string constant TLE_ONLY_BY_ADMIN = "TLE-03";
    string constant TLE_ONLY_BY_PENDING_ADMIN = "TLE-04";
    string constant TLE_ONLY_BY_THIS_TIMELOCK = "TLE-05";
    string constant TLE_EXECUTION_TIME_UNDERESTIMATED = "TLE-06";
    string constant TLE_ACTION_NOT_QUEUED = "TLE-07";
    string constant TLE_TIMELOCK_NOT_FINISHED = "TLE-08";
    string constant TLE_GRACE_PERIOD_FINISHED = "TLE-09";
    string constant TLE_NOT_ENOUGH_MSG_VALUE = "TLE-10";

    // DABotVoteStrategy (BVS) string constant BVS_ = "BVS-";
    string constant BVS_NOT_A_REGISTERED_DABOT = "BVS-01";

    // DABotWhiteList (BWL) string constant BWL_ = "BWL-";
    string constant BWL_ACCOUNT_IS_ZERO = "BWL-01";
    string constant BWL_ACCOUNT_IS_NOT_WHITELISTED = "BWL-02";

    // Marginal Lending Worker string constant MLF_ = "MLF-";
    string constant MLF_ZERO_DEPOSIT = "MLF-01";
    string constant MLF_UNKNOWN_CONFIG_TOPIC = "MLF-02";
    string constant MLF_REGISTERED_COLLATERAL_ID_EXPECTED = "MLF-03";
    string constant MLF_CONFIG_TOPICS_AND_VALUES_MISMATCHED = "MLF-04";
    string constant MLF_ADAPTER_IS_NOT_CONFIGURED = "MLF-05";
    string constant MLF_CANNOT_REMOVE_IN_USED_COLLATERAL = "MLF-06";
    string constant MLF_CANNOT_CHANGE_LENDING_ADAPTER = "MLF-07";
    string constant MLF_INVALID_PLATFORM_TOKEN = "MLF-08";
    string constant MLF_CANNOT_CHANGE_IN_USED_LEVERAGE_ASSET = "MLF-09";
    string constant MLF_INVALID_EXPECTED_HEALTH_FACTOR = "MLF-10";
    string constant MLF_LEVERAGE_ASSET_IS_NOT_SET = "MLF-11";
    string constant MLF_INVALID_PRECISION = "MLF-12";
    string constant MLF_INTERNAL_ERROR = "MLF-13";

    // FarmCertTokenModule (FTM) string constant FTM_ = "FTM-";
    string constant FTM_INSUFFICICIENT_AMOUNT_TO_DEPOSIT = "FTM-01";

    // ILendingAdapter (ILA) string constant ILA_ = "ILA-";
    string constant ILA_INVALID_EXPECTED_HEALTH_FACTOR = "ILA-01";

    // RoboFi game string constant RFG_ = "RFG-";
    string constant RFG_CALLER_IS_NOT_REGISTERED_BOT = "RFG-01";
    string constant RFG_CALLER_IS_NOT_BOT_OWNER = "RFG-02";
    string constant RFG_CALLER_IS_NOT_VAULT = "RFG-03";
    string constant RFG_ROUND_NOT_FINISHED = "RFG-04";
    string constant RFG_ROUND_NOT_IN_COMMIT_PHASE = "RFG-05";
    string constant RFG_ROUND_NOT_IN_REVEAL_PHASE = "RFG-06";
    string constant RFG_ROUND_NOT_READY_CLOSE = "RFG-07";
    string constant RFG_ROUND_NOT_CLOSED_YET = "RFG-08";
    string constant RFG_INVALID_SECRET_NUMBER = "RFG-09";
    string constant RFG_WINNER_IS_REQUIRE = "RFG-10";
    string constant RFG_INVALID_SUBMIT_WINNERS = "RFG-11";
    string constant RFG_INVALID_NUMBER_OF_WINNERS = "RFG-12";
    string constant RFG_INVALID_WON_NUMBER = "RFG-13";
    string constant RFG_INVALID_VICS_ADDRESS = "RFG-14";
    string constant RFG_INVALID_COMMIT_DURATION = "RFG-15";
    string constant RFG_INVALID_REVEAL_DURATION = "RFG-16";
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IProxyAdmin {
    function getProxyImplementation(address proxy) external view returns(address);
    function isAdminOf(address proxy) external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DABotCommon.sol"; 
import "./IDABotController.sol";
import "./IDABotSettingModule.sol";
import "./IDABotStakingModule.sol";
import "./IDABotGovernModule.sol";
import "./IDABotWhitelist.sol";
import "./IDABotFundManagerModule.sol";

interface IDABot is IDABotController, 
    IDABotSettingModule, 
    IDABotStakingModule, 
    IDABotGovernModule, 
    IDABotWhitelistModule,
    IDABotFundManagerModule 
{
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBotVault.sol";
import "../DABotCommon.sol";
import "../../common/IRoboFiFactory.sol";
import "../../common/IConfigurator.sol";

interface IDABotManagerEvent {
    event BotRemoved(address indexed bot);
    event BotDeployed(uint botId, address indexed bot, BotDetail detail); 
    event TemplateRegistered(address indexed template, string name, string version, uint8 templateType);
}

interface IDABotManager is IDABotManagerEvent {
    
    function configurator() external view returns(IConfigurator);
    function vaultManager() external view returns(IBotVaultManager);
    function addTemplate(address template) external;
    function templates() external view returns(address[] memory);
    function isRegisteredTemplate(address template) external view returns(bool);
    function isRegisteredBot(address botAccount) external view returns(bool);
    function totalBots() external view returns(uint);
    function botIdOf(string calldata qualifiedName) external view returns(int);
    function queryBots(uint[] calldata botId) external view returns(BotDetail[] memory output);
    function deployBot(address template, 
                        string calldata symbol, 
                        string calldata name,
                        BotModuleInitData[] calldata initData
                        ) external;
    function snapshot(address botAccount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IDefiAdapter.sol";

struct MarketInfo {
    address platformToken;
    address asset;
    uint collateralFactor;
}

struct AccountDetailInfo {
    address platformToken;
    address asset;
    uint deposit;
    uint collateral;
    uint borrow;
    uint depositValue;
    uint borrowValue;
    bool listed;
    uint oraclePriceMantissa;
    uint exchangeRateMantissa;
}

interface ILendingAdapter is IDefiAdapter {
    function getMarket(address asset) external view returns(address platformToken);
    function getMarkets() external view returns(MarketInfo[] memory markets);
    function isCollateral(address account, address platformToken) external view returns(bool);
    function enableCollateral(address platformToken) external;
    function rewardTokens() external view returns(address[] memory);

    function collateralFactor(address platformToken) external view returns(uint);

    function priceUnderlying(address platformToken) external view returns(uint);
    /**
    @notice healthFactor is stored scale 1e18, and should be greater than 1.0
            otherwise, the account will be liquidated.
     */
    function accountInfo(address account) external view 
        returns(uint totalDeposit,
                uint totalCollateral, 
                uint totalBorrow, 
                uint healthFactor);
    function accountInfo(address account, address platformToken) external view 
        returns(uint depositToken, uint borrowToken);

    function rewardAccrued(address account) external view returns(uint);
    function accountDetailInfo(address account) external view returns(AccountDetailInfo[] memory) ;

    function deposit(address platformToken, uint amount) external;
    function withdraw(address platformToken, uint amount) external;
    function borrow(address platformToken, uint amount) external;
    function repay(address platformToken, uint amount) external;
    function harvestReward(address account) external;

    function getBorrowableToken(address account, address platformToken, uint expectedHealthFactor) external view returns(uint);
    function getWithdrawableToken(address account, address platformToken, uint expectedHealthFactor) external view returns(uint);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

struct SwapDetail {
    uint amountIn;
    address[] path;
    address adapter;
}

interface IDABotFarmingModuleEvent {
    event WorkerAdded(address indexed worker);
    event WorkerRemoved(address indexed worker);
    event OperatorUpdated(address indexed account, bool status);
    event Swap(address indexed from, address indexed to, uint amountIn, uint amountOut, address adapter);
    event Repay(address indexed worker, address platformToken, uint amount);
}

interface IDABotFarmingModule is IDABotFarmingModuleEvent {

    function allWorkers() external view returns(address[] memory workers);

    function deployWorker(
        address engineTemplate,
        uint16[] calldata pIDs,
        bytes[] calldata values
    ) external returns(address worker);

    function canRemoveWorker(address worker) external view returns(bool);

    function indexOfWorker(address worker) external view returns(bool found, uint index);

    function removeWorker(uint index) external;

    function setOperator(address account, bool status) external; 

    function isOperator(address account) external view returns(bool);

    function swap(SwapDetail[] calldata details) external;

    function repay(uint index, address platformToken, uint amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

enum WorkerPropertyDataType {
    NUMBER, BOOL, ASSET, ASSETS, LENDING_PLATFORM, EXCHANGE_PLATFORM, FARMING_PLATFORM 
}

enum WorkerStatus {
    INACTIVE, ACTIVE
}

struct WorkerProperty {
    uint16 pId;
    WorkerPropertyDataType pType;
    string name;
    bytes value;
}

interface IBotWorker {

    event Configure(uint16 pId, bytes value);
    event Deposit(address indexed platformToken, address indexed underlyingAsset, address indexed from, uint amount);
    event Withdraw(address indexed platformToken, address indexed underlyingAsset, address indexed to, uint amount);
    event ClaimReward(address indexed asset, uint amount);
    event Started();
    event Stopped();
    event Executed(uint action, bytes data);

    function initialize() external;

    function status() external view returns(WorkerStatus);

    function properties() external view returns(WorkerProperty[] memory);
    function property(uint16 pId) external view returns(bytes memory);
    function configure(uint16 pId, bytes calldata value) external;
    function configureEx(uint16[] calldata pIds, bytes[] calldata values) external;

    function accountInfo() external view returns(
        uint initDeposit, uint totalReward, uint healthFactor);

    function deposit(address platformToken, uint amount) external payable;
    function withdraw(address platformToken, uint amount) external;
    function claimReward() external;
    function start() external;
    function stop() external;
    function monitor(bytes memory) external view returns(uint action, bytes memory data);
    function execute(uint action, bytes calldata data) external;
    function underlying(address platformToken) external view returns(address asset);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBotWorker.sol";

struct CollateralInfo {
    address platformToken;
    address underlying;
    uint initDeposit;
    uint currentDeposit;
    uint currentBorrow;
    uint currentDepositValue;
    uint currentBorrowValue;
    uint weight;          
}

struct HarvestReward {
    address platformToken;
}

struct HarvestedRewardDetail {
    address platformToken;
    address underlying;
    uint deposit;   // in underlying
    uint interest;  // in underlying
}

interface ILendingBotWorker is IBotWorker {
    event HarvestedReward(uint platformBonus, HarvestedRewardDetail[] details);

    function collateralInfo() external view returns(CollateralInfo[] memory);
    function harvestReward(bool platformBonus, HarvestReward[] calldata details) external;
    function repay(address platformToken, uint amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

struct TradingRoute {
    uint8 layoutType;   // 1 - array of address
                        // 2 - KyberSwap Description
    bool bidirection;   // true - the route is for bi-direction swap
    bytes data;
}


interface IExchangeAdapter {

    event RouteUpdated(address indexed from, 
                    address indexed to, TradingRoute route);
    event RouteRemoved(address indexed from, address indexed to);

    /**
    @param from the source asset
    @param to the target asset
    @param layoutType the layout of the route data: 0 - array of address, 1 KyberSwap Description
    @param bidirection determines the route data can be used to infer the reverse swap direction
    @param data the route data
     */
    function setRoute(address from, address to, 
                uint8 layoutType, bool bidirection, bytes calldata data) external;

    function removeRoute(address from, address to) external;

    function routeOf(address from, address to) external view returns(TradingRoute memory);

    function swap(address from, address to, uint amount) external payable;
    function swapable(address from, address to) external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Exponential module for storing fixed-precision decimals
 * @author Atlantis
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
contract ExponentialNoError {
    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale/2;
    uint constant mantissaOne = expScale;

    struct Exp {
        uint mantissa;
    }

    struct Double {
        uint mantissa;
    }

    /**
     * @dev Truncates the given exp to a whole number value.
     *      For example, truncate(Exp{mantissa: 15 * expScale}) = 15
     */
    function truncate(Exp memory exp) pure internal returns (uint) {
        // Note: We are not using careful math here as we're performing a division that cannot fail
        return exp.mantissa / expScale;
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mul_ScalarTruncate(Exp memory a, uint scalar) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return truncate(product);
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mul_ScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return add_(truncate(product), addend);
    }

    /**
     * @dev Checks if first Exp is less than second Exp.
     */
    function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa < right.mantissa;
    }

    /**
     * @dev Checks if left Exp <= right Exp.
     */
    function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa <= right.mantissa;
    }

    /**
     * @dev Checks if left Exp > right Exp.
     */
    function greaterThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa > right.mantissa;
    }

    /**
     * @dev returns true if Exp is exactly zero
     */
    function isZeroExp(Exp memory value) pure internal returns (bool) {
        return value.mantissa == 0;
    }

    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {
        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint n, string memory errorMessage) pure internal returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {
        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {
        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {
        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) pure internal returns (uint) {
        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {
        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

import "@openzeppelin/contracts/utils/Context.sol";

import "./interfaces/IDABotComponent.sol";

enum BotStatus { PRE_IBO, IN_IBO, ACTIVE, ABANDONED }

struct BotModuleInitData {
    bytes32 moduleId;
    bytes data;
}

struct BotSetting {             // for saving storage, the meta-fields of a bot are encoded into a single uint256 byte slot.
    uint64 iboTime;             // 32 bit low: iboStartTime (unix timestamp), 
                                // 32 bit high: iboEndTime (unix timestamp)
    uint24 stakingTime;         // 8 bit low: warm-up time, 
                                // 8 bit mid: cool-down time
                                // 8 bit high: time unit (0 - day, 1 - hour, 2 - minute, 3 - second)
    uint32 pricePolicy;         // 16 bit low: price multiplier (fixed point, 2 digits for decimal)
                                // 16 bit high: commission fee in percentage (fixed point, 2 digit for decimal)
    uint128 profitSharing;      // packed of 16bit profit sharing: bot-creator, gov-user, stake-user, and robofi-game
    uint initDeposit;           // the intial deposit (in VICS) of bot-creator
    uint initFounderShare;      // the intial shares (i.e., governance token) distributed to bot-creator
    uint maxShare;              // max cap of gtoken supply
    uint iboShare;              // max supply of gtoken for IBO. Constraint: maxShare >= iboShare + initFounderShare
}

struct BotMetaData {
    string name;
    string symbol;
    string version;
    uint8 botType;
    bool abandoned;
    bool isTemplate;        // determine this module is a template, not a bot instance
    bool initialized;       // determines whether the bot has been initialized 
    address botOwner;       // the public address of the bot owner
    address botManager;
    address botTemplate;    // address of the template contract 
    address gToken;         // address of the governance token
}

struct BotDetail { // represents a detail information of a bot, merely use for bot infomation query
    uint id;                    // the unique id of a bot within its manager.
                                // note: this id only has value when calling {DABotManager.queryBots}
    address botAddress;         // the contract address of the bot.

    BotStatus status;           // 0 - PreIBO, 1 - InIBO, 2 - Active, 3 - Abandonned
    uint8 botType;              // type of the bot (inherits from the bot's template)
    string botSymbol;           // get the bot name.
    string botName;             // get the bot full name.
    address governToken;        // the address of the governance token
    address template;           // the address of the master contract which defines the behaviors of this bot.
    string templateName;        // the template name.
    string templateVersion;     // the template version.
    uint iboStartTime;          // the time when IBO starts (unix second timestamp)
    uint iboEndTime;            // the time when IBO ends (unix second timestamp)
    uint warmup;                // the duration (in days) for which the staking profit starts counting
    uint cooldown;              // the duration (in days) for which users could claim back their stake after submiting the redeem request.
    uint priceMul;              // the price multiplier to calculate the price per gtoken (based on the IBO price).
    uint commissionFee;         // the commission fee when buying gtoken after IBO time.
    uint initDeposit;           
    uint initFounderShare;
    uint144 profitSharing;
    uint maxShare;              // max supply of governance token.
    uint circulatedShare;       // the current supply of governance token.
    uint iboShare;              // the max supply of gtoken for IBO.
    uint userShare;             // the amount of governance token in the caller's balance.
    UserPortfolioAsset[] portfolio;
}

struct BotModuleInfo {
    string name;
    string version;
    address handler;
}

struct PortfolioCreationData {
    address asset;
    uint256 cap;            // the maximum stake amount for this asset (bot-lifetime).
    uint256 iboCap;         // the maximum stake amount for this asset within the IBO.
    uint256 weight;         // preference weight for this asset. Use to calculate the max purchasable amount of governance tokens.
}

struct PortfolioAsset {
    address certToken;    // the certificate asset to return to stake-users
    uint256 cap;            // the maximum stake amount for this asset (bot-lifetime).
    uint256 iboCap;         // the maximum stake amount for this asset within the IBO.
    uint256 weight;         // preference weight for this asset. Use to calculate the max purchasable amount of governance tokens.
}

struct UserPortfolioAsset {
    address asset;
    PortfolioAsset info;
    uint256 userStake;
    uint256 totalStake;     // the total stake of all users.
    uint256 certSupply;     // the total supply of the certificated token
}

/**
@dev Records warming-up certificate tokens of a DABot.
*/
struct LockerData {         
    address bot;            // the DABOT which creates this locker.
    address owner;          // the locker owner, who is albe to unlock and get tokens after the specified release time.
    address token;          // the contract of the certificate token.
    uint64 created_at;      // the moment when locker is created.
    uint64 release_at;      // the monent when locker could be unlock. 
}

/**
@dev Provides detail information of a warming-up token lock, plus extra information.
    */
struct LockerInfo {
    address locker;
    LockerData info;
    uint256 amount;         // the locked amount of cert token within this locker.
    uint256 reward;         // the accumulated rewards
    address asset;          // the stake asset beyond the certificated token
}

struct MintableShareDetail {
    address asset;
    uint stakeAmount;
    uint mintableShare;
    uint weight;
    uint iboCap;
}

struct AwardingDetail {
    address asset;
    uint compound;
    uint reward;
    uint compoundMode;  // 0 - increase, 1 - decrrease
}

struct StakingReward {
    address asset;
    uint amount;
}

struct BenefitciaryInfo {
    address account;
    string name;
    string shortName;
    uint weight;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DABotCommon.sol"; 

interface IDABotControllerEvent {
    event BotAbandoned(bool value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ModuleHandlerChanged(bytes32 moduleId, address indexed oldModuleAddress, address indexed newModuleAddress);
    event ModuleRegistered(bytes32 moduleId, address indexed moduleAddress, string name, string version);
}

/**
@dev The generic interface of a DABot.
 */
interface IDABotController is IDABotControllerEvent {
    function owner() external view returns(address);
    function abandon(bool value) external;
    function modulesInfo() external view returns(BotModuleInfo[] memory result);
    function governToken() external view returns(address);
    function qualifiedName() external view returns(string memory);
    function metadata() external view returns(BotMetaData memory);
    function setting() external view returns(BotSetting memory);
    function botDetails() view external returns(BotDetail memory);
    function updatePortfolio(address asset, uint maxCap, uint iboCap, uint weight) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DABotCommon.sol";

interface IDABotSettingModuleEvent {
    event SettingChanged(uint what, BotSetting setting);  
    event AddressWritten(bytes32 itemId, address indexed value);
    event UintWritten(bytes32 itemId, uint value);
    event BytesWritten(bytes32 itemId, bytes value);
}

interface IDABotSettingModule is IDABotSettingModuleEvent {   
    function status() external view returns(uint);
    function iboTime() external view returns(uint startTime, uint endTime);
    function stakingTime() external view returns(uint warmup, uint cooldown, uint unit);
    function pricePolicy() external view returns(uint priceMul, uint commission);
    function profitSharing() external view returns(uint128);
    function setIBOTime(uint startTime, uint endTime) external;
    function setStakingTime(uint warmup, uint cooldown, uint unit) external;
    function setPricePolicy(uint priceMul, uint commission) external;
    function setProfitSharing(uint sharingScheme) external;

    function readAddress(bytes32 itemId, address defaultAddress) external view returns(address);
    function readUint(bytes32 itemId, uint defaultValue) external view returns(uint);
    function readBytes(bytes32 itemId, bytes calldata defaultValue) external view returns(bytes memory);

    function writeAddress(bytes32 itemId, address value) external;
    function writeUint(bytes32 itemId, uint value) external;
    function writeBytes(bytes32 itemId, bytes calldata value) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IDABotCertToken.sol";
import "../DABotCommon.sol";
import "../interfaces/IBotVault.sol";

interface IDABotStakingModuleEvent {
     event PortfolioUpdated(address indexed asset, address indexed certToken, uint maxCap, uint iboCap, uint weight);
     event AssetRemoved(address indexed asset, address indexed certToken);   
     event Stake(address indexed asset, uint amount, address indexed certToken, uint certAmount, address indexed locker);
     event Unstake(address indexed certToken, uint certAmount, address indexed asset, 
          uint assetAmount, address indexed locker, uint releaseTime);
}

interface IDABotStakingModule is IDABotStakingModuleEvent {

     /**
     @dev Gets the detailed information of the bot's portfolio.
     @return the arrays of UserPortfolioAsset struct.
      */
     function portfolioDetails() external view returns(UserPortfolioAsset[] memory);

     /**
     @dev Gets the portfolio information for the given asset.
     @param asset - the asset to query.
      */
     function portfolioOf(address asset) external view returns(UserPortfolioAsset memory);

     /**
     @dev Adds or update an asset in the bot's portfolio.
     @param asset - the crypto asset to add/update in the portfolio.
     @param maxCap - the maximum amount of crypto asset to stake to the bot.
     @param iboCap - the maximum amount of crypto asset to stake during the bot's IBO.
     @param weight - the preference index of an asset in the portfolio. This is used
               to calculate the mintable amount of governance shares in accoardance to 
               staked amount. 

               Gven the same USD-worth amount of two assets, the one with higher weight 
               will contribute more to the mintable amount of shares than the other.
      */
     function updatePortfolioAsset(address asset, uint maxCap, uint iboCap, uint weight) external;

     /**
     @dev Removes an asset from the bot's portfolio.
     @param asset - the crypto asset to remove.
     @notice asset could only be removed before the IBO. After that, asset could only be
               remove if there is no tokens of this asset staked to the bot.
      */
     function removePortfolioAsset(address asset) external;

     /**
     @dev Creates vaults for each asset in the portfolio. This method should be called 
          internally by the bot manager.
      */
     function createPortfolioVaults() external;

     /**
     @dev Gets the vaults of certificate tokens in the portfolio.
     @param certToken the certificate token.
     @param account the account to query deposit/reward information
      */
     function certificateVaults(address certToken, address account) external view returns(VaultInfo[] memory);

     /**
     @dev Queries the total staking reward of the specific certificate token of the given account
     @param certToken the certificate token.
     @param account the account to query.
      */
     function stakingReward(address certToken, address account) external view returns(uint);

     /**
     @dev Claims all pending staking rewards of the callers.
      */
     function harvestStakingReward() external; 

     /**
     @dev Moves certificate tokens staked in warm-up vault to regular vault.
          If the tokens are locked, the operation will be reverted.
      */
     function upgradeVault(address certToken) external;

     /**
     @dev Gets the maximum amount of crypto asset that could be staked  to the bot.
     @param asset - the crypto asset to check.
     @return the maximum amount of crypto asset to stake.
      */
     function getMaxStake(address asset) external returns(uint);

     /**
     @dev Stakes an amount of crypto asset to the bot to receive staking certificate tokens.
     @param asset - the asset to stake.
     @param amount - the amount to stake.
      */
     function stake(address asset, uint amount) external;

     /**
     @dev Burns an amount of staking certificates to get back underlying asset.
     @param certToken - the certificate to burn.
     @param amount - the amount to burn.
      */
     function unstake(IDABotCertToken certToken, uint amount) external;

     /**
     @dev Gets the total staking balance of an account for the specific asset.
          The balance includes pending stakes (i.e., warmup) and excludes 
          pending unstakes (i.e., cooldown)
     @param account - the account to query.
     @param asset - the crypto asset to query.
     @return the total staked amount of the asset.
      */
     function stakeBalanceOf(address account, address asset) external view returns(uint);

     /**
     @dev Gets the total pending stake balance of an account for the specific asset.
     @param account - the account to query.
     @param asset - the asset to query.
     @return the total pending stake.
      */
     function warmupBalanceOf(address account, address asset) external view returns(uint);

     /**
     @dev Gets to total pending unstake balance of an account for the specific certificate.
     @param account - the account to query.
     @param certToken - the certificate token to query.
     @return the total pending unstake.
      */
     function cooldownBalanceOf(address account, address certToken) external view returns(uint);

     /**
     @dev Gets the certificate contract of an asset of a bot.
     @param asset - to crypto asset to query.
     @return the address of the certificate contract.
      */
     function certificateOf(address asset) external view returns(address);

     /**
     @dev Gets the underlying asset of a certificate.
     @param certToken - the address of the certificate contract.
     @return the address of the underlying crypto asset.
      */
     function assetOf(address certToken) external view returns(address);

     /**
     @dev Determines whether an account is a certificate locker.
     @param account - the account to check.
     @return true - if the account is an certificate locker instance creatd by the bot.
      */
     function isCertLocker(address account) external view returns(bool);

     /**
     @dev Gets the details of lockers for pending stake.
     @param account - the account to query.
     @return the array of LockerInfo struct.
      */
     function warmupDetails(address account) external view returns(LockerInfo[] memory);

     /**
     @dev Gets the details of lockers for pending unstake.
     @param account - the account to query.
     @return the array of LockerInfo struct.
      */
     function cooldownDetails(address account) external view returns(LockerInfo[] memory);

     /**
     @dev Releases tokens in all pending stake lockers. 
     @notice At most 20 lockers are unlocked. If the caller has more than 20, additional 
          transactions are required.
      */
     function releaseWarmups() external;

     /**
     @dev Releases token in all pending unstake lockers.
     @notice At most 20 lockers are unlocked. If the caller has more than 20, additional 
          transactions are required.
      */
     function releaseCooldowns() external;

     
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DABotCommon.sol";
import "../interfaces/IBotVault.sol";

interface IDABotGovernModuleEvent {
    event MintGToken(address indexed account, uint amountIn, uint fee, uint amountOut, uint updatedRate);
}

interface IDABotGovernModule is IDABotGovernModuleEvent {

    /**
    @dev Creates staking vaults for governance tokens. This method should be called
        internally only by the bot manager.
     */
    function createGovernVaults() external;

    /**
    @dev Gets the vaults of governance tokens.
    @param account - the account to query depsot/reward information
     */
    function governVaults(address account) external view returns(VaultInfo[] memory);

    /**
    @dev Claims all pending governance rewards in all vaults.
     */
    function harvestGovernanceReward() external;

    /**
    @dev Queries the total pending governance rewards in all vaults
    @param account - the account to query.
     */
    function governanceReward(address account) external view returns(uint);

    /**
    @dev Gets the maximum amount of gToken that an account could mint from a bot.
    @param account - the account to query.
    @return the total mintable amount of gToken.
     */
    function mintableShare(address account) external view returns(uint);

    /** 
    @dev Gets the details accounting for the amount of mintable shares.
    @param account the account to query
    @return an array of MintableShareDetail strucs.
     */
    function iboMintableShareDetail(address account) external view returns(MintableShareDetail[] memory); 

    /**
    @dev Calculates the output for an account who mints shares with the given VICS amount.
    @param account - the account to query
    @param vicsAmount - the amount of VICS used to mint shares.
    @return payment - the amount of VICS for minting shares.
            shares - the amount of shares mintied.
            fee - the amount of VICS for minting fee. 
     */
    function calcOutShare(address account, uint vicsAmount) external view returns(uint payment, uint shares, uint fee);

    /**
    @dev Get the total balance of shares owned by the specified account. The total includes
        shares within the account's wallet, and shares staked in bot's vaults.
    @param account - the account to query.
    @return the number of shares.
     */
    function shareOf(address account) external view returns(uint);

    /**
    @dev Mints shares for the given VICS amount. Minted shares will directly stakes to BotVault for rewards.
    @param vicsAmount - the amount of VICS used to mint shared.
    @notice
        Minted shares during IBO will be locked in separated pool, which onlly allow users to withdraw
        after 1 month after the IBO ends.

        VICS for payment will be kept inside the share contracts. Whereas, VICS for fee are transfered
        to the tax address, configured in the platform configurator.
     */
    function mintShare(uint vicsAmount) external;

    /**
    @dev Burns an amount of gToken and sends the corresponding VICS to caller's wallet.
    @param amount - the amount of gToken to burn.
     */
    function burnShare(uint amount) external;

    /**
    @dev Takes a snapshot of current vote powers (i.e. amount of gov)
     */
    function snapshot() external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

uint constant WHITELIST_CHECK_STAKE_USERS = 1;
uint constant WHITELIST_CHECK_GOV_USERS = 2;

interface IDABotWhitelistModuleEvent {
    event WhitelistScope(uint scope);
    event WhitelistAdd(address indexed account, uint scope);
    event WhitelistRemove(address indexed account);
}

interface IDABotWhitelistModule is IDABotWhitelistModuleEvent {

    function whitelistScope() external view returns(uint);
    function setWhitelistScope(uint scope) external;
    function addWhitelist(address account, uint scope) external;
    function removeWhitelist(address account) external;
    function isWhitelist(address acount, uint scope) external view returns(bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DABotCommon.sol";

interface IDABotFundManagerModuleEvent {
    event Award(AwardingDetail[] pnl, uint[] totalStakes, uint[] certTokenValues);
    event AwardCompound(address indexed asset, uint amount, uint mode);
    event AwardBenefitciary(address indexed benefitciary, address indexed portfolioAsset, address indexed awardedAsset, uint amount, uint share, uint totalShare);
    event AddBenefitciary(address indexed benefitciary);
}

interface IDABotFundManagerModule is IDABotFundManagerModuleEvent {
    
    /**
    @dev Gets detailed information about benefitciaries of staking rewards.
     */
    function benefitciaries() external view returns(BenefitciaryInfo[] memory result);

    /**
    @dev Replaces the current bot's benefitciaries with its bot template's
    @notice Only bot owner can call.
     */
    function resetBenefitciaries() external; 

    /**
    @dev Add new benefitciary
    @param benefitciary - the benefitciary address. Should not be added before.
     */
    function addBenefitciary(address benefitciary) external;

    /**
     @dev Add profit/loss for each asset in the portfolio.
     @param pnl - list of AwardingDetail data.
     */
    function award(AwardingDetail[] calldata pnl) external;

    /**
    @dev Checks the pending stake rewarod of a given account for specified assets.
    @param account - the account to check.
    @param assets - the list of assets to check for reward. 
        If empty list is passed, all assets in the portfolio are checked.
    @param subVaults - the list of sub-vaults to check. 
        If empty list is passed, all sub vaults (i.e., [0, 1, 2]) are checked.
     */
    function pendingStakeReward(address account, address[] calldata assets, 
        bytes calldata subVaults) external view returns(StakingReward[] memory);

    /**
    @dev Checks the pending governance rewardsof a given account.
    @param account - the account to check.
    @param subVaults - the lst oof sub-vaults to check. 
        if empty list is passed, all sub vaults (i.e., [0, 1]) are checked.
     */
    function pendingGovernReward(address account, bytes calldata subVaults) external view returns(uint);

    /**
    @dev Withdraws tokens that have been transfered to the bot contract by mistake.
    All balance of the specified token in the bot will be transfered to `to` address.
    @param asset - the IERC20 token contract.
    @param to - the recipient address
     */
    function withdrawToken(address asset, address to) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

bytes32 constant IDABotFarmingModuleID = keccak256("farming.module");
bytes32 constant IDABotFundManagerModuleID = keccak256('fundmanager.module');
bytes32 constant IDABotStakingModuleID = keccak256("staking.module");
bytes32 constant IDABotGovernModuleID = keccak256('governance.module');
bytes32 constant IDABotSettingModuleID = keccak256('setting.module');
bytes32 constant IDABotWhitelistModuleID = keccak256("whitelist.module");

bytes32 constant GovTokenHandlerID = keccak256('govtokenimpl.dabot.module');
bytes32 constant CertTokenHandlerID = keccak256('certtokenimpl.dabot.module');

bytes32 constant BOT_CERT_TOKEN_COOLDOWN_HANDLER_ID = keccak256("cooldown.dabot.module");

bytes32 constant BOT_CERT_TOKEN_TEMPLATE_ID = keccak256("certificate-token.dabot.module");
bytes32 constant BOT_GOV_TOKEN_TEMPLATE_ID = keccak256("governance-token.dabot.module");

//bytes32 constant BOT_MODULE_COOLDOWN_LOCKER = keccak256("cooldown.dabot.module");

interface IDABotComponent {   
    function moduleInfo() external view returns(string memory name, string memory version, bytes32 moduleId);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDABotCertTokenEvent {
    /**
    @dev Triggered when the bot owner locked an amount of certificate token for trading (or yield farming).
    @param assetAmount the amount of the underlying asset locked.
     */
    event Lock(uint assetAmount);

    /**
    @dev Triggered when the bot owner unlocked an amount of certificate token.
    @param assetAmount the amount of the underlying asset unlocked.
     */
    event Unlock(uint assetAmount);

    /**
    @dev Triggered when the amount of pegged assets of this certificate token has been changed.
    @param amount the changed amount.
    @param profitOrLoss true if the the pegged assets increase, false on otherwise.
     */
    event Compound(uint amount, bool profitOrLoss);
}

interface IDABotCertToken is IERC20, IDABotCertTokenEvent {

    function isCertToken() external view returns(bool);

    /**
    @dev Gets the total deposit of the underlying asset within this certificate.
     */
    function totalStake() external view returns(uint);

    function totalLiquid() external view returns(uint);

    /**
    @dev Queries the bot who owned this certificate.
     */
    function owner() external view returns(address);
    
    /**
    @dev Gets the underlying asset of this certificate.
     */
    function asset() external view returns (IERC20);
    
    /**
    @dev Returns the equivalent amount of the underlying asset for the given amount
        of certificate tokens.
    @param certTokenAmount - the amount of certificate tokens.
     */
    function value(uint certTokenAmount) external view returns(uint);

    function lock(uint assetAmount) external;

    function unlock(uint assetAmount) external;

    /**
    @dev Mints an amount of certificate tokens to the given amount. The equivalent of
        underlying asset should be tranfered to this certificate contract by the caller.
    @param account - the address to recieve minted tokens.
    @param certTokenAmount - the amount of tokens to mint.
    @notice Only the owner bot can call this function.
     */
    function mint(address account, uint certTokenAmount) external returns(uint);

    /**
    @dev Burns an amount of certificate tokens, and returns the equivalant amount of
        the underlying asset to the specified account.
    @param account - the address holing certificate tokens to burn.
    @param certTokenAmount - the amount of certificate token to burn.
    @return the equivalent amount of underlying asset tranfered to the specified account.
    @notice Only the owner bot can call this function.
     */
    function burn(address account, uint certTokenAmount) external returns (uint);

    /**
    @dev Burns an amount of certificate tokens, and returns the equivalent amount of the 
        underlying asset to the caller.
    @param amount - the amount of certificate token to burn.
    @return the equivalent amount of underlying asset transfered to the caller.
     */
    function burn(uint amount) external returns(uint);

    /**
    @dev Burns an amount of certificate tokens without returning any underlying assets.
    @param account - the account holding certificate tokens to burn.
    @param amount - the amount of certificate tokens to burn.
    @notice Only owner bot can call this function.
     */
    function slash(address account, uint amount) external;

    /**
    @dev Compound a given amount of the underlying asset to the total deposit. 
        The compoud could be either profit or loss.
    @param amount - the compound amount.
    @param profitOrLoss - `true` to increase the total deposit, `false` to decrease.
     */
    function compound(uint amount, bool profitOrLoss) external;

    /**
    @dev Deletes this certificate token contracts.
     */
    function finalize() external payable;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../token/IRoboFiERC20.sol";

struct VaultData {
    address botToken;
    IERC20 asset;
    address bot;
    uint8 index;                // the index-th vault generated from botToken
                                //  0 - warmup vault, 1 - regular vault, 2 - VIP vault
    bytes4 vaultType;           // type of the vault, used to determine the vault handler
}

struct UserInfo {
    uint deposit;
    uint debtPoints;
    uint debt;
    uint lockPeriod;
    uint lastDepositTime;
}

struct VaultInfo {
    VaultData data;             
    UserInfo user;
    uint totalDeposit;          // total deposits in the vault
    uint accRewardPerShare;     // the pending reward per each unit of deposit
    uint lastRewardTime;        // the block time of the last reward transaction
    uint pendingReward;         // the pending reward for the caller
    bytes option;               // vault option
} 

struct RegularVaultOption {
    bool restricted;    // restrict deposit activity to bot only
}


interface IBotVaultEvent {
    event Deposit(uint vID, address indexed payor, address indexed account, uint amount);
    event Widthdraw(uint vID, address indexed account, uint amount);
    event RewardAdded(uint vID, uint assetAmount);
    event RewardClaimed(uint vID, address indexed account, uint amount);
    event Snapshot(uint vID, uint snapshotId);
}

interface IBotVault is IBotVaultEvent {
    function deposit(uint vID, uint amount) external;
    function delegateDeposit(uint vID, address payor, address account, uint amount, uint lockTime) external;
    function withdraw(uint vID, uint amount) external;
    function delegateWithdraw(uint vID, address account, uint amount) external;
    function pendingReward(uint vID, address account) external view returns(uint);
    function balanceOf(uint vID, address account) external view returns(uint);
    function balanceOfAt(uint vID, address account, uint blockNo) external view returns(uint);
    function updateReward(uint vID, uint assetAmount) external;
    function claimReward(uint vID, address account) external;

    /**
    @dev Queries user deposit info for the given vault.
    @param vID the vault ID to query.
    @param account the user account to query.
     */
    function getUserInfo(uint vID, address account) external view returns(UserInfo memory result);
    function getVaultInfo(uint vID, address account) external view returns(VaultInfo memory);
    function getVaultOption(uint vID) external view returns(bytes memory);
    function setVaultOption(uint vID, bytes calldata option) external;
}

interface IBotVaultManagerEvent is IBotVaultEvent {
    event OpenVault(uint vID, VaultData data);
    event DestroyVault(uint vID);
    event RegisterHandler(bytes4 vaultType, address handler);
    event BotManagerUpdated(address indexed botManager);
}

interface IBotVaultManager is IBotVault, IBotVaultManagerEvent {
    function vaultOf(uint vID) external view returns(VaultData memory result);
    function validVault(uint vID) external view returns(bool);
    function createVault(VaultData calldata data) external returns(uint);
    function destroyVault(uint vID) external;
    function vaultId(address botToken, uint8 vaultIndex) external pure returns(uint);
    function registerHandler(bytes4 vaultType, IBotVault handler) external;
    function botManager() external view returns(address);
    function setBotManager(address account) external;
    function snapshot(uint vID) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRoboFiERC20 is IERC20 {
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRoboFiFactory {
    function deploy(address masterContract, 
                    bytes calldata data, 
                    bool useCreate2) 
        external 
        payable 
        returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library Roles {
    bytes32 constant ROLE_ADMIN = keccak256('operator.dabot.role');
    bytes32 constant ROLE_OPERATORS = keccak256('operator.dabot.role');
    bytes32 constant ROLE_TEMPLATE_CREATOR = keccak256('creator.template.dabot.role');
    bytes32 constant ROLE_BOT_CREATOR = keccak256('creator.dabot.role');
    bytes32 constant ROLE_FUND_APPROVER = keccak256('approver.fund.role');
}

library AddressBook {
    bytes32 constant ADDR_FACTORY = keccak256('factory.address');
    bytes32 constant ADDR_VICS = keccak256('vics.address');
    bytes32 constant ADDR_TAX = keccak256('tax.address');
    bytes32 constant ADDR_GOVERNANCE = keccak256('governance.address');
    bytes32 constant ADDR_GOVERNANCE_EXECUTOR = keccak256('executor.governance.address');
    bytes32 constant ADDR_BOT_MANAGER = keccak256('botmanager.address');
    bytes32 constant ADDR_VICS_EXCHANGE = keccak256('exchange.vics.address');
    bytes32 constant ADDR_TREASURY_MANAGER = keccak256('treasury-manager.address');
    bytes32 constant ADDR_CEX_FUND_MANAGER = keccak256('fund-manager.address');
    bytes32 constant ADDR_CEX_DEFAULT_MASTER_ACCOUNT = keccak256('default.master.address');
    bytes32 constant ADDR_ROBOFI_GAME = keccak256('robofi-game.address');
}

library Config {
    /// The amount of VICS that a proposer has to pay when create a new proposal
    bytes32 constant PROPOSAL_DEPOSIT = keccak256('deposit.proposal.config');

    /// The percentage of proposal creation fee distributed to the account that execute a propsal
    bytes32 constant PROPOSAL_REWARD_PERCENT = keccak256('reward.proposal.config');

    /// The minimum VICS a bot creator has to deposit to a newly created bot
    bytes32 constant CREATOR_DEPOSIT = keccak256('deposit.creator.config');

    /// The minim 
    bytes32 constant PROPOSAL_CREATOR_MININUM_POWER = keccak256('minpower.goverance.config');
    
    /// The minimum percentage of for-votes over total votes a proposal has to achieve to be passed
    bytes32 constant PROPOSAL_MINIMUM_QUORUM = keccak256('minquorum.governance.config');

    /// The minimum difference (in percentage) between for-votes and against-vote for a proposal to be passed
    bytes32 constant PROPOSAL_VOTE_DIFFERENTIAL = keccak256('differential.governance.config');

    /// The voting duration of a proposal
    bytes32 constant PROPOSAL_DURATION = keccak256('duration.goverance.config');

    /// The interval that a passed proposed is waiting in queue before being executed
    bytes32 constant PROPOSAL_EXECUTION_DELAY = keccak256('execdelay.governance.config');

    // Number of winners of RoboFi Game
    bytes32 constant GAME_NUMBER_WINNER = keccak256('num-of-winner.game.config');

    // The commit phase duration of a game
    bytes32 constant GAME_COMMIT_DURATION = keccak256('commit.game.config');

    // The reveal phase duration of a game
    bytes32 constant GAME_REVEAL_DURATION = keccak256('reveal.game.config');
}

interface IConfigurator {
    function addressOf(bytes32 addrId) external view returns(address);
    function configOf(bytes32 configId) external view returns(uint);
    function bytesConfigOf(bytes32 configId) external view returns(bytes memory);

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDefiAdapter {
    function underlying(address platformToken) external view returns(address);
    function amountUnderlying(address platformToken, uint amount) external view returns(uint);
}