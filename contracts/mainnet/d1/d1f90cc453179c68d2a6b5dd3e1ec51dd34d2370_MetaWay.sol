/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: GPL-3
pragma solidity ^0.8.6;
// Author: jack_chim
// IERC20 {{{
// -----------------------------------------------------------------------------
interface IERC20 {
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
// }}}

// Ownable {{{
// -----------------------------------------------------------------------------
contract Ownable {
    address public _owner;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}
// }}}

// SafeMath {{{
// -----------------------------------------------------------------------------
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
}
// }}}

// IUniswapV2Factory {{{
// -----------------------------------------------------------------------------
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
// }}}

// IUniswapV2Pair {{{
// -----------------------------------------------------------------------------
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
// }}}

// IUniswapV2Router01 {{{
// -----------------------------------------------------------------------------
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

// }}}

// IUniswapV2Router02 {{{
// -----------------------------------------------------------------------------
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
// }}}

// MetaWay {{{
// -----------------------------------------------------------------------------
contract MetaWay is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    uint256 private _tTotal;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    uint256 public _destroyFee = 20;
    uint256 public _fundFee = 10;
    uint256 public _lpDivFee = 10;
    uint256 public _destroyMaxAmount;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);

    address payable public _fundWalletAddress;
    address payable public _lpDivWalletAddress;

    uint256 public _inviterFee = 60;
    uint256 public _transferFee = 3;

    mapping(address => address) public swapPairList;
    mapping(address => address) public inviter;
    mapping(address => uint256) public lastSellTime;

    mapping(address => bool) public isWalletLimitExempt;
    mapping(address => bool) public isTxLimitExempt;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public mdswapPair;
    address public busdPair;
    
    uint256 public _mintTotal;
	uint256 public _launchedAt;

    uint256 public _maxTxAmount; 
    uint256 public _walletMax;

    bool public inInitialAddLiquidity  = true;
    bool public checkWalletLimit = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event DisableTxAndWalletLimit(uint256 maxTxAmount, uint256 maxWalletAmount, bool isCheckWalletLimit);
    
    constructor(address tokenOwner) {
        _name = "MetaWay Token";
        _symbol = "METAW";
        _decimals = 10;
        _tTotal = 11000000 * 10**_decimals;
        _destroyMaxAmount = _tTotal.div(10).mul(9);
        _balances[tokenOwner] = _tTotal;

        _maxTxAmount = 10000 * 10**_decimals;     
        _walletMax = 20000 * 10**_decimals;      

        // set foundation wallet and LP wallet
        _fundWalletAddress = payable(0x1d10600F5c4D9b4C4AB685De1038c3e4eF783884);
        _lpDivWalletAddress = payable(0xFD014e187c73915afE55464a0FA9541CeAd8e405);

        // exclude owner and this contract from fee
        _isExcludedFromFee[tokenOwner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_lpDivWalletAddress] = true;

        _owner = tokenOwner;
        _launchedAt = 1649939400;

        // Pancakeswap router02
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 

        // Create a pancakeswap pair for this new token
        // BUSDT pair
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0x55d398326f99059fF775485246999027B3197955));

        // BNB pair
        mdswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        swapPairList[mdswapPair] = mdswapPair;

        // BUSD pair
        busdPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56));
        swapPairList[busdPair] = busdPair;

        // Set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        isWalletLimitExempt[_owner] = true;
        isWalletLimitExempt[address(uniswapV2Pair)] = true;
        isWalletLimitExempt[address(mdswapPair)] = true;
        isWalletLimitExempt[address(_fundWalletAddress)] = true;
        isWalletLimitExempt[address(_lpDivWalletAddress)] = true;
        isWalletLimitExempt[address(this)] = true;

        isTxLimitExempt[_owner] = true;
        isTxLimitExempt[address(this)] = true;
 
        emit Transfer(address(0), tokenOwner, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    
    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if(msg.sender == uniswapV2Pair || msg.sender == mdswapPair || msg.sender == swapPairList[msg.sender] ){
             _transfer(msg.sender, recipient, amount);
        } else {
            _tokenOlnyTransfer(msg.sender, recipient, amount);
        }
       
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom( address sender, address recipient, uint256 amount) public override returns (bool) {
        if(recipient == uniswapV2Pair || recipient == mdswapPair || recipient == swapPairList[recipient] ){
             _transfer(sender, recipient, amount);
        } else {
             _tokenOlnyTransfer(sender, recipient, amount);
        }
       
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve( address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer( address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(inInitialAddLiquidity && from != uniswapV2Pair) { 
            return _tokenOlnyTransfer(from, to, amount); 
        } else {
            if(!isTxLimitExempt[from] && !isTxLimitExempt[to]) {
                require(getBlockNow() > _launchedAt, "Trading not open yet");
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            }            

            //indicates if fee should be deducted from transfer
            bool takeFee = true;

            uint256 _destroyAmount = balanceOf(_destroyAddress);

            //if any account belongs to _isExcludedFromFee account then remove the fee
            if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || _destroyAmount >= _destroyMaxAmount) {
                takeFee = false;
            }
            
            //transfer amount, it will take tax, burn, liquidity fee
            _tokenTransfer(from, to, amount, takeFee);

        }
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer( address sender, address recipient, uint256 tAmount, bool takeFee) private {

        _balances[sender] = _balances[sender].sub(tAmount);

        uint256 rate;
        if (takeFee) {
            // lpFee
            _takeTransfer(
                sender,
                _destroyAddress,
                tAmount.div(1000).mul(_destroyFee)
            );

            // fundFee 
            _takeTransfer(
                sender,
                _fundWalletAddress,
                tAmount.div(1000).mul(_fundFee)
            );

             // lpDivFee 
            _takeTransfer(
                sender,
                _lpDivWalletAddress,
                tAmount.div(1000).mul(_lpDivFee)
            );
            
            // inviterFee
            _takeInviterFee(sender, recipient, tAmount);
            
            rate = _destroyFee.add(_fundFee).add(_lpDivFee).add(_inviterFee);
        }

        // recipient
        uint256 recipientRate = 1000 - rate;
        uint256 finalAmount = tAmount.div(1000).mul(recipientRate);

        if(checkWalletLimit && !isWalletLimitExempt[recipient]) {
            require(balanceOf(recipient).add(finalAmount) <= _walletMax, "Wallet exceeds the maximum receive limit");
        }

        _balances[recipient] = _balances[recipient].add(finalAmount);
        emit Transfer(sender, recipient, finalAmount);
    }
    
    //this method is responsible for taking all fee, if takeFee is true
    function _tokenOlnyTransfer( address sender, address recipient, uint256 tAmount) private {
        require(tAmount > 0, "Transfer amount must be greater than zero");
        if(_balances[recipient] == 0 && inviter[recipient] == address(0)){
			inviter[recipient] = sender;
		}
        
        _balances[sender] = _balances[sender].sub(tAmount);
        
        uint256 _destroyAmount = balanceOf(_destroyAddress);

        if (_isExcludedFromFee[recipient] || _isExcludedFromFee[sender] || _destroyAmount >= _destroyMaxAmount) {
            _balances[recipient] = _balances[recipient].add(tAmount);
            emit Transfer(sender, recipient, tAmount);
        }else{
             _takeTransfer(
                sender,
                _destroyAddress,
                tAmount.div(1000).mul(_transferFee)
            );
            _balances[recipient] = _balances[recipient].add(tAmount.div(1000).mul(1000-_transferFee));
            emit Transfer(sender, recipient, tAmount.div(1000).mul(1000-_transferFee));
        }
    }
    
    function tokenOlnyTransferCheck1( address sender, address recipient) public view returns(bool){
        uint256 _destroyAmount = balanceOf(_destroyAddress);
        return _isExcludedFromFee[recipient] || _isExcludedFromFee[sender] || _destroyAmount >= _destroyMaxAmount;
    }
    
    function tokenOlnyTransferCheck2( address recipient) public view returns(bool){
        return _balances[recipient] == 0 && inviter[recipient] == address(0);
    }

    function _takeTransfer( address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }

    function _takeInviterFee( address sender, address recipient, uint256 tAmount) private {
        address cur;
        if (sender == uniswapV2Pair || sender == mdswapPair || sender == swapPairList[sender]) {
            cur = recipient;
        } else {
            cur = sender;
        }
        
        for (int256 i = 0; i < 4; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 30;
            } else {
                rate = 10;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = _destroyAddress;
            }
            uint256 curTAmount = tAmount.div(1000).mul(rate);
            _balances[cur] = _balances[cur].add(curTAmount);
            emit Transfer(sender, cur, curTAmount);
        }
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setIsTxLimitExempt(address account, bool exempt) public onlyOwner {
        isTxLimitExempt[account] = exempt;
    }

    function setInInitialAddLiquidity  (bool _bool) public onlyOwner {
        inInitialAddLiquidity = _bool;
    }

    function setIsWalletLimitExempt(address account, bool exempt) public onlyOwner {
        isWalletLimitExempt[account] = exempt;
    }

    function cancelTxAndWalletLimit(uint256 maxTxAmount, uint256 maxWalletAmount, bool isCheckWalletLimit) public onlyOwner {
        _maxTxAmount = maxTxAmount;
        _walletMax  = maxWalletAmount;
        checkWalletLimit = isCheckWalletLimit;
        emit DisableTxAndWalletLimit(maxTxAmount, maxWalletAmount, isCheckWalletLimit);
    }
 
    function setFundWalletAddress(address newAddress) public onlyOwner {
        _fundWalletAddress = payable(newAddress);
    }

    function setlpDivWalletAddress(address newAddress) public onlyOwner {
        _lpDivWalletAddress = payable(newAddress);
    }

    function changeMdSwap(address addr) public onlyOwner {
        mdswapPair = addr;
    }
    
    function setPairList(address _pair) public onlyOwner {
        swapPairList[_pair] = _pair;
    }

    function setLaunchedTime(uint256 t) public onlyOwner {
        _launchedAt = t;
    }

    function checkTxLimitExempt(address addr) public view returns (bool) {
        return isTxLimitExempt[addr];
    }

    function getBlockNow() public view returns (uint256) {
        return block.timestamp;
    }

}

// }}}