pragma solidity 0.5.16;
import "./uniswapCommon.sol";

//国库
contract Treasury is UniswapCommon{
    constructor (address router) UniswapCommon(router) public {}
    //添加流动性折损率(100为不折损 因有几率添加失败 故设置折损率)
    uint8 public addLpWreck=95;
    //超级合约索取数量记录
    mapping(address=>uint256) public _claimInfos;
    //超级合约索取代币给用户
    function claim(address recipient,uint256 amount) external onlySuperContract{
        require(IBEP20(_dol).balanceOf(address(this)) >= amount,"The contract does not have enough money");
        IBEP20(_dol).transfer(recipient,amount);
        _claimInfos[_msgSender()]+=amount;
    }
    //添加流动性
    function addLiquidity(uint256 payAmount) external onlySuperContract{
        require(payAmount>0);
        require(address(_pay)!=address(0));
        require(address(_dol)!=address(0));
        uint112 reserve0;
        uint112 reserve1;

        address pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(_pay, _dol);
        (reserve0,reserve1,) = IUniswapV2Pair(pair).getReserves();
        if(_pay!=IUniswapV2Pair(pair).token0()){
            //对应流动性
            uint112 reserveTemp;
            reserveTemp=reserve1;
            reserve1=reserve0;
            reserve0=reserveTemp;
        }
        uint256 dolAmount=uniswapV2Router.quote(payAmount,reserve0,reserve1);
        uniswapV2Router.addLiquidity(_pay,_dol,payAmount,dolAmount,payAmount.mul(addLpWreck).div(100),dolAmount.mul(addLpWreck).div(100),address(this),block.timestamp);
    }
    function test(uint256 payAmount) external view returns (uint112[2] memory temp){
        require(payAmount>0);
        require(address(_pay)!=address(0));
        require(address(_dol)!=address(0));
        uint112 reserve0;
        uint112 reserve1;

        address pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(_pay, _dol);
        (reserve0,reserve1,) = IUniswapV2Pair(pair).getReserves();
        if(_pay!=IUniswapV2Pair(pair).token0()){
            //对应流动性
            uint112 reserveTemp;
            reserveTemp=reserve1;
            reserve1=reserve0;
            reserve0=reserveTemp;
        }
        temp[0]=reserve0;
        temp[1]=reserve1;
    }
    function test1() external view returns (address pair){
        require(address(_pay)!=address(0));
        require(address(_dol)!=address(0));

        pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(_pay, _dol);
    }
}