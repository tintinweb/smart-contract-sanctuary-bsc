pragma solidity 0.5.16;
import "./uniswapCommon.sol";

//金库
contract Vault is uniswapCommon{
    constructor (address router) uniswapCommon(router) public {}
    //是否开启回购
    bool public _openBuyBackStatus=true;
    //目标价
    uint256 public _targetPrice=0;
    function _init(bool openBuyBackStatus, uint256 targetPrice) external onlyOwner{
        _openBuyBackStatus=openBuyBackStatus;
        _targetPrice=targetPrice;
    }
    //修改路由
    function changeRouter(address newRouter) external onlyOwner returns(bool) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouter);
        uniswapV2Router = _uniswapV2Router;
        return true;
    }
    //购买token 用u买token
    function swapToken(uint amountIn,address[] calldata addresses, uint256 maxFee) external onlyOwner returns (bool) {
        require(_openBuyBackStatus==true,"error1");
        require(maxFee<=50&&maxFee>=0,"the maxFee error");
        address[] memory path;
        path[0]=_dol;
        path[1]=_pay;
        //获取1个代币A价值多少个代币B
        uint[] memory amounts=uniswapV2Router.getAmountsOut(1*10**uint256(IBEP20(_dol).decimals()),path);
        require(_targetPrice>0&&amounts[1]<_targetPrice,"error3");
        //授权
        IBEP20(addresses[0]).approve(address(uniswapV2Router),amountIn);
        //兑换
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn,amounts[1].mul(maxFee).div(100),addresses,address(this),block.timestamp);
        return true;
    }
    function test() external view returns(uint256){
        address[] memory path;
        path[0]=_dol;
        path[1]=_pay;
        //获取1个代币A价值多少个代币B
        uint[] memory amounts = uniswapV2Router.getAmountsOut(1*10**uint256(IBEP20(_dol).decimals()),path);
        return amounts[1];
    }
    function test1() external view returns(uint256){
        return uint256(IBEP20(_dol).decimals());
    }
    function test2() external view returns(uint256){
        return 1*10**uint256(IBEP20(_dol).decimals());
    }
    function test3() external view returns(uint[] memory){
        address[] memory path;
        path[0]=_dol;
        path[1]=_pay;
        //获取1个代币A价值多少个代币B
        uint[] memory amounts = uniswapV2Router.getAmountsOut(1*10**uint256(IBEP20(_dol).decimals()),path);
        return amounts;
    }
}