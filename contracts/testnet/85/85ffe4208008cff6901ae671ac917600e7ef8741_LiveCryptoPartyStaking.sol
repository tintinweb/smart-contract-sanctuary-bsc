/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-04
 */

pragma solidity ^0.8.10;

// SPDX-License-Identifier: MIT

// Treat people with kindness: Rosie
// All copyrights, trademarks and patents belongs to Live Crypto Party livecryptoparty.com

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

interface IERC721 {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);
}

interface oldStaking {
    struct Stake {
        uint256 plan;
        uint256 withdrawtime;
        uint256 staketime;
        uint256 amount;
        uint256 reward;
        uint256 persecondreward;
        bool withdrawan;
        bool unstaked;
    }

    struct User {
        uint256 totalStakedTokenUser;
        uint256 totalWithdrawanTokenUser;
        uint256 totalUnStakedTokenUser;
        uint256 totalClaimedRewardTokenUser;
        uint256 stakeCount;
        bool alreadyExists;
    }

    function stakersRecord(address staker, uint256 index)
        external
        view
        returns (Stake memory stakeData);

    function Stakers(address staker) external view returns (User memory user);
}

contract LiveCryptoPartyStaking {
    using SafeMath for uint256;
    IERC20 public stakeToken;
    oldStaking public oldStakingAddress;
    IERC721 goldNFT;
    IERC721 silverNFT;

    address payable public owner;
    address payable public feeReciever =
        payable(0xFA8FA2Ef81A7931fC97F7617FDFE81585B5F735E);
    uint256 public unstakePenaltyFee = 0.005 ether;
    uint256 public claimFee = 0.002 ether;

    uint256 public totalStakedLCP;
    uint256 public totalUnStakedLCP;
    uint256 public totalWithdrawanLCP;
    uint256 public totalClaimedRewardLCP;
    uint256 public totalStakersLCP;
    uint256 public percentDivider;
    bool public pauseStaking;

    mapping(address => bool) public _isExcludedFromReward;

    uint256[100] public Duration = [3 minutes, 6 minutes, 9 minutes];
    uint256[100] public Bonus = [75, 150, 300];
    uint256[100] public totalStakedPerPlanLCP;
    uint256[100] public totalStakersPerPlanLCP;
    uint256 public counter = 3;

    uint256 public goldMaxStakingAmount ;
    uint256 public silverMaxStakingAmount ;

    struct StakeLCP {
        uint256 planLCP;
        uint256 withdrawtimeLCP;
        uint256 staketimeLCP;
        uint256 amountLCP;
        uint256 rewardLCP;
        uint256 persecondrewardLCP;
        bool withdrawanLCP;
        bool unstakedLCP;
    }

    struct UserLCP {
        uint256 totalStakedTokenUserLCP;
        uint256 totalTokensCurrentlyStaked;
        uint256 totalWithdrawanTokenUserLCP;
        uint256 totalUnStakedTokenUserLCP;
        uint256 remainingPendingAmount;
        uint256 totalClaimedRewardTokenUserLCP;
        uint256 stakeCountLCP;
        bool alreadyExistsLCP;
    }

    struct NFTRecord {
        bool exists;
        address owner;
    }

    mapping(address => UserLCP) public StakersLCP;
    mapping(uint256 => address) public StakersIDLCP;
    mapping(address => mapping(uint256 => StakeLCP)) public stakersRecordLCP;
    mapping(address => mapping(uint256 => uint256)) public userStakedPerPlanLCP;
    mapping(uint256 => mapping(uint256 => NFTRecord)) public stakedNFTData;
    mapping(uint256 => uint256) public stakedNFTCount;

    event STAKE(address Staker, uint256 amount);
    event UNSTAKE(address Staker, uint256 amount);
    event RESTAKE(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);

    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    constructor(
    ) {
        owner = payable(0xFA8FA2Ef81A7931fC97F7617FDFE81585B5F735E);
        stakeToken = IERC20(0x9E37efb8Ebf9eb8831bFCA312B215c78759785F5);
        percentDivider = 1000;
        oldStakingAddress = oldStaking(0x201d598EDc3e5150581DC87f3D7689Ecdc3293e6);
        goldNFT = IERC721(0x013Cb7bCdE5070920034FFA7883eA2a8751292d9);
        silverNFT = IERC721(0x013Cb7bCdE5070920034FFA7883eA2a8751292d9);
        goldMaxStakingAmount = 2_000_00 * (10**stakeToken.decimals());
        silverMaxStakingAmount = 5_00_00 * (10**stakeToken.decimals());

    }

    function stakeNFT(uint256 _nft, uint256 _id) external {
        require(
            _nft == 0 || _nft == 1,
            "Please  add '0' for Gold Nft & '1' for silver NFT"
        );

        if (_nft == 0) {
            goldNFT.transferFrom(msg.sender, address(this), _id);
            stakedNFTCount[0]++;
            stakedNFTData[0][_id].exists = true;
            stakedNFTData[0][_id].owner = msg.sender;
        }
        if (_nft == 1) {
            silverNFT.transferFrom(msg.sender, address(this), _id);
            stakedNFTCount[1]++;
            stakedNFTData[1][_id].exists = true;
            stakedNFTData[1][_id].owner = msg.sender;
        }
    }

    function stake(uint256 amount, uint256 planIndex) public {
        require(planIndex >= 0 && planIndex <= 9, "Invalid Time Period");
        require(amount >= 0, "stake more than 0");
        require(!pauseStaking, "staking is paused");

        uint256 goldNFTStaked = stakedNFTCount[0];
        uint256 silverNFTStaked = stakedNFTCount[1];
        // uint256 silverNFTBalance = silverNFT.balanceOf(msg.sender);
        require(
            goldNFTStaked >= 1 || silverNFTStaked >= 1,
            "Please hold LCP NFT first, At this moment you are unable to stake !"
        );

        uint256 allowedAmount;
        if (goldNFTStaked >= 1) {
            allowedAmount = allowedAmount.add(
                goldNFTStaked.mul(goldMaxStakingAmount)
            );
        }
        if (goldNFTStaked >= 1) {
            allowedAmount = allowedAmount.add(
                silverNFTStaked.mul(goldMaxStakingAmount)
            );
        }

        require(
            StakersLCP[msg.sender].totalTokensCurrentlyStaked.add(amount) <=
                allowedAmount,
            "You cannot stake amount greater than Max Limit !"
        );

        if (!StakersLCP[msg.sender].alreadyExistsLCP) {
            StakersLCP[msg.sender].alreadyExistsLCP = true;
            StakersIDLCP[totalStakersLCP] = msg.sender;
            totalStakersLCP++;
        }

        storeData(msg.sender, amount, planIndex);
        stakeToken.transferFrom(msg.sender, address(this), amount);

        emit STAKE(msg.sender, amount);
    }

    function unstakeNFT(uint256 _nft, uint256 _id) external {
        require(
            _nft == 0 || _nft == 1,
            "Please  add '0' for Gold Nft & '1' for silver NFT"
        );

        require(
            stakedNFTCount[0] > 0 || stakedNFTCount[1] > 0,
            "Currently you dont have any staked NFT"
        );

        require(
            StakersLCP[msg.sender].remainingPendingAmount == 0,
            "Please unstake all your stakings first !"
        );

        require(
            stakedNFTData[_nft][_id].exists &&
                stakedNFTData[_nft][_id].owner == msg.sender,
            "Currently this token is not stake !"
        );

        if (_nft == 0) {
            goldNFT.transferFrom(address(this), msg.sender, _id);
            delete stakedNFTData[1][_id];
            stakedNFTCount[0]--;
        }

        if (_nft == 1) {
            silverNFT.transferFrom(address(this), msg.sender, _id);
            delete stakedNFTData[1][_id];
            stakedNFTCount[1]--;
        }
    }

    function storeData(
        address user,
        uint256 amount,
        uint256 planIndex
    ) internal {
        uint256 index = StakersLCP[user].stakeCountLCP;
        StakersLCP[user].totalStakedTokenUserLCP = StakersLCP[user]
            .totalStakedTokenUserLCP
            .add(amount);

        totalStakedLCP = totalStakedLCP.add(amount);
        stakersRecordLCP[user][index].withdrawtimeLCP = block.timestamp.add(
            Duration[planIndex]
        );
        stakersRecordLCP[user][index].staketimeLCP = block.timestamp;
        stakersRecordLCP[user][index].amountLCP = amount;
        stakersRecordLCP[user][index].rewardLCP = amount
            .mul(Bonus[planIndex])
            .div(percentDivider);
        stakersRecordLCP[user][index].persecondrewardLCP = stakersRecordLCP[
            user
        ][index].rewardLCP.div(Duration[planIndex]);
        stakersRecordLCP[user][index].planLCP = planIndex;
        StakersLCP[user].stakeCountLCP++;
        userStakedPerPlanLCP[user][planIndex] = userStakedPerPlanLCP[user][
            planIndex
        ].add(amount);
        totalStakedPerPlanLCP[planIndex] = totalStakedPerPlanLCP[planIndex].add(
            amount
        );

        StakersLCP[user].remainingPendingAmount = StakersLCP[user]
            .remainingPendingAmount
            .add(
                stakersRecordLCP[user][index].rewardLCP.add(
                    stakersRecordLCP[msg.sender][index].amountLCP
                )
            );

        StakersLCP[user].totalTokensCurrentlyStaked = StakersLCP[user]
            .totalTokensCurrentlyStaked
            .add(stakersRecordLCP[msg.sender][index].amountLCP);
        totalStakersPerPlanLCP[planIndex]++;
    }

    function unstake(uint256 index) public payable {
        require(msg.value >= unstakePenaltyFee, "Insufficient Funds");
        require(
            !stakersRecordLCP[msg.sender][index].withdrawanLCP,
            "already withdrawan"
        );
        require(
            !stakersRecordLCP[msg.sender][index].unstakedLCP,
            "already unstaked"
        );
        require(index < StakersLCP[msg.sender].stakeCountLCP, "Invalid index");

        stakersRecordLCP[msg.sender][index].unstakedLCP = true;

        stakeToken.transfer(
            msg.sender,
            stakersRecordLCP[msg.sender][index].amountLCP
        );

        StakersLCP[msg.sender].totalTokensCurrentlyStaked = StakersLCP[
            msg.sender
        ].totalTokensCurrentlyStaked.sub(
                stakersRecordLCP[msg.sender][index].amountLCP
            );
        totalUnStakedLCP = totalUnStakedLCP.add(
            stakersRecordLCP[msg.sender][index].amountLCP
        );
        feeReciever.transfer(msg.value);
        StakersLCP[msg.sender].totalUnStakedTokenUserLCP = StakersLCP[
            msg.sender
        ].totalUnStakedTokenUserLCP.add(
                stakersRecordLCP[msg.sender][index].amountLCP
            );
        uint256 planIndex = stakersRecordLCP[msg.sender][index].planLCP;
        userStakedPerPlanLCP[msg.sender][planIndex] = userStakedPerPlanLCP[
            msg.sender
        ][planIndex].sub(
                stakersRecordLCP[msg.sender][index].amountLCP,
                "user stake"
            );
        totalStakedPerPlanLCP[planIndex] = totalStakedPerPlanLCP[planIndex].sub(
            stakersRecordLCP[msg.sender][index].amountLCP,
            "total stake"
        );

        StakersLCP[msg.sender].remainingPendingAmount = StakersLCP[msg.sender]
            .remainingPendingAmount
            .sub(stakersRecordLCP[msg.sender][index].amountLCP);

        totalStakersPerPlanLCP[planIndex]--;

        emit UNSTAKE(msg.sender, stakersRecordLCP[msg.sender][index].amountLCP);
    }

    function withdraw(uint256 index) public payable {
        require(msg.value >= claimFee, "Insufficient Funds");
        require(!_isExcludedFromReward[msg.sender], "excluded from reward");
        require(
            !stakersRecordLCP[msg.sender][index].withdrawanLCP,
            "already withdrawan"
        );
        require(
            !stakersRecordLCP[msg.sender][index].unstakedLCP,
            "already unstaked"
        );
        require(
            stakersRecordLCP[msg.sender][index].withdrawtimeLCP <
                block.timestamp,
            "cannot withdraw before stake duration"
        );
        require(index < StakersLCP[msg.sender].stakeCountLCP, "Invalid index");

        stakersRecordLCP[msg.sender][index].withdrawanLCP = true;
        stakeToken.transfer(
            msg.sender,
            stakersRecordLCP[msg.sender][index].amountLCP
        );
        stakeToken.transferFrom(
            owner,
            msg.sender,
            stakersRecordLCP[msg.sender][index].rewardLCP
        );
        feeReciever.transfer(msg.value);
        totalWithdrawanLCP = totalWithdrawanLCP.add(
            stakersRecordLCP[msg.sender][index].amountLCP
        );
        totalClaimedRewardLCP = totalClaimedRewardLCP.add(
            stakersRecordLCP[msg.sender][index].rewardLCP
        );
        StakersLCP[msg.sender].totalWithdrawanTokenUserLCP = StakersLCP[
            msg.sender
        ].totalWithdrawanTokenUserLCP.add(
                stakersRecordLCP[msg.sender][index].amountLCP
            );
        StakersLCP[msg.sender].totalClaimedRewardTokenUserLCP = StakersLCP[
            msg.sender
        ].totalClaimedRewardTokenUserLCP.add(
                stakersRecordLCP[msg.sender][index].rewardLCP
            );

        StakersLCP[msg.sender].remainingPendingAmount = StakersLCP[msg.sender]
            .remainingPendingAmount
            .sub(
                stakersRecordLCP[msg.sender][index].amountLCP.add(
                    stakersRecordLCP[msg.sender][index].rewardLCP
                )
            );

        StakersLCP[msg.sender].totalTokensCurrentlyStaked = StakersLCP[
            msg.sender
        ].totalTokensCurrentlyStaked.sub(
                stakersRecordLCP[msg.sender][index].amountLCP
            );

        uint256 planIndex = stakersRecordLCP[msg.sender][index].planLCP;
        userStakedPerPlanLCP[msg.sender][planIndex] = userStakedPerPlanLCP[
            msg.sender
        ][planIndex].sub(
                stakersRecordLCP[msg.sender][index].amountLCP,
                "user stake"
            );
        totalStakedPerPlanLCP[planIndex] = totalStakedPerPlanLCP[planIndex].sub(
            stakersRecordLCP[msg.sender][index].amountLCP,
            "total stake"
        );
        totalStakersPerPlanLCP[planIndex]--;

        emit WITHDRAW(
            msg.sender,
            stakersRecordLCP[msg.sender][index].rewardLCP.add(
                stakersRecordLCP[msg.sender][index].amountLCP
            )
        );
    }

    function reStake() public {
        require(!StakersLCP[msg.sender].alreadyExistsLCP, "already restaked");
        StakersLCP[msg.sender].alreadyExistsLCP = true;
        StakersIDLCP[totalStakersLCP] = msg.sender;
        totalStakersLCP++;

        uint256 totalOldStaked;
        oldStaking.User memory userOldData = oldStakingAddress.Stakers(
            msg.sender
        );
        uint256 oldStakeCount = userOldData.stakeCount;

        for (uint256 i = 0; i < oldStakeCount; i++) {
            oldStaking.Stake memory userOldStake = oldStakingAddress
                .stakersRecord(msg.sender, i);
            uint256 planIndex = userOldStake.plan;
            if (!userOldStake.unstaked && !userOldStake.withdrawan) {
                uint256 rewardTime;
                if (block.timestamp >= userOldStake.withdrawtime) {
                    rewardTime =
                        userOldStake.withdrawtime -
                        userOldStake.staketime;
                } else {
                    rewardTime = block.timestamp - userOldStake.staketime;
                }
                uint256 rewardAmount = rewardTime.mul(
                    userOldStake.persecondreward
                );
                uint256 amountBefore = userOldStake.amount;
                uint256 totalrestaked = amountBefore.add(rewardAmount);
                totalOldStaked += totalrestaked;
                storeData(msg.sender, totalrestaked, planIndex);
            }
        }

        stakeToken.transferFrom(owner, address(this), totalOldStaked);

        emit RESTAKE(msg.sender, totalOldStaked);
    }

    function SetStakeDuration(uint256 index, uint256 duration)
        external
        onlyowner
    {
        Duration[index] = duration;
    }

    function SetFees(
        address payable _feeReciever,
        uint256 _penaltyFee,
        uint256 _claimFee
    ) external onlyowner {
        feeReciever = _feeReciever;
        unstakePenaltyFee = _penaltyFee;
        claimFee = _claimFee;
    }

    function SetStakeBonus(uint256 index, uint256 bonus) external onlyowner {
        Bonus[index] = bonus;
    }

    function addNewStakePlan(uint256 duration, uint256 bonus)
        external
        onlyowner
    {
        require(counter <= 100, "plan exceeds limit");
        Duration[counter] = duration;
        Bonus[counter] = bonus;
        counter++;
    }

    function PauseStaking(bool _pause) external onlyowner {
        pauseStaking = _pause;
    }

    function setSilverMaxStakingAmount(uint256 _amount) external onlyowner {
        silverMaxStakingAmount = _amount;
    }

    function setGoldMaxStakingAmount(uint256 _amount) external onlyowner {
        goldMaxStakingAmount = _amount;
    }

    function ExcludeFromReward(address staker, bool _state) external onlyowner {
        _isExcludedFromReward[staker] = _state;
    }

    function realtimeReward(address user) public view returns (uint256) {
        uint256 ret;
        for (uint256 i; i < StakersLCP[user].stakeCountLCP; i++) {
            if (
                !stakersRecordLCP[user][i].withdrawanLCP &&
                !stakersRecordLCP[user][i].unstakedLCP
            ) {
                uint256 val;
                val = block.timestamp - stakersRecordLCP[user][i].staketimeLCP;
                val = val.mul(stakersRecordLCP[user][i].persecondrewardLCP);
                if (val < stakersRecordLCP[user][i].rewardLCP) {
                    ret += val;
                } else {
                    ret += stakersRecordLCP[user][i].rewardLCP;
                }
            }
        }
        return ret;
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