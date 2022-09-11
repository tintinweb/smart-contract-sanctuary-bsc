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

// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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


pragma solidity ^0.8.0;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

pragma solidity ^0.8.0;

interface IUniswapV2Router {

    function factory() external view returns (address);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

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

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

}

pragma solidity ^0.8.0;

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
}

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

}

pragma solidity ^0.8.0;

interface IMonkeyBarisNFT {

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function mintForFeelLucky(address _receiver) external returns (uint256);

}

pragma solidity ^0.8.8;

contract MonkeyBaristaMysteryBoxPool is ERC721Holder, Pausable, Ownable {

    uint256 constant MAX_INT = 2**256 - 1;

    using SafeMath for uint256;

    struct MysteryBox {
        uint256 price;
        address developer;
        address usdt;
        address tmon;
        address nft;
    }

    struct Pool {
        uint256 accPerShare;
        uint256 nftNumber;
    }

    struct Uniswap {
        IUniswapV2Router uniswapV2Router;
        IPancakeFactory uniswapFactory;
        IPancakePair uniswapPair;
    }

    struct Lottery {
        uint256 rndMax;
        uint256 rndInc;
        uint256 rndEndTime;
        uint256 amount;
        address lastAddr;
    }

    struct NFTLP {
        uint256 baseLP;
        uint256 debtLP;
    }

    MysteryBox public mysteryBox;
    Pool public pool;
    Uniswap public uniswap;
    Lottery public lottery;
    mapping(uint256 => NFTLP) public nftLPMapping;

    constructor(uint256 _rndMax) {
        lottery.rndMax = _rndMax;
        lottery.rndInc = 30;
        lottery.rndEndTime = block.timestamp+_rndMax;
        lottery.lastAddr = address(this);
    }

    function initialize(
        uint256 price,
        address developer,
        address usdt,
        address tmon,
        address nft,
        address uniswapV2RouterAddr
    ) external onlyOwner {
        mysteryBox = MysteryBox({
            price : price,
            developer : developer,
            usdt : usdt,
            tmon : tmon,
            nft : nft
        });

        IUniswapV2Router uniswapV2Router = IUniswapV2Router(uniswapV2RouterAddr);
        IPancakeFactory uniswapFactory = IPancakeFactory(uniswapV2Router.factory());
        uniswap = Uniswap({
            uniswapV2Router : uniswapV2Router,
            uniswapFactory : uniswapFactory,
            uniswapPair : IPancakePair(uniswapFactory.getPair(usdt, tmon))
        });

        IERC20(usdt).approve(address(uniswap.uniswapV2Router), MAX_INT);
        IERC20(tmon).approve(address(uniswap.uniswapV2Router), MAX_INT);
        IERC20(address(uniswap.uniswapPair)).approve(address(uniswap.uniswapV2Router), MAX_INT);
    }

    function updateLottery(uint256 rndMax, uint256 rndInc) external onlyOwner {
        lottery.rndMax = rndMax;
        lottery.rndInc = rndInc;
    }

    function openMysteryBox() external whenNotPaused {
        require(_msgSender().code.length <= 0, "Pool: address error");

        TransferHelper.safeTransferFrom(
            mysteryBox.usdt, 
            _msgSender(),
            address(this),
            mysteryBox.price
        );

        uint256 nftId = IMonkeyBarisNFT(mysteryBox.nft).mintForFeelLucky(_msgSender());

        mint(nftId);
    }

    function openMysteryBoxList(uint256 number) external whenNotPaused {
        require(_msgSender().code.length <= 0, "Pool: address error");

        TransferHelper.safeTransferFrom(
            mysteryBox.usdt, 
            _msgSender(),
            address(this),
            mysteryBox.price*number
        );

        for(uint256 index=0; index<number; index++) {
            uint256 nftId = IMonkeyBarisNFT(mysteryBox.nft).mintForFeelLucky(_msgSender());

            mint(nftId);
        }
        
    }

    function withdrawLottery() private {
        if(block.timestamp < lottery.rndEndTime) {
            return;
        }
        uint256 withdrawAmount = lottery.amount*80/100;

        lottery.amount = lottery.amount-withdrawAmount;
        lottery.rndEndTime = block.timestamp+lottery.rndMax;

        TransferHelper.safeTransfer(mysteryBox.usdt, lottery.lastAddr, withdrawAmount);
    }

    function updateLottery(uint256 amount, address lastAddr) private {
        if((block.timestamp + lottery.rndMax) > lottery.rndEndTime) {
            lottery.rndEndTime += lottery.rndInc;
        }
        lottery.amount += amount;
        lottery.lastAddr = lastAddr;
    }

    function updateReward(uint256 reward) private {
        if(pool.nftNumber == 0) {
            return;
        }
        pool.accPerShare += reward/pool.nftNumber;
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = uniswap.uniswapPair.getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function mint(uint256 nftId) private {
        withdrawLottery();

        uint256 devFee = mysteryBox.price/20;
        TransferHelper.safeTransfer(mysteryBox.usdt, mysteryBox.developer, devFee);

        uint256 swapUsdtAmount = mysteryBox.price*15/100;
        address[] memory path = new address[](2);
        path[0] = mysteryBox.usdt;
        path[1] = mysteryBox.tmon;
        (uint[] memory amounts) = uniswap.uniswapV2Router.swapExactTokensForTokens(
            swapUsdtAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        IERC20(mysteryBox.tmon).burn(amounts[1]);

        uint256 lotteryAmount = mysteryBox.price/20;
        updateLottery(lotteryAmount, _msgSender());

        uint256 addLiquidityUsdtAmount = mysteryBox.price-devFee-swapUsdtAmount-lotteryAmount;
        (uint reserveA, uint reserveB) = getReserves(mysteryBox.usdt, mysteryBox.tmon);
        uint addLiquidityTMONAmount = quote(addLiquidityUsdtAmount, reserveA, reserveB);
        uint256 thisTMONBalance = IERC20(mysteryBox.tmon).balanceOf(address(this));
        require(thisTMONBalance >= addLiquidityTMONAmount, "Pool: insufficient amount");
        (, , uint256 liquidity) = uniswap.uniswapV2Router.addLiquidity(
            mysteryBox.usdt,
            mysteryBox.tmon,
            addLiquidityUsdtAmount,
            addLiquidityTMONAmount,
            0,
            0,
            address(this),
            block.timestamp
        );

        uint256 reward = liquidity/10;
        updateReward(reward);
        nftLPMapping[nftId] = NFTLP({
            baseLP : liquidity-reward,
            debtLP : pool.accPerShare
        });
        pool.nftNumber +=1;
    }

    function innerGetLpNumber(uint256 nftId) private view returns(uint256) {
        NFTLP memory nftLp = nftLPMapping[nftId];
        if(nftLp.baseLP == 0) {
            return 0;
        }

        return nftLp.baseLP.add(pool.accPerShare).sub(nftLp.debtLP);
    }

    function getLpNumber(uint256 nftId) external view returns(uint256) {
        return innerGetLpNumber(nftId);
    }

    function getUsdt(uint256 nftId) external view returns(uint256) {
        uint256 totalSupplyPair = IERC20(address(uniswap.uniswapPair)).totalSupply();
        uint256 liquidity = innerGetLpNumber(nftId);
        uint256 usdtBalancePair = IERC20(mysteryBox.usdt).balanceOf(address(uniswap.uniswapPair));
        return liquidity.mul(usdtBalancePair)/totalSupplyPair;
    }

    function burn(uint256 nftId) private returns(uint256) {
        uint256 liquidity = innerGetLpNumber(nftId);
        require(liquidity != 0, "Pool: nftId error");

        (uint amountA,) = uniswap.uniswapV2Router.removeLiquidity(
            mysteryBox.usdt,
            mysteryBox.tmon,
            liquidity,
            0,
            0,
            address(this),
            block.timestamp
        );

        delete nftLPMapping[nftId];
        pool.nftNumber -=1;
        IMonkeyBarisNFT(mysteryBox.nft).safeTransferFrom(_msgSender(), address(this), nftId);
        TransferHelper.safeTransfer(mysteryBox.usdt, _msgSender(), amountA);

        return amountA;
    }

    function burnList(uint256[] memory nftIdList) external returns(uint256[] memory amountList) {
        amountList = new uint256[](nftIdList.length);
        for(uint256 index=0; index<nftIdList.length; index++) {
            amountList[index] = burn(nftIdList[index]);
        }
    }

    function safeTransferToken(address token, address to, uint value) external onlyOwner {
        TransferHelper.safeTransfer(token, to, value);
    }

    function safeTransferNFT(uint256 nftId, address to) external onlyOwner {
        IMonkeyBarisNFT(mysteryBox.nft).safeTransferFrom(address(this), to, nftId);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() external virtual onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() external virtual onlyOwner whenPaused {
        _unpause();
    }

}