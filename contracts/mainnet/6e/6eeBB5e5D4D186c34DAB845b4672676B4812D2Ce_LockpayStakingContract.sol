// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./SafeMath.sol";
import "./Owned.sol";

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract LockpayStakingContract is Owned, ReentrancyGuard {
    using SafeMath for uint256;
    uint256 private LockpayDecimals = 18;
    address public LockPayV2Contract =
        0xdCAC116fF1B4D3595E323a92902E85fBee1104bf;
    address private LockpayStakeWallet;

    struct Stake {
        uint256 stakeOptionId;
        uint256 startTS;
        uint256 endTS;
        uint256 amountStaked;
        uint256 rewardAmountAtEnd;
        bool claimed;
    }

    struct Staker {
        mapping (uint256 => Stake) stakes;
        bool isBlacklisted;
        bool isDeclared;
        uint256 stakeCounter;
    }

    struct StakeOption {
        uint256 periodInSeconds;
        bool isActive;
        bool canStake;
        bool canWithdraw;
        bool isImportAllowed;
        uint256 rewardMultiplicatorMilions;
        uint256 totalTokensStaked;
        uint256 activeTokensStaked;
        uint256 totalTokensRewarded;
        uint256 totalTokensClaimed;
        uint256 activeStakers;
    }

    mapping(address => Staker) private stakers;
    mapping(uint256 => StakeOption) public stakeOptions;
    uint256 public stakeOptionsCounter = 0;

    event STAKED(address indexed from, uint256 amount);
    event CLAIMED(address indexed from, uint256 amount);

    function STAKE(uint256 stakeOptionId, uint256 tokens)
        external
        nonReentrant
        returns (bool)
    {
        require (!(stakers[msg.sender].isBlacklisted), "you are blacklisted");
        require(tokens > 0, "Stake amount should be correct");
        require(
            stakeOptions[stakeOptionId].isActive &&
                stakeOptions[stakeOptionId].canStake,
            "Stake option is not allowed to stake"
        );

        
        require(
            IERC20(LockPayV2Contract).transferFrom(
                msg.sender,
                LockpayStakeWallet,
                tokens
            ),
            "Tokens cannot be transferred from user for locking"
        );

        addStaker(stakeOptionId, msg.sender, tokens, block.timestamp);
        emit STAKED(msg.sender, tokens);
        return true;
    }

    function getStake(address addr, uint256 index) external view returns (Stake memory) {
        return stakers[addr].stakes[index];
    }

    function addStaker(uint256 stakeOptionId, address addr, uint256 tokens, uint256 startPeriod) private {
       
        if(!stakers[addr].isDeclared) {
            stakers[addr].isBlacklisted = false;
            stakers[addr].isDeclared = true;
            stakers[addr].stakeCounter = 0;
        }
        stakers[addr].stakes[stakers[addr].stakeCounter] = Stake({
            stakeOptionId: stakeOptionId,
            startTS: startPeriod,
            endTS: startPeriod +
                stakeOptions[stakeOptionId].periodInSeconds,
            amountStaked: tokens,
            rewardAmountAtEnd: tokens.mul(
                stakeOptions[stakeOptionId].rewardMultiplicatorMilions
            ).div(1000000),
            claimed: false
        });

        stakers[addr].stakeCounter = stakers[addr].stakeCounter + 1;
        stakeOptions[stakeOptionId].totalTokensStaked = stakeOptions[
            stakeOptionId
        ].totalTokensStaked.add(tokens);
        stakeOptions[stakeOptionId].activeTokensStaked = stakeOptions[
            stakeOptionId
        ].activeTokensStaked.add(tokens);
        stakeOptions[stakeOptionId].activeStakers = stakeOptions[stakeOptionId].activeStakers + 1;
    }

    function CLAIM(uint256 stakeId) external returns (bool) {
        require (!(stakers[msg.sender].isBlacklisted), "you are blacklisted");
        require(stakers[msg.sender].isDeclared, "You are not staker");
        require(
            stakers[msg.sender].stakes[stakeId].endTS < block.timestamp,
            "Stake Time is not over yet"
        );
        require(
            stakers[msg.sender].stakes[stakeId].claimed == false,
            "Already claimed"
        );

        uint256 stakeOptionId = stakers[msg.sender]
            .stakes[stakeId]
            .stakeOptionId;

        require(
            stakeOptions[stakeOptionId].isActive &&
                stakeOptions[stakeOptionId].canWithdraw,
            "Stake option is not allowed to stake"
        );

        uint256 rewardAmount = stakers[msg.sender]
            .stakes[stakeId]
            .rewardAmountAtEnd;

        require(
            IERC20(LockPayV2Contract).transferFrom(
                LockpayStakeWallet,
                msg.sender,
                rewardAmount
            ),
            "Tokens cannot be transferred from user for locking"
        );

        uint256 amountStaked = stakers[msg.sender].stakes[stakeId].amountStaked;

        stakers[msg.sender].stakes[stakeId].claimed = true;

        stakeOptions[stakeOptionId].activeTokensStaked = stakeOptions[
            stakeOptionId
        ].activeTokensStaked.sub(amountStaked);
        stakeOptions[stakeOptionId].totalTokensRewarded = stakeOptions[
            stakeOptionId
        ].totalTokensRewarded.add(rewardAmount).sub(amountStaked);
        stakeOptions[stakeOptionId].totalTokensClaimed = stakeOptions[
            stakeOptionId
        ].totalTokensClaimed.add(rewardAmount);

        stakeOptions[stakeOptionId].activeStakers = stakeOptions[stakeOptionId].activeStakers - 1;

        emit CLAIMED(msg.sender, rewardAmount);

        return true;
    }


    function addStakeOption( uint256 periodInSeconds, uint256 rewardMultiplicatorMilions) external onlyOwner {
        stakeOptions[stakeOptionsCounter] = StakeOption({
        periodInSeconds : periodInSeconds,
        isActive: false,
        canStake: false,
        canWithdraw: false,
        isImportAllowed: true,
        rewardMultiplicatorMilions: rewardMultiplicatorMilions,
        totalTokensStaked: 0,
        activeTokensStaked: 0,
        totalTokensRewarded: 0,
        totalTokensClaimed:0,
        activeStakers: 0
        });
        stakeOptionsCounter++;
    }

    function importStakers(uint256 stakeOptionId, address[] memory accounts, uint256[] memory startPeriods, uint256[] memory stakedTokens) external onlyOwner {
        require(
            stakeOptions[stakeOptionId].isImportAllowed,
            "Stake option is not allowed to stake"
        );
        require (accounts.length > 0 && accounts.length == startPeriods.length && startPeriods.length == stakedTokens.length, "Bad input data");
        for(uint256 i = 0; i < accounts.length; i++) {
                addStaker(stakeOptionId, accounts[i], stakedTokens[i].mul(10 ** LockpayDecimals), startPeriods[i]);
        }
    }

    function blacklistStakers(address[] memory accounts, bool blacklisted) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            stakers[accounts[i]].isBlacklisted = blacklisted;
        }
    }

    function setCanStake(uint256 stakeOptionId, bool newValue) external onlyOwner{
        stakeOptions[stakeOptionId].canStake = newValue;
    }
    function setCanWithdraw(uint256 stakeOptionId, bool newValue) external onlyOwner{
        stakeOptions[stakeOptionId].canWithdraw = newValue;
    }

    function activate(uint256 stakeOptionId) external onlyOwner{
        stakeOptions[stakeOptionId].isActive = true;
        stakeOptions[stakeOptionId].isImportAllowed = false;
    }

    function setStakeWallet(address newValue) external onlyOwner{
        LockpayStakeWallet = newValue;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8 <0.9.0;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }


    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

 
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

  
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }


    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

pragma solidity >=0.8 <0.9.0;

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

pragma solidity >=0.8 <0.9.0;
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8 <0.9.0;

contract Owned {
    address private owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "ERC20: sending to the zero address");
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}