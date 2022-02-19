// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "../libraries/NFTLib.sol";

interface IDroidBot is IERC721{
    function create(address, uint256, uint256) external returns(uint256);
    function upgrade(uint256, uint256, uint256) external;
    function burn(uint256) external;
    function info(uint256) external view returns(NFTLib.Info memory);
    function power(uint256) external view returns(uint256);
    function level(uint256) external view returns(uint256);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;
import "../interfaces/IDroidBot.sol";

library NFTLib {
    struct Info {
        uint256 level;
        uint256 power;
    }

    function max(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a < b) {
            return b;
        }
        return a;
    }

    function min(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a < b) {
            return a;
        }
        return b;
    }

    function optimizeEachLevel(NFTLib.Info[] memory info, uint256 level, uint256 m,  uint256 n) internal pure returns (uint256){
        // calculate m maximum values after remove n values
        uint256 l = 1;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].level == level) {
                l++;
            }
        }
        uint256[] memory tmp = new uint256[](l);
        require(l > n + m, 'Lib: not enough droidBot');
        uint256 j = 0;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].level == level) {
                tmp[j++] = info[i].power;
            }
        }
        for (uint256 i = 0; i < l; i++) {
            for (j = i + 1; j < l; j++) {
                if (tmp[i] < tmp[j]) {
                    uint256 a = tmp[i];
                    tmp[i] = tmp[j];
                    tmp[j] = a;
                }
            }
        }

        uint256 res = 0;
        for (uint256 i = n; i < n + m; i++) {
            res += tmp[i];
        }
        return res;
    }

    function getPower(uint256[] memory tokenIds, IDroidBot droidBot) external view returns (uint256) {
        NFTLib.Info[] memory info = new NFTLib.Info[](tokenIds.length);
        uint256[9] memory count;
        uint256[9] memory old_count;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            info[i] = droidBot.info(tokenIds[i]);
            count[info[i].level]++;
        }
        uint256 res = 0;
        uint256 c9 = count[0];
        for (uint256 i = 1; i < 9; i++) {
            c9 = min(c9, count[i]);
        }
        if (c9 > 0) {
            uint256 tmp = 0;
            for (uint256 i = 0; i < 9; i++) {
                tmp += optimizeEachLevel(info, i, c9, 0);
            }
            if (c9 >= 3) {
                res += tmp * 5; // 5x
            } else {
                res += tmp * 2; // 2x
            }
        }

        for (uint256 i = 0; i < 9; i++) {
            count[i] -= c9;
            old_count[i] = count[i];
        }

        for (uint256 i = 8; i >= 5; i--) {
            uint256 fi = count[i];
            for (uint256 j = i; j >= i - 5; j--) {
                fi = min(fi, count[j]);
                if (j == 0) {
                    break;
                }
            }
            if (fi > 0) {
                uint tmp = 0;
                for (uint256 j = i; j >= i - 5; j--) {
                    tmp += optimizeEachLevel(info, j, fi, old_count[j] - count[j]);
                    count[j] -= fi;
                    if (j == 0) {
                        break;
                    }
                }
                res += tmp * 14 * fi / 10; // 1.4x
            }
        }

        for (uint256 i = 8; i >= 2; i--) {
            uint256 fi = count[i];
            for (uint256 j = i; j >= i - 2; j--) {
                fi = min(fi, count[j]);
                if (j == 0) {
                    break;
                }
            }
            if (fi > 0) {
                uint tmp = 0;
                for (uint256 j = i; j >= i - 2; j--) {
                    tmp += optimizeEachLevel(info, j, fi, old_count[j] - count[j]);
                    count[j] -= fi;
                    if (j == 0) {
                        break;
                    }
                }
                res += tmp * 115 * fi / 100; //1.15 x
            }
        }

        for (uint256 i = 0; i < 9; i++) {
            if (count[i] > 0) {
                res += optimizeEachLevel(info, i, count[i], old_count[i] - count[i]); // normal
            }
        }
        return res;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../interfaces/IDroidBot.sol";

contract NFTRanking is Ownable {

    struct UserInfo {
        address addr;
        uint256 power;
    }

    IDroidBot public droidBot;
    
    uint256 public nUser;
    mapping (address => uint256) private powerUser;
    mapping (uint256 => address) private indexUser;
    mapping (uint256 => uint256) public helper;
    UserInfo[] public userInfos;
    UserInfo[] public ranking;
    
    uint256 public endRanking;

    // constructor (address _droidBot, uint256 _endRanking) {
    //     droidBot = IDroidBot(_droidBot);
    //     endRanking = _endRanking;
    // }

    constructor (UserInfo[] memory _infos) {
        addUsers(_infos);
        // add(_infos);
    }

    modifier whenEnded() {
        require(block.timestamp > endRanking, 'NFTRanking: ranking end');
        _;
    }

    modifier whenNotEnded() {
        require(block.timestamp < endRanking, 'NFTRanking: ranking not end');
        _;
    }

    // function getInfoLength() public view returns(uint256) {
    //     return userInfos.length;
    // }

    // function userInfo(uint256 _index) public view returns(UserInfo memory) {
    //     return _index < userInfos.length ? userInfos[_index] : UserInfo(address(0), 0);
    // }

    function userInfo(uint256 _index) public view returns(UserInfo memory info) {
        return UserInfo(indexUser[_index + 1], powerUser[indexUser[_index + 1]]);
        // return _index < userInfos.length ? userInfos[_index] : UserInfo(address(0), 0);
    }

    // function getTop(uint256 _n) view public returns (UserInfo[] memory) {
    //     uint256 n = Math.min(userInfos.length, _n);
    //     UserInfo[] memory _ranking = new UserInfo[](n);
    //     for (uint i = 0; i < n; i++) {
    //         _ranking[helper[i]-1] = userInfos[i];
    //     }
    //     return ranking;
    // }

    // function getTop() view public returns (UserInfo[] memory) {
    //     uint256 n = userInfos.length;
    //     UserInfo[] memory _ranking = new UserInfo[](n+1);
    //     for (uint i = 0; i < n; i++) {
    //         _ranking[helper[i]-1] = userInfos[i];
    //     }
    //     return ranking;
    // }

    function burnDroidBot(uint256 _droidBotId) external {
        require(droidBot.ownerOf(_droidBotId) == msg.sender, 'NFTRanking: not owner of bot');
        droidBot.burn(_droidBotId);

        if (powerUser[msg.sender] == 0) {
            // userInfos.push(UserInfo(msg.sender, droidBot.power(_droidBotId)));
            // indexUser[msg.sender] = userInfos.length;
            indexUser[++nUser] = msg.sender;
            powerUser[msg.sender] = droidBot.power(_droidBotId);
        } else {
            // userInfos[userIndex[msg.sender] - 1].power += droidBot.power(_droidBotId);
            powerUser[msg.sender] += droidBot.power(_droidBotId);
        }
    }

    function add(UserInfo[] memory _value) public {
        for(uint256 i = 0; i < _value.length; i++) {  
            userInfos.push(_value[i]);
        }
    }

    function sort() public {
        for (uint i = 0; i < nUser; i++) {
            helper[i] = 0;
            for (uint j = 0; j < i; j++){
                if (powerUser[indexUser[i+1]] > powerUser[indexUser[j+1]]) {
                    if (helper[i] == 0){
                        helper[i] = helper[j];
                    }
                    helper[j] = helper[j] + 1;
                }
            }
            if (helper[i] == 0) {
                helper[i] = i + 1;
            }
        }
        // uint256 lengthSortedArray = ranking.length;
        // for (uint i = 0; i < userInfos.length; i++) {
        //     if (i < lengthSortedArray) continue;
        //     ranking.push(UserInfo(msg.sender, 0));
        // }
        // for (uint i = 0; i < userInfos.length; i++) {
        //     ranking[helper[i]-1] = userInfos[i];
        // }
    }

    /*----------------------------RESTRICT FUNCTIONS----------------------------*/

    function setEndRanking(uint256 _endRanking) external onlyOwner {
        require(_endRanking >= block.timestamp, 'NFTRanking: newEndRanking too small');

        uint256 oldendRanking = endRanking;
        endRanking = _endRanking;
        emit EndRankingChanged(oldendRanking, _endRanking);
    }    
    
    /*----------------------------TEST FUNCTIONS----------------------------*/

    function addUser(UserInfo memory _info) public onlyOwner {
        if (powerUser[_info.addr] == 0) {
            // userInfos.push(_info);
            // indexUser[_info.addr] = userInfos.length;
            indexUser[++nUser] = _info.addr;
            powerUser[_info.addr] = _info.power;
        } else {
            // userInfos[indexUser[_info.addr] - 1].power += _info.power;
            powerUser[_info.addr] += _info.power;
        }
    }

    function addUsers(UserInfo[] memory _infos) public onlyOwner {
        for (uint256 i = 0; i < _infos.length; i++) {
            addUser(_infos[i]);
        }
    }

    /*----------------------------EVENTS----------------------------*/

    event EndRankingChanged(uint256 oldendRanking, uint256 newEndRanking);

}