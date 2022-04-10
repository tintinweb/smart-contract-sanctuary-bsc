pragma solidity 0.6.12;

import './SafeMath.sol';
import './IBEP20.sol';
import './SafeBEP20.sol';
import './Ownable.sol';
//import "hardhat/console.sol";
pragma experimental ABIEncoderV2;

// SousChef is the chef of new bonusEndBlocktokens. He can make yummy food and he is a fair guy as well as MasterChef.
contract InviterChef is Ownable {

    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 inviteNumber;
        uint256 rewardInvite;
        uint256 rewardInviteQJI;   // 邀请的QJI 收益
        uint256 claimedRewardInviteQJI; // 已经领取
        uint256 claimedRewardInvite;
    }

    // The rewardToken TOKEN!
    IBEP20 public rewardToken;
    // burn token
    IBEP20 public rewardTokenQJI;

    // Info of each user that stakes rewardToken tokens.
    mapping(address => UserInfo) public userInfo;

    uint256 public inviteRate = 10;
    // adminAddress
    address public adminAddress;

    uint256 public inviterLength = 20;

    mapping(address => bool) public callerAccessable;

    struct Inviter {
        address account;
        uint256 inviteBlockNumber;
        uint256 inviteTimestamp;
    }

    //    mapping (address => address) public invitedBy;
    //    mapping (address => uint) public invitedNumOf;
    mapping(address => Inviter[]) memberInviter;
    mapping(address => address) inviter;

    event WithdrawInviteReward(address indexed user, uint256 amount);
    event WithdrawInviteRewardQJI(address indexed user, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "admin: wut?");
        _;
    }

    constructor(
        IBEP20 _rewardToken,
        IBEP20 _rewardTokenQJI
    ) public {
        rewardToken = _rewardToken;
        rewardTokenQJI = _rewardTokenQJI;
    }

    function getUserInviters(address a) public view returns (Inviter[] memory invit){
        return memberInviter[a];
    }

    function getParentInviter(address a) public view returns (address){
        return inviter[a];
    }


    function getInviteRewardAmount() external view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        return user.rewardInvite;
    }


    // Withdraw rewardToken tokens from SousChef.
    function withdrawInviteReward() public {

        UserInfo storage user = userInfo[msg.sender];

        uint256 rewardAll = rewardToken.balanceOf(address(this));
        if (user.rewardInvite > 0 && rewardAll > 0 && rewardAll >= user.rewardInvite) {
            rewardToken.safeTransfer(address(msg.sender), user.rewardInvite);
            user.claimedRewardInvite = user.claimedRewardInvite.add(user.rewardInvite);
            user.rewardInvite = 0;
        }

        emit WithdrawInviteReward(msg.sender, user.rewardInvite);
    }

    function withdrawInviteRewardQJI() public {

        UserInfo storage user = userInfo[msg.sender];

        uint256 rewardAll = rewardTokenQJI.balanceOf(address(this));
        if (user.rewardInviteQJI > 0 && rewardAll > 0 && rewardAll >= user.rewardInviteQJI) {
            rewardTokenQJI.safeTransfer(address(msg.sender), user.rewardInviteQJI);
            user.claimedRewardInviteQJI = user.claimedRewardInviteQJI.add(user.rewardInviteQJI);
            user.rewardInviteQJI = 0;
        }

        emit WithdrawInviteRewardQJI(msg.sender, user.rewardInviteQJI);
    }

    function getInviteRewardQJIAmount() external view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        return user.rewardInviteQJI;
    }

    function getClaimedInviteRewardQJIAmount() external view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        return user.claimedRewardInviteQJI;
    }

    function getClaimedInviteRewardAmount() external view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        return user.claimedRewardInvite;
    }

    function setAdmin(address _adminAddress) public onlyOwner {
        adminAddress = _adminAddress;
    }


    function setInviteRate(uint256 _inviteRate) public onlyAdmin {
        inviteRate = _inviteRate;
    }

    function setInviterLength(uint256 _inviterLength) public onlyAdmin {
        inviterLength = _inviterLength;
    }

    function setInviterAccess(address caller, bool canAccess) public onlyAdmin {
        callerAccessable[caller] = canAccess;
    }


    //    function addMemberInviter(address _inviter) public {
    //        address parent = inviter[msg.sender];
    //        if(parent == address(0) && _inviter != msg.sender){
    //            inviter[msg.sender] = _inviter;
    //            UserInfo storage user = user[_inviter];
    //            user.inviteNumber = user.inviteNumber.add(1);
    //        }
    //    }
    function addMemberInviter(address _inviter) public {

        require(msg.sender != _inviter, 'cannot invite yourself');
        address parent = inviter[msg.sender];
        if (parent == address(0) && _inviter != msg.sender) {
            inviter[msg.sender] = _inviter;

            if (memberInviter[_inviter].length >= inviterLength) {
                delete memberInviter[_inviter][0];
                for (uint256 i = 0; i < memberInviter[_inviter].length - 1; i++) {
                    memberInviter[_inviter][i] = memberInviter[_inviter][i + 1];
                }

                memberInviter[_inviter].pop();
            }
            memberInviter[_inviter].push(Inviter(msg.sender, block.number, block.timestamp));

        }
    }

    function assignInviteReward(address sender, uint256 amount) public {
        require(callerAccessable[msg.sender], 'cannot access');

        address inviter = inviter[sender];
        if(inviter!= address(0)&& inviteRate> 0){
            UserInfo storage user = userInfo[inviter];

            user.rewardInvite = user.rewardInvite.add(amount.mul(inviteRate).div(100));
        }

    }

    function assignInviteRewardQJI(address sender, uint256 amount) public {
        require(callerAccessable[msg.sender], 'cannot access');

        address inviter = inviter[sender];
        if(inviter!= address(0)&& inviteRate> 0){
            UserInfo storage user = userInfo[inviter];

            user.rewardInviteQJI = user.rewardInviteQJI.add(amount);
        }

    }


    //    function inviter(address inviterUser) external {
    //        require(msg.sender != governor, 'governor');
    //        require(msg.sender != inviterUser, 'cannot invite yourself');
    //        require(invitedBy[msg.sender]==address(0), 'repeated');
    //        invitedNumOf[inviterUser] = invitedNumOf[inviterUser].add(1);
    //        invitedBy[msg.sender] = inviterUser;
    //    }
}