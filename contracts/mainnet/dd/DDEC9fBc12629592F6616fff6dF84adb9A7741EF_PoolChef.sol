pragma solidity 0.6.12;

import './SafeMath.sol';
import './IBEP20.sol';
import './SafeBEP20.sol';
import './Ownable.sol';
//import "hardhat/console.sol";
pragma experimental ABIEncoderV2;
import "./InviterChef.sol";

// SousChef is the chef of new bonusEndBlocktokens. He can make yummy food and he is a fair guy as well as MasterChef.
contract PoolChef is Ownable{

    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;   // How many rewardToken tokens the user has provided.
        uint256 lockAmount;
        uint256 rewardDebt;  // Reward debt. See explanation below.
        bool inBlackList;
        uint256 inviteNumber;
        uint256 lastDepositBlockNumber;
        uint256 lastClaimBlockNumber;
        uint256 claimedReward;
        //
        // We do some fancy math here. Basically, any point in time, the amount of SYRUPs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accRewardPerShare) - user.rewardDebt + user.rewardPending
        //
        // Whenever a user deposits or withdraws rewardToken tokens to a pool. Here's what happens:
        //   1. The pool's `accRewardPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of Pool
    struct PoolInfo {
        uint256 lastRewardBlock;  // Last block number that Rewards distribution occurs.
        uint256 accRewardPerShare; // Accumulated reward per share, times 1e12. See below.
    }
    // The lpToken TOKEN!
    IBEP20 public lpToken;
    // The burnToken TOKEN!
    IBEP20 public burnToken;

    uint256 public lpTokenPrice;
    uint256 public  burnTokenPrice;
    uint256 public removeCountDown = 3;

    uint256 public intervalBlockOneDay = 20 * 60 * 24;
    uint256 public intervalBlockOneMonth = intervalBlockOneDay * 30;
    uint256 public intervalBlockLpLock = intervalBlockOneDay * 93;

    // Info.
    PoolInfo public poolInfo;
    // Info of each user that stakes burnToken tokens.
    mapping (address => UserInfo) public userInfo;

    // addresses list
    address[] public addressList;

    uint256 public inviteRate =10;
    // adminAddress
    address public adminAddress;

    uint256 public inviterLength = 2;

    uint256 liveDayTime = 90;

    uint256 public claimedRewardInterval = 1;  // 30 天

    uint256 public depositAmount = 0;

    InviterChef inviterChef;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "admin: wut?");
        _;
    }

    constructor(
        IBEP20 _lpToken,
        IBEP20 _burnToken,
        uint256 _liveDayTime,
        InviterChef _InviterChef
    ) public {
        lpToken = _lpToken;
        burnToken = _burnToken;
        liveDayTime = _liveDayTime;
        inviterChef = _InviterChef;

        lpTokenPrice = 130 * uint256( 10** uint256(_lpToken.decimals()));
        burnTokenPrice = 2 * uint256( 10** uint256(_burnToken.decimals() - 2));

        intervalBlockLpLock = intervalBlockOneDay.mul(liveDayTime.add(removeCountDown));

    }


    function setIntervalBlockOneDay(uint256 _intervalBlockOneDay) public onlyAdmin {
        intervalBlockOneDay = _intervalBlockOneDay;
        intervalBlockLpLock = intervalBlockOneDay.mul(liveDayTime.add(removeCountDown));
    }

    function addressLength() external view returns (uint256) {
        return addressList.length;
    }

    function getAllLockAmount() external view returns (uint256) {
//        return lpToken.balanceOf(address(this));
        return depositAmount;
    }

    function getMyLockAmount() external view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        return user.amount;
    }

    function getGainedRewardAmount() external view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        return user.claimedReward;
    }

    function getAllRewardAmount() external view returns (uint256) {

        uint256 lpTokenAmount = lpToken.balanceOf(address(this));
        if(lpTokenAmount > depositAmount)
        {
            return lpTokenAmount.sub(depositAmount);
        }

    }

    function getLockCountDown() external view returns (uint256) {
        // uint256 liveDayTimeLock = liveDayTime.add(3);
        UserInfo storage user = userInfo[msg.sender];
        if(user.lastDepositBlockNumber == 0){
            return 0;
        }

        uint256  withdrawableBlockDiff = block.number.sub(user.lastDepositBlockNumber);
        //console.log("getLockCountDown = withdrawableBlockDiff %s  ===block.number   %s  =lastDepositBlockNumber = %s", withdrawableBlockDiff, block.number, user.lastDepositBlockNumber);
        uint256  withdrawableBlockLeft = intervalBlockLpLock.sub(withdrawableBlockDiff.mod(intervalBlockLpLock));
        //console.log("getLockCountDown = withdrawableBlockLeft %s  ===intervalBlockLpLock   %s  =lastDepositBlockNumber = %s", withdrawableBlockLeft, intervalBlockLpLock, withdrawableBlockDiff.mod(intervalBlockLpLock));

        uint256 intervalBlock = intervalBlockOneDay.mul(removeCountDown);
        if(withdrawableBlockLeft > intervalBlock){
            return withdrawableBlockLeft.sub(intervalBlock);
        }else{
            return 0;
        }
    }

    function getRemoveCountDown() external view returns (uint256) {
        // uint256 liveDayTimeLock = liveDayTime.add(3);
        UserInfo storage user = userInfo[msg.sender];
        uint256  withdrawableBlockDiff = block.number.sub(user.lastDepositBlockNumber);
        //console.log("getRemoveCountDown = withdrawableBlockDiff %s  ===block.number   %s  =lastDepositBlockNumber = %s", withdrawableBlockDiff, block.number, user.lastDepositBlockNumber);
        uint256  withdrawableBlockLeft = intervalBlockLpLock.sub(withdrawableBlockDiff.mod(intervalBlockLpLock));
        //console.log("getRemoveCountDown = withdrawableBlockLeft %s  ===intervalBlockLpLock   %s  =lastDepositBlockNumber = %s", withdrawableBlockLeft, intervalBlockLpLock, withdrawableBlockDiff.mod(intervalBlockLpLock));

        uint256 intervalBlock = intervalBlockOneDay.mul(removeCountDown);
        if(withdrawableBlockLeft > intervalBlock){
            return 0 ;
        }
        return withdrawableBlockLeft;
    }

    function getRewardCountDown() external view returns (uint256) {

        uint256 intervalBlockDays = intervalBlockOneDay.mul(claimedRewardInterval);
        UserInfo storage user = userInfo[msg.sender];
        uint256  withdrawableBlockDiff = block.number.sub(user.lastClaimBlockNumber);

        if(withdrawableBlockDiff < intervalBlockDays){
            return intervalBlockDays.sub(withdrawableBlockDiff);
        }else{
            return 0;
        }
    }


    // View function to see pending Tokens on frontend.
    function pendingReward(address _user) external view returns (uint256 rewardRet) {
        UserInfo storage user = userInfo[_user];
        //        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 stakedSupply = lpToken.balanceOf(address(this));
//        uint256 stakedSupplyAll = lpToken.balanceOf(address(this));
        uint256 rewardAll = 0;//burnToken.balanceOf(address(this));

        if(stakedSupply > depositAmount){
            rewardAll = stakedSupply.sub(depositAmount);
        }

        //console.log("deposit1 = rewardAll %s  ===stakedSupply   %s  == %s", rewardAll, stakedSupply, block.number);
        //        if (block.number > pool.lastRewardBlock && stakedSupply != 0) {
        if (depositAmount != 0) {
            //            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            //            uint256 tokenReward = multiplier.mul(rewardPerBlock);
            //            accRewardPerShare = accRewardPerShare.add(tokenReward.mul(1e12).div(stakedSupply));
            rewardRet = user.amount.mul(rewardAll).div(depositAmount);
            //            //console.log("deposit1 =accRewardPerShare =  %s    ===tokenReward   %s  =multiplier= %s", accRewardPerShare, tokenReward, multiplier);
        }
        //        return user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt).add(user.lockAmount);
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool() public {


    }


    function withdrawReward() public {
        UserInfo storage user = userInfo[msg.sender];
        uint256  withdrawableBlockDiff = block.number.sub(user.lastClaimBlockNumber);
        //console.log(" ==withdrawableBlockDiff lastClaimBlockNumber   %s  intervalBlockOneDay.mul(claimedRewardInterval)", withdrawableBlockDiff, intervalBlockOneDay.mul(claimedRewardInterval));
        // 如果是 91 92 93 ，用 93 - 91 92 93  =  2 1 0 判断是否是2 1 0 就可以提取
        // require (withdrawableBlockDiff > intervalBlockOneDay.mul(2), 'need wait unlock ');
        require (withdrawableBlockDiff > intervalBlockOneDay.mul(claimedRewardInterval), 'need wait unlock ');

        if (user.amount > 0 ) {
            uint256 stakedSupply = lpToken.balanceOf(address(this));
//            uint256 rewardAll = burnToken.balanceOf(address(this));
            uint256 rewardAll = 0;//burnToken.balanceOf(address(this));

            if(stakedSupply > depositAmount){
                rewardAll = stakedSupply.sub(depositAmount);
            }
//            if (stakedSupply != 0) {
            if (depositAmount != 0) {
                //console.log("withdrawReward = rewardAll %s  ===depositAmount   %s  == %s", rewardAll, depositAmount, block.number);
                uint256 pending = user.amount.mul(rewardAll).div(depositAmount); //.sub(user.rewardDebt);
                if(pending > 0) {

                    lpToken.safeTransfer(address(msg.sender), pending);
                    user.claimedReward = user.claimedReward.add(pending);

                    user.lastClaimBlockNumber = block.number;
                    inviterChef.assignInviteReward(msg.sender, pending);
                }
            }

        }
    }


    // Deposit burnToken tokens to SousChef for Reward allocation.
    function deposit(uint256 _amount) public {
        // require (_amount > 0, 'amount 0');
        require (inviterChef.getParentInviter(msg.sender) != address(0), 'must be invited');

        //console.log("deposit1 =msg.sender =  %s    ===amount   %s  == %s", msg.sender, _amount, block.number);
        uint256 lpTokenAmount = lpTokenPrice.mul(_amount);
        uint256 burnTokenAmount = burnTokenPrice.mul(_amount);
        UserInfo storage user = userInfo[msg.sender];
        require (!user.inBlackList, 'in black list');
        require (lpToken.balanceOf(msg.sender)> lpTokenAmount, 'lptoken not enough');
        require (burnToken.balanceOf(msg.sender)> burnTokenAmount, 'burnToken not enough');

        updatePool();

        if(_amount > 0) {
            depositAmount = depositAmount.add(lpTokenAmount);
            //console.log("deposit2 =lpToken %s", address(lpToken));
            //console.log("deposit2 =  =msg.sender =  %s    ===amount   %s  == %s",  msg.sender, _amount, block.number);
            lpToken.safeTransferFrom(address(msg.sender), address(this), lpTokenAmount);

            uint256 half = burnTokenAmount.div(2);
            // burnTokenAmount 一半销毁，一半给邀请人
            if(address(inviterChef) != address(0)){
                burnToken.transferFrom(address(msg.sender), address(inviterChef), half);
                inviterChef.assignInviteRewardQJI(msg.sender, half);
            }

            burnToken.transferFrom(address(msg.sender), address(1), half);
            user.amount = user.amount.add(lpTokenAmount);
            user.lastDepositBlockNumber = block.number;
            user.lastClaimBlockNumber = block.number;
        }
        //        user.rewardDebt = user.amount.mul(poolInfo.accRewardPerShare).div(1e12);

        emit Deposit(msg.sender, _amount);
    }


    // Withdraw burnToken tokens from SousChef.
    function withdraw() public {

        UserInfo storage user = userInfo[msg.sender];
        uint256  withdrawableBlockDiff = block.number.sub(user.lastDepositBlockNumber);
        uint256  withdrawableBlockLeft = intervalBlockLpLock.sub(withdrawableBlockDiff.mod(intervalBlockLpLock)); // 判断是否是  91 92 93
        //console.log(" ==withdrawableBlockDiff %s =====withdrawableBlockDiff %s ========", withdrawableBlockDiff, withdrawableBlockLeft);
        // 如果是 91 92 93 ，用 93 - 91 92 93  =  2 1 0 判断是否是2 1 0 就可以提取
        // withdrawableBlockDiff 》 90 days &&  withdrawableBlockLeft < 3 days
        // return withdrawableBlockLeft.sub(intervalBlockOneDay.mul(3));
        require (withdrawableBlockDiff > intervalBlockOneDay.mul(liveDayTime) && withdrawableBlockLeft < intervalBlockOneDay.mul(removeCountDown), 'need wait unlock ');

        updatePool();

        uint256 stakedSupply = lpToken.balanceOf(address(this));
//        uint256 rewardAll = burnToken.balanceOf(address(this));
        uint256 rewardAll = 0;//burnToken.balanceOf(address(this));

        if(stakedSupply > depositAmount){
            rewardAll = stakedSupply.sub(depositAmount);
        }
        if (depositAmount != 0) {
            //console.log(" ==user.amount %s =====rewardAll %s ==== stakedSupply %s  ==   ", user.amount, rewardAll,stakedSupply);

            uint256 pending = user.amount.mul(rewardAll).div(depositAmount);//.sub(user.rewardDebt);
            if(pending > 0) {
                lpToken.safeTransfer(address(msg.sender), pending);
                user.claimedReward = user.claimedReward.add(pending);
                inviterChef.assignInviteReward(msg.sender, pending);
            }
        }

        if(user.amount > 0 && depositAmount > user.amount) {
            lpToken.safeTransfer(address(msg.sender), user.amount);
            depositAmount = depositAmount.sub(user.amount);
            user.amount = 0;

        }

        emit Withdraw(msg.sender, user.amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() public {
        UserInfo storage user = userInfo[msg.sender];
        if(user.amount > 0 && depositAmount > user.amount) {
            lpToken.safeTransfer(address(msg.sender), user.amount);
            depositAmount = depositAmount.sub(user.amount);
            emit EmergencyWithdraw(msg.sender, user.amount);
            user.amount = 0;
            user.rewardDebt = 0;
            user.lockAmount = 0;
            user.claimedReward = 0;
        }
    }


    function emergencyRewardWithdraw(uint256 _amount) public onlyOwner {
        require(_amount < lpToken.balanceOf(address(this)), 'not enough token');
        lpToken.safeTransfer(address(msg.sender), _amount);
    }

    function setAdmin(address _adminAddress) public onlyOwner {
        adminAddress = _adminAddress;
    }

    function setBlackList(address _blacklistAddress) public onlyAdmin {
        userInfo[_blacklistAddress].inBlackList = true;
    }

    function removeBlackList(address _blacklistAddress) public onlyAdmin {
        userInfo[_blacklistAddress].inBlackList = false;
    }

}