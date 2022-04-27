/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

/*

1、发行总量：10000亿，不可增发
2、流通手续费：13%
3%销毁
5%LP分红
3%回流
2%基金池：
3、指定地址接收代币(设置转账不通缩)
4、 设置白名单地址：（转账不通缩，兑换功能开关，设置加完底池可以优先买入，其它地址不可交易）

*/

//LP分红


pragma solidity ^0.8.6;

// need contract dev . telegram @zuoyachaobi

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
    
    // function renounceOwnership() public virtual onlyOwner {
    //     emit OwnershipTransferred(_owner, address(0));
    //     _owner = address(0);
    // }
    //所有权转移 默认关闭
    // function transferOwnership(address newOwner) public virtual onlyOwner {
    //     require(newOwner != address(0), "Ownable: new owner is the zero address");
    //     emit OwnershipTransferred(_owner, newOwner);
    //     _owner = newOwner;
    // }
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



contract Token is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isWhiteList;
    mapping(address => bool) private _updated;


    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD); 
    // //基金会账户
    address private _fundAddress = address(0x212EB66690B4Ef79e23b6d7a4B02cE3b6D38F1de);
    //新增回流账户 
    address private _huiliuAddress=address(0xbdDc4b9234791bCbA888EadBbeca1C21617D428c);
    //接收发币的地址
    address private _tokenAddress=address(0x8c056ff1Fdb622EF2b1D5fdC6F19661d4c1F4F53);
    //白名单
    address private _bai1Address=address(0xFa45B735cCa97469096C646510A9E4c640Fc44a1);
    address private _bai2Address=address(0x9d8296Fa627CA61E00dfC7A360938E4fDb9828d6);
    address private _bai3Address=address(0xEF9d133f7772B519c9e8BA4C3cc60dfa53eB783b);
    address private _bai4Address=address(0x33c82967689B6deEb409fEA28E07b175c303d9e0);
    address private _bai5Address=address(0x8d67cd1F1e5549563Af19Ea1b89c4d1684bD4cf4);

    //  //基金会账户
    // address private _fundAddress = address(0x1cb70e88940391264e6398bfAB927F756EBdd5A2);
    // //新增回流账户 
    // address private _huiliuAddress=address(0xe2bc6C49035fCe0728d0dB7d0330249A7Bb7CaC0);
    // //接收发币的地址
    // address private _tokenAddress=address(0xbD61246D0b5F5aDb7652C8eFA2d086A488f2aF89);
    // //15白名单
    // address private _bai1Address=address(0xAa24FfC72d720B38eb9c9821601eb83dFcACc6Dd);
    // address private _bai2Address=address(0xf28654570b5d575733b097Fa5C8110944AC3FF2C);
    // address private _bai3Address=address(0xcE3B1c96C018F62C3856116B3a1031c79ab9Cc80);
    // address private _bai4Address=address(0xbB0b7e0B4F0Bc955521Ae7C1645F31fAd98923e8);
    // address private _bai5Address=address(0x02E1e11B688D0E45846928B7606a310e8B0A7930);
    // address private _bai6Address=address(0xc4C7897d0F20Ba6aaBbfb7601cff00AD2b92C336);
    // address private _bai7Address=address(0x3F32bDC6d05A0c49C4DE87F1d31D9771659b0774);
    // address private _bai8Address=address(0xd6333C93E831D5C6CD2A963dd8C580832eC25071);
    // address private _bai9Address=address(0xf4C7e5CFbef724B37A0F13163d2D2cc3634A2FA3);
    // address private _bai10Address=address(0xF2860D90Bd830d3c12e83df1c0753c32B88851B0);
    // address private _bai11Address=address(0xbD61246D0b5F5aDb7652C8eFA2d086A488f2aF89);
    // address private _bai12Address=address(0xD42dc9A2dFe604594f45a1c9830426E1514436C8);
    // address private _bai13Address=address(0xd996C6238A0cf9b593F111e780F9Cbc036098f9B);
    // address private _bai14Address=address(0xe2bc6C49035fCe0728d0dB7d0330249A7Bb7CaC0);
    // address private _bai15Address=address(0x1cb70e88940391264e6398bfAB927F756EBdd5A2);
    uint256 private _FeeTotal;

    string private _name = "flydog";
    string private _symbol = "FLYG";   
    uint8 private _decimals = 18;


    uint256 public _fundFee = 200;
    uint256 private _previousFundFee;

    uint256 public _burnFee = 300;
    uint256 private _previousBurnFee;

    uint256 public _liquidityFee = 300;
    uint256 private _previousLiquidityFee;

    uint256 public _LPFee = 500;
    uint256 private _previousLPFee;


    uint256 currentIndex;  
    uint256 private _Total =10000 * 10 **8 * 10**18;
    uint256 distributorGas = 3000000;
    //流动性池分红时间 1小时分一次
    uint256 public minPeriod = 1 hours;
    uint256 public LPFeefenhong;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    address private fromAddress;
    address private toAddress;


    // mapping(address => address) public inviter;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    //是否可以swap
    bool canSwap = true;
    //是否可以转账 默认不可以
    bool CanTran=false;

    constructor() {
        _balances[msg.sender] = _Total;
        //Uniswap测试合约地址以及正式合约地址
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
       IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //主账户、回流账户、基金会账户、发币接收地址都设置在转账交易不收手续费 在白名单里面
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[_fundAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_huiliuAddress]=true;
         _isExcludedFromFee[_tokenAddress]=true;
        _isWhiteList[msg.sender] = true;
        _isWhiteList[_fundAddress] = true;
        _isWhiteList[address(this)] = true;
        _isWhiteList[_huiliuAddress]=true;
        _isWhiteList[_tokenAddress]=true;
        //这里是直接新增白名单 白名单转账不收手续费
         _isExcludedFromFee[_bai1Address]=true;
          _isWhiteList[_bai1Address]=true;
           _isExcludedFromFee[_bai2Address]=true;
          _isWhiteList[_bai2Address]=true;
        //   //白3-15
           _isExcludedFromFee[_bai3Address]=true;
          _isWhiteList[_bai3Address]=true;
           _isExcludedFromFee[_bai4Address]=true;
          _isWhiteList[_bai4Address]=true;
           _isExcludedFromFee[_bai5Address]=true;
          _isWhiteList[_bai5Address]=true;
        //    _isExcludedFromFee[_bai6Address]=true;
        //   _isWhiteList[_bai6Address]=true;
        //    _isExcludedFromFee[_bai7Address]=true;
        //   _isWhiteList[_bai7Address]=true;
        //    _isExcludedFromFee[_bai8Address]=true;
        //   _isWhiteList[_bai8Address]=true;
        //    _isExcludedFromFee[_bai9Address]=true;
        //   _isWhiteList[_bai9Address]=true;
        //    _isExcludedFromFee[_bai10Address]=true;
        //   _isWhiteList[_bai10Address]=true;
        //    _isExcludedFromFee[_bai11Address]=true;
        //   _isWhiteList[_bai11Address]=true;
        //    _isExcludedFromFee[_bai12Address]=true;
        //   _isWhiteList[_bai12Address]=true;
        //     _isExcludedFromFee[_bai13Address]=true;
        //   _isWhiteList[_bai13Address]=true;
        //     _isExcludedFromFee[_bai14Address]=true;
        //   _isWhiteList[_bai14Address]=true;
        //     _isExcludedFromFee[_bai15Address]=true;
        //   _isWhiteList[_bai15Address]=true;


        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        //这句话表示发币到授权支付地址
        //emit Transfer(address(0), msg.sender, _Total);
        //新功能 发币到指定地址
         emit Transfer(address(0),_tokenAddress, _Total);

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
        return _Total;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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

    // function increaseAllowance(address spender, uint256 addedValue)
    //     public
    //     virtual
    //     returns (bool)
    // {
    //     _approve(
    //         msg.sender,
    //         spender,
    //         _allowances[msg.sender][spender].add(addedValue)
    //     );
    //     return true;
    // }

    // function decreaseAllowance(address spender, uint256 subtractedValue)
    //     public
    //     virtual
    //     returns (bool)
    // {
    //     _approve(
    //         msg.sender,
    //         spender,
    //         _allowances[msg.sender][spender].sub(
    //             subtractedValue,
    //             "ERC20: decreased allowance below zero"
    //         )
    //     );
    //     return true;
    // }

    function totalFees() public view returns (uint256) {
        return _FeeTotal;
    }

    //判断该账户是否免手续费
   function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    //设置地址免手续费  先关闭
    // function excludeFromFee(address account) public onlyOwner {
    //     _isExcludedFromFee[account] = true;
    // }
    //设置地址取消手续费
    // function includeInFee(address account) public onlyOwner {
    //     _isExcludedFromFee[account] = false;
    // }
    //设置白名单 暂时关闭
    // function setWhiteList(address account, bool enable) public onlyOwner {
    //     _isWhiteList[account] = enable;
    // }

    //设置是否可以swap交易
     function setCanSwap(bool _swap) public onlyOwner {
        canSwap = _swap;
    }
    //设置是否可以交易
    function setCanTran(bool _tran) public onlyOwner {
        CanTran = _tran;
    }

    //把合约里币转入owner
    function transferContracts() public onlyOwner {
        distributeDividend(owner(), _balances[address(this)]);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function removeAllFee() private {

        _previousBurnFee = _burnFee;
        _previousLPFee = _LPFee;
        _previousLiquidityFee = _liquidityFee;
        _previousFundFee = _fundFee;

        _burnFee = 0;
        _LPFee = 0;
        _liquidityFee = 0;
        _fundFee = 0;

    }

    function restoreAllFee() private {
        _burnFee = _previousBurnFee;
        _LPFee = _previousLPFee;
        _liquidityFee = _previousLiquidityFee;
        _fundFee = _previousFundFee;

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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(!canSwap){

            if(from == uniswapV2Pair || to == uniswapV2Pair){

                require(_isWhiteList[from] || _isWhiteList[to], "not whitelist");
            }       
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true; 

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || from == address(uniswapV2Router)) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);

        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;
        //上一次转账的from和to
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to; 

        if(_balances[address(this)] >= 1 * 10**1 * 10**18 && from != address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
             process(distributorGas) ;
             LPFeefenhong = block.timestamp;
        }
       

    }

   

    function process(uint256 gas ) private {
        //lp人数
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;
        //合约的币数
        uint256 nowbanance = _balances[address(this)];
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
            //币数*自己份额/总额
          uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
         if( amount < 1 * 10**18) {//1
             currentIndex++;
             iterations++;
             return;
         }

            if(_balances[address(this)]  < amount )return;
            //分币
            distributeDividend(shareholders[currentIndex],amount);
            
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
   
    //合约里转币
    function distributeDividend(address shareholder ,uint256 amount) internal {
            
            _balances[address(this)] = _balances[address(this)].sub(amount);
            _balances[shareholder] = _balances[shareholder].add(amount);
             emit Transfer(address(this), shareholder, amount);
    }

    function setShare(address shareholder) private {

           if(_updated[shareholder] ){  
               //没有lp    
                if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           //没有lp
           if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return; 

            //加入lp分红
            addShareholder(shareholder);
            _updated[shareholder] = true;
          
    }
    //添加shareholder
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
    }

    //删除shareholder
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        _transferStandard(sender, recipient, amount);

        if (!takeFee) restoreAllFee();
    }

  
    function _takeburnFee(address sender,uint256 tAmount) private {

        if (_burnFee == 0) return;

        _balances[address(0)] = _balances[address(0)].add(tAmount);
        _FeeTotal = _FeeTotal.add(tAmount);
        emit Transfer(sender, address(0), tAmount);
    }

    function _takeLPFee(address sender,uint256 tAmount) private {
        if (_LPFee == 0 ) return;
        _balances[address(this)] = _balances[address(this)].add(tAmount);
        emit Transfer(sender, address(this), tAmount);
    }


    function _takeFundFee(address sender, uint256 tAmount) private {
        if (_fundFee == 0 ) return;
        _balances[_fundAddress] = _balances[_fundAddress].add(tAmount);
        emit Transfer(sender, _fundAddress, tAmount);
    }


    function _takeLiquidityFee(address sender,uint256 tAmount) private {
        if (_liquidityFee == 0 ) return;
        //默认回流
        // _balances[uniswapV2Pair] = _balances[uniswapV2Pair].add(tAmount);
        // emit Transfer(sender, uniswapV2Pair, tAmount);
        //新改动直接进入到指定账户里面
          _balances[_huiliuAddress] = _balances[_huiliuAddress].add(tAmount);
        emit Transfer(sender, _huiliuAddress, tAmount);
    }

    //手续费
    function _transferStandard(address sender,address recipient,uint256 tAmount) private {

        //新功能 发件人是白名单 或者开启交易
         if(_isWhiteList[sender] || CanTran){

        _balances[sender] = _balances[sender].sub(tAmount);

        _takeburnFee(sender, tAmount.div(10000).mul(_burnFee));
        _takeFundFee(sender, tAmount.div(10000).mul(_fundFee));
        _takeLPFee(sender, tAmount.div(10000).mul(_LPFee));
        _takeLiquidityFee(sender,tAmount.div(10000).mul(_liquidityFee));

        uint256 recipientRate = 10000 -_burnFee -_LPFee - _fundFee -_liquidityFee;
        _balances[recipient] = _balances[recipient].add(tAmount.div(10000).mul(recipientRate));
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
        }
    }  
 
}