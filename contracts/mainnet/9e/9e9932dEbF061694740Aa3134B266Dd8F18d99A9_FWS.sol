/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT
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

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
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
    function _msgSender() internal view virtual returns (address ) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
contract usdtReceiver {
    address private usdt = 0x55d398326f99059fF775485246999027B3197955;
    //address private usdt = 0x5c6ECdD74b4f1de6932b64A1eBB78a1aC1F963ac;
    constructor() {
        IBEP20(usdt).approve(msg.sender,~uint256(0));
    }
}
contract FWS is Ownable, IBEP20 {
    using SafeMath for uint256;
    using Address for address;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 internal _totalSupply;
   
    address private pancakeRouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    //address private pancakeRouterAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    //address public usdt = 0x5c6ECdD74b4f1de6932b64A1eBB78a1aC1F963ac;
    address public daoAddr = 0x773051Df45F341C91f3eEE6C41EcBE50E85c498b;
    address public dead = 0x000000000000000000000000000000000000dEaD;

    uint256 public buyBurnFee = 1;
    uint256 public buyDaoFee = 2;
    uint256 public buyLpDividendFee = 0;
    uint256 public buyLpFee = 1;

    uint256 public sellBurnFee = 1;
    uint256 public sellDaoFee = 2;
    uint256 public sellLpDividendFee = 0;
    uint256 public sellLpFee = 1;

    uint256 public numTokensSellToAddToLiquidity = 1 * (1e18);
    uint256 public minAmountToDividend = 1 * (1e18);
    uint256 public  _feeToLP;
    uint256 public lastProcessedIndex = 0;
    uint256 public maxBuyAmount = 666666 * (1e18);
    uint256 public maxSellAmount = 666666 * (1e18);
   
    address public pair;
    address public lastPotentialLPHolder;
    address[] public lpHolders;
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    mapping (address => bool) public _isLPHolderExist;
    mapping (address => bool) public exemptFee;
    IPancakeRouter02 private _router;
    usdtReceiver private _usdtReceiver;

    bool private inSwapAndLiquify;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    constructor() {
        _name = "FWS";
        _symbol = "FWS";
        _decimals = 18;
        _totalSupply = 100000 * (1e18); 
	    _balances[_msgSender()] = _totalSupply;
        exemptFee[_msgSender()] = true;
        exemptFee[address(this)] = true;
        _router = IPancakeRouter02(pancakeRouterAddr);
        pair = IPancakeFactory(_router.factory()).createPair(
            address(usdt),
            address(this)
        );
        _usdtReceiver = new usdtReceiver();
	    emit Transfer(address(0), msg.sender, _totalSupply);  
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
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public override  returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address towner, address spender) public view override returns (uint256) {
        return _allowances[towner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance.sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(amount > _balances[sender].sub(1e14))
            amount = _balances[sender].sub(1e14);
        bool overMinTokenBalance = _feeToLP >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            sender != pair
        ) {
            //add liquidity
            swapAndLiquify(_feeToLP);
        }
        if(!inSwapAndLiquify && sender != pair) {
            uint256 balanceToLPDividend = _balances[address(this)].sub(_feeToLP);
            if(balanceToLPDividend >= minAmountToDividend) {
                dividendToLPHolders(balanceToLPDividend);
            }
        }
        
        uint fee;
        if(!exemptFee[sender] && !exemptFee[recipient]) { 
            uint256 burnFee;
            uint256 daoFee;
            uint256 lpDividendFee;
            uint256 lpFee;
            if(sender == pair) {
                require(amount <= maxBuyAmount, "ERC20: amount exceed max amount");
                if(_totalSupply <= 10000 * (1e18)) {
                    buyLpDividendFee = buyLpDividendFee + buyBurnFee;
                    buyBurnFee = 0;
                }
                burnFee = buyBurnFee;
                daoFee = buyDaoFee;
                lpDividendFee = buyLpDividendFee;
                lpFee = buyLpFee;
            } else if (recipient == pair) {
                require(amount <= maxSellAmount, "ERC20: amount exceed max amount");
                if(_totalSupply <= 10000 * (1e18)) {
                    sellLpDividendFee = sellLpDividendFee + sellBurnFee;
                    sellBurnFee = 0;
                }
                burnFee = sellBurnFee;
                daoFee = sellDaoFee;
                lpDividendFee = sellLpDividendFee;
                lpFee = sellLpFee;
            }
            
            if(burnFee > 0) {
                uint256 feeToBurn = amount.mul(burnFee).div(100);
                _balances[dead] = _balances[dead].add(feeToBurn);
                _totalSupply = _totalSupply.sub(feeToBurn);
                fee = fee.add(feeToBurn);
                emit Transfer(sender, dead, feeToBurn);
            }
            if(daoFee > 0) {
                 uint256 feeToDao = amount.mul(daoFee).div(100);
                _balances[daoAddr] = _balances[daoAddr].add(feeToDao);
                fee = fee.add(feeToDao);
                emit Transfer(sender, daoAddr, feeToDao);
            }
            if(lpDividendFee > 0) {
                uint256 feeToLpDividend = amount.mul(lpDividendFee).div(100);
                _balances[address(this)] = _balances[address(this)].add(feeToLpDividend);
                fee = fee.add(feeToLpDividend);
                emit Transfer(sender, address(this), feeToLpDividend);
            }
            if(lpFee > 0) {
                uint256 feeToLp = amount.mul(lpFee).div(100);
                _balances[address(this)] = _balances[address(this)].add(feeToLp);
                _feeToLP = _feeToLP.add(feeToLp);
                fee = fee.add(feeToLp);
                emit Transfer(sender, address(this), feeToLp);
            }
        }

        if(lastPotentialLPHolder != address(0) && !_isLPHolderExist[lastPotentialLPHolder]) {
            uint256 lpAmount = IBEP20(pair).balanceOf(lastPotentialLPHolder);
            if(lpAmount > 0) {
                lpHolders.push(lastPotentialLPHolder);
                _isLPHolderExist[lastPotentialLPHolder] = true;
            }
        }
        if(recipient == pair && sender != address(this) ) {
            lastPotentialLPHolder = sender;
        }
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount.sub(fee));
        emit Transfer(sender, recipient, amount.sub(fee));
    }

    function dividendToLPHolders(uint256 rewards) private {
        if(rewards == 0) return;
        uint256 numberOfTokenHolders = lpHolders.length;	
        if(numberOfTokenHolders == 0) return;
        IBEP20 pairContract = IBEP20(pair);
        uint256 gas = 300000;
        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 totalLPAmount = pairContract.totalSupply() - 1e3;

        while(gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if(_lastProcessedIndex >= lpHolders.length) {
                _lastProcessedIndex = 0;
            }

            address account = lpHolders[_lastProcessedIndex];
            uint256 LPAmount = pairContract.balanceOf(account); 
            if(LPAmount > 0) {
                uint256 reward = rewards.mul(LPAmount).div(totalLPAmount);
                if(reward == 0) continue;
                if(_balances[address(this)].sub(_feeToLP) < reward) break;
                _balances[address(this)] = _balances[address(this)].sub(reward); 
                _balances[account] = _balances[account].add(reward);
                emit Transfer(address(this), account, reward); 
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if(gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;
    }

    function swapAndLiquify(uint256 feeToLP) private lockTheSwap {
        // split the balance into halves
        uint256 half = feeToLP.div(2);
        uint256 otherHalf = feeToLP.sub(half);

        // capture the contract's current USDT balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = IBEP20(usdt).balanceOf(address(_usdtReceiver));

        // swap tokens for USDT
        swapTokensForUSDT(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = (IBEP20(usdt).balanceOf(address(_usdtReceiver))).sub(initialBalance);
        IBEP20(usdt).transferFrom(address(_usdtReceiver),address(this), newBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        _feeToLP = 0;
    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(_router), tokenAmount);

        // make the swap
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of USDT
            path,
            address(_usdtReceiver),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 USDTAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(_router), tokenAmount);
        IBEP20(usdt).approve(address(_router),USDTAmount);
        // add the liquidity
        _router.addLiquidity(
            address(this),
            usdt,
            tokenAmount,
            USDTAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            daoAddr,
            block.timestamp
        );
    }

    function setNumTokensSellToAddToLiquidity(uint256 value) external onlyOwner { 
        numTokensSellToAddToLiquidity = value;
    }

    function setMinAmountToDividend(uint256 value) external onlyOwner { 
        minAmountToDividend = value;
    }

    function setDaoAddr(address value) external onlyOwner { 
        daoAddr = value;
    }

    function setSellBurnFee(uint256 value) external onlyOwner { 
        sellBurnFee = value;
    }

    function setSellDaoFee(uint256 value) external onlyOwner { 
        sellDaoFee = value;
    }

    function setSellLpDividendFee(uint256 value) external onlyOwner { 
        sellLpDividendFee = value;
    }

    function setSellLpFee(uint256 value) external onlyOwner { 
        sellLpFee = value;
    }

    function setBuyBurnFee(uint256 value) external onlyOwner { 
        buyBurnFee = value;
    }

    function setBuyDaoFee(uint256 value) external onlyOwner { 
        buyDaoFee = value;
    }

    function setBuyLpDividendFee(uint256 value) external onlyOwner { 
        buyLpDividendFee = value;
    }

    function setBuyLpFee(uint256 value) external onlyOwner { 
        buyLpFee = value;
    }

    function setMaxSellAmount(uint256 value) external onlyOwner { 
        maxSellAmount = value;
    }

    function setMaxBuyAmount(uint256 value) external onlyOwner { 
        maxBuyAmount = value;
    }

    function setExemptFee(address[] memory account, bool flag) external onlyOwner {
        require(account.length > 0, "no account");
        for(uint256 i = 0; i < account.length; i++) {
            exemptFee[account[i]] = flag;
        }
    }

    function claimLeftUSDT() external onlyOwner {
        uint256 left = IBEP20(usdt).balanceOf(address(_usdtReceiver));
        IBEP20(usdt).transferFrom(address(_usdtReceiver), owner(), left);
    }

    function claimLeftToken(address token) external onlyOwner {
        if(token == address(this)) {
            uint256 amount = _balances[address(this)];
            _balances[address(this)] = 0;
            _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        } else {
            uint256 left = IBEP20(token).balanceOf(address(this));
            IBEP20(token).transfer(_msgSender(), left);
        }   
    }
}