/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
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
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage)
        private
        pure
    {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
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

abstract contract Ownable is Context {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
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

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
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
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

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

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

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

    function allowance(address owner, address spender)
        external
        view
        returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
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

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
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
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountETH,
            uint liquidity
        );

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
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
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

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);
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
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
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

contract KingCorgiChain is ERC20, Ownable {
    using Address for address payable;
    using Address for address;

    uint256 public buybackFeeOnBuy;
    uint256 public buybackFeeOnSell;

    uint256 public marketingFeeOnBuy;
    uint256 public marketingFeeOnSell;

    uint256 public charityFeeOnBuy;
    uint256 public charityFeeOnSell;

    uint256 public devFeeOnBuy;
    uint256 public devFeeOnSell;

    uint256 public wtwFee;

    uint public bnbValueForBuyBurn;
    uint public accumulatedBuybackBNB;

    uint256 private _totalFeesOnBuy;
    uint256 private _totalFeesOnSell;

    address public marketingWallet;
    address public devWallet;
    address public charityWallet;
    address public busdAddress;

    bool public walletToWalletTransferWithoutFee;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    bool private swapping;
    uint256 public swapTokensAtAmount;

    mapping(address => bool) private _isExcludedFromFees;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event UpdateBuyFees(
        uint256 buybackFeeOnBuy,
        uint256 marketingFeeOnBuy,
        uint256 devFeeOnBuy,
        uint256 charityFeeOnBuy
    );
    event UpdateSellFees(
        uint256 buybackFeeOnSell,
        uint256 marketingFeeOnSell,
        uint256 devFeeOnSell,
        uint256 charityFeeOnSell
    );
    event UpdateWalletToWalletFee(uint256 wtwFee);

    event MarketingWalletChanged(address marketingWallet);
    event DevWalletChanged(address devWallet);
    event CharityWalletChanged(address charityWallet);

    event BuyBack(uint256 buybackAmount);
    event SendCharityWallet(uint256 charityBusd);
    event SendMarketingWallet(uint256 marketingBusd);
    event SendDevWallet(uint256 devBusd);

    constructor() ERC20("KingCorgi Chain", "KCC") {
        address newOwner = 0x1aBF9A2E66906F13ff2830bc18478405abC68eE0;
        transferOwnership(newOwner);

        address router;
        if (block.chainid == 56) {
            router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // BSC Pancake Mainnet Router
        } else if (block.chainid == 97) {
            router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // BSC Pancake Testnet Router
        } else if (block.chainid == 1 || block.chainid == 5) {
            router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // ETH Uniswap Mainnet % Testnet
        } else {
            revert();
        }

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        buybackFeeOnBuy = 2;
        buybackFeeOnSell = 2;

        marketingFeeOnBuy = 2;
        marketingFeeOnSell = 2;

        accumulatedBuybackBNB = 0;

        devFeeOnBuy = 1;
        devFeeOnSell = 1;

        charityFeeOnBuy = 1;
        charityFeeOnSell = 1;

        wtwFee = 6;

        _totalFeesOnBuy =
            buybackFeeOnBuy +
            marketingFeeOnBuy +
            devFeeOnBuy +
            charityFeeOnBuy;
        _totalFeesOnSell =
            buybackFeeOnSell +
            marketingFeeOnSell +
            devFeeOnSell +
            charityFeeOnSell;

        marketingWallet = 0x29224fC97BcB2Df0ceCB56BC1E7b579708fFa3ea;
        devWallet = 0x43BCc53C9C6F034Cf6F3d3E736e0230133C626D4;
        charityWallet = 0xB828b4B5dE5ca744688d6F7fe27310Ac621aEa0b;
        busdAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

        walletToWalletTransferWithoutFee = true;

        maxWalletLimitEnabled = true;
        maxWalletAmount = 1e7 * (10**decimals());

        maxTransactionLimitEnabled = true;
        maxTransactionAmountBuy = 1e6 * (10**decimals());
        maxTransactionAmountSell = 1e6 * (10**decimals());

        _isExcludedFromMaxTxLimit[owner()] = true;
        _isExcludedFromMaxTxLimit[address(0)] = true;
        _isExcludedFromMaxTxLimit[address(this)] = true;
        _isExcludedFromMaxTxLimit[DEAD] = true;

        _isExcludedFromMaxWalletLimit[owner()] = true;
        _isExcludedFromMaxWalletLimit[address(0)] = true;
        _isExcludedFromMaxWalletLimit[address(this)] = true;
        _isExcludedFromMaxWalletLimit[DEAD] = true;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;

        _mint(owner(), 1e9 * (10**18));
        swapTokensAtAmount = totalSupply() / 5000;
    }

    receive() external payable {}

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim native tokens");
        if (
            token == address(0x0) && address(this).balance >= bnbValueForBuyBurn
        ) {
            uint256 bnbBalance = address(this).balance - bnbValueForBuyBurn;
            payable(msg.sender).transfer(bnbBalance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    //=======FeeManagement=======//
    function excludeFromFees(address account, bool excluded)
        external
        onlyOwner
    {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function updateBuyFees(
        uint256 _buybackFeeOnBuy,
        uint256 _marketingFeeOnBuy,
        uint256 _devFeeOnBuy,
        uint256 _charityFeeOnBuy
    ) external onlyOwner {
        require(
            _buybackFeeOnBuy +
                _marketingFeeOnBuy +
                _devFeeOnBuy +
                _charityFeeOnBuy <=
                10,
            "Fees must be less than 11%"
        );
        buybackFeeOnBuy = _buybackFeeOnBuy;
        marketingFeeOnBuy = _marketingFeeOnBuy;
        devFeeOnBuy = _devFeeOnBuy;
        charityFeeOnBuy = _charityFeeOnBuy;
        _totalFeesOnBuy =
            buybackFeeOnBuy +
            marketingFeeOnBuy +
            devFeeOnBuy +
            charityFeeOnBuy;
        emit UpdateBuyFees(
            buybackFeeOnBuy,
            marketingFeeOnBuy,
            devFeeOnBuy,
            charityFeeOnBuy
        );
    }

    function updateSellFees(
        uint256 _buybackFeeOnSell,
        uint256 _marketingFeeOnSell,
        uint256 _devFeeOnSell,
        uint256 _charityFeeOnSell
    ) external onlyOwner {
        require(
            _buybackFeeOnSell +
                _marketingFeeOnSell +
                _devFeeOnSell +
                _charityFeeOnSell <=
                10,
            "Fees must be less than 11%"
        );
        buybackFeeOnSell = _buybackFeeOnSell;
        marketingFeeOnSell = _marketingFeeOnSell;
        devFeeOnSell = _devFeeOnSell;
        charityFeeOnSell = _charityFeeOnSell;
        _totalFeesOnSell =
            buybackFeeOnSell +
            marketingFeeOnSell +
            devFeeOnSell +
            charityFeeOnSell;
        emit UpdateSellFees(
            buybackFeeOnSell,
            marketingFeeOnSell,
            devFeeOnSell,
            charityFeeOnSell
        );
    }

    function updateWalletToWalletFee(uint256 _walletToWalletFee)
        external
        onlyOwner
    {
        require(_walletToWalletFee <= 10, "Fees must be less than 11%");
        wtwFee = _walletToWalletFee;
        emit UpdateWalletToWalletFee(wtwFee);
    }

    function enableWalletToWalletTransferWithoutFee(bool enable)
        external
        onlyOwner
    {
        require(
            walletToWalletTransferWithoutFee != enable,
            "Wallet to wallet transfer without fee is already set to that value"
        );
        walletToWalletTransferWithoutFee = enable;
    }

    function changeMarketingWallet(address _marketingWallet)
        external
        onlyOwner
    {
        require(
            _marketingWallet != marketingWallet,
            "Marketing wallet is already that address"
        );
        marketingWallet = _marketingWallet;
        emit MarketingWalletChanged(marketingWallet);
    }

    function changeDevWallet(address _devWallet) external onlyOwner {
        require(_devWallet != devWallet, "Dev wallet is already that address");
        devWallet = _devWallet;
        emit DevWalletChanged(devWallet);
    }

    function changeCharityWallet(address _charityWallet) external onlyOwner {
        require(
            _charityWallet != charityWallet,
            "Charity wallet is already that address"
        );
        charityWallet = _charityWallet;
        emit CharityWalletChanged(charityWallet);
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

        if (maxTransactionLimitEnabled) {
            if (
                (from == uniswapV2Pair || to == uniswapV2Pair) &&
                _isExcludedFromMaxTxLimit[from] == false &&
                _isExcludedFromMaxTxLimit[to] == false
            ) {
                if (from == uniswapV2Pair) {
                    require(
                        amount <= maxTransactionAmountBuy,
                        "AntiWhale: Transfer amount exceeds the maxTransactionAmount"
                    );
                } else {
                    require(
                        amount <= maxTransactionAmountSell,
                        "AntiWhale: Transfer amount exceeds the maxTransactionAmount"
                    );
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            !swapping &&
            to == uniswapV2Pair &&
            _totalFeesOnBuy + _totalFeesOnSell > 0
        ) {
            swapping = true;

            uint256 totalFee = _totalFeesOnBuy + _totalFeesOnSell;
            uint256 marketingShare = marketingFeeOnBuy + marketingFeeOnSell;
            uint256 devShare = devFeeOnBuy + devFeeOnSell;
            uint256 charityShare = charityFeeOnBuy + charityFeeOnSell;
            uint256 buybackShare = buybackFeeOnBuy + buybackFeeOnSell;

            uint256 initialBalance = address(this).balance;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();

            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractTokenBalance,
                0,
                path,
                address(this),
                block.timestamp
            );

            uint256 newBalance = address(this).balance - initialBalance;

            uint256 busdShare = marketingShare + devShare + charityShare;
            

            if (busdShare > 0) {
                uint256 bnbToUsd = (newBalance * busdShare) / totalFee;
                path = new address[](2);
                path[0] = uniswapV2Router.WETH();
                path[1] = busdAddress;
                
                uint256 initialBusdBalance = IERC20(busdAddress).balanceOf(address(this));

                uniswapV2Router
                    .swapExactETHForTokensSupportingFeeOnTransferTokens{
                    value: bnbToUsd
                }(0, path, address(this), block.timestamp);

                uint256 currentBalance = IERC20(busdAddress).balanceOf(address(this));
                currentBalance -= initialBusdBalance;
                

                if (marketingShare > 0) {
                    uint256 marketingBusd = (currentBalance * marketingShare) / bnbToUsd;
                    IERC20(busdAddress).transfer(
                        marketingWallet,
                        marketingBusd
                    );
                    emit SendMarketingWallet(marketingBusd);
                }

                if (charityShare > 0) {
                    uint256 charityBusd = (currentBalance * charityShare) / bnbToUsd;
                    IERC20(busdAddress).transfer(
                        charityWallet,
                        charityBusd);
                    emit SendCharityWallet(charityBusd);
                }
                if (devShare > 0) {
                    uint256 devBusd = (currentBalance * devShare) / bnbToUsd;
                    IERC20(busdAddress).transfer(
                        devWallet,
                        devBusd);
                    emit SendDevWallet(devBusd);
                }
            }

            if (buybackShare > 0) {
                uint256 buybackBNB = (newBalance * buybackShare) / totalFee;
                accumulatedBuybackBNB += buybackBNB;
                if (accumulatedBuybackBNB > bnbValueForBuyBurn) {
                    if (address(this).balance >= accumulatedBuybackBNB) {
                        buyBack(accumulatedBuybackBNB);
                    } else {
                        buyBack(address(this).balance);
                    }
                    accumulatedBuybackBNB = 0;
                }
            }


            swapping = false;
        }

        bool takeFee = !swapping;
        uint256 _totalFees;
        if (
            (_isExcludedFromFees[from] || _isExcludedFromFees[to]) ||
            (walletToWalletTransferWithoutFee &&
                from != uniswapV2Pair &&
                to != uniswapV2Pair)
        ) {
            takeFee = false;
        } else if (from == uniswapV2Pair) {
            _totalFees = _totalFeesOnBuy;
        } else if (to == uniswapV2Pair) {
            _totalFees = _totalFeesOnSell;
        } else {
            _totalFees = wtwFee;
        }

        if (takeFee && _totalFees > 0) {
            uint256 fees = (amount * _totalFees) / 100;
            amount = amount - fees;
            super._transfer(from, address(this), fees);
        }

        if (maxWalletLimitEnabled) {
            if (
                _isExcludedFromMaxWalletLimit[from] == false &&
                _isExcludedFromMaxWalletLimit[to] == false &&
                to != uniswapV2Pair
            ) {
                uint balance = balanceOf(to);
                require(
                    balance + amount <= maxWalletAmount,
                    "MaxWallet: Recipient exceeds the maxWalletAmount"
                );
            }
        }

        super._transfer(from, to, amount);
    }

    //=======Swap=======//
    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        require(
            newAmount > totalSupply() / 100000,
            "SwapTokensAtAmount must be greater than 0.001% of total supply"
        );
        swapTokensAtAmount = newAmount;
    }

    function startBuyback(uint valBNB) public payable onlyOwner {
        require(msg.value >= valBNB, "BNB invalid");
        buyBack(msg.value);
    }

    function setBNBValueForBuyBurn(uint value) public onlyOwner {
        bnbValueForBuyBurn = value;
        // require(value >= 1, "'BNBValueForBuyBurn' must be greater than 1);
        // bnbValueForBuyBurn = value * (10**17);
    }

    function buyBack(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, DEAD, block.timestamp);
    }

    //------------------MaxWallet------------------//
    mapping(address => bool) private _isExcludedFromMaxWalletLimit;
    bool public maxWalletLimitEnabled;
    uint256 public maxWalletAmount;

    event ExcludedFromMaxWalletLimit(address indexed account, bool isExcluded);
    event MaxWalletLimitStateChanged(bool maxWalletLimit);
    event MaxWalletLimitAmountChanged(uint256 maxWalletAmount);

    function setEnableMaxWalletLimit(bool enable) external onlyOwner {
        require(
            enable != maxWalletLimitEnabled,
            "Max wallet limit is already set to that state"
        );
        maxWalletLimitEnabled = enable;
        emit MaxWalletLimitStateChanged(maxWalletLimitEnabled);
    }

    function setMaxWalletAmount(uint256 _maxWalletAmount) external onlyOwner {
        require(
            _maxWalletAmount >= (totalSupply()) / ((10**decimals()) / 100),
            "Max wallet percentage cannot be lower than 1%"
        );
        maxWalletAmount = _maxWalletAmount * (10**decimals());
        emit MaxWalletLimitAmountChanged(maxWalletAmount);
    }

    function setExcludeFromMaxWallet(address account, bool exclude)
        external
        onlyOwner
    {
        require(
            _isExcludedFromMaxWalletLimit[account] != exclude,
            "Account is already set to that state"
        );
        _isExcludedFromMaxWalletLimit[account] = exclude;
        emit ExcludedFromMaxWalletLimit(account, exclude);
    }

    function isExcludedFromMaxWalletLimit(address account)
        public
        view
        returns (bool)
    {
        return _isExcludedFromMaxWalletLimit[account];
    }

    //------------------MaxTransaction------------------//
    mapping(address => bool) private _isExcludedFromMaxTxLimit;
    bool public maxTransactionLimitEnabled;
    uint256 public maxTransactionAmountBuy;
    uint256 public maxTransactionAmountSell;

    event ExcludedFromMaxTransactionLimit(
        address indexed account,
        bool isExcluded
    );
    event MaxTransactionLimitStateChanged(bool maxTransactionLimit);
    event MaxTransactionLimitAmountChanged(
        uint256 maxTransactionAmountBuy,
        uint256 maxTransactionAmountSell
    );

    function setEnableMaxTransactionLimit(bool enable) external onlyOwner {
        require(
            enable != maxTransactionLimitEnabled,
            "Max transaction limit is already set to that state"
        );
        maxTransactionLimitEnabled = enable;
        emit MaxTransactionLimitStateChanged(maxTransactionLimitEnabled);
    }

    function setMaxTransactionAmounts(
        uint256 _maxTransactionAmountBuy,
        uint256 _maxTransactionAmountSell
    ) external onlyOwner {
        require(
            _maxTransactionAmountBuy >=
                (totalSupply() / (10**decimals())) / 1000 &&
                _maxTransactionAmountSell >=
                (totalSupply() / (10**decimals())) / 1000,
            "Max Transaction limis cannot be lower than 0.1% of total supply"
        );
        maxTransactionAmountBuy = _maxTransactionAmountBuy * (10**decimals());
        maxTransactionAmountSell = _maxTransactionAmountSell * (10**decimals());
        emit MaxTransactionLimitAmountChanged(
            maxTransactionAmountBuy,
            maxTransactionAmountSell
        );
    }

    function setExcludeFromMaxTransactionLimit(address account, bool exclude)
        external
        onlyOwner
    {
        require(
            _isExcludedFromMaxTxLimit[account] != exclude,
            "Account is already set to that state"
        );
        _isExcludedFromMaxTxLimit[account] = exclude;
        emit ExcludedFromMaxTransactionLimit(account, exclude);
    }

    function isExcludedFromMaxTransaction(address account)
        public
        view
        returns (bool)
    {
        return _isExcludedFromMaxTxLimit[account];
    }
}