pragma solidity ^0.8.0;

import "./BaseCoboSafeModuleAcl.sol";
import "./interface/IAddressAccessControl.sol";

contract OneInchAggregationRouterV5Acl is BaseCoboSafeModuleAcl {
 
    address public tokenWhiteListAcl;
    constructor(address _safeAddress, address _safeModule, address tokenAcl) {
        _setSafeAddressAndSafeModule(_safeAddress, _safeModule);
        tokenWhiteListAcl = tokenAcl;
    }

    function setWhiteListAcl(address acl) external onlyOwner {
        tokenWhiteListAcl = acl;
    }

    function _checkAllAddresses(address[] memory addresses)
        internal
        view
        virtual
    {
        require(IAddressAccessControl(tokenWhiteListAcl).containsAll(addresses), "An unsupported token exists!");
    }

    function _checkAddress(address addr) internal view virtual {
        require(IAddressAccessControl(tokenWhiteListAcl).contains(addr), "An unsupported token exists!");
    }

    function clipperSwapToWithPermit(
        address clipperExchange,
        address payable recipient,
        address srcToken,
        address dstToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 goodUntil,
        bytes32 r,
        bytes32 vs,
        bytes calldata permit
    ) external view onlySelf {
        onlySafeAddress(recipient);
        _checkAddress(srcToken);
        _checkAddress(dstToken);
    }

    function clipperSwap(
        address clipperExchange,
        address srcToken,
        address dstToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 goodUntil,
        bytes32 r,
        bytes32 vs
    ) external view onlySelf {
        _checkAddress(srcToken);
        _checkAddress(dstToken);
    }

    function clipperSwapTo(
        address clipperExchange,
        address payable recipient,
        address srcToken,
        address dstToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 goodUntil,
        bytes32 r,
        bytes32 vs
    ) external view onlySelf {
        onlySafeAddress(recipient);
        _checkAddress(srcToken);
        _checkAddress(dstToken);
    }

    struct SwapDescription {
        address srcToken;
        address dstToken;
        address payable srcReceiver;
        address payable dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
    }

    function swap(
        address executor,
        SwapDescription calldata desc,
        bytes calldata permit,
        bytes calldata data
    ) external view onlySelf {
        onlySafeAddress(desc.dstReceiver);
        _checkAddress(desc.srcToken);
        _checkAddress(desc.dstToken);
    }


    function unoswapToWithPermit(
        address payable recipient,
        address srcToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools,
        bytes calldata permit
    ) external view onlySelf {
        onlySafeAddress(recipient);
        _checkAddress(srcToken);
    }

    function unoswapTo(
        address payable recipient,
        address srcToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) external view onlySelf  {
        onlySafeAddress(recipient);
        _checkAddress(srcToken);
    }


    function unoswap(
        address srcToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) external view onlySelf {
        _checkAddress(srcToken);
    }



    function uniswapV3SwapToWithPermit(
        address payable recipient,
        address srcToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools,
        bytes calldata permit
    ) external view onlySelf {
        onlySafeAddress(recipient);
        _checkAddress(srcToken);
    }

    function uniswapV3Swap(
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) external view onlySelf {
    }

    function uniswapV3SwapTo(
        address payable recipient,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) external view onlySelf {
        onlySafeAddress(recipient);
    }
}

pragma solidity ^0.8.0;

interface IAddressAccessControl {
    function addAddress(address addr) external returns (bool);
    function addAddresses(address[] memory addresses) external;
    function removeAddress(address addr) external returns (bool);
    function contains(address addr) external view returns (bool);
    function containsAll(address[] memory addresses)external view returns (bool);
}

// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

interface AclProtector {
    function check(bytes32 role, uint256 value, bytes calldata data) external returns (bool);
}

pragma solidity ^0.8.0;

import "./interface/AclProtector.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


abstract contract BaseCoboSafeModuleAcl is AclProtector, Ownable {

    address public safeAddress;
    address public safeModule;

    modifier onlySelf() {
        require(address(this) == msg.sender, "Caller is not inner");
        _;
    }

    modifier onlyModule() {
        require(safeModule == msg.sender, "Caller is not the module");
        _;
    }

    function onlySafeAddress(address to) internal view {
        require(to == safeAddress, "to is not allowed");
    }

    fallback() external {
        // 出于安全考虑，当调用到本合约中没有出现的 ACL Method 都会被拒绝
        revert("Unauthorized access");
    }

    function check(
        bytes32 _role,
        uint256 _value,
        bytes calldata data
    ) external onlyModule returns (bool) {
        // 调用 ACL methods
        (bool success, ) = address(this).staticcall(data);
        return success;
    }

    function _setSafeAddressAndSafeModule(address _safeAddress, address _safeModule) internal {
        require(_safeAddress != address(0), "invalid safe address");
        require(_safeModule != address(0), "invalid module address");
        safeAddress = _safeAddress;
        safeModule = _safeModule;
        _transferOwnership(_safeAddress);
    }

    function setSafeAddressAndSafeModule(address _safeAddress, address _safeModule) external onlyOwner {
       _setSafeAddressAndSafeModule(_safeAddress, _safeModule);
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