// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (finance/VestingWallet.sol)
pragma solidity ^0.8.0;


import "./Address.sol";
import "./BEPPausable.sol";
import "./IBEP20.sol";
import "./IERC721Enumerable.sol";

contract VIMStake is BEPPausable {
    uint256 private daylyReward;
    address private admin;
    address public VIMContract;
    address public rewardSource;
    uint256 private StakeId;

    struct Stake{
        uint256 id;
        address user;
        uint256 amount;
        uint256 stakeAt;
        uint256 unStakeAt;
        uint256 lastTimeClaim;
    }

    uint256[] private allStake;

    mapping(uint256 => Stake) lstStake;
    mapping(address => uint256[]) lstStakeHolder;

    constructor() payable{
        StakeId = 0;
        daylyReward = 100;
        admin = 0x2602fB43b4e434c2e157E75E19B796cb011826c7;
        VIMContract = 0x5bcd91C734d665Fe426A5D7156f2aD7d37b76e30;
        rewardSource = 0x096dd27752c6F5eD5816C93EB4333e0c793abf62;
    }
 
    function setDaylyReward(uint256 _daylyReward) external onlyOwner{
        daylyReward = _daylyReward;
    }
    function setRewardSource(address _rewardSource) external onlyOwner{
        rewardSource = _rewardSource;
    }

    function stake(uint256 amount) external whenNotPaused{
        require(amount > 0,"amount > 0");
        require(IBEP20(VIMContract).allowance(msg.sender,address(this)) >= amount * 10**18,"The VIM allowed is not enough. You need approve more VIM");
        require(IBEP20(VIMContract).balanceOf(msg.sender) >= amount * 10**18,"The VIM is not enough.");
        
        IBEP20(VIMContract).transferFrom(msg.sender,address(this),amount * 10**18);

        StakeId = StakeId + 1;
        lstStake[StakeId] = Stake(StakeId, msg.sender, amount, block.timestamp, 0, block.timestamp/86400*86400);
        lstStakeHolder[msg.sender].push(StakeId);
        allStake.push(StakeId);
    }

    function unStake(uint256 stakeId) external whenNotPaused{
        require(lstStake[stakeId].user == msg.sender, "Can not unstake this");
        require(lstStake[stakeId].unStakeAt == 0, "Can not unstake this");
        lstStake[stakeId].unStakeAt = block.timestamp;
    }

    function stakeAt(uint256 amount, uint256 timestamp) external whenNotPaused{
        require(amount > 0,"amount > 0");
        require(IBEP20(VIMContract).allowance(msg.sender,address(this)) >= amount,"The VIM allowed is not enough. You need approve more VIM");
        require(IBEP20(VIMContract).balanceOf(msg.sender) >= amount * 10**18,"The VIM is not enough.");
        IBEP20(VIMContract).transferFrom(msg.sender,address(this),amount * 10**18);
        StakeId = StakeId + 1;
        lstStake[StakeId] = Stake(StakeId, msg.sender, amount, timestamp, 0, timestamp/86400*86400);
        lstStakeHolder[msg.sender].push(StakeId);
        allStake.push(StakeId);
    }

    function unStakeAt(uint256 stakeId, uint256 timestamp) external whenNotPaused{
        require(lstStake[stakeId].user == msg.sender, "stake not belong use");
        require(lstStake[stakeId].unStakeAt == 0, "Can not unstake this");
        lstStake[stakeId].unStakeAt = timestamp;
    }

    function claim(uint stakeId) external whenNotPaused{
        uint256 date = block.timestamp/86400*86400;
        require(lstStake[stakeId].amount > 0, "stake id not exist");
        require(lstStake[stakeId].user == msg.sender, "stake not belong use");
        require(lstStake[stakeId].lastTimeClaim < date, "Can not claim now");
        require(lstStake[stakeId].unStakeAt == 0, "Can not claim this stake");
        while(lstStake[stakeId].lastTimeClaim < date)
        {
            lstStake[stakeId].lastTimeClaim += 86400;
            uint256 stakeByDate = 0;
            for(uint256 i = 0; i < allStake.length; i++){
                if (lstStake[allStake[i]].stakeAt < lstStake[stakeId].lastTimeClaim &&
                 (lstStake[allStake[i]].unStakeAt > lstStake[stakeId].lastTimeClaim || lstStake[allStake[i]].unStakeAt == 0)){
                    stakeByDate += lstStake[allStake[i]].amount;
                }
            }
            uint256 reward = daylyReward * 10**18 * lstStake[stakeId].amount / stakeByDate;
            IBEP20(VIMContract).transferFrom(rewardSource,lstStake[stakeId].user,reward);
        }
    }

    function getStakeDate(uint256 timestamp) external view returns(uint256 totalAmount)
    {
        uint256 date = timestamp/86400*86400;
        uint256 stakeByDate = 0;
        for(uint256 i = 0; i < allStake.length; i++){
            if (lstStake[allStake[i]].stakeAt < date && (lstStake[allStake[i]].unStakeAt > date || lstStake[allStake[i]].unStakeAt == 0)){
                stakeByDate += lstStake[allStake[i]].amount;
            }
        }
        return (stakeByDate);
    }

    function getStake(uint256 stakeid) external view returns(Stake memory res)
    {
        res = lstStake[stakeid];
        return (res);
    }

    function getAllStake(address _address) external view returns(uint256[] memory holder)
    {
        return (lstStakeHolder[_address]);
    }



}