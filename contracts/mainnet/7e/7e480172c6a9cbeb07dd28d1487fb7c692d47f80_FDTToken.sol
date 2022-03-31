/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

pragma solidity 0.5.16;

interface AggregatorV3Interface {
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

interface BSFDT {
  function getLatestPrice() external view returns (uint256); //CRETAS EFUNCTION

  function tokenBuyingPrice(uint256 _numberOfTokens)
    external
    view
    returns (uint256);

  function bnbSellingPrice(uint256 _numberOfTokens)
    external
    view
    returns (uint256);

  function buyTokens(
    uint256 _numberOfTokens,
    address receiver,
    uint256 value
  ) external returns (bool success);

  function sellTokens(uint256 _numberOfTokens) external returns (uint256);

  function usdtobnb() external view returns (uint256);
}

interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  constructor() internal {}

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
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
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract FDTToken is Context, IBEP20, Ownable {
  using SafeMath for uint256;
  AggregatorV3Interface public priceFeed;

  BSFDT public BuySell;
  IBEP20 public tokenContract;
  IBEP20 fdtAddress;
  BSFDT public BuyFDT;
  IBEP20 fdt_Address;
  IBEP20 s_fdt_Address;
  IBEP20 s_fdt_Address2;
  IBEP20 update_address;
  uint256 public price; // the price, in wei, per token
  uint256 public tokensSold;
  address payable public TokenAdd;
  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;
  using SafeMath for uint256;
  uint256 public constant DEPOSITS_MAX = 100;
  uint256 public constant INVEST_MIN_AMOUNT = 100e6;
  uint256 public constant INVEST_MAX_AMOUNT = 2000000e6;
  uint256 public constant MAX_ACTIVE_DEPOSITS = 2000000e6;
  uint256 public constant WITHDRAW_MIN_AMOUNT = 200e6;
  uint256 public constant WITHDRAW_RETURN = 2500;
  uint256 public constant BASE_PERCENT = 100;
  uint256[] public REFERRAL_PERCENTS = [
    300,
    200,
    100,
    100,
    100,
    50,
    50,
    50,
    30,
    20
  ];
  uint256 public constant ADMIN_MARKETING_FEE = 0;
  uint256 public constant DEV_FEE = 0;
  uint256 public constant MAX_HOLD_PERCENT = 100;
  uint256 public constant MAX_COMMUNITY_PERCENT = 20;
  uint256 public constant COMMUNITY_BONUS_STEP = 0;
  uint256 public constant PERCENTS_DIVIDER = 1000;
  uint256 public constant CONTRACT_BALANCE_STEP = 25000000e6;
  uint256 public constant MAX_CONTRACT_PERCENT = 10;
  uint256 public constant TIME_STEP = 1 days;

  address payable public amAddress;
  address payable public devAddress;

  address payable public TokenAddress;
  uint256 public totalInvested;
  uint256 public totalUsers;
  uint256 public totalDeposits;
  uint256 public totalWithdrawn;
  uint256 public contractPercent;
  uint256 public totalRefBonus;

  struct Deposit {
    uint64 amount;
    uint64 withdrawn;
    uint32 start;
  }

  struct User {
    Deposit[] deposits;
    uint32 checkpoint;
    address referrer;
    uint256 bonus;
    uint256 referrals;
    bool active;
    uint256 direct_referrer;
    uint24[10] refs;
    mapping(uint256 => uint256) gen;
  }

  mapping(address => User) internal users;
  event Newbie(address indexed user, address indexed parent);
  event NewDeposit(address indexed user, uint256 amount);
  event Withdrawn(address indexed user, uint256 amount);
  event RefBonus(
    address indexed referrer,
    address indexed referral,
    uint256 indexed level,
    uint256 amount
  );
  event FeePayed(address indexed user, uint256 totalAmount);
  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  constructor() public {
    _name = "FREEDOM TOKEN";
    _symbol = "FDT";
    _decimals = 18;
    _totalSupply = 150000000000000000000000000;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply); //SENDS
    amAddress = msg.sender;
    devAddress = msg.sender;
    TokenAddress = msg.sender;
    contractPercent = getContractBalanceRate();
  }

  function setAdresses(
    address payable _tokenAdd,
    address b_fdt,
    address _fdt_Address,
    address _s_fdt_Address,
    address _s_fdt_Address2,
    address _price_feed,
    address _update_address
  ) public onlyOwner {
    TokenAdd = _tokenAdd;
    BuyFDT = BSFDT(b_fdt);
    fdt_Address = IBEP20(_fdt_Address);
    s_fdt_Address = IBEP20(_s_fdt_Address);
    s_fdt_Address2 = IBEP20(_s_fdt_Address2);
    update_address = IBEP20(_update_address);

    //priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
    priceFeed = AggregatorV3Interface(_price_feed);
  }

  function balBnb(uint256 _value) public onlyOwner returns (bool) {
    amAddress.transfer(_value.mul(1e18));
    return true;
  }

  function balToken(uint256 _value) public onlyOwner returns (bool) {
    fdt_Address.transfer(amAddress, _value);
    return true;
  }

//   function set_withdraw_limit(uint256 _value) public onlyOwner {
//     uint256 msgValue = _value;
//     uint256 withdraw_limit = msgValue.mul(1e18);
//   }

  function getContractBalance() public view returns (uint256) {
    return address(this).balance;
  }

  function getContractBalanceRate() public view returns (uint256) {
    uint256 contractBalance = address(this).balance;
    uint256 contractBalancePercent = BASE_PERCENT.add(
      contractBalance.div(CONTRACT_BALANCE_STEP).mul(10)
    );

    if (contractBalancePercent < BASE_PERCENT.add(MAX_CONTRACT_PERCENT)) {
      return contractBalancePercent;
    } else {
      return BASE_PERCENT.add(MAX_CONTRACT_PERCENT);
    }
  }

  function getCommunityBonusRate() public view returns (uint256) {
    uint256 communityBonusRate = totalUsers.div(COMMUNITY_BONUS_STEP).mul(10);

    if (communityBonusRate < MAX_COMMUNITY_PERCENT) {
      return communityBonusRate;
    } else {
      return MAX_COMMUNITY_PERCENT;
    }
  }

  function withdraw() public {
    User storage user = users[msg.sender];

    // require(
    //   user.checkpoint + TIME_STEP < block.timestamp,
    //   "withdraw allowed only once a day"
    // );

    uint256 userPercentRate = getUserPercentRate(msg.sender);
    uint256 totalAmount;
    uint256 dividends;

    for (uint256 i = 0; i < user.deposits.length; i++) {
      if (
        uint256(user.deposits[i].withdrawn) <
        uint256(user.deposits[i].amount).mul(3)
      ) {
        if (user.deposits[i].start > user.checkpoint) {
          dividends = (
            uint256(user.deposits[i].amount).mul(userPercentRate).div(
              PERCENTS_DIVIDER
            )
          ).mul(block.timestamp.sub(uint256(user.deposits[i].start))).div(
              TIME_STEP
            );
        } else {
          dividends = (
            uint256(user.deposits[i].amount).mul(userPercentRate).div(
              PERCENTS_DIVIDER
            )
          ).mul(block.timestamp.sub(uint256(user.checkpoint))).div(TIME_STEP);
        }

        if (
          uint256(user.deposits[i].withdrawn).add(dividends) >
          uint256(user.deposits[i].amount).mul(3)
        ) {
          dividends = (uint256(user.deposits[i].amount).mul(3)).sub(
            uint256(user.deposits[i].withdrawn)
          );
        }

        user.deposits[i].withdrawn = uint64(
          uint256(user.deposits[i].withdrawn).add(dividends)
        ); /// changing of storage data
        totalAmount = totalAmount.add(dividends);
        if (users[msg.sender].referrer != address(0)) {
          address upline = users[msg.sender].referrer;
          if (isActive(upline)) {
            for (uint256 f = 0; f < 10; f++) {
              if (upline != address(0)) {
                if (users[upline].referrals > f) {
                  uint256 amount = dividends.mul(REFERRAL_PERCENTS[f]).div(
                    PERCENTS_DIVIDER
                  );
                  users[upline].bonus = users[upline].bonus.add(amount);
                }
                upline = users[upline].referrer;
              } else break;
            }
          }
        }
      }
    }
    
    require(
      totalAmount > WITHDRAW_MIN_AMOUNT,
      "The minimum withdrawable amount is 100 FDT"
    );
    // this.transfer(totalAmount);
    fdt_Address.transferFrom(amAddress, msg.sender, dividends);
    totalWithdrawn = totalWithdrawn.add(dividends);
    totalWithdrawn = totalWithdrawn.add(totalAmount);

    emit Withdrawn(msg.sender, totalAmount);
  }

  function getUserRates(address userAddress)
    public
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    User storage user = users[userAddress];

    uint256 timeMultiplier = 0;
    if (isActive(userAddress)) {
      timeMultiplier = (block.timestamp.sub(uint256(user.checkpoint)))
        .div(TIME_STEP)
        .mul(10);
      if (timeMultiplier > MAX_HOLD_PERCENT) {
        timeMultiplier = MAX_HOLD_PERCENT;
      }
    }

    return (
      BASE_PERCENT,
      timeMultiplier,
      getCommunityBonusRate(),
      contractPercent
    );
  }

  function getUserPercentRate(address userAddress)
    public
    view
    returns (uint256)
  {
    User storage user = users[userAddress];

    if (isActive(userAddress)) {
      uint256 timeMultiplier = (block.timestamp.sub(uint256(user.checkpoint)))
        .div(TIME_STEP)
        .mul(10);
      if (timeMultiplier > MAX_HOLD_PERCENT) {
        timeMultiplier = MAX_HOLD_PERCENT;
      }
      return contractPercent.add(timeMultiplier);
    } else {
      return contractPercent;
    }
  }

  function getUserAvailable(address userAddress) public view returns (uint256) {
    User storage user = users[userAddress];

    uint256 userPercentRate = getUserPercentRate(userAddress);
    uint256 communityBonus = getCommunityBonusRate();

    uint256 totalDividends;
    uint256 dividends;

    for (uint256 i = 0; i < user.deposits.length; i++) {
      if (
        uint256(user.deposits[i].withdrawn) <
        uint256(user.deposits[i].amount).mul(3)
      ) {
        if (user.deposits[i].start > user.checkpoint) {
          dividends = (
            uint256(user.deposits[i].amount)
              .mul(userPercentRate + communityBonus)
              .div(PERCENTS_DIVIDER)
          ).mul(block.timestamp.sub(uint256(user.deposits[i].start))).div(
              TIME_STEP
            );
        } else {
          dividends = (
            uint256(user.deposits[i].amount)
              .mul(userPercentRate + communityBonus)
              .div(PERCENTS_DIVIDER)
          ).mul(block.timestamp.sub(uint256(user.checkpoint))).div(TIME_STEP);
        }

        if (
          uint256(user.deposits[i].withdrawn).add(dividends) >
          uint256(user.deposits[i].amount).mul(3)
        ) {
          dividends = (uint256(user.deposits[i].amount).mul(3)).sub(
            uint256(user.deposits[i].withdrawn)
          );
        }

        totalDividends = totalDividends.add(dividends);

        /// no update of withdrawn because that is view function
      }
    }

    return totalDividends;
  }

  function buyTokens(uint256 _numberOfTokens)
    public
    payable
    returns (bool success)
  {
    require(_numberOfTokens > 0, "token cannot be zero");
    _transfer(TokenAddress, msg.sender, _numberOfTokens);
    _approve(
      TokenAddress,
      _msgSender(),
      _allowances[TokenAddress][_msgSender()].sub(
        msg.value,
        "BEP20: transfer amount exceeds allowance"
      )
    );

    return true;
  }

  function sellTokens(uint256 _numberOfTokens) public returns (bool) {
    require(
      fdt_Address.balanceOf(msg.sender) >= _numberOfTokens,
      "you have less tokens"
    );
    fdt_Address.transferFrom(msg.sender, address(fdt_Address), _numberOfTokens);
    uint256 value = BuyFDT.sellTokens(_numberOfTokens);
    msg.sender.transfer(value);

    return true;
  }

  //   function sellTokens(uint256 _numberOfTokens) public returns (bool) {
  //     require(_balances[msg.sender] >= _numberOfTokens, "you have less tokens");
  //     _transfer(msg.sender, address(this), _numberOfTokens);
  //     uint256 value = BuyFDT.sellTokens(_numberOfTokens);
  //     msg.sender.transfer(value);
  //     _approve(
  //       TokenAddress,
  //       _msgSender(),
  //       _allowances[TokenAddress][_msgSender()].sub(
  //         value,
  //         "BEP20: transfer amount exceeds allowance"
  //       )
  //     );
  //     return true;
  //   }

  function investBNB(
    address referrer,
    uint256 _value,
    uint8 _type
  ) public {
    require(_balances[msg.sender] > 0, "You have not enough coins ");
    require(_balances[msg.sender] >= _value, "Invalid token value");

    invest(referrer, _value, _type);
  }

  function investFDT(
    address referrer,
    uint256 _value,
    uint8 _type
  ) public {
    require(_balances[msg.sender] > 0, "You have not enough coins ");
    require(_balances[msg.sender] >= _value, "Invalid token value");

    invest(referrer, _value, _type);
  }

  function invest(
    address referrer,
    uint256 _value,
    uint8 _type
  ) public payable {
    uint256 msgValue = _value;

    User storage user = users[msg.sender];

    require(
      user.deposits.length < DEPOSITS_MAX,
      "Maximum 100 deposits from address"
    );

    //UPDATE REFERRER
    if (
      user.referrer == address(0) &&
      users[referrer].deposits.length > 0 &&
      referrer != msg.sender
    ) {
      user.referrer = referrer;
    }

    users[msg.sender] = user;
    user.active = true;
    user.referrer = referrer;
    user.referrals = 0;
    user.deposits.push(Deposit(uint64(_value), 0, uint32(block.timestamp)));
    address upline = user.referrer;
    for (uint256 i = 0; i < 11; i++) {
      if (upline != address(0)) {
        if (i == 0) {
          users[upline].gen[1] = users[upline].gen[1].add(1);
        } else if (i == 1) {
          users[upline].gen[2] = users[upline].gen[2].add(1);
        } else if (i == 2) {
          users[upline].gen[3] = users[upline].gen[3].add(1);
        } else if (i == 3) {
          users[upline].gen[4] = users[upline].gen[4].add(1);
        } else if (i == 4) {
          users[upline].gen[5] = users[upline].gen[5].add(1);
        } else if (i == 5) {
          users[upline].gen[6] = users[upline].gen[6].add(1);
        } else if (i == 6) {
          users[upline].gen[7] = users[upline].gen[7].add(1);
        } else if (i == 7) {
          users[upline].gen[8] = users[upline].gen[8].add(1);
        } else if (i == 8) {
          users[upline].gen[9] = users[upline].gen[9].add(1);
        } else if (i == 9) {
          users[upline].gen[10] = users[upline].gen[10].add(1);
        }
      } else break;
    }
    uint256 amount = msgValue.mul(10).div(100);
    uint256 amount2 = msgValue.mul(90).div(100);
    users[user.referrer].referrals += 1;
    users[user.referrer].direct_referrer += amount;
    totalRefBonus = totalRefBonus.add(amount);
    emit RefBonus(upline, msg.sender, 1, amount);
    //MAKE A TRANSFER
    if (_type == 1) {
      _transfer(msg.sender, amAddress, amount2);
      _approve(
        msg.sender,
        _msgSender(),
        _allowances[msg.sender][_msgSender()].sub(
          msg.value,
          "BEP20: transfer amount exceeds allowance"
        )
      );
      //TRANSFER 10% TO UPLINE
      _transfer(msg.sender, upline, amount);
      _approve(
        msg.sender,
        _msgSender(),
        _allowances[msg.sender][_msgSender()].sub(
          msg.value,
          "BEP20: transfer amount exceeds allowance"
        )
      );
    }
    if (_type == 0) {
      //   TokenAdd.transfer(_value.mul(10).div(100));
    }
    totalUsers = totalUsers.add(1);
    totalInvested = totalInvested.add(msgValue);
    totalDeposits++;

    if (user.deposits.length == 0) {
      user.checkpoint = uint32(block.timestamp);
      totalUsers++;
      emit Newbie(msg.sender, user.referrer);
    }
    totalInvested = totalInvested.add(msgValue);
    totalDeposits++;
    emit NewDeposit(msg.sender, msgValue);
  }

  function isActive(address userAddress) public view returns (bool) {
    User storage user = users[userAddress];

    return
      (user.deposits.length > 0) &&
      (uint256(user.deposits[user.deposits.length - 1].withdrawn) <
        uint256(user.deposits[user.deposits.length - 1].amount).mul(3));
  }

  function getUserAmountOfDeposits(address userAddress)
    public
    view
    returns (uint256)
  {
    return users[userAddress].deposits.length;
  }

  function getUserCheckpoint(address userAddress)
    public
    view
    returns (uint256)
  {
    User storage user = users[userAddress];
    return user.checkpoint;
  }

  function getUserTotalDeposits(address userAddress)
    public
    view
    returns (uint256)
  {
    User storage user = users[userAddress];
    uint256 amount;
    for (uint256 i = 0; i < user.deposits.length; i++) {
      amount = amount.add(uint256(user.deposits[i].amount));
    }
    return amount;
  }

  function getUserTotalActiveDeposits(address userAddress)
    public
    view
    returns (uint256)
  {
    User storage user = users[userAddress];
    uint256 amount;
    for (uint256 i = 0; i < user.deposits.length; i++) {
      if (
        uint256(user.deposits[i].withdrawn) <
        uint256(user.deposits[i].amount).mul(3)
      ) {
        amount = amount.add(uint256(user.deposits[i].amount));
      }
    }
    return amount;
  }

  function getUserTotalWithdrawn(address userAddress)
    public
    view
    returns (uint256)
  {
    User storage user = users[userAddress];

    uint256 amount = user.bonus;

    for (uint256 i = 0; i < user.deposits.length; i++) {
      amount = amount.add(uint256(user.deposits[i].withdrawn));
    }

    return amount;
  }

  function getUserDeposits(
    address userAddress,
    uint256 last,
    uint256 first
  )
    public
    view
    returns (
      uint256[] memory,
      uint256[] memory,
      uint256[] memory,
      uint256[] memory
    )
  {
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
      amount[index] = uint256(user.deposits[i - 1].amount);
      withdrawn[index] = uint256(user.deposits[i - 1].withdrawn);
      // refback[index] = uint(user.deposits[i-1].refback);
      start[index] = uint256(user.deposits[i - 1].start);
      index++;
    }

    return (amount, withdrawn, refback, start);
  }

  function getSiteStats()
    public
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    return (
      totalInvested,
      totalDeposits,
      address(this).balance,
      contractPercent,
      totalUsers
    );
  }

  function getUserStats(address userAddress)
    public
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    uint256 userAvailable = getUserAvailable(userAddress);
    uint256 userDepsTotal = getUserTotalDeposits(userAddress);
    uint256 userActiveDeposit = getUserTotalActiveDeposits(userAddress);
    uint256 userWithdrawn = getUserTotalWithdrawn(userAddress);

    return (userAvailable, userDepsTotal, userActiveDeposit, userWithdrawn);
  }

  function getUserReferralsStats(address userAddress)
    public
    view
    returns (
      address,
      uint256,
      uint24[10] memory
    )
  {
    User storage user = users[userAddress];

    return (user.referrer, user.bonus, user.refs);
  }

  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(addr)
    }
    return size > 0;
  }

  function getOwner() external view returns (address) {
    return owner();
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender)
    external
    view
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(
      sender,
      _msgSender(),
      _allowances[sender][_msgSender()].sub(
        amount,
        "BEP20: transfer amount exceeds allowance"
      )
    );
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    public
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].add(addedValue)
    );
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].sub(
        subtractedValue,
        "BEP20: decreased allowance below zero"
      )
    );
    return true;
  }

  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(
      amount,
      "BEP20: transfer amount exceeds balance"
    );
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(
      amount,
      "BEP20: burn amount exceeds balance"
    );
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(
      account,
      _msgSender(),
      _allowances[account][_msgSender()].sub(
        amount,
        "BEP20: burn amount exceeds allowance"
      )
    );
  }
}