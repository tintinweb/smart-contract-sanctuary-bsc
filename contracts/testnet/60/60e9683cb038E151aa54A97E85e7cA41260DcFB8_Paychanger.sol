//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
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

contract TokenVesting is Ownable, ReentrancyGuard{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    struct VestingSchedule{
        bool initialized;
        // beneficiary of tokens after they are released
        address  beneficiary;
        // cliff period in seconds
        uint256  cliff;
        // start time of the vesting period
        uint256  start;
        // duration of the vesting period in seconds
        uint256  duration;
        // duration of a slice period for the vesting in seconds
        uint256 slicePeriodSeconds;
        // whether or not the vesting is revocable
        bool  revocable;
        // total amount of tokens to be released at the end of the vesting
        uint256 amountTotal;
        // amount of tokens released
        uint256  released;
        // whether or not the vesting has been revoked
        bool revoked;
    }

    // address of the ERC20 token
    IERC20 immutable private _token;

    bytes32[] private vestingSchedulesIds;
    mapping(bytes32 => VestingSchedule) private vestingSchedules;
    uint256 private vestingSchedulesTotalAmount;
    mapping(address => uint256) private holdersVestingCount;
    mapping(address => uint256) internal holdersVestingTokens;

    event Released(uint256 amount);
    event Revoked();

    /**
    * @dev Reverts if no vesting schedule matches the passed identifier.
    */
    modifier onlyIfVestingScheduleExists(bytes32 vestingScheduleId) {
        require(vestingSchedules[vestingScheduleId].initialized == true);
        _;
    }

    /**
    * @dev Reverts if the vesting schedule does not exist or has been revoked.
    */
    modifier onlyIfVestingScheduleNotRevoked(bytes32 vestingScheduleId) {
        require(vestingSchedules[vestingScheduleId].initialized == true);
        require(vestingSchedules[vestingScheduleId].revoked == false);
        _;
    }

    /**
     * @dev Creates a vesting contract.
     * @param token address of the ERC20 token contract
     */
    constructor(IERC20 token) {
        _token = token;
    }

    receive() external payable {}

    fallback() external payable {}

    /**
    * @dev Returns the number of vesting schedules associated to a beneficiary.
    * @return the number of vesting schedules
    */
    function getVestingSchedulesCountByBeneficiary(address _beneficiary)
    external
    view
    returns(uint256){
        return holdersVestingCount[_beneficiary];
    }

    /**
    * @dev Returns the vesting schedule id at the given index.
    * @return the vesting id
    */
    function getVestingIdAtIndex(uint256 index)
    external
    view
    returns(bytes32){
        require(index < getVestingSchedulesCount(), "TokenVesting: index out of bounds");
        return vestingSchedulesIds[index];
    }

    /**
    * @notice Returns the vesting schedule information for a given holder and index.
    * @return the vesting schedule structure information
    */
    function getVestingScheduleByAddressAndIndex(address holder, uint256 index)
    external
    view
    returns(VestingSchedule memory){
        return getVestingSchedule(computeVestingScheduleIdForAddressAndIndex(holder, index));
    }


    /**
    * @notice Returns the total amount of vesting schedules.
    * @return the total amount of vesting schedules
    */
    function getVestingSchedulesTotalAmount()
    public 
    view
    returns(uint256){
        return vestingSchedulesTotalAmount;
    }

    /**
    * @dev Returns the address of the ERC20 token managed by the vesting contract.
    */
    function getToken()
    external
    view
    returns(address){
        return address(_token);
    }

    /**
    * @notice Creates a new vesting schedule for a beneficiary.
    * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
    * @param _start start time of the vesting period
    * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
    * @param _duration duration in seconds of the period in which the tokens will vest
    * @param _slicePeriodSeconds duration of a slice period for the vesting in seconds
    * @param _revocable whether the vesting is revocable or not
    * @param _amount total amount of tokens to be released at the end of the vesting
    */
    function createVestingSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        bool _revocable,
        uint256 _amount
    )
        public
        onlyOwner returns(bytes32) {

        require(_duration > 0, "TokenVesting: duration must be > 0");
        require(_amount > 0, "TokenVesting: amount must be > 0");
        require(_slicePeriodSeconds >= 1, "TokenVesting: slicePeriodSeconds must be >= 1");
        bytes32 vestingScheduleId = this.computeNextVestingScheduleIdForHolder(_beneficiary);
        uint256 cliff = _start.add(_cliff);
        vestingSchedules[vestingScheduleId] = VestingSchedule(
            true,
            _beneficiary,
            cliff,
            _start,
            _duration,
            _slicePeriodSeconds,
            _revocable,
            _amount,
            0,
            false
        );
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount.add(_amount);
        vestingSchedulesIds.push(vestingScheduleId);
        uint256 currentVestingCount = holdersVestingCount[_beneficiary];
        holdersVestingCount[_beneficiary] = currentVestingCount.add(1);
        holdersVestingTokens[_beneficiary] += _amount;
        return vestingScheduleId;
    }

    /**
    * @notice Revokes the vesting schedule for given identifier.
    * @param vestingScheduleId the vesting schedule identifier
    */
    function revoke(bytes32 vestingScheduleId)
        public
        onlyOwner
        onlyIfVestingScheduleNotRevoked(vestingScheduleId){
        VestingSchedule storage vestingSchedule = vestingSchedules[vestingScheduleId];
        require(vestingSchedule.revocable == true, "TokenVesting: vesting is not revocable");
        /*uint256 vestedAmount = _computeReleasableAmount(vestingSchedule);
        if(vestedAmount > 0){
            release(vestingScheduleId, vestedAmount);
        }*/
        uint256 unreleased = vestingSchedule.amountTotal.sub(vestingSchedule.released);
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount.sub(unreleased);
        vestingSchedule.revoked = true;
    }

    /**
    * @notice Release vested amount of tokens.
    * @param vestingScheduleId the vesting schedule identifier
    * @param amount the amount to release
    */
    function release(
        bytes32 vestingScheduleId,
        address beneficiary,
        uint256 amount
    )
        public
        nonReentrant
        onlyIfVestingScheduleNotRevoked(vestingScheduleId){
        VestingSchedule storage vestingSchedule = vestingSchedules[vestingScheduleId];
        bool isBeneficiary = beneficiary == vestingSchedule.beneficiary;
        bool isOwner = beneficiary == owner();
        require(
            isBeneficiary || isOwner,
            "TokenVesting: only beneficiary and owner can release vested tokens"
        );
        uint256 vestedAmount = _computeReleasableAmount(vestingSchedule);
        require(vestedAmount >= amount, "TokenVesting: cannot release tokens, not enough vested tokens");
        vestingSchedule.released = vestingSchedule.released.add(amount);
        //address payable beneficiaryPayable = payable(vestingSchedule.beneficiary);
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount.sub(amount);
        //_token.safeTransfer(beneficiaryPayable, amount);
        //return amount;
    }

    /**
    * @dev Returns the number of vesting schedules managed by this contract.
    * @return the number of vesting schedules
    */
    function getVestingSchedulesCount()
        public
        view
        returns(uint256){
        return vestingSchedulesIds.length;
    }

    /**
    * @notice Computes the vested amount of tokens for the given vesting schedule identifier.
    * @return the vested amount
    */
    function computeReleasableAmount(bytes32 vestingScheduleId)
        public
        onlyIfVestingScheduleNotRevoked(vestingScheduleId)
        view
        returns(uint256){
        VestingSchedule storage vestingSchedule = vestingSchedules[vestingScheduleId];
        return _computeReleasableAmount(vestingSchedule);
    }

    /**
    * @notice Returns the vesting schedule information for a given identifier.
    * @return the vesting schedule structure information
    */
    function getVestingSchedule(bytes32 vestingScheduleId)
        public
        view
        returns(VestingSchedule memory){
        return vestingSchedules[vestingScheduleId];
    }

    /**
    * @dev Computes the next vesting schedule identifier for a given holder address.
    */
    function computeNextVestingScheduleIdForHolder(address holder)
        public
        view
        returns(bytes32){
        return computeVestingScheduleIdForAddressAndIndex(holder, holdersVestingCount[holder]);
    }

    /**
    * @dev Returns the last vesting schedule for a given holder address.
    */
    function getLastVestingScheduleForHolder(address holder)
        public
        view
        returns(VestingSchedule memory){
        return vestingSchedules[computeVestingScheduleIdForAddressAndIndex(holder, holdersVestingCount[holder] - 1)];
    }

    /**
    * @dev Computes the vesting schedule identifier for an address and an index.
    */
    function computeVestingScheduleIdForAddressAndIndex(address holder, uint256 index)
        public
        pure
        returns(bytes32){
        return keccak256(abi.encodePacked(holder, index));
    }

    /**
    * @dev Computes the releasable amount of tokens for a vesting schedule.
    * @return the amount of releasable tokens
    */
    function _computeReleasableAmount(VestingSchedule memory vestingSchedule)
    internal
    view
    returns(uint256){
        uint256 currentTime = getCurrentTime();
        if ((currentTime < vestingSchedule.cliff) || vestingSchedule.revoked == true) {
            return 0;
        } else if (currentTime >= vestingSchedule.start.add(vestingSchedule.duration)) {
            return vestingSchedule.amountTotal.sub(vestingSchedule.released);
        } else {
            uint256 timeFromStart = currentTime.sub(vestingSchedule.start);
            uint secondsPerSlice = vestingSchedule.slicePeriodSeconds;
            uint256 vestedSlicePeriods = timeFromStart.div(secondsPerSlice);
            uint256 vestedSeconds = vestedSlicePeriods.mul(secondsPerSlice);
            uint256 vestedAmount = vestingSchedule.amountTotal.mul(vestedSeconds).div(vestingSchedule.duration);
            vestedAmount = vestedAmount.sub(vestingSchedule.released);
            return vestedAmount;
        }
    }

    function getCurrentTime()
        internal
        virtual
        view
        returns(uint256){
        return block.timestamp;
    }

    function getVestingAmountByAddress(address holder) public view returns(uint256) {
        return holdersVestingTokens[holder];
    }

}

contract InvestorsStorage is Ownable {

  struct investorSubscription {
    bytes32 uid;
    uint value;
    uint valueUsd;
    uint startFrom;
    uint endDate;
    uint takenFromPool;
    uint takenFromPoolUsd;
    bool active;
    bool vesting;
  }

  struct investor {
    uint keyIndex;
    uint bonusUsd;
    uint refBonus;
    uint turnoverToken;
    uint turnoverUsd;
    uint refFirst;
    uint careerPercent;
    investorSubscription[] subscriptions;
  }

  struct itmap {
    mapping(address => investor) data;
    address[] keys;
  }
  
  itmap private s;

  constructor() {

  }

  function insertInvestor(address addr) public onlyOwner returns (bool) {
    uint keyIndex = s.data[addr].keyIndex;
    if (keyIndex != 0) return false;

    uint keysLength = s.keys.length;
    keyIndex = keysLength+1;
    
    s.data[addr].keyIndex = keyIndex;
    s.keys.push(addr);
    return true;
  }

  function insertSubscription(bytes32 uid, address addr, uint value, uint valueUsd) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;

    s.data[addr].subscriptions.push(
      investorSubscription(uid, value, valueUsd, block.timestamp, 0, 0, 0, true, true)
    );

    return true;
  }

  function setNotActiveSubscription(address addr, uint index) public onlyOwner returns (bool) {
      s.data[addr].subscriptions[index].endDate = block.timestamp;
      s.data[addr].subscriptions[index].active = false;

      return true;
  }

  function setCareerPercent(address addr, uint careerPercent) public onlyOwner {
    s.data[addr].careerPercent = careerPercent;
  }

  function setBonusUsd(address addr, uint bonusUsd, bool increment) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    if (increment) {
        s.data[addr].bonusUsd += bonusUsd;
    } else {
        s.data[addr].bonusUsd -= bonusUsd;
    }
    return true;
  }

  function setTakenFromPool(address addr, uint index, uint value, uint valueUsd) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].subscriptions[index].takenFromPool += value;
    s.data[addr].subscriptions[index].takenFromPoolUsd += valueUsd;
    return true;
  }

  function addTurnover(address addr, uint256 turnoverToken, uint256 turnoverUsd) public onlyOwner {
    s.data[addr].turnoverToken += turnoverToken;
    s.data[addr].turnoverUsd += turnoverUsd; 
  }
  
  function addRefBonus(address addr, uint refBonus, uint turnoverUsd, uint turnoverToken, uint level) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].refBonus += refBonus;
    s.data[addr].turnoverUsd += turnoverUsd;
    s.data[addr].turnoverToken += turnoverToken;

    if (level == 1) {
     s.data[addr].refFirst += refBonus;
    }  
    return true;
  }

  function investorTurnover(address addr) public view returns(uint, uint, uint) {
    return (
        s.data[addr].turnoverToken,
        s.data[addr].turnoverUsd,
        s.data[addr].careerPercent
    );
  }

  function investorReferralBonuses(address addr) public view returns(uint, uint) {
    return (
        s.data[addr].refFirst,
        s.data[addr].refBonus
    );
  }

  function investorSingleSubscriptionActive(address addr, uint index) public view returns(bytes32, uint, uint, uint, uint, bool) {
     return (
      s.data[addr].subscriptions[index].uid,
      s.data[addr].subscriptions[index].value,
      s.data[addr].subscriptions[index].valueUsd,
      s.data[addr].subscriptions[index].startFrom,
      s.data[addr].subscriptions[index].takenFromPoolUsd,
      s.data[addr].subscriptions[index].vesting
    );   
  }

  function investorSingleSubscriptionPool(address addr, uint index) public view returns(uint, uint, uint, uint, uint, bool) {
    return (
      s.data[addr].subscriptions[index].valueUsd,
      s.data[addr].subscriptions[index].startFrom,
      s.data[addr].subscriptions[index].endDate,
      s.data[addr].subscriptions[index].takenFromPool,
      s.data[addr].subscriptions[index].takenFromPoolUsd,
      s.data[addr].subscriptions[index].active
    );
  }

  function contains(address addr) public view returns (bool) {
    return s.data[addr].keyIndex > 0;
  }

  function haveValue(address addr) public view returns (bool) {
    if (s.data[addr].subscriptions.length > 0) {
        for(uint i = 0; i < s.data[addr].subscriptions.length; i++) {
            if (s.data[addr].subscriptions[i].active) {
                return true;
            }
        }

        return false;
    } else {
        return false;
    }
  }

  function getBonusUsd(address addr) public view returns (uint) {
    return s.data[addr].bonusUsd;
  }

  function getCareerPercent(address addr) public view returns (uint) {
    return s.data[addr].careerPercent;
  }

  function getTotalSubscription(address addr) public view returns (uint) {
      return s.data[addr].subscriptions.length;
  }

  function size() public view returns (uint) {
    return s.keys.length;
  }
}

error Package__BuyFailed();
error payment__Failed();

contract Paychanger is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Percent for Percent.percent;
    using Zero for *;

    struct careerInfo {
        uint percentFrom;
        uint turnoverFrom;
        uint turnoverTo;
    }

    careerInfo[] internal career;

    struct poolTransaction {
        uint date;
        uint value;
    }

    poolTransaction[] internal pools;

    uint256 public freezeInPools;

    mapping(uint => uint) public pools_reward;

    Percent.percent internal m_adminPercent = Percent.percent(40, 100); // 40/100*100% = 40%
    Percent.percent internal m_poolPercent = Percent.percent(10, 100); // 10/100*100% = 10%
    Percent.percent internal m_bonusUsdPercent = Percent.percent(30, 100); // 30/100*100% = 30%
    Percent.percent internal m_paymentComissionPercent = Percent.percent(10, 100); // 10/100*100% = 10%
    Percent.percent internal m_paymentReferralPercent = Percent.percent(10, 100); // 10/100*100% = 10%
    Percent.percent internal m_paymentCashbackPercent = Percent.percent(10, 100); // 10/100*100% = 10%

    IERC20 public _token;

    uint256 public _rate;

    address payable _wallet;

    mapping(address => bool) internal m_referrals;

    mapping(address => address) public referral_tree;

    uint256[4] public packages = [100,500,1000,2500];

    uint256 internal _durationVesting;

    uint256 internal _periodVesting;

    uint256 internal _cliffVesting;

    InvestorsStorage internal m_investors;

    TokenVesting internal vesting;

    event AdminWalletChanged(address indexed oldWallet, address indexed newWallet);

    event compressionBonusPaid(address indexed from, address indexed to, uint256 indexed package, uint256 value);

    event transactionCompleted(address indexed from, address indexed to, uint256 tokenAmount, string txdata);

    //PriceFeed internal priceFeed;
    AggregatorV3Interface internal priceFeed;

    modifier checkPackage(uint package) {
        require(_getUsdAmount(msg.value) >= package,"Wrong amount for this package");
        require(havePackage(package) == true, "There is no such package");
        _;
    }

    modifier activeSponsor(address walletSponsor) {
        require(m_investors.contains(walletSponsor) == true,"There is no such sponsor");
        //require(referral_tree[_msgSender()] == walletSponsor, "This is not your sponsor");
        require(walletSponsor != _msgSender(),"You need a sponsor referral link, not yours");
        _;
    }

    constructor(IERC20 token, address payable wallet, uint256 rate) {
      _token = token;
      _wallet = wallet;
      _rate = rate;

      m_investors = new InvestorsStorage();

      vesting = new TokenVesting(_token);

      _durationVesting = 31104000; //- 360days in seconds
      _periodVesting = 604800; //- 7 days in seconds
      _cliffVesting = 0;

      pools_reward[100] = 1;
      pools_reward[500] = 2;
      pools_reward[1000] = 3;
      pools_reward[2500] = 4;
      

        career.push(careerInfo(50, 0, 999)); //5%
        career.push(careerInfo(60, 1000, 2499)); //6%
        career.push(careerInfo(70, 2500, 4999)); //7%
        career.push(careerInfo(80, 5000, 9999)); //8%
        career.push(careerInfo(90, 10000, 24999)); //9%
        career.push(careerInfo(100, 25000, 49999)); //10%
        career.push(careerInfo(110, 50000, 99999)); //11%
        career.push(careerInfo(120, 100000, 249999)); //12%
        career.push(careerInfo(135, 250000, 499999)); //13,5%
        career.push(careerInfo(150, 500000, 999999)); //15%
        career.push(careerInfo(165, 1000000, 2499999)); //16,5%
        career.push(careerInfo(175, 2500000, 4999999)); //17,5%
        career.push(careerInfo(185, 5000000, 9999999)); //18,5%
        career.push(careerInfo(190, 10000000, 24999999)); //19%
        career.push(careerInfo(195, 25000000, 49999999)); //19,5%
        career.push(careerInfo(200, 50000000, 10000000000000000)); //20%

      priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526); //testnet
      //priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE); //mainnet

      assert(m_investors.insertInvestor(wallet));
      referral_tree[wallet] = address(0);
    }

    function havePackage(uint256 package) internal view returns(bool) {
        for (uint i = 0; i < packages.length; i++) {
            if (packages[i] == package) {
                return true;
            }
        }
        return false;
    }

    function buyPackage(uint256 package, address sponsor) public payable activeSponsor(sponsor) checkPackage(package) nonReentrant {
        address beneficiary = _msgSender();
        uint256 bonusPackage = 0;

        if (m_investors.getBonusUsd(beneficiary) > 0) {
            if (m_investors.getBonusUsd(beneficiary) <= m_bonusUsdPercent.mul(package)) {
                bonusPackage = m_investors.getBonusUsd(beneficiary);
            } else {
                bonusPackage = m_bonusUsdPercent.mul(package);               
            }
            m_investors.setBonusUsd(beneficiary, bonusPackage, false);
        }

        uint256 tokenAmountForPay = _getTokenAmountByUSD(package-bonusPackage);
        uint256 tokenAmount = _getTokenAmountByUSD(package);
        

      require(
          getAvailableTokenAmount() >= tokenAmount,
          "cannot buy a package because not sufficient tokens"
      );
      
      if (m_investors.contains(beneficiary)) {

        require(_token.allowance(_msgSender(),address(this)) >= tokenAmountForPay, "Please allow fund first");
        bool success = _token.transferFrom(_msgSender(), address(this), tokenAmountForPay);

        if (!success) {
          revert Package__BuyFailed();
        } else {
            uint adminAmount = 0;

            if (bonusPackage > 0) {
                adminAmount = m_adminPercent.mul(tokenAmount) - (tokenAmount-tokenAmountForPay);
            } else {
                adminAmount = m_adminPercent.mul(tokenAmount);
            }

            _token.transfer(_wallet, adminAmount);

          _sendToPools(tokenAmount);

          bytes32 vestingId = vesting.createVestingSchedule(beneficiary, block.timestamp, _cliffVesting, _durationVesting, _periodVesting, true, tokenAmount*2);
          assert(m_investors.insertSubscription(vestingId, beneficiary, tokenAmount, package));
          //транзакции + пулы ( подписки ) участвуют в х2, удалить рефку и компрессию

          if (sponsor.notZero()) {
            address Sponsor = referral_tree[beneficiary];

            if (Sponsor.isZero()) {
              referral_tree[beneficiary] = sponsor;
            }

            assert(m_investors.setBonusUsd(sponsor, 1, true));
            
            address payable mySponsor = payable(referral_tree[_msgSender()]);

            if (m_investors.haveValue(mySponsor)) {
              doMarketing(tokenAmount);
            }	
            compressionBonus(tokenAmount, package, mySponsor, 0, 1);    
          } 
        }
      }
    }

    /**
    * @dev Returns the amount of tokens that can be withdrawn by the owner.
    * @return the amount of tokens
    */
    function getAvailableTokenAmount()
        public
        view
        returns(uint256){
        return _token.balanceOf(address(this)).sub(vesting.getVestingSchedulesTotalAmount()).sub(freezeInPools);
    }

    function calculatePoolAmount(address addr) public view returns(uint totalAmount, uint availableAmount) {
        uint poolAmount;

        for (uint i = 0; i < m_investors.getTotalSubscription(addr); i++) {
            (uint _valueUsd, uint _startFrom, , uint _takenFromPool, , bool _active) = m_investors.investorSingleSubscriptionPool(addr, i);

            for (uint k = 0; k < pools.length; k++) {
                if (pools[k].date >= _startFrom && _active) {
                    poolAmount = pools[k].value*pools_reward[_valueUsd];
                    totalAmount += poolAmount;
                    availableAmount += poolAmount-_takenFromPool;
                }
            }
        }
    }

    function calculatePoolAmountBySubscription(address addr, uint index) public view returns(uint availableAmount) {
        (uint _valueUsd, uint _startFrom, , uint _takenFromPool, , bool _active) = m_investors.investorSingleSubscriptionPool(addr, index);

        if (_active) {
            for (uint k = 0; k < pools.length; k++) {
                if (pools[k].date >= _startFrom && _active) {
                    availableAmount += pools[k].value*pools_reward[_valueUsd]-_takenFromPool;
                }
            }
        }

    }

    function getInvestorSubscription(address addr, uint index) public view returns(bytes32 _uid, uint _value, uint _valueUsd, uint _startFrom, uint _takenFromPoolUsd, bool _vesting) {
      (_uid, _value, _valueUsd, _startFrom, _takenFromPoolUsd, _vesting) = m_investors.investorSingleSubscriptionActive(addr, index);
    }

    function compressionBonus(uint256 tokenAmount, uint256 package, address payable user, uint256 prevPercent, uint256 line) internal {
      address payable mySponsor = payable(referral_tree[user]);

      if (m_investors.haveValue(user)) {

        uint256 careerPercent = m_investors.getCareerPercent(user);

        m_investors.addTurnover(user, tokenAmount, package);
        checkCareerPercent(user);

        if (line == 1) {
          prevPercent = careerPercent;
        }
        if (line >= 2) {

            if (prevPercent < careerPercent) {

              uint256 finalPercent = career[careerPercent].percentFrom - career[prevPercent].percentFrom;
              uint bonus = tokenAmount*finalPercent/1000;//finalPercentValue.mul(tokenAmount);

              if (bonus > 0 && m_investors.haveValue(user)) {
                assert(m_investors.addRefBonus(user, bonus, _getUsdAmount(tokenAmount), tokenAmount, line));
                _token.transfer(user, bonus);
                emit compressionBonusPaid(_msgSender(), user, package, bonus);
              }

              prevPercent = careerPercent;
            }
        }
      }
      if (notZeroNotSender(mySponsor) && m_investors.contains(mySponsor)) {
        line = line + 1;
        compressionBonus(tokenAmount, package, mySponsor, prevPercent, line);
      }
    }

    function doMarketing(uint256 tokenAmount) internal {
      // level 1
      address payable sponsorOne = payable(referral_tree[_msgSender()]);
      if (notZeroNotSender(sponsorOne) && m_investors.contains(sponsorOne)) {
        addReferralBonus(sponsorOne, tokenAmount, 1);
      }
    }

    function withdraw(address payable beneficiary) public payable nonReentrant {
        require(_msgSender() == beneficiary, "you cannot access to release");

      for (uint i = 0; i < m_investors.getTotalSubscription(beneficiary); i++) {
          (bytes32 _uid, , uint _valueUsd, , ,) = m_investors.investorSingleSubscriptionActive(beneficiary, i);

        uint256 vestingAmount = vesting.computeReleasableAmount(_uid);
        uint256 vestingUsdAmount = _getUsdAmount(vestingAmount);
        uint256 poolAmount = calculatePoolAmountBySubscription(beneficiary, i);
        uint256 poolUsdAmount = _getUsdAmount(poolAmount);

          if ((vestingUsdAmount+poolUsdAmount) >= (_valueUsd*2)) {
            vesting.revoke(_uid);
          }
          
          vesting.release(_uid, beneficiary, vestingAmount);
          m_investors.setTakenFromPool(beneficiary, i, poolAmount, poolUsdAmount);
      }
    }

    function addReferralBonus(address payable sponsor, uint256 tokenAmount, uint level) internal {
      //uint index = level-1;
      uint256 careerPercent = m_investors.getCareerPercent(sponsor);
      //uint reward = career[careerPercent].mul(tokenAmount);
      uint reward = tokenAmount*career[careerPercent].percentFrom/1000;
      assert(m_investors.addRefBonus(sponsor, reward, _getUsdAmount(tokenAmount), tokenAmount, level));
      _token.transfer(sponsor, reward);      
    }

    function addPaymentReferralBonus(address payable wallet, uint256 amount, uint256 reward) internal {
      assert(m_investors.addRefBonus(wallet, reward, _getUsdAmount(amount), amount, 1));
      _token.transfer(wallet, reward); 
    }

    function payment(uint256 tokenAmount, address receiver, string calldata txdata) public payable {
      require(_token.balanceOf(_msgSender()) >= tokenAmount, "Not enough tokens");

      require(_token.allowance(_msgSender(),address(this)) > tokenAmount, "Please allow fund first");
      bool success = _token.transferFrom(_msgSender(), address(this), tokenAmount);

      if (!success) {
        revert payment__Failed();
      } else {

        address payable sponsorSenderOne = payable(referral_tree[_msgSender()]);
        address payable sponsorReceiverOne = payable(referral_tree[receiver]);

        uint256 tokenCommission = m_paymentComissionPercent.mul(tokenAmount);
        uint256 referralBonus = m_paymentReferralPercent.mul(tokenCommission);

        if (m_investors.haveValue(sponsorSenderOne)) {
            addPaymentReferralBonus(sponsorSenderOne, tokenCommission, referralBonus);
        }

        if (m_investors.haveValue(sponsorReceiverOne)) {
            addPaymentReferralBonus(sponsorReceiverOne, tokenCommission, referralBonus);
        }
        
        _token.transfer(_wallet, m_adminPercent.mul(tokenCommission));

        _sendToPools(tokenCommission);

        if (getAvailableTokenAmount() >= (tokenCommission*2)) {
            vesting.createVestingSchedule(_msgSender(), block.timestamp, _cliffVesting, _durationVesting, _periodVesting, false, tokenCommission);
            vesting.createVestingSchedule(receiver, block.timestamp, _cliffVesting, _durationVesting, _periodVesting, false, tokenCommission);
        }

        _token.transfer(receiver, (tokenAmount-tokenCommission));

        emit transactionCompleted(_msgSender(), receiver, tokenAmount, txdata);
      }
    }

    function checkCareerPercent(address addr) internal returns(uint) {
        (, uint turnoverUsd, uint careerPercent) = m_investors.investorTurnover(addr);

        for (uint i = 0; i < career.length; i++) {
            if (career[i].turnoverFrom <= turnoverUsd && career[i].turnoverTo >= turnoverUsd && i > careerPercent) {
                m_investors.setCareerPercent(addr, i);
                return i;
            }
        }

        return careerPercent;
    }

    function investorsNumber() public view returns(uint) {
        return m_investors.size();
    }

    function notZeroNotSender(address addr) internal view returns(bool) {
      return addr.notZero() && addr != _msgSender();
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

    function _getTokenAmountByBNB(uint256 weiAmount) internal view returns(uint256) {
      int bnbPrice = _getBNBPrice();

      uint256 _bnbPrice = uint256(bnbPrice);

      uint256 _Amount = _bnbPrice/_rate;

      return weiAmount.mul(_Amount);
    }

    function _getTokenAmountByUSD(uint256 usdAmount) internal view returns(uint256) {
      return usdAmount/_rate;
    }

    function _sendToPools(uint256 tokenAmount) internal {
      uint256 toPool = m_poolPercent.mul(tokenAmount);
        freezeInPools += toPool*4;
      pools.push(poolTransaction(block.timestamp, toPool));
    }

    function activateReferralLinkByOwner(address sponsor, address referral, bool needBonusUsd) public onlyOwner activeSponsor(sponsor) returns(bool) {
        activateReferralLink(sponsor, referral, needBonusUsd);
        return true;
    }

    function activateReferralLinkByUser(address sponsor) public nonReentrant returns(bool) {
        activateReferralLink(sponsor, _msgSender(), true);
        return true;
    }

    function activateReferralLink(address sponsor, address referral, bool needBonusUsd) internal activeSponsor(sponsor) {
        require(m_investors.contains(referral) == false, "already activate");

        assert(m_investors.insertInvestor(referral));
        referral_tree[referral] = sponsor;

        if (needBonusUsd) {
            assert(m_investors.setBonusUsd(sponsor, 1, true));
        }
    }

    function changeAdminWallet(address payable wallet) public onlyOwner {
      require(wallet != address(0), "New admin address is the zero address");
      address oldWallet = _wallet;
      _wallet = wallet;
      emit AdminWalletChanged(oldWallet, wallet);
    }

    function setRate(uint256 rate) public onlyOwner {
      _rate = rate;
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
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
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
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