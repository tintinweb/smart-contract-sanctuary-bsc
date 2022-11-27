// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

struct Main {
    uint256 totalUsers;
    uint256 totalCompounds;
    uint256 totalWith;
    uint256 totalStakeNumber;
    uint256 totalMemberNumber;
    uint256 totalRoundReward;
    address previousRewardWinner;
    uint256 previousRewardAmount;
    uint256 previousRewardPercentage;
}
struct User {
    uint256 startDate;
    uint256 activeStakeCounter;
    uint256 totalStake;
    uint256 totalWith;
    uint256 lastWith;
    Depo[] depoList;
    address ref;
    uint256 bonus;
    uint256 totalBonus;
    uint256[3] levels;
    uint256 memberType;
}
struct DivPercs {
    uint256 daysInSeconds;
    uint256 divsPercentage;
    uint16[4] feePercentage;
}
struct Depo {
    uint256 key;
    uint256 depoTime;
    uint256 amt;
    bool validated;
}
struct Member {
    uint256 percentageReward;
    uint72[3] price;
    uint8[3] refPercentage;
}
struct Reward {
    uint256 balance;
    address payable[] participants;
    uint256 participantCount;
    address winner;
    uint256 winnerAmount;
    uint256 winnerPercentage;
    bool payout;
}

contract TestFarm is Context, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    // uint256 constant firstlaunch = 1664600400; //fixed to October 1st, 2022

    uint256 constant hardDays = 1 days;
    uint256 constant hardMinutes = 30 minutes;
    uint256 constant percentdiv = 1000;
    uint256 constant minDeposit = 50 ether;
    uint256 immutable feeStake = 100;
    uint256 immutable feeReinvest = 50;

    uint256 private dateLaunched;
    bool private rewardWinnerEnabled = true;
    
    mapping(uint256 => Main) public MainKey;
    mapping(address => User) public UsersKey;
    mapping(uint256 => DivPercs) public PercsKey;
    mapping(uint256 => Member) public MemberKey;
    mapping(uint256 => Reward) public RewardKey;

    IERC20 private BUSD = IERC20(0x1A3cf138BB72db9F64F42236FD4728B6e2d84941);
    address private immutable dApp;
    address private immutable devOwner;

    constructor(address _devOwner) {
        dateLaunched = block.timestamp;

        PercsKey[10] = DivPercs({daysInSeconds:  10 days, divsPercentage:  10, feePercentage: [uint16(500), 400, 300, 200]});
        PercsKey[20] = DivPercs({daysInSeconds:  20 days, divsPercentage:  10, feePercentage: [uint16(470), 370, 280, 180]});
        PercsKey[30] = DivPercs({daysInSeconds:  30 days, divsPercentage:  20, feePercentage: [uint16(440), 340, 260, 160]});
        PercsKey[40] = DivPercs({daysInSeconds:  40 days, divsPercentage:  30, feePercentage: [uint16(410), 310, 240, 140]});
        PercsKey[50] = DivPercs({daysInSeconds:  50 days, divsPercentage:  40, feePercentage: [uint16(380), 280, 220, 120]});
        PercsKey[60] = DivPercs({daysInSeconds:  60 days, divsPercentage:  50, feePercentage: [uint16(350), 250, 200, 100]});
        PercsKey[70] = DivPercs({daysInSeconds:  70 days, divsPercentage:  60, feePercentage: [uint16(320), 230, 180, 80]});
        PercsKey[80] = DivPercs({daysInSeconds:  80 days, divsPercentage:  70, feePercentage: [uint16(290), 210, 160, 60]});
        PercsKey[90] = DivPercs({daysInSeconds:  90 days, divsPercentage:  80, feePercentage: [uint16(260), 190, 140, 40]});
        PercsKey[100]= DivPercs({daysInSeconds: 100 days, divsPercentage:  90, feePercentage: [uint16(230), 170, 120, 20]});
        PercsKey[110]= DivPercs({daysInSeconds: 101 days, divsPercentage: 100, feePercentage: [uint16(200), 150, 100, 0]});

        MemberKey[0] = Member({percentageReward: 10, price: [uint72(50 ether), 100 ether, 250 ether], refPercentage: [50, 30, 20]});
        MemberKey[1] = Member({percentageReward: 20, price: [uint72(0 ether),  50 ether,  200 ether], refPercentage: [60, 40, 30]});
        MemberKey[2] = Member({percentageReward: 30, price: [uint72(0 ether),  0 ether,   150 ether], refPercentage: [70, 50, 30]});
        MemberKey[3] = Member({percentageReward: 50, price: [uint72(0 ether),  0 ether,   0 ether],   refPercentage: [80, 60, 40]});

        dApp = payable(msg.sender);
        devOwner = payable(_devOwner);
    }

    function Stake(uint256 _amt, address _ref) public payable {
        // require(block.timestamp >= firstlaunch, "App did not launch yet.");
        require(_ref != msg.sender, "You cannot refer yourself!");
        require(_amt >= minDeposit, "Min Investment 50 BUSD!");

        BUSD.safeTransferFrom(msg.sender, address(this), _amt);

        Main storage main = MainKey[1];
        User storage user = UsersKey[msg.sender];
        Member storage userMember = MemberKey[user.memberType];
        Reward storage reward = RewardKey[getCurrentDay()];

        uint256 stakeFee = _amt.mul(feeStake).div(percentdiv);
        uint256 adjustedAmt = _amt.sub(stakeFee);

        if (user.ref == address(0) && msg.sender != devOwner) {
            user.ref = UsersKey[_ref].depoList.length == 0 ? devOwner : _ref;
			address upline = user.ref;
            User storage userRef = UsersKey[upline];
			for (uint256 i = 0; i < MemberKey[0].refPercentage.length; i++) {
				if (upline != address(0)) {
                    userRef.levels[i].add(1);
					upline = userRef.ref;
				} else break;
			}
		}

		if (user.ref != address(0)) {
            address upline = user.ref;
            if(user.memberType == 0 || UsersKey[upline].memberType == 0) {
                for (uint256 i = 0; i < MemberKey[0].refPercentage.length; i++) {
                    upline = upline == address(0) ? devOwner : upline;
                    uint256 amount = adjustedAmt.mul(MemberKey[0].refPercentage[i]).div(percentdiv);
                    UsersKey[upline].bonus = UsersKey[upline].bonus.add(amount);
                    UsersKey[upline].totalBonus = UsersKey[upline].totalBonus.add(amount);
                    upline = UsersKey[upline].ref;
                }
            } else if(user.memberType > 0 && user.memberType <= 3 && UsersKey[upline].memberType > 0 && UsersKey[upline].memberType <= 3){
                for (uint256 i = 0; i < userMember.refPercentage.length; i++) {
                    upline = upline == address(0) ? devOwner : upline;
                    uint256 amount = adjustedAmt.mul(MemberKey[UsersKey[upline].memberType].refPercentage[i]).div(percentdiv);
                    UsersKey[upline].bonus = UsersKey[upline].bonus.add(amount);
                    UsersKey[upline].totalBonus = UsersKey[upline].totalBonus.add(amount);
                    upline = UsersKey[upline].ref;
                }
            }
		}

        user.depoList.push(
            Depo({
                key: user.depoList.length,
                depoTime: block.timestamp,
                amt: adjustedAmt,
                validated: false
            })
        );

        main.totalStakeNumber += 1;
        if(user.startDate == 0){
            main.totalUsers += 1;
            user.lastWith = block.timestamp;
            user.startDate = block.timestamp;
        }
        user.totalStake += adjustedAmt;
        user.activeStakeCounter += 1;

        BUSD.safeTransfer(dApp, stakeFee);

        if(rewardWinnerEnabled){
            if(!checkPartecipantExist(msg.sender, getCurrentDay())) {
                reward.balance += adjustedAmt;
                reward.participants.push(payable(msg.sender));
                reward.participantCount += 1;
            }
            RewardWinner();
        }
    }

    function Unstake(uint256 _key) public payable {
        Main storage main = MainKey[1];
        User storage user = UsersKey[msg.sender];
        Reward storage reward = RewardKey[getCurrentDay()];
        require(!user.depoList[_key].validated, "This stake has already been withdrawn."); // CHECK
        
        uint256 dailyReturn;
        uint256 transferAmt;
        uint256 amount = user.depoList[_key].amt;
        uint256 elapsedTime = block.timestamp.sub(user.depoList[_key].depoTime);
        
        if (elapsedTime <= PercsKey[10].daysInSeconds){
            dailyReturn = amount.mul(PercsKey[10].divsPercentage).div(percentdiv);
            transferAmt = amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[10].feePercentage[user.memberType]).div(percentdiv));
        } else if (elapsedTime > PercsKey[10].daysInSeconds && elapsedTime <= PercsKey[20].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[20].divsPercentage).div(percentdiv);
            transferAmt = amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[20].feePercentage[user.memberType]).div(percentdiv));
        } else if (elapsedTime > PercsKey[20].daysInSeconds && elapsedTime <= PercsKey[30].daysInSeconds){
            dailyReturn = amount.mul(PercsKey[30].divsPercentage).div(percentdiv);
            transferAmt = amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[30].feePercentage[user.memberType]).div(percentdiv));
        } else if (elapsedTime > PercsKey[30].daysInSeconds && elapsedTime <= PercsKey[40].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[40].divsPercentage).div(percentdiv);
            transferAmt = amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[40].feePercentage[user.memberType]).div(percentdiv));
        } else if (elapsedTime > PercsKey[40].daysInSeconds && elapsedTime <= PercsKey[50].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[50].divsPercentage).div(percentdiv);
            transferAmt = amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[50].feePercentage[user.memberType]).div(percentdiv));
        } else if (elapsedTime > PercsKey[50].daysInSeconds && elapsedTime <= PercsKey[60].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[60].divsPercentage).div(percentdiv);
            transferAmt = amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[60].feePercentage[user.memberType]).div(percentdiv));
        } else if (elapsedTime > PercsKey[60].daysInSeconds && elapsedTime <= PercsKey[70].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[70].divsPercentage).div(percentdiv);
            transferAmt = amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[70].feePercentage[user.memberType]).div(percentdiv));
        } else if (elapsedTime > PercsKey[70].daysInSeconds && elapsedTime <= PercsKey[80].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[80].divsPercentage).div(percentdiv);
            transferAmt = amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[80].feePercentage[user.memberType]).div(percentdiv));
        } else if (elapsedTime > PercsKey[80].daysInSeconds && elapsedTime <= PercsKey[90].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[90].divsPercentage).div(percentdiv);
            transferAmt = amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[90].feePercentage[user.memberType]).div(percentdiv));
        } else if (elapsedTime > PercsKey[90].daysInSeconds && elapsedTime <= PercsKey[100].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[100].divsPercentage).div(percentdiv);
            transferAmt = amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[100].feePercentage[user.memberType]).div(percentdiv));
        } else if (elapsedTime > PercsKey[110].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[110].divsPercentage).div(percentdiv);
            transferAmt = amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[110].feePercentage[user.memberType]).div(percentdiv));
        } else {
            revert("Cannot calculate user's staked days.");
        }

        BUSD.safeTransfer(msg.sender, transferAmt);

        if(rewardWinnerEnabled){
            if(block.timestamp - user.depoList[_key].depoTime < hardMinutes){ // hardDays
                for (uint i = 0; i < reward.participants.length; i++) {
                    if (reward.participants[i] == msg.sender) {
                        reward.balance -= amount;
                        delete reward.participants[i];
                        reward.participantCount -= 1;
                    }
                }
            }
            RewardWinner();
        }

        main.totalWith += transferAmt;
        main.totalStakeNumber -= 1;
        user.lastWith = block.timestamp;
        user.totalWith += transferAmt;
        user.activeStakeCounter -= 1;
        user.totalStake -= user.depoList[_key].amt;
        user.depoList[_key].amt = 0;
        user.depoList[_key].validated = true;
        user.depoList[_key].depoTime = block.timestamp;
    }

    function Reinvest(uint256 _key) public payable {
        // require(block.timestamp >= firstlaunch, "App did not launch yet.");
        User storage user = UsersKey[msg.sender];
        uint256 calc;
        if(_key == 0){ calc = CalculateEarnings(msg.sender); } else if(_key == 1){ calc = user.bonus; } else { calc = 0; }
        // require(calc >= 50, "Min Investment 50 BUSD!");

        for (uint256 i = 0; i < user.depoList.length; i++) {
            if (user.depoList[i].validated == false) {
                user.depoList[i].depoTime = block.timestamp;
            }
        }

        Main storage main = MainKey[1];
        Member storage userMember = MemberKey[user.memberType];
        Reward storage reward = RewardKey[getCurrentDay()];

        uint256 reinvestFee = calc.mul(feeReinvest).div(percentdiv);
        uint256 adjustedAmt = calc.sub(reinvestFee);

        user.ref = (user.ref == address(0) && msg.sender != devOwner) ? devOwner: user.ref;
        address upline = user.ref;
        if(user.memberType == 0 || UsersKey[upline].memberType == 0) {
            for (uint256 i = 0; i < MemberKey[0].refPercentage.length; i++) {
                upline = (upline == address(0) && msg.sender != devOwner ) ? devOwner : upline;
                uint256 amount = adjustedAmt.mul(MemberKey[0].refPercentage[i]).div(percentdiv);
                UsersKey[upline].bonus = UsersKey[upline].bonus.add(amount);
                UsersKey[upline].totalBonus = UsersKey[upline].totalBonus.add(amount);
                upline = UsersKey[upline].ref;
            }
        } else if(user.memberType > 0 && user.memberType <= 3 && UsersKey[upline].memberType > 0 && UsersKey[upline].memberType <= 3){
            for (uint256 i = 0; i < userMember.refPercentage.length; i++) {
                upline = (upline == address(0) && msg.sender != devOwner) ? devOwner : upline;
                uint256 amount = adjustedAmt.mul(MemberKey[UsersKey[upline].memberType].refPercentage[i]).div(percentdiv);
                UsersKey[upline].bonus = UsersKey[upline].bonus.add(amount);
                UsersKey[upline].totalBonus = UsersKey[upline].totalBonus.add(amount);
                upline = UsersKey[upline].ref;
            }
        }

        user.depoList.push(
            Depo({
                key: user.activeStakeCounter,
                depoTime: block.timestamp,
                amt: adjustedAmt,
                validated: false
            })
        );

        main.totalStakeNumber += 1;
        user.activeStakeCounter += 1;
        user.totalStake += adjustedAmt;
        user.bonus = (_key == 1) ? 0 : user.bonus;

        BUSD.safeTransfer(dApp, reinvestFee);

        if(rewardWinnerEnabled){
            if(!checkPartecipantExist(msg.sender, getCurrentDay())) {
                reward.balance += adjustedAmt;
                reward.participants.push(payable(msg.sender));
                reward.participantCount += 1;
            }
            RewardWinner();
        }
    }

    function Compound() public {
        Main storage main = MainKey[1];
        User storage user = UsersKey[msg.sender];

        uint256 calc = CalculateEarnings(msg.sender);

        for (uint256 i = 0; i < user.depoList.length; i++) {
            if (user.depoList[i].validated == false) {
                user.depoList[i].depoTime = block.timestamp;
            }
        }

        user.depoList.push(
            Depo({
                key: user.activeStakeCounter,
                depoTime: block.timestamp,
                amt: calc,
                validated: false
            })
        );

        main.totalStakeNumber += 1;
        main.totalCompounds += 1;
        user.activeStakeCounter += 1;
        user.totalStake += calc;
    }

    function Collect() public {
        Main storage main = MainKey[1];
        User storage user = UsersKey[msg.sender];

        uint256 calc = CalculateEarnings(msg.sender);

        for (uint256 i = 0; i < user.depoList.length; i++) {
            if (user.depoList[i].validated == false) {
                user.depoList[i].depoTime = block.timestamp;
            }
        }

        BUSD.safeTransfer(msg.sender, calc);

        main.totalWith += calc;
        user.totalWith += calc;
        user.lastWith = block.timestamp;
    }

    function CompoundRef() public {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];

        require(user.bonus > 10 ether);

        user.depoList.push(
            Depo({
                key: user.activeStakeCounter,
                depoTime: block.timestamp,
                amt: user.bonus,
                validated: false
            })
        );

        main.totalStakeNumber += 1;
        main.totalCompounds += 1;
        user.activeStakeCounter += 1;
        user.totalStake += user.bonus;
        user.bonus = 0;
    }

    function CollectRef() public {
        User storage user = UsersKey[msg.sender];

        uint totalAmount = UsersKey[msg.sender].bonus;

		require(totalAmount > 0, "User has no dividends");
        BUSD.safeTransfer(msg.sender, totalAmount);

        user.bonus = 0;
    }

    function CalculateEarnings(address _dy) public view returns (uint256) {
        User storage user = UsersKey[_dy];	

        uint256 totalWithdrawable;
        
        for (uint256 i = 0; i < user.depoList.length; i++){	
            uint256 elapsedTime = block.timestamp.sub(user.depoList[i].depoTime);
            uint256 amount = user.depoList[i].amt;

            if (user.depoList[i].validated == false){

                if (elapsedTime <= PercsKey[10].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[10].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[10].daysInSeconds && elapsedTime <= PercsKey[20].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[20].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[20].daysInSeconds && elapsedTime <= PercsKey[30].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[30].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[30].daysInSeconds && elapsedTime <= PercsKey[40].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[40].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[40].daysInSeconds && elapsedTime <= PercsKey[50].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[50].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[50].daysInSeconds && elapsedTime <= PercsKey[60].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[60].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[60].daysInSeconds && elapsedTime <= PercsKey[70].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[70].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[70].daysInSeconds && elapsedTime <= PercsKey[80].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[80].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[80].daysInSeconds && elapsedTime <= PercsKey[90].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[90].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[90].daysInSeconds && elapsedTime <= PercsKey[100].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[100].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[110].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[110].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
            } 
        }
        return totalWithdrawable;
    }

    function JoinMember(uint256 _key) public payable {
        // require(block.timestamp < firstlaunch, "You can only join Member before the Member launch");
        Main storage main = MainKey[1];
        User storage user = UsersKey[msg.sender];

        require(user.activeStakeCounter == 0, "You have active investments!");
        require(_key > 0 && _key <= 3, "Invalid selection!");
        require(user.memberType < _key, "You have a better plan!");

        Member storage userMember = MemberKey[user.memberType];

        uint256 _amt = userMember.price[_key - 1];

        require(_amt > 0 && _amt <= 250 ether, "Invalid amount!");

        BUSD.safeTransferFrom(msg.sender, address(this), _amt);
        BUSD.safeTransfer(dApp, minDeposit);

        main.totalMemberNumber = user.memberType == 0 ? main.totalMemberNumber + 1 : main.totalMemberNumber;
        user.memberType = _key;
    }

    function GestureMember(uint256 _key, address _memberAddr) public onlyOwner {
        // require(block.timestamp < firstlaunch);
        Main storage main = MainKey[1];
        User storage user = UsersKey[_memberAddr];

        require(_key > 0 && _key <= 3, "Invalid selection!");

        main.totalMemberNumber = user.memberType == 0 ? main.totalMemberNumber + 1 : main.totalMemberNumber;
        user.memberType = _key;
    }

    function checkPartecipantExist(address _key, uint256 _time) public view returns (bool) {
        Reward storage reward = RewardKey[_time];
        for (uint i = 0; i < reward.participants.length; i++) {
            if (reward.participants[i] == _key) {
                return true;
            }
        }
        return false;
    }

    function getCurrentDay() public view returns (uint256) {
        return minZero(block.timestamp, dateLaunched).div(hardMinutes); // firstlaunch
    }

    function getTimeToNextDay() public view returns (uint256) {
        uint time = minZero(block.timestamp, dateLaunched); // firstlaunch
        uint nextDay = getCurrentDay().mul(hardMinutes);
        return nextDay.add(hardMinutes).sub(time);
    }

    function minZero(uint256 _a, uint256 _b) private pure returns(uint256) {
        return (_a > _b) ? _a - _b : 0;
    }

    function random() private view returns(uint256){
        uint256 count = RewardKey[getCurrentDay()].participantCount;
        return uint256(keccak256(abi.encode(block.difficulty, block.timestamp, count, block.number)));
    }

    function RewardWinner() private {
        if(getCurrentDay() > 0 && rewardWinnerEnabled){
            Main storage main = MainKey[1];
            Reward storage reward = RewardKey[getCurrentDay() - 1];
            if(!reward.payout){
                if(reward.balance > 0 && reward.participantCount >= 1) { // reward.participantCount >= 10;
                    uint256 index = random() % reward.participantCount;
                    address winner = reward.participants[index];
                    if(checkPartecipantExist(winner, getCurrentDay() - 1) && address(winner) != address(main.previousRewardWinner)){
                        User storage user = UsersKey[winner];
                        Member storage member = MemberKey[user.memberType];
                        uint256 rewardBalance = reward.balance;
                        uint256 percentage = member.percentageReward;
                        uint256 rewardAmt = rewardBalance.mul(percentage).div(percentdiv);

                        BUSD.safeTransfer(winner, rewardAmt);

                        main.totalRoundReward += 1;
                        main.previousRewardWinner = winner;
                        main.previousRewardAmount = rewardAmt;
                        main.previousRewardPercentage = percentage;
                        reward.payout = true;
                        reward.winner = winner;
                        reward.winnerAmount = rewardAmt;
                        reward.winnerPercentage = percentage;

                        delete reward.participants;
                    }
                }
            }
        }
    }

    function RewardWinner_M(uint256 _key) external onlyOwner {
        // require(block.timestamp < firstlaunch);
        require (_key >= 0 && _key < getCurrentDay(), "Invalid key!");
        Main storage main = MainKey[1];
        Reward storage reward = RewardKey[_key];
        require(!reward.payout, "Reward already verified!");
        require(reward.balance > 0, "Insufficient reward balance!");
        require(reward.participantCount >= 1, "Insufficient number of participants!"); // reward.participantCount >= 10;

        uint256 index = random() % reward.participantCount;
        address winner = reward.participants[index];

        require(checkPartecipantExist(winner, _key), "Participant not found!");
        require(winner != main.previousRewardWinner, "You cannot win the reward below!");
        User storage user = UsersKey[winner];
        Member storage member = MemberKey[user.memberType];

        uint256 rewardBalance = reward.balance;
        uint256 percentage = member.percentageReward;
        uint256 rewardAmt = rewardBalance.mul(percentage).div(percentdiv);

        BUSD.safeTransfer(winner, rewardAmt);

        main.totalRoundReward += 1;
        main.previousRewardWinner = winner;
        main.previousRewardAmount = rewardAmt;
        main.previousRewardPercentage = percentage;
        reward.payout = true;
        reward.winner = winner;
        reward.winnerAmount = rewardAmt;
        reward.winnerPercentage = percentage;

        delete reward.participants;
    }

    function switchRewardWinnerEnabled() public onlyOwner {
        RewardWinner();
        rewardWinnerEnabled = !rewardWinnerEnabled ? true : false;
    }

    function UserInfo() external view returns (Depo[] memory depoList) {
        User storage user = UsersKey[msg.sender];
        return (user.depoList);
    }

    function MemberInfoPrice() external view returns (uint72[3] memory price) {
        User storage user = UsersKey[msg.sender];
        Member storage userMember = MemberKey[user.memberType];
        return (userMember.price);
    }

    function RefPercentageInfo() external view returns (uint8[3] memory refPercentage) {
        User storage user = UsersKey[msg.sender];
        Member storage userMember = MemberKey[user.memberType];
        return (userMember.refPercentage);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}