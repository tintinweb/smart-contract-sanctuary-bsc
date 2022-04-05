// SPDX-License-Identifier: UNLICENSED
// @Credits Unicrypt Network 2021

// This contract generates Presale01 contracts and registers them in the PresaleFactory.
// Ideally you should not interact with this contract directly, and use the Octofi presale app instead so warnings can be shown where necessary.

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import "./TransferHelper.sol";
import "./Presale01.sol";
import "./IERC20.sol";

interface IPresaleFactory {
    function registerPresale (address _presaleAddress) external;
    function presaleIsRegistered(address _presaleAddress) external view returns (bool);
}


contract PresaleGenerator01 {
    using SafeMath for uint256;
    
    IPresaleFactory public PRESALE_FACTORY;
    IPresaleSettings public PRESALE_SETTINGS;
    address UNISWAP_V2_FACTORY_ADDRESS;
    address WETH_ADDRESS;
    address UNISWAP_LOCKER_ADDRESS;
    address FEE_ADDRESS;
    address PRESALE_SETTINGS_ADDRESS;
    address PRESALE_IMPLEMENTATION_ADDRESS;


struct PresaleParams {
        uint256 amount;
        uint256 tokenPrice;
        uint256 maxSpendPerBuyer;
        uint256 hardcap;
        uint256 softcap;
        uint256 liquidityPercent;
        uint256 listingRate; // sale token listing price on uniswap
        uint256 startDate;
        uint256 endDate;
        uint256 lockPeriod;
        uint256 minSpendPerBuyer;
    }


    constructor(
        address _presaleFactory,
        address _presaleSettings,
        address _uniswapV2Factory,
        address _weth,
        address _feeAddress,
        address _uniLockerAddress,
        address _presaleImplementationAddress
    ) {
        PRESALE_FACTORY = IPresaleFactory(_presaleFactory);
        PRESALE_SETTINGS = IPresaleSettings(_presaleSettings);
        UNISWAP_V2_FACTORY_ADDRESS = _uniswapV2Factory;
        WETH_ADDRESS = _weth;
        FEE_ADDRESS = _feeAddress;
        PRESALE_SETTINGS_ADDRESS = _presaleSettings;
        UNISWAP_LOCKER_ADDRESS = _uniLockerAddress;
        PRESALE_IMPLEMENTATION_ADDRESS = _presaleImplementationAddress;
    }

    function calculateAmountRequired (uint256 _amount, uint256 _tokenPrice, uint256 _listingRate, uint256 _liquidityPercent, uint256 _tokenFee) public pure returns (uint256) {
        uint256 listingRatePercent = _listingRate.mul(1000).div(_tokenPrice);
        uint256 unicryptTokenFee = _amount.mul(_tokenFee).div(1000);
        uint256 amountMinusFee = _amount.sub(unicryptTokenFee);
        uint256 liquidityRequired = amountMinusFee.mul(_liquidityPercent).mul(listingRatePercent).div(1000000);
        uint256 tokensRequiredForPresale = _amount.add(liquidityRequired).add(unicryptTokenFee);
        return tokensRequiredForPresale;
    }
    
    /**
     * @notice Creates a new Presale contract and registers it in the PresaleFactory.sol.
     */
    function createPresale (
      address payable _presaleOwner,
      IERC20 _presaleToken,
      IERC20 _baseToken,
      address payable _referralAddress,
        PresaleParams memory params
      ) public payable {
        


        require(params.startDate > block.timestamp + PRESALE_SETTINGS.getMinStartDate(), 'MIN START DATE');
        require(params.endDate > params.startDate, 'MIN END DATE');

        /*if (params.lockPeriod < 4 weeks) {
            params.lockPeriod = 4 weeks;
        }*/

        // Charge ETH fee for contract creation
        require(msg.value == PRESALE_SETTINGS.getEthCreationFee(), 'FEE NOT MET');
        PRESALE_SETTINGS.getEthAddress().transfer(PRESALE_SETTINGS.getEthCreationFee());
        
        if (_referralAddress != address(0)) {
            require(PRESALE_SETTINGS.referrerIsValid(_referralAddress), 'INVALID REFERRAL');
        }
        
        require(params.amount >= 10000, 'MIN DIVIS'); // minimum divisibility
        require(params.endDate.sub(params.startDate) <= PRESALE_SETTINGS.getMaxPresaleLength());
        require(params.tokenPrice.mul(params.hardcap) > 0, 'INVALID PARAMS'); // ensure no overflow for future calculations
        require(params.liquidityPercent >= PRESALE_SETTINGS.getMinLiquidity(), 'MIN LIQUIDITY'); // minimum liquidity lock
        require(params.liquidityPercent <= PRESALE_SETTINGS.getMaxLiquidity(), 'MAX LIQUIDITY'); // maximum liquidity lock

        uint256 tokensRequiredForPresale = calculateAmountRequired(params.amount, params.tokenPrice, params.listingRate, params.liquidityPercent, PRESALE_SETTINGS.getTokenFee());
        Presale01 newPresale = Presale01(Clones.clone(PRESALE_IMPLEMENTATION_ADDRESS));
        newPresale.initialize(address(this), UNISWAP_V2_FACTORY_ADDRESS, WETH_ADDRESS,  PRESALE_SETTINGS_ADDRESS, FEE_ADDRESS, UNISWAP_LOCKER_ADDRESS);
        TransferHelper.safeTransferFrom(address(_presaleToken), address(msg.sender), address(newPresale), tokensRequiredForPresale);
        newPresale.init1(_presaleOwner, params.amount, params.tokenPrice, params.maxSpendPerBuyer, params.hardcap, params.softcap, 
        params.liquidityPercent, params.listingRate, params.startDate, params.endDate, params.lockPeriod, params.minSpendPerBuyer);
        newPresale.init2(_baseToken, _presaleToken, PRESALE_SETTINGS.getBaseFee(), PRESALE_SETTINGS.getTokenFee(), PRESALE_SETTINGS.getReferralFee(), PRESALE_SETTINGS.getEthAddress(), PRESALE_SETTINGS.getTokenAddress(), _referralAddress);

        PRESALE_FACTORY.registerPresale(address(newPresale));

    }
    
}

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

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
            to.transfer(value);
        } else {
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
// @Credits Unicrypt Network 2021

// Presale contract. Version 1

/**
  Allows a decentralised presale to take place, and on success creates a uniswap pair and locks liquidity on Octofi.
  B_TOKEN, or base token, is the token the presale attempts to raise. (Usally ETH).
  S_TOKEN, or sale token, is the token being sold, which investors buy with the base token.
  If the base currency is set to the WETH9 address, the presale is in ETH.
  Otherwise it is for an ERC20 token - such as DAI, USDC, WBTC etc.
  For the Base token - It is advised to only use tokens such as ETH (WETH), DAI, USDC or tokens that have no rebasing, or complex fee on transfers. 1 token should ideally always be 1 token.
  Token withdrawls are done on a percent of total contribution basis (opposed to via a hardcoded 'amount'). This allows 
  fee on transfer, rebasing, or any magically changing balances to still work for the Sale token.
*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "./TransferHelper.sol";
import "./IERC20.sol";

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IPresaleSettings {
    function getMaxPresaleLength () external view returns (uint256);
    function getRound1Length () external view returns (uint256);
    function userHoldsSufficientRound1Token (address _user) external view returns (bool);
    function referrerIsValid(address _referrer) external view returns (bool);
    function getBaseFee () external view returns (uint256);
    function getTokenFee () external view returns (uint256);
    function getEthAddress () external view returns (address payable);
    function getTokenAddress () external view returns (address payable);
    function getReferralFee () external view returns (uint256);
    function getEthCreationFee () external view returns (uint256);
    function getWithdrawPenaltyPercent () external view returns (uint256);
    function getEmergencyWithdrawPreventionTime () external view returns (uint256);
    function getMinStartDate () external view returns (uint256);
    function getMinLiquidity () external view returns (uint256);
    function getMaxLiquidity () external view returns (uint256);
}

interface IUniswapV2Locker {
  function lockLPToken (address _lpToken, uint256 _amount, uint256 _unlock_date, address payable _referral, bool _fee_in_eth, address payable _withdrawer) external payable;
  function uniswapPairIsInitialised (address _token0, address _token1) external view returns (bool);
  function lockLiquidity (IERC20 _baseToken, IERC20 _saleToken, uint256 _baseAmount, uint256 _saleAmount, uint256 _unlock_date, address payable _withdrawer) external;
}

contract Presale01 is ReentrancyGuard, Initializable {
  using SafeMath for uint256;
  using EnumerableSet for EnumerableSet.AddressSet;


  uint constant PERCENTAGE_DIVISOR = 1000;
  
  /// @notice Presale Contract Version, used to choose the correct ABI to decode the contract
  uint256 public CONTRACT_VERSION = 1;

    struct Cap {
        uint256 HARDCAP;
        uint256 SOFTCAP;
    }

  struct Dex {
    uint256 LIQUIDITY_PERCENT; // divided by 1000
    uint256 LISTING_RATE; // fixed rate at which the token will list on uniswap
  }
  
  struct PresaleInfo {
    address payable PRESALE_OWNER;
    IERC20 S_TOKEN; // sale token
    IERC20 B_TOKEN; // base token // usually WETH (ETH)
    uint256 TOKEN_PRICE; // 1 base token = ? s_tokens, fixed price
    uint256 MAX_SPEND_PER_BUYER; // maximum base token BUY amount per account
    uint256 MIN_SPEND_PER_BUYER; // minimum base token BUY amount per account
    uint256 AMOUNT; // the amount of presale tokens up for presale
    Cap CAP;
    Dex DEX;
    uint256 START_DATE;
    uint256 END_DATE;
    uint256 LOCK_PERIOD; // unix timestamp -> e.g. 2 weeks
    bool PRESALE_IN_ETH; // if this flag is true the presale is raising ETH, otherwise an ERC20 token such as DAI
  }
  
  struct PresaleFeeInfo {
    uint256 OCTOFI_BASE_FEE; // divided by 1000
    uint256 OCTOFI_TOKEN_FEE; // divided by 1000
    uint256 REFERRAL_FEE; // divided by 1000
    address payable BASE_FEE_ADDRESS;
    address payable TOKEN_FEE_ADDRESS;
    address payable REFERRAL_FEE_ADDRESS; // if this is not address(0), there is a valid referral
  }
  
  struct PresaleStatus {
    bool WHITELIST_ONLY; // if set to true only whitelisted members may participate
    bool LP_GENERATION_COMPLETE; // final flag required to end a presale and enable withdrawls
    bool FORCE_FAILED; // set this flag to force fail the presale
    uint256 TOTAL_BASE_COLLECTED; // total base currency raised (usually ETH)
    uint256 TOTAL_TOKENS_SOLD; // total presale tokens sold
    uint256 TOTAL_TOKENS_WITHDRAWN; // total tokens withdrawn post successful presale
    uint256 TOTAL_BASE_WITHDRAWN; // total base tokens withdrawn on presale failure
    uint256 ROUND1_LENGTH; // in timestamp
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
  IUniswapV2Locker public UNISWAP_LOCKER;

  IPresaleSettings public PRESALE_SETTINGS;
  address OCTOFI_FEE_ADDRESS;
  IUniswapV2Factory public UNI_FACTORY;
  IWETH public WETH;
  mapping(address => BuyerInfo) public BUYERS;
  EnumerableSet.AddressSet private WHITELIST;

  //pasar para parametro
  function initialize(address _presaleGenerator, address _uniswapV2Factory, address _weth, address _presaleSettings, address _feeAddress, address _lockerAddress)
  initializer public {
    PRESALE_GENERATOR = _presaleGenerator;
    UNI_FACTORY = IUniswapV2Factory(_uniswapV2Factory);
    WETH = IWETH(_weth);
    PRESALE_SETTINGS = IPresaleSettings(_presaleSettings);
    OCTOFI_FEE_ADDRESS = _feeAddress;
    UNISWAP_LOCKER = IUniswapV2Locker(_lockerAddress);

  }
  
  function init1 (
    address payable _presaleOwner, 
    uint256 _amount,
    uint256 _tokenPrice, 
    uint256 _maxEthPerBuyer, 
    uint256 _hardcap, 
    uint256 _softcap,
    uint256 _liquidityPercent,
    uint256 _listingRate,
    uint256 _startdate,
    uint256 _enddate,
    uint256 _lockPeriod,
    uint256 _minEthPerBuyer
    ) external {
          
      require(msg.sender == PRESALE_GENERATOR, 'FORBIDDEN');
      PRESALE_INFO.PRESALE_OWNER = _presaleOwner;
      PRESALE_INFO.AMOUNT = _amount;
      PRESALE_INFO.TOKEN_PRICE = _tokenPrice;
      PRESALE_INFO.MAX_SPEND_PER_BUYER = _maxEthPerBuyer;
      PRESALE_INFO.CAP.HARDCAP = _hardcap;
      PRESALE_INFO.CAP.SOFTCAP = _softcap;
      PRESALE_INFO.DEX.LIQUIDITY_PERCENT = _liquidityPercent;
      PRESALE_INFO.DEX.LISTING_RATE = _listingRate;
      PRESALE_INFO.START_DATE = _startdate;
      PRESALE_INFO.END_DATE = _enddate;
      PRESALE_INFO.LOCK_PERIOD = _lockPeriod;
      PRESALE_INFO.MIN_SPEND_PER_BUYER = _minEthPerBuyer;
  }
  
  function init2 (
    IERC20 _baseToken,
    IERC20 _presaleToken,
    uint256 _unicryptBaseFee,
    uint256 _unicryptTokenFee,
    uint256 _referralFee,
    address payable _baseFeeAddress,
    address payable _tokenFeeAddress,
    address payable _referralAddress
    ) external {
          
      require(msg.sender == PRESALE_GENERATOR, 'FORBIDDEN');
      require(!UNISWAP_LOCKER.uniswapPairIsInitialised(address(_presaleToken), address(_baseToken)), 'PAIR INITIALISED');
      
      PRESALE_INFO.PRESALE_IN_ETH = address(_baseToken) == address(WETH);
      PRESALE_INFO.S_TOKEN = _presaleToken;
      PRESALE_INFO.B_TOKEN = _baseToken;
      PRESALE_FEE_INFO.OCTOFI_BASE_FEE = _unicryptBaseFee;
      PRESALE_FEE_INFO.OCTOFI_TOKEN_FEE = _unicryptTokenFee;
      PRESALE_FEE_INFO.REFERRAL_FEE = _referralFee;
      
      PRESALE_FEE_INFO.BASE_FEE_ADDRESS = _baseFeeAddress;
      PRESALE_FEE_INFO.TOKEN_FEE_ADDRESS = _tokenFeeAddress;
      PRESALE_FEE_INFO.REFERRAL_FEE_ADDRESS = _referralAddress;
      STATUS.ROUND1_LENGTH = PRESALE_SETTINGS.getRound1Length();
  }
  
  modifier onlyPresaleOwner() {
    require(PRESALE_INFO.PRESALE_OWNER == msg.sender, "NOT PRESALE OWNER");
    _;
  }
  
  function presaleStatus () public view returns (uint256) {
    if (STATUS.FORCE_FAILED) {
      return 3; // FAILED - force fail
    }
    if ((block.timestamp > PRESALE_INFO.END_DATE) && (STATUS.TOTAL_BASE_COLLECTED < PRESALE_INFO.CAP.SOFTCAP)) {
      return 3; // FAILED - softcap not met by end date
    }
    if (STATUS.TOTAL_BASE_COLLECTED >= PRESALE_INFO.CAP.HARDCAP) {
      return 2; // SUCCESS - hardcap met
    }
    if ((block.timestamp > PRESALE_INFO.END_DATE) && (STATUS.TOTAL_BASE_COLLECTED >= PRESALE_INFO.CAP.SOFTCAP)) {
      return 2; // SUCCESS - enddate and soft cap reached
    }
    if ((block.timestamp >= PRESALE_INFO.START_DATE) && (block.timestamp <= PRESALE_INFO.END_DATE)) {
      return 1; // ACTIVE - deposits enabled
    }
    return 0; // QUED - awaiting start date
  }
  
  // accepts msg.value for eth or _amount for ERC20 tokens
  function userDeposit (uint256 _amount) external payable nonReentrant {
    require(presaleStatus() == 1, 'NOT ACTIVE'); // ACTIVE
    if (STATUS.WHITELIST_ONLY) {
      require(WHITELIST.contains(msg.sender), 'NOT WHITELISTED');
    }

    require(_amount >= PRESALE_INFO.MIN_SPEND_PER_BUYER, 'MIN CONTRIBUTION');

    // Presale Round 1 - require participant to hold a certain token and balance
    if (block.timestamp < PRESALE_INFO.START_DATE + STATUS.ROUND1_LENGTH) { // 276 blocks = 1 hour
        require(PRESALE_SETTINGS.userHoldsSufficientRound1Token(msg.sender), 'INSUFFICENT ROUND 1 TOKEN BALANCE');
    }
    BuyerInfo storage buyer = BUYERS[msg.sender];
    uint256 amount_in = PRESALE_INFO.PRESALE_IN_ETH ? msg.value : _amount;
    uint256 allowance = PRESALE_INFO.MAX_SPEND_PER_BUYER.sub(buyer.baseDeposited);
    uint256 remaining = PRESALE_INFO.CAP.HARDCAP - STATUS.TOTAL_BASE_COLLECTED;
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
      (payable(msg.sender)).transfer(msg.value.sub(amount_in));
    }
    // deduct non ETH token from user
    if (!PRESALE_INFO.PRESALE_IN_ETH) {
      TransferHelper.safeTransferFrom(address(PRESALE_INFO.B_TOKEN), msg.sender, address(this), amount_in);
    }
  }
  
  // withdraw presale tokens
  // percentile withdrawls allows fee on transfer or rebasing tokens to still work
  function userWithdrawTokens () external nonReentrant {
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
  function userWithdrawBaseTokens () external nonReentrant {
    require(presaleStatus() == 3, 'NOT FAILED'); // FAILED
    BuyerInfo storage buyer = BUYERS[msg.sender];
    uint256 baseRemainingDenominator = STATUS.TOTAL_BASE_COLLECTED.sub(STATUS.TOTAL_BASE_WITHDRAWN);
    uint256 remainingBaseBalance = PRESALE_INFO.PRESALE_IN_ETH ? address(this).balance : PRESALE_INFO.B_TOKEN.balanceOf(address(this));
    uint256 tokensOwed = remainingBaseBalance.mul(buyer.baseDeposited).div(baseRemainingDenominator);
    require(tokensOwed > 0, 'NOTHING TO WITHDRAW');
    STATUS.TOTAL_BASE_WITHDRAWN = STATUS.TOTAL_BASE_WITHDRAWN.add(buyer.baseDeposited);
    buyer.baseDeposited = 0;
    TransferHelper.safeTransferBaseToken(address(PRESALE_INFO.B_TOKEN), payable(msg.sender), tokensOwed, !PRESALE_INFO.PRESALE_IN_ETH);
  }

  function emergencyUserWithdrawBaseTokens () external nonReentrant {

    require(block.timestamp < PRESALE_INFO.END_DATE - PRESALE_SETTINGS.getEmergencyWithdrawPreventionTime(), 'MIN EMERGENCY TIME' );

    BuyerInfo storage buyer = BUYERS[msg.sender];
    uint256 baseRemainingDenominator = STATUS.TOTAL_BASE_COLLECTED.sub(STATUS.TOTAL_BASE_WITHDRAWN);
    uint256 remainingBaseBalance = PRESALE_INFO.PRESALE_IN_ETH ? address(this).balance : PRESALE_INFO.B_TOKEN.balanceOf(address(this));
    uint256 tokensOwed = remainingBaseBalance.mul(buyer.baseDeposited).div(baseRemainingDenominator);
    require(tokensOwed > 0, 'NOTHING TO WITHDRAW');

    uint256 baseToTransfer = tokensOwed.sub(tokensOwed.mul(PRESALE_SETTINGS.getWithdrawPenaltyPercent()).div(PERCENTAGE_DIVISOR));

    STATUS.TOTAL_TOKENS_SOLD = STATUS.TOTAL_TOKENS_SOLD.sub(buyer.tokensOwed);
    STATUS.TOTAL_BASE_COLLECTED = STATUS.TOTAL_BASE_COLLECTED.sub(buyer.baseDeposited);

    buyer.baseDeposited = 0;
    buyer.tokensOwed = 0;

    TransferHelper.safeTransferBaseToken(address(PRESALE_INFO.B_TOKEN), payable(msg.sender), baseToTransfer, !PRESALE_INFO.PRESALE_IN_ETH);
  }
  
  // on presale failure
  // allows the owner to withdraw the tokens they sent for presale & initial liquidity
  function ownerWithdrawTokens () external onlyPresaleOwner {
    require(presaleStatus() == 3); // FAILED
    TransferHelper.safeTransfer(address(PRESALE_INFO.S_TOKEN), PRESALE_INFO.PRESALE_OWNER, PRESALE_INFO.S_TOKEN.balanceOf(address(this)));
  }
  

  // Can be called at any stage before or during the presale to cancel it before it ends.
  // If the pair already exists on uniswap and it contains the presale token as liquidity 
  // the final stage of the presale 'addLiquidity()' will fail. This function 
  // allows anyone to end the presale prematurely to release funds in such a case.
  function forceFailIfPairExists () external {
    require(!STATUS.LP_GENERATION_COMPLETE && !STATUS.FORCE_FAILED);
    if (UNISWAP_LOCKER.uniswapPairIsInitialised(address(PRESALE_INFO.S_TOKEN), address(PRESALE_INFO.B_TOKEN))) {
        STATUS.FORCE_FAILED = true;
    }
  }
  
  // if something goes wrong in LP generation
  function forceFailByOctofi () external {
      require(msg.sender == OCTOFI_FEE_ADDRESS);
      STATUS.FORCE_FAILED = true;
  }

  function forceFailByPresaleOwner() external onlyPresaleOwner {
    require(presaleStatus() == 1, 'NOT ACTIVE');
    STATUS.FORCE_FAILED = true;
  }
  
  // on presale success, this is the final step to end the presale, lock liquidity and enable withdrawls of the sale token.
  // This function does not use percentile distribution. Rebasing mechanisms, fee on transfers, or any deflationary logic
  // are not taken into account at this stage to ensure stated liquidity is locked and the pool is initialised according to 
  // the presale parameters and fixed prices.
  function addLiquidity() external nonReentrant {
    require(!STATUS.LP_GENERATION_COMPLETE, 'GENERATION COMPLETE');
    require(presaleStatus() == 2, 'NOT SUCCESS'); // SUCCESS
    // Fail the presale if the pair exists and contains presale token liquidity
    if (UNISWAP_LOCKER.uniswapPairIsInitialised(address(PRESALE_INFO.S_TOKEN), address(PRESALE_INFO.B_TOKEN))) {
        STATUS.FORCE_FAILED = true;
        return;
    }
    
    uint256 unicryptBaseFee = STATUS.TOTAL_BASE_COLLECTED.mul(PRESALE_FEE_INFO.OCTOFI_BASE_FEE).div(PERCENTAGE_DIVISOR);
    
    // base token liquidity
    uint256 baseLiquidity = STATUS.TOTAL_BASE_COLLECTED.sub(unicryptBaseFee).mul(PRESALE_INFO.DEX.LIQUIDITY_PERCENT).div(PERCENTAGE_DIVISOR);
    if (PRESALE_INFO.PRESALE_IN_ETH) {
        WETH.deposit{value : baseLiquidity}();
    }
    TransferHelper.safeApprove(address(PRESALE_INFO.B_TOKEN), address(UNISWAP_LOCKER), baseLiquidity);
    
    // sale token liquidity
    uint256 tokenLiquidity = baseLiquidity.mul(PRESALE_INFO.DEX.LISTING_RATE).div(10 ** uint256(PRESALE_INFO.B_TOKEN.decimals()));
    TransferHelper.safeApprove(address(PRESALE_INFO.S_TOKEN), address(UNISWAP_LOCKER), tokenLiquidity);
    
    UNISWAP_LOCKER.lockLiquidity(PRESALE_INFO.B_TOKEN, PRESALE_INFO.S_TOKEN, baseLiquidity, tokenLiquidity, block.timestamp + PRESALE_INFO.LOCK_PERIOD, PRESALE_INFO.PRESALE_OWNER);
    
    // transfer fees
    uint256 unicryptTokenFee = STATUS.TOTAL_TOKENS_SOLD.mul(PRESALE_FEE_INFO.OCTOFI_TOKEN_FEE).div(PERCENTAGE_DIVISOR);
    // referrals are checked for validity in the presale generator
    if (PRESALE_FEE_INFO.REFERRAL_FEE_ADDRESS != address(0)) {
        // Base token fee
        uint256 referralBaseFee = unicryptBaseFee.mul(PRESALE_FEE_INFO.REFERRAL_FEE).div(PERCENTAGE_DIVISOR);
        TransferHelper.safeTransferBaseToken(address(PRESALE_INFO.B_TOKEN), PRESALE_FEE_INFO.REFERRAL_FEE_ADDRESS, referralBaseFee, !PRESALE_INFO.PRESALE_IN_ETH);
        unicryptBaseFee = unicryptBaseFee.sub(referralBaseFee);
        // Token fee
        uint256 referralTokenFee = unicryptTokenFee.mul(PRESALE_FEE_INFO.REFERRAL_FEE).div(PERCENTAGE_DIVISOR);
        TransferHelper.safeTransfer(address(PRESALE_INFO.S_TOKEN), PRESALE_FEE_INFO.REFERRAL_FEE_ADDRESS, referralTokenFee);
        unicryptTokenFee = unicryptTokenFee.sub(referralTokenFee);
    }
    TransferHelper.safeTransferBaseToken(address(PRESALE_INFO.B_TOKEN), PRESALE_FEE_INFO.BASE_FEE_ADDRESS, unicryptBaseFee, !PRESALE_INFO.PRESALE_IN_ETH);
    TransferHelper.safeTransfer(address(PRESALE_INFO.S_TOKEN), PRESALE_FEE_INFO.TOKEN_FEE_ADDRESS, unicryptTokenFee);
    
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
  }
  
  function updateMaxSpendLimit(uint256 _maxSpend) external onlyPresaleOwner {
    PRESALE_INFO.MAX_SPEND_PER_BUYER = _maxSpend;
  }
  
  // postpone or bring a presale forward, this will only work when a presale is inactive.
  // i.e. current start date > block.timestamp
  function updateDates(uint256 _startDate, uint256 _endDate) external onlyPresaleOwner {
    require(PRESALE_INFO.START_DATE > block.timestamp);
    require(_endDate.sub(_startDate) <= PRESALE_SETTINGS.getMaxPresaleLength());
    PRESALE_INFO.START_DATE = _startDate;
    PRESALE_INFO.END_DATE = _endDate;
  }

  // editable at any stage of the presale
  function setWhitelistFlag(bool _flag) external onlyPresaleOwner {
    STATUS.WHITELIST_ONLY = _flag;
  }

  // editable at any stage of the presale
  function editWhitelist(address[] memory _users, bool _add) external onlyPresaleOwner {
    if (_add) {
        for (uint i = 0; i < _users.length; i++) {
          WHITELIST.add(_users[i]);
        }
    } else {
        for (uint i = 0; i < _users.length; i++) {
          WHITELIST.remove(_users[i]);
        }
    }
  }

  // whitelist getters
  function getWhitelistedUsersLength () external view returns (uint256) {
    return WHITELIST.length();
  }
  
  function getWhitelistedUserAtIndex (uint256 _index) external view returns (address) {
    return WHITELIST.at(_index);
  }
  
  function getUserWhitelistStatus (address _user) external view returns (bool) {
    return WHITELIST.contains(_user);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}