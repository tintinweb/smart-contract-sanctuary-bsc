/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// Sources flattened with hardhat v2.9.9 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/access/[email protected]


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/utils/math/[email protected]


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]


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


// File @openzeppelin/contracts/utils/introspection/[email protected]


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


// File @openzeppelin/contracts/token/ERC721/[email protected]


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


// File contracts/interfaces/IABep20Interface.sol


pragma solidity ^0.8.0;

interface IABep20Interface {
  function mint(uint256 mintAmount) external returns (uint256);

  function balanceOf(address account) external view returns (uint256);
}


// File contracts/interfaces/IAnnexRouter01.sol


pragma solidity >=0.6.2;

interface IAnnexRouter01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}


// File contracts/interfaces/IAnnexRouter02.sol


pragma solidity >=0.6.2;

interface IAnnexRouter02 is IAnnexRouter01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}


// File contracts/libraries/IdToAddressBiMap.sol


pragma solidity >=0.6.2;

library IdToAddressBiMap {
  struct Data {
    mapping(uint64 => address) idToAddress;
    mapping(address => uint64) addressToId;
  }

  function hasId(Data storage self, uint64 id) internal view returns (bool) {
    return self.idToAddress[id + 1] != address(0);
  }

  function hasAddress(Data storage self, address addr) internal view returns (bool) {
    return self.addressToId[addr] != 0;
  }

  function getAddressAt(Data storage self, uint64 id) internal view returns (address) {
    require(hasId(self, id), "INVALID_ID");
    return self.idToAddress[id + 1];
  }

  function getId(Data storage self, address addr) internal view returns (uint64) {
    require(hasAddress(self, addr), "INVALID_ADDRESS");
    return self.addressToId[addr] - 1;
  }

  function insert(
    Data storage self,
    uint64 id,
    address addr
  ) internal returns (bool) {
    require(addr != address(0), "ERROR_ZERO");
    // require(id != uint64(-1), "ERROR_64");
    // Ensure bijectivity of the mappings
    if (self.addressToId[addr] != 0 || self.idToAddress[id + 1] != address(0)) {
      return false;
    }
    self.idToAddress[id + 1] = addr;
    self.addressToId[addr] = id + 1;
    return true;
  }
}


// File contracts/libraries/SafeCast.sol


pragma solidity >=0.6.2;

library SafeCast {
  function toUint96(uint256 value) internal pure returns (uint96) {
    require(value < 2**96, "SafeCast: value doesn't fit in 96 bits");
    return uint96(value);
  }

  function toUint64(uint256 value) internal pure returns (uint64) {
    require(value < 2**64, "SafeCast: value doesn't fit in 64 bits");
    return uint64(value);
  }
}


// File contracts/AnnexIronNFTVault.sol


pragma solidity ^0.8.9;








contract AnnexIronNFTVault is Ownable {
  using SafeMath for uint64;
  using SafeMath for uint96;
  using SafeMath for uint256;
  using SafeCast for uint256;
  using IdToAddressBiMap for IdToAddressBiMap.Data;
  bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

  IERC721 public annexNFT;
  IERC20 public aNN;
  IABep20Interface public aANN;
  IERC20 public tusd;
  IAnnexRouter02 public annexRouter;

  uint256 public rewardsPerSecond;
  uint256 public totalStakedTokens;
  uint256 public totalRewards;
  uint256 public totalRewardsForCompound;
  uint256 private totalRewardsForCompoundReleased;
  uint256 private avalibleCompoundBalanceaANN;
  uint256 private _daySecond = 86400;
  uint256 public unstakeInterval;
  uint256 public claimInterval;
  IdToAddressBiMap.Data private registeredUsers;
  uint64 public numUsers;
  

  struct Staker {
    uint256[] tokenIds;
    mapping(uint256 => uint256) tokenIndex;
    uint256 rewardsEarned;
    uint256 aANNrewardsEarned;
    uint256 lastClaimedAt;
    bool isAutoCompound;
  }
  
  mapping(uint256 => Staker) public stakers;
  mapping(uint256 => address) public tokenOwner;

  event Staked(address owner, uint256 amount);
  event UnStaked(address owner, uint256 tokenid);
  event Claim(address owner, uint256 amount);
  event CompoundStatus(address owner, bool status);
  event UserRegistration(address indexed user, uint64 userId);
  event NewUser(uint64 indexed userId, address indexed userAddress);

  constructor() {
    uint256 rewardsAllocationTUSD = 1000 ether;
    rewardsPerSecond = (rewardsAllocationTUSD).div(_daySecond);
    annexNFT = IERC721(0xB103D5166CA024Aa167A93Ca88f713ec6998B38A); // ANNEX NFT
    annexRouter = IAnnexRouter02(0x81A2E0Bdb480aFa026E10F15aB2c536c2F54433D); // ANNEX ROUTER
    aNN = IERC20(0xB8d4DEBc77fE2D412f9bA5B22B33A8f6c4d9aE1e); // ANNEX TOKEN
    aANN = IABep20Interface(0x15EdC067884b969a6BE23605499f5e6fc114017e); // ANNEX A-TOKEN
    tusd = IERC20(0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47); // TUSD
    unstakeInterval = 0;
    claimInterval = 0;
  }

  function stake(uint256 tokenId) external {
    _stake(msg.sender, tokenId);
  }

  function stakeBatch(uint256[] memory tokenIds) external {
    for (uint256 i = 0; i < tokenIds.length; i++) {
      _stake(msg.sender, tokenIds[i]);
    }
  }

  function _stake(address _user, uint256 _tokenId) public {
    uint64 userId = getUserId(_user);
    require(annexNFT.ownerOf(_tokenId) == _user, "NOT ONWER OF NFT");
    Staker storage staker = stakers[userId];
    _updateReward(userId);

    if (staker.lastClaimedAt == 0) {
      staker.lastClaimedAt = block.timestamp;
    }

    staker.tokenIds.push(_tokenId);
    staker.tokenIndex[staker.tokenIds.length - 1];
    tokenOwner[_tokenId] = _user;

    totalStakedTokens = totalStakedTokens.add(1);

    annexNFT.safeTransferFrom(_user, address(this), _tokenId);
    emit Staked(_user, _tokenId);
  }

  function _updateReward(uint64 userId) public returns (uint256) {
    Staker storage staker = stakers[userId];
    uint256 bonusAmount = calculateRewards(userId);
    uint256 bounsDif = 0;
    if (bonusAmount == 0) {
      totalRewards = totalRewards.sub(staker.rewardsEarned);
      staker.rewardsEarned = 0;
      if (staker.isAutoCompound) {
        totalRewardsForCompound = 0;
      }
    } else if (bonusAmount > staker.rewardsEarned) {
      bounsDif = bonusAmount.sub(staker.rewardsEarned);
      totalRewards = totalRewards.add(bounsDif);
      staker.rewardsEarned = staker.rewardsEarned.add(bounsDif);
      if (staker.isAutoCompound) {
        totalRewardsForCompound = totalRewardsForCompound.add(bounsDif);
      }
    } else {
      bounsDif = staker.rewardsEarned.sub(bonusAmount);
      totalRewards = totalRewards.sub(bounsDif);
      staker.rewardsEarned = staker.rewardsEarned.sub(bounsDif);
      if (staker.isAutoCompound) {
        totalRewardsForCompound = totalRewardsForCompound.sub(bounsDif);
      }
    }
    return bounsDif;
  }

  function unStake(uint256 tokenId) external {
    _unStake(msg.sender, tokenId);
  }

  function unStakeBatch(uint256[] memory tokenIds) external {
    for (uint256 i = 0; i < tokenIds.length; i++) {
      _unStake(msg.sender, tokenIds[i]);
    }
  }

  function _unStake(address _user, uint256 _tokenId) public {
    uint64 userId = getUserId(_user);
    Staker storage staker = stakers[userId];
    require(staker.lastClaimedAt.add(unstakeInterval) < block.timestamp,"Claim allow once in 24 hours");
    require(annexNFT.ownerOf(_tokenId) == address(this), "NOT ONWER OF NFT");
    require(tokenOwner[_tokenId] == _user, "NOT ONWER OF NFT");

    uint256 lastIndex = staker.tokenIds.length - 1;
    uint256 lastIndexKey = staker.tokenIds[lastIndex];
    uint256 tokenIdIndex = staker.tokenIndex[_tokenId];

    staker.tokenIds[tokenIdIndex] = lastIndexKey;
    staker.tokenIndex[lastIndexKey] = tokenIdIndex;
    if (staker.tokenIds.length > 0) {
      staker.tokenIds.pop();
      delete staker.tokenIndex[_tokenId];
    }

    delete tokenOwner[_tokenId];
    totalStakedTokens = totalStakedTokens.sub(1);
    uint256 unstakedRewardClaim = _updateReward(userId);

    tusd.transfer(_user, unstakedRewardClaim);
    annexNFT.safeTransferFrom(address(this), _user, _tokenId);

    emit UnStaked(_user, _tokenId);
  }

  function updateAutoCompound(bool isAutoCompound) public {
    uint64 userId = getUserId(msg.sender);
    Staker storage staker = stakers[userId];
    require(staker.tokenIds.length > 0, "NO NFT STAKED");
    staker.isAutoCompound = isAutoCompound;
    _updateReward(userId);
    emit CompoundStatus(msg.sender, isAutoCompound);
  }

  function calculateRewards(uint64 userId) public view returns (uint256) {
    Staker storage staker = stakers[userId];
    if (staker.lastClaimedAt == 0 || staker.tokenIds.length == 0) {
      return 0;
    }
    uint256 deltaSeconds = (block.timestamp).sub(staker.lastClaimedAt);
    return rewardsPerSecond.mul(deltaSeconds).mul((staker.tokenIds.length).div(totalStakedTokens));
  }

  function claim() public {
    uint64 userId = getUserId(msg.sender);
    Staker storage staker = stakers[userId];
    require(staker.lastClaimedAt.add(claimInterval) < block.timestamp,"Claim allow once in 24 hours");
    require(staker.rewardsEarned > 0, "ZERO REWARD");
    if(staker.isAutoCompound){
      require(avalibleCompoundBalanceaANN > 0, "WAIT FOR CLAIM");
      uint256 earnedANNReward = staker.rewardsEarned.div(totalRewardsForCompoundReleased).mul(avalibleCompoundBalanceaANN);
      staker.aANNrewardsEarned = staker.aANNrewardsEarned.add(earnedANNReward);
      totalRewardsForCompoundReleased = totalRewardsForCompoundReleased.sub(staker.rewardsEarned);
      avalibleCompoundBalanceaANN = avalibleCompoundBalanceaANN.sub(earnedANNReward);
    }
    else{
      require(tusd.balanceOf(address(this)) >= staker.rewardsEarned, "NO TUSD AVALIBLE");
      tusd.transfer(msg.sender, staker.rewardsEarned);
    }

    staker.rewardsEarned = 0;
    staker.lastClaimedAt = block.timestamp;

    emit Claim(msg.sender, staker.rewardsEarned);
  }

  function swapAutoCompound() public onlyOwner {
    
    uint256 aAnnBalanceBefore = aANN.balanceOf(address(this));
    require(totalRewardsForCompound > 0, "LOW REWARD TO COMPOUND");
    uint256 swappedTokens = _swapTokens(totalRewardsForCompound);
    _lendingTokens(swappedTokens);
    uint256 aAnnBalanceAfter = aANN.balanceOf(address(this));
    uint256 aAnnBalanceDiff = aAnnBalanceAfter.sub(aAnnBalanceBefore);
    // _compoundTokensAssign(aAnnBalanceDiff);
    avalibleCompoundBalanceaANN = avalibleCompoundBalanceaANN.add(aAnnBalanceDiff);
    totalRewardsForCompoundReleased = totalRewardsForCompoundReleased.add(totalRewardsForCompound);
    totalRewardsForCompound = 0;
  }

  // function _compoundTokensAssign(uint256 _aAnnAmount) public {
  //   for (uint256 i = 1; i <= numUsers; i++) {
  //     if (stakers[i].isAutoCompound) {
  //       stakers[i].aANNrewardsEarned = stakers[i].rewardsEarned.div(totalRewardsForCompound).mul(_aAnnAmount);
  //       stakers[i].lastClaimedAt = block.timestamp;
  //       stakers[i].rewardsEarned = 0;
  //     }
  //   }
  // }

  function _swapTokens(uint256 _amount) public returns (uint256) {
    uint256[] memory amounts;
    address[] memory path = new address[](2);
    path[0] = address(tusd);
    path[1] = address(aNN);
    tusd.approve(address(annexRouter), _amount);
    amounts = annexRouter.swapExactTokensForTokens(_amount, 0, path, address(this), block.timestamp + 300);
    return amounts[1];
  }

  function _lendingTokens(uint256 _amount) public {
    require(aNN.balanceOf(address(this)) >= _amount, "LOW BALANCE IN VAULT");
    aNN.approve(address(aANN), _amount);
    aANN.mint(_amount);
  }

  function registerUser(address user) public returns (uint64) {
    numUsers = numUsers.add(1).toUint64();
    require(registeredUsers.insert(numUsers, user), "REGISTERED");
    emit UserRegistration(user, numUsers);
    return numUsers;
  }

  function getUserAddress(uint256 userId) external view returns (address) {
    return registeredUsers.hasId(userId.toUint64()) == true ? registeredUsers.getAddressAt(userId.toUint64()) : address(0);
  }

  function getUserId(address user) public returns (uint64 userId) {
    if (registeredUsers.hasAddress(user)) {
      userId = registeredUsers.getId(user);
    } else {
      userId = registerUser(user);
      emit NewUser(userId, user);
    }
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata data
  ) public pure returns (bytes4) {
    return _ERC721_RECEIVED;
  }

  function setRewardsAllocationTUSD(uint256 _amount) public onlyOwner {
    rewardsPerSecond = (_amount).div(_daySecond);
  }

  function setAnnexNFT(address _new) public onlyOwner {
    annexNFT = IERC721(_new);
  }

  function setAnn(address _new) public onlyOwner {
    aNN = IERC20(_new);
  }

  function setaAnn(address _new) public onlyOwner {
    aANN = IABep20Interface(_new);
  }

  function setTusdAddress(address _new) public onlyOwner {
    tusd = IERC20(_new);
  }

  function setAnnexRouter(address _new) public onlyOwner {
    annexRouter = IAnnexRouter02(_new);
  }

  function setIntervals(uint256 _unstakeInterval,uint256 _claimInterval) public onlyOwner {
    unstakeInterval = _unstakeInterval;
    claimInterval = _claimInterval;
  }

  function withdrawTokens(address token) public onlyOwner {
    uint256 balanceOfTokens = IERC20(token).balanceOf(address(this));
    require(balanceOfTokens > 0, "INSUFFICIENT BALANCE");
    IERC20(token).transfer(owner(), balanceOfTokens);
  }
}