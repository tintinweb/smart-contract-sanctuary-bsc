/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^ 0.8.3;

abstract contract ERC20{
    function balanceOf(address tokenOwner) external virtual view returns (uint balance);
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function getInviter(address _address) external view virtual returns (address);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        if (b == a) {
            return 0;
        }
        require(b < a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
    function divFloat(uint256 a, uint256 b,uint decimals) internal pure returns (uint256){
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 c = aPlus/b;
        return c;
    }
}

contract Comn {
    address internal owner;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status = 1;
    modifier onlyOwner(){
        require(msg.sender == owner,"Modifier: The caller is not the creator");
        _;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }
    function backWei(uint256 a, uint decimals) internal pure returns (uint256){
        if (a == 0) {
            return 0;
        }
        uint256 amount = a / (10 ** uint256(decimals));
        return amount;
    }
    function outToken(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC20(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    function outToken(address contractAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC20(contractAddress).transfer(targetAddress,amountToWei);
    }
    fallback () payable external {}
    receive () payable external {}
}

contract Finance is Comn{
    using SafeMath for uint256;
    uint256 private rewardOneToken;                      //每单位 token 奖励数量
    uint256 private updateTime;                          //最近一次更新时间
    mapping(address => uint) private userRewardOneToken; //已采集量
    mapping(address => uint) public exchangeMap;         //总兑换金额
    mapping(address => uint) public yieldMap;            //总产量
    mapping(address => uint) public outPutTotalMap;      //总产出金额
    mapping(address => uint) public outPutCollectMap;    //已领取金额

    //更新挖矿奖励
    modifier updateReward(address account) {
        rewardOneToken = rewardPerToken();
        updateTime = getNowTime(); //最新时间
        if (account != address(0)) {
            outPutTotalMap[account] = totalOutput(account);//获取最新产出
            userRewardOneToken[account] = rewardOneToken;//每单位 token 奖励数量
        }
        _;
    }

    function getNowTime() public view returns (uint256) {//获取最新时间
        if (miningEndTime > block.timestamp) {
            return block.timestamp;
        }
        return miningEndTime;
    }

    function rewardPerToken() public view returns (uint256) {//全网每单位 token 奖励数量
        return rewardOneToken + (getNowTime() - updateTime) * miningRateSecond;
    }

    function totalOutput(address account) public view returns (uint256 total) {//获取最新产出
        if(yieldMap[msg.sender] > outPutCollectMap[msg.sender]){//还有剩余收益未提取完,可以继续产出
            uint planTotalOutput =  (yieldMap[account]-outPutCollectMap[msg.sender]) * (rewardPerToken() - userRewardOneToken[account]) / 1e18;//计划产出
            if(outPutTotalMap[account] + planTotalOutput > yieldMap[msg.sender]){//超出产量
               total = yieldMap[msg.sender];
            } else {
               total = outPutTotalMap[account] + planTotalOutput;
            }
        } else {
            total = yieldMap[msg.sender];
        }
    }
    
    //获取收益
    function getProfit() public view returns (uint amountToWei){
        if(totalOutput(msg.sender) > outPutCollectMap[msg.sender]){
            amountToWei = totalOutput(msg.sender) - outPutCollectMap[msg.sender];
        } else {
            amountToWei = 0;
        }
    }

    //兑换
    function exchange(uint amountToWei) public updateReward(msg.sender) {
        require(amountToWei > 0, "Finance : Amount must be greater than 0");
        exchangeMap[msg.sender] += amountToWei;//总兑换金额
        yieldMap[msg.sender] += amountToWei.div(exchangeSaclePair[1]).mul(exchangeSaclePair[0]);//总产量
        ERC20(inAddress).transferFrom(msg.sender,address(this),amountToWei);
    }

    //领取
    function collect() public updateReward(msg.sender){
        uint waitProfit = getProfit();
        if (waitProfit > 0) {
            outPutCollectMap[msg.sender] += waitProfit;
            ERC20(outAddress).transfer(msg.sender,waitProfit);
        }
    }

    //转介兑换
    function referral(address target,uint amountToWei) public updateReward(target) {
        if(msg.sender != verifyExtractFinanceContract){ _status = _NOT_ENTERED; revert("Finance: Non agency financing"); }
        require(amountToWei > 0, "Finance : Amount must be greater than 0");
        exchangeMap[target] += amountToWei;//总兑换金额
        yieldMap[target] += amountToWei.div(exchangeSaclePair[1]).mul(exchangeSaclePair[0]);//总产量
    }

    //导入兑换
    function importExchange(address target,uint amountToWei) public onlyOwner updateReward(target) {
        require(amountToWei > 0, "Finance : Amount must be greater than 0");
        exchangeMap[target] += amountToWei;//总兑换金额
        yieldMap[target] += amountToWei.div(exchangeSaclePair[1]).mul(exchangeSaclePair[0]);//总产量
    }


    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    address private inAddress;                                   //[设置]  兑换代币地址
    address private outAddress;                                  //[设置]  获得代币地址
    address private verifyExtractFinanceContract;                //[设置]  验证提取代币合约
    uint public miningRateSecond;                                //[设置]  挖矿速率 (单位:秒)
    uint public miningEndTime;                                   //[设置]  截止时间 (单位:秒)
    uint[] public exchangeSaclePair;                             //兑换比例 [分子:exchangeSaclePair[0],分母:exchangeSaclePair[1]]
    
    function setConfig(address _inAddress,address _outAddress,uint _miningRateSecond,uint _miningEndTime) public onlyOwner {
        inAddress = _inAddress;
        outAddress = _outAddress;
        miningRateSecond = _miningRateSecond;
        miningEndTime = _miningEndTime;
    }

    function setVerifyExtractFinanceContract(address _verifyExtractFinanceContract) public onlyOwner {
        verifyExtractFinanceContract = _verifyExtractFinanceContract;
    }

    function setExchangeSaclePair(uint[] memory _exchangeSaclePair) public onlyOwner {
        exchangeSaclePair = _exchangeSaclePair;
    }

    function updateOutput(uint outputToWei) public onlyOwner {
        rewardOneToken = rewardPerToken();     //每单位 token 奖励数量
        updateTime = block.timestamp; //最新时间
        miningRateSecond = outputToWei;
    }
}