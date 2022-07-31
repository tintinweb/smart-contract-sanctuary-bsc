/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity ^0.8.11;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint256);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract ATS is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) isDividendExempt;
    mapping(address => bool) public _updated;

    mapping(address => bool) public isRoute;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    uint256 public _taxFee;

    uint256 public _destroyFee;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);

    uint256 public _inviterFee;

    uint256 public _fundFee;
    address private fundAddress = address(0x647CE53aA76DB31b1f63Fa977Fee50BD3861414c);
    address private fundAddress2 = address(0xAc1690128533042C81df6a711eCe1A29452caF93);
    address private fundAddress3 = address(0xAc1690128533042C81df6a711eCe1A29452caF93);
    address private fundAddress4 = address(0x1942fCE48856548edEb6f06fccfd737ed8ab8Cd2);



    mapping(address => address) public inviter;
    mapping(bytes32 => bool) public beforInviter;
    mapping(address => uint256) public inviterNum;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;

    uint256 public currentIndex;
    uint256 distributorGas = 500000;
    uint256 public _lpFee;
    uint256 public minPeriod = 5 minutes;
    uint256 public LPFeefenhong;

    address private fromAddress;
    address private toAddress;
    address private _tokenOwner;

    address[] public shareholders;
    mapping(address => uint256) public shareholderIndexes;

    uint256 public _lpTotal;
    bool public _isDestroyLp=true;
    bool public isBuyLimit=true;
    bool public isPanRate=true;
    uint256 public lastDesLpDate;
    uint256 public desLpDay = 1 days;
    uint256 public buyUint = 3*10**18;
    uint256 public uUint = 10*10**18;
    uint256 public desMax = 100000*10**18;
    uint256 public tranLpMax = 0;
    uint256 public desLpMin = 0;


    uint256 public yesHighPrice = 0;
    uint256 public yesZero = 0;
    uint256 public todayHighPrice = 0;
    uint256 public todayZero = 0;
    uint256 public extendTime = 0;

    uint256 public extendFee = 0;
    uint256 public _destroyFee2 = 0;


    uint256 public starttime = 0;
    mapping(address=>uint256) public buyTotal;
    mapping(address => bool) public stopAddr;

    address public USDT = address(0x55d398326f99059fF775485246999027B3197955);
    constructor() {
        _name = "Atom Space";
        _symbol = "ATS";
        _decimals = 18;

        _destroyFee = 0;
        _fundFee = 0;
        _taxFee = 0;
        _lpFee = 0;
        _inviterFee = 0;

        isRoute[0x10ED43C718714eb63d5aA57B78B54704E256024E]=true;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), USDT);

        uniswapV2Router = _uniswapV2Router;

        _tTotal = 180000 * 10 ** _decimals;
        _rTotal = (MAX - (MAX % _tTotal));
        _rOwned[msg.sender] = _rTotal;
        _tokenOwner = msg.sender;

        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;

        lastDesLpDate=block.timestamp;

        todayZero=dayZero();
        yesZero=todayZero-24*3600;

        _owner = msg.sender;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
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
            _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool){
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool){
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

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
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

    function setfun(address _addr) public onlyOwner {
        fundAddress=_addr;
    }

    function setfun2(address _addr) public onlyOwner {
        fundAddress2=_addr;
    }

    function setfun3(address _addr) public onlyOwner {
        fundAddress3=_addr;
    }

    function setfun4(address _addr) public onlyOwner {
        fundAddress4=_addr;
    }


    function setstarttime(uint256 _time) public onlyOwner {
        starttime=_time;
    }

    function setdesLpMin(uint256 amount) public onlyOwner {
        desLpMin=amount;
    }

    function setIsDestroyLp() public onlyOwner {
        _isDestroyLp=!_isDestroyLp;
    }

    function setisBuyLimit() public onlyOwner {
        isBuyLimit=!isBuyLimit;
    }

    function setisPanRate() public onlyOwner {
        isPanRate=!isPanRate;
    }

    function setdesMax(uint256 amount) public onlyOwner {
        desMax=amount;
    }

    function settranLpMax(uint256 amount) public onlyOwner {
        tranLpMax=amount;
    }

    function setextendTime(uint256 amount) public onlyOwner {
        extendTime=amount;
    }

    function setstopAddr(address addr,bool succ) public onlyOwner {
        stopAddr[addr]=succ;
    }

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

    function claim() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function claimTokens(address token,address to,uint256 amount) public onlyOwner {
        IERC20(token).transfer(to,amount);
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

    function getReserves() public view returns(uint112 reserve0,uint112 reserve1){
        (reserve0,reserve1,)=IUniswapV2Pair(uniswapV2Pair).getReserves();
    }

    function dayZero () public view returns(uint256){
        return block.timestamp-(block.timestamp%(24*3600))-(8*3600);
    }


    function getPrice() public view returns(uint256){

        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = address(this);
        uint256[] memory amounts = uniswapV2Router.getAmountsIn(1*10**18,path);
        return amounts[0];

    }


    function buyMax(uint256 amount) public view returns(bool){
        uint256 lpAmount=IERC20(USDT).balanceOf(uniswapV2Pair);
        //lpAmount=lpAmount.mul(2);
        uint256 times=lpAmount.div(buyUint);
        if(times==0){
            times=1;
        }

        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = address(this);
        uint256[] memory amounts = uniswapV2Router.getAmountsIn(amount,path);
        return amounts[0]<=uUint.mul(times);
    }

    function updatePrice() public {
        uint256 currPrice=getPrice();
        uint256 currZero=dayZero()+extendTime;
        if(currZero==todayZero){
            if(todayHighPrice<currPrice){
                todayHighPrice=currPrice;
            }
        }else{
            todayZero=currZero;
            todayHighPrice=currPrice;
        }
    }

    event PanRateEvent(uint256 _currPrice , uint256 _todayHighPrice, uint256 _diff, uint256 _extendFee, uint256 _type);

    function panRate() public {
        uint256 currPrice=getPrice();
        uint256 diff=0;
        if(currPrice<todayHighPrice){
            diff = todayHighPrice.sub(currPrice).mul(100).div(todayHighPrice);
            if(diff<15){
                extendFee=0;
                _destroyFee2=0;
            }
            if(diff>=15 && diff<30){
                extendFee=20;
                _destroyFee2=20;
                fundAddress2=fundAddress3;
            }
            if(diff>=30){
                extendFee=30;
                _destroyFee2=30;
                fundAddress2=fundAddress4;
            }
        }else{
            extendFee=0;
            _destroyFee2=0;
        }
        emit PanRateEvent(currPrice,todayHighPrice,diff,extendFee,2);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(from != to, "Transfer self");

        require(!stopAddr[from] && !stopAddr[to],"stop addr");


        if(balanceOf(uniswapV2Pair)>0 && IERC20(USDT).balanceOf(uniswapV2Pair)>0){
            updatePrice();
        }

        bool takeFee = false;

        if (from==uniswapV2Pair && isRoute[to]){
            takeFee = false;
        }else if (from==uniswapV2Pair && !isRoute[to]) {
            if(block.timestamp<=starttime){
                require(buyTotal[to].add(amount)<=100*10**18,"buy limit 100");
            }

            takeFee = true;
        }else if (to==uniswapV2Pair) {
            if(isPanRate && balanceOf(uniswapV2Pair)>0){
                panRate();
            }
            if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                require(balanceOf(from).sub(amount)>=1*10**12,"hold lt min ");
            }
            takeFee = true;
        }else{
            if (from!=uniswapV2Pair && isRoute[from]){
                takeFee = true;
            }else {
                if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                    require(balanceOf(from).sub(amount)>=1*10**12,"hold lt min ");
                }
                takeFee = true;
            }
        }

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);

        bytes32  addrHash = keccak256(abi.encode(from, to));
        if(inviter[to]==address(0) && !isContract(from) && !isContract(to)){
            beforInviter[addrHash]=true;
        }

        bytes32  addrHash2 = keccak256(abi.encode(to,from));
        if(inviter[from]==address(0) && beforInviter[addrHash2] && !isContract(from) && !isContract(to)){
            address paddr=to;
            bool isCan=true;
            for (uint256 i = 1; i <= 10; i++) {
                paddr=inviter[paddr];
                if(paddr==address(0)){
                    break;
                }
                if(paddr==from){
                    isCan=false;
                }
            }
            if(isCan){
                inviter[from]=to;
            }
        }

        if (fromAddress == address(0)) fromAddress = from;
        if (toAddress == address(0)) toAddress = to;
        if (!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair) setShare(fromAddress);
        if (!isDividendExempt[toAddress] && toAddress != uniswapV2Pair) setShare(toAddress);

        fromAddress = from;
        toAddress = to;

        if (from != address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
            process(distributorGas);
            LPFeefenhong = block.timestamp;
        }


    }


    function getBefore(address from,address to) public view returns (bool) {
        bytes32 addrHash = keccak256(abi.encode(from, to));
        return beforInviter[addrHash];
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        uint256 currentRate = _getRate();

        if (shareholderCount == 0) return;

        uint256 nowbanance = balanceOf(address(this));
        if (nowbanance == 0) return;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;


        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
            //            if (amount < 1 * 10 ** 18) {
            //                currentIndex++;
            //                iterations++;
            //                return;
            //            }
            if (balanceOf(address(this)) < amount) return;
            if(amount>0){
                distributeDividend(shareholders[currentIndex], amount, currentRate);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function distributeDividend(address shareholder, uint256 amount, uint256 currentRate) internal {
        uint256 rAmount = amount.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].sub(rAmount);
        _rOwned[shareholder] = _rOwned[shareholder].add(rAmount);
        emit Transfer(address(this), shareholder, amount);
    }

    function setShare(address shareholder) private {
        if (_updated[shareholder]) {
            if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;
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
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {

        uint256 currentRate = _getRate();
        uint256 multiple = 1;
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        uint256 rate;

        if (takeFee) {

            if (sender==uniswapV2Pair && isRoute[recipient]){
                _destroyFee = 0;
                _fundFee = 0;
                _taxFee = 0;
                _lpFee = 0;
                _inviterFee = 0;
                extendFee=0;
                _destroyFee2 = 0;

            }else if (sender==uniswapV2Pair && !isRoute[recipient]) {
                _destroyFee = 0;
                _fundFee = 0;
                _taxFee = 0;
                _lpFee = 0;
                _inviterFee = 80;
                extendFee=0;
                _destroyFee2 = 0;

                _takeInviterFee(sender, recipient, tAmount, currentRate);

                buyTotal[recipient]=buyTotal[recipient].add(tAmount);
            }else if (recipient==uniswapV2Pair) {
                _destroyFee = 20;
                _fundFee = 0;
                _taxFee = 0;
                _lpFee = 60;
                _inviterFee = 0;

                if(totalSupply().sub(balanceOf(_destroyAddress))<=800*10**18){
                    _destroyFee=0;
                    _destroyFee2=0;
                }

                if(_destroyFee2>0){
                    _takeTransfer(
                        sender,
                        _destroyAddress,
                        tAmount.div(1000).mul(_destroyFee.add(_destroyFee2)),
                        currentRate
                    );
                }else{
                    _takeTransfer(
                        sender,
                        _destroyAddress,
                        tAmount.div(1000).mul(_destroyFee),
                        currentRate
                    );
                }


                _takeTransfer(
                    sender,
                    address(this),
                    tAmount.div(1000).mul(_lpFee.mul(multiple)),
                    currentRate
                );

                if(extendFee>0){
                    _takeTransfer(
                        sender,
                        fundAddress2,
                        tAmount.div(1000).mul(extendFee),
                        currentRate
                    );
                }

            }else{
                if (sender!=uniswapV2Pair && isRoute[sender]){
                    _destroyFee = 0;
                    _fundFee = 0;
                    _taxFee = 0;
                    _lpFee = 0;
                    _inviterFee = 80;
                    extendFee=0;
                    _destroyFee2 = 0;

                    _takeInviterFee(sender, recipient, tAmount, currentRate);
                }else {
                    _destroyFee = 20;
                    _fundFee = 0;
                    _taxFee = 0;
                    _lpFee = 0;
                    _inviterFee = 0;
                    extendFee=0;
                    _destroyFee2 = 0;

                    _takeTransfer(
                        sender,
                        _destroyAddress,
                        tAmount.div(1000).mul(_destroyFee.mul(multiple)),
                        currentRate
                    );
                }
            }
            rate = _taxFee.mul(multiple) + _destroyFee.mul(multiple) + _inviterFee.mul(multiple) + _lpFee.mul(multiple) + _fundFee.mul(multiple);
            if(extendFee>0){
                rate=rate.add(extendFee);
            }
            if(_destroyFee2>0){
                rate=rate.add(_destroyFee2);
            }
        }


        uint256 recipientRate = 1000 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(1000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(1000).mul(recipientRate));
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

    function _takeSub(
        address addr,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[addr] = _rOwned[addr].sub(rAmount);
    }


    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        address cur;
        address init;
        uint256 multiple = 1;

        if (sender == uniswapV2Pair) {
            cur = recipient;
            init = recipient;
        } else {
            cur = sender;
            init = sender;
        }
        cur = inviter[cur];
        for (uint256 i = 1; i <= 10; i++) {
            uint256 rate;

            if (i == 1) {
                rate = 300 * multiple;
            }else if (i == 2) {
                rate = 200 * multiple;
            }else if (i == 3) {
                rate = 100 * multiple;
            }else if (i == 4) {
                rate = 70 * multiple;
            }else if (i == 5) {
                rate = 50 * multiple;
            }else if (i == 6) {
                rate = 30 * multiple;
            }else if (i == 7) {
                rate = 20 * multiple;
            }else {
                rate = 10 * multiple;
            }
            if (cur == address(0)) {
                uint256 curTAmount = tAmount.div(10000).mul(rate);
                uint256 curRAmount = curTAmount.mul(currentRate);
                _rOwned[fundAddress] = _rOwned[fundAddress].add(curRAmount);
                emit Transfer(init, fundAddress, curTAmount);
                cur = address(0);
            }else{
                if (balanceOf(cur)<50*10**18) {
                    uint256 curTAmount = tAmount.div(10000).mul(rate);
                    uint256 curRAmount = curTAmount.mul(currentRate);
                    _rOwned[fundAddress] = _rOwned[fundAddress].add(curRAmount);
                    emit Transfer(init, fundAddress, curTAmount);
                }else{
                    uint256 curTAmount = tAmount.div(10000).mul(rate);
                    uint256 curRAmount = curTAmount.mul(currentRate);
                    _rOwned[cur] = _rOwned[cur].add(curRAmount);
                    emit Transfer(init, cur, curTAmount);
                }
                cur = inviter[cur];
            }

        }
    }
}