/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function releaseAfter() external view returns (uint256);
}

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

library SafeERC20 {
    using Address for address;
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);
        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
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
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

contract opXOnsBTCUSDTONBNB is ReentrancyGuard {
    using SafeERC20 for IERC20;    
    IERC20 public USDTToken; 
    IERC20 public WBTCToken; 
    address public beneficiary;
    uint64 public holdDuration;
    uint64 public maxTimeToWithdraw;
    address payable public feeAddress;
    uint256 public feePercentage;
    uint256 public releaseTime;
    uint256 public btcAmount;
    uint256 public marketPrice;
    uint256 public strikePrice;
    uint256 public bnbFees;
    bool public isActive = false;
    AggregatorV3Interface internal priceBTCUSDFeed;
    AggregatorV3Interface internal priceBNBUSDFeed;
    constructor(
        uint64 _holdDurationInDays,
        uint64 _maxTimeToWithdrawHours,
        uint256 _btcAmount, 
        uint256 _feePercentage
    ) {
        require(_holdDurationInDays > 0, "Release time must be in the future");
        require(_maxTimeToWithdrawHours > 1, "you should give the option at least 1 hour to withdraw");
        require(_btcAmount > 0, "you need a positive number");
        require(_feePercentage > 0 && _feePercentage <= 100, "Invalid fee percentage");
        priceBTCUSDFeed = AggregatorV3Interface(address(0x5741306c21795FdCBb9b265Ea0255F499DFe515C));
        priceBNBUSDFeed = AggregatorV3Interface(address(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526));
        USDTToken = IERC20(0xfF981A6afAD78A38BccDB73E68A3D4c4de72606A);
        WBTCToken = IERC20(0x8Ba5797E28E0170B8D1c76E19527A8F8Ca78356c);
        btcAmount = _btcAmount;
        feePercentage = _feePercentage;
        holdDuration = _holdDurationInDays * 86400;
        maxTimeToWithdraw = _maxTimeToWithdrawHours * 3600;
        feeAddress = payable (msg.sender);
        isActive = true;
    }
    function buyOption() public payable {
        require(isActive = true);
        require(beneficiary == 0x0000000000000000000000000000000000000000, "the option is already bought");
        (, int _priceBTC, , ,) = priceBTCUSDFeed.latestRoundData();
        (, int _priceBNB, , ,) = priceBNBUSDFeed.latestRoundData();
        uint256 _marketPrice = uint256(_priceBTC);
        uint256 _strikePrice = (_marketPrice * btcAmount) / 100000000;
        uint256 _bnbFees = _strikePrice * feePercentage * 1000000 / uint256(_priceBNB);
        require (msg.value > _bnbFees);

        beneficiary = msg.sender;
        releaseTime = block.timestamp + holdDuration;
        marketPrice = _marketPrice;
        strikePrice = _strikePrice;
        feeAddress.transfer(msg.value);
    }
    function balanceOfBTC() public view returns (uint256) {
        return WBTCToken.balanceOf(address(this));
    }
    function balanceOfUSDT() public view returns (uint256) {
        return USDTToken.balanceOf(address(this));
    }
    function release() public nonReentrant {
        require(isActive = true);
        require(block.timestamp >= releaseTime, "Release time has not yet come");
        require(block.timestamp <= releaseTime + maxTimeToWithdraw, "You have will not abel to withdraw any more");
        uint256 amountOfUSDT = balanceOfUSDT();
        require(amountOfUSDT >= strikePrice, "You did not transfer the required amount of USDT to release your BTC");
        uint256 amountOfBTC = balanceOfBTC();
        require(amountOfBTC >= 0, "There is no BTC to Withdraw");
        WBTCToken.safeTransfer(beneficiary, amountOfBTC);
        USDTToken.safeTransfer(feeAddress, amountOfUSDT);
    }
    function refundAll() public {
        require(isActive = true);
        require(msg.sender == feeAddress);
        require(block.timestamp > releaseTime + maxTimeToWithdraw, "The buyer still have a time");
        uint256 amountOfBTC = balanceOfBTC();
        require(amountOfBTC >= 0, "There is no BTC to Refund");
        require(beneficiary != 0x0000000000000000000000000000000000000000);
        WBTCToken.safeTransfer(feeAddress, amountOfBTC);
        uint256 amountOfUSDT = balanceOfUSDT();
        if (amountOfUSDT > 0) {
            USDTToken.safeTransfer(feeAddress, amountOfUSDT);
        }
    }
    function closeContract() public {
        require(isActive = true);
        require(msg.sender == feeAddress);
        uint256 amountOfBTC = balanceOfBTC();
        require(amountOfBTC >= 0, "There is no BTC to Refund");
        require(beneficiary == 0x0000000000000000000000000000000000000000);
        WBTCToken.safeTransfer(feeAddress, amountOfBTC);
        isActive = false;
    }

}