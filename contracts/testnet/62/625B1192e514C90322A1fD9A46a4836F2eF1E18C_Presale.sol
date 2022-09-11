/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);
  function burn(uint256 amount) external;

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);


  function mintPRESALE(address account_, uint256 amount_) external;

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
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
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }
}

library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return _functionCallWithValue(target, data, 0, errorMessage);
  }

  function _functionCallWithValue(
    address target,
    bytes memory data,
    uint256 weiValue,
    string memory errorMessage
  ) private returns (bytes memory) {
    require(isContract(target), "Address: call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{value: weiValue}(
      data
    );
    if (success) {
      return returndata;
    } else {
      if (returndata.length > 0) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }

  function _verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) private pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      if (returndata.length > 0) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }
}

library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transfer.selector, to, value)
    );
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
    );
  }

  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    bytes memory returndata = address(token).functionCall(
      data,
      "SafeERC20: low-level call failed"
    );
    if (returndata.length > 0) {
      // Return data is optional
      // solhint-disable-next-line max-line-length
      require(
        abi.decode(returndata, (bool)),
        "SafeERC20: ERC20 operation did not succeed"
      );
    }
  }
}

interface IOwnable {
  function owner() external view returns (address);

  function renounceOwnership() external;

  function transferOwnership(address newOwner_) external;
}

contract Ownable is IOwnable {
  address internal _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  function owner() public view override returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public virtual override onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner_)
    public
    virtual
    override
    onlyOwner
  {
    require(newOwner_ != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner_);
    _owner = newOwner_;
  }
}

library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract Presale is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  using Counters for Counters.Counter;

  Counters.Counter public totalContributors;

  address public blstToken;
  address public busd;

  uint256 public minPurchaseAmount;
  uint256 public maxPurchaseAmount;
  uint256 public maxExtraPurchaseAmount;
  uint256 public totalAmount;
  uint256 public sellAmount;
  uint256 public rate;

  bool public openIdo = false;
  bool public openClaim = false;
  bool public finishIdo = false;
  uint256 public saleStartTime;
  uint256 public privateSalePeriod = 1 hours;
  
  mapping(address => uint256) public purchasedAmount;

  mapping(address => bool) public boughtTokens;
  mapping(address => bool) public claimed;
  mapping(address => bool) public whitelisted;
  mapping(address => bool) public extraWhitelisted;

  constructor() {
  }

  function initialize(
    address _blstToken,
    address _busd,
    uint256 _rate,
    uint256 _totalAmount,
    uint256 _minPurchaseAmount,
    uint256 _maxPurchaseAmount,
    uint256 _maxExtraPurchaseAmount
  ) external onlyOwner returns (bool) {
    blstToken = _blstToken;
    busd = _busd;
    totalAmount = _totalAmount;
    rate = _rate;
    minPurchaseAmount = _minPurchaseAmount;
    maxPurchaseAmount = _maxPurchaseAmount;
    maxExtraPurchaseAmount = _maxExtraPurchaseAmount;
    return true;
  }

  function whitelistUsers(address[] memory addresses) public onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
      if(whitelisted[addresses[i]] == false) {
        whitelisted[addresses[i]] = true;
      }
    }
  }

  function unwhitelistUsers(address[] memory addresses) public onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {      
      if(whitelisted[addresses[i]] == true) {
        whitelisted[addresses[i]] = false;
      }
    }
  }

  function extraWhitelistUsers(address[] memory addresses) public onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
      if(extraWhitelisted[addresses[i]] == false) {
        extraWhitelisted[addresses[i]] = true;
      }
    }
  }

  function extraUnwhitelistUsers(address[] memory addresses) public onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {      
      if(extraWhitelisted[addresses[i]] == true) {
        extraWhitelisted[addresses[i]] = false;
      }
    }
  }

  function setOpenPresale(bool _open) external onlyOwner {
    openIdo = _open;
    if (_open == true)
      saleStartTime = block.timestamp;
  }

  function setOpenClaim(bool _open) external onlyOwner {
    openClaim = _open;
  }

  function setFinishPresale(bool _open) external onlyOwner {
    finishIdo = _open;
  }

  function isOpenForUser(address _user) public view returns (bool) {
    if(!openIdo || whitelisted[_user] == false || extraWhitelisted[_user] == false || (boughtTokens[_user] && purchasedAmount[_user] == maxPurchaseAmount) || (boughtTokens[_user] && purchasedAmount[_user] == maxExtraPurchaseAmount))
      return false;
    uint256 privateSaleEndTime = saleStartTime.add(privateSalePeriod);
    return block.timestamp < privateSaleEndTime && block.timestamp > saleStartTime;
  }

  function getClaimable(address _user) public view returns (bool) {
    return openClaim == true && claimed[_user] == false && boughtTokens[_user] && (saleStartTime.add(privateSalePeriod) < block.timestamp || finishIdo == true);
  }

  function getTimeForClaim() external view returns (uint256) {
    if (finishIdo == true || saleStartTime.add(privateSalePeriod) < block.timestamp)
      return 0;
    else
      return saleStartTime.add(privateSalePeriod).sub(block.timestamp);
  }

  function purchase(uint256 _purchaseAmount) external returns (bool) {
    require(openIdo == true, "IDO is closed");
    require(purchasedAmount[msg.sender] < maxPurchaseAmount, "You've already purchased max amount.");
    require(_purchaseAmount >= minPurchaseAmount, "Less than min amount");
    require(whitelisted[msg.sender] == true || extraWhitelisted[msg.sender] == true, "You are not a whitelisted user.");

    if (whitelisted[msg.sender] == true)
      require(_purchaseAmount <= maxPurchaseAmount, "More than max amount");
    else if (extraWhitelisted[msg.sender] == true)
      require(_purchaseAmount <= maxExtraPurchaseAmount, "More than max amount");

    uint256 nowTime = block.timestamp;
    uint256 busdVal = IERC20(busd).balanceOf(msg.sender);
    require(busdVal >= _purchaseAmount, "Insufficient busd balance.");
    sellAmount = sellAmount.add(_purchaseAmount);

    require(sellAmount <= totalAmount, "The amount entered exceeds IDO Goal");
    require(nowTime < saleStartTime.add(privateSalePeriod), "Presale is finished.");

    if (boughtTokens[msg.sender] == false){
      boughtTokens[msg.sender] = true;
      totalContributors.increment();
    }
    IERC20(busd).safeTransferFrom(msg.sender, address(this), _purchaseAmount.mul(10 ** 18));
    purchasedAmount[msg.sender] = purchasedAmount[msg.sender].add(_purchaseAmount);
    return true;
  }

  function claim() external returns (bool) {
    require(openClaim == true, "Can't claim now. please wait.");
    require(claimed[msg.sender] == false, "You have already claimed.");

    uint256 _purchaseAmount = purchasedAmount[msg.sender];
    require(_purchaseAmount > 0, "Can't claim.");
    
    IERC20(blstToken).safeTransfer(msg.sender, _purchaseAmount.mul(rate).mul(10 ** 18).div(100));
    claimed[msg.sender] = true;
    return true;
  }

  function withdraw() external onlyOwner {
    uint256 blstAmount = (totalAmount.sub(sellAmount)).mul(rate).mul(10 ** 18).div(100);
    if (totalAmount < sellAmount){
      blstAmount = IERC20(blstToken).balanceOf(address(this));
    }
    uint256 busdAmount = IERC20(busd).balanceOf(address(this));
    IERC20(busd).approve(msg.sender, busdAmount);
    IERC20(busd).safeTransfer(msg.sender, busdAmount);

    IERC20(blstToken).approve(msg.sender, blstAmount);
    IERC20(blstToken).safeTransfer(msg.sender, blstAmount);
  }
}