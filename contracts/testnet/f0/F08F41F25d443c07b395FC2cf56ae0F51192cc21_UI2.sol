/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: contracts/IEternalStorage.sol



pragma solidity 0.8.7;

interface IEternalStorage {
    // *** GLOBAL_DATA_BOOL ***
    function SET_GLOBAL_DATA_BOOL(bytes32 key_, bool value_) external;
    function GET_GLOBAL_DATA_BOOL(bytes32 key_) external view returns (bool);
    function SET_GLOBAL_DATA_BOOL(bytes32 key_0, bool value_0,
                                  bytes32 key_1, bool value_1,
                                  bytes32 key_2, bool value_2,
                                  bytes32 key_3, bool value_3) 
                                  external;
    function GET_GLOBAL_DATA_BOOL(bytes32 key_0, bytes32 key_1) 
                                  external view
                                  returns (bool, bool);
    function GET_GLOBAL_DATA_BOOL(bytes32 key_0, bytes32 key_1, 
                                  bytes32 key_2, bytes32 key_3) 
                                  external view
                                  returns (bool, bool, bool, bool);

    // *** GLOBAL_DATA_UINT256 ***
    function SET_GLOBAL_DATA_UINT256(bytes32 key_, uint256 value_) external;
    function GET_GLOBAL_DATA_UINT256(bytes32 key_) external view returns (uint256);
    function SET_GLOBAL_DATA_UINT256(bytes32 key_0, uint256 value_0,
                                     bytes32 key_1, uint256 value_1,
                                     bytes32 key_2, uint256 value_2,
                                     bytes32 key_3, uint256 value_3) 
                                     external;
    function GET_GLOBAL_DATA_UINT256(bytes32 key_0, bytes32 key_1) 
                                     external view
                                     returns (uint256, uint256);
    function GET_GLOBAL_DATA_UINT256(bytes32 key_0, bytes32 key_1, 
                                     bytes32 key_2, bytes32 key_3) 
                                     external view
                                     returns (uint256, uint256, uint256, uint256);

    // *** GLOBAL_DATA_ADDRESS ***
    function SET_GLOBAL_DATA_ADDRESS(bytes32 key_, address value_) external;
    function GET_GLOBAL_DATA_ADDRESS(bytes32 key_) external view returns (address);
    function SET_GLOBAL_DATA_ADDRESS(bytes32 key_0, address value_0,
                                     bytes32 key_1, address value_1,
                                     bytes32 key_2, address value_2,
                                     bytes32 key_3, address value_3) 
                                     external;
    function GET_GLOBAL_DATA_ADDRESS(bytes32 key_0, bytes32 key_1) 
                                     external view
                                     returns (address, address);
    function GET_GLOBAL_DATA_ADDRESS(bytes32 key_0, bytes32 key_1, 
                                     bytes32 key_2, bytes32 key_3) 
                                     external view
                                     returns (address, address, address, address);
    function INCREASE_GLOBAL_DATA_UINT256(bytes32 key_, uint256 value_) external;
    function DECREASE_GLOBAL_DATA_UINT256(bytes32 key_, uint256 value_) external;

    // *** NFT_DATA ***
    function SET_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external;
    function SET_NFT_DATA_BOOL(uint256 index_, uint256 structDataIndex_, uint256 boolDataIndex_, bool value_) external;
    function GET_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, uint256 uint256DataIndex_) external view returns (uint256);
    function GET_NFT_DATA_BOOL(uint256 index_, uint256 structDataIndex_, uint256 boolDataIndex_) external view returns (bool);
    function SET_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, 
                                  uint256 uint256DataIndex_0, uint256 value_0,
                                  uint256 uint256DataIndex_1, uint256 value_1) 
                                  external;
    function SET_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, 
                                  uint256 uint256DataIndex_0, uint256 value_0,
                                  uint256 uint256DataIndex_1, uint256 value_1,
                                  uint256 uint256DataIndex_2, uint256 value_2,
                                  uint256 uint256DataIndex_3, uint256 value_3) 
                                  external;
    function SET_NFT_DATA_BOOL(uint256 index_, uint256 structDataIndex_, 
                               uint256 boolDataIndex_0, bool value_0,
                               uint256 boolDataIndex_1, bool value_1,
                               uint256 boolDataIndex_2, bool value_2,
                               uint256 boolDataIndex_3, bool value_3) 
                               external;
    function GET_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, 
                                  uint256 uint256DataIndex_0, uint256 uint256DataIndex_1) 
                                  external view 
                                  returns (uint256, uint256);
    function GET_NFT_DATA_BOOL(uint256 index_, uint256 structDataIndex_, 
                               uint256 boolDataIndex_0, uint256 boolDataIndex_1) 
                               external view 
                               returns (bool, bool);
    function GET_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, 
                                  uint256 uint256DataIndex_0, uint256 uint256DataIndex_1,
                                  uint256 uint256DataIndex_2, uint256 uint256DataIndex_3) 
                                  external view 
                                  returns (uint256, uint256, uint256, uint256);
    function GET_NFT_DATA_BOOL(uint256 index_, uint256 structDataIndex_, 
                               uint256 boolDataIndex_0, uint256 boolDataIndex_1,
                               uint256 boolDataIndex_2, uint256 boolDataIndex_3) 
                               external view 
                               returns (bool, bool, bool, bool);
    function INCREASE_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external;
    function DECREASE_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external;

    // *** WALLET_DATA ***
    function SET_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external;
    function SET_WALLET_DATA_BOOL(address addr_, uint256 structDataIndex_, uint256 boolDataIndex_, bool value_) external;
    function GET_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, uint256 uint256DataIndex_) external view returns (uint256);
    function GET_WALLET_DATA_BOOL(address addr_, uint256 structDataIndex_, uint256 boolDataIndex_) external view returns (bool);
    function SET_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, 
                                     uint256 uint256DataIndex_0, uint256 value_0,
                                     uint256 uint256DataIndex_1, uint256 value_1) 
                                     external;
    function SET_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, 
                                     uint256 uint256DataIndex_0, uint256 value_0,
                                     uint256 uint256DataIndex_1, uint256 value_1,
                                     uint256 uint256DataIndex_2, uint256 value_2,
                                     uint256 uint256DataIndex_3, uint256 value_3) 
                                     external;
    function SET_WALLET_DATA_BOOL(address addr_, uint256 structDataIndex_, 
                                  uint256 boolDataIndex_0, bool value_0,
                                  uint256 boolDataIndex_1, bool value_1,
                                  uint256 boolDataIndex_2, bool value_2,
                                  uint256 boolDataIndex_3, bool value_3) 
                                  external;
    function GET_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, 
                                     uint256 uint256DataIndex_0, uint256 uint256DataIndex_1) 
                                     external view 
                                     returns (uint256, uint256);
    function GET_WALLET_DATA_BOOL(address addr_, uint256 structDataIndex_, 
                                  uint256 boolDataIndex_0, uint256 boolDataIndex_1) 
                                  external view 
                                  returns (bool, bool);
    function GET_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, 
                                     uint256 uint256DataIndex_0, uint256 uint256DataIndex_1,
                                     uint256 uint256DataIndex_2, uint256 uint256DataIndex_3) 
                                     external view 
                                     returns (uint256, uint256, uint256, uint256);
    function GET_WALLET_DATA_BOOL(address addr_, uint256 structDataIndex_, 
                                  uint256 boolDataIndex_0, uint256 boolDataIndex_1,
                                  uint256 boolDataIndex_2, uint256 boolDataIndex_3) 
                                  external view 
                                  returns (bool, bool, bool, bool);
    function INCREASE_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external;
    function DECREASE_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external;

    // *** WORD_DATA ***
    function SET_WORD_DATA_UINT256(bytes32 key_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external;
    function SET_WORD_DATA_BYTES32(bytes32 key_, uint256 structDataIndex_, uint256 bytes32DataIndex_, bytes32 value_) external;
    function SET_WORD_DATA_ADDRESS(bytes32 key_, uint256 structDataIndex_, uint256 addressDataIndex_, address value_) external;
    function SET_WORD_DATA_UINT256(bytes32 key_, uint256 structDataIndex_, uint256[] calldata uint256DataIndexes_, uint256[] calldata values_) external;
    function SET_WORD_DATA_BYTES32(bytes32 key_, uint256 structDataIndex_, uint256[] calldata bytes32DataIndexes_, bytes32[] calldata values_) external;
    function SET_WORD_DATA_ADDRESS(bytes32 key_, uint256 structDataIndex_, uint256[] calldata addressDataIndexes_, address[] calldata values_) external;
    function GET_WORD_DATA_UINT256(bytes32 key_, uint256 structDataIndex_, uint256 uint256DataIndex_) external view returns (uint256);
    function GET_WORD_DATA_BYTES32(bytes32 key_, uint256 structDataIndex_, uint256 bytes32DataIndex_) external view returns (bytes32);
    function GET_WORD_DATA_ADDRESS(bytes32 key_, uint256 structDataIndex_, uint256 addressDataIndex_) external view returns (address);
    function GET_WORD_DATA_UINT256(bytes32 key_, uint256 structDataIndex_, uint256 startIndex_, uint256 endIndex_) external view returns (uint256[] memory);
    function GET_WORD_DATA_BYTES32(bytes32 key_, uint256 structDataIndex_, uint256 startIndex_, uint256 endIndex_) external view returns (bytes32[] memory);
    function GET_WORD_DATA_ADDRESS(bytes32 key_, uint256 structDataIndex_, uint256 startIndex_, uint256 endIndex_) external view returns (address[] memory);

    // TRANSFER
    function TRANSFER_ERC20(address tokenAddress_, address to_, uint256 amount_) external;

    // *** OWNER ***
    function AddToWhiteList(address addr_) external;
    function AddToWhiteList(address[] calldata addr_) external;
    function RemoveFromWhiteList(address addr_) external;
    function RemoveFromWhiteList(address[] calldata addr_) external;
    function AddToAllWhiteLists(address addr_) external;
    function AddToAllWhiteLists(address[] calldata addr_) external;
    function RemoveFromAllWhiteLists(address addr_) external;
    function RemoveFromAllWhiteLists(address[] calldata addr_) external;
    function IsWhiteListed(address addr) external view returns (bool);
    function owner() external view returns (address);
    function transferOwnership(address newOwner_) external;
    function withdrawETHFixed(uint256 withdrawAmount_) external;
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


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: contracts/IWarrior721.sol



pragma solidity 0.8.7;


interface IWarrior721 is IERC721Enumerable {
    function ETERNAL_CALL() external;
    function G_WarriorId() external view returns (uint256 _warriorId);
    function G_TotalActiveSupply() external view returns (uint256 _totalActiveSupply);
    function G_AllOwnerTokenIds(address tokenOwner_) external view returns (uint256[] memory _ownedTokenIds);
    function WhitelistMint(address to_, uint256 timestamp_, uint256 hero_, uint256 rarity_, uint256 level_) external;
    function MultiWhitelistMint(address[] calldata to_, uint256[] calldata hero_, uint256[] calldata rarity_) external;
    function changeBaseURI(string calldata newbaseURI) external returns (string memory _newbaseURI);
}
// File: contracts/UI2.sol



pragma solidity 0.8.7;





contract UI2 {

    // Eternal Storage
    IEternalStorage private eternalStorage;

    // Initialize
    uint256 private constant oneWarriorArraySize = 7;

    // Constructor
    constructor(address eternalStorageAddr_) {
        eternalStorage = IEternalStorage(eternalStorageAddr_);
    }

    // OWNER
    function G_OWNER() external view returns (address _owner) {
        return eternalStorage.owner();
    }

    // *** DESTROY ***
    function A_DestroyContract(bool confirmed) external onlyOwner {
        address collector_ = eternalStorage.owner();
        require(confirmed && collector_ != address(0));
        selfdestruct(payable(collector_));
    }

    // startIndex and endIndex are included
    function EX_AllPlayerPowers(uint256 startIndex, uint256 endIndex) external view returns (address[] memory players_, uint256[] memory playerPowers_, uint256[] memory strongestWarriorIds_) {
        uint256 maxIndex = eternalStorage.GET_WORD_DATA_UINT256("PLAYER", 0, 0);
        address[] memory addresses;
        uint256[] memory powers;
        uint256[] memory NFTids;
        uint256[] memory strongestWarriorIds;
        uint256 level; uint256 rarity;
        IWarrior721 warrior721 = IWarrior721(eternalStorage.GET_GLOBAL_DATA_ADDRESS("WARRIOR721_ADDRESS"));
        if (startIndex > endIndex || endIndex == 0 || endIndex > maxIndex || startIndex > maxIndex) {
            startIndex = 0; 
            endIndex = maxIndex;
        }
        addresses = eternalStorage.GET_WORD_DATA_ADDRESS("PLAYER", 0, startIndex, endIndex); // new address[]((endIndex + 1) - startIndex); 
        powers = new uint256[](addresses.length);
        strongestWarriorIds = new uint256[](addresses.length);
        for (uint i = 0; i <= endIndex; ++i) {
            if (addresses[i] != address(0)) {
                NFTids = warrior721.G_AllOwnerTokenIds(addresses[i]);
                uint256 strongestWarriorPower = 0;
                for (uint256 j = 0; j < NFTids.length; ++j) {
                    (rarity, level) = eternalStorage.GET_NFT_DATA_UINT256(NFTids[j], 0, 2, 3);
                    uint256 warriorPower = calculateWarriorPower(rarity, level);
                    powers[i] += warriorPower;
                    if (warriorPower > strongestWarriorPower) {
                        strongestWarriorPower = warriorPower;
                        strongestWarriorIds[i] = NFTids[j];
                    }
                }
            }
        }

        return (addresses, powers, strongestWarriorIds);
    }

    // startIndex and endIndex are included
    function EX_AllPlayerPowersOnly() external view returns (uint256[] memory playerPowers_) {
        uint256 maxIndex = eternalStorage.GET_WORD_DATA_UINT256("PLAYER", 0, 0);
        address[] memory addresses;
        uint256[] memory powers;
        uint256[] memory NFTids;
        uint256 level; uint256 rarity;
        IWarrior721 warrior721 = IWarrior721(eternalStorage.GET_GLOBAL_DATA_ADDRESS("WARRIOR721_ADDRESS"));

        addresses = eternalStorage.GET_WORD_DATA_ADDRESS("PLAYER", 0, 0, maxIndex + 1);
        powers = new uint256[](maxIndex + 1);
        for (uint256 i = 0; i <= maxIndex + 1; ++i) {
            if (addresses[i] != address(0)) {
                NFTids = warrior721.G_AllOwnerTokenIds(addresses[i]);
                for (uint256 j = 0; j < NFTids.length; ++j) {
                    (rarity, level) = eternalStorage.GET_NFT_DATA_UINT256(NFTids[j], 0, 2, 3);
                    powers[i] += calculateWarriorPower(rarity, level);
                }
            }
        }

        return powers;
    }

    function EX_AllPlayerPowers(uint256[] memory addressIndexs) external view returns (address[] memory players_, uint256[] memory playerPowers_, uint256[] memory strongestWarriorIds_) {
        address[] memory addresses;
        uint256[] memory powers;
        uint256[] memory NFTids;
        uint256[] memory strongestWarriorIds;
        uint256 level; uint256 rarity;
        IWarrior721 warrior721 = IWarrior721(eternalStorage.GET_GLOBAL_DATA_ADDRESS("WARRIOR721_ADDRESS"));
        
        uint256 arraySize = addressIndexs.length;
        addresses = new address[](arraySize); 
        for (uint256 i = 0; i < arraySize; i++) {
            addresses[i] = eternalStorage.GET_WORD_DATA_ADDRESS("PLAYER", 0, addressIndexs[i]);
        }

        powers = new uint256[](addresses.length);
        strongestWarriorIds = new uint256[](addresses.length);
        for (uint i = 0; i < arraySize; ++i) {
            if (addresses[i] != address(0)) {
                NFTids = warrior721.G_AllOwnerTokenIds(addresses[i]);
                uint256 strongestWarriorPower = 0;
                for (uint256 j = 0; j < NFTids.length; ++j) {
                    (rarity, level) = eternalStorage.GET_NFT_DATA_UINT256(NFTids[j], 0, 2, 3);
                    uint256 warriorPower = calculateWarriorPower(rarity, level);
                    powers[i] += warriorPower;
                    if (warriorPower > strongestWarriorPower) {
                        strongestWarriorPower = warriorPower;
                        strongestWarriorIds[i] = NFTids[j];
                    }
                }
            }
        }

        return (addresses, powers, strongestWarriorIds);
    }


    function calculateWarriorPower(uint256 rarity, uint256 level) private pure returns (uint256) {
        uint256 basePower = 1000 + rarity * 50;
        return basePower + ((level - 1) * basePower) / 10;
    }

    // *** GET EXTERNAL IN-GAME ***
    /*
        0  - heroPersona_
        1  - heroRarity_
        2  - heroLevel_
        3  - heroExp_
        4  - ownedAbilityAmount_
        5  - ability1_
        6  - ability2_
    */
    function EX_AllWarriorDetails(uint256[] memory warriorIds_) external view returns (uint256[] memory _warriorDetails) {
        uint256 warriorIdsLength = warriorIds_.length;
        uint256[] memory values;
        if (warriorIdsLength > 0) {
            uint256 valuesIndex;
            values = new uint256[](warriorIdsLength * oneWarriorArraySize);
            for (uint256 i = 0; i < warriorIdsLength; ++i) {
                uint256[] memory warriorDetails_ = _EX_WarriorDetails(warriorIds_[i]);
                for (uint j = 0; j < oneWarriorArraySize; ++j) {
                    values[valuesIndex] = warriorDetails_[j];
                    valuesIndex++;
                }
            }
        }
        return values;
    }
    // startIndex and endIndex are included
    function EX_WarriorLevelsAndExps(uint256 startIndex, uint256 endIndex) external view returns (uint256[] memory _levels, uint256[] memory _rarities) {
        uint256[] memory levels;
        uint256[] memory rarities;
        if (startIndex > endIndex) {
            startIndex = 0;
            endIndex = IWarrior721(eternalStorage.GET_GLOBAL_DATA_ADDRESS("WARRIOR721_ADDRESS")).G_WarriorId();
            levels = new uint256[](endIndex + 1);
            rarities = new uint256[](endIndex + 1);
        }
        else {
            levels = new uint256[](endIndex - startIndex);
            rarities = new uint256[](endIndex - startIndex);
        }
        for (uint256 i = 0; i < levels.length; ++i) {
            (levels[i], rarities[i]) = eternalStorage.GET_NFT_DATA_UINT256(startIndex + i, 0, 3, 2);
        }
        return (levels, rarities);
    }

    // *** PRIVATE ***
    function _EX_WarriorDetails(uint256 warriorId_) private view returns (uint256[] memory) {
        uint256[] memory values = new uint256[](oneWarriorArraySize);
        (values[0], values[1], values[2], values[3]) = eternalStorage.GET_NFT_DATA_UINT256(warriorId_, 0, 1, 2, 3, 4);
        if (eternalStorage.GET_NFT_DATA_UINT256(warriorId_, 0, 13) > 0) {
            (values[4] , values[5], values[6],) = eternalStorage.GET_NFT_DATA_UINT256(warriorId_, 0, 7, 8, 9, 99);
        }
        
        return values;
    }

    // *** MODIFIERS ***
    // ONLY OWNER
    modifier onlyOwner() {
        _onlyOwner();
        _;
    }
    function _onlyOwner() private view {
        require(eternalStorage.owner() == msg.sender);
    }
}