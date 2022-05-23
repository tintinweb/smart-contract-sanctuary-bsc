/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/MysteryBox.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;



interface IMonster{
    function safeMint(address to, uint monsterId) external returns(uint256);
}
interface ILand{
    function safeMint(address to, uint256 zone, uint256 landId) external returns(uint256);
}
interface IBusd{
    function balanceOf(address _addr) external view returns(uint256);
    function Transfer(address from, address to, uint256 value) external;
}
contract MysteryBox is Ownable  {
    // monster
    struct MonsterBox {
        uint256 price;
        uint256[] monsterId;
        bool isOpen;
        bool isCreate;
    }
    mapping(string => MonsterBox) private mysteryMonster; // type => data

    // land
    struct LandBox {
        uint256 price;
        uint256[] landId;
        bool isOpen;
        bool isCreate;
    }
    mapping(uint => LandBox) private mysteryLand; // zone => data

    // global
    address public addressRecipient;
    address public addressToken;
    address public addressMonster;
    address public addressLand;


    constructor(address recipient, address tokenBUSD, address monster, address land) {
        addressRecipient = recipient;
        addressToken = tokenBUSD;
        addressMonster = monster;
        addressLand = land;
    }

    // monster function for owner 
    function createMonsterBox(
        string memory box,
        uint256 price,
        uint256[] memory monsterId,
        bool isOpen
    ) public onlyOwner {
        require(!mysteryMonster[box].isCreate,"MysteryBox not recreate!!");
        mysteryMonster[box] = MonsterBox({
            price: price,
            monsterId: monsterId,
            isOpen: isOpen,
            isCreate: true
        });
    }
    function updateMonsterIdInBox(string memory box, uint[] memory monsterId) public onlyOwner{
        require(mysteryMonster[box].isCreate,"MysteryBox not create!!");
        require(!mysteryMonster[box].isOpen,"MysteryBox is open!!");
        mysteryMonster[box].monsterId = monsterId;
    }
    function undateIsOpenMonsterBox(string memory box, bool isOpen) public onlyOwner {
        require(mysteryMonster[box].isCreate,"box is wrong!!");
        mysteryMonster[box].isOpen = isOpen;
    }
    function getMysteryMonster(string memory box) public onlyOwner view returns(MonsterBox memory){
        return mysteryMonster[box];
    }

    // monster function for user
    function gachaMonster(string memory box)
        public
        returns (uint256[2] memory)
    {
        // check myterybox
        require(mysteryMonster[box].isOpen, "MysteryBox not open!!");
        require(mysteryMonster[box].monsterId.length > 0, "MysteryBox is empty");
        require(mysteryMonster[box].price > 0, "MysteryBox price wrong");

        // check token and transfer
        require(IBusd(addressToken).balanceOf(msg.sender)>=mysteryMonster[box].price,string(abi.encodePacked("TOKEN <= ",Strings.toString(mysteryMonster[box].price))));
        IBusd(addressToken).Transfer(msg.sender,addressRecipient,mysteryMonster[box].price);

        // random monster
        uint256 indexMonsterId = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % mysteryMonster[box].monsterId.length;
        uint256 resultMonsterId = mysteryMonster[box].monsterId[indexMonsterId];
        // mint NFT
        uint256 tokenId = IMonster(addressMonster).safeMint(msg.sender,resultMonsterId);

        return [resultMonsterId,tokenId];
    }


    // land function for owner 
    function createLandBox(
        uint256 zone,
        uint256 price,
        uint256[] memory landId,
        bool isOpen
    ) public onlyOwner {   
        require(!mysteryLand[zone].isCreate,"MysteryBox not recreate!!");
        mysteryLand[zone] = LandBox({
            price: price,
            landId: landId,
            isOpen: isOpen,
            isCreate: true
        });
    }
    function updateLandIdInBox(uint256 zone, uint[] memory landId) public onlyOwner{
        require(mysteryLand[zone].isCreate,"MysteryBox not create!!");
        require(!mysteryLand[zone].isOpen,"MysteryBox is open!!");
        mysteryLand[zone].landId = landId;
    }
    function undateIsOpenLandBox(uint256 zone, bool isOpen) public onlyOwner {
        require(mysteryLand[zone].isCreate,"zone is wrong!!");
        mysteryLand[zone].isOpen = isOpen;
    }
    function getMysteryLand(uint256 land) public onlyOwner view returns(LandBox memory){
        return mysteryLand[land];
    }

    // land function for user
    function gachaLand(uint256 zone)
        public
        returns (uint256[2] memory)
    {
        // check myterybox
        require(mysteryLand[zone].isOpen, "MysteryBox not open!!");
        require(mysteryLand[zone].landId.length > 0, "MysteryBox is empty");
        require(mysteryLand[zone].price > 0, "MysteryBox price wrong");

        // check token and transfer
        require(IBusd(addressToken).balanceOf(msg.sender)>=mysteryLand[zone].price,string(abi.encodePacked("TOKEN <= ",Strings.toString(mysteryLand[zone].price))));
        IBusd(addressToken).Transfer(msg.sender,addressRecipient,mysteryLand[zone].price);

        // random land
        uint256 indexLandId = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % mysteryLand[zone].landId.length;
        uint256 resultLandId = mysteryLand[zone].landId[indexLandId];

        // indexLandId != last index
        if(indexLandId != mysteryLand[zone].landId.length - 1 ){
            mysteryLand[zone].landId[indexLandId] = mysteryLand[zone].landId[mysteryLand[zone].landId.length - 1];
        }
        // remove landId in box
        mysteryLand[zone].landId.pop();

        // mint NFT
        uint256 tokenId = ILand(addressLand).safeMint(msg.sender,zone,resultLandId);
        
        return [resultLandId,tokenId];
    }
}