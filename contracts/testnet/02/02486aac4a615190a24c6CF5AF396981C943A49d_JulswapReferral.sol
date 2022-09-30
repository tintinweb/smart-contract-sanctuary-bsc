// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity =0.6.12;

import '@openzeppelin/contracts/access/Ownable.sol';
import "./common/ReentrancyGuard.sol";
import './libraries/SafeMath.sol';
import './interfaces/IJulswapReferral.sol';
import './libraries/TransferHelper.sol';
import './interfaces/IJulswapERC20.sol';

contract JulswapReferral is IJulswapReferral, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    event SetterAdded(address indexed setter);
    event SetterRemoved(address indexed setter);
    event SwapRecorded(address indexed user, address indexed referrer, address indexed token, uint256 amount);

    mapping(address => bool) private setters;
    mapping(address => address) private referrers;
    mapping(address => uint256) private totals;
    mapping(address => mapping(address => uint256)) private rewards;

    address public factory;
    address private defaultReferrer;

    modifier onlySetter() {
        require(setters[msg.sender], 'JulswapReferral: caller is not the setter');
        _;
    }
    modifier onlyFactory() {
        require(msg.sender==owner() || msg.sender == factory, 'JulswapReferral: caller is not the factory');
        _;
    }

    constructor(address _default) public {
        setters[msg.sender] = true;
        defaultReferrer = _default;
    }

    function getReferrer(address user) external view override returns (address) {
        return referrers[user];
    }

    function register(address user, address referrer) external override onlySetter returns (bool) {
        if (referrer == address(0)) {
            return true;
        }
        if (referrers[user] == address(0)) {
            referrers[user] = referrer;
            emit Registered(user, referrer);
        }
        return true;
    }

    function recordSwap(address user, uint256 amount) external payable override onlySetter returns (bool) {
        address token = msg.sender;
        address referrer = referrers[user];
        totals[token] = totals[token].add(amount);
        if (referrer != address(0)) {
            rewards[token][referrer] = rewards[token][referrer].add(amount);
            emit SwapRecorded(user, referrer, token, amount);
        }
        else {
            rewards[token][defaultReferrer] = rewards[token][defaultReferrer].add(amount);
            emit SwapRecorded(user, defaultReferrer, token, amount);
        }
        return true;
    }

    function referrerReward(address token, address referrer)
        external
        view
        override
        returns (uint256 total, uint256 reward)
    {
        return (totals[token], rewards[token][referrer]);
    }

    // function clearReferrerScore(address token, address referrer) external override onlySetter returns (bool) {
    //     uint256 score = rewards[token][referrer];
    //     if (score > 0) {
    //         totals[token] = totals[token].sub(score);
    //         rewards[token][referrer] = 0;
    //     }
    //     return true;
    // }

    function checkSetter(address account) external view returns (bool) {
        return setters[account];
    }

    function addSetter(address setter) external override onlyFactory {
        if (!setters[setter]) {
            setters[setter] = true;
            emit SetterAdded(setter);
        }
    }

    function removeSetter(address setter) external override onlyFactory {
        if (setters[setter]) {
            setters[setter] = false;
            emit SetterRemoved(setter);
        }
    }

    function  claim(address token) external nonReentrant {
        require(rewards[token][msg.sender]>0, 'JulswapReferral: INSUFFICIENT Reward');
        TransferHelper.safeTransfer(token, msg.sender, rewards[token][msg.sender]);
        rewards[token][msg.sender] =0;
    }

    function setFactory(address _factory) external onlyOwner {
        factory = _factory;
    }

    function setDefault(address _default) external onlyOwner {
        defaultReferrer = _default;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.6.0;

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

    constructor() public {
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
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity =0.6.12;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity =0.6.12;

interface IJulswapReferral {
    event Registered(address indexed user, address indexed referrer);
    event SwapRecorded(
        address indexed user,
        address indexed referrer,
        address token,
        uint256 amount
    );

    function getReferrer(address user) external view returns (address);

    function register(address user, address referrer) external returns (bool);

    function recordSwap(address user, uint256 amount)
        external
        payable
        returns (bool);

    function referrerReward(address token, address referrer)
        external
        view
        returns (uint256 total, uint256 reward);

    // function clearReferrerScore(address token, address referrer)
    //     external
    //     returns (bool);
    

    function addSetter(address setter) external;

    function removeSetter(address setter) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.5.0;

interface IJulswapERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}