// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./SafeOwnable.sol";

/*
 * @title Contract for adding/removing Pools from subgraph
 */
contract FixedPeriodPoolSubgraphHelper is SafeOwnable {

    event FixedPeriodPoolDeployed(address poolAddress);
    event StartUpdatingStakePPS(address poolAddress);
    event StopUpdatingStakePPS(address poolAddress);

    /*
     * @notice Adds pool to subgraph
     * @param poolAddress Pool address
     * @param updateStakePPS Should we update stakePPS in subgraph for this pool?
     * Use true for reflection tokens as stake tokens
     * @dev Only Owner
     */
    function addPoolToSubgraph(
        address poolAddress,
        bool updateStakePPS
    ) external onlyOwner {
        emit FixedPeriodPoolDeployed(poolAddress);
        // for subgraph
        if (updateStakePPS) {
            emit StartUpdatingStakePPS(poolAddress);
        }
    }


    /*
     * @notice Subgraph starts updating Pool stake PPS
     * @param poolAddress Pool address
     * @dev Only Owner. For subgraph tracking
     */
    function startUpdatingStakePPS(
        address poolAddress
    ) external onlyOwner {
        emit StartUpdatingStakePPS(poolAddress);
    }


    /*
     * @notice Subgraph stops updating Pool stake PPS
     * @param poolAddress Pool address
     * @dev Only Owner. For subgraph tracking
     */
    function stopUpdatingStakePPS(
        address poolAddress
    ) external onlyOwner {
        emit StopUpdatingStakePPS(poolAddress);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {updateOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract SafeOwnable is Context {
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipUpdated(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = _msgSender();
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
        _owner = address(0);
    }

    /**
     * @dev Allows newOwner to claim ownership
     * @param newOwner Address that should become a new owner
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to msg.sender
     */
    function updateOwnership() external {
        _updateOwnership();
    }

    /**
     * @dev Allows newOwner to claim ownership
     * @param newOwner Address that should become a new owner
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _newOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to msg.sender
     * Internal function without access restriction.
     */
    function _updateOwnership() private {
        address oldOwner = _owner;
        address newOwner = _newOwner;
        require(msg.sender == newOwner, "Not a new owner");
        require(oldOwner != newOwner, "Already updated");
        _owner = newOwner;
        emit OwnershipUpdated(oldOwner, newOwner);
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