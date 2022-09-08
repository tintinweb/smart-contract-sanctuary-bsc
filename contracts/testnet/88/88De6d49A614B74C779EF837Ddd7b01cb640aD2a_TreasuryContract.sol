// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "Ownable.sol";

contract TreasuryContract is Ownable {

    // Array of wallets for payment
    address[] public wallets;

    // Mapping from leader address to percent
    mapping(address => uint256) public paymentsPercent;

    /**
     * @dev Modifier to make a function callable only when the sender is founder
     */
    modifier onlyFounder() {
        require(paymentsPercent[msg.sender] > 0, 'Sender is not founder');
        _;
    }

    /**
     * @dev Constructor, inits founders data
     * @param _addresses - array of founder addresses
     * @param _percents - array of percents
     */
    constructor(address[] memory _addresses, uint256[] memory _percents) {
        require(_addresses.length == _percents.length, "Length of arrays must be equal");

        uint256 percentSum = 0;
        for (uint256 i = 0; i < _percents.length; i++) {
            percentSum += _percents[i];
        }
        require(percentSum == 100, "Wrong summary of percents");

        for (uint256 i = 0; i < _addresses.length; i++ ) {
            wallets.push(_addresses[i]);
            paymentsPercent[_addresses[i]] = _percents[i];
        }
    }

    /**
     * @dev Changes founders data
     * @param _addresses - array of founder addresses
     * @param _percents - array of percents
     */
    function changeFounderData(address[] memory _addresses, uint256[] memory _percents) public onlyOwner {
        require(_addresses.length == wallets.length, "The length of arrays must be equal to the original");
        require(_addresses.length == _percents.length, "Length of arrays must be equal");

        uint256 percentSum = 0;
        for (uint256 i = 0; i < _percents.length; i++) {
            percentSum += _percents[i];
        }
        require(percentSum == 100, "Wrong summary of percents");

        for (uint256 i = 0; i < _addresses.length; i++ ) {
            wallets[i] = _addresses[i];
            paymentsPercent[_addresses[i]] = _percents[i];
        }
    }

    /**
     * @dev Sends payments to referrals
     */
    function sendPayments() public onlyFounder {
        uint256 paymentAmount = address(this).balance;

        for (uint8 i = 0; i < wallets.length; i++) {
            address receiver = wallets[i];
            uint256 payment = (paymentAmount * paymentsPercent[receiver]) / 100;
            payable(receiver).transfer(payment);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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