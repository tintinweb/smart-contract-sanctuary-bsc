import './safeMath.sol';
import './IERC20.sol';
import './context.sol';

pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT


contract FiPiStacking is Ownable {
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount;
        bool withdrawRequested;
        uint256 releaseDate;
        uint256 fipiTokenCumulatedReward;
        uint256 busdCumulatedReward;
    }

    IERC20 fipiToken;
    IERC20 busd;

    //it could be different from contract token balance, because rewards has external source added by owner
    uint256 public totalTokenStacked; 


    address public devAddr;
    
    uint256 public rewardPerBlock;
    

    //so we have 3 variables current state, all previous rewards, last update date
    //so the idea is as follows
    //when something is changing in totalTokenStaked, so whenever someone is depositing or withdrawing their tokens
    //we need to save cumulated values as lets say checkpoint and the date, current values are used to calculate pending rewards based on current state
    

    uint256 public fipiTokenCumulatedPerTokenStaked;
    uint256 public fipiTokenCumulatedPerTokenStakedUpdateBlock;

    uint256 public busdCumulatedPerTokenStaked;

    mapping (address => UserInfo) public userInfo;
    
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event Claimed(uint256 amount);

    constructor(
        IERC20 _fipiToken,
        uint256 _rewardPerBlock
    ) {
        fipiToken = _fipiToken;
        devAddr = _msgSender();
        //reward per block need to be multiplied by bignumber to avoid problem with floating shit so it would be initialy 7500 * 10**18 (decimal) * 10**18
        rewardPerBlock = _rewardPerBlock;
        fipiTokenCumulatedPerTokenStakedUpdateBlock = block.number;
        busd = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    }

    

   

    function deposit(uint256 _amount) public {
        
        UserInfo storage user = userInfo[msg.sender];

        require(user.withdrawRequested == false, "You can not deposit tokens while withdrawing");
        uint256 allowance = fipiToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");
        //each time something change in any user/total stacked ratio we need to update fipiTokenCumulatedPerTokenStaked
        
        if (user.amount == 0)
        {
            updateRewardPerTokenStaked();
            totalTokenStacked = totalTokenStacked.add(_amount);
            user.amount = _amount;
        }
        else
        {
            claimAndRestake();
            claimBusd();
            user.amount = user.amount.add(_amount);
        }

        user.fipiTokenCumulatedReward = fipiTokenCumulatedPerTokenStaked.mul(user.amount).div(10**18);
        user.busdCumulatedReward = busdCumulatedPerTokenStaked.mul(user.amount).div(10**18);

        fipiToken.transferFrom(msg.sender, address(this), _amount);
        emit Deposit(msg.sender, _amount);
    }


    

    function claimAndRestake() public  
    {
        //at the beginning of every interaction lets update the pool info
        updateRewardPerTokenStaked();
        UserInfo storage user = userInfo[_msgSender()];

        require(user.withdrawRequested == false, "You can not claim any rewards when you already initialize a withdraw");

        uint256 maxClaim = user.amount.mul(fipiTokenCumulatedPerTokenStaked).div(10**18);
        uint256 claimableAmount = maxClaim.sub(user.fipiTokenCumulatedReward);

        
        user.amount = user.amount.add(claimableAmount);
        //everything is claimed so i assign to fipiTokenCumulatedReward everything that is there to be claimed
        user.fipiTokenCumulatedReward = user.amount.mul(fipiTokenCumulatedPerTokenStaked).div(10**18);
        
        totalTokenStacked = totalTokenStacked.add(claimableAmount);
        
        emit Claimed(claimableAmount);

    }

    function claimAndWithdraw() public  
    {
        //at the beginning of every interaction lets update the pool info
        updateRewardPerTokenStaked();
        UserInfo storage user = userInfo[_msgSender()];
        require(user.withdrawRequested == false, "You can not claim any rewards when you already initialize a withdraw");
        
        uint256 maxClaim = user.amount.mul(fipiTokenCumulatedPerTokenStaked).div(10**18);
        uint256 claimableAmount = maxClaim.sub(user.fipiTokenCumulatedReward);

        //everything is claimed so i assign to fipiTokenCumulatedReward everything that is there to be claimed
        user.fipiTokenCumulatedReward = maxClaim;
        fipiToken.transfer(msg.sender, claimableAmount);

        emit Claimed(claimableAmount);

    }


    function claimBusd() public  
    {
        if(busdCumulatedPerTokenStaked == 0){
            return;
        }

        UserInfo storage user = userInfo[_msgSender()];
        require(user.withdrawRequested == false, "You can not claim any rewards when you already initialize a withdraw");
        
        uint256 maxClaim = user.amount.mul(busdCumulatedPerTokenStaked).div(10**18);
        uint256 claimableAmount = maxClaim.sub(user.busdCumulatedReward);

        //everything is claimed so i assign to fipiTokenCumulatedReward everything that is there to be claimed
        user.busdCumulatedReward = maxClaim;
        busd.transfer(msg.sender, claimableAmount);

        emit Claimed(claimableAmount);

    }

    function pendingRewards(address _user) external view returns (uint256) 
    {
        UserInfo storage user = userInfo[_user];
        
        if(user.withdrawRequested == true){
            return 0;
        }
        uint256 tokenPerStake = fipiTokenCumulatedPerTokenStaked;
        uint256 totalStacked = totalTokenStacked;

        if (block.number > fipiTokenCumulatedPerTokenStakedUpdateBlock && totalStacked != 0) {
            uint256 nrOfBlocks = block.number.sub(fipiTokenCumulatedPerTokenStakedUpdateBlock);
            uint256 reward = nrOfBlocks.mul(rewardPerBlock);
            tokenPerStake = tokenPerStake.add(reward.mul(10**18).div(totalStacked));
        }
        uint256 claimable = user.amount.mul(tokenPerStake).div(10**18).sub(user.fipiTokenCumulatedReward);
        return claimable;
    }


    function initWithdraw() public{
       
        claimAndRestake();
        claimBusd();
        UserInfo storage user = userInfo[msg.sender];

        uint256 tokensToWithdraw = user.amount;
        totalTokenStacked = totalTokenStacked.sub(tokensToWithdraw);

        require(user.amount >= 0, "You have no tokens to withdraw");
        require(user.withdrawRequested == false, "You already initialize withdraw");
        user.releaseDate = block.timestamp + 1209600;
        user.withdrawRequested = true;

    }

    function withdraw() public {
        
        UserInfo storage user = userInfo[msg.sender];

        require(user.amount >0, "You have no tokens to withdraw");
        require(user.withdrawRequested == true, "You need to initialize your withdraw first" );
        require(block.timestamp > user.releaseDate, "You can't withdraw yet" );
        
        
        user.withdrawRequested = false;
        user.releaseDate = 0;
        fipiToken.transfer(msg.sender, user.amount);

        emit Withdraw(msg.sender, user.amount);
    }

    function distribute(uint _reward) external onlyOwner
    {
        uint256 allowance = busd.allowance(msg.sender, address(this));
        require(allowance >= _reward, "Check the token allowance");
        uint reward = _reward.mul(10**18).div(totalTokenStacked);
        busdCumulatedPerTokenStaked = busdCumulatedPerTokenStaked.add(reward);
    }

    function updateRewardPerTokenStaked() private 
    {
        if(totalTokenStacked > 0)
        {
            //if something is staked we need to calculate how much rewards it is pending per one token
            uint256 howManyBlocksFromLast = block.number.sub(fipiTokenCumulatedPerTokenStakedUpdateBlock);
            uint256 rewardToBeDistributed = howManyBlocksFromLast.mul(rewardPerBlock).mul(10**18).div(totalTokenStacked);
            fipiTokenCumulatedPerTokenStaked = fipiTokenCumulatedPerTokenStaked.add(rewardToBeDistributed);
            fipiTokenCumulatedPerTokenStakedUpdateBlock = block.number;
        }
    }

    

}