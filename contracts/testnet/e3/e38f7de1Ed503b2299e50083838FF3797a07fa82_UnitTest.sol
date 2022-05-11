/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// File: contracts/erc/erc165/IERC165Upgradeable.sol


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
interface IERC165Upgradeable {
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

// File: contracts/erc/erc1155/IERC1155Upgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// File: contracts/core/interface/ITableclothAwardsPool.sol



pragma solidity ^0.8.0;

/**
 * @dev This is the interface about acclocation of chitoken to tablecloth holders
 */
interface ITableclothAwardsPool {

    event AddAwards(uint128 indexed awardsType, uint128 indexed tableclothType, uint256 chiAmount);
    event Withdraw(uint256 indexed tableclothId, address indexed to, uint256 chiAmount);

    function AWARDS_TYPE_BATTLE() external view returns(uint128);
    function AWARDS_TYPE_MERGE() external view returns(uint128);

    /**
     * @dev Add awards in pool.
     * only permit sandwith or qualifying role
     */
    function addAwards(
        address sender,
        uint128 awardsType,
        uint128 tableclothType,
        uint256 chiAmount
    ) external;

    /**
     * @dev Add awards in pool.
     * only permit sandwith or qualifying role
     */
    function addAwards(
        address sender,
        uint128 awardsType,
        uint128[] memory tableclothTypes,
        uint256 chiAmount
    ) external;

    /**
     * @dev Get the token's unaccalimed awards amount in pool.
     * only amount in pool of tokentype can you get
     */
    function getUnaccalimedAmount(uint256 tableclothId) external view returns(uint256);

    function getUnaccalimedAmountByType(uint128 tableclothType) external view returns(uint256 amounts);

    /**
     * @dev Get the pool's historical total awards amount in pool.
     */
    function getPoolTotalAmount(uint128 tableclothType) external view returns(uint256);


    /**
     * @dev Withdraw the token's unaccalimed awards amount in pool.
     * only amount in pool of tokentype can you withdraw
     */
    function withdraw(uint256 tableclothId) external;

    /**
     * @dev Withdraw the token's unaccalimed awards amount in pool.
     * only amount in pool of tokentype can you withdraw
     * This funtion will withdraw all awards of table cloth you hold which typeid = tableclothType
     */
    function withdrawByType(uint128 tableclothType) external;

}
// File: contracts/core/interface/IERC20Token.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Token {
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
// File: contracts/core/interface/ITableclothERC1155.sol


pragma solidity ^0.8.0;

interface ITableclothERC1155 {

    function buyTablecloth(
        uint256 cswAmount,
        uint128 typeId
    )  external;

    /**
     * @dev Return details of Tablecloth 
     *
     * Requirements:
     * - tokenId
     */
    function getTablecloth(uint256 _id) external view returns (
        uint id,
        uint256 maximum,
        uint256 soldQuantity,
        uint256 price,
        bool[5] memory _attr,
        uint128 created,
        uint128 typeId,
        string memory tableclothName,
        string memory tableclothDescribe
    );

    /**
     * @dev Return tablecloth type of token 
     *
     * Requirements:
     * - tokenId
     */
    function getTableclothType(uint256 _id) external view returns(uint128);


    /**
     *  @dev Get tablecloth type details by type id
     */
    function getTypeDetails(uint128 typeId) external view returns (
        string memory tableclothName,
        string memory tableclothDescribe,
        uint256 tableclothPrice,
        uint256 maximum,
        uint256 soldQuantity,
        bool[5] memory attr,
        uint16 attrnum,
        uint256 totalAwards
    );

    /**
     * @dev Get the enemy of attributes
     *
     * Requirements:
     * - attr >= 1 and <= 5
     */
    function getAttributesEnemy(uint16 attr) external view returns(uint16);

    /**
     * @dev Get the token id list of holder
     *
     */
    function getHoldArray(uint128 typeId, address holder) external view returns(uint256[] memory);
}

// File: contracts/core/interface/ISandwichesERC1155.sol



pragma solidity ^0.8.0;

/**
 * @dev 
 */
interface ISandwichesERC1155 {

    /**
     * @dev Create new sandwich heroes by ingredients, tablecloths, and equipments.
     *
     * The length of ingredient Tokens required for merging must be 4,
     * The length of equipment Tokens required for merging must be greater than 3 and less than 4.
     *
     * CHI coins must be paid as a handling fee when merging, 
     * and CHI coins will be equally distributed to the holders of the tablecloth shares.
     */
    function merge(
        uint256 chiAmount,
        uint256[] memory ingredients,
        uint256[] memory equipments, 
        uint128 tableclothType,
        string memory _name,
        string memory _describe
    ) external;

    function testCreate(uint128 tableclothType, string memory _name,
        string memory _describe) external;


    /**
     *  @dev Get sandwich details by token id.
     */
    function getSandwich(uint256 _id) external view returns (
        uint id,
        string memory name,
        string memory describe,
        uint256 aggressivity,
        uint256 defensive,
        uint256 healthPoint,
        bool[5] memory attributes,
        uint256 created,
        uint16 attrnum
    );

    /**
     *  @dev Get sandwich parts by token id.
     */
    function getSandwichParts(uint256 _id) external view returns (
        uint256[] memory ingredients,
        uint256[] memory equipments
    );

}
// File: contracts/test/UnitTest.sol


pragma solidity ^0.8.0;






contract UnitTest{
    ITableclothERC1155 private tablecloth;
    ISandwichesERC1155 private sandwich;
    ITableclothAwardsPool private pool;
    IERC20Token private chiCoin;
    IERC20Token private cswToken;

    address public _owner;

    constructor(){
        _owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function setAddress(address _tablecloth, address _sandwich, address _pool, address _chiCoin, address _cswToken) external onlyOwner{
        tablecloth = ITableclothERC1155(_tablecloth);
        sandwich = ISandwichesERC1155(_sandwich);
        pool = ITableclothAwardsPool(_pool);
        chiCoin = IERC20Token(_chiCoin);
        cswToken = IERC20Token(_cswToken);
    }

    function buyTablecloth(uint128 typeId) external onlyOwner{
        (,,uint256 price,,,,,) = tablecloth.getTypeDetails(typeId);
        if(price > 0){
            cswToken.approve(address(tablecloth), price);
            tablecloth.buyTablecloth(price, typeId);
        }
    }

    function createSandwich(uint128 typeId, string memory _name, string memory _describe) external onlyOwner{
        chiCoin.approve(address(pool), 20000 ether);
        sandwich.testCreate(typeId, _name, _describe);
        (,,uint256 price,,,,,) = tablecloth.getTypeDetails(typeId);
        if(price > 0){
            tablecloth.buyTablecloth(price, typeId);
        }
    }

    function getUnaccalimedAmountByType(uint128 tableclothType) external view returns(uint256 amounts){
        return pool.getUnaccalimedAmountByType(tableclothType);
    }

    function withdrawByType(uint128 tableclothType) external onlyOwner{
        pool.withdrawByType(tableclothType);
     }

    function withdrawChiAndCsw() external onlyOwner{
        cswToken.transfer(msg.sender, cswToken.balanceOf(address(this)));
        chiCoin.transfer(msg.sender, chiCoin.balanceOf(address(this)));
    }

    function withdrawTableCloth(uint256 id) external onlyOwner{
        IERC1155Upgradeable(address(tablecloth)).safeTransferFrom(address(this), msg.sender, id, 1, "");
    }

    function withdrawSandwich(uint256 id) external onlyOwner{
        IERC1155Upgradeable(address(sandwich)).safeTransferFrom(address(this), msg.sender, id, 1, "");
    }

}