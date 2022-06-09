/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-04
*/

pragma solidity 0.5.16;
/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _factory;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event FactoryTransferred(address indexed previousFactory, address indexed newFactory);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        _factory = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function factory() public view returns (address) {
        return _factory;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyFactory() {
        require(isFactory(), "Ownable: caller is not the factory");
        _;
    }

    modifier onlyFactoryOrOwner() {
        require(isFactory() || isOwner(), "Ownable: caller is not the factory");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function isFactory() public view returns (bool) {
        return _msgSender() == _factory;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function renounceFactory() public onlyFactory {
        emit FactoryTransferred(_owner, address(0));
        _factory = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function setOwnerOnce(address newOwner) public onlyFactory {
        _owner = newOwner;
    }

    function setFactory(address newFactory) public onlyOwner {
        _factory = newFactory;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
    function mint(address account, uint amount) external;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IUniswapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IERC721{
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    function mintNFT(uint256 id, address user) external returns (uint256);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

contract SupeAvatarMintGold is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC721 public nft_token = IERC721(0xEdE9d7fA6a88Bb01578352ECeC2FA786513feecA);
    address public dev_pool = address(0x96eD0b21d024b82A430386A3A1477324f25f0143);

    uint256 start_id = 100;
    bool private paused = false;
    bool private emergency = false;

    // Info of each pool.
    PoolInfo[] public pools;

    // Info of each pool.
    struct PoolInfo {
        uint256 start_time;
        uint256 end_time;

        uint256 male_max_stake_count;
        uint256 male_lock_duration;
        address male_reward_coin_a;
        address male_reward_coin_b;
        uint256 male_reward_coin_a_amount;
        uint256 male_reward_coin_b_amount;

        uint256 female_max_stake_count;
        uint256 female_lock_duration;
        address female_reward_coin_a;
        address female_reward_coin_b;
        uint256 female_reward_coin_a_amount;
        uint256 female_reward_coin_b_amount;

        mapping(address => uint256) male_balance;
        mapping(address => mapping(uint256=>StakeInfo)) male_stakes;
        mapping(address => uint256) female_balance;
        mapping(address => mapping(uint256=>StakeInfo)) female_stakes;
        mapping(uint256 => address) asset2account;
    }

    struct StakeInfo {
        uint256 asset_id;
        uint256 rount_id;
        uint256 start_ts;
        uint256 end_ts;
    }

    event StakeOne(address _user, uint256 _asset_id, uint256 _start_ts, uint256 _end_ts, uint256 round_id);
    event ExitOne(address _user, uint256 _asset_id, uint256 _start_ts, uint256 _end_ts, uint256 _tlp, uint256 _frog);
    event ClaimReward(uint256 _round, address _account, uint256 _asset_id, address _coina, address _coinb, uint256 _coina_amount, uint256 _coinb_amount);

    constructor() public {
    }

    function initialize(IERC721 _nftToken) external onlyFactoryOrOwner{
        nft_token = _nftToken;
    }

    function pool_length() external view returns (uint256) {
        return pools.length;
    }

    function get_male_pool_config(uint256 _pid, address _account) public view returns 
    (uint256 start_time, uint256 end_time, uint256 lock_duration, uint256 max_stake_count,
    address reward_coin_a, address reward_coin_b, uint256 reward_coin_a_amount, uint256 reward_coin_b_amount,
    uint256 staked_balance)
    {
        start_time = pools[_pid].start_time;
        end_time = pools[_pid].end_time;
        lock_duration = pools[_pid].male_lock_duration;
        max_stake_count = pools[_pid].male_max_stake_count;
        reward_coin_a = pools[_pid].male_reward_coin_a;
        reward_coin_b = pools[_pid].male_reward_coin_b;
        reward_coin_a_amount = pools[_pid].male_reward_coin_a_amount;
        reward_coin_b_amount = pools[_pid].male_reward_coin_b_amount;
        staked_balance = pools[_pid].male_balance[_account];
    }

    function get_female_pool_config(uint256 _pid, address _account) public view returns 
    (uint256 start_time, uint256 end_time, uint256 lock_duration, uint256 max_stake_count,
    address reward_coin_a, address reward_coin_b, uint256 reward_coin_a_amount, uint256 reward_coin_b_amount,
    uint256 staked_balance)
    {
        start_time = pools[_pid].start_time;
        end_time = pools[_pid].end_time;
        lock_duration = pools[_pid].female_lock_duration;
        max_stake_count = pools[_pid].female_max_stake_count;
        reward_coin_a = pools[_pid].female_reward_coin_a;
        reward_coin_b = pools[_pid].female_reward_coin_b;
        reward_coin_a_amount = pools[_pid].female_reward_coin_a_amount;
        reward_coin_b_amount = pools[_pid].female_reward_coin_b_amount;
        staked_balance = pools[_pid].female_balance[_account];
    }

    function pool_add(uint256 _start_time, uint256 _end_time) external onlyFactoryOrOwner{
        pools.push(PoolInfo({
            start_time:         _start_time,
            end_time:           _end_time,
            male_lock_duration: 0,
            male_max_stake_count: 0,
            male_reward_coin_a: address(0x0),
            male_reward_coin_b: address(0x0),
            male_reward_coin_a_amount: 0,
            male_reward_coin_b_amount: 0,
            female_lock_duration: 0,
            female_max_stake_count: 0,
            female_reward_coin_a: address(0x0),
            female_reward_coin_b: address(0x0),
            female_reward_coin_a_amount: 0,
            female_reward_coin_b_amount: 0
        }));
    }
    function set_pool_config(uint256 _pid, uint256 start_ts, uint256 end_ts)  external onlyFactoryOrOwner
    {
        pools[_pid].start_time = start_ts;
        pools[_pid].end_time = end_ts;
    }
    function set_male_pool_config(uint256 _pid, uint256 lock_duration, uint256 max_stake_count,
    address reward_coin_a, address reward_coin_b, uint256 reward_coin_a_amount, uint256 reward_coin_b_amount)  external onlyFactoryOrOwner
    {
        pools[_pid].male_lock_duration = lock_duration;
        pools[_pid].male_max_stake_count = max_stake_count;
        pools[_pid].male_reward_coin_a = reward_coin_a;
        pools[_pid].male_reward_coin_b = reward_coin_b;
        pools[_pid].male_reward_coin_a_amount = reward_coin_a_amount;
        pools[_pid].male_reward_coin_b_amount = reward_coin_b_amount;
    }
    function set_female_pool_config(uint256 _pid, uint256 lock_duration, uint256 max_stake_count,
    address reward_coin_a, address reward_coin_b, uint256 reward_coin_a_amount, uint256 reward_coin_b_amount)  external onlyFactoryOrOwner
    {
        pools[_pid].female_lock_duration = lock_duration;
        pools[_pid].female_max_stake_count = max_stake_count;
        pools[_pid].female_reward_coin_a = reward_coin_a;
        pools[_pid].female_reward_coin_b = reward_coin_b;
        pools[_pid].female_reward_coin_a_amount = reward_coin_a_amount;
        pools[_pid].female_reward_coin_b_amount = reward_coin_b_amount;
    }

    function stake_male(uint256 _pid, uint256[] memory ids) public{
        require(block.timestamp >= pools[_pid].start_time && block.timestamp < pools[_pid].end_time, "invalid ts");
        uint256 start_ts = block.timestamp;
        uint256 end_ts = start_ts.add(pools[_pid].male_lock_duration);
        for (uint256 i = 0; i < ids.length; ++i) {
            stake_male_one(_pid, ids[i], start_ts, end_ts);
        }
    }
    function stake_male_one(uint256 round_id, uint256 _asset_id, uint256 _start_ts, uint256 _end_ts) internal checkPaused{
        uint256 _pid = round_id;
        require(nft_token.ownerOf(_asset_id) == msg.sender, "not asset owner");
        require(_asset_id > 5000 && _asset_id <= 10000, "invalid asset id");
        require(pools[_pid].male_balance[msg.sender] < pools[_pid].male_max_stake_count, "1");
        require(pools[round_id].male_stakes[msg.sender][_asset_id].asset_id == 0, "asset has been staked");
        nft_token.safeTransferFrom(msg.sender, dev_pool, _asset_id);
        pools[round_id].male_stakes[msg.sender][_asset_id] = StakeInfo({
            asset_id: _asset_id,
            rount_id: round_id,
            start_ts: _start_ts,
            end_ts: _end_ts
        });
        pools[round_id].male_balance[msg.sender] = pools[round_id].male_balance[msg.sender].add(1);
        pools[round_id].asset2account[_asset_id] = msg.sender;
        emit StakeOne(msg.sender, _asset_id, _start_ts, _end_ts, round_id);
    }

    function stake_female(uint256 _pid, uint256[] memory ids) public{
        require(block.timestamp >= pools[_pid].start_time && block.timestamp < pools[_pid].end_time, "invalid ts");
        uint256 start_ts = block.timestamp;
        uint256 end_ts = start_ts.add(pools[_pid].female_lock_duration);
        for (uint256 i = 0; i < ids.length; ++i) {
            stake_female_one(_pid, ids[i], start_ts, end_ts);
        }
    }
    function stake_female_one(uint256 round_id, uint256 _asset_id, uint256 _start_ts, uint256 _end_ts) internal checkPaused{
        uint256 _pid = round_id;
        require(nft_token.ownerOf(_asset_id) == msg.sender, "not asset owner");
        require(_asset_id > 0 && _asset_id <= 5000, "invalid asset id");
        require(pools[_pid].female_balance[msg.sender] < pools[_pid].female_max_stake_count, "1");
        require(pools[round_id].female_stakes[msg.sender][_asset_id].asset_id == 0, "asset has been staked");
        nft_token.safeTransferFrom(msg.sender, dev_pool, _asset_id);
        pools[round_id].female_stakes[msg.sender][_asset_id] = StakeInfo({
            asset_id: _asset_id,
            rount_id: round_id,
            start_ts: _start_ts,
            end_ts: _end_ts
        });
        pools[round_id].female_balance[msg.sender] = pools[round_id].female_balance[msg.sender].add(1);
        pools[round_id].asset2account[_asset_id] = msg.sender;
        emit StakeOne(msg.sender, _asset_id, _start_ts, _end_ts, round_id);
    }

    function exit_male(uint256[] memory ids, uint256[] memory rounds) public{
        for (uint256 i = 0; i < ids.length; ++i) {
            exit_male_one(rounds[i], ids[i]);
        }
    }
    function exit_male_one(uint256 _round_id, uint256 _asset_id) internal{
        require(pools[_round_id].male_stakes[msg.sender][_asset_id].asset_id > 0, "asset has been exited");
        require(pools[_round_id].male_stakes[msg.sender][_asset_id].end_ts <= block.timestamp, "asset not end");
        nft_token.safeTransferFrom(dev_pool, msg.sender, _asset_id);
        uint256 coin_a_amount;
        uint256 coin_b_amount;
        if(pools[_round_id].male_reward_coin_a != address(0x0) && pools[_round_id].male_reward_coin_a_amount != 0){
            coin_a_amount = pools[_round_id].male_reward_coin_a_amount;
            IERC20(pools[_round_id].male_reward_coin_a).safeTransfer(msg.sender, pools[_round_id].male_reward_coin_a_amount);
        }
        if(pools[_round_id].male_reward_coin_b != address(0x0) && pools[_round_id].male_reward_coin_b_amount != 0){
            coin_b_amount = pools[_round_id].male_reward_coin_b_amount;
            IERC20(pools[_round_id].male_reward_coin_b).safeTransfer(msg.sender, pools[_round_id].male_reward_coin_b_amount);
        }
        emit ExitOne(msg.sender, _asset_id, pools[_round_id].male_stakes[msg.sender][_asset_id].start_ts, pools[_round_id].male_stakes[msg.sender][_asset_id].end_ts, coin_a_amount, coin_b_amount);
        emit ClaimReward(_round_id, msg.sender, _asset_id, pools[_round_id].male_reward_coin_a, pools[_round_id].male_reward_coin_b, coin_a_amount, coin_b_amount);
        delete(pools[_round_id].male_stakes[msg.sender][_asset_id]);
    }

    function exit_female(uint256[] memory ids, uint256[] memory rounds) public{
        for (uint256 i = 0; i < ids.length; ++i) {
            exit_female_one(rounds[i], ids[i]);
        }
    }
    function exit_female_one(uint256 _round_id, uint256 _asset_id) internal{
        require(pools[_round_id].female_stakes[msg.sender][_asset_id].asset_id > 0, "asset has been exited");
        require(pools[_round_id].female_stakes[msg.sender][_asset_id].end_ts <= block.timestamp, "asset not end");
        nft_token.safeTransferFrom(dev_pool, msg.sender, _asset_id);
        uint256 coin_a_amount;
        uint256 coin_b_amount;
        if(pools[_round_id].female_reward_coin_a != address(0x0) && pools[_round_id].female_reward_coin_a_amount != 0){
            coin_a_amount = pools[_round_id].female_reward_coin_a_amount;
            IERC20(pools[_round_id].female_reward_coin_a).safeTransfer(msg.sender, pools[_round_id].female_reward_coin_a_amount);
        }
        if(pools[_round_id].female_reward_coin_b != address(0x0) && pools[_round_id].female_reward_coin_b_amount != 0){
            coin_b_amount = pools[_round_id].female_reward_coin_b_amount;
            IERC20(pools[_round_id].female_reward_coin_b).safeTransfer(msg.sender, pools[_round_id].female_reward_coin_b_amount);
        }
        emit ExitOne(msg.sender, _asset_id, pools[_round_id].female_stakes[msg.sender][_asset_id].start_ts, pools[_round_id].female_stakes[msg.sender][_asset_id].end_ts, coin_a_amount, coin_b_amount);
        emit ClaimReward(_round_id, msg.sender, _asset_id, pools[_round_id].female_reward_coin_a, pools[_round_id].female_reward_coin_b, coin_a_amount, coin_b_amount);
        delete(pools[_round_id].female_stakes[msg.sender][_asset_id]);
    }

    function withdrawToken(address token) external onlyOwner {
        IERC20(token).safeTransfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }
    function withdrawETH() external onlyOwner{
        _safeTransferETH(msg.sender, address(this).balance);
    }
    function _safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'SupeNFTStakingPool Transfer: ETH_TRANSFER_FAILED');
    }
    function _isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function set_paused(bool _paused) external onlyOwner {
        paused = _paused;
    }
    modifier checkNotContract(address _account) {
        require(!_isContract(_account), "SupeNFTStakingPool: is contract");
        _;
    }
    modifier checkPaused() {
        require(!paused, "SupeNFTStakingPool: Pool is paused");
        _;
    }
    function set_emergency(bool _emergency) external onlyOwner {
        emergency = _emergency;
    }
    modifier checkEmergency() {
        require(emergency, "SupeNFTStakingPool: Emergency is closed");
        _;
    }

}