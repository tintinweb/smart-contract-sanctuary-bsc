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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

pragma solidity ^0.8.11;

contract Staking360 is Ownable {
    IERC20 public TKN;
    address private feeAddress;

    uint256[] public periods;
    uint16[] public rates;
    uint16 public constant FEE_RATE = 40;
    uint256[] public rewardsPool;
    uint256[] public rewardsPoolMax;
    uint256 public MAX_STAKES = 100;

    struct Stake {
        uint8 class;
        uint256 initialAmount;
        uint256 finalAmount;
        uint256 timestamp;
        bool unstaked;
    }

    struct LeaderboardItem {
        address user;
        uint256 totalStaked;
    }

    Stake[] public stakes;
    LeaderboardItem[] public leaderboards;

    mapping(address => uint256[]) public stakesOf;
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public leaderboardsUser;

    event Staked(
        address indexed sender,
        uint8 indexed class,
        uint256 amount,
        uint256 finalAmount
    );
    event Unstaked(address indexed sender, uint8 indexed class, uint256 amount);
    event IncreaseRewardsPool(address indexed adder, uint256 added);

    constructor(IERC20 _TKN, address _feeAddress) {
        TKN = _TKN;
        feeAddress = _feeAddress;
    }

    function stakesInfo(uint256 _from, uint256 _to)
        public
        view
        returns (Stake[] memory s)
    {
        s = new Stake[](_to - _from);
        for (uint256 i = _from; i < _to; i++) s[i - _from] = stakes[i];
    }

    function stakesInfoAll() public view returns (Stake[] memory s) {
        uint256 stakeLength = stakes.length;
        s = new Stake[](stakeLength);
        for (uint256 i = 0; i < stakeLength; i++) s[i] = stakes[i];
    }

    function stakesLength() public view returns (uint256) {
        return stakes.length;
    }

    function myStakes(address _me)
        public
        view
        returns (Stake[] memory s, uint256[] memory indexes)
    {
        uint256 stakeLength = stakesOf[_me].length;
        s = new Stake[](stakeLength);
        indexes = new uint256[](stakeLength);
        for (uint256 i = 0; i < stakeLength; i++) {
            indexes[i] = stakesOf[_me][i];
            s[i] = stakes[indexes[i]];
        }
    }

    function myActiveStakesCount(address _me) public view returns (uint256 l) {
        uint256[] storage _s = stakesOf[_me];
        uint256 stakeLength = _s.length;
        for (uint256 i = 0; i < stakeLength; i++) if (!stakes[_s[i]].unstaked) l++;
    }

    function stake(uint8 _class, uint256 _amount) public {
        require(_class < 2, 'Wrong class');
        require(_amount > 0, 'Cannot Stake 0 Tokens');
        require(myActiveStakesCount(msg.sender) < MAX_STAKES, 'MAX_STAKES overflow');
        uint256 _finalAmount = _amount + (_amount * rates[_class]) / 10000;
        require(
            rewardsPool[_class] >= _finalAmount - _amount,
            'Rewards pool is empty for now'
        );
        rewardsPool[_class] -= _finalAmount - _amount;
        TKN.transferFrom(msg.sender, address(this), _amount);
        uint256 _index = stakes.length;
        stakesOf[msg.sender].push(_index);
        stakes.push(
            Stake({
                class: _class,
                initialAmount: _amount,
                finalAmount: _finalAmount,
                timestamp: block.timestamp,
                unstaked: false
            })
        );
        ownerOf[_index] = msg.sender;
        if (_class == 1) {
            if (leaderboardsUser[msg.sender] == 0) {
                leaderboards.push(LeaderboardItem({user: msg.sender, totalStaked: 0}));
                leaderboardsUser[msg.sender] = leaderboards.length - 1;
            }
            leaderboards[leaderboardsUser[msg.sender]].totalStaked += _amount;
        }
        emit Staked(msg.sender, _class, _amount, _finalAmount);
    }

    function unstake(uint256 _index) public {
        require(msg.sender == ownerOf[_index], 'Not correct index');
        Stake storage _s = stakes[_index];
        require(!_s.unstaked, 'Already unstaked');
        require(
            block.timestamp >= _s.timestamp + periods[_s.class],
            'Staking period not finished'
        );
        uint256 _reward = (_s.initialAmount * rates[_s.class]) / 10000;
        uint256 total = _s.initialAmount + _reward;
        uint256 _fee = (_reward * FEE_RATE) / 1000;
        total -= _fee;
        TKN.transfer(feeAddress, _fee);
        TKN.transfer(msg.sender, total);
        _s.unstaked = true;
        if (_s.class == 1) {
            leaderboards[leaderboardsUser[msg.sender]].totalStaked -= _s.initialAmount;
        }
        emit Unstaked(msg.sender, _s.class, _s.finalAmount);
    }

    function returnAccidentallySent(IERC20 _TKN) public onlyOwner {
        require(address(_TKN) != address(TKN), 'Unable to withdraw staking token');
        uint256 _amount = _TKN.balanceOf(address(this));
        _TKN.transfer(msg.sender, _amount);
    }

    function increaseRewardsPool(uint256[] memory _amount) public onlyOwner {
        require(_amount.length == rates.length, 'increaseRewardsPool: _amount length should be the same as rates length');
        uint256 amountLength = _amount.length;
        uint256 summary = 0;
        for (uint256 i = 0; i < amountLength; i++) {
            rewardsPoolMax[i] += _amount[i];
            rewardsPool[i] += _amount[i];
            summary += _amount[i];
        }
        TKN.transferFrom(msg.sender, address(this), summary);
        emit IncreaseRewardsPool(msg.sender, summary);
    }

    function withdrawRewardFromPool(uint256 _class, uint256 _amount) public onlyOwner {
        require(_class < periods.length, 'withdrawRewardFromPool: wrong class');
        require(rewardsPool[_class] >= _amount, 'withdrawRewardFromPool: not enough reward on reward pool');
        TKN.transfer(msg.sender, _amount);
        rewardsPool[_class] -= _amount;
    }

    function updateMax(uint256 _max) external onlyOwner {
        MAX_STAKES = _max;
    }

    function changeFeeAddress(address newFeeAddress) external onlyOwner {
        require(newFeeAddress != address(0), 'Zero address');
        feeAddress = newFeeAddress;
    }

    function getLeaderboards() public view returns (LeaderboardItem[] memory) {
        return leaderboards;
    }

    function addPeriods(uint256[] memory _periods, uint16[] memory _rates) public onlyOwner {
        require(
            _periods.length == _rates.length,
            'addPeriods: arrays not the same length'
        );
        uint256 len = _periods.length;
        for (uint256 i = 0; i < len; i++) {
            addPeriod(_periods[i], _rates[i]);
        }
    }

    function addPeriod(uint256 _period, uint16 _rate) public onlyOwner {
        require(_period > 0, 'addPeriod: period should be > 0');
        require(_rate > 0, 'addPeriod: rate should be > 0');
        periods.push(_period);
        rates.push(_rate);
    }

    function changeRate(uint256 _class, uint16 _rate) public onlyOwner {
        rates[_class] = _rate;
    }

    struct StakingInfo {
        uint256[] periods;
        uint16[] rates;
        uint256 feeRate;
        uint256[] rewardsPool;
        uint256[] rewardsPoolMax;
        uint256 maxStakes;
    }

    function getStakingInfo() public view returns (StakingInfo memory) {
        return
            StakingInfo({
                periods: periods,
                rates: rates,
                feeRate: FEE_RATE,
                rewardsPool: rewardsPool,
                rewardsPoolMax: rewardsPoolMax,
                maxStakes: MAX_STAKES
            });
    }
}