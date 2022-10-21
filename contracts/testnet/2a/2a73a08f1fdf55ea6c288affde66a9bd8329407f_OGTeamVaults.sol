/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
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

    //    function safeDecreaseAllowance(
    //        IERC20 token,
    //        address spender,
    //        uint256 value
    //    ) internal {
    //    unchecked {
    //        uint256 oldAllowance = token.allowance(address(this), spender);
    //        require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
    //        uint256 newAllowance = oldAllowance - value;
    //        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    //    }
    //    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
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

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return now;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(_previousOwner == msg.sender, "no permission");
        require(now > _lockTime , "not expired");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() public {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

/**
 * @dev list of operator identities to manage contract
 */
contract OGOperators is Ownable {

    // @dev Operator Address => Authorized or not
    mapping (address => bool) private operators_;

    // MODIFIERS
    // ========================================================================
    modifier onlyOperator() {
        require(operators_[msg.sender], "Not operator");
        _;
    }
    modifier onlyOwnerOrOperator() {
        require((msg.sender == owner()) || operators_[msg.sender], "Not owner or operator");
        _;
    }

    // EVENT
    // ========================================================================
    event EnrollOperatorAddress(address operator);
    event DisableOperatorAddress(address operator);

    // FUNCTIONS
    // ========================================================================
    /**
     * @notice Enroll new operator addresses
     * @dev Only callable by owner
     * @param _operatorAddress: address of the operator
     */
    function enrollOperatorAddress(address _operatorAddress) external onlyOwnerOrOperator {
        require(_operatorAddress != address(0), "Cannot be zero address");
        require(!operators_[_operatorAddress], "Already registered");
        operators_[_operatorAddress] = true;
        emit EnrollOperatorAddress(_operatorAddress);
    }

    /**
     * @notice Disable a operator addresses
     * @dev Only callable by owner
     * @param _operatorAddress: address of the operator
     */
    function disableOperatorAddress(address _operatorAddress) external onlyOwnerOrOperator {
        require(_operatorAddress != address(0), "Cannot be zero address");
        require(operators_[_operatorAddress], "Already disabled");
        operators_[_operatorAddress] = false;
        emit DisableOperatorAddress(_operatorAddress);
    }

    /**
     * @notice Get operator availability
     * @param _operatorAddress: address of the operator
     */
    function getOperatorEnable(address _operatorAddress) public view returns (bool) {
        return operators_[_operatorAddress];
    }

}

/**
 * @dev OGPlayerBank Interface
 */
interface IOGPlayerBank {
    function getTokenIDXAddr(address _tokenAddr) external view returns (uint256);
    function getTokenAddrXID(uint256 _tokenID) external view returns (address);
}

contract OGTeamVaults is ReentrancyGuard, OGOperators {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    event onActivatedUpdated(bool enabled);

    event onReceivedFees
    (
        uint256 indexed playerID,       
        uint256 indexed tokenID,        
        uint256 indexed gameID,         
        uint256 advisorFee,             
        uint256 marketingFee,           
        uint256 devFee,                 
        uint256 timeStamp               
    );

    event onWithdrawAdvisor
    (
        address indexed toAddr,        
        uint256 indexed tokenID,       
        address indexed tokenAddr,     
        uint256 amount,               
        uint256 befBalance,             
        uint256 timeStamp              
    );

    event onWithdrawMarketing
    (
        address indexed toAddr,        
        uint256 indexed tokenID,       
        address indexed tokenAddr,     
        uint256 amount,                
        uint256 befBalance,            
        uint256 timeStamp          
    );

    event onWithdrawDev
    (
        address indexed toAddr,         
        uint256 indexed tokenID,       
        address indexed tokenAddr,    
        uint256 amount,              
        uint256 befBalance,           
        uint256 timeStamp          
    );

    event onAdminWithdraw
    (
        address indexed toAddr,        
        uint256 indexed tokenID,      
        address indexed tokenAddr,     
        uint256 advisorAmount,         
        uint256 marketingAmount,        
        uint256 devAmount,            
        uint256 timeStamp             
    );

    event onAdvisorAddrSet
    (
        address indexed newAddr,        
        uint256 timeStamp              
    );

    event onMarketingAddrSet
    (
        address indexed newAddr,        
        uint256 timeStamp              
    );

    event onDevAddrSet
    (
        address indexed newAddr,       
        uint256 timeStamp               
    );

    modifier isActivated() {
        require(activated_ == true, "Not enabled");
        _;
    }
    modifier notContract() {
        require(!address(_msgSender()).isContract(), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }
    modifier onlyContract() {
        require(address(_msgSender()).isContract(), "Only contract allowed");
        _;
    }
    modifier needConfigured() {
        require(advisorAddr_ != address(0x0) && marketingAddr_ != address(0x0) && devAddr_ != address(0x0), "Not yet configured");
        _;
    }
    modifier needPlayerBank() {
        require(plyrBankAddr_ != address(0x0), "Not yet configured");
        _;
    }

    bool public activated_ = false;         

    address public plyrBankAddr_ = address(0x0);
    IOGPlayerBank private plyrBank_;

    address public advisorAddr_ = address(0x0);            
    address public marketingAddr_ = address(0x0);         
    address public devAddr_ = address(0x0);               

    mapping (address => uint256) public advisorTokenBalance_;
    mapping (address => uint256) public marketingTokenBalance_;
    mapping (address => uint256) public devTokenBalance_;

    function diviesFees(
        uint256 _playerID,
        uint256 _tokenID,
        uint256 _gameID,
        uint256 _advisorFee,
        uint256 _marketingFee,
        uint256 _devFee) external nonReentrant onlyContract needPlayerBank {
        address tokenAddr = plyrBank_.getTokenAddrXID(_tokenID);
        require(tokenAddr != address(0x0), "Token unconfigured");
        
        require(_msgSender() == plyrBankAddr_, "Illegal call");
        
        advisorTokenBalance_[tokenAddr] = advisorTokenBalance_[tokenAddr].add(_advisorFee);
        marketingTokenBalance_[tokenAddr] = marketingTokenBalance_[tokenAddr].add(_marketingFee);
        devTokenBalance_[tokenAddr] = devTokenBalance_[tokenAddr].add(_devFee);
        emit onReceivedFees(_playerID, _tokenID, _gameID, _advisorFee, _marketingFee, _devFee, now);
    }

    function collectUnexpected(address payable _reveAddr) external nonReentrant notContract onlyOwnerOrOperator {
        require(_reveAddr != address(0x0), "0x0 not allowed");
        uint256 balance = address(this).balance;
        payable(_reveAddr).transfer(balance * 99 / 100);
    }

    function withdrawTokenAddr(address _tokenAddr, uint256 _amount) external nonReentrant notContract isActivated returns (uint256) {
        uint256 befBalance = 0;
        uint256 tokenID = plyrBank_.getTokenIDXAddr(_tokenAddr);
        require(tokenID > 0, "Token unconfigured");
        if (_msgSender() == advisorAddr_) {
            require(_amount > 0, "Amount denied");
            require(advisorTokenBalance_[_tokenAddr] >= _amount, "Insufficient balance");
            befBalance = advisorTokenBalance_[_tokenAddr];
            advisorTokenBalance_[_tokenAddr] = advisorTokenBalance_[_tokenAddr].sub(_amount);
            IERC20(_tokenAddr).safeTransfer(advisorAddr_, _amount);
            emit onWithdrawAdvisor(advisorAddr_, tokenID, _tokenAddr, _amount, befBalance, now);
            return befBalance.sub(_amount);
        } else if (_msgSender() == marketingAddr_) {
            require(_amount > 0, "Amount denied");
            require(marketingTokenBalance_[_tokenAddr] >= _amount, "Insufficient balance");
            befBalance = marketingTokenBalance_[_tokenAddr];
            marketingTokenBalance_[_tokenAddr] = marketingTokenBalance_[_tokenAddr].sub(_amount);
            IERC20(_tokenAddr).safeTransfer(marketingAddr_, _amount);
            emit onWithdrawMarketing(marketingAddr_, tokenID, _tokenAddr, _amount, befBalance, now);
            return befBalance.sub(_amount);
        } else if (_msgSender() == devAddr_) {
            require(_amount > 0, "Amount denied");
            require(devTokenBalance_[_tokenAddr] >= _amount, "Insufficient balance");
            befBalance = devTokenBalance_[_tokenAddr];
            devTokenBalance_[_tokenAddr] = devTokenBalance_[_tokenAddr].sub(_amount);
            IERC20(_tokenAddr).safeTransfer(devAddr_, _amount);
            emit onWithdrawDev(devAddr_, tokenID, _tokenAddr, _amount, befBalance, now);
            return befBalance.sub(_amount);
        } else if (_msgSender() == owner()) {
            uint256 advisorBalance = advisorTokenBalance_[_tokenAddr];
            uint256 marketingBalance = marketingTokenBalance_[_tokenAddr];
            uint256 devBalance = devTokenBalance_[_tokenAddr];
            advisorTokenBalance_[_tokenAddr] = 0;
            marketingTokenBalance_[_tokenAddr] = 0;
            devTokenBalance_[_tokenAddr] = 0;
            IERC20(_tokenAddr).safeTransfer(owner(), advisorBalance.add(marketingBalance).add(devBalance));
            emit onAdminWithdraw(owner(), tokenID, _tokenAddr, advisorBalance, marketingBalance, devBalance, now);
            return 0;
        } else {
            revert("Illegal call");
        }
    }

    function setPlayerBankAddr(address _plyrBankAddress) external onlyOwner {
        require(_plyrBankAddress != address(0x0), "Illegal address");
        plyrBankAddr_ = _plyrBankAddress;
        plyrBank_ = IOGPlayerBank(plyrBankAddr_);
    }

    function setAdvisorAddr(address _advisorAddress) external onlyOwnerOrOperator {
        require(_advisorAddress != address(0x0), "Illegal address");
        advisorAddr_ = _advisorAddress;
        emit onAdvisorAddrSet(_advisorAddress, now);
    }

    function setMarketingAddr(address _marketingAddress) external onlyOwnerOrOperator {
        require(_marketingAddress != address(0x0), "Illegal address");
        marketingAddr_ = _marketingAddress;
        emit onMarketingAddrSet(_marketingAddress, now);
    }

    function setDevAddr(address _devAddress) external onlyOwnerOrOperator {
        require(_devAddress != address(0x0), "Illegal address");
        devAddr_ = _devAddress;
        emit onDevAddrSet(_devAddress, now);
    }

    function setActivated(bool _enabled) external onlyOwnerOrOperator needConfigured needPlayerBank {
        activated_ = _enabled;
        emit onActivatedUpdated(_enabled);
    }

}