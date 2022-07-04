/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: RXFNDTN

pragma solidity ^0.7.4;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░██████╗░░░███████╗░░██╗░░░██╗░░ //  REX TOKEN -- MAIN CONTRACT
// ░░██╔══██╗░░██╔════╝░░╚██╗░██╔╝░░ //
// ░░██████╔╝░░█████╗░░░░░╚████╔╝░░░ //  PART OF "REX" SMART CONTRACTS
// ░░██╔══██╗░░██╔══╝░░░░░██╔═██╗░░░ //
// ░░██║░░██║░░███████╗░░██╔╝░░██╗░░ //  FOR DEPLOYMENT ON NETWORK:
// ░░╚═╝░░╚═╝░░╚══════╝░░╚═╝░░░╚═╝░░ //  BINANCE SMART CHAIN - ID: 56
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░ Latin: king, ruler, monarch ░░ //
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░░ Copyright (C) 2022 rex.io ░░░ //  SINGLE SOURCE OF TRUTH: rex.io
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //

/*

Name      :: REX
Ticker    :: XRX
Decimals  :: 18

Concept   :: CERTIFICATE OF DEPOSIT / INTERNET BOND
Special   :: RANDOM PERSONAL Big Pay Days
Category  :: Passive Income

REX - STAKING UNLEASHED
Cryptocurrency & Certificate of Deposit
The world's most flexible staking token.

REX is a cryptocurrency token for storing and transfering value.
In addition, REX provides built-in functions to deposit REX in order to gain staking rewards.
In this manner, REX may be regarded as a Certificate of Deposit (CD) or a "staking token".

REX is also an ADVANCED staking token: REX lets you name time deposits
(to keep track of their purposes), withdraw staking rewards before maturity,
split them and even transfer them to other addresses.

Thirdly, REX is the world's first EXTENDED STAKING TOKEN.
A user may sell and buy STAKES on an NATIVE (integrated) decentralized exchange (DEX).
This makes REX a most powerful and flexible ecosystem for decentralized value transfers,
a "world's first" in DeFi. Unleashing staking.

Find the REXpaper for more information: rex.io/paper

*/

/**
 *
 * GENERAL SHORT DESCRIPTION
 *
 * REX is an advanced STAKING token
 * Its functionality is described in the REX PAPER (whitepaper).
 * In REX, stakers may NAME, RENAME, SPLIT, TRANSFER, SELL or BUY a stake or WITHDRAW already earned REWARDS from it.
 *
 * This contract is the MAIN contract in the ecosystem:
 * It defines the actual REX DAY (iteration day since contract inception, see "LAUNCH_TIME"),
 * implements the REX token and provides all basic, advanced and extended staking functionality.
 *
 * This contract uses other REX contracts: RDA_CONTRACT, DEX_CONTRACT, TREX_TOKEN, AIRDROP_CONTRACT.
 * This contract creates the REX/BUSD pair on PancakeSwap "UNISWAP_PAIR" when calling "initRexContracts()".
 *
 * Staking
 * REX holders can elect to time-lock their REX tokens into the staking contract. Technically, staking burns the staked tokens.
 * In exchange for the burnt REX, the address receives SHARES, representing a certificate of deposit and a right to future rewards.
 * Users select the lockup period for their tokens when depositing their stake (7 to 3653 days).
 * The amount of shares and rewards a user recieves for their stake depends upon the staker’s staked amount of REX,
 * the total amount staked by all users, the start date of the stake, and the end date of the stake.
 * When ending a stake, REX are minted back to the user (plus rewards minus penalties).
 * The token supply inflates at 12.9% per year. (This may be higher if penalties occur, when users early end stakes.)
 * This inflation is distributed to the STAKERS, in proportion to their SHARES.
 * Longer pays better: When opening a stake, the longer the stake, the more SHARES it gets (slightly exponential).
 * The amount of SHARES also depends on the SHARE PRICE, initially 0.1 = The user receives 10 SHARES/REX.
 * The SHARE PRICES only rises over the time.
 * Penalties may be incurred by stakers who early unstake or who fail to claim their rewards in a timely manner.
 * TREX holders get 25% more SHARES when opening a stake (via a 20% discount on the SharePrice).
 * Making a stake "irrevocable" adds 25% more SHARES when opening a stake.
 *
 * DEX: Built-in Decentralized Exchange for active REX STAKES
 * REX provides its own native decentralized exchange ("DEX") for stakes, where users may offer their stakes for sale.
 * This is implemented in the linked DEX contract.
 * When offering a stake, the user must set a desired BUSD price (5 BUSD minimum) and an offer duration from 1 to 30 days,
 * where the scheduled end of the offer must be before the stake’s maturity date.
 * Offering a stake will list the stake on the DEX (in the DEX contract) and set the offered stake inactive,
 * so the user can’t transfer, rename, end or split the stake, nor withdraw staking rewards during the time of the offering.
 * The offered stake will be buyable by other users until the offer has expired or the user has revoked it.
 * A stake offer may be revoked by the seller anytime within the offer duration, unless a buyer has bought it.
 * Successfully buying a stake creates for the buyer a new active stake with the exact properties of the offered stake,
 * with the description set to "Bought on DEX" and closes the offered stake of the seller.
 * If the offered stake isn’t sold before expiry, the seller must actively revoke the offer to restore
 * the original name of the stake and reactivate it.
 * A stake must have fulfilled at least 10% of the staking duration to be offered.
 * Stake offers may be submitted from REX DAY 111 (DEX activation day).
 * Stakes that have any of their staking rewards withdrawn can’t be offered.
 * Buying a stake incurs a fee of 2% of the stake’s BUSD price for the buyer.
 * Fee usage: 1% goes to MARKETING FUND and 1% goes to DEV FUND.
 *
 * "ADMIN RIGHTS"
 * The deploying address "TOKEN_DEFINER" has only one right:
 * Calling initRexContracts() providing the addresses of the other REX contracts.
 * This is needed to link all the contracts after deployment.
 * Afterwards, the TOKEN_DEFINER shall call "revokeAccess", so this can only be done once.
 * No further special rights are granted to the TOKEN_DEFINER (or any other address).
 *
 */

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function factory() external view returns (address);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
}

interface IREXDEX {
    function listStake(
        address staker,
        uint32 offerStartDay,
        uint32 offerDurationDays,
        uint256 offerPrice,
        bytes16 stakeID
    )   external;
}

contract Context {
  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }
}

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: add");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;
    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: mul");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: div");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

library SafeMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        require(c >= a);
        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b <= a);
        uint32 c = a - b;
        return c;
    }

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {

        if (a == 0) {
            return 0;
        }

        uint32 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b > 0);
        uint32 c = a / b;
        return c;
    }

    function mod(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b != 0);
        return a % b;
    }
}

contract BEP20Token is Context {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply = 0;
  uint8 private constant _decimals = 18;
  string private _symbol;
  string private _name;

  event Transfer(
      address indexed from,
      address indexed to,
      uint256 value
  );

  event Approval(
      address indexed owner,
      address indexed spender,
      uint256 value
  );

  constructor (string memory tokenName, string memory tokenSymbol) {
    _name = tokenName;
    _symbol = tokenSymbol;
  }

  function decimals() external pure returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: tx from 0x0");
    require(recipient != address(0), "BEP20: tx to 0x0");
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to 0x0");
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from 0x0");
    _balances[account] = _balances[account].sub(amount, "BEP20: exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from 0x0");
    require(spender != address(0), "BEP20: approve to 0x0");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}

contract Events {

    event StakeStarted(
        bytes16 indexed stakeID,
        address indexed stakerAddress,
        uint256 stakedAmount,
        uint256 stakesShares,
        uint32 indexed startDay,
        uint32 stakingDays
    );

    event StakeEnded(
        bytes16 indexed stakeID,
        address indexed stakerAddress,
        uint256 stakedAmount,
        uint256 stakesShares,
        uint256 rewardAmount,
        uint32 indexed closeDay,
        uint256 penaltyAmount
    );

    event StakeTransferred(
        bytes16 fromStakeID,
        bytes16 toStakeID,
        address indexed fromStakerAddress,
        address indexed toStakerAddress,
        uint32 indexed currentRxDay
    );

    event RewardsWithdrawn(
        bytes16 indexed stakeID,
        address indexed stakerAddress,
        uint256 withdrawAmount,
        uint32 withdrawDay,
        uint256 stakersPenalty,
        uint32 indexed currentRxDay
    );

    event NewGlobals(
        uint256 totalShares,
        uint256 totalStaked,
        uint256 sharePrice,
        uint32 indexed currentRxDay
    );

    event NewSharePrice(
        uint256 newSharePrice,
        uint256 oldSharePrice,
        uint32 indexed currentRxDay
    );
}

abstract contract Global is BEP20Token, Events {

    using SafeMath for uint256;

    struct Globals {
        uint256 totalStaked;
        uint256 totalShares;
        uint256 sharePrice;
        uint32 currentRxDay;
    }

    Globals public globals;

    constructor() {
        globals.sharePrice = 1E17;   // start price = 0.1 REX
    }

    function _increaseGlobals(
        uint256 _staked,
        uint256 _shares
    )
        internal
    {
        globals.totalStaked = globals.totalStaked.add(_staked);
        globals.totalShares = globals.totalShares.add(_shares);
        _logGlobals();
    }

    function _decreaseGlobals(
        uint256 _staked,
        uint256 _shares
    )
        internal
    {
        globals.totalStaked =
        globals.totalStaked > _staked ?
        globals.totalStaked - _staked : 0;

        globals.totalShares =
        globals.totalShares > _shares ?
        globals.totalShares - _shares : 0;

        _logGlobals();
    }

    function _logGlobals()
        private
    {
        emit NewGlobals(
            globals.totalStaked,
            globals.totalShares,
            globals.sharePrice,
            globals.currentRxDay
        );
    }
}

abstract contract Declaration is Global {

    uint256 public LAUNCH_TIME;                             // desired beginning of DAY 0
    uint256 internal constant SECONDS_IN_DAY = 86400 seconds;
    uint256 internal constant SHARES_PRECISION = 1E10;
    uint256 internal constant PRECISION_RATE = 1E18;
    uint256 internal constant MIN_STAKE_AMOUNT = 1000000;   // equals 0.000000000001 REX

    uint32 internal constant DEX_ACTIVATION_DAY = 111;      // used when offering a stake

    address public constant busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public RDA_CONTRACT;                // defined later via init after deployment
    address public AIRDROP_CONTRACT;            // defined later via init after deployment

    IUniswapV2Router02 public constant UNISWAP_ROUTER = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IBEP20 public TREX_TOKEN;                   // defined later via init after deployment
    IREXDEX public DEX_CONTRACT;                // defined later via init after deployment

    constructor() {
        LAUNCH_TIME = 1656608400;               // DAY 0 :: Thu Jun 30 2022 17:00:00 GMT+0000 (AUCTIONS start 1 day later at 1656694800)
    }

    struct Stake {
        uint256 stakesShares;
        uint256 stakedAmount;
        uint256 rewardAmount;
        uint256 penaltyAmount;
        uint32 startDay;
        uint32 stakingDays;
        uint32 finalDay;
        uint32 closeDay;
        uint32 withdrawDay;
        uint8 isActive; // 0=inactive (ended) 1=ACTIVE 2=offered_on_DEX (inactive) 3=sold_on_DEX (inactive) 4=transferred_away (inactive)
        bool isSplit;
        uint8 isIrrTrex; // 0=!isIrr && !isTrex  /  1=isIrr && !isTrex  /  2=!isIrr && isTrex  /  3=isIrr && isTrex
        string description;
    }

    mapping(address => uint256) public stakeCount;
    mapping(address => uint256) public totalREXinActiveStakes;
    mapping(address => mapping(bytes16 => Stake)) public stakes;
    mapping(address => mapping(bytes16 => uint256)) public withdraws;
    mapping(address => mapping(bytes16 => uint256)) public initialShares;
    mapping(uint32 => uint256) public scheduledToEnd;
    mapping(uint32 => uint256) public totalPenalties;
}

abstract contract Timing is Declaration {

    function currentRxDay() public view returns (uint32) {
        return block.timestamp >= LAUNCH_TIME ? _currentRxDay() : 0;
    }

    function _currentRxDay() internal view returns (uint32) {
        return uint32((block.timestamp - LAUNCH_TIME) / SECONDS_IN_DAY);
    }

    function _nextRexDay() internal view returns (uint32) {
        return _currentRxDay() + 1;
    }
}

abstract contract Helper is Timing {

    using SafeMath for uint256;
    using SafeMath32 for uint32;

    function _notContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly { size := extcodesize(_addr) }
        return (size == 0);
    }

    function _toBytes16(uint256 x) internal pure returns (bytes16 b) {
       return bytes16(bytes32(x));
    }

    function generateID(address x, uint256 y, bytes1 z) public pure returns (bytes16 b) {
        b = _toBytes16( uint256(keccak256(abi.encodePacked(x, y, z))));
    }

    function _generateStakeID(address _staker) internal view returns (bytes16 stakeID) {
        return generateID(_staker, stakeCount[_staker], 0x01);
    }

    function stakesPagination(
        address _staker,
        uint256 _offset,
        uint256 _length
    )
        external
        view
        returns (bytes16[] memory _stakes)
    {
        uint256 start = _offset > 0 &&
            stakeCount[_staker] > _offset ?
            stakeCount[_staker] - _offset : stakeCount[_staker];

        uint256 finish = _length > 0 &&
            start > _length ?
            start - _length : 0;

        uint256 i;

        _stakes = new bytes16[](start - finish);

        for (uint256 _stakeIndex = start; _stakeIndex > finish; _stakeIndex--) {
            bytes16 _stakeID = generateID(_staker, _stakeIndex - 1, 0x01);
            if (stakes[_staker][_stakeID].stakedAmount > 0) {
                _stakes[i] = _stakeID; i++;
            }
        }
    }

    function _stakeNotStarted(Stake memory _stake) internal view returns (bool) {
        return _stake.closeDay > 0                // has the staked been closed already? (closeDay > 0)
            ? _stake.startDay > _stake.closeDay   // stake has been closed -> check if the CLOSE was before start day
            : _stake.startDay > _currentRxDay();  // stake hasn't been closed -> check if startDay is greater than current day
    }

    function _daysDiff(uint32 _startDate, uint32 _endDate) internal pure returns (uint32) {
        return _startDate > _endDate ? 0 : _endDate.sub(_startDate);
    }

    function _daysLeft(Stake memory _stake) internal view returns (uint32) {
        return _stake.isActive == 0
            ? _daysDiff(_stake.closeDay, _stake.finalDay)     // for ENDED stakes
            : _daysDiff(_currentRxDay(), _stake.finalDay);    // all other cases
    }

    function _calculationDay(Stake memory _stake) internal view returns (uint32) {
        return _stake.finalDay > globals.currentRxDay ? globals.currentRxDay : _stake.finalDay;  // checking for "globals.currentRxDay" prevents from trying to get values from days that haven't been calculated yet
    }

    function _startingDay(Stake memory _stake) internal pure returns (uint32) {
        return _stake.withdrawDay == 0 ? _stake.startDay : _stake.withdrawDay;  // used in withdrawing rewards and ending stakes: returns the first day after last rewards withdraw day
    }
}

abstract contract Snapshot is Helper {

    using SafeMath for uint256;
    using SafeMath32 for uint32;

    struct SnapShot {
        uint256 totalShares;
        uint256 inflationAmount;
        uint256 scheduledToEnd;
    }

    mapping(uint32 => SnapShot) public snapshots;

    /**
     * @notice allows volunteer to offload snapshots
     * to save on gas during next start/end stake
     * where only one day is processed, which is the first unprocessed
     * where days 0 and 1 are not processed, because there is no data
     */
    function manualSnapshotOneDay()
        external
    {
        require(_notContract(msg.sender) && msg.sender == tx.origin, 'REX: Not an address');

        if (currentRxDay() >= 2) {                                    // do nothing on days 0 and 1 where nothing happens
            if (currentRxDay() > globals.currentRxDay + 1) {          // snapshot needed? (difference between actual and update day > 2)
                _dailySnapshotPoint(globals.currentRxDay + 1); } }    // update only the first day after last snapshot day
    }

    /**
     * @notice internal function that offloads global values to daily snapshots
     * updates globals.currentRxDay
     * first function call will be for _updateDay == 2
     * (skip days 0 and 1 then, as no REX exist then and no data has to be saved)
     */
    function _dailySnapshotPoint(
        uint32 _updateDay
    )
        internal
    {
        uint256 totalStakedToday = globals.totalStaked;
        uint256 scheduledToEndToday;

        for (uint32 _day = globals.currentRxDay; _day < _updateDay; _day++) {

            if (_day >= 2)
            {
                scheduledToEndToday = scheduledToEnd[_day] + snapshots[_day - 1].scheduledToEnd;
                SnapShot memory snapshot = snapshots[_day];
                snapshot.scheduledToEnd = scheduledToEndToday;

                snapshot.totalShares =
                    globals.totalShares > scheduledToEndToday ?
                    globals.totalShares - scheduledToEndToday : 0;

                  // as on day 0 and 1 _inflationAmount() might be zero, those days are skipped
                snapshot.inflationAmount =  snapshot.totalShares
                    .mul(PRECISION_RATE)
                    .div(
                        _inflationAmount(
                            totalStakedToday,
                            totalSupply(),
                            totalPenalties[_day]
                        )
                    );

                snapshots[_day] = snapshot;

            }

            globals.currentRxDay++;

        }
    }

    /**
     * @notice A function for calculating the needed daily inflation to reach the yearly desired inflation
     * 12.9% MORE TOKENS PER YEAR = 0.00033247247636 PER DAY
     * 0.00033247247636 = 33247247636 / 1E14
     */
    function _inflationAmount(uint256 _totalStaked, uint256 _totalSupply, uint256 _totalPenalties) private pure returns (uint256) {
        return (_totalStaked + _totalSupply) * 33247247636 / 1E14 + _totalPenalties;
    }
}

abstract contract StakingToken is Snapshot {

    using SafeMath for uint256;
    using SafeMath32 for uint32;

    /**
     * @notice A function for a staker to create multiple stakes
     * @dev The function only passes address(0x0) to createStake() as this function reads msg.sender itself
     * @param _stakedAmount Amount of REX staked
     * @param _stakingDays Number of days it is locked
     * @param _description ONE name for all stakes
     * @param _irrevocable Flag for the stake to be locked
     */
    function createStakeBatch(
        uint256[] memory _stakedAmount,
        uint32[] memory _stakingDays,
        string calldata _description,
        bool[] memory _irrevocable
    )
        external
    {
        for(uint256 i = 0; i < _stakedAmount.length; i++) {
            createStake(
                address(0x0),
                _stakedAmount[i],
                _stakingDays[i],
                _description,
                _irrevocable[i]
            );
        }
    }

    /**
     * @notice A function for a staker (not a contract) to create a stake, also used by above batch function
     * but also used by allowed contracts: AIRDROP and AUCTION (RDA)
     * @param _stakerAdd Address of staker            - ONLY used if called by AIRDROP or AUCTION
     * @param _stakedAmount Amount of REX staked
     * @param _stakingDays Number of days it is locked
     * @param _description One name for all stakes    - ONLY used if called by user
     * @param _irrevocable Flag for irrevocable stake - ONLY used if called by user
     */
    function createStake(
        address _stakerAdd,
        uint256 _stakedAmount,
        uint32 _stakingDays,
        string calldata _description,
        bool _irrevocable
    )
        public
    {
        _dailySnapshotPoint(_currentRxDay());

        Stake memory _newStake;
        _newStake.stakingDays = _stakingDays;
        _newStake.startDay = _nextRexDay();
        _newStake.finalDay = _newStake.startDay + _stakingDays;
        _newStake.isActive = 1;
        _newStake.stakedAmount = _stakedAmount;

        address _staker;

        if (msg.sender == AIRDROP_CONTRACT || msg.sender == RDA_CONTRACT)
        {
            _staker = _stakerAdd;
        }
        else
        {
            _staker = msg.sender;

            require(_notContract(_staker) && msg.sender == tx.origin, 'RX: 1');
            require(_stakedAmount >= MIN_STAKE_AMOUNT, 'RX: 2');
            require(_stakingDays >= 7 && _stakingDays <= 3653, 'RX: 3');

            _burn(_staker, _stakedAmount);
        }

          // holding TREX gets 20% discount on SHARE price (results in 25% more SHARES)
        _newStake.stakesShares = (TREX_TOKEN.balanceOf(_staker) > 0)
            ? _stakesShares(_stakedAmount, _stakingDays, globals.sharePrice.mul(80).div(100))
            : _stakesShares(_stakedAmount, _stakingDays, globals.sharePrice);

        if (msg.sender == AIRDROP_CONTRACT || msg.sender == RDA_CONTRACT)
        {
            _newStake.stakesShares = _newStake.stakesShares.mul(125).div(100); // stake is irrevocable, give 25% extra shares
            _newStake.isIrrTrex = TREX_TOKEN.balanceOf(_staker) > 0 ? uint8(3) : uint8(1); // 3=isIrrevocable && has Trex / 1=isIrrevocable && no Trex
            _newStake.description = msg.sender == AIRDROP_CONTRACT
                ? unicode'🤴 AIRDROP'
                : unicode'🤴 AUCTION';
        }
        else
        {
            _newStake.description = _description;

            if (_irrevocable)
            {
                  // adds an extra 25% OF SHARES (also on the +25% for TREX)
                _newStake.stakesShares = _newStake.stakesShares.mul(125).div(100);
                _newStake.isIrrTrex = TREX_TOKEN.balanceOf(_staker) > 0 ? uint8(3) : uint8(1); // 3=isIrrevocable && has Trex / 1=isIrrevocable && no Trex
            }
            else
            {
                _newStake.isIrrTrex = TREX_TOKEN.balanceOf(_staker) > 0 ? uint8(2) : uint8(0); // 2=notIrrevocable && has Trex / 0=notIrrevocable && no Trex
            }
        }

        totalREXinActiveStakes[_staker] = totalREXinActiveStakes[_staker].add(_stakedAmount);

        bytes16 stakeID = _generateStakeID(_staker);
        stakes[_staker][stakeID] = _newStake;

        initialShares[_staker][stakeID] = _newStake.stakesShares;

        stakeCount[_staker] = stakeCount[_staker] + 1;
        _increaseGlobals(_newStake.stakedAmount, _newStake.stakesShares);
        _addScheduledShares(_newStake.finalDay, _newStake.stakesShares);

        emit StakeStarted(
            stakeID,
            _staker,
            _newStake.stakedAmount,
            _newStake.stakesShares,
            _newStake.startDay,
            _newStake.stakingDays
        );
    }

    /**
    * @notice A function for a staker (not a contract) to end (or early end) a stake
    * @param _stakeID unique bytes sequence reference to the stake
    */
    function endStake(
        bytes16 _stakeID
    )
        external
    {
        _dailySnapshotPoint(_currentRxDay());

        require(stakes[msg.sender][_stakeID].isActive == 1, 'RX: 4');    // only ACTIVE stakes can be "ended"

          // irrevocable stakes cannot be ended before maturity, even if the stake is still PENDING
        if ( stakes[msg.sender][_stakeID].isIrrTrex == 1 || stakes[msg.sender][_stakeID].isIrrTrex == 3 )
        {
            require(stakes[msg.sender][_stakeID].finalDay <= _currentRxDay(), 'RX: 6');
        }

        Stake storage _stake = stakes[msg.sender][_stakeID];      // get stake
        _stake.closeDay = _currentRxDay();                        // set closeDay
        ( , _stake.rewardAmount , ) =
            _checkRewardAmountbyID(msg.sender, _stakeID, 0);      // loop calculates rewards/day (for ALL days), reduced if late claim, reduced if rewards withdrawn before
        _stake.penaltyAmount = _calculatePenaltyAmount(_stake);   // penalty reduces principal payout, if ended before maturity
        _stake.isActive = 0;                                      // deactivate

          // keep track of the user's REX in active stakes
        totalREXinActiveStakes[msg.sender] =
            totalREXinActiveStakes[msg.sender] >= (_stake.stakedAmount) ?
            totalREXinActiveStakes[msg.sender].sub(_stake.stakedAmount) : 0;

          // mint back the principal minus penalties
        _mint(
            msg.sender,
            _stake.stakedAmount > _stake.penaltyAmount ?
            _stake.stakedAmount - _stake.penaltyAmount : 0
        );

          // mint the rewards
        _mint(
            msg.sender,
            _stake.rewardAmount
        );

        _decreaseGlobals(_stake.stakedAmount, _stake.stakesShares);
        _removeScheduledShares(_stake.finalDay, _stake.stakesShares);

          // distribute penalties to all stakers
          // (if stake was ended before maturity)
        if (_stake.penaltyAmount > 0) {
            totalPenalties[_stake.closeDay] = totalPenalties[_stake.closeDay].add(_stake.penaltyAmount);
        }

          // When calculating the SharePrice-Update, given bonuses (TREX/IRR) must be calculated backwards
          // otherwise the SharePrice would rise more than needed
          // also, use the initialShares of the stake, not the (possibly) deducted value in _stake.stakesShares

        uint256 stakesSharesCorr = (_stake.isIrrTrex == 2 || _stake.isIrrTrex == 3)   // IF TREX, calculate back the TREX bonus
            ? initialShares[msg.sender][_stakeID].mul(80).div(100)
            : initialShares[msg.sender][_stakeID];

        if (_stake.isIrrTrex == 1 || _stake.isIrrTrex == 3) {                         // IF IRREVOCABLE, calculate back the bonus
            stakesSharesCorr = stakesSharesCorr.mul(80).div(100);
        }

        _sharePriceUpdate(
            _stake.stakedAmount > _stake.penaltyAmount ? _stake.stakedAmount - _stake.penaltyAmount : 0,
            _stake.rewardAmount + withdraws[msg.sender][_stakeID],
            _stake.stakingDays,
            stakesSharesCorr
        );

        emit StakeEnded(
            _stakeID,
            msg.sender,
            _stake.stakedAmount,
            _stake.stakesShares,
            _stake.rewardAmount,
            _stake.closeDay,
            _stake.penaltyAmount
        );
    }

    function _addScheduledShares(
        uint32 _finalDay,
        uint256 _shares
    )
        private
    {
        scheduledToEnd[_finalDay] =
        scheduledToEnd[_finalDay].add(_shares);
    }

    function _removeScheduledShares(
        uint32 _finalDay,
        uint256 _shares
    )
        internal
    {
        if (_finalDay >= _currentRxDay()) {

            scheduledToEnd[_finalDay] =
            scheduledToEnd[_finalDay] > _shares ?
            scheduledToEnd[_finalDay] - _shares : 0;

        } else {

            uint32 _day = _currentRxDay() - 1;
            snapshots[_day].scheduledToEnd =
            snapshots[_day].scheduledToEnd > _shares ?
            snapshots[_day].scheduledToEnd - _shares : 0;
        }
    }

    function _sharePriceUpdate(
        uint256 _stakedAmount,
        uint256 _rewardAmount,
        uint32 _stakingDays,
        uint256 _stakeShares
    )
        internal
    {
        if (_stakeShares > 0 && _currentRxDay() > 3) {

            uint256 newSharePrice = _getNewSharePrice(
                _stakedAmount + _rewardAmount,
                _stakeShares,
                _stakingDays
            );

            if (newSharePrice > globals.sharePrice) {

                newSharePrice =
                    newSharePrice < globals.sharePrice.mul(105).div(100) ?
                    newSharePrice : globals.sharePrice.mul(105).div(100);

                emit NewSharePrice(
                    newSharePrice,
                    globals.sharePrice,
                    _currentRxDay()
                );

                globals.sharePrice = newSharePrice;
            }
        }
    }

    function _getNewSharePrice(
        uint256 _tokenAmount,
        uint256 _stakeShares,
        uint32 _stakingDays
    )
        private
        pure
        returns (uint256)
    {
        return _tokenAmount
            .mul(PRECISION_RATE)
            .mul( SHARES_PRECISION + _getBonus(_stakingDays) )
            .div(SHARES_PRECISION)
            .div(_stakeShares);
    }

    function _stakesShares(
        uint256 _stakedAmount,
        uint32 _stakingDays,
        uint256 _sharePrice
    )
        internal
        pure
        returns (uint256)
    {
        return _stakedAmount
            .mul(PRECISION_RATE)
            .div(_sharePrice)
            .mul( SHARES_PRECISION + _getBonus(_stakingDays) )
            .div(SHARES_PRECISION);
    }

    function _getBonus(
        uint32 _stakingDays
    )
        private
        pure
        returns (uint256)
    {
        uint32 _days = 0;
        uint32 fullYears = _stakingDays.div(365);
        for (uint32 i = 1; i <= fullYears; i++)
        {
            _days += i * 365;
        }
        _days += (_stakingDays - 365 * fullYears) * (fullYears + 1);

        return uint256(_days).mul(SHARES_PRECISION).div(7300);
    }

    function _checkStakeDataByID(address _staker, bytes16 _stakeID) external view returns (bool, uint8, uint32, uint32, uint256, uint256) {
        return (stakes[_staker][_stakeID].isSplit, stakes[_staker][_stakeID].isIrrTrex, stakes[_staker][_stakeID].startDay, stakes[_staker][_stakeID].finalDay, stakes[_staker][_stakeID].stakesShares, stakes[_staker][_stakeID].stakedAmount);
    }

    /**
    * @notice A public function to calculate the accumulated REWARDS of a STAKE (in any state)
    * @dev Returns paid rewards of ENDED stakes, 0 for SOLD and TRANSFERRED stakes, withdrawable rewards for ACTIVE/OFFERED stakes
    * @param _staker Owner of the stake
    * @param _stakeID unique bytes sequence reference to the stake of the owner
    * @param _withdrawDays Number of days to calculate in case of withdrawal of rewards, 0 for ALL days
    */
    function _checkRewardAmountbyID(
        address _staker,
        bytes16 _stakeID,
        uint32 _withdrawDays
    )
        public
        view
        returns (uint32 _withdrawDay, uint256 rewardAmount, uint256 sharesPenalty)
    {
        Stake memory stake = stakes[_staker][_stakeID];

        if (stake.isActive == 0) { return (0, stake.rewardAmount, 0); }        // ended stake - return saved rewardAmount
        if (stake.startDay > _currentRxDay()) { return (0, 0, 0); }            // stake not started - return 0
        if (stake.isActive == 3 || stake.isActive == 4) { return (0, 0, 0); }  // stake transferred or sold - return 0

        if (_currentRxDay() >= stake.finalDay)
        {
            // the stake is ACTIVE (or still OFFERED on DEX) and MATURE - calculate rewards for ALL past days and deduct LATE penalty on rewards (if applicable)
            // Withdrawing rewards is not possible at this point, so there are no penalties for shares
            // if rewards have been withdrawn before, this is regarded by using _startingDay(stake)

            uint32 _finalDay = _calculationDay(stake);

            rewardAmount = _loopRewardAmount(
                stake.stakesShares,
                _startingDay(stake),
                _finalDay
            );

              // LATE CLAIM: deduct REWARDS penalty of 1%/week, if claimed more than 14 days after finalDay
            if (_currentRxDay() > (_finalDay + uint32(14)) && rewardAmount > 0) {
                uint256 _reductionPercent = ((uint256(_currentRxDay()) - uint256(_finalDay) - uint256(14)) / uint256(7)) + uint256(1);
                if (_reductionPercent > 100) { _reductionPercent = 100; }
                rewardAmount = rewardAmount
                    .mul( uint256(100).sub(_reductionPercent) )
                    .div(100);
            }
            return (0, rewardAmount, 0);
        }
        else
        {
            // now, the stake must be ACTIVE or OFFERED on DEX, already started and not mature:
            // calculate the withdrawable rewardAmount and the sharesPenalty that would be deducted

            _withdrawDay = _withdrawDays > 0               // startingDay returns stake.startDay OR stake.withdrawDay (if withdrawn already)
                ? _startingDay(stake).add(_withdrawDays)   // if not all days shall be withdrawn, add desired days to startingDay
                : _calculationDay(stake);                  // calculationDay returns latest possible day to withdraw (calculated day))

            _withdrawDay = _withdrawDay > _currentRxDay()  // as _withdrawDay still might exceed currrentDay, limit to currentDay
                ? _calculationDay(stake)
                : _withdrawDay;

            if ( _withdrawDay <= _startingDay(stake))      // if _withdrawDay is not greater than _startingDay all possible rewards have already been fetched
            {
                return (0, 0, 0);
            }

            rewardAmount = _loopRewardAmount(              // startingDay returns stake.startDay OR stake.withdrawDay (if withdrawn before)
                stake.stakesShares,
                _startingDay(stake),
                _withdrawDay
            );

              // calculate penalty - shares that would be deducted (if there are any rewards)
              // this part is only for REVOCABLE STAKES when rewards are being withdrawn
              // deduct the shares, that the user would get, when creating a new stake for the remaining days (@ current SharePrice)

            if (rewardAmount > 0)
            {
                sharesPenalty = _stakesShares(
                    rewardAmount,
                    _daysLeft(stake),
                    stake.isIrrTrex == 2 ? globals.sharePrice.mul(80).div(100) : globals.sharePrice
                );
            }
            else
            {
                return (0, 0, 0);
            }

            return (_withdrawDay, rewardAmount, sharesPenalty);
        }
    }

    /**
    * @notice An external function to calculate penalties on a REX PRINCIPAL for ACTIVE STAKES and OFFERED STAKES
    * @dev Shouldn't be used in front-end for IMMATURE IRREVOCABLE STAKES, because they cannot be ended early
    * @param _staker Owner of the stake
    * @param _stakeID unique bytes sequence reference to the stake of the owner
    */
    function _checkPenaltyAmountbyID(address _staker, bytes16 _stakeID) external view returns (uint256 penaltyAmount) {
        Stake memory stake = stakes[_staker][_stakeID];
        return stake.isActive == 0 ? stake.penaltyAmount : (
            stake.isActive == 1 || stake.isActive == 2 ? _calculatePenaltyAmount(stake) : (
                stake.isActive == 3 || stake.isActive == 4 ? 0 : 0
                )
            );
    }

    /**
    * @notice A private function used to calculate penalties on a REX PRINCIPAL for ACTIVE STAKES and OFFERED STAKES
    * If stake has not started or fully served, no penalty => (_stakeNotStarted(_stake) || _daysLeft(_stake) == 0)
    * Otherwise linear from day 1 (90% penalty) to last day before maturity (10% penalty)
    * @param _stake unique bytes sequence reference to the stake
    */
    function _calculatePenaltyAmount(
        Stake memory _stake
    )
        private
        view
        returns (uint256)
    {
        return ( _stakeNotStarted(_stake) || _daysLeft(_stake) == 0 ) ? 0 :
            ( _stake.stakedAmount * (100 + (800 * (_daysLeft(_stake) - 1) / (_stake.stakingDays - 1) ) ) / 1000 );
    }

    function _loopRewardAmount(
        uint256 _stakeShares,
        uint32 _startDay,
        uint32 _finalDay
    )
        internal
        view
        returns (uint256 _rewardAmount)
    {
          // calculate rewards / day
        for (uint32 _day = _startDay; _day < _finalDay; _day++) {
            _rewardAmount += _stakeShares * PRECISION_RATE / snapshots[_day].inflationAmount;
        }
    }
}

abstract contract ExtendedStaking is StakingToken {

    using SafeMath for uint256;
    using SafeMath32 for uint32;

    /**
    * @notice A function for a staker (not a contract) to transfer an active stake,
    * belonging to his address by providing the stake ID, to another address (not a contract).
    * Not possible if staking rewards have been withdrawn before.
    * @param _stakeID unique bytes sequence reference to the stake
    * @param _toAddress Receiver of the stake
    */
    function transferStake(
        bytes16 _stakeID,
        address _toAddress
    )
        external
    {
        require(_notContract(msg.sender) && msg.sender == tx.origin, 'REX: Not an address');

        _dailySnapshotPoint(_currentRxDay());

        require(stakes[msg.sender][_stakeID].isActive == 1, 'RX: 7');
        require(stakes[msg.sender][_stakeID].withdrawDay == 0, 'RX: 8');
        require(_toAddress != msg.sender && _notContract(_toAddress), 'RX: 9');

        Stake memory _temp = stakes[msg.sender][_stakeID];
        Stake memory _newStake;

        _newStake.stakesShares = _temp.stakesShares;
        _newStake.stakedAmount = _temp.stakedAmount;
        _newStake.startDay = _temp.startDay;
        _newStake.stakingDays = _temp.stakingDays;
        _newStake.finalDay = _temp.finalDay;
        _newStake.isActive = 1;
        _newStake.isIrrTrex = _temp.isIrrTrex;
        _newStake.isSplit = _temp.isSplit;
        _newStake.description = _temp.description;

          // save the new stake for the new staker (toAddress)
        bytes16 _newReceiverStakeID = _generateStakeID(_toAddress);
        stakes[_toAddress][_newReceiverStakeID] = _newStake;
        stakeCount[_toAddress] = stakeCount[_toAddress] + 1;

        Stake storage _stake = stakes[msg.sender][_stakeID];
        _stake.closeDay = _currentRxDay();
        _stake.isActive = 4;

          // transfer staked amount to the new staker (sub and add)
        totalREXinActiveStakes[msg.sender] = totalREXinActiveStakes[msg.sender] > _temp.stakedAmount ?
            totalREXinActiveStakes[msg.sender].sub(_temp.stakedAmount) : 0;
        totalREXinActiveStakes[_toAddress] = totalREXinActiveStakes[_toAddress].add(_temp.stakedAmount);

        emit StakeTransferred(_stakeID, _newReceiverStakeID, msg.sender, _toAddress, _currentRxDay());
    }

    /**
    * @notice A function for a staker to rename a stake
    * belonging to his address by providing the stake ID
    * @param _stakeID unique bytes sequence reference to the stake
    * @param _description New description
    */
    function renameStake(
        bytes16 _stakeID,
        string calldata _description
    )
        external
    {
        _dailySnapshotPoint(_currentRxDay());

        require(stakes[msg.sender][_stakeID].isActive == 1, 'RX: 10');

        Stake storage _stake = stakes[msg.sender][_stakeID];    // get the stake
        _stake.description = _description;                      // change description
    }

    /**
    * @notice A function for a staker to split a portion off the stake
    * belonging to his address by providing the stake ID and the amount of REX principal
    * @param _stakeID unique bytes sequence reference to the stake
    * @param amountSplit amount that shall be slit off to a new stake
    */
    function splitStake(
        bytes16 _stakeID,
        uint256 amountSplit
    )
        external
    {
        _dailySnapshotPoint(_currentRxDay());

        require(stakes[msg.sender][_stakeID].isActive == 1, 'RX: 11');
        require(!stakes[msg.sender][_stakeID].isSplit, 'RX: 12');
        require(stakes[msg.sender][_stakeID].withdrawDay == 0, 'RX: 13');

        uint256 origAmount = stakes[msg.sender][_stakeID].stakedAmount;
        require(amountSplit >= MIN_STAKE_AMOUNT && amountSplit < origAmount, 'RX: 14');
        require((origAmount - amountSplit) >= MIN_STAKE_AMOUNT, 'RX: 15'); // original stake gets too small?

        Stake memory _temp = stakes[msg.sender][_stakeID];
        Stake memory _newStake;

        _newStake.stakesShares = _temp.stakesShares.mul(amountSplit).div(origAmount);
        _newStake.stakedAmount = amountSplit;
        _newStake.startDay = _temp.startDay;
        _newStake.stakingDays = _temp.stakingDays;
        _newStake.finalDay = _temp.finalDay;
        _newStake.isActive = 1;
        _newStake.isSplit = true;
        _newStake.isIrrTrex = _temp.isIrrTrex;
        _newStake.description = _temp.description;

        Stake storage _stake = stakes[msg.sender][_stakeID];
        _stake.isSplit = true;
        _stake.stakesShares = _stake.stakesShares - _newStake.stakesShares; // can't be less than zero
        _stake.stakedAmount = _stake.stakedAmount - _newStake.stakedAmount;

          // save the new stake
        bytes16 _newStakeID = _generateStakeID(msg.sender);
        stakes[msg.sender][_newStakeID] = _newStake;
        stakeCount[msg.sender] = stakeCount[msg.sender] + 1;

        emit StakeStarted(
            _newStakeID,
            msg.sender,
            _newStake.stakedAmount,
            _newStake.stakesShares,
            _newStake.startDay,
            _newStake.stakingDays
        );
    }

    /**
    * @notice allows a staker (not a contract) to withdraw staking rewards from active stake
    * @param _stakeID unique bytes sequence reference to the stake
    * @param _withdrawDays number of days to process (from the beginning / last withdraw day), all possible days = 0
    */
    function withdrawRewards(
        bytes16 _stakeID,
        uint32 _withdrawDays
    )
        external
        returns (
            uint32 withdrawDay,
            uint256 withdrawAmount,
            uint256 stakersPenalty
        )
    {
        _dailySnapshotPoint(_currentRxDay());

        require(stakes[msg.sender][_stakeID].isActive == 1, 'RX: 16');                // only if stake is active
        require(stakes[msg.sender][_stakeID].isIrrTrex == 0 || stakes[msg.sender][_stakeID].isIrrTrex == 2, 'RX: 18'); // not possible for irrevocable stakes
        require(_currentRxDay() > stakes[msg.sender][_stakeID].startDay, 'RX: 17');   // stake must have passed the first active day, or there are no rewards to withdraw
        require(stakes[msg.sender][_stakeID].finalDay > _currentRxDay(), 'RX: 17a');  // only if stake is immature

        Stake memory stake = stakes[msg.sender][_stakeID];  // get stake

        (withdrawDay, withdrawAmount, stakersPenalty) = _checkRewardAmountbyID(msg.sender, _stakeID, _withdrawDays);
        require(withdrawAmount > 0, 'RX: Fail');

        uint256 _sharesTemp = stake.stakesShares;  // save current stakesShares in _sharesTemp

          // deduct penalty from SHARES
        stake.stakesShares =
            stake.stakesShares > stakersPenalty ?
            stake.stakesShares.sub(stakersPenalty) : 0;

          // keep track of the scheduled shares: deduct from final day - then log globals
        _removeScheduledShares(stake.finalDay, stakersPenalty > _sharesTemp ? _sharesTemp : stakersPenalty);
        _decreaseGlobals(0, _sharesTemp > stakersPenalty ? stakersPenalty : _sharesTemp);

          // keep track of withdraws for sharePriceUpdate when calling _endStake
        withdraws[msg.sender][_stakeID] = withdraws[msg.sender][_stakeID].add(withdrawAmount);

        stake.withdrawDay = withdrawDay;
        stakes[msg.sender][_stakeID] = stake;

        _mint(msg.sender, withdrawAmount);

        emit RewardsWithdrawn(_stakeID, msg.sender, withdrawAmount, withdrawDay, stakersPenalty, _currentRxDay());
    }
}

abstract contract DexToken is ExtendedStaking {

    using SafeMath for uint256;
    using SafeMath32 for uint32;

    /**
    * @notice A function for a staker (not a contract) to offer an active stake on the REX STAKES DEX
    * Requirements: Listing duration is between 1 and 30 days.
    * Not possible if rewards have been withdrawn before.
    * @param _stakeID unique bytes sequence reference to the stake
    * @param _price of the stake
    * @param _durationDays of the stake
    */
    function offerStake(
        bytes16 _stakeID,
        uint256 _price,
        uint32 _durationDays
    )
        external
    {
        _dailySnapshotPoint(_currentRxDay());

          // require price/duration/timing limits
        require(_price >= 5E18, 'RX: 19');
        require(_durationDays >= 1 && _durationDays <= 30, 'RX: 20');
        require((_currentRxDay() + _durationDays) < stakes[msg.sender][_stakeID].finalDay, 'RX: 21');
        require(_currentRxDay() >= ((stakes[msg.sender][_stakeID].stakingDays).mul(10).div(100).add(stakes[msg.sender][_stakeID].startDay)), 'RX: 22');
        require(_currentRxDay() >= DEX_ACTIVATION_DAY, 'RX: 23');

          // require stake active and not-withdrawn rewards
        require(stakes[msg.sender][_stakeID].isActive == 1, 'RX: 24');
        require(stakes[msg.sender][_stakeID].withdrawDay == 0, 'RX: 25');

          // temporarily deactivate stake to prevent from usage (isActive = 2)
          // do this before "listStake" on DEX (reentrancy) - in the next step
        Stake storage _stake = stakes[msg.sender][_stakeID];
        _stake.isActive = 2;

          // sent data to DEX
        DEX_CONTRACT.listStake(msg.sender, _currentRxDay(), _durationDays, _price, _stakeID);
    }

    /**
    * @notice A function for the DEX to restore a stake
    * @dev Triggered by the user in DEX contract
    */
    function restoreStake(
        address _staker,
        bytes16 _stakeID
    )
        external
    {
        _dailySnapshotPoint(_currentRxDay());

        require(msg.sender == address(DEX_CONTRACT), 'RX: 26');

        Stake storage _stake = stakes[_staker][_stakeID];  // get the stake
        _stake.isActive = 1;
    }

    /**
    * @notice A function for the DEX to create a stake
    * belonging to _fromAddress by providing the stake ID, to _toAddress.
    * @dev Triggered by the user in DEX contract
    * @param _stakeID unique bytes sequence reference to the stake
    * @param _fromAddress Seller of the stake
    * @param _toAddress Buyer of the stake
    */
    function createBoughtStake(
        bytes16 _stakeID,
        address _fromAddress,
        address _toAddress
    )
        external
    {
        _dailySnapshotPoint(_currentRxDay());

        require(msg.sender == address(DEX_CONTRACT), 'RX: 27');

        Stake memory _temp = stakes[_fromAddress][_stakeID];
        Stake memory _newStake;

        _newStake.stakesShares = _temp.stakesShares;
        _newStake.stakedAmount = _temp.stakedAmount;
        _newStake.startDay = _temp.startDay;
        _newStake.stakingDays = _temp.stakingDays;
        _newStake.finalDay = _temp.finalDay;
        _newStake.isActive = 1;
        _newStake.isIrrTrex = _temp.isIrrTrex;
        _newStake.isSplit = _temp.isSplit;
        _newStake.description = unicode'BOUGHT on DEX';

          // save the new stake for the buyer (toAddress)
        bytes16 _newReceiverStakeID = _generateStakeID(_toAddress);
        stakes[_toAddress][_newReceiverStakeID] = _newStake;
        stakeCount[_toAddress] = stakeCount[_toAddress] + 1;

        Stake storage _stake = stakes[_fromAddress][_stakeID];
        _stake.closeDay = _currentRxDay();
        _stake.isActive = 3;

          // transfer staked amount to the new staker (sub and add)
        totalREXinActiveStakes[_fromAddress] = totalREXinActiveStakes[_fromAddress] > _temp.stakedAmount ?
            totalREXinActiveStakes[_fromAddress].sub(_temp.stakedAmount) : 0;
        totalREXinActiveStakes[_toAddress] = totalREXinActiveStakes[_toAddress].add(_temp.stakedAmount);

        emit StakeTransferred(_stakeID, _newReceiverStakeID, _fromAddress, _toAddress, _currentRxDay());
    }
}

contract RexToken is DexToken {

    address public TOKEN_DEFINER;
    IUniswapV2Pair public UNISWAP_PAIR;

    constructor() BEP20Token("REX", "XRX") {
        TOKEN_DEFINER = msg.sender;
    }

    receive() external payable { revert(); }
    fallback() external payable { revert(); }

    /**
     * @notice Set up the contract's REX interface
     * @dev revoke TOKEN_DEFINER access afterwards
     */
    function initRexContracts(address _AIRDROP, address _RDA, address _DEX, address _TREX) external {
        require(msg.sender == TOKEN_DEFINER, 'RX: 28');
        AIRDROP_CONTRACT = _AIRDROP;
        RDA_CONTRACT = _RDA;
        DEX_CONTRACT = IREXDEX(_DEX);
        TREX_TOKEN = IBEP20(_TREX);
        UNISWAP_PAIR = IUniswapV2Pair(IUniswapV2Factory(UNISWAP_ROUTER.factory())
        .createPair(address(this), busd_address));
    }

    function revokeAccess() external
    {
        require(msg.sender == TOKEN_DEFINER, 'RX: 29');
        TOKEN_DEFINER = address(0x0);
    }

    /**
     * @notice Allows RexDailyAuction Contract to mint REX tokens
     * @dev executed from RDA_CONTRACT when claiming REX after donations and referrals
     * @param _donatorAddress to mint REX for
     * @param _amount of tokens to mint for _donatorAddress
     */
    function mintSupply(
        address _donatorAddress,
        uint256 _amount
    )
        external
    {
        require( (msg.sender == AIRDROP_CONTRACT || msg.sender == RDA_CONTRACT), 'RX: 30');
        _mint(_donatorAddress, _amount);
    }

    /**
     * @dev totalSupply() is the circulating supply, doesn't include STAKED REX. allocatedSupply() includes both.
     * @return Allocated Supply in REX
     */
    function allocatedSupply() external view returns (uint256)
    {
        return totalSupply() + globals.totalStaked;
    }

}