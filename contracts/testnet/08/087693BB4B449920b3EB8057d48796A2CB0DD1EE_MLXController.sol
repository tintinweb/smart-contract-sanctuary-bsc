//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

// Libraries / Interfaces
import "../interfaces/IBEP20.sol";
import "../utils/SafeBEP20.sol";
import "../utils/SafeMath.sol";
import "../helpers/Ownable.sol";
import "../utils/Utils360.sol";

// MLX Helpers
import "./MLXEvents.sol";
import "./MLXData.sol";
import "../tokens/bsc/imlx.sol";
import "../tokens/bsc/mlxpos.sol";

// MLX State Contracts
import "./states/govern.sol";
import "./states/limits.sol";
import "./states/info.sol";

contract MLXController is
    Ownable,
    MLXData,
    MLXEvents,
    MLXGovern,
    MLXLimits,
    MLXInfo
{
    using SafeBEP20 for IBEP20;
    using SafeMath for uint;

    IMetaple internal mlx;
    MLXPOS internal mlxpos;

    // MLX Controller: Data Variables
    uint256 public mlxPerBlock = 0.1 ether;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public referralReward = 5;
    uint256 internal _depositedMLX = 0;

    // MLX Controller: Double Staking Protocol
    uint internal stakingAt = 0;
    uint internal xPool = 1;
    uint internal xRewards = 2;
    uint public xLocked = 14 days;

    // MLX Controller: Modifiers
    modifier onlyPoolAdder() {
        require(_poolAdder == _msgSender(), appendADDR("MLXError:", _msgSender()," is not the pool owner"));
        _;
    }
    
    modifier validatePoolByPid(uint256 _pid) {
        require (_pid < poolInfo . length , "Pool does not exist") ;
        _;
    }

    constructor (
        address _mlx,
        address _mlxpos,
        uint _startBlock
    ) {
        mlx = IMetaple(_mlx);
        mlxpos = MLXPOS(_mlxpos);
        _poolAdder = _msgSender();

        startBlock = _startBlock;

        // staking pool
        _addPool(IBEP20(_mlx), 1000, startBlock, 0);
        // pos pool
        _addPool(IBEP20(_mlxpos), 2000, startBlock, 0);
        totalAllocPoint = 3000;

        _poolExists[address(_mlx)] = true;
        _poolExists[address(_mlxpos)] = true;

    }

    // Setter Functions
    function setXRewards(uint _rewards) external onlyPoolAdder {
        require(_rewards <= 5 && _rewards > 0, "MLXController: not valid");
        emit SetNewXRewards(xRewards, _rewards);
        xRewards = _rewards;
    }

    function setXPool(uint _xpool) external onlyPoolAdder {
        xPool = _xpool;
    }

    function setStakePool(uint stakePool) external onlyPoolAdder {
        stakingAt = stakePool;
    }
    
    // Getter Functions

    function getmlx() external view returns (IMetaple) {
        return mlx;
    }

    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from).mul(1);
    }

    function _getMLXPerBlock() internal view returns (uint256) {
        return mlxPerBlock;
    }

    function getMLXPerBlock() external view returns (uint256) {
        return _getMLXPerBlock();
    }

    function getRewards(address _referrer) external view returns (uint256, uint256) {
        uint256 _farmRewards = _referrersFarm[_referrer];
        uint256 _stakeRewards = _referrersStake[_referrer];

        return (_farmRewards, _stakeRewards);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function checkReferral(uint256 _amount) internal view returns(uint256){
        return _amount.sub(_amount.mul(referralReward).div(1e2));
    }

    // MLX Controller: Logic Functions
    // Add New Pools - Only Operated by Pool Adder
    function add( uint256 _allocPoint, IBEP20 _lpToken, bool _withUpdate ) external onlyPoolAdder {
        require(!_poolExists[address(_lpToken)], "[!] Pool Already Exists");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accMLXPerShare: 0
            })
        );
        _poolExists[address(_lpToken)] = true;
    }

    // Update the given pool's MLX allocation point. Can only be called by the owner.
    function set( uint256 _pid, uint256 _allocPoint, bool _withUpdate) external onlyPoolAdder validatePoolByPid(_pid) {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        if(_pid == stakingAt) {
            poolInfo[xPool].allocPoint = _allocPoint.mul(xRewards);
        }
    }

    // Update Functions
    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public validatePoolByPid(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (_pid == 0){
            lpSupply = _depositedMLX;
        }
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 mlxReward = multiplier.mul(_getMLXPerBlock()).mul(pool.allocPoint).div(totalAllocPoint);
    
        mlx.mintMLX(address(mlxpos), mlxReward);

        if (_devFee > 0) {
            uint256 devFee = mlxReward.mul(_devFee).div(1e4);
            mlx.mintMLX(_devAddress, devFee);
        }
        
        pool.accMLXPerShare = pool.accMLXPerShare.add(mlxReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

     // View function to see pending MLXs on frontend.
    function pendingMLX(uint256 _pid, address _user) external validatePoolByPid(_pid) view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accMLXPerShare = pool.accMLXPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        
        if (_pid == 0){
            lpSupply = _depositedMLX;
        }

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 mlxReward = multiplier.mul(_getMLXPerBlock()).mul(pool.allocPoint).div(totalAllocPoint);
            accMLXPerShare = accMLXPerShare.add(mlxReward.mul(1e12).div(lpSupply));
        }

        return checkReferral(user.amount.mul(accMLXPerShare).div(1e12).sub(user.rewardDebt));
    }

    // Initialize Pending Rewards with Referral Rewards
    function initPending(address sender, uint256 pending, string memory which) internal returns (uint256) {
        address referral = mlx.referrer(sender);
        uint256 refRewards = pending.mul(referralReward).div(100);
        uint256 pendingRewards = pending.sub(refRewards);

        safeMLXTransfer(sender, pendingRewards);
        if(referral != address(0)){
            safeMLXTransfer(referral, refRewards);
            if(compareStrings("farm", which)){
                _referrersFarm[referral] = _referrersFarm[referral].add(refRewards);
            }else {
                _referrersStake[referral] = _referrersStake[referral].add(refRewards);
            }
        }else{
            safeMLXTransfer(_defaultReferral, refRewards);
            if(compareStrings("farm", which)){
                _referrersFarm[_defaultReferral] = _referrersFarm[_defaultReferral].add(refRewards);
            }else {
                _referrersStake[_defaultReferral] = _referrersStake[_defaultReferral].add(refRewards);
            }
        }

        return pendingRewards;
    }

    // Deposit LP tokens to MLX Controller for MLX allocation.
    function deposit(uint256 _pid, uint256 _amount) external validatePoolByPid(_pid) {
        require(startBlock <= block.number, "[+] Farming not started");
        require (_pid != 0, "deposit MLX by stakinge");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accMLXPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0){
                initPending(msg.sender, pending, "farm");
            }
        }

        if (_amount > 0){
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            user._lastInvested = block.timestamp;
            user._blockInvested = block.number;
        }

        user.rewardDebt = user.amount.mul(pool.accMLXPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MLX Controller.
    function withdraw(uint256 _pid, uint256 _amount) external validatePoolByPid(_pid) {
        require (_pid != 0, "withdraw MLX by unstaking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "MLXC: amount > staked");
        updatePool(_pid);

        if (_pid == xPool) {
            require (
                block.timestamp.sub(user._lastInvested) > xLocked, "[+] X Pool Locked"
            );
        }

        uint256 pending = user.amount.mul(pool.accMLXPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0){
            initPending(msg.sender, pending, "farm");
        }

        if(_amount > 0){
            user.amount = user.amount.sub(_amount);
            uint _withdrawFee = _withdrawalFee(_amount, user._lastInvested);
            if(_withdrawFee > 0){
                pool.lpToken.safeTransfer(_devAddress, _withdrawFee);
                _amount = _amount.sub(_withdrawFee);
            }
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }

        user.rewardDebt = user.amount.mul(pool.accMLXPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Stake MLX tokens to MLX Controller
    function enterStaking(uint256 _amount) external {
        require(startBlock <= block.number, "[+] Staking not started");
        
        PoolInfo storage pool = poolInfo[stakingAt];
        UserInfo storage user = userInfo[stakingAt][msg.sender];
        updatePool(stakingAt);

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accMLXPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                initPending(msg.sender, pending, "Stake");
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            user._lastInvested = block.timestamp;
            user._blockInvested = block.number;
            _depositedMLX = _depositedMLX.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accMLXPerShare).div(1e12);
        mlxpos.mint(msg.sender, _amount);
        emit Deposit(msg.sender, stakingAt, _amount);
    }

    // Withdraw MLX tokens from Staking.
    function leaveStaking(uint256 _amount) external {
        PoolInfo storage pool = poolInfo[stakingAt];
        UserInfo storage user = userInfo[stakingAt][msg.sender];
        require(user.amount >= _amount, "MLXC: amount > staked");
        updatePool(stakingAt);

        uint256 pending = user.amount.mul(pool.accMLXPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            initPending(msg.sender, pending, "Stake");
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            mlxpos.burn(msg.sender, _amount);

            uint _withdrawFee = _withdrawalFee(_amount, user._lastInvested);
            if(_withdrawFee > 0){
                pool.lpToken.safeTransfer(_devAddress, _withdrawFee);
                _amount = _amount.sub(_withdrawFee);
            }
            
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            _depositedMLX = _depositedMLX.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accMLXPerShare).div(1e12);
        emit Withdraw(msg.sender, stakingAt, _amount);
    }

    // Withdraw without rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external validatePoolByPid(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if(_pid == 0) {
            mlxpos.burn(msg.sender, user.amount);
        }

        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Transfer generated rewards
    function safeMLXTransfer(address _to, uint256 _amount) internal {
        mlxpos.safeMLXTransfer(_to, _amount);
    }

    // MLX Controller: Governing Functions
    function transferMLXOwner(address owner) external onlyOwner {
        mlx.transferOwnership(owner);
    }
    
    function transferPOSOwner(address owner) external onlyOwner {
        mlxpos.transferOwnership(owner);
    }

}

// SPDX-License-Identifier: MTI
pragma solidity 0.8.11;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MTI
pragma solidity 0.8.11;
import '../interfaces/IBEP20.sol';
import './SafeMath.sol';
import '../helpers/AddressHelper.sol';

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: MTI
pragma solidity 0.8.11;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
        return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
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

// SPDX-License-Identifier: MTI
pragma solidity 0.8.11;
import './Context.sol';

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
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
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() external onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) external onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// SPDX-License-Identifier: MTI
pragma solidity 0.8.11;
import "./SafeMath.sol";

contract Utils360 {
    using SafeMath for uint;
    
    function append(string memory a, string memory b, string memory c) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b, c));
    }

    function appendADDR(string memory a, address b, string memory c) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b, c));
    }

    function appendINT(string memory a, uint b, string memory c) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b, c));
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract MLXEvents {
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    
    event SetDevAddress(address indexed oldDev, address indexed newDev);
    event SetPoolAdder(address indexed oldAdder, address indexed newAdder);
    event SetReferralAddress(address indexed oldAddr, address indexed newAddr);
    event SetMLXPerBlock(uint256 oldPerBlock, uint256 newPerBlock);
    event SetMultiplier(uint256 oldMultiplier, uint256 newMultiplier);
    event SetMinReward(uint256 oldReward, uint256 newReward);
    event SetReferralReward(uint256 oldReferralReward, uint256 newReferralReward);
    event SetDevFee(uint256 oldFee, uint256 newFee);
    event SetNewMLX(address indexed _newMLX);
    event SetNewMLXPos(address indexed _newMLXPos);
    event SetNewXRewards(uint _old, uint _new);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../interfaces/IBEP20.sol";

contract MLXData {
    struct PoolInfo {
        IBEP20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accMLXPerShare;
    }

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint _lastInvested;
        uint _blockInvested;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IMetaple {
    function initReferral(address _referrer) external;
    function referrer(address owner) external view returns (address);
    function mintMLX(address account, uint256 amount) external returns (bool);
    function transferOwnership(address _newOwner) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../../interfaces/BEP20.sol";
import "./mlx.sol";

contract MLXPOS is BEP20("Metple POS", "MLXPOS", 18) {
    METAPLE private mlx;

    constructor(METAPLE _mlx) {
        mlx = _mlx;
    }

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _from ,uint256 _amount) external onlyOwner {
        _burn(_from, _amount);
    }

    function safeMLXTransfer(address _to, uint256 _amount) external onlyOwner {
        uint256 mlxBal = mlx.balanceOf(address(this));
        if (_amount > mlxBal) {
            mlx.transfer(_to, mlxBal);
        } else {
            mlx.transfer(_to, _amount);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../../helpers/Ownable.sol";
import "../MLXEvents.sol";

// MLX Controller: Governing Addresses
contract MLXGovern is Ownable, MLXEvents {
    address internal _devAddress;
    address internal _poolAdder;
    address internal _defaultReferral;
    uint256 internal _devFee;

    function devAddress() external view returns (address) {
        return _devAddress;
    }

    function poolAdder() external view returns (address) {
        return _poolAdder;
    }

    function defaultReferral() external view returns (address) {
        return _defaultReferral;
    }

    function devFee() external view returns (uint256) {
        return _devFee;
    }

    function setDevAddress(address _dev) external onlyOwner {
        emit SetDevAddress(_devAddress, _dev);
        _devAddress = _dev;
    }

    function setPoolAdder(address poolAddr) external onlyOwner {
        emit SetPoolAdder(_poolAdder, poolAddr);
        _poolAdder = poolAddr;
    }

    function setReferralAddress(address _referralAddr) external onlyOwner {
        emit SetReferralAddress(_defaultReferral, _referralAddr);
        _defaultReferral = _referralAddr;
    }

    function setDevFee(uint256 value) external onlyOwner {
        emit SetDevFee(_devFee, value);
        _devFee = value;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../../helpers/Ownable.sol";
import "../../utils/SafeMath.sol";
import "../../utils/Utils360.sol";
import "../MLXEvents.sol";

// MLX Controller: Withdraw Limits
contract MLXLimits is Ownable, MLXEvents, Utils360 {
    using SafeMath for uint;

    uint internal _lockedPeriod = 7 days;
    uint internal _withdrawFee = 3;
    uint internal _withdrawFeeMax = 1e3;

    function lockedPeriod() external view returns (uint) {
        return _lockedPeriod;
    }

    function withdrawFee() external view returns (uint) {
        return _withdrawFee;
    }

    function withdrawFeeMax() external view returns (uint) {
        return _withdrawFeeMax;
    }

    function setLockPeriod(uint lockP) external onlyOwner {
        _lockedPeriod = lockP;
    }

    function setWithdrawFee(uint fee) external onlyOwner {
        emit SetDevFee(_withdrawFee, fee);
        _withdrawFee = fee;
    }

    function canWithdrawRewards(uint investedAt) internal view {
        require(
            investedAt.add(_lockedPeriod) <= block.timestamp,
            appendINT("+ Withdrwal at ", investedAt.add(_lockedPeriod), " Epoch")
        );
    }

    function _withdrawalFee(uint amount, uint depositedAt) internal view returns (uint) {
        if (depositedAt.add(_lockedPeriod) > block.timestamp) {
            return amount.mul(_withdrawFee).div(_withdrawFeeMax);
        }

        return 0;
    }

    function withdrawalFee(uint amount, uint depositedAt) external view returns (uint) {
        return _withdrawalFee(amount, depositedAt);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../MLXData.sol";
import "../../interfaces/IBEP20.sol";

// MLX Controller: Info Variables
contract MLXInfo is MLXData {
    
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => bool) internal _poolExists;
    mapping(address => uint256) public _referrersFarm;
    mapping(address => uint256) public _referrersStake;

    function _addPool(
        IBEP20 lpToken,
        uint256 allocPoint,
        uint256 lastRewardBlock,
        uint256 accMLXPerShare
    ) internal {
        poolInfo.push(PoolInfo({
            lpToken: lpToken,
            allocPoint: allocPoint,
            lastRewardBlock: lastRewardBlock,
            accMLXPerShare: accMLXPerShare
        }));
    }

    function _getPool(
        uint _pid
    ) internal view returns (PoolInfo memory) {
        return poolInfo[_pid];
    }
}

// SPDX-License-Identifier: MTI
pragma solidity 0.8.11;

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
        assembly {
            codehash := extcodehash(account)
        }
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, 'Address: low-level call failed');
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: MTI
pragma solidity 0.8.11;

contract Context {
    constructor () { }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

// SPDX-License-Identifier: MTI
pragma solidity 0.8.11;
import "./IBEP20.sol";
import "../helpers/Context.sol";
import "../helpers/Ownable.sol";
import "../utils/SafeMath.sol";

abstract contract BEP20 is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  constructor(string memory NAME, string memory SYMBOL, uint8 DECIMALS) {
    _name = NAME;
    _symbol = SYMBOL;
    _decimals = DECIMALS;
  }

  function _initialMint(uint256 _value) internal {
    _mint(_msgSender(), _value);
  }

  function getOwner() external override view returns (address) {
    return owner();
  }

  function decimals() external override view returns (uint8) {
    return _decimals;
  }

  function symbol() external override view returns (string memory) {
    return _symbol;
  }

  function getSymbol() internal view returns (string memory) {
      return _symbol;
  }

  function name() external override view returns (string memory) {
    return _name;
  }

  function totalSupply() external override view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external override view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external override view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
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

  function mint(uint256 amount) external onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  function mintMLX(address receiver, uint256 amount) external onlyOwner returns (bool) {
    _mint(receiver, amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }
  
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _burnFrom(address account, uint256 amount) external {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../../interfaces/BEP20.sol";
import "../../utils/Utils360.sol";
import "../core/Ref360.sol";

contract METAPLE is BEP20("Metaple", "MLX", 18), Utils360, Ref360 {
    event MetapleDeployed (address metapleAddress);

    bool private isDeployed;
    uint256 private distribution = 150_000_000 ether;
    uint256 private distributed = 0;

    constructor () {
        isDeployed = true;
        assert(isDeployed == true);
        emit MetapleDeployed(address(this));
    }

    function initialMint() external onlyOwner {
        require(distributed < distribution, append("+ Not Enough ", getSymbol(), " Tokens To Mint"));
        _initialMint(distribution);
        distributed += distribution;
    }

    function initReferral(address _referrer) external {
        _setReferrer(msg.sender, _referrer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract Ref360 {
    mapping (address => address) private _referrals;
    mapping (address => address[]) public _allReferrals;

    function referrer(address owner) external view returns (address) {
        return _referrals[owner];
    }
    
    function getReferrals(address owner) external view returns (uint) {
        return _allReferrals[owner].length;
    }
    
    function _setReferrer(address owner, address refer) internal {
        require(_referrals[owner] == address(0) && owner != refer && refer != address(0), "[!] Invalid Referrer");
        _allReferrals[refer].push(owner);
        _referrals[owner] = refer;
    }
}