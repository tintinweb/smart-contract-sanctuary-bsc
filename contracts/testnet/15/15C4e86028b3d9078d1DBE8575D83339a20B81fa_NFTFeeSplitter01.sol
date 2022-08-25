// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
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

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

interface ITokensRecoverable {
    function recoverTokens(IERC20 token) external;
}

abstract contract TokensRecoverable is Ownable, ITokensRecoverable {
    using SafeERC20 for IERC20;

    function recoverTokens(IERC20 token) public override onlyOwner {
        require (canRecoverTokens(token));
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }

    function canRecoverTokens(IERC20 token) internal virtual view returns (bool) { 
        return address(token) != address(this); 
    }
}

interface INFTFeeClaim {
    function depositFees(address _nftContract, uint256 _amount) external;
}

contract NFTFeeSplitter01 is TokensRecoverable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    address public devAddress;
    address public burnAddress;
    address public nftFeeClaim;

    uint256 public burnRate;
    
    mapping (IERC20 => address[]) public feeCollectors;
    mapping (IERC20 => uint256[]) public feeRates;
    
    constructor(address _feeClaim, address _token, address _burnPit, uint256 _burnrate) {
        devAddress = msg.sender;
        burnAddress = _burnPit;
        burnRate = _burnrate;

        setFeeClaim(_feeClaim);
        approveClaim(_token);
    }

    function setFees(address token, address _burnpit, uint256 _burnRate, address[] memory collectors, uint256[] memory rates) public onlyOwner {

        // Must have more than 1 address in the array
        require (collectors.length == rates.length && collectors.length > 1, "Fee Collectors and Rates must be the same size and contain at least 2 elements");

        // Empty init
        uint256 totalRate;

        // Add rates together from array
        for (uint256 i = 0; i < rates.length; i++) {
            totalRate = totalRate + rates[i];
        }

        // Require the whole lot to equal 10k (100%)
        require ((_burnRate + totalRate) == 10000, "Total fee rate must be 100%");
        
        // If there's any balance
        if (IERC20(token).balanceOf(address(this)) > 0) {
            // Pay fees for the token
            payFees(token);
        }

        // set collectors and fees in storage
        
        burnAddress = _burnpit;
        burnRate = _burnRate;

        feeCollectors[IERC20(token)] = collectors;
        feeRates[IERC20(token)] = rates;
    }

    function setFeeClaim(address _feeClaim) public onlyOwner {
        nftFeeClaim = _feeClaim;
    }

    function approveClaim(address token) public onlyOwner {
        IERC20(token).approve(nftFeeClaim, uint256(2**256 - 1));
    }

    function payFees(address token) public {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require (balance > 0, "Nothing to pay");

        if (burnRate > 0) {
            uint256 burnAmount = burnRate * balance / 10000;
            IERC20(token).transfer(burnAddress, burnAmount);
        }

        address[] memory collectors = feeCollectors[IERC20(token)];
        uint256[] memory rates = feeRates[IERC20(token)];

        for (uint256 i = 0; i < collectors.length; i++) {
            address collector = collectors[i];
            uint256 rate = rates[i];

            if (rate > 0) {
                uint256 feeAmount = rate * balance / 10000;
                INFTFeeClaim(nftFeeClaim).depositFees(collector, feeAmount);
            }
        }
    }

    function setBurnPit(address _burnpit) public onlyOwner {
        require(Address.isContract(_burnpit) && _burnpit != address(0) && _burnpit != address(this), "INVALID_ADDRESS");

        burnAddress = _burnpit;
    }

    function setDevAddress(address _devAddress) public onlyOwner {
        devAddress = _devAddress;
    }
}