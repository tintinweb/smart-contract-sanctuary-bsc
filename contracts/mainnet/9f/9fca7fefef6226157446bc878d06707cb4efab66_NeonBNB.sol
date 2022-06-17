/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// SPDX-License-Identifier: MIT

// 888b    888                            888888b.   888b    888 888888b.   
// 8888b   888                            888  "88b  8888b   888 888  "88b  
// 88888b  888                            888  .88P  88888b  888 888  .88P  
// 888Y88b 888  .d88b.   .d88b.  88888b.  8888888K.  888Y88b 888 8888888K.  
// 888 Y88b888 d8P  Y8b d88""88b 888 "88b 888  "Y88b 888 Y88b888 888  "Y88b 
// 888  Y88888 88888888 888  888 888  888 888    888 888  Y88888 888    888 
// 888   Y8888 Y8b.     Y88..88P 888  888 888   d88P 888   Y8888 888   d88P 
// 888    Y888  "Y8888   "Y88P"  888  888 8888888P"  888    Y888 8888888P"


pragma solidity 0.8.14;
// safemath is not needed since 0.8


contract NeonBNB {
    uint256 constant public INVEST_MIN_AMOUNT            = 0.1 ether;               // min possible investment amount
    uint256 constant public INVEST_MAX_AMOUNT            = 100 ether;               // max possible investment amount
    uint256 constant public MAX_DEPOSITS                 = 100;                     // max count of investment transactions per user
    uint256 constant public ANTI_WHALE_THRESHOLD         = 50 ether;                // anti whale protection threshold
    uint256 constant public MAX_WHALE_WITHDRAW           = 10 ether;                // max withdraw for whale per TIME_STEP
                                                                                    // LIMIT ONLY FOR DIVIDENTS BASED ON PERCENT, NOT REFERRAL
    uint256 constant public BASE_PERCENT                 = 250;                     // 2.5% per step
    uint256 constant public PROJECT_FEE                  = 1000;                    // 10% project fee for future development
    uint256 constant public DEV_FEE                      = 100;                     // 1% developer fee
    uint256 constant public PERCENTS_DIVIDER             = 10000;                   // 1% = 100
    uint256 constant public CONTRACT_BALANCE_STEP        = 500 ether;
    uint256 constant public TIME_STEP                    = 1 days;


	uint256 [] public REFERRAL_PERCENTS                  = [
																500, 				// 1st lvl +5%
																200, 				// 2nd lvl +2%
																100, 				// 3rd lvl +1%
																75, 				// 4th lvl +0.75%
																25	     		    // 5th lvl +0.25%
															];

    uint256 public totalUsers;                                                      // count of users
    uint256 public totalInvested;                                                   // invested amount
    uint256 public totalWithdrawn;                                                  // withdrawn amount
    uint256 public totalDeposits;                                                   // count of deposits
    uint256 public totalReferrals;                                                  // referred money

    address payable public devAddress;
    address payable public projectAddress;

    struct Deposit {
        uint256 amount;
        uint256 withdrawn;
        uint256 start;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256 bonus;
        uint256 totalBonus;
        uint256 totalInvested;
        uint256[5] levels;
    }

    mapping (address => User) internal users;
    mapping (address => bool) internal antiWhale;

    uint256 public startUNIX;

    event NewUser(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);

    constructor(address payable projectAddr, address payable devAddr, uint256 start) {
        require(!isContract(devAddr) && !isContract(projectAddr));
        projectAddress = projectAddr;
        devAddress = devAddr;

        if(start > 0){
            startUNIX = start;
        }
        else{
            startUNIX = block.timestamp;
        }
    }

    function invest(address referrer) public payable {
        require(block.timestamp > startUNIX, "not launched yet");
        require(msg.value >= INVEST_MIN_AMOUNT, "min deposit amount is not reached");
        User storage user = users[msg.sender];
        require(user.deposits.length < MAX_DEPOSITS, "max deposit amount excedeed");
        require(user.totalInvested + msg.value < INVEST_MAX_AMOUNT, "max amount excedeed");

        projectAddress.transfer((msg.value * PROJECT_FEE) / PERCENTS_DIVIDER);
        devAddress.transfer((msg.value * DEV_FEE) / PERCENTS_DIVIDER);


        if (user.referrer == address(0)) {
            if(users[referrer].deposits.length > 0 && referrer != msg.sender){
                user.referrer = referrer;
            }
            else{
                user.referrer = projectAddress;
            }

            address upline = user.referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    users[upline].levels[i] += 1;
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.referrer != address(0)) {

            address upline = user.referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    uint256 amount = (msg.value * REFERRAL_PERCENTS[i]) / PERCENTS_DIVIDER;
                    users[upline].bonus += amount;
                    users[upline].totalBonus += amount;
                    totalReferrals += amount;
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = users[upline].referrer;
                } else break;
            }

        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            totalUsers += 1;
            emit NewUser(msg.sender);
        }

        user.deposits.push(Deposit(msg.value, 0, block.timestamp));

        user.totalInvested += msg.value;
        totalInvested += msg.value;
        totalDeposits += 1;

        if (user.totalInvested >= ANTI_WHALE_THRESHOLD) {
            antiWhale[msg.sender] = true;
        }

        emit NewDeposit(msg.sender, msg.value);

    }

    // withdraw
    function withdraw() public {
        require(block.timestamp > startUNIX, "not luanched yet");

        User storage user = users[msg.sender];

        require(block.timestamp - user.checkpoint >= TIME_STEP, "withdraw is allowed only once per 24h");

        uint256 userPercentRate = getUserPercentRate(msg.sender);

        uint256 totalAmount;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {

            if (user.deposits[i].withdrawn < user.deposits[i].amount * 2) {
                if (user.deposits[i].start > user.checkpoint) {
                    dividends = (
                        (
                            (user.deposits[i].amount * userPercentRate) / PERCENTS_DIVIDER
                        ) * (
                            block.timestamp - user.deposits[i].start
                        )
                    ) / TIME_STEP;

                } else {
                    dividends = (
                        (
                            (user.deposits[i].amount * userPercentRate) / PERCENTS_DIVIDER
                        ) * (
                            block.timestamp - user.checkpoint
                        )
                    ) / TIME_STEP;
                }

                if (user.deposits[i].withdrawn + dividends > user.deposits[i].amount * 2) {
                    dividends = (user.deposits[i].amount * 2) - user.deposits[i].withdrawn;
                }

                if (antiWhale[msg.sender] && dividends > MAX_WHALE_WITHDRAW) {
                    dividends = MAX_WHALE_WITHDRAW;
                }
                user.deposits[i].withdrawn += dividends;
                totalAmount += dividends;
            }
        }

        uint256 referralBonus = getUserReferralBonus(msg.sender);
        if (referralBonus > 0) {
            totalAmount += referralBonus;
            user.bonus = 0;
        }

        require(totalAmount > 0, "User has no dividends");

        uint256 contractBalance = address(this).balance;
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

        user.checkpoint = block.timestamp;
        payable(msg.sender).transfer(totalAmount);
        totalWithdrawn += totalAmount;
        emit Withdrawn(msg.sender, totalAmount);
    }

    // get contract balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // get current contract rate
    function getContractBalanceRate() public view returns (uint256) {
        uint256 contractBalance = address(this).balance;
        uint256 contractBalancePercent = contractBalance / CONTRACT_BALANCE_STEP;
        return BASE_PERCENT + contractBalancePercent;
    }

    // get the user's percent rate
    function getUserPercentRate(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 contractBalanceRate = getContractBalanceRate();
        if (isActive(userAddress)) {
            uint256 timeMultiplier = (block.timestamp - user.checkpoint) / TIME_STEP;
            return contractBalanceRate + timeMultiplier;
        } else {
            return contractBalanceRate;
        }
    }

    // get the user's dividends
    function getUserDividends(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 userPercentRate = getUserPercentRate(userAddress);
        uint256 totalDividends;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.deposits[i].withdrawn < user.deposits[i].amount * 2) {
                if (user.deposits[i].start > user.checkpoint) {
                    dividends = (
                        (
                            (user.deposits[i].amount * userPercentRate) / PERCENTS_DIVIDER
                        ) * (
                            block.timestamp - user.deposits[i].start
                        )
                    ) / TIME_STEP;
                } else {
                    dividends = (
                        (
                            (user.deposits[i].amount * userPercentRate) / PERCENTS_DIVIDER
                        ) * (
                            block.timestamp - user.checkpoint
                        )
                    ) / TIME_STEP;
                }

                if (user.deposits[i].withdrawn + dividends > user.deposits[i].amount * 2) {
                    dividends = (user.deposits[i].amount * 2) - user.deposits[i].withdrawn;
                }
                totalDividends += dividends;
            }
        }

        return totalDividends;
    }

    // get the user's checkpoint
    function getUserCheckpoint(address userAddress) public view returns(uint256) {
        return users[userAddress].checkpoint;
    }

    // get the user's referrer
    function getUserReferrer(address userAddress) public view returns(address) {
        return users[userAddress].referrer;
    }

    // get the user's referral bonus
    function getUserReferralBonus(address userAddress) public view returns(uint256) {
        return users[userAddress].bonus;
    }

    // get the user's dividents + referral bonus
    function getUserAvailable(address userAddress) public view returns(uint256) {
        return getUserReferralBonus(userAddress) + getUserDividends(userAddress);
    }

    // check if the user is active (has at least 1 deposit)
    function isActive(address userAddress) public view returns (bool status) {
        User storage user = users[userAddress];
        if (user.deposits.length > 0) {
            if (user.deposits[user.deposits.length-1].withdrawn < user.deposits[user.deposits.length-1].amount * 2) {
                status = true;
                return status;
            }
        }
    }

    // get the user's deposits information
    function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256, uint256, uint256) {
        User storage user = users[userAddress];
        uint256 dividends;
        uint256 userPercentRate = getUserPercentRate(msg.sender);
        if (user.deposits[index].withdrawn < user.deposits[index].amount * 2) {
            if (user.deposits[index].start > user.checkpoint) {
                dividends = (
                    (
                        (user.deposits[index].amount * (userPercentRate)) / PERCENTS_DIVIDER
                    ) * (
                        block.timestamp - user.deposits[index].start
                    )
                ) / TIME_STEP;
            } else {
                dividends = (
                    (
                        (user.deposits[index].amount * (userPercentRate)) / PERCENTS_DIVIDER
                    ) * (
                        block.timestamp - user.checkpoint
                    )
                ) / TIME_STEP;
            }
            if (user.deposits[index].withdrawn + dividends > user.deposits[index].amount * 2) {
                dividends = (user.deposits[index].amount * 2) - user.deposits[index].withdrawn;
            }
        }
        return (user.deposits[index].amount, user.deposits[index].withdrawn + dividends, user.deposits[index].start);
    }

    // get count of the user's deposits
    function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
        return users[userAddress].deposits.length;
    }

    // get the amount of the user's deposits
    function getUserTotalDeposits(address userAddress) public view returns(uint256) {
        User storage user = users[userAddress];
        return user.totalInvested;
    }

    // get the amount of the user's withdrawals
    function getUserTotalWithdrawn(address userAddress) public view returns(uint256) {
        User storage user = users[userAddress];
        uint256 amount;
        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount += user.deposits[i].withdrawn;
        }
        return amount;
    }

    // get count of users by their level
    function getUserDownlineCount(address userAddress) public view returns(uint256, uint256, uint256, uint256, uint256) {
        return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2], users[userAddress].levels[3], users[userAddress].levels[4]);
    }

    // get total referral system bonus
    function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
        return users[userAddress].totalBonus; 
    }

    // get payed to users referral system bonus
    function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
        return users[userAddress].totalBonus - users[userAddress].bonus;
    }

    // get information about user by address
    function getUserInfo(address userAddress) public view returns(uint256, uint256, uint256){
        return (
            getUserAvailable(userAddress),
            getUserTotalDeposits(userAddress),
            getUserTotalWithdrawn(userAddress)
        );
    }

    // get information about contract
    function getContractInfo() public view returns(uint256, uint256, uint256, uint256, uint256){
        return (
            totalUsers,
            totalInvested,
            totalWithdrawn,
            totalReferrals,
            getContractBalance()
        );
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}