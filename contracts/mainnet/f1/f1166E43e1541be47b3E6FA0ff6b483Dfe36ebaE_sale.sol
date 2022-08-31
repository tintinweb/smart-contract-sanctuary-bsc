/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: Unlicensed
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    } 
}

    interface Erc20Token {
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }
    
interface ERC721 {
    event Transfer(address indexed _from,address indexed _to,uint256 indexed _tokenId);
    event Approval(address indexed _owner,address indexed _approved,uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner,address indexed _operator,bool _approved);
    function safeTransferFrom(address _from,address _to,uint256 _tokenId,bytes calldata _data) external;   
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;   
    function transferFrom(address _from,address _to,uint256 _tokenId) external;
    function approve(address _approved,uint256 _tokenId) external;
    function setApprovalForAll(address _operator,bool _approved) external;
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function getApproved(uint256 _tokenId) external view returns (address);
    function mint(address _to,uint256 _tokenId ) external;
    function tokenURI(uint256 _tokenId) external view returns(address  _uri);
    function isApprovedForAll(address _owner,address _operator) external view returns (bool);
}

    

    contract Base {
        Erc20Token constant  internal _USDTAddr = Erc20Token(0x55d398326f99059fF775485246999027B3197955);
        ERC721     constant internal   EOSSNFT = ERC721(0x163C140BE039b206b3B150532479142FA1895C65); 
        Erc20Token constant  internal _EOSAddr = Erc20Token(0xB04906e95AB5D797aDA81508115611fee694c2b3);
        Erc20Token constant  internal _EOSLPAddr = Erc20Token(0xa0D6d7eE26215d00291d51510040BEcB9EBB9C4B);
        Erc20Token constant  internal _EOSSAddr = Erc20Token(0xB04906e95AB5D797aDA81508115611fee694c2b3);
        Erc20Token constant  internal _EOSSLPAddr = Erc20Token(0xa0D6d7eE26215d00291d51510040BEcB9EBB9C4B);
        uint256 public oneDay = 1000; 
        uint256 public _startTime;
        address  _owner;
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
        
        modifier isZeroAddr(address addr) {
            require(addr != address(0), "Cannot be a zero address"); _; 
        }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }



    receive() external payable {}  
}


contract sale is Base  {
    
    using SafeMath for uint256;

    address public Uaddress; 
    uint256 public _NodePlayerCount; 
    uint256 public _SupernodeCount; 
    uint256 public _SEOSPlayerCount; 
 
    uint256 public _IDOCount; 
 
    
    uint256 public _IDOUnlockTime = 10000000000000000000000000;
    uint256  public IDOtimeLimitS = 10000000000000000000000000;
    uint256  public IDOtimeLimitE = 10000000000000000000000000;



    // uint256 public    SupernodePrice = 2000000000000000000000;
    // uint256 public    nodePrice      = 20000000000000000000000;
    uint256 public SupernodePrice    = 200000000000000000;
    uint256 public nodePrice         = 2000000000000000000;

    uint256 public CurrentOutput; 


    mapping(uint256 => address) public IDtoToken; 
    mapping(uint256 => address) public IDtoTokenLP; 

    function setUaddressship(address newaddress) public onlyOwner {
        require(newaddress != address(0));
        Uaddress = newaddress;
    }
   
    mapping(address => uint256) public _SEOSAddrMap; 
    mapping(uint256 => uint256) public everydaytotle; 
    mapping(uint256 => uint256) public everydayDTtotle; 
    mapping(uint256 => uint256) public everydayTotalOutput; 
    uint256 allNetworkCalculatingPower;
    uint256 allNetworkCalculatingPowerDT; 



    uint256 bonusNum;
    uint256 NFTbonusNum; 
    uint256 NFTcastingTime; 

    uint256 bonusTime; 
    uint256 NFTbonusTime; 
    mapping(uint256 => SEOSPlayer)   _SEOSPlayerMap;

    struct SEOSPlayer{
            uint256 id; 
            address addr; 
            uint256 integral;
            address superior;
            uint256 NFTmintnumber;
            uint256 SEOSQuantity;
            uint256 level;
            uint256[]  IDlist;
            mining EOSmining;
            IDO PlayerIDO;
            GenesisNodePlayer GenesisNode;
            SupernodePlayer Supernode;

     }

 
    struct IDO{
        bool IDO;
        uint256 IDORecommend;
        uint256 LockWarehouse;
    }
  
    // 挖矿
    struct mining{
        uint256 OutGold;
        uint256 dynamic;
   
        uint256 CalculatingPower;
        uint256 LastSettlementTime;
    }
//  创世节点
    struct GenesisNodePlayer{
        uint256 id; 
        uint256 investTime; 
        uint256 LockUp; 
        uint256 LastReceiveTime;
        uint256 bonusTime;
        uint256 NFTbonusTime; 

    }
 
    struct SupernodePlayer{
        uint256 id; 
        uint256 LockUp; 
        uint256 LastReceiveTime;
        uint256 investTime;
        uint256 bonusTime; 
        uint256 NFTbonusTime;
    }
    constructor()
    public {
        _startTime = block.timestamp;
        _owner = msg.sender; 
        Uaddress = msg.sender; 
    }
 
   
    function ERC20_Convert(uint256 value) internal pure returns(uint256) {
            return value.mul(1000000000000000000);
    }

    function Noderegistry(address playerAddr) internal    {
        uint256 id = _SEOSAddrMap[playerAddr];
        if(id == 0){
            _SEOSPlayerCount++;
            _SEOSAddrMap[playerAddr] = _SEOSPlayerCount; 
            _SEOSPlayerMap[_SEOSPlayerCount].id = _SEOSPlayerCount; 
            _SEOSPlayerMap[_SEOSPlayerCount].addr = playerAddr;
            id = _SEOSPlayerCount; 
        }


        require(_NodePlayerCount < 19, "NodeSoldOut");       
        _NodePlayerCount++;       
        _SEOSPlayerMap[id].GenesisNode.id = _NodePlayerCount;
        _SEOSPlayerMap[id].GenesisNode.investTime = block.timestamp;
        _SEOSPlayerMap[id].GenesisNode.LockUp = ERC20_Convert(500000000);
        _SEOSPlayerMap[id].integral = nodePrice.mul(10);
        _SEOSPlayerMap[id].NFTmintnumber = _SEOSPlayerMap[id].NFTmintnumber.add(3);

    }

    function levelUP(uint256 IDD) public    returns(uint256,uint256){

        uint256 livel = 0;
        uint256 totle = 0;
        uint256 lilv = 0;//利率
        (livel,totle) = range(_SEOSPlayerMap[IDD].IDlist);
        if(totle > 10000 && totle<50000){
            if(_SEOSPlayerMap[IDD].level != 1){
                _SEOSPlayerMap[IDD].level = 1;
            }
            livel = 1;
            lilv = 5;

        }
        else  if(totle > 50000 && totle<150000){
            if(_SEOSPlayerMap[IDD].level != 2){
                _SEOSPlayerMap[IDD].level = 2;
            }
            livel = 2;
            lilv = 8;

        }
        else  if(totle > 150000 && totle<500000){
            if(_SEOSPlayerMap[IDD].level != 3){
                _SEOSPlayerMap[IDD].level = 3;
            }
            livel = 3;
            lilv = 15;

        }
        else if(totle > 500000 && totle<1000000){
            if(_SEOSPlayerMap[IDD].level != 4){
                _SEOSPlayerMap[IDD].level = 4;
            }
            livel = 4;
            lilv = 15;

        }
        else if(totle > 1000000 ){
            if(_SEOSPlayerMap[IDD].level != 5){
                _SEOSPlayerMap[IDD].level = 5;
            }
            livel = 5;
            lilv = 18;

        }
        return (livel,lilv);
    }


    function range(uint256[] memory   _IDlist) public  view returns(uint256,uint256){
        uint256 max;
        uint256 MAXID = _IDlist[0];
    	for (uint256 i = 0; i < _IDlist.length; i++) {
            uint256 dynamic = _SEOSPlayerMap[_IDlist[i]].EOSmining.dynamic;
    		if (dynamic > max) {
    			max = dynamic;
                MAXID = _IDlist[i];
    		}	
        }
        uint256 totle;
        for (uint256 i = 0; i < _IDlist.length; i++) {
            uint256 dynamic = _SEOSPlayerMap[_IDlist[i]].EOSmining.dynamic;
    		if (MAXID !=  _IDlist[i]) {
    			totle = totle.add(dynamic);
    		}	
        }
        return (MAXID,totle);
    }

    function SEOSPlayeRegistry(address playerAddr, address superior) internal {
        uint256 id = _SEOSAddrMap[playerAddr];
        _SEOSPlayerCount++;
        _SEOSAddrMap[playerAddr] = _SEOSPlayerCount; 
        _SEOSPlayerMap[_SEOSPlayerCount].id = _SEOSPlayerCount; 
        _SEOSPlayerMap[_SEOSPlayerCount].addr = playerAddr;
        id = _SEOSAddrMap[superior];
        if(id > 0){
            _SEOSPlayerMap[_SEOSPlayerCount].superior = superior;
        }
     }


     function SupernodeRegistry(address playerAddr, address superior) internal {



        uint256 id = _SEOSAddrMap[playerAddr];
        require(_SupernodeCount < 5000, "SupernodeOut");
         if(id == 0){
            _SEOSPlayerCount++;
            _SEOSAddrMap[playerAddr] = _SEOSPlayerCount; 
            _SEOSPlayerMap[_SEOSPlayerCount].id = _SEOSPlayerCount; 
            _SEOSPlayerMap[_SEOSPlayerCount].addr = playerAddr;
            id = _SEOSAddrMap[superior];
            if(id > 0){
                _SEOSPlayerMap[_SEOSPlayerCount].superior = superior;
            }
            id = _SEOSPlayerCount;
        }

// 超级节点数据
        _SupernodeCount++;
        _SEOSPlayerMap[id].Supernode.id = _SupernodeCount; 
        _SEOSPlayerMap[id].Supernode.investTime = block.timestamp;
        _SEOSPlayerMap[id].Supernode.LockUp = ERC20_Convert(20000);
                _SEOSPlayerMap[id].NFTmintnumber = _SEOSPlayerMap[id].NFTmintnumber.add(1);

    }

    function becomeNode() public payable  {
 
        uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
        require(_usdtBalance >= nodePrice, "9999");
        _USDTAddr.transferFrom(address(msg.sender), address(this), nodePrice);

        _USDTAddr.transfer(Uaddress, nodePrice);
        uint256 senderid = _SEOSAddrMap[msg.sender];
        require(_SEOSPlayerMap[senderid].GenesisNode.id == 0, "is GenesisNode"); 
         Noderegistry(msg.sender);
    }
 
  function becomeSupernode(address recommend) public payable  {

        uint256 id = _SEOSAddrMap[recommend];
        if(id > 0){
         SEOSPlayer memory  play  = _SEOSPlayerMap[id];
    
        uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
        require(_usdtBalance >= SupernodePrice, "9999");
        _USDTAddr.transferFrom(address(msg.sender), address(this), SupernodePrice);

        if(play.GenesisNode.id > 0){
            _USDTAddr.transfer(recommend, SupernodePrice.mul(20).div(100));
            _USDTAddr.transfer(Uaddress, SupernodePrice.sub(nodePrice.mul(20).div(100)));
        }else{
             if(play.Supernode.id > 0){
                _USDTAddr.transfer(recommend, SupernodePrice.mul(15).div(100));
                _USDTAddr.transfer(Uaddress, SupernodePrice.sub(nodePrice.mul(15).div(100)));
            }else{
                _USDTAddr.transfer(Uaddress, SupernodePrice);
            }
        }
        }else{
            _USDTAddr.transfer(Uaddress, SupernodePrice);
        }
        uint256 senderid = _SEOSAddrMap[msg.sender];
        require(_SEOSPlayerMap[senderid].Supernode.id == 0, "is Supernode"); 
        SupernodeRegistry(msg.sender,recommend);
    }


    modifier isNodePlayer() {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256 Nodeid = _SEOSPlayerMap[id].Supernode.id;
        require(Nodeid > 0, "Node"); 
        _; 
    }
    modifier isSuperNodePlayer() {
        uint256 id = _SEOSAddrMap[msg.sender];
       uint256  Supernodeid =   _SEOSPlayerMap[id].Supernode.id;
        require(Supernodeid > 0, "SuperNode"); 
        _; 
    }

    modifier isPlayer() {
        uint256 id = _SEOSAddrMap[msg.sender];
        require(id > 0, "userDoesNotExist"); 
        _; 
    }

     
    function setStartTime(uint256 _startTimes) public onlyOwner {
        _startTime = _startTimes;
    }
 


    function settleStatic() external  isNodePlayer  {
        uint256 id = _SEOSAddrMap[msg.sender];
 

        uint256 difTime = block.timestamp.sub(_SEOSPlayerMap[id].GenesisNode.investTime); 
        uint256 dif  = difTime.div(oneDay.mul(30));
        require(dif > 0, "ThereAreNoONE_MonthToSettle");
        _SEOSPlayerMap[id].GenesisNode.investTime = block.timestamp;
        uint256  amount = ERC20_Convert(dif.mul(26000));
        if(_SEOSPlayerMap[id].GenesisNode.LockUp > amount){
            _SEOSPlayerMap[id].GenesisNode.LockUp = _SEOSPlayerMap[id].GenesisNode.LockUp.sub(amount);
        }else{
            amount = _SEOSPlayerMap[id].GenesisNode.LockUp;
            _SEOSPlayerMap[id].GenesisNode.LockUp = 0;
        }
        _EOSSAddr.transfer(msg.sender, amount);
    }


    function SupernodesettleStatic() external   isSuperNodePlayer  {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256 difTime = block.timestamp.sub(_SEOSPlayerMap[id].Supernode.investTime); 
        uint256 dif  = difTime.div(oneDay.mul(30));
        require(dif > 0, "ThereAreNoONE_MonthToSettle");
        _SEOSPlayerMap[id].Supernode.investTime = block.timestamp;
        uint256  amount = ERC20_Convert(dif.mul(1000));
        if(_SEOSPlayerMap[id].Supernode.LockUp > amount){
            _SEOSPlayerMap[id].Supernode.LockUp = _SEOSPlayerMap[id].Supernode.LockUp.sub(amount);
        }else{
            amount = _SEOSPlayerMap[id].Supernode.LockUp;
            _SEOSPlayerMap[id].Supernode.LockUp = 0;
        }
        _EOSSAddr.transfer(msg.sender, amount);
    }


   function integral(address Destination,uint256 integralamount) external   isNodePlayer  {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256 DestinationID = _SEOSAddrMap[Destination];
        require(_SEOSPlayerMap[id].integral >= integralamount, "Insufficient");
        if(DestinationID == 0)
        {
            SEOSPlayeRegistry(Destination,Destination);
        }
        DestinationID = _SEOSAddrMap[Destination];
        _SEOSPlayerMap[DestinationID].integral = _SEOSPlayerMap[DestinationID].integral.add(integralamount);
        _SEOSPlayerMap[id].integral = _SEOSPlayerMap[id].integral.sub(integralamount);
    }

    function pIDO(address Destination) external {

   

        require(block.timestamp > IDOtimeLimitS, "time start");
        require(block.timestamp < IDOtimeLimitE, "time end");

        uint256 id = _SEOSAddrMap[msg.sender];
        uint256 EOSSID = _SEOSAddrMap[Destination];
        require(10000 >= _IDOCount, "IDO");
        if(id == 0)
        {
            SEOSPlayeRegistry(msg.sender,Destination);
        }
        id = _SEOSAddrMap[msg.sender];

        if(EOSSID != 0)
        {
            _SEOSPlayerMap[EOSSID].PlayerIDO.IDORecommend =  _SEOSPlayerMap[EOSSID].PlayerIDO.IDORecommend.add(1);
        }
        require(!_SEOSPlayerMap[id].PlayerIDO.IDO, "IDO");

        uint256 BuyPrice =  getprice();
        _USDTAddr.transferFrom(address(msg.sender), address(this), BuyPrice);
        if(id > 0){
         SEOSPlayer memory  play  = _SEOSPlayerMap[EOSSID];
        uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
        require(_usdtBalance >= SupernodePrice, "9999");

        if(play.GenesisNode.id > 0){
            _USDTAddr.transfer(Destination, BuyPrice.mul(20).div(100));
            _USDTAddr.transfer(Uaddress, BuyPrice.sub(BuyPrice.mul(20).div(100)));
        }else{
             if(play.Supernode.id > 0){
                _USDTAddr.transfer(Destination, BuyPrice.mul(20).div(100));
                _USDTAddr.transfer(Uaddress, BuyPrice.sub(BuyPrice.mul(20).div(100)));
            }else{
                _USDTAddr.transfer(Uaddress, BuyPrice);
            }
        }
        }else{
            _USDTAddr.transfer(Uaddress, BuyPrice);
        }
        _SEOSPlayerMap[id].PlayerIDO.IDO = true;
        _SEOSPlayerMap[id].PlayerIDO.LockWarehouse = 25000;
        _SEOSPlayerMap[id].NFTmintnumber = _SEOSPlayerMap[id].NFTmintnumber.add(1);
        _IDOCount = _IDOCount.add(1);

    }

    function getprice() public view  returns(uint256){
        return  _IDOCount.div(500).mul(5).add(100);
    }
  

    function ERC20Transfer(uint256 USDT_Num,uint256 tokenIndex) public    {
        address  tokenAddress  = IDtoToken[tokenIndex];
        Erc20Token  token = Erc20Token(tokenAddress);
        address  tekenLPaddress  = IDtoTokenLP[tokenIndex];
        Erc20Token  tekenLP = Erc20Token(tekenLPaddress);
        uint256  tokenNum = USDT_Num.mul(Spire_Price(token, tekenLP)).div(10000000);
        token.transferFrom(address(msg.sender), address(this),tokenNum);
        token.transfer(address(Uaddress),tokenNum);
     }


     function EOSTransfer(uint256 EOSnum) public    {
        uint256 id = _SEOSAddrMap[msg.sender];
        EOSnum = EOSnum.mul(Spire_Price(_EOSAddr, _EOSLPAddr)).div(10000000);
        uint256 EOSBalance = _EOSAddr.balanceOf(msg.sender);
        if(EOSBalance >= EOSnum){
            _EOSAddr.transferFrom(address(msg.sender), address(this),EOSnum);
            _EOSAddr.transfer(address(Uaddress),EOSnum);
        }else{
            uint256  EOS_BQ_Balance =   EOSnum.sub(EOSBalance);
            require(_SEOSPlayerMap[id].integral >= EOS_BQ_Balance, "integral");
            if(EOSBalance > 100000000000000000){
                _EOSAddr.transferFrom(address(msg.sender), address(this),EOSBalance);
                    _EOSAddr.transfer(address(Uaddress),EOSBalance);
            }
            _SEOSPlayerMap[id].integral  = _SEOSPlayerMap[id].integral .sub(EOS_BQ_Balance);
        }
     }




    function pmining(uint256 USDTNum,uint256 tokenAIndex,uint256 tokenBIndex,uint256 paytype) external     { 
        uint256 id = _SEOSAddrMap[msg.sender];
        require(id > 0, "IDO");
        // require(USDT_Num >= 50000000000000000000, "mining limit");
        require(USDTNum >= 5000, "IDO");

        uint256 USDT_Num = USDTNum;

        if(paytype == 1){

            EOSTransfer( USDT_Num.div(2));
            _USDTAddr.transferFrom(address(msg.sender), address(this), USDT_Num.div(2));
            _USDTAddr.transfer( address(Uaddress), USDT_Num.mul(4).div(10));

        }else if(paytype == 2){//
            uint256  EOSnum = USDT_Num.mul(4).div(10);
            EOSTransfer( EOSnum);
            ERC20Transfer(  EOSnum.div(2),tokenAIndex);
            ERC20Transfer(  EOSnum,  tokenBIndex);
        }else if(paytype == 3)
        {
            USDT_Num = _SEOSPlayerMap[id].SEOSQuantity.mul(10000000).div(Spire_Price(_EOSSAddr, _EOSSLPAddr));
            _SEOSPlayerMap[id].SEOSQuantity = 0;
        }

        uint256  CalculatingPower = _SEOSPlayerMap[id].EOSmining.CalculatingPower.add(USDT_Num);
        require(3000000000000000000000 >= CalculatingPower, "3000 limit");
        _SEOSPlayerMap[id].EOSmining.CalculatingPower = CalculatingPower;

        uint256  OutGold = _SEOSPlayerMap[id].EOSmining.OutGold.add(USDT_Num.mul(3));
        _SEOSPlayerMap[id].EOSmining.OutGold = OutGold;
        allNetworkCalculatingPower = allNetworkCalculatingPower.add(USDT_Num);
        allNetworkCalculatingPowerDT = allNetworkCalculatingPower.add(USDT_Num.mul(2));

        grantProfitsl(_SEOSPlayerMap[id].superior,USDT_Num,6);

        uint256 Daynumber =  getdayNum(block.timestamp);
        getCapacity();
        everydayTotalOutput[Daynumber] = CurrentOutput;
        _SEOSPlayerMap[id].EOSmining.LastSettlementTime =  Daynumber;
        everydaytotle[Daynumber] = everydaytotle[Daynumber].add(USDT_Num);
        levelgod(msg.sender,USDT_Num,15,3);
    }


    function levelgod(address superior,uint256 GbonusNum,uint256 Algebra,uint256 pj) internal  {
        if(Algebra > 0){
            uint256 id = _SEOSAddrMap[superior];
            if(id > 0 ){
                uint256 livel = 0;
                uint256 lilv = 0;
                (livel,lilv) = levelUP(id);
                address sjid =  _SEOSPlayerMap[id].superior;
                uint256 SJlivel = 0;
                uint256 SJlilv = 0;
                (SJlivel,SJlilv) = levelUP( _SEOSAddrMap[sjid]);
                if(pj == 2){
                    _SEOSPlayerMap[id].SEOSQuantity  = _SEOSPlayerMap[id].SEOSQuantity.add(GbonusNum.mul(lilv).div(1000));
                }else if(pj == 1){
                     _SEOSPlayerMap[id].SEOSQuantity  = _SEOSPlayerMap[id].SEOSQuantity.add(GbonusNum.mul(lilv).div(100));
                }
                if(livel == SJlilv){
                    pj = 2;
                }else if(livel > SJlilv){
                    pj = 3;
                }else{
                    pj = 1;
                }
                levelgod(sjid, GbonusNum, Algebra.sub(1),pj);
            }
        }
    }


    function Spire_Price(Erc20Token ERC20Address, Erc20Token LP) public view returns(uint256) {
        uint256 usdtBalance = _USDTAddr.balanceOf(address(LP));
        uint256 SpireBalance = ERC20Address.balanceOf(address(LP));
        if(usdtBalance == 0){
            return  0;
        }else{
            return  SpireBalance.mul(10000000).div(usdtBalance);
        }
    }


    function getdayNum(uint256 time) public view returns(uint256) {
        return (time.sub(_startTime)).div(oneDay);
    }


    function jsplayer() public payable    {
        uint256 id = _SEOSAddrMap[msg.sender];
        require(id > 0, "nothisuser");
      
        uint256 Daynumber =  getdayNum(block.timestamp);
        uint256 daytotle = 0;
        uint256 dayDTtotle = 0;
        uint256 Static = _SEOSPlayerMap[id].EOSmining.CalculatingPower;
        uint256 dynamic = _SEOSPlayerMap[id].EOSmining.dynamic;
        uint256 Quantity = 0;
        uint256 DTQuantity = 0;
        require(Daynumber > _SEOSPlayerMap[id].EOSmining.LastSettlementTime, "time");

        if(Daynumber > _SEOSPlayerMap[id].EOSmining.LastSettlementTime){

            for (uint256 m = _SEOSPlayerMap[id].EOSmining.LastSettlementTime; m < Daynumber; m++) {
                if(everydaytotle[m] == 0)
                {
                    everydaytotle[m] = daytotle;
                }
                else
                {
                    daytotle = everydaytotle[m];
                }

                if(everydayDTtotle[m] == 0)
                {
                    everydayDTtotle[m] = dayDTtotle;
                }
                else
                {
                    dayDTtotle = everydayDTtotle[m];
                }
                if(everydayTotalOutput[m] == 0)
                {
                    everydayTotalOutput[m] = CurrentOutput;
                }
                uint256 todayOutput = everydayTotalOutput[m];
                // uint256 todayOutput =50000000000000000000;
                Quantity =Quantity.add(Static.mul(todayOutput.mul(7).div(10)).div(daytotle).mul(7).div(10));
                uint256 dongtaishouyi = 0;
                if (dayDTtotle > 0){
                    dongtaishouyi = dynamic.mul(todayOutput.mul(3).div(10)).div(dayDTtotle).mul(3).div(10);
                    DTQuantity =DTQuantity.add(dongtaishouyi);
                }
            }
     
            everydaytotle[Daynumber] = allNetworkCalculatingPower;
            everydayDTtotle[Daynumber] = allNetworkCalculatingPowerDT;
            _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id].SEOSQuantity.add(Quantity);
            grantProfit(_SEOSPlayerMap[id].superior,DTQuantity.div(20),2);
            _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id].SEOSQuantity.add(DTQuantity);
            _SEOSPlayerMap[id].EOSmining.LastSettlementTime = Daynumber;
        }
    }


   function TX() public {
        uint256 id = _SEOSAddrMap[msg.sender];
        require(id > 0, "isplayer");  
        if(_SEOSPlayerMap[id].SEOSQuantity > 0 &&  _SEOSPlayerMap[id].EOSmining.OutGold > 0){

            uint256 EOSSPrice  =   Spire_Price(_EOSSAddr, _EOSSLPAddr);
        //   uint256 EOSSPrice  =  10000000;
            uint256 Unum = _SEOSPlayerMap[id].SEOSQuantity.mul(10000000).div(EOSSPrice);
            if(_SEOSPlayerMap[id].EOSmining.OutGold >= Unum){
                _EOSSAddr.transfer(msg.sender, _SEOSPlayerMap[id].SEOSQuantity);
                _SEOSPlayerMap[id].EOSmining.OutGold  = _SEOSPlayerMap[id].EOSmining.OutGold.sub(Unum);
                _SEOSPlayerMap[id].SEOSQuantity  = 0;
            }else{
                uint256 EOSSnum = _SEOSPlayerMap[id].SEOSQuantity.mul(10000000).div(EOSSPrice);
                _EOSSAddr.transfer(msg.sender, EOSSnum);
                _SEOSPlayerMap[id].SEOSQuantity  = _SEOSPlayerMap[id].SEOSQuantity.sub(EOSSnum);
                _SEOSPlayerMap[id].EOSmining.OutGold  = 0;
            }
        }
    }

   function BQ(address recommend) public {
         uint256 id = _SEOSAddrMap[msg.sender];
         uint256 Tid = _SEOSAddrMap[recommend];
         require(_SEOSPlayerMap[id].PlayerIDO.IDO, "IDO");
        require(id > 0, "IS");
         SEOSPlayer memory  play  = _SEOSPlayerMap[Tid];
        uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
        if( _SEOSPlayerMap[id].PlayerIDO.IDORecommend < 100)
        {
            uint256 SuperPrice = SupernodePrice.sub(SupernodePrice.mul(_SEOSPlayerMap[id].PlayerIDO.IDORecommend).div(100));
            require(_usdtBalance >= SuperPrice, "9999");
            if(play.GenesisNode.id > 0)
            {
                _USDTAddr.transfer(recommend, SuperPrice.mul(20).div(100));
                _USDTAddr.transfer(Uaddress, SuperPrice.sub(nodePrice.mul(20).div(100)));
            }
            else
            {
                if(play.Supernode.id > 0){
                    _USDTAddr.transfer(recommend, SuperPrice.mul(15).div(100));
                    _USDTAddr.transfer(Uaddress, SuperPrice.sub(nodePrice.mul(15).div(100)));
                }
                else
                {
                    _USDTAddr.transfer(Uaddress, SuperPrice);
                }
            }
        }
        uint256 senderid = _SEOSAddrMap[msg.sender];
        require(_SEOSPlayerMap[senderid].Supernode.id == 0, "is Supernode"); 
        SupernodeRegistry(msg.sender,recommend);
    }


    function getCapacity() public     {
        uint256 USDTq =   allNetworkCalculatingPower.div(300000000000000000000000);
        if(USDTq > 0){
            CurrentOutput = CurrentOutput.add(USDTq.mul(30000000000000000000000));
        }else{
            CurrentOutput = 50000000000000000000000;
        }
    }


    function grantProfitsl(address superior,uint256 GbonusNum,uint256 Algebra) internal   {
        if(Algebra > 0){
            uint256 id = _SEOSAddrMap[superior];
            if(id > 0 ){
                _SEOSPlayerMap[id].EOSmining.dynamic = _SEOSPlayerMap[id].EOSmining.dynamic.add(GbonusNum);
                address sjid =  _SEOSPlayerMap[id].superior;
                grantProfitsl(sjid,  GbonusNum.div(2),  Algebra.sub(1));
                uint256 Daynumber =  getdayNum(block.timestamp);
                everydayDTtotle[Daynumber] = everydayDTtotle[Daynumber].add(GbonusNum);
            }
        }
    }


    function grantProfit(address superior,uint256 GbonusNum,uint256 Algebra) internal  {
        if(Algebra > 0){
            uint256 id = _SEOSAddrMap[superior];
            if(id > 0 ){
                if(Algebra == 2){
                    _SEOSPlayerMap[id].SEOSQuantity  = _SEOSPlayerMap[id].SEOSQuantity.add(GbonusNum);
                }else{
                    _SEOSPlayerMap[id].SEOSQuantity  = _SEOSPlayerMap[id].SEOSQuantity.add(GbonusNum.mul(2).div(5));
                }

                address sjid =  _SEOSPlayerMap[id].superior;
                grantProfit(sjid, GbonusNum, Algebra.sub(1));
            }
        }
    }


    function setbonusNum(uint256 SbonusNum,uint256 SbonusTime) public  onlyOwner{
        require(SbonusTime > block.timestamp, "timeisout");  
        bonusNum = SbonusNum;
        bonusTime = SbonusTime;
    }

    function EOSbonus() public  {
        require(block.timestamp > bonusTime, "timeisout");
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256  GenesisNodebonus = bonusNum.div(5).div(19);
        uint256  Supernodebonus = bonusNum.div(2).div(5000);
        SEOSPlayer memory  play  = _SEOSPlayerMap[id];
        if(play.GenesisNode.id > 0){
            if( bonusTime != play.GenesisNode.bonusTime)
            {
                _EOSSAddr.transfer(msg.sender, GenesisNodebonus);
                _SEOSPlayerMap[id].GenesisNode.bonusTime = bonusTime;
            }
        }
        if(play.Supernode.id > 0)
        {
            if( bonusTime != play.Supernode.bonusTime){
                _EOSSAddr.transfer(msg.sender, Supernodebonus);
                _SEOSPlayerMap[id].Supernode.bonusTime = bonusTime;
            }
        }
    }

    function getMining(address playerAddr)   external
        view returns(mining memory s){
        uint256 id = _SEOSAddrMap[playerAddr];
        SEOSPlayer memory  player  = _SEOSPlayerMap[id];
        return player.EOSmining;
    }

     function getSupernode(address playerAddr)   external
        view returns(SupernodePlayer memory  ){
        uint256 id = _SEOSAddrMap[playerAddr];
        SEOSPlayer memory  player  = _SEOSPlayerMap[id];
        return player.Supernode;
    }

    function getGenesisNode(address playerAddr)   external
        view returns(GenesisNodePlayer memory  ){
        uint256 id = _SEOSAddrMap[playerAddr];
        SEOSPlayer memory  player  = _SEOSPlayerMap[id];
        return player.GenesisNode;
    }

    function getplayer(address playerAddr)   external
        view returns(SEOSPlayer memory  ){
        uint256 id = _SEOSAddrMap[playerAddr];
        SEOSPlayer memory  player  = _SEOSPlayerMap[id];
        return player;
    }
    
    function getIDO(address playerAddr)   external
        view returns(IDO memory s){
        uint256 id = _SEOSAddrMap[playerAddr];
        SEOSPlayer memory  player  = _SEOSPlayerMap[id];
        return player.PlayerIDO;
    }

    function setTokenandLP(uint256 index,address LP ,address token) public onlyOwner  {
        IDtoToken[index] = token;
        IDtoTokenLP[index] = LP;
    }

    function withdrawErc20(
        address _to,
        address _contract,
        uint256 amount
    ) public onlyOwner {
       Erc20Token(_contract).transfer(_to, amount);
    }

    function IODLocklq() public  {
        require(block.timestamp > _IDOUnlockTime, "timeisout");
        uint256 id = _SEOSAddrMap[msg.sender];
        if(id > 0){
            _EOSSAddr.transfer(msg.sender,  _SEOSPlayerMap[id].PlayerIDO.LockWarehouse);
        }
    }
 
    function setIDOTime(uint256 _Time,uint256 IDOType) public onlyOwner {
        if(IDOType == 1){
            _IDOUnlockTime = _Time;
        }
        if(IDOType == 2){
            IDOtimeLimitS = _Time;
        }
        if(IDOType == 3){
            IDOtimeLimitE = _Time;
        }
    }

    function NFTcasting(address PlayerAddress) public isPlayer   {
        require(NFTcastingTime != 0, "NFT casting time out"); 
        uint256 id = _SEOSAddrMap[PlayerAddress];
        SEOSPlayer memory  player  = _SEOSPlayerMap[id];
        EOSSNFT.mint(PlayerAddress, id.mul(10000).add(player.NFTmintnumber));
        require(player.NFTmintnumber != 0, "is fil"); 
        player.NFTmintnumber = player.NFTmintnumber.sub(1); 
    }
    function getplayerinfo(address playerAddr) public view returns(uint256[] memory,address,address    ){
        uint256[] memory playerinfo = new uint256[](6);
        uint256 id = _SEOSAddrMap[playerAddr];
        SEOSPlayer memory  player  = _SEOSPlayerMap[id];
        playerinfo[0] = player.id;
        playerinfo[1] = player.integral;
        playerinfo[2] = player.NFTmintnumber;
        playerinfo[3] = player.SEOSQuantity;
        playerinfo[4] = player.level;
        return (playerinfo,player.addr,player.superior);
     }

       function getXJAddressID(address playerAddr) public view returns(uint256[] memory    ){
        uint256 id = _SEOSAddrMap[playerAddr];
        SEOSPlayer memory  player  = _SEOSPlayerMap[id];
         return player.IDlist;
     }

    function getAddressByID(uint256 id) public view returns(address){
        SEOSPlayer memory  player  = _SEOSPlayerMap[id];
        return player.addr;
    }

}