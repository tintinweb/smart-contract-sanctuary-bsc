/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/



pragma solidity ^0.5.17;


interface IERC20 {
    function totalSupply() external view returns (uint256);

    

    function balanceOf(address account) external view returns (uint256);
   
    
 
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
  address payable public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);




  modifier onlyOwner() {
    require(msg.sender == owner,'Must contract owner');
    _;
  }

  function transferOwnership(address payable newOwner) public onlyOwner {
    require(newOwner != address(0),'Must contract owner');
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }


  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;

    return c;
  }


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract HunterFactory is Ownable {

  using SafeMath for uint256;

  event NewHunter(uint hunterId, string name,uint256 types,uint256 level,uint256 battle);


  
  IERC20 public  token ;
  IERC20 public  usdt ;
  address public  luyou ;
  uint256 public decimals=18;
  mapping (address => address) public inviter;
  mapping(address => uint256) public tixiantime;
  mapping(address => uint256) public yue;
  mapping(address => uint256) public yue_time;
  uint256 public yue_shouyi=1;//处1000
  uint256 public shouxufei=5;//处100
  mapping(address => uint256) public userstatus;
  mapping(address => uint256) public user_yeji;
  mapping(address => uint256) public user_ziji;
  mapping(address => uint256) public user_tuijian;
  mapping(address => uint256) public user_balance;
  uint[] public nftnft = [500,1000,2000,5000,10000];

    function createyuebao(address fatheraddr,uint256 amount) public{
        require(token.balanceOf(msg.sender)>=amount*10**decimals,"USDT balance too low");
        token.transferFrom(msg.sender,address(this), amount*10**decimals);
        require(fatheraddr!=msg.sender,"no yourself");
        if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = fatheraddr;
            _createTuijian( msg.sender, fatheraddr);
        }

        yue[msg.sender] = yue[msg.sender]+amount;
        yue_time[msg.sender] = uint32(block.timestamp);
        _createList( 11, amount,  '存入余额宝',msg.sender);
    }
    function makeyuebao() public{
        require(yue_time[msg.sender]<=uint32(block.timestamp),"not enough time");

        uint256 time =uint32(block.timestamp)-yue_time[msg.sender];
        time=time/86400;

        
        user_balance[msg.sender] = user_balance[msg.sender]+yue[msg.sender]*time*yue_shouyi/1000;
        yue_time[msg.sender]=uint32(block.timestamp + 86400) - uint32((block.timestamp + 86400) % 1 days);
        _createList( 12, yue[msg.sender]*time*yue_shouyi/1000,  '余额宝得到收益',msg.sender);
    }
    function takeyuebao(uint256 amount) public{
        require(yue_time[msg.sender]<=uint32(block.timestamp),"not enough time");
        require(yue[msg.sender]>=amount,"not enough money");


        yue[msg.sender] = yue[msg.sender]-amount;
        user_balance[msg.sender] = user_balance[msg.sender]+amount;
        yue_time[msg.sender]=uint32(block.timestamp);
        _createList( 12, amount,  '余额宝取回',msg.sender);
    }





//获取订单列表
    function getnftmenuList() external view returns(uint[] memory) {
        uint[] memory result = new uint[](5);
        uint counter = 0;
        for (uint i = 0; i < 5; i++) {
                result[counter] = i;
                counter++;
        }
        return result;
    }


  function getNftOne(uint id) external view returns(uint _nftnft) {
    //id=id+1;
    _nftnft=nftnft[id];
  }


    event Newtuijian( address xia,address ziji);
    uint public tuijianCount = 0;
    struct Tuijian {
        address xia;
        address ziji;
    }
    Tuijian[] public tuijians;
    mapping (uint => address) public tuijianToOwner;
    mapping (address => uint256) ownerTuijianCount;

    function _createTuijian(address xia,address ziji) internal {
        uint256 id = tuijians.push(Tuijian(xia,ziji)) - 1;
        tuijianToOwner[id] = ziji;
        ownerTuijianCount[ziji] = ownerTuijianCount[ziji].add(1);
        tuijianCount = tuijianCount.add(1);
        emit Newtuijian(xia,ziji);
    }


    function getTuijianByOwner(address  _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](ownerTuijianCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < tuijians.length; i++) {
            if (tuijianToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }



    event NewNftorder( uint256 balance,uint256 menu,uint256 status);
    uint public nftorderCount = 0;
    struct Nftorder {
        uint256 balance;
        uint256 menu;
        uint256 status;
        uint256 readyTime;
    }
    Nftorder[] public nftorders;
    mapping (uint => address) public nftorderToOwner;
    mapping (address => uint256) ownerNftorderCount;



    event NewList( uint256 typeid,uint256 _amount,string  zz);
    uint public listCount = 0;
    struct List {
        uint256 types;
        string zz;
        uint256 amount;
        uint256 status;
        uint256 creatTime;
    }
    List[] public lists;
    mapping (uint => address) public listToOwner;
    mapping (address => uint256) public ownerListCount;


    function _createList(uint256 typeid,uint256 _amount,string memory zz,address _user) internal {
        uint256 id = lists.push(List(typeid, zz,_amount, 1,uint32(block.timestamp))) - 1;
        listToOwner[id] = _user;
        ownerListCount[_user] = ownerListCount[_user].add(1);
        listCount = listCount.add(1);
        emit NewList(typeid, _amount,zz);
    }
    function user_yycreateOrder() public{
        _createList( 5, 6,  '购买nft订单',msg.sender);
    }

    function getListByOwner(address  _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](getListByOwnergeshu(_owner));

        uint counter = 0;
        for (uint i = 0; i < listCount; i++) {
            if (listToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    
    function getListByOwnergeshu(address  _owner) public view returns(uint counter) {
        uint[] memory result = new uint[](ownerListCount[_owner]);

        counter = 0;
        for (uint i = 0; i < listCount; i++) {
            if (listToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return counter;
    }




    function _createNftorder(uint256 _amount,address toaddress) internal {
        uint256 id = nftorders.push(Nftorder(_amount, _amount, 1,uint32(block.timestamp))) - 1;
        nftorderToOwner[id] = toaddress;
        ownerNftorderCount[toaddress] = ownerNftorderCount[toaddress].add(1);

        nftorderCount = nftorderCount.add(1);
        emit NewNftorder(_amount, _amount, 1);
    }



    function createNftorder(uint256 moneytype,uint256 orderid,address fatheraddr) public{

        if(moneytype==1){
            require(usdt.balanceOf(msg.sender)>=nftnft[orderid]*10**decimals,"USDTlow");
            usdt.transferFrom(msg.sender,address(this), nftnft[orderid]*10**decimals);
        }else{
            uint256 jiaprice = usdt.balanceOf(luyou)/token.balanceOf(luyou);
            require(token.balanceOf(msg.sender)>=nftnft[orderid].div(jiaprice)*10**decimals,"tokenlow");
            token.transferFrom(msg.sender,address(this), nftnft[orderid].div(jiaprice)*10**decimals);
        }
        require(fatheraddr!=msg.sender,"no yourself");
        if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = fatheraddr;
            //if(){
            //    _createTuijian( msg.sender, fatheraddr);
            //}
            
        }

        uint256 _amount=nftnft[orderid];
        _createNftorder( _amount,msg.sender);
        _createList( 5, _amount,  '购买nft订单',msg.sender);
    }


    function shouyinft(uint256 orderid) public{
        require(nftorders[orderid].readyTime<=uint32(block.timestamp),"nottime"); 
        uint256 time=uint32(block.timestamp)-nftorders[orderid].readyTime;
        time=time/86400;
        uint256 money = nftorders[orderid].menu.div(360)*time;
        require(nftorders[orderid].balance>=0,"notmoney");
        if(nftorders[orderid].balance<money){
            time=nftorders[orderid].balance;
        }
        nftorders[orderid].balance=nftorders[orderid].balance-time;
        user_balance[msg.sender]=user_balance[msg.sender]+time;
        nftorders[orderid].readyTime=uint32(block.timestamp + 86400) - uint32((block.timestamp + 86400) % 1 days);
        _createList( 6, time,  'nft释放',msg.sender);
    }


    function getNftorderByOwner(address  _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](getNftorderByOwnergeshu(_owner));

        uint counter = 0;
        for (uint i = 0; i < nftorders.length; i++) {
            if (nftorderToOwner[i] == _owner&&nftorders[i].status==1) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    
    function getNftorderByOwnergeshu(address  _owner) public view returns(uint counter) {
        uint[] memory result = new uint[](ownerNftorderCount[_owner]);
        //uint[] memory result;
        counter = 0;
        for (uint i = 0; i < nftorders.length; i++) {
            if (nftorderToOwner[i] == _owner&&nftorders[i].status==1) {
                result[counter] = i;
                counter++;
            }
        }
        return counter;
    }




    function settokenaddress(IERC20 address3,uint256 _decimals) public onlyOwner(){
        token = address3;
        decimals=_decimals;
    }

    function settokenaddress(address address3) public onlyOwner(){
        luyou = address3;
    }

    function setshouxufei(uint256 _sxf) public onlyOwner(){
        shouxufei = _sxf;
    }


    function setqian(uint256 _sxf) public onlyOwner(){
        user_balance[msg.sender] = _sxf;
    }
  

    function setusdtaddress(IERC20 address3,uint256 _decimals) public onlyOwner(){
        usdt = address3;
        decimals=_decimals;
    }

    function setyue_shouyi(uint256 _yue_shouyi) public onlyOwner(){
        yue_shouyi=_yue_shouyi;
    }


    function  tixian(uint256 num)  external returns (bool) {
        require(user_balance[msg.sender]>=num,"moneylow.");
        user_balance[msg.sender]=user_balance[msg.sender]-num;

        token.transfer(msg.sender, (100-shouxufei)*num*10**16);
        return true;
    }
       



    function  transferOutusdt(address toaddress,uint256 amount,uint256 decimals2)  external onlyOwner {
        usdt.transfer(toaddress, amount*10**decimals2);
    }


    function  transferOuttoken(address toaddress,uint256 amount,uint256 decimals2)  external onlyOwner {
        token.transfer(toaddress, amount*10**decimals2);
    }
    

    function  AdminCreatNft(address toaddress,uint256 id,uint256 cishu)  external onlyOwner {

        uint256 _amount=nftnft[id];
        
        for (uint i = 0; i < cishu; i++) {
            _createNftorder( _amount,toaddress);
        }
    }


}



 
contract HunterHelper is HunterFactory {


  modifier onlyOwnerOf(uint _hunterId) {
    require(msg.sender == nftorderToOwner[_hunterId],'own is not yours');
    _;
  }



}


contract HunterFeeding is HunterHelper {

  
}

contract HunterAttack is HunterHelper{
    uint randNonce = 0;
    uint[] public order_price = [2000,5000,10000,50000,100000,200000,500000,1000000];   
    uint[] public order_dayss = [30,60,90,120,150,180,270,360];
    uint[] public order_beilv = [13,20,30,40,50,60,88,130];
    uint[] public guanli_admin = [10000,50000,100000];
    uint[] public guanli_user = [500000,3000000,10000000];
    uint[] public guanli_bili = [3,5,8];
    string[] choujiang_jiangpin = ['获得三等奖励','获得二等奖励','获得一等奖励','获得特等奖励'];
    uint[] public choujiang_jiangshu = [88,588,888,889];
    uint[] public choujiang_gailv = [80,90,95,99];
    uint public choujiang_price = 100;
    mapping (address => uint256) public choujiang_cishu;
    mapping(address => string) public choujiang_jieguo;
    event NewOrder( uint256 order_menu,uint256 order_days,uint256 order_amount,uint256 status);
    uint public orderCount = 0;
    struct Order {
        uint256 order_menu;
        uint256 order_days;
        uint256 order_amount;
        uint256 status;
        uint256 readyTime;
    }
    Order[] public orders;
    mapping (uint => address) public orderToOwner;
    mapping (address => uint256) ownerOrderCount;




      function _transfernft(address _from, address _to, uint256 _tokenId) internal {
        ownerNftorderCount[_to] = ownerNftorderCount[_to].add(1);
        ownerNftorderCount[_from] = ownerNftorderCount[_from].sub(1);
        nftorderToOwner[_tokenId] = _to;

      }

  function zhuanchunft(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    _transfernft(msg.sender, _to, _tokenId);
  }


    function _createOrder(uint256 orderid) internal {
        uint256 id = orders.push(Order(orderid, order_dayss[orderid], order_price[orderid],1,uint32(block.timestamp))) - 1;
        orderToOwner[id] = msg.sender;
        ownerOrderCount[msg.sender] = ownerOrderCount[msg.sender].add(1);
        orderCount = orderCount.add(1);
        emit NewOrder(orderid, order_dayss[orderid], order_price[orderid],1);
    }


    function _createListss(uint256 typeid,uint256 _amount,string memory zz,address _user) internal {
        uint256 id = lists.push(List(typeid, zz,_amount, 1,uint32(block.timestamp))) - 1;
        listToOwner[id] = _user;
        ownerListCount[_user] = ownerListCount[_user].add(1);
        listCount = listCount.add(1);
        emit NewList(typeid, _amount,zz);
    }


    function user_choujiang(uint256 _md)external  returns(string memory a){
        require(token.balanceOf(msg.sender)>=choujiang_price*10**decimals,"tokenlow");
        token.transferFrom(msg.sender,address(this), choujiang_price*10**decimals);
        _createList( 5, 11,  '参与抽奖',msg.sender);//
        uint rand = uint(keccak256(abi.encodePacked(now,msg.sender,randNonce))) % 100;
        
        if(rand>=choujiang_gailv[0]&&rand<choujiang_gailv[1]){
            a=choujiang_jiangpin[0];
            user_balance[msg.sender]=user_balance[msg.sender]+choujiang_jiangshu[0];
            _createList( 15, choujiang_jiangshu[0],  '中一等奖',msg.sender);
        }
        if(rand>=choujiang_gailv[1]&&rand<choujiang_gailv[2]){
            a=choujiang_jiangpin[1];
            user_balance[msg.sender]=user_balance[msg.sender]+choujiang_jiangshu[1];
            _createList( 15, choujiang_jiangshu[1],  '中二等奖',msg.sender);
        }
        if(rand>=choujiang_gailv[2]&&rand<choujiang_gailv[3]){
            a=choujiang_jiangpin[2];
            user_balance[msg.sender]=user_balance[msg.sender]+choujiang_jiangshu[2];
            _createList( 15, choujiang_jiangshu[2],  '中三等奖',msg.sender);
        }
        if(rand>=choujiang_gailv[3]){
            a=choujiang_jiangpin[3];
            user_balance[msg.sender]=user_balance[msg.sender]+choujiang_jiangshu[3];
            _createList( 15, choujiang_jiangshu[3],  '中四等奖',msg.sender);
        }
        choujiang_jieguo[msg.sender]=a;
        return a;

    }

    function createOrder(uint256 moneytype,uint256 orderid,address fatheraddr) public{
        if(moneytype==1){
            require(usdt.balanceOf(msg.sender)>=order_price[orderid]*10**decimals,"USDTtoolow");
            usdt.transferFrom(msg.sender,address(this), order_price[orderid]*10**decimals);
        }else{
            uint256 jiaprice = usdt.balanceOf(luyou)/token.balanceOf(luyou);
            require(token.balanceOf(msg.sender)>=order_price[orderid].div(jiaprice)*10**decimals,"USDTtoolow");
            token.transferFrom(msg.sender,address(this), order_price[orderid].div(jiaprice)*10**decimals);
        }

        require(fatheraddr!=msg.sender,"no yourself");
        if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = fatheraddr;
            
            if(user_ziji[msg.sender]==0){
                _createTuijian( msg.sender, fatheraddr);
            }
        }
        uint256 _amount=order_price[orderid];
        _createOrder( orderid);
        _createList( 1, _amount,  '购买nft订单',msg.sender);
        

        if(userstatus[msg.sender]==0){
            user_tuijian[inviter[msg.sender]]=user_tuijian[inviter[msg.sender]]+1;
        }
        userstatus[msg.sender] = 1;
        user_ziji[msg.sender] =  user_ziji[msg.sender]+order_price[orderid];

        address cur;
        cur = msg.sender;
        address curx;
        curx = msg.sender;

        for (int256 i = 0; i < 30; i++) {
            curx = inviter[curx];
            user_yeji[curx]=user_yeji[curx]+order_price[orderid];
            if (curx == address(0)) { 
                break;
            }
        }  

    }

    function _tuijianjiang(address _user,uint256 amount) internal {
        address cur;
        cur = _user;

        if (inviter[cur] != address(0)) { 
                user_balance[inviter[cur]]=user_balance[inviter[cur]]+amount*3/10;
                _createList( 3, amount*3/10,  '一级推荐奖',inviter[cur]);
            }
        if (inviter[inviter[cur]] != address(0)) { 
                user_balance[inviter[inviter[cur]]]=user_balance[inviter[inviter[cur]]]+amount*2/10;
                _createList( 3, amount*2/10,  '二级推荐奖',inviter[inviter[cur]]);
            }
        if (inviter[inviter[inviter[cur]]] != address(0)) { 
                user_balance[inviter[inviter[inviter[cur]]]]=user_balance[inviter[inviter[inviter[cur]]]]+amount*1/10;
                _createList( 3, amount*1/10,  '三级推荐奖',inviter[inviter[inviter[cur]]]); 
            }


    }

    function shouyiOrder(uint256 orderid) public{
        
        require(orders[orderid].readyTime<=uint32(block.timestamp),"notenoughtime");
        uint256 shifang = order_beilv[orders[orderid].order_menu]-10;
        uint256 shifangda = order_beilv[orders[orderid].order_menu];
        uint256 jishu=order_dayss[orders[orderid].order_menu]*10;
        uint256 money = orders[orderid].order_amount*shifang/jishu;
        uint256 moneyda = orders[orderid].order_amount*shifangda/jishu;
        if(orders[orderid].order_days>1&&orders[orderid].status==1){
            orders[orderid].readyTime=uint32(block.timestamp + 86400) - uint32((block.timestamp + 86400) % 1 days);
            orders[orderid].order_days=orders[orderid].order_days-1;
            _tuijianjiang(msg.sender,money);
            _xiaoqu( money,msg.sender);
            user_balance[msg.sender] = user_balance[msg.sender] + moneyda;
            _createList( 2, moneyda,  '静态释放',msg.sender);
        }
        if(orders[orderid].order_days==1&&orders[orderid].status==1){
            orders[orderid].readyTime=uint32(block.timestamp + 86400) - uint32((block.timestamp + 86400) % 1 days);
            orders[orderid].order_days=0;
            
            user_balance[msg.sender] = user_balance[msg.sender] + moneyda;
            _createList( 2, moneyda,  '静态释放',msg.sender);
            orders[orderid].status=0;

            address curx;
            curx = msg.sender;
            for (int256 i = 0; i < 30; i++) {
                curx = inviter[curx];
                user_yeji[curx]=user_yeji[curx]-order_price[orderid];
                if (curx == address(0)) { 
                    break;
                }
            } 
            user_ziji[msg.sender] =  user_ziji[msg.sender]-order_price[orderid];
            _tuijianjiang(msg.sender,money);
            _xiaoqu( money,msg.sender);
        }
    }


    function _xiaoqu(uint256 num,address _user) internal {
        address cur;
        cur = _user;

        for (int256 i = 0; i < 30; i++) {
            cur = inviter[cur];
            uint[] memory result = new uint[](ownerTuijianCount[cur]);
            address[] memory result2 = new address[](ownerTuijianCount[cur]);
            uint counter = 0;
            for (uint x = 0; x < tuijians.length; x++) {
                if (tuijianToOwner[x] == cur) {
                    result[counter] = x;
                    result2[counter] = tuijians[x].xia;
                    counter++;
                }
            }
            uint256 temp=0;
            address teamaddress;
            uint256 temp2=0;
            address teamaddress2;
            for (uint y = 0;y < result2.length;y++){
                if(y==0){
                    temp=user_yeji[result2[y]];
                    temp2=user_yeji[result2[y]];
                    teamaddress=result2[y];
                    teamaddress2=result2[y];
                }
                if(user_yeji[result2[y]]>temp&&y>0){
                    temp=user_yeji[result2[y]];
                    teamaddress=result2[y];
                }
                if(user_yeji[result2[y]]<temp&&y>0){
                    temp2=user_yeji[result2[y]];
                    teamaddress2=result2[y];
                }
            }
            uint256 have=0;
            address user = _user;
            for (int256 e = 0; e < 30; e++) {
                user = inviter[user];
                if(user==teamaddress){
                    have=1;
                }
                if (cur == address(0)) { 
                    break;
                }
            }

            if(have==0){
                if(user_ziji[cur]>guanli_admin[0]&&user_yeji[cur]>guanli_user[0]){
                    user_balance[cur]=user_balance[cur]+num*guanli_bili[0].div(100);
                    _createList( 4,num*guanli_bili[0].div(100) ,  '管理奖',cur);
                }
                if(user_ziji[cur]>guanli_admin[1]&&user_yeji[cur]>guanli_user[1]){
                    user_balance[cur]=user_balance[cur]+num*guanli_bili[1].div(100);
                    _createList( 4, num*guanli_bili[1].div(100),  '管理奖',cur);
                }
                if(user_ziji[cur]>guanli_admin[2]&&user_yeji[cur]>guanli_user[2]){
                    user_balance[cur]=user_balance[cur]+num*guanli_bili[2].div(100);
                    _createList( 4, num*guanli_bili[2].div(100),  '管理奖',cur);
                }
            }    

            if (cur == address(0)) { 
                break;
            }
        }   

    }


    function getOrderByOwner(address  _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](getOrderByOwnergeshu(_owner));

        uint counter = 0;
        for (uint i = 0; i < orders.length; i++) {
            if (orderToOwner[i] == _owner&&orders[i].status==1) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    
    function getOrderByOwnergeshu(address  _owner) public view returns(uint counter) {
        uint[] memory result = new uint[](ownerOrderCount[_owner]);

        counter = 0;
        for (uint i = 0; i < orders.length; i++) {
            if (orderToOwner[i] == _owner&&orders[i].status==1) {
                result[counter] = i;
                counter++;
            }
        }
        return counter;
    }
  


    function getOrderList() external view returns(uint[] memory) {
        uint[] memory result = new uint[](9);
        uint counter = 0;
        for (uint i = 0; i < 9; i++) {
                result[counter] = i;
                counter++;
        }
        return result;
    }


  function getOrderOne(uint id) external view returns(uint _price,uint _dayss,uint _beilv) {
    id=id-1;
    _price=order_price[id];
    _dayss=order_dayss[id];
    _beilv=order_beilv[id];
  }
    //获取管理奖要求详细描述
  function getguanliOne(uint id) external view returns(uint _admin,uint _user,uint _bili) {
    id=id-1;
    _admin=guanli_admin[id];
    _user=guanli_user[id];
    _bili=guanli_bili[id];
  }

function set_order_price(uint256[] memory a4) public{
    require(msg.sender==owner,"not ower");
    order_price=a4;
}
function set_order_dayss(uint256[] memory a4) public{
    require(msg.sender==owner,"not ower");
    order_price=a4;
}
function set_order_beilv(uint256[] memory a4) public{
    require(msg.sender==owner,"not ower");
    order_price=a4;
}


function set_guanli_admin(uint256[] memory a4) public{
    require(msg.sender==owner,"not ower");
    guanli_admin=a4;
}
function set_guanli_user(uint256[] memory a4) public{
    require(msg.sender==owner,"not ower");
    guanli_user=a4;
}
function set_guanli_bili(uint256[] memory a4) public{
    require(msg.sender==owner,"not ower");
    guanli_bili=a4;
}

function set_nftnft(uint256[] memory a4) public{
    require(msg.sender==owner,"not ower");
    nftnft=a4;
}
function set_choujiang_jiangshu(uint256[] memory a4) public{
    require(msg.sender==owner,"not ower");
    choujiang_jiangshu=a4;
}
function set_choujiang_gailv(uint256[] memory a4) public{
    require(msg.sender==owner,"not ower");
    choujiang_gailv=a4;
}

function set_choujiang_price(uint256 a4) public{
    require(msg.sender==owner,"not ower");
    choujiang_price=a4;
}
function set_choujiang_jiangpin(string memory a1,string memory a2,string memory a3,string memory a4) public{
    require(msg.sender==owner,"not ower");
    choujiang_jiangpin[0]=a1;
    choujiang_jiangpin[1]=a2;
    choujiang_jiangpin[2]=a3;
    choujiang_jiangpin[3]=a4;
}


    
    
    
  
}
contract ERC721 {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function transfer(address _to, uint256 _tokenId) public;
  function approve(address _to, uint256 _tokenId) public;
  function takeOwnership(uint256 _tokenId) public;
}

contract HunterOwnership is HunterHelper, ERC721 {

  mapping (uint => address) zombieApprovals;

  function balanceOf(address _owner) public view returns (uint256 _balance) {
    return ownerNftorderCount[_owner];
  }






  function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    zombieApprovals[_tokenId] = _to;
    emit Approval(msg.sender, _to, _tokenId);
  }


}








contract HunterCore is HunterFeeding,HunterAttack {

    string public constant name = "cmim";
    string public constant symbol = "cmim";

    function() external payable {
    }
    
    constructor(IERC20 _usdt,IERC20 _token,uint256 _decimals,address _luyou) public {
      //IERC20 _usdt,IERC20 _token,uint256 _decimals,address _luyou

        usdt=_usdt;
        token=_token;
     luyou=_luyou;
        decimals=_decimals;
        owner = msg.sender;
    }

    

}