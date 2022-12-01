// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/ICompassCollect.sol";
import "./CompassWallet.sol";


contract CompassCollect is ICompassCollect, Ownable {

    bytes32 public constant WALLET_INIT_CODE_HASH = keccak256(abi.encodePacked(type(CompassWallet).creationCode));

    address payable public override recipient;
    address public override useToken;
    bool private lock;

    constructor(address payable _recipient) {
        recipient = _recipient;
    }

    function setRecipient(address payable _recipient) external override onlyOwner {
        recipient = _recipient;
    }

    modifier ensure(address token) {
        require(!lock, "CompassCollect: locked");
        useToken = token;
        lock = true;
        _;
        useToken = address(0);
        lock = false;
    }

    function collect(address token, bytes32[] memory salts) external override ensure(token) {
        bytes memory bytecode = type(CompassWallet).creationCode;
        for (uint8 i = 0; i < salts.length; i++) {
            bytes32 salt = salts[i];
            address addr;
            assembly {
                addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            }
            require(addr != address(0), "Create2: Failed on deploy");
        }
    }

    function getBalance(address token, bytes32[] memory salts) external override view returns (uint[] memory){
        uint[] memory balance = new uint[](salts.length);
        for (uint8 i = 0; i < salts.length; i++) {
            bytes32 salt = salts[i];
            address addr = computeAddress(salt);
            balance[i] = IERC20(token).balanceOf(addr);
        }
        return balance;
    }

    function computeAddress(bytes32 salt) public override view returns (address addr) {
        address deployer = address(this);
        bytes32 bytecodeHash = WALLET_INIT_CODE_HASH;
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer)
            let start := add(ptr, 0x0b)
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./interfaces/ICompassCollect.sol";

contract CompassWallet {

    constructor() {
        address token = ICompassCollect(msg.sender).useToken();
        address recipient = ICompassCollect(msg.sender).recipient();

        if (token != address(0)) {
            uint balance = IERC20(token).balanceOf(address(this));
            if (balance > 0) {
                IERC20(token).transfer(recipient, balance);
            }
        }

        selfdestruct(payable(recipient));
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >= 0.6.0;

interface ICompassCollect {

    function recipient() external view returns (address payable);

    function useToken() external view returns (address);

    function setRecipient(address payable _recipient) external;

    function collect(address token, bytes32[] memory salts) external;

    function getBalance(address token, bytes32[] memory salts) external view returns (uint[] memory);

    function computeAddress(bytes32 salt) external view returns (address addr);
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

pragma solidity >= 0.6.0;

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

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