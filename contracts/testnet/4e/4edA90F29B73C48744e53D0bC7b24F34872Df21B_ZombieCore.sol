/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

pragma solidity ^0.5.12;

contract ERC721 {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function transfer(address _to, uint256 _tokenId) public;
  function approve(address _to, uint256 _tokenId) public;
  function takeOwnership(uint256 _tokenId) public;
}

contract Migrations {
  address public owner;
  uint public last_completed_migration;

  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
contract Ownable {
  address payable public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner,'Must contract owner');
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address payable newOwner) public onlyOwner {
    require(newOwner != address(0),'Must contract owner');
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
contract ZombieFactory is Ownable {

  using SafeMath for uint256;

  event NewZombie(uint zombieId, uint level);

  //uint dnaDigits = 16;
  //uint dnaModulus = 10 ** dnaDigits;
  //uint public cooldownTime = 1 days;
  uint public zombiePrice = 0.01 ether;
  uint public zombieCount = 0;

  struct Zombie {
    //string name;
    //uint dna;
    uint level;

  }

  Zombie[] public zombies;

  mapping (uint => address) public zombieToOwner;
  mapping (address => uint) ownerZombieCount;
  mapping (uint => uint) public zombieFeedTimes;

  function _createZombie(uint _jibie,address  _add) internal {
//require(_jibie<3,"Cannot be greater than 3");
//require(_jibie>1,"Cannot be less than 1");
    uint id = zombies.push(Zombie( _jibie )) - 1;
    zombieToOwner[id] = _add;
    ownerZombieCount[_add] = ownerZombieCount[_add].add(1);
    zombieCount = zombieCount.add(1);
    emit NewZombie(id,  _jibie);
  }

//  function _generateRandomDna(string memory _str) private view returns (uint) {
 //   return uint(keccak256(abi.encodePacked(_str,now))) % dnaModulus;
 // }

  function createZombie(uint _level,address  _add) public onlyOwner{
  //  require(ownerZombieCount[msg.sender] == 0);
 //   uint randDna = _generateRandomDna(_name);
  //  randDna = randDna - randDna % 10;
require(_level<4,"Cannot be greater than 3");
require(_level>0,"Cannot be less than 1");
    _createZombie(_level, _add);
  }

    function create100Zombie(uint _level,address  _add,uint _num) public onlyOwner{
  //  require(ownerZombieCount[msg.sender] == 0);
 //   uint randDna = _generateRandomDna(_name);
  //  randDna = randDna - randDna % 10;
require(_level<4,"Cannot be greater than 3");
require(_level>0,"Cannot be less than 1");

    for (uint i = 0; i < _num; i++) {
      _createZombie(_level, _add);
    }

  }



  function setZombiePrice(uint _price) external onlyOwner {
    zombiePrice = _price;
  }

}
contract ZombieHelper is ZombieFactory {

  uint public levelUpFee = 0.001 ether;

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level,'Level is not sufficient');
    _;
  }
  modifier onlyOwnerOf(uint _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId],'Zombie is not yours');
    _;
  }


 // function changeName(uint _zombieId, string calldata _newName) external  aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
 //   zombies[_zombieId].name = _newName;
 // }

  function getZombiesByOwner(address  _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }


  function getZombiesByOwnerlevel(address  _owner,uint _level) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    //uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner&&zombies[i].level == _level) {
        result[counter] = i;
        counter++;
        
      }else{
        continue;
      }
    }
    return result;
  }


  function getZombiesBylevel(uint _level) external view returns(uint[] memory) {
    uint[] memory result = new uint[](zombieCount);
    uint counter = 0;
    //uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombies[i].level == _level) {
        result[counter] = i;
        counter++;
        
      }else{
        continue;
      }
    }
    return result;
  }


  function getZombiesByAlllevelnum(uint _level) external view returns(uint) {
    uint[] memory result = new uint[](zombieCount);
    uint counter = 0;
    uint num = 0;
    //uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombies[i].level == _level) {
        result[counter] = i;
        result[num] = counter;
        counter++;
        
      }
    }
    return counter;
  }


  function getZombiesByOwnerlevelnum(address  _owner,uint _level) external view returns(uint) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    uint num = 0;
    //uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner&&zombies[i].level == _level) {
        result[counter] = i;
        result[num] = counter;
        counter++;
        
      }
    }
    return counter;
  }





}





contract ZombieOwnership is ZombieHelper, ERC721 {

  mapping (uint => address) zombieApprovals;

  function balanceOf(address _owner) public view returns (uint256 _balance) {
    return ownerZombieCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return zombieToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
    ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
    zombieToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    _transfer(msg.sender, _to, _tokenId);
  }


  function transferbylevel(address _to,  uint _level) public   {
   
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == msg.sender&&zombies[i].level == _level) {
        _transfer(msg.sender, _to, i);
        break;
        
      }
    }
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

contract ZombieMarket is ZombieOwnership {
    struct zombieSales{
        address payable seller;
        uint price;
    }
    mapping(uint=>zombieSales) public zombieShop;
    uint shopZombieCount;
    uint public tax = 1 finney;
    uint public minPrice = 1 finney;

    event SaleZombie(uint indexed zombieId,address indexed seller);
    event BuyShopZombie(uint indexed zombieId,address indexed buyer,address indexed seller);

    function saleMyZombie(uint _zombieId,uint _price)public onlyOwnerOf(_zombieId){
        require(_price>=minPrice+tax,'Your price must > minPrice+tax');
        uint _yesno=getShopZombiesyesno(_zombieId);
        require(_yesno==0,"is selling");
        zombieShop[_zombieId] = zombieSales(msg.sender,_price);
        shopZombieCount = shopZombieCount.add(1);
        emit SaleZombie(_zombieId,msg.sender);
    }
    function buyShopZombie(uint _zombieId)public payable{
        uint _yesno=getShopZombiesyesno(_zombieId);
        require(_yesno==1,"is not selling");
        require(zombieShop[_zombieId].seller!=msg.sender,"buy can not myself");
        require(msg.value >= zombieShop[_zombieId].price,'No enough money');
        _transfer(zombieShop[_zombieId].seller,msg.sender, _zombieId);
        zombieShop[_zombieId].seller.transfer(msg.value - tax);
        delete zombieShop[_zombieId];
        shopZombieCount = shopZombieCount.sub(1);
        emit BuyShopZombie(_zombieId,msg.sender,zombieShop[_zombieId].seller);
    }
    function getShopZombies() external view returns(uint[] memory) {
        uint[] memory result = new uint[](shopZombieCount);
        uint counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
            if (zombieShop[i].price != 0) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
    function getShopZombiesyesno(uint _zombieId) public view returns(uint yesno) {
        
        uint counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
            if (zombieShop[i].price != 0 && i==_zombieId) {
                counter=1;
                break;
            }
        }
        return counter;
    }

    function setTax(uint _value)public onlyOwner{
        tax = _value;
    }
    function setMinPrice(uint _value)public onlyOwner{
        minPrice = _value;
    }
}

contract ZombieCore is ZombieMarket{

    string public constant name = "MyCryptoZombie";
    string public constant symbol = "MCZ";

    function() external payable {
    }

    function withdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    function checkBalance() external view onlyOwner returns(uint) {
        return address(this).balance;
    }

}