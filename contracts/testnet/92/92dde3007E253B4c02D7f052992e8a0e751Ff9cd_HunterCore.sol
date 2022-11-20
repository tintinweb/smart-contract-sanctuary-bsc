/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

/**
 *Submitted for verification at hecoinfo.com on 2022-06-24
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

contract PlayerFactory is Ownable {

  using SafeMath for uint256;

  event NewHunter(uint hunterId, string name,uint256 types,uint256 level,uint256 battle);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint public cooldownTime = 1 days;
  uint public hunterPrice = 0.01 ether;
  uint public hunterCount = 0;
  IERC20 usdt ;
  uint256 public decimals=18;
  uint256 public HunterPrice=100;




  

  mapping (address => address) public inviter;
  mapping(address => uint256) public mybonus;
  mapping(address => uint256) public tixiantime;
  
  mapping(address => uint256) public userstatus;
  mapping(address => uint256) public usersbouns;
  mapping(address => uint256) public usersbat;
  mapping(address => uint256) public teamnum;

  mapping(address => uint256) public tixianxianzhi;



event NewpkGame(string name1,string name2,uint256 jiegui,uint256 peilv1,uint256 peilv2,uint256 peilv3,string gametype);


    uint public pkgameCount = 0;

    struct Pkgame {
        string team1;//球队1
        string team2;//球队2
        uint256 jieguo;//0未开赛，1主胜利，2平，3主失败
        uint256 peilv1;//%主队胜利赔率
        uint256 peilv2;//%主队平局赔率
        uint256 peilv3;//%主队失败赔率
        uint256 status;//状态：1未开赛./,2.以开赛
        string gametype;//状态：小组赛，淘汰赛，半决赛，决赛
        uint256 readyTime;//开赛时间
    }
    Pkgame[] public pkgames;
    mapping (uint => address) public pkgamesToOwner;
    mapping (address => uint) ownerPkgameCount;
    mapping (uint => uint) public pkgamesFeedTimes;


    event NewGame(uint256 pkgameid,uint256 mai_jieguo,uint256 amount);
    uint public gameCount = 0;
    struct Game {
        uint256 pkgameid;//比赛id
        uint256 amount;//金额
        uint256 time;//下单时间
        uint256 status;//状态：1未开赛./,2.以开赛
        uint256 mai_jieguo;//状态：1主胜利，2平，3主失败
        uint256 chengbai;//成功失败:0未开始1成功2失败
    }

    Game[] public games;
    mapping (uint => address) public gameToOwner;
    mapping (address => uint) ownerGameCount;
    mapping (uint => uint) public gameFeedTimes;


//会员添加比赛订单
    function jionGames(uint256 pkgameid,uint256 mai_jieguo,uint256 amount) public  {
        require(pkgames[pkgameid].readyTime>=uint32(block.timestamp),"it is time out!");
        require(pkgames[pkgameid].status==1,"it is status wrong!");
        require(pkgames[pkgameid].jieguo==0,"it is jieguo wrong!");

        uint id = games.push(Game(pkgameid, amount,uint32(block.timestamp),1,mai_jieguo,0))-1;
        gameCount = gameCount.add(1);
        gameToOwner[id] = msg.sender;
        ownerGameCount[msg.sender] = ownerGameCount[msg.sender].add(1);
        emit NewGame(pkgameid, mai_jieguo, amount);
    }


    //填充结果
    function endgame(uint256 _pkgameId,uint256 _mai_jieguo) public {
      pkgames[_pkgameId].status=2;
      pkgames[_pkgameId].jieguo=_mai_jieguo;
      //uint[] memory result = new uint[](gameCount);
      
      for (uint i = 0; i < gameCount; i++) {
        if (games[i].status==1&&games[i].pkgameid==_pkgameId) {
          games[i].status==2;
          if(_mai_jieguo==games[i].mai_jieguo){//winer
              if(_mai_jieguo==1){
                  usersbouns[gameToOwner[i]]=pkgames[games[i].pkgameid].peilv1*games[i].amount.div(100);
              }
              if(_mai_jieguo==2){
                  usersbouns[gameToOwner[i]]=pkgames[games[i].pkgameid].peilv2*games[i].amount.div(100);
              }
              if(_mai_jieguo==3){
                  usersbouns[gameToOwner[i]]=pkgames[games[i].pkgameid].peilv3*games[i].amount.div(100);
              }
          }
        
        }
      }
    
    }
    /*
    //某场未开赛的订单数量
    function getnogamelistshu(uint256 _pkgameId) public view returns(uint counter) {
      uint[] memory result = new uint[](gameCount);
      counter = 0;
      for (uint i = 0; i < gameCount; i++) {
        if (games[i].status==1) {
          result[counter] = i;
          counter++;
        }
      }
    return counter;
    }*/

//获取某会员购买的比赛
  function getGameByOwner(address  _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](getPkgameByOwnergeshu(_owner));
    uint counter = 0;
    for (uint i = 0; i < games.length; i++) {
      if (gameToOwner[i] == _owner&&games[i].status==1) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }
//获取某个会员的购买数    Game games game  
  function getGameByOwnergeshu(address  _owner) public view returns(uint counter) {
    uint[] memory result = new uint[](ownerGameCount[_owner]);
    //uint[] memory result;
      counter = 0;
    for (uint i = 0; i < games.length; i++) {
      if (gameToOwner[i] == _owner&&games[i].status==1) {
        result[counter] = i;
        counter++;
      }
    }
    return counter;
  }


//创建比赛列表
    function newpkGames(string memory _team1,string memory _team2,uint256 jieguo,uint256 peilv1,uint256 peilv2,uint256 peilv3,uint256 time,string memory gametype) public  {
        uint id = pkgames.push(Pkgame(_team1,_team2,jieguo,peilv1,peilv2,peilv3,1,gametype,time))-1;
        pkgameCount = pkgameCount.add(1);
        pkgamesToOwner[id] = msg.sender;
        ownerPkgameCount[msg.sender] = ownerPkgameCount[msg.sender].add(1);
        emit NewpkGame(_team1, _team2, jieguo, peilv1,peilv2,peilv3,gametype);
    }
  function getPkgameByOwnergeshu(address  _owner) public view returns(uint counter) {
    uint[] memory result = new uint[](ownerPkgameCount[_owner]);
    //uint[] memory result;
      counter = 0;
    for (uint i = 0; i < pkgames.length; i++) {
      if (pkgamesToOwner[i] == _owner&&pkgames[i].status==1&&pkgames[i].readyTime>=uint32(block.timestamp)) {//
        result[counter] = i;
        counter++;
      }
    }
    return counter;
  }
//
  function getPkgameByOwner(address  _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](getPkgameByOwnergeshu(_owner));
    uint counter = 0;
    for (uint i = 0; i < pkgames.length; i++) {
      if (pkgamesToOwner[i] == _owner&&pkgames[i].status==1&&pkgames[i].readyTime>=uint32(block.timestamp)) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

    function getPkgamelistshu() public view returns(uint counter) {
    uint[] memory result = new uint[](pkgameCount);
    //uint[] memory result;
      counter = 0;
    for (uint i = 0; i < pkgameCount; i++) {
      if (pkgames[i].status==1&&pkgames[i].readyTime>=uint32(block.timestamp)) {//
        result[counter] = i;
        counter++;
      }
    }
    return counter;
  }
//获取可参与的比赛列表
  function getPkgamelist() external view returns(uint[] memory) {
    uint[] memory result = new uint[](getPkgamelistshu());
    uint counter = 0;
    for (uint i = 0; i < pkgameCount; i++) {
      if (pkgames[i].status==1&&pkgames[i].readyTime>=uint32(block.timestamp)) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }








  function _generateRandomDna(string memory _str) private view returns (uint) {
    return uint(keccak256(abi.encodePacked(_str,now))) % dnaModulus;
  }
  function _generateRandomDnanum(uint256 _num) private view returns (uint) {
    return uint(keccak256(abi.encodePacked(_num,now))) % dnaModulus;
  }

  function setHunterPrice(uint256 _price) external onlyOwner {
    hunterPrice = _price;
  }

  
//设置usdt合约地址
    function setusdtaddress(IERC20 address3,uint256 _decimals) public onlyOwner(){
        usdt = address3;
        decimals=_decimals;
    }
    

//管理员usdt提现
    function  transferOutusdt(address toaddress,uint256 amount,uint256 decimals2)  external onlyOwner {
        usdt.transfer(toaddress, amount*10**decimals2);
    }
    
 //会员的余额提现方法   
    function  tixian(uint256 num)  external returns (bool) {
        
        require(usersbouns[msg.sender]>=num,"not have enongh money.");
        require(tixianxianzhi[msg.sender]!=1,"not have enongh money.");
  

        usersbouns[msg.sender]=usersbouns[msg.sender]-num;//
        tixiantime[msg.sender] = uint32(now + cooldownTime) - uint32((now + cooldownTime) % 1 days);
        usdt.transfer(msg.sender, num*10**18);//
        return true;
    }


  function _tixianCooldown(address toaddress) internal {
    tixiantime[toaddress] = uint32(now + cooldownTime) - uint32((now + cooldownTime) % 1 days);
  }
}
contract ClothingFactory is PlayerFactory {
}
contract HunterHelper is ClothingFactory {
  uint public levelUpFee = 0.001 ether;
  uint public day_price =  5;
  uint public day10_price = 40;
  uint public join_price = 40;

  modifier onlyOwnerOf(uint _hunterId) {
    require(msg.sender == pkgamesToOwner[_hunterId],'game is not yours');
    _;
  }




}

contract HunterFeeding is HunterHelper {

}

contract HunterAttack is HunterHelper{
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
    return ownerPkgameCount[_owner];
  }
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return pkgamesToOwner[_tokenId];
  }
  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    ownerPkgameCount[_to] = ownerPkgameCount[_to].add(1);
    ownerPkgameCount[_from] = ownerPkgameCount[_from].sub(1);
    pkgamesToOwner[_tokenId] = _to;
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
contract HunterMarket is HunterOwnership {
}
contract HunterCore is HunterMarket,HunterFeeding,HunterAttack {
    string public constant name = "ZISgame";
    string public constant symbol = "ZISgame";
    function() external payable {
    }
    constructor() public {
      //IERC20 _usdt,uint256 _decimals
     //   usdt=_usdt;
    //    decimals=_decimals;
       owner = msg.sender;
    }
    function withdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }
    function checkBalance() external view onlyOwner returns(uint) {
        return address(this).balance;
    }
}