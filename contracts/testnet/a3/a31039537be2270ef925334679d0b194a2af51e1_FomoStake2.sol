// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import './SafeMath.sol';
import './Math.sol';

contract FomoStake2 {
    using SafeMath for uint256;

   
    uint256[3] public REFERRAL_PERCENTS = [50, 25, 5];
    uint256 public constant MIN_INVEST = 0.025 ether;
    uint256 public constant PERCENT_STEP = 5;
    uint256 public constant WITHDRAW_FEE = 100;
    uint256 public constant DIVIDER = 1000;
    uint256 public constant TIME_STEP = 1 minutes; 
    uint256 public constant DECREASE_TIME = 30 seconds;
    uint256 public constant FORCE_WITHDRAW = 300;
    uint256 public constant SECUREADRESS_WITHDRAW = 200;
    uint256 public constant INVEST = 120;
    uint256 public constant REINVEST = 100;
    uint256 public START_DATE;
    uint256 internal constant reinvestPercent = 100;

    uint256 internal usersTotalNumber;
    uint256 internal totalStaked;
    uint256 internal totalReinvested;
    uint256 internal totalWithdrawn;
    uint256 internal totalDeposits;

    struct Plan {
        uint256 time;
        uint256 percent;
        bool locked;
        uint256 returnPercent;
    }

    Plan[] internal plans;   
  //  mapping(uint256 => Plan) internal plans;
    uint256 public plansLength;

    struct Deposit {
        uint8 plan;
        uint256 percent;
        uint256 amount;
        uint256 profit;
        uint256 initDate;
        uint256 duration;
        bool force;
        uint256 reinvestBonus;
    }

    struct User {
        mapping(uint256 => Deposit) deposits;
        uint256 depositsLength;
        uint256 checkpoint;
        uint256 lasReinvest;
        address payable referrer;
        uint256[3] levels;
        uint256 bonus;
        uint256 totalBonus;
        uint256 totalStaked;
        uint256 withdrawn;
        uint256 reinvested;
    }

    mapping(address => User) public users;
    mapping(address => Deposit[]) public penaltyDeposits;
address payable public AddressOwnerProject;
    address payable public marketingAddress;
    address payable public projectAddress;
    address payable public devAddress;
    address payable public secureAddress;

    event Newbie(address user);
    event NewDeposit(
        address indexed user,
        uint8 plan,
        uint256 percent,
        uint256 amount,
        uint256 profit,
        uint256 start,
        uint256 duration
    );
    event Withdrawn(address indexed user, uint256 amount);

    event Reinvestment(address indexed user, uint256 amount);

    event ForceWithdrawn(
        address indexed user,
        uint256 amount,
        uint256 penaltyAmount,
        uint256 penaltyID,
        uint256 toSecure
    );
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );
    event FeePayed(address indexed user, uint256 totalAmount);

    event Unpaused(address account);

    modifier onlyOwner() {
        require(AddressOwnerProject == msg.sender, "You're not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!CurrentState(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(CurrentState(), "Pausable: not paused");
        _;
    }

    function startContract() external whenPaused onlyOwner{
        START_DATE = block.timestamp;
        emit Unpaused(msg.sender);
    }

    function CurrentState() public view returns(bool) {
        return (START_DATE == 0);
    }

    modifier isUser() {
        require(users[msg.sender].checkpoint > 0, 'is not user');
        _;
    }

    constructor(address payable marketingAddr,address payable _AddressOwnerProject /* address payable projectAddr, address payable devAddr */, address payable secureAddr) {
        require(!isContract(marketingAddr), "!marketingAddr");
     require(!isContract(_AddressOwnerProject), "!_AddressOwnerProject");
        require(!isContract(secureAddr), "!secureAddr");
        AddressOwnerProject =_AddressOwnerProject;
        marketingAddress = marketingAddr;
        projectAddress = _AddressOwnerProject;
        devAddress = _AddressOwnerProject;
        secureAddress = secureAddr;

         //planes no bloqueados
        plans.push(Plan(14, 80,false,1120));

         plans.push(Plan(21, 65,false,1136));

         plans.push(Plan(28, 50,false,1140));

            //planes bloqueados hasta el final
       
        plans.push(Plan(14, 137,true,1193));

         plans.push(Plan(21, 131,true,1275));

           plans.push(Plan(28, 104,true,1292));

        plansLength = plans.length;

    }

    function invest(address payable referrer, uint8 plan) external payable {
        require(msg.value >= MIN_INVEST, "insufficient deposit");
        require(plan < plans.length, "Invalid plan");

        uint256 investFee = msg.value.mul(INVEST).div(DIVIDER);
        uint256 feeToTransfer = investFee.div(3);
        marketingAddress.transfer(feeToTransfer);

        projectAddress.transfer(feeToTransfer);

        devAddress.transfer(feeToTransfer);

        emit FeePayed(msg.sender, investFee);

        User storage user = users[msg.sender];
        uint256 referalLength = REFERRAL_PERCENTS.length;
        if (user.referrer == address(0)) {
            if (referrer != msg.sender) {
                user.referrer = referrer;
            }

            address upline = user.referrer;
            for (uint256 i; i < referalLength; i++) {
                if (upline != address(0)) {
                    uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(DIVIDER);
                    users[upline].bonus = users[upline].bonus.add(amount);
                    users[upline].totalBonus = users[upline].totalBonus.add(amount);
                    users[upline].levels[i] = users[upline].levels[i].add(1);
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.depositsLength == 0) {
            user.checkpoint = block.timestamp;
            usersTotalNumber = usersTotalNumber.add(1);
            emit Newbie(msg.sender);
        }

        (uint256 percent, uint256 profit, uint256 initDate, uint256 duration) = getResult(plan, msg.value);
        Deposit memory deposit;
        deposit.plan = plan;
        deposit.percent = percent;
        deposit.amount = msg.value;
        deposit.profit = profit;
        deposit.initDate = initDate;
        deposit.duration = duration;
        deposit.force = true;
        user.deposits[user.depositsLength] = deposit;
        user.depositsLength++;

        totalStaked = totalStaked.add(msg.value);
        totalDeposits = totalDeposits.add(1);
        emit NewDeposit(
            msg.sender,
            plan,
            percent,
            msg.value,
            profit,
            initDate,
            duration
        );
    }

    function withdraw() external whenNotPaused {
        User storage user = users[msg.sender];

        (uint256 totalAmount, uint256 referalBonus) = getUserDividends(msg.sender);

        totalAmount = totalAmount.add(referalBonus);

        require(totalAmount > 0, "User has no dividends");

        user.withdrawn = user.withdrawn.add(totalAmount);

        uint256 contractBalance = getContractBalance();
        bool feeToSecure;
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
            feeToSecure = true;
        }

        user.checkpoint = block.timestamp;

        for (uint256 i; i < user.depositsLength; i++) {
            Deposit memory deposit = user.deposits[i];
            uint256 finishDate = getFinishDeposit(deposit);
            if (user.checkpoint < finishDate) {
                Plan memory tempPlan = plans[deposit.plan];
                if (!tempPlan.locked) {
                    delete user.deposits[i].force;
                } else if (block.timestamp > finishDate) {
                    delete user.deposits[i].force;
                }
            }
        }

        uint256 fee = totalAmount.mul(WITHDRAW_FEE).div(DIVIDER);

        uint256 toTransfer = totalAmount.sub(fee);

        totalWithdrawn = totalWithdrawn.add(totalAmount);

        payable(msg.sender).transfer(toTransfer);

        uint256 feeDivider = feeToSecure ? 1 : 2;
        secureAddress.transfer(fee.div(feeDivider));

        emit Withdrawn(msg.sender, totalAmount);
        emit FeePayed(msg.sender, fee);

    }

    function forceWithdraw(uint256 index) external {
        User storage user = users[msg.sender];

        require(index < user.depositsLength, "Invalid index");
        require(user.deposits[index].force == true, "Force is false");

        uint256 depositAmount = user.deposits[index].amount;
        uint256 contractBalance = getContractBalance();
        uint256 toDistribute = Math.min(depositAmount, contractBalance);
        uint256 toUser = toDistribute.mul(FORCE_WITHDRAW).div(DIVIDER);
        uint256 toSecure = toDistribute.mul(SECUREADRESS_WITHDRAW).div(DIVIDER);
        user.deposits[index].profit = toDistribute;
        penaltyDeposits[msg.sender].push(user.deposits[index]);

        user.deposits[index] = user.deposits[user.depositsLength - 1];

        delete user.deposits[user.depositsLength - 1];
        user.depositsLength = user.depositsLength.sub(1);

        payable(msg.sender).transfer(toUser);
        secureAddress.transfer(toSecure);

        totalWithdrawn = totalWithdrawn.add(toDistribute);
        emit ForceWithdrawn(
            msg.sender,
            depositAmount,
            toUser,
            penaltyDeposits[msg.sender].length,
            toSecure
        );

    }

    function reinvestment() external whenNotPaused returns(bool) {
        User storage user = users[msg.sender];
        uint256 currentDate = block.timestamp;
        uint256 totalAmount;
        for (uint256 i; i < user.depositsLength; i++) {
            Deposit memory deposit = user.deposits[i];
            uint256 finishDate = getFinishDeposit(deposit);
            uint256 userCheckpoint = getlastActionDate(user);
            uint256 userWithdraw = Math.max(user.checkpoint, getLaunchDate());
            if (userWithdraw < finishDate && currentDate < finishDate) {
                Plan memory tempPlan = plans[deposit.plan];
                if (!tempPlan.locked) {
                    uint256 share = deposit.amount.mul(deposit.percent).div(DIVIDER);

                    uint256 _from = getInintDeposit(deposit.initDate);
                    _from = _from > userCheckpoint ? _from : userCheckpoint;

                    uint256 _to = finishDate < currentDate ? finishDate : currentDate;

                    if (_from < _to) {
                        uint256 dividens = share.mul(_to.sub(_from)).div(TIME_STEP);
                        uint256 toBonus = dividens.mul(REINVEST_PERCENT()).div(DIVIDER);
                        user.deposits[i].reinvestBonus = user.deposits[i].reinvestBonus.add(dividens.add(toBonus));
                        totalAmount = totalAmount.add(dividens.add(toBonus));
                    }
                }
            }
        }

        require(totalAmount > 0, "User has no dividends");

        user.reinvested = user.reinvested.add(totalAmount);
        totalReinvested = totalReinvested.add(totalAmount);
        user.lasReinvest = currentDate;

        uint256 fee = totalAmount.mul(REINVEST).div(DIVIDER);
        fee = Math.min(fee, getContractBalance());
        secureAddress.transfer(fee);

        emit Reinvestment(msg.sender, totalAmount);
        emit FeePayed(msg.sender, fee);
        return true;
    }

    function getUserData(address userAddress) external view returns(uint256 totalWithdrawn_,
        uint256 totalDeposits_,
        uint256 totalInvested,
        uint256 totalreinvest_,
        uint256 balance_,
        uint256 reinvestBonus,
        uint256 checkpoint,
        uint256 referralTotalBonus,
        uint256 referalBonus,
        address referrer_,
        uint256[3] memory referrerCount_
    ){
        User storage user = users[userAddress];
        totalWithdrawn_ = user.withdrawn;
        totalDeposits_ = user.depositsLength;
        (balance_, reinvestBonus) = getUserDividends(userAddress);
        balance_ = balance_.add(reinvestBonus);
        totalreinvest_ = user.reinvested;
        checkpoint = getlastActionDate(user);
        referrer_ = user.referrer;
        referrerCount_ = user.levels;
        referralTotalBonus = getUserReferralTotalBonus(userAddress);
        referalBonus = getUserReferralBonus(userAddress);
        totalInvested = getUserTotalStacked(userAddress);

    }

    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getPlanInfo(uint256 plan) public view returns (uint256 time, uint256 percent, bool locked, uint256 returnPercent) {
        require(plan < plans.length, "Invalid plan");
        Plan memory tempPlan = plans[plan];
        locked = tempPlan.locked;
        uint256 profit;
        uint256 tempInvest = 1 ether;
        (percent, profit,, time) = getResult(plan, tempInvest);
        returnPercent = profit.mul(DIVIDER).div(tempInvest);
        time = time.div(TIME_STEP);
    }

    function getPlans() external view returns(Plan[] memory _plans) {
        _plans = new Plan[] (plans.length);
        for(uint256 i; i < plans.length; i++) {
            (_plans[i].time, _plans[i].percent, _plans[i].locked, _plans[i].returnPercent) = getPlanInfo(i);
        }
    }

    function getPercent(uint256 plan) public view returns (uint256) {
        require(plan < plans.length, "Invalid plan");
        return getPercentFrom(plans[plan].percent);
    }

    function getPercentFrom(uint256 percent) internal view returns(uint256){
        if (!CurrentState()) {
            return Math.min(percent.add(PERCENT_STEP.mul(block.timestamp.sub(getLaunchDate())).div(TIME_STEP)), percent.mul(3));
        } else {
            return percent;
        }
    }

    function REINVEST_PERCENT() public view returns(uint256) {
        return getPercentFrom(reinvestPercent);
    }

    function getResult(uint256 plan, uint256 deposit) public view
        returns (
            uint256 percent,
            uint256 profit,
            uint256 current,
            uint256 duration
        ) {

        require(plan < plans.length, "Invalid plan");

        Plan memory tempPlan = plans[plan];
        percent = getPercent(plan);

        current = block.timestamp;
        duration = getDecreaseDays(plans[plan].time);

        uint256 durationToDays = duration.div(TIME_STEP);

        percent = percent.mul(plans[plan].time).mul(TIME_STEP).div(duration);

        uint256 amt = deposit;

        if (!tempPlan.locked) {
            profit = deposit.mul(percent).mul(duration).div(DIVIDER.mul(TIME_STEP));
        } else {
            for (uint256 i; i < durationToDays; i++) {
                profit = profit.add(amt.add(profit).mul(percent).div(DIVIDER));
            }
        }

    }

    function getUserDividends(address userAddress) public view returns (uint256 totalAmount, uint256 reinvestBonus) {
        User storage user = users[userAddress];

        for (uint256 i; i < user.depositsLength; i++) {
            Deposit memory deposit = user.deposits[i];
            uint256 finishDate = getFinishDeposit(deposit);
            uint256 userCheckpoint = getlastActionDate(user);
            uint256 userWithdraw = Math.max(user.checkpoint, getLaunchDate());
            uint256 currentDate = block.timestamp;
            if (userWithdraw < finishDate) {
                Plan memory tempPlan = plans[deposit.plan];
                if (!tempPlan.locked) {
                    uint256 share = deposit.amount.mul(deposit.percent).div(DIVIDER);

                    uint256 _from = getInintDeposit(deposit.initDate);
                    _from = _from > userCheckpoint ? _from : userCheckpoint;


                    uint256 _to = finishDate < currentDate ? finishDate : currentDate;

                    if (_from < _to) {
                        totalAmount = totalAmount.add(share.mul(_to.sub(_from)).div(TIME_STEP));
                    }

                    if(currentDate >= finishDate) {
                        reinvestBonus = reinvestBonus.add(deposit.reinvestBonus);
                    }

                } else if (currentDate >= finishDate) {
                    totalAmount = totalAmount.add(deposit.profit);
                }
            }
        }
    }

    function getDecreaseDays(uint256 planTime) public view returns (uint256) {
        uint256 limitDays = PERCENT_STEP.mul(TIME_STEP);
        uint256 pastDays = block.timestamp.sub(getLaunchDate()).div(TIME_STEP);
        uint256 decreaseDays = pastDays.mul(DECREASE_TIME);
        uint256 minimumDays;
        if(planTime.mul(TIME_STEP) > decreaseDays) {
            minimumDays = planTime.mul(TIME_STEP).sub(decreaseDays);
        }

        if (minimumDays < limitDays) {
            return limitDays;
        }

        return minimumDays;
    }

    function getUserCheckpoint(address userAddress) external view returns (uint256) {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress) external view returns (address) {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress) external view returns (uint256, uint256, uint256) {
        return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2]);
    }

    function getUserReferralBonus(address userAddress) public view returns (uint256) {
        return users[userAddress].bonus;
    }

    function withdrawReferralBonus() external whenNotPaused isUser {
        User storage user = users[msg.sender];
        uint256 referralBonus = getUserReferralBonus(msg.sender);
        require(referralBonus > 0, "User has no dividends");
        delete user.bonus;
        payable(msg.sender).transfer(referralBonus);
    }

    function getUserReferralTotalBonus(address userAddress) public view returns (uint256) {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress) external view returns (uint256) {
        return users[userAddress].totalBonus.sub(users[userAddress].bonus);
    }

    function getUserAvailable(address userAddress) external view returns (uint256) {
        (uint256 totalAmount, uint256 reinvestBonus) = getUserDividends(msg.sender);
        return getUserReferralBonus(userAddress).add(totalAmount).add(reinvestBonus);
    }

    function getUserAmountOfDeposits(address userAddress) external view returns (uint256) {
        return users[userAddress].depositsLength;
    }

    function getUserAmountOfPenaltyDeposits(address userAddress) external view returns (uint256) {
        return penaltyDeposits[userAddress].length;
    }

    function getUserTotalDeposits(address userAddress) external view returns (uint256 amount) {
        for (uint256 i; i < users[userAddress].depositsLength; i++) {
            amount = amount.add(users[userAddress].deposits[i].amount);
        }
    }

    function getUserDepositInfo(address userAddress, uint256 index) external view returns (uint8 plan, uint256 percent,
            uint256 amount,
            uint256 profit,
            uint256 start,
            uint256 finish,
            uint256 duration,
            bool force,
            uint256 reinvestBonus
        ) {
        User storage user = users[userAddress];

        require(index < user.depositsLength, "Invalid index");
        Deposit memory deposit = user.deposits[index];

        plan = deposit.plan;
        percent = deposit.percent;
        amount = deposit.amount;
        profit = deposit.profit;
        start = getInintDeposit(deposit.initDate);
        finish = getFinishDeposit(deposit);
        duration = deposit.duration;
        force = deposit.force;
        reinvestBonus = deposit.reinvestBonus;
    }

    function getUserPenaltyDepositInfo(address userAddress, uint256 index) external view returns (
            uint8 plan,
            uint256 percent,
            uint256 amount,
            uint256 profit,
            uint256 start,
            uint256 finish,
            uint256 reinvestBonus
        ) {
        Deposit[] memory userPenaltyDeposit = penaltyDeposits[userAddress];
        require(index < userPenaltyDeposit.length, "Invalid index");
        Deposit memory deposit = userPenaltyDeposit[index];

        plan = deposit.plan;
        percent = deposit.percent;
        amount = deposit.amount;
        profit = deposit.profit;
        start = getInintDeposit(deposit.initDate);
        finish = getFinishDeposit(deposit);
        reinvestBonus = deposit.reinvestBonus;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function getFinishDeposit(Deposit memory deposit) internal view returns (uint256 _to) {
        uint256 _from = getInintDeposit(deposit.initDate);
        _to = _from.add(deposit.duration);
    }

    function getInintDeposit(uint256 init) internal view returns (uint256 _from) {
        uint256 launchDate = getLaunchDate();
        _from = init > launchDate ? init : launchDate;
    }

    function getLaunchDate() internal view returns (uint256 launch) {
        if(START_DATE == 0) {
            launch = block.timestamp;
        }
        else {
            launch = START_DATE;
        }
    }

    function getPublicData() external view returns(uint256 totalUsers_,
        uint256 totalInvested_,
        uint256 totalReinvested_,
        uint256 totalWithdrawn_,
        uint256 totalDeposits_,
        uint256 balance_,
        uint256 minDeposit,
        uint256 daysFormdeploy,
        uint256 reinvestPercent_
        ) {
        totalUsers_ = usersTotalNumber;
        totalInvested_ = totalStaked;
        totalReinvested_ = totalReinvested;
        totalWithdrawn_ = totalWithdrawn;
        totalDeposits_ = totalDeposits;
        balance_ = getContractBalance();
        minDeposit = MIN_INVEST;
        daysFormdeploy = block.timestamp.sub(START_DATE).div(TIME_STEP);
        reinvestPercent_ = REINVEST_PERCENT();
    }

    function getlastActionDate(User storage user) internal view returns(uint256) {
        uint256 checkpoint;
        checkpoint = Math.max(user.checkpoint, user.lasReinvest);

        checkpoint = Math.max(getLaunchDate(), checkpoint);

        return checkpoint;
    }

    function getAvailableFormReinvest(address userAddress) external view returns(uint256 available) {
        (available,) = getUserDividends(userAddress);
    }

    function getUserTotalStacked(address userAddress) internal view returns(uint256) {
        User storage user = users[userAddress];

        uint256 amount;

        for(uint256 i; i < user.depositsLength; i++) {
            amount = amount.add(users[userAddress].deposits[i].amount);
        }
        return amount;
    }

    function getPlansToForce(address userAddress) public view returns(uint256[] memory toForceView) {
        User storage user = users[userAddress];
        require(user.depositsLength > 0, 'No deposits');
        uint256[] memory toForce = new uint256[](user.depositsLength);
        uint256 toForceLength;
        for(uint256 i; i < toForce.length; i++) {
            if(!user.deposits[i].force){
                continue;
            }
            toForce[toForceLength] = i;
            toForceLength++;
        }
        toForceView = new uint256[] (toForceLength);
        for(uint256 i; i < toForceLength; i++) {
            toForceView[i] = toForce[i];
        }

    }

}