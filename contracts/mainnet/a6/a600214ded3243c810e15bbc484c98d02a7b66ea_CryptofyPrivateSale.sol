/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

//SPDX-License-Identifier: MIT
// Links: https://linktr.ee/zeroloss
// Contract code designed by @EVMlord (Telegram & Twitter)

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

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

        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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

        (bool success, bytes memory returndata) = target.call{value : value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
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
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

interface IKimberliteSafe {
    function lockTokens(
        address _tokenAddress,
        address lockOwner,
        uint256 _amount,
        uint256 _unlockTime,
        address _payee,
        string memory name,
        string memory description,
        bool _feeInBnb
    ) external payable returns (uint256 _id);
}

contract CryptofyPrivateSale is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public tokenIn = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public tokenOut = 0x03B6119662292b6BBecFc432B799a82Ae9157f12;
    address public ZLT = 0x05D8762946fA7620b263E1e77003927addf5f7E6;
    IKimberliteSafe public KimberliteSafe = IKimberliteSafe(0xFb22A44FF24D599600A90eea13B14b5662b10353);
    
	address payable public ADMIN;
    address payable private VAULT;
    address payable private ROOT;

    bool public saleStarted = false;
	
    uint256 public minPurchase = 1 ether;
    uint256 public maxPurchase = 5000 ether;
    uint256 public swapRate = 100;
    uint256 public ZerolossThreshold = 10000 ether;
    uint256 public participants;
    uint256 public moneyRaisedinBUSD;

    mapping (address => uint256) internal userInvestment;

    constructor(address payable _vault, address payable _admin) ReentrancyGuard() {
        ADMIN = payable(_admin);
        VAULT = payable(_vault);
        ROOT = payable(msg.sender);
    }

    function buyCFYC(uint256 inAmount) external {
        uint256 quota = IERC20(tokenOut).balanceOf(ROOT);
        uint256 total = IERC20(tokenIn).balanceOf(msg.sender);
        uint256 outAmount = convert(inAmount);

        require(saleStarted == true, "Zeroloss LaunchPad: Sale not started.");
        require(inAmount <= total, "Zeroloss LaunchPad: Insufficient fund.");
        require(outAmount <= quota, "Zeroloss Launchpad: Quota(ROOT Balance) not enough.");
        require(inAmount >= minPurchase, "Zeroloss Launchpad: Below minimum purchase amount.");
        require(inAmount+userInvestment[msg.sender] <= maxPurchase, "Zeroloss Launchpad: Above maximum purchase amount.");
        require(IERC20(ZLT).balanceOf(msg.sender) >= ZerolossThreshold, "Zeroloss Launchpad: You need a minimum balance of 10,000 ZLT to participate");

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), inAmount);
        (uint iD1, uint iD2, uint iD3) = setVesting(outAmount);
		
		uint256 launchpadFee = inAmount.mul(10).div(100);
		uint256 adminFunds = inAmount-launchpadFee;

        if(userInvestment[msg.sender] == 0){
            participants++;
        }
		
		sA(launchpadFee);
		IERC20(tokenIn).safeTransfer(ADMIN, adminFunds);

        userInvestment[msg.sender] += inAmount;
        moneyRaisedinBUSD += inAmount;

        emit Swap(msg.sender, inAmount, outAmount, iD1, iD2, iD3);
    }
	
    function setSaleStarted(bool _status) external onlyOwner {
        require(saleStarted != _status, "Not changed");
        saleStarted = _status;
    }

    function setZerolossThreshold(uint256 newThreshold) external onlyOwner {
        ZerolossThreshold = newThreshold;
    }

    function setPurchaseLimits(uint256 newMin, uint256 newMax) external onlyOwner {
        minPurchase = newMin;
        maxPurchase = newMax;
    }

    function setSwapRate(uint256 newRate) external onlyOwner {
        swapRate = newRate;
    }

    function sA(uint256 sentAmount) internal {
		uint256 qsA = sentAmount.mul(80).div(100);
        
        IERC20(tokenIn).safeTransfer(VAULT, qsA);
	}

    function setTokens(address _tokenIn, address _tokenOut) external onlyOwner {
        tokenIn = _tokenIn;
        tokenOut = _tokenOut;
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }
	
	function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }	

    function setVesting(uint _outAmount) internal returns (uint iD1, uint iD2, uint iD3) {
        // Check for the allowance and transfer from the owners account
        require(
            IERC20(tokenOut).allowance(ROOT, address(KimberliteSafe)) >= _outAmount,
            "Zeroloss Launchpad: Insufficient allowance from the Admin"
        );

        uint256 _initialAmount = _outAmount.mul(10).div(100); 
        uint256 subsequentAmounts = _outAmount.mul(30).div(100);

        require(
            IERC20(tokenOut).transferFrom(
                ROOT,
                msg.sender,
                _initialAmount
            ),
            "Failed to transfer tokens to Investor"
        );
 
        iD1 = KimberliteSafe.lockTokens{value: 0}(tokenOut, msg.sender, 
        subsequentAmounts, block.timestamp + 90 days, ROOT, "Cryptofy Private Sale Vesting", 
        "Automatic Vesting of private sale tokens from Zeroloss Launchpad", false);

        iD2 = KimberliteSafe.lockTokens{value: 0}(tokenOut, msg.sender, 
        subsequentAmounts, block.timestamp + 180 days, ROOT, "Cryptofy Private Sale Vesting", 
        "Automatic Vesting of private sale tokens from Zeroloss Launchpad", false);

        iD3 = KimberliteSafe.lockTokens{value: 0}(tokenOut, msg.sender, 
        subsequentAmounts, block.timestamp + 270 days, ROOT, "Cryptofy Private Sale Vesting", 
        "Automatic Vesting of private sale tokens from Zeroloss Launchpad", false);
    }

    function convert(uint256 amountInBUSD) internal view returns (uint256) {
        uint256 factor = 10 ** (18 - 2); // 10 ** 16
        uint256 amountInCFYC = (amountInBUSD + factor / 2) / factor;
        return amountInCFYC.mul(1000).div(swapRate);
    }

    event Swap(address indexed user, uint256 inAmount, uint256 outAmount, uint id1, uint id2, uint id3);
    event AdminTokenRecovery(address tokenRecovered, uint256 amount); 

// Contract code designed by @EVMlord (Telegram & Twitter)
}