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

// File: contracts/lootBox/LootboxUncommon.sol


pragma solidity ^0.6.0;


interface IMintToken {
  function mint(address to, uint[] memory params) external;
}

contract LootboxUncommon is Ownable {

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
    uint[] memory badges = new uint[](8);
    badges[0] = 4;
    badges[1] = 4;
    badges[2] = 4;
    badges[3] = 3;
    badges[4] = 3;
    badges[5] = 1;
    badges[6] = 1;
    badges[7] = 5;
    addPrimaryItems(0, badges);

    addPrimaryItemGroup("emotion");
    uint[] memory emotions = new uint[](1);
    emotions[0] = 4; 
    addPrimaryItems(1,emotions);

    addPrimaryItemGroup("eye");
    uint[] memory eyes = new uint[](4);
    eyes[0] = 4;
    eyes[1] = 4;
    eyes[2] = 2;
    eyes[3] = 6;

    addPrimaryItems(2,eyes);

    addPrimaryItemGroup("body");
    uint[] memory bodies = new uint[](2);
    bodies[0] = 14;
    bodies[1] = 13;

    addPrimaryItems(3,bodies);

    addPrimaryItemGroup("jacket");
    uint[] memory jackets = new uint[](11);
    jackets[0] = 3;
    jackets[1] = 3;
    jackets[2] = 3;
    jackets[3] = 3;
    jackets[4] = 3;
    jackets[5] = 4;
    jackets[6] = 4;
    jackets[7] = 4;
    jackets[8] = 4;
    jackets[9] = 6;
    jackets[10] = 5;

    addPrimaryItems(4,jackets);

    addPrimaryItemGroup("gradient");
    uint[] memory gradients = new uint[](6);
    gradients[0] = 4;
    gradients[1] = 4;
    gradients[2] = 4;
    gradients[3] = 4;
    gradients[4] = 5;
    gradients[5] = 5;

    addPrimaryItems(5,gradients);


    addSecondaryItemGroup("ear");
    uint[] memory ears = new uint[](11);
    ears[0] = 3;
    ears[1] = 3;
    ears[2] = 3;
    ears[3] = 3;
    ears[4] = 3;
    ears[5] = 3;
    ears[6] = 4;
    ears[7] = 4;
    ears[8] = 4;
    ears[9] = 4;
    ears[10] = 6;

    addSecondaryItems(0,ears);

    addSecondaryItemGroup("hat");
    uint[] memory hats = new uint[](12);
    hats[0] = 3;
    hats[1] = 3;
    hats[2] = 3;
    hats[3] = 3;
    hats[4] = 3;
    hats[5] = 4;
    hats[6] = 4;
    hats[7] = 4;
    hats[8] = 4;
    hats[9] = 4;
    hats[10] = 4;
    hats[11] = 4;

    addSecondaryItems(1,hats);

    addSecondaryItemGroup("accessory");
    uint[] memory accessories = new uint[](8);
    accessories[0] = 3;
    accessories[1] = 4;
    accessories[2] = 4;
    accessories[3] = 4;
    accessories[4] = 4;
    accessories[5] = 5;
    accessories[6] = 6;
    accessories[7] = 6;

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