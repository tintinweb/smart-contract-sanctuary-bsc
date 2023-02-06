/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
}

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract checkToken_BSC_TEST {
    using SafeMath for uint256;


    IPancakeRouter02 public router;  //0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    address public weth;
    uint256 public payEthAmount = 1000000000000;  //0.000001 ether
    address public owner;
    modifier onlyOwner  {require(msg.sender == owner , "is not owner"); _;}
    receive() external payable {}
    constructor (address pancakerouter){
        router = IPancakeRouter02(pancakerouter);
        weth = router.WETH();
        owner = address(msg.sender);
    }
    

    //--------------------------------->检测貔貅(主币池)
    function checkETHfroToken(address token) external payable  {

        //获取当前代币的pair地址
        address pairAddr = IPancakeFactory(router.factory()).getPair(weth,token);
        require(pairAddr != address(0) , "pair is address 0 "); //交易对不能是0地址

        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = token;

        ///////------------>买入
      try  router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: payEthAmount}(
            0,
            path,
            address(this),
            block.timestamp + 100
           ) {}catch
           {
           revert("buy err");
           }

    
        //当前账户代币的余额
        uint256 tokenbalance = IERC20(token).balanceOf(address(this)); 

 
        //走到这里表示可以完成购买操作
        IERC20(token).approve(address(router) ,tokenbalance ); //授权给路由地址代币
   
        ////////-------------->卖出
        address[] memory path1 = new address[](2);  //这里将交易路径翻转
        path1[0] = token;
        path1[1] = weth;

      try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenbalance,
            0,
            path1,
            address(this),
            block.timestamp + 100
            ) {
                //这里相当于成功卖出了
                revert("sell success");
            }catch{
                revert("sell err");

            }
    }

    //--------------------------------->检测貔貅(其他代币池子)
    function checkOtherfroToken( address token0 , address token1 ) external payable  {

        //获取当前代币的pair地址
        address pairAddr = IPancakeFactory(router.factory()).getPair(token0,token1);
        require(pairAddr != address(0) , "pair is address 0 "); //交易对不能是0地址

        address[] memory path0 = new address[](3);
        path0[0] = weth;
        path0[1] = token0;
        path0[2] = token1;


        //需要将weth换成token0再使用token0换token1
      try  router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: payEthAmount}(
            0,
            path0,
            address(this),
            block.timestamp + 100
        ){}catch {
            revert("buy err1");
        }

        //当前账户token1代币的余额
        uint256 token1Amount = IERC20(token1).balanceOf(address(this)); 

        //走到这里表示可以完成购买操作
        IERC20(token1).approve(address(router) ,token1Amount ); //授权给路由地址代币
        
        ////////-------------->卖出
        address[] memory path1 = new address[](2); 
        path1[0] = token1;
        path1[1] = token0;

      try router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            token1Amount,
            0,
            path1,
            address(this),
            block.timestamp + 100
            ) {
                //这里相当于成功卖出了
                revert("sell success");
            }catch{
                revert("sell err");
            }
    }

    //--------------------------------->检查交易滑点(主币池)
    function checkTokenBurn_ETH(address token , uint8 ratio_buy ,uint8 ratio_sell) external payable {
        require(ratio_buy <= 100 , "ratio is > 100");

        address pairAddr = IPancakeFactory(router.factory()).getPair(weth,token);  //获取当前代币的交易对
        require(pairAddr != address(0) , "pair is address 0 "); //交易对不能是0地址

        //通过交易对的接口获取代币的实际可以兑换的值
        address pairtoken0 = IPancakePair(pairAddr).token0();  //这里拿到交易对的token0地址
      
        //获取当前交易池的兑换比例
       (uint112 reserve0 , uint112 reserve1 ) =getReservece(weth , token);

       uint256 pool_wethAmounts = pairtoken0 == weth ? reserve0 : reserve1;  //池子weth的数量
       uint256 pool_tokenAmounts = pairtoken0 == weth ? reserve1 : reserve0;  //池子代币的数量
     
        //滑点 (应该收到的比例）
        uint8 shoudAmmount = 100 - ratio_buy; 

        uint256 AforB = ( pool_tokenAmounts.div((pool_wethAmounts.div(payEthAmount))).mul(shoudAmmount)).div(100);

        //进行模拟买入交易
        address[] memory path0 = new address[](2); 
        path0[0] = weth;
        path0[1] = token;

        try  router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: payEthAmount}(
            AforB,
            path0,
            address(this),
            block.timestamp + 100
        ){}catch {
            revert("buy err");
        }

        //模拟卖出交易 E1 =  E0 / (T0 /T1)

        uint256 walletTokenAmount = IERC20(token).balanceOf(address(this));  //钱包代币余额
        IERC20(token).approve(address(router) ,walletTokenAmount );             //授权给路由地址代币
        
        uint256 BforA =  ((pool_wethAmounts.div((pool_tokenAmounts.div(walletTokenAmount)))).mul(100-ratio_sell)).div(100);


        //进行模拟买入交易
        address[] memory path1 = new address[](2); 
        path1[0] = token;
        path1[1] = weth;

      try  router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            walletTokenAmount,
            BforA,
            path1,
            address(this),
            block.timestamp + 100
        ) {
            revert("sell success");
        }catch {
            revert("sell err");
        }
    }

    //--------------------------------->检查交易滑点(其他池)
    function checkTokenBurn_Other(address pooladdress,  address token , uint8 ratio_buy ,uint8 ratio_sell) external payable {

       require(ratio_buy <= 100 , "ratio is > 100");

       address pools  = pooladdress;
       address tokens = token;
       uint8   ratios = ratio_buy;
       uint8 ratiosell = ratio_sell;
       
       address pair0token0 =  getToken0(weth , pools);//这里拿到主币和当前底池交易对的 token0 地址}
       address pair1token0  =  getToken0(pools , tokens);//这里拿到当前交易对的 token0 地址
      
       require(getpair(pools , tokens) != address(0), "pair is address 0 "); //交易对不能是0地址

        //获取主币池和当前池低底池代币的兑换比例
        (uint112 reserve0 , uint112 reserve1 ) = getReservece(pools ,weth);

        //获取当前交易池的兑换比例
        (uint112 reserve2 , uint112 reserve3 ) = getReservece(pools ,token);

        //获取主币池和当前底池的储备量
        (uint256 WETHreserves  , uint256 POOLreserves) = pair0token0 == weth ? ( reserve0 , reserve1) :  ( reserve1 , reserve0);

       //获取当前池的储备量
        (uint256 poolreserve0  , uint256 tokenreserve1) = pair1token0 == pools ?  ( reserve2 , reserve3) : ( reserve3 , reserve2);

    
        //进行模拟买入交易
        uint8 R = ratios;
        address[] memory path0 = new address[](3); 
        path0[0] = weth;
        path0[1] = pools;
        path0[2] = tokens;
        try  router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: payEthAmount}(
            tallyReserve(WETHreserves,POOLreserves,poolreserve0,tokenreserve1 ,R),
            path0,
            address(this),
            block.timestamp + 100
        ){}catch {
            revert("buy err");
        }

        //进行模拟卖出交易
        uint256 walletTokenAmount = IERC20(tokens).balanceOf(address(this));  //钱包代币余额
        IERC20(tokens).approve(address(router) ,walletTokenAmount );          //授权给路由地址代币
       
       //应该收到底池代币数量
       uint8 R1 = 100 - ratiosell;
       uint256 shouldPoolAmount = (poolreserve0.div(tokenreserve1.div(walletTokenAmount)).mul(R1)).div(100);

       address[] memory path1 = new address[](2); 
       path1[0] = path0[2];
       path1[1] = path0[1];

      try router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
        walletTokenAmount,
        shouldPoolAmount,
        path1,
        address(this),
        block.timestamp + 100
        ){
            revert("sell success");
        }catch {
            revert("sell err");
        }
    }




    //更改交易测试费
    function SetTestFee(uint256 value) public onlyOwner{
        payEthAmount = value;
    }

    function tallyReserve(uint256 A , uint256 B , uint256 C , uint256 D , uint8 R ) view internal returns(uint256) {

        uint256 etherforB = B.div( (A.div(payEthAmount) ));  //第一步计算 0.0001 ether 可以兑换多少 B

        uint256 etherforD = D.div((C.div(etherforB))) ;   //第二步计算用 etherforB 可以兑换多少D
       
        return (etherforD.mul(100 - R)).div(100);    //计算百分比
    }

    function getToken0( address _token0 , address _token1) private view  returns(address) {
        return  IPancakePair( IPancakeFactory(router.factory()).getPair(_token0,_token1)).token0();
    }

    function getpair (address A , address B) private view returns (address) {
        return IPancakeFactory(router.factory()).getPair(A,B);
    }

    function getReservece(address tokenA ,address tokenB) private view returns (uint112  , uint112) {
       (uint112 reserve0 , uint112 reserve1 , uint32 time0) = IPancakePair( getpair(tokenA ,tokenB)).getReserves(); 
        return (reserve0 , reserve1);

    }



}