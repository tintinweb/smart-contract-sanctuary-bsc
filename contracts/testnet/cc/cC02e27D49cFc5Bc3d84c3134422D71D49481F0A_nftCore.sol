// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)
// SPDX-License-Identifier: SimPL-2.0

pragma solidity ^0.8.0;

import "./nft.sol";

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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

contract nftCore is GameItem {
    using SafeMath for uint256;
    uint public cooldownTime = 1 days;
    uint public hunterCount = 0;
    IERC20 public  usdt ;
    IERC20 public  token ;
    uint256 public decimals=18;
    uint256 public bili=10;
    mapping(address => uint256) public tixiantime;
    mapping(address => uint256) public userstatus;
    mapping(address => uint256) public user_tuijian;//推荐人数
    mapping(address => uint256) public user_yeji;//业绩
    mapping(address => uint256) public user_levels;//级别
    mapping(address => uint256) public user_linlevel;//级别
    mapping(address => uint256) public user_team;//伞下总人数（团队人数）
    mapping(address => uint256) public balance;//usdt余额
    mapping(address => uint256) public token_balance;//token余额
    mapping (address => address) public inviter;//推荐领导人
    mapping(address => uint256) public user_ziji;//用户购买次数
    address public admin_user ;
    address public admin_push ;
    address public admin_guanli ;


//用户列表表部分
    event Newuserlist( address _uuser,uint256 order_creatTime);
    uint public userlistCount = 0;
    struct Userlist {
        address user;
        uint256 order_creatTime;
    }
    //Userlist[] public userlists;
    mapping  (uint=>Userlist) public userlists;
    mapping (uint => address) public userlistToOwner;
    mapping (address => uint256) public ownerUserlistCount;
    mapping (address => uint256) public ownerfatherlistCount;


    function _createUserlist(address ziji,address fatheraddr) public {//internal
        inviter[ziji] = fatheraddr;
        Userlist  memory userlist = Userlist(ziji,uint32(block.timestamp));
        userlistToOwner[userlistCount] = ziji;
        userlists[userlistCount]=userlist;
        userlistCount = userlistCount+1;
        ownerfatherlistCount[fatheraddr] = ownerfatherlistCount[fatheraddr]+1;
        ownerUserlistCount[fatheraddr] = ownerUserlistCount[fatheraddr]+1;
    }

    function _adtuijianren(uint256 _level) public {
        //_createUserlist( msg.sender, _baba);
        user_linlevel[msg.sender]=_level;
    }

    function getTuijianByOwnerLevel(address  _owner,uint256 _level) public view returns(uint shus) {
        shus = 0;
        uint[] memory result = new uint[](ownerfatherlistCount[_owner]);
        
        for (uint i = 0; i < userlistCount; i++) {
            if (inviter[userlistToOwner[i]] == _owner&&user_linlevel[userlistToOwner[i]]>=_level) {//
            result[shus] = i;
                shus++;
            }
        }
        return shus;
    }
    function aceshi(address  _owner) public {
        uint  aa=getTuijianByOwnerLevel(_owner,2);
    }




    function getTuijianByOwner(address  _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](ownerfatherlistCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < userlistCount; i++) {
            if (inviter[userlistToOwner[i]] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }


//list订单列表部分
    uint public listCount = 0;
    struct List {
        uint256 types;//1充值。 2提现。3购买。4出售  5预约。6推荐奖。 7管理奖。 8评级奖。 9回购。  10合伙人收益
        string zz;
        uint256 amount;
        uint256 status;
        uint256 creatTime;
    }
    mapping  (uint=>List) public lists;
    mapping (uint => address) public listToOwner;
    mapping (address => uint256) public ownerListCount;

    function savelist() public {
        _savelist(1,'heihei',100,msg.sender);
    }

    function _savelist(uint256 _types,string memory _zz,uint256 _amount,address _user) internal {
        List  memory list = List(_types,_zz,_amount,1,uint32(block.timestamp));
        listCount=listCount.add(1);
        lists[listCount]=list;
        ownerListCount[_user] = ownerListCount[_user].add(1);
        listToOwner[listCount] = _user;//158报单 2推荐奖 3极差奖 4ipo 5提现 6
    }

//获取用户资金记录列表
    function getListByOwner(address  _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](getListByOwnergeshu(_owner));

        uint counter = 0;
        if(listCount>0){
            for (uint i=listCount; i >0; i=i-1) {
                if (listToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
                }
            }
        }
        return result;
    }


//获取用户 某行为资金记录列表： _id=1,2,3,4,5,6,7,8.....
    function getListByOwners(address  _owner,uint _id) external view returns(uint[] memory) {
        uint[] memory result = new uint[](getListByOwnergeshu(_owner));

        uint counter = 0;
        if(listCount>0){
            for (uint i=listCount; i >0; i=i-1) {
                if (listToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
                }
            }
        }
        return result;
    }
    
    function getListByOwnergeshu(address  _owner) public view returns(uint counter) {
        uint[] memory result = new uint[](ownerListCount[_owner]);

        counter = 0;
        for (uint i = 0; i <= listCount; i++) {
            if (listToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return counter;
    }


//订单部分
    uint[] public order_price = [333,666,999,100]; 
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    string[] public order_name = [unicode'第一期精美创世',unicode'第二期精美创世',unicode'第三期精美创世',unicode'生肖NFT'];
    string[] public order_url = [unicode'http://baidu.com',unicode'http://baidu.com',unicode'http://baidu.com',unicode'http://baidu.com'];
    uint256 public timeshang = 36000;
    uint256 public timeshangend = 37800;
    uint256 public timexia = 57600;
    uint256 public timexiaend = 59400;
    mapping (uint => address) public orderLastOwner;
    mapping (uint => uint256) public orderLastPrice;

 //   using Counters for Counters.Counter;
  //  Counters.Counter private _tokenIds; //计数器，用于NTF的编号
/*
    uint public orderCount = 0;  
    struct Order {
        uint256 order_type;//1第一期nft，2第二期nft，3第三期nft ,4正常抢购nft
        string order_url;//外部721链接，不用前端管
        uint256 order_dna;//dna，需要合成图片
        uint256 order_price;//nft价格，
        uint256 order_amount;//nft在市场里的剩余数量
        uint256 order_status;//状态，，，，1，2，3
        string order_name;//nft名字
        string order_zz;//nft描述. 
        uint256 order_startTime;
        uint256 order_endTime;
    }  
    mapping  (uint=>Order) public orders;
    mapping (uint => address) public orderToOwner;
    mapping (address => uint256) public ownerOrderCount;
*/

    function _generateRandomDnanum(uint256 _num) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(_num,uint32(block.timestamp)))) % dnaModulus;
    }


    function _saveorder(uint256 _types ,address _user,uint256 _time ,uint256 _status ) internal {
        uint256 _order_price = order_price[_types-1];
        uint256 randGailvs = _generateRandomDnanum(_types);
        string memory name = order_name[_types-1];
        uint256 randGailv = _generateRandomDnanum(randGailvs);
        uint256 order_dna = randGailv % 100000000;
        string memory _order_url = order_url[_types-1];
        Order  memory order = Order(_types,_order_url,order_dna,_order_price,_status,name,unicode'正常状态',_time);
        
        
        uint256 tid = _neibumint( _user,_order_url);
        orderCount=orderCount;
        orderLastOwner[orderCount] = _user;
        orderLastPrice[orderCount] = _order_price;
        orderCount = orderCount.add(1);
        orders[tid]=order;
        ownerOrderCount[_user] = orderCount;
        orderToOwner[tid] = _user;
    }
    /*
    function aaaa() external view returns(uint256 now,uint256 dian,uint256 new_dian ,uint256 ok,uint256 ok2,uint256 iss){
        now = uint32(block.timestamp);//- uint32(block.timestamp)%86400;//+uint32(block.timestamp)+timeshang+86400;  uint32(block.timestamp)-
        dian = uint32(block.timestamp)%86400;
        new_dian = uint32(block.timestamp)-uint32(block.timestamp)%86400;
        ok = uint32(block.timestamp)-uint32(block.timestamp)%86400+timeshang+86400-28800;
        ok2 = uint32(block.timestamp)-uint32(block.timestamp)%86400+timeshang+86400-7200;
        iss = 0;
        uint32 xianzai = 1677354455;
        if(uint32(block.timestamp)>=xianzai){
            iss = 1;
        }
    }*/


    function adminxiugaitime(uint256 _id,uint32 _time) public {
        //require(msg.sender==admin_user,"not admin.");
        //orders[_id].order_startTime=_time;
    }


    function adminordercreat(address _user) public {
        uint256 time = uint32(block.timestamp);
        
        _saveorder( 1,_user,time,2);
    }



//用户订单列表
    function getOrderByOwner(address  _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](getOrderByOwnergeshu(_owner));

        uint counter = 0;
        for (uint i = 0; i <= orderCount; i++) {
            if (orderToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    
    function getOrderByOwnergeshu(address  _owner) public view returns(uint counter) {
        uint[] memory result = new uint[](ownerOrderCount[_owner]);
        counter = 0;
        for (uint i = 0; i <= orderCount; i++) {
            if (orderToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return counter;
    }

    uint[] public priceteam_start = [0,500,1000,2000]; //价格分组：起始价格
    uint[] public priceteam_end = [500,1000,2000,3000]; //价格分组：结束价格
    uint public priceteam_num = 4; //显示一共多少组价格


//价格分组，的列表
    function getPriceTeamList() external view returns(uint[] memory) {
        uint[] memory result = new uint[](priceteam_num);
        uint counter = 0;
        for (uint i = 0; i < priceteam_num; i++) {
                result[counter] = i;
                counter++;
        }
        return result;
    }

//价格分组里面具体，每组的，起始价格和终止价格
  function getPriceTeamOne(uint id) external view returns(uint _priceteam_start,uint _priceteam_end) {
    _priceteam_start=priceteam_start[id];
    _priceteam_end=priceteam_end[id];
  }

//每天上午市场可抢购列表. //timeshang. timeshangend  timexia timexiaend
    function getMarket1(uint256  _priceteam) external view returns(uint[] memory) {
        uint[] memory result = new uint[](getOrdershubyid(_priceteam));
        uint32 time=uint32(block.timestamp);
        uint counter = 0;
        uint256 id=_priceteam;
        for (uint i = 0; i <= orderCount; i++) {
            if (orders[i].order_price>=priceteam_start[id]&&orders[i].order_price<=priceteam_end[id]&&orders[i].order_time<=time&&orders[i].order_type==1&&orders[i].order_status==2) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }


    function getOrdershubyid(  uint256  _priceteam) public view returns(uint counter) {
        uint[] memory result = new uint[](orderCount);
        counter = 0;
        uint32 time=uint32(block.timestamp);
        uint256 id=_priceteam;
        for (uint i = 0; i <= orderCount; i++) {
            if (orders[i].order_price>=priceteam_start[id]&&orders[i].order_price<priceteam_end[id]&&orders[i].order_time<=time&&orders[i].order_type==1&&orders[i].order_status==2) {
                result[counter] = i;
                counter++;
            }
        }
        return counter;
    }
    


    //用户上午购买前的检测
    function getBuyMarketOk1(uint256 _id) external view returns(uint256 nowprice,uint256 neeprice,string memory need,uint256 ok) {
        neeprice = orders[_id].order_price;
        need = unicode'可以购买';
        ok=1;
        if(balance[msg.sender]<neeprice){
            need = unicode'资金不足不可以购买';ok=0;
        }
        uint32 time=uint32(block.timestamp);
        if (orders[_id].order_time<=time) {
            need = unicode'时间超限';ok=0;
        }
        if (orders[_id].order_status!=2) {
            need = unicode'NFT状态不正常';ok=0;
        }
        if (orders[_id].order_type!=1) {
            need = unicode'该NFT不能出售';ok=0;
        }
    }

    

//用户上午购买
    function userBuyMarket1(uint256 _id,address _baba) public {
        require(_baba!=msg.sender,"Can't do it yourself");
        require(orders[_id].order_status==2,"status not 2");
        uint256 need = orders[_id].order_price;
        require(balance[msg.sender]<need,"NEED MORE MONEY");
        require(ownerOrderCount[msg.sender]<=nftnum,"nft more ");

        uint32 time=uint32(block.timestamp);
        require(orders[_id].order_time<time,"Time exceeds");
        if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = _baba;
            _createUserlist(msg.sender,_baba);
            if(user_ziji[msg.sender]==0){
                user_tuijian[_baba] = user_tuijian[_baba].add(1);
                _adteam( msg.sender);
            }
        }
        user_ziji[msg.sender]+=1;

        balance[msg.sender]=balance[msg.sender]-need;
        _adyeji( msg.sender);
        _nfttransfer(orderToOwner[_id],msg.sender,_id);
        _tjj( orders[_id].order_price, _baba);
        _jcj( orders[_id].order_price, msg.sender);
        _sj(msg.sender);
        orders[_id].order_status=1;
        _savelist(3,unicode"抢购nft" ,orders[_id].order_price,msg.sender);
        liushui += orders[_id].order_price*200;
    }


//用户出售订单
    function userSell(uint256 _id) public {
        uint256 newprice = adprice+1000;
        uint256 newmoney = jingtai+1000;
        order_price[_id] = order_price[_id]*newprice;
        balance[orderLastOwner[_id]] +=order_price[_id]*newmoney;
        orders[_id].order_status=2;
        _savelist(3,unicode"出售所得" ,order_price[_id]*newmoney,orderLastOwner[_id]);
        
    }



    uint public adprice = 1000;
    uint public jingtai = 200;
    uint public tuijian = 100;
    uint public pingji = 120;
    uint[] public jicha = [0,0,40,80,120,160];
    uint public v5 = 0;
    uint public liushui = 0;
    uint public nftnum = 10;



    function _sj(address _user) public {
        address curx = _user;
        for (int256 i = 0; i < 30; i++) {
            curx = inviter[curx];
            if(user_levels[curx]==5){
                break;
            }
            if(user_levels[curx]<2){
                if(user_tuijian[curx]>=3&&user_team[curx]>=10&&user_ziji[curx]>=200&&user_yeji[curx]>=1000){
                    user_levels[curx]==2;
                }
            }
            if(user_levels[curx]==2){
                uint shu = getTuijianByOwnerLevel(curx,2);
                if(shu>=2&&user_yeji[curx]>=400){
                    user_levels[curx]==3;
                }
            }
            if(user_levels[curx]==3){
                uint shu = getTuijianByOwnerLevel(curx,3);
                if(shu>=3&&user_yeji[curx]>=600){
                    user_levels[curx]==4;
                }
            }
            if(user_levels[curx]==4){
                uint shu = getTuijianByOwnerLevel(curx,3);
                if(shu>=3){
                    user_levels[curx]==5;
                }
            }
            if (curx == address(0)) { 
                break;
            }
        }    
    }

    function _adlinshi(address _user,uint _le) public {
        address curx = _user;
        for (int256 i = 0; i < 30; i++) {
            curx = inviter[curx];
            
            if (user_linlevel[curx]<_le) { 
                user_linlevel[curx]==_le;
            }
            if (curx == address(0)) { 
                break;
            }
        }  
    }

    function _adyeji(address _user) public {
        address curx = _user;
        for (int256 i = 0; i < 30; i++) {
            curx = inviter[curx];
            user_yeji[curx]=user_yeji[curx]+1;
            if (curx == address(0)) { 
                break;
            }
        }  
    }

    function _adteam(address _user) public {
        address curx = _user;
        for (int256 i = 0; i < 30; i++) {
            curx = inviter[curx];
            user_team[curx]=user_team[curx]+1;
            if (curx == address(0)) { 
                break;
            }
        }  
    }

    function _tjj(uint256 _num,address _user) public {
        if(user_ziji[_user]>0){
            balance[_user]=balance[_user]+_num*tuijian;
        }
    }

    function _jcj(uint256 _num,address _user) public {
        address curx;
        curx = _user;
        uint256 max=0 ;
        uint256 cha=0 ;
        uint256 ci=0 ;
        for (int256 i = 0; i < 30; i++) {
            curx = inviter[curx];
            uint256 rate ;
            
                if(user_levels[curx]>max&&ci!=0){
                    cha=jicha[user_levels[curx]]-jicha[max] ; 
                    max=user_levels[curx];
                    if(user_levels[curx]!=5){
                        balance[curx]=balance[curx]+cha*_num;
                        _savelist(3,unicode"极差奖" ,cha*_num,curx);
                    }else{
                        v5 += cha*_num;
                    }
                }
                if(user_levels[curx]==max&&ci==0){
                    if(user_levels[curx]!=5){
                        balance[curx]=balance[curx]+pingji*_num;
                        _savelist(3,unicode"平级奖" ,cha*_num,curx);
                        ci+=1;
                    }
                }

        }
    }




  



    function  userchongzhi(uint256 num)  external returns (bool) {
     //   require(user_balance[msg.sender]>=num*100,"moneylow.");
      //  user_balance[msg.sender]=user_balance[msg.sender]-num*100;

      //  token.transfer(msg.sender, (100-shouxufei)*num*10**16);
        return true;
    }



//usdt提现
    function  usdt_tixian(uint256 num)  external returns (bool) {
     //   require(user_balance[msg.sender]>=num*100,"moneylow.");
      //  user_balance[msg.sender]=user_balance[msg.sender]-num*100;

      //  token.transfer(msg.sender, (100-shouxufei)*num*10**16);
        return true;
    }
//token提现
    function  token_tixian(uint256 num)  external returns (bool) {
     //   require(user_balance[msg.sender]>=num*100,"moneylow.");
      //  user_balance[msg.sender]=user_balance[msg.sender]-num*100;

      //  token.transfer(msg.sender, (100-shouxufei)*num*10**16);
        return true;
    }


    function adminsetorder_price(address _user,uint256 _num ) public {
        //require(msg.sender==admin_user,"not admin.");
        balance[_user] = _num;
    }






}