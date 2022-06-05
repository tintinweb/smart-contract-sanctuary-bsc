// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./libraries/Ownable.sol";
import "./libraries/IBEP20.sol";

contract TestabdexChefMaster is Ownable {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 boostMultiplier;
    }

    struct PoolInfo {
        uint256 accCakePerShare;
        uint256 lastRewardBlock;
        uint256 allocPoint;
        uint256 totalBoostedShare;
        bool isRegular;
    }

    struct CakePhase {
        uint256 cakePerBlock;
        uint256 startBlock;
        uint256 bonusEndBlock;
    }

    IBEP20 public CAKE;
    address public boostContract;
    CakePhase[] public cakePhase;
    PoolInfo[] public poolInfo;
    IBEP20[] public lpToken;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => bool) public whiteList;

    uint256 public totalRegularAllocPoint;
    uint256 public totalSpecialAllocPoint;
    uint256 public constant ACC_CAKE_PRECISION = 1e18;
    uint256 public constant BOOST_PRECISION = 100 * 1e10;
    uint256 public constant MAX_BOOST_PRECISION = 200 * 1e10;
    uint256 public constant CAKE_RATE_TOTAL_PRECISION = 1e12;
    uint256 public cakeRateToRegularFarm = 1e12;
    uint256 public cakeRateToSpecialFarm = 0;

    event AddPool(uint256 indexed pid, uint256 allocPoint, IBEP20 indexed lpToken, bool isRegular);
    event SetPool(uint256 indexed pid, uint256 allocPoint);
    event UpdatePool(uint256 indexed pid, uint256 lastRewardBlock, uint256 lpSupply, uint256 accCakePerShare);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event NewCakePhase(uint256 cakePerBlock, uint256 startBlock, uint256 bonusEndBlock, bool voted);
    event UpdateCakeRate(uint256 regularFarmRate, uint256 specialFarmRate);
    event UpdateWhiteList(address indexed user, bool isValid);
    event UpdateBoostContract(address indexed boostContract);
    event UpdateBoostMultiplier(address indexed user, uint256 pid, uint256 oldMultiplier, uint256 newMultiplier);


    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'TestabdexChefFactory: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
    modifier onlyBoostContract() {
        require(boostContract == msg.sender, "Ownable: caller is not the boost contract");
        _;
    }

    constructor(IBEP20 _cake) {
        CAKE = _cake;
    }

    function poolLength() public view returns (uint256 pools) {
        pools = poolInfo.length;
    }

    function phaseLength() public view returns (uint256 phases) {
        phases = cakePhase.length;
    }

    function stakedAmount(uint256 pid) public view returns (uint256 amount) {
        require(pid < poolInfo.length, 'PID_NOT_EXSITS');
        amount = poolInfo[pid].totalBoostedShare;
    }

    function add(
        uint256 _allocPoint,
        IBEP20 _lpToken,
        bool _isRegular,
        bool _withUpdate
    ) external onlyOwner {
        require(_lpToken.balanceOf(address(this)) >= 0, "None BEP20 tokens");
        require(_lpToken != CAKE, "CAKE token can't be added to farm pools");

        if (_withUpdate) {
            massUpdatePools();
        }

        if (_isRegular) {
            totalRegularAllocPoint = totalRegularAllocPoint + _allocPoint;
        } else {
            totalSpecialAllocPoint = totalSpecialAllocPoint + _allocPoint;
        }
        lpToken.push(_lpToken);

        poolInfo.push(
            PoolInfo({
            allocPoint: _allocPoint,
            lastRewardBlock: block.number,
            accCakePerShare: 0,
            isRegular: _isRegular,
            totalBoostedShare: 0
        }));
        emit AddPool(lpToken.length - 1, _allocPoint, _lpToken, _isRegular);
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external onlyOwner {
        updatePool(_pid);

        if (_withUpdate) {
            massUpdatePools();
        }

        if (poolInfo[_pid].isRegular) {
            totalRegularAllocPoint = totalRegularAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        } else {
            totalSpecialAllocPoint = totalSpecialAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        }
        poolInfo[_pid].allocPoint = _allocPoint;
        emit SetPool(_pid, _allocPoint);
    }

    function addCakePhase(uint256 _cakePerBlock, uint256 _startBlock, uint256 _bonusEndBlock, bool _voted) external lock onlyOwner {
        require(_cakePerBlock > 0, 'NONE_CAKEPERBLOCK');
        require(_startBlock < _bonusEndBlock, 'BONUSENDBLOCK_MUST_GREATER_THAN_START');
        if (_voted) {
            for (uint256 pid = 0; pid < cakePhase.length; ++pid) {
                if (_startBlock > cakePhase[pid].startBlock && _startBlock <= cakePhase[pid].bonusEndBlock) {
                    cakePhase[pid].bonusEndBlock = _startBlock;
                    trimpCakePhase(pid);
                    break;
                }          
            }
        }
        CakePhase memory newPhase = CakePhase({ 
            cakePerBlock: _cakePerBlock,
            startBlock: _startBlock,
            bonusEndBlock: _bonusEndBlock
        });
        cakePhase.push(newPhase);
        emit NewCakePhase(_cakePerBlock, _startBlock, _bonusEndBlock, _voted);
    }

    function trimpCakePhase(uint256 end) internal {
        for (uint256 pid = cakePhase.length -1; pid > end; --pid) {
            cakePhase.pop();
        }
    }

    function pendingReward(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 accCakePerShare = pool.accCakePerShare;
        uint256 lpSupply = pool.totalBoostedShare;

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = block.number - pool.lastRewardBlock;

            uint256 cakeReward = multiplier * cakePerBlock(_pid) * pool.allocPoint /
                (pool.isRegular ? totalRegularAllocPoint : totalSpecialAllocPoint);
            accCakePerShare = accCakePerShare + (cakeReward * ACC_CAKE_PRECISION / lpSupply);
        }
        uint256 boostedAmount = user.amount * getBoostMultiplier(_user, _pid) / BOOST_PRECISION;
        return boostedAmount * accCakePerShare / ACC_CAKE_PRECISION - user.rewardDebt;
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo memory pool = poolInfo[pid];
            if (pool.allocPoint != 0) {
                updatePool(pid);
            }
        }
    }

    function cakePerBlock(uint256 _pid) public view returns (uint256 amount) {
        PoolInfo memory pool = poolInfo[_pid];
        uint256 length = cakePhase.length;
        uint256 cakeReward = 0;
        for (uint256 pid = 0; pid < length; pid++) {
            CakePhase memory phase = cakePhase[pid];
            uint256 _startBlock = pool.lastRewardBlock > phase.startBlock ? pool.lastRewardBlock : phase.startBlock;
            uint256 _endBlock = block.number <= phase.bonusEndBlock ? block.number : phase.bonusEndBlock;
            if (_endBlock > _startBlock) {
                cakeReward += phase.cakePerBlock * (_endBlock - _startBlock);
            }             
        }
        amount = cakeReward / (block.number - pool.lastRewardBlock);
        if (pool.isRegular) {
            amount = amount * cakeRateToRegularFarm / CAKE_RATE_TOTAL_PRECISION;
        } else {
            amount = amount * cakeRateToSpecialFarm / CAKE_RATE_TOTAL_PRECISION;
        }
    }

    function updatePool(uint256 _pid) public returns (PoolInfo memory pool) {
        pool = poolInfo[_pid];
        if (block.number > pool.lastRewardBlock) {
            uint256 lpSupply = pool.totalBoostedShare;
            uint256 totalAllocPoint = (pool.isRegular ? totalRegularAllocPoint : totalSpecialAllocPoint);

            if (lpSupply > 0 && totalAllocPoint > 0) {
                uint256 multiplier = block.number - pool.lastRewardBlock;
                uint256 cakeReward = multiplier * cakePerBlock(_pid) * pool.allocPoint / totalAllocPoint;
                pool.accCakePerShare = pool.accCakePerShare + (cakeReward * ACC_CAKE_PRECISION / lpSupply);
            }
            pool.lastRewardBlock = block.number;
            poolInfo[_pid] = pool;
            emit UpdatePool(_pid, pool.lastRewardBlock, lpSupply, pool.accCakePerShare);
        }
    }

    function deposit(uint256 _pid, uint256 _amount) external lock {
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(
            pool.isRegular || whiteList[msg.sender],
            "TestabdexChefMaster: The address is not available to deposit in this pool"
        );

        uint256 multiplier = getBoostMultiplier(msg.sender, _pid);

        if (user.amount > 0) {
            settlePendingCake(msg.sender, _pid, multiplier);
        }

        if (_amount > 0) {
            uint256 before = lpToken[_pid].balanceOf(address(this));
            _safeTransferFrom(address(lpToken[_pid]), msg.sender, address(this), _amount);
            _amount = lpToken[_pid].balanceOf(address(this)) - before;
            user.amount = user.amount + _amount;

            pool.totalBoostedShare = pool.totalBoostedShare + (_amount * multiplier / BOOST_PRECISION);
        }

        user.rewardDebt = (user.amount * multiplier / BOOST_PRECISION) * pool.accCakePerShare / ACC_CAKE_PRECISION;
        poolInfo[_pid] = pool;

        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external lock {
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.amount >= _amount, "withdraw: Insufficient");

        uint256 multiplier = getBoostMultiplier(msg.sender, _pid);

        settlePendingCake(msg.sender, _pid, multiplier);

        if (_amount > 0) {
            user.amount = user.amount - _amount;
            _safeTransfer(address(lpToken[_pid]), msg.sender, _amount);

            pool.totalBoostedShare = pool.totalBoostedShare - (_amount * multiplier / BOOST_PRECISION);
        }

        user.rewardDebt = (user.amount * multiplier / BOOST_PRECISION) * pool.accCakePerShare / ACC_CAKE_PRECISION;
        poolInfo[_pid] = pool;

        emit Withdraw(msg.sender, _pid, _amount);
    }


    function emergencyWithdraw(uint256 _pid) external lock {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        uint256 boostedAmount = amount * getBoostMultiplier(msg.sender, _pid) / BOOST_PRECISION;
        pool.totalBoostedShare = pool.totalBoostedShare > boostedAmount ? pool.totalBoostedShare - boostedAmount : 0;
        
        _safeTransfer(address(lpToken[_pid]), msg.sender, amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function updateWhiteList(address _user, bool _isValid) external onlyOwner {
        require(_user != address(0), "TestabdexChefMaster: The white list address must be valid");

        whiteList[_user] = _isValid;
        emit UpdateWhiteList(_user, _isValid);
    }

    function updateCakeRate(
        uint256 _regularFarmRate,
        uint256 _specialFarmRate,
        bool _withUpdate
    ) external onlyOwner {
        require(_regularFarmRate + _specialFarmRate == CAKE_RATE_TOTAL_PRECISION,
            "TestabdexChefMaster: Total rate must be 1e12"
        );
        if (_withUpdate) {
            massUpdatePools();
        }
        cakeRateToRegularFarm = _regularFarmRate;
        cakeRateToSpecialFarm = _specialFarmRate;
        emit UpdateCakeRate(_regularFarmRate, _specialFarmRate);
    }

    function updateBoostContract(address _newBoostContract) external onlyOwner {
        require(
            _newBoostContract != address(0) && _newBoostContract != boostContract,
            "TestabdexChefMaster: New boost contract address must be valid"
        );

        boostContract = _newBoostContract;
        emit UpdateBoostContract(_newBoostContract);
    }

    function updateBoostMultiplier(
        address _user,
        uint256 _pid,
        uint256 _newMultiplier
    ) external onlyBoostContract lock {
        require(_user != address(0), "TestabdexChefMaster: The user address must be valid");
        require(poolInfo[_pid].isRegular, "TestabdexChefMaster: Only regular farm could be boosted");
        require(
            _newMultiplier >= BOOST_PRECISION && _newMultiplier <= MAX_BOOST_PRECISION,
            "TestabdexChefMaster: Invalid new boost multiplier"
        );

        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][_user];

        uint256 prevMultiplier = getBoostMultiplier(_user, _pid);
        settlePendingCake(_user, _pid, prevMultiplier);

        user.rewardDebt = (user.amount * _newMultiplier / BOOST_PRECISION) * pool.accCakePerShare / ACC_CAKE_PRECISION;
        pool.totalBoostedShare = pool.totalBoostedShare - (user.amount * prevMultiplier / BOOST_PRECISION) + (
            user.amount * _newMultiplier / BOOST_PRECISION
        );
        poolInfo[_pid] = pool;
        userInfo[_pid][_user].boostMultiplier = _newMultiplier;

        emit UpdateBoostMultiplier(_user, _pid, prevMultiplier, _newMultiplier);
    }

    function getBoostMultiplier(address _user, uint256 _pid) public view returns (uint256) {
        uint256 multiplier = userInfo[_pid][_user].boostMultiplier;
        return multiplier > BOOST_PRECISION ? multiplier : BOOST_PRECISION;
    }

    function settlePendingCake(
        address _user,
        uint256 _pid,
        uint256 _boostMultiplier
    ) internal {
        UserInfo memory user = userInfo[_pid][_user];

        uint256 boostedAmount = user.amount * _boostMultiplier / BOOST_PRECISION;
        uint256 accCake = boostedAmount * poolInfo[_pid].accCakePerShare / ACC_CAKE_PRECISION;
        uint256 pending = accCake - user.rewardDebt;
        if (pending > 0) {
            require(CAKE.balanceOf(address(this)) >= pending, 'INSUFFICIENT_REWARDS');
            _safeTransfer(address(CAKE), _user, pending);
        }  
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'safeTransfer: transfer failed'
        );
    }

    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'transferFrom: transferFrom failed'
        );
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