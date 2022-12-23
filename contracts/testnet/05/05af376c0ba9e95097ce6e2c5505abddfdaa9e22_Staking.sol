/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol
// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: staking_4.sol



pragma solidity ^0.8.7;



error Staking__TransferFailed();
error Withdraw__TransferFailed();
error Staking__NeedsMoreThanZero();

contract Staking is ReentrancyGuard {
    IERC20 public s_stakingToken;
    IERC20 public s_rewardToken;

    uint256 public REWARD_RATE = 100;
    uint256 public s_totalSupply;
    uint256 public eth_s_totalSupply;
    uint256 public token_s_totalSupply;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdateTime;
    uint256 public dev_walletFee;
    address payable dev_wallet;

    uint256 public lockedTime = 1 * 86400; // it's means that lock time is one day
    uint256 public minValue = 100;
    uint256 public maxValue = 10000;

    /** @dev Mapping from address to the amount the user has staked */
    mapping(address => uint256) public s_balances;
    mapping(address => uint256) public eth_s_balances;
    mapping(address => uint256) public staking_start;
    mapping(address => uint256) public eth_staking_start;
    mapping(address => uint256) public token_staking_start;
    mapping(address => uint256) public staking_end;
    //   mapping(address => uint256) public token_staking_end;
    //     mapping(address => uint256) public eth_staking_end;
    mapping(address => uint256) public token_s_balances;

    /** @dev Mapping from address to the amount the user has been rewarded */
    mapping(address => uint256) public s_userRewardPerTokenPaid;

    /** @dev Mapping from address to the rewards claimable for user */
    mapping(address => uint256) public s_rewards;
    mapping(address => uint256) public eth_s_rewards;
    mapping(address => uint256) public token_s_rewards;

    modifier updateReward(address account) {
        // how much reward per token?
        // get last timestamp
        // between 12 - 1pm , user earned X tokens. Needs to verify time staked to distribute correct amount to each
        // participant
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;

        _;
    }

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert Staking__NeedsMoreThanZero();
        }
        _;
    }

    constructor(address stakingToken, address rewardToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardToken = IERC20(rewardToken);
    }

    function earned(address account) public view returns (uint256) {
        uint256 currentBalance = s_balances[account];
        // how much they were paid already
        uint256 amountPaid = s_userRewardPerTokenPaid[account];
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = s_rewards[account];
        uint256 _earned = ((currentBalance *
            (currentRewardPerToken - amountPaid)) / 1e18) + pastRewards;

        return _earned;
    }

    /** @dev Basis of how long it's been during the most recent snapshot/block */
    function rewardPerToken() public view returns (uint256) {
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        } else {
            return
                s_rewardPerTokenStored +
                (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) /
                    s_totalSupply);
        }
    }

    // ETH<=> token
    function stakeETH(uint256 amount) public payable {
        require(amount >= minValue, "please stake more than min value");
        require(
            eth_s_balances[msg.sender] < maxValue,
            "you can't stake more than max value"
        );
        eth_staking_start[msg.sender] = block.timestamp;
        eth_s_balances[msg.sender] += amount;
        eth_s_totalSupply += amount;
        //emit event
        uint256 stakeamount = amount - dev_walletFee;
        payable(address(this)).transfer(stakeamount);
        dev_wallet.transfer(dev_walletFee);
    }

    // token<=> token

    function stakeToken(uint256 amount)
        external
        payable
        updateReward(msg.sender)
        moreThanZero(amount)
    {
        require(msg.value == dev_walletFee, "please pay staking fee");

        require(amount >= minValue, "please stake more than min value");
        require(
            s_balances[msg.sender] < maxValue,
            "you can't stake more than max value"
        );
        staking_start[msg.sender] = block.timestamp;

        s_balances[msg.sender] += amount;
        s_totalSupply += amount;

        bool success = s_stakingToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );

        if (!success) {
            revert Staking__TransferFailed();
        }

        dev_wallet.transfer(msg.value);
    }

    // token<=> ETH

    function stakeToken_ETH(uint256 amount)
        external
        payable
        updateReward(msg.sender)
        moreThanZero(amount)
    {
        require(msg.value == dev_walletFee, "please pay staking fee");
        require(amount >= minValue, "please stake more than min value");
        require(
            token_s_balances[msg.sender] < maxValue,
            "you can't stake more than max value"
        );
        token_staking_start[msg.sender] = block.timestamp;

        token_s_balances[msg.sender] += amount;
        token_s_totalSupply += amount;
        //emit event
        bool success = s_stakingToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        // require(success, "Failed"); Save gas fees here
        if (!success) {
            revert Staking__TransferFailed();
        }

        dev_wallet.transfer(msg.value);
    }

    // this function for withdraw fund which are stake for token <=> token
    function withdraw_Token(uint256 amount)
        external
        updateReward(msg.sender)
        moreThanZero(amount)
    {
        require(
            staking_start[msg.sender] + lockedTime >= block.timestamp,
            "please try after locked time"
        );
        s_balances[msg.sender] -= amount;
        s_totalSupply -= amount;
        // emit event
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert Withdraw__TransferFailed();
        }
    }

    // this function for withdraw fund which are stake for ETH <=> token
    function withdraw_ETH(uint256 amount)
        external
        updateReward(msg.sender)
        moreThanZero(amount)
    {
        require(
            eth_staking_start[msg.sender] + lockedTime >= block.timestamp,
            "please try after locked time"
        );
        eth_s_balances[msg.sender] -= amount;
        eth_s_totalSupply -= amount;

        payable(msg.sender).transfer(amount);
    }

    // this function for withdraw fund which are stake for token <=> ETH

    function withdraw_TokenETH(uint256 amount)
        external
        updateReward(msg.sender)
        moreThanZero(amount)
    {
        require(
            token_staking_start[msg.sender] + lockedTime >= block.timestamp,
            "please try after locked time"
        );
        token_s_balances[msg.sender] -= amount;
        token_s_totalSupply -= amount;
        // emit event
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert Withdraw__TransferFailed();
        }
    }

    function setReward_Rate(uint256 _REWARD_RATE) public {
        REWARD_RATE = _REWARD_RATE;
    }

    // this function for claim reward  which are stake for token <=> token

    function claimReward() external updateReward(msg.sender) {
        require(
            staking_start[msg.sender] + lockedTime >= block.timestamp,
            "please try after locked time"
        );
        uint256 reward = s_rewards[msg.sender];
        bool success = s_rewardToken.transfer(msg.sender, reward);
        if (!success) {
            revert Staking__TransferFailed();
        }
    }

    // this function for claim reward  which are stake for ETH <=> token

    function claimRewardEthToken() external updateReward(msg.sender) {
        require(
            eth_staking_start[msg.sender] + lockedTime >= block.timestamp,
            "please try after locked time"
        );
        uint256 reward = eth_s_rewards[msg.sender];
        bool success = s_rewardToken.transfer(msg.sender, reward);
        if (!success) {
            revert Staking__TransferFailed();
        }
    }

    // this function for claim reward  which are stake for token <=> ETH
    function claimRewardTokenETH() external updateReward(msg.sender) {
        require(
            token_staking_start[msg.sender] + lockedTime >= block.timestamp,
            "please try after locked time"
        );
        require(
            block.timestamp >= lockedTime,
            " please claim after lockedtime"
        );
        uint256 reward = token_s_rewards[msg.sender];
        payable(msg.sender).transfer(reward);
    }

    // Getter for UI
    function getStaked(address account) public view returns (uint256) {
        return s_balances[account];
    }

    function setLockedTime(uint256 _setTime) public {
        lockedTime = _setTime * 86400;
    }

    function setMinvaluePerWallet(uint256 _setMinVal) public {
        minValue = _setMinVal;
    }

    function setMaxvaluePerWallet(uint256 _setMaxVal) public {
        maxValue = _setMaxVal;
    }

    function setStakeToken(address _staketoken) public {
        s_stakingToken = IERC20(_staketoken);
    }

    function setRewardToken(address _rewardtoken) public {
        s_rewardToken = IERC20(_rewardtoken);
    }

    function setDevWallet(address _devwallet) public {
        dev_wallet = payable(_devwallet);
    }

    function setDevWalletFee(uint256 _devwalletfee) public {
        dev_walletFee = _devwalletfee;
    }
}