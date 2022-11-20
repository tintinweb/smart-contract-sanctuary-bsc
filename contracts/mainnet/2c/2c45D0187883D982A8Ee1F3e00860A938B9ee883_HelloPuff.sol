// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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

pragma solidity >=0.8.4;

import './SafeOwnableInterface.sol';

/**
 * This is a contract copied from 'OwnableUpgradeable.sol'
 * It has the same fundation of Ownable, besides it accept pendingOwner for mor Safe Use
 */
abstract contract SafeOwnable is SafeOwnableInterface {
    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public override view returns (address) {
        return _owner;
    }

    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function setPendingOwner(address _addr) public onlyOwner {
        _pendingOwner = _addr;
    }

    function acceptOwner() public {
        require(msg.sender == _pendingOwner, "Ownable: caller is not the pendingOwner"); 
        _transferOwnership(_pendingOwner);
        _pendingOwner = address(0);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

/**
 * This is a contract copied from 'OwnableUpgradeable.sol'
 * It has the same fundation of Ownable, besides it accept pendingOwner for mor Safe Use
 */
abstract contract SafeOwnableInterface {

    function owner() public virtual view returns (address);

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '../interfaces/IBurnableERC721.sol';
import '../core/SafeOwnable.sol';

contract HelloPuff is SafeOwnable {

    event SignIn(address user, uint timestamp, uint loop, uint score);
    event BurnReward(uint nonce, address user, IERC721 nft, uint rewardId);

    uint public immutable BEGIN_TIME = 36000;
    uint public constant MAX_LOOP = 7;
    uint public immutable interval;

    uint public startAt;
    uint public finishAt;
    uint[] public scoreInfo;
    mapping(address => uint) public userCrycle;
    mapping(address => uint) public userLoop;
    mapping(address => uint) public userScores;
    mapping(IERC721 => mapping(uint => uint)) public nftCrycle;
    uint public totalScores;
    uint public nonce;
    mapping(IERC721 => bool) public supportNfts;

    constructor(uint _startAt, uint _finishAt, uint _interval, IERC721[] memory _supportNfts, uint[] memory _scores) {
        require(_startAt > block.timestamp && _finishAt > _startAt, "illegal startAt or finishAt");
        startAt = _startAt;
        finishAt = _finishAt;
        require(_interval != 0, "interval is zero");
        interval = _interval;
        for (uint i = 0; i < _supportNfts.length; i ++) {
            supportNfts[_supportNfts[i]] = true;
        }
        require(_scores.length == MAX_LOOP, "illegal score num");
        scoreInfo.push(0);
        for (uint i = 0; i < _scores.length; i ++) {
            scoreInfo.push(_scores [i]);
        }
    }

    function getScoreInfo() external view returns(uint[] memory) {
        return scoreInfo;
    }

    function setTimeInfo(uint _startAt, uint _finishAt) external onlyOwner {
        if (_startAt != 0) {
            require(_startAt > block.timestamp, "illegal startAt");
            startAt = _startAt;
        }
        if (_finishAt != 0) {
            require(_finishAt > startAt, "illegal startAt or finishAt");
            finishAt = _finishAt;
        }
    }

    function setScore(uint _loop, uint _newScore) external onlyOwner {
        require(_loop > 0 && _loop <= MAX_LOOP, "illegal loop");
        scoreInfo[_loop] = _newScore;
    }

    function setSupportNft(IERC721 _supportNft, bool _support) external onlyOwner {
        if (_support) {
            require(!supportNfts[_supportNft], "already support");
            supportNfts[_supportNft] = true;
        } else {
            require(supportNfts[_supportNft], "not supported this nft");
            delete supportNfts[_supportNft];
        }
    }

    modifier AlreadyBegin() {
        require(block.timestamp >= startAt, "not begin");
        _;
    }
    
    modifier NotFinish() {
        require(block.timestamp <= finishAt, "already finish");
        _;
    }

    function timeToCrycle(uint _timestamp) public view returns(uint _crycle) {
        return (_timestamp - BEGIN_TIME) / interval;
    }

    function signIn() external AlreadyBegin NotFinish {
        uint crycle = timeToCrycle(block.timestamp);
        uint lastCrycle = userCrycle[msg.sender];
        require(crycle > lastCrycle, "already signIn");
        uint loop = 1;
        if (crycle - lastCrycle == 1) {
            if (userLoop[msg.sender] >= MAX_LOOP) {
                loop = 1;
            } else {
                loop = userLoop[msg.sender] + 1;
            }
        } else {
            loop = 1; 
        }
        uint score = scoreInfo[loop];
        userCrycle[msg.sender] = crycle;
        userLoop[msg.sender] = loop;
        userScores[msg.sender] += score;
        totalScores += score;
        emit SignIn(msg.sender, block.timestamp, loop, score);
    }

    function signInInfo(address _user) external view returns(bool available, uint loop) {
        if (block.timestamp < startAt || block.timestamp > finishAt) {
            return (false, 0);
        }
        uint crycle = timeToCrycle(block.timestamp);
        if (crycle == userCrycle[_user]) {
            return (false, userLoop[_user]);
        } else if (crycle - userCrycle[_user] > 1) {
            return (true, 1);
        } else if (userLoop[_user] >= MAX_LOOP) {
            return (true, 1);
        } else {
            return (true, userLoop[_user] + 1);
        }
    }

    function strengthen(IERC721 _strengthenNft, uint _rewardId) external AlreadyBegin NotFinish {
        require(supportNfts[_strengthenNft], "nft not support");
        require(_strengthenNft.ownerOf(_rewardId) == msg.sender, "illegal owner");
        uint crycle = timeToCrycle(block.timestamp);
        uint lastCrycle = nftCrycle[_strengthenNft][_rewardId];
        require(crycle > lastCrycle, "already signIn");
        nonce ++;
        nftCrycle[_strengthenNft][_rewardId] = crycle;
        emit BurnReward(nonce, msg.sender, _strengthenNft, _rewardId);
    }

    function strengthenInfo(IERC721 _strengthenNft, uint _rewardId) external view returns(bool available) {
        uint crycle = timeToCrycle(block.timestamp);
        return  crycle > nftCrycle[_strengthenNft][_rewardId];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './IERC721Core.sol';

interface IBurnableERC721 is IERC721Core {

    function burn(address _to, uint _id) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

interface IERC721Core is IERC721 {

    function totalSupply() external returns (uint);

}