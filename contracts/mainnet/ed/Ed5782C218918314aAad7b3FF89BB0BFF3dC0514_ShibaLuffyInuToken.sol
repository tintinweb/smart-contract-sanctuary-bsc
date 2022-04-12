/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 *   @author "Shiba Luffy Inu"
 *   @title "The safe and friendly community-driven token $SLUFFY."
 *   @dev Main website: https://shibaluffyinu.org/
 *
 *      ,~"""~.
 *   ,-/       \-.
 * .' '`._____.'` `.
 * `-._         _,-'
 *     `--...--'
 *
 *   @dev SLUFFY transaction will be charged an 8% fee, including:
 *   @dev     💱 4% Reflection, spread across all holders except for team's wallet.
 *   @dev     💱 2% Team funding, team's wallet will have no initial fund and has to earn them accordingly to SLUFFY success.
 *   @dev     💱 1% Burn, making SLUFFY a deflationary token since it becomes scarcer overtime. -> price goes up.
 *   @dev     💱 1% Re-add back to pool for liquidity.
 *
 *   @dev SLUFFY 100% total supply is spreaded as following:
 *   @dev     💵 95% Handled by DxSale for IDO.
 *   @dev     💵 5% Marketing wallet initial fund.
 *
 *   @dev Reasons why SLUFFY is a safe and stable investment
 *   @dev     🛡️ Contract ownership is renounced after IDO.
 *   @dev     🛡️ Has a maximum transaction limit to avoid whale.
 *   @dev     🛡️ Our team initial allocation is relatively small compare to the overall supply.
 *   @dev     🛡️ Liquidity is locked for 3 years after IDO.
 *   @dev     🛡️ Fee is immutable since it's a constant value.
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library Address {
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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
    function renounceOwnership() public virtual onlyOwner {
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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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

contract ShibaLuffyInuToken is Context, Ownable, IERC20 {
    using Address for address;
    modifier validClaim() {
        require(!_marketingFundClaimed, "MarketingFund: Fail to claim");
        _;
        _marketingFundClaimed = true;
    }
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    //list of addresses excluded from reward
    mapping(address => bool) private _isExcludedFromReward;
    address[] private _excluded;

    //list of addresses excluded from obligation to pay fee
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromMaxTx;

    address private _teamWallet = 0xfC67a0b410B640d244d3B3a2788f147720F6C899;
    address private _marketingWallet =
        0x384082EfdB280BEd3BcE4Ba59cA9d6885527CE8D;
    bool private _marketingFundClaimed = false;
    address public constant DEAD_ADDRESS =
        0x000000000000000000000000000000000000dEaD;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000 * 1e9 * 10**8;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    //Fees cannot be adjusted
    uint8 public constant _totalFee = 8;
    uint8 public constant _taxFee = 4;
    uint8 public constant _teamFee = 2;
    uint8 public constant _burnFee = 1;
    uint8 public constant _liquidityFee = 1;
    bool private _taxEnabled = false;
    bool private _previousTaxEnabled = false;
    // default to not restrict max tx amount until after IDO
    bool private _antiWhale = false;

    string private _name = "Shiba Luffy Inu";
    string private _symbol = "SLUFFY";
    uint8 private _decimals = 8;

    bool private inSwapAndLiquify;
    bool private _swapAndLiquifyEnabled;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    uint256 public constant AMMLimit = 10**8;
    uint256 public constant MaxTxAmount = _tTotal / (10**2);

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    constructor() {
        _rOwned[_msgSender()] = _rTotal;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[DEAD_ADDRESS] = true;
        _isExcludedFromFee[_marketingWallet] = true;
        _isExcludedFromFee[_teamWallet] = true;

        _excludeAccount(owner());
        _excludeAccount(address(this));
        _excludeAccount(DEAD_ADDRESS);
        _excludeAccount(_marketingWallet);
        _excludeAccount(_teamWallet);

        // exclude from max tx for easier management
        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxTx[address(this)] = true;
        _isExcludedFromMaxTx[DEAD_ADDRESS] = true;
        _isExcludedFromMaxTx[address(0)] = true;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        _approve(
            address(this),
            0x10ED43C718714eb63d5aA57B78B54704E256024E,
            type(uint256).max
        );

        uniswapV2Router = _uniswapV2Router;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }

    function circulatingSupply() external view returns (uint256 _cSupply) {
        require(_tTotal >= balanceOf(DEAD_ADDRESS));
        unchecked {
            _cSupply = _tTotal - balanceOf(DEAD_ADDRESS);
        }
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromReward[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function teamWallet() external view returns (address) {
        return _teamWallet;
    }

    function marketingWallet() external view returns (address) {
        return _marketingWallet;
    }

    function taxEnabled() external view returns (bool) {
        return _taxEnabled;
    }

    function antiWhaleEnabled() external view returns (bool) {
        return _antiWhale;
    }

    function swapAndLiquifyEnabled() external view returns (bool) {
        return _swapAndLiquifyEnabled;
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        address sender = _msgSender();
        _transfer(sender, recipient, amount);
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
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _spendAllowance(sender, _msgSender(), amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Enable tax after IDO
     * Cannot be modified after ownership renounced
     */
    function changeTaxStatus(bool status) external onlyOwner {
        _taxEnabled = status;
    }

    /**
     * @dev Enable anti-whale after IDO
     * Cannot be modified after ownership renounced
     */
    function changeAntiWhaleStatus(bool status) external onlyOwner {
        _antiWhale = status;
    }

    /**
     * @dev Allow marketing wallet to claim initial fund of 5% of total supply after IDO
     */
    function marketingClaimInitialShare() external validClaim onlyOwner {
        _tokenTransfer(owner(), _marketingWallet, (_tTotal * 5) / 100, false);
    }

    /**
     * @dev Is used once after DxSale IDO is created to exclude DxSale presale contract from fee
     * @dev Ownership will be renounced so there will be no extra fee-evader created in the future
     */
    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function isExcludedFromReward(address account)
        external
        view
        returns (bool)
    {
        return _isExcludedFromReward[account];
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

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
        return rAmount / currentRate;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        _swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function changeTeamWallet(address wallet) external {
        address sender = _msgSender();
        require(
            sender == _teamWallet,
            "Permission: Address does not have permission"
        );
        require(
            wallet != address(0),
            "Invalid Address: Address 0 cannot be a team wallet"
        );
        // Move all token from current team wallet to the new one
        _isExcludedFromFee[wallet] = true;
        _excludeAccount(wallet);
        _internalTransfer(_teamWallet, wallet, _tOwned[_teamWallet]);
        _teamWallet = wallet;
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

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = _allowances[owner][spender];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _removeFee() private {
        _previousTaxEnabled = _taxEnabled;
        _taxEnabled = false;
    }

    function _restoreFee() private {
        _taxEnabled = _previousTaxEnabled;
    }

    function _ensureMaxTxAmount(
        address from,
        address to,
        uint256 amount
    ) private view {
        if (
            _isExcludedFromMaxTx[from] == false &&
            _isExcludedFromMaxTx[to] == false &&
            _antiWhale
        ) {
            require(
                amount <= MaxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );
        }
    }

    /**
     * @dev Use this when transaction is taxless
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        _ensureMaxTxAmount(sender, recipient, amount);

        //indicates if fee should be deducted from transfer
        bool feeEnabled = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            feeEnabled = false;
        }
        _tokenTransfer(sender, recipient, amount, feeEnabled);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool feeEnabled
    ) private {
        if (!feeEnabled) _removeFee();
        if (
            _isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]
        ) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (
            !_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]
        ) {
            _transferToExcluded(sender, recipient, amount);
        } else if (
            !_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]
        ) {
            _transferStandard(sender, recipient, amount);
        } else if (
            _isExcludedFromReward[sender] && _isExcludedFromReward[recipient]
        ) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!feeEnabled) _restoreFee();
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        uint256 half = tAmount / 2;
        uint256 otherHalf = tAmount - half;
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half);
        // ensure the BNB token used to add to liquidity doesnot includes contract's BNB
        assert(address(this).balance >= initialBalance);
        uint256 newBalance;
        unchecked {
            newBalance = address(this).balance - initialBalance;
        }
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp + 360
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // add the liquid
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this), //lock liquidity in this contract to avoid any abuse
            block.timestamp + 360
        );
    }

    function includeAccount(address account) external {
        require(_isExcludedFromReward[account], "Account is already included");
        _isExcludedFromReward[account] = false;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _excluded.pop();
                break;
            }
        }
    }

    function _excludeAccount(address account) private {
        require(!_isExcludedFromReward[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        if (_excluded.length >= 5) _excluded.pop();
        _isExcludedFromReward[account] = true;
        _excluded.push(account);
    }

    function _reflectFee(uint256 rTotalFee, uint256 tTotalFee) private {
        uint256 rFee = (rTotalFee * _taxFee) / _totalFee;
        uint256 tFee = (tTotalFee * _taxFee) / _totalFee;
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rTotalFee,
            uint256 tTransferAmount,
            uint256 tTotalFee
        )
    {
        (tTransferAmount, tTotalFee) = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        rAmount = tAmount * currentRate;
        rTotalFee = tTotalFee * currentRate;
        rTransferAmount = rAmount - rTotalFee;
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (uint256 tTransferAmount, uint256 tTotalFee)
    {
        tTotalFee = calculateTotalFee(tAmount);
        tTransferAmount = tAmount - tTotalFee;
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeTeamFee(uint256 rTotalFee, uint256 tTotalFee) private {
        uint256 rTeam = (rTotalFee * _teamFee) / _totalFee;
        uint256 tTeam = (tTotalFee * _teamFee) / _totalFee;
        _rOwned[_teamWallet] += rTeam;
        _tOwned[_teamWallet] += tTeam;
    }

    function _takeBurn(uint256 rTotalFee, uint256 tTotalFee) private {
        uint256 rBurn = (rTotalFee * _burnFee) / _totalFee;
        uint256 tBurn = (tTotalFee * _burnFee) / _totalFee;
        _rOwned[DEAD_ADDRESS] += rBurn;
        _tOwned[DEAD_ADDRESS] += tBurn;
    }

    function _takeLiquidity(uint256 rTotalFee, uint256 tTotalFee) private {
        uint256 rLiquidity = (rTotalFee * _liquidityFee) / _totalFee;
        uint256 tLiquidity = (tTotalFee * _liquidityFee) / _totalFee;
        _rOwned[address(this)] += rLiquidity;
        _tOwned[address(this)] += tLiquidity;
    }

    function _internalTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        require(
            _tOwned[sender] >= tAmount,
            "ERC20: decreased sender's balance below zero"
        );
        unchecked {
            _tOwned[sender] = _tOwned[sender] - tAmount;
            _rOwned[recipient] = _rOwned[sender];
        }
        _tOwned[recipient] = _tOwned[recipient] + tAmount;
        emit Transfer(sender, recipient, tAmount);
    }

    function _checkExceededAMMLimit(address sender) private {
        if (!inSwapAndLiquify && _swapAndLiquifyEnabled) {
            uint256 contractTokenBalance = balanceOf(address(this));

            bool overMaxTokenBalance = contractTokenBalance >= AMMLimit;
            if (overMaxTokenBalance && sender != uniswapV2Pair) {
                swapAndLiquify(contractTokenBalance);
            }
        }
    }

    function calculateTotalFee(uint256 _amount) private view returns (uint256) {
        uint8 _fee = _totalFee;
        if (!_taxEnabled) _fee = 0;
        return (_amount * _fee) / (10**2);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rTotalFee,
            uint256 tTransferAmount,
            uint256 tTotalFee
        ) = _getValues(tAmount);
        require(
            _rOwned[sender] >= rAmount,
            "ERC20: decreased sender's balance below zero"
        );
        unchecked {
            _rOwned[sender] = _rOwned[sender] - rAmount;
        }
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        if (_taxEnabled) {
            _takeTeamFee(rTotalFee, tTotalFee);
            _takeBurn(rTotalFee, tTotalFee);
            _takeLiquidity(rTotalFee, tTotalFee);
            _reflectFee(rTotalFee, tTotalFee);
            _checkExceededAMMLimit(sender);
        }
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
            uint256 rTotalFee,
            uint256 tTransferAmount,
            uint256 tTotalFee
        ) = _getValues(tAmount);
        require(
            _rOwned[sender] >= rAmount,
            "ERC20: decreased sender's balance below zero"
        );
        unchecked {
            _rOwned[sender] = _rOwned[sender] - rAmount;
        }
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        if (_taxEnabled) {
            _takeTeamFee(rTotalFee, tTotalFee);
            _takeBurn(rTotalFee, tTotalFee);
            _takeLiquidity(rTotalFee, tTotalFee);
            _reflectFee(rTotalFee, tTotalFee);
            _checkExceededAMMLimit(sender);
        }
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
            uint256 rTotalFee,
            uint256 tTransferAmount,
            uint256 tTotalFee
        ) = _getValues(tAmount);
        require(
            _rOwned[sender] >= rAmount && _tOwned[sender] >= tAmount,
            "ERC20: decreased sender's balance below zero"
        );
        unchecked {
            _tOwned[sender] = _tOwned[sender] - tAmount;
            _rOwned[sender] = _rOwned[sender] - rAmount;
        }
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        if (_taxEnabled) {
            _takeTeamFee(rTotalFee, tTotalFee);
            _takeBurn(rTotalFee, tTotalFee);
            _takeLiquidity(rTotalFee, tTotalFee);
            _reflectFee(rTotalFee, tTotalFee);
            _checkExceededAMMLimit(sender);
        }
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
            uint256 rTotalFee,
            uint256 tTransferAmount,
            uint256 tTotalFee
        ) = _getValues(tAmount);
        require(
            _rOwned[sender] >= rAmount && _tOwned[sender] >= tAmount,
            "ERC20: decreased sender's balance below zero"
        );
        unchecked {
            _tOwned[sender] = _tOwned[sender] - tAmount;
            _rOwned[sender] = _rOwned[sender] - rAmount;
        }
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        if (_taxEnabled) {
            _takeTeamFee(rTotalFee, tTotalFee);
            _takeBurn(rTotalFee, tTotalFee);
            _takeLiquidity(rTotalFee, tTotalFee);
            _reflectFee(rTotalFee, tTotalFee);
            _checkExceededAMMLimit(sender);
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }
}