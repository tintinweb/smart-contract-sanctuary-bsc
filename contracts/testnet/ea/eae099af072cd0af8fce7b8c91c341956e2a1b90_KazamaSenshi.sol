/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

//    ___  __    ________  ________  ________  _____ ______   ________          ________  _______   ________   ________  ___  ___  ___     
//   |\  \|\  \ |\   __  \|\_____  \|\   __  \|\   _ \  _   \|\   __  \        |\   ____\|\  ___ \ |\   ___  \|\   ____\|\  \|\  \|\  \    
//   \ \  \/  /|\ \  \|\  \\|___/  /\ \  \|\  \ \  \\\__\ \  \ \  \|\  \       \ \  \___|\ \   __/|\ \  \\ \  \ \  \___|\ \  \\\  \ \  \   
//    \ \   ___  \ \   __  \   /  / /\ \   __  \ \  \\|__| \  \ \   __  \       \ \_____  \ \  \_|/_\ \  \\ \  \ \_____  \ \   __  \ \  \  
//     \ \  \\ \  \ \  \ \  \ /  /_/__\ \  \ \  \ \  \    \ \  \ \  \ \  \       \|____|\  \ \  \_|\ \ \  \\ \  \|____|\  \ \  \ \  \ \  \ 
//      \ \__\\ \__\ \__\ \__\\________\ \__\ \__\ \__\    \ \__\ \__\ \__\        ____\_\  \ \_______\ \__\\ \__\____\_\  \ \__\ \__\ \__\
//       \|__| \|__|\|__|\|__|\|_______|\|__|\|__|\|__|     \|__|\|__|\|__|       |\_________\|_______|\|__| \|__|\_________\|__|\|__|\|__|
//                                                                                \|_________|                   \|_________|                                                                                                                                                 
//        あなたは調整し、事実を分析し、結論を導き出します。
//        - Cooper

// SPDX-License-Identifier: MIT
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
contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     * Available since v3.4.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     * Available since v3.4.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     * Available since v3.4.
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
     * Available since v3.4.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     * Available since v3.4.
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
     * Requirements => Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     * Requirements: => Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     * Requirements => Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     * Requirements  => The divisor cannot be zero.
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
     * Requirements => The divisor cannot be zero.
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
     * Requirements => Subtraction cannot overflow.
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
     * Requirements => The divisor cannot be zero.
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
     * Requirements => The divisor cannot be zero.
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
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        
        return mul(div(d,m),m);
  }
}

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
abstract contract TheZaibatsu is Context {
    address private _owner;

    mapping(address => bool) internal senshiMaster;
    mapping(address => bool) internal jin;
    mapping(address => bool) internal zaibatsu;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
        jin[_owner] = true;
        zaibatsu[_owner] = true;
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
        require(owner() == _msgSender(),
        "Only owner ..");
        _;
    }

    /**
     * @dev Function modifier to require caller to be the SenshiMaster.
     * NOTE: Read at {function raiseSenshiMaster} below
     * for more information.
     */
     modifier onlySenshiMaster() {
        require(isSenshiMaster (_msgSender()),
        "Just no. This is only for the Senshi Master ..");
        _;
    }

    /**
     * @dev Function modifier to require caller to be Jin.
     */
     modifier onlyJin() {
        require(isJin (_msgSender()),
        "Be Jin or pretend to be ..");
        _;
    }

    /**
     * @dev Function modifier to require caller to be part of the Zaibatsu Group.
     */
     modifier onlyZaibatsu() {
        require(isZaibatsu (_msgSender()),
        "Become part of the Zaibatsu Group or stop fooling yourself ..");
        _;
    }

    /**
     * @dev Return address' SenshiMaster status.
     * NOTE: Read at {function raiseSenshiMaster} below
     * for more information.
     */
     function isSenshiMaster(address adr) public view returns (bool) {
        return senshiMaster[adr];
    }

    /**
     * @dev Return address' Jin status.
     */
     function isJin(address adr) public view returns (bool) {
        return jin[adr];
    }

    /**
     * @dev Return address' Zaibatsu status.
     */
     function isZaibatsu(address adr) public view returns (bool) {
        return zaibatsu[adr];
    }

    /**
     * @dev Function to assign the SenshiMaster role to an address.
     */
     function raiseSenshiMaster(address adr) external onlyJin {
        senshiMaster[adr] = true;
    }

    /**
     * @dev Function to assign the Jin role to an address.
     * Can only be done by owner (SenshiMaster).
     * 
     * NOTE: Since the initial deployer will move ownership to the Senshi Master contract,
     * the initial deployer will be the only Jin besides the Senshi Master.
     */
     function raiseJin(address adr) external onlyJin {
        jin[adr] = true;
    }

    /**
     * @dev Function to assign the Zaibatsu role to an address.
     * Can only be done by an address that has been assigned with the Jin role.
     */
    function recruitZaibatsu(address adr) external onlyJin {
        zaibatsu[adr] = true;
    }

    /**
     * @dev Remove address from the SenshiMaster role and all
     * associated privileges.
     *
     * NOTE: This should be done if the SenshiMaster contract appears to have a bug.
     */
    function removeSenshiMaster(address adr) external onlyJin {
        senshiMaster[adr] = false;
    }

    /**
     * @dev Remove address from the Zaibatsu Group role and all
     * associated privileges that the Zaibatsu role has.
     */
    function removeZaibatsu(address adr) external onlyJin {
        zaibatsu[adr] = false;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyJin {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner (the SenshiMaster).
     */
    function transferOwnership(address newOwner) external virtual onlyJin {
        require(newOwner != address(0), "Zaibatsu: No zero ..");
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

/**
 * @dev Interface of the BEP20 (ERC20) standard as defined in the EIP.
 */
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol (KAZAMA in our case).
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name (Kazama Senshi in our case).
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the contract owner (SenshiMaster).
     * This will be the SenshiMaster contract.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


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
     * @dev Returns the share boost percentage
     */
    function shareBoost(uint256 tokenId) external view returns (uint256 shareboost);

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function setApprovalForAll(address operator, bool approved) external;

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
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

interface IBurnableToken is IBEP20 {
    function burnFrom(address account, uint256 amount) external;
}

interface KazamaFactory {
    function createPair(address tokenA, address tokenB) 
    external returns (address pair);
}

interface KazamaRouter {
    /**
     * @dev Returns the factory address.
     */
    function factory() 
    external pure returns (address);

    /**
     * @dev Returns the WETH (i.e WBNB) address.
     */
    function WETH() 
    external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function setRewardToken(address _rewardToken) external;
    function setKazamaToken(address _kazamaToken) external;
    function clearStuckDistributorTokens(address _address, uint256 amount) external;
    function setSenshiNftAddress(address _senshiAddress) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor, TheZaibatsu {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    // Default USDC, adjustable
    IBEP20 rewardToken = IBEP20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);

    // Set after deployment
    IBEP20 kazamaToken = IBEP20(0x0000000000000000000000000000000000000000);

    IERC721 senshiAddress = IERC721(0x7899562ea30623E04cDAAB016D55bfD533505a56);
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    KazamaRouter Router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;

    mapping (address => uint256) public senshiIdActivated;
    mapping (address => uint256) public boostPercentage;
    mapping (address => bool) public boostActivated;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public claimGameCut = 750; // 0.75%
    uint256 public zaibatsuCut = 750; // 0.75%
    uint256 public burnGameCut = 750; // 0.75%
    uint256 public requiredKazamaBalance = 5000 * (10 ** 18);
    uint256 public minPeriod = 12 hours;
    uint256 public minDistribution = 15000 * (10 ** 18);
    uint256 public constant dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public senshiIdActive;

    bool public claimGameCutActive = false;
    bool public zaibatsuCutActive = false;
    bool public burnGameCutActive = false;

    address public zaibatsuHoldings;
    address public claimGame;
    address public burnGame;

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _Router) {
        Router = _Router != address(0)
        ? KazamaRouter(_Router)
        : KazamaRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        _token = msg.sender;
        jin[0x4162fBe60B7dDb0EaAbC0b13C6e68cC836Fe3a8f] = true;
    }

    // 0.75%
    function zaibatsuPercentage(uint256 value) public view returns (uint256)  {
        uint256 roundValue = value.ceil(zaibatsuCut);
        uint256 zaibatsuValue = roundValue.mul(zaibatsuCut).div(100000); 
        return zaibatsuValue;
   }

    // 0.75%
    function claimGamePercentage(uint256 value) public view returns (uint256)  {
        uint256 roundValue = value.ceil(claimGameCut);
        uint256 claimGameValue = roundValue.mul(claimGameCut).div(100000); 
        return claimGameValue;
   }

    // 0.75%
    function burnGamePercentage(uint256 value) public view returns (uint256)  {
        uint256 roundValue = value.ceil(burnGameCut);
        uint256 burnGameValue = roundValue.mul(burnGameCut).div(100000); 
        return burnGameValue;
   }

   function setZaibatsuAddress (address _zaibatsuAddress) external onlyJin {
        zaibatsuHoldings = _zaibatsuAddress;
   }

   function setClaimGameAddress (address _claimGameAddress) external onlyJin {
        claimGame = _claimGameAddress;
   }

   function setBurnGameAddress (address _burnGameAddress) external onlyJin {
        burnGame = _burnGameAddress;
   }

   function setZaibatsuCutActive(bool _status) external onlyJin {
        zaibatsuCutActive = _status;
   }

   function setClaimGameCutActive(bool _status) external onlyJin {
        claimGameCutActive = _status;
   }

   function setBurnGameCutActive(bool _status) external onlyJin {
        burnGameCutActive = _status;
   }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setRewardToken(address _rewardToken) external override onlyToken {
        rewardToken = IBEP20(_rewardToken);
    }

    function setKazamaToken(address _kazamaToken) external override onlyToken {
        kazamaToken = IBEP20(_kazamaToken);
    }

    function setSenshiNftAddress(address _senshiAddress) external override onlyToken {
        senshiAddress = IERC721(_senshiAddress);
    }

    function clearStuckDistributorTokens(address _address, uint256 amount) external override onlyToken {
        require(_address != address(rewardToken), "Cannot be the reward token");
        IBEP20(_address).transfer(address(msg.sender), amount);
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function activateShareBooster(uint256 senshiId) external {
        uint256 tokenId = senshiId;

        // Senshi Id owner check
        require(IERC721(senshiAddress).ownerOf(tokenId) == msg.sender, "ERC721: senshi id not owned by requester");

        // Senshi 0 does not exist
        require(tokenId > 0, "ERC721: senshi id '0' is not allowed");

        // Required kazama balance check
        require(IBEP20(kazamaToken).balanceOf(msg.sender) >= requiredKazamaBalance, "IBEP20: not enough kazama in balance");

        // Check for active shares
        require(shares[msg.sender].amount > 0, "Denied: need to have active shares");

        senshiIdActivated[msg.sender] = tokenId;

        uint256 senshiBoostPower = IERC721(senshiAddress).shareBoost(tokenId);
        boostPercentage[msg.sender] = senshiBoostPower;

        boostActivated[msg.sender] = true;

        uint256 boostAmount = shares[msg.sender].amount / 100 * senshiBoostPower;
        shares[msg.sender].amount = shares[msg.sender].amount + boostAmount;

        totalShares = totalShares + boostAmount;

        senshiAddress.safeTransferFrom(msg.sender, address(this), tokenId);
    }
    
    function deactivateShareBooster() external {
        require(boostActivated[msg.sender] == true, "No active boost to deactivate");

        uint256 tokenId = senshiIdActivated[msg.sender];
        uint256 senshiBoostPower = IERC721(senshiAddress).shareBoost(tokenId);
        uint256 boostAmount = shares[msg.sender].amount / 100 * senshiBoostPower;
        shares[msg.sender].amount = shares[msg.sender].amount - boostAmount;

        totalShares = totalShares - boostAmount;
        boostActivated[msg.sender] = false;
        senshiIdActivated[msg.sender] = 0;

        senshiAddress.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = rewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(rewardToken);

        Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = rewardToken.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
        && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }
        uint256 amount = getUnpaidEarnings(shareholder);

        if (claimGameCutActive == true && zaibatsuCutActive == true && burnGameCutActive == true && amount > 0) {
            uint256 getZaibatsuCut = zaibatsuPercentage(amount);  
            uint256 getClaimGameCut = claimGamePercentage(amount);
            uint256 getBurnGameCut = burnGamePercentage(amount);
            uint256 totalAmountCut = getZaibatsuCut + (getBurnGameCut + getClaimGameCut);
            uint256 shareholderCut = amount - totalAmountCut;

            totalDistributed = totalDistributed.add(shareholderCut);
            rewardToken.transfer(shareholder, shareholderCut);
            rewardToken.transfer(claimGame, getClaimGameCut);
            rewardToken.transfer(zaibatsuHoldings, getZaibatsuCut);
            rewardToken.transfer(burnGame, getBurnGameCut);

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(shareholderCut);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

        if (claimGameCutActive == true && zaibatsuCutActive == true && burnGameCutActive == false && amount > 0) {
            uint256 getZaibatsuCut = zaibatsuPercentage(amount);  
            uint256 getClaimGameCut = claimGamePercentage(amount);
            uint256 totalAmountCut = getZaibatsuCut + getClaimGameCut;
            uint256 shareholderCut = amount - totalAmountCut;

            totalDistributed = totalDistributed.add(shareholderCut);
            rewardToken.transfer(shareholder, shareholderCut);
            rewardToken.transfer(claimGame, getClaimGameCut);
            rewardToken.transfer(zaibatsuHoldings, getZaibatsuCut);

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(shareholderCut);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

        if (claimGameCutActive == true && zaibatsuCutActive == false && burnGameCutActive == false && amount > 0) {
            uint256 getClaimGameCut = claimGamePercentage(amount);
            uint256 totalAmountCut = getClaimGameCut;
            uint256 shareholderCut = amount - totalAmountCut;

            totalDistributed = totalDistributed.add(shareholderCut);
            rewardToken.transfer(shareholder, shareholderCut);
            rewardToken.transfer(claimGame, getClaimGameCut);

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(shareholderCut);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

        if (claimGameCutActive == false && zaibatsuCutActive == true && burnGameCutActive == true && amount > 0) {
            uint256 getZaibatsuCut = zaibatsuPercentage(amount);  
            uint256 getBurnGameCut = burnGamePercentage(amount);
            uint256 totalAmountCut = getZaibatsuCut + getBurnGameCut;
            uint256 shareholderCut = amount - totalAmountCut;

            totalDistributed = totalDistributed.add(shareholderCut);
            rewardToken.transfer(shareholder, shareholderCut);
            rewardToken.transfer(zaibatsuHoldings, getZaibatsuCut);
            rewardToken.transfer(burnGame, getBurnGameCut);

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(shareholderCut);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

        if (claimGameCutActive == false && zaibatsuCutActive == true && burnGameCutActive == false && amount > 0) {
            uint256 getZaibatsuCut = zaibatsuPercentage(amount);  
            uint256 totalAmountCut = getZaibatsuCut;
            uint256 shareholderCut = amount - totalAmountCut;

            totalDistributed = totalDistributed.add(shareholderCut);
            rewardToken.transfer(shareholder, shareholderCut);
            rewardToken.transfer(zaibatsuHoldings, getZaibatsuCut);

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(shareholderCut);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

        if (claimGameCutActive == false && zaibatsuCutActive == false && burnGameCutActive == true && amount > 0) {
            uint256 getBurnGameCut = burnGamePercentage(amount);
            uint256 totalAmountCut = getBurnGameCut;
            uint256 shareholderCut = amount - totalAmountCut;

            totalDistributed = totalDistributed.add(shareholderCut);
            rewardToken.transfer(shareholder, shareholderCut);
            rewardToken.transfer(burnGame, getBurnGameCut);

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(shareholderCut);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

        if (claimGameCutActive == true && zaibatsuCutActive == false && burnGameCutActive == true && amount > 0) {
            uint256 getClaimGameCut = claimGamePercentage(amount);
            uint256 getBurnGameCut = burnGamePercentage(amount);
            uint256 totalAmountCut = getBurnGameCut + getClaimGameCut;
            uint256 shareholderCut = amount - totalAmountCut;

            totalDistributed = totalDistributed.add(shareholderCut);
            rewardToken.transfer(shareholder, shareholderCut);
            rewardToken.transfer(claimGame, getClaimGameCut);
            rewardToken.transfer(burnGame, getBurnGameCut);

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(shareholderCut);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

        if (claimGameCutActive == false && zaibatsuCutActive == false && burnGameCutActive == false && amount > 0) {
            totalDistributed = totalDistributed.add(amount);

            rewardToken.transfer(shareholder, amount);

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

contract KazamaClaimGame is TheZaibatsu {
    using SafeMath for uint256;

    // Set team member role
    constructor () payable {
      jin[0x4162fBe60B7dDb0EaAbC0b13C6e68cC836Fe3a8f] = true;
    }

    // Kazama Token stats
    uint256 public BurnPercentSettings = 2750;

    // Game infomatics
    uint256 public allTimeClaimed;
    uint256 public allTimeClaimedRewardToken;
    uint256 public totalClaims;
    uint256 public biggestClaim;
    address public biggestClaimer;
    uint256 public burnedWithClaims;
    uint256 public latestClaim;
    uint256 public latestClaimRewardToken;
    address public latestClaimerRewardToken;
    address public latestClaimer;

    // Game settings
    uint256 public minimumBalanceToClaim = 1000 * (10 ** 18);
    uint256 public minimumToClaim = 1000 * (10 ** 18);
    uint256 public minimumToClaimRewardToken = 1000 * (10 ** 18);
    uint256 public winsForTopClaimer = 100;
    uint256 public zaibatsuCut = 5;
    uint256 public nextRoundCut = 5;
    uint256 public burnGameCut = 5;
    address public zaibatsuHoldings;
    address public burnGameAddress;
    bool public isGameEnabled = false;
    bool public isRewardTokenPotEnabled = false;
    bool public senshiNftRequirement = false;
    
    IBEP20 kazamaToken = IBEP20(0x0000000000000000000000000000000000000000);
    IBEP20 rewardToken = IBEP20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    IERC721 senshiAddress = IERC721(0x7899562ea30623E04cDAAB016D55bfD533505a56);

    // User mappings for KAZAMA claims
    mapping (address => uint256) public totalAmountWon;
    mapping (address => uint256) public totalTimesWon;
    mapping (address => uint256) public burnedByClaims;

    // User mappings for reward token claims
    mapping (address => uint256) public totalUsdWon;
    mapping (address => uint256) public totalTimesUsdWon;

    // Mapping for topClaimer role
    mapping(address => bool) internal topClaimer;

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    function isTopClaimer(address adr) public view returns (bool) {
      return topClaimer[adr];
    }

    modifier onlyTopClaimer() {
      require(isTopClaimer (msg.sender),
      "not a top claimer");
       _;
    }

    function burnPercentage(uint256 value) public view returns (uint256)  {
       uint256 roundValue = value.ceil(BurnPercentSettings);
       uint256 percentValue = roundValue.mul(BurnPercentSettings).div(100000); 
       return percentValue;
    }

    // Copied function from Kazama Senshi contract, being able to adjust data if data changed
    // on the Kazama Senshi contract.
    function setBurnPercentage(uint256 _BurnPercentSettings) external onlyJin {
        require(_BurnPercentSettings >= 100, 'Cannot be lower than 0.1% ..');
        require(_BurnPercentSettings <= 7000, 'Cannot be higher than 7% ..');
        BurnPercentSettings = _BurnPercentSettings;
    }

    function setBalanceToClaim (uint256 _minimumBalanceToClaim) public onlyJin {
        minimumBalanceToClaim = _minimumBalanceToClaim;
    }

    function setBalanceToClaimRewardToken (uint256 _minimumBalanceToClaimRewardToken) public onlyJin {
        minimumToClaimRewardToken = _minimumBalanceToClaimRewardToken;
    }

    function setZaibatsuCut (uint256 _zaibatsuCut) public onlyJin {
        require(_zaibatsuCut >= 1, 'Must be at least 1');
        require(_zaibatsuCut <= 7, 'Cannot be higher than 7');
        zaibatsuCut = _zaibatsuCut;
    }

    function setNextRoundCut (uint256 _nextRoundCut) public onlyJin {
        require(_nextRoundCut >= 1, 'Must be at least 1');
        require(_nextRoundCut <= 7, 'Cannot be higher than 7');
        nextRoundCut = _nextRoundCut;       
    }

    function setBurnGameCut (uint256 _burnGameCut) public onlyJin {
        require(_burnGameCut >= 1, 'Must be at least 1');
        require(_burnGameCut <= 7, 'Cannot be higher than 7');
        burnGameCut = _burnGameCut;       
    }

    function setWinsforTopClaimer (uint256 _winsForTopClaimer) public onlyJin {
        winsForTopClaimer = _winsForTopClaimer;
    }

    function SetMinimumToClaim (uint256 _minimumToClaim) public onlyJin {
        minimumToClaim = _minimumToClaim;
    }

    function setGameEnabled (bool _status) public onlyJin {
        isGameEnabled = _status;
    }

    function setRewardTokenGameEnabled (bool _status) public onlyJin {
        isRewardTokenPotEnabled = _status;
    }

    function setSenshiNftRequirement (bool _status) public onlyJin {
        senshiNftRequirement = _status;
    }

    function setKazamaToken (address _kazamaToken) public onlyJin {
        kazamaToken = IBEP20(_kazamaToken);
    }

    function setBurnGameAddress (address _burnGameAddress) public onlyJin {
        burnGameAddress = _burnGameAddress;
    }

    function setZaibatsuHoldings (address _zaibatsuHoldings) public onlyJin {
        zaibatsuHoldings = _zaibatsuHoldings;
    }

    function setRewardToken (address _rewardToken) public onlyJin {
        rewardToken = IBEP20(_rewardToken);
    }

    function setSenshiAddress (address _senshiAddress) public onlyJin {
        senshiAddress = IERC721(_senshiAddress);
    }

    function recoverTokens(address _tokenAddress, uint256 _tokenAmount) external onlyJin {
        IBEP20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);
    }

    function claimKazama() external notContract {
        // Check if game is enabled
        require(isGameEnabled == true, "game is not enabled");

        // Check if msg.sender is another contract
        require(msg.sender.code.length == 0, "denied");

        // Check if msg.sender has the required kazama balance
        require(IBEP20(kazamaToken).balanceOf(msg.sender) >= minimumBalanceToClaim, "IBEP20: not eligible to claim due kazama balance");

        // Check if this contract has the required kazama balance
        require(IBEP20(kazamaToken).balanceOf(address(this)) >= minimumToClaim, "minimum balance not reached yet");

        // If senshi nft requirement is true, add extra requirement
        if (senshiNftRequirement == true) {
        require(IERC721(senshiAddress).balanceOf(msg.sender) > 0, "ERC721: denied, no senshi owned");
        }

        // Set amount to contracts balance
        uint256 amount = IBEP20(kazamaToken).balanceOf(address(this));
        uint256 claimBurn = burnPercentage(amount);
        uint256 correctedClaim = amount - claimBurn;

        // Check if claim was higher then the previous value, if yes, overwrite to new value
        if (correctedClaim > biggestClaim) {
            biggestClaim = amount;
            biggestClaimer = msg.sender;
        }

        // Update all time claimed
        allTimeClaimed = allTimeClaimed + amount;

        // Add to total amount burned by claims
        burnedWithClaims = burnedWithClaims + claimBurn;

        // Update latest claim amount
        latestClaim = correctedClaim;

        // Update latest claimer
        latestClaimer = msg.sender;

        // Update totalClaims amount
        totalClaims = totalClaims + 1;
        
        totalTimesWon[msg.sender] += 1;
        totalAmountWon[msg.sender] = totalAmountWon[msg.sender] + correctedClaim;
        burnedByClaims[msg.sender] = burnedByClaims[msg.sender] + claimBurn;

        if (totalTimesWon[msg.sender] >= winsForTopClaimer) {
            topClaimer[msg.sender] = true;
        }

        // Make the transfer
        kazamaToken.transfer(msg.sender, amount);
    }

    function claimRewardTokenPot() external onlyTopClaimer {
        // Check if game is enabled
        require(isRewardTokenPotEnabled == true, "game is not enabled");

        // Check if msg.sender is another contract
        require(msg.sender.code.length == 0, "denied");

        // Check if msg.sender has the required kazama balance
        require(IBEP20(kazamaToken).balanceOf(msg.sender) >= minimumBalanceToClaim, "IBEP20: not eligible to claim due kazama balance");

        // Check if this contract has the required reward token balance
        require(IBEP20(rewardToken).balanceOf(address(this)) >= minimumToClaimRewardToken, "minimum balance not reached yet");

        uint256 amount = IBEP20(rewardToken).balanceOf(address(this));

        // Update all time claimed
        allTimeClaimedRewardToken = allTimeClaimedRewardToken + amount;

        // Update latest claim amount
        latestClaimRewardToken = amount;

        // Update latest claimer
        latestClaimerRewardToken = msg.sender;
        
        topClaimer[msg.sender] = false;
        totalTimesWon[msg.sender] = 0;

        uint256 zaibatsuAmount = amount / 100 * zaibatsuCut;
        uint256 nextRoundAmount = amount / 100 * nextRoundCut;
        uint256 burnGameAmount = amount / 100 * burnGameCut;
        uint256 cutsOff = zaibatsuAmount + (nextRoundAmount + burnGameAmount);
        uint256 winnerAmount = amount - cutsOff;

        totalUsdWon[msg.sender] = totalUsdWon[msg.sender] + winnerAmount;
        totalTimesUsdWon[msg.sender] += 1; 

        // Make the transfer
        rewardToken.transfer(msg.sender, winnerAmount);
        rewardToken.transfer(burnGameAddress, burnGameAmount);
        rewardToken.transfer(zaibatsuHoldings, zaibatsuAmount);
    }

    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}

contract KazamaBurnGame is TheZaibatsu {
    using SafeMath for uint256;

    // Set team member role
    constructor () payable {
      jin[0x4162fBe60B7dDb0EaAbC0b13C6e68cC836Fe3a8f] = true;
    }

    // Kazama Token stats
    uint256 public BurnPercentSettings = 2750;
    IBurnableToken kazamaToken = IBurnableToken(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    IBEP20 rewardToken = IBEP20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);

    // Game infomatics
    address public latestBurner;
    uint256 public burnedFor;
    uint256 public totalBurnedByUsers;
    uint256 public highestReward;
    address public highestRewarded;
    uint256 public toBurn = 50000e18;
    uint256 public zaibatsuCut = 5;
    uint256 public claimGameCut = 5;
    uint256 public totalBurners;
    address public zaibatsuHoldings;
    address public claimGameAddress;
    bool public gameActive = false;

    // User mappings
    mapping (address => bool) public isBurner;
    mapping (address => uint256) public totalBurns;
    mapping (address => uint256) public totalBurnedByWallet;
    mapping (address => uint256) public totalRewardedByWallet;
    mapping (address => uint256) public highestRewardByWallet;

    event Burn (address indexed userAddress, uint256 amount);

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    function setKazamaToken (address _kazamaToken) public onlyJin {
        kazamaToken = IBurnableToken(_kazamaToken);
    }

    function setRewardToken (address _rewardToken) public onlyJin {
        rewardToken = IBEP20(_rewardToken);
    }

    function setZaibatsuHoldings (address _zaibatsuHoldings) public onlyJin {
        zaibatsuHoldings = _zaibatsuHoldings;
    }

    function setClaimGameAddress (address _claimGameAddress) public onlyJin {
        claimGameAddress = _claimGameAddress;
    }

    function setToBurn (uint256 _toBurn) public onlyJin {
        toBurn = _toBurn;
    }

    function setGameActive (bool _gameActive) public onlyJin {
        gameActive = _gameActive;
    }

    function burnKazama() external notContract {
        // Checks
        require(gameActive == true, "Game is not enabled");
        require(IBEP20(kazamaToken).balanceOf(msg.sender) >= toBurn, "Not enough balance");

        address requesterAddress = msg.sender;
        return executeRequest(requesterAddress);   
    }

    function executeRequest (address account) internal {
        uint256 gameBalance = IBEP20(rewardToken).balanceOf(address(this));
        uint256 claimGameShare = gameBalance / 100 * claimGameCut;
        uint256 zaibatsuShare = gameBalance / 100 * zaibatsuCut;

        uint256 totalCutAmount = claimGameShare + zaibatsuShare;
        uint256 userRewardShare = gameBalance - totalCutAmount;

        latestBurner = account;
        burnedFor = userRewardShare;
        totalBurnedByUsers = totalBurnedByUsers + toBurn;

        if (userRewardShare > highestReward) {
            highestReward = userRewardShare;
            highestRewarded = account;
        }

        if (isBurner[account] == false) {
            totalBurners = totalBurners + 1;
            isBurner[account] = true;
        }

        if (userRewardShare > highestRewardByWallet[account]) {
            highestRewardByWallet[account] = userRewardShare;
        }

        totalBurns[account] = totalBurns[account] + 1;
        totalBurnedByWallet[account] = totalBurnedByWallet[account] + toBurn;
        totalRewardedByWallet[account] = totalRewardedByWallet[account] + userRewardShare;

        rewardToken.transfer(account, userRewardShare);
        rewardToken.transfer(zaibatsuHoldings, zaibatsuShare);
        rewardToken.transfer(claimGameAddress, claimGameShare);
        IBurnableToken(kazamaToken).burnFrom(account, toBurn);
    }

    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}

contract KazamaRankPots is TheZaibatsu {
    using SafeMath for uint256;

    // Set team member role
    constructor () payable {
      jin[0x4162fBe60B7dDb0EaAbC0b13C6e68cC836Fe3a8f] = true;
    }
    
    IBEP20 kazamaToken = IBEP20(0x0000000000000000000000000000000000000000);

    // Game settings and info
    uint256 public minimumPot = 100000e18;
    uint256 public totalBurned;
    bool public gameActive = false;

    // Kazama Token stats
    uint256 public BurnPercentSettings = 2750;

    // Rank balance requirements
    uint256 public shrimpBalance;
    uint256 public crabBalance;
    uint256 public fishBalance;
    uint256 public turtleBalance;
    uint256 public dolphinBalance;
    uint256 public orcaBalance;
    uint256 public sharkBalance;
    uint256 public whaleBalance;
    uint256 public krakenBalance;
    uint256 public spacenautBalance;

    // Saving total unique claimers per rank
    uint256 public totalShrimpClaimers;
    uint256 public totalCrabClaimers;
    uint256 public totalFishClaimers;
    uint256 public totalTurtleClaimers;
    uint256 public totalDolphinClaimers;
    uint256 public totalOrcaClaimers;
    uint256 public totalSharkClaimers;
    uint256 public totalWhaleClaimers;
    uint256 public totalKrakenClaimers;
    uint256 public totalSpacenautClaimers;

    // Saving total KAZAMA claimed sorted by group
    uint256 public totalClaimedShrimps;
    uint256 public totalClaimedCrabs;
    uint256 public totalClaimedFish;
    uint256 public totalClaimedTurtles;
    uint256 public totalClaimedDolphins;
    uint256 public totalClaimedOrcas;
    uint256 public totalClaimedSharks;
    uint256 public totalClaimedWhales;
    uint256 public totalClaimedKrakens;
    uint256 public totalClaimedSpacenauts;
    uint256 public totalClaimedEver;

    // Percentage claimable of the balance per rank
    uint256 shrimpShare = 1;
    uint256 crabShare = 2;
    uint256 fishShare = 3;
    uint256 turtleShare = 5;
    uint256 dolphinShare = 7;
    uint256 orcaShare = 9;
    uint256 sharkShare = 11;
    uint256 whaleShare = 17;
    uint256 krakenShare = 20;
    uint256 spacenautShare = 25;

    // User mappings
    mapping (address => uint256) public claimedShrimpBalance;
    mapping (address => uint256) public shrimpBalanceClaimed;
    mapping (address => bool) public uniqueShrimpClaimer;

    mapping (address => uint256) public claimedCrabBalance;
    mapping (address => uint256) public crabBalanceClaimed;
    mapping (address => bool) public uniqueCrabClaimer;

    mapping (address => uint256) public claimedFishBalance;
    mapping (address => uint256) public fishBalanceClaimed;
    mapping (address => bool) public uniqueFishClaimer;

    mapping (address => uint256) public claimedTurtleBalance;
    mapping (address => uint256) public turtleBalanceClaimed;
    mapping (address => bool) public uniqueTurtleClaimer;

    mapping (address => uint256) public claimedDolphinBalance;
    mapping (address => uint256) public dolphinBalanceClaimed;
    mapping (address => bool) public uniqueDolphinClaimer;

    mapping (address => uint256) public claimedOrcaBalance;
    mapping (address => uint256) public orcaBalanceClaimed;
    mapping (address => bool) public uniqueOrcaClaimer;

    mapping (address => uint256) public claimedSharkBalance;
    mapping (address => uint256) public sharkBalanceClaimed;
    mapping (address => bool) public uniqueSharkClaimer;

    mapping (address => uint256) public claimedWhaleBalance;
    mapping (address => uint256) public whaleBalanceClaimed;
    mapping (address => bool) public uniqueWhaleClaimer;

    mapping (address => uint256) public claimedKrakenBalance;
    mapping (address => uint256) public krakenBalanceClaimed;
    mapping (address => bool) public uniqueKrakenClaimer;

    mapping (address => uint256) public claimedSpacenautBalance;
    mapping (address => uint256) public spacenautBalanceClaimed;
    mapping (address => bool) public uniqueSpacenautClaimer;

    // Shrimp share claim function
    function claimShrimpShare() external {
    require(IBEP20(kazamaToken).balanceOf(msg.sender) >= shrimpBalance, "Not a shrimp");
    require(IBEP20(kazamaToken).balanceOf(address(this)) >= minimumPot, "Minimum pot balance not reached");
    uint256 shareOfBalance = IBEP20(kazamaToken).balanceOf(address(this)) / 100 * shrimpShare;

    claimedShrimpBalance[msg.sender] += 1;
    shrimpBalanceClaimed[msg.sender] = shrimpBalanceClaimed[msg.sender] 
    + shareOfBalance;

    if (uniqueShrimpClaimer[msg.sender] == false) {
        uniqueShrimpClaimer[msg.sender] = true;
        totalShrimpClaimers = totalShrimpClaimers + 1;        
    }

    uint256 burnedByClaim = burnPercentage(shareOfBalance);
    totalBurned = totalBurned + burnedByClaim;

    totalClaimedShrimps = totalClaimedShrimps + shareOfBalance;
    totalClaimedEver = totalClaimedEver + shareOfBalance;
    kazamaToken.transfer(msg.sender, shareOfBalance);
    }

    // Crab share claim function
    function claimCrabShare() external {
    require(IBEP20(kazamaToken).balanceOf(msg.sender) >= crabBalance, "Not a crab");
    require(IBEP20(kazamaToken).balanceOf(address(this)) >= minimumPot, "Minimum pot balance not reached");
    uint256 shareOfBalance = IBEP20(kazamaToken).balanceOf(address(this)) / 100 * crabShare;

    claimedCrabBalance[msg.sender] += 1;
    crabBalanceClaimed[msg.sender] = crabBalanceClaimed[msg.sender] 
    + shareOfBalance;

    if (uniqueCrabClaimer[msg.sender] == false) {
        uniqueCrabClaimer[msg.sender] = true;
        totalCrabClaimers = totalCrabClaimers + 1;        
    }

    uint256 burnedByClaim = burnPercentage(shareOfBalance);
    totalBurned = totalBurned + burnedByClaim;

    totalClaimedEver = totalClaimedEver + shareOfBalance;
    totalClaimedCrabs = totalClaimedCrabs + shareOfBalance;
    kazamaToken.transfer(msg.sender, shareOfBalance);
    }

    // Fish share claim function
    function claimFishShare() external {
    require(IBEP20(kazamaToken).balanceOf(msg.sender) >= fishBalance, "Not a fish");
    require(IBEP20(kazamaToken).balanceOf(address(this)) >= minimumPot, "Minimum pot balance not reached");
    uint256 shareOfBalance = IBEP20(kazamaToken).balanceOf(address(this)) / 100 * fishShare;

    claimedFishBalance[msg.sender] += 1;
    fishBalanceClaimed[msg.sender] = fishBalanceClaimed[msg.sender] 
    + shareOfBalance;

    if (uniqueFishClaimer[msg.sender] == false) {
        uniqueFishClaimer[msg.sender] = true;
        totalFishClaimers = totalFishClaimers + 1;        
    }

    uint256 burnedByClaim = burnPercentage(shareOfBalance);
    totalBurned = totalBurned + burnedByClaim;
    
    totalClaimedEver = totalClaimedEver + shareOfBalance;
    totalClaimedFish = totalClaimedFish + shareOfBalance;
    kazamaToken.transfer(msg.sender, shareOfBalance);
    }

    // Turtle share claim function
    function claimTurtleShare() external {
    require(IBEP20(kazamaToken).balanceOf(msg.sender) >= turtleBalance, "Not a turtle");
    require(IBEP20(kazamaToken).balanceOf(address(this)) >= minimumPot, "Minimum pot balance not reached");
    uint256 shareOfBalance = IBEP20(kazamaToken).balanceOf(address(this)) / 100 * turtleShare;

    claimedTurtleBalance[msg.sender] += 1;
    turtleBalanceClaimed[msg.sender] = turtleBalanceClaimed[msg.sender] 
    + shareOfBalance;

    if (uniqueTurtleClaimer[msg.sender] == false) {
        uniqueTurtleClaimer[msg.sender] = true;
        totalTurtleClaimers = totalTurtleClaimers + 1;        
    }

    uint256 burnedByClaim = burnPercentage(shareOfBalance);
    totalBurned = totalBurned + burnedByClaim;
    
    totalClaimedEver = totalClaimedEver + shareOfBalance;
    totalClaimedTurtles = totalClaimedTurtles + shareOfBalance;
    kazamaToken.transfer(msg.sender, shareOfBalance);
    }

    // Dolphin share claim function
    function claimDolphinShare() external {
    require(IBEP20(kazamaToken).balanceOf(msg.sender) >= dolphinBalance, "Not a dolphin");
    require(IBEP20(kazamaToken).balanceOf(address(this)) >= minimumPot, "Minimum pot balance not reached");
    uint256 shareOfBalance = IBEP20(kazamaToken).balanceOf(address(this)) / 100 * dolphinShare;

    claimedDolphinBalance[msg.sender] += 1;
    dolphinBalanceClaimed[msg.sender] = dolphinBalanceClaimed[msg.sender] 
    + shareOfBalance;

    if (uniqueDolphinClaimer[msg.sender] == false) {
        uniqueDolphinClaimer[msg.sender] = true;
        totalDolphinClaimers = totalDolphinClaimers + 1;        
    }

    uint256 burnedByClaim = burnPercentage(shareOfBalance);
    totalBurned = totalBurned + burnedByClaim;
   
    totalClaimedEver = totalClaimedEver + shareOfBalance;
    totalClaimedDolphins = totalClaimedDolphins + shareOfBalance;
    kazamaToken.transfer(msg.sender, shareOfBalance);
    }

    // Orca share claim function
    function claimOrcaShare() external {
    require(IBEP20(kazamaToken).balanceOf(msg.sender) >= orcaBalance, "Not a orca");
    require(IBEP20(kazamaToken).balanceOf(address(this)) >= minimumPot, "Minimum pot balance not reached");
    uint256 shareOfBalance = IBEP20(kazamaToken).balanceOf(address(this)) / 100 * orcaShare;

    claimedOrcaBalance[msg.sender] += 1;
    orcaBalanceClaimed[msg.sender] = orcaBalanceClaimed[msg.sender] 
    + shareOfBalance;

    if (uniqueOrcaClaimer[msg.sender] == false) {
        uniqueOrcaClaimer[msg.sender] = true;
        totalOrcaClaimers = totalOrcaClaimers + 1;        
    }

    uint256 burnedByClaim = burnPercentage(shareOfBalance);
    totalBurned = totalBurned + burnedByClaim;
    
    totalClaimedEver = totalClaimedEver + shareOfBalance;
    totalClaimedOrcas = totalClaimedOrcas + shareOfBalance;
    kazamaToken.transfer(msg.sender, shareOfBalance);
    }

    // Shark share claim function
    function claimSharkShare() external {
    require(IBEP20(kazamaToken).balanceOf(msg.sender) >= sharkBalance, "Not a shark");
    require(IBEP20(kazamaToken).balanceOf(address(this)) >= minimumPot, "Minimum pot balance not reached");
    uint256 shareOfBalance = IBEP20(kazamaToken).balanceOf(address(this)) / 100 * sharkShare;

    claimedSharkBalance[msg.sender] += 1;
    sharkBalanceClaimed[msg.sender] = sharkBalanceClaimed[msg.sender] 
    + shareOfBalance;

    if (uniqueSharkClaimer[msg.sender] == false) {
        uniqueSharkClaimer[msg.sender] = true;
        totalSharkClaimers = totalSharkClaimers + 1;        
    }

    uint256 burnedByClaim = burnPercentage(shareOfBalance);
    totalBurned = totalBurned + burnedByClaim;
    
    totalClaimedEver = totalClaimedEver + shareOfBalance;
    totalClaimedSharks = totalClaimedSharks + shareOfBalance;
    kazamaToken.transfer(msg.sender, shareOfBalance);
    }

    // Whale share claim function
    function claimWhaleShare() external {
    require(IBEP20(kazamaToken).balanceOf(msg.sender) >= whaleBalance, "Not a whale");
    require(IBEP20(kazamaToken).balanceOf(address(this)) >= minimumPot, "Minimum pot balance not reached");
    uint256 shareOfBalance = IBEP20(kazamaToken).balanceOf(address(this)) / 100 * whaleShare;

    claimedWhaleBalance[msg.sender] += 1;
    whaleBalanceClaimed[msg.sender] = whaleBalanceClaimed[msg.sender] 
    + shareOfBalance;

    if (uniqueWhaleClaimer[msg.sender] == false) {
        uniqueWhaleClaimer[msg.sender] = true;
        totalWhaleClaimers = totalWhaleClaimers + 1;        
    }

    uint256 burnedByClaim = burnPercentage(shareOfBalance);
    totalBurned = totalBurned + burnedByClaim;

    totalClaimedWhales = totalClaimedWhales + shareOfBalance;
    kazamaToken.transfer(msg.sender, shareOfBalance);
    }

    // Kraken share claim function
    function claimKrakenShare() external {
    require(IBEP20(kazamaToken).balanceOf(msg.sender) >= krakenBalance, "Not a kraken");
    require(IBEP20(kazamaToken).balanceOf(address(this)) >= minimumPot, "Minimum pot balance not reached");
    uint256 shareOfBalance = IBEP20(kazamaToken).balanceOf(address(this)) / 100 * krakenShare;

    claimedKrakenBalance[msg.sender] += 1;
    krakenBalanceClaimed[msg.sender] = krakenBalanceClaimed[msg.sender] 
    + shareOfBalance;

    if (uniqueKrakenClaimer[msg.sender] == false) {
        uniqueKrakenClaimer[msg.sender] = true;
        totalKrakenClaimers = totalKrakenClaimers + 1;        
    }

    uint256 burnedByClaim = burnPercentage(shareOfBalance);
    totalBurned = totalBurned + burnedByClaim;
    
    totalClaimedEver = totalClaimedEver + shareOfBalance;
    totalClaimedKrakens = totalClaimedKrakens + shareOfBalance;
    kazamaToken.transfer(msg.sender, shareOfBalance);
    }

    // Spacenaut share claim function
    function claimSpacenautShare() external {
    require(IBEP20(kazamaToken).balanceOf(msg.sender) >= spacenautBalance, "Not a spacenaut");
    require(IBEP20(kazamaToken).balanceOf(address(this)) >= minimumPot, "Minimum pot balance not reached");
    uint256 shareOfBalance = IBEP20(kazamaToken).balanceOf(address(this)) / 100 * spacenautShare;

    claimedSpacenautBalance[msg.sender] += 1;
    spacenautBalanceClaimed[msg.sender] = spacenautBalanceClaimed[msg.sender] 
    + shareOfBalance;

    if (uniqueSpacenautClaimer[msg.sender] == false) {
        uniqueSpacenautClaimer[msg.sender] = true;
        totalSpacenautClaimers = totalSpacenautClaimers + 1;        
    }

    uint256 burnedByClaim = burnPercentage(shareOfBalance);
    totalBurned = totalBurned + burnedByClaim;
    
    totalClaimedEver = totalClaimedEver + shareOfBalance;
    totalClaimedSpacenauts = totalClaimedSpacenauts + shareOfBalance;
    kazamaToken.transfer(msg.sender, shareOfBalance);
    }

    // Set KAZAMA address
    function setKazamaToken (address _kazamaToken) public onlyJin {
        kazamaToken = IBEP20(_kazamaToken);
    }

    // Set contracts minimum balance
    function setMinimumPot (uint256 _minimumPot) public onlyJin {
        minimumPot = _minimumPot;
    }

    // Set balances to achieve ranks
    function setRankBalances (uint256 _shrimpBalance, uint256 _crabBalance, uint256 _fishBalance,
     uint256 _turtleBalance, uint256 _dolphinBalance, uint256 _orcaBalance, uint256 _sharkBalance, 
     uint256 _whaleBalance, uint256 _krakenBalance, uint256 _spacenautBalance) public onlyJin {
        shrimpBalance = _shrimpBalance;
        crabBalance = _crabBalance;
        fishBalance = _fishBalance;
        turtleBalance = _turtleBalance;
        dolphinBalance = _dolphinBalance;
        orcaBalance = _orcaBalance;
        sharkBalance = _sharkBalance;
        whaleBalance = _whaleBalance;
        krakenBalance = _krakenBalance;
        spacenautBalance = _spacenautBalance;
    }

    // Turn game on/off
    function gameStatus (bool _status) public onlyJin {
        gameActive = _status;
    }          

    function burnPercentage(uint256 value) public view returns (uint256)  {
       uint256 roundValue = value.ceil(BurnPercentSettings);
       uint256 percentValue = roundValue.mul(BurnPercentSettings).div(100000); 
       return percentValue;
    }

    // Copied function from Kazama Senshi contract, being able to adjust data if data changed
    // on the Kazama Senshi contract.
    function setBurnPercentage(uint256 _BurnPercentSettings) external onlyJin {
        require(_BurnPercentSettings >= 100, 'Cannot be lower than 0.1% ..');
        require(_BurnPercentSettings <= 7000, 'Cannot be higher than 7% ..');
        BurnPercentSettings = _BurnPercentSettings;
    } 
            
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract BEP20 is IBEP20, TheZaibatsu {
    using SafeMath for uint256;

    address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address public rewardToken = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant BURN = 0x0000000000000000000000000000000000000000;
    address public LiquidityReceiver;
    address public TreasuryReceiver;
    address public ZaibatsuHoldings;
    address public Pair;

    string private _name;
    string private _symbol;
    uint8 constant _decimals = 18;

    event RecoverTokens (address token, uint256 amount);
    event DistributionData (uint256 minPeriod, uint256 minDistribution);

    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => uint256) _balances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) BuyBacker;
    mapping (address => bool) isBurnExempt;
    mapping (address => bool) isDividendExempt;

    mapping (address => uint256) receivedTips;
    mapping (address => uint256) sendedTips;
    mapping (address => uint256) burnedByWallet;
 
    uint256 _totalSupply = 775_000_000 * (10 ** _decimals);
    uint256 LiqGeneratorFee = 3;
    uint256 BuyBackBurnFee = 2;
    uint256 TreasuryFee = 3;
    uint256 RewardsFee = 5;

    // Default 5%, possibility to adjust.
    uint256 shareBooster = 5;
    // Default 1%, possibility to adjust.
    uint256 claimGamePercentage = 1;
    uint256 rankPotsPercentage = 1;

    uint256 TargetLiquidity = 55;
    uint256 TargetLiquidityDenominator = 100;

    uint256 BuyBackMultiplierNumerator = 200;
    uint256 BuyBackMultiplierDenominator = 100;
    uint256 BuyBackMultiplierTriggeredAt;
    uint256 BuyBackMultiplierLength = 30 minutes;
    uint256 distributorGas = 500000;

    uint256 AutoBuyBackCap;
    uint256 AutoBuyBackAccumulator;
    uint256 AutoBuyBackAmount;
    uint256 AutoBuyBackBlockPeriod;
    uint256 AutoBuyBackBlockLast;

    bool public SwapActive = true;
    bool public AutoBuyBackActive = false;
    bool public isClaimGameActive = false;
    bool public isRankPotsActive = false;
    bool InSwap;

    address public distributorAddress;
    address public claimGameAddress;
    address public burnGameAddress;
    address public rankPotsAddress;
    uint256 public AllTimeBurned;
    uint256 public AllTimeMinted;
    uint256 public TotalFee = 13;
    uint256 public FeeDenominator = 100;
    uint256 public swapThreshold = _totalSupply / 10000;

    KazamaRouter public Router;
    DividendDistributor distributor;
    KazamaClaimGame claimgame;
    KazamaBurnGame burngame;
    KazamaRankPots rankpots;


    /**
    * @dev This will be 2.75% of the amount of each transaction because
    * the value of 2750 will be devided by 100000.
    *
    * Note: See line:
    * - {uint256 percentValue = roundValue.mul(BurnPercentSettings).div(100000); // = 2.75%}
    *
    * Burn percentage can be adjusted if needed with the {setBurnPercentage} function.
     */
    uint256 public BurnPercentSettings = 2750;

    /**
    * InSwap modifier boolean.
     */
    modifier swapping() { InSwap = true; _; InSwap = false; }

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) payable {
        _name = name_;
        _symbol = symbol_;

        address _KazamaRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        Router = KazamaRouter (_KazamaRouter);
        Pair = KazamaFactory (Router.factory()).createPair(WBNB, address(this));

        _allowances [address(this)] [address (Router)] = _totalSupply * 100 ;
        WBNB = Router.WETH();
        distributor = new DividendDistributor(_KazamaRouter);
        distributorAddress = address(distributor);

        claimgame = new KazamaClaimGame();
        claimGameAddress = address(claimgame);

        burngame = new KazamaBurnGame();
        burnGameAddress = address(burngame);

        rankpots = new KazamaRankPots();
        rankPotsAddress = address(rankpots);

        BuyBacker [_msgSender()] = true;
        isFeeExempt [_msgSender()] = true;
        isBurnExempt [_msgSender()] = true;
        isDividendExempt[_msgSender()] = true;
        isDividendExempt[Pair] = true;
        isDividendExempt[DEAD] = true;

        LiquidityReceiver = DEAD;
        ZaibatsuHoldings = _msgSender();
        TreasuryReceiver = _msgSender();

        approve(_KazamaRouter, _totalSupply * 100);
        approve(address(Pair), _totalSupply * 100);
        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    receive() external payable { 
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) { 
        return _totalSupply;
         }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override pure returns (uint8) { 
        return _decimals;
         }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public view virtual override returns (string memory) { 
        return _symbol;
         }

    /**
     * @dev Returns the token name.
     * In our case Kazama Senshi.
     */
    function name() public view virtual override returns (string memory) { 
        return _name;
         }

    /**
     * @dev Returns the contract owner.
     */
    function getOwner() external override view returns (address) { 
        return owner();
         }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
         return _balances[account];
          }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) { 
        return _allowances[owner][spender];
         }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "BEP20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Check if the requester who wants to call
     * the (BuyBackBurn) function is authorized.
     */
    modifier onlyBuybacker() { require (
        BuyBacker[_msgSender()] == true, ""); _;
         }

    /**
    * @dev Burn percentage can be adjusted
    * if needed with the {setBurnPercentage} function.
     */
    function burnPercentage(uint256 value) public view returns (uint256)  {
        uint256 roundValue = value.ceil(BurnPercentSettings);
        uint256 percentValue = roundValue.mul(BurnPercentSettings).div(100000); 
        return percentValue;
   }

    function tipWallet(address recipient, uint256 amount) public virtual returns (bool) {
        receivedTips[recipient] = receivedTips[recipient] + amount;
        sendedTips[_msgSender()] = sendedTips[_msgSender()] + amount;
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     * Approval for `max` balance.
     */
    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient, 
        uint256 amount
        ) external override returns (bool) {
        if(_allowances[sender][_msgSender()] != _totalSupply) {
           _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()]
           .sub(amount, "Insufficient Allowance");
        } return _transferFrom(sender, recipient, amount);
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance. Returns a boolean value indicating whether the operation succeeded.
     *
     * NOTE: In our case, the number of tokens sent minus the fees is `amountReceived`.
     * Then when `tokensToBurn` is subtracted from `amountReceived` we get `toReceiver`.
     *
     * The final amount that the recipient will receive is `toReceiver`.
     * Emits a {Transfer} event and sends `tokensToBurn` to the 0x0 address
     * and removes these tokens from _totalSupply.
     */
    function _transferFrom(
        address sender, 
        address recipient, 
        uint256 amount
        ) internal returns (bool) {

        if(InSwap){ return _basicTransfer(sender, recipient, amount); 
        }

        if(shouldSwapBack()){ 
            swapBack(); 
            }

        if(shouldAutoBuyback()){ 
            triggerAutoBuyback(); 
            }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 tokensToBurn = burnPercentage(amount);
        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

         if  (shouldBurnSender(sender) == false) {
            uint256 toReceiver = amountReceived;
            _balances[recipient] = _balances[recipient].add(toReceiver);
            emit Transfer(sender, recipient, toReceiver);
        } else {
             uint256 toReceiver = amountReceived.sub(tokensToBurn);
            _totalSupply = _totalSupply.sub(tokensToBurn);
            _balances[recipient] = _balances[recipient].add(toReceiver);
            AllTimeBurned = AllTimeBurned + tokensToBurn;
            emit Transfer(sender, recipient, toReceiver);
            emit Transfer(sender, address(0), tokensToBurn);
        }
        try distributor.process(distributorGas) {} catch {}
        return true;
    }

    /**
     * @dev If the sender or receiver is FeeExempt, a normal transaction
     * will be triggered without fees.
     *
     * NOTE: This also applies when the {SwapActive} boolean is set to false.
     */
    function _basicTransfer(
        address sender, 
        address recipient, 
        uint256 amount
        ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        uint256 tokensToBurn = burnPercentage(amount);

        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

         if  (shouldBurnSender(sender) == false) {
            uint256 toReceive = amount;
             _balances[recipient] += toReceive;
            emit Transfer(sender, recipient, toReceive);
            _afterTokenTransfer(sender, recipient, toReceive);
        } else {
            uint256 toReceive = amount - tokensToBurn;
            _balances[recipient] += toReceive;
            _totalSupply = _totalSupply.sub(tokensToBurn);
            AllTimeBurned = AllTimeBurned + tokensToBurn;
            burnedByWallet[sender] = burnedByWallet[sender] + tokensToBurn;
            emit Transfer(sender, recipient, toReceive);
            emit Transfer(sender, address(0), tokensToBurn);
            _afterTokenTransfer(sender, recipient, toReceive);
        }
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * This feature will only be used by the SenshiMaster contract for mining tokens and 
     * paying out to stakers and farmers. 
     *
     * NOTE: The onlyOwner role cannot access this function, only the SenshiMaster role can. 
     * This is to ensure that as long as the SenshiMaster is not yet the owner of this contract because
     * it is in a test phase, the current owner cannot just mint tokens. 
     *
     * When the SenshiMaster contract is found to be bug free, it will become the real owner of this contract 
     * and also own the SenshiMaster role.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
    @dev Calculate fees on transaction if SwapActive boolean is `True`, 
    * use _basicTransfer if `False` or if sender or recipient is `FeeExempt`.
     */
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function shouldBurnSender(address sender) internal view returns (bool) {
        return !isBurnExempt[sender];
    }

    /**
    @dev Adds all fees together and marks them as TotalFee, burn excluded.
     */
    function getTotalFee(bool selling) public view returns (uint256) {
        if(selling) { 
            return getMultipliedFee();
             }
        return TotalFee;
    }

    /**
    * @dev If BuyBack is active and the contract is in the process of buying back tokens and burning, 
    * the fees are increased for the duration of the buyback process. This is to discourage selling 
    * when the price rises (after all, we want diamond hands).
    *
    * NOTE: It is possible to turn off this multiplier during automatic buy backs.
     */
    function getMultipliedFee() public view returns (uint256) {
        if (BuyBackMultiplierTriggeredAt.add(BuyBackMultiplierLength) > block.timestamp) {
            uint256 remainingTime = BuyBackMultiplierTriggeredAt.add(BuyBackMultiplierLength).sub(block.timestamp);
            uint256 feeIncrease = TotalFee.mul(BuyBackMultiplierNumerator).div(BuyBackMultiplierDenominator).sub(TotalFee);
            return TotalFee.add(feeIncrease.mul(remainingTime).div(BuyBackMultiplierLength));
        }
        return TotalFee;
    }

    function takeFee(
        address sender, 
        address receiver, 
        uint256 amount
        ) internal returns (uint256) {
        if (isClaimGameActive == true && isRankPotsActive == true) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == Pair)).div(FeeDenominator);
        uint256 claimGameShare = feeAmount / 100 * claimGamePercentage;
        uint256 rankPotsShare = feeAmount / 100 * rankPotsPercentage;
        uint256 remainAmount = feeAmount - (claimGameShare - rankPotsShare);

        _balances[address(this)] = _balances[address(this)].add(remainAmount);
        _balances[address(claimGameAddress)] = _balances[address(claimGameAddress)].add(claimGameShare);
        _balances[address(rankPotsAddress)] = _balances[address(rankPotsAddress)].add(rankPotsShare);

        emit Transfer(sender, address(this), remainAmount);
        emit Transfer(sender, address(claimGameAddress), claimGameShare);
        emit Transfer(sender, address(rankPotsAddress), rankPotsShare);

        return amount.sub(feeAmount);
        }

        else if (isClaimGameActive == true && isRankPotsActive == false) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == Pair)).div(FeeDenominator);
        uint256 claimGameShare = feeAmount / 100 * claimGamePercentage;
        uint256 remainAmount = feeAmount - claimGameShare;

        _balances[address(this)] = _balances[address(this)].add(remainAmount);
        _balances[address(claimGameAddress)] = _balances[address(claimGameAddress)].add(claimGameShare);

        emit Transfer(sender, address(this), remainAmount);
        emit Transfer(sender, address(claimGameAddress), claimGameShare);

        return amount.sub(feeAmount);
        }

        else if (isClaimGameActive == false && isRankPotsActive == true) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == Pair)).div(FeeDenominator);
        uint256 rankPotsShare = feeAmount / 100 * rankPotsPercentage;
        uint256 remainAmount = feeAmount - rankPotsShare;

        _balances[address(this)] = _balances[address(this)].add(remainAmount);
        _balances[address(rankPotsAddress)] = _balances[address(rankPotsAddress)].add(rankPotsShare);

        emit Transfer(sender, address(this), remainAmount);
        emit Transfer(sender, address(rankPotsAddress), rankPotsShare);

        return amount.sub(feeAmount);
        }

        else {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == Pair)).div(FeeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
        }
    }

    /**
    * @dev When the set threshold is reached, activate {swapBack()}.
    *
    * NOTE: If SwapActive is boolean False or sender/ricipient is FeeExempt, 
    * the threshold will not be swapped.
    */
    function shouldSwapBack() internal view returns (bool) {
        return _msgSender() != Pair
        && !InSwap
        && SwapActive
        && _balances[address(this)] >= swapThreshold;
    }

        /**
        * @dev Some of the collected tokens will be swapped back to WBNB for
        * buybacks and the other portion will be used to create additional liquidity and
        * send the Kazama-LP (liquidity provider) tokens to the DEAD address.
         */
        function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(TargetLiquidity, TargetLiquidityDenominator) ? 0 : LiqGeneratorFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(TotalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance;

        Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = TotalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBTreasury = amountBNB.mul(TreasuryFee).div(totalBNBFee);
        uint256 amountBNBRewards = amountBNB.mul(RewardsFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBRewards}() {} catch {}
        payable(TreasuryReceiver).transfer(amountBNBTreasury);

        if(amountToLiquify > 0){
            Router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                LiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    /**
    * @dev Calculate whether automatic buyback should be activated.
     */
    function shouldAutoBuyback() internal view returns (bool) {
        return _msgSender() != Pair
        && !InSwap
        && AutoBuyBackActive
        && AutoBuyBackBlockLast + AutoBuyBackBlockPeriod <= block.number
        && address(this).balance >= AutoBuyBackAmount;
    }

    /**
    * @dev If necessary, the contract can be manually instructed to make a buyback.
    * NOTE: Including the possibility to turn off the multiplier during the buyback period.
     */
    function triggerKazamaBuyback(uint256 amount, bool triggerBuybackMultiplier) external onlyZaibatsu {
        buyKazama(amount, BURN);
        if(triggerBuybackMultiplier){
            BuyBackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(BuyBackMultiplierLength);
        }
    }

    function clearBuybackMultiplier() external onlyZaibatsu {
        BuyBackMultiplierTriggeredAt = 0;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyZaibatsu {
        uint256 amountBNB = address(this).balance;
        payable(ZaibatsuHoldings).transfer(amountBNB * amountPercentage / 100);
    }

    function setClaimGameStatus(bool _status) external onlyZaibatsu {
        isClaimGameActive = _status;
    }

    function setRankPotsStatus(bool _status) external onlyZaibatsu {
        isRankPotsActive = _status;
    }

    function setClaimGamePercentage(uint256 _claimGamePercentage) external onlyJin {
        require(_claimGamePercentage >= 1, 'Cannot be lower than 1% ..');
        require(_claimGamePercentage <= 5, 'Cannot be higher than 5% ..');
        claimGamePercentage = _claimGamePercentage;
    }

    function setRankPotsPercentage(uint256 _rankPotsPercentage) external onlyJin {
        require(_rankPotsPercentage >= 1, 'Cannot be lower than 1% ..');
        require(_rankPotsPercentage <= 5, 'Cannot be higher than 5% ..');
        rankPotsPercentage = _rankPotsPercentage;
    }

    function clearStuckDistributorTokens(address _address, uint256 amount) external onlyJin {
        require(_address != address(rewardToken), "Cannot be the reward token");
        distributor.clearStuckDistributorTokens(_address, amount);
    }

    function setSenshiNftAddress(address _senshiAddress) external onlyJin {
        distributor.setSenshiNftAddress(_senshiAddress);
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyJin {
        require(_tokenAddress != address(this), "Cannot be KAZAMA token");
        IBEP20(_tokenAddress).transfer(address(ZaibatsuHoldings), _tokenAmount);
        emit RecoverTokens(_tokenAddress, _tokenAmount);
    }

    /**
    * @dev If it is decided to increase or decrease the burning percentage.
    * Min of 0.1% / Max of 7%
    */
    function setBurnPercentage(uint256 _BurnPercentSettings) external onlyZaibatsu {
        require(_BurnPercentSettings >= 100, 'Cannot be lower than 0.1% ..');
        require(_BurnPercentSettings <= 7000, 'Cannot be higher than 7% ..');
        BurnPercentSettings = _BurnPercentSettings;
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyJin {
        require(holder != address(this) && holder != Pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function triggerAutoBuyback() internal {
        buyKazama(AutoBuyBackAmount, BURN);
        AutoBuyBackBlockLast = block.number;
        AutoBuyBackAccumulator = AutoBuyBackAccumulator.add(AutoBuyBackAmount);
        if(AutoBuyBackAccumulator > AutoBuyBackCap) { 
           AutoBuyBackActive = false;
         }
    }

    function buyKazama(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );

        _totalSupply = _totalSupply.sub(AutoBuyBackAmount);
        AllTimeBurned = AllTimeBurned + AutoBuyBackAmount;

    }

    /**
    * @dev Function to configure the automatic buybacks.
     */
    function setAutoBuybackSettings(bool _enabled, uint256 _cap, uint256 _amount, uint256 _period) external onlyZaibatsu {
        AutoBuyBackActive = _enabled;
        AutoBuyBackCap = _cap;
        AutoBuyBackAccumulator = 0;
        AutoBuyBackAmount = _amount;
        AutoBuyBackBlockPeriod = _period;
        AutoBuyBackBlockLast = block.number;
    }

    /**
    * @dev If the automatic buybacks use the multiplier during the buyback period, 
    * a lower or higher multiplier can be set + the duration of the buyback.
     */
    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external onlyZaibatsu {
        require(numerator / denominator <= 2 && numerator > denominator);
        BuyBackMultiplierNumerator = numerator;
        BuyBackMultiplierDenominator = denominator;
        BuyBackMultiplierLength = length;
    }

    /**
    * @dev Free a wallet or contract from fees.
    * This will be required if third parties make applications that integrate our token. 
    * Also useful for our own applications.
     */
    function setIsFeeExempt(address holder, bool exempt) external onlyZaibatsu {
        isFeeExempt[holder] = exempt;
    }

    /**
    * @dev Free a wallet or contract from burning tokens on transactions.
    * Useful for our applications, like a bridge.
     */
    function setIsBurnExempt(address holder, bool exempt) external onlyZaibatsu {
        isBurnExempt[holder] = exempt;
    }

    /**
    * @dev If necessary to change the fees.
    *
    * NOTE: All fees added together can never be set higher than 13% (TotalFee).
     */
    function setFees(uint256 _LiqGeneratorFee, uint256 _BuyBackBurnFee, uint256 _TreasuryFee, uint256 _RewardsFee) external onlyJin {
        LiqGeneratorFee = _LiqGeneratorFee;
        BuyBackBurnFee = _BuyBackBurnFee;
        TreasuryFee = _TreasuryFee;
        RewardsFee = _RewardsFee;
        TotalFee = _LiqGeneratorFee.add(_BuyBackBurnFee).add(_TreasuryFee).add(_RewardsFee);
        // TotalFee checks
        require (TotalFee >= 4, 'EXCEEDS MIN: Total fee must be equal to `4` or higher ..');
        require (TotalFee <= 13, 'EXCEEDS MAX: Total fee must be equal to `13` or lower ..');
    }

    function setFeeReceivers(address _TreasuryReceiver) external onlyJin {
        TreasuryReceiver = _TreasuryReceiver;
    }

    function setZaibatsuHoldings(address _ZaibatsuHoldings) external onlyJin {
        ZaibatsuHoldings = _ZaibatsuHoldings;
    }

   function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyZaibatsu {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
        emit DistributionData (_minPeriod, _minDistribution);
    }

    function setRewardToken(address _rewardToken) external onlyJin {
        distributor.setRewardToken(_rewardToken);
        rewardToken = _rewardToken;
    }

    function setKazamaToken(address _kazamaToken) external onlyJin {
        distributor.setKazamaToken(_kazamaToken);
    }

    function setDistributorSettings(uint256 gas) external onlyZaibatsu {
        require(gas < 15000000);
        distributorGas = gas;
    }

    /**
    * @dev Set SwapActive to `True` or `False` (If `True`, the configured threshold is used for the swaps).
     */
    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyZaibatsu {
        SwapActive = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyJin {
        TargetLiquidity = _target;
        TargetLiquidityDenominator = _denominator;
    }

    /**
    * @dev Output the total supply. If tokens are sent to the DEAD address
    * by someone for whatever reason, we will subtract them from `_totalSupply`.
     */
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(Pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
}

contract KazamaSenshi is BEP20 ("Kazama Senshi", "KAZAMA") {
    using SafeMath for uint256;

    /// @notice Creates `_amount` token to `_to`. Must only be called by an contract with the SenshiMaster role (i.e SenshiMaster & Bridge contract).
    function mint(address _to, uint256 _amount) public onlySenshiMaster {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
        AllTimeMinted = AllTimeMinted + _amount;
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
        AllTimeBurned = AllTimeBurned + amount;
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    mapping (address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

      /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /**
     * @notice Delegate votes from `_msgSender()` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

   /**
    * @notice Delegate votes from `_msgSender()` to `delegatee`
    * @param delegatee The address to delegate votes to
    */
    function delegate(address delegatee) external {
        return _delegate(_msgSender(), delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "KAZAMA [delegateBySig]: Invalid signature");
        require(nonce == nonces[signatory]++, "KAZAMA [delegateBySig]: Invalid nonce");
        require(block.timestamp <= expiry, "KAZAMA [delegateBySig]: Signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "KAZAMA [getPriorVotes]: Not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); 
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);
        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "KAZAMA [_writeCheckpoint]: Block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}