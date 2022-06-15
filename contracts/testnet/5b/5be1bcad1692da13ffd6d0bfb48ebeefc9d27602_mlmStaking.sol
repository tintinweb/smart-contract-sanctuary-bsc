/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
error TransferFailed();
error NeedsMoreThanZero();

contract mlmStaking is ReentrancyGuard {
    IERC20 public s_stakingToken;
    using Counters for Counters.Counter;
   
    Counters.Counter private _referralIds;

    
    uint256 public constant REWARD_RATE = 35;
    uint256 public s_lastUpdateTime;
    uint256 public s_rewardPerTokenStored;

    mapping(address => uint256) public s_userRewardPerTokenPaid;
    mapping(address => uint256) public s_rewards;

    uint256 private s_totalSupply;
    mapping(address => uint256) public s_balances;

    event Staked(address indexed user, uint256 indexed amount);
    event WithdrewStake(address indexed user, uint256 indexed amount);
    event RewardsClaimed(address indexed user, uint256 indexed amount);
    address owner;
    uint cost = 390000000000;
   


    mapping(uint => stakermlmbonus) private mlmbonusinfo;

    struct stakermlmbonus {
      address account;
      address referral;
      uint level;
      uint256 amount;
     
    }

    constructor(address stakingToken) {
        s_stakingToken = IERC20(stakingToken);
        owner = msg.sender;
    }

    
    function rewardPerToken() public view returns (uint256) {
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }
        return
            s_rewardPerTokenStored +
            (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) / s_totalSupply);
    }

    
    function earned(address account) public view returns (uint256) {
        return
            ((s_balances[account] * (rewardPerToken() - s_userRewardPerTokenPaid[account])) /
                1e18) + s_rewards[account];
    }

    function setcost(uint amount) public{
        cost = amount;
    }

   
    function stake( address account)
        external payable
        updateReward(msg.sender)
        nonReentrant
        //moreThanZero(amount)
    {   
        //require(amount == 300 ||amount == 1000 ||amount == 5000);
        require(msg.value >= 2700000000000000000 );
        uint totalprice = msg.value;
        uint amount = cost*totalprice/1 ether;
        address referral = msg.sender;
        if(account != address(0) && account != 0x2Ff10D4343f225AfcA34C39B03ffe270a393268D){
             s_stakingToken.transferFrom(owner, account, (amount*10/100)*10**18);
             uint totalreferralId = _referralIds.current();
             uint level = 1;
       
              _referralIds.increment();
               mlmbonusinfo[totalreferralId] = stakermlmbonus(
                account,
                referral,
                level,
                amount
                );
               
            uint totalItemCount = _referralIds.current();
            for (uint i = 0; i < totalItemCount; i++) {
            if (mlmbonusinfo[i + 1].referral == account) {
           
            uint currentId = i + 1;
            address account1 = mlmbonusinfo[currentId].account;
            uint level1 = mlmbonusinfo[currentId].level;
            uint setlevel;
            uint levelamount;
            if(level1 == 1){
               setlevel = 2;
               levelamount = amount*2/100;
            }
            else if(level1 == 2){
               setlevel = 3;
               levelamount = amount*1/100;
            }
            else if(level1 == 3){
               setlevel = 4;
               levelamount = amount*1/100;
            }
            else if(level1 == 4){
               setlevel = 5;
               levelamount = amount*5/1000;
            }
            else if(level1 == 5){
               setlevel = 6;
               levelamount = amount*5/1000;
            }
            else if(level1 == 6){
               setlevel = 7;
               levelamount = amount*5/1000;
            }
            else if(level1 == 7){
               setlevel = 8;
               levelamount = amount*3/1000;
            }
            else if(level1 == 8){
               setlevel = 9;
               levelamount = amount*3/1000;
            }
            else if(level1 == 9){
               setlevel = 10;
               levelamount = amount*3/1000;
            }
            uint amount1;
            s_stakingToken.transferFrom(owner, account1, levelamount*10**18);
            uint totreferralId = _referralIds.current();
       
                _referralIds.increment();
                 mlmbonusinfo[totreferralId] = stakermlmbonus(
                account1,
                msg.sender,
                level,
                amount1
               );
            }

            }
        }    
       
        s_totalSupply += amount;
        s_balances[msg.sender] += amount;
        emit Staked(msg.sender, amount);
        bool success = s_stakingToken.transferFrom(owner, address(this), amount*10**18);
        if (!success) {
            revert TransferFailed();
        }
    }

    
    function withdraw(uint256 amount) external updateReward(msg.sender) nonReentrant {
        s_totalSupply -= amount;
        s_balances[msg.sender] -= amount;
        emit WithdrewStake(msg.sender, amount);
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert TransferFailed();
        }
    }

   
    function claimReward() external updateReward(msg.sender) nonReentrant {
        uint256 reward = s_rewards[msg.sender];
        s_rewards[msg.sender] = 0;
        emit RewardsClaimed(msg.sender, reward);
        bool success = s_stakingToken.transfer(msg.sender, reward);
        if (!success) {
            revert TransferFailed();
        }
    }

    
    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert NeedsMoreThanZero();
        }
        _;
    }

   
    function getStaked(address account) public view returns (uint256) {
        return s_balances[account];
    }
}