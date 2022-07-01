pragma solidity 0.5.16;
import "./bankCommon.sol";

//白名单
contract White is BankCommon{
    uint256 public _whiteAmount=200*10**18;//u单价
    mapping(address=>bool) public _whites;//白名单
    uint256 public _releasePercentage=50;//线性释放比例
    constructor () public {}
    //初始化合约参数
    function _init(uint256 whiteAmount,uint256 release) public {
        require(whiteAmount>0);
        require(release<=100&&release>=0);
        _whiteAmount=whiteAmount;
        _releasePercentage=release;
    }
    //购买白名单
    function buyWhite() external{
        require(_whites[_msgSender()]==false);
        _whites[_msgSender()];
        //支付对应token (需授权)
        IBEP20(_pay).transferFrom(_msgSender(),address(this),_whiteAmount);
        _setBalance(_msgSender(),_whiteAmount.mul(100-_releasePercentage).div(100));
        _setReleaseBalance(_msgSender(),_whiteAmount.mul(_releasePercentage).div(100));
    }
    //设置白名单
    function setWhite(address whiteAddress) external onlyOwner{
        _whites[whiteAddress]=true;
        _setBalance(whiteAddress,_whiteAmount.mul(100-_releasePercentage).div(100));
        _setReleaseBalance(whiteAddress,_whiteAmount.mul(_releasePercentage).div(100));
    }
}