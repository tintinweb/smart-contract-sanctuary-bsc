// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./Distributor.sol";
import "./interfaces/DexRouter.sol";

contract ARTKToken is IERC20, Initializable {
    using SafeMath for uint256;

    // Pancakeswap 0x10ED43C718714eb63d5aA57B78B54704E256024E (testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3)
    address private constant ROUTER =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // WBNB 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c (testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd)
    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    uint256 private constant TEAM_FEE = 20;
    uint256 private constant TAX_FEE = 10;
    uint256 private constant ANTI_WHALE_AMOUNT = 50000000000000000000000000;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    mapping(address => bool) private excludedFromTax;
    address private _owner;

    Distributor private distributor;
    address payable public distributorAddress;

    DexRouter private dexRouter;
    uint256 public dateFeesAccumulation;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function initialize(uint256 _supply) public initializer {
        _name = "Artik";
        _symbol = "ARTK";

        _transferOwnership(msg.sender);

        _totalSupply += _supply * (10**decimals());
        _balances[_owner] += _supply * (10**decimals());

        excludedFromTax[_owner] = true;
        excludedFromTax[ROUTER] = true;

        dexRouter = DexRouter(ROUTER);
        _approve(address(this), ROUTER, totalSupply());
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function configureDistributor(address payable _address) external onlyOwner {
        distributorAddress = _address;
        distributor = Distributor(_address);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address the_owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[the_owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address the_owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(
            the_owner != address(0),
            "ERC20: approve from the zero address"
        );
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[the_owner][spender] = amount;
        emit Approval(the_owner, spender, amount);
    }

    function processTransfers(
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
        if (
            excludedFromTax[msg.sender] ||
            excludedFromTax[_sender] ||
            _recipient == distributorAddress
        ) {
            _transfer(_sender, _recipient, _amount);
        } else {
            require(
                _amount < ANTI_WHALE_AMOUNT,
                "amount greater than anti-whale limit"
            );

            if (msg.sender != ROUTER) {
                require(
                    balanceOf(_recipient) < ANTI_WHALE_AMOUNT,
                    "recipient balance greater than anti-whale limit"
                );
            }

            uint256 taxFee = _amount.mul(TAX_FEE).div(100);

            // Transfer amount-fees to recipient
            _transfer(_sender, _recipient, _amount.sub(taxFee));

            // Transfer fee to token wallet
            _transfer(_sender, address(this), taxFee);

            distributor.addShareHolder(_recipient);
            if (balanceOf(_sender) <= 0) {
                distributor.removeShareHolder(_sender);
            }
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function accumulateFees() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        uint256 teamFee = tokenBalance.mul(TEAM_FEE).div(100);

        // Transfer fee to team wallet
        swapTokens(teamFee, _owner);

        // Transfer airdrop and buy-back fee to distributor
        swapTokens(tokenBalance.sub(teamFee), distributorAddress);

        // Convert distributor's balance BNB to BUSD
        distributor.swapTokens();
    }

    function transfer(address _recipient, uint256 _amount)
        public
        override
        returns (bool)
    {
        if (msg.sender == distributorAddress && _recipient == address(0x0)) {
            _burn(msg.sender, _amount);
        } else {
            processTransfers(msg.sender, _recipient, _amount);
        }

        return true;
    }

    function transferFrom(
        address the_owner,
        address _recipient,
        uint256 _amount
    ) public override returns (bool) {
        processTransfers(the_owner, _recipient, _amount);

        uint256 currentAllowance = allowance(the_owner, msg.sender);
        require(
            currentAllowance >= _amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(the_owner, msg.sender, currentAllowance.sub(_amount));
        }

        return true;
    }

    function swapTokens(uint256 _amount, address _to) private {
        require(_amount > 0, "amount less than 0");
        require(_to != address(0), "address equal to 0");

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;
        uint256 amountWethMin = dexRouter.getAmountsOut(_amount, path)[1];

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            amountWethMin,
            path,
            _to,
            block.timestamp
        );
    }

    function excludeFromFee(address _user, bool _exclude) external onlyOwner {
        require(_user != address(0));
        excludedFromTax[_user] = _exclude;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

        (bool success, ) = recipient.call{value: amount}("");
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

        (bool success, bytes memory returndata) = target.call{value: value}(data);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/*
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

pragma solidity >=0.6.2;

interface DexRouter {
    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./interfaces/DexRouter.sol";

contract Distributor is Initializable {
    using SafeMath for uint256;

    // Pancakeswap 0x10ED43C718714eb63d5aA57B78B54704E256024E (testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3)
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // WBNB 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c (testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd)
    address constant BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    // BUSD 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 (testnet: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7)
    address constant STABLE_COIN = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    uint256 private constant BUY_BACK_FEE = 25; //(2% of total fee)
    uint256 private accumulatedEthForAirdrop;

    DexRouter private dexRouter;

    address private artikToken;
    address payable private admin;

    address[] public shareholders;
    uint256 private shareholderCount;
    mapping(address => uint256) private shareholderIndexes;

    uint256 public roundNumber;
    mapping(address => mapping(uint256 => uint256)) private voters;
    mapping(address => bool) private isVoter;

    mapping(address => mapping(uint256 => bool)) private userClaimedProject;
    uint256 public totalAmountAirdropped;
    mapping(address => uint256) public amountClaimed;

    Project public bestProject;

    uint256 public airdropBalance;
    uint256 public totalHoldersBalance;
    uint256 public airdropDate;

    uint256 public projectCount;
    uint256 public votesCount;
    mapping(uint256 => Project) public projects;

    event WithdrawAirdropTokens(uint256 amount, address token);

    event ProjectUploaded(
        uint256 id,
        string img,
        string name,
        string description,
        string category,
        string url,
        string twitter,
        uint256 votes,
        address tokenAddress,
        string tokenSymbol,
        uint256 tokenDecimals,
        bool active
    );

    struct Project {
        uint256 id;
        string img;
        string name;
        string description;
        string category;
        string url;
        string twitter;
        uint256 votes;
        address tokenAddress;
        string tokenSymbol;
        uint256 tokenDecimals;
        bool active;
    }

    function initialize(address _tokenAddress) public initializer {
        dexRouter = DexRouter(ROUTER);
        artikToken = _tokenAddress;
        admin = payable(msg.sender);
        shareholderCount = 0;
        roundNumber = 1;
        totalAmountAirdropped = 0;
        projectCount = 0;
        votesCount = 0;
        accumulatedEthForAirdrop = 0;
        totalHoldersBalance = 0;
        airdropBalance = 0;
    }

    modifier onlyToken() {
        require(msg.sender == artikToken, "sender is not the token");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    function uploadProject(
        string memory _img,
        string memory _name,
        string memory _description,
        string memory _category,
        string memory _url,
        string memory _twitter,
        bytes20 _tokenAddress,
        string memory _tokenSymbol,
        uint256 _tokenDecimals
    ) external onlyAdmin {
        require(msg.sender != address(0));
        require(bytes(_img).length > 0);
        require(bytes(_name).length > 0);
        require(bytes(_description).length > 0);
        require(bytes(_category).length > 0);
        require(bytes(_url).length > 0);
        require(address(_tokenAddress) != address(0x0));
        require(bytes(_tokenSymbol).length > 0);
        require(_tokenDecimals > 0);

        projectCount = projectCount.add(1);
        projects[projectCount] = Project(
            projectCount,
            _img,
            _name,
            _description,
            _category,
            _url,
            _twitter,
            0,
            address(_tokenAddress),
            _tokenSymbol,
            _tokenDecimals,
            true
        );

        emit ProjectUploaded(
            projectCount,
            _img,
            _name,
            _description,
            _category,
            _url,
            _twitter,
            0,
            address(_tokenAddress),
            _tokenSymbol,
            _tokenDecimals,
            true
        );
    }

    function changeProjectState(uint256 _projectId, bool _active)
        external
        onlyAdmin
    {
        projects[_projectId].active = _active;
    }

    function voteProject(uint256 _projectId) external {
        require(
            voters[msg.sender][_projectId] != roundNumber,
            "voters can vote the same project only 1 time"
        );
        require(
            shareholderIndexes[msg.sender] > 0,
            "voters must be token holders"
        );
        require(_projectId != 0, "projectId canno be 0");

        projects[_projectId].votes = projects[_projectId].votes.add(1);
        voters[msg.sender][_projectId] = roundNumber;
        isVoter[msg.sender] = true;
        votesCount = votesCount.add(1);
    }

    function resetProjectVotes(uint256 _projectId) external onlyAdmin {
        projects[_projectId].votes = 0;
    }

    function setBestProject(uint256 _projectId) external onlyAdmin {
        bestProject = projects[_projectId];
    }

    function setAirdropDate(uint256 _days) public onlyAdmin {
        airdropDate = block.timestamp + (1 days * _days);
    }

    function initializeAirdrop(uint256 _days) external onlyAdmin {
        require(block.timestamp >= airdropDate);

        uint256 STABLE_COINBalance = IERC20(STABLE_COIN).balanceOf(
            address(this)
        );

        require(STABLE_COINBalance > 0);
        require(bestProject.id != 0);

        totalHoldersBalance = calculateTVL(true);
        nextRound();

        IERC20(STABLE_COIN).approve(ROUTER, STABLE_COINBalance);
        (uint256 amountWethMin, ) = getAmountOutMin(
            STABLE_COINBalance,
            STABLE_COIN,
            BNB
        );
        IERC20(BNB).approve(ROUTER, amountWethMin);

        uint256 buyBackFee = STABLE_COINBalance.mul(BUY_BACK_FEE).div(100);
        uint256 amountToSwap = STABLE_COINBalance.sub(buyBackFee);

        // Buy back mechanism
        buyBack(buyBackFee);

        // Swap BUSD -> BNB -> Airdrop Token
        buyAirdropTokens(amountToSwap, bestProject.tokenAddress);
        setAirdropDate(_days);

        airdropBalance = IERC20(bestProject.tokenAddress).balanceOf(
            address(this)
        );

        //accumulatedEthForAirdrop = airdropBalance;
        (accumulatedEthForAirdrop, ) = getAmountOutMin(
            airdropBalance,
            bestProject.tokenAddress,
            BNB
        );
    }

    function buyAirdropTokens(uint256 _amount, address _project) private {
        swapTokensForETH(_amount, STABLE_COIN);
        swapETHForTokens(address(this).balance, _project);
    }

    function buyBack(uint256 _fee) private {
        swapTokensForETH(_fee, STABLE_COIN);
        swapETHForTokens(address(this).balance, artikToken);
        IERC20(artikToken).transfer(
            address(0x0),
            IERC20(artikToken).balanceOf(address(this))
        );
    }

    function claimAirdrop() public {
        uint256 airdrop = calculateAirdropAmount(msg.sender);
        IERC20(bestProject.tokenAddress).transfer(msg.sender, airdrop);

        isVoter[msg.sender] == false;
        userClaimedProject[msg.sender][bestProject.id] = true;

        (uint256 amountWethMin, ) = getAmountOutMin(
            airdrop,
            bestProject.tokenAddress,
            BNB
        );
        (uint256 amountStableMin, ) = getAmountOutMin(
            amountWethMin,
            BNB,
            STABLE_COIN
        );

        amountClaimed[msg.sender] = amountClaimed[msg.sender].add(
            amountStableMin
        );
        totalAmountAirdropped = totalAmountAirdropped.add(amountStableMin);
    }

    function calculateTVL(bool _onlyVoters) public view returns (uint256) {
        uint256 currentBalance = 0;
        for (uint256 i = 0; i < shareholders.length; i++) {
            if ((_onlyVoters && isVoter[shareholders[i]]) || !_onlyVoters) {
                currentBalance = currentBalance.add(
                    IERC20(artikToken).balanceOf(shareholders[i])
                );
            }
        }
        return currentBalance;
    }

    function calculateAirdropAmount(address _shareholder)
        public
        view
        returns (uint256)
    {
        require(shareholderIndexes[_shareholder] > 0, "not a shareholder");
        require(isVoter[_shareholder] == true, "not a voter");
        require(
            _shareholder != address(0x0),
            "shareholder cannot be address of 0"
        );
        require(
            userClaimedProject[_shareholder][bestProject.id] != true,
            "shareholder has already claimed this airdrop"
        );
        require(totalHoldersBalance > 0, "total holders balance less than 0");

        uint256 holderPercentage = calculateHolderPercentage(
            _shareholder,
            totalHoldersBalance
        );
        uint256 airdrop = airdropBalance.mul(holderPercentage).div(100);

        return airdrop;
    }

    function calculateHolderPercentage(
        address _shareholder,
        uint256 _totalHoldersBalance
    ) private view returns (uint256) {
        // 100 : x = totalHoldersBalance : holderBalance
        uint256 holderBalance = IERC20(artikToken).balanceOf(_shareholder);
        uint256 holderPercentage = holderBalance.mul(100).div(
            _totalHoldersBalance
        );
        return holderPercentage;
    }

    function calculateAirdropPercentage(address _shareholder)
        external
        view
        returns (uint256)
    {
        require(
            _shareholder != address(0x0),
            "shareholder address cannot be 0"
        );
        require(shareholderIndexes[_shareholder] > 0, "not a shareholder");

        uint256 holderBalance = IERC20(artikToken).balanceOf(_shareholder);
        require(
            holderBalance > 0,
            "shareholder balance must be greater than 0"
        );

        uint256 holders_balance = 0;
        if (totalHoldersBalance > 0) {
            holders_balance = totalHoldersBalance;
        } else {
            holders_balance = calculateTVL(true);
        }

        uint256 holderPercentage = calculateHolderPercentage(
            _shareholder,
            holders_balance
        );
        uint256 airdrop = accumulatedEthForAirdrop.mul(holderPercentage).div(
            100
        );

        require(airdrop > 0, "airdrop amount must be greater than 0");
        (uint256 airdropInArtik, ) = getAmountOutMin(airdrop, BNB, artikToken);

        // 100 : x = artik balance : airdrop in artik
        return airdropInArtik.mul(100).div(holderBalance);
    }

    function addShareHolder(address _shareholder) external onlyToken {
        require(_shareholder != address(0x0));

        if (shareholderIndexes[_shareholder] <= 0) {
            shareholders.push(_shareholder);
            shareholderCount = shareholderCount.add(1);
            shareholderIndexes[_shareholder] = shareholderCount;
        }
    }

    function removeShareHolder(address _shareholder) external onlyToken {
        require(_shareholder != address(0x0));

        if (shareholderIndexes[_shareholder] > 0) {
            shareholders[shareholderIndexes[_shareholder] - 1] = shareholders[
                shareholders.length - 1
            ];
            shareholders.pop();
            shareholderCount = shareholderCount.sub(1);
            shareholderIndexes[_shareholder] = 0;
        }
    }

    function swapETHForTokens(uint256 _amount, address _token) private {
        require(_amount > 0);
        require(_token != address(0x0));
        require(address(this).balance >= _amount, "balance less than _amount");

        address[] memory path = new address[](2);
        path[0] = BNB;
        path[1] = _token;

        dexRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: _amount
        }(0, path, address(this), block.timestamp);
    }

    function swapTokensForETH(uint256 _amount, address _token) private {
        require(_amount > 0);
        require(_token != address(0x0));
        require(
            IERC20(_token).balanceOf(address(this)) >= _amount,
            "balance less than _amount"
        );

        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = BNB;

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function getAmountOutMin(
        uint256 _amount,
        address _tokenIn,
        address _tokenOut
    ) private view returns (uint256, address[] memory) {
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;

        uint256[] memory amountOutMins = dexRouter.getAmountsOut(_amount, path);
        return (amountOutMins[1], path);
    }

    function swapTokens() external onlyToken {
        uint256 buyBackFee = address(this).balance.mul(BUY_BACK_FEE).div(100);
        accumulatedEthForAirdrop = accumulatedEthForAirdrop
            .add(address(this).balance)
            .sub(buyBackFee);

        IERC20(BNB).approve(ROUTER, address(this).balance);
        swapETHForTokens(address(this).balance, STABLE_COIN);
    }

    function nextRound() public onlyAdmin {
        roundNumber = roundNumber.add(1);
    }

    function withdrawRemainingAirdrop(address _token) external onlyAdmin {
        require(_token != address(0x0));
        uint256 remainingBalance = IERC20(_token).balanceOf(address(this));
        require(remainingBalance > 0);
        IERC20(_token).transfer(admin, remainingBalance);
        emit WithdrawAirdropTokens(remainingBalance, _token);
    }

    function hasVotedProject(uint256 _projectId) external view returns (bool) {
        if (voters[msg.sender][_projectId] == roundNumber) {
            return true;
        } else {
            return false;
        }
    }

    receive() external payable {}
}