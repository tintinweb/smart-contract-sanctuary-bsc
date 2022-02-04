/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

contract gELVN is IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    address[] private _excluded;

    uint256 private constant _totalSupply = 1000000000 * 10**18;

    mapping(address => uint256) public unvestedBalance;
    mapping(address => uint256) public usedUnvestedBalance;
    mapping(address => bool) public paymentContracts;
    

    //stake nft pool
    address public poolAddr;
    address public serviceAddr;
    uint256 public _poolFee = 3;
    uint256 public _serviceFee = 7;
    uint256 public _maxTxAmount = 5000000 * 10**18;

    IERC20 public originalToken_;

    mapping(address => bool) public transferBlockList_;
    mapping(address => bool) public approveBlockList_;

    event PoolFeeSet(uint256 _new);
    event ServiceFeeSet(uint256 _new);
    event MaxTxPercSet(uint256 _new);
    event NumTokensSet(uint256 _new);
    event PoolAddrSet(address indexed _new);
    event ServiceAddrSet(address indexed _new);
    event SetFee(uint16 oldFeePercentage, uint16 newFeePercentage);
    event SetFeeOwner(address indexed oldFeeOwner, address indexed newFeeOwner);
    event SwapToOriginal(address indexed user, uint256 totalAmount, uint256 feeAmount);
    event SwapFromOriginal(address indexed user, uint256 amount);
    event AddToTransferBlockList(address indexed addr);
    event RemoveFromTransferBlockList(address indexed addr);
    event AddToApproveBlockList(address indexed addr);
    event RemoveFromApproveBlockList(address indexed addr);

    modifier onlyPaymentContracts() {
        require(paymentContracts[msg.sender], "gELVN: You can't call this function!");
        _;
    }

    constructor(address _serviceAddr, address _poolAddr) public {
        require(
            address(_poolAddr) != address(0),
            "gELVN: Zero address in constructor."
        );
        require(
            address(_serviceAddr) != address(0),
            "gELVN: Zero address in constructor."
        );

        poolAddr = _poolAddr;
        serviceAddr = _serviceAddr;

        balances[_msgSender()] = _totalSupply;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[poolAddr] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() external pure returns (string memory) {
        return "Eleven Token";
    }

    function symbol() external pure returns (string memory) {
        return "gELVN";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    //to receive ETH from uniswapV2Router when swapping
    receive() external payable {}

    function withdraw(uint256 amount) external onlyOwner {
        // we assume owner is not a contract
        // so there is no problem with using `transfer`
        payable(owner()).transfer(amount);
    }

    function _takePool(uint256 _poolFeeAmount, address sender) private {
        balances[poolAddr] = balances[poolAddr].add(_poolFeeAmount);
        emit Transfer(sender, poolAddr, _poolFeeAmount);
    }

    function _takeService(uint256 _serviceFeeAmount, address sender) private {
        balances[serviceAddr] = balances[serviceAddr].add(_serviceFeeAmount);
        emit Transfer(sender, serviceAddr, _serviceFeeAmount);
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from != owner() && to != owner())
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount);
    }

    function calculatePoolFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_poolFee).div(10**2);
    }

    function calculateServiceFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_serviceFee).div(10**2);
    }

    function _getValues(uint256 _amount)
        private
        view
        returns (uint256[3] memory)
    {
        uint256[3] memory values;
        values[0] = calculateServiceFee(_amount);
        values[1] = calculatePoolFee(_amount);
        values[2] = _amount.sub(values[0]).sub(values[1]);
        return values;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            _transferWithoutFee(sender, recipient, amount);
        } else {
            _transferWithFee(sender, recipient, amount);
        }
    }

    function _transferWithoutFee(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        balances[sender] = balances[sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _transferWithFee(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256[3] memory values = _getValues(amount);
        /*
            [0] = service fee
            [1] = liquidity fee
            [2] = pool fee
            [3] = token will send
        */

        balances[sender] = balances[sender].sub(amount);
        balances[recipient] = balances[recipient].add(values[2]);

        _takeService(values[0], sender);
        _takePool(values[1], sender);
        emit Transfer(sender, recipient, values[2]);
    }

    function unvestedPayment(address _owner, uint _amount) public onlyPaymentContracts {
        uint256 _ownerBalance = balanceOf(_owner);
        if(_amount <= _ownerBalance) {
            transferFrom(_owner, msg.sender, _amount);
        } else {
            uint256 _ownerAvailableBalance = totalAvailableBalance(_owner);
            if(_ownerBalance.add(_ownerAvailableBalance) >= _amount) {
                transferFrom(_owner, msg.sender, _amount);
                if(_ownerBalance >= _ownerAvailableBalance) {
                    usedUnvestedBalance[msg.sender] = usedUnvestedBalance[msg.sender].add(_ownerBalance.sub(_ownerAvailableBalance));
                } else {
                    usedUnvestedBalance[msg.sender] = usedUnvestedBalance[msg.sender].add(_ownerAvailableBalance.sub(_ownerBalance));
                }
            } else {
                // balance is not enough
                revert("gELVN: Balance is not enough!");
            }
        }
    }

    function vestingIncome(address _to, uint _amount) public onlyPaymentContracts {
        unvestedBalance[_to] = unvestedBalance[_to].sub(_amount);
        usedUnvestedBalance[_to] = usedUnvestedBalance[_to].sub(_amount);
    }

    function setUnvestedBalance(address _to, uint _amount) public onlyPaymentContracts {
        unvestedBalance[_to] = _amount;
    }

    function availableUnvestedBalance(address _owner) public view returns(uint256) {
        return unvestedBalance[_owner].sub(usedUnvestedBalance[_owner]);
    }

    function totalAvailableBalance(address _owner) public view returns(uint256) {
        return balanceOf(_owner).add(availableUnvestedBalance(_owner));
    }

    function addPaymentContract(address _contract) external onlyOwner {
        paymentContracts[_contract] = true;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setServiceFeePercent(uint256 serviceFee) external onlyOwner {
        require(
            serviceFee.add(_poolFee) <= 30,
            "gELVN: Total fee can't be bigger than 30!"
        );
        _serviceFee = serviceFee;
        emit ServiceFeeSet(serviceFee);
    }

    function setPoolFeePercent(uint256 poolFee) external onlyOwner {
        require(
            _serviceFee.add(poolFee) <= 30,
            "gELVN: Total fee can't be bigger than 30!"
        );
        _poolFee = poolFee;
        emit PoolFeeSet(poolFee);
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        require(maxTxPercent > 0, "gELVN: Max tx percent can't be zero!");
        _maxTxAmount = _totalSupply.mul(maxTxPercent).div(10**2);
        emit MaxTxPercSet(maxTxPercent);
    }

    function setPoolAddr(address _poolAddr) external onlyOwner {
        require(_poolAddr != address(0), "zero_address");
        poolAddr = _poolAddr;
        _isExcludedFromFee[poolAddr] = true;
        emit PoolAddrSet(_poolAddr);
    }

    function setServiceAddr(address _serviceAddr) external onlyOwner {
        require(_serviceAddr != address(0), "zero_address");
        serviceAddr = _serviceAddr;
        _isExcludedFromFee[serviceAddr] = true;
        emit ServiceAddrSet(_serviceAddr);
    }

    function setOriginalToken(IERC20 _originalToken) external onlyOwner {
     
        _ensureNotZeroAddress(address(_originalToken));
        require(address(originalToken_) == address(0), "ERR_ORIGINAL_TOKEN_ALREADY_SET");
       // require(_originalToken.decimals() == decimals(), "ERR_DECIMALS_MISMATCH");

        originalToken_ = _originalToken;
     
    }

    function modifyTransferBlockList(address[] calldata _addList, address[] calldata _removeList) external onlyOwner {
        for (uint16 i = 0; i < _addList.length; ++i) {
            transferBlockList_[_addList[i]] = true;
            emit AddToTransferBlockList(_addList[i]);
        }

        for (uint16 i = 0; i < _removeList.length; ++i) {
            delete transferBlockList_[_removeList[i]];
            emit RemoveFromTransferBlockList(_removeList[i]);
        }
    }

    function modifyApproveBlockList(address[] calldata _addList, address[] calldata _removeList) external onlyOwner {
        for (uint16 i = 0; i < _addList.length; ++i) {
            approveBlockList_[_addList[i]] = true;
            emit AddToApproveBlockList(_addList[i]);
        }

        for (uint16 i = 0; i < _removeList.length; ++i) {
            delete approveBlockList_[_removeList[i]];
            emit RemoveFromApproveBlockList(_removeList[i]);
        }
    }

    function isTransferAllowed(address _sender, address _recipient) internal view virtual returns (bool) {
        return !transferBlockList_[_sender]
            && !transferBlockList_[_recipient]
            && !_isUniswapPair(_sender)
            && !_isUniswapPair(_recipient);
    }

    function _isUniswapPair(address _addr) private view returns (bool) {
        if (!_addr.isContract()) return false;

        bool isTokenGetSuccess;
        (isTokenGetSuccess,) = _addr.staticcall(abi.encodeWithSignature("token0()"));
        if(isTokenGetSuccess) {
            (isTokenGetSuccess,) = _addr.staticcall(abi.encodeWithSignature("token1()"));
        }
        return isTokenGetSuccess;
    }

    function isApproveAllowed(address _spender) internal virtual view returns (bool) {
        return !approveBlockList_[_spender];
    }

    function swapToOriginal(uint256 _amount) payable external {
        _ensureOriginalTokenSet();
        require(_amount != 0, "ERR_ZERO_SWAP_AMOUNT");
        require(msg.value >= _amount, "ERR_ZERO_SWAP_AMOUNT");
        uint feeAmount;
        address msgSender = _msgSender();

        if (_isExcludedFromFee[msgSender]) {
            feeAmount = 0;
        } else
        {
            uint256[3] memory values = _getValues(_amount);
            _takeService(values[0], address(this));
            _takePool(values[1], address(this));
            feeAmount = values[0] + values[1];
        }

        originalToken_.transfer(msgSender, _amount - feeAmount);

        emit SwapToOriginal(msgSender, _amount, feeAmount);
    }    

    function swapFromOriginal(uint256 _amount) external {
        _ensureOriginalTokenSet();
        require(_amount != 0, "ERR_ZERO_SWAP_AMOUNT");

        address msgSender = _msgSender();

        originalToken_.transferFrom(msgSender, address(this), _amount);
        _transfer(address(this),msgSender, _amount);

        emit SwapFromOriginal(msgSender, _amount);
    }

    function _validateFee(uint16 _feePercentage) private pure {
        require(_feePercentage <= 10_000, "ERR_FEE_PERCENTAGE_EXCEEDS_MAX");
    }

    function _ensureOriginalTokenSet() private view {
        require(address(originalToken_) != address(0), "ERR_ORIGINAL_TOKEN_NOT_SET");
    }

    function _ensureNotZeroAddress(address _addr) private pure {
        require(_addr != address(0), "ERR_ZERO_ADDRESS");
    }
}