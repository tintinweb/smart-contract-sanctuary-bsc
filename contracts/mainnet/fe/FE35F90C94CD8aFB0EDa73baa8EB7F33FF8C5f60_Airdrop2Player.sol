/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

/***
 * 
 * 
 *    ▄████████  ▄█   ▄█        ▄█       ▄██   ▄      ▄████████    ▄█    █▄       ▄████████    ▄████████    ▄███████▄
 *   ███    ███ ███  ███       ███       ███   ██▄   ███    ███   ███    ███     ███    ███   ███    ███   ███    ███
 *   ███    █▀  ███▌ ███       ███       ███▄▄▄███   ███    █▀    ███    ███     ███    █▀    ███    █▀    ███    ███
 *   ███        ███▌ ███       ███       ▀▀▀▀▀▀███   ███         ▄███▄▄▄▄███▄▄  ▄███▄▄▄      ▄███▄▄▄       ███    ███
 * ▀███████████ ███▌ ███       ███       ▄██   ███ ▀███████████ ▀▀███▀▀▀▀███▀  ▀▀███▀▀▀     ▀▀███▀▀▀     ▀█████████▀
 *          ███ ███  ███       ███       ███   ███          ███   ███    ███     ███    █▄    ███    █▄    ███
 *    ▄█    ███ ███  ███▌    ▄ ███▌    ▄ ███   ███    ▄█    ███   ███    ███     ███    ███   ███    ███   ███
 *  ▄████████▀  █▀   █████▄▄██ █████▄▄██  ▀█████▀   ▄████████▀    ███    █▀      ██████████   ██████████  ▄████▀
 *                   ▀         ▀
 *
 * https://sillysheep.io
 * MIT License
 * ===========
 *
 * Copyright (c) 2022 sillysheep
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/// File: @openzeppelin/contracts/utils/math/SafeMath.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contracts/interface/ISheepProp.sol

pragma solidity ^0.8.0;


interface ISheepProp {

    struct PropInfo {
        uint256 propType; // 1, 2, 3
        uint256 rechargeTimes;
    }
    
    function increaseProp(uint256 _propId, uint256 times) external;

    function getPropInfo(uint256 _propId)
        external view returns(PropInfo memory info);
    
    function mint(
        address to,
        PropInfo calldata _info)
        external returns(uint256);

    function burn(uint256 _propId) external;
}

// File: contracts/interface/IPlayerReward.sol

pragma solidity ^0.8.0;


interface IPlayerReward {
    
    struct Player {
        address addr;
        bytes32 name;
        uint8 nameCount;
        uint256 laff;
        uint256 amount;
        uint256 rreward;
        uint256 allReward;
        uint256 lv1Count;
        uint256 lv2Count;
    }
    
    function settleReward(address from,uint256 amount ) external returns (uint256, address, uint256, address);
    function _pIDxAddr(address from) external view returns(uint256);
    function _plyr(uint256 playerId) external view returns(Player memory player);
    function _pools(address pool) external view returns(bool);
}

// File: contracts/referral/Airdrop2Player.sol


pragma solidity ^0.8.0;



/// @title Airdrop2Player Contract
contract Airdrop2Player is Ownable {
    using SafeMath for uint256;
    bool private initialized;

    IPlayerReward public playerBook;
    ISheepProp public prop;
    
    // type -> times
    mapping(uint256 => uint256) public initTimes;
    // ID -> claim
    mapping (uint256 => bool) public claimed;
    event UpdatePropInitTimes(uint256 propType, uint256 times);
    
    event ClaimProp(
        address sender,
        uint256 playerId,
        uint256 removalPropId,
        uint256 undoPropId,
        uint256 shufflePropId,
        uint256 removalPropId1,
        uint256 undoPropId1,
        uint256 shufflePropId1);

    function initialize(
        address owner_,
        address _prop,
        IPlayerReward playerBook_
        ) external {
        require(!initialized, "initialize: Already initialized!");
        _transferOwnership(owner_);
        initTimes[1] = 37;
        initTimes[2] = 47;
        initTimes[3] = 28;
        prop = ISheepProp(_prop);
        playerBook = playerBook_;
        initialized = true;
    }

    function claim() external {
        (bool canClaim, uint256 pID) = isClaim(msg.sender);
        require(canClaim, "Not register Or already claimed");
        
        uint256 removalPropId = prop.mint(msg.sender, propByType(1));
        uint256 undoPropId = prop.mint(msg.sender, propByType(2));
        uint256 shufflePropId = prop.mint(msg.sender, propByType(3));

        uint256 removalPropId1 = prop.mint(msg.sender, propByType(1));
        uint256 undoPropId1 = prop.mint(msg.sender, propByType(2));
        uint256 shufflePropId1 = prop.mint(msg.sender, propByType(3));
        
        claimed[pID] = true;

        emit ClaimProp(msg.sender, pID,
        removalPropId, undoPropId, shufflePropId,
        removalPropId1, undoPropId1, shufflePropId1);
    }

    function propByType(uint256 propType) internal view returns(ISheepProp.PropInfo memory info) {
        info.propType = propType;
        info.rechargeTimes = initTimes[propType];
    }

    function isClaim(address sender) public view returns (bool canClaim, uint256 pID) {
        canClaim = false;
        pID = playerBook._pIDxAddr(sender);
        if (pID == 0) {
            return(canClaim, pID);
        } else {
            bytes32 name = playerBook._plyr(pID).name;
            if (name == bytes32(0)) {
                return(canClaim, pID);
            }
        }
        canClaim = true;
        if (claimed[pID] == true) {
            canClaim = false;
        }
        return(canClaim, pID);
    }
    function updatePropTimes(uint256 propType, uint256 times) external onlyOwner {
        initTimes[propType] = times;
        emit UpdatePropInitTimes(propType, times);
    }
}