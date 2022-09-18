/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

// SPDX-License-Identifier: Mozilla
pragma solidity ^0.8.0;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

abstract contract Ownable is Context {
  address private _owner;

  constructor() {
    _transferOwnership(_msgSender());
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(address(0));
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

abstract contract Destory is Context, Ownable {
  function destory() public onlyOwner {
    selfdestruct(payable(owner()));
  }
}

library Address {
  function isContract(address account) internal view returns (bool) {
    return account.code.length > 0;
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount);
    (bool success, ) = recipient.call{value: amount}("");
    require(success);
  }

  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, "Address: low-level call failed");
  }

  function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, errorMessage);
  }

  function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

  function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
    require(address(this).balance >= value);
    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return verifyCallResultFromTarget(target, success, returndata, errorMessage);
  }

  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
    return functionStaticCall(target, data, "Address: low-level static call failed");
  }

  function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
    (bool success, bytes memory returndata) = target.staticcall(data);
    return verifyCallResultFromTarget(target, success, returndata, errorMessage);
  }

  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionDelegateCall(target, data, "Address: low-level delegate call fialed");
  }

  function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return verifyCallResultFromTarget(target, success, returndata, errorMessage);
  }

  function verifyCallResultFromTarget(address target, bool success, bytes memory returndata, string memory errorMessage) internal view returns (bytes memory) {
    if (success) {
      if (returndata.length == 0) {
        require(isContract(target));
      }
      return returndata;
    } else {
      _revert(returndata, errorMessage);
    }
  }

  function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      _revert(returndata, errorMessage);
    }
  }

  function _revert(bytes memory returndata, string memory errorMessage) private pure {
    if (returndata.length > 0) {
      assembly {
        let returndataSize := mload(returndata)
        revert(add(32, returndata), returndataSize)
      }
    } else {
      revert(errorMessage);
    }
  }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);
  function transfer(address to, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}

library SafeERC20 {
  using Address for address;

  function safeTransfer(IERC20 token, address to, uint256 value) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(IERC20 token, address spender, uint256 value) internal {
    require((value == 0) || (token.allowance(address(this), spender) == 0));
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    uint256 newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    unchecked {
      uint256 oldAllowance = token.allowance(address(this), spender);
      require(oldAllowance >= value);
      uint256 newAllowance = oldAllowance - value;
      _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
  }

  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) {
      require(abi.decode(returndata, (bool)));
    }
  }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require (c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
        return c;
    }
}

interface IVesting {
  function setStartTime(uint64 startTime) external returns (bool);
  function addBalance(address beneficiary, uint256 amount) external returns (bool);
  function getBalance(address beneficiary) external view returns (uint256);
  function release() external returns (bool);
  function release(address beneficiary) external returns (bool);
  function getRelease(address beneficiary) external view returns (uint256);
  function addOperationAuthority(address perm) external returns (bool);
}

contract Vesting5 is IVesting, Ownable, Destory {
  using SafeMath for uint256;

  address private _tokenAddress;
  address private _fromWallet;
  address private _inviteFromWallet;

  uint256 private _released;

  uint64 private _start;
  uint64 private _duration;
  uint64 private _firstPercentage;

  mapping(address => bool) private _operationAuthority;

  mapping(address => uint256) private _beneficiaryBalances;
  mapping(address => uint256) private _beneficiaryInviteBalances;
  mapping(address => uint256) private _beneficiaryBalanceReleased;
  mapping(address => uint256) private _beneficiaryInviteBalanceReleased;

  bool private _isStart = false;

  struct Info {
    uint256 lockBalance;
    uint256 unlockBalance;
    uint256 withdrawBalance;
    uint256 lockInviateBalance;
    uint256 unlockInviteBalance;
    uint256 withdrawInviteBalance;
  }

  constructor(address __tokenAddress, address __fromWallet, address __inviteFromWallet, uint64 firstPercentage, uint64 durationSeconds) {
    require(__tokenAddress != address(0), "Vesting5: tokenAddress is zero");
    require(__fromWallet != address(0), "Vesting5: fromWallet is zero");
    require(__inviteFromWallet != address(0), "Vesting5: inviteFromWallet is zero");
    _tokenAddress = __tokenAddress;
    _fromWallet = __fromWallet;
    _inviteFromWallet = __inviteFromWallet;

    _duration = durationSeconds;
    _firstPercentage = firstPercentage;

    _operationAuthority[_msgSender()] = true;
  }

  modifier hasPerm() {
    require(_operationAuthority[_msgSender()], "Vesting5: caller is not has authority");
    _;
  }

  modifier isStart() {
    require(_isStart, "Vesting5: caller is not start");
    _;
  }

  function addBalance(address beneficiary, uint256 amount) public override hasPerm returns (bool) {
    require(beneficiary != address(0), "Vesting5: addBalance beneficiary is zero");
    _beneficiaryBalances[beneficiary] += amount;
  }

  function getBalance(address beneficiary) public view override returns (uint256) {
    require(beneficiary != address(0), "Vesting5: getBalance beneficiary is zero");
    return _beneficiaryBalances[beneficiary];
  }

  function addInvite(address beneficiary, uint256 amount) public hasPerm returns (bool) {
    require(beneficiary != address(0), "Vesting5: addBalance beneficiary is zero");
    _beneficiaryInviteBalances[beneficiary] += amount;
    return true;
  }

  function getInvite(address beneficiary) public view returns (uint256) {
    require(beneficiary != address(0), "Vesting5: getInvite beneficiary is zero");
    return _beneficiaryBalances[beneficiary];
  }

  function getInviteRelease(address beneficiary) public view returns (uint256) {
    require(beneficiary != address(0), "Vesting5: getInviteRelease beneficiary is zero");
    return _beneficiaryInviteBalanceReleased[beneficiary];
  }

  function release() public override hasPerm isStart returns (bool) {
    revert("Vesting5: release not support");
    return true;
  }

  function release(address beneficiary) public override hasPerm isStart returns (bool) {
    require(beneficiary != address(0), "Vesting5: release beneficiary is zero");
    uint256 balanceReleaseable = vestedAmountBalance(beneficiary, uint64(block.timestamp)) - _beneficiaryBalanceReleased[beneficiary];
    uint256 inviteReleaseable = vestedAmountInvite(beneficiary, uint64(block.timestamp)) - _beneficiaryInviteBalanceReleased[beneficiary];
    _beneficiaryBalanceReleased[beneficiary] += balanceReleaseable;
    _beneficiaryInviteBalanceReleased[beneficiary] += inviteReleaseable;
    _beneficiaryBalances[beneficiary] -= balanceReleaseable;
    _beneficiaryInviteBalances[beneficiary] -= inviteReleaseable;
    if (balanceReleaseable > 0) {
        IERC20(_tokenAddress).transferFrom(_fromWallet, beneficiary, balanceReleaseable);
    }
    if (inviteReleaseable > 0) {
        IERC20(_tokenAddress).transferFrom(_inviteFromWallet, beneficiary, inviteReleaseable);
    }
  }

  function getRelease(address beneficiary) public view override returns (uint256) {
    require(beneficiary != address(0), "Vesting5: getRelease beneficiary is zero");
    return _beneficiaryBalanceReleased[beneficiary];
  }

  function addOperationAuthority(address perm) public override onlyOwner returns (bool) {
    require(perm != address(0), "Vesting5: addOperationAuthority address is zero");
    _operationAuthority[perm] = true;
    return true;
  }

  function vestedAmountBalance(address beneficiary, uint64 timestamp) public view returns (uint256) {
    return _vestingSchedule(_beneficiaryBalances[beneficiary] + _beneficiaryBalanceReleased[beneficiary], timestamp);
  }

  function vestedAmountInvite(address beneficiary, uint64 timestamp) public view returns (uint256) {
    return _vestingSchedule(_beneficiaryInviteBalances[beneficiary] + _beneficiaryInviteBalanceReleased[beneficiary], timestamp);
  }

  function start() public view returns (uint64) {
    return _start;
  }

  function setStartTime(uint64 startAt) public override hasPerm returns (bool) {
    require(!_isStart, "Vesting5: setStartTime alreday start");
    _start = startAt;
    return true;
  }

  function setStart() public hasPerm returns (bool) {
    require(!_isStart, "Vesting5: setStart alreday start");
    _isStart = true;
    _start = uint64(block.timestamp);
    return true;
  }

  function info(address account) public view returns (Info memory) {
    require(account != address(0), "Vesting5: info account is zero");
    uint256 balanceReleaseable = vestedAmountBalance(account, uint64(block.timestamp)) - _beneficiaryBalanceReleased[account];
    uint256 inviteReleaseable = vestedAmountInvite(account, uint64(block.timestamp)) - _beneficiaryInviteBalanceReleased[account];
    return Info({
      lockBalance : _beneficiaryBalances[account],
      unlockBalance : _beneficiaryBalanceReleased[account],
      withdrawBalance : balanceReleaseable,
      lockInviateBalance : _beneficiaryInviteBalances[account],
      unlockInviteBalance : _beneficiaryInviteBalanceReleased[account],
      withdrawInviteBalance : inviteReleaseable
    });
  }

  function _vestingSchedule(uint256 totalAllocation, uint256 timestamp) internal view returns (uint256) {
    if (!_isStart) {
      return 0;
    }
    if (timestamp < _start) {
      return 0;
    } else if (timestamp >= _start + _duration) {
      return totalAllocation;
    } else {
      return (totalAllocation * _firstPercentage) / 100 + ((totalAllocation - (totalAllocation * _firstPercentage) / 100) * (timestamp - _start)) / _duration;
    }
  }
}

contract Invite is Context {
  mapping(address => address) private _superiors;                  

  constructor() {
  }

  function addRecord(address __superiors) public returns (bool) {
    require(__superiors != address(0), "Invite: addRecord superiors is zero");
    address self = _msgSender();
    require(self != __superiors, "Invite: addRecord superiors is not self");
    require(_superiors[self] == address(0), "Invite: addRecord superiors already exists");
    _superiors[self] = __superiors;
    return true;
  }

  function getSuperior(address account) public view returns (address) {
    require(account != address(0), "Invite: getSuperior account is zero");
    return _superiors[account];
  }

  function hasSuperior(address account) public view returns (bool) {
      require(account != address(0), "Invite: hasSuperior account is zero");
      return _superiors[account] != address(0);
  }
}

contract PreSale is Context, Ownable {
  using SafeMath for uint256;

  struct Item {
    uint256 beginAt;                                                
    uint256 endAt;                                                  
    uint256 min;                                                    
    uint256 limit;                                                 
    uint256 priece;                                                 
    uint256 share;                                                  
    uint256 saleShare;                                              
  }

  enum State {
    INIT, START, STOP
  }

  Item[] private _items;                                           
  mapping(uint8 => mapping(address => uint256)) private _balance;   

  uint8 private _index = 0;                                         
  State private _state = State.INIT;                               

  address private _tokenAddress;                                    
  address private _busdtAddress;                                    
  address private _vestingAddress;                                 
  address private _inviteAddress;                                  

  constructor(address __tokenAddress, address __busdtAddress, address __vestingAddress, address __inviteAddress) {
    require(__tokenAddress != address(0), "PreSale: caller tokenAddress is zero");
    require(__busdtAddress != address(0), "PreSale: caller busdtAddress is zero");
    require(__vestingAddress != address(0), "PreSale: caller vestingAddress is zero");
    require(__inviteAddress != address(0), "PreSale: caller inviteAddress is zero");
    _tokenAddress = __tokenAddress;
    _busdtAddress = __busdtAddress;
    _vestingAddress = __vestingAddress;
    _inviteAddress = __inviteAddress;
  }

  modifier isEnd() {
    require(State.STOP == _state, "PreSale: caller is not end");
    _;
  }

  modifier isNotEnd() {
    require(State.STOP != _state, "PreSale: caller is end");
    _;
  }

  modifier isStart() {
    require(State.START == _state, "PreSale: caller is not start");
    _;
  }

  function setPreSale(uint8 index, uint256 beginAt, uint256 endAt, uint256 min, uint256 limit, uint256 priece, uint256 share) public onlyOwner isNotEnd returns (bool) {
    // require(!_isStop, "PreSale: add is already stop");
    // require(beginAt >= block.timestamp, "PreSale: add the beginAt >= now");
    require(endAt >= block.timestamp, "PreSale: add the endAt >= now");
    require(beginAt < endAt, "PreSale: add the beginAt < endAt");
    require(limit >= min, "PreSale: add the limit < min");
    require(priece > 0, "PreSale: add the priece > 0");
    require(share > 0, "PreSale: add the share > 0");
    if (index < _items.length) {
      Item storage __item = _items[index];
      __item.beginAt = beginAt;
      __item.endAt = endAt;
      __item.min = min;
      __item.limit = limit;
      __item.priece = priece;
      __item.share = share;
    } else {
      _items.push(Item({
        beginAt : beginAt,
        endAt : endAt,
        min : min,
        limit : limit,
        priece : priece,
        share : share,
        saleShare : 0
      }));
    }
    return true;
  }

  function setStart() public onlyOwner {
    require(State.INIT == _state, "PreSale: setStart already start or stop");
    _state = State.START;
  }

  function state() public view returns (State) {
    return _state;
  }

  function setStop() public onlyOwner isNotEnd {
    _state = State.STOP;
    Vesting5(_vestingAddress).setStart();
  }

  function getPreSale() public view returns (State, Item[] memory) {
    return (_state, _items);
  }

  function release() public isEnd returns (bool) {
    IVesting(_vestingAddress).release(_msgSender());
    return true;
  }

  function totalSaleShare(uint8 index) public view returns (uint256) {
    return _items[index].saleShare;
  }

  function saleBalance(uint8 index, address account) public view returns (uint256) {
    return _balance[index][account];
  }

  function purchasing(uint8 index, uint256 amount) public isStart returns (bool) {
    require(amount > 0, "PreSale: Purchasing amount > 0");
    address account = _msgSender();
    require(account != address(0), "PreSale: Purchasing account is zero");
    Item memory item = _items[index];
    require(item.beginAt < block.timestamp, "PreSale: purchasing beginAt < now");
    require(item.endAt >= block.timestamp, "PreSale: purchasing endAt >= now");
    require(amount >= item.min, "PreSale: purchasing amount >= min");
    require(amount + _balance[index][account] <= item.limit, "PreSale: purchasing amount <= limit");

    uint256 share = amount.mul(10000).div(item.priece);// * 10 ** IERC20Metadata(_tokenAddress).decimals();
    require(share + _items[index].saleShare <= item.share, "PreSale: purchasing share not enought");

    SafeERC20.safeTransferFrom(IERC20(_busdtAddress), account, address(this), amount);
    // IERC20(_busdtAddress).transferFrom(account, address(this), amount);

    if (share > 0) {
      Vesting5(_vestingAddress).addBalance(account, share);
      address inviteAccount = Invite(_inviteAddress).getSuperior(account);
      if (inviteAccount != address(0)) {
        Vesting5(_vestingAddress).addInvite(inviteAccount, share.mul(5).div(100));
      }
    }
    _balance[index][account] += amount;
    _items[index].saleShare += share;

    return true;
  }

  function purchasingAmount(uint8 index, address account) public view returns (uint256) {
    return _balance[index][account];
  }

  function withdraw(address toAccount) public onlyOwner {
    require(toAccount != address(0), "PreSale: withdraw toAccount is zero");
    SafeERC20.safeTransfer(IERC20(_busdtAddress), toAccount, IERC20(_busdtAddress).balanceOf(address(this)));
  }
}