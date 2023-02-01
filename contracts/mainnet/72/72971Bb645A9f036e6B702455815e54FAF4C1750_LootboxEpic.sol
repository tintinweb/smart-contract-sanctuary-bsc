/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

// File: @openzeppelin/contracts/utils/Context.sol



pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/lootBox/LootboxEpic.sol


pragma solidity ^0.6.0;


interface IMintToken {
  function mint(address to, uint[] memory params) external;
}

contract LootboxEpic is Ownable {

  IMintToken public nft;

  struct ItemGroup {
    string name;
    uint[] powers;
  }

  ItemGroup[] public primaryItemGroups;
  ItemGroup[] public secondaryItemGroups;

  uint public secondaryParamsCount;
  uint public seed;

  address public router;

  mapping(bytes32 => bool) public createdItems;

  event NewToken(uint[] params);

  constructor(IMintToken _nftAddress, address _router, uint _secondaryParamsCount) public {
    nft = _nftAddress;
    router = _router;
    secondaryParamsCount = _secondaryParamsCount;

    addPrimaryItemGroup("badge");
    uint[] memory badges = new uint[](7);
    badges[0] = 9;
    badges[1] = 9;
    badges[2] = 7;
    badges[3] = 6;
    badges[4] = 5;
    badges[5] = 10;
    badges[6] = 10;
    addPrimaryItems(0, badges);

    addPrimaryItemGroup("emotion");
    uint[] memory emotions = new uint[](1);
    emotions[0] = 8; 
    addPrimaryItems(1,emotions);

    addPrimaryItemGroup("eye");
    uint[] memory eyes = new uint[](2);
    eyes[0] = 8;
    eyes[1] = 8;

    addPrimaryItems(2,eyes);

    addPrimaryItemGroup("body");
    uint[] memory bodies = new uint[](2);
    bodies[0] = 17;
    bodies[1] = 19;

    addPrimaryItems(3,bodies);

    addPrimaryItemGroup("jacket");
    uint[] memory jackets = new uint[](8);
    jackets[0] = 9;
    jackets[1] = 9;
    jackets[2] = 9;
    jackets[3] = 7;
    jackets[4] = 7;
    jackets[5] = 7;
    jackets[6] = 8;
    jackets[7] = 8;

    addPrimaryItems(4,jackets);

    addPrimaryItemGroup("gradient");
    uint[] memory gradients = new uint[](2);
    gradients[0] = 8;
    gradients[1] = 9;

    addPrimaryItems(5,gradients);


    addSecondaryItemGroup("ear");
    uint[] memory ears = new uint[](6);
    ears[0] = 8;
    ears[1] = 8;
    ears[2] = 7;
    ears[3] = 7;
    ears[4] = 10;
    ears[5] = 10;

    addSecondaryItems(0,ears);

    addSecondaryItemGroup("hat");
    uint[] memory hats = new uint[](9);
    hats[0] = 8;
    hats[1] = 8;
    hats[2] = 8;
    hats[3] = 9;
    hats[4] = 9;
    hats[5] = 9;
    hats[6] = 9;
    hats[7] = 7;
    hats[8] = 7;

    addSecondaryItems(1,hats);

    addSecondaryItemGroup("accessory");
    uint[] memory accessories = new uint[](7);
    accessories[0] = 7;
    accessories[1] = 9;
    accessories[2] = 8;
    accessories[3] = 8;
    accessories[4] = 8;
    accessories[5] = 6;
    accessories[6] = 6;

    addSecondaryItems(2,accessories);
  }

  function addPrimaryItems(uint _itemGroupId, uint[] memory _powers) public onlyOwner {
    for(uint i = 0; i < _powers.length; i++) {
      primaryItemGroups[_itemGroupId].powers.push(_powers[i]);
    }
  }

  function addPrimaryItemGroup(string memory _name) public onlyOwner {
    uint[] memory buf;
    primaryItemGroups.push(ItemGroup(_name, buf));
  }

  function addSecondaryItems(uint _itemGroupId, uint[] memory _powers) public onlyOwner {
    for(uint i = 0; i < _powers.length; i++) {
      secondaryItemGroups[_itemGroupId].powers.push(_powers[i]);
    }
  }

  function addSecondaryItemGroup(string memory _name) public onlyOwner {
    uint[] memory buf;
    secondaryItemGroups.push(ItemGroup(_name, buf));
  }

  function createItem(address _nftReceiver) public {
    
    require(msg.sender == router, "only router");
    uint[] memory result;
    
    while(true) {
      seed++;
      result = getRandomItem();
      if(!createdItems[keccak256(abi.encodePacked(result))]) {
        break;
      }
    }

    createdItems[keccak256(abi.encodePacked(result))] = true;

    nft.mint(_nftReceiver, result);
  }

  function getRandomItem() public view returns(uint[] memory result) {

    uint _seed = seed;
    result = new uint[](primaryItemGroups.length + secondaryItemGroups.length);

    for(uint i = 0; i < primaryItemGroups.length; i++) {
      uint itemId = randomUINT256(_seed) % primaryItemGroups[i].powers.length;
      _seed++;
      result[i] = itemId + 1;
    }


    uint[] memory secondaryParamsIndexes = new uint[](secondaryParamsCount);
    uint lastIndexBuf = 0;
    if(secondaryParamsCount > 0) {
      while(lastIndexBuf < secondaryParamsCount) {
        uint secondaryItemId = randomUINT256(_seed) % secondaryItemGroups.length + 1;
        _seed++;


        bool foundRepeat;
        for(uint i = 0; i < lastIndexBuf; i++) {
          if(secondaryParamsIndexes[i] == secondaryItemId) {
            foundRepeat = true;
            break;
          }
        }
        if(foundRepeat) {
          continue;
        }

        secondaryParamsIndexes[lastIndexBuf] = secondaryItemId;
        lastIndexBuf++;
      }
    }

    for(uint i = 0; i < secondaryItemGroups.length; i++) {
      for(uint j = 0; j < secondaryParamsIndexes.length; j++) {
        require(secondaryParamsIndexes[j] > 0, "ERRORRRR1111");
        if(secondaryParamsIndexes[j] - 1 == i) {

          require(secondaryItemGroups.length > secondaryParamsIndexes[j] - 1, "ERROR222");
          uint itemId = randomUINT256(_seed) % secondaryItemGroups[secondaryParamsIndexes[j] - 1].powers.length;
          _seed++;

          result[primaryItemGroups.length + i] = itemId + 1;
        } 
      }
    }
  }

  

  function randomUINT256(uint _seed) public view returns (uint) {
    // seed++;
    return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, _seed)));
  }
}