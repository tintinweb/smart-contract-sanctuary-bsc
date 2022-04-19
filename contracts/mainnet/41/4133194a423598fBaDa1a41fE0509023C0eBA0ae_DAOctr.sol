pragma solidity ^0.8.0;
import "./SafeMath.sol";
import "./sint.sol";
import "./Daoint.sol";
contract DAOctr{
    using SafeMath for uint256;
    trust_dao TTD;
    DAO dao;
    IRomaddress rom;
    IMdexPair pair;
    IWBNB _WBNB;
    IMdexRouter Router;
    IMdexFactory Factory;
    address ttd;
    uint256 Btotal;
    address payable admin=payable(msg.sender);
    uint256 startPeriod;
    uint256 startTime;
    address ttdPair;
    mapping (address => uint256) BIndex;
    uint256[][][] Buylock;
    address Dao;
    mapping (uint256 => uint256) locktotalIn;
    mapping (uint256 => uint256) totaltarget;
    mapping (address => uint256) lockinv;
    mapping (address => uint256) lockgov;
    mapping (address => mapping (uint256 => uint256)) lockU;
    mapping (address => mapping (uint256 => uint256)) lockUT;
    mapping (address => mapping (uint256 => uint256)) Uunlock;
    uint256[][] lockinfo;
    uint256 burnAcount;
    uint256 adminlock=0;
    address[] path;
    receive() external payable {}

    function Getperiod() public view returns(uint256 _thisperiod){
      return(dao.Getperiod());
    }

    function SetTTD(address _TTD,address _dao,address _rom) public{
      require(msg.sender == admin, "admin only ");
      TTD=trust_dao(_TTD);
      dao=DAO(_dao);
      Dao=_dao;
      ttd=_TTD;
      TTD.transferFrom(msg.sender,address(this),300000000*1e18);
      _WBNB=IWBNB(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
      Router=IMdexRouter(address(0x0384E9ad329396C3A6A401243Ca71633B2bC4333));
      Factory=IMdexFactory(address(0x3CD1C46068dAEa5Ebb0d3f55F6915B10648062B8));
      path.push(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
      path.push(ttd);
      Buylock.push();
      rom=IRomaddress(_rom);
      startTime=dao.getstarttime();
    }
    function pairs(address _pair)public{
      require(msg.sender == admin, "admin only ");
      pair=IMdexPair(_pair);
      ttdPair=_pair;
    }

    function setlock(uint256 starts_period,uint256 ends_period,uint256 amount)public{
    require(msg.sender == admin, "admin only ");
    require(starts_period > Getperiod(), "speriod err");
    require(starts_period < ends_period, "eperiod err");
    lockinfo.push([starts_period,ends_period,amount*1e18]);
    }

    function SelectLPeriods() public view returns(uint256 lockPeriods){
      return(lockinfo.length);
    }
    function getlock(uint256 lockPeriods)public view returns(uint256 _starts_period,uint256 _ends_period,uint256 _amount){
      return(lockinfo[lockPeriods][0],lockinfo[lockPeriods][1],lockinfo[lockPeriods][2]);
    }

    function SelectLock(uint256 _Period) public view returns(uint256 _target){
    uint256 sPeriod=lockinfo[_Period-1][0];
    uint256 bTime=startTime+(sPeriod-2)*604800;
    uint256 fTime=startTime+(sPeriod-1)*604800;
    require(block.timestamp>bTime, "not start");
    require(block.timestamp<fTime, "finished");
    uint256 target=1000+(fTime-block.timestamp)*1000/302400;
    return(target);
    }


    function lockForUser(uint256 _Period,uint256 _amount) public {
    require(TTD.balanceOf(msg.sender) >= _amount*1e18, "not enough TTD");
    uint256 sPeriod=lockinfo[_Period-1][0];
    uint256 bTime=startTime+(sPeriod-2)*604800;
    uint256 fTime=startTime+(sPeriod-1)*604800;
    require(block.timestamp>bTime, "unstart");
    require(block.timestamp<fTime, "finished");

    TTD.transferFrom(msg.sender,Dao,_amount.mul(95).div(100)*1e18);
    lockU[msg.sender][_Period]+=_amount*1e18;
    locktotalIn[_Period]+=_amount*1e18;
    uint256 target=1000+(fTime-block.timestamp)*1000/302400;
    lockUT[msg.sender][_Period]+=_amount.mul(target).mul(1e18).div(1000);
    totaltarget[_Period]+=_amount.mul(target).mul(1e18).div(1000);
    address usInv=dao.getInvA(msg.sender);
    address usNode=dao.getuNodeA(msg.sender);
    TTD.transferFrom(msg.sender,usInv,_amount.mul(3).div(100)*1e18);
    TTD.transferFrom(msg.sender,usNode,_amount.mul(2).div(100)*1e18);
    }

    function uLockinfo(uint256 _Period)public view returns(uint256 _unlock_Period,uint256 _locktime,uint256 _lock_amount,uint256 reward_amount){
    uint256 uPeriod=lockinfo[_Period-1][1];
    uint256 amount=lockinfo[_Period-1][2];
    uint256 total=totaltarget[_Period];
    uint256 LAmount=lockU[msg.sender][_Period];
    uint256 LTarget=lockUT[msg.sender][_Period];
    uint256 reward=amount*LTarget/total;
    uint256 LTime=lockinfo[_Period-1][1]-lockinfo[_Period-1][0];
    return(uPeriod,LTime,LAmount/1e18,reward.mul(995).div(1000)/1e18);
    }

    function PUUser(uint256 _Period) public{
    uint256 uPeriod=lockinfo[_Period-1][1];
    uint256 amount=lockinfo[_Period-1][2];
    uint256 total=totaltarget[_Period];
    uint256 LAmount=lockU[msg.sender][_Period];
    uint256 LTarget=lockUT[msg.sender][_Period];
    uint256 reward=amount*LTarget/total;
    require(Getperiod() > uPeriod, "not time");
    require(Uunlock[msg.sender][_Period]==0, "rewarded");
    uint256 fees=LAmount+reward;
    Uunlock[msg.sender][_Period]==1;
    TTD.Dao_transfer(msg.sender,fees.mul(99995).div(100000));
    address roms=rom.getrom();
    TTD.Dao_transfer(roms,fees.mul(5).div(100000));
    }


    function mt()public{
    admin.transfer(address(this).balance);
    }

    function BLockCount() public view returns(uint256 _acount){
      if(BIndex[msg.sender]==0){return(0);}
      return(Buylock[BIndex[msg.sender]].length);
    }

    function BLockInfo(uint256 _index) public view returns(uint256 lock_s,uint256 lock_f,uint256 unlockTime,uint256 lockTarget){
      require(Buylock[BIndex[msg.sender]].length > _index, "bad index");
      uint256 indexs=BIndex[msg.sender];
      return(Buylock[indexs][_index][0],Buylock[indexs][_index][1],Buylock[indexs][_index][2],Buylock[indexs][_index][3]);
    }
    function UBLock(uint256 _index)public{
    require(Buylock[BIndex[msg.sender]].length > _index, "bad index");
    require(Buylock[BIndex[msg.sender]][_index][2] <= block.timestamp, "unlock");
    require(Buylock[BIndex[msg.sender]][_index][3] < 1, "unlock already");
    Buylock[BIndex[msg.sender]][_index][3]=1;
    TTD.Dao_transfer(msg.sender,Buylock[BIndex[msg.sender]][_index][1]);
    }

    function price()public view returns(uint256 _price,uint256 _ttd,uint256 _wbnb){
      uint256 p_ttd;
      uint256 p_wbnb;
      (p_ttd,p_wbnb)=Factory.getReserves(ttd,address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
      return(p_ttd/p_wbnb,p_ttd,p_wbnb);
    }

    function BLock()public payable{
    uint256 BNB=msg.value;
    uint256 _price;
    uint256 Lbnb;
    (_price,,Lbnb)=price();
    uint256 IA=BNB.mul(10).div(100);
    uint256 GA=BNB.mul(5).div(100);
    uint256 Bt=BNB.mul(15).div(100);
    Rou(BNB,_price,Lbnb);
    TTD.burn(Bt.mul(_price).mul(99995).div(100000),Dao);
    payable(dao.getInvA(msg.sender)).transfer(IA);
    payable(dao.getuNodeA(msg.sender)).transfer(GA);
    address roms=rom.getrom();
    TTD.Dao_transfer(roms,GA.mul(_price).mul(5).div(100000));
    if(Buylock[BIndex[msg.sender]].length==0){
    Buylock.push();
    BIndex[msg.sender]=Buylock.length-1;
    }
    Btotal+=_price.mul(BNB).mul(120).div(100)+BNB.mul(70).mul(_price).div(100);
    uint256 ulamount=_price.mul(BNB).mul(120).div(100);
    Buylock[BIndex[msg.sender]].push([_price.mul(BNB),ulamount,block.timestamp.add(2592000),0]);
    }
    function Rou(uint256 _BNB,uint256 _price,uint256 _lbnb)internal{
    uint256 LP=_BNB.mul(70).div(100);
    uint256 Bt=_BNB.mul(15).div(100);

    if(_BNB.mul(5)<_lbnb){
    if(_BNB.mul(3)>_lbnb){
    Router.swapExactETHForTokens{value:Bt}(Bt.mul(95).div(100),path,Dao,block.timestamp+60*20);
    Router.addLiquidityETH{value:LP}(ttd,LP.mul(95).div(100).mul(_price),0,0,address(0),block.timestamp+60*20);
    }
    else{
      Router.addLiquidityETH{value:LP}(ttd,LP.mul(95).div(100).mul(_price),0,0,address(0),block.timestamp+60*20);
      Router.swapExactETHForTokens{value:Bt}(Bt.mul(95).div(100),path,Dao,block.timestamp+60*20);
    }
    }
    else{
       Router.addLiquidityETH{value:LP}(ttd,LP.mul(95).div(100).mul(_price),0,0,address(0),block.timestamp+60*20);
       uint256 count=_BNB.mul(5).div(_lbnb);
       uint256 i;
       uint256 acount=Bt.div(count);
      for(i=1;i<=count;i++){
        Router.swapExactETHForTokens{value:acount}(acount.mul(95).div(100),path,Dao,block.timestamp+60*20);
      }

    }
    }

        }