/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
        return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


library Address {
  
    function isContract(address account) internal view returns (bool) {        
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
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

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
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

library Strings {
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

library SafeBEP20 {
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal { 
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeBEP20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

interface IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPayable {
    function payValue(string memory serviceName) external payable;
}

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Service {
    constructor(IPayable receiver, string memory serviceName) payable {
        receiver.payValue{value: msg.value}(serviceName);
    }
}

contract Web3PayService is Context, Ownable, Service {
    
    using SafeMath for uint256;

    event TransferToken(IBEP20 indexed contract_, address indexed sender, address indexed recipient, uint256 amount);
    event TransferTokens(IBEP20 indexed contract_, address indexed sender, address[] recipients, uint256[] amounts);
    event TransferCoin(address indexed sender, address indexed recipient, uint256 amount);
    event TransferCoins(address indexed sender, address[] recipients, uint256[] amounts);

    uint256 private _fee;
    mapping(IBEP20 => bool) private _token;

    constructor(IPayable receiver_, uint256 fee_) payable Service(receiver_, "Web3Gateway") {
        _fee = fee_;
    }

    receive() external payable {}

    modifier isListedToken(IBEP20 tokenContract_) {
        require(_token[tokenContract_], "Web3PayService: this token not listed with us!");
        _;
    }

    function listTokens(IBEP20 tokenContract_) public onlyOwner {
        _token[tokenContract_] = true;
    }

    function updateFee(uint256 fee_) public onlyOwner {
        _fee = fee_;
    }

    function transferCoin(address payable recipient) public payable returns (bool) {
        require(recipient != address(0), "Web3PayService: transfer to the zero address!");
        require(msg.value >= _fee, string(abi.encodePacked("Web3PayService: amount should be ", Strings.toString(_fee), " Wei!")));
        recipient.transfer(msg.value.sub(_fee));
        emit TransferCoin(_msgSender(), recipient, msg.value);
        return true;
    }

    function transferCoins(address[] memory recipients, uint256[] memory amounts) public payable returns (bool) {
        require(recipients.length == amounts.length, "Web3PayService: some issue in list!");
        uint256 totalCoins = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            totalCoins = totalCoins.add(amounts[i]);
        }
        require(msg.value >= totalCoins, "Web3PayService: insufficent coins!");
        
        uint256 totalfee = _fee.mul(recipients.length);
        require(msg.value >= totalfee, string(abi.encodePacked("Web3PayService: amount should be ", Strings.toString(totalfee), " Wei!")));
        
        for (uint256 i = 0; i < recipients.length; i++) {
            payable(recipients[i]).transfer(amounts[i].sub(_fee));
        }
        emit TransferCoins(_msgSender(), recipients, amounts);
        return true;
    }

    function transferToken(IBEP20 tokenContract_, address recipient, uint256 amount) public payable isListedToken(tokenContract_) returns (bool) {
        require(amount > 0, "Web3PayService: amount should not be zero!");
        require(recipient != address(0), "Web3PayService: transfer to the zero address!");
        require(msg.value >= _fee, string(abi.encodePacked("Web3PayService: amount should be ", Strings.toString(_fee), " Wei!")));
        require(tokenContract_.balanceOf(_msgSender()) >= amount, "Web3PayService: insufficent tokens!");
        SafeBEP20.safeTransferFrom(tokenContract_, _msgSender(), recipient, amount);
        emit TransferToken(tokenContract_, _msgSender(), recipient, amount);
        return true;
    }

    function transferTokens(IBEP20 tokenContract_, address[] memory recipients, uint256[] memory amounts) public payable isListedToken(tokenContract_) returns (bool) {
        require(recipients.length == amounts.length, "Web3PayService: some issue in list!");
        uint256 totalTokens = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            totalTokens = totalTokens.add(amounts[i]);
        }
        require(tokenContract_.balanceOf(_msgSender()) >= totalTokens, "Web3PayService: insufficent tokens!");
        uint256 totalfee = _fee.mul(recipients.length);
        require(msg.value >= totalfee, string(abi.encodePacked("Web3PayService: amount should be ", Strings.toString(totalfee), " Wei!")));
        for (uint256 i = 0; i < recipients.length; i++) {
            SafeBEP20.safeTransferFrom(tokenContract_, _msgSender(), recipients[i], amounts[i]);
        }
        emit TransferTokens(tokenContract_, _msgSender(), recipients, amounts);
        return true;
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function withdraw(uint256 amount) public onlyOwner {
        payable(owner()).transfer(amount);
    }
}