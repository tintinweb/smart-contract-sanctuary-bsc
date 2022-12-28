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
// import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
// import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
// import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract SaltsToken is Context, IERC20, Ownable {
    
    string public name = "Salts Token" ;
    string public symbol = "SALTZ";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * (10 ** 18);


    // current supply = totalSupply- burntTokens
    uint256 public currentSupply;

    
    uint8 a = 1;
    uint8 b = 2;
    uint8 c = a / b;
    mapping(uint8 => uint8) public commision; // for referals
 

    constructor() {
        currentSupply = totalSupply;
        // MAX - MAX % totalSupply
        reflectionTotal = (~uint256(0) - (~uint256(0) % totalSupply));

        //Mint
        reflectionBalances[msg.sender] = reflectionTotal;
        
        // exclude owner and this contract from fee.
        excludeAccountFromFee(owner());
        excludeAccountFromFee(address(this));

        // exclude owner, burnAccount, and this contract from receiving rewards.
        excludeAccountFromReward(owner());
        excludeAccountFromReward(burnAccount);
        excludeAccountFromReward(address(this));

        commision[0] = 5;
        commision[1] = 3;
        commision[2] = 2;
        commision[3] = 1;
        commision[4] = c;

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

    // The multisig dev wallet address
    address public devWallet;

    // address where burned tokens sent to, No one have access to this address
    address private constant burnAccount = 0x000000000000000000000000000000000000dEaD;
    
    uint8 totalTax = 10;
    uint8 totalTaxDecimals = 0;

    // percentage of totalTax(after referrals distributed , if any) that goes into burning mechanism
    uint8 private taxBurn = 40;
    uint8 private taxBurnDecimals = 0;

    // percentage of transaction redistributed to all holders
    uint8 private taxReward = 35;
    uint8 private taxRewardDecimals = 0;

    // percentage of transaction goes to developers
    uint8 private taxDev = 25;
    uint8 private taxDevDecimals = 0;

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
    uint256 public totalRewarded;

    // Total amount of tokens burnt.
    uint256 public totalBurnt;

    // boolean values for rewards, burn and autoLiquify
    // bool private inSwapAndLiquify;
    bool private autoSwapAndLiquifyEnabled;
    // bool private autoBurnEnabled;
    // bool private rewardEnabled;
    // bool private devTaxEnabled;

    // calculated values from given amount
    struct ValuesOfAmount {
        // amount of tokens to transfer
        uint256 amount;
        // tokens charged for ref tax
        uint256 tReferalFee;
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

        uint256 tTotalTax;
        // reflection of amount
        uint256 rAmount;
        // reflection of referal fee
        uint256 rReferalFee;
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

        uint256 rTotalTax;

    }

    // event Approval(address indexed owner, address indexed spender, uint256 amount, uint256 timeStamp );
    // event Transfer(address indexed from, address indexed to, uint256 amount, uint256 timestamp);
    event Burn (address from, uint256 amount, uint256 timestamp);
    event ExcludeAccountFromReward(address account);
    event IncludeAccountInReward(address account);
    event ExcludeAccountFromFee(address account);
    event IncludeAccountInFee(address account);
    // event EnabledAutoBurn();
    // event EnabledReward();
    // event EnabledDevTax();
    // event EnabledAutoSwapAndLiquify();
    // event DisabledAutoBurn();
    // event DisabledReward();
    // event DisabledDevTax();
    // event DisabledAutoSwapAndLiquify();
    // event SwapAndLiquify(uint256 tokensSwapped,uint256 ethReceived,uint256 tokensAddedToLiquidity);
    // event MinTokensBeforeSwapUpdated(uint256 previous, uint256 NewminTokensBeforeSwap);
    event TaxBurnUpdated(uint8 previousTax, uint8 previousDecimals, uint8 currentTax, uint8 currentDecimals);
    event TaxRewardUpdated(uint8 previousTax, uint8 previousDecimals, uint8 currentTax, uint8 currentDecimals);
    event TaxDevUpdated(uint8 previousTax, uint8 previousDecimals, uint8 currentTax, uint8 currentDecimals);
    // fallback function , allow the contract to receive ETH
   
    receive() external payable {
        revert();
    }

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
        // TODO: refTax Bool
        ValuesOfAmount memory values = getValues(amount, isExcludedFromFee[sender], sender);
        
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
            // referals 
            distributeRefAmount(msg.sender);

            // Burn
            tokenBalances[address(this)] += values.tBurnFee;
            reflectionBalances[address(this)] += values.rBurnFee;
            _approve(address(this), msg.sender, values.tBurnFee);
            burnFrom(address(this), values.tBurnFee);  
                
            // Reflect
            _distributeFee(values.rRewardFee, values.tRewardFee);

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
    function reflectionFromToken(uint256 amount, bool deductTransferFee, address user) internal  returns(uint256) {
        require(amount <= totalSupply, "Amount must be less than supply");
        ValuesOfAmount memory values = getValues(amount, deductTransferFee, user);
        return values.rTransferAmount;
    }

    // used to figure out the balance after reflection
    function tokenFromReflection(uint256 rAmount) internal view returns(uint256) {
        require(rAmount <= reflectionTotal, "Amount must be less than total reflections");
        uint256 currentRate =  getRate();
        return rAmount / currentRate;
    }

    //Distribute the `tRewardFee` tokens to all holders that are included in receiving reward.
    //amount received is based on how many token one owns. 
    function _distributeFee(uint256 rRewardFee, uint256 tRewardFee) private {
        // This would decrease rate, thus increase amount reward receive based on one's balance.
        // reflectionTotal = reflectionTotal - rRewardFee;

        tokenBalances[rewardWallet] += tRewardFee;
        reflectionBalances[rewardWallet] += rRewardFee;
        totalRewarded += tRewardFee;
    }


    // Returns fees and transfer amount in both tokens and reflections.
    function getValues(uint256 amount, bool deductTransferFee, address user) private  returns (ValuesOfAmount memory) {
        ValuesOfAmount memory values;
        values.amount = amount;
        getTValues(values, deductTransferFee, user);
        getRValues(values, deductTransferFee);
        return values;
    }


    // TODO : remove it also
    function setTax(uint8 tax, uint8 taxDecimals) public onlyOwner {
        totalTax = tax;
        totalTaxDecimals = taxDecimals;
    }

    // mapping used in distributing referals;
    mapping(address => uint256) internal refBalances;
   

    // Adds fees and transfer amount in tokens to `values`. check out ValuesOfAmount struct
    function getTValues(ValuesOfAmount memory values, bool deductTransferFee, address _user)  private {       
        if (deductTransferFee) {
            values.tTransferAmount = values.amount;
        } else {
            // calculate fee
            uint8 taxWhale_ = taxWhale(values.amount);
            values.tWhaleFee = calculateTax(values.amount, taxWhale_, 0);
            uint256 tempTotalTax = calculateTax((values.amount - values.tWhaleFee), totalTax, totalTaxDecimals);
            values.tTotalTax = tempTotalTax + values.tWhaleFee;
            values.tTransferAmount = values.amount - values.tTotalTax;
            uint256 totalTax_ = values.tTotalTax;
            if(hadRefTax[_user] = true) {
                USER storage user = users[_user];
                for(uint8 i = 0 ; i < user.parents.length; i++) {
                    uint256 Amount = calculateTax(totalTax_, commision[i], 0);
                    refBalances[user.parents[i]] = Amount;
                    values.tReferalFee += Amount;
                    totalTax_ -= Amount;
                }

            }
            values.tBurnFee = calculateTax(totalTax_, taxBurn, taxBurnDecimals);
            values.tRewardFee = calculateTax(totalTax_, taxReward, taxRewardDecimals);
            values.tDevFee = calculateTax(totalTax_, taxDev, taxDevDecimals);
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
            values.rTotalTax = values.tTotalTax * currentRate;
            values.rBurnFee = values.tBurnFee * currentRate;
            values.rRewardFee = values.tRewardFee * currentRate;
            values.rDevFee = values.tDevFee * currentRate;
            values.rWhaleFee = values.tWhaleFee * currentRate;
            values.rReferalFee = values.tReferalFee * currentRate;
            values.rTransferAmount = values.rAmount - values.rTotalTax ;
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
        // restrict dev wallet from receiving rewards
        excludeAccountFromFee(devWallet);
        excludeAccountFromReward(devWallet);

    }

    address public rewardWallet;

    function setRewardsWallet(address _rewardWallet) public onlyOwner {
        rewardWallet = _rewardWallet;
        excludeAccountFromFee(rewardWallet);
        excludeAccountFromReward(rewardWallet);
    }

    // only owner can withdraw funds to dev wallet 
       /////Fill me in..////





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
        // excludeAccountFromReward(address(uniswapV2Router));
        // // exclude WETH and this Token Pair from receiving reward.
        // excludeAccountFromReward(uniswapV2Pair);
        // // exclude uniswapV2Router from paying fees.
        // excludeAccountFromFee(address(uniswapV2Router));
        // // exclude WETH and this Token Pair from paying fees.
        // excludeAccountFromFee(uniswapV2Pair);

        //enable 
        autoSwapAndLiquifyEnabled = true;

        // emit EnabledAutoSwapAndLiquify();
    }

   


    // Disables the autoswap and liquidity feature
    function disableAutoSwapAndLiquify() public onlyOwner {
        require(autoSwapAndLiquifyEnabled, "Auto swap and liquify feature is already disabled.");
        autoSwapAndLiquifyEnabled = false;
         
        // emit DisabledAutoSwapAndLiquify();
    }


    // upadtes burn tax
    function setTaxBurn(uint8 taxBurn_, uint8 taxBurnDecimals_) public onlyOwner {
        require(taxBurn_ + taxReward + taxDev <= 100, "Tax fee too high.");

        uint8 previousTax = taxBurn;
        uint8 previousDecimals = taxBurnDecimals;
        taxBurn = taxBurn_;
        taxBurnDecimals = taxBurnDecimals_;

        emit TaxBurnUpdated(previousTax, previousDecimals, taxBurn_, taxBurnDecimals_);
    }

    //updates rewards tax
    function setTaxReward(uint8 taxReward_, uint8 taxRewardDecimals_) public onlyOwner {
        require(taxBurn + taxReward_ + taxDev <= 100, "Tax fee too high.");

        uint8 previousTax = taxReward;
        uint8 previousDecimals = taxRewardDecimals;
        taxReward = taxReward_;
        taxBurnDecimals = taxRewardDecimals_;

        emit TaxRewardUpdated(previousTax, previousDecimals, taxReward_, taxRewardDecimals_);
    }

    // updates developer tax
    function setTaxDev(uint8 taxDev_, uint8 taxDevDecimals_) public onlyOwner {
        require(taxBurn + taxReward + taxDev_ <= 100, "Tax fee too high.");

        uint8 previousTax = taxDev;
        uint8 previousDecimals = taxDevDecimals;
        taxDev = taxDev_;
        taxDevDecimals = taxDevDecimals_;

        emit TaxDevUpdated(previousTax, previousDecimals, taxDev_, taxDevDecimals_);
    }
        // calculates whale tax depending on the amount
        function taxWhale(uint256 _amount) internal view returns(uint8) {
            uint i = (_amount * 100) / currentSupply ;
            uint8 whaleTax;
            if (i < 1) {
                whaleTax = 0;
            } else if (i >= 1 && i < 2) {
                whaleTax = 5;
            } else if (i >= 2 && i < 3) {
                whaleTax = 10;
            } else if (i >= 3 && i < 4) {
                whaleTax = 15;
            } else if (i >= 4 && i < 5) {
                whaleTax = 20;
            } else if (i >= 5 && i < 6) {
                whaleTax = 25;
            } else if (i >= 6 && i < 7) {
                whaleTax = 30;
            } else if (i >= 7 && i < 8) {
                whaleTax = 35;
            } else if (i >= 8 && i < 9) {
                whaleTax = 40;
            } else if (i >= 9 && i < 10) {
                whaleTax = 45;
            } else if (i >= 10) {
                whaleTax = 50;
            }
            return whaleTax;
        }


        event UserRegistered(
            address indexed user,
            address indexed referer,
            uint256 timestamp
        );

        event RefTx(
            uint8 refIndex, 
            address referer, 
            uint256 amount
        );

        struct USER {
            address user;
            address[] parents;
        }

        mapping(address => USER) public users;

        // function getRef(address user, uint8 i) internal view returns(address){
        //     return parents[user][i];
        // }

        mapping(address => bool) public isRegistered;
        mapping(address => bool) private hadRefTax;

        function registerUser(address _user, address _referer) public {
        require(isRegistered[_user] == false);
        // the default value for a user regestering without ref is 0x00
        
        if (_referer == address(0)) {
            _register(_user, _referer);
            hadRefTax[_user] = false;
        } else {
            _register(_user, _referer);    
             hadRefTax[_user] = true;                   
            USER storage ref = users[_referer];
            for (uint8 i = 1; i <= ref.parents.length ; i++){
                users[_user].parents.push(ref.parents[i-1]);
            }
        }
        emit UserRegistered(_user, _referer, block.timestamp);
    }



    function _register(address _user, address _referer) internal {
        USER storage user = users[_user];
        user.user = _user;
        user.parents.push(_referer);
        isRegistered[_user] = true;
    }
            
    function distributeRefAmount(address user) internal {
           for (uint8 i =0 ; i < users[user].parents.length ; i++) {
            uint256 tAmount =  refBalances[users[user].parents[i]];
             uint256 currentRate = getRate();
             uint256 rAmount = tAmount * currentRate;
             tokenBalances[users[user].parents[i]] += tAmount;
             reflectionBalances[users[user].parents[i]] += rAmount;
             emit RefTx(i,users[user].parents[i], tAmount );
           }
        }      
}