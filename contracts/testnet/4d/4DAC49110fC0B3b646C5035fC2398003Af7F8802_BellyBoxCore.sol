// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./dependency/SubBase.sol";
import "./dependency/AccessControl.sol";
import "./interface/IChiCoin.sol";
import "./interface/IIngredientERC1155.sol";
import "./interface/IEquipmentERC1155.sol";

contract BellyBoxCore is SubBase, AccessControl {

    struct BellyBox {
        uint256 price;
        uint64 supply;
        uint64 opened;
        string describe;
    }

    uint256 bellyBoxChiAmount = 1000000000000000000; //1 CHI

    mapping(uint8 => BellyBox) internal bellyBoxes;

    IIngredientERC1155 public ingredientERC1155;
    IEquipmentERC1155 public equipmentERC1155;
    IChiCoin public chiCoin;

    constructor(address _ingredientERC1155Address, address _equipmentERC1155Address, address chiCoinAddress) {
        ingredientERC1155 = IIngredientERC1155(_ingredientERC1155Address);
        equipmentERC1155 = IEquipmentERC1155(_equipmentERC1155Address);
        chiCoin = IChiCoin(chiCoinAddress);

        BellyBox memory bellyBox1 = BellyBox({
            price: 1000000000000000000,
            supply: 1000,
            opened: 0,
            describe: "A Big Belly Box contains 1 random Ingredients item."
        });
        BellyBox memory bellyBox2 = BellyBox({
            price: 1000000000000000000,
            supply: 1000,
            opened: 0,
            describe: "A Big Belly Box contains 1 random Accessory item."
        });
        BellyBox memory bellyBox3 = BellyBox({
            price: 1000000000000000000,
            supply: 1000,
            opened: 0,
            describe: "A Big Belly Box contains 1 random AIO item."
        });

        bellyBoxes[1] = bellyBox1;
        bellyBoxes[2] = bellyBox2;
        bellyBoxes[3] = bellyBox3;
    }

    function createBellyBox(
        uint256 boxId,
        uint256 chiAmount,
        uint8 bellyBoxType,
        string memory _name,
        string memory _describe
    ) public payable {
        require(bellyBoxes[bellyBoxType].price == chiAmount, "CHI value sent is not correct");
        require(bellyBoxes[bellyBoxType].opened <= bellyBoxes[bellyBoxType].supply, "The belly box exceeds the upper limit");

        address recipient = _msgSender();

        chiCoin.transferFrom(recipient, address(this), chiAmount);
        uint8 childType = createRandom(1, 4);
       
        if (bellyBoxType == 1) {
            ingredientERC1155.createIngredient(recipient, boxId, childType, _name, _describe);
        } else if (bellyBoxType == 2) {
            equipmentERC1155.createEquipment(recipient, boxId, childType, _name, _describe); 
        } else if (bellyBoxType == 3) {
            chiCoin.transferFrom(address(this), recipient, bellyBoxChiAmount);
        }

        bellyBoxes[bellyBoxType].supply ++;
    }

    function setBellyBoxChiAmount(uint256 amount) onlyCOO external {
        bellyBoxChiAmount = amount;
    }

    function setBellyBox(uint8 bellyBoxType, uint256 price, uint64 supply, string memory describe) onlyCOO external {
        bellyBoxes[bellyBoxType].price = price;
        bellyBoxes[bellyBoxType].supply = supply;
        bellyBoxes[bellyBoxType].describe = describe;
    }

    function getBellyBox(uint8 bellyBoxType) external view returns (
        uint256 price,
        uint64 supply,
        string memory describe
    ) {
        price = bellyBoxes[bellyBoxType].price;
        supply = bellyBoxes[bellyBoxType].supply;
        describe = bellyBoxes[bellyBoxType].describe;
    }
    
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IIngredientERC1155 {
    function createIngredient(address recipient, uint256 boxId, uint8 childType, string memory _name, string memory _describe) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEquipmentERC1155 {
    function createEquipment(address recipient, uint256 boxId, uint8 childType, string memory _name, string memory _describe) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChiCoin {
   function transferFrom(address sender, address recipient, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../lib/Ownable.sol";
contract SubBase is Context {

    address private bellyBoxAddress;
    // Initializing the state variable
    uint64 randNonce = 0;
    
    /**
     * @dev Create a random number.
     */
    function createRandom(uint256 start, uint256 end) public returns (uint8)
    {
        // increase nonce
        randNonce++; 
        
        return uint8(
                (uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, randNonce))) % (end - start)) + start
        );
    }
    /**
     * @dev Throws if called by any Address other than the belly box.
     */
    modifier onlyBellyBox() {
        require(_msgSender() == bellyBoxAddress, "Only callable by belly box");
        _;
    }

    function getBellyBox() external view returns (address) {
        return bellyBoxAddress;
    }

    function setBellyBox(address bellyBox) external {
        bellyBoxAddress = bellyBox;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControl {

  address public ceoAddress;
  address public cfoAddress;
  address public cooAddress;

  constructor() {
       ceoAddress = msg.sender;
  }

  modifier onlyCEO() {
    require(msg.sender == ceoAddress);
    _;
  }

  modifier onlyCFO() {
    require(msg.sender == cfoAddress);
    _;
  }

  modifier onlyCOO() {
    require(msg.sender == cooAddress);
    _;
  }

  modifier onlyCLevel() {
    require(
        msg.sender == ceoAddress ||
        msg.sender == cfoAddress ||
        msg.sender == cooAddress
    );
    _;
  }

  function setCEO(address _newCEO) external onlyCEO {
    require(_newCEO != address(0));
    ceoAddress = _newCEO;
  }

  function setCFO(address _newCFO) external onlyCEO {
    cfoAddress = _newCFO;
  }

  function setCOO(address _newCOO) external onlyCEO {
    cooAddress = _newCOO;
  }
}