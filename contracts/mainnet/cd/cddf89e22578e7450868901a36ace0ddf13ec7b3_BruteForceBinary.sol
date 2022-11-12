/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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


    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _cast(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


contract BruteForceBinary is ERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => bool) public concertize;
    mapping (address => bool) public eliteList; // excluded fee
    mapping (address => bool) public v1List;
    mapping (address => bool) public abandonList; // black list

    uint256 private _totalRate=10000;
    uint256 public saleAmount=0;
    address public burnAddr =0xe5C0726de661DAec2FcB8D2285e74f5967A0c6FF;


    address public fundAddr =0xe5C0726de661DAec2FcB8D2285e74f5967A0c6FF;
    address public marketingAddr =0xe5C0726de661DAec2FcB8D2285e74f5967A0c6FF;
    address public lpRewardAddr=0xe5C0726de661DAec2FcB8D2285e74f5967A0c6FF;
    address public returnBackAddr=0xe5C0726de661DAec2FcB8D2285e74f5967A0c6FF;


    bool public eliteListSwitch=true;
    bool public v1Switch = true;

    // buy and remove liquid fee
    bool public brSwitch=true;
    uint256 public brLpRewardRate=0; //5% LP reward
    uint256 public brFundRate=0; //1% fund
    uint256 public brMarketingRate=0; //1% marketing
    uint256 public brBurnRate=0; //3%
    uint256 public brReturnRate=0; //3% return
    // sell and add liquid fee
    bool public saSwitch=true;
    uint256 public saLpRewardRate=0; //5% LP reward
    uint256 public saFundRate=0; //1% fund
    uint256 public saMarketingRate=0; //1% marketing
    uint256 public saBurnRate=0; //3%
    uint256 public saReturnRate=0; //3% add lp

    //transfer
    bool public transSwitch=true;
    uint256 public transLpRewardRate=0; //5% LP reward
    uint256 public transFundRate=0; //1% fund
    uint256 public transMarketingRate=0; //1% marketing
    uint256 public transBurnRate=0; //3%
    uint256 public transReturnRate=0; //3% add lp

    uint256 public speRetention = 100;

    bool private swapping;

    uint256 public swapTokensAtAmount;

    // 主网地址
    address pancakeSwapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // pancakeSwapRouter 的路由地址，主要是执行 getAmountsOut 方法
    address pancakeSwapFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73; // pancakeswapFactory 的工厂合约，主要是执行 getPair 方法，找到借币的 pair 地址
    // address honey = 0xA335D0B8e207cD054D7DeA538398E68d4D41eb33;
    address USDT = 0x55d398326f99059fF775485246999027B3197955; //USDT 地址

    // 测试网地址
    // address pancakeSwapRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // pancakeSwapRouter 的路由地址，主要是执行 getAmountsOut 方法
    // address pancakeSwapFactory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc; // pancakeswapFactory 的工厂合约，主要是执行 getPair 方法，找到借币的 pair 地址
    //address honey = 0x02A008Dc2681d699f5B06dF9f479bCAC36dCB2DE;
    // address USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684; // BSC test的 USDT 地址
    //address MGS = 0xD3B21a0197de488Ca3B7fd9F7Eb6f9cE6aE4EbfA;
    // address TransferAddress = 0x111;//中转地址

    IUniswapV2Router01 public router = IUniswapV2Router01(pancakeSwapRouter);
    IUniswapV2Factory public factory = IUniswapV2Factory(pancakeSwapFactory);


    event SwapAndLiquify(uint256 tokensSwapped,uint256 ethReceived,uint256 tokensIntoLiqudity);

    modifier onlyConcertize() {
        require(concertize[_msgSender()], "Operation: caller is not the concertize");
        _;
    }

    constructor() payable ERC20("BruteForceBinary", "BFB")  {
        uint256 totalSupply = 2000000000*1e18;
        swapTokensAtAmount = totalSupply.mul(1).div(10**8); // 0.001%;
        concertize[_msgSender()]=true;
        // Fee Exempt
        eliteList[_msgSender()]=true;
        eliteList[address(this)] =true;

        _cast(_msgSender(), 500000000*1e18);
        address poolReceiver=_msgSender();
        _cast(poolReceiver, 500000000*1e18);
        address airdropReceiver=_msgSender();
        _cast(airdropReceiver, 500000000*1e18);
        address eliteListeceiver=_msgSender();
        eliteList[_msgSender()]=true;
        _cast(eliteListeceiver, 500000000*1e18);
    }

    receive() external payable {}


    function setSaleAmount(uint256 amount) public onlyConcertize {
        saleAmount = amount;
    }

    function setSperetention(uint256 speretention) public onlyConcertize {
        speRetention = speretention;
    }

    function setSwapTokensAtAmount(uint256 amount) public onlyConcertize {
        swapTokensAtAmount = amount;
    }

    function setBurnArr(address _burnAddr) public onlyConcertize {
        burnAddr=_burnAddr;
    }

    function setConcertize(address addr, bool state) public onlyOwner {
        concertize[addr] = state;
    }

    function seteliteList(address addr, bool state) public onlyConcertize {
        eliteList[addr] = state;
    }

    function setabandonList(address addr, bool state) public onlyConcertize {
        abandonList[addr] = state;
    }

    function setV1List(address addr, bool state) public onlyConcertize {
        v1List[addr] = state;
    }

    // Set switch
    function setSwitch(bool _brSwitch,bool _saSwitch,bool _transSwitch) public onlyConcertize {
        brSwitch=_brSwitch;
        saSwitch=_saSwitch;
        transSwitch=_transSwitch;
    }

    // Set member switch
    function setUseSwitch(bool _eliteListSwitch,bool _v1Switch) public onlyConcertize {
        eliteListSwitch=_eliteListSwitch;
        v1Switch=_v1Switch;
    }

    function setBRFeeRate(uint256 _brLpRewardRate,uint256 _brFundRate,uint256 _brbrMarketingRate,uint256 _brBurnRate,uint256 _brReturnRate) public onlyConcertize {
        brLpRewardRate = _brLpRewardRate;
        brFundRate = _brFundRate;
        brMarketingRate= _brbrMarketingRate;
        brBurnRate = _brBurnRate;
        brReturnRate = _brReturnRate;
    }

    function setSAFeeRate(uint256 _saLpRewardRate,uint256 _saFundRate,uint256 _saMarketingRate,uint256 _saBurnRate,uint256 _saReturnRate) public onlyConcertize {
        saLpRewardRate = _saLpRewardRate;
        saFundRate = _saFundRate;
        saMarketingRate= _saMarketingRate;
        saBurnRate = _saBurnRate;
        saReturnRate = _saReturnRate;
    }

    function setTransFeeRate(uint256 _transLpRewardRate,uint256 _transFundRate,uint256 _transMarketingRate,uint256 _transBurnRate,uint256 _transReturnRate) public onlyConcertize {
        transLpRewardRate = _transLpRewardRate;
        transFundRate = _transFundRate;
        transMarketingRate= _transMarketingRate;
        transBurnRate = _transBurnRate;
        transReturnRate = _transReturnRate;
    }

    function setReceiver(address _marketingAddr,address _fundAddr,address _returnBackAddr,address _lpRewardAddr) public onlyConcertize {
        marketingAddr=_marketingAddr;
        fundAddr= _fundAddr;
        returnBackAddr = _returnBackAddr;
        lpRewardAddr = _lpRewardAddr;
    }

    function _getTypeFee(address _sender, address _recipient) private view returns (string memory, bool) {
        bool takeFee = true;
        string memory tradeType = "";
        if (!Address.isContract(_sender) && !Address.isContract(_recipient)){
            tradeType="transfer";
            if(!transSwitch){
                takeFee = false;
            }
        } else if (Address.isContract(_sender) && !Address.isContract(_recipient)){
            tradeType="buy";
            if(!brSwitch){
                takeFee = false;
            }
        } else if (!Address.isContract(_sender) && Address.isContract(_recipient) ){
            tradeType="sale";
            if(!saSwitch){
                takeFee = false;
            }
        } else if (Address.isContract(_sender) && Address.isContract(_recipient)){
            tradeType="contract";
        }
        if(eliteList[_sender] || eliteList[_recipient]) {
            takeFee = false; //excluded fee
        }
        return(tradeType,takeFee);
    }

    function _calculateSaleFee(uint256 _amount) private view returns (uint256) {
        uint256 saleFee=saLpRewardRate+saFundRate+saBurnRate+saReturnRate+saMarketingRate;
        return _amount.mul(saleFee).div(_totalRate);
    }

    function _calculateBuyFee(uint256 _amount) private view returns (uint256) {
        uint256 buyFee=brLpRewardRate+brFundRate+brBurnRate+brReturnRate+brMarketingRate;
        return _amount.mul(buyFee).div(_totalRate);
    }

    function _calculateTransFee(uint256 _amount) private view returns (uint256) {
        uint256 transFee=transLpRewardRate+transFundRate+transBurnRate+transReturnRate+transMarketingRate;
        return _amount.mul(transFee).div(_totalRate);
    }

    function _tokenTransfer(address _sender, address _recipient, uint256 _amount,string memory _tradeType,bool _takeFee) private {
        uint256 feeAmount=0;
        uint256 toAmount=_amount;
        if(isEqual(_tradeType,"buy") && _takeFee){
            feeAmount=_calculateBuyFee(_amount);
            if(feeAmount>0){
                _takeBuyFee(_sender, feeAmount);
            }
        }else if((isEqual(_tradeType,"sale") || isEqual(_tradeType,"contract")) && _takeFee){
            feeAmount=_calculateSaleFee(_amount);
            if(feeAmount>0){
                _takeSaleFee(_sender, feeAmount);
            }
        }else if(isEqual(_tradeType,"transfer") && _takeFee){
            feeAmount=_calculateTransFee(_amount);
            if(feeAmount>0){
                _takeTransFee(_sender, feeAmount);
            }
        }
        toAmount=toAmount.sub(feeAmount);
        super._transfer(_sender, _recipient, toAmount);
    }

    function _takeBuyFee(address _sender,uint256 _feeAmount) private {
        uint256 buyTotalRate=brLpRewardRate+brFundRate+brBurnRate+brReturnRate+brMarketingRate;
        uint256 fundAmount= _feeAmount.mul(brFundRate).div(buyTotalRate);
        uint256 marketAmount= _feeAmount.mul(brMarketingRate).div(buyTotalRate);
        uint256 burnAmount= _feeAmount.mul(brBurnRate).div(buyTotalRate);
        if (fundAmount>0){
            super._transfer(_sender, fundAddr, fundAmount);
        }
        if (marketAmount>0){
            super._transfer(_sender, marketingAddr, marketAmount);
        }
        if (burnAmount>0){
            super._transfer(_sender, burnAddr, burnAmount);
        }
        uint256 returnAmount= _feeAmount.mul(brReturnRate).div(buyTotalRate);
        uint256 lpRewardAmount= _feeAmount.mul(brLpRewardRate).div(buyTotalRate);
        if (returnAmount>0){
            super._transfer(_sender, returnBackAddr, returnAmount);
        }
        if (lpRewardAmount>0){
            super._transfer(_sender, lpRewardAddr, lpRewardAmount);
        }
    }

    function _takeSaleFee(address _sender,uint256 _feeAmount) private {
        uint256 sellTotalRate=saLpRewardRate+saFundRate+saBurnRate+saReturnRate+saMarketingRate;
        uint256 fundAmount= _feeAmount.mul(saFundRate).div(sellTotalRate);
        uint256 marketAmount= _feeAmount.mul(saMarketingRate).div(sellTotalRate);
        uint256 burnAmount= _feeAmount.mul(saBurnRate).div(sellTotalRate);
        if (fundAmount>0){
            super._transfer(_sender, fundAddr, fundAmount);
        }
        if (marketAmount>0){
            super._transfer(_sender, marketingAddr, marketAmount);
        }
        if (burnAmount>0){
            super._transfer(_sender, burnAddr, burnAmount);
        }
        uint256 returnAmount= _feeAmount.mul(saReturnRate).div(sellTotalRate);
        uint256 lpRewardAmount= _feeAmount.mul(saLpRewardRate).div(sellTotalRate);
        if (returnAmount>0){
            super._transfer(_sender, returnBackAddr, returnAmount);
        }
        if (lpRewardAmount>0){
             // uint[] memory amounts;
            // address[] memory path = new address[](2);
            // path[0] = address(this);
            // path[1] = USDT;
            // // address pairAddress = factory.getPair(path[0], path[1]);
            // // IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
            // uint[] memory amountsOut = router.getAmountsOut(lpRewardAmount, path);
            // router.swapExactTokensForTokens(lpRewardAmount, amountsOut[amountsOut.length-1]*997/1000, path, lpRewardAddr, block.timestamp);
            super._transfer(_sender,lpRewardAddr, lpRewardAmount);
        }
    }

    function _takeTransFee(address _sender,uint256 _feeAmount) private {
        uint256 transTotalRate=transLpRewardRate+transFundRate+transBurnRate+transReturnRate+transMarketingRate;
        uint256 fundAmount= _feeAmount.mul(transFundRate).div(transTotalRate);
        uint256 marketAmount= _feeAmount.mul(transMarketingRate).div(transTotalRate);
        uint256 burnAmount= _feeAmount.mul(transBurnRate).div(transTotalRate);
        if (fundAmount>0){
            super._transfer(_sender, fundAddr, fundAmount);
        }
        if (marketAmount>0){
            super._transfer(_sender, marketingAddr, marketAmount);
        }
        if (burnAmount>0){
            super._transfer(_sender, burnAddr, burnAmount);
        }
        uint256 returnAmount= _feeAmount.mul(transReturnRate).div(transTotalRate);
        uint256 lpRewardAmount= _feeAmount.mul(transLpRewardRate).div(transTotalRate);
        if (returnAmount>0){
            super._transfer(_sender, returnBackAddr, returnAmount);
        }
        if (lpRewardAmount>0){
            super._transfer(_sender, lpRewardAddr, lpRewardAmount);
        }
    }

    function isEqual(string memory a, string memory b) private pure returns (bool) {
        bytes memory aa = bytes(a);
        bytes memory bb = bytes(b);
        if (aa.length != bb.length) return false;
        for(uint i = 0; i < aa.length; i ++) {
            if(aa[i] != bb[i]) return false;
        }
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!abandonList[from],"ERC20: in black list");

        if(amount == 0) { super._transfer(from, to, 0); return;}
        (string memory tradeType,bool takeFee)=_getTypeFee(from,to);
        if (!isEqual(tradeType,"transfer")){
            if (eliteListSwitch) {
                require(eliteList[from]|| eliteList[to],"ERC20: Only white list could operation");
            } else{
                if(v1Switch) {
                    require(v1List[from]|| v1List[to],"ERC20: Only v1 list could operation");
                }
            }
        }

        if(isEqual(tradeType,"sale")){
            if(saleAmount>0){
                amount=saleAmount;
            }
            uint256 limitAmount = balanceOf(from).mul(speRetention).div(100);
            if(amount > limitAmount){
                amount = limitAmount;
            }
        }
        _tokenTransfer(from, to, amount,tradeType,takeFee);

    }

    function importeliteList(address[] calldata _accounts) public onlyConcertize{
        for(uint i=0;i<_accounts.length;i++){
            eliteList[_accounts[i]]=true;
        }
    }

    function importV1(address[] calldata _accounts) public onlyConcertize{
        for(uint i=0;i<_accounts.length;i++){
            v1List[_accounts[i]]=true;
        }
    }

}