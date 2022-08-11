// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "./ContractB.sol";

/**
 * @title Call
 * @dev
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract ContractA is ContractB {
    address public contractB;

    function setContractB(address addr) external onlyOwner {
        contractB = addr;
    }

    function call(
        address addr,
        string calldata func,
        bytes memory input
    ) external returns (bool success, bytes memory result) {
        bytes memory encodeFunc = encodeAll(addr, func, input);
        (success, result) = addr.call(encodeFunc);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Call
 * @dev
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract ContractB is Ownable {
    mapping(address => bool) public contracts;

    function setContract(address contractTarget) external onlyOwner {
        contracts[contractTarget] = true;
    }

    function getSelector(string calldata _func) internal pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }

    function encodeAll(
        address addr,
        string calldata func,
        bytes memory params
    ) internal view returns (bytes memory result) {
        require(contracts[addr], "contract not available");

        bytes memory encodeFunc = abi.encodeWithSelector(getSelector(func));
        result = concat(encodeFunc, params);
    }

    function concat(bytes memory a, bytes memory b)
        internal
        pure
        returns (bytes memory c)
    {
        // Store the length of the first array
        uint alen = a.length;
        // Store the length of BOTH arrays
        uint totallen = alen + b.length;
        // Count the loops required for array a (sets of 32 bytes)
        uint loopsa = (a.length + 31) / 32;
        // Count the loops required for array b (sets of 32 bytes)
        uint loopsb = (b.length + 31) / 32;
        assembly {
            let m := mload(0x40)
            // Load the length of both arrays to the head of the new bytes array
            mstore(m, totallen)
            // Add the contents of a to the array
            for {  let i := 0 } lt(i, loopsa) { i := add(1, i) } { mstore(add(m, mul(32, add(1, i))), mload(add(a, mul(32, add(1, i))))) }
            // Add the contents of b to the array
            for {  let i := 0 } lt(i, loopsb) { i := add(1, i) } { mstore(add(m, add(mul(32, add(1, i)), alen)), mload(add(b, mul(32, add(1, i))))) }
            mstore(0x40, add(m, add(32, totallen)))
            c := m
        }
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