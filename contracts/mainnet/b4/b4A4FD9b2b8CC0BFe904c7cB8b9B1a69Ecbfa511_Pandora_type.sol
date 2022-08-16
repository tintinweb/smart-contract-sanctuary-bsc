pragma solidity =0.6.6;

import "./IPancake.sol";
import "./BEP20Token.sol";

contract Pandora_type is BEP20Token {
    uint constant private BASE = 10 ** 8;

    address public pancakeRouter;
    uint public addressKeep;
    uint public feeToMarketPercent;
    uint public feeToBCPercent;
    uint public feeToNFTPercent;    

    mapping(address => bool) public isPancakePair;

    address public bnbPair;
    address public usdtPair;

    struct USER_STATU {
        uint8 blo;
        uint8 whi;
    }
    mapping(address => USER_STATU) private USER_STATUS;
    uint256 private feeRate =  5;
    uint256 private _timestart;
    //Address:
    address private marketAddress = address(0x000000000000000000000000000000000000dEaD);
    address private BCAddress = address(0x000000000000000000000000000000000000dEaD);
    address private NFTAddress = address(0x000000000000000000000000000000000000dEaD);


    constructor(address router, address usdt) public {
        //test router: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        //test usdt: 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
        // router: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        //usdt: 0x55d398326f99059fF775485246999027B3197955
        _name = "panda";
        _symbol = "PANDA";
        _decimals = 8;
        uint total = 80000000 * BASE;
        //额度分配msg.sender
        _mint(msg.sender,total);
        addressKeep = BASE / 1000;

        pancakeRouter = router;
        IPancakeRouter02 r = IPancakeRouter02(router);
        //创建Pair合约
        //bnbPair = IPancakeFactory(r.factory()).createPair(address(this), r.WETH());
        usdtPair = IPancakeFactory(r.factory()).createPair(address(this), usdt);
        //加入白名单
        //isPancakePair[bnbPair] = true;
        isPancakePair[usdtPair] = true;
        //USER_STATUS[bnbPair].whi=1;
        USER_STATUS[usdtPair].whi=1;
        feeToMarketPercent =40;
        feeToBCPercent = 40;
        feeToNFTPercent = 20;

    }


    function setPancakePair(address pair, bool state) external onlyOwner {
        isPancakePair[pair] = state;
    }
    //usdtpair 加入白名单 全网可以swap  usdt->bi
    function _transfer(address sender, address recipient, uint256 amount) override internal {
        address mSender = msg.sender;
        require(USER_STATUS[sender].blo == 0, "[error]: sender is disabled");
        _balances[sender].sub(amount + addressKeep, "[error]: transfer amount exceeds balance");
        //用U 买 检查 是不是白名单
        ////买的时候sender 是pair 卖的时候 recipient 是pair
        if(USER_STATUS[sender].whi != 0 && USER_STATUS[recipient].whi != 0){ 
           super._transfer(sender, recipient, amount);
            return;
        }
        //当 买币或者 买币时 不到开始时间 
        //限制买币
        if(USER_STATUS[recipient].whi == 0 && block.timestamp < _timestart && (mSender == pancakeRouter || isPancakePair[mSender])) {
            revert("[error]: not start");
        }
        //不能让普通用户卖币
         if(USER_STATUS[sender].whi == 0 && block.timestamp < _timestart && (recipient == pancakeRouter || isPancakePair[recipient])) {
            revert("[error]: not start");
        }       
        //当卖出BI 时 recipient 是是池子 扣手续费
        if ( block.timestamp > _timestart && (recipient == pancakeRouter || isPancakePair[recipient])) {
            uint feeAmount = amount.mul(feeRate).div(100);
            uint feeToMarket = _percent(feeAmount, feeToMarketPercent);
            uint feeToBC = _percent(feeAmount, feeToBCPercent);
            uint feeToNFT = _percent(feeAmount, feeToNFTPercent);
            super._transfer(sender, marketAddress, feeToMarket);
            super._transfer(sender, BCAddress, feeToBC);
            super._transfer(sender, NFTAddress, feeToNFT);
            amount = amount.sub(feeAmount);
        }
        super._transfer(sender, recipient, amount);
    }

    function _percent(uint n, uint p) private pure returns (uint) {
        return n.mul(p) / 100;
    }

    function setStartTime(uint timestart) external onlyOwner {
        _timestart=timestart;
    }

    function addUSER_STATUS(uint8 _blo,uint8 _whi,address acc) external onlyOwner {
        require(acc != address(0),"account can not be address 0"); 
        USER_STATUS[acc].blo = _blo;
        USER_STATUS[acc].whi = _whi;
    }
    function updateFeeAddress(address _marketAddress,address _BCAddress,address _NFTAddress) external onlyOwner {
        marketAddress=_marketAddress;
        BCAddress=_BCAddress;
        NFTAddress=_NFTAddress;
    }
}