/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

/**
 *Submitted for verification at BscScan.com on 2021-04-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

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

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMathExt {
    function add128(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
        require(c >= a, "uint128: addition overflow");

        return c;
    }

    function sub128(uint128 a, uint128 b) internal pure returns (uint128) {
        require(b <= a, "uint128: subtraction overflow");
        uint128 c = a - b;

        return c;
    }

    function add64(uint64 a, uint64 b) internal pure returns (uint64) {
        uint64 c = a + b;
        require(c >= a, "uint64: addition overflow");

        return c;
    }

    function sub64(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b <= a, "uint64: subtraction overflow");
        uint64 c = a - b;

        return c;
    }

    function safe128(uint256 a) internal pure returns(uint128) {
        require(a < 0x0100000000000000000000000000000000, "uint128: number overflow");
        return uint128(a);
    }

    function safe64(uint256 a) internal pure returns(uint64) {
        require(a < 0x010000000000000000, "uint64: number overflow");
        return uint64(a);
    }

    function safe32(uint256 a) internal pure returns(uint32) {
        require(a < 0x0100000000, "uint32: number overflow");
        return uint32(a);
    }

    function safe16(uint256 a) internal pure returns(uint16) {
        require(a < 0x010000, "uint32: number overflow");
        return uint16(a);
    }
}

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


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
    constructor() internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_msgSender() == _owner, "not owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public {
        require(newOwner != address(0), "newOwner invalid");
        if (_owner != address(0)) {
            require(_msgSender() == _owner, "not owner");
        }
        
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract YiBoxSetting is Ownable {
    address public settingGuardian;

    uint256 public levelMaxV4;
    uint256 public levelMaxV5;
    uint256 public levelMaxV6;
    
    mapping (uint256 => uint256) _levelUpV4;
    mapping (uint256 => uint256) _levelUpV5;
    mapping (uint256 => uint256) _levelUpV6;


    mapping (uint256 => string) _ipfsUrisGeneral; 
    mapping (uint256 => string) _ipfsUrisSpecial;


    constructor() public {
        
    }

    function setSettingGuardian(address addr_) external onlyOwner {
        settingGuardian = addr_;
    }

    modifier onlyGuardian() {
        require(msg.sender == settingGuardian, "not writer");
        _;
    }

    function setMaxLevel(uint256 lvv4_, uint256 lvv5_, uint256 lvv6_) external onlyGuardian {
        require(lvv4_ > levelMaxV4 && lvv4_ < 256, "invalid lvv4");
        require(lvv5_ > levelMaxV5 && lvv5_ < 256, "invalid lvv5");
        require(lvv6_ > levelMaxV6 && lvv6_ < 256, "invalid lvv6");

        levelMaxV4 = lvv4_;
        levelMaxV5 = lvv5_;
        levelMaxV6 = lvv6_;
    }

    function getMaxLevel(uint8 _vLevel) public view returns(uint256 _levelMax) {
        if (_vLevel == 4) {
            _levelMax = levelMaxV4;
        } else if (_vLevel == 5) {
            _levelMax = levelMaxV5;
        } else if (_vLevel == 6) {
            _levelMax = levelMaxV6;
        } else {
            _levelMax = 0;
        }
    }

    // function setUri(uint256 prototype_, string memory uri_) external onlyGuardian {
    //     _ipfsUrisGeneral[prototype_] = uri_;
    // }

    // function setUriSpecial(uint256 tokenId_, string memory uri_, bool remove_) external onlyGuardian {
    //     if (remove_) {
    //         delete _ipfsUrisSpecial[tokenId_];
    //     } else {
    //         _ipfsUrisSpecial[tokenId_] = uri_;
    //     }
    // }

    function setLevelUpV4(
        uint256[] memory lvs_, 
        uint256[] memory countV1_, 
        uint256[] memory countV2_, 
        uint256[] memory countV3_, 
        uint256[] memory countV4self_,
        uint256[] memory levelV4_
    ) public onlyGuardian {
        require(lvs_.length == countV1_.length && lvs_.length == countV2_.length, "invalid param");
        require(lvs_.length == countV3_.length && lvs_.length == countV4self_.length, "invalid param");
        uint256 level;
        for (uint256 i = 0; i < lvs_.length; ++i) {
            level = lvs_[i];
            require(level > 0 && level <= levelMaxV4, "invalid prototype");
            uint256 cfgVal = countV1_[i] + (countV2_[i] << 32) + (countV3_[i] << 64) + (countV4self_[i] << 96) + (levelV4_[i] << 128);
            _levelUpV4[level] = cfgVal;
        }
    }

    function setLevelUpV5(
        uint256[] memory lvs_, 
        uint256[] memory countV1_, 
        uint256[] memory countV2_, 
        uint256[] memory countV3_,
        uint256[] memory countV4_, 
        uint256[] memory levelV4_,
        uint256[] memory countV5self_
    ) public onlyGuardian {
        require(lvs_.length == countV1_.length && lvs_.length == countV2_.length && lvs_.length == countV3_.length, "invalid param");
        require(lvs_.length == countV4_.length && lvs_.length == levelV4_.length && lvs_.length == countV5self_.length, "invalid param");
        uint256 level;
        for (uint256 i = 0; i < lvs_.length; ++i) {
            level = lvs_[i];
            require(level > 0 && level <= levelMaxV5, "invalid prototype");
            uint256 cfgVal = countV1_[i] + (countV2_[i] << 32) + (countV3_[i] << 64) + (countV4_[i] << 96) + (levelV4_[i] << 128) + (countV5self_[i] << 160);
            _levelUpV5[level] = cfgVal;
        }
    }

    function setLevelUpV6(
        uint256[] memory lvs_, 
        uint256[] memory countV1_, 
        uint256[] memory countV2_, 
        uint256[] memory countV3_,
        uint256[] memory countV4_, 
        uint256[] memory levelV4_,
        uint256[] memory countV5_
    ) public onlyGuardian {
        require(lvs_.length == countV1_.length && lvs_.length == countV2_.length && lvs_.length == countV3_.length, "invalid param");
        require(lvs_.length == countV4_.length && lvs_.length == levelV4_.length && lvs_.length == countV5_.length, "invalid param");
        uint256 level;
        for (uint256 i = 0; i < lvs_.length; ++i) {
            level = lvs_[i];
            require(level > 0 && level <= levelMaxV6, "invalid prototype");
            uint256 cfgVal = countV1_[i] + (countV2_[i] << 32) + (countV3_[i] << 64) + (countV4_[i] << 96) + (levelV4_[i] << 128) + (countV5_[i] << 160);
            _levelUpV6[level] = cfgVal;
        }
    }

    function getURI(uint256 tokenId_, uint256 prototype_) external view returns(string memory uri) {
        uri = _ipfsUrisSpecial[tokenId_];
        if (bytes(uri).length < 1) {
            uri = _ipfsUrisGeneral[prototype_];
        } 
    }


    function getLevelUpV4(uint256 currentLevel_) 
        external 
        view 
        returns(
            uint256 countV1,
            uint256 countV2,
            uint256 countV3,
            uint256 countV4Self,
            uint256 levelV4
        ) 
    {
        uint256 cfgVal = _levelUpV4[currentLevel_];
        require(cfgVal > 0 && currentLevel_ < levelMaxV4, "level limited");
        countV1 = cfgVal % 0x0100000000;
        countV2 = (cfgVal >> 32) % 0x0100000000;
        countV3 = (cfgVal >> 64) % 0x0100000000;
        countV4Self = (cfgVal >> 96) % 0x0100000000;
        levelV4 = (cfgVal >> 128) % 0x0100000000;
    }

    function getLevelUpV5(uint256 currentLevel_) 
        external 
        view 
        returns(
            uint256 countV1,
            uint256 countV2,
            uint256 countV3,
            uint256 countV4,
            uint256 levelV4,
            uint256 countV5Self
        ) 
    {
        uint256 cfgVal = _levelUpV5[currentLevel_];
        require(cfgVal > 0 && currentLevel_ < levelMaxV5, "level limited");
        countV1 = cfgVal % 0x0100000000;
        countV2 = (cfgVal >> 32) % 0x0100000000;
        countV3 = (cfgVal >> 64) % 0x0100000000;
        countV4 = (cfgVal >> 96) % 0x0100000000;
        levelV4 = (cfgVal >> 128) % 0x0100000000;
        countV5Self = (cfgVal >> 160) % 0x0100000000;
    }

    function getLevelUpV6(uint256 currentLevel_) 
        external 
        view 
        returns(
            uint256 countV1,
            uint256 countV2,
            uint256 countV3,
            uint256 countV4,
            uint256 levelV4,
            uint256 countV5
        ) 
    {
        uint256 cfgVal = _levelUpV6[currentLevel_];
        require(cfgVal > 0 && currentLevel_ < levelMaxV6, "level limited");
        countV1 = cfgVal % 0x0100000000;
        countV2 = (cfgVal >> 32) % 0x0100000000;
        countV3 = (cfgVal >> 64) % 0x0100000000;
        countV4 = (cfgVal >> 96) % 0x0100000000;
        levelV4 = (cfgVal >> 128) % 0x0100000000;
        countV5 = (cfgVal >> 160) % 0x0100000000;
    }
}