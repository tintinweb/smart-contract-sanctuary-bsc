// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract CCCTokenDistribution is Ownable {
    IERC20 public token;
    uint256 public startDateDistribution;
    bool tokenConfigured;

    struct DistributionItem {
        uint256 startDate;
        uint256 endDate;
        uint256 amount;
        bool sent;
    }

    mapping(address => DistributionItem[]) distributionsByAddress;

    constructor(
        address _walletPrivateSale,
        address _walletPublicSale,
        address _walletTeam,
        address _walletAdvisors,
        address _walletCommunitMarket,
        address _walletLiquidityExchange,
        address _walletEcoSystem
    ) {
        startDateDistribution = block.timestamp;
        tokenConfigured = false;

        privateSaleLocks(_walletPrivateSale);
        publicSaleLocks(_walletPublicSale);
        teamLocks(_walletTeam);
        advisorsLocks(_walletAdvisors);
        communitMarketLocks(_walletCommunitMarket);
        liquidityExchangeLocks(_walletLiquidityExchange);
        walletEcoSystemLocks(_walletEcoSystem);
    }

    function configureTokenAddress(address _token)
        public
        onlyOwner
    {
        // We need to configure token after token was created, because token needs Distribution contract.
        require(!tokenConfigured);
        token = IERC20(_token);
        tokenConfigured = true;
    }

    function claimAmount() external onlyOwner {
        DistributionItem[] storage distributionList = distributionsByAddress[
            msg.sender
        ];
        require(distributionList.length > 0);

        for (uint256 i = 0; i < distributionList.length; i++) {
            if (
                !distributionList[i].sent &&
                block.timestamp >= distributionList[i].endDate
            ) {
                distributionList[i].sent = true;
                token.transfer(msg.sender, distributionList[i].amount);
            }
        }
    }

    function privateSaleLocks(address _walletPrivateSale) private {
        DistributionItem[] storage distributionList = distributionsByAddress[
            _walletPrivateSale
        ];

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 90 days,
            12000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 180 days,
            12000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 270 days,
            12000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 360 days,
            12000000
        );
    }

    function publicSaleLocks(address _walletPublicSale) private {
        DistributionItem[] storage distributionList = distributionsByAddress[
            _walletPublicSale
        ];

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 30 days,
            10000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 90 days,
            10000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 150 days,
            10000000
        );
    }

    function teamLocks(address _walletTeam) private {
        DistributionItem[] storage distributionList = distributionsByAddress[
            _walletTeam
        ];

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 360 days,
            12500000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 720 days,
            12500000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 1080 days,
            12500000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 1440 days,
            12500000
        );
    }

    function advisorsLocks(address _walletAdvisors) private {
        DistributionItem[] storage distributionList = distributionsByAddress[
            _walletAdvisors
        ];

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 360 days,
            1250000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 720 days,
            1250000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 1080 days,
            1250000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 1440 days,
            1250000
        );
    }

    function communitMarketLocks(address _walletCommunitMarket) private {
        DistributionItem[] storage distributionList = distributionsByAddress[
            _walletCommunitMarket
        ];

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 90 days,
            12000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 270 days,
            12000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 360 days,
            15000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 720 days,
            18000000
        );
    }

    function liquidityExchangeLocks(address _walletLiquidityExchange) private {
        DistributionItem[] storage distributionList = distributionsByAddress[
            _walletLiquidityExchange
        ];

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 90 days,
            10000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 180 days,
            10000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 270 days,
            10000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 360 days,
            25000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 720 days,
            30000000
        );
    }

    function walletEcoSystemLocks(address _walletEcoSystem) private {
        DistributionItem[] storage distributionList = distributionsByAddress[
            _walletEcoSystem
        ];

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 180 days,
            25000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 360 days,
            25000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 720 days,
            30000000
        );

        createDistributionTime(
            distributionList,
            block.timestamp,
            block.timestamp + 1080 days,
            20000000
        );
    }

    function createDistributionTime(
        DistributionItem[] storage distributionList,
        uint256 timestampInit,
        uint256 timestampEnd,
        uint256 _amount
    ) private {
        uint256 _amoutWithDecimals = _amount * 10**18;
        distributionList.push(
            DistributionItem(timestampInit, timestampEnd, _amoutWithDecimals, false)
        );
    }

    function getTimelockAddress(address _address)
        public
        view
        returns (DistributionItem[] memory _timelocks)
    {
        DistributionItem[] memory distributionList = distributionsByAddress[
            _address
        ];
        return distributionList;
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