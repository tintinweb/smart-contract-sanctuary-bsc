// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./libraries/Ownable.sol";
import "./libraries/IBEP20.sol";
import "./libraries/TransferHelper.sol";
import "./ITestabdexPair.sol";

contract TestabdexMasterChef is Ownable {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IBEP20 lpToken;
        uint256 lpSupply;
        uint256 lastRewardBlock;
        uint256 pointsPerShare; 
        uint256 rewardPerBlock;
        uint256 accCakePerShare;
        bool isPair;
    }

    PoolInfo[] public poolInfo;
    mapping(address => uint256) public lpPoolID;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    address public CHEF_FACTORY;
    bool public isInitialized;

    string public name;
    IBEP20 public rewardToken;
    IBEP20 public weightsToken;
    uint256 public PRECISION_FACTOR;
    uint256 public WEIGHTS_PRECISION_FACTOR;
    uint256 public totalPoints;
    uint256 public rewardPerBlock;
    uint256 public startBlock; 
    uint256 public bonusEndBlock;
    uint256 public lastRewardBlock;
    uint256 internal poolLength;

    event AddPool(uint256 indexed pid, IBEP20 indexed lpToken);
    event UpdatePool(uint256 indexed pid, uint256 lastRewardBlock, uint256 lpSupply, uint256 accCakePerShare);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardsStop(uint256 blockNumber);
    event NewRewardPerBlock(uint256 rewardPerBlock, uint256 startBlock);

    constructor() {
        CHEF_FACTORY = msg.sender;
    }

    function initialize(
        IBEP20 _rewardToken,
        IBEP20 _weightsToken,
        string calldata _name,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        address _admin
    ) external {
        require(!isInitialized, "Already initialized");
        require(msg.sender == CHEF_FACTORY, "Not factory");
        require(IBEP20(_rewardToken).balanceOf(address(this)) >= 0, "None BEP20 tokens");
        require(IBEP20(_weightsToken).balanceOf(address(this)) >= 0, "None BEP20 tokens");
        require(bytes(_name).length > 0, "None Name");
        name = _name;
        rewardToken = _rewardToken;
        weightsToken = _weightsToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;

        uint256 decimalsRewardToken = uint256(IBEP20(rewardToken).decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(30 - decimalsRewardToken));

        uint256 decimalsWeihtsToken = uint256(IBEP20(weightsToken).decimals());
        require(decimalsWeihtsToken < 30, "Must be inferior to 30");
        WEIGHTS_PRECISION_FACTOR = uint256(10**(30 - decimalsWeihtsToken));

        lastRewardBlock = _startBlock;
        transferOwnership(_admin);

        isInitialized = true;

        emit NewRewardPerBlock(rewardPerBlock, lastRewardBlock);
    }

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'TestabdexChef: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getPoolLength() public view returns (uint256 pools) {
        pools = poolLength;
    }

    function stakedAmount(uint256 pid) public view returns (uint256 amount) {
        require(pid < poolLength, 'PID_NOT_EXSITS');
        PoolInfo memory _info = poolInfo[pid];
        amount = _info.lpSupply;
    }

    function addPool(
        address _lpToken,
        bool _isPair
    ) external lock {
        require(msg.sender == CHEF_FACTORY, "Not factory");
        require(IBEP20(_lpToken).balanceOf(address(this)) >= 0, "None BEP20 tokens");

        uint256 pointsPerShare = 0;
        if (_isPair) {
            ITestabdexPair _pair = ITestabdexPair(_lpToken);
            uint256 _totalSupply = _pair.totalSupply();
            (address _token0, address _token1, uint112 _reserveA, uint112 _reserveB) = _pair.getTokenPool(); 
            require(IBEP20(_token0) == weightsToken || IBEP20(_token1) == weightsToken, 'CANOT_ADD_INTO_POOL');
            uint256 points = (IBEP20(_token0) == weightsToken) ? (uint256(_reserveA) * WEIGHTS_PRECISION_FACTOR / _totalSupply) : (uint256(_reserveB) * WEIGHTS_PRECISION_FACTOR / _totalSupply);
            pointsPerShare = points;
        } else {
            require(IBEP20(_lpToken) == weightsToken, 'CANOT_ADD_INTO_POOL');
            pointsPerShare = 1;
        }

        PoolInfo memory _info = PoolInfo({
            lpToken: IBEP20(_lpToken),
            lpSupply: 0,
            lastRewardBlock: block.number,
            rewardPerBlock: 0,
            pointsPerShare: pointsPerShare,
            accCakePerShare: 0,
            isPair: _isPair
        });
    
        lpPoolID[_lpToken] = poolLength;
        poolInfo.push(_info);
        poolLength ++; 
        
        emit AddPool(poolLength-1, IBEP20(_lpToken));
    }

    function updateRewardPerBlock(uint256 _rewardPerBlock) external lock onlyOwner {
        require(block.number <= bonusEndBlock, 'REWARDS_ENDED');
        massUpdatePools();
        rewardPerBlock = _rewardPerBlock;
        emit NewRewardPerBlock(_rewardPerBlock, block.number);
    }

    function pendingReward(uint256 _pid, address _user) external view returns (uint256) {
        require(_pid < poolLength, 'PID_NOT_EXSITS');
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 accCakePerShare = pool.accCakePerShare;

        if (block.number > pool.lastRewardBlock && pool.lpSupply != 0) {
            uint256 multiplier = _getMultiplier(pool.lastRewardBlock, block.number);
            uint256 cakeReward = multiplier * pool.rewardPerBlock;
            uint256 adjustedTokenPerShare = accCakePerShare + (cakeReward * PRECISION_FACTOR / pool.lpSupply);
            return user.amount * adjustedTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        }
        return user.amount * accCakePerShare / PRECISION_FACTOR - user.rewardDebt;
    }

    function massUpdatePools() public {
        if (block.number <= lastRewardBlock) { return; }
        lastRewardBlock = block.number;
        uint256 _totalPoints = 0;
        for (uint256 pid = 0; pid < poolLength; pid++) { 
            PoolInfo memory pool = updatePool(pid);
            _totalPoints += pool.pointsPerShare * pool.lpSupply / WEIGHTS_PRECISION_FACTOR;
        }
        if ( _totalPoints == totalPoints ) { return; }
        totalPoints = _totalPoints;
        for (uint256 pid = 0; pid < poolLength; pid++) { 
            PoolInfo memory pool = updatePool(pid);
            uint256 _rewardPerBlock = rewardPerBlock * pool.pointsPerShare * pool.lpSupply / (totalPoints * WEIGHTS_PRECISION_FACTOR);  
            if (pool.rewardPerBlock != _rewardPerBlock) { 
                pool.rewardPerBlock = _rewardPerBlock;
                poolInfo[pid] = pool;
            }
        }
    }

    function _getMultiplier(uint256 _from, uint256 _to) internal view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to - _from;
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock - _from;
        }
    }

    function updatePool(uint256 _pid) public returns (PoolInfo memory pool) {
        pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) { return pool; }
        if (pool.lpSupply > 0) {
            uint256 multiplier = _getMultiplier(pool.lastRewardBlock, block.number);
            uint256 cakeReward = multiplier * pool.rewardPerBlock;
            pool.accCakePerShare = pool.accCakePerShare + (cakeReward * PRECISION_FACTOR / pool.lpSupply);
        }
        pool.lastRewardBlock = block.number;
        poolInfo[_pid] = pool;
        emit UpdatePool(_pid, pool.lastRewardBlock, pool.lpSupply, pool.accCakePerShare);
    }

    function deposit(uint256 _pid, uint256 _amount) external lock {
        require(_pid < poolLength, 'PID_NOT_EXSITS');
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];
        settlePendingReward(msg.sender, _pid);
        if (_amount > 0) {           
            uint256 before = pool.lpToken.balanceOf(address(this));
            TransferHelper.safeTransferFrom(address(pool.lpToken), msg.sender, address(this), _amount);
            _amount = pool.lpToken.balanceOf(address(this)) - before;
            user.amount += _amount;  
            pool.lpSupply += _amount;       
        }
        user.rewardDebt = user.amount * pool.accCakePerShare / PRECISION_FACTOR;
        poolInfo[_pid] = pool;
        massUpdatePools();
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external lock {
        require(_pid < poolLength, 'PID_NOT_EXSITS');
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: Insufficient");
        settlePendingReward(msg.sender, _pid);
        if (_amount > 0) {
            user.amount -= _amount;
            pool.lpSupply -= _amount; 
            TransferHelper.safeTransfer(address(pool.lpToken), msg.sender, _amount);
        }
        user.rewardDebt = user.amount * pool.accCakePerShare / PRECISION_FACTOR;
        poolInfo[_pid] = pool;
        massUpdatePools();
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) external lock {
        require(_pid < poolLength, 'PID_NOT_EXSITS');
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 amount = user.amount;   
        if (amount > 0) {
            user.amount = 0;
            user.rewardDebt = 0; 
            pool.lpSupply -= amount;
            TransferHelper.safeTransfer(address(pool.lpToken), msg.sender, amount);
            poolInfo[_pid] = pool;
            massUpdatePools();
        }
    
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        TransferHelper.safeTransfer(address(rewardToken), msg.sender, _amount);
    }

    function settlePendingReward(
        address _user,
        uint256 _pid
    ) internal {
        require(_pid < poolLength, 'PID_NOT_EXSITS');
        UserInfo memory user = userInfo[_pid][_user];
        PoolInfo memory pool = updatePool(_pid);
        uint256 pending = user.amount * pool.accCakePerShare / PRECISION_FACTOR - user.rewardDebt;
        if (pending > 0) {
            require(rewardToken.balanceOf(address(this)) >= pending, 'INSUFFICIENT_BALANCE');
            TransferHelper.safeTransfer(address(rewardToken), _user, pending);
        }  
    }

    function stopReward() external onlyOwner {
        if (block.number <= bonusEndBlock) {
            bonusEndBlock = block.number;
            emit RewardsStop(bonusEndBlock);
        }  
    }

    function updateLPWeights(address lp, address tokenA, address tokenB, uint256 , uint256 ) external lock {
        require(msg.sender == CHEF_FACTORY, "Not factory");
        if (tokenA != address(weightsToken) && tokenB != address(weightsToken)) { return; }
        uint256 points = calculatePointPerShare(ITestabdexPair(lp));
        uint256 pid = lpPoolID[lp];
        PoolInfo memory pool = poolInfo[pid];
        pool.pointsPerShare = points;
        poolInfo[pid] = pool;
        massUpdatePools();
    } 

    function calculatePointPerShare(ITestabdexPair pair) internal view returns (uint256 points) {
        uint256 _totalSupply = pair.totalSupply();
        (address _token0, address _token1, uint112 _reserveA, uint112 _reserveB) = pair.getTokenPool(); 
        require(IBEP20(_token0) == weightsToken || IBEP20(_token1) == weightsToken, 'CANOT_ADD_INTO_POOL');
        points = (IBEP20(_token0) == weightsToken) ? (uint256(_reserveA) * WEIGHTS_PRECISION_FACTOR / _totalSupply) : (uint256(_reserveB) * WEIGHTS_PRECISION_FACTOR / _totalSupply);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface ITestabdexPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event LimitSwap(address indexed token, uint32 startTime, uint32 endTime, uint256 userAmount, uint256 totalAmount);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function getTokenPool() external view returns (address _token0, address _token1, uint112 reserve0, uint112 reserve1);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(
        address tokenA,
        address tokenB,
        address burnToken,
        uint256 burnTokenSupplyLimit,
        uint32[3] calldata burnTokenParams
    ) external;

    function getSwapFee()
        external
        view
        returns (
            uint112 swapFee0,
            uint112 swapFee1,
            uint32 blockTimestampLast
        );

    function getBurnToken() external view returns (address token, uint256 supplyLimit, uint32 burnShare, uint32 feeShare, uint32 poolShare); 

    function setBurnToken(address token, uint256 supplyLimit, uint32 burnShare, uint32 feeShare, uint32 poolShare) external;

    function setSwapLimit(
        address token,
        uint32 startTimeStamp,
        uint32 endTimeStamp,
        uint256 userAmountLimit,
        uint256 totalAmountLimit
    ) external;

    function getSwapLimit() external view returns (address token, uint32 startTimeStamp, uint32 endTimeStamp, uint256 userAmountLimit, uint256 totalAmountLimit); 

    function getUserLimitedSwapAmounts(address from) external view returns (uint256 amount);

    function setAdmin(address admin) external;

}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
   * @dev Returns the token name.
   */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

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