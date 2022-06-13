/**
 *Submitted for verification at BscScan.com on 2022-06-13
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

// File: CreatePartcode.sol


pragma solidity ^0.8.7;






interface RANDOM_CONTRACT {
    function startRandom() external returns (uint256);
}



contract RandomPartcode is Ownable {
    using Strings for string;
    uint8 private constant NFT_TYPE = 0; //Kingdom

    uint8 private constant SUITE = 5; //Battle Suit
    uint8 private constant WEAP = 8; //WEAP
    uint8 private constant SPACE_WARRIOR = 6;


    uint8 private constant COMMON = 0;
    uint8 private constant RARE = 1;
    uint8 private constant EPIC = 2;
    uint8 private constant LEGENDARY = 3;
    uint8 private constant LIMITED=4;

    // mapping(uint8=>mapping(uint8=>uint8)) public Weapon;
    uint8 [][4] public Weapon;
    uint8 [][4] public Battle_Bot;
    uint8 [][4] public Battle_Suite;
    uint8 [][4] public Battle_Drone;
    uint8 [][4] public Battle_Gear;
    uint8 [5] public Training_Camp;


    address public randomWorkerContract;    

    constructor() {
        Weapon[COMMON]=[0,1,2,3];
        Weapon[RARE]=[4,5,6,7,8];
        Weapon[EPIC]=[9,10,11,12,13,14];
        Weapon[LEGENDARY]=[15,16,17,18,19];

        Battle_Bot[COMMON]=[0,1,2,3,4];
        Battle_Bot[RARE]=[0,5,6,7];
        Battle_Bot[EPIC]=[0,8,9,10];
        Battle_Bot[LEGENDARY]=[0,11,12];

        Battle_Suite[COMMON]=[0,1,2];
        Battle_Suite[RARE]=[3,4,5];
        Battle_Suite[EPIC]=[6,7,8,9];
        Battle_Suite[LEGENDARY]=[10,11];

        Battle_Drone[COMMON]=[0,1,2,3,4];
        Battle_Drone[RARE]=[0,5,6,7];
        Battle_Drone[EPIC]=[0,8,9,10];
        Battle_Drone[LEGENDARY]=[0,11,12];

        Battle_Gear[COMMON]=[0,1,2,3,4];
        Battle_Gear[RARE]=[0,5,6,7];
        Battle_Gear[EPIC]=[0,8,9,10];
        Battle_Gear[LEGENDARY]=[0,11,12];

        Training_Camp=[0,1,2,3,4];
        
    }

    function changeRandomWorkerContract(address _address) public onlyOwner {
        randomWorkerContract = _address;
    }   
    function getNumberAndMod(
        uint256 _ranNum,
        uint16 digit,
        uint256 mod
    ) public view virtual returns (uint16) {
        if (digit == 1) {
            return uint16((_ranNum % 10000) % mod);
        } else if (digit == 2) {
            return uint16(((_ranNum % 100000000) / 10000) % mod);
        } else if (digit == 3) {
            return uint16(((_ranNum % 1000000000000) / 100000000) % mod);
        } else if (digit == 4) {
            return uint16(((_ranNum % 10000000000000000) / 1000000000000) % mod);
        } else if (digit == 5) {
            return uint16(((_ranNum % 100000000000000000000) / 10000000000000000) % mod);
        } else if (digit == 6) {
            return uint16(((_ranNum % 1000000000000000000000000) / 100000000000000000000) % mod);
        } else if (digit == 7) {
            return uint16(((_ranNum % 10000000000000000000000000000) / 1000000000000000000000000) % mod);
        } else if (digit == 8) {
            return uint16(((_ranNum % 100000000000000000000000000000000) / 10000000000000000000000000000) % mod);
        }

        return 0;
    }


    function createSW(uint256 _randomNumber, uint8 rarity)
        private
        view
        returns (string memory)
        {     
        uint256 weapon_length=Weapon[rarity].length;
        uint256 weapon_Index=getNumberAndMod(_randomNumber,3,weapon_length);
        uint8 weapon_Id=Weapon[rarity][weapon_Index];

        uint256 bot_length=Battle_Bot[rarity].length;
        uint256 bot_Index=getNumberAndMod(_randomNumber,4,bot_length);
        uint8 bot_Id=Battle_Bot[rarity][bot_Index];

        uint256 suite_length=Battle_Suite[rarity].length;
        uint256 suite_Index=getNumberAndMod(_randomNumber,5,suite_length);
        uint8 suite_Id=Weapon[rarity][suite_Index];

        uint256 drone_length=Battle_Drone[rarity].length;
        uint256 drone_Index=getNumberAndMod(_randomNumber,6,drone_length);
        uint8 drone_Id=Weapon[rarity][drone_Index];

        uint256 gear_length=Battle_Gear[rarity].length;
        uint256 gear_Index=getNumberAndMod(_randomNumber,7,gear_length);
        uint8 gear_Id=Battle_Gear[rarity][gear_Index];

        uint256 camp_Index=getNumberAndMod(_randomNumber,8,5);
        uint8 camp_Id=Training_Camp[camp_Index];

        // adjust digit to random partcode     
        string memory concatedCode = "";
        concatedCode = concateCode(concatedCode, 0); //kingdomCode
        concatedCode = concateCode(concatedCode, 0);
        concatedCode = concateCode(concatedCode, 0);
        concatedCode = concateCode(concatedCode, 0);
        concatedCode = concateCode(concatedCode,weapon_Id);
        concatedCode = concateCode(concatedCode,rarity);
        concatedCode = concateCode(concatedCode,bot_Id);
        concatedCode = concateCode(concatedCode,suite_Id);
        concatedCode = concateCode(concatedCode,drone_Id);
        concatedCode = concateCode(concatedCode,gear_Id);
        concatedCode = concateCode(concatedCode,camp_Id);  
        concatedCode = concateCode(concatedCode, 0); //Reserved
        concatedCode = concateCode(concatedCode, 0); //Reserved
        return concatedCode;
    }


    function concateCode(string memory concatedCode, uint8 digit)
        internal
        pure
        returns (string memory)
    {
        concatedCode = string(
            abi.encodePacked(convertCodeToStr(digit), concatedCode)
        );

        return concatedCode;
    }

    function convertCodeToStr(uint256 code)
        private
        pure
        returns (string memory)
    {
        if (code <= 9) {
            return string(abi.encodePacked("0", Strings.toString(code)));
        }

        return Strings.toString(code);
    }
 }