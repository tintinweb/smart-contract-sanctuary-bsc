/**
    XPROJECT | XPRO STAKING
    Staking Site : https://stake.xpro.community
    Website      : https://xpro.community
    Social       : https://xpro.community/#social
    Contract     : 0x7c1b2f618569789941b88680966333f3e8fedc61
    Donate       : 0x1B8dfe4Dc5759A7B7b07EbE224C54971Dbb3F349
*/

pragma solidity ^0.7.5;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract XPRO_Staking is Ownable {
    using SafeMath for uint256;

    address public constant TOKEN = 0x7C1b2f618569789941B88680966333F3e8FEdc61; // XPRO TOKEN

    //STAKING PARAMETERS
    uint256 public constant stakingPeriod = 180 days; //period over which tokens are locked after staking
    uint256 public stakingEnd; //point after which staking rewards cease to accumulate
    uint256 public rewardRate = 5; //5% linear return per staking period
    uint256 public totalStaked; //sum of all user stakes
    uint256 public maxTotalStaked = 50e21; //50 trillion tokens
    uint256 public minStaked = 10e20; //100 billion tokens. min staked per user

    //STAKING MAPPINGS
    mapping (address => uint256) public stakedTokens; //amount of tokens has staked (by address)
    mapping (address => uint256) public lastStaked; //last time at which address staked, deposited
    mapping (address => uint256) public totalEarnedTokens; //total tokens earned (by user)

    constructor(){
        stakingEnd = (block.timestamp + 360 days);
    }

    //STAKING FUNCTIONS
    function deposit(uint256 amountTokens) external {
        require( (stakedTokens[msg.sender] >= minStaked || amountTokens >= minStaked), "deposit: must exceed minimum stake" );
        require(totalStaked + amountTokens <= maxTotalStaked, "deposit: amount would exceed max stake. call updateStake to claim dividends");
        updateStake();
        IERC20(TOKEN).transfer(address(this), amountTokens);
        stakedTokens[msg.sender] += amountTokens;
        totalStaked += amountTokens;
    }

    function updateStake() public {
        uint256 stakedUntil = min(block.timestamp, stakingEnd);
        uint256 periodStaked = stakedUntil.sub(lastStaked[msg.sender]);
        uint256 dividends;
        //linear rewards up to stakingPeriod
        if(periodStaked < stakingPeriod) {
            dividends = periodStaked.mul(stakedTokens[msg.sender]).mul(rewardRate).div(stakingPeriod).div(100);
        } else {
            dividends = stakedTokens[msg.sender].mul(rewardRate).div(100);
        }
        lastStaked[msg.sender] = stakedUntil;
        if(totalStaked + dividends > maxTotalStaked) {
            IERC20(TOKEN).transfer(msg.sender, dividends);
            totalEarnedTokens[msg.sender] += dividends;
        } else {
            stakedTokens[msg.sender] += dividends;
            totalStaked += dividends;
            totalEarnedTokens[msg.sender] += dividends;
        }
    }

    function withdrawDividends() external {
        uint256 stakedUntil = min(block.timestamp, stakingEnd);
        uint256 periodStaked = stakedUntil.sub(lastStaked[msg.sender]);
        uint256 dividends;
        if(periodStaked < stakingPeriod) {
            dividends = periodStaked.mul(stakedTokens[msg.sender]).mul(rewardRate).div(stakingPeriod).div(100);
        } else {
            dividends = stakedTokens[msg.sender].mul(rewardRate).div(100);
        }
        lastStaked[msg.sender] = stakedUntil;
        IERC20(TOKEN).transfer(msg.sender, dividends);
        totalEarnedTokens[msg.sender] += dividends;
    }

    function min(uint256 a, uint256 b) internal pure returns(uint256) {
        return a < b ? a : b;
    }

    function unstake() external {
        uint256 timeSinceStake = (block.timestamp).sub(lastStaked[msg.sender]);
        require(timeSinceStake >= stakingPeriod || block.timestamp > stakingEnd, "unstake: staking period for user still ongoing");
        updateStake();
        uint256 toTransfer = stakedTokens[msg.sender];
        stakedTokens[msg.sender] = 0;
        IERC20(TOKEN).transfer(msg.sender, toTransfer);
        totalStaked = totalStaked.sub(toTransfer);
    }

    function getPendingDivs(address user) external view returns(uint256) {
        uint256 stakedUntil = min(block.timestamp, stakingEnd);
        uint256 periodStaked = stakedUntil.sub(lastStaked[user]);
        uint256 dividends;
        //linear rewards up to stakingPeriod
        if(periodStaked < stakingPeriod) {
            dividends = periodStaked.mul(stakedTokens[user]).mul(rewardRate).div(stakingPeriod).div(100);
        } else {
            dividends = stakedTokens[user].mul(rewardRate).div(100);
        }
        return(dividends);
    }

    //OWNER FUNCTIONS
    function updateMinStake(uint256 newMinStake) external onlyOwner() {
        minStaked = newMinStake;
    }

    function updateStakingEnd(uint256 newStakingEnd) external onlyOwner() {
        require(newStakingEnd >= block.timestamp, "updateStakingEnd: newStakingEnd must be in future");
        stakingEnd = newStakingEnd;
    }

    function updateRewardRate(uint256 newRewardRate) external onlyOwner() {
        require(newRewardRate <= 100, "newRewardRate can not greater than 100");
        rewardRate = newRewardRate;
    }

    function updateMaxTotalStaked(uint256 newMaxTotalStaked) external onlyOwner() {
        maxTotalStaked = newMaxTotalStaked;
    }

    //allows owner to recover ERC20 tokens for users when they are mistakenly sent to contract
    function recoverTokens(address tokenAddress, address dest, uint256 amountTokens) external onlyOwner() {
        require(tokenAddress != TOKEN, "recoverTokens: cannot move staked token");
        IERC20(tokenAddress).transfer(dest, amountTokens);
    }

    //allows owner to reclaim any tokens not distributed during staking
    function recoverTOKEN() external onlyOwner() {
        require(block.timestamp >= (stakingEnd + 180 days), "recoverTOKEN: too early");
        uint256 amountToSend = IERC20(TOKEN).balanceOf(address(this));
        IERC20(TOKEN).transfer(msg.sender, amountToSend);
    }
}