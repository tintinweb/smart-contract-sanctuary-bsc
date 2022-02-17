/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;



library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function sub0(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? 0 : sub(a, b);
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function mul18(uint256 a) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * (10 ** 18);
        require(c / a == 10 ** 18, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div18(uint256 a) internal pure returns (uint256) {
        return div(a, (10 ** 18), "SafeMath: division by zero");
    }
    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() public {
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


abstract contract Mutex {
    uint256 private _guard;
    uint256 private constant GUARD_PASS = 1;
    uint256 private constant GUARD_BLOCK = 2;

    constructor() public {
        _initGuard();
    }

    function guard() internal view returns (uint256) {
        return _guard;
    }

    function _initGuard() internal {
        _guard = GUARD_PASS;
    }

    modifier reGuard() {
        require(_guard == GUARD_PASS, "Mutex: reentrancy guarded");
        _guard = GUARD_BLOCK;
        _;
        _guard = GUARD_PASS;
    }

}


interface IContractProxiable {
    event ImplementationUpdated(address indexed _implementation);

    function updateImplementation(address _newImplementation) external;

    function getImplementation() external view returns (address);
}

abstract contract Proxiable is Ownable, Mutex, IERC165, IContractProxiable {
    bytes4 internal constant INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;
    bytes4 internal constant INTERFACE_SIGNATURE_ContractProxiable = 0xa8aa2dfe;

    bool public initialized = false;

    function _initialize() internal {
        require(!initialized, "Proxiable: contract already initialized");
        require(owner() == address(0x0), "Proxiable: logic implementation contract cannot be initialized");
        initialized = true;
        _initGuard();
        _transferOwnership(_msgSender());
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function initialize() external virtual {
        _initialize();
    }

    modifier inited() {
        require(initialized, "Proxiable: contract not initialized");
        _;
    }

    function _updateImplementation(address _newImplementation) internal {
        require(IERC165(_newImplementation).supportsInterface(0xa8aa2dfe), "Contract address not proxiable");

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, _newImplementation)
        }

        emit ImplementationUpdated(_newImplementation);
    }

    function updateImplementation(address _newImplementation) external virtual override onlyOwner {
        _updateImplementation(_newImplementation);
    }

    function getImplementation() external view virtual override returns (address _implementation) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            _implementation := sload(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7)
        }
    }

    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return _interfaceId == INTERFACE_SIGNATURE_ERC165 || _interfaceId == INTERFACE_SIGNATURE_ContractProxiable;
    }
}


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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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


interface IUpgradeableMiningBase {
    struct UserInfo {
        uint256 currentStaked;
        uint256 rewardDebt;
        uint256 rewardSettled;
        uint256 rewardWithdrawn;
        uint256 lastWithdrawTime;
    }

    struct PoolInfo {
        address stakeTokenAddr;
        address rewardTokenAddr;
        IERC20 stakeToken;
        IERC20 rewardToken;
        uint256 rewardPerBlock;
        uint256 lastRewardBlock;
        uint256 accRewardPerStake;
        uint256 currentStaked;
        uint256 rewardSettled;
        uint256 rewardWithdrawn;
        uint256 lockTime;
        uint256 lockNum;
        uint256 minRelease;
        address target;
        address receiver;
    }

    function setRewardPerBlock(uint256 _rewardPerBlock) external;

    function stake(uint256 _amount) external;

    function withdraw() external;

    function reinvestTarget() external;

    function withdrawTargetReward(uint256 _amount) external;

    function overview()
        external
        view
        returns (
            address _stakeToken,
            address _rewardToken,
            uint256 _rewardPerBlock,
            uint256 _currentStaked,
            uint256 _rewardTotal,
            uint256 _rewardWithdrawn
        );

    function getUserInfo(address _user)
        external
        view
        returns (
            uint256 _currentStaked,
            uint256 _currentPending,
            uint256 _rewardTotal,
            uint256 _rewardWithdrawable,
            uint256 _rewardWithdrawn
        );

    function getTargetReward() external view returns (uint256 _reward);

    event TokenStaked(
        uint256 indexed pool,
        address indexed _user,
        uint256 _amount,
        uint256 _prev,
        uint256 _currentReward,
        uint256 timestamp
    );

    event RewardWithdrawn(uint256 indexed pool, address indexed _user, uint256 _amount, uint256 _rewardLeft,uint256 timestamp);
}

abstract contract UpgradeableMiningBase is Proxiable, IUpgradeableMiningBase {
    using SafeMath for uint256;

    uint256 internal constant shareBase = 1e18;

    mapping(uint256 => PoolInfo) internal pools;
    mapping(address => UserInfo) internal users;
}


interface ITarget {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);
}

contract MiningWithToken is UpgradeableMiningBase {
    string public constant contractName = "MiningWithToken";
    string public constant contractVersion = "0.1";

    function getStakeContractBalance() public view returns (uint256 _stakeBalance) {
        return pools[0].stakeToken.balanceOf(address(this));
    }

    function getStakeTargetAmount() public view returns (uint256 _stakeBalance) {
        (_stakeBalance, ) = ITarget(pools[0].target).userInfo(0, address(this));
    }

    function getStakeTargetPending() public view returns (uint256 _stakeBalance) {
        return ITarget(pools[0].target).pendingCake(0, address(this));
    }

    function getStakeTotalBalance() public view returns (uint256 _stakeBalance) {
        return getStakeContractBalance().add(getStakeTargetAmount()).add(getStakeTargetPending());
    }

    modifier doReinvest() {
        ITarget(pools[0].target).leaveStaking(getStakeTargetAmount());
        _;
        ITarget(pools[0].target).enterStaking(getStakeContractBalance());
    }

    function initialize() external override {
        revert("Use initialize with params instead!!");
    }

    function initialize(
        address _stakeToken,
        address _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _lockTime,
        uint256 _lockNum,
        uint256 _minRelease,
        address _targetAddr,
        address _receiverAddr
    ) external {
        _initialize();
        pools[0].stakeTokenAddr = _stakeToken;
        pools[0].rewardTokenAddr = _rewardToken;
        pools[0].stakeToken = IERC20(_stakeToken);
        pools[0].rewardToken = IERC20(_rewardToken);
        pools[0].rewardPerBlock = _rewardPerBlock;
        pools[0].lastRewardBlock = block.number;
        pools[0].lockTime = _lockTime;
        pools[0].lockNum = _lockNum;
        pools[0].minRelease = _minRelease;
        pools[0].target = _targetAddr;
        pools[0].receiver = _receiverAddr;

        IERC20(_stakeToken).approve(_targetAddr, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function setRewardPerBlock(uint256 _rewardPerBlock) external override onlyOwner {
        pools[0].rewardPerBlock = _rewardPerBlock;
    }

    function updatePool() private {
        if (block.number > pools[0].lastRewardBlock) {
            uint256 newReward;
            if (pools[0].currentStaked > 0) {
                newReward = block.number.sub(pools[0].lastRewardBlock).mul(pools[0].rewardPerBlock);
                pools[0].accRewardPerStake = pools[0].accRewardPerStake.add(
                    newReward.mul(shareBase).div(pools[0].currentStaked)
                );
            }
            pools[0].rewardSettled = pools[0].rewardSettled.add(newReward);
            pools[0].lastRewardBlock = block.number;
        }
    }

    function stake(uint256 _amount) external override inited reGuard doReinvest {
        if (users[msg.sender].currentStaked > 0) {
            require(
                pools[0].stakeToken.transfer(msg.sender, users[msg.sender].currentStaked),
                "stake token transfer out failed!!"
            );
        }
        if (_amount > 0) {
            require(
                pools[0].stakeToken.transferFrom(msg.sender, address(this), _amount),
                "stake token transfer in failed!!"
            );
        }
        updatePool();
        uint256 newReward = users[msg.sender].currentStaked.mul(pools[0].accRewardPerStake).div(shareBase).sub(
            users[msg.sender].rewardDebt
        );
        users[msg.sender].rewardSettled = users[msg.sender].rewardSettled.add(newReward);
        if (users[msg.sender].rewardSettled <= 0) {
            users[msg.sender].lastWithdrawTime = block.timestamp;
        }
        pools[0].currentStaked = pools[0].currentStaked.sub(users[msg.sender].currentStaked);
        users[msg.sender].rewardDebt = _amount.mul(pools[0].accRewardPerStake).div(shareBase);
        uint256 prevAmount = users[msg.sender].currentStaked;
        users[msg.sender].currentStaked = _amount;
        pools[0].currentStaked = pools[0].currentStaked.add(_amount);

        emit TokenStaked(0, msg.sender, _amount, prevAmount, users[msg.sender].rewardSettled,block.timestamp);
    }

    function withdraw() external override inited reGuard doReinvest {
        require(users[msg.sender].lastWithdrawTime > 0, "cannot withdraw without staking!!");
        updatePool();
        uint256 newReward = users[msg.sender].currentStaked.mul(pools[0].accRewardPerStake).div(shareBase).sub(
            users[msg.sender].rewardDebt
        );
        users[msg.sender].rewardSettled = users[msg.sender].rewardSettled.add(newReward);
        users[msg.sender].rewardDebt = users[msg.sender].currentStaked.mul(pools[0].accRewardPerStake).div(shareBase);
        uint256 releaseNum = block.timestamp.sub(users[msg.sender].lastWithdrawTime).div(pools[0].lockTime);
        releaseNum = releaseNum > pools[0].lockNum ? pools[0].lockNum : releaseNum;
        uint256 released = users[msg.sender].rewardSettled.mul(releaseNum).div(pools[0].lockNum);
        released = released > 0 && released < pools[0].minRelease ? pools[0].minRelease : released;
        released = released > users[msg.sender].rewardSettled ? users[msg.sender].rewardSettled : released;
        require(pools[0].rewardToken.balanceOf(address(this)) >= released, "not enough reward token in pool!!");
        require(pools[0].rewardToken.transfer(msg.sender, released), "reward token transfer failed!!");
        users[msg.sender].rewardSettled = users[msg.sender].rewardSettled.sub(released);
        users[msg.sender].rewardWithdrawn = users[msg.sender].rewardWithdrawn.add(released);
        users[msg.sender].lastWithdrawTime = block.timestamp;
        pools[0].rewardSettled = pools[0].rewardSettled.sub(released);
        pools[0].rewardWithdrawn = pools[0].rewardWithdrawn.add(released);

        emit RewardWithdrawn(0, msg.sender, released, users[msg.sender].rewardSettled,block.timestamp);
    }

    function getUserReward(address _user) public view returns (uint256 _reward) {
        _reward = users[_user].rewardSettled;
        if (block.number > pools[0].lastRewardBlock && pools[0].currentStaked > 0) {
            uint256 poolNewReward = block.number.sub(pools[0].lastRewardBlock).mul(pools[0].rewardPerBlock);
            uint256 accRewardPerStake = pools[0].accRewardPerStake.add(
                poolNewReward.mul(shareBase).div(pools[0].currentStaked)
            );
            uint256 userNewReward = users[_user].currentStaked.mul(accRewardPerStake).div(shareBase).sub(
                users[_user].rewardDebt
            );
            _reward = _reward.add(userNewReward);
        }
    }

    function getPoolReward() public view returns (uint256 _reward) {
        _reward = pools[0].rewardSettled;
        if (block.number > pools[0].lastRewardBlock && pools[0].currentStaked > 0) {
            uint256 poolNewReward = block.number.sub(pools[0].lastRewardBlock).mul(pools[0].rewardPerBlock);
            _reward = _reward.add(poolNewReward);
        }
    }

    function getUserWithdrawable(address _user) public view returns (uint256 _withdrawable) {
        if (users[_user].lastWithdrawTime <= 0) {
            return 0;
        }

        uint256 reward = getUserReward(_user);
        uint256 releaseNum = block.timestamp.sub(users[_user].lastWithdrawTime).div(pools[0].lockTime);
        releaseNum = releaseNum > pools[0].lockNum ? pools[0].lockNum : releaseNum;
        uint256 released = reward.mul(releaseNum).div(pools[0].lockNum);
        released = released > 0 && released < pools[0].minRelease ? pools[0].minRelease : released;
        released = released > reward ? reward : released;
        return released;
    }

    function overview()
        external
        view
        override
        returns (
            address _stakeToken,
            address _rewardToken,
            uint256 _rewardPerBlock,
            uint256 _currentStaked,
            uint256 _rewardTotal,
            uint256 _rewardWithdrawn
        )
    {
        _stakeToken = pools[0].stakeTokenAddr;
        _rewardToken = pools[0].rewardTokenAddr;
        _rewardPerBlock = pools[0].rewardPerBlock;
        _currentStaked = pools[0].currentStaked;
        _rewardTotal = getPoolReward().add(pools[0].rewardWithdrawn);
        _rewardWithdrawn = pools[0].rewardWithdrawn;
    }

    function getUserInfo(address _user)
        external
        view
        override
        returns (
            uint256 _currentStaked,
            uint256 _currentPending,
            uint256 _rewardTotal,
            uint256 _rewardWithdrawable,
            uint256 _rewardWithdrawn
        )
    {
        _currentStaked = users[_user].currentStaked;
        _currentPending = getUserReward(_user);
        _rewardTotal = _currentPending.add(users[_user].rewardWithdrawn);
        _rewardWithdrawable = getUserWithdrawable(_user);
        _rewardWithdrawn = users[_user].rewardWithdrawn;
    }

    function reinvestTarget() external override onlyOwner doReinvest {}

    function getTargetReward() public view override returns (uint256 _reward) {
        return getStakeTotalBalance().sub(pools[0].currentStaked);
    }

    function withdrawTargetReward(uint256 _amount) external override onlyOwner doReinvest {
        require(getTargetReward() >= _amount, "Not enough target reward to withdraw!!");
        if (_amount <= 0) {
            _amount = getTargetReward();
        }
        require(pools[0].stakeToken.transfer(pools[0].receiver, _amount), "Target reward transfer failed!!");
    }
}