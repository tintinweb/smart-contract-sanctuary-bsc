/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

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
// File: contracts/IMint.sol



pragma solidity 0.8.7;

interface IMint {
    function ETERNAL_CALL() external;
    function A_USER_MINT() external;
    function A_USER_MINT_MULTI(uint256 amount) external;
    function A_UPGRADE_AREA(uint256 warriorId_) external;
    function A_WhitelistMintRandomized(address to_) external;
    function A_WhitelistMintMultiple(address to_, uint256 mintAmount_, uint256 hero_, uint256 rarity_, uint256 level_) external;
    function A_WhitelistMintMultipleRandomized(address to_, uint256 mintAmount_) external;
	function withdrawERC721(address tokenAddress_, uint256 tokenId_) external;
    function withdrawERC1155(address tokenAddress_, uint256 tokenId_, uint256 amount_) external;
    function withdrawETHFixed(uint256 withdrawAmount_) external;
    function withdrawETH(uint256 withdrawAmount_) external;
    function transferERC20(address tokenAddress_, uint256 amount) external;
    function A_DestroyContract(bool confirmed) external;
}
// File: contracts/IFight.sol



pragma solidity 0.8.7;

interface IFight {
    function ETERNAL_CALL() external;
    function A_INITIALIZE() external;
    function A_FIGHT(uint256 warriorId_, uint256 choosingEnemy_, bool spendAllFightsAtOnce_) external;
    function A_RerollEnemies(uint256 warriorId_) external;
    function A_EnemiesAndRarities(uint256 index_) external view returns (uint256[] memory _result);
    function A_DestroyContract(bool confirmed) external;
}
// File: contracts/IBank.sol



pragma solidity 0.8.7;

interface IBank {
    function ETERNAL_CALL() external;
    function A_WITHDRAW_AOW() external payable;
    function A_REFERENCE(address addr_) external;
    function S_MaxWithdrawAmount(uint256 maxWithdrawAmount_) external;
    function GetVariablesUint256() external view returns (uint256[] memory _values);
    function GetVariablesBool() external view returns (bool[] memory _values);
    function GetVariablesAddress() external view returns (address[] memory _values);
    function IsAcceptedReferenceAddress(address mainAddr_) external view returns (uint256 _mainPassed, uint256 _refPassed);
    function withdrawERC721(address tokenAddress_, uint256 tokenId_) external;
    function withdrawERC1155(address tokenAddress_, uint256 tokenId_, uint256 amount_) external;
    function withdrawETHFixed(uint256 withdrawAmount_) external;
    function withdrawETH(uint256 withdrawAmount_) external;
    function transferERC20(address tokenAddress_, uint256 amount) external;
    function A_DestroyContract(bool confirmed) external;
}
// File: contracts/IActions.sol



pragma solidity 0.8.7;

interface IActions {
    function ETERNAL_CALL() external;
    function A_AfterHeroMinted(address to_, uint256 warriorId_, uint256 createdTime_, uint256 hero_, uint256 rarity_, uint256 level_) external;
    function A_BeforeTokenTransfer(address from, address to, uint256 tokenId) external;
    function A_AfterTokenTransfer(address from, address to, uint256 tokenId) external;
    function A_DestroyContract(bool confirmed) external;
}
// File: contracts/UI.sol



pragma solidity 0.8.7;









contract UI {

    // Eternal Storage
    IEternalStorage private eternalStorage;

    // Initialize
    bool private initialized = false;
    uint256 private constant oneWarriorArraySize = 24;
    address private immutable temporaryOwner;
    address private immutable BNB_ADDRESS;
    // Constructor
    constructor(address bnbAddress) {
        temporaryOwner = msg.sender;
        BNB_ADDRESS = bnbAddress;
    }

// *** SET ***
    function UpgradeUI(address eternalStorageAddr_, uint256 gameVersion) external {
        require(!initialized && msg.sender == temporaryOwner && eternalStorageAddr_ != address(0));
        initialized = true;
        eternalStorage = IEternalStorage(eternalStorageAddr_);
        eternalStorage.SET_GLOBAL_DATA_ADDRESS("UI_ADDRESS", address(this));
        eternalStorage.SET_GLOBAL_DATA_UINT256("GAME_VERSION", gameVersion);
        _ETERNAL_CALL();
    }
    function Initialize_All_Game(address eternalStorageAddr_, address[] memory values) external {
        require(!initialized && msg.sender == temporaryOwner && eternalStorageAddr_ != address(0) && values.length == 11);

        /*
            0  -  AOW_ADDRESS
            1  -  WARRIOR721_ADDRESS
            2  -  BURN_ADDRESS
            3  -  AOW_PAIR_ADDRESS
            4  -  ROUTER_ADDRESS
            5  -  BUSD_BNB_PAIR_ADDRESS
            6  -  FEECOLLECTOR_ADDRESS
            7  -  BANK_ADDRESS
            8  -  ACTIONS_ADDRESS
            9  -  FIGHT_ADDRESS
            10 -  MINT_ADDRESS
        */

        // UI Initialize
        initialized = true;
        
        eternalStorage = IEternalStorage(eternalStorageAddr_);

        eternalStorage.SET_GLOBAL_DATA_UINT256("GAME_VERSION", 1);
        eternalStorage.SET_GLOBAL_DATA_ADDRESS("UI_ADDRESS", address(this),
                                               "AOW_ADDRESS", values[0],
                                               "WARRIOR721_ADDRESS", values[1],
                                               "BURN_ADDRESS", values[2]);
        eternalStorage.SET_GLOBAL_DATA_ADDRESS("AOW_PAIR_ADDRESS", values[3],
                                               "ROUTER_ADDRESS", values[4],
                                               "BUSD_BNB_PAIR_ADDRESS", values[5],
                                               "FEECOLLECTOR_ADDRESS", values[6]);
        eternalStorage.SET_GLOBAL_DATA_ADDRESS("BANK_ADDRESS", values[7],
                                               "ACTIONS_ADDRESS", values[8],
                                               "FIGHT_ADDRESS", values[9],
                                               "MINT_ADDRESS", values[10]);

        eternalStorage.SET_GLOBAL_DATA_UINT256("MAX_HERO_PERSONA", 4,
                                               "MAX_HERO_RARITY", 4,
                                               "MAX_ENEMY_PERSONA", 5,
                                               "WARRIOR_MINT_COST_ORACLE", 160 * 10 ** 18); // 160 USD referred
        eternalStorage.SET_GLOBAL_DATA_UINT256("AREA_UPGRADE_LEVEL", 5, // Area level up is available every 5 level
                                               "MAX_FIGHT_LIMIT", 3, // 3 Fight limit
                                               "ONE_FIGHT_COST", 4 * 3600, // 4 hours
                                               "MAX_FIGHTS_AT_ONCE", 2); // Maximum 2 fights for a single action
        eternalStorage.SET_GLOBAL_DATA_UINT256("WITHDRAW_COIN_FEE", 20, // 20% fee for the withdraw
                                               "WITHDRAW_FEE_DAILY_DROP", 2, // Fee decreasing 2% every day
                                               "WARRIOR_COMBAT_REWARD_ORACLE", 5 * 10 ** 18, // 5 USD referred
                                               "WARRIOR_COMBAT_REWARD_STABLE", 250 * 10 ** 18); // 0.02 referred
        eternalStorage.SET_GLOBAL_DATA_UINT256("ETH_WARRIOR_MINT_FEE", 0, // 4 * 10 ** 15 = 0.004 BNB (1.6 USD)
                                               "ETH_WITHDRAW_FEE", 4 * 10 ** 15, // 4 * 10 ** 15 = 0.004 BNB (1.6 USD)
                                               "SWAP_FEE_ON_WITHDRAW", 0, // 0% of the fee will be swapped
                                               "WITHDRAW_COOLDOWN", 2 * 3600); // Wait 2 hours for every withdraw action
        eternalStorage.SET_GLOBAL_DATA_UINT256("REFERENCE_FEE", 10, // 10% withdraw fee (5% for user, 5% for owner)
                                               "DISCOUNT5", 10, // Mint 5 discount: 10%
                                               "DISCOUNT10", 15, // Mint 10 discount: 15%
                                               "AREA_UPGRADE_COST", 30 * 10 ** 18); // 30 USD referred
        
        eternalStorage.SET_GLOBAL_DATA_BOOL("CAN_TRANSFER", true,
                                            "CAN_MINT_WHITELIST", true,
                                            "RESET_FIGHTS_AFTER_TRANSFER", true,
                                            "ORACLE_ENABLED", true);
        eternalStorage.SET_GLOBAL_DATA_BOOL("CAN_COMBAT_FIGHT", true,
                                            "SPEND_FIGHTS_AT_ONCE", true,
                                            "CAN_WITHDRAW_COIN", true,
                                            "CAN_MINT_USER", true);
        eternalStorage.SET_GLOBAL_DATA_BOOL("REFERENCE_ENABLED", true);
                                               
        eternalStorage.SET_WALLET_DATA_BOOL(values[2], 0, 2, true);

        // Add To All Whitelists (Warrior721, Bank, Actions, Fight, Mint)
        eternalStorage.AddToAllWhiteLists(values[1]);
        eternalStorage.AddToAllWhiteLists(values[7]);
        eternalStorage.AddToAllWhiteLists(values[8]);
        eternalStorage.AddToAllWhiteLists(values[9]);
        eternalStorage.AddToAllWhiteLists(values[10]);

        // Eternal Storage Call
        _ETERNAL_CALL();

        // IFight -> A_Initialize
        IFight(values[9]).A_INITIALIZE();

        // Set GAME_ENABLED -> eternalStorage.SET_GLOBAL_DATA_BOOL("GAME_ENABLED", true);
    }
    // *** DESTROY ***
    function A_DestroyContract(bool confirmed) external onlyOwner {
        require(confirmed);
        address collector_ = eternalStorage.owner();
        require(collector_ != address(0));
        selfdestruct(payable(collector_));
    }

    function ETERNAL_CALL() external onlyOwner {
        _ETERNAL_CALL();
    }
    function Initialize_Fight() external onlyOwner {
        IFight(eternalStorage.GET_GLOBAL_DATA_ADDRESS("FIGHT_ADDRESS")).A_INITIALIZE();
    }
    function S_GAME_ENABLED(bool forceStop, bool gameEnabled, bool canTransfer, bool canWithdraw) external onlyOwner {
        eternalStorage.SET_GLOBAL_DATA_BOOL("FORCE_STOP", forceStop,
                                            "GAME_ENABLED", gameEnabled,
                                            "CAN_TRANSFER", canTransfer,
                                            "CAN_WITHDRAW_COIN", canWithdraw);
    }
    // GLOBAL DATA BOOL
    /*
    function S_GLOBAL_DATA_BOOL(string[] calldata key_, bool[] calldata value_) external onlyOwner {
        if (key_.length > 0 && key_.length == value_.length) {
            for (uint256 i = 0; i < key_.length; ++i){
                eternalStorage.SET_GLOBAL_DATA_BOOL(_stringToBytes32(key_[i]), value_[i]);
            }
        }
    }
    */
    function S_GLOBAL_DATA_BOOL(bytes32[] calldata key_, bool[] calldata value_) external onlyOwner {
        if (key_.length > 0 && key_.length == value_.length) {
            for (uint256 i = 0; i < key_.length; ++i){
                eternalStorage.SET_GLOBAL_DATA_BOOL(key_[i], value_[i]);
            }
        }
    }
    // GLOBAL DATA UINT256
    /*
    function S_GLOBAL_DATA_UINT256(string[] calldata key_, uint256[] calldata value_) external onlyOwner {
        if (key_.length > 0 && key_.length == value_.length) {
            for (uint256 i = 0; i < key_.length; ++i){
                eternalStorage.SET_GLOBAL_DATA_UINT256(_stringToBytes32(key_[i]), value_[i]);
            }
        }
    }
    */
    function S_GLOBAL_DATA_UINT256(bytes32[] calldata key_, uint256[] calldata value_) external onlyOwner {
        if (key_.length > 0 && key_.length == value_.length) {
            for (uint256 i = 0; i < key_.length; ++i){
                eternalStorage.SET_GLOBAL_DATA_UINT256(key_[i], value_[i]);
            }
        }
    }
    /*
    function S_MAX_FIGHT_LIMIT_AND_ONE_FIGHT_COST(uint256 newMaxFightLimit_, uint256 newOneFightCost_, uint256 timeType_) external onlyOwner returns (uint256 maxFightLimit_, uint256 oneFightCost_) {
        require(newMaxFightLimit_ > 0 && newOneFightCost_ > 0 && timeType_ >= 0 && timeType_ <= 3);
        if (timeType_ == 0) newOneFightCost_ *= 1; // Seconds
        else if (timeType_ == 1) newOneFightCost_ *= 60; // Minutes
        else if (timeType_ == 2) newOneFightCost_ *= 3600; // Hours
        else if (timeType_ == 3) newOneFightCost_ *= 86400; // Days
        eternalStorage.SET_GLOBAL_DATA_UINT256("MAX_FIGHT_LIMIT", newMaxFightLimit_,
                                               "ONE_FIGHT_COST", newOneFightCost_,
                                               "NULL_INDEX", 0,
                                               "NULL_INDEX", 0);
        return (newMaxFightLimit_, newOneFightCost_);
    }
    */
    /*
    function S_WITHDRAW_COIN_FEE_AND_DAILY_DROP(uint256 withdrawCoinFeePercentage_, uint256 dailyDropAmount_) external onlyOwner returns (uint256 withdrawCoinFee_, uint256 withdrawFeeDailyDrop_) {
        require(withdrawCoinFeePercentage_ < 100 && dailyDropAmount_ <= 10, "Wrong value");
        eternalStorage.SET_GLOBAL_DATA_UINT256("WITHDRAW_COIN_FEE", withdrawCoinFeePercentage_,
                                               "WITHDRAW_FEE_DAILY_DROP", dailyDropAmount_,
                                               "NULL_INDEX", 0,
                                               "NULL_INDEX", 0);
        return (withdrawCoinFeePercentage_, dailyDropAmount_);
    }
    */
    function S_WARRIOR_MINT_COST_ORACLE(uint256 oracleValue_) external onlyOwner{
        require(oracleValue_ >= 10 ** 20, "Wrong value");
        eternalStorage.SET_GLOBAL_DATA_UINT256("WARRIOR_MINT_COST_ORACLE", oracleValue_);
    }
    function S_WARRIOR_COMBAT_REWARD_ORACLE_AND_STABLE(uint256 oracleValue_, uint256 stableValue_) external onlyOwner{
        require(oracleValue_ >= 10 ** 18 && stableValue_ >= 10 ** 18, "Wrong value");
        eternalStorage.SET_GLOBAL_DATA_UINT256("WARRIOR_COMBAT_REWARD_ORACLE", oracleValue_,
                                               "WARRIOR_COMBAT_REWARD_STABLE", stableValue_,
                                               "NULL_INDEX", 0,
                                               "NULL_INDEX", 0);
    }
    function S_ETH_FEES_AND_WITHDRAW_COOLDOWN(uint256 mintFee_, uint256 withdrawFee_, uint256 withdrawCooldown_) external onlyOwner 
        returns (uint256 ethWarriorMintFee_, uint256 ethWithdrawFee_, uint256 _withdrawCooldown) {
        require((mintFee_ >= 10 ** 14 || mintFee_ == 0) && 10 ** 18 > mintFee_ &&
                (withdrawFee_ >= 10 ** 14 || withdrawFee_ == 0) && 10 ** 18 > withdrawFee_ &&
                withdrawCooldown_ > 0 , "Wrong values");
        eternalStorage.SET_GLOBAL_DATA_UINT256("ETH_WARRIOR_MINT_FEE", mintFee_,
                                               "ETH_WITHDRAW_FEE", withdrawFee_,
                                               "WITHDRAW_COOLDOWN", withdrawCooldown_,
                                               "NULL_INDEX", 0);
        return (mintFee_, withdrawFee_, withdrawCooldown_);
    }

    // GLOBAL DATA ADDRESS
    function S_GLOBAL_DATA_ADDRESS(bytes32[] calldata key_, address[] calldata value_) external onlyOwner {
        if (key_.length > 0 && key_.length == value_.length) {
            for (uint256 i = 0; i < key_.length; ++i){
                eternalStorage.SET_GLOBAL_DATA_ADDRESS(key_[i], value_[i]);
            }
        }
    }
    // NFT DATA
    function S_NFT_DATA_UINT256(uint256 index_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external onlyOwner {
        eternalStorage.SET_NFT_DATA_UINT256(index_, structDataIndex_, uint256DataIndex_, value_);
    }
    function S_WarriorDetails(uint256 warriorId_, uint256 hero_, uint256 rarity_, uint256 level_, 
                              uint256 ownedAbilityAmount_, uint256 ability1, uint256 ability2, uint256 abilitiesRevealed_) 
                              external onlyOwner {
        eternalStorage.SET_NFT_DATA_UINT256(warriorId_, 0, 1, hero_, 2, rarity_, 3, level_, 99, 99);
        eternalStorage.SET_NFT_DATA_UINT256(warriorId_, 0, 8, ability1, 9, ability2, 7, ownedAbilityAmount_, 13, abilitiesRevealed_);
    }

    // WALLET DATA
    function SET_WALLET_DATA_UINT256(address addr_, uint256 structDataIndex_, uint256 uint256DataIndex_, uint256 value_) external onlyOwner {
        eternalStorage.SET_WALLET_DATA_UINT256(addr_, structDataIndex_, uint256DataIndex_, value_);
    }
    function SET_WALLET_DATA_BOOL(address addr_, uint256 structDataIndex_, uint256 boolDataIndex_, bool value_) external onlyOwner {
        eternalStorage.SET_WALLET_DATA_BOOL(addr_, structDataIndex_, boolDataIndex_, value_);
    }
    function S_List(uint256 listIndex_, address[] calldata addresses, bool value_) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; ++i) {
			if (addresses[i] != address(0)) {
                eternalStorage.SET_WALLET_DATA_BOOL(addresses[i], 0, listIndex_, value_);
            }
		}
    }

    // WHITELISTS
    function SetToAllWhiteLists(address[] calldata addresses, bool value_) external onlyOwner {
        if (value_) {
            for (uint256 i = 0; i < addresses.length; ++i) {
                eternalStorage.AddToAllWhiteLists(addresses[i]);
            }
        }
        else {
            for (uint256 i = 0; i < addresses.length; ++i) {
                eternalStorage.RemoveFromAllWhiteLists(addresses[i]);
            }
        }
    }

// *** GET ***
    // OWNER
    function G_OWNER() external view returns (address _owner) {
        return eternalStorage.owner();
    }

// *** PRIVATE ***
    function _ETERNAL_CALL() private {
        IActions(eternalStorage.GET_GLOBAL_DATA_ADDRESS("ACTIONS_ADDRESS")).ETERNAL_CALL();
        IBank(eternalStorage.GET_GLOBAL_DATA_ADDRESS("BANK_ADDRESS")).ETERNAL_CALL();
        IFight(eternalStorage.GET_GLOBAL_DATA_ADDRESS("FIGHT_ADDRESS")).ETERNAL_CALL();
        IMint(eternalStorage.GET_GLOBAL_DATA_ADDRESS("MINT_ADDRESS")).ETERNAL_CALL();
        IWarrior721(eternalStorage.GET_GLOBAL_DATA_ADDRESS("WARRIOR721_ADDRESS")).ETERNAL_CALL();
    }
    function _stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }
    // TOKEN to BUSD
    function getUSDToTokenPrice(address tokenETHPairAddress, address usdETHPairAddress, uint256 usdAmount) private view returns (uint256 usdPriceAsToken_) {
        (, uint256 usdPriceAsToken) = getUSDToETHToTokenPrice(tokenETHPairAddress, usdETHPairAddress, usdAmount);
        return usdPriceAsToken;
    }
    function getTokenToUSDPrice(address tokenETHPairAddress, address usdETHPairAddress, uint256 tokenAmount) private view returns (uint256 tokenPriceAsUSD_) {
        (, uint256 tokenPriceAsUSD) = getTokenToETHToUSDPrice(tokenETHPairAddress, usdETHPairAddress, tokenAmount);
        return tokenPriceAsUSD;
    }
    function getUSDToETHToTokenPrice(address tokenETHPairAddress, address usdETHPairAddress, uint amount) 
        private view returns (uint256 usdPriceAsETH_, uint256 usdPriceAsToken_) {
        uint usdPriceAsETH = getTokenToETHPrice(usdETHPairAddress, amount);
        uint usdPriceAsToken = getETHToTokenPrice(tokenETHPairAddress, usdPriceAsETH);
        return (usdPriceAsETH, usdPriceAsToken);
    }
    function getTokenToETHToUSDPrice(address tokenETHPairAddress, address usdETHPairAddress, uint amount) 
        private view returns (uint256 tokenPriceAsETH_, uint256 tokenPriceAsUSD_) {
        uint tokenPriceAsETH = getTokenToETHPrice(tokenETHPairAddress, amount);
        uint tokenPriceAsUSD = getETHToTokenPrice(usdETHPairAddress, tokenPriceAsETH);
        return (tokenPriceAsETH, tokenPriceAsUSD);
    }
    function getTokenToETHPrice(address pairAddress, uint amount) private view returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint Res0, uint Res1,) = pair.getReserves();
        if (pair.token1() == BNB_ADDRESS) return((amount*Res1)/Res0); // Returns amount of token1 needed to buy token0
        else return((amount*Res0)/Res1);
    }
    function getETHToTokenPrice(address pairAddress, uint amount) private view returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint Res0, uint Res1,) = pair.getReserves();
        if (pair.token1() == BNB_ADDRESS) return((amount*Res0)/Res1); // Returns amount of token0 needed to buy token0
        else return((amount*Res1)/Res0);
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

// *** GET EXTERNAL IN-GAME ***

    // GETTERS ALL
    function EX_GetAll(address addr_) external view returns (uint256[] memory _uint256Status, address[] memory _addressStatus,
                                                             bool[] memory _boolStatus, uint256[] memory _walletDetailsUint256,
                                                             bool[] memory _allLists, uint256[] memory _warriorDetails) {
        return (_EX_StatusUint256(), 
                _EX_StatusAddress(addr_), 
                _EX_StatusBool(),
                _EX_WalletDetailsUint256(addr_),
                _EX_AllLists(addr_, 0),
                _EX_AllWarriorDetails(IWarrior721(eternalStorage.GET_GLOBAL_DATA_ADDRESS("WARRIOR721_ADDRESS")).G_AllOwnerTokenIds(addr_)));
    }

    /*
        0  - ONE_FIGHT_COST
        1  - MAX_FIGHT_LIMIT
        2  - MAX_FIGHTS_AT_ONCE
        3  - MAX_HERO_PERSONA
        4  - MAX_HERO_RARITY
        5  - WITHDRAW_COIN_FEE
        6  - WITHDRAW_FEE_DAILY_DROP
        7  - WARRIOR_MINT_COST_ORACLE
        8  - WARRIOR_MINT_COST_STABLE
        9  - WARRIOR_COMBAT_REWARD_ORACLE
        10 - WARRIOR_COMBAT_REWARD_STABLE
        11 - DISCOUNT10
        12 - ETH_WITHDRAW_FEE
        13 - SWAP_FEE_ON_WITHDRAW
        14 - WITHDRAW_COOLDOWN
        15 - REFERENCE_FEE
        16 - AOW to USD Price
        17 - USD to AOW Price
        18 - Minting cost as AOW
        19 - GAME_VERSION
        20 - DISCOUNT5
        21 - AREA_UPGRADE_COST
        22 - AREA_UPGRADE_LEVEL
    */
    function _EX_StatusUint256() private view returns (uint256[] memory) {
        uint256[] memory status = new uint256[](23);   
        (status[0], status[1], status[2], status[3]) = (eternalStorage.GET_GLOBAL_DATA_UINT256(   "ONE_FIGHT_COST", 
                                                                                                  "MAX_FIGHT_LIMIT", 
                                                                                                  "MAX_FIGHTS_AT_ONCE", 
                                                                                                  "MAX_HERO_PERSONA"));
        (status[4], status[5], status[6], status[7]) = eternalStorage.GET_GLOBAL_DATA_UINT256(    "MAX_HERO_RARITY",
                                                                                                  "WITHDRAW_COIN_FEE",
                                                                                                  "WITHDRAW_FEE_DAILY_DROP",
                                                                                                  "WARRIOR_MINT_COST_ORACLE");
        (status[8], status[9], status[10], status[11]) = eternalStorage.GET_GLOBAL_DATA_UINT256(  "WARRIOR_MINT_COST_STABLE",
                                                                                                  "WARRIOR_COMBAT_REWARD_ORACLE",
                                                                                                  "WARRIOR_COMBAT_REWARD_STABLE",
                                                                                                  "DISCOUNT10");   
        (status[12], status[13], status[14], status[15]) = eternalStorage.GET_GLOBAL_DATA_UINT256("ETH_WITHDRAW_FEE",
                                                                                                  "SWAP_FEE_ON_WITHDRAW",
                                                                                                  "WITHDRAW_COOLDOWN",
                                                                                                  "REFERENCE_FEE");
        // 0 AOWToBUSDPrice, 1 BUSDToAOWPrice, 2 mint cost (oracle or stable)
        (address tokenBnbPairAddress, address busdBnbPairAddress) = eternalStorage.GET_GLOBAL_DATA_ADDRESS("AOW_PAIR_ADDRESS", "BUSD_BNB_PAIR_ADDRESS");
        status[16] = getTokenToUSDPrice(tokenBnbPairAddress, busdBnbPairAddress, 10 ** 18);
        status[17] = getUSDToTokenPrice(tokenBnbPairAddress, busdBnbPairAddress, 10 ** 18);
        //if (eternalStorage.GET_GLOBAL_DATA_BOOL("ORACLE_ENABLED")) // Busd Amount -> Converts to Bnb Amount -> Converts to Aow Amount
        status[18] = getETHToTokenPrice(tokenBnbPairAddress, getTokenToETHPrice(busdBnbPairAddress, status[7]));
        //else 
            //status[18] = status[8];
        (status[19], status[20], status[21], status[22])  = eternalStorage.GET_GLOBAL_DATA_UINT256("GAME_VERSION", "DISCOUNT5", "AREA_UPGRADE_COST", "AREA_UPGRADE_LEVEL");
        return status;
    }

    /*
        0  - UI_ADDRESS
        1  - WARRIOR721_ADDRESS
        2  - AOW_ADDRESS
        3  - AOW_PAIR_ADDRESS
        4  - BUSD_BNB_PAIR_ADDRESS
        5  - BANK_ADDRESS
        6  - ACTIONS_ADDRESS
        7  - FIGHT_ADDRESS
        8  - MINT_ADDRESS
        9  - FEECOLLECTOR_ADDRESS
        10 - BURN_ADDRESS
        11 - ROUTER_ADDRESS
        12 - Account reference address
        13 - Eternal storage owner address
    */
    function _EX_StatusAddress(address addr_) private view returns (address[] memory) {
        address[] memory status = new address[](14);   
        (status[0], status[1], status[2], status[3]) = (eternalStorage.GET_GLOBAL_DATA_ADDRESS( "UI_ADDRESS", 
                                                                                                "WARRIOR721_ADDRESS", 
                                                                                                "AOW_ADDRESS",
                                                                                                "AOW_PAIR_ADDRESS"));
        (status[4], status[5], status[6], status[7]) = eternalStorage.GET_GLOBAL_DATA_ADDRESS(  "BUSD_BNB_PAIR_ADDRESS",
                                                                                                "BANK_ADDRESS",
                                                                                                "ACTIONS_ADDRESS",
                                                                                                "FIGHT_ADDRESS");
        (status[8], status[9], status[10], status[11]) = eternalStorage.GET_GLOBAL_DATA_ADDRESS("MINT_ADDRESS",                                                                                       
                                                                                                "FEECOLLECTOR_ADDRESS",
                                                                                                "BURN_ADDRESS",
                                                                                                "ROUTER_ADDRESS");      
        (status[12], status[13]) = (eternalStorage.GET_WORD_DATA_ADDRESS(_stringToBytes32(string(abi.encodePacked(addr_))), 0, 0), eternalStorage.owner());                                                                                                                                         
        return (status);
    }

    /*
        0  - FORCE_STOP
        1  - GAME_ENABLED
        2  - CAN_TRANSFER
        3  - CAN_MINT_USER
        4  - CAN_MINT_WHITELIST
        5  - RESET_FIGHTS_AFTER_TRANSFER
        6  - CAN_COMBAT_FIGHT
        7  - CAN_WITHDRAW_COIN
        8  - SPEND_FIGHTS_AT_ONCE
        9  - ORACLE_ENABLED
        10 - BETATEST_ENABLED
        11 - REFERENCE_ENABLED
        12 - PROMOWALLET_ENABLED
    */
    function _EX_StatusBool() private view returns (bool[] memory) {
        bool[] memory status = new bool[](13);   
        (status[0], status[1], status[2], status[3]) = (eternalStorage.GET_GLOBAL_DATA_BOOL( "FORCE_STOP", 
                                                                                             "GAME_ENABLED", 
                                                                                             "CAN_TRANSFER", 
                                                                                             "CAN_MINT_USER"));
        (status[4], status[5], status[6], status[7]) = eternalStorage.GET_GLOBAL_DATA_BOOL(  "CAN_MINT_WHITELIST",
                                                                                             "RESET_FIGHTS_AFTER_TRANSFER",
                                                                                             "CAN_COMBAT_FIGHT",
                                                                                             "CAN_WITHDRAW_COIN");
        (status[8], status[9], status[10], status[11]) = eternalStorage.GET_GLOBAL_DATA_BOOL("SPEND_FIGHTS_AT_ONCE",
                                                                                             "ORACLE_ENABLED",
                                                                                             "BETATEST_ENABLED",
                                                                                             "REFERENCE_ENABLED"); 
        (status[12]) = eternalStorage.GET_GLOBAL_DATA_BOOL("PROMOWALLET_ENABLED");
        return (status);
    }
    
    /*
        0  - heroPersona_
        1  - heroRarity_
        2  - heroLevel_
        3  - heroExp_
        4  - ownedAbilityAmount_
        5  - ability1_
        6  - ability2_
        7  - abilitiesRevealed_
        8  - heroExpBar_
        9  - energy_
        10 - loseStreak_
        11 - warriorId_
        12 - enemyRarity0_
        13 - enemyRarity1_
        14 - enemyRarity2_
        15 - enemyRarity3_
        16 - enemyPersona0_
        17 - enemyPersona1_
        18 - enemyPersona2_
        19 - enemyPersona3_
        20 - createdTime_
        21 - lastFightedTime_
        22 - winStreak_
        23 - areaLevel_
    */
    function _EX_AllWarriorDetails(uint256[] memory warriorIds_) private view returns (uint256[] memory) {
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
    function _EX_WarriorDetails(uint256 warriorId_) private view returns (uint256[] memory) {
        uint256[] memory values = new uint256[](oneWarriorArraySize);
        values[11] = warriorId_;
        //(uint256 oneFightCost_, uint256 maxFightLimit_) = eternalStorage.GET_GLOBAL_DATA_UINT256("ONE_FIGHT_COST", "MAX_FIGHT_LIMIT");
        (uint256 enemyRarityIndex_, uint256 enemyPersonaIndex_) = eternalStorage.GET_NFT_DATA_UINT256(warriorId_, 0, 11, 12);
        (values[0], values[1], values[2], values[3]) = eternalStorage.GET_NFT_DATA_UINT256(warriorId_, 0, 1, 2, 3, 4);
        (values[7], values[22], values[10], values[21]) = eternalStorage.GET_NFT_DATA_UINT256(warriorId_, 0, 13, 5, 6, 10);
        (values[20]) = eternalStorage.GET_NFT_DATA_UINT256(warriorId_, 0, 0);
        if (values[7] > 0) {
            (values[4] , values[5], values[6], values[23]) = eternalStorage.GET_NFT_DATA_UINT256(warriorId_, 0, 7, 8, 9, 14);
        }
        values[8] = ((values[2] / 10) + 1) * 1000;
        if (block.timestamp > values[21]) values[9] = block.timestamp - values[21];

        uint256 enemyPersonaMod = eternalStorage.GET_GLOBAL_DATA_UINT256("MAX_ENEMY_PERSONA") + 1;
        uint256[] memory rarityValues = IFight(eternalStorage.GET_GLOBAL_DATA_ADDRESS("FIGHT_ADDRESS")).A_EnemiesAndRarities(enemyRarityIndex_);
        uint256[] memory personaValues = IFight(eternalStorage.GET_GLOBAL_DATA_ADDRESS("FIGHT_ADDRESS")).A_EnemiesAndRarities(enemyPersonaIndex_);
        
        for (uint256 i = 0; i < 4; ++i) {
            values[i + 12] = rarityValues[i];
            values[i + 16] = personaValues[i + 4] % enemyPersonaMod;
        }
        
        return values;
    }

    /*
        0  - aowWalletBalance_
        1  - aowGameBalance_
        2  - lastWithdrawTime_
        3  - Main address refference passed
        4  - Ref address refference passed
        5  - userFeePercentage_
        6  - withdrawalAmountTotal_
        7  - withdrawalAmountAfterFee_
        8  - withdrawCooldownTotal_
        9  - withdrawCooldownLeft_
        10  - AOW Allowance for Mint
        11  - Warrior721 last token id
        12  - Collected coin amount from reference
        13  - Used as ref amount
        14  - aowPromoBalance_
    */
    function _EX_WalletDetailsUint256(address addr_) private view returns (uint256[] memory) {
        uint256[] memory values = new uint256[](15);
        (values[0], values[1]) = (IERC20(eternalStorage.GET_GLOBAL_DATA_ADDRESS("AOW_ADDRESS")).balanceOf(addr_),
                                  eternalStorage.GET_WALLET_DATA_UINT256(addr_, 0, 0));
        (values[2], values[14]) = eternalStorage.GET_WALLET_DATA_UINT256(addr_, 0, 1, 3);
        (values[5], values[8]) = eternalStorage.GET_GLOBAL_DATA_UINT256("WITHDRAW_COIN_FEE", "WITHDRAW_COOLDOWN");
        
        uint256 withdrawTimeDifference = block.timestamp - values[2];
        values[6] = eternalStorage.GET_WALLET_DATA_UINT256(addr_, 0, 0);
        values[7] = values[6];
        if (withdrawTimeDifference < values[8]) {
            values[9] = values[8] - withdrawTimeDifference;
        }
        // Seconds per day
        if (withdrawTimeDifference >= 86400) {
            withdrawTimeDifference /= 86400;
            uint256 totalFeeReduction = withdrawTimeDifference * eternalStorage.GET_GLOBAL_DATA_UINT256("WITHDRAW_FEE_DAILY_DROP");
            if (values[5] >= totalFeeReduction) values[5] -= totalFeeReduction;
            else values[5] = 0;
        }
        values[7] -= (values[7] * values[5]) / 100;
        values[10] = IERC20(eternalStorage.GET_GLOBAL_DATA_ADDRESS("AOW_ADDRESS")).allowance(addr_, eternalStorage.GET_GLOBAL_DATA_ADDRESS("MINT_ADDRESS"));
        values[11] = IWarrior721(eternalStorage.GET_GLOBAL_DATA_ADDRESS("WARRIOR721_ADDRESS")).G_WarriorId();
        values[12] = eternalStorage.GET_WORD_DATA_UINT256(_stringToBytes32(string(abi.encodePacked(addr_))), 0, 0);
        values[13] = eternalStorage.GET_WORD_DATA_UINT256(_stringToBytes32(string(abi.encodePacked(addr_))), 0, 1);
        (values[3], values[4]) = IBank(eternalStorage.GET_GLOBAL_DATA_ADDRESS("BANK_ADDRESS")).IsAcceptedReferenceAddress(addr_);
        return values;
    }
    function _EX_AllLists(address addr_, uint256 maxIndex) private view returns (bool[] memory) {
        if (maxIndex == 0) maxIndex = 10;
        bool[] memory values_ = new bool[](maxIndex);
        for (uint256 i = 0; i < maxIndex; ++i) {
            values_[i] =  eternalStorage.GET_WALLET_DATA_BOOL(addr_, 0, i);
        }
        return values_;
    }
}