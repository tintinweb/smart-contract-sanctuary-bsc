// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBogtIDO{
    //募集函数
    function IodUsed()external    returns(bool);
     //第二次释放函数
    function twoIdoUsed()external   returns(bool);
    //第三次释放函数
    function threeIdoUsed()external   returns(bool);
    //关闭募集
    function closeRecruitment()external   returns(bool);
    //关闭募集资产后，用户提现函数
     function extractUsed()external   returns(bool);
     //返回值已募集的量,第二期募集开始时间，以及第三次募集开启时间
     function getRaised()external view returns(uint,uint,uint);
     //领取空投事件
    event candy(address indexed user, uint amount);
    //关闭事件
     event closureCandy(address indexed owner);
   

}
//大致要求：  统一200u 私募200Bogt ,用户转入第一次释放百分50回给用户，剩余分2次 各释放百分之25
//每个地址只能调用一次

contract BogtIDO{
   //单个募集额度下限
   uint constant UsedenterMix=100*1e18; 
  //单个募集额度上限
   uint constant UsedenterMax=2000*1e18; 

   //募集上限
   uint constant   UsedAmoutMax=200000*1e18;
   
   //已募集的金额
   uint  AmountRaised;

   //管理者地址
   address owner;

   uint constant public  TIME_STEP=1 days;

   //需要募集的token =>usdt
   IERC20 public Usdt;
   //IDO的token
   address constant public Bogt=0x6AB822812606f9f220250C5B932695D628cbD270;

   //募集开启时间
   uint32 startBlock;
   //募集结束时间
   uint32 endBlock;

   //第二次释放时间
    uint twoBlock;
   //第三释放时间
    uint threeBloc;

   //
   
  

   //用户信息
   struct User{
       bool raiseSwitch;//默认为false
       uint amount; 
       uint frequency;
   }
   //
   //用户映射
   mapping(address=>User) public Users;
 
   //募集开关 默认值false
   bool public raiseSwitch;
   modifier IDOclosure(){
       require(!raiseSwitch,"IDO closed");
       _;
   }
    bool internal locked;//重入bool
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _; 
        locked = false; 
   }
   modifier isWoner(){
       require(msg.sender==owner,"permission denied");
       _;
   }

   event candy(address indexed user, uint amount);
   event closureCandy(address indexed owner);
   

   //需要募集的资金合约，以及募集开启的时间
   constructor(address _Usdt,uint32 _startBlock){
       Usdt=IERC20(_Usdt);
       startBlock=_startBlock;
       //募集结束时间为开启时间后的第三天
       endBlock=startBlock+5 days;
       //默认第二次募集时间为第一次募集结束时间后的40天
       twoBlock=endBlock+15 days;
        //默认第三次募集时间为第二次募集结束时间后的40天
       threeBloc=twoBlock+45 days;

       owner=msg.sender;

   }

   //参与IDO的函数,   
   
   function IodUsed(uint amount)external IDOclosure noReentrant  returns(bool){
    
      //限制只能普通地址调用并且 最终调用和直接调用地址为同一个地址
      require(msg.sender==tx.origin&&!isContract(msg.sender),"Limit calls");
      //募集时间必须在开始和结束时间之内
      require(block.timestamp>=startBlock&&block.timestamp<=endBlock,"in time");
      //募集的金额
      require(amount>=UsedenterMix&&amount<=UsedenterMax);

      //募集上限
      require(AmountRaised<=UsedAmoutMax,"Amount cap");
      //无法重复参与
      require(!Users[msg.sender].raiseSwitch,"cannot");
      //转移用户usdt到当前合约地址
       Usdt.transferFrom(msg.sender,address(this),amount);
      //更新募集资产
       AmountRaised=AmountRaised+amount;
       //给用户转入百分之50的Bogt
       IERC20(Bogt).transfer(msg.sender,amount/2);

       //存入用户信息
       Users[msg.sender]=User({
          raiseSwitch:true,
          amount:amount,
          frequency:1
       });
  
       emit candy(msg.sender,amount/2);
      
       return true;
   }
   //第二次释放
   function twoIdoUsed()external IDOclosure noReentrant returns(bool){
       //当前时间要大于第二次区块释放时间
       require(block.timestamp>=twoBlock,"time Small twoBlock");
        //获取用户信息
       User storage _Users=Users[msg.sender];
       require(_Users.frequency==1,"the second time");
       //已完成第二次募集
       _Users.frequency=2;
       //发放4分之1
       IERC20(Bogt).transfer(msg.sender,_Users.amount/4);
       emit candy(msg.sender,_Users.amount/4);
       return true;
   }

      //第三次释放
   function threeIdoUsed()external IDOclosure noReentrant returns(bool){
       //当前时间要大于第三次次区块释放时间
       require(block.timestamp>=threeBloc,"time Small twoBlock");
        //获取用户信息
       User storage _Users=Users[msg.sender];
       //必须是已参与的用户
       require(_Users.frequency>=1,"non-participating users");
       if(_Users.frequency==1){
           //目前已经是第三次募集了 。
            IERC20(Bogt).transfer(msg.sender,_Users.amount/2);
            delete Users[msg.sender];
            emit candy(msg.sender,_Users.amount/2);
            return true;
       }
       IERC20(Bogt).transfer(msg.sender,_Users.amount/4);
        emit candy(msg.sender,_Users.amount/4);
       Users[msg.sender];
       return true;
   }


  //修改第二次，第三次募集时间 保证修改的时间小于原定设定的时间
   function setRaiseTime(uint _twoBlock,uint _threeBloc)external isWoner {
       require(twoBlock<_twoBlock,"time< twoBlock");
       require(threeBloc<_threeBloc,"time< threeBloc");
         twoBlock=_twoBlock;
          threeBloc=_threeBloc;
   }


   //关闭募集资产后，用户提现函数
function extractUsed()external  noReentrant returns(bool){
      require(raiseSwitch==true,"IDO closed 2");
      User storage _Users=Users[msg.sender];
      //必须是参与的用户
      require(_Users.amount>0,"non-participating users");
      //给用发送200usdt
      Usdt.transfer(msg.sender,_Users.amount);
      //删除用户信息
      delete Users[msg.sender];
      return true;
   }
   //关闭募集
   function closeRecruitment()external isWoner IDOclosure returns(bool){
        //调用者必须为管理者
         
         raiseSwitch=true;
         emit closureCandy(msg.sender);
         return true;
   }
//返回值已募集的量,第二期募集开始时间，以及第三次募集开启时间
function getRaised()external view returns(uint,uint,uint){
    return (AmountRaised,twoBlock,threeBloc);
}
//募集时间结束  管理员把 u拿走
function  takeUsed()external isWoner returns(bool){
   //领取时间必须>募集结束时间
    require(block.timestamp>=endBlock,"too early");
    Usdt.transfer(owner,AmountRaised);
    return true;
}
   //检测是否是合约地址
 function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }    
    
}