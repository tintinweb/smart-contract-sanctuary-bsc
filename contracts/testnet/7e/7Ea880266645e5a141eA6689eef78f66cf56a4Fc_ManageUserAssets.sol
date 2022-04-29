/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// File: @openzeppelin/contracts/utils/Context.sol

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

// File: contracts/AccessControl.sol


pragma solidity ^0.8.12;
abstract contract AccessControl is Context {
    address public owner;
    mapping(address => bool) private operators;

    constructor() {
        owner = _msgSender();
        operators[owner] = true;
    }

    function hasRole(address account) public view virtual returns (bool) {
        return operators[account];
    }

    modifier onlyOwner() {
        require(_msgSender() == owner, "OnlyAdmin");
        _;
    }

    modifier onlyOperator() {
        require(hasRole(_msgSender()) == true, "OnlyOperator");
        _;
    }

    function setOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0));

        operators[owner] = false;
        owner = newOwner;
        operators[newOwner] = true;
    }

    function addOperator(address newOperator) external onlyOwner {
        require(newOperator != address(0));
        operators[newOperator] = true;
    }

    function removeOperator(address operator) external onlyOwner {
        require(operator != address(0));
        require(operator != owner);
        operators[operator] = false;
    }
}

// File: contracts/interfaces/IManageUserAssets.sol

pragma solidity ^0.8.12;


interface IManageUserAssets {
    struct Assets {
        uint256[] lands;
        uint256[] robots;
        uint256 SND;
        uint256 ACD;
        uint256 state;
    }
    function getAsset(address user) external view returns(Assets memory);

    function depositLand(uint256 _tokenId) external;

    function depositRobot(uint256 _tokenId) external;

    function depositACD(uint256 _amount) external;

    function depositSND(uint256 _amount) external;

    function withdrawLand(address ownerLand, uint256 _tokenId) external;

    function withdrawRobot(address ownerRobot, uint256 _tokenId) external;

    function withdrawACD(address to, uint256 amountWithdraw, uint256 amountInGame) external;

    function withdrawSND(address to, uint256 amountWithdraw, uint256 amountInGame) external;
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts/interfaces/IERC721Metadata.sol

// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Metadata.sol)

pragma solidity ^0.8.0;

// File: contracts/interfaces/ISNLand.sol

pragma solidity ^0.8.0;
interface ISNLand is IERC721Metadata {
    function setPause() external;

    function setUnpause() external;

    function getFloorPrice(uint256 tokenId) external view returns (uint256);

    function mint(address to, uint256 tokenId) external payable;

    function addFloorPrice(uint256 tokenId) external payable;

    function burn(uint256 tokenId) external;
    
    function setBaseURI(string memory baseURI_) external;
}

// File: contracts/interfaces/IRobot.sol

pragma solidity ^0.8.0;
interface IRobot is IERC721Metadata {
    function setPause() external;

    function setUnpause() external;

    function getFloorPrice(uint256 tokenId) external view returns (uint256);

    function mint(address to, uint256 tokenId) external payable;

    function addFloorPrice(uint256 tokenId) external payable;

    function burn(uint256 tokenId) external;
    
    function setBaseURI(string memory baseURI_) external;
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

// File: contracts/interfaces/IACDToken.sol

pragma solidity ^0.8.12;
interface IACDToken is IERC20 {
    function mintToken(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function addOperator(address newOperator) external;
}

// File: contracts/interfaces/ISNDToken.sol

pragma solidity ^0.8.12;
interface ISNDToken is IERC20 {
    function mintToken(address to, uint256 amount) external;
    function burn(uint256 amount) external;
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: contracts/ManageUserAssets.sol

pragma solidity ^0.8.12;
contract ManageUserAssets is AccessControl, IManageUserAssets, ReentrancyGuard {
    // event
    event DepositLand(address indexed sender, uint256 tokenId);
    event DepositRobot(address indexed sender, uint256 tokenId);
    event DepositACD(address indexed sender, uint256 amount);
    event DepositSND(address indexed sender, uint256 amount);
    event WithdrawRobot(address indexed owner, uint256 tokenId);
    event WithdrawLand(address indexed owner, uint256 tokenId);
    event WithdrawACD(address indexed owner, uint256 withdrawAmount, uint256 mintedAmount, uint256 burnedAmount);
    event WithdrawSND(address indexed owner, uint256 withdrawAmount, uint256 mintedAmount, uint256 burnedAmount);
    // variables
    ISNLand landNFT;
    IRobot robotNFT;
    IACDToken ACDToken;
    ISNDToken SNDToken;

    mapping(address => Assets) pools;

    // functions
    constructor(
        address _landNFT,
        address _robotNFT,
        address _ACDToken,
        address _SNDToken
    ) {
        landNFT = ISNLand(_landNFT);
        robotNFT = IRobot(_robotNFT);
        ACDToken = IACDToken(_ACDToken);
        SNDToken = ISNDToken(_SNDToken);
    }

    function getAsset(address user) external view override returns (Assets memory) {
        return pools[user];
    }

    function depositLand(uint256 _tokenId) external override {
        address from = msg.sender;

        require(from != address(0), "ManageUserAssets: sender is zero");
        landNFT.transferFrom(from, address(this), _tokenId);

        if (pools[from].state == 0) {
            pools[from].state = 1;
        }
        pools[from].lands.push(_tokenId);

        emit DepositLand(from, _tokenId);
    }

    function depositRobot(uint256 _tokenId) external override {
        address from = msg.sender;

        require(from != address(0), "ManageUserAssets: sender is zero");
        robotNFT.transferFrom(from, address(this), _tokenId);

        if (pools[from].state == 0) {
            pools[from].state = 1;
        }
        pools[from].robots.push(_tokenId);

        emit DepositRobot(from, _tokenId);
    }

    function depositACD(uint256 _amount) external override {
        address from = msg.sender;

        require(from != address(0), "ManageUserAssets: sender is zero");
        ACDToken.transferFrom(from, address(this), _amount);

        if (pools[from].state == 0) {
            pools[from].state = 1;
        }
        pools[from].ACD += _amount;

        emit DepositACD(from, _amount);
    }

    function depositSND(uint256 _amount) external override {
        // address from = msg.sender;
        // require(from != address(0), "ManageUserAssets: sender is zero");
        // SNDToken.transferFrom(from, address(this), _amount);
        // if (pools[from].state == 0) {
        //     pools[from].state = 1;
        // }
        // pools[from].SND +=_amount;
        // emit DepositACD(from, _amount);
    }

    function withdrawLand(address ownerLand, uint256 _tokenId) external override onlyOperator nonReentrant {
        require(ownerLand != address(0), "ManageUserAssets: owner is zero");
        Assets memory pool = pools[ownerLand];
        require(pool.state == 1, "ManageUserAssets: pool is not exist");

        bool landInPool = false;
        int256 indexLandInPool = -1;
        for (uint256 i = 0; i < pool.lands.length; i++) {
            if (pool.lands[i] == _tokenId) {
                landInPool = true;
                indexLandInPool = int256(i);
                break;
            }
        }

        require(landInPool == true, "ManageUserAssets: land is not exist");
        landNFT.safeTransferFrom(address(this), ownerLand, _tokenId);
        delete pool.lands[uint256(indexLandInPool)];

        pools[ownerLand] = pool;
        emit WithdrawLand(ownerLand, _tokenId);
    }

    function withdrawRobot(address ownerRobot, uint256 _tokenId) external override onlyOperator nonReentrant {
        require(ownerRobot != address(0), "ManageUserAssets: owner is zero");
        Assets storage pool = pools[ownerRobot];
        require(pool.state == 1, "ManageUserAssets: pool is not exist");

        bool robotInPool = false;
        int256 indexRobotInPool = -1;
        for (uint256 i = 0; i < pool.lands.length; i++) {
            if (pool.lands[i] == _tokenId) {
                robotInPool = true;
                indexRobotInPool = int256(i);
                break;
            }
        }

        require(robotInPool == true, "ManageUserAssets: robot is not exist");
        robotNFT.safeTransferFrom(address(this), ownerRobot, _tokenId);
        delete pool.robots[uint256(indexRobotInPool)];

        emit WithdrawRobot(ownerRobot, _tokenId);
    }

    function withdrawACD(
        address to,
        uint256 amountWithdraw,
        uint256 amountInGame
    ) external override onlyOperator nonReentrant {
        require(to != address(0), "ManageUserAssets: owner is zero");
        Assets storage pool = pools[to];
        require(pool.state == 1, "ManageUserAssets: pool is not exist");

        uint256 extraMinedAmount = 0;
        uint256 burnedAmount = 0;
        // Amount in game > Amount in pool
        if (amountInGame >= pool.ACD) {
            if (amountWithdraw <= pool.ACD) {
                pool.ACD = pool.ACD - amountWithdraw;
                ACDToken.transfer(to, amountWithdraw);
            } else {
                extraMinedAmount = amountWithdraw - pool.ACD;
                ACDToken.transfer(to, pool.ACD);
                pool.ACD = 0;
                ACDToken.mintToken(to, extraMinedAmount);
            }
        } else {
            burnedAmount = pool.ACD - amountInGame;
            ACDToken.burn(burnedAmount);
            ACDToken.transfer(to, amountWithdraw);
            pool.ACD = amountInGame - amountWithdraw;
        }

        emit WithdrawACD(to, amountWithdraw, extraMinedAmount, burnedAmount);
    }

    function withdrawSND(
        address to,
        uint256 amountWithdraw,
        uint256 amountInGame
    ) external override onlyOperator nonReentrant {
        // require(to != address(0), "ManageUserAssets: owner is zero");
        // Assets memory pool = pools[to];
        // uint256 extraMinedAmount = 0;
        // uint burnedAmount = 0;
        // // Amount in game > Amount in pool
        // if (amountInGame > pool.SND) {
        //     if (amountWithdraw <= pool.SND) {
        //         pool.SND = pool.SND - amountWithdraw;
        //         SNDToken.transferFrom(address(this), to, amountWithdraw);
        //     } else {
        //         pool.SND = 0;
        //         extraMinedAmount = amountWithdraw - pool.SND;
        //         SNDToken.transferFrom(address(this), to, pool.SND);
        //         SNDToken.mintToken(to, extraMinedAmount);
        //     }
        // } else {
        //     burnedAmount = pool.SND - amountInGame;
        //     SNDToken.burn(burnedAmount);
        //     pool.SND =  pool.SND - burnedAmount;
        //     SNDToken.transferFrom(address(this), to, amountWithdraw);
        //     pool.SND =  pool.SND - amountWithdraw;
        // }
        // emit WithdrawSND(to, amountWithdraw, extraMinedAmount, burnedAmount);
    }
}