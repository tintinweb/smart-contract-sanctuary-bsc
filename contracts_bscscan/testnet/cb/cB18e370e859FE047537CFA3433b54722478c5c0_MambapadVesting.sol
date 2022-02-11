/**
 *Submitted for verification at BscScan.com on 2022-01-18
 */

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function allowance(address _owner, address spender) external view returns (uint256);
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
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
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }
}

library SafeMathInt {
  int256 private constant MIN_INT256 = int256(1) << 255;
  int256 private constant MAX_INT256 = ~(int256(1) << 255);

  function mul(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a * b;

    require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
    require((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {
    require(b != -1 || a != MIN_INT256);

    return a / b;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a - b;
    require((b >= 0 && c <= a) || (b < 0 && c > a));
    return c;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

  function abs(int256 a) internal pure returns (int256) {
    require(a != MIN_INT256);
    return a < 0 ? -a : a;
  }
}

abstract contract Auth {
  address internal owner;
  mapping(address => bool) internal authorizations;
  event OwnershipTransferred(address owner);

  modifier onlyOwner() {
    require(isOwner(msg.sender), '!OWNER');
    _;
  }

  modifier authorized() {
    require(isAuthorized(msg.sender), '!AUTHORIZED');
    _;
  }

  constructor(address _owner) {
    owner = _owner;
    authorizations[_owner] = true;
  }

  function authorize(address adr) public onlyOwner {
    authorizations[adr] = true;
  }

  function unauthorize(address adr) public onlyOwner {
    authorizations[adr] = false;
  }

  function transferOwnership(address payable adr) public onlyOwner {
    owner = adr;
    authorizations[adr] = true;
    emit OwnershipTransferred(adr);
  }

  function isOwner(address account) public view returns (bool) {
    return account == owner;
  }

  function isAuthorized(address adr) public view returns (bool) {
    return authorizations[adr];
  }
}

contract MambapadVesting is Auth {
  
  using SafeMath for uint256;
  using SafeMathInt for int256;

  IBEP20 public MambaContract;

  uint256 public Denominator = 100;
  uint256 public maxPerc = 100;


  uint256 public vestableTeamPerc = 80;

  uint256 public vestableDevPerc = 80;

  uint256 public vestableMarketingPerc = 80;

  uint256 public vestableAirdropPerc = 80;


  uint256 public Team_VESTING_PER_MONTH = 10;

  uint256 public Dev_VESTING_PER_MONTH = 10;

  uint256 public Marketing_VESTING_PER_MONTH = 10;
  
  uint256 public Airdrop_VESTING_PER_MONTH = 10;

  uint256 public vestedCount = 0;
  uint256 public periodPerVesting = 1 minutes;// 30 days;
  uint256 private availableVestingCount = 8;

  uint256 public totalVestableAmount = 160000;  //16,000,000
  uint256 public totalVestingAmount = 0;
  uint256 public vestedAmount = 0;
  uint256 public restAmount = 0;

  uint256 private vest_start_day;
  bool private finalSet = false;

  bool public isInitialDeposit;
  uint256 private constant MAX_UINT256 = ~uint256(0);

  event initialVestingAmountDeposit(address indexed _from, address indexed _to, uint256 amount);
  event MonthWithdraw(address indexed _to, uint256 amount);
  event EmergencyWithdraw(address indexed _from, uint256 amount);

  constructor(address _mambapad) Auth(msg.sender) {
    MambaContract =  IBEP20(_mambapad);
    vest_start_day = block.timestamp;
    MambaContract.approve(_mambapad, totalVestableAmount);
  }

  function initialDepositVestingAmountsP() public onlyOwner {
    require(isInitialDeposit == false, "Vesting:initialDepositVestingAmounts - Already deposited");
    uint256 tokenTotalSupply = MambaContract.totalSupply();

    
    uint256 teamTotalVestingAmount = tokenTotalSupply.mul(5).mul(vestableTeamPerc).div(Denominator).div(Denominator);
    uint256 devTotalVestingAmount = tokenTotalSupply.mul(5).mul(vestableDevPerc).div(Denominator).div(Denominator);
    uint256 marketingTotalVestingAmount = tokenTotalSupply.mul(5).mul(vestableMarketingPerc).div(Denominator).div(Denominator);
    uint256 airdropTotalVestingAmount = tokenTotalSupply.mul(5).mul(vestableAirdropPerc).div(Denominator).div(Denominator);

    totalVestingAmount = totalVestingAmount.add(teamTotalVestingAmount).add(devTotalVestingAmount).add(marketingTotalVestingAmount).add(airdropTotalVestingAmount);
    restAmount = totalVestingAmount;
    
    MambaContract.transfer(address(this), totalVestingAmount);
    isInitialDeposit = true;
    vestedCount = 1;

    emit initialVestingAmountDeposit(owner, address(this), totalVestingAmount);
  }

  function initialDepositVestingAmountsPP() public onlyOwner {
    require(isInitialDeposit == false, "Vesting:initialDepositVestingAmounts - Already deposited");
    uint256 tokenTotalSupply = MambaContract.totalSupply();

    
    uint256 teamTotalVestingAmount = tokenTotalSupply.mul(5).mul(vestableTeamPerc).div(Denominator).div(Denominator);
    uint256 devTotalVestingAmount = tokenTotalSupply.mul(5).mul(vestableDevPerc).div(Denominator).div(Denominator);
    uint256 marketingTotalVestingAmount = tokenTotalSupply.mul(5).mul(vestableMarketingPerc).div(Denominator).div(Denominator);
    uint256 airdropTotalVestingAmount = tokenTotalSupply.mul(5).mul(vestableAirdropPerc).div(Denominator).div(Denominator);

    totalVestingAmount = totalVestingAmount.add(teamTotalVestingAmount).add(devTotalVestingAmount).add(marketingTotalVestingAmount).add(airdropTotalVestingAmount);
    restAmount = totalVestingAmount;

    MambaContract.transferFrom(owner, address(this), totalVestingAmount);
    isInitialDeposit = true;
    vestedCount = 1;

    emit initialVestingAmountDeposit(owner, address(this), totalVestingAmount);
  }

  function monthWithdraw(address _to) external onlyOwner returns(bool) {
    require(isInitialDeposit, "Not deposited yet");
    uint256 period = block.timestamp - vest_start_day;
    require(period > vestedCount.mul(periodPerVesting), "Vesting:monthWithdraw - can't withdraw now");
    require(vestedCount < 9, "Vesting:monthWithdraw - can't withdraw anymore");

    uint256 tokenTotalSupply = MambaContract.totalSupply();


    uint256 teamAmount = tokenTotalSupply.mul(5).mul(10);
    teamAmount = teamAmount.div(Denominator).div(Denominator);

    uint256 devAmount = tokenTotalSupply.mul(5).mul(10);
    devAmount = devAmount.div(Denominator**2);

    uint256 marketingAmount = tokenTotalSupply.mul(5).mul(10);
    marketingAmount = marketingAmount.div(Denominator**2);

    uint256 airdropAmount = tokenTotalSupply.mul(5).mul(10);
    airdropAmount = airdropAmount.div(Denominator**2);


    uint256 monthTotalAmount = teamAmount.add(devAmount).add(marketingAmount).add(airdropAmount);
    address recipient = _to;
    
    if(MambaContract.balanceOf(address(this)) > monthTotalAmount)
      MambaContract.transfer(recipient, monthTotalAmount);
    else MambaContract.transfer(recipient, MambaContract.balanceOf(address(this)));

    vestedAmount = vestedAmount.add(monthTotalAmount);
    restAmount = totalVestingAmount.sub(vestedAmount);

    vestedCount++;

    emit MonthWithdraw(_to, monthTotalAmount);

    return true;
  }

  function setVestStartTime(uint _startTime) public onlyOwner {
    require(finalSet == false, "You can not set anymore");
    vest_start_day = _startTime;
    finalSet = true;
  }

  function setPeriodPerVesting(uint _period) public onlyOwner {
    periodPerVesting = _period;
  }

  function emergencyWithdraw(uint256 amount) external onlyOwner {
    MambaContract.transfer(owner, amount);
    emit EmergencyWithdraw(owner, amount);
  }

}