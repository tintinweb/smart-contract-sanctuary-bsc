/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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

library ConvertString {
    function toStr(uint256 value) internal pure returns (string memory str){
        if (value == 0) return "0";
        uint256 j = value;
        uint256 length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bStr = new bytes(length);
        uint256 k = length;
        j = value;
        while (j != 0){
            bStr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bStr);
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
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

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

contract DenoTracker is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using ConvertString for uint256;
    using Address for address;

    string private _name;
    string private _symbol;
    uint8 private _decimals = 0;

    struct TrxInfo {
        uint256 trxMode;
        address trxAccount;
        uint256 trxDate;
        uint256 trxAmount;
    }

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    TrxInfo[] private _trxList;

    mapping (string => string) private _fieldStringMap;
    mapping (string => uint256) private _fieldNumberMap;
    mapping (string => address) private _fieldAddressMap;

    address private _tokenAddress;

    constructor(string memory name_, string memory symbol_, address tokenAddress_) {
        _name = string(abi.encodePacked("DenoTracker", name_));
        _symbol = string(abi.encodePacked("DTR", symbol_));
        _tokenAddress = tokenAddress_;
    }

    receive() external payable {}

    modifier authSender() {
        require((owner() == _msgSender() || _tokenAddress == _msgSender()), "Ownable: caller is not the owner");
        _;
    }
    function setTokenAddress(address address_) public authSender {
        _tokenAddress = address_;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function _increaseBalance(address account_, uint256 balance_) private {
        uint256 currBalance = _balances[account_];
        uint256 newBalance = currBalance.add(balance_);
        _setBalance(account_, newBalance);
    }
    function _decreaseBalance(address account_, uint256 balance_) private {
        uint256 currBalance = _balances[account_];
        uint256 newBalance = currBalance.sub(balance_);
        require(newBalance >= 0, "ERR");
        _setBalance(account_, newBalance);
    }
    function increaseBalance(address account_, uint256 balance_) public onlyOwner returns (uint256) {
        _increaseBalance(account_, balance_);
        TrxInfo memory trxInfo = TrxInfo(1, account_, block.timestamp, balance_);
        _trxList.push(trxInfo);
        return _balances[account_];
    }
    function decreaseBalance(address account_, uint256 balance_) public onlyOwner returns (uint256) {
        _decreaseBalance(payable(account_), balance_);
        TrxInfo memory trxInfo = TrxInfo(2, account_, block.timestamp, balance_);
        _trxList.push(trxInfo);
        return _balances[account_];
    }
    function _setBalance(address account, uint256 newBalance) private {
        uint256 currentBalance = _balances[account];
        if(newBalance > currentBalance) {
            uint256 addAmount = newBalance.sub(currentBalance);
            _mint(address(this), addAmount);
            _transfer(address(this), account, addAmount);
        } else if(newBalance < currentBalance) {
            uint256 subAmount = currentBalance.sub(newBalance);
            _transfer(account, address(this), subAmount);
            _burn(address(this), subAmount);
        }
    }
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "zero address");
        require(recipient != address(0), "zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function getAccountBalance(address account_) public view returns (uint256) {
        return _balances[account_];
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address, uint256) public pure override returns (bool) {
        revert("DenoTracker: method not implemented");
    }
    function allowance(address, address) public pure override returns (uint256) {
        revert("DenoTracker: method not implemented");
    }
    function approve(address, uint256) public pure override returns (bool) {
        revert("DenoTracker: method not implemented");
    }
    function transferFrom(address, address, uint256) public pure override returns (bool) {
        revert("DenoTracker: method not implemented");
    }
    function setFieldString(string memory key_, string memory value_) public onlyOwner {
        _fieldStringMap[key_] = value_;
    }
    function getFieldString(string memory key_) public view returns (string memory) {
        return _fieldStringMap[key_];
    }
    function setFieldNumber(string memory key_, uint256 value_) public onlyOwner {
        _fieldNumberMap[key_] = value_;
    }
    function getFieldNumber(string memory key_) public view returns (uint256) {
        return _fieldNumberMap[key_];
    }
    function setFieldAddress(string memory key_, address value_) public onlyOwner {
        _fieldAddressMap[key_] = value_;
    }
    function getFieldAddress(string memory key_) public view returns (address) {
        return _fieldAddressMap[key_];
    }
    function listTrx(address account_) public view returns (uint256[] memory, uint256[] memory, uint256[] memory) {
        uint rowCount = _trxList.length;

        uint256[] memory _modes = new uint256[](rowCount);
        uint256[] memory _dates = new uint256[](rowCount);
        uint256[] memory _amounts = new uint256[](rowCount);

        uint id = 0;

        for (uint i = 0; i < rowCount; i++) {
            address _account = _trxList[i].trxAccount;
            if (account_ == _account){
                _modes[id] = _trxList[i].trxMode;
                _dates[id] = _trxList[i].trxDate;
                _amounts[id] = _trxList[i].trxAmount;
                id++;
            }
        }
        return (_modes, _dates, _amounts);
    }
    function trxCount(address account_) public view returns (uint256) {
        uint256 result;
        for (uint i = 0; i < _trxList.length; i++) {
            address _account = _trxList[i].trxAccount;
            if (account_ == _account){
                result++;
            }
        }
        return result;
    }
}