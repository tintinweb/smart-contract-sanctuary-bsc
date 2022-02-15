// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity 0.8.0;

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
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity 0.8.0;

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

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
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

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity 0.8.0;

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
    constructor() {
        _transferOwnership(_msgSender());
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
    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0));
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
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Ancestry is Context, IERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    /* events section */

    event NewTaxFeePercent(uint256 oldTaxFee, uint256 newTaxFee);
    event NewTeamFeePercent(uint256 oldTeamFee, uint256 newTeamFee);
    event NewMaxTxAmount(uint256 oldMaxTxAmount, uint256 newMaxTxAmount);

    event AncToCoinmita(address account, uint256 amount, uint256 allowance);
    event CoinmitaToAnc(address account, uint256 amount, uint256 allowance);
    event PayWithCoinmita(address account, uint256 amount, uint256 allowance);
    event ClaimCoinmita(address account, uint256 amount);
    event UpdateCoinmitaFee(uint256 oldFee, uint256 newFee);

    /*
        Contract designed based on reflected.finance reflections between holders
        system by @0xDoctorCrypto for Fortress ART NFT Game 18/01/2021

        Total supply of token is fully fixed. Only 26000000 ANC will be fairly
        distributed following announced tokenomics scheme provided on gitDocs

        No one from the team during the development phase has received a dollar. 
        This is the biggest signal of our trust in this project. That's the 
        reason the contract will be deployed with the next fees in order to cover
        big spending we've made during this phase.

            + 2% Fee to be distributed between hodlers on each transaction
            + 3% Fee of transacion to be distributed to development team

        Anyway, we will always will do our best to keep the project alive and
        we'll rennounce to our fee when needed keeping this finality.
        That's why this contract have both fees adjustables by methods below.

        We'll keep this small fees for some time from launch and will announce
        on official channels how do they evolve over time in order to protect
        user experience and token price. Injection liquidity plans are always
        dynamic based on the evolution from project launch.

        But development team also needs to keep evolving. Keep this in mind,
        and always trust us as we've trusted you before knowing each other.

        Our first priority is FortressART NFT Game and to be able to continue
        developing more project for BSC and further Blockchains.

        This is just the beginning...

        Stay tuned.


    */

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;

    // Struct for saving Game information mapped to each address
    struct Player {
        uint256 timesBlacklisted;
        bool isBlacklisted;
        string reason;
        uint256 coinmitaBalance;
    }

    uint256 private _coinmitaToANCFee = 3;

    // For tracking players
    mapping(address => Player) public _playerTrack;

    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 26000000 ether;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "Ancestry";
    string private constant _symbol = "ANC";
    uint8 private constant _decimals = 18;
    /* 
        Token Launch conditions: 
            + 2% of each transaction distributed between holders
            + 3% of each transaction distributed between dev team
    */
    uint256 public _taxFee = 2;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _teamFee = 3;
    uint256 private _previousteamFee = _teamFee;

    /*
        Max tokens per transaction for users in order to prevent
        whale behavior and protect token price & community
        0.146% from _tTotal = 38000

    */
    uint256 public _maxTxAmount = 25000 ether;

    address private dev1;
    address private dev2;
    address private dev3;
    address private dev4;
    address private dev5;
    address private dev6;
    address private dev7;
    address private rewBag;
    address private teamRw;

    /* first quantity must remain on deployer wallet for promo */
    uint256 constant PUBLIC_AND_PRIVATE_SALE_TOKENS = 6929000 ether;
    uint256 constant REWARD_BAG_TOKENS = 18811000 ether;
    uint256 PER_MEMBER_TOKENS = SafeMath.div(260000 ether, 7);

    constructor(
        address _dev1,
        address _dev2,
        address _dev3,
        address _dev4,
        address _dev5,
        address _dev6,
        address _dev7,
        address _rewBag,
        address _teamRw
    ) {
        require(
            address(_msgSender()) != address(0),
            "ERC20: construct from the zero address"
        );
        require(_dev1 != address(0), "ERC20: construct from the zero address");
        require(_dev2 != address(0), "ERC20: construct from the zero address");
        require(_dev3 != address(0), "ERC20: construct from the zero address");
        require(_dev4 != address(0), "ERC20: construct from the zero address");
        require(_dev5 != address(0), "ERC20: construct from the zero address");
        require(_dev6 != address(0), "ERC20: construct from the zero address");
        require(_dev7 != address(0), "ERC20: construct from the zero address");
        require(
            _rewBag != address(0),
            "ERC20: construct from the zero address"
        );
        require(
            _teamRw != address(0),
            "ERC20: construct from the zero address"
        );
        require(
            _rewBag != address(0),
            "ERC20: construct from the zero address"
        );

        dev1 = _dev1;
        dev2 = _dev2;
        dev3 = _dev3;
        dev4 = _dev4;
        dev5 = _dev5;
        dev6 = _dev6;
        dev7 = _dev7;
        rewBag = _rewBag;
        teamRw = _teamRw;

        _rOwned[_msgSender()] = _rTotal;

        //exclude owner, devs, and this contract from fee
        _isExcludedFromFee[address(0)] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[rewBag] = true;

        _isExcludedFromFee[dev1] = true;
        _isExcludedFromFee[dev2] = true;
        _isExcludedFromFee[dev3] = true;
        _isExcludedFromFee[dev4] = true;
        _isExcludedFromFee[dev5] = true;
        _isExcludedFromFee[dev6] = true;
        _isExcludedFromFee[dev7] = true;
        _isExcludedFromFee[teamRw] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);

        transfer(rewBag, REWARD_BAG_TOKENS);
        transfer(dev1, PER_MEMBER_TOKENS);
        transfer(dev2, PER_MEMBER_TOKENS);
        transfer(dev3, PER_MEMBER_TOKENS);
        transfer(dev4, PER_MEMBER_TOKENS);
        transfer(dev5, PER_MEMBER_TOKENS);
        transfer(dev6, PER_MEMBER_TOKENS);
        transfer(dev7, PER_MEMBER_TOKENS);
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
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
        external nonReentrant
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
        external nonReentrant
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

    function isExcludedFromReward(address account)
        external
        view
        returns (bool)
    {
        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    /* 
        For further information about reflected tokens contracts (math explained)
        https://reflect-contract-doc.netlify.app/ 
    */

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        uint256 oldTaxFee = _taxFee;
        _taxFee = taxFee;
        emit NewTaxFeePercent(oldTaxFee, taxFee);
    }

    function setTeamFeePercent(uint256 teamFee) external onlyOwner {
        uint256 oldTeamFeePercent = _teamFee;
        _teamFee = teamFee;
        emit NewTeamFeePercent(oldTeamFeePercent, teamFee);
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        uint256 oldMaxTxAmount = _maxTxAmount;
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);
        emit NewMaxTxAmount(oldMaxTxAmount, _maxTxAmount);
    }

    function addToBlacklist(address addr, string calldata reason)
        external
        onlyOwner
    {
        assert(address(addr) != address(0));
        _playerTrack[addr].isBlacklisted = true;
        _playerTrack[addr].reason = reason;
        _playerTrack[addr].timesBlacklisted++;
        excludeFromReward(addr);
    }

    function removeFromBlacklist(address addr) external onlyOwner {
        assert(address(addr) != address(0));
        _playerTrack[addr].isBlacklisted = false;
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeamFee) = _getTValues(
            tAmount
        );
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tTeamFee,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tTeamFee
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tTeamFee = calculateTeamFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeamFee);
        return (tTransferAmount, tFee, tTeamFee);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTeamFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeamFee = tTeamFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeamFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeTeamFee(uint256 tAmount) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[teamRw] = _rOwned[teamRw].add(rAmount);
        if (_isExcluded[teamRw]) _tOwned[teamRw] = _tOwned[teamRw].add(tAmount);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }

    function calculateTeamFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_teamFee).div(10**2);
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _teamFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousteamFee = _teamFee;

        _taxFee = 0;
        _teamFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _teamFee = _previousteamFee;
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
    ) private nonReentrant {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //if any account belongs to _isExcludedFromFee then remove the maxTxAmount
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to])
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeamFee
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeamFee(tTeamFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeamFee
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeamFee(tTeamFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeamFee
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeamFee(tTeamFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeamFee
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeamFee(tTeamFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // coinmita functions

    /*  
        dev: transfer 'amount' of ANC to game wallet and increases
             coinmita balance 'amount' quantity.
        @amount: quantity of ANC to be converted to coinmita
    */

    function ancToCoinmita(uint256 amount) external nonReentrant returns (bool) {
        require(
            !Address.isContract(msg.sender),
            "Not by now, not EOA users are not allowed"
        );
        // require user is not blacklisted
        require(
            !_playerTrack[_msgSender()].isBlacklisted,
            "Sorry game ended for you: You're blacklisted"
        );
        // require user's ANC balance is GE than amount requested
        require(balanceOf(_msgSender()) >= amount, "Not enough balance");
        // transfer to rewBag ANC amount to convert
        transfer(rewBag, amount);
        uint256 coinmitaAmount = amount - amount.mul(5).div(100);
        // update user Coinmita balance
        _playerTrack[_msgSender()].coinmitaBalance += coinmitaAmount;
        // appprove for later conversion that amount of ANC to be spent from game Wallet
        _approve(
            rewBag,
            _msgSender(),
            _allowances[rewBag][_msgSender()].add(coinmitaAmount)
        );
        emit AncToCoinmita(
            _msgSender(),
            coinmitaAmount,
            _allowances[rewBag][_msgSender()]
        );
        return true;
    }

    /*
        dev: allows an user to transform their conmita balance back
             to ANC Token. 
        @amount: quantity of Coinmita to be converted to ANC
    */

    function coinmitaToAnc(uint256 amount) external nonReentrant returns (bool) {
        require(
            !Address.isContract(msg.sender),
            "Not by now, not EOA users are not allowed"
        );
        // require user is not blacklisted
        require(
            !_playerTrack[_msgSender()].isBlacklisted,
            "Sorry game ended for you: You're blacklisted"
        );
        // requiere user's Coinmita balance is GE than amount requested
        require(
            _playerTrack[_msgSender()].coinmitaBalance >= amount,
            "Not enough balance. Re-connect your wallet in order to update it."
        );
        uint256 coinmitaAmountToDeliver = amount -
            (amount * _coinmitaToANCFee) /
            100;
        // update user's coinmita balance substracting requested amount
        _playerTrack[_msgSender()].coinmitaBalance = _playerTrack[_msgSender()]
            .coinmitaBalance
            .sub(amount, "ERC20: decreased balance below zero");
        // update user allowance substracting the fee
        _approve(
            rewBag,
            _msgSender(),
            _allowances[rewBag][_msgSender()].sub(
                amount.mul(_coinmitaToANCFee).div(100)
            )
        );
        // transfer from rewBag requested amount to user
        transferFrom(rewBag, _msgSender(), coinmitaAmountToDeliver);
        emit CoinmitaToAnc(
            _msgSender(),
            coinmitaAmountToDeliver,
            _allowances[rewBag][_msgSender()]
        );
        return true;
    }

    /*
        dev: allows user to transact a payment on Fortress Art Game with Coinmita
        @amount: quantity of Coinmita to be deducted from allowance and balance
    */

    function payWithCoinmita(uint256 amount) external nonReentrant returns (bool) {
        require(
            !Address.isContract(msg.sender),
            "Not by now, not EOA users are not allowed"
        );
        // require user is not blacklisted
        require(
            !_playerTrack[_msgSender()].isBlacklisted,
            "Sorry game ended for you: You're blacklisted"
        );
        // requiere user's Coinmita balance is GE than amount requested
        require(
            _playerTrack[_msgSender()].coinmitaBalance >= amount,
            "Not enough balance"
        );
        // update coinmita Balance
        _playerTrack[_msgSender()].coinmitaBalance = _playerTrack[_msgSender()]
            .coinmitaBalance
            .sub(amount, "ERC20: decreased balance below zero");
        // Decrease Allowance for later ANC conversion
        _approve(
            rewBag,
            _msgSender(),
            _allowances[rewBag][_msgSender()].sub(
                amount,
                "ERC20: decreased allowance below zero"
            )
        );
        emit PayWithCoinmita(
            _msgSender(),
            amount,
            _allowances[rewBag][_msgSender()]
        );
        return true;
    }

    function getCoinmitaBalance(address account)
        external
        view
        returns (uint256)
    {
        require(
            !_playerTrack[_msgSender()].isBlacklisted,
            "Sorry game ended for you: You're blacklisted"
        );
        return _playerTrack[account].coinmitaBalance;
    }

    function getCoinmitaAllowance(address account)
        external
        view
        returns (uint256)
    {
        return _allowances[rewBag][account];
    }

    /*
        dev: Increase the balance of coinmita on the blockchain user account, able to be claimed
        as a higher quantity has been earned on the game. This function is called
        for us when connecting to DAPP checking if Coinmita balance from Fortress Art Game 
        is higher than value received from getCoinmitaBalance, allowing us to update it and
        leting an user to claim their earned funds. 
        @account: acount to be checked
        @amount: total coinmita amount on our BBDD from the game
    */

    function claimCoinmita(address account, uint256 amount)
        external
        nonReentrant
        onlyOwner
        returns (bool)
    {
        require(
            !Address.isContract(msg.sender),
            "Not by now, not EOA users are not allowed"
        );
        // require user is not blacklisted
        require(
            !_playerTrack[account].isBlacklisted,
            "Sorry game ended for you: You're blacklisted"
        );
        // require new Allowance is GE Current Allowance
        require(
            _allowances[rewBag][account] < amount,
            "You can't increase allowance to a smaller value"
        );
        // update coinmita Balance
        _playerTrack[account].coinmitaBalance = amount;
        // increase allowance
        _approve(rewBag, account, _playerTrack[account].coinmitaBalance);
        emit ClaimCoinmita(account, _playerTrack[account].coinmitaBalance);
        return true;
    }

    function updateCoinmitaFee(uint256 newFee)
        external
        onlyOwner
        returns (bool)
    {
        uint256 oldFee = _coinmitaToANCFee;
        _coinmitaToANCFee = newFee;
        emit UpdateCoinmitaFee(oldFee, newFee);
        return true;
    }
}