/**
 *Submitted for verification at BscScan.com on 2022-09-07
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

    interface Erc20Token {//konwnsec//ERC20 接口
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
 
    function mint(address _to,uint256 _tokenId ) external;
 
}

    
// 基类合约
    contract Base {



         
// 测试
// USDT   0x5f5bD6f8743A567BAa0313b54F82C20724f5cC5f
// EOS     0x29769b1B99D5e46fA7dD3Ba46cf04aba27A1aE27
// SEOS    0xFfF328b88c12C32731ABF193c2A4e0e2561C27dD
// 代币A    0x13A29dD851Ea73dDA436E72239dfb19bD6aa344b              0xB70884Bd503f324B082fd11EDE9264ac48068a0f
// 代币B     0xc7195D6fF88eE196a87Aa3D8dBd59CBe53AA8ADA   


        Erc20Token constant  internal _USDTAddr = Erc20Token(0x5f5bD6f8743A567BAa0313b54F82C20724f5cC5f);
        ERC721       internal   EOSSNFT = ERC721(0x163C140BE039b206b3B150532479142FA1895C65); 
        Erc20Token constant  internal _EOSAddr = Erc20Token(0x29769b1B99D5e46fA7dD3Ba46cf04aba27A1aE27);
        Erc20Token constant  internal _EOSLPAddr = Erc20Token(0x4173bbD124710F547E3D3CF545f8d90F22504B41);
        Erc20Token constant  internal _EOSSAddr = Erc20Token(0xFfF328b88c12C32731ABF193c2A4e0e2561C27dD);
        Erc20Token constant  internal _EOSSLPAddr = Erc20Token(0x6037b3a65992d11DB52A4bf4227f2E2578309beb);

// 本地测试链
        // Erc20Token constant  internal _USDTAddr = Erc20Token(0x11343e19FAA20969921E7E5726ee2857F505897B);
        // ERC721       internal   EOSSNFT = ERC721(0x163C140BE039b206b3B150532479142FA1895C65); 
        // Erc20Token constant  internal _EOSAddr = Erc20Token(0x7f569bcCD70EC2314b33fF83c827FA255d17E361);
        // Erc20Token constant  internal _EOSLPAddr = Erc20Token(0x4173bbD124710F547E3D3CF545f8d90F22504B41);
        // Erc20Token constant  internal _EOSSAddr = Erc20Token(0x930033Ec33b578Dac7944fAB362e2839C03AeCaf);
        // Erc20Token constant  internal _EOSSLPAddr = Erc20Token(0x6037b3a65992d11DB52A4bf4227f2E2578309beb);


        // Erc20Token constant  internal _USDTAddr = Erc20Token(0x55d398326f99059fF775485246999027B3197955);
        // ERC721     constant internal   EOSSNFT = ERC721(0x163C140BE039b206b3B150532479142FA1895C65); 
        // Erc20Token constant  internal _EOSAddr = Erc20Token(0xB04906e95AB5D797aDA81508115611fee694c2b3);
        // Erc20Token constant  internal _EOSLPAddr = Erc20Token(0xa0D6d7eE26215d00291d51510040BEcB9EBB9C4B);
        // Erc20Token constant  internal _EOSSAddr = Erc20Token(0xB04906e95AB5D797aDA81508115611fee694c2b3);
        // Erc20Token constant  internal _EOSSLPAddr = Erc20Token(0xa0D6d7eE26215d00291d51510040BEcB9EBB9C4B);
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
 
    
    uint256 public _IDOUnlockTime = 1000000000;
    uint256  public IDOtimeLimitS = 1000000000;
    uint256  public IDOtimeLimitE = 1000000000;



    uint256 public    SupernodePrice = 2000000000000000000000;
    uint256 public    nodePrice      = 20000000000000000000000;
 

    uint256 public CurrentOutput; //全网当前产出


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
    uint256  public  allNetworkCalculatingPower; //全网算力
    uint256  public allNetworkCalculatingPowerDT; //全网推广算力



    uint256 public bonusNum; //EOS生态网络基金会加权分红总额   创世节点20%加权分红  超级节点50%加权分红
    uint256 public NFTbonusNum; //NFT分红
    uint256 public NFTcastingTime; //NFT可以铸造的时间

    uint256 public bonusTime; //分红时间
    uint256 public NFTbonusTime; //分红时间
    mapping(uint256 => SEOSPlayer) public  _SEOSPlayerMap;

    struct SEOSPlayer{
            uint256 id; 
            address addr; 
            uint256 integral; //积分
            address superior;//上级    
            uint256 NFTmintnumber;//NFT可铸造数量
            uint256 SEOSQuantity;//可提现代币
            uint256 TSEOSQuantity;//推广可提现代币
            uint256 communitySEOSQuantity;//社区收益
            uint256 level;//推 等级
            uint256[]  IDlist;//下级集合
            mining EOSmining;//挖矿相关
            IDO PlayerIDO;//IDO
            GenesisNodePlayer GenesisNode;//创世节点
            SupernodePlayer Supernode;//超级节点
            uint256 USDT_T_Quantity;//推荐奖励  分享奖励

     }

 
    struct IDO{
        bool IDO;//IDO只能参与一次
        uint256 IDORecommend;//IDO推荐的数量
        uint256 LockWarehouse;//锁仓数量
    }
  
    // 挖矿
    struct mining{
        uint256 OutGold;//出局金额
        uint256 dynamic;//动态算力  推荐算力
   
        uint256 CalculatingPower;// 累计算力
        uint256 LastSettlementTime;//最后结算时间
    }
//  创世节点
    struct GenesisNodePlayer{
        uint256 id; 
        uint256 investTime; //参与时间
        uint256 LockUp; //锁仓
        uint256 LastReceiveTime;//最后结算时间
        uint256 bonusTime; //分红时间
        uint256 NFTbonusTime; //分红时间

    }
 
    struct SupernodePlayer{
        uint256 id; 
        uint256 LockUp; //锁仓
        uint256 LastReceiveTime;//最后结算时间
        uint256 investTime; //参与时间
        uint256 bonusTime; //分红时间
        uint256 NFTbonusTime; //分红时间
    }
    constructor()
    public {
        _startTime = block.timestamp;//参与时间
        _owner = msg.sender; 
        Uaddress = msg.sender; 
    }
 
   function set721Address(address value) public   {
          EOSSNFT = ERC721(value);
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

// 创世节点数据
        require(_NodePlayerCount < 19, "NodeSoldOut");       
        _NodePlayerCount++;       
        _SEOSPlayerMap[id].GenesisNode.id = _NodePlayerCount; //节点编号
        _SEOSPlayerMap[id].GenesisNode.investTime = block.timestamp;//参与时间
        _SEOSPlayerMap[id].GenesisNode.LockUp = ERC20_Convert(500000000);//锁仓
        _SEOSPlayerMap[id].integral = nodePrice.mul(10);//积分
        _SEOSPlayerMap[id].NFTmintnumber = _SEOSPlayerMap[id].NFTmintnumber.add(3);

    }





    function levelUP(uint256 IDD) public    returns(uint256,uint256){

        uint256 livel = 0;
        uint256 totle = 0;
        uint256 lilv = 0;//利率
        (,totle) = range(_SEOSPlayerMap[IDD].IDlist);
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
            lilv = 12;

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

// 极差
    function range(uint256[] memory   _IDlist) public  view returns(uint256,uint256){
        uint256 max;
        uint256 MAXID = 0;
        uint256 totle;
        if(_IDlist.length>0){
             MAXID = _IDlist[0];
    	    for (uint256 i = 0; i < _IDlist.length; i++) {
                uint256 dynamic = _SEOSPlayerMap[_IDlist[i]].EOSmining.CalculatingPower;
    		    if (dynamic > max) {
    			    max = dynamic;
                    MAXID = _IDlist[i];
    		    }	
            }
            for (uint256 i = 0; i < _IDlist.length; i++) {
                uint256 dynamic = _SEOSPlayerMap[_IDlist[i]].EOSmining.CalculatingPower;
    		    if (MAXID !=  _IDlist[i]) {
    			    totle = totle.add(dynamic);
    		    }	
            }
        }
  
        return (MAXID,totle);
    }

// 普通玩家数据
    function SEOSPlayeRegistry(address playerAddr, address superior) internal {
        uint256 id = _SEOSAddrMap[playerAddr];
        _SEOSPlayerCount++;
        _SEOSAddrMap[playerAddr] = _SEOSPlayerCount; 
        _SEOSPlayerMap[_SEOSPlayerCount].id = _SEOSPlayerCount; 
        _SEOSPlayerMap[_SEOSPlayerCount].addr = playerAddr;
        id = _SEOSAddrMap[superior];
        if(id > 0){
            _SEOSPlayerMap[_SEOSPlayerCount].superior = superior;
            _SEOSPlayerMap[id].IDlist.push(_SEOSPlayerCount);

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
                _SEOSPlayerMap[id].IDlist.push(_SEOSPlayerCount);
            }
            id = _SEOSPlayerCount;
        }

// 超级节点数据
        _SupernodeCount++;
        _SEOSPlayerMap[id].Supernode.id = _SupernodeCount; //节点编号
        _SEOSPlayerMap[id].Supernode.investTime = block.timestamp;//参与时间
        _SEOSPlayerMap[id].Supernode.LockUp = ERC20_Convert(20000);//锁仓
                _SEOSPlayerMap[id].NFTmintnumber = _SEOSPlayerMap[id].NFTmintnumber.add(1);

    }



// 成为创世节点
    function becomeNode() public payable  {
 
        uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
        require(_usdtBalance >= nodePrice, "9999");
        _USDTAddr.transferFrom(address(msg.sender), address(this), nodePrice);

        _USDTAddr.transfer(Uaddress, nodePrice);
        uint256 senderid = _SEOSAddrMap[msg.sender];
        require(_SEOSPlayerMap[senderid].GenesisNode.id == 0, "is GenesisNode"); 
         Noderegistry(msg.sender);
    }
//  成为超级节点  购买超级节点
  function becomeSupernode(address recommend) public payable  {

        uint256 id = _SEOSAddrMap[recommend];
        _USDTAddr.transferFrom(address(msg.sender), address(this), SupernodePrice);

        if(id > 0){
                SEOSPlayer memory  play  = _SEOSPlayerMap[id];

            uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
            require(_usdtBalance >= SupernodePrice, "9999");

            if(play.GenesisNode.id > 0)
            {
                _SEOSPlayerMap[play.GenesisNode.id].USDT_T_Quantity = SupernodePrice.mul(20).div(100);

                _USDTAddr.transfer(Uaddress, SupernodePrice.sub(SupernodePrice.mul(20).div(100)));
            }
            else{
                    if(play.Supernode.id > 0){
                    _SEOSPlayerMap[play.Supernode.id].USDT_T_Quantity = SupernodePrice.mul(15).div(100);

                    _USDTAddr.transfer(Uaddress, SupernodePrice.sub(SupernodePrice.mul(15).div(100)));
                }else{
                    _USDTAddr.transfer(Uaddress, SupernodePrice);
                }
            }
        }
        else{
            _USDTAddr.transfer(Uaddress, SupernodePrice);
        }
        uint256 senderid = _SEOSAddrMap[msg.sender];
        require(_SEOSPlayerMap[senderid].Supernode.id == 0, "is Supernode"); 
        SupernodeRegistry(msg.sender,recommend);
    }


    modifier isNodePlayer() {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256 Nodeid = _SEOSPlayerMap[id].GenesisNode.id;
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
 

// 创世节点领取代币  每月 每个节点均分26000枚/节点
    function GenesisNodeStatic() external  isNodePlayer  {
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

// 超级节点 领取代币每月 每个节点均分1000枚/节点
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

// 积分转让
   function integral(address Destination,uint256 integralamount) external      {
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

// IDO参与 一个地址只能参与一次   创世节点  20%    超级节点15%
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


            _SEOSPlayerMap[play.GenesisNode.id].USDT_T_Quantity =  BuyPrice.mul(20).div(100);

            _USDTAddr.transfer(Uaddress, BuyPrice.sub(BuyPrice.mul(20).div(100)));
        }else{
             if(play.Supernode.id > 0){
                _SEOSPlayerMap[play.Supernode.id].USDT_T_Quantity = BuyPrice.mul(20).div(100);

                _USDTAddr.transfer(Uaddress, BuyPrice.sub(BuyPrice.mul(20).div(100)));
            }else{
                _USDTAddr.transfer(Uaddress, BuyPrice);
            }
        }
        }else{
            _USDTAddr.transfer(Uaddress, BuyPrice);
        }
        _SEOSPlayerMap[id].PlayerIDO.IDO = true;
        _SEOSPlayerMap[id].PlayerIDO.LockWarehouse = 500000000000000000000;
        _SEOSPlayerMap[id].NFTmintnumber = _SEOSPlayerMap[id].NFTmintnumber.add(1);
        _IDOCount = _IDOCount.add(1);

    }
// IDO单价
    function getprice() public view  returns(uint256){
            return  _IDOCount.div(2).mul(5000000000000000000).add(100000000000000000000);

        // return  _IDOCount.div(500).mul(5000000000000000000).add(100000000000000000000);
    }
  
//  第三方代币转账
    function ERC20Transfer(uint256 USDT_Num,uint256 tokenIndex) internal    {
        address  tokenAddress  = IDtoToken[tokenIndex];
        Erc20Token  token = Erc20Token(tokenAddress);
        address  tekenLPaddress  = IDtoTokenLP[tokenIndex];
        Erc20Token  tekenLP = Erc20Token(tekenLPaddress);
        uint256  tokenNum = USDT_Num.mul(Spire_Price(token, tekenLP)).div(10000000);
        token.transferFrom(address(msg.sender), address(this),tokenNum);
        token.transfer(address(Uaddress),tokenNum);
     }

// EOS
     function EOSTransfer(uint256 EOSnum) internal    {
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



// 挖矿投资
    function pmining(uint256 USDTNum,uint256 tokenAIndex,uint256 tokenBIndex,uint256 paytype) external     { 
        uint256 id = _SEOSAddrMap[msg.sender];
        require(id > 0, "IDO");
        require(USDTNum >= 50000000000000000000, "mining limit");


        uint256 USDT_Num = USDTNum;

        if(paytype == 1){//一半U一半EOS

            EOSTransfer( USDT_Num.div(2));
            _USDTAddr.transferFrom(address(msg.sender), address(this), USDT_Num.div(2));
            _USDTAddr.transfer( address(Uaddress), USDT_Num.mul(4).div(10));

        }else if(paytype == 2){// 40%  eos  20%代币A 40%代币B
            uint256  EOSnum = USDT_Num.mul(4).div(10);
            EOSTransfer( EOSnum);
            ERC20Transfer(  EOSnum.div(2),tokenAIndex);
            ERC20Transfer(  EOSnum,  tokenBIndex);
        }else if(paytype == 3)//复投
        {
            USDT_Num = _SEOSPlayerMap[id].SEOSQuantity.mul(10000000).div(Spire_Price(_EOSSAddr, _EOSSLPAddr));
            _SEOSPlayerMap[id].SEOSQuantity = 0;
        }

        uint256  CalculatingPower = _SEOSPlayerMap[id].EOSmining.CalculatingPower.add(USDT_Num);
        require(3000000000000000000000 >= CalculatingPower, "3000 limit");
        _SEOSPlayerMap[id].EOSmining.CalculatingPower = CalculatingPower;
// 总产出
        uint256  OutGold = _SEOSPlayerMap[id].EOSmining.OutGold.add(USDT_Num.mul(3));
        _SEOSPlayerMap[id].EOSmining.OutGold = OutGold;
        allNetworkCalculatingPower = allNetworkCalculatingPower.add(USDT_Num);
        allNetworkCalculatingPowerDT = allNetworkCalculatingPower.add(USDT_Num.mul(2));
// 给上级加算力
        grantProfitsl(_SEOSPlayerMap[id].superior,USDT_Num,6);
// 更新当日代币产出
        uint256 Daynumber =  getdayNum(block.timestamp);
        getCapacity();
        everydayTotalOutput[Daynumber] = CurrentOutput;
        _SEOSPlayerMap[id].EOSmining.LastSettlementTime =  Daynumber;
        everydaytotle[Daynumber] = everydaytotle[Daynumber].add(USDT_Num);
        levelgod(msg.sender,USDT_Num,15,3);
        grantProfit(_SEOSPlayerMap[id].superior,USDT_Num.div(20),2);

    }

// 社区奖励
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
                (SJlivel,SJlilv) = levelUP(_SEOSAddrMap[sjid]);
                if(pj == 2){
                    _SEOSPlayerMap[id].communitySEOSQuantity  = _SEOSPlayerMap[id].communitySEOSQuantity.add(GbonusNum.mul(lilv).div(1000));
                }else if(pj == 1){
                     _SEOSPlayerMap[id].communitySEOSQuantity  = _SEOSPlayerMap[id].communitySEOSQuantity.add(GbonusNum.mul(lilv).div(100));
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

    // 获取代币价格
    function Spire_Price(Erc20Token ERC20Address, Erc20Token LP) public view returns(uint256) {
        uint256 usdtBalance = _USDTAddr.balanceOf(address(LP));
        uint256 SpireBalance = ERC20Address.balanceOf(address(LP));
        if(usdtBalance == 0){
            // return  10000000;
            return  0;
        }else{
            return  SpireBalance.mul(10000000).div(usdtBalance);
        }
    }

// 当前是系统开始的地几天
    function getdayNum(uint256 time) public view returns(uint256) {
        return (time.sub(_startTime)).div(oneDay);
    }

// 挖矿结算收益
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
            // grantProfit(_SEOSPlayerMap[id].superior,DTQuantity.div(20),2);
            _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id].SEOSQuantity.add(DTQuantity);
            _SEOSPlayerMap[id].EOSmining.LastSettlementTime = Daynumber;
        }
    }

// 提取产出（挖矿）
   function TX() public {
        uint256 id = _SEOSAddrMap[msg.sender];
        require(id > 0, "isplayer");  
        if(_SEOSPlayerMap[id].SEOSQuantity > 0 &&  _SEOSPlayerMap[id].EOSmining.OutGold > 0){

            uint256 EOSSPrice  =   Spire_Price(_EOSSAddr, _EOSSLPAddr);
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



    // 领取分享奖励、
   function sharebonus() public {
        uint256 id = _SEOSAddrMap[msg.sender];
        require(id > 0, "isplayer");  
        if(_SEOSPlayerMap[id].USDT_T_Quantity >  0){
            _USDTAddr.transfer(msg.sender, _SEOSPlayerMap[id].USDT_T_Quantity);
            _SEOSPlayerMap[id].USDT_T_Quantity = 0;
        }
    }

      // 分享奖金(推广)
   function extensionTX() public {
        uint256 id = _SEOSAddrMap[msg.sender];
        require(id > 0, "isplayer");  
        if(_SEOSPlayerMap[id].TSEOSQuantity > 0 &&  _SEOSPlayerMap[id].EOSmining.OutGold > 0){

            uint256 EOSSPrice  =   Spire_Price(_EOSSAddr, _EOSSLPAddr);
            uint256 Unum = _SEOSPlayerMap[id].TSEOSQuantity.mul(10000000).div(EOSSPrice);
            if(_SEOSPlayerMap[id].EOSmining.OutGold >= Unum){
                _EOSSAddr.transfer(msg.sender, _SEOSPlayerMap[id].TSEOSQuantity);
                _SEOSPlayerMap[id].EOSmining.OutGold  = _SEOSPlayerMap[id].EOSmining.OutGold.sub(Unum);
                _SEOSPlayerMap[id].TSEOSQuantity  = 0;
            }else{
                uint256 EOSSnum = _SEOSPlayerMap[id].TSEOSQuantity.mul(10000000).div(EOSSPrice);
                _EOSSAddr.transfer(msg.sender, EOSSnum);
                _SEOSPlayerMap[id].TSEOSQuantity  = _SEOSPlayerMap[id].TSEOSQuantity.sub(EOSSnum);
                _SEOSPlayerMap[id].EOSmining.OutGold  = 0;
            }
        }
    }


    
    // 提取产出（级别）
   function community() public {
        uint256 id = _SEOSAddrMap[msg.sender];
        require(id > 0, "isplayer");  
        if(_SEOSPlayerMap[id].communitySEOSQuantity > 0 &&  _SEOSPlayerMap[id].EOSmining.OutGold > 0){

            uint256 EOSSPrice  =   Spire_Price(_EOSSAddr, _EOSSLPAddr);
            uint256 Unum = _SEOSPlayerMap[id].communitySEOSQuantity.mul(10000000).div(EOSSPrice);
            if(_SEOSPlayerMap[id].EOSmining.OutGold >= Unum){
                _EOSSAddr.transfer(msg.sender, _SEOSPlayerMap[id].communitySEOSQuantity);
                _SEOSPlayerMap[id].EOSmining.OutGold  = _SEOSPlayerMap[id].EOSmining.OutGold.sub(Unum);
                _SEOSPlayerMap[id].communitySEOSQuantity  = 0;
            }else{
                uint256 EOSSnum = _SEOSPlayerMap[id].communitySEOSQuantity.mul(10000000).div(EOSSPrice);
                _EOSSAddr.transfer(msg.sender, EOSSnum);
                _SEOSPlayerMap[id].communitySEOSQuantity  = _SEOSPlayerMap[id].communitySEOSQuantity.sub(EOSSnum);
                _SEOSPlayerMap[id].EOSmining.OutGold  = 0;
            }
        }
    }

// 推荐补齐
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
            _USDTAddr.transferFrom(address(msg.sender), address(this), SuperPrice);

            if(play.GenesisNode.id > 0)
            {
                _SEOSPlayerMap[play.GenesisNode.id].USDT_T_Quantity = SuperPrice.mul(20).div(100);

                _USDTAddr.transfer(Uaddress, SuperPrice.sub(nodePrice.mul(20).div(100)));
            }
            else
            {
                if(play.Supernode.id > 0){
                    _SEOSPlayerMap[play.Supernode.id].USDT_T_Quantity = SuperPrice.mul(15).div(100);

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

    // 获取当日产出
    function getCapacity() public     {
        uint256 USDTq =   allNetworkCalculatingPower.div(300000000000000000000000);
        if(USDTq > 0){
            CurrentOutput = CurrentOutput.add(USDTq.mul(30000000000000000000000));
        }else{
            CurrentOutput = 50000000000000000000000;
        }
    }

// 推广算力计算
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

// 推荐奖励
    function grantProfit(address superior,uint256 GbonusNum,uint256 Algebra) internal  {
        if(Algebra > 0){
            uint256 id = _SEOSAddrMap[superior];
            if(id > 0 ){
                if(Algebra == 2){
                    _SEOSPlayerMap[id].TSEOSQuantity  = _SEOSPlayerMap[id].TSEOSQuantity.add(GbonusNum);
                }else{
                    _SEOSPlayerMap[id].TSEOSQuantity  = _SEOSPlayerMap[id].TSEOSQuantity.add(GbonusNum.mul(2).div(5));
                }

                address sjid =  _SEOSPlayerMap[id].superior;
                grantProfit(sjid, GbonusNum, Algebra.sub(1));
            }
        }
    }

// 分红 
    function setbonusNum(uint256 SbonusNum,uint256 SbonusTime) public  onlyOwner{
        bonusNum = SbonusNum;
        bonusTime = SbonusTime;
    }

// 领取分红
    function EOSbonus() public  {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256  GenesisNodebonus = bonusNum.div(10).div(19);
        uint256  Supernodebonus = bonusNum.mul(45).div(100).div(5000);
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



    
// // 获取挖矿信息
//     function getMining(address playerAddr)   external
//         view returns(mining memory s){
//         uint256 id = _SEOSAddrMap[playerAddr];
//         SEOSPlayer memory  player  = _SEOSPlayerMap[id];
//         return player.EOSmining;
//     }
// // 获取超级节点信息
//      function getSupernode(address playerAddr)   external
//         view returns(SupernodePlayer memory  ){
//         uint256 id = _SEOSAddrMap[playerAddr];
//         SEOSPlayer memory  player  = _SEOSPlayerMap[id];
//         return player.Supernode;
//     }
// // 获取创世节点信息
//     function getGenesisNode(address playerAddr)   external
//         view returns(GenesisNodePlayer memory  ){
//         uint256 id = _SEOSAddrMap[playerAddr];
//         SEOSPlayer memory  player  = _SEOSPlayerMap[id];
//         return player.GenesisNode;
//     }

//     function getplayer(address playerAddr)   external
//         view returns(SEOSPlayer memory  ){
//         uint256 id = _SEOSAddrMap[playerAddr];
//         SEOSPlayer memory  player  = _SEOSPlayerMap[id];
//         return player;
//     }
//     // 获取IDO信息
//     function getIDO(address playerAddr)   external
//         view returns(IDO memory s){
//         uint256 id = _SEOSAddrMap[playerAddr];
//         SEOSPlayer memory  player  = _SEOSPlayerMap[id];
//         return player.PlayerIDO;
//     }

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

    // 领取IDO 锁仓的额度
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

         if(IDOType == 4){
            NFTcastingTime = _Time;
        }
    }

// // 铸造NFT
    function NFTcasting() public isPlayer   {
        require(block.timestamp > NFTcastingTime, "NFT casting time out");

        uint256 id = _SEOSAddrMap[msg.sender];
        SEOSPlayer memory  player  = _SEOSPlayerMap[id];
        EOSSNFT.mint(msg.sender, id.mul(10000).add(player.NFTmintnumber));
        require(player.NFTmintnumber != 0, "NFT casting is fil"); 
        player.NFTmintnumber = player.NFTmintnumber.sub(1); 
    }

    // function getplayerinfo(address playerAddr) public view returns(uint256[] memory,address,address){
    //     uint256[] memory playerinfo = new uint256[](6);
    //     uint256 id = _SEOSAddrMap[playerAddr];
    //     SEOSPlayer memory  player  = _SEOSPlayerMap[id];
    //     playerinfo[0] = player.id;
    //     playerinfo[1] = player.integral;
    //     playerinfo[2] = player.NFTmintnumber;
    //     playerinfo[3] = player.SEOSQuantity;
    //     playerinfo[4] = player.level;
    //     return (playerinfo,player.addr,player.superior);
    //  }



    function getplayerinfo(address playerAddr) public view returns(SEOSPlayer memory  ){
            uint256 id = _SEOSAddrMap[playerAddr];
            SEOSPlayer memory  player  = _SEOSPlayerMap[id];
        return player;
     }

    function getXJAddress(address playerAddr) public view returns(address[] memory    ){
        address[] memory playerinfo = new address[](10);
        uint256 id = _SEOSAddrMap[playerAddr];
        SEOSPlayer memory  player  = _SEOSPlayerMap[id];
        uint256[] memory addressID = player.IDlist;
        uint256 length = addressID.length;
        if(length >10)
        {
            length = 10;
        }
        if(length >0)
        {
            for (uint256 m = 0; m < length; m++) {
                playerinfo[m] = getAddressByID(addressID[m]);
            }
        }
        return playerinfo;
     }

    function getAddressByID(uint256 id) public view returns(address){
        SEOSPlayer memory  player  = _SEOSPlayerMap[id];
        return player.addr;
    }

}