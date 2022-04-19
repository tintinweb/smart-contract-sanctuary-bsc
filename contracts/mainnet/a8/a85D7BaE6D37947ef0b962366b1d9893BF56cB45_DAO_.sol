pragma solidity ^0.8.0;
import "./SafeMath.sol";
import "./sint.sol";
contract DAO_{
    using SafeMath for uint256;
    trust_dao TTD;
    IRomaddress rom;
    IMdexPair pair;
    IWBNB _WBNB;
    IMdexRouter Router;
    IMdexFactory Factory;
    address ttd;
    uint256 Btotal;
    address payable admin=payable(msg.sender);
    uint256 startPeriod;
    uint256 startTime=block.timestamp;
    address[] node;
    address[] invs;
    address ttdPair;
    mapping (address => uint256) NODES;
    mapping (address => uint256) uNode;
    mapping (address => uint256) uInvs;
    mapping (address => uint256) daoctr;
    mapping (address => bytes4) Inv;
    mapping (address => address) uInv;
    mapping (bytes4 => address) C2A;

    mapping (uint256 => uint256) totalIn;
    mapping (uint256 => uint256) totalOut;

    mapping (address => mapping (uint256 => uint256)) invIn;
    mapping (address => mapping (uint256 => uint256)) invOut;
    mapping (address => mapping (uint256 => uint256)) nodeIn;
    mapping (address => mapping (uint256 => uint256)) nodeOut;

    mapping (address => uint256) BIndex;
    uint256[][][] Buylock;
    uint256 NodeTotal;
    mapping (address => uint256) UnodeTotal;
    mapping (uint256 => uint256) locktotalIn;
    mapping (uint256 => uint256) totaltarget;
    mapping (address => uint256) lockinv;
    mapping (address => uint256) locknode;
    mapping (address => mapping (uint256 => uint256)) lockU;
    mapping (address => mapping (uint256 => uint256)) lockUT;
    mapping (address => mapping (uint256 => uint256)) Uunlock;
    uint256[][] lockinfo;
    uint256 adminlock=0;
    address[] path;
    receive() external payable {}

    function setstart(uint256 _period) public{
    require(msg.sender == admin, "admin only ");
    startPeriod=_period;
    }

    function Getperiod() public view returns(uint256 _thisperiod){
      return(1+(block.timestamp-startTime)/604800);
    }
    function getstarttime()public view returns(uint256){
      return(startTime);
    }
    function SetTTD(address _TTD,address _rom) public{
      require(msg.sender == admin, "admin only ");
      require(ttd == address(0), "seted ");
      TTD=trust_dao(_TTD);
      ttd=_TTD;
      TTD.transferFrom(msg.sender,address(this),370000000*1e18);
      rom=IRomaddress(_rom);
        node.push();
        uint256 Gindex=node.length-1;
        node[Gindex]=admin;
        NODES[admin]=Gindex;
        uNode[admin]=Gindex;

      bytes4 i=bytes4(keccak256(abi.encode(admin)));
      Inv[admin]=i;
      C2A[i]=admin;
      uInv[admin]=admin;
      invs.push();
      invs[invs.length-1]=admin;
      uInvs[admin]=invs.length-1;

    }
    function pairs(address _pair)public{
      pair=IMdexPair(_pair);
      ttdPair=_pair;
    }

    function setNode(address _NODE)public{
        require(uInvs[_NODE] != 0, "unregedit ");
        require(_NODE!=admin, "admin bad ");
        require(TTD.balanceOf(msg.sender) >=1000000*1e18, "not enough TTD");
        TTD.burn(800000*1e18,msg.sender);
        TTD.transferFrom(msg.sender,uInv[_NODE],50000*1e18);
        TTD.transferFrom(msg.sender,node[NODES[_NODE]],1500000*1e18);
        node.push();
        uint256 Gindex=node.length-1;
        node[Gindex]=_NODE;
        NODES[_NODE]=Gindex;
        uNode[_NODE]=Gindex;
      }

      function setInv(bytes4 _invcode,address user)public{
      require(user!=admin, "admin bad ");
      require(uInvs[user] == 0, "user is already");
      bytes4 i=bytes4(keccak256(abi.encode(user)));
      if(C2A[_invcode]==address(0)){
      _invcode=0x3b7204ab;

      }
      Inv[user]=i;
      C2A[i]=user;
      uNode[user]=uNode[C2A[_invcode]];
      uInv[user]=C2A[_invcode];
      invs.push();
      invs[invs.length-1]=user;
      uInvs[user]=invs.length-1;
      }
      function getInv(address addr)public view returns (bytes4 _inv){
      return(Inv[addr]);
      }
      function getuNode(address addr)public view returns (uint256 _unode){
      return(uNode[addr]);
      }

      function getInvA(address addr)public view returns (address _addr){
      if(uInv[addr]==address(0)){return(C2A[0x3b7204ab]);}
      return(uInv[addr]);
      }
      function getuNodeA(address addr)public view returns (address _addr){
      return(node[uNode[addr]]);
      }
    function getinfo(address sender,address recipient,uint256 from_amount,uint256 to_amount)external{
     require(msg.sender == ttd, "ttd only ");
    uint256 thisperiod=Getperiod();
    totalIn[thisperiod]+=to_amount;
     totalOut[thisperiod]+=from_amount;
      if(uInvs[recipient]==0){invIn[C2A[0x3b7204ab]][thisperiod]+=to_amount;}
      else{invIn[uInv[recipient]][thisperiod]+=to_amount;}
      if(uInvs[sender]==0){invOut[C2A[0x3b7204ab]][thisperiod]+=from_amount;}
      else{invOut[uInv[sender]][thisperiod]+=from_amount;}
      nodeIn[node[uNode[recipient]]][thisperiod]+=to_amount;
      nodeOut[node[uNode[sender]]][thisperiod]+=from_amount;
     address roms=rom.getrom();
     TTD.Dao_transfer(roms,to_amount.mul(5).div(10000000));
    }

    function Rinfo(address user,uint256 _period)public view returns(uint256 _totalIn,uint256 _totaloutput,uint256 _invincome,uint256 _invoutput,uint256 _nodeIn,uint256 _nodeOut){
    return(totalIn[_period],totalOut[_period],invIn[user][_period],invOut[user][_period],nodeIn[user][_period],nodeOut[user][_period]);
    }

    function ForLockinfo(address user)public view returns(uint256 inv_lock,uint256 node_lock){
    return(lockinv[user],locknode[user]);
    }

    function getTtd(uint256 period)public{
      require(Uunlock[msg.sender][period]==0, "geted");
      require(period<Getperiod(), "not time");
      Uunlock[msg.sender][period]=1;
      uint256 fees;
      (fees,)=getUser(period);
      TTD.Dao_transfer(msg.sender,fees.mul(99995).div(100000));
      address roms=rom.getrom();
      TTD.Dao_transfer(roms,fees.mul(5).div(100000));
      uint256 Acount=lockinv[msg.sender]+locknode[msg.sender];
      lockinv[msg.sender]=0;
      locknode[msg.sender]=0;
      TTD.Dao_transfer(msg.sender,Acount);
    }

    function getUser(uint256 Period)public view returns(uint256 _ddt,uint256 Key){
    uint256 Dao1=getDaoFromPeriod(Period);
    uint256 totalNum=totalIn[Period]+totalOut[Period];
    uint256 totalOutput=totalOut[Period];
    uint256 DaoInv=totalOutput.mul(6).div(300)+Dao1.mul(6).div(300);
    uint256 DaoNode=totalOutput.mul(3).div(300)+Dao1.mul(3).div(300);
    uint256 invNum=invIn[msg.sender][Period]+invOut[msg.sender][Period];
    uint256 nodeNum=nodeIn[msg.sender][Period]+nodeOut[msg.sender][Period];
    if(getuNode(msg.sender)==0 && msg.sender!=admin){nodeNum=0;}
    uint256 GetDdt=DaoInv.mul(invNum).div(totalNum)+DaoNode.mul(nodeNum).div(totalNum);
    return(GetDdt.mul(995).div(1000),Uunlock[msg.sender][Period]);
    }

    function getDaoFromPeriod(uint256 Period)public view returns(uint256 ttd_amount){
    uint256 num=0;
    uint256 DaoP=0;
    if(Period>startPeriod){
      uint256 DaoEnd=Period-startPeriod;
      if(DaoEnd<=108){
      num=Period-startPeriod;
      DaoP=40*1e18+(num-1)*1e18;
      }}
    return(DaoP);
    }
    function setDaoctr(address payable _daoctr)public{
      require(msg.sender == admin, "admin only ");
      daoctr[_daoctr]=1;
    }
    function wd()public{
    require(msg.sender == admin, "admin only ");
    admin.transfer(address(this).balance);
    }
    function getLockCountInfo(address user)public view returns(uint256 _lockinv,uint256 _locknode){
    return(lockinv[user],locknode[user]);
    }
    function setLockCountInfo(address user,uint256 _lockinv,uint256 _locknode)public{
      require(daoctr[msg.sender]==1, "admin only ");
      lockinv[user]+=_lockinv;
      locknode[user]+=_locknode;
      NodeTotal+=_locknode;
      UnodeTotal[user]+=_locknode;
    }
    function getNodetotalCount()public view returns(uint256 _NodeTotal,uint256 _UnodeTotal,uint256 NodeAmount){
        return(NodeTotal,UnodeTotal[msg.sender],node.length);
}
}