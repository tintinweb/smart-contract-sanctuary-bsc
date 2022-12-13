/**
 *Submitted for verification at BscScan.com on 2022-12-12
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
  

  IERC20 public  usdt ;
  uint256 public decimals=18;

  uint256 public bili=10;
  uint256 public luck1100=0;




  mapping (address => address) public inviter;
  mapping(address => uint256) public mybonus;
  mapping(address => uint256) public tixiantime;
  
  mapping(address => uint256) public userstatus;
  mapping(address => uint256) public usersbouns;//社区盲盒

  mapping(address => uint256) public user_yeji;//用户业绩
  mapping(address => uint256) public user_tuijian;//推荐人数
  mapping(address => uint256) public user_level;//会员级：0，1，2，3
    mapping(address => string) public user_level_name;//会员级名称
  mapping(address => uint256) public user_balance;//用户余额

  //mapping(address => uint256) public user_shequbox;//社区盲盒
  //user_batcishu  user_tuijian  user_shengli  user_jiangjin user_shengli_jiangjin



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




    function _createNftorder(uint256 _amount) internal {
        uint256 id = nftorders.push(Nftorder(_amount, _amount, 1,uint32(block.timestamp))) - 1;
        nftorderToOwner[id] = msg.sender;
        ownerNftorderCount[msg.sender] = ownerNftorderCount[msg.sender].add(1);
        //userstatus[msg.sender] = userstatus[msg.sender].add(1);
        nftorderCount = nftorderCount.add(1);
        emit NewNftorder(_amount, _amount, 1);
    }

    function createNftorder(uint256 moneytype,uint256 orderid,address fatheraddr) public{
        //require(usdt.balanceOf(msg.sender)>=HunterPrice*10**decimals,"USDT balance too low");
        //usdt.transferFrom(msg.sender,address(this), HunterPrice*10**decimals);
        uint256 _amount=1000;
        _createNftorder( _amount);
        _createList( 1, 100,  '购买nft订单');
    }

//每天领取nft收益
    function shouyinft(uint256 orderid) public{
        //require(usdt.balanceOf(msg.sender)>=HunterPrice*10**decimals,"USDT balance too low");
        //usdt.transferFrom(msg.sender,address(this), HunterPrice*10**decimals);
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
    
    uint[] price = [1000,5000,10000,50000,100000,200000,500000,2000000,10000000];
    uint[] dayss = [30,60,90,180,270,360,720,720,720];
    uint[] beilv = [13,15,20,40,58,80,100,120,130];

    string[] choujiang_jiangpin = ['获得100枚奖励','获得200枚奖励','获得300枚奖励','获得400枚奖励'];//1
    uint public choujiang_gailv = 70;
    mapping (address => uint256) choujiang_cishu;//抽奖剩余次数

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
        uint256 _amount=1000;
        _createOrder( orderid);
    }

//会员给自己的正式订单，每天点领取收益
    function shouyiOrder(uint256 orderid) public{
        //require(usdt.balanceOf(msg.sender)>=HunterPrice*10**decimals,"USDT balance too low");
        //usdt.transferFrom(msg.sender,address(this), HunterPrice*10**decimals);
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
        for (uint i = 0; i < 9; i++) {
                result[counter] = i;
                counter++;
        }
        return result;
    }

    
    //获取订单详细描述
  function getOrderOne(uint id) external view returns(uint _price,uint _dayss,uint _beilv) {
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

  function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
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