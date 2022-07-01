/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

pragma solidity ^0.8.0;

/// @title bit library
/// @notice old school bit bits
library bits {

    /// @notice check if only a specific bit is set
    /// @param slot the bit storage slot
    /// @param bit the bit to be checked
    /// @return return true if the bit is set
    function only(uint slot, uint bit) internal pure returns (bool) {
        return slot == bit;
    }

    /// @notice checks if all bits ares set and cleared
    function all(uint slot, uint set_, uint cleared_) internal pure returns (bool) {
        return all(slot, set_) && !all(slot, cleared_);
    }

    /// @notice checks if any of the bits_ are set
    /// @param slot the bit storage to slot
    /// @param bits_ the or list of bits_ to slot
    /// @return true of any of the bits_ are set otherwise false
    function any(uint slot, uint bits_) internal pure returns(bool) {
        return (slot & bits_) != 0;
    }

    /// @notice checks if any of the bits are set and all of the bits are cleared
    function check(uint slot, uint set_, uint cleared_) internal pure returns(bool) {
        return slot != 0 ?  ((set_ == 0 || any(slot, set_)) && (cleared_ == 0 || !all(slot, cleared_))) : (set_ == 0 || any(slot, set_));
    }

    /// @notice checks if all of the bits_ are set
    /// @param slot the bit storage
    /// @param bits_ the list of bits_ required
    /// @return true if all of the bits_ are set in the sloted variable
    function all(uint slot, uint bits_) internal pure returns(bool) {
        return (slot & bits_) == bits_;
    }

    /// @notice set bits_ in this storage slot
    /// @param slot the storage slot to set
    /// @param bits_ the list of bits_ to be set
    /// @return a new uint with bits_ set
    /// @dev bits_ that are already set are not cleared
    function set(uint slot, uint bits_) internal pure returns(uint) {
        return slot | bits_;
    }

    function toggle(uint slot, uint bits_) internal pure returns (uint) {
        return slot ^ bits_;
    }

    function isClear(uint slot, uint bits_) internal pure returns(bool) {
        return !all(slot, bits_);
    }

    /// @notice clear bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared
    function clear(uint slot, uint bits_) internal pure returns(uint) {
        return slot & ~(bits_);
    }

    /// @notice clear & set bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared and set
    function reset(uint slot, uint bits_) internal pure returns(uint) {
        slot = clear(slot, type(uint).max);
        return set(slot, bits_);
    }

}

/// @notice Emitted when a check for
error FlagsInvalid(address account, uint256 set, uint256 cleared);

/// @title UsingFlags contract
/// @notice Use this contract to implement unique permissions or attributes
/// @dev you have up to 255 flags you can use. Be careful not to use the same flag more than once. Generally a preferred approach is using
///      pure virtual functions to implement the flags in the derived contract.
abstract contract UsingFlags {
    /// @notice a helper library to check if a flag is set
    using bits for uint256;
    event FlagsChanged(address indexed, uint256, uint256);

    /// @notice checks of the required flags are set or cleared
    /// @param account_ the account to check
    /// @param set_ the flags that must be set
    /// @param cleared_ the flags that must be cleared
    modifier requires(address account_, uint256 set_, uint256 cleared_) {
        if (!(_getFlags(account_).check(set_, cleared_))) revert FlagsInvalid(account_, set_, cleared_);
        _;
    }

    /// @notice getFlags returns the currently set flags
    /// @param account_ the account to check
    function getFlags(address account_) public view returns (uint256) {
        return _getFlags(account_);
    }

    function _getFlags(address account_) internal view returns (uint256) {
        return _getFlagStorage()[uint256(uint160(account_))];
    }

    /// @notice set and clear flags for the given account
    /// @param account_ the account to modify flags for
    /// @param set_ the flags to set
    /// @param clear_ the flags to clear
    function _setFlags(address account_, uint256 set_, uint256 clear_) internal virtual {
        uint256 before = _getFlags(account_);
        _getFlagStorage()[uint256(uint160(account_))] = _getFlags(account_).set(set_).clear(clear_);
        emit FlagsChanged(account_, before, _getFlags(account_));
    }

    /// @notice get the storage for flags
    function _getFlagStorage() internal view virtual returns (mapping(uint256 => uint256) storage);

}

abstract contract UsingDefaultFlags is UsingFlags {
    using bits for uint256;

    /// @notice the value of the initializer flag
    function _INITIALIZED_FLAG() internal pure virtual returns (uint256) {
        return 1 << 255;
    }

    function _TRANSFER_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return _INITIALIZED_FLAG() >> 1;
    }

    function _PROVIDER_FLAG() internal pure virtual returns (uint256) {
        return _TRANSFER_DISABLED_FLAG() >> 1;
    }

    function _SERVICE_FLAG() internal pure virtual returns (uint256) {
        return _PROVIDER_FLAG() >> 1;
    }

    function _NETWORK_FLAG() internal pure virtual returns (uint256) {
        return _SERVICE_FLAG() >> 1;
    }

    function _SERVICE_EXEMPT_FLAG() internal pure virtual returns(uint256) {
        return _NETWORK_FLAG() >> 1;
    }

    function _PROCESSING_FLAG() internal pure virtual returns (uint256) {
        return _SERVICE_EXEMPT_FLAG() >> 1;
    }

    function _ADMIN_FLAG() internal virtual pure returns (uint256) {
        return _PROCESSING_FLAG() >> 1;
    }

    function _BLOCKED_FLAG() internal pure virtual returns (uint256) {
        return _ADMIN_FLAG() >> 1;
    }

    function _ROUTER_FLAG() internal pure virtual returns (uint256) {
        return _BLOCKED_FLAG() >> 1;
    }

    function _SERVICE_FEE_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _ROUTER_FLAG() >> 1;
    }

    function _SERVICES_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return _SERVICE_FEE_EXEMPT_FLAG() >> 1;
    }

    function _FEE_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _SERVICES_DISABLED_FLAG() >> 1;
    }

    function _isFeeExempt(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).all(_FEE_EXEMPT_FLAG());
    }

    function _isServiceFeeExempt(address from_, address to_) internal view virtual returns (bool) {
        return _getFlags(from_).all(_SERVICE_FEE_EXEMPT_FLAG()) || _getFlags(to_).all(_SERVICE_FEE_EXEMPT_FLAG());
    }

    function _isServiceExempt(address from_, address to_) internal view virtual returns (bool) {
        return _getFlags(from_).all(_SERVICE_EXEMPT_FLAG()) || _getFlags(to_).all(_SERVICE_EXEMPT_FLAG());
    }
}

/// @title UsingFlagsWithStorage contract
/// @dev use this when creating a new contract
abstract contract UsingFlagsWithStorage is UsingFlags {
    using bits for uint256;

    /// @notice the mapping to store the flags
    mapping(uint256 => uint256) internal _flags;

    function _getFlagStorage() internal view override returns (mapping(uint256 => uint256) storage) {
        return _flags;
    }
}

abstract contract UsingAdmin is UsingFlags, UsingDefaultFlags {

    function _initializeAdmin(address admin_) internal virtual {
        _setFlags(admin_, _ADMIN_FLAG(), 0);
    }

    function setFlags(address account_, uint256 set_, uint256 clear_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _setFlags(account_, set_, clear_);
    }

}

abstract contract CPTXFlags is UsingFlags, UsingDefaultFlags, UsingAdmin {
    using bits for uint256;

    function _TRANSFER_LIMIT_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return 1 << 128;
    }

    function _LP_PAIR_FLAG() internal pure virtual returns (uint256) {
        return _TRANSFER_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _REWARD_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _LP_PAIR_FLAG() >> 1;
    }

    function _TRANSFER_LIMIT_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _REWARD_EXEMPT_FLAG() >> 1;
    }

    function _ACCOUNT_FLAG() internal pure virtual returns (uint256) {
        return _ROUTER_FLAG() >> 1;
    }

    function _isLPPair(address from_, address to_) internal view virtual returns (bool) {
        return _isLPPair(from_) || _isLPPair(to_);
    }

    function _isLPPair(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).check(_LP_PAIR_FLAG(), 0);
    }

    function _isTransferLimitEnabled() internal view virtual returns (bool) {
        return _getFlags(address(this)).check(0, _TRANSFER_LIMIT_DISABLED_FLAG());
    }

    function _isRewardExempt(address account_) internal view virtual returns (bool) {
        return account_ == address(0) ||  _getFlags(account_).check(_REWARD_EXEMPT_FLAG(), 0);
    }

    function _isTransferLimitExempt(address account_) internal view virtual returns (bool) {
        return _isTransferLimitEnabled() && _getFlags(account_).check(_TRANSFER_LIMIT_EXEMPT_FLAG(), 0);
    }

    function _isRouter(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).check(_ROUTER_FLAG(), 0);
    }

    function _checkFlags(address account_, uint set_, uint cleared_) internal view returns (bool) {
        return _getFlags(account_).check(set_, cleared_);
    }

}

contract CPTXFlagsWithStorage is UsingFlagsWithStorage, CPTXFlags {
    using bits for uint256;

}

/// @notice This error is emitted when attempting to use the initializer twice
error InitializationRecursion();

/// @title UsingInitializer
/// @notice Use this contract in conjunction with UsingUUPS to allow initialization instead of construction
/// @author FYB3R STUDIOS
abstract contract UsingInitializer is UsingFlags, UsingDefaultFlags {
    using bits for uint256;

    /// @notice modifier to prevent double initialization
    modifier initializer() {
        if (_getFlags(address(this)).all(_INITIALIZED_FLAG())) revert InitializationRecursion();
        _;
        _setFlags(address(this), _INITIALIZED_FLAG(), 0);
    }

    /// @notice helper function to check if the contract has been initialized
    function initialized() public view returns (bool) {
        return _getFlags(address(this)).all(_INITIALIZED_FLAG());
    }

}

interface IService {

    function process(address from_, address to_, uint256 amount) external payable returns (uint256);
    function withdraw() external;
    function fee() external view returns (uint24);
    function provider() external view returns (address);
    function providerFee() external view returns (uint24);
}

interface IServiceProvider is IService {

    function removeServices(address[] memory services_) external;
    function addServices(address[] memory services_, uint256[] memory fees_) external;
    function setServiceFee(address service_, uint256 value_) external;
    function services() external view returns (address[] memory);
}

error Unauthorized();
contract CPTXAdmin is CPTXFlagsWithStorage, UsingInitializer {
    using bits for uint256;

    address public swapService;
    address public token;
    address public liquidityService;
    address public rewardsService;

    modifier requiresAdmin() {
        if (!_getFlags(msg.sender).all(_ADMIN_FLAG())) revert Unauthorized();
        _;
    }

    function initialize() external initializer {
        _initializeAdmin(msg.sender);
    }

    function setSwapService(address swap_) external requiresAdmin {
        swapService = swap_;
    }

    function setToken(address token_) external requiresAdmin {
        token = token_;
    }

    function setLiquidityService(address liquidityService_) external requiresAdmin {
        liquidityService = liquidityService_;
    }

    function setRewardsService(address rewardsService_) external requiresAdmin {
        rewardsService = rewardsService_;
    }

    function disableTransfers() external requiresAdmin {
        UsingAdmin(token).setFlags(token, _TRANSFER_DISABLED_FLAG(), 0);
    }

    function enableTransfer() external requiresAdmin {
        UsingAdmin(token).setFlags(token, 0, _TRANSFER_DISABLED_FLAG());
    }

    function setAdmin(address account_, address service_) external requiresAdmin {
        _setFlags(account_, _ADMIN_FLAG(), 0);
    }

    function setRewardsPercentage(address service_, uint256 fee_) external requiresAdmin {
        IServiceProvider(swapService).setServiceFee(service_, fee_);
    }

    function addServices(address[] memory services_, uint256[] memory fees_) external requiresAdmin {
        IServiceProvider(swapService).addServices(services_, fees_);
    }

    function removeServices(address[] memory services_) external requiresAdmin {
        IServiceProvider(swapService).removeServices(services_);
    }

    function setLPPair(address account_) external requiresAdmin {
        UsingAdmin(token).setFlags(token, _LP_PAIR_FLAG(), 0);
        UsingAdmin(swapService).setFlags(token, _LP_PAIR_FLAG(), 0);
        UsingAdmin(liquidityService).setFlags(token, _LP_PAIR_FLAG(), 0);
        UsingAdmin(rewardsService).setFlags(token, _LP_PAIR_FLAG(), 0);
    }

    function exemptFromRewards(address account_) external requiresAdmin {
        UsingAdmin(token).setFlags(token, _REWARD_EXEMPT_FLAG(), 0);
        UsingAdmin(swapService).setFlags(token, _REWARD_EXEMPT_FLAG(), 0);
        UsingAdmin(liquidityService).setFlags(token, _REWARD_EXEMPT_FLAG(), 0);
        UsingAdmin(rewardsService).setFlags(token, _REWARD_EXEMPT_FLAG(), 0);
    }

    function blockAccount(address account_) external requiresAdmin {
        UsingAdmin(token).setFlags(token, _BLOCKED_FLAG(), 0);
        UsingAdmin(swapService).setFlags(token, _BLOCKED_FLAG(), 0);
        UsingAdmin(liquidityService).setFlags(token, _BLOCKED_FLAG(), 0);
        UsingAdmin(rewardsService).setFlags(token, _BLOCKED_FLAG(), 0);
    }

    function exemptFromServices(address account_) external requiresAdmin {
        UsingAdmin(token).setFlags(token, _SERVICE_EXEMPT_FLAG(), 0);
    }

    function exemptFromFees(address account_) external requiresAdmin {
        UsingAdmin(token).setFlags(token, _FEE_EXEMPT_FLAG(), 0);
    }

    function destroy() external requiresAdmin {
        UsingAdmin(token).setFlags(address(this), 0, _ADMIN_FLAG());
        UsingAdmin(swapService).setFlags(address(this), 0, _ADMIN_FLAG());
        UsingAdmin(liquidityService).setFlags(address(this), 0, _ADMIN_FLAG());
        UsingAdmin(rewardsService).setFlags(address(this), 0, _ADMIN_FLAG());
        selfdestruct(payable(msg.sender));
    }

}