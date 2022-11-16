/**
 *Submitted for verification at BscScan.com on 2022-11-16
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


  struct Player {
    string name;//名字
    uint256 types;//类型：1球员./,2.
    uint256 level;//级别
    string level_name;//级别名称
    uint256 battle;//战斗力
    uint256 dna;//容量

    uint256 status;//状态：1正常./,2.已经加入球队/3.已经在挂卖状态/4.死了
    uint256 shoes;//鞋子
    uint256 Jersey;//上衣
    uint256 trousers;//裤子
    uint256 isTeam;//是否在球队0，1
    uint256 readyTime;
  }

  Player[] public players;

  mapping (uint => address) public playerToOwner;
  mapping (address => uint256) ownerPlayerCount;
  mapping (uint => uint) public playerFeedTimes;

  mapping (address => address) public inviter;
  mapping(address => uint256) public mybonus;
  mapping(address => uint256) public tixiantime;
  
  mapping(address => uint256) public userstatus;
  mapping(address => uint256) public usersbouns;
  mapping(address => uint256) public usersbat;
  mapping(address => uint256) public teamnum;




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
      uint[] memory result = new uint[](gameCount);
      
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
    for (uint i = 0; i < players.length; i++) {
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
    for (uint i = 0; i < players.length; i++) {
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
        bool Limited = tixiantime[msg.sender] !=0;
        require(Limited,"Exchange interval is too short.");
        uint256 lasttimehei = uint32((block.timestamp - tixiantime[msg.sender])/86400 );   
        if(lasttimehei<1){
            lasttimehei=1;
        }  
        uint256 shui;
        if(lasttimehei<=15){
            shui = 30-(lasttimehei*2);
        }else{
            shui = 0;
        }
        mybonus[msg.sender]=mybonus[msg.sender]-num;//
        tixiantime[msg.sender] = block.timestamp;
        usdt.transferFrom(msg.sender,msg.sender, num*10**18);//基金钱包
        return true;
    }
}
contract ClothingFactory is PlayerFactory {
}
contract HunterHelper is ClothingFactory {
  uint public levelUpFee = 0.001 ether;
  uint public day_price =  5;
  uint public day10_price = 40;
  uint public join_price = 40;
  modifier aboveLevel(uint _level, uint _zombieId) {
    require(players[_zombieId].level >= _level,'Level is not sufficient');
    _;
  }
  modifier onlyOwnerOf(uint _hunterId) {
    require(msg.sender == playerToOwner[_hunterId],'Zombie is not yours');
    _;
  }
  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }
  function setLluck1100(uint _fee) external onlyOwner {
  //  luck1100 = _fee;//0-100
  }

  function _triggerCooldown(Player storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime) - uint32((now + cooldownTime) % 1 days);
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
    return ownerPlayerCount[_owner];
  }
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return playerToOwner[_tokenId];
  }
  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    ownerPlayerCount[_to] = ownerPlayerCount[_to].add(1);
    ownerPlayerCount[_from] = ownerPlayerCount[_from].sub(1);
    playerToOwner[_tokenId] = _to;
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