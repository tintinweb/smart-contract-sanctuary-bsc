// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./interfaces/dex/IPancakeRouter02.sol";
import "./interfaces/dex/IPancakeFactory.sol";
import "./interfaces/ITokenPresenter.sol";
import "./interfaces/IMintable.sol";
import "./interfaces/IBurnable.sol";
import "./utils/EmergencyWithdraw.sol";
import "./utils/AntiWhale.sol";
import "./utils/Whitelist.sol";

contract RIS3Presenter is
  ITokenPresenter,
  ReentrancyGuardUpgradeable,
  AccessControlUpgradeable,
  EmergencyWithdraw,
  AntiWhale,
  Whitelist
{
  using SafeERC20Upgradeable for IERC20Upgradeable;

  uint256 private constant _RATE_NOMINATOR = 100e2;
  uint256 private constant _PRECISION_FACTOR = 1e36;
  uint256 private constant _MAX_INT = type(uint256).max;

  bytes32 public constant EDITOR_ROLE = keccak256("EDITOR_ROLE");
  address public constant LP_BURNER = 0x000000000000000000000000000000000000dEaD;

  // Token & dex
  address public token;
  uint256 public tokenDecimals;
  address public dexLP;
  address public dexRouter;

  // Non-whitelisted tax. Default 1% = 1e2
  uint256 public sysTax;

  // Game config
  bool public gameStarted;
  uint256 public cycleDuration;
  uint256 public cycle0StartTime;

  // Game state
  struct UserStake {
    uint farmAmt;
    uint factoryAmt;
    uint citizenAmt;
  }

  struct UserDebt {
    uint farmDebtAmt;
    uint factoryDebtAmt;
    uint citizenDebtAmt;
  }

  struct PoolInfo {
    uint farmAmt;
    uint factoryAmt;
    uint citizenAmt;
  }

  struct CycleInfo {
    // Laws
    uint prodsAmt;
    uint prodsTax;
    uint taxBurn;
    // Government type 0(Socialism), 1(Democracy), 2(Dictatorship)
    uint govType;
    // Dictator address with gov type 2
    address dictator;
    // After finish voting
    bool dictatorVoted;
  }

  // Default law
  // [100_000, 300_000, 500_000] per week
  uint256[3] public prodsAmts;
  // [10%, 30%, 50%]
  // Value: 10e2, 30e2, 50e2
  uint256[3] public prodsTaxes;
  // [0%, 50%, 100%]
  // Value: 0, 50e2, 100e2
  uint256[3] public taxBurns;
  // Default law is Socialism (500e3 prod, 50% tax, 0% burn)
  uint256 public defaultProductionAmt;
  uint256 public defaultProductionTax;
  uint256 public defaultTaxBurnPercentage;

  // Pools size
  uint256 public farmStakedAmt;
  uint256 public factoryStakedAmt;
  uint256 public citizenStakedAmt;

  // Last cycle
  CycleInfo public tmpCycle;

  // users[address] => UserStake
  mapping(address => UserStake) public users;
  // userDebts[address][cycleIndex] => UserDebt
  mapping(address => mapping(uint => UserDebt)) public userDebts;
  // stakers counter
  uint256 public totalStakers;
  // payOuts[timestamp/1day] => value
  mapping(uint256 => uint256) public payOuts;

  // pools[cycleIndex] => PoolInfo
  mapping(uint256 => PoolInfo) public pools;
  // cycles[cycleIndex] => CycleInfo
  mapping(uint256 => CycleInfo) public cycles;
  // sysTaxCredited[cycleIndex] => Value
  mapping(uint256 => uint256) public sysTaxCredited;

  // votes[nextCycleIndex][user] => vote count
  mapping(uint256 => mapping(address => uint256)) public votes;
  // vGovCount[nextCycleIndex][0: Socialism, 1: Democracy, 2: Dictatorship] = vote count
  mapping(uint256 => uint256[3]) public vGovCount;
  // vGovCountMax[nextCycleIndex] = max vote count
  mapping(uint256 => uint256) public vGovCountMax;
  // voteDeLawCount[nextCycleIndex][0: production, 1: tax, 2: burn rate] = [0, 1, 2] index vote count
  mapping(uint256 => mapping(uint256 => uint256[3])) public voteDeLawCount;
  // voteDeLawCountMax[nextCycleIndex][0: production, 1: tax, 2: burn rate] = max vote count
  mapping(uint256 => uint256[3]) public voteDeLawCountMax;
  // voteDeLawCountWin[nextCycleIndex][0: production, 1: tax, 2: burn rate] = win index
  mapping(uint256 => uint256[3]) public voteDeLawCountWin;
  // voteDicCount[nextCycleIndex][address] = vote count
  mapping(uint256 => mapping(address => uint256)) public voteDicCount;
  // voteDicCountMax[nextCycleIndex] = max vote count
  mapping(uint256 => uint256) public voteDicCountMax;
  // voteDicCountWin[nextCycleIndex] = win dictator
  mapping(uint256 => address) public voteDicCountWin;

  // Events
  event EStakingFarm(address indexed _user, uint _cycleIndex);
  event EStakingFactory(address indexed _user, uint _cycleIndex);
  event EStakingCitizen(address indexed _user, uint _cycleIndex);
  event EUnStakingCitizen(address indexed _user, uint _cycleIndex);
  event EClaimReward(address indexed _user, uint _cycleIndex);
  event EVoting(address indexed _user, uint _cycleIndex, uint _votes);
  event EDictator(address indexed _user, uint _cycleIndex);

  /**
   * @dev Initialize
   * @param _token address of the token
   */
  function RIS3PresenterInit(address _token) external initializer {
    __ReentrancyGuard_init();
    __AccessControl_init();
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(EDITOR_ROLE, _msgSender());
    _setupRole(_WHITELIST_ROLE, _msgSender());
    _setupRole(_ANTIWHALE_ROLE, _msgSender());

    // Exclude addresses
    _isInWhitelist[_msgSender()] = true;

    // Initial config
    token = _token;
    tokenDecimals = 10**IERC20MetadataUpgradeable(token).decimals();
    sysTax = 1e2;
    prodsAmts = [100e3, 300e3, 500e3];
    prodsTaxes = [10e2, 30e2, 50e2];
    taxBurns = [0, 50e2, 100e2];
    defaultProductionAmt = prodsAmts[2];
    defaultProductionTax = prodsTaxes[2];
    defaultTaxBurnPercentage = taxBurns[0];
    _setTmpCycleByNext(
      CycleInfo(defaultProductionAmt, defaultProductionTax, defaultTaxBurnPercentage, 0, address(0), false)
    );
  }

  /**
   * @dev Update tax info
   * @param _sysTax tax for System, default 1%
   */
  function fSetTax(uint _sysTax) external onlyRole(EDITOR_ROLE) {
    sysTax = _sysTax;
  }

  /**
   * @dev Set exchange router
   * @param _router address of main token
   */
  function fSetDexInfo(address _router) external onlyRole(EDITOR_ROLE) {
    dexRouter = _router;
    IPancakeRouter02 router_ = IPancakeRouter02(dexRouter);
    IPancakeFactory factory_ = IPancakeFactory(router_.factory());
    address dexLP_ = factory_.getPair(address(token), router_.WETH());
    if (dexLP_ == address(0)) {
      dexLP_ = factory_.createPair(address(token), router_.WETH());
    }
    dexLP = dexLP_;
  }

  /**
   * @dev This is the main function to distribute the tokens call from only main token via external app
   * @param _trigger trigger address
   * @param _from from address
   * @param _to to address
   * @param _amount amount of tokens
   */
  // solhint-disable no-unused-vars
  function fReceiveTokens(
    address _trigger,
    address _from,
    address _to,
    uint256 _amount
  ) external override returns (bool) {
    require(_trigger != address(0), "Invalid trigger");
    require(_from != address(0), "Invalid from");
    require(msg.sender == token, "Invalid sender");

    // Transaction type detail
    bool[9] memory flags;
    // Trigger from router: isViaRouter
    flags[0] = _trigger == dexRouter;
    // Trigger from lp pair: isViaLP
    flags[1] = _trigger == dexLP;
    // Check is to user = _to not router && not lp: isToUser
    flags[2] = (_to != dexLP && _to != dexRouter);
    // Check is from user = _from not router && not lp: isFromUser
    flags[3] = (_from != dexLP && _from != dexRouter);
    // In case remove LP: isRemoveLP
    flags[4] = (_from == dexLP && _to == dexRouter) || (_from == dexRouter && flags[2]);
    // In case buy: LP transfer to user directly: isBuy
    flags[5] = flags[1] && _from == dexLP && flags[2];
    // In case sell (Same with add LP case): User send to LP via router (using transferFrom): isSell
    flags[6] = flags[0] && (flags[3] && _to == dexLP);
    // In case normal transfer: isTransfer
    flags[7] = !flags[5] && !flags[6] && !flags[4];
    // Exclude from fees: isExcluded
    flags[8] = _isInWhitelist[_from] || _isInWhitelist[_to];
    // quit loop
    bool isQuitLoop = _from == address(this);
    // Logic
    if (flags[8] || flags[4] || isQuitLoop) {
      return IERC20Upgradeable(token).transfer(_to, _amount);
    } else {
      // Anti whale and bot
      if (flags[7] || flags[6]) _fValidateWhale(_from, _amount);
      else _fValidateWhale(_to, _amount);

      uint256 taxAmt_ = _taxCollector(_amount);
      return IERC20Upgradeable(token).transfer(_to, _amount - taxAmt_);
    }
  }

  /**
   * @dev Set game mode
   */
  function fStartGame(bool _status) external onlyRole(EDITOR_ROLE) {
    require(gameStarted != _status, "0x1");
    gameStarted = _status;
  }

  /**
   * @dev Set initial start time.
   */
  function fSetGameConfig(uint256 _duration, uint256 _startTime) external onlyRole(EDITOR_ROLE) {
    require(!gameStarted, "0x1");
    require(cycle0StartTime == 0, "0x2");
    require(_startTime > block.timestamp, "0x3");
    cycleDuration = _duration;
    cycle0StartTime = _startTime;
  }

  /**
   * @dev Get cycle index. Start from 0
   */
  function fGetCycleIndex() public view returns (uint256) {
    uint256 cycleWindow = block.timestamp - cycle0StartTime;
    return cycleWindow / cycleDuration;
  }

  /**
   * @dev Get sub cycle index.
   * 0: staking day (1st)
   * 1: production days (2nd - 6th)
   * 2: voting day
   * 3: result day
   */
  function fGetSubCycleIndex() public view returns (uint256) {
    uint256 cycleWindow = block.timestamp - cycle0StartTime;
    uint256 cycleProgress = cycleWindow % cycleDuration;
    if (cycleProgress < cycleDuration / 7) return 0;
    if (cycleProgress < (cycleDuration * 6) / 7) return 1;
    if (cycleProgress < (cycleDuration * 13) / 14) return 2;
    return 3;
  }

  /**
   * @dev Stake token to Farm Pool
   */
  function fStakingFarm(uint256 _amount) external nonReentrant {
    require(gameStarted, "0x1");
    uint256 cycleIndex_ = fGetCycleIndex();
    uint256 subCycleIndex = fGetSubCycleIndex();
    require(subCycleIndex == 0, "Staking day only");
    IBurnable(token).fBurnFrom(_msgSender(), _amount);

    farmStakedAmt += _amount;
    pools[cycleIndex_].farmAmt += _amount;
    users[_msgSender()].farmAmt += _amount;
    totalStakers++;

    emit EStakingFarm(_msgSender(), cycleIndex_);
  }

  /**
   * @dev Stake LP to Factory Pool
   */
  function fStakingFactory(uint256 _amount) external nonReentrant {
    require(gameStarted, "0x1");
    uint256 cycleIndex_ = fGetCycleIndex();
    uint256 subCycleIndex = fGetSubCycleIndex();
    require(subCycleIndex == 0, "Staking day only");
    IERC20Upgradeable(dexLP).safeTransferFrom(_msgSender(), LP_BURNER, _amount);

    factoryStakedAmt += _amount;
    pools[cycleIndex_].factoryAmt += _amount;
    users[_msgSender()].factoryAmt += _amount;
    totalStakers++;

    emit EStakingFactory(_msgSender(), cycleIndex_);
  }

  /**
   * @dev Stake token to Citizen Pool
   */
  function fStakingCitizen(uint256 _amount) external nonReentrant {
    require(gameStarted, "0x1");
    uint256 cycleIndex_ = fGetCycleIndex();
    uint256 subCycleIndex = fGetSubCycleIndex();
    require(subCycleIndex == 0, "Staking day only");
    IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), _amount);

    citizenStakedAmt += _amount;
    pools[cycleIndex_].citizenAmt += _amount;
    users[_msgSender()].citizenAmt += _amount;
    totalStakers++;

    emit EStakingCitizen(_msgSender(), cycleIndex_);
  }

  /**
   * @dev Un-stake token from Citizen Pool
   */
  function fUnStakingCitizen(uint256 _amount) external nonReentrant {
    require(gameStarted, "0x1");
    uint256 cycleIndex_ = fGetCycleIndex();
    uint256 subCycleIndex = fGetSubCycleIndex();
    require(subCycleIndex == 0, "Staking day only");
    IERC20Upgradeable(token).safeTransfer(_msgSender(), _amount);

    citizenStakedAmt -= _amount;
    pools[cycleIndex_].citizenAmt -= _amount;
    users[_msgSender()].citizenAmt -= _amount;
    if (users[_msgSender()].citizenAmt == 0) totalStakers--;

    emit EUnStakingCitizen(_msgSender(), cycleIndex_);
  }

  /**
   * @dev Get pending reward of Production pools
   * _isFarm: true if farm pool, else is factory
   */
  function fGetRewardProductionPools(address _account, bool _isFarm) public view returns (uint256) {
    uint256 cycleIndex_ = fGetCycleIndex();

    // Pool's rewards
    CycleInfo memory cycleInfo = cycles[cycleIndex_];
    if (cycleInfo.prodsAmt == 0) {
      // Init default value
      cycleInfo.prodsAmt = tmpCycle.prodsAmt;
      cycleInfo.prodsTax = tmpCycle.prodsTax;
      cycleInfo.taxBurn = tmpCycle.taxBurn;
    }

    uint256 maxReward = (cycleInfo.prodsAmt * (_RATE_NOMINATOR - cycleInfo.prodsTax)) / _RATE_NOMINATOR;

    // User's total rewards
    UserStake memory userInfo = users[_account];
    uint percentage_ = 0;
    uint debt_;
    if (_isFarm) {
      percentage_ = (userInfo.farmAmt * _PRECISION_FACTOR) / farmStakedAmt;
      debt_ = userDebts[_account][cycleIndex_].farmDebtAmt;
    } else {
      percentage_ = (userInfo.factoryAmt * _PRECISION_FACTOR) / factoryStakedAmt;
      debt_ = userDebts[_account][cycleIndex_].factoryDebtAmt;
    }
    uint userReward_ = (percentage_ * maxReward) / _PRECISION_FACTOR;

    // User's rewards by second
    uint oneDay = cycleDuration / 7;
    uint rewardStartTime = cycle0StartTime + cycleIndex_ * cycleDuration + oneDay;
    percentage_ = ((block.timestamp - rewardStartTime) * _PRECISION_FACTOR) / (oneDay * 5);
    if (percentage_ > _PRECISION_FACTOR) percentage_ = _PRECISION_FACTOR;
    return (percentage_ * userReward_) / _PRECISION_FACTOR - debt_;
  }

  /**
   * @dev Get pending reward of Citizen pool
   * Return (
   */
  function fGetRewardCitizenPool(address _account) public view returns (uint256) {
    uint256 cycleIndex_ = fGetCycleIndex();

    // Pool's rewards
    CycleInfo memory cycleInfo = cycles[cycleIndex_];
    if (cycleInfo.prodsAmt == 0) {
      // Init default value
      cycleInfo.prodsAmt = tmpCycle.prodsAmt;
      cycleInfo.prodsTax = tmpCycle.prodsTax;
      cycleInfo.taxBurn = tmpCycle.taxBurn;
    }

    uint totalProductionAmt = cycleInfo.prodsAmt * 2;
    uint totalProdsTax = (totalProductionAmt * cycleInfo.prodsTax) / _RATE_NOMINATOR;
    uint totalRewardAfterTaxBurn = (totalProdsTax * (_RATE_NOMINATOR - cycleInfo.taxBurn)) / _RATE_NOMINATOR;
    uint maxReward = totalRewardAfterTaxBurn * tokenDecimals + sysTaxCredited[cycleIndex_];
    if (maxReward > 0) {
      // User's total rewards
      UserStake memory userInfo = users[_account];
      uint percentage_ = (userInfo.citizenAmt * _PRECISION_FACTOR) / citizenStakedAmt;
      uint debt_ = userDebts[_account][cycleIndex_].citizenDebtAmt;
      uint userReward_ = (percentage_ * maxReward) / _PRECISION_FACTOR;

      // User's rewards by second
      uint oneDay = cycleDuration / 7;
      uint rewardStartTime = cycle0StartTime + cycleIndex_ * cycleDuration + oneDay;
      percentage_ = ((block.timestamp - rewardStartTime) * _PRECISION_FACTOR) / (oneDay * 5);
      if (percentage_ > _PRECISION_FACTOR) percentage_ = _PRECISION_FACTOR;
      return (percentage_ * userReward_) / _PRECISION_FACTOR - debt_;
    }

    return 0;
  }

  /**
   * @dev Claim pending reward
   * poolIndex (0: farm, 1: factory, 2: citizen)
   */
  function fClaimReward(uint256 _poolIndex) external nonReentrant {
    require(gameStarted, "0x1");
    uint256 cycleIndex_ = fGetCycleIndex();
    uint256 subCycleIndex = fGetSubCycleIndex();
    require(subCycleIndex > 0, "Not staking day");
    uint256 pendingReward_ = 0;
    if (_poolIndex == 0) {
      pendingReward_ = fGetRewardProductionPools(_msgSender(), true);
      userDebts[_msgSender()][cycleIndex_].farmDebtAmt += pendingReward_;
      pendingReward_ *= tokenDecimals;
    } else if (_poolIndex == 1) {
      pendingReward_ = fGetRewardProductionPools(_msgSender(), false);
      userDebts[_msgSender()][cycleIndex_].factoryDebtAmt += pendingReward_;
      pendingReward_ *= tokenDecimals;
    } else {
      pendingReward_ = fGetRewardCitizenPool(_msgSender());
      userDebts[_msgSender()][cycleIndex_].citizenDebtAmt += pendingReward_;
    }

    require(pendingReward_ > 0, "Empty");
    payOuts[block.timestamp / 1 days] += pendingReward_;
    IMintable(token).fMint(_msgSender(), pendingReward_);

    emit EClaimReward(_msgSender(), cycleIndex_);
  }

  /**
   * @dev Voting part
   * @param govType: 0(Socialism), 1(Democracy), 2(Dictatorship)
   * @param dictator: address dictator with gov 2
   * @param prodsAmtIndex: [0: 100k, 1: 300k, 2: 500k]
   * @param prodsTaxIndex: [0: 10%, 1: 30%, 2: 50%]
   * @param taxBurnIndex: [0: 0%, 1: 50%, 2: 100%]
   */
  function fVoting(
    uint govType,
    address dictator,
    uint prodsAmtIndex,
    uint prodsTaxIndex,
    uint taxBurnIndex
  ) external nonReentrant {
    require(gameStarted, "0x1");
    uint256 cycleIndex_ = fGetCycleIndex();
    uint256 subCycleIndex = fGetSubCycleIndex();
    require(subCycleIndex == 2, "Not voting time");
    require(prodsAmtIndex < 3, "Invalid prodsAmtIndex");
    require(prodsTaxIndex < 3, "Invalid prodsTaxIndex");
    require(taxBurnIndex < 3, "Invalid taxBurnIndex");

    // Government type 0(Socialism), 1(Democracy), 2(Dictatorship)
    // 0: User can set law
    // 1: Use pre-defined law (500k, tax 50%, burn 0%)
    // 2: Only dictator can set law

    CycleInfo storage nextCycle = cycles[cycleIndex_ + 1];
    UserStake memory userInfo = users[_msgSender()];
    require(userInfo.citizenAmt > 0, "Insufficient ballot");
    require(votes[cycleIndex_ + 1][_msgSender()] == 0, "Already voted");

    // Update vote data
    votes[cycleIndex_ + 1][_msgSender()] = userInfo.citizenAmt;
    vGovCount[cycleIndex_ + 1][govType] += userInfo.citizenAmt;
    if (vGovCountMax[cycleIndex_ + 1] < vGovCount[cycleIndex_ + 1][govType]) {
      vGovCountMax[cycleIndex_ + 1] = vGovCount[cycleIndex_ + 1][govType];
      nextCycle.govType = govType;
    }
    if (govType == 1) {
      voteDeLawCount[cycleIndex_ + 1][0][prodsAmtIndex] += userInfo.citizenAmt;
      voteDeLawCount[cycleIndex_ + 1][1][prodsTaxIndex] += userInfo.citizenAmt;
      voteDeLawCount[cycleIndex_ + 1][2][taxBurnIndex] += userInfo.citizenAmt;

      // Update max and win
      if (voteDeLawCountMax[cycleIndex_ + 1][0] < voteDeLawCount[cycleIndex_ + 1][0][prodsAmtIndex]) {
        voteDeLawCountMax[cycleIndex_ + 1][0] = voteDeLawCount[cycleIndex_ + 1][0][prodsAmtIndex];
        voteDeLawCountWin[cycleIndex_ + 1][0] = prodsAmtIndex;
      }
      if (voteDeLawCountMax[cycleIndex_ + 1][1] < voteDeLawCount[cycleIndex_ + 1][1][prodsTaxIndex]) {
        voteDeLawCountMax[cycleIndex_ + 1][1] = voteDeLawCount[cycleIndex_ + 1][1][prodsTaxIndex];
        voteDeLawCountWin[cycleIndex_ + 1][1] = prodsTaxIndex;
      }
      if (voteDeLawCountMax[cycleIndex_ + 1][2] < voteDeLawCount[cycleIndex_ + 1][2][taxBurnIndex]) {
        voteDeLawCountMax[cycleIndex_ + 1][2] = voteDeLawCount[cycleIndex_ + 1][2][taxBurnIndex];
        voteDeLawCountWin[cycleIndex_ + 1][2] = taxBurnIndex;
      }
    } else if (govType == 2) {
      voteDicCount[cycleIndex_ + 1][dictator] += userInfo.citizenAmt;
      if (voteDicCountMax[cycleIndex_ + 1] < voteDicCount[cycleIndex_ + 1][dictator]) {
        voteDicCountMax[cycleIndex_ + 1] = voteDicCount[cycleIndex_ + 1][dictator];
        voteDicCountWin[cycleIndex_ + 1] = dictator;
      }
    }

    // Update vote result based on vote data
    nextCycle.dictator = address(0);
    if (nextCycle.govType == 1) {
      nextCycle.prodsAmt = prodsAmts[voteDeLawCountWin[cycleIndex_ + 1][0]];
      nextCycle.prodsTax = prodsTaxes[voteDeLawCountWin[cycleIndex_ + 1][1]];
      nextCycle.taxBurn = taxBurns[voteDeLawCountWin[cycleIndex_ + 1][2]];
    } else if (nextCycle.govType == 2) {
      nextCycle.dictator = voteDicCountWin[cycleIndex_ + 1];
      // Default law is from previous cycle
      CycleInfo memory currentCycle = cycles[cycleIndex_];
      nextCycle.prodsAmt = currentCycle.prodsAmt;
      nextCycle.prodsTax = currentCycle.prodsTax;
      nextCycle.taxBurn = currentCycle.taxBurn;
    }
    if (nextCycle.govType == 0 || nextCycle.prodsAmt == 0) {
      nextCycle.prodsAmt = defaultProductionAmt;
      nextCycle.prodsTax = defaultProductionTax;
      nextCycle.taxBurn = defaultTaxBurnPercentage;
    }

    // Update last cycle
    _setCurrByTmpCycle(cycles[cycleIndex_]);
    _setTmpCycleByNext(nextCycle);

    emit EVoting(_msgSender(), cycleIndex_, userInfo.citizenAmt);
  }

  /**
   * @dev Dictator part
   * @param prodsAmtIndex: [0: 100k, 1: 300k, 2: 500k]
   * @param prodsTaxIndex: [0: 10%, 1: 30%, 2: 50%]
   * @param taxBurnIndex: [0: 0%, 1: 50%, 2: 100%]
   */
  function fDictator(
    uint prodsAmtIndex,
    uint prodsTaxIndex,
    uint taxBurnIndex
  ) external nonReentrant {
    require(gameStarted, "0x1");
    require(prodsAmtIndex < 3, "Invalid prodsAmtIndex");
    require(prodsTaxIndex < 3, "Invalid prodsTaxIndex");
    require(taxBurnIndex < 3, "Invalid taxBurnIndex");

    uint256 cycleIndex_ = fGetCycleIndex();
    uint256 subCycleIndex = fGetSubCycleIndex();
    require(subCycleIndex == 3, "Not dictator time");
    CycleInfo storage nextCycle = cycles[cycleIndex_ + 1];
    require(nextCycle.govType == 2, "0x2");
    require(nextCycle.dictator == _msgSender(), "0x3");
    require(!nextCycle.dictatorVoted, "0x4");

    // Update vote result
    nextCycle.dictatorVoted = true;
    nextCycle.prodsAmt = prodsAmts[prodsAmtIndex];
    nextCycle.prodsTax = prodsTaxes[prodsTaxIndex];
    nextCycle.taxBurn = taxBurns[taxBurnIndex];

    // Update last cycle
    _setCurrByTmpCycle(cycles[cycleIndex_]);
    _setTmpCycleByNext(nextCycle);

    emit EDictator(_msgSender(), cycleIndex_);
  }

  /**
   * @dev Caching voting latest result for the next cycle
   */
  function _setTmpCycleByNext(CycleInfo memory _nextCycle) private {
    tmpCycle.govType = _nextCycle.govType;
    tmpCycle.dictator = _nextCycle.dictator;
    tmpCycle.prodsAmt = _nextCycle.prodsAmt;
    tmpCycle.prodsTax = _nextCycle.prodsTax;
    tmpCycle.taxBurn = _nextCycle.taxBurn;
  }

  /**
   * @dev Init current cycle data by tmp cycle if need be
   */
  function _setCurrByTmpCycle(CycleInfo storage _currentCycle) private {
    if (_currentCycle.prodsAmt == 0) {
      // Init default value
      _currentCycle.govType = tmpCycle.govType;
      _currentCycle.dictator = tmpCycle.dictator;
      _currentCycle.prodsAmt = tmpCycle.prodsAmt;
      _currentCycle.prodsTax = tmpCycle.prodsTax;
      _currentCycle.taxBurn = tmpCycle.taxBurn;
    }
  }

  /**
   * @dev Apply tax and update pending
   * @param _amount raw sending amount
   */
  function _taxCollector(uint256 _amount) private returns (uint256) {
    uint256 tax_ = (_amount * sysTax) / _RATE_NOMINATOR;

    // Credit tax amount after burn rate
    if (gameStarted) {
      uint256 cycleIndex_ = fGetCycleIndex();
      CycleInfo memory currentCycle = cycles[cycleIndex_];
      if (currentCycle.prodsAmt == 0) {
        currentCycle.taxBurn = tmpCycle.taxBurn;
      }
      sysTaxCredited[cycleIndex_] += (tax_ * (_RATE_NOMINATOR - currentCycle.taxBurn)) / _RATE_NOMINATOR;
    } else {
      sysTaxCredited[0] += tax_;
    }
    IBurnable(token).fBurn(tax_);
    return tax_;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Whitelist is AccessControlUpgradeable {
  bytes32 internal constant _WHITELIST_ROLE = keccak256("WHITELIST_ROLE");

  // Whitelist map
  mapping(address => bool) internal _isInWhitelist;

  event EWhitelist(address _account, bool _status);

  /**
   * @dev Function to get whitelist status
   */
  function fIsInWhitelist(address _pAccount) external view onlyRole(_WHITELIST_ROLE) returns (bool) {
    return _isInWhitelist[_pAccount];
  }

  /**
   * @dev Function to add a account to whitelist
   */
  function fSetWhitelist(address _pAccount, bool _pStatus) external onlyRole(_WHITELIST_ROLE) {
    require(_isInWhitelist[_pAccount] != _pStatus, "0x1");
    _isInWhitelist[_pAccount] = _pStatus;
    emit EWhitelist(_pAccount, _pStatus);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

abstract contract EmergencyWithdraw is AccessControlUpgradeable {
  using SafeERC20Upgradeable for IERC20Upgradeable;
  bytes32 private constant _EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

  event EReceived(address _sender, uint256 _amount);
  event EEmergencyEth(address _to, uint256 _amount);
  event EEmergencyToken(address _tokenAddress, address _to, uint256 _amount);

  /**
   * @dev Allow contract to receive ethers
   */
  receive() external payable {
    emit EReceived(msg.sender, msg.value);
  }

  /**
   * @dev Withdraw eth balance
   * @param _pTo destination address
   * @param _pAmount token amount
   */
  function fEmergencyEth(address _pTo, uint256 _pAmount) external onlyRole(_EMERGENCY_ROLE) {
    require(_pTo != address(0), "fEmergencyEth:0x1");
    payable(_pTo).transfer(_pAmount);

    emit EEmergencyEth(_pTo, _pAmount);
  }

  /**
   * @dev Withdraw token balance
   * @param _pTokenAddress token address
   * @param _pTo destination address
   * @param _pAmount token amount
   */
  function fEmergencyToken(
    address _pTokenAddress,
    address _pTo,
    uint256 _pAmount
  ) external onlyRole(_EMERGENCY_ROLE) {
    IERC20Upgradeable(_pTokenAddress).safeTransfer(_pTo, _pAmount);

    emit EEmergencyToken(_pTokenAddress, _pTo, _pAmount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

abstract contract AntiWhale is AccessControlUpgradeable {
  bytes32 internal constant _ANTIWHALE_ROLE = keccak256("ANTIWHALE_ROLE");

  // Anti bot
  uint256 private _offsetTime;
  uint256 private _limitAmount;
  mapping(address => uint256) private _whaleAmounts;
  mapping(address => uint256) private _whaleTimestamps;

  // Whale config
  uint256 private _startTime;
  uint256 private _endTime;
  uint256 private _limitWhale;
  bool private _antiWhaleActivated;
  uint256 private _defaultLimitDuration;
  bool private _tradingActivated;

  event EAntiWhaleActivated();
  event EAntiWhaleDeactivated();
  event ESetTradingMode(bool _status);
  event ESetAntiBot(uint256 _amount, uint256 _duration);
  event EWhaleConfigLimitAmount(uint256 _limitAmount);
  event EWhaleConfigLimitDuration(uint256 _limitDuuration);

  /**
   * @dev Update offset time
   * @param _pAmount limited amount per each transfer
   * @param _pDuration = 0 as default mean Antibot is disable
   */
  function fSetAntiBot(uint256 _pAmount, uint256 _pDuration) external onlyRole(_ANTIWHALE_ROLE) {
    _limitAmount = _pAmount / 3;
    _offsetTime = _pDuration / 2;
    emit ESetAntiBot(_pAmount, _pDuration);
  }

  /**
   * @dev Update trading mode
   * @param _pStatus Trading mode
   */
  function fSetTradingMode(bool _pStatus) external onlyRole(_ANTIWHALE_ROLE) {
    _tradingActivated = _pStatus;
    emit ESetTradingMode(_pStatus);
  }

  /**
   * @dev Activate antiwhale
   */
  function fActivateAntiWhale(uint _pStartTime, uint256 _pEndTime) external onlyRole(_ANTIWHALE_ROLE) {
    require(!_antiWhaleActivated, "Already activated");
    if (_pStartTime == 0) _startTime = block.timestamp;
    else _startTime = _pStartTime;
    if (_pEndTime == 0) _endTime = _startTime + _defaultLimitDuration;
    else _endTime = _pEndTime;

    _tradingActivated = true;
    _antiWhaleActivated = true;

    emit EAntiWhaleActivated();
  }

  /**
   * @dev Deactivate antiwhale
   */
  function fDeactivateAntiWhale() external onlyRole(_ANTIWHALE_ROLE) {
    require(_antiWhaleActivated, "Already deactivated");
    _antiWhaleActivated = false;
    emit EAntiWhaleDeactivated();
  }

  /**
   * @dev Set antiwhale amount
   * @param _pLimitWhale limit amount of antiwhale
   */
  function fSetAntiWhaleAmount(uint256 _pLimitWhale) external onlyRole(_ANTIWHALE_ROLE) {
    _limitWhale = _pLimitWhale / 5;
    emit EWhaleConfigLimitAmount(_pLimitWhale);
  }

  /**
   * @dev Set antiwhale default limit duration
   * @param _pLimitDuration duration in seconds
   */
  function fSetDefaultLimitDuration(uint256 _pLimitDuration) external onlyRole(_ANTIWHALE_ROLE) {
    _defaultLimitDuration = _pLimitDuration;
    emit EWhaleConfigLimitDuration(_pLimitDuration);
  }

  /**
   * @dev Check if antiwhale is enable and amount should be less than to whale in specify duration
   * @param _pAccount user address
   * @param _pAmount amount to check antiwhale
   */
  function _fValidateWhale(address _pAccount, uint256 _pAmount) internal {
    require(_tradingActivated, "0x0");
    if (!_antiWhaleActivated) return;
    if (block.timestamp >= _startTime && block.timestamp <= _endTime) {
      require(_pAmount <= _limitWhale, "Error: No time for whales!");
      if (_limitAmount > 0) {
        uint256 accAmount_ = _pAmount;
        if (block.timestamp >= _whaleTimestamps[_pAccount] + _offsetTime) {
          _whaleTimestamps[_pAccount] = block.timestamp;
          _whaleAmounts[_pAccount] = _pAmount;
        } else {
          accAmount_ += _whaleAmounts[_pAccount];
          _whaleAmounts[_pAccount] = accAmount_;
        }
        require(accAmount_ <= _limitAmount, "Error: No time for bot!");
      }
    }
  }

  /**
   * @dev Check whale
   * @param _pAmount amount to check whale
   */
  function _fIsWhale(uint256 _pAmount) internal view returns (bool) {
    if (!_tradingActivated) return true;
    if (!_antiWhaleActivated || _pAmount <= _limitWhale) return false;
    if (block.timestamp >= _startTime && block.timestamp <= _endTime) return true;
    return false;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IPancakeRouter01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IPancakeFactory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ITokenPresenter {
  function fReceiveTokens(
    address _pTrigger,
    address _pFrom,
    address _pTo,
    uint256 _pAmount
  ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IMintable {
  function fMint(
    address _pTo,
    uint256 _pAmount /* onlyOwner */
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IBurnable {
  function fBurn(uint _pAmount) external;

  function fBurnFrom(address _pAccount, uint _pAmount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}