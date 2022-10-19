/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

// Sources flattened with hardhat v2.9.6 https://hardhat.org

// File contracts/MultiSigOwner.sol

// SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;
pragma abicoder v2;

// 2/3 Multi Sig Owner
contract MultiSigOwner {
    address[] public owners;
    mapping(uint256 => bool) public signatureId;
    bool private initialized;
    // events
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event SignValidTimeChanged(uint256 newValue);
    modifier validSignOfOwner(
        bytes calldata signData,
        bytes calldata keys,
        string memory functionName
    ) {
        require(isOwner(msg.sender), "on");
        address signer = getSigner(signData, keys);
        require(
            signer != msg.sender && isOwner(signer) && signer != address(0),
            "is"
        );
        (bytes4 method, uint256 id, uint256 validTime, ) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        require(
            signatureId[id] == false &&
                method == bytes4(keccak256(bytes(functionName))),
            "sru"
        );
        require(validTime > block.timestamp, "ep");
        signatureId[id] = true;
        _;
    }

    function isOwner(address addr) public view returns (bool) {
        bool _isOwner = false;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == addr) {
                _isOwner = true;
            }
        }
        return _isOwner;
    }

    constructor() {}

    function initializeOwners(address[3] memory _owners) public {
        require(
            !initialized &&
                _owners[0] != address(0) &&
                _owners[1] != address(0) &&
                _owners[2] != address(0),
            "ai"
        );
        owners = [_owners[0], _owners[1], _owners[2]];
        initialized = true;
    }

    function getSigner(bytes calldata _data, bytes calldata keys)
        public
        view
        returns (address)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(
            keys,
            (uint8, bytes32, bytes32)
        );
        return
            ecrecover(
                toEthSignedMessageHash(
                    keccak256(abi.encodePacked(this, chainId, _data))
                ),
                v,
                r,
                s
            );
    }

    function encodePackedData(bytes calldata _data)
        public
        view
        returns (bytes32)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return keccak256(abi.encodePacked(this, chainId, _data));
    }

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    // Set functions
    // verified
    function transferOwnership(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "transferOwnership")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        address newOwner = abi.decode(params, (address));
        uint256 index;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                index = i;
            }
        }
        address oldOwner = owners[index];
        owners[index] = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/Manager.sol

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.7.0;

contract Manager {
    address public immutable cardContract;

    constructor(address _cardContract) {
        cardContract = _cardContract;
    }

    /// modifier functions
    modifier onlyFromCardContract() {
        require(msg.sender == cardContract, "oc");
        _;
    }
}


// File contracts/interfaces/ILevelManager.sol

pragma solidity ^0.7.0;

interface ILevelManager {
    function getUserLevel(address userAddr) external view returns (uint256);

    function getLevel(uint256 _okseAmount) external view returns (uint256);

    function updateUserLevel(
        address userAddr,
        uint256 beforeAmount
    ) external returns (bool);
}


// File contracts/libraries/SafeMath.sol

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
    return add(a, b, "SafeMath: addition overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, errorMessage);

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
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
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
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
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
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}


// File contracts/LimitManager.sol

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.7.0;
contract LimitManager is MultiSigOwner, Manager {
    using SafeMath for uint256;
    address public immutable levelManager;
    uint256 public constant MAX_LEVEL = 5;
    // user's sepnd amount in a day.
    mapping(address => uint256) public usersSpendAmountDay;
    // user's spend date
    // it is needed to calculate how much assets user sold in a day.
    mapping(address => uint256) public usersSpendTime;
    // unit is usd amount , so decimal is 18
    // specific user's daily spend limit.
    // this value should be zero in default.
    // if this value is not 0, then return the value and if 0, return limt for user's level.
    mapping(address => uint256) public userDailyLimits;
    uint256[] public DailyLimits;
    uint256 public timeDiff;
    event TimeDiffChanged(uint256 timeDiff);
    event DailyLimitChanged(uint256 index, uint256 _amount);
    event UserDailyLimitChanged(address userAddr, uint256 usdAmount);

    constructor(address _cardContract, address _levelManager)
        Manager(_cardContract)
    {
        DailyLimits = [
            250 ether,
            500 ether,
            2500 ether,
            5000 ether,
            10000 ether,
            50000 ether
        ];
        levelManager = _levelManager;
        timeDiff = 4 hours;
    }

    ////////////////////////// Read functions /////////////////////////////////////////////////////////////
    function getUserLimit(address userAddr) public view returns (uint256) {
        uint256 dailyLimit = userDailyLimits[userAddr];
        if (dailyLimit != 0) return dailyLimit;
        uint256 userLevel = ILevelManager(levelManager).getUserLevel(userAddr);
        return getDailyLimit(userLevel);
    }

    // verified
    function getDailyLimit(uint256 level) public view returns (uint256) {
        require(level <= 5, "level > 5");
        return DailyLimits[level];
    }

    // decimal of usdAmount is 18
    function withinLimits(address userAddr, uint256 usdAmount)
        public
        view
        returns (bool)
    {
        if (usdAmount <= getUserLimit(userAddr)) return true;
        return false;
    }

    function getSpendAmountToday(address userAddr)
        public
        view
        returns (uint256)
    {
        uint256 currentDate = (block.timestamp.add(timeDiff)).div(1 days); // UTC -> PST time zone 12 PM
        if (usersSpendTime[userAddr] != currentDate) {
            return 0;
        }
        return usersSpendAmountDay[userAddr];
    }

    ///////////////// CallBack functions from card contract //////////////////////////////////////////////
    function updateUserSpendAmount(address userAddr, uint256 usdAmount)
        public
        onlyFromCardContract
    {
        uint256 currentDate = (block.timestamp.add(timeDiff)).div(1 days); // UTC -> PST time zone 12 PM
        uint256 totalSpendAmount;

        if (usersSpendTime[userAddr] != currentDate) {
            usersSpendTime[userAddr] = currentDate;
            totalSpendAmount = usdAmount;
        } else {
            totalSpendAmount = usersSpendAmountDay[userAddr].add(usdAmount);
        }

        require(withinLimits(userAddr, totalSpendAmount), "odl");
        usersSpendAmountDay[userAddr] = totalSpendAmount;
    }

    //////////////////// Owner functions ////////////////////////////////////////////////////////////////
    // verified
    function setDailyLimit(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "setDailyLimit")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        (uint256 index, uint256 _amount) = abi.decode(
            params,
            (uint256, uint256)
        );
        require(index <= MAX_LEVEL, "level<=5");
        DailyLimits[index] = _amount;
        emit DailyLimitChanged(index, _amount);
    }

    // verified
    function setUserDailyLimits(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "setUserDailyLimits")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        (address userAddr, uint256 usdAmount) = abi.decode(
            params,
            (address, uint256)
        );
        userDailyLimits[userAddr] = usdAmount;
        emit UserDailyLimitChanged(userAddr, usdAmount);
    }

    function setTimeDiff(bytes calldata signData, bytes calldata keys)
        external
        validSignOfOwner(signData, keys, "setTimeDiff")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        uint256 _value = abi.decode(params, (uint256));
        timeDiff = _value;
        emit TimeDiffChanged(timeDiff);
    }
}