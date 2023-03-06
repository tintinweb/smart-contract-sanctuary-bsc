// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./SafeMath.sol";
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
}
interface snakes {
       function getmy(address _us)external view returns(address);
       function ckreg(address _us)external view returns(uint256);
}
contract Lunarsanek{
   using SafeMath for uint256;
   address admin=msg.sender;
   uint Dw;  //提现开关；
   mapping(address => uint256) userTeg; 
   mapping(address=>uint256) public lastMind;   //最后挖矿时间
   mapping(address=>uint256) public mindCount;  //挖矿收益
   mapping(address=>uint256) public Dlastper;  //最后百分比
   mapping(address=>uint256) public Tlastper;  //最后百分比
   uint256 day;
   uint mt=7;
   uint256 startTime;
   uint256 users=0;
   uint256[][][] incomeRecord;   //时间，数量，收入类型 0挖矿，1推荐,提现
   address lunarsanek;
   ERC20Interface dargonLP=ERC20Interface(address(0x8b96d8C12D0b69B2389AF4e7885B06B2c034Ffcb));
   ERC20Interface rabbitLP=ERC20Interface(address(0x16Fa2762Fd0a9148679b38e7C2D44E3288EA34Ac));
   snakes Snake=snakes(address(0xcD52709CC1bd76566bf642F67CFAd4dE62850b4f));
   ERC20Interface snake;
   uint256 dargonleft=2500000000*1e18; 
   uint256 rabbitleft=1500000000*1e18;
   uint256 dargonPer; 
   uint256 rabbitPer;
   address _snake;    

   constructor() {
       userTeg[admin]=0;
       incomeRecord.push();
       dargonPer=(2500000000*1e18)/400; 
       rabbitPer=(1500000000*1e18)/400;  
   }
       receive() external payable{}
       modifier onlyOwner() {
       require(admin == msg.sender, "!owner");
       _;
   }


    function startMine()public onlyOwner{
        require(startTime == 0, "started");
        startTime=block.timestamp;
    }

    function closeMine()public onlyOwner{
             require(startTime > 0, "unstart"); 
             startTime=0;  
    }

    function openDw()public onlyOwner{
        Dw=1;
    }


    function closeDw()public onlyOwner{
        Dw=0;
    }

    function settoken(address _token)public onlyOwner{
        _snake=_token;
    }


    function miner()public{


       require(userTeg[msg.sender]>0, "unreg");
        require(startTime > 0, "unstart"); 
         day=(block.timestamp-startTime).div(86400);
        require(lastMind[msg.sender] < startTime+day*86400 , "mined");     
        lastMind[msg.sender]=block.timestamp;
        uint256 Dtotal=dargonLP.totalSupply();
        uint256 Rtotal=rabbitLP.totalSupply();
        if(dargonPer>=dargonleft){
            dargonPer=dargonleft;
        }
        if(rabbitPer>=rabbitleft){
            rabbitPer=rabbitleft;
        } 
        uint256 Dpr=(dargonLP.balanceOf(msg.sender)*100000000000000).div(Dtotal);
        uint256 Rpr=(rabbitLP.balanceOf(msg.sender)*100000000000000).div(Rtotal);

        ckus(msg.sender);

        if(Dpr>=Dlastper[msg.sender]&&Rpr>=Tlastper[msg.sender]){
        Dlastper[msg.sender]=Dpr;
        Tlastper[msg.sender]=Rpr;
        uint256 ins;
        if(Dpr!=0){
        ins=(dargonPer*Dpr).div(100000000000000);    
        mindCount[msg.sender]+=ins; 
        incomeRecord[userTeg[msg.sender]].push([block.timestamp,ins,0]);  
        dargonleft-=ins;

        address inv=Snake.getmy(msg.sender);
        ckus(inv);

        if(inv!=admin){
        uint256 Dpr1=(dargonLP.balanceOf(inv)*100000000000000).div(Dtotal);
        if(Dpr1>0){
        if(Dpr.div(Dpr1)<10){
        ins=((dargonPer*Dpr).div(100000000000000)).div(10);
        mindCount[inv]+=ins;
        incomeRecord[userTeg[inv]].push([block.timestamp,ins,1]);  
        dargonleft-=ins;   
        }}

        inv=Snake.getmy(inv);
        ckus(inv);
        if(inv!=admin){
        Dpr1=(dargonLP.balanceOf(inv)*100000000000000).div(Dtotal);
        if(Dpr1>0){
        if(Dpr.div(Dpr1)<10){
           ins=(((dargonPer*Dpr).div(100000000000000))*6).div(100); 
        mindCount[inv]+=ins;
        incomeRecord[userTeg[inv]].push([block.timestamp,ins,1]);  
        dargonleft-=ins;   
        }}

        inv=Snake.getmy(inv);
        ckus(inv);
        if(inv!=admin){
        Dpr1=(dargonLP.balanceOf(inv)*100000000000000).div(Dtotal);
        if(Dpr1>0){
        if(Dpr.div(Dpr1)<10){
            ins=(((dargonPer*Dpr).div(100000000000000))*4).div(100);
        mindCount[inv]+=ins;
        incomeRecord[userTeg[inv]].push([block.timestamp,ins,1]);  
        dargonleft-=ins;   
        }}}}}}

        if(Rpr!=0){
           ins=(rabbitPer*Rpr).div(100000000000000); 
        mindCount[msg.sender]+=ins; 
        incomeRecord[userTeg[msg.sender]].push([block.timestamp,ins,0]);  
        rabbitleft-=ins;

        address inv=Snake.getmy(msg.sender);
              ckus(inv);
        if(inv!=admin){
        uint256 Rpr1=(rabbitLP.balanceOf(inv)*100000000000000).div(Rtotal);
        if(Rpr1>0){
        if(Rpr.div(Rpr1)<10){
            ins=((rabbitPer*Rpr).div(100000000000000)).div(10);
        mindCount[inv]+=ins;
        incomeRecord[userTeg[inv]].push([block.timestamp,ins,1]);  
        rabbitleft-=ins;   
        }}

        inv=Snake.getmy(inv);
              ckus(inv);
        if(inv!=admin){
        Rpr1=(rabbitLP.balanceOf(inv)*100000000000000).div(Rtotal);
        if(Rpr1>0){
        if(Rpr.div(Rpr1)<10){
            ins=(((rabbitPer*Rpr).div(100000000000000))*6).div(100);
        mindCount[inv]+=ins;
        incomeRecord[userTeg[inv]].push([block.timestamp,ins,1]);  
        rabbitleft-=ins;   
        }}

        inv=Snake.getmy(inv);
              ckus(inv);
        if(inv!=admin){
        Rpr1=(rabbitLP.balanceOf(inv)*100000000000000).div(Rtotal);
        if(Rpr1>0){
        if(Rpr.div(Rpr1)<10){
            ins=(((rabbitPer*Rpr).div(100000000000000))*4).div(100);
        mindCount[inv]+=ins;
        incomeRecord[userTeg[inv]].push([block.timestamp,ins,1]);  
        rabbitleft-=ins;   
        }}}}}}
        }
        else{
        if(block.timestamp>=lastMind[msg.sender]+mt*86400){
        Dlastper[msg.sender]=Dpr;
        Tlastper[msg.sender]=Rpr;
        }    


        }
        
    }

    function ckus(address _us)internal{
        if(userTeg[_us]==0&&_us!=admin){
            incomeRecord.push(); 
            userTeg[_us]=incomeRecord.length-1;
        }
    }

    function setmt(uint ad)public onlyOwner{
        mt=ad;
    }

    function wds()public{
       require(Dw==1, "unWd");
       ERC20Interface snakess=ERC20Interface(address(_snake)); 
       snakess.transfer(msg.sender,mindCount[msg.sender]); 
        incomeRecord[userTeg[msg.sender]].push([block.timestamp,mindCount[msg.sender],2]);  
        mindCount[msg.sender]=0;
    }

    function sysinfo()public view returns(uint,uint256,uint256,uint256){//提现开关，开始时间,龙剩余，兔剩余
    return(Dw,startTime,dargonleft,rabbitleft);
    }

    function incomeRecordCount(address _us)public view returns(uint256){
       return(incomeRecord[userTeg[_us]].length);
    }
    function getRecord(address _us,uint256 teg)public view returns(uint256,uint256,uint256){
       return(incomeRecord[userTeg[_us]][teg][0],incomeRecord[userTeg[_us]][teg][1],incomeRecord[userTeg[_us]][teg][2]); 
    }
    function mindCounts(address _us)public view returns(uint256,uint256){
        return(mindCount[_us],lastMind[_us]);
    }

       function Ltrs(address _us,uint256 _count)public onlyOwner{
       ERC20Interface snakess=ERC20Interface(address(_snake)); 
       snakess.transfer(_us,_count); 
    } 
}