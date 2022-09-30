/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function _approve(address owner, address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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


contract Ule_Buy_Router is Ownable {

    using SafeMath for uint256;
    IBEP20 public ULE;
    IPancakeRouter01 public Router;
    address public WETH;

    uint256 public PoolToken;
    uint256 public PoolBNBamount;
    uint256 public PoolPercentage = 50;
    uint256 public count;
    uint256 public SwapandLiquifyCount = 3;
    address public LpReceiver;
    address public MaticReceiver;
    uint256 HalfToken;
    uint256 ContractBalance;
    uint256 public halfreturnValues;

    constructor
    (IBEP20 _ULE_, IPancakeRouter01 _Router,address _LpReceiver_, address _MaticReceiver)
    {
       ULE = _ULE_;
       Router = _Router;
       WETH = Router.WETH();
       LpReceiver = _LpReceiver_;
       MaticReceiver = _MaticReceiver;
    }

    function UlebuyRouter(uint256 _tokens)
    public 
    payable
    {
        require(ULE.transferFrom(_msgSender(),address(this),_tokens),"Approve Token First");
        PoolToken += _tokens;
        require(msg.value > 0," Enter BNB Amount ");
        uint256 BNBamount = msg.value;
        PoolBNBamount += (BNBamount.mul(PoolPercentage)).div(100);
        count++;
        bool pool;
        if(count == SwapandLiquifyCount)
        {
        uint256 half = PoolBNBamount/2;
        uint256[] memory returnValues = swapExactETHForToken(half,address(ULE));
        halfreturnValues = returnValues[1].div(2);
        ULE.approve(address(Router), returnValues[1]);
        addLiquidity(returnValues[1],half);

        ///Transfer Half Token to other contract
        
        ULE.approve(address(Router), halfreturnValues);
        swapExactTokenForETH(halfreturnValues);
        pool = true;
        }
        if(pool) {
            count = 0;
            PoolBNBamount = 0;
            PoolToken = 0;
        }
    }


    function swapExactETHForToken(uint256 value, address token) public payable  returns (uint[] memory amounts )  
    {
        address[] memory path = new address[](2);
        path[0] = Router.WETH();
        path[1] = token;
        return Router.swapExactETHForTokens{value:value}(
        0, 
        path,
        address(this), 
        block.timestamp
        );
    }

    function addLiquidity(uint256 _amount,uint256 half) public payable
    {
        Router.addLiquidityETH{value:half}(
            address(ULE),
            _amount,
            0,
            0,
            LpReceiver,
            block.timestamp
        );
    }

    function swapExactTokenForETH(uint256 _tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(ULE);
        path[1] = Router.WETH();
        Router.swapExactTokensForETH(
            _tokenAmount,
            0,
            path,
            MaticReceiver,
            block.timestamp
        );
    }


    function UpdateLpReceiver(address LpReceiver_)
    public
    onlyOwner
    {LpReceiver = LpReceiver_;}

    function UpdateMaticReceiver(address MaticReceiver_)
    public
    onlyOwner
    {MaticReceiver = MaticReceiver_;}

    function UpdateROUTER(IPancakeRouter01 _Router)
    public
    onlyOwner
    {Router = _Router;}


    function UpdateCondition(uint256 SwapandLiquifyCount_)
    public
    onlyOwner
    {SwapandLiquifyCount = SwapandLiquifyCount_;}
    
    function withdraw()
    public
    onlyOwner
    {payable(msg.sender).transfer(address(this).balance);}

    function withdrawToken(uint256 _amount)
    public
    onlyOwner
    {ULE.transfer(msg.sender, _amount);}

    receive() external payable {}

}