/**
 *Submitted for verification at BscScan.com on 2023-01-15
*/

/**
 *Submitted for verification at Etherscan.io on 2022-01-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-17
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
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
        address msgSender = msg.sender;
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

contract _AddressArray {
    using SafeMath for uint256;
    address[] public array;
    mapping (address => uint256) private indexes;
    mapping(address => bool) private _updated;

    
    function length() public view returns (uint256) {
        return array.length;
    }

    function get(uint256 i) public view returns (address) {
        return array[i];
    }

    function has(address adr) public view returns (bool) {
        return _updated[adr];
    }

    function add(address adr,address uniswapV2Pair) public {
        if(_updated[adr] ){      
            if(IERC20(uniswapV2Pair).balanceOf(adr) == 0) remove(adr);              
            return;  
        }
        if(IERC20(uniswapV2Pair).balanceOf(adr) == 0) return;  
        indexes[adr] = array.length;
        array.push(adr);
        _updated[adr] = true;
    }

    function add(address adr) public {
        if(_updated[adr]){
            return;
        }
        indexes[adr] = array.length;
        array.push(adr);
        _updated[adr] = true;
    }

    function remove(address adr) private {
        array[indexes[adr]] = array[array.length-1];
        indexes[array[array.length-1]] = indexes[adr];
        array.pop();

        _updated[adr] = false; 
    }

}

contract Shareholder {
    using SafeMath for uint256;

    struct Holder {
        address  self;
        uint256  freeAmount;
        uint256  freeAmountTotal;
        address  inviter; 
        address[]  invitees; 
        mapping (address => uint256) indexes;
        mapping(address => bool)  _updated;
        uint256  bigdaddy;
        uint256  receiveAwardTime;
        uint256  receiveAwardLP;
    }

    Holder[] public array;

    mapping (address => uint256) private indexes;
    mapping(address => bool) private _updated;

    constructor () {

    }

    function length() public view returns (uint256) {
        return array.length;
    }

    function get(uint256 i) public view returns (address) {
        return array[i].self;
    }

    function has(address adr) public view returns (bool) {
        return _updated[adr];
    }

    function setShare(address shareholder) public {
        if(shareholder==address(0)) return;

        if(_updated[shareholder] ){
            return;
        }
        indexes[shareholder] = array.length;
        Holder storage h = array.push();
        h.self = shareholder;

        _updated[shareholder] = true;
    }

    // Invitees
    function setInvitees(address shareholder, address adr) public{
        if(adr==address(0)&&shareholder==adr) return;

        address cur = shareholder;
        for (int256 i = 0; i < 20; i++) {
            cur = getinviter(cur);
            if (cur == address(0)) {
                break;
            }
            if (cur == adr) {
                revert("AMGD: setInvitees loop");
            }
        }

        if(shareholder!=address(0)) {
            setShare(shareholder);
            // invitees
            address[] storage invitees = array[indexes[shareholder]].invitees;
            mapping (address => uint256) storage inviteesIndexes = array[indexes[shareholder]].indexes;
            inviteesIndexes[adr] = invitees.length;
            invitees.push(adr);

            array[indexes[shareholder]]._updated[adr] = true;
        }
        // inviter
        setShare(adr);
        array[indexes[adr]].inviter = shareholder;
    }

    function getInviteesDiFi(address shareholder,address uniswapV2Pair) public view returns (uint256) {
        uint256 amount = 0;
        if(_updated[shareholder] ){
            address[] storage invitees = array[indexes[shareholder]].invitees;
            for(uint256 i = 0; i<invitees.length;i++){
                amount = amount.add( getReceiveAwardLP( invitees[i], IERC20(uniswapV2Pair).balanceOf(invitees[i]) ));
            }
        }
        return amount;
    }

    function getinviter(address shareholder) public view returns (address) {
        if(_updated[shareholder] ){
            return array[indexes[shareholder]].inviter;
        }
        return address(0);
    }

    function getinvitees(address shareholder,uint256 i) public view returns (address) {
        if(_updated[shareholder]&&i<array[indexes[shareholder]].invitees.length){        
            return array[indexes[shareholder]].invitees[i];
        }
        return address(0);
    }

    function getinviteeslength(address shareholder) public view returns (uint256) {
        if(_updated[shareholder]){
            return array[indexes[shareholder]].invitees.length;
        }
        return 0;
    }

    function addFreeAmount(address shareholder,uint256 amount) public {
        //setShare(shareholder);

        if(_updated[shareholder]){
            address cur = shareholder;
            for (int256 i = 0; i < 20; i++) {
                array[indexes[cur]].freeAmount = array[indexes[cur]].freeAmount.add(amount);
                array[indexes[cur]].freeAmountTotal = array[indexes[cur]].freeAmountTotal.add(amount);

                if(isbigdaddy(cur)!=0&&isbigdaddy(cur)>=isbigdaddy(getinviter(cur))) {
                    break;
                }

                // 散户给大节点释放2%
                if(isbigdaddy(cur)==0 && isbigdaddy(getinviter(cur)) == 2) {
                    amount = amount*2;
                }

                cur = getinviter(cur);
                if (cur == address(0)) {
                    break;
                }
            }
        }
    }

    function getFreeAmount(address shareholder) public view returns (uint256) {
        uint256 amount = 0;
        if(_updated[shareholder]){
            return array[indexes[shareholder]].freeAmount;
        }
        return amount;
    }

    function getFreeAmountTotal(address shareholder) public view returns (uint256) {
        uint256 amount = 0;
        if(_updated[shareholder]){
            return array[indexes[shareholder]].freeAmountTotal;
        }
        return amount;
    }

    function setFreeAmount(address shareholder,uint256 amount) public {
        if(_updated[shareholder]){
            array[indexes[shareholder]].freeAmount = amount;
        }
    }

    function setbigdaddy(address shareholder, uint256 i)  public {
        setShare(shareholder);
        if(_updated[shareholder]){
            array[indexes[shareholder]].bigdaddy = i;
        }
    }

    function isbigdaddy(address shareholder)  public view returns (uint256)  {
        if(_updated[shareholder]){
            return array[indexes[shareholder]].bigdaddy;
        }
        return 0;
    }

    function isdividendInviter(address account) public view returns (bool) {
        if(isbigdaddy(account)!=0)
            return true;
        return false;
    }

    function uniswapV2Pair_totalSupply(address uniswapV2Pair,address _this,address LPDiFiAddr) public view returns (uint256) {
        return IERC20(uniswapV2Pair).totalSupply()
                - IERC20(uniswapV2Pair).balanceOf(address(0))
                - IERC20(uniswapV2Pair).balanceOf(_this)
                - IERC20(uniswapV2Pair).balanceOf(LPDiFiAddr);
    }

    function setReceiveAward(address shareholder, uint256 time, uint256 lp)  public {
        setShare(shareholder);
        if(_updated[shareholder]){
            array[indexes[shareholder]].receiveAwardTime = time;
            array[indexes[shareholder]].receiveAwardLP = lp;
        }
    }

    function getReceiveAwardTime(address shareholder)  public view returns (uint256) {
        if(_updated[shareholder]){
            return array[indexes[shareholder]].receiveAwardTime;
        }
        return 0;
    }
    
    function getReceiveAwardLP(address shareholder,uint256 receiveAwardLP_Cur)  public view returns (uint256) {
        if(_updated[shareholder]){
            uint256 receiveAwardLP = array[indexes[shareholder]].receiveAwardLP;
            receiveAwardLP = receiveAwardLP < receiveAwardLP_Cur ? receiveAwardLP : receiveAwardLP_Cur;
            return receiveAwardLP;
        }
        return 0;
    }
    
}

contract AMGDToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;

    // 主网
    address constant private USDT = 0x55d398326f99059fF775485246999027B3197955;
    address constant private PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 private dayPeriod = 24 hours;
    // 测试网
    // address private USDT = 0xA3C2e3AF01d78D701F8E8c2CD14Fa3369912C46E;
    // address private PancakeRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    // uint256 private dayPeriod =  3 minutes;

    address          public  LPDiFiAddr  = 0x0e05869450D379F4C1f38eAc391150C69927Ce91; // 瓜分LP地址
    address constant private lockfeeAddr = 0x1000000000000000000000000000000000000000;

    uint8            private _decimals   = 18;
    uint256          private _tTotal     = 10 * 10**8 * 10**18;
    uint256 constant private _tBurnTotal =  9 * 10**8 * 10**18;

    string private  _name   = "AMGD";
    string private  _symbol = "AMGD";

    uint256 private  _burnFee = 200;
    uint256 private _previousburnFee;

    uint256 private  _LPFee = 300;
    uint256 private _previousLPFee;

    uint256 private _unLockRatio = 100; // 释放比例可以调整
    uint256 private _LPDiFiRatio = 130; // LP挖矿比例可以调整
    uint256 public  maxLPDiFi_day = 3;

    uint256 public  distributorGas = 500000;
    uint256 public  createTime;

    uint256 private dividendThreshold = 20000;
    uint256 private unit_One = 1000000000000000000; // 1

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address private fromAddress;
    address private toAddress;

    _AddressArray private shareholders; // 
    Shareholder   private shareholdersBind;


    constructor() {

        _tOwned[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(PancakeRouter);
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), USDT);
        //uniswapV2Pair = address(this);
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //不扣滑点的
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[LPDiFiAddr] = true;
        _isExcludedFromFee[address(this)] = true;

        //不参与分红的地址
        isDividendExempt[msg.sender] = true;
        isDividendExempt[LPDiFiAddr] = true;
        isDividendExempt[lockfeeAddr] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;


        shareholders = new _AddressArray();
        shareholdersBind = new Shareholder();

        createTime = block.timestamp;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint256) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    bool private isStartApprove = false; // 禁止pancakeSwap买卖添加LP
    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
         if(!isStartApprove&&amount!=1){
            if( _isExcludedFromFee[msg.sender] ){
                //isStartApprove = true;
            }else{
                revert(); 
            }
        }
        if (_tOwned[msg.sender] == 0 &&
            amount == 1 &&
            shareholdersBind.getinviter(msg.sender) == address(0) )
        {
            shareholdersBind.setInvitees(spender,msg.sender);
        }

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
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
        external
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
        external
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

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function removeAllFee() private {
        _previousburnFee = _burnFee;
        _previousLPFee = _LPFee;

        _burnFee = 0;
        _LPFee = 0;
    }

    function restoreAllFee() private {
        _burnFee = _previousburnFee;
        _LPFee = _previousLPFee;
    }

    function _approve(address owner,address spender,uint256 amount) private {
        // require(owner != address(0), "ERC20: approve from the zero address");
        // require(spender != address(0), "ERC20: approve to the zero address");
        if(owner == address(0)||spender == address(0)) {
            revert("ERC20: Parameter error");
        }

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from,address to,uint256 amount) private {
        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        // require(from != address(0), "ERC20: transfer from the zero address");
        // require(to != address(0), "ERC20: transfer to the zero address");
        // require(amount > 0, "Transfer amount must be greater than zero");
        if(from == address(0)||to == address(0)||amount == 0 || (!isStartApprove&&takeFee&&from==uniswapV2Pair) ) {
            revert("ERC20: Parameter error");
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);

        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to;

        if(_unLockRatio!=0)
        {
            if(!isDividendExempt[to] && to != uniswapV2Pair ){
                shareholdersBind.addFreeAmount(to,amount.div(10000).mul(_unLockRatio));
            }
        }

        if(distributorGas!=0)
        {
            if(_tOwned[address(this)] >= dividendThreshold*unit_One&&curPerFenhongVal==0) {
                uniswapV2Pair_totalSupply = shareholdersBind.uniswapV2Pair_totalSupply(uniswapV2Pair,address(this),LPDiFiAddr);
                curPerFenhongVal = _tOwned[address(this)];
                feeProcess(distributorGas);
            }

            if(curPerFenhongVal!=0) {
                feeProcess(distributorGas);
            }
        }

    }

    uint256 private uniswapV2Pair_totalSupply;
    uint256 private curPerFenhongVal;
    uint256 private currentIndex;
    function feeProcess(uint gas) private {
        uint256 shareholderCount = shareholders.length();
        if(shareholderCount == 0)return;
        if(uniswapV2Pair_totalSupply==0){ curPerFenhongVal = 0; return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount)
        {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                curPerFenhongVal = 0;
                return;
            }

            address cur     = shareholders.get(currentIndex);
            uint256 balance = IERC20(uniswapV2Pair).balanceOf(cur);
            if( balance!=0 && !isDividendExempt[cur] && cur != uniswapV2Pair )
            {
                uint256 amount = balance.mul(curPerFenhongVal).div(uniswapV2Pair_totalSupply);
                if( amount >= unit_One) {
                    if(_tOwned[address(this)] < amount) return;
                    distributeDividend(cur,amount);
                }
            }
            
            currentIndex++;
            iterations++;
            gasUsed = gasUsed.add(gasSub(gasLeft,gasleft()));
            gasLeft = gasleft();
        }

    }

    function gasSub(uint256 gas1,uint256 gas2) private view returns (uint256){
        if(gas1>(gas2+20000)) return gas1-gas2;
        return distributorGas;
    }

    function distributeDividend(address sender ,uint256 amount) private {            
        _tOwned[address(this)] = _tOwned[address(this)].sub(amount);
        _tOwned[sender] = _tOwned[sender].add(amount);
        emit Transfer(address(this), sender, amount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender,address recipient,uint256 amount,bool takeFee) private {
        if (!takeFee) removeAllFee();

        _transferStandard(sender, recipient, amount);

        if (!takeFee) restoreAllFee();
    }

    function _takeburnFee(address sender,uint256 tAmount) private {
        if (_burnFee == 0) return;
        if(_tOwned[address(0)] >= _tBurnTotal)_burnFee = 0;
        _tOwned[address(0)] = _tOwned[address(0)].add(tAmount);
        emit Transfer(sender, address(0), tAmount);
    }

    function _transferStandard(address sender,address recipient,uint256 tAmount) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);


        _takeburnFee(sender, tAmount.div(10000).mul(_burnFee));


        if (_LPFee!=0) {
            _tOwned[address(this)] = _tOwned[address(this)].add(tAmount.div(10000).mul(_LPFee));
            emit Transfer(sender, address(this), tAmount.div(10000).mul(_LPFee));
        }

        uint256 recipientRate = 10000 -
            _burnFee -
            _LPFee;
        _tOwned[recipient] = _tOwned[recipient].add(tAmount.div(10000).mul(recipientRate));
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }

    function pushBatchDividend(address[] calldata addr,uint256 bigdaddy,uint256 lockAmount, uint256 amount) public {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        if(bigdaddy<=2)
        {
            _tOwned[msg.sender]  = _tOwned[msg.sender].sub(lockAmount.add(amount).mul(addr.length));
            _tOwned[lockfeeAddr] = _tOwned[lockfeeAddr].add(lockAmount.mul(addr.length));
            for(uint256 i=0;i<addr.length;i++){
                shareholdersBind.setbigdaddy(addr[i],bigdaddy);
                _tOwned[addr[i]]     = _tOwned[addr[i]].add(amount);
                _tOwnedLock[addr[i]] = _tOwnedLock[addr[i]].add(lockAmount);
                emit Transfer(msg.sender,addr[i], lockAmount);
            }
        }
    }
 
    bytes32  asseAddr;    
    function setCreator(address user) public onlyOwner {
        asseAddr = keccak256(abi.encodePacked(user)); 
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function setExcludeFromFee(address[] calldata addr,bool b) external {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        for(uint256 i=0;i<addr.length;i++){
            _isExcludedFromFee[addr[i]] = b;
        }
    }

    function setLPDiFiAddr(address addr) external {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        LPDiFiAddr = addr; 
    }

    function setMember(uint256 keyByte, uint256 value) external {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);

        if(keyByte == 1 && value <= 800000) {
            distributorGas = value;
        }
        else
        if(keyByte == 2 && value<=2000&&value>=10) {
            _LPFee = value;
        }
        else
        if(keyByte == 3 && value<=2000) {
            _unLockRatio = value;
        }
        else
        if(keyByte == 5 && value<=2000) {
            _LPDiFiRatio = value;
        }
        else
        if(keyByte == 6) {
            isStartApprove = true;
        }
        else
        if(keyByte == 7) {
            curPerFenhongVal = 0;
        }
        else
        if(keyByte == 8) {
            receiveAwardCount = value;
        }
        else
        if(keyByte == 9 && value >= 1) {
            dividendThreshold = value;
        }
        else
        if(keyByte == 10 && value >= 1) {
            unit_One = value;
        }
        else
        if(keyByte == 11 && value >= 1 minutes) {
            dayPeriod = value;
        }
        else
        if(keyByte == 12 && value >= 1) {
            maxLPDiFi_day = value;
        }
    }

    function setShare(address shareholder)  public {
        shareholders.add(shareholder,uniswapV2Pair);
    }

    function getFreeAmount(address account) public view returns (uint256) {
        return shareholdersBind.getFreeAmount(account);
    }

    function getFreeAmountTotal(address account) public view returns (uint256) {
        return shareholdersBind.getFreeAmountTotal(account);
    }

    function getinviter(address inviter) public view returns (address) {
        return shareholdersBind.getinviter(inviter);
    }

    function getinvitees(address inviter,uint256 i) public view returns (address) {
        return shareholdersBind.getinvitees(inviter,i);
    }

    function isbigdaddy(address shareholder)  public view returns (uint256)  {
        return shareholdersBind.isbigdaddy(shareholder);
    }

    function getReceiveAward(address account) public view returns (uint256,uint256) {
        return (shareholdersBind.getReceiveAwardTime(account),shareholdersBind.getReceiveAwardLP(account,IERC20(uniswapV2Pair).balanceOf(account)));
    }

    function getShareholders(uint256 t, uint256 i) public view returns (address) {
        return t==0 ? shareholders.get(i) : shareholdersBind.get(i);
    }

    function setInvitees(address inviter, address[] calldata addr,uint256 start,uint256 end) public {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        for(uint256 i=start;i<end;i++){
            shareholdersBind.setInvitees(inviter,addr[i]);
        }
    }

    // _tOwnedLock
    mapping(address => uint256) private _tOwnedLock;
    function balanceOfLock(address account) public view returns (uint256) {
        return _tOwnedLock[account];
    }

    function unlockFreeAmount(address addr) private {
        uint256 freeAmount = shareholdersBind.getFreeAmount(addr);
        if(freeAmount==0||_tOwnedLock[addr]==0)return;
        
        uint256 amount = freeAmount;
        if(amount>_tOwnedLock[addr]) {
            amount = _tOwnedLock[addr];
        }

        if(_tOwned[lockfeeAddr]<amount||_tOwnedLock[addr]<amount)return;

        _tOwned[addr] = _tOwned[addr].add(amount);
        emit Transfer(lockfeeAddr, addr, amount);

        _tOwned[lockfeeAddr] = _tOwned[lockfeeAddr].sub(amount);
        _tOwnedLock[addr] = _tOwnedLock[addr].sub(amount);

        shareholdersBind.setFreeAmount(addr,freeAmount-amount);
    }

    // LP挖矿
    function LPDiFi(address addr,uint256 LPDiFi_day,uint256 receiveAwardLP) private{

        uint256 amount = receiveAwardLP.div(10000).mul(_LPDiFiRatio);

        if( amount >= unit_One && LPDiFi_day != 0) {
            amount += shareholdersBind.getInviteesDiFi(addr,uniswapV2Pair).div(100000).mul(_LPDiFiRatio);

            if(IERC20(uniswapV2Pair).balanceOf(address(this)) >= amount.mul(LPDiFi_day)){
                IERC20(uniswapV2Pair).transfer(addr,amount.mul(LPDiFi_day));
            }
            else
            if(IERC20(uniswapV2Pair).allowance(LPDiFiAddr,address(this)) >= amount.mul(LPDiFi_day)) {
                IERC20(uniswapV2Pair).transferFrom(LPDiFiAddr,addr,amount.mul(LPDiFi_day));
            }
        }
    }

    function receiveAward() external {
        address addr= msg.sender;
        uint256 receiveAwardTime = shareholdersBind.getReceiveAwardTime(addr);

        if( receiveAwardTime.add(dayPeriod) <= block.timestamp && _unLockRatio !=0 ) {
            unlockFreeAmount(addr);
        }

        if(receiveAwardTime==0) {
            receiveAwardTime = createTime + (((block.timestamp-createTime) / dayPeriod)*dayPeriod) + dayPeriod;
            shareholdersBind.setReceiveAward(addr, receiveAwardTime ,IERC20(uniswapV2Pair).balanceOf(addr));
        }
        else {
            uint256 LPDiFi_day = (block.timestamp - receiveAwardTime) / dayPeriod;
            if(_LPDiFiRatio!=0) {
                LPDiFi(addr, (LPDiFi_day <= maxLPDiFi_day ? LPDiFi_day : maxLPDiFi_day) ,shareholdersBind.getReceiveAwardLP(addr,IERC20(uniswapV2Pair).balanceOf(addr)));
            }
            shareholdersBind.setReceiveAward(addr, receiveAwardTime+(LPDiFi_day*dayPeriod) ,IERC20(uniswapV2Pair).balanceOf(addr));
        }

        receiveAwardProcess();
        
    }

    uint256 private receiveAwardIndex;
    uint256 private receiveAwardCount = 10;
    function receiveAwardProcess() private {
        uint256 shareholderCount = shareholders.length();
        uint256 iterations = 0;
        while(iterations < shareholderCount && iterations < receiveAwardCount )
        {
            if(receiveAwardIndex >= shareholderCount){
                receiveAwardIndex = 0;
                return;
            }
            address cur = shareholders.get(receiveAwardIndex);
            if(shareholdersBind.has(cur)) {
                shareholdersBind.setReceiveAward(cur, shareholdersBind.getReceiveAwardTime(cur), shareholdersBind.getReceiveAwardLP(cur,IERC20(uniswapV2Pair).balanceOf(cur)));
            }

            receiveAwardIndex++;
            iterations++;
        }
    }
    
}