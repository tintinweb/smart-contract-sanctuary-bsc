pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed
// 节点管理合约  
import "./Base.sol";


contract sale is Base  {
    uint256 private constant  ONE_Month = 60 * 60  * 24  * 30;
    uint256 private constant  LockWarehouse = 50000000;
    address[] public node;
    address public Uaddress; 

    mapping(address => uint256) public _playerAddrMap; 


    uint256 public _playerCount; 
    uint256 public DividendAmount; 
    uint256 public _naturalCount; 
    uint256 public administrators; 


    uint256 public startTime = 100000000000;
    uint256 public nodeTime = 100000000000;


    bool public _LOCK = false;
    bool public _nodeLOCK = false;

    uint256 public    stage1 = 100000000000000000000000;
    uint256 public    stage2 = 150000000000000000000000;
    uint256 public    stage3 = 200000000000000000000000;
    uint256 public    stage4 = 300000000000000000000000;
    uint256 public    stage5 = 400000000000000000000000;



    uint256 public    U = 100000000000000000000;
    uint256 public    NU = 100000000000000000000;


  function setstage(uint256 stage,uint256 account) public onlyOwner {
         stage1 = stage;
        if(stage == 1){
            stage1 = account;
         }  if(stage == 2){
            stage2 = account;
         }
           if(stage == 3){
            stage3 = account;
         }
           if(stage == 4){
            stage4 = account;
         }
           if(stage == 5){
            stage5 = account;
         }
           if(stage == 6){
            U = account;
         }
        if(stage == 7){
            NU = account;
         }
 


    }
    

   
  function setUaddressship(address newaddress) public onlyOwner {
        require(newaddress != address(0));
        Uaddress = newaddress;
    }
    mapping(uint256 => Player) public _playerMap;
     
    mapping(address => uint256) public participateIn; 
    struct Player{
            uint256 id; 
            address addr; 
            uint256 investTime; 
            uint256 Available; 
            uint256 LockWarehouse; 
        }
    constructor()
    public {
        _owner = msg.sender; 
    }
 function getAddrById(uint256 id) public view returns(address) {//konwnsec//通过 id 获取玩家地址
        return _playerMap[id].addr; 
    }
    function getIdByAddr(address addr) public view returns(uint256) {//konwnsec//通过地址获取玩家 id
        return _playerAddrMap[addr]; 
    }

function getStage() public view returns(uint256[] memory) {//konwnsec//通过地址获取玩家 id


        uint256   stage = 0;
        uint256   quota = 0;
        if(stage1 != 0 && stage1 <  100000000000000000000000){
            stage = 1;
            quota = stage1;
        }
        if(stage2 != 0 && stage2 <  150000000000000000000000){
            stage = 2;
            quota = stage2;
        }
          if(stage3 != 0 && stage3 <  200000000000000000000000){
            stage = 3;
            quota = stage3;
        }
          if(stage4 != 0 && stage4 <  300000000000000000000000){
            stage = 4;
             quota = stage4;
        }
          if(stage5 != 0 && stage5 <  400000000000000000000000){
            stage = 5;
            quota = stage5;
        }
        uint256[] memory temp = new uint256[](2);
        temp[0] = stage;
        temp[1] = quota;
        return temp; 
     }






  function registry(address playerAddr) internal    {
        uint256 id = _playerAddrMap[playerAddr];
        require(id == 0, "nodeAlreadyExists");
        require(_naturalCount < 49, "NodeSoldOut");       
        _playerCount++;
        _naturalCount++;
        _playerAddrMap[playerAddr] = _playerCount; 
        _playerMap[_playerCount].id = _playerCount; 
        _playerMap[_playerCount].addr = playerAddr;
        _playerMap[_playerCount].investTime = block.timestamp;
        _playerMap[_playerCount].LockWarehouse = LockWarehouse;
        // _FTPNFT.mint(playerAddr, _playerCount,playerAddr);
         node.push(playerAddr);
    }

    function investment(address Recommender) public payable  {
        require(block.timestamp>nodeTime, "83791");
         require(_nodeLOCK, "isnodeLOCK"); 
        uint256 isparticipateIn  = participateIn[msg.sender];
        require(isparticipateIn == 0, "10993");
        uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
        require(_usdtBalance >= NU, "9999"); 
        _USDTAddr.transferFrom(msg.sender, address(this), NU);

        uint256 _usdtuantity90 = NU.mul(90).div(100);
        uint256 _usdtuantity10 = NU.sub(_usdtuantity90);


        _USDTAddr.transfer(Recommender, _usdtuantity10);
        _USDTAddr.transfer(Uaddress, _usdtuantity90);



        registry(msg.sender);
    }
 
    modifier isRealPlayer() {
        uint256 id = _playerAddrMap[msg.sender];
        require(id > 0, "userDoesNotExist"); 
        _; 
    }


    modifier isLOCK() {
         require(_LOCK, "islock"); 
        _; 
    }

 function setnodeTime(uint256 _nodeTime) public onlyOwner {
        nodeTime = _nodeTime;
    }


     function setStartTime(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
    }
 function nodeLOCK(bool LOCK) public onlyOwner {
        _nodeLOCK = LOCK;
    }
    function stop(bool LOCK) public onlyOwner {
        _LOCK = LOCK;
    }
    function settleStatic() external  isRealPlayer  {
        uint256 id = _playerAddrMap[msg.sender];
       uint256 difTime = block.timestamp.sub(_playerMap[id].investTime); 
        uint256 dif  = difTime.div(ONE_Month);
        require(dif > 0, "ThereAreNoONE_MonthToSettle");
        uint256 m  =  _playerMap[_playerCount].LockWarehouse;
        uint256 n  =    m.sub (m.mul(9).div(10));
        uint256 na  =  m.sub (n);
        _playerMap[id].investTime = block.timestamp;
        _playerMap[id].LockWarehouse = na;
        _FTPIns.transfer(msg.sender, FPT_Convert(n));
    }

   function NodeDividend() public onlyOwner  {
        _FTPIns.pathTransferSame(node);
     }



  function administratorsRegistry(address playerAddr) public onlyOwner   {
        uint256 id = _playerAddrMap[playerAddr];
        require(id == 0, "nodeAlreadyExists");
        require(administrators < 3, "NodeSoldOut");       
        _playerCount++;
        administrators++;
        _playerAddrMap[playerAddr] = _playerCount; 
        _playerMap[_playerCount].id = _playerCount; 
        _playerMap[_playerCount].addr = playerAddr;
        _playerMap[_playerCount].investTime = block.timestamp;
        _playerMap[_playerCount].LockWarehouse = LockWarehouse;
        // _FTPNFT.mint(playerAddr, _playerCount,playerAddr);
         node.push(playerAddr);
    }


    function PreSale(address nodeAddr) public isLOCK {

       
        require(block.timestamp>startTime, "83793");

        uint256 isparticipateIn  = participateIn[msg.sender];
        require(isparticipateIn == 0, "100");

        uint256 sender = _playerAddrMap[msg.sender];

        require(sender == 0, "83399");

        uint256 quantity = U;

        uint256 id = _playerAddrMap[nodeAddr];
        require(id != 0, "NodeDoesNotExist");
        uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
        require(_usdtBalance >= quantity, "9999"); 
        uint256 _fptquantity = 0;
        uint256 _usdtuantity = 0;
        if(stage1 != 0 ){
            if(stage1 > quantity )
            {
                _fptquantity = quantity.mul(5000);
                _usdtuantity = quantity;
                stage1 = stage1.sub(quantity);
            }
            else{
                _fptquantity = stage1.mul(5000);
                _usdtuantity = stage1;
                stage1 = 0;
                _LOCK = false;
                startTime = 100000000000;

            }
        }
        else 
        {
            if(stage2 != 0 )
            {
                if(stage2 > quantity )
                {
                    _fptquantity = quantity.mul(4000);
                    _usdtuantity = quantity;
                    stage2 = stage2.sub(quantity);
                }
                else{
                    _fptquantity = stage2.mul(4000);
                    _usdtuantity = stage2;
                    stage2 = 0;
                    _LOCK = false;
                    startTime = 100000000000;

                }
            }else{
                if(stage3 != 0 ){
                    if(stage3 >= quantity )
                    {
                        _fptquantity = quantity.mul(3333);
                        _usdtuantity = quantity;
                        stage3 = stage3.sub(quantity);

                    }
                    else{
                        _fptquantity = stage3.mul(3333);
                        _usdtuantity = stage3;
                        stage3 = 0;
                        _LOCK = false;
                        startTime = 100000000000;

                    }
                }else{
                    if(stage4 != 0 ){
                        if(stage4 > quantity )
                        {
                                _fptquantity = quantity.mul(2857);
                                _usdtuantity = quantity;
                                stage4 = stage4.sub(quantity);
                        }
                        else
                        {
                            _fptquantity = stage4.mul(2857);
                            _usdtuantity = stage4;
                            stage4 = 0;
                            _LOCK = false;
                            startTime = 100000000000;

                        }
                    }else{
                        if(stage5 != 0 )
                        {
                            if(stage5 > quantity )
                            {
                                _fptquantity = quantity.mul(2500);
                                _usdtuantity = quantity;
                                stage5 = stage5.sub(quantity);
                            }
                            else
                            {
                                _fptquantity = stage5.mul(2500);
                                _usdtuantity = stage5;
                                stage5 = 0;
                                _LOCK = false;
                                startTime = 100000000000;

                            }
                        } 
                    }
                }
            }
        }

        uint256 _usdtuantity75 = _usdtuantity.mul(75).div(100);
        uint256 _usdtuantity25 = _usdtuantity.sub(_usdtuantity75);
        _USDTAddr.transferFrom(msg.sender, address(this), _usdtuantity);
        _USDTAddr.transfer(Uaddress, _usdtuantity75);
        _USDTAddr.transfer(nodeAddr, _usdtuantity25);
        _FTPIns.transfer(msg.sender, _fptquantity);
        participateIn[msg.sender] = 100;

    }


}