// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./libraries/Ownable.sol";
import "./libraries/TransferHelper.sol";
import "./interfaces/IERC20.sol";

contract TransitAllowed is Ownable {

    constructor(address executor) Ownable(executor) {

    }

    event ChangeCallerAllowed(uint8[] flags, address[][] callers);
    event ChangeFunctionAllowed(address[] callers, bytes4[] functions, bool[] newAllowed);
    event ChangeRequireAllowed(bool oldRequireAllowed, bool newRequireAllowed);
    event ChangeRequireFunctionAllowed(address[] callers, bool[] newAllowed);
    event Withdraw(address indexed token, address indexed executor, address indexed recipient, uint amount);
    mapping(uint8 => mapping(address => bool)) private _caller_allowed;
    mapping(address => mapping(bytes4 => bool)) private _function_allowed;
    bool private _requireAllowed;
    mapping(address => bool) private _requireFunctionAllowed;

    function requireAllowed() public view returns (bool) {
        return _requireAllowed;
    }

    function requireFunctionAllowed(address caller) public view returns (bool) {
        return _requireFunctionAllowed[caller];
    }

    function checkAllowed(uint8 flag, address caller, bytes4 fun) public view returns (bool) {
        if (!requireAllowed()) {
            return true;
        }
        bool callerAllowed = _caller_allowed[flag][caller];
        if (requireFunctionAllowed(caller)) {
            bool functionAllowed = _function_allowed[caller][fun];
            return callerAllowed && functionAllowed;
        }
        return callerAllowed;
    }

    function changeRequireAllowed() public onlyExecutor {
        bool oldRequireAllowed = _requireAllowed;
        _requireAllowed = !_requireAllowed;
        emit ChangeRequireAllowed(oldRequireAllowed, _requireAllowed);
    }

    function changeRequireFunctionAllowed(address[] calldata callers) public onlyExecutor {
        bool[] memory newAllowed = new bool[](callers.length);
        for (uint index; index < callers.length; index++) {
            bool oldRequireAllowed = _requireFunctionAllowed[callers[index]];
            _requireFunctionAllowed[callers[index]] = !oldRequireAllowed;
            newAllowed[index] = !oldRequireAllowed;
        }
        emit ChangeRequireFunctionAllowed(callers, newAllowed);
    }

    function changeCallerAllowed(uint8[] calldata flags, address[][] calldata callers) public onlyExecutor {
        for (uint index; index < flags.length; index++) {
            for (uint indexSecond; indexSecond < callers[index].length; indexSecond++) {
                _caller_allowed[flags[index]][callers[index][indexSecond]] = !_caller_allowed[flags[index]][callers[index][indexSecond]];
            }
        }
        emit ChangeCallerAllowed(flags, callers);
    }

    function changeFunctionAllowed(address[] calldata callers, bytes4[] calldata functions) public onlyExecutor {
        bool[] memory newAllowed = new bool[](callers.length);
        for (uint index; index < callers.length; index++) {
            _function_allowed[callers[index]][functions[index]] = !_function_allowed[callers[index]][functions[index]];
        }
        emit ChangeFunctionAllowed(callers, functions, newAllowed);
    }
    
    function withdrawTokens(address[] memory tokens, address recipient) external onlyExecutor {
        for(uint index; index < tokens.length; index++) {
            uint amount;
            if(TransferHelper.isETH(tokens[index])) {
                amount = address(this).balance;
                TransferHelper.safeTransferETH(recipient, amount);
            } else {
                amount = IERC20(tokens[index]).balanceOf(address(this));
                TransferHelper.safeTransferWithoutRequire(tokens[index], recipient, amount);
            }
            emit Withdraw(tokens[index], msg.sender, recipient, amount);
        }
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.9;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

library TransferHelper {
    
    address private constant _ETH_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    address private constant _ZERO_ADDRESS = address(0);
    
    function isETH(address token) internal pure returns (bool) {
        return (token == _ZERO_ADDRESS || token == _ETH_ADDRESS);
    }
    
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_TOKEN_FAILED');
    }
    
    function safeTransferWithoutRequire(address token, address to, uint256 value) internal returns (bool) {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        // solium-disable-next-line
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: TRANSFER_FAILED');
    }

    function safeDeposit(address wrapped, uint value) internal {
        // bytes4(keccak256(bytes('deposit()')));
        (bool success, bytes memory data) = wrapped.call{value:value}(abi.encodeWithSelector(0xd0e30db0));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: DEPOSIT_FAILED');
    }

    function safeWithdraw(address wrapped, uint value) internal {
        // bytes4(keccak256(bytes('withdraw(uint256 wad)')));
        (bool success, bytes memory data) = wrapped.call{value:0}(abi.encodeWithSelector(0x2e1a7d4d, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: WITHDRAW_FAILED');
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)
// Add executor extension

pragma solidity ^0.8.0;

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
abstract contract Ownable {
    address private _owner;
    address private _pendingOwner;
    address private _executor;
    address private _pendingExecutor;
    bool internal _initialized;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ExecutorshipTransferStarted(address indexed previousExecutor, address indexed newExecutor);
    event ExecutorshipTransferred(address indexed previousExecutor, address indexed newExecutor);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address newExecutor) {
        require(!_initialized, "Ownable: initialized");
        _transferOwnership(msg.sender);
        _transferExecutorship(newExecutor);
        _initialized = true;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Throws if called by any account other than the executor.
     */
    modifier onlyExecutor() {
        _checkExecutor();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current executor.
     */
    function executor() public view virtual returns (address) {
        return _executor;
    }

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Returns the address of the pending executor.
     */
    function pendingExecutor() public view virtual returns (address) {
        return _pendingExecutor;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    /**
     * @dev Throws if the sender is not the executor.
     */
    function _checkExecutor() internal view virtual {
        require(executor() == msg.sender, "Ownable: caller is not the executor");
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
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers executorship of the contract to a new account (`newExecutor`).
     * Can only be called by the current executor.
     */
    function transferExecutorship(address newExecutor) public virtual onlyExecutor {
        _pendingExecutor = newExecutor;
        emit ExecutorshipTransferStarted(executor(), newExecutor);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        delete _pendingOwner;
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _transferExecutorship(address newExecutor) internal virtual {
        delete _pendingExecutor;
        address oldExecutor = _executor;
        _executor = newExecutor;
        emit ExecutorshipTransferred(oldExecutor, newExecutor);
    }

    function acceptOwnership() external {
        address sender = msg.sender;
        require(pendingOwner() == sender, "Ownable: caller is not the new owner");
        _transferOwnership(sender);
    }

    function acceptExecutorship() external {
        address sender = msg.sender;
        require(pendingExecutor() == sender, "Ownable: caller is not the new executor");
        _transferExecutorship(sender);
    }
}