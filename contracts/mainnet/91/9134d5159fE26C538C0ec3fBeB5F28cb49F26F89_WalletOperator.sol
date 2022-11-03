// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./wallet.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WalletOperator is Ownable {

    uint256 public fee;

    uint256 public deployCount;

    mapping(address => address[]) wallets;
    mapping(address => mapping(address => bool)) public whitelist;

    struct CallOpt {
        uint256 perValue;

        // 0 pass 
        // 1 revert 
        // 2 finish
        uint256 failedCase;
    }

    // manager method

    function withdraw(address payable receiver, uint256 amount) public onlyOwner {
        receiver.transfer(amount);
    }

    function withdrawToken(address receiver, IERC20 token, uint256 amount) public onlyOwner {
        token.transfer(receiver, amount);
    }

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    // user call method

    function create(uint256 num) public {
        if (num <= 0) {
            return;
        }

        address caller = msg.sender;
        address[] storage wallet = wallets[caller];
        uint256 count = num;
        if (wallet.length <= 0) {
            wallet.push(address(new Wallet(caller, address(this))));
            count -= 1;
        }
        for (uint256 i = 0; i < count; i++) {
            wallet.push(Clones.clone(address(wallet[0])));
        }
        deployCount += num;

        whitelist[caller][caller] = true;
        whitelist[caller][address(this)] = true;
    }


    function invokeBatch(address target, bytes calldata callData, CallOpt calldata opt, address[] calldata addrs) public payable {
        _invoke(target, callData, opt, addrs);
    }

    function invokeAll(address target, bytes calldata callData, CallOpt calldata opt) public payable {
        address[] memory addrs = wallets[msg.sender];
        _invoke(target, callData, opt, addrs);
    }

    function withdrawAll(address payable receiver) public {
        address[] memory addrs = wallets[msg.sender];
        _withdraw(receiver, addrs);
    }

    function withdrawBatch(address payable receiver, address[] calldata addrs) public {
        _withdraw(receiver, addrs);
    }

    function withdrawTokenAll(address payable receiver, IERC20 token) public {
        address [] memory addrs = wallets[msg.sender];
        _withdrawToken(receiver, token, addrs);
    }

    function _invoke(address target, bytes calldata callData, CallOpt calldata opt, address[] memory addrs) internal {
        uint256 size = addrs.length;
        require(size * opt.perValue + fee >= msg.value, "Insufficient amount to pay");

        for (uint256 i = 0; i < size; i++) {
            bool success = Wallet(payable(addrs[i])).invoke{value : opt.perValue}(target, callData);
            if (success == false) {
                if (opt.failedCase == 1) {
                    revert("failed revert tx");
                } else if (opt.failedCase == 2) {
                    return;
                }
            }
        }
    }

    function withdrawTokenBatch(address payable receiver, IERC20 token, address[] calldata addrs) public {
        _withdrawToken(receiver, token, addrs);
    }

    function _withdraw(address payable receiver, address[] memory addrs) internal {
        uint256 size = addrs.length;
        for (uint256 i = 0; i < size; i++) {
            if (address(addrs[i]).balance > 0) {
                Wallet(payable(addrs[i])).withdraw(receiver);
            }
        }
    }

    function _withdrawToken(address payable receiver, IERC20 token, address[] memory addrs) internal {
        uint256 size = addrs.length;
        for (uint256 i = 0; i < size; i++) {
            if (token.balanceOf(addrs[i]) > 0) {
                Wallet(payable(addrs[i])).withdrawToken(receiver, token);
            }
        }
    }

    function changeWhitelist(address[] calldata addrs, bool status) public {
        mapping(address => bool) storage list = whitelist[msg.sender];
        uint256 size = addrs.length;
        for (uint256 i = 0; i < size; i++) {
            if (status) {
                list[addrs[i]] = true;
            } else {
                delete list[addrs[i]];
            }
        }
    }

    // view method

    function userWalletCount(address caller) public view returns (uint256){
        return wallets[caller].length;
    }

    function userWallet(address caller) public view returns (address[] memory){
        return wallets[caller];
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IOperator {
    function whitelist(address, address) external view returns (bool);
}

contract Wallet {

    address public immutable owner;
    address public immutable factory;

    constructor(address _owner, address _factory){
        owner = _owner;
        factory = _factory;
    }

    function invoke(address addr, bytes calldata data)
    public
    payable
    checkCaller
    returns (bool)
    {
        (bool success,) = addr.call{value : msg.value}(data);
        return success;
    }

    function withdraw(address payable receiver) public payable checkCaller {
        receiver.transfer(address(this).balance);
    }

    function withdrawToken(address receiver, IERC20 token) public checkCaller {
        token.transfer(receiver, token.balanceOf(address(this)));
    }

    receive() external payable {}

    modifier checkCaller() {
        require(
            tx.origin == owner && IOperator(factory).whitelist(tx.origin, msg.sender),
            "caller not allow"
        );
        _;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
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