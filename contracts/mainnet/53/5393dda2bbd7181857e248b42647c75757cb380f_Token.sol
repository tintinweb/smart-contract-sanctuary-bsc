/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


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

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender =  msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
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


contract  Token is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee; // 免fee名单
    mapping(address => bool) private _updated;

    address public TOKEN ;
    string public _name ;
    string public _symbol ;
    uint8 public _decimals ;
    uint256 private _tTotal ;

    uint256 public startTradeBlock;
    uint256 public swapTokensAtAmount ;
    uint256 public _pundasSwapTokensAtAmount ;
    uint256 public _repoSwapTokensAtAmount ;

    uint256 public _LPFee ;// 百分之0
    uint256 public _NFTFee ; // 百分之3
    uint256 public _pundasyonFee ; // 百分之1
    uint256 public _repoFee;
    address public  pundasAddr ;
    address public  NFTDividerAddr;
    address public  repoAddr; 
    //BackDistributor public backDistributor;
    TokenSwapCenter public _LpSwapCenter;
    TokenSwapCenter public _pundasSwapCenter;
    TokenSwapCenter public _repoSwapCenter;

    mapping(address => bool) public isDividendExempt;
    address[] public shareholders;
    mapping (address => uint256) public shareholderIndexes;
    uint256 public _shareThreshold; 
    uint256 public currentIndex;
    mapping (address => uint256) public shareholderClaims;
    uint256 public minDistribution = 50 * (10 ** 18); 
    uint256 public minLPDividendToken =  1 * (10 ** 18); 
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    uint256 distributorGas = 500000 ;
    mapping(address => bool) excludeHolder;

    constructor(
    ) payable {
        address adminAddress =msg.sender;
        _name = "WCP Dao";
        _symbol = "WCPDAO";
        _decimals= 8;
        _tTotal = 1499 *(10**uint256(_decimals));
        _NFTFee = 300;
        _LPFee = 100;
        _pundasyonFee = 200;
        _repoFee = 100;
        _tOwned[adminAddress] = _tTotal;

        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        TOKEN = 0xf0C30B7CAE08ad4EaaB7cb5DE516EB6394e71BE3; //wcp
        NFTDividerAddr = 0x61e48638753ee62575F47f0E705571967d0F027D; // TODO 当前分红器
        pundasAddr = 0x6DA5bAF596e89C727EF5b0Fd7FE4Bc826dD2B2cf;
        repoAddr = 0x9593A0573321099AA60692da2A9723381597474E;
        swapTokensAtAmount = 10* (10**18); // TODO 500* (10**18)
        _pundasSwapTokensAtAmount = 5* (10**18);
        _repoSwapTokensAtAmount = 5* (10**18);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        _pundasSwapCenter =  new TokenSwapCenter(address(_uniswapV2Router),address(this),TOKEN,pundasAddr);
        _repoSwapCenter =  new TokenSwapCenter(address(_uniswapV2Router),address(this),TOKEN,repoAddr);
        _LpSwapCenter =  new TokenSwapCenter(address(_uniswapV2Router),address(this),TOKEN,address(this));
        _allowances[address(_LpSwapCenter)][address(_uniswapV2Router)] = ~uint256(0);
        _allowances[address(_repoSwapCenter)][address(_uniswapV2Router)] = ~uint256(0);
        _allowances[address(_pundasSwapCenter)][address(_uniswapV2Router)] = ~uint256(0);
        _allowances[address(this)][address(_uniswapV2Router)] = ~uint256(0);
        _isExcludedFromFee[address(_LpSwapCenter)] = true;
        _isExcludedFromFee[address(_repoSwapCenter)] = true;
        _isExcludedFromFee[address(_pundasSwapCenter)] = true;

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), TOKEN);
     
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;


        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(0xdead)] = true;
        isDividendExempt[address(_LpSwapCenter)] = true;
        isDividendExempt[address(uniswapV2Pair)] = true;
        isDividendExempt[address(_uniswapV2Router)] = true;
        
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeHolder[address(0)] = true;
        excludeHolder[address(_LpSwapCenter)] = true;
        excludeHolder[address(_repoSwapCenter)] = true;
        excludeHolder[address(_pundasSwapCenter)] = true;

        _swapPairList[uniswapV2Pair] = true;
        emit Transfer(address(0), adminAddress,  _tTotal);
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function distributeDividend(address shareholder ,uint256 amount) internal {
        (bool b1, ) = TOKEN.call(abi.encodeWithSignature("transfer(address,uint256)", shareholder, amount));
        require(b1, "call error");
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
        return _tOwned[account];
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



    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function excludeisDividendExempt(address account) public onlyOwner {
        isDividendExempt[account] = true;
    }

    function includeisDividendExempt(address account) public onlyOwner {
        isDividendExempt[account] = false;
    }



    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}


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



    mapping(address => bool) public _swapPairList;
    mapping (address => bool) public whiteList;
    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setWhiteList(address acc,bool newValue) public onlyOwner {
        whiteList[acc] = newValue;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(from == uniswapV2Pair){
            require(startTradeBlock!=0 && block.timestamp>=startTradeBlock, "not start trade");
        }

        if(_swapPairList[from]){
            require(whiteList[to],"buy not allow");
        }

        //indicates if fee should be deducted from transfer
        uint256 pairInited = IERC20(uniswapV2Pair).totalSupply();

        if(!_swapPairList[from] && from != address(this)){
            swap(pairInited, address(_LpSwapCenter),swapTokensAtAmount);
            swap(pairInited, address(_repoSwapCenter),_repoSwapTokensAtAmount);
            swap(pairInited, address(_pundasSwapCenter),_pundasSwapTokensAtAmount);
        }

        if(!isDividendExempt[to]) setShare(to);
        if(!isDividendExempt[from]) setShare(from);

        bool takeFee = true;
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);

        if(!isDividendExempt[from]) {
            processReward(distributorGas); 
        }
    }

    function swap(uint256 pairInited,address swapcenter,uint _swapTokensAtAmount) private {
        bool canSwap =false;
        uint256 totalDivider = balanceOf(swapcenter);
        if(pairInited>0 && totalDivider>0 &&!_LpSwapCenter.inSwap()){
            canSwap = (getTokenPrice(totalDivider) >= _swapTokensAtAmount);
        }
        if(canSwap){
            _LpSwapCenter.Swap(totalDivider);
        }
    }

    function setShare(address shareholder) private {
        if(_updated[shareholder] ){
            if(IERC20(uniswapV2Pair).balanceOf(shareholder) < minDistribution) quitShare(shareholder);
            return;
        }
        if(IERC20(uniswapV2Pair).balanceOf(shareholder) >= minDistribution) return;
        addShareholder(shareholder);
    }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
        _updated[shareholder] = true;
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
    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);

        uint256 recipientRate = 10000;
        if(takeFee){
            _takeTransfer(sender,address(_pundasSwapCenter), tAmount,_pundasyonFee);
            _takeTransfer(sender,address(_repoSwapCenter), tAmount,_repoFee);
            _takeTransfer(sender,NFTDividerAddr, tAmount,_NFTFee);
            _takeTransfer(sender,address(_LpSwapCenter), tAmount,_LPFee);

            recipientRate = recipientRate-
            _pundasyonFee -
            _NFTFee -
            _LPFee
            -_repoFee;
        }

        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }




    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        if(currentRate==0)return;
        uint256 rAmount = tAmount.div(10000).mul(currentRate);
        _tOwned[to] = _tOwned[to].add(rAmount);
        emit Transfer(sender, to, rAmount);
    }

    function setLimitAmount(uint256[] memory value) onlyOwner  public  {
        swapTokensAtAmount = value[0];
        minDistribution = value[1];
        minLPDividendToken =  value[2];
        _repoSwapTokensAtAmount = value[3];
        _pundasSwapTokensAtAmount = value[4];
    }

    function setFee(uint256[] memory value) onlyOwner  public  {
        _NFTFee = value[0];
        _LPFee = value[1];
        _pundasyonFee =  value[2];
        _repoFee = value[3];
    }


    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }


    function setAddr(address[] memory addrs) external onlyOwner {
        NFTDividerAddr = addrs[0];
        pundasAddr = addrs[1];
        repoAddr = addrs[2];
    }

    function getTokenPrice(uint total) public view returns (uint){
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = TOKEN;
        uint[] memory amount1 = uniswapV2Router.getAmountsOut(total,path);
        return amount1[1];
    }


    function processReward(uint256 gas) public {
        uint256 TOKENAmount = IERC20(TOKEN).balanceOf(address(this));
        if (TOKENAmount >= minLPDividendToken){
            return;
        }
        IERC20 holdToken = IERC20(uniswapV2Pair);
        uint holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = shareholders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = shareholders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = TOKENAmount * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    distributeDividend(shareholders[currentIndex],amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }


}

contract TokenSwapCenter is Ownable{
    address public _tokenIn;
    address public _tokenOut;
    address public _receiver;
    bool public inSwap;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    function setReceive(address  addr) external onlyOwner {
        _receiver = addr;
    }

    IUniswapV2Router02 public _swapRouter;

    constructor(address RouterAddress, address tokenIn, address tokenOut, address receiver) {
        _tokenIn = tokenIn;
        _tokenOut =  tokenOut;
        _receiver = receiver;
        _swapRouter = IUniswapV2Router02(RouterAddress);
    }

    function Swap(uint256 amount) external lockTheSwap{
        if(IERC20(_tokenIn).balanceOf(address(this)) < amount){
            return;
        }

        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;

        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );

        IERC20(_tokenOut).transfer(_receiver, IERC20(_tokenOut).balanceOf(address(this)));
    }
}