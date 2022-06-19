// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "../registries/LendingRegistry.sol";
import "../interfaces/IPVault.sol";

contract LendingManager is Ownable, ReentrancyGuard {
    using Math for uint256;

    LendingRegistry public lendingRegistry;
    IPVault public basket;

    event Lend(address indexed underlying, uint256 amount, bytes32 indexed protocol);
    event UnLend(address indexed wrapped, uint256 amount);
    /**
        @notice Constructor
        @param _lendingRegistry Address of the lendingRegistry contract
        @param _basket Address of the pool/vault/basket to manage
    */
    constructor(address _lendingRegistry, address _basket) public {
        require(_lendingRegistry != address(0), "INVALID_LENDING_REGISTRY");
        require(_basket != address(0), "INVALID_BASKET");
        lendingRegistry = LendingRegistry(_lendingRegistry);
        basket = IPVault(_basket);
    }

    /**
        @notice Move underlying to a lending protocol
        @param _underlying Address of the underlying token
        @param _amount Amount of underlying to lend
        @param _protocol Bytes32 protocol key to lend to
    */
    function lend(address _underlying, uint256 _amount, bytes32 _protocol) public onlyOwner nonReentrant {
        // _amount or actual balance, whatever is less
        uint256 amount = _amount.min(IERC20(_underlying).balanceOf(address(basket)));

        //lend token
        (
            address[] memory _targets,
            bytes[] memory _data
        ) = lendingRegistry.getLendTXData(_underlying, amount, _protocol);

        basket.callNoValue(_targets, _data);

        // PIP01 - Remove auto add remove of token in basket.
        // if needed remove underlying from basket
        // (removing if there is 0 balance in pool)
        //removeToken(_underlying);

        // add wrapped token
        //addToken(lendingRegistry.underlyingToProtocolWrapped(_underlying, _protocol));

        emit Lend(_underlying, _amount, _protocol);
    }

    /**
        @notice Unlend wrapped token from its lending protocol
        @param _wrapped Address of the wrapped token
        @param _amount Amount of the wrapped token to unlend
    */
    function unlend(address _wrapped, uint256 _amount) public onlyOwner nonReentrant {
        // unlend token
         // _amount or actual balance, whatever is less
        uint256 amount = _amount.min(IERC20(_wrapped).balanceOf(address(basket)));

        //Unlend token
        (
            address[] memory _targets,
            bytes[] memory _data
        ) = lendingRegistry.getUnlendTXData(_wrapped, amount);
        basket.callNoValue(_targets, _data);

        // PIP01 - Remove auto add/remove of token in basket
        // // if needed add underlying
        // addToken(lendingRegistry.wrappedToUnderlying(_wrapped));

        // // if needed remove wrapped
        // removeToken(_wrapped);

        emit UnLend(_wrapped, _amount);
    }

    /**
        @notice Unlend and immediately lend in a different protocol
        @param _wrapped Address of the wrapped token to bounce to another protocol
        @param _amount Amount of the wrapped token to bounce to the other protocol
        @param _toProtocol Protocol to deposit bounced tokens in
        @dev Uses reentrency protection of unlend() and lend()
    */
    function bounce(address _wrapped, uint256 _amount, bytes32 _toProtocol) external {
       unlend(_wrapped, _amount);
       // Bounce all to new protocol
       lend(lendingRegistry.wrappedToUnderlying(_wrapped), type(uint256).max, _toProtocol);
    }

    function removeToken(address _token) internal {
        uint256 balance = basket.balance(_token);
        bool inPool = basket.getTokenInPool(_token);
        //if there is a token balance of the token is not in the pool, skip
        if(balance != 0 || !inPool) {
            return;
        }

        // remove token
        basket.singleCall(address(basket), abi.encodeWithSelector(basket.removeToken.selector, _token), 0);
    }

    function addToken(address _token) internal {
        uint256 balance = basket.balance(_token);
        bool inPool = basket.getTokenInPool(_token);
        // If token has no balance or is already in the pool, skip
        if(balance == 0 || inPool) {
            return;
        }

        // add token
        basket.singleCall(address(basket), abi.encodeWithSelector(basket.addToken.selector, _token), 0);
    }
 
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
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
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.8.1;


import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ILendingLogic.sol";

// TODO consider making this contract upgradeable
contract LendingRegistry is Ownable {

    // Maps wrapped token to protocol
    mapping(address => bytes32) public wrappedToProtocol;
    // Maps wrapped token to underlying
    mapping(address => address) public wrappedToUnderlying;

    mapping(address => mapping(bytes32 => address)) public underlyingToProtocolWrapped;

    // Maps protocol to addresses containing lend and unlend logic
    mapping(bytes32 => address) public protocolToLogic;

    event WrappedToProtocolSet(address indexed wrapped, bytes32 indexed protocol);
    event WrappedToUnderlyingSet(address indexed wrapped, address indexed underlying);
    event ProtocolToLogicSet(bytes32 indexed protocol, address indexed logic);
    event UnderlyingToProtocolWrappedSet(address indexed underlying, bytes32 indexed protocol, address indexed wrapped);

    /**
        @notice Set which protocl a wrapped token belongs to
        @param _wrapped Address of the wrapped token
        @param _protocol Bytes32 key of the protocol
    */
    function setWrappedToProtocol(address _wrapped, bytes32 _protocol) onlyOwner external {
        wrappedToProtocol[_wrapped] = _protocol;
        emit WrappedToProtocolSet(_wrapped, _protocol);
    }

    /**
        @notice Set what is the underlying for a wrapped token
        @param _wrapped Address of the wrapped token
        @param _underlying Address of the underlying token
    */
    function setWrappedToUnderlying(address _wrapped, address _underlying) onlyOwner external {
        wrappedToUnderlying[_wrapped] = _underlying;
        emit WrappedToUnderlyingSet(_wrapped, _underlying);
    }

    /**
        @notice Set the logic contract for the protocol
        @param _protocol Bytes32 key of the procol
        @param _logic Address of the lending logic contract for that protocol
    */
    function setProtocolToLogic(bytes32 _protocol, address _logic) onlyOwner external {
        protocolToLogic[_protocol] = _logic;
        emit ProtocolToLogicSet(_protocol, _logic);
    }

    /**
        @notice Set the wrapped token for the underlying deposited in this protocol
        @param _underlying Address of the unerlying token
        @param _protocol Bytes32 key of the protocol
        @param _wrapped Address of the wrapped token
    */
    function setUnderlyingToProtocolWrapped(address _underlying, bytes32 _protocol, address _wrapped) onlyOwner external {
        underlyingToProtocolWrapped[_underlying][_protocol] = _wrapped;
        emit UnderlyingToProtocolWrappedSet(_underlying, _protocol, _wrapped);
    }

    /**
        @notice Get tx data to lend the underlying amount in a specific protocol
        @param _underlying Address of the underlying token
        @param _amount Amount to lend
        @param _protocol Bytes32 key of the protocol
        @return targets Addresses of the contracts to call
        @return data Calldata for the calls
    */
    function getLendTXData(address _underlying, uint256 _amount, bytes32 _protocol) external view returns(address[] memory targets, bytes[] memory data) {
        ILendingLogic lendingLogic = ILendingLogic(protocolToLogic[_protocol]);
        require(address(lendingLogic) != address(0), "NO_LENDING_LOGIC_SET");

        return lendingLogic.lend(_underlying, _amount);
    }

    /**
        @notice Get the tx data to unlend the wrapped amount
        @param _wrapped Address of the wrapped token
        @param _amount Amount of wrapped token to unlend
        @return targets Addresses of the contracts to call
        @return data Calldata for the calls
    */
    function getUnlendTXData(address _wrapped, uint256 _amount) external view returns(address[] memory targets, bytes[] memory data) {
        ILendingLogic lendingLogic = ILendingLogic(protocolToLogic[wrappedToProtocol[_wrapped]]);
        require(address(lendingLogic) != address(0), "NO_LENDING_LOGIC_SET");

        return lendingLogic.unlend(_wrapped, _amount);
    }

    /**
        @notice Get the beste apr for the give protocols
        @dev returns default values if lending logic not found
        @param _underlying Address of the underlying token
        @param _protocols Array of protocols to include
        @return apr The APR
        @return protocol Protocol that provides the APR
    */
    function getBestApr(address _underlying, bytes32[] memory _protocols) external view returns(uint256 apr, bytes32 protocol) {
        uint256 bestApr;
        bytes32 bestProtocol;

        for(uint256 i = 0; i < _protocols.length; i++) {
            bytes32 protocol = _protocols[i];
            ILendingLogic lendingLogic = ILendingLogic(protocolToLogic[protocol]);
            require(address(lendingLogic) != address(0), "NO_LENDING_LOGIC_SET");

            uint256 apr = lendingLogic.getAPRFromUnderlying(_underlying);
            if (apr > bestApr) {
                bestApr = apr;
                bestProtocol = protocol;
            }
        }

        return (bestApr, bestProtocol);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPVault is IERC20 {
    
    function mint(uint256 amount) external returns (bool);

    function burn(uint256 amount) external returns (bool);

    function joinPool(uint256 _amount, bool _lending) external returns (uint256);

    function exitPool(uint256 _amount) external returns(uint256);

    function calcOutStandingAnnualizedFee() external view returns(uint256);

    function chargeOutstandingAnnualizedFee() external;

    /* ==========  View Functions  ========== */

    function getLock() external view returns(bool);

    function balance(address _token) external view returns(uint256);

    function calcTokensForAmount(uint256 _amount) external view 
        returns (address[] memory, uint256[] memory);

    function calcTokensForAmountExit(uint256 _amount) external view 
        returns (address[] memory tokensArray, uint256[] memory amounts);

    function getTokenInPool(address _token) external view returns(bool);

    /* ==========  Configs  ========== */
    function setLock(uint256 _lock) external;

    function setEntryFee(uint256 _fee) external;

    function setExitFee(uint256 _fee) external;

    function setAnnualizedFee(uint256 _fee) external;
    
    function setFeeBeneficiary(address _beneficiary) external;

    function setEntryFeeBeneficiaryShare(uint256 _share) external;

    function setExitFeeBeneficiaryShare(uint256 _share) external;

    function setCap(uint256 _maxCap) external;

    function setMinBalanceAmt(uint256 _minBal) external;

    function addToken(address _token) external;

    function removeToken(address _token) external;

    function setTokenWeight(address _token, uint256 _weight) external;

    function setLendingRegistry(address _lendingRegistry) external;

    function setLendingManager(address _lendingManager) external;

    function setUnderlyingToProtocol(address _underlying, bytes32 _protocol) external;

    function removeProtocolFromUnderlying(address _underlying) external;

    function addCaller(address _caller) external;

    function removeCaller(address _caller) external;

    /* ==========  Call Functions  ========== */
    function call(address[] memory _targets, bytes[] memory _calldata, uint256[] memory _values) external;

    function callNoValue(address[] memory _targets, bytes[] memory _calldata) external;

    function singleCall(address _target, bytes calldata _calldata, uint256 _value) external;

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
pragma solidity ^0.8.1;

interface ILendingLogic {
    /**
        @notice Get the APR based on underlying token.
        @param _token Address of the underlying token
        @return Interest with 18 decimals
    */
    function getAPRFromUnderlying(address _token) external view returns(uint256);

    /**
        @notice Get the APR based on wrapped token.
        @param _token Address of the wrapped token
        @return Interest with 18 decimals
    */
    function getAPRFromWrapped(address _token) external view returns(uint256);

    /**
        @notice Get the calls needed to lend.
        @param _underlying Address of the underlying token
        @param _amount Amount of the underlying token
        @return targets Addresses of the contracts to call
        @return data Calldata of the calls
    */
    function lend(address _underlying, uint256 _amount) external view returns(address[] memory, bytes[] memory);

    /**
        @notice Get the calls needed to unlend
        @param _wrapped Address of the wrapped token
        @param _amount Amount of the underlying tokens
        @return targets Addresses of the contracts to call
        @return data Calldata of the calls
    */
    function unlend(address _wrapped, uint256 _amount) external view returns(address[] memory, bytes[] memory);

    /**
        @notice Get the underlying wrapped exchange rate
        @param _wrapped Address of the wrapped token
        @return The exchange rate
    */
    function exchangeRate(address _wrapped) external returns(uint256);

    /**
        @notice Get the underlying wrapped exchange rate in a view (non state changing) way
        @param _wrapped Address of the wrapped token
        @return The exchange rate
    */
    function exchangeRateView(address _wrapped) external view returns(uint256);
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