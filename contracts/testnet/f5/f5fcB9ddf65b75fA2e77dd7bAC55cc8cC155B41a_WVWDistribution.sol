// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
    This contracts will gona control all token supply of WVW, and it guarantees that anything will going to be different from WVW Tokenomics.
    Onwer can't even change wallets if he wants to.
    Claims are gonna be locked until it gets the timeslock from each tokenomic rules.
 */
contract WVWDistribution is Ownable {
    IERC20 private token;
    uint256 private startDateDistribution;
    bool private tokenConfigured;

    uint256 private constant oneDay = 1 days;
    uint256 private constant oneMonth = 30 days;
    uint256 private constant sixMonths = 180 days;

    address private walletTeam;
    address private walletPartners;
    address private walletGiveways;
    address private walletLiquidityExchange;
    address private walletLaunch;
    address private walletStake;
    address private walletFounder;

    struct DistributionItem {
        address wallet;
        uint256 lastClaim;
        uint256 totalAmount;
        uint256 timeLock;
        uint256 amountPerClaim;
        uint256 claimed;
    }

    DistributionItem[] distributions;

    constructor(
        address _owner,
        address _walletTeam,
        address _walletPartners,
        address _walletGiveways,
        address _walletLiquidityExchange,
        address _walletLaunch,
        address _walletStake,
        address _walletFounder
    ) {
        startDateDistribution = block.timestamp;
        tokenConfigured = false;

        walletTeam = _walletTeam;
        walletPartners = _walletPartners;
        walletGiveways = _walletGiveways;
        walletLiquidityExchange = _walletLiquidityExchange;
        walletLaunch = _walletLaunch;
        walletStake = _walletStake;
        walletFounder = _walletFounder;

        configureTimeLocks();

        // Transfer ownership if sender is not the _owner
        if (msg.sender != _owner) {
            transferOwnership(_owner);
        }
    }

    function configureTokenAddress(address _token) public onlyOwner {
        // We need to configure token after token was created, but token needs Distribution contract.
        require(!tokenConfigured);
        token = IERC20(_token);
        tokenConfigured = true;

        sendPredefinedTokens(walletLaunch);
    }

    function configureTimeLocks() private {
        
        // Wallet Founder will get all tokens after 24 hours
        distributions.push(
            DistributionItem(
                walletFounder,
                startDateDistribution,
                10000000 * 10**18,
                oneDay,
                10000000 * 10**18,
                0
            )
        );
        // Wallet Team will gonna claim each month 500000 tokens until it gets 10000000
        distributions.push(
            DistributionItem(
                walletTeam,
                startDateDistribution,
                10000000 * 10**18,
                oneMonth,
                500000 * 10**18,
                0
            )
        );
        // Wallet Partners will gonna claim each month 500000 tokens until it gets 10000000
        distributions.push(
            DistributionItem(
                walletPartners,
                startDateDistribution,
                10000000 * 10**18,
                oneMonth,
                500000 * 10**18,
                0
            )
        );
        // Wallet Giveways will gonna claim each month 500000 tokens until it gets 10000000
        distributions.push(
            DistributionItem(
                walletGiveways,
                startDateDistribution,
                10000000 * 10**18,
                oneMonth,
                500000 * 10**18,
                0
            )
        );

        // Wallet Stake will gonna claim each month 500000 tokens until it gets 10000000
        distributions.push(
            DistributionItem(
                walletStake,
                startDateDistribution,
                10000000 * 10**18,
                oneMonth,
                500000 * 10**18,
                0
            )
        );

        // Wallet Liquidity Exchange will gonna claim each six month 5000000 tokens until it gets 20000000
        distributions.push(
            DistributionItem(
                walletLiquidityExchange,
                startDateDistribution,
                20000000 * 10**18,
                sixMonths,
                5000000 * 10**18,
                0
            )
        );
    }

    function sendPredefinedTokens(
        address _walletLaunch
    ) private {
        require(
            token.transfer(_walletLaunch, 30000000 * 10**18),
            "Error to send initial tokens to WalletLaunch"
        );
    }

    function verifyTimeLock() external view returns (bool availableClaim) {
        for (uint256 i = 0; i < distributions.length; i++) {
            if (
                (distributions[i].claimed < distributions[i].totalAmount) &&
                (block.timestamp >=
                    distributions[i].lastClaim + distributions[i].timeLock)
            ) {
                return true;
            }
        }
    }

    function claim() external onlyOwner {
        for (uint256 i = 0; i < distributions.length; i++) {
            if (
                block.timestamp >=
                distributions[i].lastClaim + distributions[i].timeLock
            ) {
                if (distributions[i].claimed < distributions[i].totalAmount) {
                    distributions[i].claimed += distributions[i].amountPerClaim;
                    distributions[i].lastClaim = block.timestamp;
                    require(
                        token.transfer(
                            distributions[i].wallet,
                            distributions[i].amountPerClaim
                        ),
                        "error to send tokens to Wallet"
                    );
                }
            }
        }
    }

    function getTimelocks()
        external
        view
        returns (DistributionItem[] memory _timelocks)
    {
        return distributions;
    }
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