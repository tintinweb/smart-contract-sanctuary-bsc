/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.8;

interface ServiceInterface {
  function claimingFeeNumerator() external view returns(uint256);

  function claimingFeeDenominator() external view returns(uint256);

  function doesNodeExist(address entity, uint128 nodeId) external view returns (bool);

  function getNodeId(address entity, uint128 nodeId) external view returns (bytes memory);

  function getReward(address entity, uint128 nodeId) external view returns (uint256);

  function getRewardByBlock(address entity, uint128 nodeId, uint256 blockNumber) external view returns (uint256);

  function getTraunch(address entity) external view returns (uint256);

  function isEntityActive(address entity) external view returns (bool);

  function claim(uint128 nodeId, uint256 blockNumber, bool toStrongPool) external payable;
}
interface IERC1155Preset {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

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
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

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
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

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
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    /**
     * @dev Creates `amount` new tokens for `to`, of token type `id`.
     *
     * See {ERC1155-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 id, uint256 amount, bytes memory data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] variant of {mint}.
     */
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;

    function getOwnerIdByIndex(address owner, uint256 index) external view returns (uint256);

    function getOwnerIdIndex(address owner, uint256 id) external view returns (uint256);
}
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract StrongNFTBonusDeprecated is Context {

  using SafeMath for uint256;

  event Staked(address indexed sender, uint256 tokenId, uint128 nodeId, uint256 block);
  event Unstaked(address indexed sender, uint256 tokenId, uint128 nodeId, uint256 block);

  ServiceInterface public service;
  IERC1155Preset public nft;

  bool public initDone;

  address public serviceAdmin;
  address public superAdmin;

  string[] public nftBonusNames;
  mapping(string => uint256) public nftBonusLowerBound;
  mapping(string => uint256) public nftBonusUpperBound;
  mapping(string => uint256) public nftBonusValue;

  mapping(uint256 => uint256) public nftIdStakedForNodeId;
  mapping(address => mapping(uint128 => uint256)) public entityNodeStakedNftId;
  mapping(address => mapping(uint128 => uint256)) public entityNodeStakedNftBlock;

  bool public disabled;

  function init(address serviceContract, address nftContract, address serviceAdminAddress, address superAdminAddress) public {
    require(initDone == false, "init done");

    serviceAdmin = serviceAdminAddress;
    superAdmin = superAdminAddress;
    service = ServiceInterface(serviceContract);
    nft = IERC1155Preset(nftContract);
    initDone = true;
  }

  function isNftStaked(uint256 _tokenId) public view returns (bool) {
    return nftIdStakedForNodeId[_tokenId] != 0;
  }

  function getNftStakedForNodeId(uint256 _tokenId) public view returns (uint256) {
    return nftIdStakedForNodeId[_tokenId];
  }

  function getStakedNftId(address _entity, uint128 _nodeId) public view returns (uint256) {
    return entityNodeStakedNftId[_entity][_nodeId];
  }

  function getStakedNftBlock(address _entity, uint128 _nodeId) public view returns (uint256) {
    return entityNodeStakedNftBlock[_entity][_nodeId];
  }

  function getBonus(address _entity, uint128 _nodeId, uint256 _fromBlock, uint256 _toBlock) public view returns (uint256) {
    uint256 nftId = entityNodeStakedNftId[_entity][_nodeId];

    if (nftId == 0) return 0;
    if (nftIdStakedForNodeId[nftId] == 0) return 0;
    if (nftId < nftBonusLowerBound["BRONZE"]) return 0;
    if (nftId > nftBonusUpperBound["BRONZE"]) return 0;
    if (nft.balanceOf(_entity, nftId) == 0) return 0;
    if (_fromBlock >= _toBlock) return 0;

    uint256 stakedAtBlock = entityNodeStakedNftBlock[_entity][_nodeId];

    if (stakedAtBlock == 0) return 0;

    uint256 startFromBlock = stakedAtBlock > _fromBlock ? stakedAtBlock : _fromBlock;

    if (startFromBlock >= _toBlock) return 0;

    return _toBlock.sub(startFromBlock).mul(nftBonusValue["BRONZE"]);
  }

  function stakeNFT(uint256 _tokenId, uint128 _nodeId) public payable {
    require(disabled == false, "disabled");
    require(nft.balanceOf(_msgSender(), _tokenId) != 0, "not enough");
    require(_tokenId >= nftBonusLowerBound["BRONZE"] && _tokenId <= nftBonusUpperBound["BRONZE"], "not eligible");
    require(nftIdStakedForNodeId[_tokenId] == 0, "already staked");
    require(service.doesNodeExist(_msgSender(), _nodeId), "node doesnt exist");

    nftIdStakedForNodeId[_tokenId] = _nodeId;
    entityNodeStakedNftId[_msgSender()][_nodeId] = _tokenId;
    entityNodeStakedNftBlock[_msgSender()][_nodeId] = block.number;

    emit Staked(msg.sender, _tokenId, _nodeId, block.number);
  }

  function unStakeNFT(uint256 _tokenId, uint256 _blockNumber) public {
    uint128 nodeId = uint128(nftIdStakedForNodeId[_tokenId]);

    require(entityNodeStakedNftId[_msgSender()][nodeId] != 0, "not staked");

    nftIdStakedForNodeId[_tokenId] = 0;
    entityNodeStakedNftId[_msgSender()][nodeId] = 0;
    entityNodeStakedNftBlock[_msgSender()][nodeId] = 0;

    emit Unstaked(msg.sender, _tokenId, nodeId, _blockNumber);
  }

  function unStakeNFTAdmin(address _entity, uint256 _tokenId, uint256 _blockNumber) public {
    require(msg.sender == serviceAdmin || msg.sender == superAdmin, "not admin");

    uint128 nodeId = uint128(nftIdStakedForNodeId[_tokenId]);

    nftIdStakedForNodeId[_tokenId] = 0;
    entityNodeStakedNftId[_entity][nodeId] = 0;

    emit Unstaked(_entity, _tokenId, nodeId, _blockNumber);
  }

  function updateBonus(string memory _name, uint256 _lowerBound, uint256 _upperBound, uint256 _value) public {
    require(msg.sender == serviceAdmin || msg.sender == superAdmin, "not admin");

    bool alreadyExit = false;
    for (uint i = 0; i < nftBonusNames.length; i++) {
      if (keccak256(abi.encode(nftBonusNames[i])) == keccak256(abi.encode(_name))) {
        alreadyExit = true;
      }
    }

    if (!alreadyExit) {
      nftBonusNames.push(_name);
    }

    nftBonusLowerBound[_name] = _lowerBound;
    nftBonusUpperBound[_name] = _upperBound;
    nftBonusValue[_name] = _value;
  }

  function updateContracts(address serviceContract, address nftContract) public {
    require(msg.sender == superAdmin, "not admin");
    service = ServiceInterface(serviceContract);
    nft = IERC1155Preset(nftContract);
  }

  function updateServiceAdmin(address newServiceAdmin) public {
    require(msg.sender == superAdmin, "not admin");
    serviceAdmin = newServiceAdmin;
  }

  function updateDisabled(bool _disabled) public {
    require(msg.sender == serviceAdmin || msg.sender == superAdmin, "not admin");
    disabled = _disabled;
  }
}