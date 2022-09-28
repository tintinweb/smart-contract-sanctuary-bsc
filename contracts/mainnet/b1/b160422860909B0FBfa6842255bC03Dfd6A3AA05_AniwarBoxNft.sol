//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
 
import "@openzeppelin/contracts/access/Ownable.sol";


interface IAniwarNft {
    function createManyAniwarItem(uint8 _count, address _owner, string memory _aniwarType) external;
    
    function aniwarItems(uint256 _id) external view returns(uint256, string memory);
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}
interface IERC20 { 
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract AniwarBoxNft is Ownable {
    address public constant NULL_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    IAniwarNft public immutable ANIWAR_NFT_CONTRACT;
    IERC20 public immutable ANI_TOKEN;
    mapping (string => bool) public aniwarTypesAllowed;
    mapping (string => string) public aniwarBoxToType;
    mapping (string => string) public aniwarTypeToBox;

    constructor(address _aniwar_nft_contract, address _aniwar_token) {
        ANIWAR_NFT_CONTRACT = IAniwarNft(_aniwar_nft_contract);
        ANI_TOKEN = IERC20(_aniwar_token);
        aniwarBoxToType["BoxAni"] = "Ani";
        aniwarBoxToType["BoxItem"] = "Item";
        aniwarTypeToBox["Ani"] = "BoxAni";
        aniwarTypeToBox["Item"] = "BoxItem";
        aniwarTypesAllowed["Ani"] = true;
        aniwarTypesAllowed["Item"] = true;
    } 

    // Owner Only
    function mintManyBoxes(address owner, uint8 _count, string memory _boxType) public onlyOwner {
        require(aniwarTypesAllowed[aniwarBoxToType[_boxType]], "Type Not Allowed! Add before continue!");
        require(owner != address(0), "Address Zero!");
        ANIWAR_NFT_CONTRACT.createManyAniwarItem( _count, owner, _boxType); 
    }

    function OpenBox(uint256 _id) public {
        (uint256 aniwarNftId, string memory _boxType) = ANIWAR_NFT_CONTRACT.aniwarItems(_id);
        require(aniwarTypesAllowed[aniwarBoxToType[_boxType]], "Type not allowed!");
        ANIWAR_NFT_CONTRACT.transferFrom(
            msg.sender,
            NULL_ADDRESS,
            aniwarNftId
        );
        ANIWAR_NFT_CONTRACT.createManyAniwarItem(1, msg.sender, aniwarBoxToType[_boxType]); 
    }

    function withdrawToken(address _token, address _to, uint256 _amount) public onlyOwner {
        IERC20(_token).transferFrom(address(this), _to, _amount);
    }

    function setTypesAllowed(string[] memory types, bool state) public onlyOwner {
        for (uint8 i = 0; i < types.length; i++) {
            aniwarTypesAllowed[types[i]] = state;
        }
    }
    function setBoxesAndTypes(string[] memory boxes, string[] memory types) public onlyOwner {
        for (uint8 i = 0; i < types.length; i++) {
            aniwarTypesAllowed[types[i]] = true;
            aniwarBoxToType[boxes[i]] = types[i];
            aniwarTypeToBox[types[i]] = boxes[i];
        }
    }
    function aniwarType() public pure returns(string memory) {
        return "BoxNft";
    }
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