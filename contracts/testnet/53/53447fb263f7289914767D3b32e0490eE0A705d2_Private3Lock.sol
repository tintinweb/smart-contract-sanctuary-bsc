/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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

library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

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


    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }


    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Private3Lock is Ownable {
    using SafeERC20 for IERC20;
    mapping(address => uint256) public balance;
    mapping(address => uint256) public claimedByUser;
    mapping(address => uint256) public balanceInBUSD;
    uint256 public tokenPriceBUSD = 16e14;
    uint256 public maxBusdAmount = 2500e18;
    uint256 public minBusdAmount = 500e18;
    uint256 public avalableToClaimGlobal;
    uint256 public unlockPeriod = 2592000; // 2592000 - 30 days in seconds
    uint256 public unlockPercent = 50; // 50 its 5%
    uint256 public tokensSoldAmount;
    uint256 public tokensSoldAmountMax;
    uint256 public nextUnlock;
    uint256 public level;
    uint256 public startUnlock;
    bool public seedIsStarted;
    bool public vestingIsStarted;
    address public busdAddress = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    address public tokenAddress = 0x149D455bbe970d90fA31762abb4ee5cc4381D765;
    address public marketingAddress = 0x0000000000000000000000000000000000000000;
    uint256 public marketingPercent = 375;
    uint256 public liquidityPercent = 625;


    IERC20 private _token = IERC20(tokenAddress);
    IERC20 private _busd = IERC20(busdAddress);


    constructor() { }

    function startSeed() public onlyOwner() {
        require(tokensSoldAmountMax == 0);
        require(_token.balanceOf(address(this)) != 0);
        require(!seedIsStarted);
        seedIsStarted = true;
        tokensSoldAmountMax = _token.balanceOf(address(this));
    }

    function stopSeed() public onlyOwner() {
        require(seedIsStarted);
        seedIsStarted = false;
    }

    function resumeSeed() public onlyOwner() {
        require(tokensSoldAmountMax != 0);
        require(!seedIsStarted);
        seedIsStarted = true;
    }

    function startVesting() public onlyOwner() {
        require(!seedIsStarted);
        require(!vestingIsStarted);
        vestingIsStarted = true;
        startUnlock = block.timestamp;
        nextUnlock = startUnlock + unlockPeriod;
        avalableToClaimGlobal = unlockPercent;
    }

    function buy(uint256 amountBUSD) public {
        require(tokensSoldAmount < tokensSoldAmountMax);
        require(seedIsStarted);
        if (balance[msg.sender] == 0) {
            require(amountBUSD >= minBusdAmount);
            require(amountBUSD <= maxBusdAmount);
        }
        require(balanceInBUSD[msg.sender] + amountBUSD <= maxBusdAmount);
        uint256 tokenAmount = amountBUSD / tokenPriceBUSD * 1e18;
        require(tokenAmount <= tokensSoldAmountMax - tokensSoldAmount);
        _busd.safeTransferFrom(msg.sender, address(this), amountBUSD);
        balanceInBUSD[msg.sender] += amountBUSD;
        balance[msg.sender] += tokenAmount;
        tokensSoldAmount += tokenAmount;
        uint256 minTokenAmount = minBusdAmount / tokenPriceBUSD * 1e18;
        if (tokensSoldAmountMax - tokensSoldAmount < minTokenAmount) stopSeed();
    }

    function claim() public {
        require(balance[msg.sender] > 0);
        require(avalableToClaimGlobal > 0);
        if (block.timestamp > nextUnlock) {
            level += 1;
            if (level == 1) unlockPercent = 60;
            if (level == 6) unlockPercent = 65;
            avalableToClaimGlobal += unlockPercent;
            if (avalableToClaimGlobal == 1000) {
                nextUnlock = ~uint256(0);
            } else {
                nextUnlock = block.timestamp + unlockPeriod;
            }
        }
        uint256 _avalableToClaim = avalableToClaimGlobal - claimedByUser[msg.sender];
        require(_avalableToClaim > 0);
        uint256 _amount = balance[msg.sender] * _avalableToClaim / 1000;
        claimedByUser[msg.sender] += _avalableToClaim;
        _token.safeTransfer(msg.sender, _amount);
    }

    function distributionBUSD() public onlyOwner() {
        uint256 _totalBalanceBUSD = _busd.balanceOf(address(this));
        require(_totalBalanceBUSD > 0);
        require(!seedIsStarted);
        uint256 _marketingAmount = _totalBalanceBUSD * marketingPercent / 1000;
        uint256 _liquidityAmount = _totalBalanceBUSD * liquidityPercent / 1000;
        _busd.safeTransfer(marketingAddress, _marketingAmount);
        _busd.safeTransfer(tokenAddress, _liquidityAmount);
    }
    
}