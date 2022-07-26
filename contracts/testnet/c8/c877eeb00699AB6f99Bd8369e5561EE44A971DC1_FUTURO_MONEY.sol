/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

/**
* iLLegal.Money* $MOB$
* t.me/illegalMoney*
* iLLegalMoney is a gamified meme token
*
* Its A Game, Its A Token 
*
* Create Your LaFamilia (with vault) & Invite Traders To Join Your Family
* As The Head Of The Family, You Get 1% $MOB$ Transactions Of The
* Members In Your Family.
*
* The Biggest Family Controls Of The Token. Set Liquidity, Reflections % AND* Set % Fees In BNB, Your Family Receives Each Trade.
* Head Family Members Are Excempt From Fees
*
* Family Members can withdraw from the community vault every x days
*
* Become A Made Man To Be Fee Exempt By Burning 1% or More Of Total Supply* Or Become A Made Man By Owning A Specific NFTea
* 
* Stick Up Any Holder (except Made Men) With More Than 1% Of Total Supply In  * Their Wallet.
*
* They Cannot Sell Unless They Pay Your Family 12.5% Of Their Balance AND* Burn 12.5% Of Their Balance
*
* Family Payments Go Into The Family Vault
*
* Challenge Any Family For Their Family Vault. Big Bank Takes Little Banks* In This Fight.
*
* 1st Family With 100 Members Controls The Contract
*
* Family count auto updated with each trade. Any community can take over
*
*
*/

pragma solidity ^0.8.11;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {

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

library SafeMath {
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return (msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
        (bool success, ) = recipient.call{ value: amount }("");
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
    address private _super;
    address private _previousOwner;
    uint256 private _lockTime;
    mapping (address => bool) internal authorizations;
    mapping (address => bool) internal superAdmin;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        _super = msgSender;
        authorizations[_owner] = true;
        superAdmin[_owner] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }
    function superAd(address _value) public view returns (bool) {
        return superAdmin[_value];
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    modifier onlySuper() {
        require(_super == _msgSender(), "Ownable: caller is not a super");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided (seconds)
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp> _lockTime , "Contract is still locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }

    //Modifier to require caller to be authorized
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    //Authorize address.
    function authorize(address account) public onlySuper {
        authorizations[account] = true;
    }

    // Remove address' authorization.
    function unauthorize(address account) public onlySuper {
        authorizations[account] = false;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address account) public view returns (bool) {
        return authorizations[account];
    }
}

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
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


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
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

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}



// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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
}

interface i1155 {

    function joinCommunity(address _member) external pure returns(bool);
    function leaveCommunity(address _member) external pure returns(uint256);
    function createCommunity(string memory _name, address _leader,uint256 _minVaultAdd) external returns(address);
    function setStatus(address _leader, address _member, uint256 _status, uint256 _type, uint256 _value) external pure returns (bool);
    function _members() external pure returns(address[] memory);
    function getMember(address member_) external pure returns (address,address,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256);
    function getTribeVolume(address tribe_,address supertribe_) external pure returns (uint256,uint256);
    function setMemberStats(address member_, uint256 type_, uint256 value_, address tribe_, uint256 supply_) external returns(bool);
    function setTribeStats(address tribe_, uint256 type_, uint256 value_) external pure returns(bool);
    function getTribe(address tribe_, address member_, uint256 type_) external pure returns (address,address,uint256,uint256,uint256,uint256);
    function rainDance(address member_) external returns (address, uint256);      

}
contract FUTURO_MONEY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcludedFromReward;

    mapping (address => bool) private _isExcludedFromMaxSellTransactionAmount;
    address[] private _excludedFromReward;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 3000000000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    address public liquidityWallet;
    address payable public marketingWallet = payable(0x00293ADF690c5A6A03F1fa4b9f069EF891b38851);
    uint256 private _tFeeTotal;

    string private _name = "FuTuRo.Money";
    string private _symbol = "OWO";
    uint8 private _decimals = 18;

    address constant private  DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant private BLANK = 0x0000000000000000000000000000000000000000;
    mapping(address => bool) public _isAdmin;
    mapping(address => bool) public _isContract;
    mapping(address => address) public _member2tribe;
    mapping(address => address) public _tribe2leader;
    mapping(address => bool) public _flag;
    mapping(address => uint256) public _flagFee;
    mapping(address => address) public _flagBy;
    mapping(address=>uint256) public _raintotal;
    bool rainDance;
    uint256 rainEnd;
    address public TRIBE;
    address public SUPERTRIBE;
    address public KINGOWO;
    address public OWOPRINCE;
    bool public KINGOWO_RESTRICTED;
    uint256 public CHALLENGEDATE;


    uint8 public sellRewardFee = 2;
    uint8 public buyRewardFee = 2;

    uint8 public sellLiquidityFee = 2;
    uint8 public buyLiquidityFee = 2;

    uint8 public sellMarketingFee = 8;
    uint8 public buyMarketingFee = 8;

    uint8 totalSellFees;
    uint8 totalBuyFees;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private _inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public maxSellTransactionAmount = _tTotal.mul(6).div(100);
    uint256 private _swapTokensAtAmount =  100000000000 * 10**18;

    // all known liquidity pools
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping(address=>uint256) private _memberToErrorCode;

    uint256 private _marketingCurrentAccumulatedFee;
    uint256 private _liquidityCurrentAccumulatedFee;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event UniswapV2RouterUpdated(address indexed newAddress, address indexed oldAddress);
    event UniswapV2PairUpdated(address indexed newAddress, address indexed oldAddress);
    event MarketingWalletUpdated(address indexed newMarketingWallet, address indexed oldMarketingWallet);
    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event MaxSellTransactionAmountUpdated(uint256 amount);

    event ExcludeFromFees(address indexed account);
    event ExcludeFromReward(address indexed account);
    event ExcludeFromMaxSellTransactionAmount(address indexed account);
    event IncludeInFees(address indexed account);
    event IncludeInReward(address indexed account);
    event IncludeInMaxSellTransactionAmount(address indexed account);

    event SellFeesUpdated(uint8 rewardFee,uint8 liquidityFee,uint8 marketingFee);
    event BuyFeesUpdated(uint8 rewardFee,uint8 liquidityFee,uint8 marketingFee);

    event Burn(uint256 amount);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event SendMarketingDividends(uint256 amount);
    event SendFamilyDividends(uint256 amount, address payTo);
    event newKing(address _newKing, address _newSupremeCommunity);
    event flagPaid(address _member, address _paidTo);


    modifier lockTheSwap {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    struct tTransferValues {
      uint256 tAmount;
      uint256 tTransferAmount;
      uint256 tRewardFee;
      uint256 tLiquidityFee;
      uint256 tMarketingFee;
   }

    struct rTransferValues {
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRewardFee;
      uint256 rLiquidityFee;
      uint256 rMarketingFee;

   }

    constructor ()  {
        _rOwned[_msgSender()] = _rTotal;

        uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
         // Create a uniswap pair for this new token with BNB
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());

        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[DEAD] = true;
        _isExcludedFromFee[marketingWallet] = true;
         _isAdmin[msg.sender] = true;
        totalBuyFees = buyLiquidityFee + buyMarketingFee + buyRewardFee;
        totalSellFees = sellLiquidityFee + sellMarketingFee + sellRewardFee;

        // exclude pair and other wallets from reward
        excludeFromReward(owner());
        excludeFromReward(address(this));
        excludeFromReward(DEAD);
        excludeFromReward(marketingWallet);

        _isExcludedFromMaxSellTransactionAmount[owner()] = true;
        _isExcludedFromMaxSellTransactionAmount[address(this)] = true;

        liquidityWallet = owner();


        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    function setAdmin (address _member, bool value) public {

      require(_isAdmin[msg.sender], 'you are not that cool');
      _isAdmin[_member] = value;

    }
    function tribeUpdate (address member_, address tribe_, address leader_) public returns(bool){

      require(_isContract[msg.sender], 'you are not that cool');
      _tribe2leader[tribe_] = leader_;
      _member2tribe[member_] = tribe_;

      if(tribe_==SUPERTRIBE && KINGOWO!=leader_){
        KINGOWO = leader_;
      }

      return true;
    }
    function test(address tribe_) public returns(bool){

        uint256 sup_ = getRealSupply();
        bool success = i1155(TRIBE).setMemberStats(msg.sender,5,5000000,tribe_,sup_);
        if(success){
          (,,,,,,,uint256 status_,,) = i1155(TRIBE).getMember(msg.sender);
          if(status_>3){
              _isExcludedFromFee[msg.sender] = true;
          }
        }
        return true;
    }   
    function getMyTribe() public view returns (address,address,uint256,uint256,uint256,uint256){

        return i1155(TRIBE).getTribe(BLANK,msg.sender,1);
    }

    function TRYRAINDANCE() public returns(bool) {
        ///one person in your tribe could get % of owo transactions for 3 hours
      require(_member2tribe[msg.sender] != address(0), 'join a tribe 1st');
     (address winner_, uint256 end_) =  i1155(TRIBE).rainDance(msg.sender);
      rainDance = true;
      OWOPRINCE = winner_;
      rainEnd = end_;
      return true;
    }

    function setKingRestrict (bool value) public {

      require(_isAdmin[msg.sender], 'you are not that cool');
      KINGOWO_RESTRICTED = value;

    }
    function setErrorCode (address _member, uint256 _errorCode) public {

      require(_isContract[msg.sender], 'you are not that cool');
      _memberToErrorCode[_member] = _errorCode;

    }
    function setContract (address cont, bool value) public {

      require(_isAdmin[msg.sender] || _isContract[msg.sender], 'you are not that cool');
      _isContract[cont] = value;

    }
    function setTRIBES (address _addy) public {

      require(_isAdmin[msg.sender], 'you are not that cool');
      TRIBE = _addy;

    }

    function createCommunity(string memory _value, uint256 _minGive) public returns (address){

      address commune = i1155(TRIBE).createCommunity(_value, msg.sender,_minGive);
      _member2tribe[msg.sender] = commune;
      _tribe2leader[commune] = msg.sender;
      _isExcludedFromFee[commune] = false;
      return commune;

    }

    function joinCommunity(address _community) public returns(address) {

      require(_member2tribe[msg.sender] == address(0), 'you are already part of another community');
      require(balanceOf(msg.sender)>0 , 'balance too low to join communities');
      bool success = i1155(_community).joinCommunity(msg.sender);
      if(success){
        _member2tribe[msg.sender] = _community;
        if(_community==SUPERTRIBE){
          _isExcludedFromFee[msg.sender] = true;
        }
      }
      return _community;
    }

    function leaveCommunity() public{

      require(_member2tribe[msg.sender] != BLANK, 'you are not part of this community community');
      uint256 status_ = i1155(TRIBE).leaveCommunity(msg.sender);
        _member2tribe[msg.sender] = BLANK;
        if(status_<4){
          _isExcludedFromFee[msg.sender] = false;
        }
    }

    function KINGOWOCONTROLS(uint8 buy_rewardFee,uint8 buy_liquidityFee,uint8 buy_marketingFee,uint8 sell_rewardFee,uint8 sell_liquidityFee,uint8 sell_marketingFee) public{

      require(_member2tribe[msg.sender]==SUPERTRIBE, 'your community is not the head');
      // (/*address*/,/*name*/,/*creator*/,address leader,/*date*/,/*memnbers*/,/*buys*/,/*sellss*/,/*bnb*/,/*owo*/) = i1155(TRIBE).getCommunity(BLANK,msg.sender);
      require(_tribe2leader[_member2tribe[msg.sender]] == msg.sender, 'you are not the leader of this community');
      require(!KINGOWO_RESTRICTED, 'you have been restricted... Engineer..');

      uint8 newTotalBuyFees = buy_rewardFee + buy_liquidityFee + buy_marketingFee;
      require(newTotalBuyFees <=15 , "Total buy fees must be lower or equals to 15%");
      require(buy_marketingFee >1 , "You cutting out the Engineer? Buy marketing fee must be at least 2, do not over step your bounds.. Engineer");
      buyRewardFee = buy_rewardFee;
      buyLiquidityFee = buy_liquidityFee;
      buyMarketingFee = buy_marketingFee;
      totalBuyFees = newTotalBuyFees;
      emit BuyFeesUpdated(buy_rewardFee, buy_liquidityFee, buy_marketingFee);

      uint8 newTotalSellFees = sell_rewardFee + sell_liquidityFee + sell_marketingFee;

      require(newTotalSellFees <=15 , "Total sell fees must be lower or equals to 15%");
      require(sell_marketingFee >1 , "You cutting out the Engineer? Sell marketing fee must be at least 2, do not over step your bounds.. Engineer");

      sellRewardFee = sell_rewardFee;
      sellLiquidityFee = sell_liquidityFee;
      sellMarketingFee = sell_marketingFee;
      totalSellFees = newTotalSellFees;

      KINGOWO = msg.sender;

    }

    function _setFlag(address member_) public{

        (,,,,,,,uint256 status_,,) = i1155(TRIBE).getMember(member_);
        require(status_>3, 'member is sovereign or legend');
        require(!_flag[member_], 'member already being flagged');
        require(balanceOf(member_)>_tTotal.mul(1).div(100), 'balance should be more than 1%');
        require(balanceOf(msg.sender)>0, 'you need some owo to do that');
        require(_member2tribe[msg.sender] != address(0), 'join a tribe 1st');

        uint256 _fee = balanceOf(member_).mul(25).div(100);
        _flagFee[member_] = _fee;
        _flagBy[member_] = _member2tribe[msg.sender];
        _flag[member_] = true;
        i1155(_member2tribe[member_]).leaveCommunity(member_);

    }

    function setname() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromReward[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

      if(_member2tribe[msg.sender]!=address(0)){

        if(_member2tribe[msg.sender]==SUPERTRIBE && !_isExcludedFromFee[msg.sender]){
          _isExcludedFromFee[msg.sender] = true;
        }
        uint256 leaderFee = amount.div(100);
        amount = amount.sub(leaderFee);
        if(rainDance && block.timestamp < rainEnd){

          leaderFee = leaderFee.div(2);
          _transfer(_msgSender(), OWOPRINCE, leaderFee);

        }
        _transfer(_msgSender(), _member2tribe[msg.sender], leaderFee);
        i1155(TRIBE).setMemberStats(msg.sender,2,leaderFee,_member2tribe[msg.sender],getRealSupply());
      }

      _transfer(_msgSender(), recipient, amount);
        return true;
}

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function totalRewardFeesDistributed() public view returns (uint256) {
        return _tFeeTotal;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public authorized {
        require(pair != uniswapV2Pair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            excludeFromReward(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function deliver(uint256 tAmount) external {
        address sender = _msgSender();
        require(!_isExcludedFromReward[sender], "Excluded addresses from reward cannot call this function");
        uint256 rAmount = reflectionFromToken(tAmount);
        _rOwned[sender] -= rAmount;
        _rTotal -= rAmount;
        _tFeeTotal += tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee, bool isSellTransaction) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            uint256 rAmount = reflectionFromToken(tAmount);
            return rAmount;
        } else {
            (, rTransferValues memory rValues) = _getValuesWithFees(tAmount,isSellTransaction);
            return rValues.rTransferAmount;
        }
    }

    function reflectionFromToken(uint256 tAmount) private view returns(uint256) {
        return tAmount.mul(_getRate());
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public authorized() {
        require(!_isExcludedFromReward[account], "Account is already excluded from reward");
        require(_excludedFromReward.length <= 1000, "No more than 1000 addresses can be excluded from the rewards");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromReward[account] = true;
        _excludedFromReward.push(account);
        emit ExcludeFromReward(account);
    }

    function includeInReward(address account) external authorized() {
        require(_isExcludedFromReward[account], "Account is already included in reward");
        for (uint256 i = 0; i < _excludedFromReward.length; i++) {
            if (_excludedFromReward[i] == account) {
                _excludedFromReward[i] = _excludedFromReward[_excludedFromReward.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromReward[account] = false;
                _excludedFromReward.pop();
                break;
            }
        }
        emit IncludeInReward(account);
    }

    function excludeFromFees(address account) public authorized() {
        require(!_isExcludedFromFee[account], "Account is already excluded from fee");
        _isExcludedFromFee[account] = true;
        emit ExcludeFromFees(account);
    }

    function includeInFees(address account) public authorized() {
        require(_isExcludedFromFee[account], "Account is already included in fee");
        _isExcludedFromFee[account] = false;
        emit ExcludeFromFees(account);
    }

     //to recieve BNB from uniswapV2Router when swaping
    receive() external payable {
    }

    function _reflectFee(uint256 rRewardFee, uint256 tRewardFee) private {
        _rTotal -= rRewardFee;
        _tFeeTotal += tRewardFee;
    }


    function _getValuesWithFees(uint256 tAmount, bool isSellTransfer) private view returns (tTransferValues memory, rTransferValues memory) {
        tTransferValues memory tValues= _getTValues(tAmount,isSellTransfer);
        rTransferValues memory rValues= _getRValues(tValues);
        return (tValues,rValues);
    }

    function _getTValues(uint256 tAmount,bool isSellTransfer) private view returns (tTransferValues memory) {
        (uint256 tRewardFee, uint256 tLiquidityFee, uint256 tMarketingFee) = _calculateFees(tAmount, isSellTransfer);
        uint256 tTransferAmount = tAmount.sub(tRewardFee).sub(tLiquidityFee).sub(tMarketingFee);
        return tTransferValues(tAmount,tTransferAmount, tRewardFee, tLiquidityFee, tMarketingFee);
    }

    function _getRValues(tTransferValues memory tValues) private view returns (rTransferValues memory) {
        uint256 currentRate = _getRate();
        uint256 rAmount = tValues.tAmount.mul(currentRate);
        uint256 rRewardFee = tValues.tRewardFee.mul(currentRate);
        uint256 rLiquidityFee = tValues.tLiquidityFee.mul(currentRate);
        uint256 rMarketingFee = tValues.tMarketingFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rRewardFee).sub(rLiquidityFee).sub(rMarketingFee);
        return rTransferValues(rAmount, rTransferAmount, rRewardFee, rLiquidityFee, rMarketingFee);
    }
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excludedFromReward.length; i++) {
            if (_rOwned[_excludedFromReward[i]] > rSupply || _tOwned[_excludedFromReward[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply -= _rOwned[_excludedFromReward[i]];
            tSupply -= _tOwned[_excludedFromReward[i]];
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _calculateFees(uint256 amount, bool isSellTransaction) private view returns (uint256,uint256,uint256) {
        if(isSellTransaction) {
            return(amount*sellRewardFee/100,amount*sellLiquidityFee/100,amount*sellMarketingFee/100);
        }
        else {
            return(amount*buyRewardFee/100,amount*buyLiquidityFee/100,amount*buyMarketingFee/100);
        }

    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    function isExcludedFromReward(address account) public view returns(bool) {
        return _isExcludedFromReward[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount >= 0, "Transfer amount must be greater or equal to zero");
        bool tradingIsEnabled = true;
        bool isSellTransfer = automatedMarketMakerPairs[to];
        if(
        	!_inSwapAndLiquify &&
        	tradingIsEnabled &&
            isSellTransfer && // sells only by detecting transfer to automated market maker pair
        	from != address(uniswapV2Router)//router -> pair is removing liquidity which shouldn't have max
        ) {
            require(amount <= maxSellTransactionAmount, "Sell transfer amount exceeds the maxSellTransactionAmount.");
            require(!_flag[from], 'you are being stuck up from selling');

        }

        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= _swapTokensAtAmount;

        if (
            canSwap &&
            !_inSwapAndLiquify&&
            !automatedMarketMakerPairs[from] && // not during buying
            from != liquidityWallet &&
            to != liquidityWallet &&
            swapAndLiquifyEnabled
        ) {
            //add liquidity
            _swapAndLiquify();
        }

        bool isBuyTransfer = automatedMarketMakerPairs[from];
        bool takeFee = tradingIsEnabled && !_inSwapAndLiquify && (isBuyTransfer || isSellTransfer);

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        if(isSellTransfer){

          // (address _miCommunity,/*name*/,/*creator*/,/*leader*/,/*date*/,/*memnbers*/,/*buys*/,/*sellss*/,/*bnb*/,/*owo*/) = i1155(TRIBE).getCommunity(BLANK,from);
          if(_member2tribe[from]!=address(0)){

            i1155(TRIBE).setTribeStats(_member2tribe[from],2,amount);

          }
        }
        if(isBuyTransfer){
          // (address _miCommunity,/*name*/,/*creator*/,/*leader*/,/*date*/,/*memnbers*/,/*buys*/,/*sellss*/,/*bnb*/,/*owo*/) = i1155(TRIBE).getCommunity(BLANK,to);
          if(_member2tribe[to]!=address(0)){
            i1155(TRIBE).setTribeStats(_member2tribe[to],1,amount);

          }
        }
        _tokenTransfer(from,to,amount,takeFee,isSellTransfer);
    }

    function _swapAndLiquify() private lockTheSwap {
        uint256 totalTokens = balanceOf(address(this));
        // Get the unknown tokens that are on the contract and add them to the amount that goes to the liquidity pool
        uint256 unknownSourcetokens = totalTokens.sub(_marketingCurrentAccumulatedFee).sub(_liquidityCurrentAccumulatedFee);
        _liquidityCurrentAccumulatedFee+= unknownSourcetokens;
        uint256 liquidityTokensToNotSwap = _liquidityCurrentAccumulatedFee.div(2);
        // initial BNB amount
        uint256 initialBalance = address(this).balance;
        // swap tokens for BNB
        _swapTokensForEth(totalTokens.sub(liquidityTokensToNotSwap));

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        uint256 marketingAmount = newBalance.mul(_marketingCurrentAccumulatedFee).div(totalTokens.sub(liquidityTokensToNotSwap));
        uint256 liquidityAmount = newBalance.sub(marketingAmount);

        if(SUPERTRIBE!=address(0)){

            marketingAmount = marketingAmount.div(2);
            sendDividends(marketingAmount,2, SUPERTRIBE);
        //pay to super tribe
        }else{
        //pay to own tribe
            if(_member2tribe[msg.sender] == address(_member2tribe[msg.sender])){

                marketingAmount = marketingAmount.div(2);
                sendDividends(marketingAmount,1, _member2tribe[msg.sender]);
            }else{
                
                marketingAmount = marketingAmount.div(2);
                sendDividends(marketingAmount,3, marketingWallet);

            }
        }
        _marketingCurrentAccumulatedFee = 0;
        _liquidityCurrentAccumulatedFee = 0;
        // add liquidity to PancakeSwap
        _addLiquidity(liquidityTokensToNotSwap, liquidityAmount);
        // send BNB to marketing wallet
        sendMarketingDividends(marketingAmount);
        emit SwapAndLiquify(totalTokens.sub(liquidityTokensToNotSwap), newBalance, liquidityTokensToNotSwap);
    }

    function sendMarketingDividends(uint256 amount) private {
        (bool success,) = payable(address(marketingWallet)).call{value: amount}("");

        if(success) {
   	 		emit SendMarketingDividends(amount);
        }
    }
    function sendDividends(uint256 amount, uint256 _type, address payTo) private{

      (bool success,) = payable(address(payTo)).call{value: amount}("");

      if(success) {

        if(_type==1 && payTo!=marketingWallet){
        ///pay to super tribe
          i1155(TRIBE).setMemberStats(msg.sender,7,amount,SUPERTRIBE,getRealSupply());

        }else if(_type==2 && payTo!=marketingWallet){

            i1155(TRIBE).setMemberStats(msg.sender,7,amount,_member2tribe[msg.sender],getRealSupply());

        }

      emit SendFamilyDividends(amount,payTo);
      }
    }

    function _swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityWallet, // send to liquidity wallet
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee, bool isSellTransfer) private {
        tTransferValues memory tValues;
        rTransferValues memory rValues;

        if(!takeFee) {
            tValues = tTransferValues(amount, amount,0,0,0);
            uint256 rAmount = amount.mul(_getRate());
            rValues = rTransferValues(rAmount, rAmount,0,0,0);
        }
        else {
        (tValues, rValues) = _getValuesWithFees(amount,isSellTransfer);
        }

        if (_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferFromExcluded(sender, recipient, tValues, rValues);
        } else if (!_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferToExcluded(sender, recipient, tValues, rValues);
        } else if (!_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferStandard(sender, recipient, rValues);
        } else if (_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferBothExcluded(sender, recipient, tValues, rValues);
        } else {
            _transferStandard(sender, recipient, rValues);
        }

        emit Transfer(sender, recipient, tValues.tTransferAmount);
        if(takeFee)
            _transferFees(tValues, rValues, sender);
    }
    function _transferFees(tTransferValues memory tValues, rTransferValues memory rValues, address sender) private {
        uint256 rFees = rValues.rMarketingFee.add(rValues.rLiquidityFee);
        uint256 tFees = tValues.tMarketingFee.add(tValues.tLiquidityFee);
        _liquidityCurrentAccumulatedFee+=tValues.tLiquidityFee;
        _marketingCurrentAccumulatedFee+=tValues.tMarketingFee;
        _rOwned[address(this)] = _rOwned[address(this)].add(rFees);
        emit Transfer(sender, address(this), tFees);
        if(_isExcludedFromReward[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tFees);

        _reflectFee(rValues.rRewardFee, tValues.tRewardFee);

    }

    function _transferStandard(address sender, address recipient, rTransferValues memory rValues) private {

        _rOwned[sender] -= rValues.rAmount;
        _rOwned[recipient] += rValues.rTransferAmount;
    }

    function _transferToExcluded(address sender, address recipient, tTransferValues memory tValues, rTransferValues memory rValues) private {
        _rOwned[sender] -= rValues.rAmount;
        _tOwned[recipient] += tValues.tTransferAmount;
        _rOwned[recipient] += rValues.rTransferAmount;
    }

    function _transferFromExcluded(address sender, address recipient, tTransferValues memory tValues, rTransferValues memory rValues) private {
        _tOwned[sender] -= tValues.tAmount;
        _rOwned[sender] -= rValues.rAmount;
        _rOwned[recipient] += rValues.rTransferAmount;
    }

    function _transferBothExcluded(address sender, address recipient, tTransferValues memory tValues, rTransferValues memory rValues) private {
        _tOwned[sender] -= tValues.tAmount;
        _rOwned[sender] -= rValues.rAmount;
        _tOwned[recipient] += tValues.tTransferAmount;
        _rOwned[recipient] += rValues.rTransferAmount;
    }

    function CHALLENGETHEKING() public{
    ///take over as the supreme tribe
    ///you can challenge the king IF you are soveriegn or a legend
    ///your challenge is succesful if your tribe has more trade volume
    ///kings can be challenged daily
    require(_member2tribe[msg.sender] == address(_member2tribe[msg.sender]), 'you are not in a tribe');
    require(balanceOf(msg.sender) > _tTotal.mul(3).div(100), 'you need at least 3% wallet balance to challenge the king');
    require(SUPERTRIBE!=address(0), 'no super tribe yet');
    require(block.timestamp > CHALLENGEDATE, 'cant challenge');
    (,address leader_,,,uint256 mybuys_,uint256 mysells_) = i1155(TRIBE).getTribe(BLANK,msg.sender,1);
    require(leader_==msg.sender, 'you are not the leader of this tribe');
    (,,,,uint256 theirbuys_,uint256 theirsells_) = i1155(TRIBE).getTribe(BLANK,msg.sender,1);
    (,,,,,,,uint256 status_,,) = i1155(TRIBE).getMember(msg.sender);
    if(status_>3 && mybuys_.add(mysells_) > theirbuys_.add(theirsells_)){

        SUPERTRIBE = _member2tribe[msg.sender];
        KINGOWO = _tribe2leader[_member2tribe[msg.sender]];
        _isExcludedFromFee[msg.sender] = true;
        CHALLENGEDATE = block.timestamp + 1 days;
    }

}
    function changeName(string memory name_, string memory symbol_) public {
        require(_isAdmin[msg.sender], 'you think I am stupid? Engineer');
        _name = name_;
        _symbol = symbol_;
    }
    function getCirculatingSupply() public view returns (uint256) {
        return totalSupply().sub(balanceOf(DEAD)).sub(balanceOf(address(0)));
    }
    function getRealSupply() public view returns (uint256) {
        return totalSupply().sub(balanceOf(DEAD));
    }

    function burn(uint256 amount) public returns (bool) {

       if(_flag[msg.sender]){
           ///burn to remove flag that keeps you from selling
         require(balanceOf(msg.sender)>=_flagFee[msg.sender], 'balance too low to pay flag fee');

         _transfer(_msgSender(), DEAD, _flagFee[msg.sender].div(2));
         _transfer(_msgSender(), _flagBy[msg.sender], _flagFee[msg.sender].div(2));
         i1155(TRIBE).setMemberStats(msg.sender,5,_flagFee[msg.sender].div(2),_member2tribe[msg.sender],getRealSupply());

         _flag[msg.sender] = false;
         _flagFee[msg.sender] = 0;
         emit flagPaid(msg.sender, _flagBy[msg.sender]);

       }else{
        /// burn to reset your ability to withdraw from community vaults
         _transfer(_msgSender(), DEAD, amount);
         uint256 sup_ = getRealSupply();
        bool success = i1155(TRIBE).setMemberStats(msg.sender,5,amount,_member2tribe[msg.sender],sup_);
        if(success){
          (,,,,,,,uint256 status_,,) = i1155(TRIBE).getMember(msg.sender);
          if(status_>3){
              _isExcludedFromFee[msg.sender] = true;
          }
        }
       }
         emit Burn(amount);
         return true;
     }

    function sendLiquidityFeeManually() external authorized {
        _swapAndLiquify();
    }

    function setMarketingWallet(address payable newWallet) public {
      require(_isAdmin[msg.sender], 'you are not that cool' );
        require(newWallet != marketingWallet, "The marketing wallet has already that address");
        emit MarketingWalletUpdated(newWallet,marketingWallet);
         marketingWallet = newWallet;
        _isExcludedFromFee[newWallet] = true;
        excludeFromReward(newWallet);
    }

    function getStuckBNBs(address payable to) public {

        require(_isAdmin[msg.sender], 'you are not that cool' );

        require(address(this).balance > 0, "There are no BNBs in the contract");
        to.transfer(address(this).balance);
    }
}