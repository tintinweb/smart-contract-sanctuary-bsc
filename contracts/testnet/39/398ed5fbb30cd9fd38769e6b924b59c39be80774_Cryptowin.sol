/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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

contract Cryptowin is Ownable {
    using SafeMath for uint256;

    IBEP20 public platformToken = IBEP20(0xF59F977F9E018e4048BF637fdf97E2F2132Cd682);
    IBEP20 public usdtToken = IBEP20(0xb5Af8648EfF53FdAA680552Ef564c1F79d321a34);
    address private masterAddr = 0xA41d4e94861D5415B9070F964f98D290E3CbD95B;
    
    mapping(address => UserData) public userMap;
    uint256 public totalAmount = 6000000 * 10**18;//总供应数量  测试少10倍
    uint256 public levelAmount = 1000000 * 10**18;//每层总供应数量 测试少10倍
    uint256 public areaValue = 10000 * 10**18;//一个小区间是10000U
    uint256 public bigAreaValue = 100000 * 10**18;//一个大区间是100000U
    uint256 public soldValue = 0;//已售金额
    uint256 public soldAmount = 0;//已售数量
    uint256 public curMaxValue4 = 0;//当前小区间最大金额
    address public curMaxAddress4 = address(0);//当前小区间最大金额地址
    uint256 public curMaxValue5 = 0;//当前大区间最大金额
    address public curMaxAddress5 = address(0);//当前大区间最大金额地址
    uint256 public startTime = 1664032767;
    uint256 public endTime =   1668032767;
    RecordData[] public recordList;
    
    struct UserData {
        uint256 inviteNum;//邀请总人数
        uint256 profitUsdt0;//直推奖励USDT数量
        uint256 joinUsdt;//总投入USDT
        uint256 joinTimes;//总参与次数
        uint256 getAmount;//获得代币数
        uint256 winTimes;//中奖次数
        uint256 winUsdt;//中奖总金额USDT
        address parent;//上级
    }

    struct RecordData {
        address target;
        uint256 rtype;//1、原点将，2、1000U，3、10000U，4、1000U，5、10000U,6、450000U
        uint256 profit;//奖金
        uint256 time;
    }
    
    function checkParent(address target,address parent) public view returns (bool) {
        if(userMap[target].parent != address(0) || target == address(0) || parent == address(0) || parent == target){
            return false;
        }
        address tmp = parent;
        while (userMap[tmp].parent != address(0)) {
            tmp = userMap[tmp].parent;
            if(tmp == target){
                // 不允许闭环绑定
                return false;
            }
        }
        return true;
    }

    function bindParent(address parent) public {
        require(checkParent(msg.sender,parent), "cannot bound");
        userMap[msg.sender].parent = parent;
        userMap[parent].inviteNum = userMap[parent].inviteNum + 1;
    }

    
    //获取当前层剩余代币总数
    function getCurBalance() public view returns(uint256){
        return levelAmount - soldAmount % levelAmount;
    }
    //获取当前层编号
    function getCurLevel() public view returns(uint256){
        return 1 + soldAmount / levelAmount;
    }

    function join(uint256 usdtAmount) public{
        require(usdtAmount >= 10 * 10**18 && usdtAmount <= areaValue,"params error");
        require(totalAmount - soldAmount >= 10**18,"sold out");
        require(userMap[msg.sender].parent != address(0),"need bind parent first");
        require(block.timestamp > startTime && block.timestamp < endTime,"out of time");
        uint256 curLevel = getCurLevel();
        require(curLevel <= 6,"params error");
        if(soldValue == 0){
            //获得原点奖励
            sendProfit(msg.sender,1);
        }
        uint256 curPrice =(5+curLevel-1) * 10**16;
        uint256 curAmount = getCurBalance();
        uint256 curValue = curAmount * curPrice / 10**18;
        uint256 realAmount = 0;
        uint256 realValue = 0;
        if(usdtAmount <= curValue){
            realValue = usdtAmount;
            realAmount = usdtAmount * 10**18 / curPrice;
        }else{
            if(curLevel == 6){
                realValue = curValue;
                realAmount = curAmount;
            }else{
                uint256 nextPrice = curPrice + 10**16;
                realValue = usdtAmount;
                realAmount = curAmount + (usdtAmount - curValue) * 10**18 / nextPrice;
            }
        }

        //USDT转进，TOKEN转出
        usdtToken.transferFrom(address(msg.sender),address(this),realValue);
        platformToken.transfer(address(msg.sender),realAmount);
        userMap[msg.sender].joinUsdt = userMap[msg.sender].joinUsdt + realValue;
        userMap[msg.sender].joinTimes = userMap[msg.sender].joinTimes + 1;
        userMap[msg.sender].getAmount = userMap[msg.sender].getAmount + realAmount;

        uint256 curAreaBalance = areaValue - soldValue % areaValue;
        if(realValue < curAreaBalance){
            //小区间未满，不开奖，更新小区间、大区间最大值和地址
            if(realValue >= curMaxValue4){
                curMaxValue4 = realValue;
                curMaxAddress4 = msg.sender;
            }
            if(realValue >= curMaxValue5){
                curMaxValue5 = realValue;
                curMaxAddress5 = msg.sender;
            }
        }else{
            //小刻度奖
            sendProfit(msg.sender,2);
            //小区间满了，开奖，更新下个小区间的最大值和地址
            if(curAreaBalance >= curMaxValue4){
                // 当前区间小奖归我
                sendProfit(msg.sender,4);
            } else {
                // 当前区间小奖归别人
                sendProfit(curMaxAddress4,4);
            }
            curMaxValue4 = realValue - curAreaBalance;
            curMaxAddress4 = msg.sender;

            uint256 oldMultiples = soldValue / bigAreaValue;
            uint256 newMultiples = (soldValue + realValue) / bigAreaValue;
            //是否越过10w刻度
            if(newMultiples > oldMultiples){
                //大刻度奖
                sendProfit(msg.sender,3);
                //大区间满了，开奖，更新下个大区间最大值和地址
                if(curAreaBalance >= curMaxValue5){
                    // 当前大区间将归我
                    sendProfit(msg.sender,5);
                }else{
                    // 当前大区间将归别人
                    sendProfit(curMaxAddress5,5);
                }
                curMaxValue5 = realValue - curAreaBalance;
                curMaxAddress5 = msg.sender;
            }else{
                if(realValue >= curMaxValue5){
                    curMaxValue5 = realValue;
                    curMaxAddress5 = msg.sender;
                }
            }
        }
        
        soldValue = soldValue + realValue;
        soldAmount = soldAmount + realAmount;

        address parent = userMap[msg.sender].parent;
        if(parent != address(0) && userMap[parent].joinUsdt > 0){
            //奖励直推30%
            uint256 profitUsdt = realValue * 3 / 10;
            usdtToken.transfer(address(parent),profitUsdt);
            userMap[parent].profitUsdt0 = userMap[parent].profitUsdt0 + profitUsdt;

            usdtToken.transfer(masterAddr,realValue * 2 / 10);
        }else{
            usdtToken.transfer(masterAddr,realValue * 5 / 10);
        }

        //计算最终奖
        sendProfit(msg.sender,6);
    }

    function sendProfit(address target,uint256 rtype) private{
        uint256 profitAmount = 0;
        if(rtype == 1 || rtype == 2 || rtype == 4){
            profitAmount = 1000 * 10**18;
        }else if(rtype == 3 || rtype == 5){
            profitAmount = 10000 * 10**18;
        }else{
            if(totalAmount - soldAmount < 10**18){
                profitAmount = usdtToken.balanceOf(address(this));
            }
        }
        if(profitAmount>0){
            usdtToken.transfer(address(msg.sender),profitAmount);
            RecordData memory recordData = RecordData({target:target,rtype:rtype,profit:profitAmount,time:block.timestamp});
            recordList.push(recordData);
        }
    }

    function getData() public view returns(uint256,uint256,uint256,uint256){
        return (soldValue,soldAmount,startTime,endTime);
    }

    function setData(uint256 _startTime,uint256 _endTime) public onlyOwner{
        require(_endTime > _startTime,"param error");
        startTime = _startTime;
        endTime = _endTime;
    }

    function getUserData(address userAddress) public view returns(UserData memory){
        return userMap[userAddress];
    }
    function getRecordData() public view returns (RecordData[] memory){
        return recordList;
    }

    function t() public onlyOwner{
        uint256 usdtBalance = usdtToken.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdtToken.transfer(address(msg.sender), usdtBalance);
        }
        uint256 tokenBalance = platformToken.balanceOf(address(this));
        if (tokenBalance > 0) {
           platformToken.transfer(address(msg.sender), tokenBalance);
        }
    }
}