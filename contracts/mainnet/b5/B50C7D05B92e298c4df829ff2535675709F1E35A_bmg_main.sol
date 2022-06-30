/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);     //查看转出的额度   owner 从spender 账号额度

    function approve(address spender, uint value) external returns (bool);               //授权spender 可以转出多少
    function transfer(address to, uint value) external returns (bool);                   //转出到to多少
    function transferFrom(address from, address to, uint value) external returns (bool);  //从from 给 to 转出多少
    
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
}
//结构体
struct  allowanceOne{
    address  to;                        //授权给某人
    uint  i;                           //剩下数量
}
//锁定对象结构体
struct lockOne{
    uint nowClockSum;                         //现在还有锁定数量
    uint allClockSum;                         //初始化总锁定数
    uint cTime;                               //初始化锁定时间
}
//锁定策略结构体
struct lockSetuOne{
    uint timeLength;                          //从一开始到现在时长 单位秒
    uint intVal;                             //释放万分比
}



contract bmg_main is ERC20{
    string public name;                            //带币名称
    uint8 public decimals;                        //小数位置
    string public symbol;                        //缩写
    uint public totalSupply;                     //总数
    mapping(address=>uint) public allData;      //保持所有人币
    //发行持有初始化地址： 
    //IDO：0xaD35740e0e5aa24F16270D399FcEb961573b31c3    4%
    //私募：0xFB4C6a7FDAe51ECFde7180Fd9Ae9A56E936caBB1   2%
    //机构：0x9DD01d1d7Efbf6aa642A4c8e239E0602f9005aB1   5%
    //流动性挖矿：0xFD2bBc0a70e0ceb5ACd80F64d4f3Ea64272ea820   10%
    //游戏产出：0xc6aF9E2f39e9f74883E1acD8128dDf9eE60e33e8   59%
    //赛事活动：0x556Bfd377a8DB3a43d6dB6E8e64FCa246933a139   8%
    //战略合作：0x67b93CD00756b6E38184dC86686d6943D55B7369   5%
    //DAO金库：0x96f6568db82B1EBBBfdEA888975FC08dD1A65C53    5%
    //技术：0x16c896da547E2200F25a5BBC6f1230f7Bd978380       2%

    mapping(string=>address) public hasSetup;    //={0xaD35740e0e5aa24F16270D399FcEb961573b31c3}
    
    uint constant ALLINT=2000000000;                              //发布总数

    mapping(address=>allowanceOne[]) public allowanceData;        //允许转出的他们的额度
    uint public cTime;                                            //合约发布时间
    address public mainAddress;                                   //合约发布者地址
    mapping(address=>lockOne) public lockBufferInfo;              //锁定对象池

    uint constant simuAllFreeTime=3600*24*7;                      //总解禁时间 单位秒
    lockSetuOne[] public lockTimeSetup;                            //在未总解禁逐步解禁的的设置  


    constructor (){                             //构造函数
        mainAddress =msg.sender;                //合约生产者地址
        cTime=block.timestamp;                  //赋值合约生产时间
        symbol="BMG";                           //币缩写
        name="BMG";                         
        decimals=18; 
        totalSupply=ALLINT;                //20亿

        //私募解禁策略配置

        lockTimeSetup.push(lockSetuOne(30*60,500));              //半个小时释放 5%
        lockTimeSetup.push(lockSetuOne(60*60*3,500));            //三个小时释放 5%
        lockTimeSetup.push(lockSetuOne(60*60*24,500));           //24个小时释放 5%
        lockTimeSetup.push(lockSetuOne(60*60*24*6,500));         //6天释放 5%


        
        hasSetup["IDO"]=0xaD35740e0e5aa24F16270D399FcEb961573b31c3;
        hasSetup["SIMU"]=0xFB4C6a7FDAe51ECFde7180Fd9Ae9A56E936caBB1;
        hasSetup["JIGUO"]=0x9DD01d1d7Efbf6aa642A4c8e239E0602f9005aB1;
        hasSetup["WAGUANG"]=0xFD2bBc0a70e0ceb5ACd80F64d4f3Ea64272ea820;
        hasSetup["GAMEFI"]=0xc6aF9E2f39e9f74883E1acD8128dDf9eE60e33e8;
        hasSetup["HUODONG"]=0x556Bfd377a8DB3a43d6dB6E8e64FCa246933a139;
        hasSetup["HEZUO"]=0x67b93CD00756b6E38184dC86686d6943D55B7369;
        hasSetup["BAO"]=0x96f6568db82B1EBBBfdEA888975FC08dD1A65C53;
        hasSetup["JISHU"]=0x16c896da547E2200F25a5BBC6f1230f7Bd978380;

        //分配金币
        allData[hasSetup["IDO"]]=ALLINT/100*4*1000000000000000000;
        allData[hasSetup["SIMU"]]=ALLINT/100*2*1000000000000000000;
        allData[hasSetup["JIGUO"]]=ALLINT/100*5*1000000000000000000;       
        allData[hasSetup["WAGUANG"]]=ALLINT/100*10*1000000000000000000;
        allData[hasSetup["GAMEFI"]]=ALLINT/100*59*1000000000000000000;
        allData[hasSetup["HUODONG"]]=ALLINT/100*8*1000000000000000000;
        allData[hasSetup["HEZUO"]]=ALLINT/100*5*1000000000000000000;
        allData[hasSetup["BAO"]]=ALLINT/100*5*1000000000000000000;
        allData[hasSetup["JISHU"]]=ALLINT/100*2*1000000000000000000;        
        //allData[msg.sender]=2000000000*1000000000000000000;
    }
    //获得她的币
    function balanceOf(address addressId) public view returns(uint){
        return allData[addressId];
    }
    function allowance(address owner, address spender) external view returns (uint){            //查看转出的额度   owner 从spender 账号额度
        uint rInt=0;
        if(allowanceData[owner].length>0){
            allowanceOne[] storage thisdata=allowanceData[owner];
            uint ll=uint( thisdata.length);
            for (uint i=0;i<ll;i++){
               allowanceOne storage thisOne= thisdata[i];
               if(thisOne.to==spender){
                   rInt=thisOne.i; 
                   break;
               }
            }
        }
        return rInt;
    }
    function approve (address spender, uint value) external  returns (bool){               //授权spender 可以转出多少
        address from =msg.sender;
        if(allowanceData[from].length>0){
            bool isState=true;

            allowanceOne[] storage thisdata=allowanceData[from];
            uint ll=uint( thisdata.length);
            for (uint i=0;i<ll;i++){
               allowanceOne storage thisOne= thisdata[i];
               if(thisOne.to==spender){
                   thisOne.i+=value;
                   isState =false;  
                   break;
               }
            }
            if(isState){
                allowanceOne memory aa;
                aa.to=spender;
                aa.i=value;
                allowanceData[from].push(aa);
            }
        }else{

            allowanceOne memory aa;
            aa.to=spender;
            aa.i=value;
            allowanceData[from].push(aa);
        }
        return true;
    }
    //转账
    function transfer(address to, uint value) external returns (bool){
        address from =msg.sender;                          //发自那个Address
        
        uint nowTime=block.timestamp;                      //区块链上时间
     
        address simuAddress=hasSetup["SIMU"];              //私募id

        if(from ==simuAddress){                            //如果是私募发出的币，锁定了周期
            if(allData[from]>=value){                      
                allData[from]-=value;
                allData[to]+=value;
                lockOne memory co=lockOne(value,value,block.timestamp);     //生成锁定时间
                lockBufferInfo[to]=co;
                return true;
            }else{
                return false;
            }
        }else{
            lockOne memory thisCo= lockBufferInfo[from];
            if(thisCo.nowClockSum>0){             //有锁定的数量
                //计算现在可以转移的币

                uint timeLength=nowTime-thisCo.cTime;             //秒时长   
                
                if(timeLength<simuAllFreeTime){                   //未全部解禁
                    uint getMoveInt=0;                            //可以转移的万分比
                    for(uint i=0;i<lockTimeSetup.length;i++){
                       lockSetuOne memory thislockSetuOne=lockTimeSetup[i] ;
                       if(thislockSetuOne.timeLength<=timeLength){
                           getMoveInt+=thislockSetuOne.intVal;
                       }else{
                           break;
                       }
                    }
                    uint allowMoveInt=thisCo.allClockSum/10000*getMoveInt;      //可以转移的总数    
                    uint oldInt =allData[from];                                 //本身自带币               
                    if ((oldInt-value)>=(thisCo.allClockSum-allowMoveInt)){
                        if(allData[from]>=value){
                            allData[from]-=value;
                            allData[to]+=value;
                            return true;
                        }else{
                            return false;
                        }
                    }else{ 
                        return false;
                    }
                }else{    //已经全部是释放了
                    thisCo.nowClockSum=0;                   //以免下次再检测
                    if(allData[from]>=value){
                        allData[from]-=value;
                        allData[to]+=value;
                        return true;
                    }else{
                        return false;
                    }
                }
            }else{              //没有锁定币
                if(allData[from]>=value){
                    allData[from]-=value;
                    allData[to]+=value;
                    return true;
                }else{
                    return false;
                }
            }
        }
    }
    function transferFrom(address from, address to, uint value) external returns (bool){  //从from 给 to 转出多少
        if(allData[from]>=value){
           allData[from]-=value;
           allData[to]+=value;
           return true;
        }else{
            return false;
        }
    }
    function kill() public{                              //析构函数调用
        if(msg.sender==mainAddress){
            selfdestruct(payable(mainAddress));
        }
    }
}