// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract FixedStaking is Ownable {
    IERC20 public fitToken;

    uint256[5] public periods = [30 days, 60 days, 90 days, 180 days, 365 days];
    uint256[5] public rates = [110, 120, 125, 140, 160];
    uint256[5] public rewardsPool;
    uint256 public MAX_STAKES = 100;

    struct Stake {
        uint8 class;
        uint256 initialAmount;
        uint256 finalAmount;
        uint256 timestamp;
        bool unstaked;
    }

    Stake[] public stakes;
    mapping(address => uint256[]) public stakesOf;
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public totalStaked;

    event Staked(address indexed sender, uint8 indexed class, uint256 indexed amount, uint256 finalAmount);
    event Unstaked(address indexed sender, uint8 indexed class, uint256 indexed amount);
    event IncreaseRewardsPool(address indexed adder, uint256 indexed added);
    event IncreaseRewardPoolForClass(address indexed adder, uint256 indexed added, uint8 indexed class);

    constructor(IERC20 _fitToken) {
        fitToken = _fitToken;
    }

    function stakesInfo(uint256 _from, uint256 _to) public view returns (Stake[] memory s) {
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

    function myStakes(address _me) public view returns (Stake[] memory s, uint256[] memory indexes) {
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
        require(_class < 5, 'Wrong class');
        require(_amount > 0, 'Cannot Stake 0 Tokens');
        require(myActiveStakesCount(msg.sender) < MAX_STAKES, 'MAX_STAKES overflow');
        uint256 _finalAmount = _amount + ((_amount * rates[_class] / 100) - _amount) * periods[_class] / 365 days;
        require(rewardsPool[_class] >= _finalAmount - _amount, 'Rewards pool is empty for now');
        rewardsPool[_class] -= _finalAmount - _amount;
        fitToken.transferFrom(msg.sender, address(this), _amount);
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
        totalStaked[msg.sender] += _amount;
        emit Staked(msg.sender, _class, _amount, _finalAmount);
    }

    function unstake(uint256 _index) public {
        require(msg.sender == ownerOf[_index], 'Not correct index');
        Stake storage _s = stakes[_index];
        require(!_s.unstaked, 'Already unstaked');
        require(block.timestamp >= _s.timestamp + periods[_s.class], 'Staking period not finished');
        fitToken.transfer(msg.sender, _s.finalAmount);
        _s.unstaked = true;
        totalStaked[msg.sender] -= _s.initialAmount;
        emit Unstaked(msg.sender, _s.class, _s.finalAmount);
    }

    function returnAccidentallySent(IERC20 _token) public onlyOwner {
        require(address(_token) != address(fitToken), 'Unable to withdraw staking token');
        uint256 _amount = _token.balanceOf(address(this));
        _token.transfer(msg.sender, _amount);
    }

    function increaseRewardsPool(uint256[] memory _amount) public onlyOwner {
        require(_amount.length == rates.length, 'Only 5 amount valid');
        uint256 amountLength = _amount.length;
        uint256 summary = 0;
        for (uint256 i = 0; i < amountLength; i++) {
            rewardsPool[i] += _amount[i];
            summary += _amount[i];
        }
        fitToken.transferFrom(msg.sender, address(this), summary);
        emit IncreaseRewardsPool(msg.sender, summary);
    }

    function increaseRewardPoolForClass(uint8 _class, uint256 _amount) public onlyOwner {
        require(_class < 5, 'Wrong class');
        rewardsPool[_class] += _amount;
        fitToken.transferFrom(msg.sender, address(this), _amount);
        emit IncreaseRewardPoolForClass(msg.sender, _amount, _class);
    }

    function updateMax(uint256 _max) external onlyOwner {
        MAX_STAKES = _max;
    }
}