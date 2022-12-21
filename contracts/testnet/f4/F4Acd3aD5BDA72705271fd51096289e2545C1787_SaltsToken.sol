// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier : MIT
pragma solidity >=0.5.0;

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

// SPDX-License-Identifier : MIT
pragma solidity >=0.5.0;

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

// SPDX-License-Identifier : MIT
pragma solidity >=0.6.2;

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

// SPDX-License-Identifier : MIT
pragma solidity >=0.6.2;
import './IUniswapV2Router01.sol';

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

// SPDX-License-Identifier : MIT

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9 ;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// UniSwap and PancakeSwap libs are interchangeable
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract SaltsToken is Context, IERC20, Ownable {
    
    string public name ;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;


    // current supply = totalSupply- burntTokens
    uint256 public currentSupply;

    constructor(string memory _name, string memory _symbol, uint8 _decimals , uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * (10 ** _decimals);
        currentSupply = totalSupply;
        // MAX - MAX % totalSupply
        reflectionTotal = (~uint256(0) - (~uint256(0) % totalSupply));

        //Mint
        reflectionBalances[msg.sender] = reflectionTotal;

        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //  // Create a uniswap pair for this new token
        // uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        //     .createPair(address(this), BUSD);

        // // set the rest of the contract variables
        // uniswapV2Router = _uniswapV2Router;
        
        // exclude owner and this contract from fee.
        excludeAccountFromFee(owner());
        excludeAccountFromFee(address(this));

        // exclude owner, burnAccount, and this contract from receiving rewards.
        excludeAccountFromReward(owner());
        excludeAccountFromReward(burnAccount);
        excludeAccountFromReward(address(this));

        emit Transfer(address(0), msg.sender, totalSupply);

    }

    // ERC-20 standard
    mapping (address => mapping (address => uint256)) private allowances;


    // balances for address that are included in receiving reward
    mapping (address => uint256) private reflectionBalances;

    // balances for address that are excluded from reward
    mapping (address => uint256) private tokenBalances;

    // addresses which are excluded from fee
    mapping (address => bool) private isExcludedFromFee;

    // addresses which are excluded from reward.
     mapping (address => bool) private isExcludedFromReward;
    
    // addresses that are excluded from reward
    address[] private excludedFromReward;

    // Liquidity pool provider router
    IUniswapV2Router02 public uniswapV2Router;

    // This Token and BUSD pair contract address.
    address public uniswapV2Pair;

    address public devWallet;

    // address where burned tokens sent to, No one have access to this address
    address private constant burnAccount = 0x000000000000000000000000000000000000dEaD;

    // percentage of transaction that goes into burning mechanism
    uint8 private taxBurn;
    uint8 private taxBurnDecimals;

    // percentage of transaction redistributed to all holders
    uint8 private taxReward;
    uint8 private taxRewardDecimals;

    // percentage of transaction goes to developers
    uint8 private taxDev;
    uint8 private taxDevDecimals;

    /*
        Tax rate = (_taxXXX / 10**_tax_XXXDecimals) percent.
        If taxBurn is 1 and taxBurnDecimals is 2.
        Tax rate = 0.01%
         && 
        If taxReward is 5 and taxRewardDecimals is 0 then
        Tax rate =  5%
    */
    function calculateTax(uint256 amount, uint8 tax, uint8 taxDecimals) private pure returns (uint256) {
        return amount * tax / (10 ** taxDecimals) / (10 ** 2);
    }

    // Helps distributing fees to all holders respectively.
    uint256 private reflectionTotal;

    // Total amount of tokens rewarded / distributing. 
    uint256 private totalRewarded;

    // Total amount of tokens burnt.
    uint256 private totalBurnt;

    // Total amount of tokens locked in the LP (this token and BUSD pair).
    // uint256 private totalTokensLockedInLiquidity;

    // Total amount of BUSD locked in the LP (this token and BUSD pair).
    // uint256 private totalBUSDLockedInLiquidity;

    // A threshold for swap and Liqify
    // uint256 private minTokensBeforeSwap;

    // boolean values for rewards, burn and autoLiquify
    // bool private inSwapAndLiquify;
    bool private autoSwapAndLiquifyEnabled;
    bool private autoBurnEnabled;
    bool private rewardEnabled;
    bool private devTaxEnabled;

    // function SwapStatus() public view returns(bool) {
    //     return autoSwapAndLiquifyEnabled;
    // }


    // Prevent reentrancy.
    // modifier lockTheSwap {
    //     require(!inSwapAndLiquify, "Currently in swap and liquify.");
    //     inSwapAndLiquify = true;
    //     _;
    //     inSwapAndLiquify = false;
    // }

    // calculated values from given amount
    struct ValuesOfAmount {
        // amount of tokens to transfer
        uint256 amount;
        // tokens charged for burning
        uint256 tBurnFee;
        // tokens charged for reward
        uint256 tRewardFee;
        // tokens charged for developer fee
        uint256 tDevFee;
        // tokens charged for whale tax
        uint256 tWhaleFee;
        // amount of tokens after fee deductions
        uint256 tTransferAmount;
        // reflection of amount
        uint256 rAmount;
        // reflection of burn fee
        uint256 rBurnFee;
        // reflection of reward fee
        uint256 rRewardFee;
        // reflection of dev fee
        uint256 rDevFee;
        // reflection of whale tax 
        uint256 rWhaleFee;
        // reflection of transfer amount
        uint256 rTransferAmount;
    }

    // event Approval(address indexed owner, address indexed spender, uint256 amount, uint256 timeStamp );
    // event Transfer(address indexed from, address indexed to, uint256 amount, uint256 timestamp);
    event Burn (address from, uint256 amount, uint256 timestamp);
    event ExcludeAccountFromReward(address account);
    event IncludeAccountInReward(address account);
    event ExcludeAccountFromFee(address account);
    event IncludeAccountInFee(address account);
    event EnabledAutoBurn();
    event EnabledReward();
    event EnabledDevTax();
    event EnabledAutoSwapAndLiquify();
    event DisabledAutoBurn();
    event DisabledReward();
    event DisabledDevTax();
    event DisabledAutoSwapAndLiquify();
    // event SwapAndLiquify(uint256 tokensSwapped,uint256 ethReceived,uint256 tokensAddedToLiquidity);
    // event MinTokensBeforeSwapUpdated(uint256 previous, uint256 NewminTokensBeforeSwap);
    event TaxBurnUpdated(uint8 previousTax, uint8 previousDecimals, uint8 currentTax, uint8 currentDecimals);
    event TaxRewardUpdated(uint8 previousTax, uint8 previousDecimals, uint8 currentTax, uint8 currentDecimals);
    event TaxDevUpdated(uint8 previousTax, uint8 previousDecimals, uint8 currentTax, uint8 currentDecimals);
    // fallback function , allow the contract to receive ETH
    receive() external payable {}

    // ERC-20 standard
    function balanceOf(address _account) public view returns (uint256) {
        if (isExcludedFromReward[_account]) return tokenBalances[_account];
        return tokenFromReflection(reflectionBalances[_account]);
    }

    // ERC-20 standard 
    function transfer(address _to, uint256 _amount) public returns (bool) {
        _transfer(msg.sender, _to, _amount);
        return true;
    }
    
    // ERC-20 standard 
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount)  public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public  returns(bool) {
        _transfer(sender, recipient, amount);
        require(allowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, allowances[sender][msg.sender] - amount);
        return true;
    }

    function _burn(address account, uint256 amount) internal  {
        require(account != burnAccount, "ERC20: burn from the burn address");

        uint256 accountBalance = balanceOf(account);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        uint256 rAmount = getRAmount(amount);

        // Transfer from account to the burnAccount
        if (isExcludedFromReward[account]) {
            tokenBalances[account] -= amount;
        } 
        reflectionBalances[account] -= rAmount;

        tokenBalances[burnAccount] += amount;
        reflectionBalances[burnAccount] += rAmount;

        currentSupply -= amount;

        totalBurnt += amount;

        emit Burn(account, amount, block.timestamp);
        emit Transfer(account, burnAccount, amount);
    }

    // moves tokens "amount" from sender to recipient 
    function _transfer(address sender, address recipient, uint256 amount) internal  {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        ValuesOfAmount memory values = getValues(amount, isExcludedFromFee[sender]);
        
        if (isExcludedFromReward[sender] && !isExcludedFromReward[recipient]) {
            transferFromExcluded(sender, recipient, values);
        } else if (!isExcludedFromReward[sender] && isExcludedFromReward[recipient]) {
            transferToExcluded(sender, recipient, values);
        } else if (!isExcludedFromReward[sender] && !isExcludedFromReward[recipient]) {
            transferStandard(sender, recipient, values);
        } else if (isExcludedFromReward[sender] && isExcludedFromReward[recipient]) {
            transferBothExcluded(sender, recipient, values);
        } else {
            transferStandard(sender, recipient, values);
        }

        emit Transfer(sender, recipient, values.tTransferAmount);

        if (!isExcludedFromFee[sender]) {
            _afterTokenTransfer(values);
        }

    }

    function _afterTokenTransfer(ValuesOfAmount memory values) internal  {
        // Burn
        if (autoBurnEnabled) {
            tokenBalances[address(this)] += values.tBurnFee;
            reflectionBalances[address(this)] += values.rBurnFee;
            _approve(address(this), msg.sender, values.tBurnFee);
            burnFrom(address(this), values.tBurnFee);
        }   
                
        // Reflect
        if (rewardEnabled) {
            _distributeFee(values.rRewardFee, values.tRewardFee);
        }

        // add dev fee to dev wallet
        tokenBalances[devWallet] += values.tDevFee;
        reflectionBalances[devWallet] += values.rDevFee;
        
    }
    // transfer between two accounts that are included in reward
    function transferStandard(address sender, address recipient, ValuesOfAmount memory values) private { 
        reflectionBalances[sender] = reflectionBalances[sender] - values.rAmount;
        reflectionBalances[recipient] = reflectionBalances[recipient] + values.rTransferAmount;          
    }
    // transfer from an included account to an excluded account 
    function transferToExcluded(address sender, address recipient, ValuesOfAmount memory values) private {
        reflectionBalances[sender] = reflectionBalances[sender] - values.rAmount;
        tokenBalances[recipient] = tokenBalances[recipient] + values.tTransferAmount;
        reflectionBalances[recipient] = reflectionBalances[recipient] + values.rTransferAmount;    
    }

    // transfer from an excluded account to an included account 
    function transferFromExcluded(address sender, address recipient, ValuesOfAmount memory values) private {        
        tokenBalances[sender] = tokenBalances[sender] - values.amount;
        reflectionBalances[sender] = reflectionBalances[sender] - values.rAmount;
        reflectionBalances[recipient] = reflectionBalances[recipient] + values.rTransferAmount;   
    }

    // transfer between two accounts that are both excluded from receiving from reward
    function transferBothExcluded(address sender, address recipient, ValuesOfAmount memory values) private {
        tokenBalances[sender] = tokenBalances[sender] - values.amount;
        reflectionBalances[sender] = reflectionBalances[sender] - values.rAmount;
        tokenBalances[recipient] = tokenBalances[recipient] + values.tTransferAmount;
        reflectionBalances[recipient] = reflectionBalances[recipient] + values.rTransferAmount;        

    }
    // destroys amount of tokens from the caller
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }
    // Destroys "amount" tokens from "account"
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, msg.sender);
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, msg.sender, currentAllowance - amount);
        _burn(account, amount);
    }
    //excludes an account from receiving reward
    function excludeAccountFromReward(address account) internal {
        require(!isExcludedFromReward[account], "Account is already excluded.");

        if(reflectionBalances[account] > 0) {
            tokenBalances[account] = tokenFromReflection(reflectionBalances[account]);
        }
        isExcludedFromReward[account] = true;
        excludedFromReward.push(account);
        
        emit ExcludeAccountFromReward(account);
    }

    // Includes account in receiving rewards
    function includeAccountInReward(address account) internal {
        require(isExcludedFromReward[account], "Account is already included.");

        for (uint256 i = 0; i < excludedFromReward.length; i++) {
            if (excludedFromReward[i] == account) {
                excludedFromReward[i] = excludedFromReward[excludedFromReward.length - 1];
                tokenBalances[account] = 0;
                isExcludedFromReward[account] = false;
                excludedFromReward.pop();
                break;
            }
        }

        emit IncludeAccountInReward(account);
    }

    // Excludes an account from fee
    function excludeAccountFromFee(address account) internal {
        require(!isExcludedFromFee[account], "Account is already excluded.");
        isExcludedFromFee[account] = true;
        emit ExcludeAccountFromFee(account);
    }

    // includes an account in fee
    function includeAccountInFee(address account) internal {
        require(isExcludedFromFee[account], "Account is already included.");
        isExcludedFromFee[account] = false;       
        emit IncludeAccountInFee(account);
    }

    // returns reflected amount of a token
    function reflectionFromToken(uint256 amount, bool deductTransferFee) internal view returns(uint256) {
        require(amount <= totalSupply, "Amount must be less than supply");
        ValuesOfAmount memory values = getValues(amount, deductTransferFee);
        return values.rTransferAmount;
    }

    // used to figure out the balance after reflection
    function tokenFromReflection(uint256 rAmount) internal view returns(uint256) {
        require(rAmount <= reflectionTotal, "Amount must be less than total reflections");
        uint256 currentRate =  getRate();
        return rAmount / currentRate;
    }

    // Swap half of contract's token balance for ETH,
    //  and pair it up with the other half to add to the
    //  liquidity pool.
    // function swapAndLiquify(uint256 contractBalance) private lockTheSwap {
    //     // Split the contract balance into two halves.
    //     uint256 tokensToSwap = contractBalance / 2;
    //     uint256 tokensAddToLiquidity = contractBalance - tokensToSwap;

    //     // Contract's current ETH balance.
    //     uint256 initialBalance = address(this).balance;

    //     // Swap half of the tokens to ETH.
    //     swapTokensForEth(tokensToSwap);

    //     // Figure out the exact amount of tokens received from swapping.
    //     uint256 ethAddToLiquify = address(this).balance - initialBalance;

    //     // Add to the LP of this token and WETH pair (half ETH and half this token).
    //     addLiquidity(ethAddToLiquify, tokensAddToLiquidity);

    //     totalBUSDLockedInLiquidity += address(this).balance - initialBalance;
    //     totalTokensLockedInLiquidity += contractBalance - balanceOf(address(this));

    //     emit SwapAndLiquify(tokensToSwap, ethAddToLiquify, tokensAddToLiquidity);
    // }

    // Swap `amount` tokens for ETH.
    // function swapTokensForEth(uint256 amount) private {
    //     // Generate the uniswap pair path of token -> weth
    //     address[] memory path = new address[](2);
    //     path[0] = address(this);
    //     path[1] = uniswapV2Router.WETH();

    //     _approve(address(this), address(uniswapV2Router), amount);


    //     // Swap tokens to ETH
    //     uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    //         amount, 
    //         0, 
    //         path, 
    //         address(this),  // this contract will receive the eth that were swapped from the token
    //         block.timestamp + 60 * 1000
    //         );
    // }
    // Add `ethAmount` of ETH and `tokenAmount` of tokens to the LP.
    // Depends on the current rate for the pair between this token and WETH,
    // `ethAmount` and `tokenAmount` might not match perfectly. 
    //  Dust(leftover) ETH or token will be refunded to this contract
    // //  (usually very small quantity).
    // function addLiquidity(uint256 ethAmount, uint256 tokenAmount) private {
    //     _approve(address(this), address(uniswapV2Router), tokenAmount);

    //     // Add the ETH and token to LP.
    //     // The LP tokens will be sent to burnAccount.
    //     // No one will have access to them, so the liquidity will be locked forever.
    //     uniswapV2Router.addLiquidityETH{value: ethAmount}(
    //         address(this), 
    //         tokenAmount, 
    //         0, // slippage is unavoidable
    //         0, // slippage is unavoidable
    //         burnAccount, // the LP is sent to burnAccount. 
    //         block.timestamp + 60 * 1000
    //     );
    // }
    //Distribute the `tRewardFee` tokens to all holders that are included in receiving reward.
    //amount received is based on how many token one owns. 
    function _distributeFee(uint256 rRewardFee, uint256 tRewardFee) private {
        // This would decrease rate, thus increase amount reward receive based on one's balance.
        reflectionTotal = reflectionTotal - rRewardFee;
        totalRewarded += tRewardFee;
    }

    // Returns fees and transfer amount in both tokens and reflections.
    function getValues(uint256 amount, bool deductTransferFee) private view returns (ValuesOfAmount memory) {
        ValuesOfAmount memory values;
        values.amount = amount;
        getTValues(values, deductTransferFee);
        getRValues(values, deductTransferFee);
        return values;
    }

    // Adds fees and transfer amount in tokens to `values`. check out ValuesOfAmount struct
    function getTValues(ValuesOfAmount memory values, bool deductTransferFee) view private {       
        if (deductTransferFee) {
            values.tTransferAmount = values.amount;
        } else {
            // calculate fee
            values.tBurnFee = calculateTax(values.amount, taxBurn, taxBurnDecimals);
            values.tRewardFee = calculateTax(values.amount, taxReward, taxRewardDecimals);
            values.tDevFee = calculateTax(values.amount, taxDev, taxDevDecimals);
            uint8 taxWhale_ = taxWhale(values.amount);
            values.tWhaleFee = calculateTax(values.amount, taxWhale_, 0);
            
            // amount after fee
            values.tTransferAmount = values.amount - values.tBurnFee - values.tRewardFee - values.tDevFee - values.tWhaleFee;
        }
        
    }

    //Adds fees and transfer amount in reflection to `values`.
    function getRValues(ValuesOfAmount memory values, bool deductTransferFee) view private {
        uint256 currentRate = getRate();
        values.rAmount = values.amount * currentRate;

        if (deductTransferFee) {
            values.rTransferAmount = values.rAmount;
        } else {
            values.rAmount = values.amount * currentRate;
            values.rBurnFee = values.tBurnFee * currentRate;
            values.rRewardFee = values.tRewardFee * currentRate;
            values.rDevFee = values.tDevFee * currentRate;
            values.rWhaleFee = values.tWhaleFee * currentRate;
            values.rTransferAmount = values.rAmount - values.rBurnFee - values.rRewardFee - values.rDevFee - values.rWhaleFee;
        }
        
    }
    // returns 'amount' in reflection
    function getRAmount(uint256 amount) private view returns (uint256) {
        uint256 currentRate = getRate();
        return amount * currentRate;
    }

    // returns the current reflection rate
    function getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = getCurrentSupply();
        return rSupply / tSupply;
    }

    //Returns the current reflection supply and token supply.
    function getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = reflectionTotal;
        uint256 tSupply = totalSupply;      
        for (uint256 i = 0; i < excludedFromReward.length; i++) {
            if (reflectionBalances[excludedFromReward[i]] > rSupply || tokenBalances[excludedFromReward[i]] > tSupply) return (reflectionTotal, totalSupply);
            rSupply = rSupply - reflectionBalances[excludedFromReward[i]];
            tSupply = tSupply - tokenBalances[excludedFromReward[i]];
        }
        if (rSupply < reflectionTotal / totalSupply) return (reflectionTotal, totalSupply);
        return (rSupply, tSupply);
    }

    ///////// only owner functions ////////

    // sets developer wallet address for receiving fee 
    function setDevWallet(address _devWallet) public onlyOwner {
        devWallet = _devWallet;
    }

    // only owner can withdraw funds to dev wallet 
       /////Fill me in..////

    // Enables the auto burn feature
    function enableAutoBurn(uint8 taxBurn_, uint8 taxBurnDecimals_) public onlyOwner {
        require(!autoBurnEnabled, "Auto burn feature is already enabled.");
        require(taxBurn_ > 0, "Tax must be greater than 0");
        // tax decimals + 2 must be less than token decimals. 
        // because tax rate is in percentage
        require(taxBurnDecimals_ + 2  <= decimals, "Tax decimals must be less than token decimals - 2");
        
        autoBurnEnabled = true;
        setTaxBurn(taxBurn_, taxBurnDecimals_);
        
        emit EnabledAutoBurn();
    }

    // enables the reward feature

    function enableReward(uint8 taxReward_, uint8 taxRewardDecimals_) public onlyOwner {
        require(!rewardEnabled, "Reward feature is already enabled.");
        require(taxReward_ > 0, "Tax must be greater than 0");
        // tax decimals + 2 must be less than token decimals. 
        // because tax rate is in percentage
        require(taxRewardDecimals_ + 2  <= decimals, "Tax decimals must be less than token decimals - 2");

        rewardEnabled = true;
        setTaxReward(taxReward_, taxRewardDecimals_);

        emit EnabledReward();
    }
    // enables devoloper tax 
    function enableDevTax(uint8 taxDev_, uint8 taxDevDecimals_) public onlyOwner  {
        require(!devTaxEnabled, "Reward feature is already enabled.");
        require(taxDev_ > 0, "Tax must be greater than 0");
        // tax decimals + 2 must be less than token decimals. 
        // because tax rate is in percentage
        require(taxDevDecimals_ + 2  <= decimals, "Tax decimals must be less than token decimals - 2");
        
        devTaxEnabled = true;
        setTaxDev(taxDev_, taxDevDecimals_);

        emit EnabledDevTax();
 
    }

    function enableAutoSwapAndLiquify(address routerAddress, address pairAddress) public onlyOwner {
        require(!autoSwapAndLiquifyEnabled, "Auto swap and liquify feature is already enabled.");
        // minTokensBeforeSwap = minTokensBeforeSwap_;
        
        // init Router
        uniswapV2Router = IUniswapV2Router02(routerAddress);
        // uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());

        // if (uniswapV2Pair == address(0)) {
        //     uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
        //         .createPair(address(this), uniswapV2Router.WETH());
        // }
        uniswapV2Router = uniswapV2Router;
        uniswapV2Pair = pairAddress;
        
        // exclude uniswapV2Router from receiving reward.
        excludeAccountFromReward(address(uniswapV2Router));
        // exclude WETH and this Token Pair from receiving reward.
        excludeAccountFromReward(uniswapV2Pair);
        // exclude uniswapV2Router from paying fees.
        excludeAccountFromFee(address(uniswapV2Router));
        // exclude WETH and this Token Pair from paying fees.
        excludeAccountFromFee(uniswapV2Pair);

        //enable 
        autoSwapAndLiquifyEnabled = true;

        emit EnabledAutoSwapAndLiquify();
    }

    // Disables auto burn feature
    function disableAutoBurn() public onlyOwner {
        require(autoBurnEnabled, "Auto burn feature is already disabled.");

        setTaxBurn(0, 0);
        autoBurnEnabled = false;
        
        emit DisabledAutoBurn();
    }

    // Disables the reward feature
    function disableReward() public onlyOwner {
        require(rewardEnabled, "Reward feature is already disabled.");

        setTaxReward(0, 0);
        rewardEnabled = false;
        
        emit DisabledReward();
    }

    // Disable the dev tax
    function disableDevTax() public onlyOwner {
        require(devTaxEnabled, "Dev tax is already disabled");

        setTaxDev(0,0);
        devTaxEnabled = true;

        emit DisabledDevTax();
    }

    // Disables the autoswap and liquidity feature
    function disableAutoSwapAndLiquify() public onlyOwner {
        require(autoSwapAndLiquifyEnabled, "Auto swap and liquify feature is already disabled.");
        autoSwapAndLiquifyEnabled = false;
         
        emit DisabledAutoSwapAndLiquify();
    }

    // updates minTokensBeforeSwap
    // function setMinTokensBeforeSwap(uint256 minTokensBeforeSwap_) public onlyOwner {
    //     require(minTokensBeforeSwap_ < currentSupply, "minTokensBeforeSwap must be higher than current supply");

    //     uint256 previous = minTokensBeforeSwap;
    //     minTokensBeforeSwap = minTokensBeforeSwap_;

    //     emit MinTokensBeforeSwapUpdated(previous, minTokensBeforeSwap);
    // }

    // upadtes burn tax
    function setTaxBurn(uint8 taxBurn_, uint8 taxBurnDecimals_) public onlyOwner {
        require(autoBurnEnabled, "Auto burn feature must be enabled. Try the enableAutoBurn function.");
        require(taxBurn_ + taxReward + taxDev < 100, "Tax fee too high.");

        uint8 previousTax = taxBurn;
        uint8 previousDecimals = taxBurnDecimals;
        taxBurn = taxBurn_;
        taxBurnDecimals = taxBurnDecimals_;

        emit TaxBurnUpdated(previousTax, previousDecimals, taxBurn_, taxBurnDecimals_);
    }

    //updates rewards tax
    function setTaxReward(uint8 taxReward_, uint8 taxRewardDecimals_) public onlyOwner {
        require(rewardEnabled, "Reward feature must be enabled. Try the enableReward function.");
        require(taxBurn + taxReward_ + taxDev < 100, "Tax fee too high.");

        uint8 previousTax = taxReward;
        uint8 previousDecimals = taxRewardDecimals;
        taxReward = taxReward_;
        taxBurnDecimals = taxRewardDecimals_;

        emit TaxRewardUpdated(previousTax, previousDecimals, taxReward_, taxRewardDecimals_);
    }

    // updates developer tax
    function setTaxDev(uint8 taxDev_, uint8 taxDevDecimals_) public onlyOwner {
        require(devTaxEnabled, "devTax feature must be enabled: Try fn enableAutoSwapAndLiquify");
        require(taxBurn + taxReward + taxDev_ < 100, "Tax fee too high.");

        uint8 previousTax = taxDev;
        uint8 previousDecimals = taxDevDecimals;
        taxDev = taxDev_;
        taxDevDecimals = taxDevDecimals_;

        emit TaxDevUpdated(previousTax, previousDecimals, taxDev_, taxDevDecimals_);
    }
        // calculates whale tax depending on the amount
        function taxWhale(uint256 _amount) internal view returns(uint8) {
            uint i = (_amount / currentSupply * 100);
            uint8 whaleTax;

            if (i < 1) {
                whaleTax = 0;
            } else if (i > 1 && i <2) {
                whaleTax = 5;
            } else if (i > 2 && i < 3) {
                whaleTax = 10;
            } else if (i > 3 && i < 4) {
                whaleTax = 15;
            } else if (i > 4 && i < 5) {
                whaleTax = 20;
            } else if (i > 5 && i < 6) {
                whaleTax = 25;
            } else if (i > 6 && i < 7) {
                whaleTax = 30;
            } else if (i > 7 && i < 8) {
                whaleTax = 35;
            } else if (i > 8 && i < 9) {
                whaleTax = 40;
            } else if (i > 9 && i < 10) {
                whaleTax = 45;
            } else if (i >= 10) {
                whaleTax = 50;
            }
            return whaleTax;
        }

}