/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }
    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
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
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.
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
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
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
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
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
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
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
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
    }

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

contract OptionsBTCUSDTONBNB is ReentrancyGuard {
    using SafeERC20 for IERC20;
    // Token contracts
    IERC20 public usdtToken;
    IERC20 public wbtcToken;
    // Addresses
    address public beneficiary;
    address payable public feeAddress;
    // Time constraints
    uint256 public releaseTime;
    uint64 public holdDuration;
    uint64 public maxTimeToWithdraw;
    // Option parameters
    uint256 public btcAmount;
    uint256 public marketPrice;
    uint256 public strikePrice;
    uint256 public feePercentage;
    // State variables
    bool public isActive = false;
    // Chainlink price feeds
    AggregatorV3Interface internal priceBTCUSDFeed;
    AggregatorV3Interface internal priceBNBUSDFeed;
    constructor(
        uint64 _holdDurationInDays,
        uint64 _maxTimeToWithdrawHours,
        uint256 _btcAmount,
        uint256 _feePercentage
    ) {
        require(_holdDurationInDays > 0, "Hold duration must be greater than 0");
        require(_maxTimeToWithdrawHours > 1, "Max time to withdraw must be greater than 1 hour");
        require(_btcAmount > 0, "BTC amount must be greater than 0");
        require(_feePercentage > 0 && _feePercentage <= 100, "Invalid fee percentage");
        // Initialize token contracts
        usdtToken = IERC20(0xfF981A6afAD78A38BccDB73E68A3D4c4de72606A);
        wbtcToken = IERC20(0x8Ba5797E28E0170B8D1c76E19527A8F8Ca78356c);
        // Initialize price feeds
        priceBTCUSDFeed = AggregatorV3Interface(address(0x5741306c21795FdCBb9b265Ea0255F499DFe515C));
        priceBNBUSDFeed = AggregatorV3Interface(address(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526));
        // Set option parameters
        btcAmount = _btcAmount;
        feePercentage = _feePercentage;
        // Set time constraints
        holdDuration = _holdDurationInDays * 1 days;
        maxTimeToWithdraw = _maxTimeToWithdrawHours * 1 hours;
        // Set fee address
        feeAddress = payable(msg.sender);
        // Activate contract
        isActive = true;
    }

    function buyOption() external payable nonReentrant {
        require(isActive, "Contract is not active");
        require(beneficiary == address(0), "Option has already been purchased");
        // Get market and strike prices
        (, int _priceBTC, , ,) = priceBTCUSDFeed.latestRoundData();
        (, int _priceBNB, , ,) = priceBNBUSDFeed.latestRoundData();
        marketPrice = uint256(_priceBTC);
        strikePrice = (marketPrice * btcAmount) / 1e8;
        // Calculate fees
        uint256 _bnbFees = (strikePrice *     feePercentage * 1e6) / uint256(_priceBNB);
    require(msg.value > _bnbFees, "Insufficient funds for option fees");
    // Set beneficiary and release time
    beneficiary = msg.sender;
    releaseTime = block.timestamp + holdDuration;

    // Transfer fees to fee address
    feeAddress.transfer(msg.value);
    }

    function balanceOfBTC() public view returns (uint256) {
    return wbtcToken.balanceOf(address(this));
    }
    function balanceOfUSDT() public view returns (uint256) {
    return usdtToken.balanceOf(address(this));
    }
    function release() external nonReentrant {
    require(isActive, "Contract is not active");
    require(block.timestamp >= releaseTime, "Release time has not yet come");
    require(block.timestamp <= releaseTime + maxTimeToWithdraw, "Withdrawal period has ended");
    // Get balances
    uint256 amountOfUSDT = balanceOfUSDT();
    uint256 amountOfBTC = balanceOfBTC();
    // Check balances
    require(amountOfUSDT >= strikePrice, "Insufficient USDT balance to claim BTC");
    require(amountOfBTC > 0, "No BTC to withdraw");
    // Transfer tokens
    wbtcToken.safeTransfer(beneficiary, amountOfBTC);
    usdtToken.safeTransfer(feeAddress, amountOfUSDT);
    // Reset beneficiary
    beneficiary = address(0);
    }
    function refundAll() external {
    require(isActive, "Contract is not active");
    require(msg.sender == feeAddress, "Only the fee address can refund funds");
    require(block.timestamp > releaseTime + maxTimeToWithdraw, "Withdrawal period has not ended");
    require(beneficiary != address(0), "No option to refund");
    // Get balances
    uint256 amountOfBTC = balanceOfBTC();
    uint256 amountOfUSDT = balanceOfUSDT();
    // Refund tokens
    if (amountOfBTC > 0) {
        wbtcToken.safeTransfer(feeAddress, amountOfBTC);
    }
    if (amountOfUSDT > 0) {
        usdtToken.safeTransfer(feeAddress, amountOfUSDT);
    }
    // Reset beneficiary
    beneficiary = address(0);
    }
    function closeContract() external {
    require(isActive, "Contract is not active");
    require(msg.sender == feeAddress, "Only the fee address can close the contract");
    // Get balances
    uint256 amountOfBTC = balanceOfBTC();
    uint256 amountOfUSDT = balanceOfUSDT();
    // Ensure there are no USDT tokens remaining before deactivating contract
    require(amountOfUSDT == 0, "Cannot close contract with remaining USDT balance");
    // Refund tokens
    if (amountOfBTC > 0) {
        wbtcToken.safeTransfer(feeAddress, amountOfBTC);
    }
    // Deactivate contract
    isActive = false;
}

}