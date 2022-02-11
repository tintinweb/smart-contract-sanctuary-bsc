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

contract PrivateSale is Auth {
  using SafeMath for uint256;
  using SafeMathInt for int256;

  struct InvestorInfo {
    uint256 vestedDate; //in seconds
    uint256 _cliff; // in seconds
    uint256 totalReceivableAmount; //total
    uint256 receivableAmount; //left
    uint256 currentAmount; //current  e.g. total = left + current
    uint256 releaseState; // 0: not released, 1: listing-released, 2: first-released, 3: second-released, 4: third-released, 5: last-released
  }

  IBEP20 public MambaContract;
  address public mambapadAddress;

  /////////// whitelist
  mapping(address => bool) private _isWhitelisted; // white listed flag
  uint256 public totalWhiteListed; // white listed users number
  address[] public holdersIndex; // iterable index of holders
  // Create a new role identifier for the controller role

  event AdddWhitelisted(address indexed user);
  event RemovedWhitelisted(address indexed user);

  ////////// private sale

  address[] public investors;

  uint256 public totalAmountForPrivateSale = 10000000; //10,000,000
  uint256 public rateMAMPperBNB = 80000; //80,000
  uint256 public etherDenominator = 10**18;
  uint256 public mampDenominator = 10**8;
  uint256 public rateDenominator = 10**10;
  uint256 public percDenominator = 100;
  uint256 public fee = 3;

  uint256 public cliff = 5 minutes;
  uint256 public duration = 3 days;
  uint256 public TGE = 20; //20%
  uint256 public PercPerMonth = 20; //20%
  bool public isListedonPancakeswap = false;

  uint256 public start_time = 1644753600; //13th Feb 2022
  uint256 public end_time = 1645012800; //16th Feb 2022

  uint256 public min_buy_amount_estimate = 10; //0.1 * percDenominator
  uint256 public max_buy_amount_estimate = 24; //2.4 * percDenominator

  uint256 public depositedBNB = 0;
  mapping(address => InvestorInfo) public investorInfos;

  event joinedPool(address indexed from, uint256 amount);
  event withdrawn(address indexed from, uint256 rewardAmount);

  constructor(address _mambapad) Auth(msg.sender) {
    require(_mambapad != address(0), 'PrivateSale: mambapad is zero address');

    MambaContract = IBEP20(_mambapad);
    MambaContract.approve(_mambapad, totalAmountForPrivateSale);
    mambapadAddress = _mambapad;
  }

  function getAmountToBuy() public payable returns (uint256) {
    return (msg.value).mul(rateMAMPperBNB).div(rateDenominator);
  }

  function joinPool() public payable {
    require(block.timestamp > start_time, "PrivateSale:joinPool - Can't join pool yet");
    require(block.timestamp < end_time, "PrivateSale:joinPool - Can't join pool more");
    require(msg.value >= min_buy_amount_estimate.mul(etherDenominator).div(percDenominator), "PrivateSale:joinPool - Can't be under min_buy_amount");
    require(msg.value <= max_buy_amount_estimate.mul(etherDenominator).div(percDenominator), "PrivateSale:joinPool - Can't be over max_buy_amount");
    require(isWhitelisted(msg.sender), 'PrivateSale:joinPool - User is not whitelisted');

    uint256 amountToBuy = (msg.value).mul(rateMAMPperBNB).div(rateDenominator);

    require(
      MambaContract.balanceOf(address(this)) > amountToBuy,
      'PrivateSale:joinPool - This pool has no enough Mamp than amountToBuy'
    );

    investorInfos[msg.sender] = InvestorInfo(block.timestamp, 0, amountToBuy, amountToBuy, 0, 0);
    investors.push(msg.sender);
    depositedBNB = depositedBNB.add(msg.value);

    uint256 TGEtoPancakeswap = amountToBuy.mul(TGE).div(percDenominator);
    MambaContract.transfer(mambapadAddress, TGEtoPancakeswap);

    emit joinedPool(msg.sender, msg.value);
  }

  function withdrawBNB(uint256 _amount, address _to) public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, 'PrivateSale: No BNB to withdraw');

    (bool sent, ) = _to.call{value: _amount}('');
    require(sent, 'PrivateSale: Transfer failed.');
    emit withdrawn(msg.sender, ownerBalance);
  }

  function withdrawMAMP(uint256 _amount, address _to) public onlyOwner {
    uint256 ownerBalance = MambaContract.balanceOf(address(this));
    require(ownerBalance > 0, 'PrivateSale: No MAMP to withdraw');

    MambaContract.transfer(_to, _amount);

    emit withdrawn(msg.sender, ownerBalance);
  }

  function withdrawTGE() public {
    require(isListedonPancakeswap, 'PrivateSale:withdrawTGE - Is not yet listed on PancakeSwap');
    require(investorInfos[msg.sender].releaseState == 0, 'PrivateSale:withdrawTGE - You already received TGE');
    require(isWhitelisted(msg.sender), 'PrivateSale:withdrawTGE - User is not whitelisted');

    uint256 receivingAmountAfterListing = investorInfos[msg.sender].receivableAmount.mul(TGE).div(percDenominator);
    _claimMamp(receivingAmountAfterListing);

    // uint256 releasedAmount = MambaContract.balanceOf(msg.sender);

    investorInfos[msg.sender]._cliff = block.timestamp.add(cliff); //30 * 24 * 60 * 60
    uint256 nextReceivableAmount = investorInfos[msg.sender].receivableAmount.sub(receivingAmountAfterListing);
    investorInfos[msg.sender].receivableAmount = nextReceivableAmount;
    investorInfos[msg.sender].currentAmount = receivingAmountAfterListing;
    investorInfos[msg.sender].releaseState = 1;
    emit withdrawn(address(this), receivingAmountAfterListing);
  }

  function withdrawPerMonth() public {
    require(isListedonPancakeswap, 'PrivateSale:withdrawPerMonth - Is not yet listed on PancakeSwap');
    require(isWhitelisted(msg.sender), 'PrivateSale:withdrawPerMonth - User is not whitelisted');
    require(
      investorInfos[msg.sender]._cliff < block.timestamp,
      'PrivateSale:withdrawPerMonth - is not the time to withdraw monthly'
    );
    require(investorInfos[msg.sender].releaseState >= 1, 'PrivateSale:withdrawPerMonth - First receive TGE');
    require(
      investorInfos[msg.sender].releaseState < 5,
      'PrivateSale:withdrawPerMonth - You are all received Amount of Private Sale'
    );

    uint256 amountToReceivePerMonth = investorInfos[msg.sender].totalReceivableAmount.mul(PercPerMonth).div(
      percDenominator
    );
    _claimMamp(amountToReceivePerMonth);

    investorInfos[msg.sender]._cliff = block.timestamp.add(cliff);
    investorInfos[msg.sender].receivableAmount = investorInfos[msg.sender].receivableAmount.sub(
      amountToReceivePerMonth
    );
    investorInfos[msg.sender].currentAmount = investorInfos[msg.sender].currentAmount.add(amountToReceivePerMonth);
    investorInfos[msg.sender].releaseState++;
    emit withdrawn(address(this), amountToReceivePerMonth);
  }

  function addTotalAmountForPrivateSale(uint256 _addingAmount) public onlyOwner {
    totalAmountForPrivateSale = totalAmountForPrivateSale.add(_addingAmount);
  }

  function setListedonPancakeswap() public onlyOwner {
    isListedonPancakeswap = true;
  }

  function setStartTime(uint256 _startTime) public onlyOwner {
    start_time = _startTime;
  }

  ///////////////////////////////////////////////////////////////////////////////////////////  only for test
  function setCliff(uint256 _cliff) public onlyOwner {
    cliff = _cliff;
  }

  //////////////////////////////////////////////////////////////////////////////////////////
  function setEndTime(uint256 _endTime) public onlyOwner {
    end_time = _endTime;
  }

  function getInvestorInfo(address _beneficiary) public view returns (InvestorInfo memory) {
    return investorInfos[_beneficiary];
  }

  function getInvestorsCount() public view returns (uint256) {
    return investors.length;
  }

  function getInfo()
    public
    view
    returns (
      uint256 mampAmountofContract,
      uint256 bnbAmountDepositedinContract,
      uint256 startingTime,
      uint256 endingTime
    )
  {
    mampAmountofContract = MambaContract.balanceOf(address(this));
    bnbAmountDepositedinContract = depositedBNB;
    startingTime = start_time;
    endingTime = end_time;
    return (MambaContract.balanceOf(address(this)), depositedBNB, start_time, end_time);
  }

  function getBalanceofContract() public view returns (uint256) {
    return address(this).balance;
  }

  function getContractMampBalance() public view returns (uint256) {
    require(MambaContract.balanceOf(address(this)) > 0, 'PrivateSale: balance is 0');
    return MambaContract.balanceOf(address(this));
  }

  function getDepositedBNB() public view returns (uint256) {
    return depositedBNB;
  }

  function getStartTime() public view returns (uint256) {
    return start_time;
  }

  function getEndTime() public view returns (uint256) {
    return end_time;
  }

  function _claimMamp(uint256 amountToBuy) private {
    if (MambaContract.balanceOf(address(this)) > amountToBuy) {
      MambaContract.transfer(msg.sender, amountToBuy);
    } else MambaContract.transfer(msg.sender, MambaContract.balanceOf(address(this)));
  }

  /**
   * @dev Add an account to the whitelist,
   * @param user The address of the investor
   */
  function addWhitelisted(address user) public onlyOwner {
    _addWhitelisted(user);
  }

  /**
   * @notice This function allows to whitelist investors in batch
   * with control of number of iterations
   * @param users The accounts to be whitelisted in batch
   */
  function addWhitelistedMultiple(address[] calldata users) public onlyOwner {
    uint256 length = users.length;
    require(length <= 256, 'Whitelist-addWhitelistedMultiple: List too long');
    for (uint256 i = 0; i < length; i++) {
      _addWhitelisted(users[i]);
    }
  }

  /**
   * @notice Remove an account from the whitelist, calling the corresponding internal
   * function
   * @param user The address of the investor that needs to be removed
   */
  function removeWhitelisted(address user) public onlyOwner {
    _removeWhitelisted(user);
  }

  /**
   * @notice This function allows to whitelist investors in batch
   * with control of number of iterations
   * @param users The accounts to be whitelisted in batch
   */
  function removeWhitelistedMultiple(address[] calldata users) public onlyOwner {
    uint256 length = users.length;
    require(length <= 256, 'Whitelist-removeWhitelistedMultiple: List too long');
    for (uint256 i = 0; i < length; i++) {
      _removeWhitelisted(users[i]);
    }
  }

  /**
   * @notice Check if an account is whitelisted or not
   * @param user The account to be checked
   * @return true if the account is whitelisted. Otherwise, false.
   */
  function isWhitelisted(address user) public view returns (bool) {
    return _isWhitelisted[user];
  }

  /**
   * @notice Add an investor to the whitelist
   * @param user The address of the investor that has successfully passed KYC
   */
  function _addWhitelisted(address user) private {
    require(user != address(0), 'WhiteList:_addWhiteList - Not a valid address');
    require(_isWhitelisted[user] == false, 'Whitelist-_addWhitelisted: account already whitelisted');
    _isWhitelisted[user] = true;
    totalWhiteListed++;
    holdersIndex.push(user);
    emit AdddWhitelisted(user);
  }

  /**
   * @notice Remove an investor from the whitelist
   * @param user The address of the investor that needs to be removed
   */
  function _removeWhitelisted(address user) private {
    require(user != address(0), 'WhiteList:_removeWhitelisted - Not a valid address');
    require(_isWhitelisted[user] == true, 'Whitelist-_removeWhitelisted: account was not whitelisted');
    _isWhitelisted[user] = false;
    totalWhiteListed--;
    emit RemovedWhitelisted(user);
  }
}