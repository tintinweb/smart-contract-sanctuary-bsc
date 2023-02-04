// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IColl_NFTWA_NFTA.sol";

contract Coll_NFTWA_NFTA is Ownable,IColl_NFTWA_NFTA {

   string public URL_W= "https://bafybeiesrrbsqocdm64fs6iakbks47rjm6mbzvmipooaxsffwvern6frvq.ipfs.w3s.link/NFTWAmetadata/";

   uint256[123] NFTA_id_array = [984,983, 1027, 1026, 1023, 1068, 1069, 1025, 1070, 1071, 1072, 1073, 1074, 1075, 
    1076, 1077, 1033, 1032, 1034, 1078, 1079, 1035, 1036, 1080, 1037, 1081, 1082, 1038, 1039, 1083, 1084, 1040, 
    1041, 1085, 1042, 1086, 1043, 1087, 1088, 1044, 1045, 1089, 1090, 1046, 1002, 1003, 1047, 1048, 1004, 1049, 
    1091, 1092, 1093, 1094, 1050, 1006, 1051, 1052, 1053, 1095, 1096, 1097, 1098, 1054, 1055, 1099, 1100, 1057, 
    1058, 1059, 1060, 1061, 1062, 1063, 1064, 1065, 1066, 1022, 1067, 1116, 1117, 1118, 1115, 1114, 1113, 1112, 
    1111, 1110, 1109, 1108, 1107, 1106, 1105, 1104, 1102, 1103, 1101, 1144, 1143, 1142, 1141, 1140, 1139, 1138, 
    1137, 1136, 1134, 1135, 1133, 1132, 1131, 1130, 1129, 1128, 1119, 1120, 1121, 1122, 1123, 1124, 1125,1126, 
    1127];

   uint256[27] NFTWA_id_array = [654, 655, 656, 697, 698, 699, 700, 701, 740, 741, 742, 743, 744, 745, 784, 785, 
    786, 787, 788, 789, 829, 830, 831, 832, 833, 876, 877];

   function Get_NFTA_num (uint256 num_NFTA_) public virtual override view returns(uint256) {
       return NFTA_id_array[num_NFTA_];
    }
   function Get_NFTWA_num (uint256 num_NFTWA_) public virtual override view returns(uint256) {
       return NFTWA_id_array[num_NFTWA_];
    }
   function Get_URL () public virtual override view  returns  (string memory) {
      return URL_W;
    }
   function setBaseURI(string calldata baseURI) external onlyOwner {
    URL_W = baseURI;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IColl_NFTWA_NFTA {
    function Get_NFTA_num (uint256 num_NFTA_) external view returns(uint256);
    function Get_NFTWA_num (uint256 num_NFTA_) external view returns(uint256);
    function Get_URL () external view  returns (string memory);
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