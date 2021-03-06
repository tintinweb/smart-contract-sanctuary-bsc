//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;

import './lib/token/ERC20/IERC20.sol';
import './lib/token/ERC721/IERC721.sol';
import './lib/token/ERC1155/IERC1155.sol';

contract TransferProxy {
  event operatorChanged(address indexed from, address indexed to);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  address public owner;
  address public operator;

  constructor() {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */

  modifier onlyOwner() {
    require(owner == msg.sender, 'Ownable: caller is not the owner');
    _;
  }

  modifier onlyOperator() {
    require(
      operator == msg.sender,
      'OperatorRole: caller does not have the Operator role'
    );
    _;
  }

  /** change the OperatorRole from contract creator address to trade contractaddress
            @param _operator :trade address 
        */

  function changeOperator(address _operator) public onlyOwner returns (bool) {
    require(
      _operator != address(0),
      'Operator: new operator is the zero address'
    );
    operator = _operator;
    emit operatorChanged(address(0), operator);
    return true;
  }

  /** change the Ownership from current owner to newOwner address
        @param newOwner : newOwner address */

  function ownerTransfership(address newOwner) public onlyOwner returns (bool) {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    owner = newOwner;
    emit OwnershipTransferred(owner, newOwner);
    return true;
  }

  function erc721safeTransferFrom(
    IERC721 token,
    address from,
    address to,
    uint256 tokenId
  ) external onlyOperator {
    token.safeTransferFrom(from, to, tokenId);
  }

  function erc1155safeTransferFrom(
    IERC1155 token,
    address from,
    address to,
    uint256 tokenId,
    uint256 value,
    bytes calldata data
  ) external onlyOperator {
    token.safeTransferFrom(from, to, tokenId, value, data);
  }

  function erc20safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) external onlyOperator {
    require(token.transferFrom(from, to, value), 'failure while transferring');
  }
}

// SPDX-License-Identifier:UNLICENSED
pragma solidity 0.7.6;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier:UNLICENSED
pragma solidity 0.7.6;

import '../../introspection/ERC165.sol';

interface IERC721 is IERC165 {
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed tokenId
  );

  event Approval(
    address indexed owner,
    address indexed approved,
    uint256 indexed tokenId
  );

  event ApprovalForAll(
    address indexed owner,
    address indexed operator,
    bool approved
  );

  event URI(string value, uint256 indexed id);

  event tokenBaseURI(string value);

  function balanceOf(address owner) external view returns (uint256 balance);

  function royaltyFee(uint256 tokenId) external view returns (uint256);

  function getCreator(uint256 tokenId) external view returns (address);

  function ownerOf(uint256 tokenId) external view returns (address owner);

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

  function approve(address to, uint256 tokenId) external;

  function getApproved(uint256 tokenId)
    external
    view
    returns (address operator);

  function setApprovalForAll(address operator, bool _approved) external;

  function isApprovedForAll(address owner, address operator)
    external
    view
    returns (bool);

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes calldata data
  ) external;
}

// SPDX-License-Identifier:UNLICENSED
pragma solidity 0.7.6;

import '../../introspection/ERC165.sol';

interface IERC1155 is IERC165 {
  event TransferSingle(
    address indexed operator,
    address indexed from,
    address indexed to,
    uint256 id,
    uint256 value
  );
  event TransferBatch(
    address indexed operator,
    address indexed from,
    address indexed to,
    uint256[] ids,
    uint256[] values
  );
  event ApprovalForAll(
    address indexed account,
    address indexed operator,
    bool approved
  );
  event URI(string value, uint256 indexed id);
  event tokenBaseURI(string value);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function balanceOf(address account, uint256 id)
    external
    view
    returns (uint256);

  function royaltyFee(uint256 tokenId) external view returns (uint256);

  function getCreator(uint256 tokenId) external view returns (address);

  function tokenURI(uint256 tokenId) external view returns (string memory);

  function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
    external
    view
    returns (uint256[] memory);

  function setApprovalForAll(address operator, bool approved) external;

  function isApprovedForAll(address account, address operator)
    external
    view
    returns (bool);

  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes calldata data
  ) external;

  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] calldata ids,
    uint256[] calldata amounts,
    bytes calldata data
  ) external;
}

// SPDX-License-Identifier:UNLICENSED
pragma solidity 0.7.6;

import './IERC165.sol';

abstract contract ERC165 is IERC165 {
  bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

  mapping(bytes4 => bool) private _supportedInterfaces;

  constructor() {
    _registerInterface(_INTERFACE_ID_ERC165);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return _supportedInterfaces[interfaceId];
  }

  function _registerInterface(bytes4 interfaceId) internal virtual {
    require(interfaceId != 0xffffffff, 'ERC165: invalid interface id');
    _supportedInterfaces[interfaceId] = true;
  }
}

// SPDX-License-Identifier:UNLICENSED
pragma solidity 0.7.6;

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