/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
}
contract Lunarsanek {
   address admin=msg.sender;
   uint Dw;  //提现开关；
   mapping(address => uint256) userTeg;
   mapping(bytes4 => address) public I2A;
   mapping(address => bytes4) public A2I;
   mapping(uint256 => address) public UT2A;
   mapping(address => address) myinv;
   mapping(address=>uint256) invcount;
   mapping(address=>uint256) invs;
   mapping(address=>uint256) public lastMind;   //最后挖矿时间
   mapping(address=>uint256) public mindCount;  //挖矿收益
   uint256 day;
   uint256 startTime;
   uint256 users=0;
   uint256[][] unlist;
   uint256[][][] incomeRecord;   //时间，数量，收入类型 0挖矿，1推荐,提现
   address lunarsanek;
   ERC20Interface dargonLP=ERC20Interface(address(0x8b96d8C12D0b69B2389AF4e7885B06B2c034Ffcb));
   ERC20Interface rabbitLP=ERC20Interface(address(0x16Fa2762Fd0a9148679b38e7C2D44E3288EA34Ac)); 
   ERC20Interface snake;
   uint256 dargonleft=2500000000*1e18; 
   uint256 rabbitleft=1500000000*1e18;
   uint256 dargonPer=2500000000*1e18/200; 
   uint256 rabbitPer=1500000000*1e18/200;
   address _snake;    

   constructor() {
     I2A[0x0000000]=admin;
     A2I[admin]=0x00000000;
       UT2A[0]=admin;
       userTeg[admin]=0;
       incomeRecord.push();  
       unlist.push(); 
       myinv[admin]=admin;
   }
       receive() external payable{}
       modifier onlyOwner() {
       require(admin == msg.sender, "!owner");
       _;
   }

   function reg(bytes4 icode,address _us)public{

       require(userTeg[_us]==0&&_us!=admin, "unreg");    
       users+=1;
       bytes4 invcode1=bytes4(keccak256(abi.encode(_us,"lunar")));
       I2A[invcode1]=_us;
       A2I[_us]=invcode1;
       UT2A[users]=_us;
       userTeg[_us]=users;
       if(I2A[icode]==address(0)){
       icode=0x00000000;
       }
       myinv[_us]=I2A[icode];
       unlist.push();
       unlist[userTeg[myinv[_us]]].push(users);
       invs[myinv[_us]]+=1;
       incomeRecord.push();
       
   }

   function getmy(address _us)public view returns(address){
       return(myinv[_us]);
   }

   function ckreg(address _us)public view returns(uint256){
       return(userTeg[_us]);
   }

   function getinvlist(address _us,uint256 teg)public view returns(address){
   return( UT2A[unlist[userTeg[_us]][teg]]);
   }

   function getInvcount(address _us)public view returns(uint256){
       return(unlist[userTeg[_us]].length);
   } 

   function getmyInvCode(address _us)public view returns(bytes4){
       return(A2I[_us]);
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
         day=(block.timestamp-startTime)/86400;
        require(lastMind[msg.sender] < startTime+day*86400 , "mined");     
        lastMind[msg.sender]=block.timestamp;
        if(dargonPer>=dargonleft){
            dargonPer=dargonleft;
        }
        if(rabbitPer>=rabbitleft){
            rabbitPer=rabbitleft;
        } 
        uint256 Dpr=dargonLP.balanceOf(msg.sender)*100000000000000/dargonLP.totalSupply();
        uint256 Rpr=rabbitLP.balanceOf(msg.sender)*100000000000000/rabbitLP.totalSupply();
        if(Dpr!=0){
        mindCount[msg.sender]+=dargonPer*Dpr/100000000000000; 
        incomeRecord[userTeg[msg.sender]].push([block.timestamp,dargonPer*Dpr/100000000000000,0]);  
        dargonleft-=dargonPer*Dpr/100000000000000;

        address inv=myinv[msg.sender];
        if(inv!=admin){
        uint256 Dpr1=dargonLP.balanceOf(inv)*100000000000000/dargonLP.totalSupply();
        if(Dpr/Dpr1<10){
        mindCount[inv]+=((dargonPer*Dpr/100000000000000)*20/100)/2;
        incomeRecord[userTeg[inv]].push([block.timestamp,((dargonPer*Dpr/100000000000000)*20/100)/2,1]);  
        dargonleft-=((dargonPer*Dpr/100000000000000)*20/100)/2;   
        }

        inv=myinv[inv];
        if(inv!=admin){
        Dpr1=dargonLP.balanceOf(inv)*100000000000000/dargonLP.totalSupply();
        if(Dpr/Dpr1<10){
        mindCount[inv]+=((dargonPer*Dpr/100000000000000)*20/100)*3/10;
        incomeRecord[userTeg[inv]].push([block.timestamp,((dargonPer*Dpr/100000000000000)*20/100)*3/10,1]);  
        dargonleft-=((dargonPer*Dpr/100000000000000)*20/100)*3/10;   
        }

        inv=myinv[inv];
        if(inv!=admin){
        Dpr1=dargonLP.balanceOf(inv)*100000000000000/dargonLP.totalSupply();
        if(Dpr/Dpr1<10){
        mindCount[inv]+=((dargonPer*Dpr/100000000000000)*20/100)*2/10;
        incomeRecord[userTeg[inv]].push([block.timestamp,((dargonPer*Dpr/100000000000000)*20/100)*2/10,1]);  
        dargonleft-=((dargonPer*Dpr/100000000000000)*20/100)*2/10;   
        }}}}}

        if(Rpr!=0){
        mindCount[msg.sender]+=rabbitPer*Rpr/100000000000000; 
        incomeRecord[userTeg[msg.sender]].push([block.timestamp,rabbitPer*Rpr/100000000000000,0]);  
        rabbitleft-=rabbitPer*Rpr/100000000000000;

        address inv=myinv[msg.sender];
        if(inv!=admin){
        uint256 Rpr1=rabbitLP.balanceOf(inv)*100000000000000/rabbitLP.totalSupply();
        if(Rpr/Rpr1<10){
        mindCount[inv]+=((rabbitPer*Rpr/100000000000000)*20/100)/2;
        incomeRecord[userTeg[inv]].push([block.timestamp,((rabbitPer*Rpr/100000000000000)*20/100)/2,1]);  
        rabbitleft-=((rabbitPer*Dpr/100000000000000)*20/100)/2;   
        }

        inv=myinv[inv];
        if(inv!=admin){
        Rpr1=rabbitLP.balanceOf(inv)*100000000000000/rabbitLP.totalSupply();
        if(Rpr/Rpr1<10){
        mindCount[inv]+=((rabbitPer*Rpr/100000000000000)*20/100)*3/10;
        incomeRecord[userTeg[inv]].push([block.timestamp,((rabbitPer*Rpr/100000000000000)*20/100)*3/10,1]);  
        rabbitleft-=((rabbitPer*Rpr/100000000000000)*20/100)*3/10;   
        }

        inv=myinv[inv];
        if(inv!=admin){
        Rpr1=rabbitLP.balanceOf(inv)*100000000000000/rabbitLP.totalSupply();
        if(Rpr/Rpr1<10){
        mindCount[inv]+=((rabbitPer*Rpr/100000000000000)*20/100)*2/10;
        incomeRecord[userTeg[inv]].push([block.timestamp,((rabbitPer*Rpr/100000000000000)*20/100)*2/10,1]);  
        rabbitleft-=((rabbitPer*Rpr/100000000000000)*20/100)*2/10;   
        }}}}}
    }


    function wds()public{
       require(Dw==1, "unWd");
       ERC20Interface snakes=ERC20Interface(address(_snake)); 
       snakes.transfer(msg.sender,mindCount[msg.sender]); 
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
       ERC20Interface snakes=ERC20Interface(address(_snake)); 
       snakes.transfer(_us,_count); 
    } 
}