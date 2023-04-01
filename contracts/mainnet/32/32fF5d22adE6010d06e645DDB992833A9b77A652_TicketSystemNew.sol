//SPDX-License-Identifier:MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./IERC20.sol";

/**
 * @title TicketSystemCD
 * @author karan (@cryptofluencerr, https://cryptofluencerr.com)
 * @dev The TicketSystemCD contract is used for purchasing tickets for CryptoDuels.
 */

contract TicketSystemNew is Ownable, ReentrancyGuard, Pausable {
    IUniswapV2Router02 public pancakeRouter;

    //============== VARIABLES ==============
    IERC20 public GQToken;
    uint256 public ticketPrice;
    uint256 public teamPercentage;
    uint256 public rewardPoolPercentage;
    uint256 public burnPercentage;
    uint256 public withdrawLimit;
    uint256 public OZFees;
    address public pancakeRouterAddress;

    address public teamAddress;
    address public rewardPool;
    address public admin;
    uint256 decimals;

    address private GQ_BUSD_pair;

    struct UserInfo {
        uint256 ticketBalance;
        uint256 lastWithdrawalTime;
    }

    //============== MAPPINGS ==============
    mapping(address => UserInfo) public userInfo;

    //============== EVENTS ==============
    event TicketPurchased(
        address indexed buyer,
        uint256 numofTicket,
        uint256 amountPaid
    );
    event TicketWithdrawn(
        address indexed user,
        uint256 numOfTicket,
        uint256 amountRefund
    );
    event FeesTransfered(
        uint256 teamAmount,
        uint256 rewardPoolAmount,
        uint256 burnAmount
    );
    event TokenWithdrawn(address indexed owner, uint256 amount);
    event SetUserBalance(address indexed user, uint256 amount);
    event SetTokenAddress(address tokenAddr);
    event SetPairAddress(address pairAddr);
    event SetTicketprice(uint256 price);
    event SetTeamPercentage(uint256 teamPercent);
    event SetRewardPoolPercentage(uint256 rewardPoolPercent);
    event SetBurnPercentage(uint256 burnPercent);
    event SetWithdrawLimit(uint256 withdrawLimit);
    event SetOZFees(uint256 OZFees);
    event SetTeamAddress(address teamAddr);
    event SetRewardAddress(address rewardPoolAddr);
    event SetAdmin(address newAdmin);
    event SetRouterAddress(address _routerAddress);

    //============== CONSTRUCTOR ==============
    constructor() {
        decimals = 10 ** 18;
        ticketPrice = 1 * decimals;
        teamPercentage = (ticketPrice * 1000) / 10000;
        rewardPoolPercentage = (ticketPrice * 250) / 10000;
        burnPercentage = (ticketPrice * 250) / 10000;
        withdrawLimit = 500 * decimals;
        OZFees = (2500 * decimals) / 10000;

        // // testnet
        // pancakeRouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        // pancakeRouter = IUniswapV2Router02(pancakeRouterAddress);
        // GQToken = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
        // teamAddress = 0xDb3360F0a406Aa9fBbBd332Fdf64ADb688e9a769;
        // rewardPool = 0xDb3360F0a406Aa9fBbBd332Fdf64ADb688e9a769;
        // admin = payable(0xDb3360F0a406Aa9fBbBd332Fdf64ADb688e9a769);
        // GQ_BUSD_pair = 0x209eBd953FA5e3fE1375f7Dd0a848A9621e9eaFc;

        //        mainnet
        pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        pancakeRouter = IUniswapV2Router02(pancakeRouterAddress);
        GQToken = IERC20(0xF700D4c708C2be1463E355F337603183D20E0808);
        GQ_BUSD_pair = 0x72121d60b0e2F01c0FB7FE32cA24021b42165A40;
        admin = payable(0xbb1220Eb122f85aE0FAf61D89e0727C4962b4506);
        teamAddress = 0x81319B34e571d8aE7725bD611bcB8c0b3556bF01;
        rewardPool = 0x81319B34e571d8aE7725bD611bcB8c0b3556bF01;
    }

    //============== MODIFIER ==============
    /**
     * @dev Modifier to ensure only the admin can call the function
     */
    modifier onlyAdmin() {
        require(_msgSender() == admin, "Only admin");
        _;
    }

    //============== VIEW FUNCTIONS ==============
    /**
     * @dev Function to get GQ price from Pancackeswap
     */
    function getPrice() public view returns (uint256) {
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(GQ_BUSD_pair)
            .getReserves();
        return (uint256(reserve1) * 1e18) / uint256(reserve0);
    }

    //============== EXTERNAL FUNCTIONS ==============
    /**
     * @dev Function to Purchase Tickets
     * @param numOfTicket to select quantity of tickets to purchase
     */
    function purchaseTicket(
        uint256 numOfTicket
    ) external payable whenNotPaused nonReentrant {
        require(
            numOfTicket > 0,
            "Purchase Ticket: Number of Ticket should be greater than Zero"
        );
        uint256 amount;
        uint256 ticketAmount = (numOfTicket * ticketPrice) / decimals;
        uint256 teamAmount = (numOfTicket * teamPercentage) / decimals;
        uint256 rewardPoolAmount = (numOfTicket * rewardPoolPercentage) /
            decimals;
        uint256 burnAmount = (numOfTicket * burnPercentage) / decimals;
        uint256 ozFees = (OZFees * getPrice()) / decimals;

        amount =
            ticketAmount +
            teamAmount +
            rewardPoolAmount +
            burnAmount +
            ozFees;

        bool success = GQToken.transferFrom(
            _msgSender(),
            address(this),
            amount
        );
        require(success, "Purchase Ticket: GQ transfer failed.");
        feesTransfer(teamAmount, rewardPoolAmount, burnAmount);

        swapTokensForEth(ozFees);
        uint256 BNBBalance = address(this).balance;
        (bool BNBSuccess, ) = admin.call{value: BNBBalance}("");
        require(BNBSuccess, "Purchase Ticket: BNB transfer failed.");

        userInfo[_msgSender()].ticketBalance += numOfTicket;

        emit TicketPurchased(_msgSender(), numOfTicket, amount);
    }

    function getFees(
        uint256 numOfTicket
    ) public view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 ticketAmount = (numOfTicket * ticketPrice) / decimals;
        uint256 teamAmount = (numOfTicket * teamPercentage) / decimals;
        uint256 rewardPoolAmount = (numOfTicket * rewardPoolPercentage) /
            decimals;
        uint256 burnAmount = (numOfTicket * burnPercentage) / decimals;
        // need to do getPrice => decimals for Mainnet
        uint256 ozFees = (OZFees * getPrice()) / decimals;
        return (ticketAmount, teamAmount, rewardPoolAmount, burnAmount, ozFees);
    }

    /**
     * @dev Function to Withdraw Tickets
     * @param numOfTicket to select quantity of tickets to withdraw
     */
    function withdrawTicket(
        uint256 numOfTicket
    ) external whenNotPaused nonReentrant {
        require(
            userInfo[_msgSender()].ticketBalance >= numOfTicket,
            "Withdraw Ticket: Insufficient Balance"
        );
        require(
            numOfTicket >= 1,
            "Withdraw Ticket: Amount should be greater than Zero"
        );
        if (userInfo[_msgSender()].lastWithdrawalTime != 0) {
            require(
                userInfo[_msgSender()].lastWithdrawalTime + 24 hours <=
                    block.timestamp,
                "Withdraw Ticket: Withdrawal is only allowed once every 24 hours"
            );
        }

        uint256 amount = (numOfTicket * ticketPrice) / decimals;
        uint256 teamAmount = (numOfTicket * teamPercentage) / decimals;
        uint256 rewardPoolAmount = (numOfTicket * rewardPoolPercentage) /
            decimals;
        uint256 burnAmount = (numOfTicket * burnPercentage) / decimals;

        uint256 balance = GQToken.balanceOf(address(this));
        require(
            balance >= amount,
            "Withdraw Ticket: Not enough balance in the contract"
        );
        require(
            amount <= (withdrawLimit * getPrice()) / decimals,
            "Withdraw Ticket: Withdrawal amount exceeds Limit"
        );

        uint256 ticketAmount = amount -
            (teamAmount + rewardPoolAmount + burnAmount);

        userInfo[_msgSender()].lastWithdrawalTime = block.timestamp;
        userInfo[_msgSender()].ticketBalance -= numOfTicket;

        bool success = GQToken.transfer(_msgSender(), ticketAmount);
        require(success, "Withdraw Ticket: Return Failed");

        feesTransfer(teamAmount, rewardPoolAmount, burnAmount);

        emit TicketWithdrawn(_msgSender(), numOfTicket, ticketAmount);
    }

    /**
     * @notice swaps dedicated amount from GQ -> BNB
     * @param amount total GQ amount that need to be swapped to BNB
     */
    function swapTokensForEth(uint256 amount) private {
        // Generate the uniswap pair path of GQToken -> weth
        address[] memory path = new address[](2);
        path[0] = address(GQToken);
        path[1] = pancakeRouter.WETH();

        GQToken.approve(address(pancakeRouter), amount);

        pancakeRouter.swapExactTokensForETH(
            amount,
            0,
            path,
            address(this), // this contract will receive the eth that were swapped from the GQToken
            block.timestamp
        );
    }

    /**
     * @notice will set the router address
     * @param _routerAddress pancake router address
     */
    function setRouterAddress(address _routerAddress) external onlyOwner {
        require(
            _routerAddress != address(0),
            "Set Router Address: Invalid router address"
        );
        pancakeRouterAddress = _routerAddress;
        pancakeRouter = IUniswapV2Router02(_routerAddress);
        emit SetRouterAddress(_routerAddress);
    }

    /**
     * @dev Function to Withdraw funds
     */
    function withdraw() external onlyOwner {
        uint256 balance = GQToken.balanceOf(address(this));
        require(balance > 0, "Withdraw: Not enough balance in the contract");
        bool success;
        success = GQToken.transfer(owner(), balance);
        require(success, "Withdraw: Withdraw Failed");
        emit TokenWithdrawn(owner(), balance);
    }

    /**
     * @dev Function to set the user's ticket balance
     * @param user address of user whose balance is to be set
     * @param amount The balance change amount to be set
     */
    function setUserBalance(
        address user,
        uint256 amount
    ) external onlyAdmin whenNotPaused nonReentrant {
        require(user != address(0), "Set User Balance: Invalid user address");
        userInfo[user].ticketBalance = amount;
        emit SetUserBalance(user, amount);
    }

    /**
     * @dev Function to set the admin address
     * @param newAdmin The new address to set as the admin
     */
    function setAdmin(address newAdmin) external onlyOwner {
        require(newAdmin != address(0), "Set Admin: Invalid address");
        admin = newAdmin;
        emit SetAdmin(admin);
    }

    /**
     * @dev Function to set the new GQToken address that is used Purchasing tickets
     * @param tokenAdd The new GQToken address
     */
    function setTokenAddress(address tokenAdd) external onlyOwner {
        require(tokenAdd != address(0), "Set Token Address: Invalid address");
        GQToken = IERC20(tokenAdd);
        emit SetTokenAddress(tokenAdd);
    }

    /**
     * @dev Function to set the new Pair address of GQToken pool
     * @param pairAdd The new pair address
     */
    function setPairAddress(address pairAdd) external onlyOwner {
        require(pairAdd != address(0), "Set Pair Address: Invalid address");
        GQ_BUSD_pair = pairAdd;
        emit SetPairAddress(pairAdd);
    }

    /**
     * @dev Function to set the Ticket Price
     * @param newPrice The new tick price in wei for 1 ticket.
     */
    function setTicketPrice(uint256 newPrice) external onlyOwner {
        require(
            newPrice > 0,
            "Set Ticket Price: New Price should be greater than Zero"
        );
        ticketPrice = newPrice;
        emit SetTicketprice(newPrice);
    }

    /**
     * @dev Function to set the Ticket OpenZepellin Fees.
     * @param amount The new limit amount in wei.
     */
    function setOZFees(uint256 amount) external onlyOwner {
        require(amount > 0, "Set OZ Fees: OZ Fees be greater than Zero");
        OZFees = amount;
        emit SetOZFees(amount);
    }

    /**
     * @dev Function to set the Ticket withdraw limit.
     * @param amount The new limit amount in wei.
     */
    function setWithdrawLimit(uint256 amount) external onlyOwner {
        require(
            amount > 0,
            "Set Withdraw limit: Withdraw limit be greater than Zero"
        );
        withdrawLimit = amount;
        emit SetWithdrawLimit(amount);
    }

    /**
     * @dev Function to set amount that will be transfered to Team
     * @param amount The new team share amount in wei for 1 ticket price
     */
    function setTeamPercentage(uint256 amount) external onlyOwner {
        teamPercentage = amount;
        emit SetTeamPercentage(amount);
    }

    /**
     * @dev Function to set amount that will be transfered to Reward pool
     * @param amount The new reward pool share amount in wei for 1 ticket price
     */
    function setRewardPoolPercentage(uint256 amount) external onlyOwner {
        rewardPoolPercentage = amount;
        emit SetRewardPoolPercentage(amount);
    }

    /**
     * @dev Function to set GQToken amount that will be burned.
     * @param amount The new burn share amount in wei for 1 ticket price
     */
    function setBurnPercentage(uint256 amount) external onlyOwner {
        burnPercentage = amount;
        emit SetBurnPercentage(amount);
    }

    /**
     * @dev Function to set the Team address
     * @param newTeamAddress The new address to set as the Team address
     */
    function setTeamAddress(address newTeamAddress) external onlyOwner {
        require(
            newTeamAddress != address(0),
            "Set Team Address: Invalid address"
        );
        teamAddress = newTeamAddress;
        emit SetTeamAddress(teamAddress);
    }

    /**
     * @dev Function to set the admin address
     * @param newRewardPoolAddress The new address to set as the Rewardpool address
     */
    function setRewardAddress(address newRewardPoolAddress) external onlyOwner {
        require(
            newRewardPoolAddress != address(0),
            "Set Reward Address: Invalid address"
        );
        rewardPool = newRewardPoolAddress;
        emit SetRewardAddress(rewardPool);
    }

    /**
     * @notice Pauses the contract.
     * @dev This function can only be called by the contract owner.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses the contract.
     * @dev This function can only be called by the contract owner.
     */
    function unPause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Internal function to transfer the fees.
     * @param teamAmnt amount to transfer to team.
     * @param rewardPoolAmnt amount to transfer to reward pool.
     * @param burnAmnt amount to burn tokens.
     */
    function feesTransfer(
        uint256 teamAmnt,
        uint256 rewardPoolAmnt,
        uint256 burnAmnt
    ) internal {
        bool teamTransfer = GQToken.transfer(teamAddress, teamAmnt);
        require(teamTransfer, "Fees Tramsfer: Team transfer failed");

        bool rewardPoolTransfer = GQToken.transfer(rewardPool, rewardPoolAmnt);
        require(
            rewardPoolTransfer,
            "Fees Transfer: RewardPool Transfer failed"
        );

        bool burnTransfer = GQToken.burn(burnAmnt);
        require(burnTransfer, "Fees Transfer: Burn failed");

        emit FeesTransfered(teamAmnt, rewardPoolAmnt, burnAmnt);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

interface IUniswapV2Router01 {
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