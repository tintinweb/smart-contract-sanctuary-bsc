// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";

contract SidGiftCardVoucher is Ownable {
    uint256 public constant THREE_DIGIT_VOUCHER = 0;
    uint256 public constant FOUR_DIGIT_VOUCHER = 1;
    uint256 public constant FIVE_DIGIT_VOUCHER = 2;

    uint256 public constant THREE_DIGIT_VOUCHER_VALUE = 650 * (10**18);
    uint256 public constant FOUR_DIGIT_VOUCHER_VALUE = 160 * (10**18);
    uint256 public constant FIVE_DIGIT_VOUCHER_VALUE = 5 * (10**18);

    mapping(uint256 => uint256) public voucherValues;

    constructor() {
        voucherValues[THREE_DIGIT_VOUCHER] = THREE_DIGIT_VOUCHER_VALUE;
        voucherValues[FOUR_DIGIT_VOUCHER] = FOUR_DIGIT_VOUCHER_VALUE;
        voucherValues[FIVE_DIGIT_VOUCHER] = FIVE_DIGIT_VOUCHER_VALUE;
    }

    function addCustomizedVoucher(uint256 tokenId, uint256 price) external onlyOwner {
        require(voucherValues[tokenId] == 0, "voucher already exsits");
        voucherValues[tokenId] = price;
    }
    
    function totalValue(uint256[] calldata ids, uint256[] calldata amounts) external view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            total += voucherValues[ids[i]] * amounts[i];
        }
        return total;
    }

    function isValidVoucherIds(uint256[] calldata id) external view returns (bool) {
        for (uint256 i = 0; i < id.length; i++) {
            if (voucherValues[id[i]] == 0) {
                return false;
            }
        }
        return true;
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