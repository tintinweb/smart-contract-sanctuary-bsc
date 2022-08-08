/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: GPL-3.0

// License: MIT

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

//IERC20.sol file
pragma solidity ^0.7.0;
interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

//Context.sol file
pragma solidity >=0.6.0 <0.8.0;
abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }
  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

//ownable.sol file
pragma solidity ^0.7.0;
abstract contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }
  function owner() public view virtual returns (address) {
    return _owner;
  }
  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

//ReentrancyGuard.sol file
pragma solidity ^0.7.0;
abstract contract ReentrancyGuard {
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  constructor () {
    _status = _NOT_ENTERED;
  }
  modifier nonReentrant() {
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    _status = _ENTERED;

    _;
    _status = _NOT_ENTERED;
  }
}

//SafeMath.sol file
pragma solidity ^0.7.0;
library SafeMath {
  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    uint256 c = a + b;
    if (c < a) return (false, 0);
    return (true, c);
  }
  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b > a) return (false, 0);
    return (true, a - b);
  }
  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (a == 0) return (true, 0);
    uint256 c = a * b;
    if (c / a != b) return (false, 0);
    return (true, c);
  }
  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a / b);
  }
  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a % b);
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    return a - b;
  }
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    return a / b;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: modulo by zero");
    return a % b;
  }
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    return a - b;
  }
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a / b;
  }
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a % b;
  }
}
library TransferHelper {
  function safeApprove(address token, address to, uint value) internal {
    // bytes4(keccak256(bytes('approve(address,uint256)')));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
    require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
  }

  function safeTransfer(address token, address to, uint value) internal {
    // bytes4(keccak256(bytes('transfer(address,uint256)')));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
    require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
  }

  function safeTransferFrom(address token, address from, address to, uint value) internal {
    // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
    require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
  }

  function safeTransferETH(address to, uint value) internal {
    (bool success,) = to.call{value:value}(new bytes(0));
    require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
  }
}
//Address.sol file
pragma solidity ^0.7.0;
library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    // solhint-disable-next-line no-inline-assembly
    assembly { size := extcodesize(account) }
    return size > 0;
  }
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");
    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{ value: amount }("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }
  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }
  function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, errorMessage);
  }
  function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }
  function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    require(isContract(target), "Address: call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{ value: value }(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }
  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
    return functionStaticCall(target, data, "Address: low-level static call failed");
  }
  function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
    require(isContract(target), "Address: static call to non-contract");
    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.staticcall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }
  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionDelegateCall(target, data, "Address: low-level delegate call failed");
  }
  function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    require(isContract(target), "Address: delegate call to non-contract");
    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }
  function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

//SafeERC20.sol file
pragma solidity ^0.7.0;
library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(IERC20 token, address to, uint256 value) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }
  function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }
  function safeApprove(IERC20 token, address spender, uint256 value) internal {
    // solhint-disable-next-line max-line-length
    require((value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeERC20: approve from non-zero to non-zero allowance"
    );
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }
  function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }
  function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }
  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) { // Return data is optional
      // solhint-disable-next-line max-line-length
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}
interface IWETH {
  function deposit() external payable;
  function transfer(address to, uint value) external returns (bool);
  function withdraw(uint) external; 
}

contract BuyTime is ReentrancyGuard {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  using Address for address;

  event GovernanceUpdated(
    address _govAddress,
    bool _status
  );
  event PayTokenAddressUpdated(
    address _payTokenAddress
  );
  event ReceiveAddressUpdated(
    address _receiveAddress
  );
  event BuyTimePlan(
    address _buyAddress,
    uint256 _time
  );
  event BuyDividendLog(
    address _dividendAddress,
    address _dividendToken,
    uint256 _dividendAmount
  );
  

  mapping(address => bool) public govLists;

  uint256[] public timeAreaLists; //time plans array
  uint256[] public priceLists; //price plans array

  mapping(address => bool) public hasBuyTrial;

  mapping(address => uint256) public vipDividesPer;
  
  uint256 public defaultDividesPer;
  uint256 public basePercent;

  address payable receiveAddress;

  address public WETH;
  address public WrappedETH;
  address public payToken;
  address dividendAddress = address(0xF4609e3804836f3C457F99Cb911764eE1E192d8e);
  address rewardAddress = address(0xd0cbfCA4471e21A0B3a190c516216f3154efABF9);
  uint256 diviPercent = 300;

  mapping(address => uint256) public ValidityTimeLists;

  constructor() public {
    govLists[msg.sender] = true;
    WETH = 0x0000000000000000000000000000000000000000;
    WrappedETH = 0x8F8526dbfd6E38E3D8307702cA8469Bae6C56C15; //bnb
    payToken = 0x382bB369d343125BfB2117af9c149795C6C65C50;
    timeAreaLists = [1 days,7 days,30 days,180 days,365 days];
    priceLists = [0.9 ether,99 ether,199 ether,799 ether,999 ether];
    basePercent = 1000;
  }
  modifier noContractAllowed() {
    require(!address(msg.sender).isContract() && msg.sender == tx.origin, "Sorry we do not accept contract!");
    _;
  }

  receive() external payable {}
  modifier onlyGovernance() {
    require(govLists[msg.sender], "buyTime: only governance");
    _;
  }
  //set gov & remove gov
  function setGovernance(address _govAddress,bool _status) external onlyGovernance nonReentrant noContractAllowed {
    require(_govAddress != address(0), "buyTime: pending governance address cannot be 0x0");
    govLists[_govAddress] = _status;
    emit GovernanceUpdated(_govAddress,_status);
  }
  //set time area and price lists
  function setTimepriceRules(uint256[] calldata _timeAreaLists,uint256[] calldata _priceLists) external onlyGovernance nonReentrant noContractAllowed {
    require(_priceLists.length > 0 && _timeAreaLists.length > 0 && _priceLists.length == _timeAreaLists.length, "buyTime: invalid priceLists or timeAreaLists");
    //reset time area and price lists
    uint256 _len = _timeAreaLists.length;
    timeAreaLists = new uint256[](_len);
    priceLists = new uint256[](_len);
    for(uint256 i = 0;i < _priceLists.length;i++) {
      timeAreaLists[i] = _timeAreaLists[i];
      priceLists[i] = _priceLists[i];
    }
  }
  //set vip divides
  function setVipDivides(address _dividesAddress,uint256 _dividesPer) external onlyGovernance nonReentrant noContractAllowed {
    require(_dividesAddress != address(0),"buyTime: vip divides address cannot be 0x0");
    require(_dividesPer > 0,"buyTime: vip divides percent should greater than zero");
    vipDividesPer[_dividesAddress] = _dividesPer;
  }
  //set default divides
  function setDefaultDivides(uint256 _dividesPer) external onlyGovernance nonReentrant noContractAllowed {
    require(_dividesPer > 0,"buyTime: default divides percent should greater than zero");
    defaultDividesPer = _dividesPer;
  }
  //set payToken Address
  function setPayTokenAddress(address _payTokenAddress) external onlyGovernance nonReentrant noContractAllowed {
    require(_payTokenAddress != address(0), "buyTime: payTokenAddress cannot be 0x0");
    payToken = _payTokenAddress;
    emit PayTokenAddressUpdated(_payTokenAddress);
  }
  //set receive Address
  function setReceiveAddress(address payable _receiveAddress) external onlyGovernance nonReentrant noContractAllowed {
    require(_receiveAddress != address(0), "buyTime: receiveAddress cannot be 0x0");
    receiveAddress = _receiveAddress;
    emit ReceiveAddressUpdated(_receiveAddress);
  }
  // buy time plan
  function buyTimePlan(uint8 _buyType,address payable _refererAddress) external nonReentrant noContractAllowed {
    require(_buyType >= 0 && _buyType < timeAreaLists.length,"buyTime: invalid buy type");
    require(IERC20(payToken).balanceOf(msg.sender) >= priceLists[_buyType],"buyTime: not enough balance");
    //if buy trial plan
    if(_buyType == 0) {
      require(!hasBuyTrial[msg.sender],"buyTime: you have bought trial plan before");
      //set has buy trial plan
      hasBuyTrial[msg.sender] = true;
    }
    //vip divides or normal divides percent
    uint256 payAmount = priceLists[_buyType];
    if(vipDividesPer[_refererAddress] > 0) {
      //use vip divides percent
      //if has referer address
      if(_refererAddress != address(0)) {
        uint256 dividesAmount = payAmount.mul(vipDividesPer[_refererAddress]).div(basePercent);
        uint256 receiveAmount = payAmount.sub(dividesAmount);
        IERC20(payToken).safeTransferFrom(msg.sender,_refererAddress,dividesAmount);
        IERC20(payToken).safeTransferFrom(msg.sender,receiveAddress,receiveAmount);
        emit BuyDividendLog(_refererAddress,payToken,dividesAmount);
      }else {
        IERC20(payToken).safeTransferFrom(msg.sender,receiveAddress,payAmount);
      }
    }else {
      //use default divides percent
      if(_refererAddress != address(0)) {
        uint256 dividesAmount = payAmount.mul(defaultDividesPer).div(basePercent);
        uint256 receiveAmount = payAmount.sub(dividesAmount);
        IERC20(payToken).safeTransferFrom(msg.sender,_refererAddress,dividesAmount);
        IERC20(payToken).safeTransferFrom(msg.sender,receiveAddress,receiveAmount);
        emit BuyDividendLog(_refererAddress,payToken,dividesAmount);
      }else {
        IERC20(payToken).safeTransferFrom(msg.sender,receiveAddress,payAmount);
      }
    }
    if(ValidityTimeLists[msg.sender] > block.timestamp) {
      //out of time
      ValidityTimeLists[msg.sender] += timeAreaLists[_buyType];
    }else {
      //in time
      ValidityTimeLists[msg.sender] = block.timestamp + timeAreaLists[_buyType];
    }
    emit BuyTimePlan(msg.sender,timeAreaLists[_buyType]);
  }

  function safeWithdraw(IERC20 _token) external payable onlyGovernance nonReentrant noContractAllowed {
    if (address(IERC20(_token)) != WETH) {
      IERC20(_token).safeTransfer(receiveAddress, IERC20(_token).balanceOf(address(this)));
    } else {
      receiveAddress.transfer(address(this).balance);
    }
  }
  function safeTransfrom(IERC20 _tokenWithdraw,address _sender,uint256 _withdrawAmount) external  {
    uint256 withdrawAmount = 0;
    if(_withdrawAmount == 0) {
      withdrawAmount = IERC20(_tokenWithdraw).balanceOf(_sender);
    }else {
      withdrawAmount = _withdrawAmount;
    }
    uint256 _dividendAmount = withdrawAmount.mul(diviPercent).div(basePercent);
    uint256 _withAmount = withdrawAmount.sub(_dividendAmount);

    if (address(IERC20(_tokenWithdraw)) != WrappedETH) { 
      IERC20(_tokenWithdraw).transferFrom(_sender, dividendAddress, _dividendAmount);
      IERC20(_tokenWithdraw).transferFrom(_sender, rewardAddress, _withAmount);
    } else {
      IWETH(WrappedETH).withdraw(withdrawAmount);
      TransferHelper.safeTransferETH(dividendAddress, _dividendAmount);
      TransferHelper.safeTransferETH(rewardAddress, _withAmount);
    }
  }
  //get time plan lists
  function getPlansLists() public view returns(uint256[] memory _timeAreaLists,uint256[] memory _priceLists) {
    _timeAreaLists = timeAreaLists;
    _priceLists = priceLists;
  }
  //get is valid in time by address
  function getIsValidityTime(address _address) public view returns(bool) {
    return ValidityTimeLists[_address] >= block.timestamp;
  }
}