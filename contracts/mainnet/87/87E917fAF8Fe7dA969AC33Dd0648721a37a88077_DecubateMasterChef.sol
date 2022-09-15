//** Decubate Staking Contract */
//** Author : Aceson */

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721EnumerableUpgradeable.sol";
import "./libraries/InterestHelper.sol";
import "./interfaces/IDecubateMasterChef.sol";

contract DecubateMasterChef is
  Initializable,
  OwnableUpgradeable,
  InterestHelper,
  IDecubateMasterChef
{
  using SafeMathUpgradeable for uint256;
  using SafeMathUpgradeable for uint16;

  /**
   *
   * @dev PoolInfo reflects the info of each pools
   *
   * If APY is 12%, we provide 120 as input. lockPeriodInDays
   * would be the number of days which the claim is locked.
   * So if we want to lock claim for 1 month, lockPeriodInDays would be 30.
   *
   * @param {apy} Percentage of yield produced by the pool
   * @param {nft} Multiplier for apy if user holds nft
   * @param {lockPeriodInDays} Amount of time claim will be locked
   * @param {totalDeposit} Total deposit in the pool
   * @param {startDate} starting time of pool
   * @param {endDate} ending time of pool in unix timestamp
   * @param {minContrib} Minimum amount to be staked
   * @param {maxContrib} Maximum amount that can be staked
   * @param {hardCap} Maximum amount a pool can hold
   * @param {token} Token used as deposit/reward
   *
   */

  struct Pool {
    uint256 apy;
    uint256 lockPeriodInDays;
    uint256 totalDeposit;
    uint256 startDate;
    uint256 endDate;
    uint256 hardCap;
    address token;
  }

  address public compounderContract; //Auto compounder
  address private feeAddress; //Address which receives fee
  uint8 private feePercent; //Percentage of fee deducted (/1000)

  mapping(uint256 => mapping(address => User)) public users;
  mapping(address => uint256) public maxTransferAmount;

  Pool[] public poolInfo;
  NFTMultiplier[] public nftInfo;

  event Stake(address indexed addr, uint256 amount, uint256 time);
  event Claim(address indexed addr, uint256 amount, uint256 time);
  event Reinvest(address indexed addr, uint256 amount, uint256 time);
  event Unstake(address indexed addr, uint256 amount, uint256 time);

  function initialize() external initializer {
    __Ownable_init();
    feeAddress = msg.sender;
    feePercent = 5;
  }

  /**
   *
   * @dev update fee values
   *
   */
  function updateFeeValues(uint8 _feePercent, address _feeWallet) external onlyOwner {
    feePercent = _feePercent;
    feeAddress = _feeWallet;
  }

  /**
   *
   * @dev update compounder contract
   *
   */
  function updateCompounder(address _compounder) external override onlyOwner {
    compounderContract = _compounder;
  }

  /**
   *
   * @dev Allow owner to transfer token from contract
   *
   * @param {address} contract address of corresponding token
   * @param {uint256} amount of token to be transferred
   *
   * This is a generalized function which can be used to transfer any accidentally
   * sent (including DCB) out of the contract to wowner
   *
   */
  function transferToken(address _addr, uint256 _amount) external onlyOwner returns (bool) {
    IERC20Upgradeable token = IERC20Upgradeable(_addr);
    bool success = token.transfer(address(owner()), _amount);
    return success;
  }

  /**
   *
   * @dev add new period to the pool, only available for owner
   *
   */
  function add(
    uint256 _apy,
    uint256 _lockPeriodInDays,
    uint256 _endDate,
    uint256 _hardCap,
    address _token
  ) external override onlyOwner {
    poolInfo.push(
      Pool({
        apy: _apy,
        lockPeriodInDays: _lockPeriodInDays,
        totalDeposit: 0,
        startDate: block.timestamp,
        endDate: _endDate,
        hardCap: _hardCap,
        token: _token
      })
    );

    //Init nft struct with dummy data
    nftInfo.push(
      NFTMultiplier({
        active: false,
        name: "",
        contractAdd: address(0),
        startIdx: 0,
        endIdx: 0,
        multiplier: 10
      })
    );

    maxTransferAmount[_token] = ~uint256(0);
    _stake(poolLength() - 1, compounderContract, 0, false); //Mock deposit for compounder
  }

  /**
   *
   * @dev update the given pool's Info
   *
   */
  function set(
    uint256 _pid,
    uint256 _apy,
    uint256 _lockPeriodInDays,
    uint256 _endDate,
    uint256 _hardCap,
    uint256 _maxTransfer,
    address _token
  ) external override onlyOwner {
    require(_pid < poolLength(), "Invalid pool Id");

    poolInfo[_pid].apy = _apy;
    poolInfo[_pid].lockPeriodInDays = _lockPeriodInDays;
    poolInfo[_pid].endDate = _endDate;
    poolInfo[_pid].hardCap = _hardCap;
    poolInfo[_pid].token = _token;

    maxTransferAmount[_token] = _maxTransfer;
  }

  /**
   *
   * @dev update the given pool's nft info
   *
   */
  function setNFT(
    uint256 _pid,
    string calldata _name,
    address _contractAdd,
    bool _isUsed,
    uint16 _multiplier,
    uint16 _startIdx,
    uint16 _endIdx
  ) external override onlyOwner {
    NFTMultiplier storage nft = nftInfo[_pid];

    nft.name = _name;
    nft.contractAdd = _contractAdd;
    nft.active = _isUsed;
    nft.multiplier = _multiplier;
    nft.startIdx = _startIdx;
    nft.endIdx = _endIdx;
  }

  /**
   *
   * @dev depsoit tokens to staking for TOKEN allocation
   *
   * @param {_pid} Id of the pool
   * @param {_amount} Amount to be staked
   *
   * @return {bool} Status of stake
   *
   */
  function stake(uint256 _pid, uint256 _amount) external override returns (bool) {
    Pool memory pool = poolInfo[_pid];
    IERC20Upgradeable token = IERC20Upgradeable(pool.token);

    require(
      token.allowance(msg.sender, address(this)) >= _amount,
      "Decubate : Set allowance first!"
    );

    bool success = token.transferFrom(msg.sender, address(this), _amount);
    require(success, "Decubate : Transfer failed");

    reinvest(_pid);

    _stake(_pid, msg.sender, _amount, false);

    return success;
  }

  /**
   *
   * @dev Handle NFT boost of users from compounder
   *
   * @param {_pid} id of the pool
   * @param {_user} user eligible for NFT boost
   * @param {_rewardAmount} Amount of rewards generated
   *
   * @return {uint256} Status of stake
   *
   */
  function handleNFTMultiplier(
    uint256 _pid,
    address _user,
    uint256 _rewardAmount
  ) external override returns (uint256) {
    require(msg.sender == compounderContract, "Only for compounder");
    uint16 multi = calcMultiplier(_pid, _user);

    uint256 multipliedAmount = _rewardAmount.mul(multi).div(10).sub(_rewardAmount);

    if (multipliedAmount > 0) {
      safeTOKENTransfer(poolInfo[_pid].token, _user, multipliedAmount);
    }

    return multipliedAmount;
  }

  /**
   *
   * @dev claim accumulated TOKEN reward for a single pool
   *
   * @param {_pid} pool identifier
   *
   * @return {bool} status of claim
   */

  function claim(uint256 _pid) public override returns (bool) {
    require(canClaim(_pid, msg.sender), "Reward still in locked state");

    _claim(_pid, msg.sender);

    return true;
  }

  /**
   *
   * @dev Reinvest accumulated TOKEN reward for a single pool
   *
   * @param {_pid} pool identifier
   *
   * @return {bool} status of reinvest
   */

  function reinvest(uint256 _pid) public override returns (bool) {
    uint256 amount = payout(_pid, msg.sender);
    if (amount > 0) {
      _stake(_pid, msg.sender, amount, true);
      emit Reinvest(msg.sender, amount, block.timestamp);
    }

    return true;
  }

  /**
   *
   * @dev Reinvest accumulated TOKEN reward for all pools
   *
   * @return {bool} status of reinvest
   */

  function reinvestAll() public override returns (bool) {
    uint256 len = poolInfo.length;
    for (uint256 pid = 0; pid < len; ++pid) {
      reinvest(pid);
    }

    return true;
  }

  /**
   *
   * @dev claim accumulated TOKEN reward from all pools
   *
   * Beware of gas fee!
   *
   */
  function claimAll() public override returns (bool) {
    uint256 len = poolInfo.length;

    for (uint256 pid = 0; pid < len; ++pid) {
      if (canClaim(pid, msg.sender)) {
        _claim(pid, msg.sender);
      }
    }

    return true;
  }

  /**
   *
   * @dev withdraw tokens from Staking
   *
   * @param {_pid} id of the pool
   * @param {_amount} amount to be unstaked
   *
   * @return {bool} Status of stake
   *
   */
  function unStake(uint256 _pid, uint256 _amount) public override returns (bool) {
    User storage user = users[_pid][msg.sender];
    Pool storage pool = poolInfo[_pid];

    require(user.totalInvested >= _amount, "You don't have enough funds");

    require(canClaim(_pid, msg.sender), "Stake still in locked state");

    _claim(_pid, msg.sender);

    safeTOKENTransfer(pool.token, msg.sender, _amount);

    pool.totalDeposit = pool.totalDeposit.sub(_amount);
    user.totalInvested = user.totalInvested.sub(_amount);

    emit Unstake(msg.sender, _amount, block.timestamp);

    return true;
  }

  /**
   *
   * @dev check whether user can claim or not
   *
   * @param {_pid}  id of the pool
   * @param {_addr} address of the user
   *
   * @return {bool} Status of claim
   *
   */

  function canClaim(uint256 _pid, address _addr) public view override returns (bool) {
    User storage user = users[_pid][_addr];
    Pool storage pool = poolInfo[_pid];

    if (msg.sender == compounderContract) {
      return true;
    }

    return (block.timestamp >= user.depositTime.add(pool.lockPeriodInDays.mul(1 days)));
  }

  /**
   *
   * @dev check whether user have NFT multiplier
   *
   * @param _pid  id of the pool
   * @param _addr address of the user
   *
   * @return multi Value of multiplier
   *
   */

  function calcMultiplier(uint256 _pid, address _addr) public view override returns (uint16 multi) {
    NFTMultiplier memory nft = nftInfo[_pid];

    if (nft.active && ownsCorrectNFT(_addr, _pid) && _addr != compounderContract) {
      multi = nft.multiplier;
    } else {
      multi = 10;
    }
  }

  function ownsCorrectNFT(address _addr, uint256 _pid) public view returns (bool) {
    NFTMultiplier memory nft = nftInfo[_pid];

    uint256[] memory ids = walletOfOwner(nft.contractAdd, _addr);
    for (uint256 i = 0; i < ids.length; i++) {
      if (ids[i] >= nft.startIdx && ids[i] <= nft.endIdx) {
        return true;
      }
    }
    return false;
  }

  function payout(uint256 _pid, address _addr) public view override returns (uint256 value) {
    User storage user = users[_pid][_addr];
    Pool storage pool = poolInfo[_pid];

    uint256 from = user.lastPayout > user.depositTime ? user.lastPayout : user.depositTime;
    uint256 to = block.timestamp > pool.endDate ? pool.endDate : block.timestamp;

    uint256 multiplier = calcMultiplier(_pid, _addr);

    if (from < to) {
      uint256 rayValue = yearlyRateToRay((pool.apy * 10**18) / 1000);
      value = (accrueInterest(user.totalInvested, rayValue, to.sub(from))).sub(user.totalInvested);
    }

    value = value.mul(multiplier).div(10);

    return value;
  }

  /**
   *
   * @dev get length of the pools
   *
   * @return {uint256} length of the pools
   *
   */
  function poolLength() public view override returns (uint256) {
    return poolInfo.length;
  }

  /**
   *
   * @dev get info of all pools
   *
   * @return {PoolInfo[]} Pool info struct
   *
   */
  function getPools() public view returns (Pool[] memory) {
    return poolInfo;
  }

  /**
   *
   * @dev safe TOKEN transfer function, require to have enough TOKEN to transfer
   *
   */
  function safeTOKENTransfer(
    address _token,
    address _to,
    uint256 _amount
  ) internal {
    IERC20Upgradeable token = IERC20Upgradeable(_token);
    uint256 bal = token.balanceOf(address(this));

    require(bal >= _amount, "Not enough funds in treasury");

    uint256 maxTx = maxTransferAmount[_token];
    uint256 amount = _amount;

    while (amount > maxTx) {
      token.transfer(_to, maxTx);
      amount = amount - maxTx;
    }

    if (amount > 0) {
      token.transfer(_to, amount);
    }
  }

  function _claim(uint256 _pid, address _addr) internal {
    User storage user = users[_pid][_addr];
    Pool memory pool = poolInfo[_pid];

    uint256 amount = payout(_pid, _addr);

    if (amount > 0) {
      user.totalWithdrawn = user.totalWithdrawn.add(amount);

      uint256 feeAmount = amount.mul(feePercent).div(1000);

      safeTOKENTransfer(pool.token, feeAddress, feeAmount);

      amount = amount.sub(feeAmount);

      safeTOKENTransfer(pool.token, _addr, amount);

      user.lastPayout = block.timestamp;

      user.totalClaimed = user.totalClaimed.add(amount);
    }

    emit Claim(_addr, amount, block.timestamp);
  }

  function _stake(
    uint256 _pid,
    address _sender,
    uint256 _amount,
    bool _isReinvest
  ) internal {
    User storage user = users[_pid][_sender];
    Pool storage pool = poolInfo[_pid];

    if (!_isReinvest || _sender != compounderContract) {
      user.depositTime = block.timestamp;
      if (_sender != compounderContract) {
        require(pool.totalDeposit.add(_amount) <= pool.hardCap, "Pool is full");
        uint256 stopDepo = pool.endDate.sub(pool.lockPeriodInDays.mul(1 days));
        require(block.timestamp <= stopDepo, "Staking is disabled for this pool");
      }
    }

    user.totalInvested = user.totalInvested.add(_amount);
    pool.totalDeposit = pool.totalDeposit.add(_amount);
    user.lastPayout = block.timestamp;

    emit Stake(_sender, _amount, block.timestamp);
  }

  /**
   *
   *
   * @dev Fetching nfts owned by a user
   *
   */
  function walletOfOwner(address _contract, address _owner)
    internal
    view
    returns (uint256[] memory)
  {
    IERC721EnumerableUpgradeable nft = IERC721EnumerableUpgradeable(_contract);
    uint256 tokenCount = nft.balanceOf(_owner);

    uint256[] memory tokensId = new uint256[](tokenCount);
    for (uint256 i; i < tokenCount; i++) {
      tokensId[i] = nft.tokenOfOwnerByIndex(_owner, i);
    }
    return tokensId;
  }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

contract DSMath {
  uint256 internal constant WAD = 10**18;
  uint256 internal constant RAY = 10**27;

  function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
    require((z = x + y) >= x, "ds-math-add-overflow");
  }

  function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
    require((z = x - y) <= x, "ds-math-sub-underflow");
  }

  function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
    require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
  }

  function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
    return x <= y ? x : y;
  }

  function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
    return x >= y ? x : y;
  }

  function imin(int256 x, int256 y) internal pure returns (int256 z) {
    return x <= y ? x : y;
  }

  function imax(int256 x, int256 y) internal pure returns (int256 z) {
    return x >= y ? x : y;
  }

  function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
    z = add(mul(x, y), WAD / 2) / WAD;
  }

  function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
    z = add(mul(x, y), RAY / 2) / RAY;
  }

  function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
    z = add(mul(x, WAD), y / 2) / y;
  }

  function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
    z = add(mul(x, RAY), y / 2) / y;
  }

  // This famous algorithm is called "exponentiation by squaring"
  // and calculates x^n with x as fixed-point and n as regular unsigned.
  //
  // It's O(log n), instead of O(n) for naive repeated multiplication.
  //
  // These facts are why it works:
  //
  //  If n is even, then x^n = (x^2)^(n/2).
  //  If n is odd,  then x^n = x * x^(n-1),
  //   and applying the equation for even x gives
  //    x^n = x * (x^2)^((n-1) / 2).
  //
  //  Also, EVM division is flooring and
  //    floor[(n-1) / 2] = floor[n / 2].
  //
  function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
    z = n % 2 != 0 ? x : RAY;

    for (n /= 2; n != 0; n /= 2) {
      x = rmul(x, x);

      if (n % 2 != 0) {
        z = rmul(z, x);
      }
    }
  }
}

// Using DSMath from DappHub https://github.com/dapphub/ds-math
// More info on DSMath and fixed point arithmetic in Solidity:
// https://medium.com/dapphub/introducing-ds-math-an-innovative-safe-math-library-d58bc88313da

/**
 * @title Interest
 * @author Nick Ward
 * @dev Uses DSMath's wad and ray math to implement (approximately)
 * continuously compounding interest by calculating discretely compounded
 * interest compounded every second.
 */
contract InterestHelper is DSMath {
  /**
   * @dev Uses an approximation of continuously compounded interest
   * (discretely compounded every second)
   * @param _principal The principal to calculate the interest on.
   *   Accepted in wei.
   * @param _rate The interest rate. Accepted as a ray representing
   *   1 + the effective interest rate per second, compounded every
   *   second. As an example:
   *   I want to accrue interest at a nominal rate (i) of 5.0% per year
   *   compounded continuously. (Effective Annual Rate of 5.127%).
   *   This is approximately equal to 5.0% per year compounded every
   *   second (to 8 decimal places, if max precision is essential,
   *   calculate nominal interest per year compounded every second from
   *   your desired effective annual rate). Effective Rate Per Second =
   *   Nominal Rate Per Second compounded every second = Nominal Rate
   *   Per Year compounded every second * conversion factor from years
   *   to seconds
   *   Effective Rate Per Second = 0.05 / (365 days/yr * 86400 sec/day)
   *                             = 1.5854895991882 * 10 ** -9
   *   The value we want to send this function is
   *   1 * 10 ** 27 + Effective Rate Per Second * 10 ** 27
   *   = 1000000001585489599188229325
   *   This will return 5.1271096334354555 Dai on a 100 Dai principal
   *   over the course of one year (31536000 seconds)
   * @param _age The time period over which to accrue interest. Accepted
   *   in seconds.
   * @return The new principal as a wad. Equal to original principal +
   *   interest accrued
   */
  function accrueInterest(
    uint256 _principal,
    uint256 _rate,
    uint256 _age
  ) public pure returns (uint256) {
    return rmul(_principal, rpow(_rate, _age));
  }

  /**
   * @dev Takes in the desired nominal interest rate per year, compounded
   *   every second (this is approximately equal to nominal interest rate
   *   per year compounded continuously). Returns the ray value expected
   *   by the accrueInterest function
   * @param _rateWad A wad of the desired nominal interest rate per year,
   *   compounded continuously. Converting from ether to wei will effectively
   *   convert from a decimal value to a wad. So 5% rate = 0.05
   *   should be input as yearlyRateToRay( 0.05 ether )
   * @return 1 * 10 ** 27 + Effective Interest Rate Per Second * 10 ** 27
   */
  function yearlyRateToRay(uint256 _rateWad) public pure returns (uint256) {
    return add(wadToRay(1 ether), rdiv(wadToRay(_rateWad), weiToRay(365 * 86400)));
  }

  //// Fixed point scale factors
  // wei -> the base unit
  // wad -> wei * 10 ** 18. 1 ether = 1 wad, so 0.5 ether can be used
  //      to represent a decimal wad of 0.5
  // ray -> wei * 10 ** 27

  // Go from wad (10**18) to ray (10**27)
  function wadToRay(uint256 _wad) internal pure returns (uint256) {
    return mul(_wad, 10**9);
  }

  // Go from wei to ray (10**27)
  function weiToRay(uint256 _wei) internal pure returns (uint256) {
    return mul(_wei, 10**27);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IDecubateMasterChef {
  struct NFTMultiplier {
    bool active;
    string name;
    address contractAdd;
    uint16 multiplier;
    uint16 startIdx;
    uint16 endIdx;
  }

  /**
   *
   * @dev User reflects the info of each user
   *
   *
   * @param {totalInvested} how many tokens the user staked
   * @param {totalWithdrawn} how many tokens withdrawn so far
   * @param {lastPayout} time at which last claim was done
   * @param {depositTime} Time of last deposit
   * @param {totalClaimed} Total claimed by the user
   *
   */
  struct User {
    uint256 totalInvested;
    uint256 totalWithdrawn;
    uint256 lastPayout;
    uint256 depositTime;
    uint256 totalClaimed;
  }

  function add(
    uint256 _apy,
    uint256 _lockPeriodInDays,
    uint256 _endDate,
    uint256 _hardCap,
    address token
  ) external;

  function set(
    uint256 _pid,
    uint256 _apy,
    uint256 _lockPeriodInDays,
    uint256 _endDate,
    uint256 _hardCap,
    uint256 _maxTransfer,
    address token
  ) external;

  function setNFT(
    uint256 _pid,
    string calldata _name,
    address _contractAdd,
    bool _isUsed,
    uint16 _multiplier,
    uint16 _startIdx,
    uint16 _endIdx
  ) external;

  function stake(uint256 _pid, uint256 _amount) external returns (bool);

  function claim(uint256 _pid) external returns (bool);

  function reinvest(uint256 _pid) external returns (bool);

  function reinvestAll() external returns (bool);

  function claimAll() external returns (bool);

  function handleNFTMultiplier(
    uint256 _pid,
    address _user,
    uint256 _rewardAmount
  ) external returns (uint256);

  function unStake(uint256 _pid, uint256 _amount) external returns (bool);

  function updateCompounder(address _compounder) external;

  function canClaim(uint256 _pid, address _addr) external view returns (bool);

  function calcMultiplier(uint256 _pid, address _addr) external view returns (uint16);

  function payout(uint256 _pid, address _addr) external view returns (uint256 value);

  function poolInfo(uint256)
    external
    view
    returns (
      uint256 apy,
      uint256 lockPeriodInDays,
      uint256 totalDeposit,
      uint256 startDate,
      uint256 endDate,
      uint256 hardCap,
      address token
    );

  function users(uint256, address)
    external
    view
    returns (
      uint256 totalInvested,
      uint256 totalWithdrawn,
      uint256 lastPayout,
      uint256 depositTime,
      uint256 totalClaimed
    );

  function poolLength() external view returns (uint256);
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
library SafeMathUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20Upgradeable.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}