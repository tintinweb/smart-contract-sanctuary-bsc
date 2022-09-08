/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// File: contracts/protocols/bep/BepLib.sol
//SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.8;
pragma experimental ABIEncoderV2;

interface IBEP20 {

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

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

pragma solidity >=0.6.2 <0.8.0;

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

/*
interface OriginNFT {
    function NIds(uint256 _tokenId) external view returns (uint256);

    function mint(address _to, uint256 _NId) external returns (uint256);
}
*/

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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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
     * - the calling contract must have an BNB balance of at least `value`.
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IPancakeFactory {
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

interface IPancakePair {
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

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

library NCommon {
    using SafeMath for uint256;

    function random(uint256 from, uint256 to, uint256 salty) internal view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp + block.difficulty +
                    ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
                    block.gaslimit +
                    ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
                    block.number +
                    salty
                )
            )
        );
        return seed.mod(to - from) + from;
    }

    function getPairAddress(IPancakeRouter02 router, address tokenAddrA, address tokenAddrB) internal view returns (address)
    {
        return IPancakeFactory(router.factory()).getPair(tokenAddrA, tokenAddrB);    
    }
}

contract SCTToken is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _tTotal = 100000 * 10 ** 9;

    string private _name = "Scarecrow Token";
    string private _symbol = "SCT";
    uint8 private _decimals = 9;

    IPancakeRouter02 private pancakeRouter;

    address[] public whiteList;
    mapping(address => bool) public whiteListActive;

    address public usdt;
    bool private swapUnlock;

    mapping(address => bool) private isAccountActive;
    uint256 public activeAccountsNum;

    address private minePool;
    address private baseAccountSCT;
    address private baseAccount;
    NInternal private internalAddr;

    uint256 private X0;
    uint256 private Y0;
    uint256 private X1;
    uint256 private Y1;

    uint256 private X2;
    uint256 private Y2;
    uint256 private X3;
    uint256 private Y3;

    constructor (
        address payable routerAddress,
        address _usdt
    ) public {
        usdt = _usdt;

        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(routerAddress);
        pancakeRouter = _pancakeRouter;

        whiteList.push(msg.sender);
        whiteListActive[msg.sender] = true;
        internalAddr = new NInternal(address(this), _usdt);

        _tOwned[msg.sender] = _tTotal;
    }

    function name() public view returns (string memory) {
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
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
        return true;
    }

    receive() external payable {}

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        require(from != address(0));
        require(to != address(0));
        require(amount > 0);

        address pancakePair = NCommon.getPairAddress(pancakeRouter, address(this), usdt);

        if(from == pancakePair) {
            if(to == address(pancakeRouter)) {
                _transferStandard(from, to, amount);
            }else {
                initialAccount(tx.origin);
                if(swapUnlock) {
                    _transferStandard(from, tx.origin, amount);
                    if(nextRewardTime[tx.origin] == 0) {
                        updateRewardTime(tx.origin);
                    }
                    swapUnlock = false;
                }else {
                    if(whiteListActive[tx.origin]) {
                        _transferStandard(from, tx.origin, amount);
                    }else {
                        _transferStandard(from, tx.origin, amount);
                        paySwapTxFee(tx.origin, amount, amount.mul(X2)/100, amount.mul(Y2)/100);
                    }
                }
            }
        }else if(to == pancakePair) {
            if(swapUnlock || from == owner()) {
                _transferStandard(from, to, amount);
                swapUnlock = false;
            }else {
                if(whiteListActive[from]) {
                    _transferStandard(from, to, amount);
                }else {
                    _transferStandard(from, to, amount);
                    paySwapTxFee(to, amount, amount.mul(X3)/100, amount.mul(Y3)/100);
                }
            }
        }else {
            _transferStandard(from, to, amount);
        }
    }

    function initialAccount(address to) internal {
        if(!isAccountActive[to]) {
            isAccountActive[to] = true;
            activeAccountsNum += 1;
        }
    }

    function _transferStandard(address sender, address recipient, uint256 amount) private {
        _tOwned[sender] = _tOwned[sender].sub(amount);
        _tOwned[recipient] = _tOwned[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function paySCTSwapTxFee(uint256 amount, uint256 X, uint256 Y) 
        internal
        returns (uint256)
    {
        //IBEP20(usdt).transfer(address(this), X);
        rewardPoolUSDT = rewardPoolUSDT.add(X);
        IBEP20(usdt).transfer(address(baseAccountSCT), Y);

        return amount.sub(X+Y);
    }

    function paySwapTxFee(address from, uint256 amount, uint256 X, uint256 Y) 
        internal
        returns (uint256)
    {
        _transferStandard(from, address(minePool), X);
        _transferStandard(from, address(baseAccount), Y);

        return amount.sub(X+Y);
    }

    function getTokenBack(address tokenAddr)
        external
    {
        require(msg.sender == owner());

        if(tokenAddr == address(0)) {
            (bool sent,) = msg.sender.call{value : address(this).balance}("");
            require(sent);
        }else {
            IBEP20(tokenAddr).transfer(baseAccount, IBEP20(tokenAddr).balanceOf(address(this)));  
        }  
    }

    function setKeyAddress(
        address _minePool,
        address _account,
        address _accountSCT
    )
        public
    {
        require(tx.origin == owner());

        minePool = _minePool;
        baseAccount = _account;
        baseAccountSCT = _accountSCT;
        nextRewardTime[_account] = block.timestamp;
        nextRewardTime[_accountSCT] = block.timestamp;
    }

    function getKeyAddress()
        public
        view
        returns (address _minePool, address _account, address _accountSCT)
    {
        _minePool = minePool;
        _account = baseAccount;
        _accountSCT = baseAccountSCT;
    }

    function setBuySCTFee(uint256 X, uint256 Y)
        public
    {
        require(tx.origin == owner());
        require(X+Y < 25);
        X0 = X;
        Y0 = Y;
    }

    function setSellSCTFee(uint256 X, uint256 Y)
        public
    {
        require(tx.origin == owner());
        require(X+Y < 25);
        X1 = X;
        Y1 = Y;
    }

    function setBuyNotSCTFee(uint256 X, uint256 Y)
        public
    {
        require(tx.origin == owner());
        require(X+Y < 25);
        X2 = X;
        Y2 = Y;
    }

    function setSellNotSCTFee(uint256 X, uint256 Y)
        public
    {
        require(tx.origin == owner());
        require(X+Y < 25);
        X3 = X;
        Y3 = Y;
    }

    function swapTokensForSCT(uint256 _amount, address tokenAddress) 
        public
        payable
    {
        swapUnlock = true;

        address[] memory path = new address[](2);
        uint256 usdtSwap;
        uint256 amount;

        if(tokenAddress == usdt) {
            amount = _amount;
            IBEP20(tokenAddress).transferFrom(msg.sender, address(this), amount);
            usdtSwap = paySCTSwapTxFee(amount, 
            amount.mul(X0)/100, amount.mul(Y0)/100);
        }else if(tokenAddress == address(0)) {
            amount = msg.value;
            path[0] = pancakeRouter.WETH();
            path[1] = usdt;
            uint256[] memory usdtCanSwap = pancakeRouter.getAmountsOut(amount, path);
            pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
                0,
                path,
                address(this),
                block.timestamp
            );
            usdtSwap = paySCTSwapTxFee(usdtCanSwap[1], 
            usdtCanSwap[1].mul(X0)/100, usdtCanSwap[1].mul(Y0)/100);
        }else {
            amount = _amount;
            IBEP20(tokenAddress).transferFrom(msg.sender, address(this), amount);
            path[0] = tokenAddress;
            path[1] = usdt;
            uint256[] memory usdtCanSwap = pancakeRouter.getAmountsOut(amount, path);
            IBEP20(tokenAddress).approve(address(pancakeRouter), amount);
            pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                0,
                path,
                address(this),
                block.timestamp
            );
            usdtSwap = paySCTSwapTxFee(usdtCanSwap[1], 
            usdtCanSwap[1].mul(X0)/100, usdtCanSwap[1].mul(Y0)/100);
        }

        path[0] = usdt;
        path[1] = address(this);
        IBEP20(usdt).approve(address(pancakeRouter), usdtSwap);
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtSwap,
            0,
            path,
            msg.sender,
            block.timestamp
        );
    }

    function swapSCTForToken(uint256 amount, address tokenAddress) 
        public 
    {
        swapUnlock = true;

        _transferStandard(msg.sender, address(this), amount);
        
        address[] memory path = new address[](2);
        uint256 usdtSwap;

        path[0] = address(this);
        path[1] = usdt;
        uint256[] memory usdtCanSwap = pancakeRouter.getAmountsOut(amount, path);
        _approve(address(this), address(pancakeRouter), amount);
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(internalAddr),
            block.timestamp
        );

        internalAddr.getUSDT();
        usdtSwap = paySCTSwapTxFee(usdtCanSwap[1], 
        usdtCanSwap[1].mul(X1)/100, usdtCanSwap[1].mul(Y1)/100);

        if(tokenAddress == address(0)) {
            IBEP20(usdt).approve(address(pancakeRouter), usdtSwap);
            path[0] = usdt;
            path[1] = pancakeRouter.WETH();
            pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                usdtSwap,
                0,
                path,
                msg.sender,
                block.timestamp
            );
        }else if(tokenAddress == usdt) {
            IBEP20(usdt).transfer(msg.sender, usdtSwap);
        }else {
            IBEP20(usdt).approve(address(pancakeRouter), usdtSwap);
            path[0] = usdt;
            path[1] = tokenAddress;
            pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                usdtSwap,
                0,
                path,
                msg.sender,
                block.timestamp
            );
        }
    }

    function getBuySCTFee()
        public
        view
        returns (uint256, uint256)
    {
        return (X0, Y0);
    }

    function getSellSCTFee()
        public
        view
        returns (uint256, uint256)
    {
        return (X1, Y1);
    }

    function getBuyNotSCTFee()
        public
        view
        returns (uint256, uint256)       
    {
        return (X2, Y2);
    }

    function getSellNotSCTFee()
        public
        view
        returns (uint256, uint256)      
    {
        return (X3, Y3);
    }

    function addWhiteList(address contractAddress) 
        public 
    {
        require(tx.origin == owner());
        whiteList.push(contractAddress);
        whiteListActive[contractAddress] = true;
    }

    function removeWhiteList(address contractAddress) 
        public 
    {
        require(tx.origin == owner());
        for(uint256 i = 0; i < whiteList.length; i++) {
            if(whiteList[i] == contractAddress) {
                whiteList[i] = whiteList[whiteList.length-1];
                whiteList.pop();
                whiteListActive[contractAddress] = false;
                break;
            }
        }
    }

    uint256 public rewardPoolUSDT;

    mapping (address => uint256) public nextRewardTime; 

    uint256 public discount = 80;
    uint256 public rewardLimitPeriod = 3 days;
    uint256 public maxReward;

    function setRewardPara(uint256 time, uint256 rate, uint256 max) 
        external
    {
        require(tx.origin == owner());
        rewardLimitPeriod = time;
        discount = rate;
        maxReward = max;
    }

    function getRewardPara() 
        public
        view
        returns(uint256 time, uint256 rate, uint256 max)

    {
        time = rewardLimitPeriod;
        rate = discount;
        max = maxReward;
    }

    function claimReward()
        external 
    {
        require(nextRewardTime[msg.sender] != 0 && block.timestamp >= nextRewardTime[msg.sender]);
        uint256 reward = getReward(msg.sender);
        rewardPoolUSDT = rewardPoolUSDT.sub(reward);
        IBEP20(usdt).transfer(address(msg.sender), reward);
        updateRewardTime(msg.sender);
    }

    function updateRewardTime(address account) private {
        nextRewardTime[account] = block.timestamp + rewardLimitPeriod;
    }

    function getReward(address account) 
        public 
        view
        returns (uint256)
    {
        uint256 reward = rewardPoolUSDT.mul(discount).div(100)
                .mul(_tOwned[account])
                .div(_tTotal.sub(
                    IBEP20(address(this)).balanceOf(address(0x000000000000000000000000000000000000dEaD))
                ));
        if(reward > maxReward) {
            return maxReward;
        }else {
            return reward;
        }
    } 
}

contract NInternal  { 
    address private root;
    address private usdt;
    constructor (
        address _root,
        address _usdt
    ) public {
        root = _root;
        usdt = _usdt;
    }
    function getUSDT() public {
        require(msg.sender==root);
        IBEP20(usdt).transfer(root, IBEP20(usdt).balanceOf(address(this)));
    }
}