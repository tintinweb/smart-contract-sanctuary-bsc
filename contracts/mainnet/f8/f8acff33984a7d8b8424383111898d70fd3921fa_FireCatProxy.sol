// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IPancakeRouter02} from "../src/interfaces/IPancakeRouter02.sol";
import {IFireCatReserves} from "../src/interfaces/IFireCatReserves.sol";
import {IFireCatTreasury} from "../src/interfaces/IFireCatTreasury.sol";
import {FireCatTransfer} from "../src/utils/FireCatTransfer.sol";
import {IFireCatProxy} from "../src/interfaces/IFireCatProxy.sol";
import {IFireCatNFT} from "../src/interfaces/IFireCatNFT.sol";
import {IWETH} from "src/interfaces/IWETH.sol";

/**
 * @title FireCat's Invest Proxy Contract
 * @notice Invest logic
 * @author FireCat Finance
 */
contract FireCatProxy is IFireCatProxy, Ownable, ReentrancyGuard  {
    using SafeMath for uint256;

    event SwapWETHFor(uint256 actualAddAmountETH, uint256 actualAddAmountToken);
    event AddLiquidity(uint256 amountToken, uint256 amountETH, uint256 actualAddLP);
    event SetLiquidityConfig(address pool, address tokenA, address tokenB);
    event SetInvestAmount(uint256 amount);
    event SetLPSlippage(uint256 numerator, uint256 denominator);
    event SetAssetsInFactor(uint256 numerator, uint256 denominator);
    event SetFireCatNFT(address fireCatNFT_);
    event SetFireCatReserves(address fireCatReserves_);
    event SetFireCatTreasury(address fireCatTreasury_);
    event SetSwapRouter(address swapRouter_);
    event WithdrawRemaining(address user_, address token_, uint256 amount_);
    event Invest(address user, uint256 amount, uint256 tokenId);

    address public fireCatNFT;
    address public fireCatReserves;
    address public fireCatTreasury;
    address public swapRouter;
    uint256 public investAmount;

    /**
    * @dev The minimum amount of token to provide liquidity.  _slippageNumerator / _slippageDenominator = 0.995
    */
    uint256 private _slippageNumerator = 995;
    uint256 private _slippageDenominator = 1000;

    /**
    * @dev 95% funds transfer to FireCatTreasury.  _assetsInNumerator / _assetsInDenominator = 0.95
    */
    uint256 private _assetsInNumerator = 95;
    uint256 private _assetsInDenominator = 100;

    address private _liquidityPool;

     /**
    * @dev Add liquidity pool params: tokenA, tokenB.
    */
    address[] private _path = [address(0), address(0)];

    receive() external payable{}

    fallback() external payable {}

    constructor(
        address fireCatNFT_, 
        address fireCatReserves_,
        address fireCatTreasury_,
        address swapRouter_, 
        uint256 investAmount_
    ) {
        fireCatNFT = fireCatNFT_;
        fireCatReserves = fireCatReserves_;
        fireCatTreasury = fireCatTreasury_;
        swapRouter = swapRouter_;
        investAmount = investAmount_;
    }

    /// @inheritdoc IFireCatProxy
    function mintAllowed(address user) public view returns (bool) {
        return !IFireCatNFT(fireCatNFT).hasMinted(user);
    }

    /// @inheritdoc IFireCatProxy
    function treasuryToken() public view returns (address) {
        return IFireCatTreasury(fireCatTreasury).treasuryToken();
    }

    /// @inheritdoc IFireCatProxy
    function reservesToken() public view returns (address) {
        return IFireCatReserves(fireCatReserves).reservesToken();
    }
    
    /// @inheritdoc IFireCatProxy
    function assetsInFactor() public view returns (uint256, uint256) {
        return (_assetsInNumerator, _assetsInDenominator);
    }

    /// @inheritdoc IFireCatProxy
    function liquiditySlippage() public view returns (uint256, uint256) {
        return (_slippageNumerator, _slippageDenominator);
    }
    
    /// @inheritdoc IFireCatProxy
    function liquidityMinProvide(uint256 amount) public view returns (uint256) {
        return amount * _slippageNumerator / _slippageDenominator;
    }

    /// @inheritdoc IFireCatProxy
    function getAssetsIn(uint256 amount) public view returns (uint256) {
        return amount * _assetsInNumerator / _assetsInDenominator;
    }

    /// @inheritdoc IFireCatProxy
    function liquidityPool() public view returns (address) {
        return _liquidityPool; 
    }

    /// @inheritdoc IFireCatProxy
    function liquidityToken() public view returns (address, address) {
        return (_path[0], _path[1]); 
    }

    /**
    * @notice Swap WETH to exact token.
    * @dev Call swapExactETHForTokens method from IPancakeRouter02.
    * @param amount uint256.
    * @return addETH, addToken (uint256, uint256).
    */
    function _swapWETHFor(uint256 amount) internal returns (uint256, uint256) {
        uint256 assetsSwapAmount = amount.div(2);
        uint256[] memory amounts = IPancakeRouter02(swapRouter).getAmountsOut(assetsSwapAmount, _path);
        
        uint256[] memory actualAddAmount = IPancakeRouter02(swapRouter).swapExactETHForTokens{value: assetsSwapAmount}(
            amounts[1],  // The minimum amount tokens to receive.
            _path,  // An array of token addresses. path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity.
            address(this),  // Address of recipient.
            block.timestamp  // Unix timestamp deadline by which the transaction must confirm.
        );

        uint256 actualAddAmountETH = actualAddAmount[0];
        uint256 actualAddAmountToken = actualAddAmount[1];
        require(actualAddAmountETH > 0 && actualAddAmountToken > 0, "PXY:E02");
        emit SwapWETHFor(actualAddAmountETH, actualAddAmountToken);
        return (actualAddAmountETH, actualAddAmountToken);
    }

    /**
    * @notice Add liquidity to exact pool.
    * @dev Call addLiquidityETH method from IPancakeRouter02.
    * @param ethAmount_ uint256
    * @param tokenAmount_ uint256
    * @return actualAddLP uint256.
    */
    function _addLiquidity(uint256 ethAmount_, uint256 tokenAmount_) internal returns (uint256) {
        uint256 addBefore = IERC20(_liquidityPool).balanceOf(address(this));
        address tokenB = _path[1];
        IERC20(tokenB).approve(swapRouter, tokenAmount_);
        
        (uint amountToken, uint amountETH, ) = IPancakeRouter02(swapRouter).addLiquidityETH{value: ethAmount_}(
            tokenB,  // The contract address of the token to add liquidity.
            tokenAmount_,  // The amount of the token you'd like to provide as liquidity.
            liquidityMinProvide(tokenAmount_),  // The minimum amount of the token to provide (slippage impact).
            liquidityMinProvide(ethAmount_),  // The minimum amount of ETH to provide (slippage impact).
            address(this),  // Address of LP Token recipient.
            block.timestamp
        );

        uint256 addAfter = IERC20(_liquidityPool).balanceOf(address(this));
        uint256 actualAddLP = addAfter.sub(addBefore);
        require(actualAddLP > 0, "PXY:E03");
        emit AddLiquidity(amountToken, amountETH, actualAddLP);
        return actualAddLP;
    }
    
    /**
    * @notice Deposit LP into the treasury Contract.
    * @dev Call addTreasury method from fireCatTreasury.
    * @param user address.
    * @param actualAddLP uin256. 
    */
    function _transferInTreasury(address user, uint256 actualAddLP) internal {
        uint256 tokenId = IFireCatNFT(fireCatNFT).freshTokenId();
        IERC20(treasuryToken()).approve(fireCatTreasury, actualAddLP);
        uint256 actualAddTreasury = IFireCatTreasury(fireCatTreasury).addTreasury(user, tokenId, actualAddLP);
        require(actualAddTreasury > 0, "PXY:E04");
    }

    /**
    * @notice Deposit WBNB into the reserves Contract.
    * @dev Call addReserves method from fireCatReserves.
    * @param user address.
    */
    function _transferInReserves(address user) internal {
        IWETH _reservesToken = IWETH(reservesToken());
        IERC20 _tokenB = IERC20(_path[1]);

        _reservesToken.deposit{value: address(this).balance}();
        uint256 remainWETH = _reservesToken.balanceOf(address(this));
        _reservesToken.approve(fireCatReserves, remainWETH);
        uint256 actualAddReserves = IFireCatReserves(fireCatReserves).addReserves(user, remainWETH);
        require(actualAddReserves > 0, "PXY:E05");

        uint256 beforeBalance = _tokenB.balanceOf(address(this));
        if (beforeBalance > 0) {
            _tokenB.transfer(fireCatReserves, beforeBalance);
            uint256 afterBalance = _tokenB.balanceOf(address(this));
            require(afterBalance == 0, "PXY:E06");
        }
    }

    /**
    * @notice Call contract method from NFT.
    * @dev proxyMint is only for proxy contract.
    * @param to address.
    * @return tokenId uint256.
    */
    function _mint(address to) internal returns (uint256) {
        return IFireCatNFT(fireCatNFT).proxyMint(to);
    }

    /// @inheritdoc IFireCatProxy
    function setLiquidityConfig(address pool, address tokenA, address tokenB) external onlyOwner {
        _liquidityPool = pool;
        _path[0] = tokenA;
        _path[1] = tokenB;
        emit SetLiquidityConfig(pool, tokenA, tokenB);
    }

    /// @inheritdoc IFireCatProxy
    function setInvestAmount(uint256 amount) external onlyOwner {
        investAmount = amount;
        emit SetInvestAmount(amount);
    }
   
    /// @inheritdoc IFireCatProxy
    function setLPSlippage(uint256 numerator, uint256 denominator) external onlyOwner {
        _slippageNumerator = numerator;
        _slippageDenominator = denominator;
        emit SetLPSlippage(numerator, denominator);
    }
    
    /// @inheritdoc IFireCatProxy
    function setAssetsInFactor(uint256 numerator, uint256 denominator) external onlyOwner {
        _assetsInNumerator = numerator;
        _assetsInDenominator = denominator;
        emit SetAssetsInFactor(numerator, denominator);
    }

    /// @inheritdoc IFireCatProxy
    function setFireCatNFT(address fireCatNFT_) external onlyOwner {
        fireCatNFT = fireCatNFT_;
        emit SetFireCatNFT(fireCatNFT_);
    }
    
    /// @inheritdoc IFireCatProxy
    function setFireCatReserves(address fireCatReserves_) external onlyOwner {
        fireCatReserves = fireCatReserves_;
        emit SetFireCatReserves(fireCatReserves_);
    }

    /// @inheritdoc IFireCatProxy
    function setFireCatTreasury(address fireCatTreasury_) external onlyOwner {
        fireCatTreasury = fireCatTreasury_;
        emit SetFireCatTreasury(fireCatTreasury_);
    }

    /// @inheritdoc IFireCatProxy
    function setSwapRouter(address swapRouter_) external onlyOwner {
        swapRouter = swapRouter_;
        emit SetSwapRouter(swapRouter_);
    }
    
    /// @inheritdoc IFireCatProxy
    function invest() external payable nonReentrant returns (uint256) {
        require(msg.value == investAmount, "PXY:E00");
        require(mintAllowed(msg.sender), "PXY:E01");

        uint256 assetsIn = getAssetsIn(msg.value);
        (uint256 actualAddAmountETH, uint256 actualAddAmountToken) = _swapWETHFor(assetsIn);
        uint256 actualAddLP = _addLiquidity(actualAddAmountETH, actualAddAmountToken);
        _transferInTreasury(msg.sender, actualAddLP);
        _transferInReserves(msg.sender);
        uint256 newTokenId =  _mint(msg.sender);
        emit Invest(msg.sender, msg.value, newTokenId);
        return newTokenId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
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

pragma solidity >=0.6.2;

import './IPancakeRouter01.sol';

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
* @notice IFireCatReserves
*/
interface IFireCatReserves {
    /**
    * @notice All reserves of contract.
    * @dev Fetch data from _totalReserves.
    * @return totalReserves.
    */
    function totalReserves() external view returns (uint256);

    /**
    * @notice check reserves by address.
    * @dev Fetch reserves from _userReserves.
    * @param user address.
    * @return reserves.
    */
    function reservesOf(address user) external view returns (uint256);

    /**
    * @notice The reserves token of contract.
    * @dev Fetch data from _reservesToken.
    * @return reservesToken.
    */
    function reservesToken() external view returns (address);

    /**
    * @notice The interface of reserves adding.
    * @dev transfer WBNB to contract.
    * @param user address.
    * @param addAmount uint256.
    * @return actualAddAmount.
    */
    function addReserves(address user, uint256 addAmount) external returns (uint256);

    /**
    * @notice The interface of reserves withdrawn.
    * @dev Transfer WBNB to owner.
    * @param amount uint256.
    * @return actualSubAmount.
    */
    function withdrawReserves(uint256 amount) external returns (uint);

    /**
    * @notice The interface of IERC20 withdrawn, not include reserves token.
    * @dev Trasfer token to owner.
    * @param amount uint256.
    * @return actualSubAmount.
    */
    function withdrawRemaining(address token, uint256 amount) external returns (uint);

    /**
    * @notice set the fireCat proxy contract.
    * @dev set to _fireCatProxy.
    * @param fireCatProxy address.
    */
    function setFireCatProxy(address fireCatProxy) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
* @notice IFireCatTreasury
*/
interface IFireCatTreasury {

    /**
    * @notice All treasury of contract.
    * @dev Fetch data from _totalTreasury.
    * @return totalTreasury.
    */
    function totalTreasury() external view returns (uint256);

    /**
    * @notice check treasury by address.
    * @dev Fetch treasury from _treasurys.
    * @param tokenId uint256.
    * @return treasury.
    */
    function treasuryOf(uint256 tokenId) external view returns (uint256);

    /**
    * @notice The treasury token of contract.
    * @dev Fetch data from _treasuryToken.
    * @return treasuryToken.
    */
    function treasuryToken() external view returns (address);

    /**
    * @notice The interface of treasury adding.
    * @dev add liquidity pool token to contract.
    * @param user address.
    * @param tokenId uint256.
    * @param addAmount uint256.
    * @return actualAddAmount.
    */
    function addTreasury(address user, uint256 tokenId, uint256 addAmount) external returns (uint);
    /**
    * @notice The interface of treasury exchange.
    * @dev Exchange LP token from NFT.
    * @param tokenId uint256.
    * @return actualSubAmount.
    */
    function swapTreasury(uint256 tokenId) external returns (uint);

    /**
    * @notice The interface of treasury withdrawn.
    * @dev Trasfer LP Token to owner.
    * @param amount uint256.
    * @return actualSubAmount.
    */
    function withdrawTreasury(uint256 amount) external returns (uint);

    /**
    * @notice The interface of IERC20 withdrawn, not include treausury token.
    * @dev Trasfer token to owner.
    * @param amount uint256.
    * @return actualSubAmount.
    */
    function withdrawRemaining(address token, uint256 amount) external returns (uint);

    /**
    * @notice The exchange switch of the treasury.
    * @dev set bool to swapOn.
    * @param swapOn_ bool.
    */
    function setSwapOn(bool swapOn_) external;
    
    /**
    * @notice set the fireCat proxy contract.
    * @dev set to fireCatProxy.
    * @param fireCatProxy_ address.
    */
    function setFireCatProxy(address fireCatProxy_) external;

    /**
    * @notice set the fireCat NFT contract.
    * @dev set to fireCatNFT.
    * @param fireCatNFT_ address.
    */
    function setFireCatNFT(address fireCatNFT_) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

contract FireCatTransfer is Ownable, ReentrancyGuard {

    event Withdraw(address sender_, address token_, uint256 amount_);

     /**
     * @dev Performs a transfer in, reverting upon failure. Returns the amount actually transferred to the protocol, in case of a fee.
     * @param token_ address.
     * @param from_ address.
     * @param amount_ uint.
     * @return transfer_num.
     */
    function doTransferIn(address token_, address from_, uint amount_) internal returns (uint) {
        uint balanceBefore = IERC20(token_).balanceOf(address(this));
        IERC20(token_).transferFrom(from_, address(this), amount_);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {                       // This is a non-standard ERC-20
                    success := not(0)          // set success to true
                }
                case 32 {                      // This is a compliant ERC-20
                    returndatacopy(0, 0, 32)
                    success := mload(0)        // Set `success = returndata` of external call
                }
                default {                      // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_IN_FAILED");
        uint balanceAfter = IERC20(token_).balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "TOKEN_TRANSFER_IN_OVERFLOW");
        return balanceAfter - balanceBefore;  // underflow already checked above, just subtract
    }

    /**
     * @dev Performs a transfer out, ideally returning an explanatory error code upon failure tather than reverting.
     *  If caller has not called checked protocol's balance, may revert due to insufficient cash held in the contract.
     *  If caller has checked protocol's balance, and verified it is >= amount, this should not revert in normal conditions.
     * @param token_ address.
     * @param to_ address.
     * @param amount_ uint.
     * @return transfer_num.
     */
    function doTransferOut(address token_, address to_, uint256 amount_) internal returns (uint) {
        uint balanceBefore = IERC20(token_).balanceOf(address(this));
        IERC20(token_).transfer(to_, amount_);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    success := not(0)          // set success to true
                }
                case 32 {                     // This is a compliant ERC-20
                    returndatacopy(0, 0, 32)
                    success := mload(0)        // Set `success = returndata` of external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_IN_FAILED");
        uint balanceAfter = IERC20(token_).balanceOf(address(this));
        require(balanceAfter <= balanceBefore, "TOKEN_TRANSFER_IN_OVERFLOW");
        return balanceBefore - balanceAfter;  // underflow already checked above, just subtract
    }

    /**
    * @notice The interface of IERC20 token withdrawn.
    * @dev Call doTransferOut, transfer token to owner.
    * @param token address.
    * @param amount uint256.
    * @return actualSubAmount.
    */
    function withdraw(address token, uint256 amount) internal returns (uint) {
        require(token != address(0), "TOKEN_CANT_BE_ZERO");
        require(IERC20(token).balanceOf(address(this)) >= amount, "NOT_ENOUGH_TOKEN");
        IERC20(token).approve(msg.sender, amount);
        uint256 actualSubAmount = doTransferOut(token, msg.sender, amount);
        emit Withdraw(msg.sender, token, actualSubAmount);
        return actualSubAmount;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
* @notice IFireCatProxy
*/
interface IFireCatProxy {
    
    /**
    * @notice check user wether is minted.
    * @dev fetch data from fireCatNFT.
    * @param user address.
    * @return mintAllowed.
    */
    function mintAllowed(address user) external view returns (bool);

    /**
    * @notice treasuryToken is liquidity token.
    * @dev fetch data from fireCatTreasury.
    * @return treasuryToken.
    */
    function treasuryToken() external view returns (address);

    /**
    * @notice reservesToken should be WBNB Token.
    * @dev fetch data from fireCatReserves.
    * @return reservesToken.
    */
    function reservesToken() external view returns (address);

    /**
    * @notice The percentage of funds which put into fireCatTreasury.
    * @dev The final result will be divided.
    * @return _assetsInNumerator
    * @return _assetsInDenominator
    */
    function assetsInFactor() external view returns (uint256, uint256);

    /**
    * @notice The percentage of funds which put into liquidity.
    * @dev The final result will be divided.
    * @return _slippageNumerator 
    * @return _slippageDenominator 
    */
    function liquiditySlippage() external view returns (uint256, uint256);

    /**
    * @notice A minimum value needs to be provided when adding liquidity.
    * @dev Fetch Factor from liquiditySlippage.
    * @param amount uint256.
    * @return liquidityMinProvide.
    */
    function liquidityMinProvide(uint256 amount) external view returns (uint256);

    /**
    * @notice Draw a portion of the invested funds into the fireCatTreasury contract.
    * @dev Fetch Factor from assetsInFactor.
    * @param amount uint256.
    * @return getAssetsIn.
    */
    function getAssetsIn(uint256 amount) external view returns (uint256);

    /**
    * @notice PancakeSwap Liquidity Pool.
    * @dev Fetch from _liquidityPool.
    * @return liquidityPool.
    */
    function liquidityPool() external view returns (address);

    /**
    * @notice Two token contracts of Liquidity Pool.
    * @dev Fetch from _path.
    * @return liquidityTokenA
    * @return liquidityTokenB
    */
    function liquidityToken() external view returns (address, address);

    /**
    * @notice Token settings for adding liquidity pools
    * @param pool address.
    * @param tokenA address.
    * @param tokenB address.
    */
    function setLiquidityConfig(address pool, address tokenA, address tokenB) external;

    /**
    * @notice The amount of investment limit.
    * @param amount uint256.
    */
    function setInvestAmount(uint256 amount) external;

     /**
    * @notice set slippage of liquidity adding.
    * @param numerator uint256.
    * @param denominator uint256.
    */
    function setLPSlippage(uint256 numerator, uint256 denominator) external;

    /**
    * @notice set factor of treasury investment.
    * @param numerator uint256.
    * @param denominator uint256.
    */
    function setAssetsInFactor(uint256 numerator, uint256 denominator) external;

    /**
    * @notice set fireCatNFT address.
    * @param fireCatNFT_ address.
    */
    function setFireCatNFT(address fireCatNFT_) external;
    
    /**
    * @notice set fireCatReserves address.
    * @param fireCatReserves_ address.
    */
    function setFireCatReserves(address fireCatReserves_) external;

     /**
    * @notice set fireCatTreasury address.
    * @param fireCatTreasury_ address.
    */
    function setFireCatTreasury(address fireCatTreasury_) external;

    /**
    * @notice set swapRouter address.
    * @param swapRouter_ address.
    */
    function setSwapRouter(address swapRouter_) external;

    /**
    * @notice The interface of investment.
    * @return tokenId.
    */
    function invest() external payable returns(uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

/**
* @notice IFireCatNFT
*/
interface IFireCatNFT is IERC721 {

    /**
     * @notice Return total amount of supply, not include destoryed.
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() external view returns (uint256);

    /**
    * @notice Latest ID not yet minted.
    * @dev currentTokenId add 1.
    * @return tokenId
    */
    function freshTokenId() external view returns (uint256);

    /**
    * @notice check user whether has minted.
    * @dev fetch data from _hasMinted.
    * @param user user_address.
    * @return minted
    */
    function hasMinted(address user) external view returns (bool);

    /**
    * @notice the supply limit of NFT, set by owner.
    * @return supplyLimit
    */
    function supplyLimit() external view returns (uint256);

    /**
    * @notice the highest level of NFT, set by owner.
    * @return highestLevel 
    */
    function highestLevel() external view returns (uint256);

    /**
    * @notice check tokenId by address.
    * @dev fetch data from _ownerTokenId.
    * @param owner user_address.
    * @return tokenId
    */
    function tokenIdOf(address owner) external view returns (uint256[] memory);

    /**
    * @notice check token level by Id.
    * @dev fetch data from _tokenLevel.
    * @param tokenId uint256.
    * @return tokenLevel
    */
    function tokenLevelOf(uint256 tokenId) external view returns (uint256);

    /**
    * @notice Metadata of NFT. 
    * @dev Combination of baseURI and tokenLevel
    * @param tokenId uint256.
    * @return json
    */
    function tokenURI(uint256 tokenId) external view returns (string memory);
    
    /**
    * @notice Use for airdrop.
    * @dev access: onlyOwner.
    * @param recipient address.
    * @return newTokenId
    */
    function mintTo(address recipient) external returns (uint256);

    /**
    * @notice Use for Multi address airdrop.
    * @dev access: onlyOwner.
    * @param recipients address[].
    */
    function multiMintTo(address[] memory recipients) external;

    /**
    * @notice Use for firecat proxy.
    * @dev access: onlyProxy.
    * @param recipient address.
    * @return newTokenId
    */
    function proxyMint(address recipient) external returns (uint256);
    
    /**
    * @notice Required two contracts to upgrade NFT: upgradeProxy and upgradeStorage.
    * @dev Upgrade needs to get permission from upgradeProxy.
    * @param tokenId uint256.
    */
    function upgradeToken(uint256 tokenId) external;

    /**
    * @notice Increase the supply of NFT as needed.
    * @dev set to _supplyLimit.
    * @param amount_ uint256.
    */
    function addSupply(uint256 amount_) external;

    /**
    * @dev Burn an ERC721 token.
    * @param tokenId_ uint256.
     */
    function burn(uint256 tokenId_) external;

    /**
    * @notice Set the highest level of NFT.
    * @dev set to _highestLevel.
    * @param level_ uint256.
    */
    function setHighestLevel(uint256 level_) external;

    /**
    * @notice set the upgrade logic contract of NFT.
    * @dev set to upgradeProxy.
    * @param upgradeProxy_ address.
    */
    function setUpgradeProxy(address upgradeProxy_) external;

    /**
    * @notice set the upgrade condtiions contract of NFT.
    * @dev set to upgradeStorage.
    * @param upgradeStorage_ address.
    */
    function setUpgradeStorage(address upgradeStorage_) external;

    /**
    * @notice The proxy contract is responsible for the minting。
    * @dev set to fireCatProxy.
    * @param fireCatProxy_ address.
    */
    function setFireCatProxy(address fireCatProxy_) external;
}

pragma solidity >=0.5.0;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}

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

pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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

// SPDX-License-Identifier: MIT
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