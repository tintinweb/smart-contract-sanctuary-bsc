/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-07
 */

/**
 *Submitted for verification at BscScan.com on 2022-04-19
 */

/**
 *Submitted for verification at BscScan.com on 2022-04-16
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
        assembly {
            codehash := extcodehash(account)
        }
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
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

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
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

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
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

contract TokenTransfer is Ownable {
    using SafeMath for uint256;

    address public usdtToken;
    address public to;

    constructor(address token_, address to_) {
        usdtToken = token_;
        to = to_;
    }

    receive() external payable {}

    function process() external onlyOwner {
        uint256 nowbanance = IERC20(usdtToken).balanceOf(address(this));
        if (nowbanance > 0) {
            IERC20(usdtToken).transfer(payable(to), nowbanance);
        }
    }
}

contract SWAN is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool private swapping; 

    uint256 public swapTokensAtAmount; 

    uint256 public AmountIncomeFee; 

    uint256 public AmountBackFee; 

    mapping(address => bool) public excludedInviter; 

    uint256 public AmountFunFee; 

    mapping(address => bool) public excludedFee; 

    mapping(address => address) public inviter;

    address public incomeAddr = 0x6cb7A1E2A567291fD3c07Fbc62025117ed1C3548; 

    address public backLpAddr = 0x819a7F764E848DB5B21B9e1B67b28e81666d44A6; 

    address public fundAddr = 0x35a30b7670f8d5eD57017EbBa1311099a147A04f; 

    address public usdtToken = 0x55d398326f99059fF775485246999027B3197955; 

    address public feeAddrDead = 0x000000000000000000000000000000000000dEaD; 

    uint256 public _totalFeeRatio = 10000;

    uint256 public fristInviterFee = 40; 

    uint256 public secondInviteFee = 20; 

    uint256 public threeInviteFee = 10; 

    uint256 public buyIncomeFee = 150; 

    uint256 public buyBackLpFee = 50; 

    uint256 public buyFunFee = 30; 

    uint256 public buyFee =
        buyIncomeFee +
            buyBackLpFee +
            buyFunFee +
            fristInviterFee +
            secondInviteFee +
            threeInviteFee; //3%

    uint256 public sellIncomeFee = 150; 

    uint256 public sellBackLpFee = 50; 

    uint256 public sellFunFee = 30; 

    uint256 public sellFee =
        sellIncomeFee +
            sellBackLpFee +
            sellFunFee +
            fristInviterFee +
            secondInviteFee +
            threeInviteFee; //3%

    TokenTransfer public tokenTransfer;

    address private fromAddress;
    address private toAddress;

    uint256 distributorGas = 200000;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor(address tokenReceiveAddress_)
        payable
        ERC20("Swan Finance Community Token", "SWAN")
    {
        uint256 totalSupply = 29000 * 1e18;

        swapTokensAtAmount = totalSupply.mul(1).div(10**6); // 0.001%;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x6D327b4cc271652D2bB9765A4d079a3258964a35
        );
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(
                address(this),
                0x55d398326f99059fF775485246999027B3197955
            ); 

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        tokenTransfer = new TokenTransfer(usdtToken, address(this));

        excludedFee[address(this)] = true;
        excludedFee[tokenReceiveAddress_] = true;
        excludedFee[address(tokenTransfer)] = true;

        _cast(tokenReceiveAddress_, totalSupply);
    }

    receive() external payable {}

    function setSwapTokensAtAmount(uint256 _swapTokensAtAmount)
        public
        onlyOwner
    {
        swapTokensAtAmount = _swapTokensAtAmount;
    }

    function setIncomeAddr(address _incomeAddr) public onlyOwner {
        incomeAddr = _incomeAddr;
    }

    function setBackLpAddr(address _backLpAddr) public onlyOwner {
        backLpAddr = _backLpAddr;
    }

    function setFundAddr(address _fundAddr) public onlyOwner {
        fundAddr = _fundAddr;
    }

    function setExcludedInviter(address addr, bool state) public onlyOwner {
        excludedInviter[addr] = state;
    }

    function setMyInviter(address _inviterAddress) public {
        require(
            _inviterAddress != address(0),
            "_inviterAddress from the zero address"
        );
        require(inviter[msg.sender] == address(0), "Already bound");
        require(!excludedInviter[_inviterAddress], "address cannot be inviter");
        inviter[msg.sender] = _inviterAddress;
    }

    function setInviter(address a1, address a2) public onlyOwner {
        require(a1 != address(0));
        inviter[a1] = a2;
    }

    function setBuyFee(
        uint256 _buyIncomeFee,
        uint256 _buyBackLpFee,
        uint256 _buyFunFee
    ) public onlyOwner {
        uint256 buyTotal = fristInviterFee +
            secondInviteFee +
            threeInviteFee +
            _buyIncomeFee +
            _buyBackLpFee +
            _buyFunFee;
        require(buyTotal < _totalFeeRatio, "grant than total ratio");
        buyIncomeFee = _buyIncomeFee;
        buyBackLpFee = _buyBackLpFee;
        buyFunFee = _buyFunFee;
        buyFee = buyTotal;
    }

    function setSellFee(
        uint256 _sellIncomeFee,
        uint256 _sellBackLpFee,
        uint256 _sellFunFee
    ) public onlyOwner {
        uint256 sellTotal = fristInviterFee +
            secondInviteFee +
            threeInviteFee +
            _sellIncomeFee +
            _sellBackLpFee +
            _sellFunFee;
        require(sellTotal < _totalFeeRatio, "grant than total ratio");
        sellIncomeFee = _sellIncomeFee;
        sellBackLpFee = _sellBackLpFee;
        sellFunFee = _sellFunFee;
        sellFee = sellTotal;
    }

    function setInviteFee(
        uint256 _fristInviterFee,
        uint256 _secondInviteFee,
        uint256 _threeInviteFee
    ) external onlyOwner {
        uint256 buyTotal = _fristInviterFee +
            _secondInviteFee +
            _threeInviteFee +
            buyIncomeFee +
            buyBackLpFee +
            buyFunFee;
        uint256 sellTotal = _fristInviterFee +
            _secondInviteFee +
            _threeInviteFee +
            sellIncomeFee +
            sellBackLpFee +
            sellFunFee;
        require(buyTotal < _totalFeeRatio, "grant than total ratio");
        require(sellTotal < _totalFeeRatio, "grant than total ratio");
        fristInviterFee = _fristInviterFee;
        secondInviteFee = _secondInviteFee;
        threeInviteFee = _threeInviteFee;
        buyFee = buyTotal;
        sellFee = sellTotal;
    }

    function transferOut(address _tokenAddress) public onlyOwner {
        IERC20(_tokenAddress).transfer(
            msg.sender,
            IERC20(_tokenAddress).balanceOf(address(this))
        );
    }

    function _calculateSaleFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(sellFee).div(_totalFeeRatio);
    }

    function _calculateBuyFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(buyFee).div(_totalFeeRatio);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function setExcludedFee(address[] calldata addr, bool state)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < addr.length; i++) {
            excludedFee[addr[i]] = state;
        }
    }

    function _takeBuyFee(address _sender, uint256 _amount) private {
        uint256 buyIncomeAddrFee = _amount.mul(buyIncomeFee).div(buyFee);
        super._transfer(_sender, address(this), buyIncomeAddrFee);
        AmountIncomeFee += buyIncomeAddrFee;

        uint256 buyBackLpAddrFee = _amount.mul(buyBackLpFee).div(buyFee);
        super._transfer(_sender, address(this), buyBackLpAddrFee);
        AmountBackFee += buyBackLpAddrFee;

        uint256 buyFunAddrFee = _amount.mul(buyFunFee).div(buyFee);
        super._transfer(_sender, address(this), buyFunAddrFee);
        AmountFunFee += buyFunAddrFee;
    }

    function _takeSaleFee(address _sender, uint256 _amount) private {
        uint256 sellIncomeAddrFee = _amount.mul(sellIncomeFee).div(sellFee);
        super._transfer(_sender, address(this), sellIncomeAddrFee);
        AmountIncomeFee += sellIncomeAddrFee;

        uint256 sellBackLpAddrFee = _amount.mul(sellBackLpFee).div(sellFee);
        super._transfer(_sender, address(this), sellBackLpAddrFee);
        AmountBackFee += sellBackLpAddrFee;

        uint256 sellFunAddrFee = _amount.mul(sellFunFee).div(sellFee);
        super._transfer(_sender, address(this), sellFunAddrFee);
        AmountFunFee += sellFunAddrFee;
    }

    function _takeInviterFee(
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
        address cur = _sender;
        if (isContract(_sender)) {
            cur = _recipient;
        }
        for (uint16 i = 0; i < 3; i++) {
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = fundAddr; 
            }
            if (i == 0) {
                uint256 firstFee = _amount.mul(fristInviterFee).div(sellFee);
                super._transfer(_sender, cur, firstFee);
            } else if (i == 1) {
                uint256 secondFee = _amount.mul(secondInviteFee).div(sellFee);
                super._transfer(_sender, cur, secondFee);
            } else {
                uint256 threeFee = _amount.mul(threeInviteFee).div(sellFee);
                super._transfer(_sender, cur, threeFee);
            }
        }
    }

    function updateDistributorGas(uint256 newValue) public onlyOwner {
        require(
            newValue >= 100000 && newValue <= 500000,
            "distributorGas must be between 200,000 and 500,000"
        );
        require(
            newValue != distributorGas,
            "Cannot update distributorGas to same value"
        );
        distributorGas = newValue;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        if (
            canSwap &&
            !swapping &&
            from != uniswapV2Pair &&
            from != address(this)
        ) {
            swapping = true;
            if (AmountIncomeFee > 0) {
                swapLPRewardTokenIncome(AmountIncomeFee);
                AmountIncomeFee = 0;
            }

            if (AmountBackFee > 0) {
                swapAndLiquify(AmountBackFee);
                AmountBackFee = 0;
            }

            if (AmountFunFee > 0) {
                swapLPRewardTokenFundAddr(AmountFunFee);
                AmountFunFee = 0;
            }

            swapping = false;
        }
        (string memory tradeType, bool takeFee) = _getTradeTypeAndTakeFee(
            from,
            to
        );
        if (swapping) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, tradeType, takeFee);


        if (fromAddress == address(0)) fromAddress = from;
        if (toAddress == address(0)) toAddress = to;
        fromAddress = from;
        toAddress = to;
    }

    function _tokenTransfer(
        address _sender,
        address _recipient,
        uint256 _amount,
        string memory _tradeType,
        bool _takeFee
    ) private {
        uint256 feeAmount = 0;
        uint256 toAmount = _amount;
        if (excludedFee[_sender] || excludedFee[_recipient]) {
            _takeFee = false;
        }
        if (isEqual(_tradeType, "buy")) {
            if (_takeFee) {
                feeAmount = _calculateBuyFee(_amount);
                if (feeAmount > 0) {
                    _takeBuyFee(_sender, feeAmount);
                    _takeInviterFee(_sender, _recipient, feeAmount);
                }
            }
        } else if (
            isEqual(_tradeType, "sale") || isEqual(_tradeType, "contract")
        ) {
            if (_takeFee) {
                feeAmount = _calculateSaleFee(_amount);
                if (feeAmount > 0) {
                    _takeSaleFee(_sender, feeAmount);
                    _takeInviterFee(_sender, _recipient, feeAmount);
                }
            }
        }

        toAmount = toAmount.sub(feeAmount);
        super._transfer(_sender, _recipient, toAmount);
    }

    function _getTradeTypeAndTakeFee(address _sender, address _recipient)
        private
        view
        returns (string memory, bool)
    {
        bool takeFee = true;
        string memory tradeType = "";
        if (!Address.isContract(_sender) && !Address.isContract(_recipient)) {
            takeFee = false;
            tradeType = "transfer";
        } else if (
            Address.isContract(_sender) && !Address.isContract(_recipient)
        ) {
            tradeType = "buy";
        } else if (
            !Address.isContract(_sender) && Address.isContract(_recipient)
        ) {
            tradeType = "sale";
        } else if (
            Address.isContract(_sender) && Address.isContract(_recipient)
        ) {
            tradeType = "contract";
        }
        return (tradeType, takeFee);
    }

    function isEqual(string memory a, string memory b)
        private
        pure
        returns (bool)
    {
        bytes memory aa = bytes(a);
        bytes memory bb = bytes(b);
        if (aa.length != bb.length) return false;
        for (uint256 i = 0; i < aa.length; i++) {
            if (aa[i] != bb[i]) return false;
        }
        return true;
    }

    function swapLPRewardTokenIncome(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        //path[1] = uniswapV2Router.WETH();
        path[1] = usdtToken;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(incomeAddr),
            block.timestamp
        );
    }

    function swapLPRewardTokenFundAddr(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        //path[1] = uniswapV2Router.WETH();
        path[1] = usdtToken;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(fundAddr),
            block.timestamp
        );
    }

    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256 initialBalance = IERC20(usdtToken).balanceOf(address(this));

        swapTokensForUsdt(half); 

        tokenTransfer.process();
        uint256 newBalance = IERC20(usdtToken).balanceOf(address(this)).sub(
            initialBalance
        );
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForUsdt(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(tokenTransfer),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(usdtToken).approve(address(uniswapV2Router), ethAmount);
        uniswapV2Router.addLiquidity(
            address(this),
            usdtToken,
            tokenAmount,
            ethAmount,
            0, 
            0, 
            backLpAddr,
            block.timestamp
        );
    }
}