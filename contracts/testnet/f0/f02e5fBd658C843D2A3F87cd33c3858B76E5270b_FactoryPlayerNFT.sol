// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./file/SafeMath.sol";
import "./file/Ownable.sol";
import "./file/IERC721.sol";
import "./file/IERC20.sol";

interface IERC721GameNFT is IERC721 {
    //function mintWithCount(address to) external;
    function mintWithCount(address to) external returns (uint256);

    function mintBatch(address to, uint256[] memory tokenIds) external;

    function totalSupply() external view returns (uint256);
}

contract FactoryPlayerNFT is Ownable {
    using SafeMath for uint256;
    // NFT contract
    IERC721GameNFT public erc721;
    IERC20 public erc20;
    bool public publicMintAllowed;

    // Number of total NFT Minted
    uint256 public totalMinted;
    // Maximum number NFTs can be minted
    uint256 public totalNumberNFT;

    struct Player {
        string name;
        uint256 price;
        string rarity;
    }

    Player[] public playerList;

    event TokenMinted(
        address contractNFT,
        address contractFactory,
        address to,
        uint256 indexed tokenId,
        string name,
        uint256 price,
        string rarity
    );

    constructor(address _erc721, address _erc20) {
        erc721 = IERC721GameNFT(_erc721);
        erc20 = IERC20(_erc20);
        totalNumberNFT = 500;
        //push info nft
        playerList.push(Player("Anselm", 10 * 10**18, "common"));
        playerList.push(Player("Azaria", 11 * 10**18, "common"));
        playerList.push(Player("Basil", 12 * 10**18, "common"));
        playerList.push(Player("Benedict", 13 * 10**18, "common"));
        playerList.push(Player("Carwyn", 14 * 10**18, "common"));
        playerList.push(Player("Clitus", 16 * 10**18, "uncommon"));
        playerList.push(Player("Cuthbert", 17 * 10**18, "uncommon"));
        playerList.push(Player("Dai", 18 * 10**18, "uncommon"));
        playerList.push(Player("Darius", 19 * 10**18, "uncommon"));
        playerList.push(Player("Dominic", 20 * 10**18, "uncommon"));
        playerList.push(Player("Edsel", 23 * 10**18, "rare"));
        playerList.push(Player("Elmer", 24 * 10**18, "rare"));
        playerList.push(Player("Ethelbert", 25 * 10**18, "rare"));
        playerList.push(Player("Eugene", 26 * 10**18, "rare"));
        playerList.push(Player("Galvin", 27 * 10**18, "rare"));
        playerList.push(Player("Gwyn", 30 * 10**18, "legendary"));
        playerList.push(Player("Jethro", 31 * 10**18, "legendary"));
        playerList.push(Player("Magnus", 32 * 10**18, "legendary"));
        playerList.push(Player("Maximilian", 33 * 10**18, "legendary"));
        playerList.push(Player("Nolan", 34 * 10**18, "legendary"));
    }

    function setNewERC(address _erc721, address _erc20) external onlyOwner {
        erc721 = IERC721GameNFT(_erc721);
        erc20 = IERC20(_erc20);
    }

    function setTotalNumberNFT(uint256 _number) external onlyOwner {
        totalNumberNFT = _number;
    }

    function addNewPlayer(
        string memory _name,
        uint256 _price,
        string memory _rarity
    ) external onlyOwner {
        playerList.push(Player(_name, _price, _rarity));
    }

    function editNewPlayer(
        uint256 index,
        string memory _name,
        uint256 _price,
        string memory _rarity
    ) external onlyOwner {
        playerList[index] = Player(_name, _price, _rarity);
    }

    function getInfoNftFromIndex(uint256 index)
        external
        view
        returns (Player memory)
    {
        return playerList[index];
    }

    function mintToWithCount(address to, uint256 index) external {
        require(index < playerList.length, "Run out of NFT");
        require(totalMinted < totalNumberNFT, "Run out of NFT");
        
        totalMinted = totalMinted.add(1);
        uint256 tokenId = erc721.mintWithCount(to);
        erc20.transfer(address(this), playerList[index].price);
        emit TokenMinted(
            address(erc721),
            address(this),
            to,
            tokenId,
            playerList[index].name,
            playerList[index].price,
            playerList[index].rarity
        );
    }

    receive() external payable {}

    /**
     * @dev function to allow user mint items
     */
    function allowPublicMint() public onlyOwner {
        publicMintAllowed = true;
    }

    /**
     * @dev function to unallow user mint items
     */
    function unAllowPublicMint() public onlyOwner {
        publicMintAllowed = false;
    }

    function flushBNB(address payable _to, uint256 _amount) external onlyOwner {
        _to.transfer(_amount);
    }

    function rescueStuckErc20(address _token, address _receive)
        external
        onlyOwner
    {
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_receive, _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 * not same
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
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
   * - Subtraction cannot overflow.
   *
   * _Available since v2.4.0._
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
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
   * - The divisor cannot be zero.
   *
   * _Available since v2.4.0._
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Context.sol";

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC165.sol";

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
pragma solidity ^0.8.4;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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