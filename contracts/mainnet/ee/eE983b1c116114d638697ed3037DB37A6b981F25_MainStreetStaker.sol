// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./math/SafeMath.sol";
import "./access/Ownable.sol";
import "./token/BEP20/IBEP20.sol";
import "./utils/ReentrancyGuard.sol";

interface IBananaPool {
    function enterStaking(uint256 _amount) external;
    function leaveStaking(uint256 _amount) external;
}

interface IGnanaPool {
    function deposit(uint256 _amount) external;
    function withdraw(uint256 _amount) external;
}

interface IApeSwapRouter {
    function getAmountsOut(uint amountIn, address[] memory path) external returns (uint[] memory amounts);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint[] memory amounts);
}

interface IApeSwapTreasury {
    function buy(uint _amount) external;
}

interface IMinter {
    function balanceOf(address owner) external returns (uint256);
    function ownerOf(uint256 tokenId) external returns (address);
    function totalSupply() external returns (uint256);
}

contract MainStreetStaker is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    uint256 MAX_INT = 2**256 - 1;

    // informative variables
    uint public TOTAL_BNB_RECEIVED = 0;
    uint public TOTAL_BANANA_BOUGHT = 0;
    uint public TOTAL_BANANA_STAKED = 0;
    uint public TOTAL_GNANA_BOUGHT = 0;
    uint public TOTAL_GNANA_STAKED = 0;
    uint public TOTAL_MAINST_BURNED = 0;
    uint public TOTAL_BANANA_DISTRIBUTED = 0;

    // for governance and time lock
    bool isBananaApproved = false;
    bool isGnanaApproved = false;

    uint256 public DISTRIBUTION_PERCENTAGE; // between banana/gnana pools

    address public BANANA_POOL; // to stake banana
    address public GNANA_POOL; // to stake gnana
    address public APESWAP_ROUTER; // to swap banana and mainst
    address public MINTER; //nft minter address
    address public DISTRIBUTOR; // token distributor address
    address public WRAPPED_BNB; // to get amounts out
    address public BANANA_TOKEN;
    address public GNANA_TOKEN;
    address public APESWAP_TREASURY; // to buy gnana token for bananas

    address public MAINST_TOKEN;

    uint public TIME_LOCKED_BANANA = 0;
    bool timeLockBananaActivated = false;

    uint public TIME_LOCKED_GNANA = 0;
    bool timeLockGananaActivated = false;

    uint public FUNDING_WALLET_PERCENTAGE = 2;

    constructor(
        uint distributionPercentage,
        address minter,
        address bananaPool,
        address gnanaPool,
        address apeswapRouter,
        address wrappedBNB,
        address bananaToken,
        address gnanaToken,
        address apeswapTreasury,
        address mainst,
        address distributor
    ) {
        DISTRIBUTION_PERCENTAGE = distributionPercentage;
        MINTER = minter;
        BANANA_POOL = bananaPool;
        GNANA_POOL = gnanaPool;
        APESWAP_ROUTER = apeswapRouter;
        WRAPPED_BNB = wrappedBNB;
        BANANA_TOKEN = bananaToken;
        GNANA_TOKEN = gnanaToken;
        APESWAP_TREASURY = apeswapTreasury;
        MAINST_TOKEN = mainst;
        DISTRIBUTOR = distributor;
    }

    modifier onlyMinter() {
        require(msg.sender == MINTER, "Only the minter contract can call this function.");
        _;
    }

    function setMinterAddress(address minter) public onlyOwner {
        MINTER = minter;
    }

    function setDistributorAddress(address distributor) public onlyOwner {
        DISTRIBUTOR = distributor;
    }

    function setFundingWalletPercentage(uint _percent) public onlyOwner {
        FUNDING_WALLET_PERCENTAGE = _percent;
    }

    function activateTimeLockBanana() public onlyOwner() {
        require(!timeLockBananaActivated, "Timelock already activated");
        require(TIME_LOCKED_BANANA == 0, "Time not reset yet");
        TIME_LOCKED_BANANA = block.timestamp;
        timeLockBananaActivated = true;
    }

    function activateTimeLockGanana() public onlyOwner() {
        require(!timeLockGananaActivated, "Timelock already activated");
        require(TIME_LOCKED_GNANA == 0, "Time not reset yet");
        TIME_LOCKED_GNANA = block.timestamp;
        timeLockGananaActivated = true;
    }

    function changeBananaPoolAddress(address newBananaPoolAddress) public onlyOwner() {
        require(timeLockBananaActivated, "Time lock not activated yet");
        require((TIME_LOCKED_BANANA + 172800) < block.timestamp, "time lock still in process");
        BANANA_POOL = newBananaPoolAddress;
        timeLockBananaActivated = false;
        TIME_LOCKED_BANANA = 0;
    }


    function changeGananaPoolAddress(address newGananaPoolAddress) public onlyOwner() {
        require(timeLockGananaActivated, "Time lock not activated yet");
        require((TIME_LOCKED_GNANA + 172800) < block.timestamp, "time lock still in process");
        GNANA_POOL = newGananaPoolAddress;
        timeLockGananaActivated = false;
        TIME_LOCKED_GNANA = 0;
    }

    // distribution percentage between BANANA and GNANA pools
    function setDistributionPercentage(uint percentage) public onlyOwner() {
        require(percentage > 0 && percentage <= 100, "percentage should be between 1-100");
        DISTRIBUTION_PERCENTAGE = percentage;
    }

    function calculateBananaDistribution(uint bananaAmount) public view returns(uint[] memory _amounts) {
        uint forBananaPool = (bananaAmount / 100) * DISTRIBUTION_PERCENTAGE;
        uint forGananaPool = bananaAmount - forBananaPool;
        uint[] memory amounts = new uint[](2);
        amounts[0] = forBananaPool;
        amounts[1] = forGananaPool;
        return amounts;
    }

    function buyBanana(uint forBNBAmount) private returns(uint boughtBananaAmount) {
        address[] memory path = new address[](2);
        path[0] = WRAPPED_BNB;
        path[1] = BANANA_TOKEN;
        uint[] memory bananaAmountsOut = IApeSwapRouter(APESWAP_ROUTER).getAmountsOut(forBNBAmount, path);
        uint[] memory amounts = IApeSwapRouter(APESWAP_ROUTER).swapExactETHForTokens{value : forBNBAmount}(
            bananaAmountsOut[1],
            path,
            address(this),
            block.timestamp + 100
        );
        return amounts[1];
    }

    function buyGanana(uint forBananaAmount) private returns(uint boughtGnanaAmount) {
        IApeSwapTreasury(APESWAP_TREASURY).buy(forBananaAmount);
        return IBEP20(GNANA_TOKEN).balanceOf(address(this));
    }

    function stakeBanana(uint bananaToStake) private returns (uint stakedBananaAmount) {
        IBananaPool(BANANA_POOL).enterStaking(bananaToStake);
        return bananaToStake;
    }

    // stake remaining banana if there is any or if contract is redeployed
    function stakeRemainingBanana() public onlyOwner() {
        uint remainingBanana = IBEP20(BANANA_TOKEN).balanceOf(address(this));
        IBananaPool(BANANA_POOL).enterStaking(remainingBanana);
        TOTAL_BANANA_STAKED += remainingBanana;
    }

    // stake remaining ganana if any or if contract is redeployed
    function stakeRemainingGnana() public onlyOwner() {
        uint gnanaToStake = IBEP20(GNANA_TOKEN).balanceOf(address(this));
        IGnanaPool(GNANA_POOL).deposit(gnanaToStake);
        TOTAL_GNANA_STAKED += gnanaToStake;
    }

    function harvestBanana() private returns (uint harvestedAmount) {
        uint balanceBefore = IBEP20(BANANA_TOKEN).balanceOf(address(this));
        IBananaPool(BANANA_POOL).leaveStaking(0);
        uint balanceAfter = IBEP20(BANANA_TOKEN).balanceOf(address(this));
        return balanceAfter - balanceBefore;
    }

    // uint _percent is for the percentage of banana staked, returns unstaked + harvested banana + leftover banana from gnana withdraw
    function withdrawBanana(uint percent) public onlyOwner() {
        require(percent > 0 && percent <= 100, "incorrect percentage");
        IBananaPool(BANANA_POOL).leaveStaking((TOTAL_BANANA_STAKED / 100) *  percent);
        IBEP20(BANANA_TOKEN).transfer(msg.sender, IBEP20(BANANA_TOKEN).balanceOf(address(this)));
    }

    function withdrawLeftOverBanana() public onlyOwner() {
        IBEP20(BANANA_TOKEN).transfer(msg.sender, IBEP20(BANANA_TOKEN).balanceOf(address(this)));
    }

    function stakeGanana() private returns (uint stakedGananaAmount) {
        uint gnanaToStake = IBEP20(GNANA_TOKEN).balanceOf(address(this));
        IGnanaPool(GNANA_POOL).deposit(gnanaToStake);
        return gnanaToStake;
    }

    function harvestGnana() private returns(uint harvestedAmount) {
        uint balanceBefore = IBEP20(GNANA_TOKEN).balanceOf(address(this));
        IGnanaPool(GNANA_POOL).withdraw(0);
        uint balanceAfter = IBEP20(GNANA_TOKEN).balanceOf(address(this));
        return balanceAfter - balanceBefore;
    }

    // uint _percent is for the percentage of gnana staked, returns unstaked gnana only
    function withdrawGnana(uint _percent) public onlyOwner() {
        require(_percent > 0 && _percent <= 100, "incorrect percentage");
        IGnanaPool(GNANA_POOL).withdraw((TOTAL_GNANA_STAKED / 100) * _percent);
        IBEP20(GNANA_TOKEN).transfer(msg.sender, IBEP20(GNANA_TOKEN).balanceOf(address(this)));
    }

    function withdrawLeftOverGnana() public onlyOwner() {
        IBEP20(GNANA_TOKEN).transfer(msg.sender, IBEP20(GNANA_TOKEN).balanceOf(address(this)));
    }

    function deposit() external payable nonReentrant() {
        require(isBananaApproved, "Banana not approved yet");
        require(isGnanaApproved, "Gnana not approved yet");
        TOTAL_BNB_RECEIVED += msg.value;
        uint bananaBought = buyBanana(msg.value);
        TOTAL_BANANA_BOUGHT += bananaBought;
        uint[] memory bananaDistribution = calculateBananaDistribution(bananaBought);
        TOTAL_BANANA_STAKED += stakeBanana(bananaDistribution[0]);
        uint gnanaBought = buyGanana(bananaDistribution[1]);
        TOTAL_GNANA_BOUGHT += gnanaBought;
        TOTAL_GNANA_STAKED += stakeGanana();
    }

    function harvestAndReStake() public onlyOwner() nonReentrant() {
        harvestBanana();
        harvestGnana();
        // ganana pool rewards banana so its the total rewards.
        uint totalBananaBalance = IBEP20(BANANA_TOKEN).balanceOf(address(this));
        uint bananaToReInvest = (totalBananaBalance / 100) * 5; // 5% buy banana back to reinvest.
        uint bananaForGnana = (totalBananaBalance / 100) * 15; // 15% buy gnana and restake.
        uint bananaForMainst = (totalBananaBalance / 100) * 2; // 2% buy MAINST and burn
        uint bananaForBNB = (totalBananaBalance / 100) * FUNDING_WALLET_PERCENTAGE; // 5% to fund deployer wallet with BNB
        // reinvesting banana
        TOTAL_BANANA_STAKED += stakeBanana(bananaToReInvest);
        TOTAL_GNANA_BOUGHT += buyGanana(bananaForGnana);
        TOTAL_GNANA_STAKED += stakeGanana();
        TOTAL_MAINST_BURNED += burnMainst(buyBackMainstreet(bananaForMainst));
        fundWallet(bananaForBNB);
        sendRewardTokensToDistributor();
    }

    function fundWallet(uint bananaAmount) private returns(uint boughtBNB){
        address[] memory path = new address[](2);
        path[0] = BANANA_TOKEN;
        path[1] = WRAPPED_BNB;
        uint[] memory bnbAmountsOut = IApeSwapRouter(APESWAP_ROUTER).getAmountsOut(bananaAmount, path);
        uint[] memory amounts = IApeSwapRouter(APESWAP_ROUTER).swapExactTokensForETH(
            bananaAmount,
            bnbAmountsOut[1],
            path,
            msg.sender,
            block.timestamp + 100
        );
        return amounts[1];
    }

    function buyBackMainstreet(uint bananaAmount) private returns(uint mainstPurchased) {
        address[] memory path = new address[](3);
        path[0] = BANANA_TOKEN;
        path[1] = WRAPPED_BNB;
        path[2] = MAINST_TOKEN;
        uint[] memory mainstAmountsOut = IApeSwapRouter(APESWAP_ROUTER).getAmountsOut(bananaAmount, path);
        uint slippage = (mainstAmountsOut[2] / 100) * 12;
        uint[] memory amounts = IApeSwapRouter(APESWAP_ROUTER).swapExactTokensForTokens(
            bananaAmount,
            mainstAmountsOut[2] - slippage,
            path,
            address(this),
            block.timestamp + 100
        );
        return amounts[1];
    }

    function burnMainst(uint amount) private returns(uint){
        IBEP20(MAINST_TOKEN).transfer(0x000000000000000000000000000000000000dEaD, amount);
        return amount;
    }

    function sendTokensToDistributor() public onlyOwner() {
        IBEP20(MAINST_TOKEN).transfer(DISTRIBUTOR, IBEP20(MAINST_TOKEN).balanceOf(address(this)));
    }

    function sendRewardTokensToDistributor() public onlyOwner() {
        buyBackMainstreet(IBEP20(BANANA_TOKEN).balanceOf(address(this)));
        sendTokensToDistributor();
    }

    function withdrawRemainingMainstreet() public onlyOwner() {
        IBEP20(MAINST_TOKEN).transfer(msg.sender, IBEP20(MAINST_TOKEN).balanceOf(address(this)));
    }

    function getBananaApproved() public onlyOwner() {
        require(!isBananaApproved, "Already approved");
        IBEP20(BANANA_TOKEN).approve(BANANA_POOL, MAX_INT);
        IBEP20(BANANA_TOKEN).approve(APESWAP_ROUTER, MAX_INT);
        isBananaApproved = true;
    }

    function getGnanaApproved() public onlyOwner() {
        require(!isGnanaApproved, "Already approved");
        IBEP20(GNANA_TOKEN).approve(GNANA_POOL, MAX_INT);
        IBEP20(BANANA_TOKEN).approve(APESWAP_TREASURY, MAX_INT); // to buy gnana
        isGnanaApproved = true;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
     * by making the `nonReentrant` function external, and make it call a
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

pragma solidity ^0.8.4;

/*
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

    function _msgData() internal view virtual returns ( bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.4;

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
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
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
 */
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
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
        return div(a, b, 'SafeMath: division by zero');
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
        return mod(a, b, 'SafeMath: modulo by zero');
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
    constructor()  {
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