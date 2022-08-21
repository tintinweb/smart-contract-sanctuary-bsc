// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Coupon is Ownable {

    // UNE == unlimitted no expiry, UBE == unlimitted but expires, LNE == limited no expiry, LAE == limited and expires
    enum CouponType {UNE, UBE, LNE, LAE, NONE}

    struct CouponInfo {
        CouponType coupon_type;
        address couponUser;
        uint256 couponDiscount;
        uint256 couponStart;
        uint256 couponEnd;
        uint256 couponUses;
        uint couponActive;
    }

    //Map the user address to the coupon info
    mapping(address => CouponInfo) public _couponInfo;

    CouponInfo public coupon_info;

    modifier activeCoupon(address _couponUser) {
        require((coupon_info.couponActive == 1), "Your coupon has not been activated!");
        require((coupon_info.couponStart >= block.timestamp), "Your coupon has not started yet!");
        require((coupon_info.couponEnd > block.timestamp)||(coupon_info.couponUses >= 0), "Your coupon is expired!");
        _;
    }

    function setCoupon(address _address, uint256 _couponType, uint256 _expiry, uint256 _discount, uint256 _useCount) public onlyOwner {
        require(_address != coupon_info.couponUser, "Already has a coupon!");
        CouponInfo memory coupon = _couponInfo[_address];
        coupon_info.couponUser = _address;
        coupon_info.couponDiscount = _discount;

        uint256 _couponStart = block.timestamp;
        coupon_info.couponStart = block.timestamp;

        if(_couponType == 1) {
            coupon.coupon_type = CouponType.UNE;
            coupon_info.couponEnd = (_expiry * 9125 days)+_couponStart;
            coupon_info.couponUses = (_useCount*10000);
            coupon_info.couponActive = 1;
        }
        if(_couponType == 2) {
            coupon.coupon_type = CouponType.UBE;
            coupon_info.couponEnd = (_expiry * 1 days)+_couponStart;
            coupon_info.couponUses = _useCount;
            coupon_info.couponActive = 1;
        }
        if(_couponType == 3) {
            coupon.coupon_type = CouponType.LNE;
            coupon_info.couponEnd = (_expiry * 9125 days)+_couponStart;
            coupon_info.couponUses = (_useCount*10000);
            coupon_info.couponActive = 1;
        }
        if(_couponType == 4) {
            coupon.coupon_type = CouponType.LAE;
            coupon_info.couponEnd = (_expiry * 1 days)+_couponStart;
            coupon_info.couponUses = _useCount;
            coupon_info.couponActive = 1;
        }
    }

    function changeEnd (uint256 _newExpiry) public onlyOwner {
        coupon_info.couponEnd = (_newExpiry * 1 days)+coupon_info.couponStart;
        if (coupon_info.couponEnd > 0) {
            coupon_info.couponActive = 1;
        }
    }

    function changeDiscount (uint256 _newDiscount) public onlyOwner {
        coupon_info.couponDiscount = _newDiscount;
    }

    function changeUses (uint256 _newUses) public onlyOwner {
        coupon_info.couponUses = _newUses;
        if (coupon_info.couponUses > 0) {
            coupon_info.couponActive = 1;
        }
    }

    function couponTimeLeft(address _address) public returns(uint256) {
        uint256 remainTime = _couponInfo[_address].couponEnd > block.timestamp ? _couponInfo[_address].couponEnd-block.timestamp : 0;
        if ((coupon_info.couponEnd == 0)||(coupon_info.couponUses == 0)) {
            coupon_info.couponActive = 0;
        }

        return remainTime;
    }

    function getCoupon(address _address) external view returns (uint256 _couponDiscount, uint _couponActive) {
        CouponInfo memory coupon = _couponInfo[_address];

        if(coupon.couponActive == 1 && coupon.couponStart <= block.timestamp && coupon.couponEnd > block.timestamp && coupon.couponUses >= 0) {
            _couponDiscount = coupon.couponDiscount;
            _couponActive = coupon.couponActive;
            coupon.couponUses = coupon.couponUses - 1;
        } else {
            _couponDiscount = 0;
            _couponActive = 0;
        }

        return(_couponDiscount, _couponActive);
    }

    function getCouponDetails(address _address) external view returns (CouponType _coupon_type,address _couponUser, uint256 _couponDiscount, uint256 _couponStart, uint256 _couponEnd, uint256 _couponUses, uint _couponActive) {
        CouponInfo memory coupon = _couponInfo[_address];
        coupon.couponUses = coupon.couponUses - 1;

        if(_address != coupon_info.couponUser) {
            coupon.coupon_type = CouponType.NONE;
            coupon.couponUser = _address;
            coupon.couponDiscount = 0;
            coupon.couponStart - 0;
            coupon.couponEnd = 0;
            coupon.couponUses = 0;
            coupon.couponActive = 0;
            return(coupon.coupon_type, coupon.couponUser, coupon.couponDiscount, coupon.couponStart, coupon.couponEnd, coupon.couponUses, coupon.couponActive);
        } else {
            return(coupon.coupon_type, coupon.couponUser, coupon.couponDiscount, coupon.couponStart, coupon.couponEnd, coupon.couponUses, coupon.couponActive);
        }
    }

    function getCouponDiscount(address _address) external view returns (uint256 _couponDiscount) {
        CouponInfo memory coupon = _couponInfo[_address];
        if (coupon_info.couponActive == 1) {
            _couponDiscount = coupon.couponDiscount;
        } else {
            _couponDiscount == 0;
        }
    }

    function getCouponActive(address _address) external view returns (uint _couponActive) {
        CouponInfo memory coupon = _couponInfo[_address];
        return(coupon.couponActive);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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