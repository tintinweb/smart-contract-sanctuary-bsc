//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library Zero {
  function requireNotZero(uint a) internal pure {
    require(a != 0, "require not zero");
  }

  function requireNotZero(address addr) internal pure {
    require(addr != address(0), "require not zero address");
  }

  function notZero(address addr) internal pure returns(bool) {
    return !(addr == address(0));
  }

  function isZero(address addr) internal pure returns(bool) {
    return addr == address(0);
  }
}


library ToAddress {

  function toAddr(bytes memory source) internal pure returns(address addr) {
    assembly { addr := mload(add(source,0x14)) }
    return addr;
  }
}

contract InvestorsStorage {
  struct investor {
    uint keyIndex;
    uint value;
    uint valueUsd;
    uint paymentTime;
    uint refBonus;
    uint refUsd;
    uint turnoverUsd;
    uint refFirstUsd;
    uint refSecondUsd;
    uint refThirdUsd;
    uint refFourthUsd;
    uint refFifthUsd;
    uint refSixthUsd;
    uint refSeventhUsd;
  }

  struct itmap {
    mapping(address => investor) data;
    address[] keys;
  }
  
  itmap private s;
  address private owner;

  modifier onlyOwner() {
    require(msg.sender == owner, "access denied");
    _;
  }

  constructor() {
    owner = msg.sender;
  }

  function insert(address addr, uint value, uint valueUsd) public onlyOwner returns (bool) {
    uint keyIndex = s.data[addr].keyIndex;
    if (keyIndex != 0) return false;
    s.data[addr].value = value;
    s.data[addr].valueUsd = valueUsd;

    uint keysLength = s.keys.length;
    keyIndex = keysLength+1;
    
    s.data[addr].keyIndex = keyIndex;
    s.keys.push(addr);
    return true;
  }

  function investorFullInfo(address addr) public view returns(uint, uint, uint, uint) {
    return (
      s.data[addr].keyIndex,
      s.data[addr].value,
      s.data[addr].paymentTime,
      s.data[addr].refBonus
    );
  }

  function investorBaseInfo(address addr) public view returns(uint, uint, uint, uint, uint) {
    return (
      s.data[addr].value,
      s.data[addr].valueUsd,
      s.data[addr].paymentTime,
      s.data[addr].refBonus,
      s.data[addr].refUsd
    );
  }

  function investorLevelsInfo(address addr) public view returns(uint, uint, uint, uint, uint, uint, uint) {
    return (
      s.data[addr].refFirstUsd,
      s.data[addr].refSecondUsd,
      s.data[addr].refThirdUsd,
      s.data[addr].refFourthUsd,
      s.data[addr].refFifthUsd,
      s.data[addr].refSixthUsd,
      s.data[addr].refSeventhUsd
    );
  }

  function investorShortInfo(address addr) public view returns(uint, uint) {
    return (
      s.data[addr].value,
      s.data[addr].refBonus
    );
  }

  function addRefBonus(address addr, uint refBonus, uint refUsd, uint turnoverUsd, uint level) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].refBonus += refBonus;
    s.data[addr].refUsd += refUsd;
    s.data[addr].turnoverUsd += turnoverUsd;

    if (level == 1) {
     s.data[addr].refFirstUsd += refUsd;
    } else if (level == 2) {
      s.data[addr].refSecondUsd += refUsd;
    } else if (level == 3) {
      s.data[addr].refThirdUsd += refUsd;
    } else if (level == 4) {
      s.data[addr].refFourthUsd += refUsd;
    } else if (level == 5) {
      s.data[addr].refFifthUsd += refUsd;
    } else if (level == 6) {
      s.data[addr].refSixthUsd += refUsd;
    } else if (level == 7) {
      s.data[addr].refSeventhUsd += refUsd;
    }
    return true;
  }

  function addValue(address addr, uint value, uint valueUsd) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].value += value;
    s.data[addr].valueUsd += valueUsd;
    return true;
  }

  function setPaymentTime(address addr, uint paymentTime) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].paymentTime = paymentTime;
    return true;
  }

  function setRefBonus(address addr, uint refBonus) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].refBonus = refBonus;
    return true;
  }

  function keyFromIndex(uint i) public view returns (address) {
    return s.keys[i];
  }

  function contains(address addr) public view returns (bool) {
    return s.data[addr].keyIndex > 0;
  }

  function size() public view returns (uint) {
    return s.keys.length;
  }

  function iterStart() public pure returns (uint) {
    return 1;
  }
}

library Percent {
  // Solidity automatically throws when dividing by 0
  struct percent {
    uint num;
    uint den;
  }
  function mul(percent storage p, uint a) internal view returns (uint) {
    if (a == 0) {
      return 0;
    }
    return a*p.num/p.den;
  }

  function div(percent storage p, uint a) internal view returns (uint) {
    return a/p.num*p.den;
  }

  function sub(percent storage p, uint a) internal view returns (uint) {
    uint b = mul(p, a);
    if (b >= a) return 0;
    return a - b;
  }

  function add(percent storage p, uint a) internal view returns (uint) {
    return a + mul(p, a);
  }
}

contract Crowdsale is Context, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Percent for Percent.percent;
    using Zero for *;
    using ToAddress for *;

    mapping(uint => Percent.percent) internal m_refPercent;

    // percents 
    Percent.percent private m_adminPercent = Percent.percent(15, 100); // 15/100*100% = 15%
    Percent.percent private m_corporatePercent = Percent.percent(60, 100); // 60/100*100% = 60%

    enum CrowdsaleStage { STAGE_ONE, STAGE_TWO, STAGE_THREE, STAGE_FOUR }

    CrowdsaleStage public _stage = CrowdsaleStage.STAGE_ONE;

    uint256 public _rate;

    address payable _wallet;

    address payable _walletCorporate;

    address _admin;

    IERC20 public _token;

    uint256 public _weiRaised;

    uint256 public _tokensSold;

    uint256 public investmentsNum;

    mapping(address => uint256) private _contribution;

    mapping(address => bool) private m_referrals;

    mapping(address => address) public referral_tree;

    event TokenPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount, uint256 when);

    event WithdrawBNB(address indexed admin, uint256 value);
    
    event PresaleEnded(address indexed admin, uint256 value);

    event LogBalanceChanged(uint256 when, uint256 balance);

    event LogNewReferral(address indexed addr, uint256 when, uint256 value);

    event LogNewInvestor(address indexed addr, uint256 when, uint256 value);

    event corporateWalletChanged(address indexed oldWallet, address indexed newWallet);

    AggregatorV3Interface internal priceFeed;

    InvestorsStorage internal m_investors;

    modifier onlyAdmin() {
        require(_admin == _msgSender(), "Called from non admin wallet");
        _;
    }

    modifier minAmount() {
        require(_getUsdAmount(msg.value) >= 100,"Minimal amount is $100");
        _;
    }

    modifier activeSponsor(address walletSponsor) {
        require(m_investors.contains(walletSponsor) == true,"There is no such sponsor");
        require(walletSponsor != _msgSender(),"You need a sponsor referral link, not yours");
        _;
    }

    modifier balanceChanged {
        _;
        emit LogBalanceChanged(block.timestamp, address(this).balance);
    }

    modifier checkFinalStage(uint stage) {
      require(uint(_stage) < stage,"This stage is now or past");
      _;
    }

    constructor(IERC20 token, address payable wallet, address payable walletCorporate, uint256 rate) {
        _token = token;
        _wallet = wallet;
        _walletCorporate = walletCorporate;
        _admin = _msgSender();
        _rate = rate;

        m_investors = new InvestorsStorage();
        investmentsNum = 0;

        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);

        m_refPercent[0] = Percent.percent(8, 100); // 8/100*100% = 8%
	    m_refPercent[1] = Percent.percent(6, 100); // 6/100*100% = 6%
	    m_refPercent[2] = Percent.percent(4, 100); // 4/100*100% = 4%
	    m_refPercent[3] = Percent.percent(3, 100); // 3/100*100% = 3%
	    m_refPercent[4] = Percent.percent(1, 100); // 1/100*100% = 1%
	    m_refPercent[5] = Percent.percent(1, 100); // 1/100*100% = 1%
	    m_refPercent[6] = Percent.percent(2, 100); // 2/100*100% = 2%

      assert(m_investors.insert(wallet, 0, 0));
      referral_tree[wallet] = address(0);
    }

    fallback() external payable {
      address a = msg.data.toAddr();
      require(a.notZero(),"try to add sponsor wallet to a hex data");
      buyTokensFront(a);
    }

    function investorsNumber() public view returns(uint) {
        return m_investors.size();
    }

    function adminPercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_adminPercent.num, m_adminPercent.den);
    }

    function referrerPercent(uint level) public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_refPercent[level].num, m_refPercent[level].den);
    }

    function buyTokensFront(address sponsor) public payable minAmount activeSponsor(sponsor) balanceChanged nonReentrant {
        uint256 weiAmount = msg.value;

        address beneficiary = _msgSender();

        _prevalidatePurchase(beneficiary, weiAmount);

        uint256 tokenAmount = _getTokenAmount(weiAmount);

        _weiRaised = _weiRaised.add(weiAmount);

        _tokensSold += tokenAmount;

        _updateContribution(beneficiary, weiAmount);

        _token.transfer(beneficiary, tokenAmount);

        if (sponsor.notZero()) {
            address Sponsor = referral_tree[beneficiary];

            if (!Sponsor.notZero()) {
                referral_tree[beneficiary] = sponsor;
            }
            
            doMarketing(weiAmount);       
        } 

        // commission
        _wallet.transfer(m_adminPercent.mul(weiAmount)); 
        _walletCorporate.transfer(address(this).balance);
        
        // write to investors storage
        if (m_investors.contains(beneficiary)) {
            assert(m_investors.addValue(beneficiary, weiAmount, _getUsdAmount(weiAmount)));
        } else {
            assert(m_investors.insert(beneficiary, weiAmount, _getUsdAmount(weiAmount)));
            emit LogNewInvestor(beneficiary, block.timestamp, weiAmount); 
        }

        investmentsNum++; 

        emit TokenPurchased(_msgSender(), beneficiary, weiAmount, tokenAmount, block.timestamp);
    }

    function doMarketing(uint256 weiAmount) internal {
      // level 1
      address payable sponsorOne = payable(referral_tree[_msgSender()]);
      if (notZeroNotSender(sponsorOne) && m_investors.contains(sponsorOne)) {
          addReferralBonus(sponsorOne, weiAmount, 1);
          // level 2
          address payable sponsorTwo = payable(referral_tree[sponsorOne]);
          if (notZeroNotSender(sponsorTwo) && m_investors.contains(sponsorTwo)) { 
              addReferralBonus(sponsorTwo, weiAmount, 2);
              // level 3
              address payable sponsorThree = payable(referral_tree[sponsorTwo]);
              if (notZeroNotSender(sponsorThree) && m_investors.contains(sponsorThree)) { 
                  addReferralBonus(sponsorThree, weiAmount, 3);
                  // level 4
                  address payable sponsorFour = payable(referral_tree[sponsorThree]);
                  if (notZeroNotSender(sponsorFour) && m_investors.contains(sponsorFour)) { 
                      addReferralBonus(sponsorFour, weiAmount, 4);
                      // level 5
                      address payable sponsorFive = payable(referral_tree[sponsorFour]);
                      if (notZeroNotSender(sponsorFive) && m_investors.contains(sponsorFive)) { 
                          addReferralBonus(sponsorFive, weiAmount, 5);
                          // level 6
                          address payable sponsorSix = payable(referral_tree[sponsorFive]);
                          if (notZeroNotSender(sponsorSix) && m_investors.contains(sponsorSix)) { 
                              addReferralBonus(sponsorSix, weiAmount, 6);
                              // level 7
                              address payable sponsorSeven = payable(referral_tree[sponsorFive]);
                              if (notZeroNotSender(sponsorSeven) && m_investors.contains(sponsorSeven)) { 
                                  addReferralBonus(sponsorSeven, weiAmount, 7);
                              }
                          }
                      }
                  }
              }
          }
      }
    }

    function addReferralBonus(address payable sponsor, uint256 weiAmount, uint level) internal {
        uint index = level-1;
        uint reward = m_refPercent[index].mul(weiAmount);
        assert(m_investors.addRefBonus(sponsor, reward, _getUsdAmount(reward), _getUsdAmount(weiAmount), level));
        sponsor.transfer(reward);      
    }

    function notZeroNotSender(address addr) internal view returns(bool) {
        return addr.notZero() && addr != _msgSender();
    }

    function getTokenPrice() public view returns (uint256) {
        return _getTokenAmount(1*10**8);
    }

    function _getBNBPrice() internal view returns (int) {
        (
            , 
            int price,
            ,
            , 

        ) = priceFeed.latestRoundData();
        return price;
    }

    function _getUsdAmount(uint256 weiAmount) internal view returns (uint256){
        int bnbPrice = _getBNBPrice();

        uint256 _bnbPrice = uint256(bnbPrice);
        uint256 _Amount = ((weiAmount*(_bnbPrice*10**10))/(10**18))/(10**18);

        return _Amount;   
    }

    function _getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
        int bnbPrice = _getBNBPrice();

        uint256 _bnbPrice = uint256(bnbPrice);

        uint256 _Amount = _bnbPrice/_rate;

        return weiAmount.mul(_Amount);
    }

    function _forwardFunds(uint256 weiAmount) internal {
        _walletCorporate.transfer(weiAmount); // transfer bnb balance of this contract
    }

    function _updateContribution(address beneficiary, uint256 weiAmount) internal {
        _contribution[beneficiary] += weiAmount;
    }

    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    function _prevalidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(beneficiary != address(0), "Beneficiary is zero address");
        require(weiAmount != 0, "Wei amount is zero");
        this;
    }

    function withdrawFunds() public onlyAdmin {
        uint256 weiAmount = address(this).balance;

        _forwardFunds(address(this).balance); 

        emit WithdrawBNB(_msgSender(), weiAmount);
    }

    function endPresale() public onlyAdmin {
        uint256 weiAmount = address(this).balance;

        _forwardFunds(address(this).balance); 

        _token.transfer(_walletCorporate, _token.balanceOf(address(this)));

        emit PresaleEnded(_msgSender(), weiAmount);
    }

    function setCrowdsaleStage(uint stage, uint256 rate) public onlyAdmin checkFinalStage(stage) {
        if (uint(CrowdsaleStage.STAGE_TWO) == stage) {

          _stage = CrowdsaleStage.STAGE_TWO;
          _rate = 12500000;

        } else if (uint(CrowdsaleStage.STAGE_THREE) == stage) {

          _stage = CrowdsaleStage.STAGE_THREE;
          _rate = rate;

        } else if (uint(CrowdsaleStage.STAGE_FOUR) == stage) {

          _stage = CrowdsaleStage.STAGE_FOUR;
          _rate = rate;

        }
    }

    function activateReferralLink(address sponsor, address referral) public onlyAdmin {
      assert(m_investors.insert(referral, 0, 0));
      referral_tree[referral] = sponsor;
    }

    function changeCorporateWallet(address payable wallet) public onlyAdmin {
      require(wallet != address(0), "New corporate address is the zero address");
      address oldWallet = _walletCorporate;
      _walletCorporate = wallet;
      emit corporateWalletChanged(oldWallet, wallet);
    }

    function investorInfo(address addr) public view returns(uint value, uint valueUsd, uint paymentTime, uint refBonus, uint refUsd, bool isReferral) {
        (value, valueUsd, paymentTime, refBonus, refUsd) = m_investors.investorBaseInfo(addr);
        isReferral = m_referrals[addr];
    }

    function investorLevelsInfo(address addr) public view returns(uint refFirstUsd, uint refSecondUsd, uint refThirdUsd, uint refFourthUsd, uint refFifthUsd, uint refSixthUsd, uint refSeventhUsd, bool isReferral) {
        (refFirstUsd, refSecondUsd, refThirdUsd, refFourthUsd, refFifthUsd, refSixthUsd, refSeventhUsd) = m_investors.investorLevelsInfo(addr);
        isReferral = m_referrals[addr];
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}