// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./ICollections.sol";
import "./IMiticoin.sol";
import "./IContracts_TITIMITI.sol";

contract Collections is Ownable,Pausable,ICollections {
    IContracts_TITIMITI Contr;
    IMiticoin MITI;
    bool public Primary;

    mapping (address => uint256) private Collection_ID;
    mapping (uint256 => address) private ID_Collection;
    mapping (uint256 => uint256) private Max_id_Collection;

    //NFTA-1; NFTWA-2; NFTW-3;
    mapping (uint256 => uint256) private What_Collection;

    //Total MAX world
    uint256  Total_world_NFTWA;
    uint256  Total_world_NFTW;
    uint256  Total_world_NFTA;

    //NFTW,NFTWA
    uint256 Total_Collection;

    //NFTA
    address NFTA;
    uint256 Max_Col_NFTA =123;
    uint256 private One_Col_NFTA=12700;
    uint256 Total_ColNFTA;

    uint256 Max_Collection = 1144;
    
    uint256[123] NFTA_id_array = [984,983, 1027, 1026, 1023, 1068, 1069, 1025, 1070, 1071, 1072, 1073, 1074, 1075, 
    1076, 1077, 1033, 1032, 1034, 1078, 1079, 1035, 1036, 1080, 1037, 1081, 1082, 1038, 1039, 1083, 1084, 1040, 
    1041, 1085, 1042, 1086, 1043, 1087, 1088, 1044, 1045, 1089, 1090, 1046, 1002, 1003, 1047, 1048, 1004, 1049, 
    1091, 1092, 1093, 1094, 1050, 1006, 1051, 1052, 1053, 1095, 1096, 1097, 1098, 1054, 1055, 1099, 1100, 1057, 
    1058, 1059, 1060, 1061, 1062, 1063, 1064, 1065, 1066, 1022, 1067, 1116, 1117, 1118, 1115, 1114, 1113, 1112, 
    1111, 1110, 1109, 1108, 1107, 1106, 1105, 1104, 1102, 1103, 1101, 1144, 1143, 1142, 1141, 1140, 1139, 1138, 
    1137, 1136, 1134, 1135, 1133, 1132, 1131, 1130, 1129, 1128, 1119, 1120, 1121, 1122, 1123, 1124, 1125,1126, 
    1127];

    constructor () {
        Contr=IContracts_TITIMITI(0x998A99E482DFa7c436a39296B16C8d11e0beBFea);
        address MITI_ = Contr.getMiticoin();
         MITI=IMiticoin(address(MITI_));
         NFTA = Contr.getNFTA(); 
    }

    
    function ADD_Collection_NFTA (uint256 amount) public onlyOwner {
            require(Primary==false);
            require(Total_ColNFTA+amount<=Max_Col_NFTA);
            uint256 X;
            while(X<amount){
            uint256 ID_=NFTA_id_array[Total_ColNFTA];
            Infinity(ID_, NFTA, One_Col_NFTA);
            Total_world_NFTA=Total_world_NFTA+One_Col_NFTA;
            Total_Collection++;
            What_Collection[Total_ColNFTA]=1;
            Total_ColNFTA++;
            MITI.BypassMINT(One_Col_NFTA);
            X++;
            }
    }
 
    function ADD_Collection_NFTWA(uint256 ID, address Collection_address,uint256 Max_world) public onlyOwner {
            require(Primary==false);
            require(Collection_ID[Collection_address]==0);
          Infinity(ID, Collection_address, Max_world);

          Total_world_NFTWA=Total_world_NFTWA+Max_world;
          Total_Collection++;
         What_Collection[ID] = 2;
            MITI.PrimaryMINT(Max_world);
    }

    function ADD_Collection (uint256 ID, address Collection_address,uint256 Max_world) public onlyOwner {
        require(Collection_ID[Collection_address]==0);
          Infinity(ID, Collection_address, Max_world);
          Total_world_NFTW=Total_world_NFTW+Max_world;
          Total_Collection++;
          What_Collection[ID]=3;
          if(Primary==false){
            MITI.PrimaryMINT(Max_world);
         }
         else {
            MITI.Add_collection(Max_world);
         }
    }

    function Infinity(uint256 ID, address Collection_address,uint256 Max_world) internal {
            Collection_ID[Collection_address]=ID;
            ID_Collection[ID]=Collection_address;
            Max_id_Collection[ID]=Max_world;
    }

    

    function Get_Total_world_NFTA () public virtual override view returns (uint256){
        return Total_world_NFTA;
    }
    function Get_Total_world_NFTW () public virtual override view returns (uint256){
        return Total_world_NFTW;
    }
    function Get_Total_world_NFTWA () public virtual override view returns (uint256){
        return Total_world_NFTWA;
    }
    function Get_Total_world ()public virtual override view returns (uint256){
        return Total_world_NFTA+Total_world_NFTW+Total_world_NFTWA;
    }
    

    function Get_What_Collection (uint256 ID_Collection_) public virtual override view returns (uint256){
        return What_Collection[ID_Collection_];
    }
    function Get_Total_Collection () public virtual override view returns (uint256){
       return Total_Collection;
    }
    
    function GetCollection_ID(address adr) public virtual override view returns (uint256) {
        return Collection_ID[adr];
    } 

    function GetID_Collection(uint256 ID) public virtual override view returns (address) {
        return ID_Collection[ID];
    }

    function Get_Max_id_Collection(uint256 ID) public virtual override view returns (uint256) {
        return Max_id_Collection[ID];
    }
    function OFF_Primary() public onlyOwner {
        Primary=true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IContracts_TITIMITI {
    function getZoomLoupe() external view returns (address);
    function getMining() external view returns (address);
    function getLandLord() external view returns (address);
    function getFundNFTA() external view returns (address);
    function getBurn() external view returns (address);
    function getStock() external view returns (address);
    function getTeam() external view returns (address);
    function getCashback() external view returns (address);
    function getRsearchers() external view returns (address);
    function getDev() external view returns (address);
    function getMiningPool() external view returns (address);
    function getTitifund() external view returns (address);
    function getMINT_GNFT() external view returns (address);
    function getMiticoin() external view returns (address);
    function getDetails() external view returns (address);
    function getdis() external view returns (address);
    function getBasic_info() external view returns (address);
    function getCollections() external view returns (address);
    function getNFTO() external view returns (address);
    function getNFTA() external view returns (address);
    function getSkillUP() external view returns (address);
    function getTake() external view returns (address);
    function getTrue_chest() external view returns (address);
    function getPrice() external view returns (address);
    function getInvest() external view returns (address);
    function getSaleMITI() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICollections {
    function GetCollection_ID(address adr) external view returns (uint256);
    function GetID_Collection(uint256 ID) external view returns (address);
    function Get_Max_id_Collection(uint256 ID) external view returns (uint256);

    function Get_Total_world_NFTA () external view returns (uint256);
    function Get_Total_world_NFTW () external view returns (uint256);
    function Get_Total_world_NFTWA () external view returns (uint256);
    function Get_Total_world ()external view returns (uint256);

    function Get_What_Collection (uint256 ID_Collection_) external view returns (uint256);
    function Get_Total_Collection () external view returns (uint256);
 }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IMiticoin {
    function Add_collection (uint256 MaxWorld) external;
    function BypassMINT (uint256 Max_world) external;
    function PrimaryMINT (uint256 PrimaryTotalWorld) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
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