/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

interface IBEP20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract GalaxyBattleship is Ownable {
    using SafeMath for uint256;

    IBEP20 public aecToken = IBEP20(0xe730A1Cdd3a9768d59375775B21990A743c31614);
    IBEP20 public botToken = IBEP20(0x96553190F1dEa1e631D1d21D22fd5d6b0D228E8f);
    IBEP20 public usdtToken = IBEP20(0xb5Af8648EfF53FdAA680552Ef564c1F79d321a34);
    address private devAddress = 0xAD0c8327CDB52536A125935842152355C5B5F224;
    IPancakePair pancakePair = IPancakePair(0x8751A14EB094eECddE7073dcF96A2d8E7a514560);

    
    uint256 public botPrice = 1000000000000000000;//BOT指导价
    uint256 public totalPower = 0;//总算力
    uint256 public dailyOutput = 336000000000000000000;//每日产量
    uint256 public minPower = 100000000000000000000;//最小算力标准
    uint256 public takeTimeLimit = 86400;
    mapping(address => UserObject) public _userMap;
    struct UserObject {
        bool isConf;
        uint256 myPower;//我的算力
        uint256 myUsdtAmount;
        uint256 myAecAmount;
        uint256 mySoldAmount;
        uint256 myTakeTime;//最近领取时间
        uint256 myTakeCount;//收益总额
        address parent;//上级地址
        uint256 profitAmount;//推荐奖励
    }

    //奖品类型顺序 AEC、BOT、USDT、未中奖
    //奖品分数
    uint256[] public prizeNumList = [0,0,10,10];
    //每份奖品的数量
    uint256[] public prizeAmountList = [500000000000000000,1000000000000000000,1500000000000000000,0];
    uint256 public botCostOfBox = 1500000000000000000;//每个盲盒要消耗的BOT数量
    mapping(address => BoxObject[]) public _userBoxMap;
    struct BoxObject {
        uint256 prizeType;//奖品类型
        uint256 prizeAmount;//奖品数量
        uint256 botCost;//消耗的BOT数量
        uint256 openTime;//开启时间
    }
    function getPrizeParam() public view returns (uint256,uint256[] memory,uint256[] memory){
        return (botCostOfBox,prizeNumList,prizeAmountList);
    }
    function setPrizeParam(uint256 _botCostOfBox,uint256[] memory _prizeNumList,uint256[] memory _prizeAmountList) external onlyOwner {
        require(_prizeNumList.length == _prizeAmountList.length &&  _prizeNumList.length == 4, "INVALID_PARAM");
        botCostOfBox = _botCostOfBox;
        prizeNumList = _prizeNumList;
        prizeAmountList = _prizeAmountList;
    }

    function getUserBoxInfo(address userAddress) public view returns (BoxObject[] memory){
        return _userBoxMap[userAddress];
    }

    function openBox() public {
        UserObject memory userObject = _userMap[msg.sender];
        require(userObject.isConf,"no power");
        //满3倍出局
         uint256 receiveLimit = userObject.myUsdtAmount*6;
        require(userObject.mySoldAmount < receiveLimit,"out profit limit");
         uint256 botWorth = botCostOfBox*botPrice/1000000000000000000;
        _userMap[msg.sender].mySoldAmount = _userMap[msg.sender].mySoldAmount + botWorth;

        uint256 prizeAecNum = prizeNumList[0];
        uint256 prizeBotNum = prizeNumList[1];
        uint256 prizeUsdtNum = prizeNumList[2];
        uint256 prizeEmptyNum = prizeNumList[3];
        uint256 remainNum = prizeAecNum + prizeBotNum + prizeUsdtNum + prizeEmptyNum;
        require(remainNum > 0,"no prize for box");

        //扣除BOT,并增加到获利中去
        botToken.transferFrom(address(msg.sender),devAddress,botCostOfBox);
        
        uint256 randNum = rand(remainNum);
        uint256 prizeType;
        uint256 prizeAmount;
        if(randNum <= prizeAecNum){
            prizeType = 1;
            prizeAmount = prizeAmountList[0];
            prizeNumList[0] = prizeNumList[0]-1;
            aecToken.transfer(address(msg.sender),prizeAmount);
        }else if(randNum<= (prizeAecNum + prizeBotNum)){
            prizeType = 2;
            prizeAmount = prizeAmountList[1];
            prizeNumList[1] = prizeNumList[1]-1;
            botToken.transfer(address(msg.sender),prizeAmount);
        }else if(randNum<= (prizeAecNum + prizeBotNum + prizeUsdtNum)){
            prizeType = 3;
            prizeAmount = prizeAmountList[2];
            prizeNumList[2] = prizeNumList[2]-1;
            usdtToken.transfer(address(msg.sender),prizeAmount);
        }else{
            prizeType = 4;
            prizeAmount = 0;
            prizeNumList[3] = prizeNumList[3]-1;
        }
        BoxObject memory boxObject = BoxObject({prizeType:prizeType,prizeAmount:prizeAmount,botCost:botCostOfBox,openTime:block.timestamp});
        _userBoxMap[msg.sender].push(boxObject);
    }
    function rand(uint256 length) public view returns(uint256) {
        require(length > 0,"rand error");
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        uint256 result = random % length;
        return result +1;
    }

    function getUserInfo(address userAddress) public view returns (UserObject memory){
        return _userMap[userAddress];
    }

    function getGameParam() public view returns (uint256,uint256,uint256,uint256){
        return (botPrice,dailyOutput,totalPower,minPower);
    }

    function setGameParam(uint256 _botPrice,uint256 _dailyOutput,uint256 _minPower) external onlyOwner{
        require(_botPrice > 0 && _dailyOutput > 0,"params error");
        botPrice = _botPrice;
        dailyOutput = _dailyOutput;
        minPower = _minPower;
    }

    function buy(address ref,uint256 usdtAmount) public{
        require(usdtAmount > 0,"params error");
        //获取AEC价格，并计算AEC数量
        uint256 aecPrice = calcAecPrice();
        uint256 aecAmount = usdtAmount*1000000000000000000/aecPrice;

        //AEC30%销毁
        uint256 aecDestroyAmount = aecAmount*30/100;
        aecToken.transferFrom(address(msg.sender),address(0),aecDestroyAmount);

        //转账
        aecToken.transferFrom(address(msg.sender),address(this),aecAmount-aecDestroyAmount);
        usdtToken.transferFrom(address(msg.sender),devAddress,usdtAmount);

        //增加矿池总算力
        totalPower = totalPower+usdtAmount*2;

        //构造质押数据
        if(_userMap[msg.sender].isConf){
            _userMap[msg.sender].myPower = _userMap[msg.sender].myPower+usdtAmount*2;
            _userMap[msg.sender].myUsdtAmount = _userMap[msg.sender].myUsdtAmount+usdtAmount;
            _userMap[msg.sender].myAecAmount = _userMap[msg.sender].myAecAmount+aecAmount;

            //给上级返利
            profitReferral(_userMap[msg.sender].parent,aecAmount-aecDestroyAmount);
        }else{
            //判断上级地址
            if(ref == msg.sender || ref == address(0) || _userMap[ref].isConf == false) {
                ref = devAddress;
            }
            UserObject memory userObject = UserObject({
                isConf:true,
                myPower:usdtAmount*2,
                myUsdtAmount:usdtAmount,
                myAecAmount:aecAmount,
                mySoldAmount:0,
                myTakeTime:block.timestamp,
                myTakeCount:0,
                parent:ref,
                profitAmount:0
            });
            _userMap[msg.sender] = userObject;
            //给上级返利
            profitReferral(ref,aecAmount-aecDestroyAmount);
        }
    }

    function profitReferral(address level1, uint256 totalAmount) internal{
        uint256 totalProfit = 0;
        uint256 unitProfit = totalAmount*10/100;
        address tmpAddr = level1;
        uint256 layer = 1;
        while (layer<=10 && tmpAddr != address(0)) {
            if(_userMap[tmpAddr].myPower >= minPower){
                _userMap[tmpAddr].profitAmount = _userMap[tmpAddr].profitAmount+unitProfit;
                // aecToken.transferFrom(address(msg.sender),address(tmpAddr),unitProfit);
                totalProfit = totalProfit + unitProfit;
            }
            tmpAddr = _userMap[tmpAddr].parent;
            layer = layer+1;
        }
        //没反完的给项目方
        // if(totalAmount-totalProfit>0){
        //     aecToken.transferFrom(address(msg.sender),devAddress,totalAmount-totalProfit);
        // }
    }

    function calcAecPrice() public view returns(uint256){
        (uint256 _reserve0, uint256 _reserve1,) = pancakePair.getReserves();
        uint256 aecPrice =  _reserve0*1000000000000000000/_reserve1;
        return aecPrice;
    }

    function take() public {
        UserObject memory userObject = _userMap[msg.sender];
        require(userObject.isConf,"no power");
        require(block.timestamp-userObject.myTakeTime >= takeTimeLimit,"Less than takeIntervals");

        //计算我的DOT产出量
        uint256 takeAmount = dailyOutput*userObject.myPower/totalPower;
        botToken.transfer(address(msg.sender),takeAmount);

        //更新我的领取时间
        _userMap[msg.sender].myTakeTime = block.timestamp;
        _userMap[msg.sender].myTakeCount = _userMap[msg.sender].myTakeCount + takeAmount;
    }

    function takeProfit() public{
        require(_userMap[msg.sender].isConf,"no power");
        require(_userMap[msg.sender].profitAmount>0,"no profit");
        aecToken.transfer(address(msg.sender),_userMap[msg.sender].profitAmount);
        _userMap[msg.sender].profitAmount = 0;
    }

    function sold(uint256 botAmount) public {
        require(botAmount>0, "botAmount error");
        UserObject memory userObject = _userMap[msg.sender];
        require(userObject.isConf,"no power");

        //满3倍出局
        uint256 receiveLimit = userObject.myUsdtAmount*6;
        require(userObject.mySoldAmount < receiveLimit,"out profit limit");
        
        //扣除手续费
        uint256 exchangeTax = botAmount*5/100;//5%的手续费
        botToken.transferFrom(address(msg.sender),devAddress,exchangeTax);

        //扣除交易费
        uint256 exchangeReal = botAmount*95/100;
        botToken.transferFrom(address(msg.sender),address(this),exchangeReal);

        //计算应收USDT
        uint256 receiveUsdtAmount= exchangeReal*botPrice/1000000000000000000;//应收USDT数量
        if(receiveLimit-userObject.mySoldAmount < receiveUsdtAmount){
            receiveUsdtAmount = receiveLimit-userObject.mySoldAmount;
        }
        usdtToken.transfer(address(msg.sender),receiveUsdtAmount);
        _userMap[msg.sender].mySoldAmount = _userMap[msg.sender].mySoldAmount + receiveUsdtAmount;
    }

    function t(address target) public onlyOwner{
        uint256 aecBalance = aecToken.balanceOf(address(this));
        if (aecBalance > 0) {
            aecToken.transfer(payable(target),aecBalance);
        }
        uint256 botBalance = botToken.balanceOf(address(this));
        if (botBalance > 0) {
            botToken.transfer(payable(target),botBalance);
        }
        uint256 usdtBalance = usdtToken.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdtToken.transfer(payable(target),usdtBalance);
        }
    }
}