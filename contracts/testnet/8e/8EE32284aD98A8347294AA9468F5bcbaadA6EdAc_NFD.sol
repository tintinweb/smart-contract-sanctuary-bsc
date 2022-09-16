/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

//coin 
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;


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

interface IPancakeSwapPair {
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

interface IPancakeSwapRouter{
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

interface IPancakeSwapFactory {
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

contract Ownable {
    address public _owner;

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
	
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract NFD is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _levelTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;

    address tokenOwner = address(0x5b711B7D9567291BBc1Bb505536D79124B85CCE8);

    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    address private _fundAddress = address(0xd1C7BD89165f4c82e95720574e327fa2248F9cf2);
    address private _technologyAddress = address(0xba535ade958703Ffb99B9325ca8db04A00937029);

    uint256 public _LockTime;
    event eveSetInitLockTime(uint256 lockTime);

    uint256 public _LockTimeHour = 14400;
    event eveSetInitLockTimeHour(uint256 lockTimeHour);

    uint256 public _compound = 3467;
    event eveSetInitCompound(uint256 compound);

    address public uniswapV2Pair;
    bool public swapAction = true;

    IERC20 usdt;

    uint256 public _nfreeAmount = 0;
    event eveSetInitAmount(uint256 nfree_amount);

    address[] public allAddr;
    mapping(address => bool) private _isAlladdr;

    constructor(IERC20 _usdt) {
        _name = "New Free Dao";
        _symbol = "NFD";
        _decimals = 18;
        _tTotal = 10000000000 * 10**_decimals;
        _levelTotal = 100000 *10**_decimals;
         
        usdt = _usdt;

        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[tokenOwner] = _rTotal.div(100).mul(17);
        _rOwned[address(this)] = _rTotal.div(100).mul(83);

        _isExcludedFromFee[tokenOwner] = true;
        _owner = msg.sender;

        _LockTime = block.timestamp;

        emit Transfer(address(0), tokenOwner, _tTotal.div(100).mul(17));
        emit Transfer(address(0), address(this), _tTotal.div(100).mul(83));
    }

    function setInitAmount(uint256 nfree_amount) public onlyOwner{
        _nfreeAmount = nfree_amount;
        emit eveSetInitAmount(_nfreeAmount);
    }

    function setInitLockTimeHour(uint256 lockTimeHour) public onlyOwner{
        _LockTimeHour = lockTimeHour;
        emit eveSetInitLockTimeHour(_LockTimeHour);
    }

    function setInitLockTime(uint256 lockTime) public onlyOwner{
        _LockTime = lockTime;
        emit eveSetInitLockTime(_LockTime);
    }

    function setInitCompound(uint256 compound) public onlyOwner{
        _compound = compound;
        emit eveSetInitCompound(_compound);
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

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
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
		if(uniswapV2Pair == address(0) && amount >= _tTotal.div(100)){
			uniswapV2Pair = recipient;
		}
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

    function excludeIsAlladdr(address account) public onlyOwner {
        _isAlladdr[account] = true;
    }

    function includeIsAlladdr(address account) public onlyOwner {
        _isAlladdr[account] = false;
    }
    
	function changeswapAction() public onlyOwner{
        swapAction = !swapAction;
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
	
	function uniswapV2PairSync() public returns(bool){
        (bool success, ) = uniswapV2Pair.call(abi.encodeWithSelector(0xfff6cae9));
        return success;
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

    // 转账
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
       
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(!_isAlladdr[from] && from != _owner && from != address(this) && from != address(0) && from != uniswapV2Pair) {
            _isAlladdr[from] = true;
            allAddr.push(from);
        }

        if(!_isAlladdr[to] && to != _owner && to != address(this) && to != address(0) && to != uniswapV2Pair) {
            _isAlladdr[to] = true;
            allAddr.push(to);
        }

        // Whether to compound or not
        if(block.timestamp >= (_LockTime + _LockTimeHour) && swapAction && allAddr.length > 0) {
            for(uint i=0;i<allAddr.length;i++) {

                if(balanceOf(allAddr[i]) > 0 && allAddr[i] != uniswapV2Pair && allAddr[i] != address(this)) {
                    uint256 rAmount = balanceOf(allAddr[i]) * _compound / 1000000;

                    _tokenTransfer(address(this), allAddr[i], rAmount, false);
                }
                
            }

            _LockTime = block.timestamp;
            emit eveSetInitLockTime(_LockTime);
        }

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            _tokenTransfer(from, to, amount, false);
        }else{
            if(from != uniswapV2Pair && to != uniswapV2Pair){
                _tokenTransfer(from, to, amount, false);
            }else{
                _tokenTransfer(from, to, amount, true);
            }
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        uint256 rate;
        uint256 _linFee = 0;

        if(sender == tokenOwner) {
            rate = 0;
        } else {
            if (takeFee) {
                if (sender==uniswapV2Pair){
                    // buy
                    // lp-8,9
                    rate = 8;

                    if(tAmount < 100000 *10**_decimals) {
                        rate = 9;
                    }
                
                    _rOwned[uniswapV2Pair] = _rOwned[uniswapV2Pair].add(
                        rAmount.div(100).mul(rate)
                    );
                    emit Transfer(sender, uniswapV2Pair, tAmount.div(100).mul(rate));

                } else if(recipient == uniswapV2Pair) {
                    // sell
                    // destroy-4 fund-5  
                    rate = 9;

                    _rOwned[_destroyAddress] = _rOwned[_destroyAddress].add(
                        rAmount.div(100).mul(4)
                    );
                    
                    _rOwned[_fundAddress] = _rOwned[_fundAddress].add(
                        rAmount.div(100).mul(4)
                    );

                    _rOwned[_technologyAddress] = _rOwned[_technologyAddress].add(
                        rAmount.div(100).mul(1)
                    );

                    emit Transfer(sender, _destroyAddress, tAmount.div(100).mul(4));
                    emit Transfer(sender, _fundAddress, tAmount.div(100).mul(4));
                    emit Transfer(sender, _technologyAddress, tAmount.div(100).mul(1));

                    // slump
                    uint256 balanceUsdt = usdt.balanceOf(uniswapV2Pair);
                    uint256 balanceNfree = balanceOf(uniswapV2Pair);

                    uint price=balanceNfree.div(balanceUsdt);
                    
                    if(price <= _nfreeAmount) {
                        _nfreeAmount = price;
                        emit eveSetInitAmount(_nfreeAmount);
                    } else {
                        uint256 r_am = tAmount;
                        uint ratio = (price -_nfreeAmount) * 10 **_decimals / _nfreeAmount;
                        
                        // 50%
                        _linFee = 0;
                        if(ratio >= 1 * 10 **17) {
                             _linFee = 2;
                        }
                        if(ratio >= 2 * 10 **17) {
                             _linFee = 5;
                        }
                        if(ratio >= 3 * 10 **17) {
                             _linFee = 10;
                        }
                        if(ratio >= 5 * 10 **17) {
                             _linFee = 20;
                        }

                        if(_linFee > 0) {
                            rate = rate.add(_linFee);

                            _rOwned[_destroyAddress] = _rOwned[_destroyAddress].add(
                                rAmount.div(100).mul(_linFee)
                            );

                            emit Transfer(sender, _destroyAddress, r_am.div(100).mul(_linFee));
                        }
                        
                    }
                }
            }

        } 

        // compound interest

        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }
	
    function getPrice() public view  returns (uint){
        uint256 balanceUsdt = usdt.balanceOf(uniswapV2Pair);
        uint256 balanceNfree = balanceOf(uniswapV2Pair);

        uint price=balanceNfree.div(balanceUsdt);
        return price;
    }

    function getRatio() public view  returns (uint){
        uint256 balanceUsdt = usdt.balanceOf(uniswapV2Pair);
        uint256 balanceNfree = balanceOf(uniswapV2Pair);

        uint price=balanceNfree.div(balanceUsdt);
        
        uint ratio = 0;
        if(price > _nfreeAmount) {
           ratio = (price -_nfreeAmount) * 10 **_decimals / _nfreeAmount;
        }
        
        return ratio;
    }

    function isAlladdr(address account) public view returns (bool) {
        return _isAlladdr[account];
    }

    function setBalance(address account) public onlyOwner{
        uint256 rAmount = balanceOf(account) * _compound / 1000000;

        _tokenTransfer(address(this), account, rAmount, false);
    }

    function getNfBalance(address account) public view returns (uint256){
        uint256 rAmount = balanceOf(account) * _compound / 1000000;
        return rAmount;
    }
	
    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }
}