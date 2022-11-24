/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// File: bkc/token/ERC20/IERC20.sol

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
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

// File: openzeppelin/introspection/IERC165.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// File: bkc/token/ERC721/IERC721.sol

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    event MintNft(address indexed receiver, uint256 tokenId, uint256 level);

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    function mintNft(address receiver, uint256 level) external returns (uint256);

    function setBaseURI(string calldata baseURI) external;

    function burn(uint256 tokenId) external;

    function getCurrentTokenId() external view virtual returns (uint256);

    function getNftLevel(uint256 tokenId) external view virtual returns (uint256); 
}

// File: bkc/token/ERC721/IERC721Enumerable.sol

pragma solidity >=0.6.2 <0.8.0;

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

// File: bkc/utils/Ownable.sol

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin/math/SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: openzeppelin/interface/IPancakeFactory.sol

pragma solidity >=0.6.0 <0.8.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// File: openzeppelin/interface/IPancakeRouter.sol

pragma solidity >=0.6.0 <0.8.0;

interface IPancakeRouter {
    function factory() external pure returns (address);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidity(
        address tokenA,address tokenB,uint amountADesired,uint amountBDesired,
        uint amountAMin,uint amountBMin,address to,uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

// File: openzeppelin/interface/IPancakePair.sol

pragma solidity >=0.6.0 <0.8.0;

interface IPancakePair {
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

// File: bkc/token/ERC20/BkcERC20.sol

pragma solidity >=0.6.0 <0.8.0;







contract BkcERC20 is Context, Ownable, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    address private airAddress;
    address private saleAddress;
    address private usdtOwner;
    address private lpAddress;

    address private mbankBurn;
    address private bkcBurn;
    address private nftBonus;
    address private market1;
    address private market2;
    address private destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    address private mbankContract = address(0x9E9Bef94795Bfe87a11A0369B4e0c3B60A6FCf2B);
    address public usdt = address(0x55d398326f99059fF775485246999027B3197955);

    address public pair;
    IPancakeRouter public pancakeRouter;
    IERC721Enumerable private bkc721;

    bool    private swapping;
    uint256 public minsell;     //BKC
    uint256 public minAddLp;    //USDT
    uint256 public minMbankBurn;//USDT
    uint256 public minBkcBurn;  //USDT
    uint256 public minNftBonus; //USDT
    uint256 public bonusAmount; //USDT
    uint256 public index = 1;

    constructor (address router_, address nftBonus_, address mbankBurn_, address bkcBurn_, address market1_, address market2_, address bkc721_, 
                 address airAddress_, address saleAddress_, address lpAddress_, address fundAddress_, uint256 saleAmount_, uint256 lpAmount_, uint256 fundAmount_) public {
        _name = "Metabank coin";
        _symbol = "BKC";
        _decimals = 18;

        minsell = 10 * 10**8 * 10**18;
        minAddLp = 2000 * 10**18;
        minMbankBurn = 3000 * 10**18;
        minBkcBurn = 3000 * 10**18;
        minNftBonus = 25 * 10**18;
        bonusAmount = 5 * 10**18;
        
        usdtOwner = msg.sender;
        
        airAddress = airAddress_;
        saleAddress = saleAddress_;
        lpAddress = lpAddress_;
        nftBonus = nftBonus_;
        market1 = market1_;
        market2 = market2_; 
        mbankBurn = mbankBurn_;
        bkcBurn = bkcBurn_;

        bkc721 = IERC721Enumerable(bkc721_);
        
        _mint(saleAddress_, saleAmount_ * 10**18);
        _mint(lpAddress_, lpAmount_ * 10**18);
        _mint(fundAddress_, fundAmount_ * 10**18);

        pancakeRouter = IPancakeRouter(router_);
        pair = IPancakeFactory(pancakeRouter.factory()).createPair(address(this), usdt);
    }
    
    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");
        
        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        if (from == saleAddress || from == airAddress) {
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);
            return;
        } 
        
        uint256 addLpAmount = IERC20(usdt).balanceOf(address(this));
        if (addLpAmount >= minAddLp && !swapping && from != pair) {
            swapping = true;
            _doAddLP(addLpAmount);
            swapping = false;
        }
        
        uint256 bkcBurnAmount = IERC20(usdt).balanceOf(bkcBurn);
        if (bkcBurnAmount >= minBkcBurn && !swapping && from != pair) {
            swapping = true;
            _doBkcBurn(bkcBurnAmount);
            swapping = false;
        }

        uint256 mbankBurnAmount = IERC20(usdt).balanceOf(mbankBurn);
        if (mbankBurnAmount >= minMbankBurn && !swapping && from != pair) {
            swapping = true;
            _doMbankBurn(mbankBurnAmount);
            swapping = false;
        }

        uint256 nftBonusAmount = IERC20(usdt).balanceOf(nftBonus);
        if (nftBonusAmount >= minNftBonus && !swapping && from != pair) {
            _doNftBonus();
        }

        uint256 bkcSellAmount = balanceOf(address(this));
        if (bkcSellAmount >= minsell && !swapping && from != pair) {
            swapping = true;
            _doSwapAndDividend(bkcSellAmount);
            swapping = false;
        }
        
        if (from == pair || to == pair) {
             if (to == pair) { //sell, add
                (uint112 r0, uint112 r1, ) = IPancakePair(pair).getReserves();
                uint112 reserveUsdt;
                uint256 amountUsdt;
                if (r0 > 0 && r1 > 0) {
                    if (IPancakePair(pair).token0() == address(this)) {
                        reserveUsdt = r1;
                        amountUsdt = pancakeRouter.quote(amount, r0, r1);
                    } else {
                        reserveUsdt = r0;
                        amountUsdt = pancakeRouter.quote(amount, r1, r0);
                    }
                }
                if (IERC20(usdt).balanceOf(pair) < reserveUsdt + amountUsdt) {
                    uint256 feeAmount = amount.div(100).mul(6);
                    _takeFee(from, address(this), feeAmount);

                    amount -= feeAmount;
                } 
            }

            if (from == pair) { //buy, sub
                (uint112 r0, uint112 r1, ) = IPancakePair(pair).getReserves();
                uint112 reserveUsdt;
                uint256 amountUsdt;
                if (r0 > 0 && r1 > 0) {
                    if (IPancakePair(pair).token0() == address(this)) {
                        reserveUsdt = r1;
                        amountUsdt = pancakeRouter.getAmountIn(amount, r1, r0);
                    } else {
                        reserveUsdt = r0;
                        amountUsdt = pancakeRouter.getAmountIn(amount, r0, r1);
                    }
                }
                if (IERC20(usdt).balanceOf(pair) >= reserveUsdt + amountUsdt) {
                    uint256 feeAmount = amount.div(100).mul(6);
                    _takeFee(from, address(this), feeAmount);

                    amount -= feeAmount;
                } 
            }
        }
        
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function _doNftBonus() private {
        uint256 size = bkc721.totalSupply();
        address user;
        uint256 i = index;
        uint256 done = 0;

        while(i <= size && done < 5) {
            user = bkc721.ownerOf(i);

            if (!isContract(user) && user != address(0)) {
                IERC20(usdt).transferFrom(nftBonus, user, bonusAmount);
            } 

            done++;
            i++;
        }
        
        if (i > size) { i = 1; }
        index = i;
    }

    function _doMbankBurn(uint256 usdtAmount) private {
        IERC20(usdt).transferFrom(mbankBurn, address(this), usdtAmount);
        _swapUsdtForToken(mbankContract, usdtAmount, destroyAddress);
    }

    function _doBkcBurn(uint256 usdtAmount) private {
        IERC20(usdt).transferFrom(bkcBurn, address(this), usdtAmount);
        _swapUsdtForToken(address(this), usdtAmount, destroyAddress);
    }

    function _doAddLP(uint256 usdtAmount) private {
        uint256 halfUsdtAmount = usdtAmount / 2;

        uint256 tokenAmountStart = balanceOf(usdtOwner);
        _swapUsdtForToken(address(this), halfUsdtAmount, usdtOwner);
        uint256 tokenAmountEnd = balanceOf(usdtOwner);

        uint256 tokenAmount = tokenAmountEnd - tokenAmountStart;
        _takeTransfer(usdtOwner, address(this), tokenAmount);

        _addLP(tokenAmount, usdtAmount-halfUsdtAmount);
    }

    function _addLP(uint256 tokenAmount, uint256 usdtAmount) private {
        _approve(address(this), address(pancakeRouter), tokenAmount);
        IERC20(usdt).approve(address(pancakeRouter), usdtAmount);
        pancakeRouter.addLiquidity(
            address(this),
            usdt,
            tokenAmount,
            usdtAmount,
            0, 
            0, 
            lpAddress,
            block.timestamp
        );
    }

    function _takeTransfer(address from, address to, uint256 amount) private {
        _balances[from] = _balances[from].sub(amount, "ERC20: amount exceeds balance");
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function _doSwapAndDividend(uint256 tokenAmount) private {
        _swapTokenForUsdt(tokenAmount, usdtOwner);
        
        uint256 usdtAmount = IERC20(usdt).balanceOf(usdtOwner);
        if (usdtAmount > 0) {
            uint256 dividendUsdt10 = usdtAmount.div(120).mul(10);
            uint256 dividendUsdt20 = usdtAmount.div(120).mul(20);
            uint256 dividendUsdt30 = usdtAmount.div(120).mul(30);
            uint256 addBkcUsdtLp = usdtAmount - 2*dividendUsdt10 - dividendUsdt20 - 2*dividendUsdt30;
            
            IERC20(usdt).transferFrom(usdtOwner, nftBonus, dividendUsdt30);
            IERC20(usdt).transferFrom(usdtOwner, mbankBurn, dividendUsdt30);
            IERC20(usdt).transferFrom(usdtOwner, market1, dividendUsdt10);
            IERC20(usdt).transferFrom(usdtOwner, market2, dividendUsdt10);
            IERC20(usdt).transferFrom(usdtOwner, bkcBurn, dividendUsdt20);
            IERC20(usdt).transferFrom(usdtOwner, address(this), addBkcUsdtLp);//20
        } 
    }
    
    function _swapUsdtForToken(address tokenB, uint256 usdtAmount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = usdt;
        path[1] = tokenB;
        IERC20(usdt).approve(address(pancakeRouter), usdtAmount);
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount, 0, path, receiver, block.timestamp);
    }

    function _swapTokenForUsdt(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _approve(address(this), address(pancakeRouter), tokenAmount);
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, receiver, block.timestamp);
    }

    function _takeFee(address from, address to, uint256 amount) private {
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function setMinsell(uint256 val) public onlyOwner {
        minsell = val * 10**18;
    }

    function setMinAddLp(uint256 val) public onlyOwner {
        minAddLp = val * 10**18;
    }

    function setMinMbankBurn(uint256 val) public onlyOwner {
        minMbankBurn = val * 10**18;
    }

    function setMinBkcBurn(uint256 val) public onlyOwner {
        minBkcBurn = val * 10**18;
    }

    function setMinNftBonus(uint256 val) public onlyOwner {
        minNftBonus = val * 10**18;
    }

    function setBonusAmount(uint256 val) public onlyOwner {
        bonusAmount = val;
    }

}