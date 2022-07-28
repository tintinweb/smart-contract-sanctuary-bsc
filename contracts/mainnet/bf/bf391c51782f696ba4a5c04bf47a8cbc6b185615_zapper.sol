/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

pragma experimental ABIEncoderV2;

pragma solidity ^0.6.12;


interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
interface IPriceOracle{
      function latestAnswer() external view returns (int256);
}
    struct PairData {
        uint256 r0;
        uint256 r1;
    }

interface IPancakeRouter{
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external ;
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external  payable ;

}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract zapper {
        
    address public pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address kaoyaRouter = 0x879EAD67C92ec2bFa70fa9d157F500B7b31b64AB;
    address pan_bnb_kaoya = 0x7B1dD2B83f67A969e13a08847C2704003F38067A;
    address pan_busd_kaoya = 0x7a128817B3f432561bC47172e982a804e973d219;
    address kaoya_bnb_kaoya = 0x150587549bcE4268a35AeA3aC81d0ce94B722934;

    address kaoya_busd_kaoya = 0x3533d784739C26812AbF447d44966C1721fd9926;

    address wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address bnbPriceOracle = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;
    address kaoya = 0xa8a33e365D5a03c94C3258A10Dd5d6dfE686941B;
    address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address owner;
    
        PairData  pB;PairData  pU;PairData  kB;PairData kU;
        uint bnbPrice;
        constructor() public {
            owner = msg.sender;
            IERC20(busd).approve(pancakeRouter,uint(-1));
        }

    fallback() payable external {
    }
    receive() payable external{
    }
    
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    // function getDatas(PairData memory pairData,uint256 rdash1) internal pure returns(int){

    //     uint256 rdash2 = pairData.r1;
    //     int y = int256(sqrt(pairData.r0*pairData.r1*rdash2/rdash1));
    //     // int inputy = int(pairData.r1) - y;
    //     int x = int(pairData.r0*pairData.r1)/y;
    //     int inputx = x-int(pairData.r0);
    //     return (inputx);
    // }

    function getConstant(PairData memory pairData) public pure returns(uint){
        uint mul = pairData.r0*pairData.r1;
        return sqrt(mul);
    }

    function swapExactEthForKaoya() external payable{

        (pB.r0,pB.r1,) = IUniswapV2Pair(pan_bnb_kaoya).getReserves();
        (pU.r0,pU.r1,) = IUniswapV2Pair(pan_busd_kaoya).getReserves();
        (kB.r0,kB.r1,) = IUniswapV2Pair(kaoya_bnb_kaoya).getReserves();
        (kU.r0,kU.r1,) = IUniswapV2Pair(kaoya_busd_kaoya).getReserves();
        bnbPrice = uint(IPriceOracle(bnbPriceOracle).latestAnswer());//10e8

        uint sqrtBnbPrice = sqrt(bnbPrice);

        uint k0 = getConstant(pB)*sqrtBnbPrice/1e4;
        uint k1 = getConstant(pU);
        uint k2 = getConstant(kB)*sqrtBnbPrice/1e4;
        uint k3 = getConstant(kU);

        uint total = k0 + k1 + k2 + k3;

        uint totalBnb = pB.r1 + pU.r1*1e8/bnbPrice + kB.r1 + kU.r1*1e8/bnbPrice+msg.value;
        uint input1 = k0 * totalBnb/total;
        uint input2 = k1 * totalBnb/total;
        uint input3 = k2 * totalBnb/total;
        uint input4 = k3 * totalBnb/total;

        uint index = 5;

        if(input1<pB.r1){
            index = 1;
        }else if(input2<pU.r1*1e8/bnbPrice){
            index = 2;
        }else if(input3<kB.r1){
            index = 3;
        }else if(input4<kU.r1*1e8/bnbPrice){
            index = 4;
        }


        doSwap(index,input1,input2,input3,input4);
    }

    function doSwap(uint index,uint input1,uint input2,uint input3, uint input4) internal{

        address[] memory path = new address[](2);
        path[0] = wbnb;
        path[1] = kaoya;
        address[] memory busdPath = new address[](3);
        busdPath[0] = wbnb;
        busdPath[1] = busd;
        busdPath[2] = kaoya;
        
        //pancakeswap bnb-kaoya
        if(index!=1){
            IPancakeRouter(pancakeRouter).swapExactETHForTokens{value:input1-pB.r1}(
                0,
                path,
                msg.sender,
                block.timestamp
            );
        }
        //pancakeswap busd-kaoya
        if(index!=2){
            IPancakeRouter(pancakeRouter).swapExactETHForTokens{value:input2-pU.r1*1e8/bnbPrice}(
                0,
                busdPath,
                msg.sender,
                block.timestamp
            );
        }
        //kaoyaswap bnb-kaoya
        if(index!=3){
            IPancakeRouter(kaoyaRouter).swapExactETHForTokens{value:input3-kB.r1}(
                0,
                path,
                msg.sender,
                block.timestamp
            );

        }
        //kaoyaswap busd-kaoya
        if(index!=4){
            path[1] = busd;
            IPancakeRouter(pancakeRouter).swapExactETHForTokens{value:input4-kU.r1*1e8/bnbPrice}(
                0,
                path,
                address(this),
                block.timestamp
            );
            path[0] = busd;
            path[1] = kaoya;
            IPancakeRouter(kaoyaRouter).swapExactTokensForTokens(
                IERC20(busd).balanceOf(address(this)),
                0,
                path,
                msg.sender,
                block.timestamp
            );
        }
        if(payable(address(this)).balance>1e16){
            (msg.sender).transfer(payable(address(this)).balance);
        }
    }

    function withdrawBNB() external{
        payable(owner).transfer(payable(address(this)).balance);
    }
    function withdrawToken(address token) external{
        IERC20(token).transfer(owner,IERC20(token).balanceOf(address(this)));
    }
    function approve(address token,address router) external {
        if(msg.sender==owner)
            IERC20(token).approve(router,uint(-1));
    }

}