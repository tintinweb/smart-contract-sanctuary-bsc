pragma solidity 0.5.16;
import "./bankCommon.sol";
import "./uniswapCommon.sol";
interface IBEP20Treasury{
    function addLiquidityByPay(uint256 payAmount) external;
}
//Bond
contract Bond is BankCommon,UniswapCommon{
    uint256 public _buyMin=1*10**18;//购买最小值
    uint256 public _buyMax=10000*10**18;//购买最大值
    uint16 public _discount=10000;//折扣10000为原价 考虑到可能不止精确到百分位
    uint8[4] _distribution=[50,10,10,30];//入金分配 国库、金库、vc、资金池

    //实例化合约地址
    constructor (address router) UniswapCommon(router) public {}

    //设置初始参数
    function _init(uint256 buyMin,uint256 buyMax, uint16 discount,uint8[4] calldata distribution) external onlyOwner{
        _buyMin=buyMin;
        _buyMax=buyMax;
        _discount=discount;
        require(distribution[0]+distribution[1]+distribution[2]+distribution[3]<=100);
        _distribution=distribution;
    }
    //设置折扣率
    function setDiscount(uint8 discount) external onlyOwner{
        require(discount>0&&discount<=100);
        _discount=discount;
    }
    //获取当前折扣价格
    function getPrice(uint256 amount) public view returns(uint256 transferAmount){
        require(amount>0);
        require(_buyMin>0&&_buyMin<=amount);
        require(_buyMax>0&&_buyMax>=amount);

        address[] memory path = new address[](2);//交易对
        path[0]=_dol;
        path[1]=_pay;
        //获取需要付u的数量
        uint[] memory amounts=uniswapV2Router.getAmountsOut(amount,path);
        transferAmount = amounts[1].mul(_discount).div(10000);
    }
    //通过bond购买dol
    function bondToken(uint256 amount) external {
        require(amount>0);
        require(_buyMin>0&&_buyMin<=amount);
        require(_buyMax>0&&_buyMax>=amount);

        uint256 transferAmount = getPrice(amount);
        //支付对应token (需授权)
        IBEP20(_pay).transferFrom(_msgSender(),address(this),transferAmount);

        //50给国库
        IBEP20(_pay).transfer(_treasury,transferAmount.mul(_distribution[0]).div(100));

        //10给金库
        IBEP20(_pay).transfer(_vault,transferAmount.mul(_distribution[1]).div(100));
        //10给VC
        IBEP20(_pay).transfer(_vc,transferAmount.mul(_distribution[2]).div(100));
        //30给资金池
        IBEP20(_pay).transfer(_pool,transferAmount.mul(_distribution[3]).div(100));

        //铸造一份dol先寄存在本合约
        IBEP20(_dol).mint(address(this),amount);
        //线性释放
        _setReleaseBalance(_msgSender(),amount);
        //铸造一份dol给dao
        IBEP20(_dol).mint(address(_dao),amount);
        //铸造一份dol给国库
        IBEP20(_dol).mint(address(_treasury),amount);

        //国库添池 //放置末尾是为了国库有u和有dol
        IBEP20Treasury(_treasury).addLiquidityByPay(transferAmount.mul(_distribution[0]).div(100));
    }
}