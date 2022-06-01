/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: MIT


pragma solidity >=0.6.2;
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
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

// File: contracts\interfaces\IPancakeRouter02.sol

pragma solidity >=0.6.2;

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
pragma solidity >=0.5.0;

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

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}
interface IPancakePair {
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

pragma solidity ^0.8.6;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


contract Ownable {
    address public _owner;


    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public  onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public  onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _owner = newOwner;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
//usdt授权到合约后，由合约进行扣费。然后自动买
contract MubsFunc is Ownable, Context{
    using SafeMath for uint256;
    address private _usdt;
    address private _mubs;
    
    uint256 private _usdtNumber;
    address private _router;
    // address private mubsRecipent;
    uint8 decimals =18;
    bool public autotrade;
    address private _usdtReceiver =0x4aA8B61008E130a6c72568aE52BE33e6237F605E;
    address private fundAccount =0xD263289087C4FCf04B25B631595179B63540eA72;//需要基金账户的mubs给合约授权
    address private dichi =0xaDcD71352e8802a8dA38a7fF331a6D18dC1b518D; //mubs的owner购买账户,均需要给合约授权
    mapping(address=>uint256) private _cashFromOwner;//owner可提现金额,购买部分
    mapping(address=>uint256) private _cahsFromFund;//fund账户可提现金额，节点分红部分
    address private mubsreciever =0x4E68e469fa448706beE5B750F8d5a66bF18641F4;
    IPancakeRouter02 public immutable uniswapV2Router;
    constructor(address usdt , address mubs,address pancakerouter ){
        _usdt = usdt;
        _mubs = mubs;
        // _usdtReceiver = address(this);
        _router = pancakerouter;
        uniswapV2Router = IPancakeRouter02(pancakerouter);
        // mubsRecipent = msg.sender;
        _owner = msg.sender;
        
    autotrade = true;
        // fundAccount = fundAccount_; //基金账户
        // ownerAccount = ownerAccount_; //mubs的owner账户
        // IERC20(usdt).approve(pancakerouter,100000*10*18);
        // TransferHelper.safeApprove(_usdt,pancakerouter,10000*10**18);
        // mubsreciever = mubsreciever_;
        
    }
  

    //计算矿池占比
    function getRate() public view returns(uint256 ,uint256){
        uint256 pool = IERC20(_mubs).balanceOf(dichi);
        uint256 _totalSupply = IERC20(_mubs).totalSupply();
        return (pool,_totalSupply);
    }


    //使用其他合约授权试试
    // function usdtAprove (address to, uint256 amount )public returns(bool){
    //     TransferHelper.safeApprove(_usdt,to,amount);
    //     return true;
    // }



    //提现目前所有
    // function customerCashAll()public returns(bool){
    //     require(_cashFromOwner[_msgSender()] >0 || _cahsFromFund[_msgSender()] >0 , "no one account more than zero");

    //     customerCash(_cashFromOwner[_msgSender()], _cahsFromFund[_msgSender()]);
    //     return true;
    // }
    //改变基金分红账户
    function changeFundAccount(address account)public onlyOwner returns(bool){
        fundAccount = account;
        return true;
    }

    //从owner账户和基金账户提现
    // function customerCash(uint256 amount1, uint256 amount2) public returns(bool){
    //     require(_cashFromOwner[_msgSender()] >= amount1,"dont enough mubs from buy");
    //     require(_cahsFromFund[_msgSender()] >= amount2, "dont enough mubs from buy");
    //     _customerCash(amount1,amount2);
    //     _cashFromOwner[_msgSender()] -=amount1;
    //     _cahsFromFund[_msgSender()] -=amount2;
    //     return true;
    // }
//owner账户和基金账户直接转账
function transferToCustomer(address customer , uint256 amount1,uint256 amount2) public onlyOwner returns(bool){
    require(amount1+amount2 >0 ,"exceed withdraw amount ");
    if (amount2 ==0){
        IERC20(_mubs).transferFrom(dichi,customer, amount1);
        return true;
    }
    if(amount1 ==0){
        IERC20(_mubs).transferFrom(fundAccount,customer,amount2);
        return true;
    }
    IERC20(_mubs).transferFrom(dichi,customer, amount1);
    IERC20(_mubs).transferFrom(fundAccount,customer,amount2);
    return true;
}


//需要提前使用owneraccount和fundaccount给合约授权
    // function _customerCash(uint256 amount1,uint256 amount2 )internal returns(bool){
    //     IERC20 mubs = IERC20(_mubs);
    //     if(amount1 > 0){
    //         require(amount2 >=0,"must greater than zero");
    //     }
    //     if(amount2 >0){
    //         require(amount1 >=0,"must greater than zero");
    //     }
    //     require(mubs.balanceOf(ownerAccount) >= amount1,"dont enough mubs from buy");
    //     require(mubs.balanceOf(fundAccount) >= amount2,"have enough mubs from fund");
    //     mubs.transferFrom(ownerAccount, _msgSender(),amount1);
    //     mubs.transferFrom(fundAccount, _msgSender(), amount2);
    //     return true;
    // }

    //合约接收BNB进行提现gas费使用
    function getValue()public payable returns(bool){
        require(msg.value >= 2*10*15);
        return true;

    }
//把合约的以太转出来
    // function tranferBNB( uint256 amount )public payable onlyOwner returns(bool){
    //    payable(address(this)).transfer(amount);
    //     return true;
    // }

    function tranferBNB(address to, uint256 amount )public payable onlyOwner returns(bool){
      payable(to).transfer(amount);
        return true;
    }


//查询合约以太数量
    function balanceBNB ()public view returns(uint256){
       uint256 x =  payable(address(this)).balance;
       return x;
    } 

    //合约的usdt给其他授权
    function usdtApproveTo(address to, uint256 amount)public onlyOwner returns(bool){
        // IERC20(_usdt).approve(to,amount);
        TransferHelper.safeApprove(_usdt,to,amount);
        return true;
    }
    //合约直接转账U
    function transferUsdt(address to , uint256 amount)public onlyOwner returns(bool){
        IERC20(_usdt).transfer(to,amount);
        return true;
    }
    //查看合约有多少U
    function usdtNumber()public view returns(uint256){
        uint256 usdtBalance = IERC20(_usdt).balanceOf(address(this));
        return usdtBalance;
    }
    // function transferU(address customer,uint amount)public{
    //     TransferHelper.safeTransferFrom(_usdt,customer,address(this),amount);
    // }

    function changeAutoTrade()public returns (bool){
        autotrade =!autotrade;
        return true;
    }


    //这一步需要客户的USDT对合约授权,usdt转账
    function transferUsdtFromCustomer(address customer, uint256  amount)public  returns(bool){
        IERC20(_usdt).transferFrom(customer ,address(this),amount);
        // TransferHelper.safeTransferFrom(_usdt,customer,address(this),amount);
      
        // _tradePancake(_usdt, _mubs,address(this),amount.div(2) );
        if (autotrade){
            TransferHelper.safeApprove(_usdt,_router,amount.div(2));
            _tradePancake(_usdt, _mubs,address(this),amount.div(2) );
            uint256 getmubs =  IERC20(_mubs).balanceOf(address(this));
            IERC20(_mubs).transfer(dichi,getmubs.div(5));
            IERC20(_mubs).transfer(mubsreciever,getmubs.div(5).mul(4));
            TransferHelper.safeTransfer(_usdt,_usdtReceiver,amount.div(2));
        }else{
            TransferHelper.safeTransfer(_usdt,_usdtReceiver,amount);
        }
        
        //自动买一半usdt，返回到合约地址,这一步切记要使用合约的U给pancakerouter授权
        // _tradePancake(_usdt, _mubs,address(this),amount.div(2) );
        // uint256 getmubs =  IERC20(_mubs).balanceOf(address(this));
        // //进行到账后的分配
        // IERC20(_mubs).transfer(ownerAccount,getmubs.div(5));
        // IERC20(_mubs).transfer(mubsreciever,getmubs.div(5).mul(4));
        return true;
    }

    function transferFromNode(address customer,uint256 amount)public returns(bool){
        IERC20(_usdt).transferFrom(customer ,address(this),amount);
        TransferHelper.safeTransfer(_usdt,_usdtReceiver,amount);
        return true;
    }


    // function tradeUSDT(uint amount) public{
    //     _tradePancake(_usdt, _mubs,address(this),amount );
    // }
    //转合约的mubs


    function transferTokenToOhters(uint256 amount ,address account) public onlyOwner{
        IERC20(_mubs).transfer(account,amount);
    }
//查看合约多少mubs
    function balanceOfTokenContract()public view returns(uint256) {
        uint256 values = IERC20(_mubs).balanceOf(address(this));
        return values;
    }
// function tradeUSDT(uint256 amount) public returns(bool){
//     _tradePancake(_usdt,_mubs,address(this),amount);
//     return true;
// }

    //from pancake buy 只能当前合约去交易
    function _tradePancake(address pay,address getter,address recipient,uint256 amount)internal {
        address[] memory path = new address[](2);
        path[0] = pay;
        path[1] = getter;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount,0,path,recipient,block.timestamp+10000);
    }

    //add liquidity 添加流动性前必须授权给pancake
    // function addLiquidity(address tokenA, address tokenB, uint256 amountA ,uint256 amountB, address cakeTO ,uint256 time )public onlyOwner returns(bool) {//time为秒
    //     uint256 allowanceA = _checkAllowance(tokenA);
    //     uint256 allowanceB = _checkAllowance(tokenB);
    //     _approveToPancake(allowanceA + amountA , allowanceB + allowanceB);
    //     uniswapV2Router.addLiquidity(tokenA, tokenB , amountA, amountB ,0,0,cakeTO,block.timestamp+time+100000);
    //     return true;
    // }
    //给pancake授权
    // function _approveToPancake(uint256 mubs_,uint256 usdt_)internal  returns(bool){
    //     IERC20(_mubs).approve(_router, mubs_);
    //     IERC20(_usdt).approve(_router, usdt_);
    //     return true;
    // }
    //检查给pancake的授权额度
    // function  _checkAllowance(address token)internal view returns(uint256){
    //     uint256 allowance_ = IERC20(token).allowance(address(this), _router);
    //     return allowance_;
    // }


}