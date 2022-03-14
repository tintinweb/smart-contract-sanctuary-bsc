// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./SafeMath.sol";

contract Contract {
    using SafeMath for uint256;

    address payable developerAddress;

    struct InformationTotals {
        uint256 deposits;
        uint256 invested;
        uint256 referralRewards;
        uint256 reinvested;
        uint256 wallets;
        uint256 withdrawn;
    }

    struct Plan {
        uint256 dailyRate;
        bool locked;
        uint256 totalDays;
    }

    struct Information {
        uint256 autoReinvestRateOnWithdraw;
        uint256 commissionRate;
        uint256 maxWithdraw;
        uint256 minInvestment;
        uint256 minWithdraw;
        Plan[] plans;
        uint256 startDate;
        uint256[] referralBonusRates;
        uint256 cooldown;
        InformationTotals totals;
    }

    struct Deposit {
        uint256 endDate;
        uint256 invested;
        uint8 plan;
        uint256 startDate;
    }

    struct ReferralLevel {
        uint256 totalAmount;
        uint256 users;
    }

    struct Referral {
        ReferralLevel[] levels;
        uint256 totalWithdrawn;
        address referrer;
    }

    struct User {
        uint256 checkpoint;
        uint256 checkpointReinvest;
        uint256 checkpointWithdraw;
        Deposit[] deposits;
        Referral referral;
        uint256 reinvested;
        uint256 withdrawn;
    }

	Information public information;
    mapping (address => User) internal users;

	event CommissionFeePayed(address indexed user, uint256 amount);
	event ReferralBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event NewWallet(address indexed user, address indexed parent);
    event Withdrawn(address indexed user, uint amount);
    event Invested(address indexed user, uint256 amount, uint256 index, uint256 timestamp);
    event ReInvested(address indexed user, uint256 amount, uint256 index, uint256 timestamp);
    event AutoReinivestRateChanged(address indexed user, uint256 rate);
    event CommissionRateChanged(address indexed user, uint256 rate);
    event NewPlanAdded(uint256 dailyRate, bool locked, uint256 totalDays);
    
    constructor(address payable developerWalletAddress, uint256 startDate) {
		require(startDate > 0, "[Error] Missing Start Date");

        developerAddress = developerWalletAddress;

        information.startDate = startDate;
        information.autoReinvestRateOnWithdraw = 80;
        information.commissionRate = 8;
        information.maxWithdraw = 10000 ether;
        information.minInvestment = 1 ether;
        information.minWithdraw = 1 ether;

        information.referralBonusRates.push(7);
        information.referralBonusRates.push(3);
        information.referralBonusRates.push(2);
        information.referralBonusRates.push(1);

        information.plans.push(
            Plan(
                10,         //dailyRate
                false,      //locked
                21          //totalDays
            )
        );

        information.cooldown = 1 days;
    }
    
    function invest(address referrer, uint8 planIndex) public payable {
        require(information.startDate < block.timestamp, "[ERROR] DAPP Has Not Begun");

        _invest(msg.sender, msg.value, referrer, planIndex);

        information.totals.invested = information.totals.invested.add(msg.value);
        information.totals.deposits++;

        emit Invested(msg.sender, msg.value, planIndex, block.timestamp);
    }
    function reinvest(uint8 planIndex) public payable {  
        User storage user = users[msg.sender];
        require(user.checkpointReinvest + information.cooldown < block.timestamp, "[ERROR] Reinvestment Cooldown Is Not Met");

        uint withdrawableAmount =  _getWithdrawableAmount(msg.sender);
        uint withdrawableReferralAmount =  _getWithdrawableReferralAmount(msg.sender);
        withdrawableAmount = withdrawableAmount.add(withdrawableReferralAmount);

        require(withdrawableAmount >= information.minInvestment, "[ERROR] Minimum Invest Not Met");

        _invest(msg.sender, withdrawableAmount, msg.sender, planIndex);

        information.totals.withdrawn = information.totals.withdrawn.add(withdrawableAmount);
        information.totals.reinvested = information.totals.reinvested.add(withdrawableAmount);
        user.reinvested = user.reinvested.add(withdrawableAmount);
        user.referral.totalWithdrawn = user.referral.totalWithdrawn.add(withdrawableReferralAmount);

        user.checkpointReinvest = block.timestamp;

        emit ReInvested(msg.sender, msg.value, planIndex, block.timestamp);
    }
    function withdraw() public {
        User storage user = users[msg.sender];
        require(user.checkpointWithdraw + information.cooldown < block.timestamp, "[ERROR] Withdraw Cooldown Is Not Met");

        uint withdrawableAmount =  _getWithdrawableAmount(msg.sender);
        uint withdrawableReferralAmount =  _getWithdrawableReferralAmount(msg.sender);
        withdrawableAmount = withdrawableAmount.add(withdrawableReferralAmount);

        require(withdrawableAmount >= information.minInvestment, "[ERROR] Minimum Invest Not Met");

        uint contractBalance = address(this).balance;
        if (contractBalance < withdrawableAmount) {
            withdrawableAmount = contractBalance;
        }
        if (information.maxWithdraw < withdrawableAmount) {
            withdrawableAmount = information.maxWithdraw;
        }

        user.checkpoint = block.timestamp;
        user.checkpointWithdraw = block.timestamp;

        withdrawableAmount = withdrawableAmount.sub(withdrawableAmount.mul(information.autoReinvestRateOnWithdraw).div(100));
        user.withdrawn = user.withdrawn.sub(user.withdrawn.mul(information.autoReinvestRateOnWithdraw).div(100));
        user.referral.totalWithdrawn = user.referral.totalWithdrawn.add(withdrawableReferralAmount);
        information.totals.withdrawn = information.totals.withdrawn.add(withdrawableAmount);

        payable(msg.sender).transfer(withdrawableAmount);

        emit Withdrawn(msg.sender, withdrawableAmount);
    }
    
    function _invest(address walletAddress, uint invesment, address referrer, uint8 planIndex) internal {
        require(planIndex < information.plans.length, "[ERROR] Invalid Plan");
        Plan memory plan = information.plans[planIndex];
		require(invesment >= information.minInvestment, "[ERROR] Minimum Invest Not Met");

        uint256 commissionFee = invesment.mul(information.commissionRate).div(100);
		developerAddress.transfer(commissionFee);
		emit CommissionFeePayed(walletAddress, commissionFee);

        _updateReferralBonusus(referrer, walletAddress, invesment);

        User storage user = users[walletAddress];
		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
            for (uint256 i = 0; i < information.referralBonusRates.length; i++) {
                user.referral.levels.push(
                    ReferralLevel(
                        0,      //totalAmount
                        0       //users
                    )
                );
            }
            information.totals.wallets++;
			emit NewWallet(walletAddress, referrer);
		}

        user.deposits.push(
            Deposit(
                block.timestamp.add(plan.totalDays.mul(1 days)),    //endDate
                invesment,                                          //invested
                planIndex,                                          //plan
                block.timestamp                                     //startDate;
            )
        );
    }

    function _getWithdrawableReferralAmount(address walletAddress) private view returns (uint totalAmount) {
        User storage user = users[walletAddress];
        totalAmount = 0;

        for (uint256 i = 0; i < information.referralBonusRates.length; i++) {
			totalAmount = totalAmount.add(user.referral.levels[i].totalAmount);
		}

        totalAmount = totalAmount.sub(user.referral.totalWithdrawn);
    }
    function _getWithdrawableAmount(address walletAddress) private view returns (uint totalAmount) {
        User storage user = users[walletAddress];
        totalAmount = 0;

        for (uint i = 0; i < user.deposits.length; i++) {
            Deposit memory deposit = user.deposits[i];
            Plan storage plan = information.plans[user.deposits[i].plan];
			uint256 share = deposit.invested.mul(plan.totalDays.mul(plan.dailyRate).div(100));
            if (plan.locked == false) {
				uint256 from = deposit.startDate > user.checkpoint ? deposit.startDate : user.checkpoint;
				uint256 to = deposit.endDate < block.timestamp ? deposit.endDate : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(1 days));
				}
			} 
            else if (block.timestamp > deposit.endDate) {
			    totalAmount = totalAmount.add(share);
			}
        }
    }

    function _updateReferralBonusus(address referrer, address walletAddress, uint256 referredInvestmentAmount) private {
        User storage user = users[walletAddress];
        if (user.referral.referrer == address(0)) {
            if (users[referrer].deposits.length > 0 && referrer != walletAddress) {
				user.referral.referrer = referrer;
			}

            address activeReferrer = user.referral.referrer;
		    for (uint256 i = 0; i < information.referralBonusRates.length; i++) {
				if (activeReferrer != address(0)) {
					users[activeReferrer].referral.levels[i].users = users[activeReferrer].referral.levels[i].users.add(1);
					activeReferrer = users[activeReferrer].referral.referrer;
				} 
                else break;
			} 
        }

        if (user.referral.referrer != address(0)) {
            address activeReferrer = user.referral.referrer;
			for (uint256 i = 0; i < information.referralBonusRates.length; i++) {
                if (activeReferrer != address(0)) {
                    uint256 amount = referredInvestmentAmount.mul(information.referralBonusRates[i]).div(100);
                    users[activeReferrer].referral.levels[i].totalAmount = users[activeReferrer].referral.levels[i].totalAmount.add(amount);

                    emit ReferralBonus(activeReferrer, walletAddress, i, amount);
					activeReferrer = users[activeReferrer].referral.referrer;
                } 
                else break;
            }
        }
    }
    function getContractInformation() public view returns (Information memory) {
        return information;
    }
    function getUserInformation(address walletAddress) public view returns (User memory) {
        return users[walletAddress];
    }
    function getUserWithdrawableAmount(address walletAddress) public view returns (uint256) {
        return _getWithdrawableAmount(walletAddress);
    }
    function getWithdrawableReferralAmount(address walletAddress) public view returns (uint256) {
        return _getWithdrawableReferralAmount(walletAddress);
    }

    function changeAutoReinvestRate(uint256 rate) public {
        require(msg.sender == developerAddress, "[ERROR] You Are Not The Chosen One");

        information.autoReinvestRateOnWithdraw = rate;
        emit AutoReinivestRateChanged(msg.sender, rate);
    }

    function addPlan(uint256 dailyRate, bool locked, uint256 totalDays) public {
        require(msg.sender == developerAddress, "[ERROR] You Are Not The Chosen One");

        information.plans.push(
            Plan(
                dailyRate,         //dailyRate
                locked,            //locked
                totalDays          //totalDays
            )
        );
                
        emit NewPlanAdded(dailyRate, locked, totalDays);
    }

    function lowerCommissionRate(uint256 rate) public {
        require(msg.sender == developerAddress, "[ERROR] You Are Not The Chosen One");
        require(information.commissionRate > rate, "[ERROR] Rate is Higher Than Current");

        information.commissionRate = rate;
        emit CommissionRateChanged(msg.sender, rate);
    }

}