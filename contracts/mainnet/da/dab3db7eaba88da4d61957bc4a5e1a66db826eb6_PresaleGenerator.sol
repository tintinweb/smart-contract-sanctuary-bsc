// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./PresaleMultiLP.sol";
import "./libraries/Ownable.sol";
import "./libraries/SafeMath.sol";
import "./libraries/TransferHelper.sol";
import "./interfaces/IPresaleFactory.sol";
import "./interfaces/IPresaleSettings.sol";
import "./interfaces/IERC20.sol";

contract PresaleGenerator is Ownable {
    using SafeMath for uint256;
    
    IPresaleFactory public PRESALE_FACTORY;
    IPresaleSettings public PRESALE_SETTINGS;
    
    struct PresaleParams {
        uint256 amount;
        uint256 tokenPrice;
        uint256 minSpendPerBuyer;
        uint256 maxSpendPerBuyer;
        uint256 hardcap;
        uint256 softcap;
        uint256 earlyAllowanceRate;
        uint256 liquidityPercent;
        uint256 liquidityPercentPYE;
        uint256 liquidityPercentCAKE;
        uint256 listingRate; // sale token listing price on PYESwap
        uint256 startTime;
        uint256 endTime;
        uint256 lockPeriod;
    }
    
    constructor() {
        PRESALE_FACTORY = IPresaleFactory(0xC212bb6Cb68Cc2104166CDBE57cee1bD61ace065);
        PRESALE_SETTINGS = IPresaleSettings(0xA6fB686dAC366BfC87cC9acAb98c572C1f6a938d);
    }

    function calculateAmountRequired (uint256 _amount, uint256 _tokenPrice, uint256 _listingRate, uint256 _liquidityPercent, uint256 _tokenFee) public pure returns (uint256) {
        uint256 listingRatePercent = _listingRate.mul(1000).div(_tokenPrice);
        uint256 pyeLABTokenFee = _amount.mul(_tokenFee).div(1000);
        uint256 amountMinusFee = _amount.sub(pyeLABTokenFee);
        uint256 liquidityRequired = amountMinusFee.mul(_liquidityPercent).mul(listingRatePercent).div(1000000);
        uint256 tokensRequiredForPresale = _amount.add(liquidityRequired).add(pyeLABTokenFee);
        return tokensRequiredForPresale;
    }
    
    /**
     * @notice Creates a new Presale contract and registers it in the PresaleFactory.sol.
     */
    function createPresale (
      address payable _presaleOwner,
      IERC20 _presaleToken,
      IERC20 _baseToken,
      bytes32 _referralCode,
      uint256[14] memory uint_params
      ) public payable {
        
        PresaleParams memory params;
        params.amount = uint_params[0];
        params.tokenPrice = uint_params[1];
        params.minSpendPerBuyer = uint_params[2];
        params.maxSpendPerBuyer = uint_params[3];
        params.hardcap = uint_params[4];
        params.softcap = uint_params[5];
        params.earlyAllowanceRate = uint_params[6];
        params.liquidityPercent = uint_params[7];
        params.liquidityPercentPYE = uint_params[8];
        params.liquidityPercentCAKE = uint_params[9];
        params.listingRate = uint_params[10];
        params.startTime = uint_params[11];
        params.endTime = uint_params[12];
        params.lockPeriod = uint_params[13];
        
        if (params.lockPeriod < 4 weeks) {
            params.lockPeriod = 4 weeks;
        }
        
        // Charge ETH fee for contract creation
        require(msg.value == PRESALE_SETTINGS.getEthCreationFee(), 'FEE NOT MET');
        PRESALE_SETTINGS.getEthAddress().transfer(PRESALE_SETTINGS.getEthCreationFee());
        
        require(params.amount >= 10000, 'MIN DIVIS'); // minimum divisibility
        require(params.endTime.sub(params.startTime) <= PRESALE_SETTINGS.getMaxPresaleLength());
        require(params.tokenPrice.mul(params.hardcap) > 0, 'INVALID PARAMS'); // ensure no overflow for future calculations
        require(params.softcap >= params.hardcap.mul(PRESALE_SETTINGS.getMinSoftcapRate()).div(10000), 'Invalid Softcap Amount');
        require(params.minSpendPerBuyer < params.maxSpendPerBuyer, 'Invalid Spend Limits');
        require(params.liquidityPercent >= 300 && params.liquidityPercent <= 1000, 'MIN LIQUIDITY'); // 30% minimum liquidity lock
        require(params.liquidityPercentPYE >= PRESALE_SETTINGS.getMinimumPercentToPYE() && params.liquidityPercentPYE + params.liquidityPercentCAKE == 1000, 'Invalid Liquidity Split');
        require(PRESALE_SETTINGS.baseTokenIsValid(address(_baseToken))); // Base Token Must be Allowed
        require(params.earlyAllowanceRate >= PRESALE_SETTINGS.getMinEarlyAllowance(), 'Invalid Early Access Allowance');
        
        uint256 tokensRequiredForPresale = calculateAmountRequired(params.amount, params.tokenPrice, params.listingRate, params.liquidityPercent, PRESALE_SETTINGS.getTokenFee());
      
        PresaleMultiLP newPresale = new PresaleMultiLP(address(this));
        TransferHelper.safeTransferFrom(address(_presaleToken), address(msg.sender), address(newPresale), tokensRequiredForPresale);
        require(IERC20(_presaleToken).balanceOf(address(newPresale)) == tokensRequiredForPresale, 'Wrong Token Amount Received');
        newPresale.init1(
            _presaleOwner, 
            params.amount, 
            params.tokenPrice, 
            params.minSpendPerBuyer, 
            params.maxSpendPerBuyer, 
            params.hardcap, 
            params.softcap, 
            params.liquidityPercentPYE * params.liquidityPercent / 1000, 
            params.liquidityPercentCAKE * params.liquidityPercent / 1000, 
            params.listingRate, 
            params.startTime, 
            params.endTime, 
            params.lockPeriod
        );
        address payable _referralAddress;
        uint256 _referralIndex;
        if (_referralCode != 0) {
            bool _referrerIsValid;
            (_referrerIsValid, _referralAddress, _referralIndex) = PRESALE_SETTINGS.addReferral(_referralCode, address(_presaleToken), address(newPresale), address(_baseToken));
            require(_referrerIsValid, 'INVALID REFERRAL');
        }
        newPresale.init2(
            _baseToken, 
            _presaleToken, 
            PRESALE_SETTINGS.getBaseFee(), 
            PRESALE_SETTINGS.getTokenFee(), 
            PRESALE_SETTINGS.getReferralFee(), 
            PRESALE_SETTINGS.getEthAddress(), 
            PRESALE_SETTINGS.getTokenAddress(), 
            _referralAddress,
            _referralCode,
            _referralIndex
        );
        newPresale.initEarlyAllowance(params.earlyAllowanceRate);
        PRESALE_FACTORY.registerPresale(address(newPresale));
    }
    
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IPresaleSettings {
    function getMaxPresaleLength () external view returns (uint256);
    function getLevel4RoundLength () external view returns (uint256);
    function getLevel3RoundLength () external view returns (uint256);
    function getLevel2RoundLength () external view returns (uint256);
    function getLevel1RoundLength () external view returns (uint256);
    function userAllowlistLevel (address _user) external view returns (uint8);
    function referrerIsValid(bytes32 _referralCode) external view returns (bool, address payable);
    function baseTokenIsValid(address _baseToken) external view returns (bool);
    function getBaseFee () external view returns (uint256);
    function getTokenFee () external view returns (uint256);
    function getEthAddress () external view returns (address payable);
    function getTokenAddress () external view returns (address payable);
    function getReferralFee () external view returns (uint256);
    function getEthCreationFee () external view returns (uint256);
    function getMinSoftcapRate() external view returns (uint256);
    function getMinEarlyAllowance() external view returns (uint256);
    function getMinimumPercentToPYE() external view returns (uint256);
    function addReferral(bytes32 _referralCode, address _project, address _presale, address _baseToken) external returns (bool, address payable, uint256);
    function finalizeReferral(bytes32 _referralCode, uint256 _index, bool _active, bool _success, uint256 _raised, uint256 _earned) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IPresaleFactory {
    function registerPresale (address _presaleAddress) external;
    function presaleIsRegistered(address _presaleAddress) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

/**
    helper methods for interacting with ERC20 tokens that do not consistently return true/false
    with the addition of a transfer function to send eth or an erc20 token
*/
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    
    // sends ETH or an erc20 token
    function safeTransferBaseToken(address token, address payable to, uint value, bool isERC20) internal {
        if (!isERC20) {
            (bool success, /*memory data*/) = to.call{value: value}("");
            require(success, 'TransferHelper: TRANSFER_FAILED');
        } else {
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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
pragma solidity 0.8.15;

import "./libraries/TransferHelper.sol";
import "./libraries/EnumerableSet.sol";
import "./libraries/SafeMath.sol";
import "./libraries/ReentrancyGuard.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IPresaleLockForwarder.sol";
import "./interfaces/IPresaleSettings.sol";

contract PresaleMultiLP is ReentrancyGuard {
  using SafeMath for uint256;
  using EnumerableSet for EnumerableSet.AddressSet;
  
  /// @notice Presale Contract Version, used to choose the correct ABI to decode the contract
  uint256 public CONTRACT_VERSION = 1;
  
  struct PresaleInfo {
    address payable PRESALE_OWNER;
    IERC20 S_TOKEN; // sale token
    IERC20 B_TOKEN; // base token // usually WETH (ETH)
    uint256 TOKEN_PRICE; // 1 base token = ? s_tokens, fixed price
    uint256 MIN_SPEND_PER_BUYER; // minimum base token BUY amount per account
    uint256 MAX_SPEND_PER_BUYER; // maximum base token BUY amount per account
    uint256 AMOUNT; // the amount of presale tokens up for presale
    uint256 HARDCAP;
    uint256 SOFTCAP;
    uint256 LIQUIDITY_PERCENT_PYE; // divided by 1000
    uint256 LIQUIDITY_PERCENT_CAKE; // divided by 1000
    uint256 LISTING_RATE; // fixed rate at which the token will list on PYESwap
    uint256 START_TIMESTAMP;
    uint256 END_TIMESTAMP;
    uint256 LOCK_PERIOD; // unix timestamp -> e.g. 2 weeks
    bool PRESALE_IN_ETH; // if this flag is true the presale is raising ETH, otherwise an ERC20 token such as BUSD
  }
  
  struct PresaleFeeInfo {
    uint256 PYE_LAB_BASE_FEE; // divided by 1000
    uint256 PYE_LAB_TOKEN_FEE; // divided by 1000
    uint256 REFERRAL_FEE; // divided by 1000
    address payable BASE_FEE_ADDRESS;
    address payable TOKEN_FEE_ADDRESS;
    address payable REFERRAL_FEE_ADDRESS; // if this is not address(0), there is a valid referral
    bytes32 REFERRAL_CODE; // if this is not 0, there is a valid referral
    uint256 REFERRAL_INDEX;
  }
  
  struct PresaleStatus {
    bool ALLOWLIST_ONLY; // if set to true only allowlisted members may participate
    bool LP_GENERATION_COMPLETE; // final flag required to end a presale and enable withdrawls
    bool FORCE_FAILED; // set this flag to force fail the presale
    uint256 TOTAL_BASE_COLLECTED; // total base currency raised (usually ETH)
    uint256 TOTAL_TOKENS_SOLD; // total presale tokens sold
    uint256 TOTAL_TOKENS_WITHDRAWN; // total tokens withdrawn post successful presale
    uint256 TOTAL_BASE_WITHDRAWN; // total base tokens withdrawn on presale failure
    uint256 LEVEL_4_ROUND_LENGTH; // length of round level4 in seconds
    uint256 LEVEL_3_ROUND_LENGTH; // length of round level3 in seconds
    uint256 LEVEL_2_ROUND_LENGTH; // length of round level2 in seconds
    uint256 LEVEL_1_ROUND_LENGTH; // length of round level1 in seconds
    uint256 NUM_BUYERS; // number of unique participants
  }

  struct BuyerInfo {
    uint256 baseDeposited; // total base token (usually ETH) deposited by user, can be withdrawn on presale failure
    uint256 tokensOwed; // num presale tokens a user is owed, can be withdrawn on presale success
  }
  
  PresaleInfo public PRESALE_INFO;
  PresaleFeeInfo public PRESALE_FEE_INFO;
  PresaleStatus public STATUS;
  address public PRESALE_GENERATOR;
  IPresaleLockForwarder public PRESALE_LOCK_FORWARDER_PYE;
  IPresaleLockForwarder public PRESALE_LOCK_FORWARDER_CAKE;
  IPresaleSettings public PRESALE_SETTINGS;
  address PYE_LAB_FEE_ADDRESS;
  IWETH public WETH;
  mapping(address => BuyerInfo) public BUYERS;
  EnumerableSet.AddressSet private ALLOWLIST;
  uint256 public EARLY_ACCESS_ALLOWANCE; // the amount allowed for early access token holders

  uint256 private COOL_DOWN_TIME;

  mapping(address => bool) private BOTS;
  mapping(address => uint256) private BUY_COOL_DOWN;

  constructor(address _presaleGenerator) {
    PRESALE_GENERATOR = _presaleGenerator;
    WETH = IWETH(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    PRESALE_SETTINGS = IPresaleSettings(0xA6fB686dAC366BfC87cC9acAb98c572C1f6a938d);
    PRESALE_LOCK_FORWARDER_PYE = IPresaleLockForwarder(0xCF4516E3aBAc05F6212c602572D071BE026B2218);
    PRESALE_LOCK_FORWARDER_CAKE = IPresaleLockForwarder(0x17ddC1b2c6a0f90967BD75feA3b94a56cFEB439D);
    PYE_LAB_FEE_ADDRESS = 0xd51c85e6b4C44883e1E05F7D74113315e0862971;
  }
  
  function init1(
    address payable _presaleOwner, 
    uint256 _amount,
    uint256 _tokenPrice, 
    uint256 _minEthPerBuyer, 
    uint256 _maxEthPerBuyer, 
    uint256 _hardcap, 
    uint256 _softcap,
    uint256 _liquidityPercentPYE,
    uint256 _liquidityPercentCAKE,
    uint256 _listingRate,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _lockPeriod
    ) external {
          
      require(msg.sender == PRESALE_GENERATOR, 'FORBIDDEN');
      PRESALE_INFO.PRESALE_OWNER = _presaleOwner;
      PRESALE_INFO.AMOUNT = _amount;
      PRESALE_INFO.TOKEN_PRICE = _tokenPrice;
      PRESALE_INFO.MIN_SPEND_PER_BUYER = _minEthPerBuyer;
      PRESALE_INFO.MAX_SPEND_PER_BUYER = _maxEthPerBuyer;
      PRESALE_INFO.HARDCAP = _hardcap;
      PRESALE_INFO.SOFTCAP = _softcap;
      PRESALE_INFO.LIQUIDITY_PERCENT_PYE = _liquidityPercentPYE;
      PRESALE_INFO.LIQUIDITY_PERCENT_CAKE = _liquidityPercentCAKE;

      PRESALE_INFO.LISTING_RATE = _listingRate;
      PRESALE_INFO.START_TIMESTAMP = _startTime;
      PRESALE_INFO.END_TIMESTAMP = _endTime;
      PRESALE_INFO.LOCK_PERIOD = _lockPeriod;
  }
  
  function init2(
    IERC20 _baseToken,
    IERC20 _presaleToken,
    uint256 _pyeLABBaseFee,
    uint256 _pyeLABTokenFee,
    uint256 _referralFee,
    address payable _baseFeeAddress,
    address payable _tokenFeeAddress,
    address payable _referralAddress,
    bytes32 _referralCode,
    uint256 _referralIndex
    ) external {
          
      require(msg.sender == PRESALE_GENERATOR, 'FORBIDDEN');
      
      PRESALE_INFO.PRESALE_IN_ETH = address(_baseToken) == address(WETH);
      PRESALE_INFO.S_TOKEN = _presaleToken;
      PRESALE_INFO.B_TOKEN = _baseToken;
      PRESALE_FEE_INFO.PYE_LAB_BASE_FEE = _pyeLABBaseFee;
      PRESALE_FEE_INFO.PYE_LAB_TOKEN_FEE = _pyeLABTokenFee;
      PRESALE_FEE_INFO.REFERRAL_FEE = _referralFee;
      
      PRESALE_FEE_INFO.BASE_FEE_ADDRESS = _baseFeeAddress;
      PRESALE_FEE_INFO.TOKEN_FEE_ADDRESS = _tokenFeeAddress;
      PRESALE_FEE_INFO.REFERRAL_FEE_ADDRESS = _referralAddress;
      PRESALE_FEE_INFO.REFERRAL_CODE = _referralCode;
      PRESALE_FEE_INFO.REFERRAL_INDEX = _referralIndex;
      STATUS.LEVEL_4_ROUND_LENGTH = PRESALE_SETTINGS.getLevel4RoundLength();
      STATUS.LEVEL_3_ROUND_LENGTH = PRESALE_SETTINGS.getLevel3RoundLength();
      STATUS.LEVEL_2_ROUND_LENGTH = PRESALE_SETTINGS.getLevel2RoundLength();
      STATUS.LEVEL_1_ROUND_LENGTH = PRESALE_SETTINGS.getLevel1RoundLength();
  }

  function initEarlyAllowance(uint256 _earlyAllowanceRate) external {  
      require(msg.sender == PRESALE_GENERATOR, 'FORBIDDEN');
      EARLY_ACCESS_ALLOWANCE = _earlyAllowanceRate.mul(PRESALE_INFO.HARDCAP).div(10000);
  }
  
  modifier onlyPresaleOwner() {
    require(PRESALE_INFO.PRESALE_OWNER == msg.sender, "NOT PRESALE OWNER");
    _;
  }
  
  function presaleStatus() public view returns (uint256) {
    if (STATUS.FORCE_FAILED) {
      return 3; // FAILED - force fail
    }
    if ((block.timestamp > PRESALE_INFO.END_TIMESTAMP) && (STATUS.TOTAL_BASE_COLLECTED < PRESALE_INFO.SOFTCAP)) {
      return 3; // FAILED - softcap not met by end time
    }
    if (STATUS.TOTAL_BASE_COLLECTED >= PRESALE_INFO.HARDCAP) {
      return 2; // SUCCESS - hardcap met
    }
    if ((block.timestamp > PRESALE_INFO.END_TIMESTAMP) && (STATUS.TOTAL_BASE_COLLECTED >= PRESALE_INFO.SOFTCAP)) {
      return 2; // SUCCESS - end time and soft cap reached
    }
    if ((block.timestamp >= PRESALE_INFO.START_TIMESTAMP - STATUS.LEVEL_4_ROUND_LENGTH) && (block.timestamp <= PRESALE_INFO.END_TIMESTAMP)) {
      return 1; // ACTIVE - deposits enabled
    }
    return 0; // QUEUED - awaiting start time
  }

  function checkAllowed(address account) public view returns (bool) {
    if (block.timestamp >= PRESALE_INFO.START_TIMESTAMP) {
      if(STATUS.ALLOWLIST_ONLY) require(ALLOWLIST.contains(msg.sender), 'NOT ALLOWLISTED');
      return true;
    } else if (block.timestamp >= PRESALE_INFO.START_TIMESTAMP - STATUS.LEVEL_4_ROUND_LENGTH && ALLOWLIST.contains(account) && !STATUS.ALLOWLIST_ONLY) {
      return true;
    }

    bool allowed = false;
    uint8 accessLevel = PRESALE_SETTINGS.userAllowlistLevel(account);
    if (STATUS.TOTAL_BASE_COLLECTED < EARLY_ACCESS_ALLOWANCE){
      if (block.timestamp >= PRESALE_INFO.START_TIMESTAMP - STATUS.LEVEL_1_ROUND_LENGTH) {
        allowed = accessLevel >= 1;
      } else if (block.timestamp >= PRESALE_INFO.START_TIMESTAMP - STATUS.LEVEL_2_ROUND_LENGTH) {
        allowed = accessLevel >= 2;
      } else if (block.timestamp >= PRESALE_INFO.START_TIMESTAMP - STATUS.LEVEL_3_ROUND_LENGTH) {
        allowed = accessLevel >= 3;
      } else if (block.timestamp >= PRESALE_INFO.START_TIMESTAMP - STATUS.LEVEL_4_ROUND_LENGTH) {
        allowed = accessLevel == 4;
      }
    }
    return allowed;

  }

  function checkTokenFeeExempt() public returns (bool) {
    uint256 balanceBefore = IERC20(PRESALE_INFO.S_TOKEN).balanceOf(address(this));
    TransferHelper.safeTransfer(address(PRESALE_INFO.S_TOKEN), address(this), 100);
    uint256 balanceAfter = IERC20(PRESALE_INFO.S_TOKEN).balanceOf(address(this));

    if(balanceBefore == balanceAfter) {
      return true;
    } else {
      return false;
    }
  }
  
  // accepts msg.value for eth or _amount for ERC20 tokens
  function userDeposit(uint256 _amount) external payable nonReentrant {
    bool allowed = checkAllowed(msg.sender);
    require(allowed, 'NOT ACTIVE'); // ACTIVE
    _beforeUserDeposit(msg.sender);

    if (STATUS.ALLOWLIST_ONLY) {
      require(ALLOWLIST.contains(msg.sender), 'NOT ALLOWLISTED');
    }
    BuyerInfo storage buyer = BUYERS[msg.sender];
    require(PRESALE_INFO.MIN_SPEND_PER_BUYER <= _amount.add(buyer.baseDeposited), 'Amount does not meet minimum spend');
    uint256 amount_in = PRESALE_INFO.PRESALE_IN_ETH ? msg.value : _amount;
    uint256 allowance = PRESALE_INFO.MAX_SPEND_PER_BUYER.sub(buyer.baseDeposited);
    uint256 remaining = PRESALE_INFO.HARDCAP - STATUS.TOTAL_BASE_COLLECTED;
    allowance = allowance > remaining ? remaining : allowance;
    if (amount_in > allowance) {
      amount_in = allowance;
    }
    uint256 tokensSold = amount_in.mul(PRESALE_INFO.TOKEN_PRICE).div(10 ** uint256(PRESALE_INFO.B_TOKEN.decimals()));
    require(tokensSold > 0, 'ZERO TOKENS');
    if (buyer.baseDeposited == 0) {
        STATUS.NUM_BUYERS++;
    }
    buyer.baseDeposited = buyer.baseDeposited.add(amount_in);
    buyer.tokensOwed = buyer.tokensOwed.add(tokensSold);
    STATUS.TOTAL_BASE_COLLECTED = STATUS.TOTAL_BASE_COLLECTED.add(amount_in);
    STATUS.TOTAL_TOKENS_SOLD = STATUS.TOTAL_TOKENS_SOLD.add(tokensSold);
    
    // return unused ETH
    if (PRESALE_INFO.PRESALE_IN_ETH && amount_in < msg.value) {
      payable(msg.sender).transfer(msg.value.sub(amount_in));
    }
    // deduct non ETH token from user
    if (!PRESALE_INFO.PRESALE_IN_ETH) {
      TransferHelper.safeTransferFrom(address(PRESALE_INFO.B_TOKEN), msg.sender, address(this), amount_in);
    }
  }

  // emergency withdraw base token while presale active
  // percentile withdrawls allows fee on transfer or rebasing tokens to still work
  function userEmergencyWithdraw() external nonReentrant {
    require(presaleStatus() == 1, 'NOT ACTIVE'); // ACTIVE
    BuyerInfo storage buyer = BUYERS[msg.sender];
    uint256 remainingBaseBalance = PRESALE_INFO.PRESALE_IN_ETH ? address(this).balance : PRESALE_INFO.B_TOKEN.balanceOf(address(this));
    uint256 tokensOwed = remainingBaseBalance.mul(buyer.baseDeposited).div(STATUS.TOTAL_BASE_COLLECTED);
    require(tokensOwed > 0, 'NOTHING TO WITHDRAW');
    STATUS.TOTAL_BASE_COLLECTED = STATUS.TOTAL_BASE_COLLECTED.sub(tokensOwed);
    STATUS.TOTAL_TOKENS_SOLD = STATUS.TOTAL_TOKENS_SOLD.sub(buyer.tokensOwed);
    buyer.baseDeposited = 0;
    buyer.tokensOwed = 0;
    STATUS.NUM_BUYERS--;
    TransferHelper.safeTransferBaseToken(address(PRESALE_INFO.B_TOKEN), payable(msg.sender), tokensOwed, !PRESALE_INFO.PRESALE_IN_ETH);
  }
  
  // withdraw presale tokens
  // percentile withdrawls allows fee on transfer or rebasing tokens to still work
  function userWithdrawTokens() external nonReentrant {
    require(STATUS.LP_GENERATION_COMPLETE, 'AWAITING LP GENERATION');
    BuyerInfo storage buyer = BUYERS[msg.sender];
    uint256 tokensRemainingDenominator = STATUS.TOTAL_TOKENS_SOLD.sub(STATUS.TOTAL_TOKENS_WITHDRAWN);
    uint256 tokensOwed = PRESALE_INFO.S_TOKEN.balanceOf(address(this)).mul(buyer.tokensOwed).div(tokensRemainingDenominator);
    require(tokensOwed > 0, 'NOTHING TO WITHDRAW');
    STATUS.TOTAL_TOKENS_WITHDRAWN = STATUS.TOTAL_TOKENS_WITHDRAWN.add(buyer.tokensOwed);
    buyer.tokensOwed = 0;
    TransferHelper.safeTransfer(address(PRESALE_INFO.S_TOKEN), msg.sender, tokensOwed);
  }
  
  // on presale failure
  // percentile withdrawls allows fee on transfer or rebasing tokens to still work
  function userWithdrawBaseTokens() external nonReentrant {
    require(presaleStatus() == 3, 'NOT FAILED'); // FAILED
    BuyerInfo storage buyer = BUYERS[msg.sender];
    uint256 baseRemainingDenominator = STATUS.TOTAL_BASE_COLLECTED.sub(STATUS.TOTAL_BASE_WITHDRAWN);
    uint256 remainingBaseBalance = PRESALE_INFO.PRESALE_IN_ETH ? address(this).balance : PRESALE_INFO.B_TOKEN.balanceOf(address(this));
    uint256 tokensOwed = remainingBaseBalance.mul(buyer.baseDeposited).div(baseRemainingDenominator);
    require(tokensOwed > 0, 'NOTHING TO WITHDRAW');
    STATUS.TOTAL_BASE_WITHDRAWN = STATUS.TOTAL_BASE_WITHDRAWN.add(tokensOwed);
    buyer.baseDeposited = 0;
    TransferHelper.safeTransferBaseToken(address(PRESALE_INFO.B_TOKEN), payable(msg.sender), tokensOwed, !PRESALE_INFO.PRESALE_IN_ETH);
  }
  
  // on presale failure
  // allows the owner to withdraw the tokens they sent for presale & initial liquidity
  function ownerWithdrawTokens() external onlyPresaleOwner {
    require(presaleStatus() == 3); // FAILED
    TransferHelper.safeTransfer(address(PRESALE_INFO.S_TOKEN), PRESALE_INFO.PRESALE_OWNER, PRESALE_INFO.S_TOKEN.balanceOf(address(this)));
    PRESALE_SETTINGS.finalizeReferral(PRESALE_FEE_INFO.REFERRAL_CODE, PRESALE_FEE_INFO.REFERRAL_INDEX, false, false, 0, 0);
  }
  

  // Can be called at any stage before or during the presale to cancel it before it ends.
  // If the pair already exists on PYESwap and it contains the presale token as liquidity
  // the final stage of the presale 'addLiquidity()' will fail. This function 
  // allows anyone to end the presale prematurely to release funds in such a case.
  function forceFailIfPairExists() external {
    require(!STATUS.LP_GENERATION_COMPLETE && !STATUS.FORCE_FAILED);
    if (PRESALE_LOCK_FORWARDER_PYE.PYELabPairIsInitialised(address(PRESALE_INFO.S_TOKEN), address(PRESALE_INFO.B_TOKEN)) &&
        PRESALE_LOCK_FORWARDER_CAKE.PYELabPairIsInitialised(address(PRESALE_INFO.S_TOKEN), address(PRESALE_INFO.B_TOKEN))) {
        STATUS.FORCE_FAILED = true;
        PRESALE_SETTINGS.finalizeReferral(PRESALE_FEE_INFO.REFERRAL_CODE, PRESALE_FEE_INFO.REFERRAL_INDEX, false, false, 0, 0);
    }
  }
  
  // if something goes wrong in LP generation
  function forceFailByPYELab() external {
      require(msg.sender == PYE_LAB_FEE_ADDRESS);
      STATUS.FORCE_FAILED = true;
      PRESALE_SETTINGS.finalizeReferral(PRESALE_FEE_INFO.REFERRAL_CODE, PRESALE_FEE_INFO.REFERRAL_INDEX, false, false, 0, 0);
  }

  // if presale owner needs to cancel presale
  function forceFailByOwner() onlyPresaleOwner external {
      require(!STATUS.LP_GENERATION_COMPLETE && !STATUS.FORCE_FAILED);
      STATUS.FORCE_FAILED = true;
      PRESALE_SETTINGS.finalizeReferral(PRESALE_FEE_INFO.REFERRAL_CODE, PRESALE_FEE_INFO.REFERRAL_INDEX, false, false, 0, 0);
  }
  
  // on presale success, this is the final step to end the presale, lock liquidity and enable withdrawls of the sale token.
  // This function does not use percentile distribution. Rebasing mechanisms, fee on transfers, or any deflationary logic
  // are not taken into account at this stage to ensure stated liquidity is locked and the pool is initialised according to 
  // the presale parameters and fixed prices.
  function addLiquidity() external onlyPresaleOwner nonReentrant {
    require(!STATUS.LP_GENERATION_COMPLETE, 'GENERATION COMPLETE');
    require(presaleStatus() == 2, 'NOT SUCCESS'); // SUCCESS
    // Fail the presale if the pair exists and contains presale token liquidity
    if (PRESALE_LOCK_FORWARDER_PYE.PYELabPairIsInitialised(address(PRESALE_INFO.S_TOKEN), address(PRESALE_INFO.B_TOKEN)) && 
        PRESALE_LOCK_FORWARDER_CAKE.PYELabPairIsInitialised(address(PRESALE_INFO.S_TOKEN), address(PRESALE_INFO.B_TOKEN))) {
        STATUS.FORCE_FAILED = true;
        PRESALE_SETTINGS.finalizeReferral(PRESALE_FEE_INFO.REFERRAL_CODE, PRESALE_FEE_INFO.REFERRAL_INDEX, false, false, 0, 0);
        return;
      }
    
    uint256 pyeLABBaseFee = STATUS.TOTAL_BASE_COLLECTED.mul(PRESALE_FEE_INFO.PYE_LAB_BASE_FEE).div(1000);

    
    // PYESwap Liquidity
    // base token liquidity
    uint256 baseLiquidityPYE = STATUS.TOTAL_BASE_COLLECTED.sub(pyeLABBaseFee).mul(PRESALE_INFO.LIQUIDITY_PERCENT_PYE).div(1000);
    if (PRESALE_INFO.PRESALE_IN_ETH) {
        WETH.deposit{value : baseLiquidityPYE}();
    }
    TransferHelper.safeApprove(address(PRESALE_INFO.B_TOKEN), address(PRESALE_LOCK_FORWARDER_PYE), baseLiquidityPYE);
    
    // sale token liquidity
    uint256 tokenLiquidityPYE = baseLiquidityPYE.mul(PRESALE_INFO.LISTING_RATE).div(10 ** uint256(PRESALE_INFO.B_TOKEN.decimals()));
    TransferHelper.safeApprove(address(PRESALE_INFO.S_TOKEN), address(PRESALE_LOCK_FORWARDER_PYE), tokenLiquidityPYE);
    
    PRESALE_LOCK_FORWARDER_PYE.lockLiquidity(PRESALE_INFO.B_TOKEN, PRESALE_INFO.S_TOKEN, baseLiquidityPYE, tokenLiquidityPYE, block.timestamp + PRESALE_INFO.LOCK_PERIOD, PRESALE_INFO.PRESALE_OWNER);

    

    // PancakeSwap Liquidity
    // base token liquidity
    uint256 baseLiquidityCAKE = STATUS.TOTAL_BASE_COLLECTED.sub(pyeLABBaseFee).mul(PRESALE_INFO.LIQUIDITY_PERCENT_CAKE).div(1000);
    if (PRESALE_INFO.PRESALE_IN_ETH) {
        WETH.deposit{value : baseLiquidityCAKE}();
    }
    TransferHelper.safeApprove(address(PRESALE_INFO.B_TOKEN), address(PRESALE_LOCK_FORWARDER_CAKE), baseLiquidityCAKE);
    
    // sale token liquidity
    uint256 tokenLiquidityCAKE = baseLiquidityCAKE.mul(PRESALE_INFO.LISTING_RATE).div(10 ** uint256(PRESALE_INFO.B_TOKEN.decimals()));
    TransferHelper.safeApprove(address(PRESALE_INFO.S_TOKEN), address(PRESALE_LOCK_FORWARDER_CAKE), tokenLiquidityCAKE);
    
    PRESALE_LOCK_FORWARDER_CAKE.lockLiquidity(PRESALE_INFO.B_TOKEN, PRESALE_INFO.S_TOKEN, baseLiquidityCAKE, tokenLiquidityCAKE, block.timestamp + PRESALE_INFO.LOCK_PERIOD, PRESALE_INFO.PRESALE_OWNER);
    
    

    // transfer fees
    uint256 pyeLABTokenFee = STATUS.TOTAL_TOKENS_SOLD.mul(PRESALE_FEE_INFO.PYE_LAB_TOKEN_FEE).div(1000);
    // referrals are checked for validity in the presale generator
    uint256 referralBaseFee;
    if (PRESALE_FEE_INFO.REFERRAL_FEE_ADDRESS != address(0)) {
        // Base token fee
        referralBaseFee = pyeLABBaseFee.mul(PRESALE_FEE_INFO.REFERRAL_FEE).div(1000);
        TransferHelper.safeTransferBaseToken(address(PRESALE_INFO.B_TOKEN), PRESALE_FEE_INFO.REFERRAL_FEE_ADDRESS, referralBaseFee, !PRESALE_INFO.PRESALE_IN_ETH);
        pyeLABBaseFee = pyeLABBaseFee.sub(referralBaseFee);
    }
    TransferHelper.safeTransferBaseToken(address(PRESALE_INFO.B_TOKEN), PRESALE_FEE_INFO.BASE_FEE_ADDRESS, pyeLABBaseFee, !PRESALE_INFO.PRESALE_IN_ETH);
    TransferHelper.safeTransfer(address(PRESALE_INFO.S_TOKEN), PRESALE_FEE_INFO.TOKEN_FEE_ADDRESS, pyeLABTokenFee);
    
    // burn unsold tokens
    uint256 remainingSBalance = PRESALE_INFO.S_TOKEN.balanceOf(address(this));
    if (remainingSBalance > STATUS.TOTAL_TOKENS_SOLD) {
        uint256 burnAmount = remainingSBalance.sub(STATUS.TOTAL_TOKENS_SOLD);
        TransferHelper.safeTransfer(address(PRESALE_INFO.S_TOKEN), 0x000000000000000000000000000000000000dEaD, burnAmount);
    }
    
    // send remaining base tokens to presale owner
    uint256 remainingBaseBalance = PRESALE_INFO.PRESALE_IN_ETH ? address(this).balance : PRESALE_INFO.B_TOKEN.balanceOf(address(this));
    TransferHelper.safeTransferBaseToken(address(PRESALE_INFO.B_TOKEN), PRESALE_INFO.PRESALE_OWNER, remainingBaseBalance, !PRESALE_INFO.PRESALE_IN_ETH);
    
    STATUS.LP_GENERATION_COMPLETE = true;
    PRESALE_SETTINGS.finalizeReferral(PRESALE_FEE_INFO.REFERRAL_CODE, PRESALE_FEE_INFO.REFERRAL_INDEX, false, true, STATUS.TOTAL_BASE_COLLECTED, referralBaseFee);
  }
  
  function updateSpendLimit(uint256 _minSpend, uint256 _maxSpend) external onlyPresaleOwner {
    PRESALE_INFO.MIN_SPEND_PER_BUYER = _minSpend;
    PRESALE_INFO.MAX_SPEND_PER_BUYER = _maxSpend;
  }
  
  // postpone or bring a presale forward, this will only work when a presale is inactive.
  // i.e. current start time > block.timestamp
  function updateBlocks(uint256 _startTime, uint256 _endTime) external onlyPresaleOwner {
    require(PRESALE_INFO.START_TIMESTAMP > block.timestamp);
    require(_endTime.sub(_startTime) <= PRESALE_SETTINGS.getMaxPresaleLength());
    PRESALE_INFO.START_TIMESTAMP = _startTime;
    PRESALE_INFO.END_TIMESTAMP = _endTime;
  }

  // update the amount of hardcap that is allowed to early access token holders. Entered as a numerator with a constant denominator of 10000
  // i.e. 5000 = 50% , 7500 = 75%, etc. Must be greater than the minimum rate set by PYELab
  function updateEarlyAllowance(uint256 _earlyAllowanceRate) external onlyPresaleOwner {  
      require(_earlyAllowanceRate >= PRESALE_SETTINGS.getMinEarlyAllowance(), 'Invalid Early Access Allowance');
      EARLY_ACCESS_ALLOWANCE = _earlyAllowanceRate.mul(PRESALE_INFO.HARDCAP).div(10000);
  }

  // editable at any stage of the presale
  function setAllowlistFlag(bool _flag) external onlyPresaleOwner {
    STATUS.ALLOWLIST_ONLY = _flag;
  }

  // editable at any stage of the presale
  function editAllowlist(address[] memory _users, bool _add) external onlyPresaleOwner {
    if (_add) {
        for (uint i = 0; i < _users.length; i++) {
          ALLOWLIST.add(_users[i]);
        }
    } else {
        for (uint i = 0; i < _users.length; i++) {
          ALLOWLIST.remove(_users[i]);
        }
    }
  }

  // allowlist getters
  function getAllowlistedUsersLength() external view returns (uint256) {
    return ALLOWLIST.length();
  }
  
  function getAllowlistedUserAtIndex(uint256 _index) external view returns (address) {
    return ALLOWLIST.at(_index);
  }
  
  function getUserAllowlistStatus(address _user) external view returns (bool) {
    return ALLOWLIST.contains(_user);
  }

  function refreshRoundLengths() external {
    STATUS.LEVEL_4_ROUND_LENGTH = PRESALE_SETTINGS.getLevel4RoundLength();
    STATUS.LEVEL_3_ROUND_LENGTH = PRESALE_SETTINGS.getLevel3RoundLength();
    STATUS.LEVEL_2_ROUND_LENGTH = PRESALE_SETTINGS.getLevel2RoundLength();
    STATUS.LEVEL_1_ROUND_LENGTH = PRESALE_SETTINGS.getLevel1RoundLength();
  }

  // Anti-Bot Mechanisms

  function isContract(address account) internal view returns (bool) {
      uint256 size;
      assembly { size := extcodesize(account) }
      return size > 0;
  }

  function _beforeUserDeposit(address _buyer) internal {
      if (_buyer != PRESALE_INFO.PRESALE_OWNER) {
          require(!isContract(_buyer), "PYELab Bot Protector: Contracts are not allowed to deposit");
          require(_buyer == tx.origin, "PYELab Bot Protector: Proxy contract not allowed");
          require(!BOTS[_buyer], "PYELab Bot Protector: address is denylisted");
          require(BUY_COOL_DOWN[_buyer] < block.timestamp, "PYELab Bot Protector: can't buy until cool down");

          BUY_COOL_DOWN[_buyer] = block.timestamp + COOL_DOWN_TIME;
      }
  }

  function addBot(address _bot) external onlyPresaleOwner {
      BOTS[_bot] = true;
  }

  function removeBot(address _account) external onlyPresaleOwner {
      BOTS[_account] = false;
  }

  function setCoolDownTime(uint256 _amount) external onlyPresaleOwner {
      COOL_DOWN_TIME = _amount;
  }

  function isBot(address _account) external view returns (bool) {
      return BOTS[_account];
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./IERC20.sol";

interface IPresaleLockForwarder {
    function lockLiquidity (IERC20 _baseToken, IERC20 _saleToken, uint256 _baseAmount, uint256 _saleAmount, uint256 _unlock_date, address payable _withdrawer) external;
    function PYELabPairIsInitialised (address _token0, address _token1) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}