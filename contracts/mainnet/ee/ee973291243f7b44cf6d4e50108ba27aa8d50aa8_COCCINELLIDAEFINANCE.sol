/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

/*
 *    
 *
 * 
 *      COCCINELLIDAE FINANCE
 *   Total Supply: 1,000,000,000
 *
 *          Our Profiles
 *
 *  https://coccinellidae.finance/
 *  https://t.me/FCoccinellidae
 *  https://twitter.com/FCoccinellidae
 *
 *
 *
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal virtual view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = _msgSender(); //change owner address here
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
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

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakePair {
    function sync() external;
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

contract COCCINELLIDAEFINANCE is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    IPancakeRouter02 public immutable pancakeRouter;
    address public immutable pancakePair;

    address[] public _excluded;

    address public feeWallet;

    string private constant _name = "COCCINELLIDAE FINANCE";
    string private constant _symbol = "CDFT";

    uint8 private constant _decimals = 9;

    bool private inSwapAndLiquify;
    bool public presaleEnded = false; // should be true
    bool public isFeeActive = false; // should be true
    bool public swapAndLiquifyEnabled = false; // should be true

    uint256 private constant MAX = ~uint256(0);
    uint256 internal constant _tokenTotal = 1000000000e9; // 1 Billion
    uint256 internal _reflectionTotal = (MAX - (MAX % _tokenTotal));
    uint256 public minTokensBeforeSwap = 50000000e9;
    uint256 public startTimestamp = 0;
    uint256 public _tokenFeeTotal;

    uint256 public constant _feeDecimal = 2; // Do not change.
    uint256 public constant maxWalletToken = 200000000e9; // Max Wallet: 200 Million 
    uint256 public constant maxTxAmount = 100000000e9; // Max Transaction: 100 Million 
    uint256 public constant buyFee = 100; //buyFee fee 1%
    uint256 public constant buyLiquidityFee = 200; //buyLiquidityFee fee 2%
    uint256 public constant sellFee = 100; //sellFee fee 1%
    uint256 public constant sellLiquidityFee = 200; //sellLiquidityFee fee 2%
    
    uint256 public feeTotal;
    uint256 public liquidityFeeTotal;

    mapping(address => uint256) public excludedIndexes;
    mapping(address => bool) internal _isExcluded;
    mapping(address => bool) internal _isTaxless;
    mapping(address => uint256) internal _reflectionBalance;
    mapping(address => uint256) internal _tokenBalance;
    mapping(address => mapping(address => uint256)) internal _allowances;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        address _feeReceiver
    ) {
        feeWallet = _feeReceiver;

        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pancakePair = IPancakeFactory(_pancakeRouter.factory())
            .createPair(address(this), _pancakeRouter.WETH());
        pancakeRouter = _pancakeRouter;

        _isTaxless[owner()] = true;
        _isTaxless[address(this)] = true;
        _reflectionBalance[owner()] = _reflectionTotal;

        // exlcude pair address from tax rewards
        _isExcluded[address(pancakePair)] = true;
        excludedIndexes[address(pancakePair)] = _excluded.length;
        _excluded.push(address(pancakePair));


        emit Transfer(address(0), owner(), _tokenTotal);
    }

    event SwapAndLiquify(uint256 tokensSwapped,uint256 ethReceived, uint256 tokensIntoLiqudity, uint256 contractTokenBalance);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event UpdateWallet(address prevWallet, address newWallet, uint256 timestamp);

    receive() external payable {}

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override pure returns (uint256) {
        return _tokenTotal;
    }

    function balanceOf(address account) public override view returns (uint256) {
        if (_isExcluded[account]) return _tokenBalance[account];
        return tokenFromReflection(_reflectionBalance[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        virtual
        returns (bool)
    {
       _transfer(_msgSender(),recipient,amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
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
    ) public override virtual returns (bool) {
        _transfer(sender,recipient,amount);
               
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub( amount,"BEP20: transfer amount exceeds allowance"));
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
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

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
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if (
            sender != owner() &&
            recipient != owner() &&
            recipient != address(1) &&
            recipient != pancakePair
        ) {
            require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            uint256 contractBalanceRecepient = balanceOf(recipient);
            require(
                contractBalanceRecepient.add(amount) <= maxWalletToken,
                "Exceeds maximum wallet token amount (100,000,000)"
            );
        }
        
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        if (contractTokenBalance >= maxTxAmount) {
            contractTokenBalance = maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >= minTokensBeforeSwap;

        if (!inSwapAndLiquify && overMinTokenBalance && sender != pancakePair && swapAndLiquifyEnabled) {
            contractTokenBalance = minTokensBeforeSwap;
            swapAndLiquify(contractTokenBalance);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = isFeeActive;

        //if any account belongs to _isTaxless account then remove the fee
        //if sender is the pair address then remove the fee
        //if presale has not end then remove the fee
        //if fee is not active then remove the fee
        if (
            _isTaxless[sender] ||
            _isTaxless[recipient] ||
            sender == pancakePair ||
            !presaleEnded ||
            !isFeeActive
        ) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(sender, recipient, amount, takeFee);

    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount, takeFee);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount, takeFee);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount, takeFee);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount, takeFee);
        } else {
            _transferStandard(sender, recipient, amount, takeFee);
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 rate = _getReflectionRate();
        uint256 transferAmount = tAmount;

        if(takeFee && sender == pancakePair) {
            transferAmount = collectBuyFee(sender,tAmount,rate);
        } else if(takeFee && recipient == pancakePair) {
            transferAmount = collectSellFee(sender,tAmount,rate);
        }

        _reflectionBalance[sender] = _reflectionBalance[sender].sub(tAmount.mul(rate));
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount.mul(rate));
        
        emit Transfer(sender, recipient, transferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 rate = _getReflectionRate();
        uint256 transferAmount = tAmount;

        if(takeFee && sender == pancakePair) {
            transferAmount = collectBuyFee(sender,tAmount,rate);
        } else if(takeFee && recipient == pancakePair) {
            transferAmount = collectSellFee(sender,tAmount,rate);
        }

        _reflectionBalance[sender] = _reflectionBalance[sender].sub(tAmount.mul(rate));
        _tokenBalance[recipient] = _tokenBalance[recipient].add(transferAmount);
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount.mul(rate));
        
        emit Transfer(sender, recipient, transferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 rate = _getReflectionRate();
        uint256 transferAmount = tAmount;

        if(takeFee && sender == pancakePair) {
            transferAmount = collectBuyFee(sender,tAmount,rate);
        } else if(takeFee && recipient == pancakePair) {
            transferAmount = collectSellFee(sender,tAmount,rate);
        }

        _tokenBalance[sender] = _tokenBalance[sender].sub(tAmount);
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(tAmount.mul(rate));
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount.mul(rate));
        
        emit Transfer(sender, recipient, transferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 rate = _getReflectionRate();
        uint256 transferAmount = tAmount;

        if(takeFee && sender == pancakePair) {
            transferAmount = collectBuyFee(sender,tAmount,rate);
        } else if(takeFee && recipient == pancakePair) {
            transferAmount = collectSellFee(sender,tAmount,rate);
        }

        _tokenBalance[sender] = _tokenBalance[sender].sub(tAmount);
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(tAmount.mul(rate));
        _tokenBalance[recipient] = _tokenBalance[recipient].add(transferAmount);
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount.mul(rate));
        
        emit Transfer(sender, recipient, transferAmount);
    }

    function collectBuyFee(address account, uint256 amount, uint256 rate) private returns (uint256) {
        uint256 transferAmount = amount;
        uint256 multiplier = _getAntiDumpMultiplier();

        if(buyFee > 0) {
            uint256 fee = amount.mul(buyFee).mul(multiplier).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(fee);
            _reflectionBalance[feeWallet] = _reflectionBalance[feeWallet].add(fee.mul(rate));
            if(_isExcluded[feeWallet]){
                _tokenBalance[feeWallet] = _tokenBalance[feeWallet].add(fee);
            }
            _reflectionTotal = _reflectionTotal.sub(fee.mul(rate));
            _tokenFeeTotal = _tokenFeeTotal.add(fee);
            feeTotal = feeTotal.add(fee);
            emit Transfer(account, feeWallet , fee);
        }

        if(buyLiquidityFee > 0) {
            uint256 liquidityFee = amount.mul(buyLiquidityFee).mul(multiplier).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(liquidityFee);
            _reflectionBalance[address(this)] = _reflectionBalance[address(this)].add(liquidityFee.mul(rate));
            if(_isExcluded[address(this)]){
                _tokenBalance[address(this)] = _tokenBalance[address(this)].add(liquidityFee);
            }
            _reflectionTotal = _reflectionTotal.sub(liquidityFee.mul(rate));
            _tokenFeeTotal = _tokenFeeTotal.add(liquidityFee);
            liquidityFeeTotal = liquidityFeeTotal.add(liquidityFee);
            emit Transfer(account,address(this),liquidityFee);
        }
        
        return transferAmount;
    }
    
    function collectSellFee(address account, uint256 amount, uint256 rate) private returns (uint256) {
        uint256 transferAmount = amount;
        uint256 multiplier = _getAntiDumpMultiplier();
        
        if(sellFee > 0) {
            uint256 fee = amount.mul(sellFee).mul(multiplier).div(10**(_feeDecimal + 2));
            transferAmount=transferAmount.sub(fee);
            _reflectionBalance[feeWallet] = _reflectionBalance[feeWallet].add(fee.mul(rate));
            if(_isExcluded[feeWallet]){
                _tokenBalance[feeWallet] = _tokenBalance[feeWallet].add(fee);
            }
            _reflectionTotal = _reflectionTotal.sub(fee.mul(rate));
            _tokenFeeTotal = _tokenFeeTotal.add(fee);
            feeTotal = feeTotal.add(fee);
            emit Transfer(account, feeWallet , fee);
        }

        if(sellLiquidityFee > 0) {
            uint256 liquidityFee = amount.mul(sellLiquidityFee).mul(multiplier).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(liquidityFee);
            _reflectionBalance[address(this)] = _reflectionBalance[address(this)].add(liquidityFee.mul(rate));
            if(_isExcluded[address(this)]){
                _tokenBalance[address(this)] = _tokenBalance[address(this)].add(liquidityFee);
            }
            _reflectionTotal = _reflectionTotal.sub(liquidityFee.mul(rate));
            _tokenFeeTotal = _tokenFeeTotal.add(liquidityFee);
            liquidityFeeTotal = liquidityFeeTotal.add(liquidityFee);
            emit Transfer(account,address(this),liquidityFee);
        }
        
        return transferAmount;
    }

    function _getAntiDumpMultiplier() private view returns (uint256) {
        uint256 timePassed = block.timestamp - startTimestamp;
        if (timePassed < 12 hours) {
            return (5);
        }
        if (timePassed < 24 hours) {
            return (4);
        }
        if (timePassed < 72 hours) {
            return (3);
        }
        if (timePassed < 168 hours) {
            return (2);
        }
        return (1);
    }

    function _getReflectionRate() public view returns (uint256) {
        uint256 reflectionSupply = _reflectionTotal;
        uint256 tokenSupply = _tokenTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _reflectionBalance[_excluded[i]] > reflectionSupply ||
                _tokenBalance[_excluded[i]] > tokenSupply
            ) return _reflectionTotal.div(_tokenTotal);
            reflectionSupply = reflectionSupply.sub(
                _reflectionBalance[_excluded[i]]
            );
            tokenSupply = tokenSupply.sub(_tokenBalance[_excluded[i]]);
        }
        if (reflectionSupply < _reflectionTotal.div(_tokenTotal))
            return _reflectionTotal.div(_tokenTotal);
        return reflectionSupply.div(tokenSupply);
    }

    function tokenFromReflection(uint256 reflectionAmount)
        public
        view
        returns (uint256)
    {
        require(
            reflectionAmount <= _reflectionTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getReflectionRate();
        return reflectionAmount.div(currentRate);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
         if(contractTokenBalance > maxTxAmount){
             contractTokenBalance = maxTxAmount;
         }
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForBNB(half); // <- this breaks the BNB -> HATE swap when swap+liquify is triggered

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf, contractTokenBalance);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        _approve(address(this), address(pancakeRouter), tokenAmount);

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeRouter), tokenAmount);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function excludeAccount(address account) external onlyOwner() {
        require(
            account != address(pancakeRouter),
            "BEP20: We can not exclude Uniswap router."
        );
        require(!_isExcluded[account], "BEP20: Account is already excluded");
        if (_reflectionBalance[account] > 0) {
            _tokenBalance[account] = tokenFromReflection(
                _reflectionBalance[account]
            );
        }
        _isExcluded[account] = true;
        excludedIndexes[account] = _excluded.length;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "BEP20: Account is already included");
        _excluded[excludedIndexes[account]] = _excluded[_excluded.length - 1];
        _tokenBalance[account] = 0;
        _isExcluded[account] = false;
        excludedIndexes[_excluded[_excluded.length - 1]] = excludedIndexes[account];
        _excluded.pop();
    }

    function setTaxless(address account, bool value) external onlyOwner {
        _isTaxless[account] = value;
    }
    
    function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner {
        swapAndLiquifyEnabled = enabled;
        emit SwapAndLiquifyEnabledUpdated(enabled);
    }
    
    function setFeeActive(bool value) external onlyOwner {
        isFeeActive = value;
    }

    function setPresaleEnded() external onlyOwner {
        startTimestamp = block.timestamp;
        presaleEnded = true;
        isFeeActive = true;
        swapAndLiquifyEnabled = true;
        emit SwapAndLiquifyEnabledUpdated(true);
    }

    function updateFeeWallet(address newWallet) external onlyOwner {
        require(newWallet != feeWallet, "This is current address for the fee wallet.");
        address prevWallet = feeWallet;
        feeWallet = newWallet;
        emit UpdateWallet(prevWallet, newWallet, block.timestamp);
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function isTaxless(address account) public view returns (bool) {
        return _isTaxless[account];
    }

}