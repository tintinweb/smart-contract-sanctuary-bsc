/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/



pragma solidity ^0.5.17;


interface IERC20 {
    function totalSupply() external view returns (uint256);

    
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
   
    
    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
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

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint public cooldownTime = 1 days;
  
  IERC20 public  token ;
  IERC20 public  usdt ;
  uint256 public decimals=18;

  uint256 public bili=10;
  uint256 public luck1100=0;




  mapping (address => address) public inviter;//inviter user_tuijian
  mapping(address => uint256) public mybonus;
  mapping(address => uint256) public tixiantime;

  mapping(address => uint256) public yue;

  mapping(address => uint256) public yue_time;
  uint256 public yue_shouyi;//需要处以1000
  
  mapping(address => uint256) public userstatus;
  mapping(address => uint256) public usersbouns;//社区盲盒

  mapping(address => uint256) public user_yeji;//用户业绩
  mapping(address => uint256) public user_ziji;//用户自己报的单
  mapping(address => uint256) public user_tuijian;//推荐人数
  mapping(address => uint256) public user_level;//会员级：0，1，2，3
  mapping(address => string) public user_level_name;//会员级名称
  mapping(address => uint256) public user_balance;//用户余额
  uint[] public nftnft = [2000,5000,10000];

      

    function createyuebao(address fatheraddr,uint256 amount) public{
        //require(usdt.balanceOf(msg.sender)>=HunterPrice*10**decimals,"USDT balance too low");
        //usdt.transferFrom(msg.sender,address(this), HunterPrice*10**decimals);
        require(fatheraddr!=msg.sender,"no yourself");
        if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = fatheraddr;
            _createTuijian( msg.sender, fatheraddr);
        }

        yue[msg.sender] = yue[msg.sender]+amount;
        yue_time[msg.sender] = uint32(block.timestamp);
        _createList( 11, amount,  '存入余额宝');//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现 11存余额宝 12提取余额宝
    }
    function makeyuebao() public{
        require(yue_time[msg.sender]<=uint32(block.timestamp),"not enough time");
        //require(yue[msg.sender]>=amount,"not enough money");
        uint256 time =uint32(block.timestamp)-yue_time[msg.sender];
        time=time/86400;
        if(time<=1){
            time=0;//_yue_shouyi
        }
        
        user_balance[msg.sender] = user_balance[msg.sender]+yue[msg.sender]*time*yue_shouyi/1000;
        yue_time[msg.sender]=uint32(block.timestamp + 86400) - uint32((block.timestamp + 86400) % 1 days);
        _createList( 12, yue[msg.sender]*time*yue_shouyi,  '余额宝得到收益');//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现 11存余额宝 12提取余额宝 13余额每日收益
    }
    function takeyuebao(uint256 amount) public{
        //require(yue_time[msg.sender]<=uint32(block.timestamp),"not enough time");
        require(yue[msg.sender]>=amount,"not enough money");
        //uint256 time =uint32(block.timestamp)-yue_time[msg.sender];

        yue[msg.sender] = yue[msg.sender]-amount;
        user_balance[msg.sender] = user_balance[msg.sender]+amount;
        yue_time[msg.sender]=uint32(block.timestamp);
        _createList( 12, amount,  '余额宝取回');//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现 11存余额宝 12提取余额宝 13余额每日收益
    }





//获取订单列表
    function getnftmenuList() external view returns(uint[] memory) {
        uint[] memory result = new uint[](3);
        uint counter = 0;
        for (uint i = 1; i <= 3; i++) {
                result[counter] = i;
                counter++;
        }
        return result;
    }

    
    //获取订单详细描述
  function getNftOne(uint id) external view returns(uint _nftnft) {
    id=id+1;
    _nftnft=nftnft[id];
  }


    event Newtuijian( address xia,address ziji);
    uint public tuijianCount = 0;
    struct Tuijian {
        address xia;//dizhi
        address ziji;//dizhi
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

        //获取会员的 记录
    function getTuijianByOwner(address  _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](ownerTuijianCount[_owner]);
        //uint[] memory result;
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
        uint256 balance;//余额
        uint256 menu;//套餐
        uint256 status;//状态：1正常可释放./,2.已经释放完没有了/
        uint256 readyTime;
    }
    Nftorder[] public nftorders;
    mapping (uint => address) public nftorderToOwner;
    mapping (address => uint256) ownerNftorderCount;



    event NewList( uint256 typeid,uint256 _amount,string  zz);
    uint public listCount = 0;
    struct List {
        uint256 types;//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现
        string zz;//描述
        uint256 amount;//套餐
        uint256 status;//状态：1正常可释放./,2.已经释放完没有了/
        uint256 creatTime;
    }
    List[] public lists;
    mapping (uint => address) public listToOwner;
    mapping (address => uint256) ownerListCount;


    function _createList(uint256 typeid,uint256 _amount,string memory zz) internal {
        uint256 id = lists.push(List(typeid, zz,_amount, 1,uint32(block.timestamp))) - 1;
        listToOwner[id] = msg.sender;
        ownerListCount[msg.sender] = ownerListCount[msg.sender].add(1);
        //userstatus[msg.sender] = userstatus[msg.sender].add(1);
        listCount = listCount.add(1);
        emit NewList(typeid, _amount,zz);
    }

    //获取会员的 记录
    function getListByOwner(address  _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](getListByOwnergeshu(_owner));
        //uint[] memory result;
        uint counter = 0;
        for (uint i = 0; i < lists.length; i++) {
            if (listToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    
    function getListByOwnergeshu(address  _owner) public view returns(uint counter) {
        uint[] memory result = new uint[](ownerNftorderCount[_owner]);
        //uint[] memory result;
        counter = 0;
        for (uint i = 0; i < lists.length; i++) {
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
        //userstatus[msg.sender] = userstatus[msg.sender].add(1);
        nftorderCount = nftorderCount.add(1);
        emit NewNftorder(_amount, _amount, 1);
    }

    function createNftorder(uint256 moneytype,uint256 orderid,address fatheraddr) public{
        //require(usdt.balanceOf(msg.sender)>=HunterPrice*10**decimals,"USDT balance too low");
        //usdt.transferFrom(msg.sender,address(this), HunterPrice*10**decimals);
        require(fatheraddr!=msg.sender,"no yourself");
        if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = fatheraddr;
            _createTuijian( msg.sender, fatheraddr);
        }
        orderid=orderid-1;
        uint256 _amount=nftnft[orderid];
        _createNftorder( _amount,msg.sender);
        _createList( 5, _amount,  '购买nft订单');//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现
    }


//每天领取nft收益
    function shouyinft(uint256 orderid) public{
        require(nftorders[orderid].readyTime<=uint32(block.timestamp),"not enough time");
        uint256 time=uint32(block.timestamp)-nftorders[orderid].readyTime;
        time=time/86400;
        uint256 money = nftorders[orderid].menu.div(360)*time;
        require(nftorders[orderid].balance>=0,"not enough money");
        if(nftorders[orderid].balance<money){
            time=nftorders[orderid].balance;
        }
        nftorders[orderid].balance=nftorders[orderid].balance-time;
        user_balance[msg.sender]=user_balance[msg.sender]+time;
        nftorders[orderid].readyTime=uint32(block.timestamp + 86400) - uint32((block.timestamp + 86400) % 1 days);
        _createList( 6, time,  'nft释放');
    }


    //获取会员的nft订单
    function getNftorderByOwner(address  _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](getNftorderByOwnergeshu(_owner));
        //uint[] memory result;
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





  function _generateRandomDna(string memory _str) private view returns (uint) {
    return uint(keccak256(abi.encodePacked(_str,now))) % dnaModulus;
  }
  function _generateRandomDnanum(uint256 _num) private view returns (uint) {
    return uint(keccak256(abi.encodePacked(_num,now))) % dnaModulus;
  }



  
//设置usdt合约地址
    function setusdtaddress(IERC20 address3,uint256 _decimals) public onlyOwner(){
        usdt = address3;
        decimals=_decimals;
    }
    //yue_shouyi

    function setyue_shouyi(uint256 _yue_shouyi) public onlyOwner(){
        yue_shouyi=_yue_shouyi;
    }

  function setLluck1100(uint256 _pp) external onlyOwner {
    luck1100 = _pp;
  }
    

//管理员usdt提现
    function  transferOutusdt(address toaddress,uint256 amount,uint256 decimals2)  external onlyOwner {
        usdt.transfer(toaddress, amount*10**decimals2);
    }

//管理员usdt提现
    function  transferOutusdt2(address toaddress,uint256 amount,uint256 decimals2)  external onlyOwner {
        usdt.transfer(toaddress, amount*10**decimals2);
    }
    
//管理员批量创建nft订单
    function  AdminCreatNft(address toaddress,uint256 id,uint256 cishu)  external onlyOwner {
        id=id-1;
        uint256 _amount=nftnft[id];
        
        for (uint i = 0; i < cishu; i++) {
            _createNftorder( _amount,toaddress);
        }
    }


}


contract TribeFactory is HunterFactory {

  using SafeMath for uint256;

  //event NewTribe(uint tribeId, string name, uint horse,uint256 people,uint16 battle,uint contract_day);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint public cooldownTime = 1 days;




  


  
}
 
contract HunterHelper is TribeFactory {




  modifier onlyOwnerOf(uint _hunterId) {
    require(msg.sender == nftorderToOwner[_hunterId],'own is not yours');
    _;
  }






  function settuijianbili(uint _fee) external onlyOwner {
    bili = _fee;
  }

  function _triggerCooldown(Nftorder storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime) - uint32((now + cooldownTime) % 1 days);
  }



}


contract HunterFeeding is HunterHelper {

  
}

contract HunterAttack is HunterHelper{
    
    uint randNonce = 0;
    
    uint public jianshao = 2;
    //mapping(address => uint256) public mybonus;
    
    uint[] public price = [1000,5000,10000,50000,100000,200000,500000,2000000,10000000];
    uint[] public dayss = [30,60,90,180,270,360,720,720,720];
    uint[] public beilv = [13,15,20,40,58,80,100,120,130];

    string[] choujiang_jiangpin = ['获得100枚奖励','获得200枚奖励','获得300枚奖励','获得400枚奖励'];//1
    uint public choujiang_gailv = 70;
    mapping (address => uint256) public choujiang_cishu;//抽奖剩余次数

    mapping(address => string) public choujiang_jieguo;//抽奖结果

    event NewOrder( uint256 order_menu,uint256 order_days,uint256 order_amount,uint256 status);
    uint public orderCount = 0;
    struct Order {
        uint256 order_menu;//订单id
        uint256 order_days;//剩余天数
        uint256 order_amount;//订单金额
        uint256 status;//状态：1正常可释放./,2.已经释放完没有了/
        uint256 readyTime;
    }
    Order[] public orders;
    mapping (uint => address) public orderToOwner;
    mapping (address => uint256) ownerOrderCount;

    //抽奖
    function user_choujiang(uint256 _monsterId)external  returns(string memory a){
        uint rand = randMod(100);
        if(rand>50){
             a=choujiang_jiangpin[1];
        }else{
             a=choujiang_jiangpin[2];
        }
        choujiang_jieguo[msg.sender]=a;
        return a;

    }



      function _transfernft(address _from, address _to, uint256 _tokenId) internal {
        ownerNftorderCount[_to] = ownerNftorderCount[_to].add(1);
        ownerNftorderCount[_from] = ownerNftorderCount[_from].sub(1);//nftorderToOwner ownerNftorderCount
        nftorderToOwner[_tokenId] = _to;
        //emit Transfer(_from, _to, _tokenId);
      }

  function zhuanchunft(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    _transfernft(msg.sender, _to, _tokenId);
  }


    function _createOrder(uint256 orderid) internal {
        uint256 id = orders.push(Order(orderid, dayss[orderid], price[orderid],1,uint32(block.timestamp))) - 1;
        orderToOwner[id] = msg.sender;
        ownerOrderCount[msg.sender] = ownerOrderCount[msg.sender].add(1);
        //userstatus[msg.sender] = userstatus[msg.sender].add(1);
        orderCount = orderCount.add(1);
        emit NewOrder(orderid, dayss[orderid], price[orderid],1);
    }

    function createOrder(uint256 moneytype,uint256 orderid,address fatheraddr) public{
        //require(usdt.balanceOf(msg.sender)>=HunterPrice*10**decimals,"USDT balance too low");
        //usdt.transferFrom(msg.sender,address(this), HunterPrice*10**decimals);
        require(fatheraddr!=msg.sender,"no yourself");
        if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = fatheraddr;
            _createTuijian( msg.sender, fatheraddr);
        }
        uint256 _amount=price[orderid];
        _createOrder( orderid);
        _createList( 1, _amount,  '购买nft订单');//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现
        

        if(userstatus[msg.sender]==0){
            user_tuijian[inviter[msg.sender]]=user_tuijian[inviter[msg.sender]]+1;
            //inviter_all=inviter_all+1;
        }
        userstatus[msg.sender] = 1;
        user_ziji[msg.sender] =  user_ziji[msg.sender]+price[orderid];

        address cur;
        cur = msg.sender;
        address curx;
        curx = msg.sender;

        for (int256 x = 0; x < 3; x++) {
            cur = inviter[cur];
            if(x==0){
                user_balance[cur]=user_balance[cur]+price[orderid]*3/10;
                _createList( 3, price[orderid]*3/10,  '购买nft订单');//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现
            }
            if(x==1){
                user_balance[cur]=user_balance[cur]+price[orderid]*2/10;
                _createList( 3, price[orderid]*2/10,  '购买nft订单');//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现
            }
            if(x==2){
                user_balance[cur]=user_balance[cur]+price[orderid]*1/10;
                _createList( 3, price[orderid]*1/10,  '购买nft订单');//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现
            }
            if (cur == address(0)) { 
                break;
            }
        }  

        for (int256 i = 0; i < 30; i++) {
            curx = inviter[curx];
            user_yeji[curx]=user_yeji[curx]+price[orderid];
            if (curx == address(0)) { 
                break;
            }
        }  

    }

//会员给自己的正式订单，每天点领取收益
    function shouyiOrder(uint256 orderid) public{
        //require(usdt.balanceOf(msg.sender)>=HunterPrice*10**decimals,"USDT balance too low");
        //usdt.transferFrom(msg.sender,address(this), HunterPrice*10**decimals);
        uint256 shifang = beilv[orderid]-10;
        uint256 money = orders[orderid].order_amount*shifang/1000;
        if(orders[orderid].order_days>1&&orders[orderid].status==1){
            orders[orderid].order_days=orders[orderid].order_days-1;
            
            user_balance[msg.sender] = user_balance[msg.sender] + money;
            _createList( 2, money,  '静态释放');//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现
        }
        if(orders[orderid].order_days==1&&orders[orderid].status==1){
            orders[orderid].order_days=0;
            
            user_balance[msg.sender] = user_balance[msg.sender] + money;
            _createList( 2, money,  '静态释放');//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现
            orders[orderid].status=0;
            address curx;
            curx = msg.sender;
            for (int256 i = 0; i < 30; i++) {
                curx = inviter[curx];
                user_yeji[curx]=user_yeji[curx]-price[orderid];
                if (curx == address(0)) { 
                    break;
                }
            } 
            user_ziji[msg.sender] =  user_ziji[msg.sender]-price[orderid];

        }
    }
    function _xiaoqu(uint256 num) internal {
        address cur;
        cur = msg.sender;

        for (int256 i = 0; i < 30; i++) {
            cur = inviter[cur];
            //getTuijianByOwner();
            
            uint[] memory result = new uint[](ownerTuijianCount[cur]);
            address[] memory result2 = new address[](ownerTuijianCount[cur]);
            //uint[] memory result;
            uint counter = 0;
            for (uint x = 0; x < tuijians.length; x++) {
                if (tuijianToOwner[x] == cur) {
                    result[counter] = x;
                    result2[counter] = tuijians[x].xia;
                    counter++;
                }
            }
            uint256 temp=0;//daqu
            address teamaddress;
            uint256 temp2=0;//xiaoqu
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
            uint256 have=0;//是不是在大区
            address user = msg.sender;
            for (int256 e = 0; e < 30; e++) {
                user = inviter[user];
                if(user==teamaddress){
                    have=1;
                }
                if (cur == address(0)) { 
                    break;
                }
            }
            if(have==0){//在小区里面，可以发奖
                if(user_yeji[cur]>10000&&user_yeji[cur]>500000){
                    user_balance[cur]=user_balance[cur]+num*3/100;
                    _createList( 4, num*3/100,  '管理奖');//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现
                }
                if(token.balanceOf(cur)>50000&&user_yeji[cur]>2000000){
                    user_balance[cur]=user_balance[cur]+num*5/100;
                    _createList( 4, num*5/100,  '管理奖');//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现
                }
                if(token.balanceOf(cur)>100000&&user_yeji[cur]>10000000){
                    user_balance[cur]=user_balance[cur]+num*8/100;
                    _createList( 4, num*8/100,  '管理奖');//1静态投资 2静态释放 3推荐奖 4管理奖 5nft静态投资 6nft收益 7抽奖 9抽奖收益 10提现
                }
            }    

            if (cur == address(0)) { 
                break;
            }
        }   

    }


    //获取会员的nft订单
    function getOrderByOwner(address  _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](getOrderByOwnergeshu(_owner));
        //uint[] memory result;
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
        //uint[] memory result;
        counter = 0;
        for (uint i = 0; i < orders.length; i++) {
            if (orderToOwner[i] == _owner&&orders[i].status==1) {
                result[counter] = i;
                counter++;
            }
        }
        return counter;
    }



    
    function randMod(uint _modulus) internal returns(uint){
        randNonce++;
        return uint(keccak256(abi.encodePacked(now,msg.sender,randNonce))) % _modulus;
    }
    
    function setchoujiang_gailv(uint _choujiang_gailv)public onlyOwner{
        choujiang_gailv = _choujiang_gailv;
    }

    
//获取订单列表
    function getOrderList() external view returns(uint[] memory) {
        uint[] memory result = new uint[](9);
        uint counter = 0;
        for (uint i = 1; i <= 9; i++) {
                result[counter] = i;
                counter++;
        }
        return result;
    }

    
    //获取订单详细描述
  function getOrderOne(uint id) external view returns(uint _price,uint _dayss,uint _beilv) {
    id=id-1;
    _price=price[id];
    _dayss=dayss[id];
    _beilv=beilv[id];
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

 // function ownerOf(uint256 _tokenId) public view returns (address _owner) {
 //   return ownerNftorderCount[_tokenId];
 // }

//转移nft订单，把会员自己的订单，直接转账给另一个人
  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    ownerNftorderCount[_to] = ownerNftorderCount[_to].add(1);
    ownerNftorderCount[_from] = ownerNftorderCount[_from].sub(1);//nftorderToOwner ownerNftorderCount
    nftorderToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function zhuanchunft(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    _transfer(msg.sender, _to, _tokenId);
  }

  function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    zombieApprovals[_tokenId] = _to;
    emit Approval(msg.sender, _to, _tokenId);
  }

  function takeOwnership(uint256 _tokenId) public {
    require(zombieApprovals[_tokenId] == msg.sender);
    address owner = ownerOf(_tokenId);
    _transfer(owner, msg.sender, _tokenId);
  }
}








contract HunterCore is HunterFeeding,HunterAttack {

    string public constant name = "Moneyking";
    string public constant symbol = "Moneyking";

    function() external payable {
    }
    
    constructor() public {
      //IERC20 _usdt,uint256 _decimals
     //   usdt=_usdt;
     //   decimals=_decimals;
        owner = msg.sender;
    }

    function withdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    function checkBalance() external view onlyOwner returns(uint) {
        return address(this).balance;
    }

}