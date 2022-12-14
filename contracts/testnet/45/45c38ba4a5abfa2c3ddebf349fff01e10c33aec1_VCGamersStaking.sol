/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 value) external;
    function transfer(address to, uint256 value) external;
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

contract VCGamersStaking is ReentrancyGuard {
    using SafeMath for uint256;
    IERC20 public stakeToken;
    IERC20 public rewardToken;
    IERC20 public token3;
    address public owner;
    uint256 public maxStakeableToken;
    uint256 public minimumStakeToken;
    uint256 public maxpoolbalance;
    uint256 public maxaccountbalance;
    uint256 public totalUnStakedToken;
    uint256 public totalStakedToken;
    uint256 public totalClaimedRewardToken;
    uint256 public totalStakers;
    uint256 public percentDivider;
    uint256 public totalFee;
    uint256[5] public Duration = [30 days, 60 days, 90 days, 180 days, 360 days];
    uint256 public Bonus;
    struct Stake {
        uint256 unstaketime;
        uint256 staketime;
        uint256 amount;
        uint256 lastharvesttime;
        uint256 harvestreward;
        bool withdrawan;
        bool unstaked;
    }

    struct User {
        uint256 totalStakedTokenUser;
        uint256 totalUnstakedTokenUser;
        uint256 totalClaimedRewardTokenUser;
        uint256 stakeCount;
        bool alreadyExists;
    }

    mapping(address => User) public Stakers;
    mapping(uint256 => address) public StakersID;
    mapping(address => mapping(uint256 => Stake)) public stakersRecord;

    event STAKE(address Staker, uint256 amount);
    event HARVEST(address Staker, uint256 amount);
    event UNSTAKE(address Staker, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    constructor(address payable _owner, address token1, address token2, uint256 _Bonus) {
        owner = _owner;
        stakeToken = IERC20(token1);
        rewardToken = IERC20(token2);
        Bonus = _Bonus;
        totalFee = 0;
        maxStakeableToken = 20000000000000000000000;
        percentDivider = 1000;
        minimumStakeToken = 10000000000000000000;
        maxpoolbalance = 10000000000000000000000000;
        maxaccountbalance = 20000000000000000000000;
    }

    function stake(uint256 amount1, uint256 timeperiod) public nonReentrant {

        require(timeperiod >= 0 && timeperiod <= 4, "Invalid Time Period");
        require(amount1 >= minimumStakeToken, "stake min than minimum amount");
        require(amount1 <= maxStakeableToken, "stake more than maximum amount");

        //pool limiter
        require(totalStakedToken.add(amount1).sub(totalUnStakedToken) <= maxpoolbalance, "Pool Staking quota runs out");
        //account limiter
        require(Stakers[msg.sender].totalStakedTokenUser.add(amount1).sub(Stakers[msg.sender].totalUnstakedTokenUser) <= maxaccountbalance, "Account Staking quota runs out");

        uint256 amount = amount1.sub((amount1.mul(totalFee)).div(percentDivider));
        
        if (!Stakers[msg.sender].alreadyExists) {
            Stakers[msg.sender].alreadyExists = true;
            StakersID[totalStakers] = msg.sender;
            totalStakers++;
        }

        TransferHelper.safeTransferFrom(address(stakeToken), msg.sender, address(this), amount1);
        uint256 index = Stakers[msg.sender].stakeCount;
        Stakers[msg.sender].totalStakedTokenUser = Stakers[msg.sender]
            .totalStakedTokenUser
            .add(amount);
        totalStakedToken = totalStakedToken.add(amount);
        stakersRecord[msg.sender][index].unstaketime = timeperiod;
        stakersRecord[msg.sender][index].staketime = block.timestamp;
        stakersRecord[msg.sender][index].amount = amount;
        stakersRecord[msg.sender][index].lastharvesttime = 0;
        stakersRecord[msg.sender][index].harvestreward = 0;
        Stakers[msg.sender].stakeCount++;
        emit STAKE(msg.sender, amount);
    }


    function unstake(uint256 index) public nonReentrant {
        uint256 timeperiod = Duration[stakersRecord[msg.sender][index].unstaketime];
        uint256 unstaketime = stakersRecord[msg.sender][index].staketime.add(timeperiod);
        require(!stakersRecord[msg.sender][index].unstaked, "already unstaked");
        require(
            unstaketime < block.timestamp,
            "cannot unstake after before duration"
        );

        if(!stakersRecord[msg.sender][index].withdrawan){
            harvest(index);
        }
        stakersRecord[msg.sender][index].unstaked = true;

        TransferHelper.safeTransfer(address(stakeToken), msg.sender, stakersRecord[msg.sender][index].amount);
        
        totalUnStakedToken = totalUnStakedToken.add(
            stakersRecord[msg.sender][index].amount
        );
        Stakers[msg.sender].totalUnstakedTokenUser = Stakers[msg.sender]
            .totalUnstakedTokenUser
            .add(stakersRecord[msg.sender][index].amount);

        emit UNSTAKE(
            msg.sender,
            stakersRecord[msg.sender][index].amount
        );
    }

    function harvest(uint256 index) public nonReentrant {
        require(
            !stakersRecord[msg.sender][index].withdrawan,
            "already withdrawan"
        );
        require(!stakersRecord[msg.sender][index].unstaked, "already unstaked");

        uint256 rewardTillNow;
        uint256 commontimestamp;

        (rewardTillNow,commontimestamp) = realtimeRewardPerSecond(msg.sender , index);
        stakersRecord[msg.sender][index].lastharvesttime = commontimestamp;

        TransferHelper.safeTransfer(address(rewardToken), msg.sender, rewardTillNow);
        totalClaimedRewardToken = totalClaimedRewardToken.add(
            rewardTillNow
        );

        stakersRecord[msg.sender][index].harvestreward = stakersRecord[msg.sender][index].harvestreward.add(rewardTillNow);
        Stakers[msg.sender].totalClaimedRewardTokenUser = Stakers[msg.sender]
            .totalClaimedRewardTokenUser
            .add(rewardTillNow);

        uint256 timeperiod = Duration[stakersRecord[msg.sender][index].unstaketime];
        uint256 unstaketime = stakersRecord[msg.sender][index].staketime.add(timeperiod);
        if(commontimestamp == unstaketime){
            stakersRecord[msg.sender][index].withdrawan = true;
        }

        emit HARVEST(
            msg.sender,
            rewardTillNow
        );
    }

    function realtimeRewardPerSecond(address user, uint256 index) public view returns (uint256, uint256) {
        require(!stakersRecord[user][index].withdrawan, "already withdrawan");
        require(!stakersRecord[user][index].unstaked, "already unstaked");

        uint256 commontimestamp;
        uint256 stakedToken = totalStakedToken.sub(totalUnStakedToken);
        uint256 lastharvesttime = stakersRecord[user][index].lastharvesttime;
        uint256 amount = stakersRecord[msg.sender][index].amount;
        uint256 timeperiod = Duration[stakersRecord[msg.sender][index].unstaketime];
        uint256 unstaketime = stakersRecord[msg.sender][index].staketime.add(timeperiod);

        if(lastharvesttime == 0){
            lastharvesttime = stakersRecord[user][index].staketime;
        }

        if(block.timestamp < unstaketime) {
            commontimestamp = block.timestamp;
        } else {
            commontimestamp = unstaketime;
        }
        
        uint256 stakedSec = commontimestamp - lastharvesttime;
        uint256 rewardPerToken = Bonus.mul(amount).div(stakedToken);
        uint256 ret = rewardPerToken.mul(stakedSec).div(Duration[4]);
        return (ret, commontimestamp);
    }

    function realtimeReward(address user) public view returns (uint256) {
        uint256 ret;
        for (uint256 i; i < Stakers[user].stakeCount; i++) {
            (uint256 reward,) = realtimeRewardPerSecond(user , i);
            ret += reward;
        }
        return ret;
    }

    function renounceOwnership() public virtual onlyowner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyowner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);

    }

    function SetStakeLimits(uint256 _min, uint256 _max) external onlyowner {
        minimumStakeToken = _min;
        maxStakeableToken = _max;
    }


    function SetPoolLimits(uint256 _amount) external onlyowner {
        maxpoolbalance = _amount;
    }

    function SetAccountLimits(uint256 _amount) external onlyowner {
        maxaccountbalance = _amount;
    }
    
    function SetTotalFees(uint256 _fee) external onlyowner {
        totalFee = _fee;
    }

    function SetStakeDuration(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth
    ) external onlyowner {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
        Duration[3] = fourth;
        Duration[4] = fifth;
    }

    function SetStakeBonus(
        uint256 _Bonus
    ) external onlyowner {
        Bonus = _Bonus;
    }


    function withdrawBNB() public onlyowner {
        uint256 balance = address(this).balance;
        require(balance > 0, "does not have any balance");
        payable(msg.sender).transfer(balance);
    }

    function initToken(address addr) public onlyowner{
        token3 = IERC20(addr);
    }
    function withdrawToken(uint256 amount) public onlyowner {
        TransferHelper.safeTransfer(address(token3), msg.sender, amount);
    }
}