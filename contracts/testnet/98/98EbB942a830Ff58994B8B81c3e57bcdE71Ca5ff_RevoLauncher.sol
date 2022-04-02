// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
//import "hardhat/console.sol";

// Internal Imports
import "./interface/IRevoStaking.sol";
import "./interface/IRevoLauncher.sol";
import "./interface/IChainlink.sol";
import "./helpers/Error.sol";
import "./helpers/Tier.sol";
import {SaleInfo, StakingInfo, TierInfo, WhiteListInfo, UserPurchase} from "./types/Type.sol";

contract RevoLauncher is IRevoLauncher, Ownable, ReentrancyGuard, Tier {
    /// @dev represents the total sales created
    //uint256 private sales;

    /// @dev represents the staking address
    IRevoStaking public staking;

    /// @dev represents the sale info mapped to saleId
    //mapping(uint256 => SaleInfo) private sale;
    SaleInfo public s;

    /// @dev represents array of user purchase.
    UserPurchase[] private totalSales;

    /// @dev maps the saleId to whitelisted amount
    mapping(address => uint256) private allocation;

    /// @dev maps the saleId to whitelisted amount
    mapping(address => uint256) private unclaimed;

    /// @dev maps the purchase of user tokens during staking sale
    mapping(address => uint256) private stakeSalePurchase;

    /// @dev maps the purchase of user tokens in public pool
    mapping(address => uint256) private publicPurchase;

    /// @dev represents the oracle of BNB
    IChainlink private oracle;

    /// @dev is the address of BUSD
    address public busd;
    address public projectOwner;

    constructor(
        address _busd,
        address _newOwner,
        address prOwn
    ) {
        busd = _busd;
        projectOwner = prOwn;
        transferOwnership(_newOwner);
    }

    /// @dev see {IRevoLauncher-createSale}
    function createSale(
        address saleAddress,
        uint256 tokenDecimal,
        uint256 saleAmount,
        uint256 publicAllocation,
        uint256 costPerToken,
        uint256[4] memory time,
        uint256 stakePoolId,
        uint256 publicPerWallet,
        bool vested,
        bool whitelist
    ) external virtual override onlyOwner nonReentrant returns (bool) {
        //sales += 1;
        //require(sales<=1,"One Sale per Project");

        require(
            saleAmount - publicAllocation > 0,
            Error.VE_ERROR_INPUT_VALIDATION
        );

        //SaleInfo storage s = sale[sales];
        s.tokenAddress = saleAddress;
        s.totalAllocated = saleAmount;
        s.publicAllocated = publicAllocation;
        s.costPerToken = costPerToken;
        s.time = time;
        s.stakePoolId = stakePoolId;
        s.whitelist = whitelist;
        s.tokenDecimal = tokenDecimal;
        s.vested = vested;
        s.publicPerWallet = publicPerWallet;

        emit SaleCreated(
            saleAddress,
            tokenDecimal,
            saleAmount,
            publicAllocation,
            costPerToken,
            time[0],
            time[1],
            stakePoolId,
            whitelist
        );
        return true;
    }

    /// @dev see {RevolLauncher-publicPurchaseWithBNB}
    /// TODO::/// Make sure on nonReentrant
    function publicPurchaseWithBNB()
        public
        payable
        virtual
        override
        nonReentrant
        returns (uint256)
    {
        uint256 purchaseValue = usdValue(msg.value) * 10**18;
        UserPurchase memory tempUsrPurchase; //temp Struct variable
        //SaleInfo storage s = sale[saleId];
        require(
            block.timestamp >= s.time[2] && block.timestamp <= s.time[3],
            Error.VE_SALE_OUT_OF_BOUND
        );
        uint256 purchaseTokens = purchaseValue / s.costPerToken;
        purchaseTokens = purchaseTokens / 10**(18 - s.tokenDecimal);
        require(
            publicPurchase[_msgSender()] + purchaseTokens <= s.publicPerWallet,
            Error.VE_UNBOUNDED_PURCHASE_LIMIT
        );

        // require(
        //     s.publicAllocated >= purchaseTokens,
        //     Error.VE_INSUFFICIENT_TOKENS_LEFT_FOR_SALE
        // );
        require(
            s.totalAllocated - s.totalSold >= purchaseTokens,
            Error.VE_INSUFFICIENT_TOKENS_LEFT_FOR_SALE
        );

        s.publicAllocated -= purchaseTokens;
        s.totalSold += purchaseTokens;
        publicPurchase[_msgSender()] += purchaseTokens;

        tempUsrPurchase = UserPurchase(_msgSender(), purchaseTokens);
        totalSales.push(tempUsrPurchase);
        return purchaseTokens;
        /// This is not needed any more,Tokens will be transfered manually by project owner
    }

    /// @dev see {RevolLauncher-allocatedPurchaseWithBNB} //
    /// If no whitelist and no stake pool created, function throw divide by zero.

    /// Ask a question on Can allocation be greter then sale supply ?
    function allocatedPurchaseWithBNB()
        external
        payable
        virtual
        override
        nonReentrant
        returns (uint256)
    {
        uint256 purchaseValue = usdValue(msg.value) * 10**18; //

        require(
            block.timestamp >= s.time[0] && block.timestamp <= s.time[1],
            Error.VE_SALE_OUT_OF_BOUND
        );

        uint256 purchaseTokens = purchaseValue / s.costPerToken;
        purchaseTokens = purchaseTokens / 10**(18 - s.tokenDecimal);

        require(
            ((s.totalAllocated - s.publicAllocated - s.totalSold) > 0 &&
                purchaseTokens <=
                (s.totalAllocated - s.publicAllocated - s.totalSold)),
            "ERROR : Insufficient tokens"
        );

        if (s.whitelist) {
            require(
                allocation[_msgSender()] >= purchaseTokens,
                Error.VE_INSUFFICIENT_ALLOCATION
            );
            s.totalSold += purchaseTokens;
            allocation[_msgSender()] -= purchaseTokens;
            UserPurchase memory tempUsrPurchase;
            // publicSalers.push(_msgSender());//similarly we have stakers
            tempUsrPurchase = UserPurchase(_msgSender(), purchaseTokens);
            totalSales.push(tempUsrPurchase);
            /// This is not needed any more,Tokens will be transfered manually by project owner

            return purchaseTokens;
        } else {
            StakingInfo memory info = staking.stakeInfo(
                _msgSender(),
                s.stakePoolId
            );

            uint256 allocated = getAllocationPerStake(info.amount);
            require(
                allocated >= purchaseTokens + stakeSalePurchase[_msgSender()],
                Error.VE_INSUFFICIENT_ALLOCATION
            );

            s.totalSold += purchaseTokens;
            stakeSalePurchase[_msgSender()] += purchaseTokens;
            //Add totalsales below
            UserPurchase memory tempUsrPurchase;
            // publicSalers.push(_msgSender());//similarly we have stakers
            tempUsrPurchase = UserPurchase(_msgSender(), purchaseTokens);
            totalSales.push(tempUsrPurchase);
            //return purchase
            return purchaseTokens;

            /// This is not needed any more,Tokens will be transfered manually by project owner
        }
    }

    /// @dev see {RevolLauncher-publicPurchaseWithBUSD}
    /// TODO::/// Make sure on nonReentrant
    function publicPurchaseWithBUSD(uint256 purchaseValue)
        external
        virtual
        override
        nonReentrant
        returns (uint256)
    {
        uint256 busdValue = purchaseValue * 10**10;

        require(
            IERC20(busd).balanceOf(_msgSender()) >= busdValue,
            Error.VE_INSUFFICIENT_BALANCE
        );
        require(
            IERC20(busd).allowance(_msgSender(), address(this)) >= busdValue,
            Error.VE_INSUFFICIENT_ALLOWANCE
        );

        IERC20(busd).transferFrom(_msgSender(), address(this), busdValue); //Where to transfer?

        //SaleInfo storage s = sale[saleId];
        require(
            block.timestamp >= s.time[2] && block.timestamp <= s.time[3],
            Error.VE_SALE_OUT_OF_BOUND
        );

        uint256 purchaseTokens = (purchaseValue * 10**18) / s.costPerToken;
        purchaseTokens = purchaseTokens / 10**(18 - s.tokenDecimal);

        require(
            publicPurchase[_msgSender()] + purchaseTokens <= s.publicPerWallet,
            Error.VE_UNBOUNDED_PURCHASE_LIMIT
        );

        require(
            s.publicAllocated >= purchaseTokens,
            Error.VE_INSUFFICIENT_TOKENS_LEFT_FOR_SALE
        );

        s.publicAllocated -= purchaseTokens;
        s.totalSold += purchaseTokens;
        publicPurchase[_msgSender()] += purchaseTokens;
        //totalSale update
        UserPurchase memory tempUsrPurchase;
        // publicSalers.push(_msgSender());//similarly we have stakers
        tempUsrPurchase = UserPurchase(_msgSender(), purchaseTokens);
        totalSales.push(tempUsrPurchase);

        //return purchase

        return purchaseTokens;
    }

    /// @dev see {RevolLauncher-allocatedPurchaseWithBUSD}
    function allocatedPurchaseWithBUSD(uint256 purchaseValue)
        external
        virtual
        override
        nonReentrant
        returns (uint256)
    {
        uint256 busdValue = purchaseValue * 10**10;

        require(
            IERC20(busd).balanceOf(_msgSender()) >= busdValue,
            Error.VE_INSUFFICIENT_BALANCE
        );
        require(
            IERC20(busd).allowance(_msgSender(), address(this)) >= busdValue,
            Error.VE_INSUFFICIENT_ALLOWANCE
        );

        IERC20(busd).transferFrom(_msgSender(), address(this), busdValue);

        //SaleInfo storage s = sale[saleId];
        require(
            block.timestamp >= s.time[0] && block.timestamp <= s.time[1],
            Error.VE_SALE_OUT_OF_BOUND
        );

        uint256 purchaseTokens = (purchaseValue * 10**18) / s.costPerToken;
        purchaseTokens = purchaseTokens / 10**(18 - s.tokenDecimal);

        require(
            ((s.totalAllocated - s.publicAllocated - s.totalSold) > 0 &&
                purchaseTokens <=
                (s.totalAllocated - s.publicAllocated - s.totalSold)),
            "ERROR : Insufficient tokens"
        );

        if (s.whitelist) {
            require(
                allocation[_msgSender()] >= purchaseTokens,
                Error.VE_INSUFFICIENT_ALLOCATION
            );
            s.totalSold += purchaseTokens;
            allocation[_msgSender()] -= purchaseTokens;
            UserPurchase memory tempUsrPurchase;
            // publicSalers.push(_msgSender());//similarly we have stakers
            tempUsrPurchase = UserPurchase(_msgSender(), purchaseTokens);
            totalSales.push(tempUsrPurchase);
            return purchaseTokens;
        } else {
            StakingInfo memory info = staking.stakeInfo(
                _msgSender(),
                s.stakePoolId
            );

            uint256 allocated = getAllocationPerStake(info.amount);
            require(
                allocated >= purchaseTokens + stakeSalePurchase[_msgSender()],
                Error.VE_INSUFFICIENT_ALLOCATION
            );

            s.totalSold += purchaseTokens;
            stakeSalePurchase[_msgSender()] += purchaseTokens;
            //here comes the totalSales
            UserPurchase memory tempUsrPurchase;
            // publicSalers.push(_msgSender());//similarly we have stakers
            tempUsrPurchase = UserPurchase(_msgSender(), purchaseTokens);
            totalSales.push(tempUsrPurchase);
            //return purchased tokens
            return purchaseTokens;

            // return
            //     settleTokens(
            //         s.vested,
            //         s.time[2],
            //         _msgSender(),
            //         s.tokenAddress,
            //         purchaseTokens,
            //         saleId
            //     );
        }
    }

    /* /// @dev settles the tokens to the users.
    function settleTokens(
        bool vested,
        uint256 claimTime,
        address user,
        address token,
        uint256 purchased,
        uint256 saleId
    ) private returns (bool) {
        if (!vested) {
            if (block.timestamp > claimTime) {
                IERC20(token).transfer(user, purchased);
            } else {
                unclaimed[user] += purchased;
            }
        }
        emit Purchase(user, purchased);
        return true;
    }*/

    /// @dev returns the USD equivalent value of BNB sent via tx
    function usdValue(uint256 bnbValue) private view returns (uint256) {
        (, int256 b, , , ) = oracle.latestRoundData();
        uint256 price = uint256(b);
        return ((price * bnbValue) / 10**18);
    }

    /// @dev see {RevolLauncher-withdrawTokens}
    /*
    function withdrawTokens()
        external
        virtual
        override
        onlyOwner
        returns (bool)
    {
        //SaleInfo storage s = sale[saleId];
        require(s.time[3] < block.timestamp, Error.VE_SALE_NOT_ENDED);

        require(s.totalAllocated > s.totalSold, Error.VE_NO_VALUE_TO_CLAIM);
        IERC20(s.tokenAddress).transfer(
            owner(),
            s.totalAllocated - s.totalSold
        );

        return true;
    }*/

    /// @dev see {RevoLauncher-setStakingContract}
    function setStakingContract(address stakingAddress)
        external
        virtual
        override
        onlyOwner
        returns (bool)
    {
        require(stakingAddress != address(0), Error.VE_ZERO_ADDRESS);
        staking = IRevoStaking(stakingAddress);

        return true;
    }

    /// @dev see {RevoLauncher-setStakingContract}
    function setOracleContract(address oracleAddress)
        external
        virtual
        override
        onlyOwner
        returns (bool)
    {
        require(oracleAddress != address(0), Error.VE_ZERO_ADDRESS);
        oracle = IChainlink(oracleAddress);

        return true;
    }

    /// @dev see {RevoLauncher-whitelistUser}
    function whitelistUser(WhiteListInfo[] memory _usrAddrAmt)
        external
        onlyOwner
        returns (bool)
    {
        for (uint256 i = 0; i < _usrAddrAmt.length; i++)
            allocation[_usrAddrAmt[i].userAddress] = _usrAddrAmt[i]
                .purchaseAmount;
        return true;
    }

    /// @dev setTierLevel ;
    //[[5,10],[10,100],[15,150],[20,250],[50,1000]]
    function setTierLevel(
        uint256[5] calldata tierMinStakeAmount,
        uint256[5] calldata tierAllocation
    ) external onlyOwner {
        _setTier(tierMinStakeAmount, tierAllocation);
    }

    //Get Purchase Data of sender. address -> uint oxabc => 240 tokens

    function getTotalSalesData() external view returns (UserPurchase[] memory) {
        return totalSales;
    }

    //Withdraw BNB & BUSD and Recover functions

    function recoverBNB() external onlyOwner returns (bool) {
        //SaleInfo storage s = sale[saleId];
        require(s.time[3] < block.timestamp, Error.VE_SALE_NOT_ENDED);
        address recipient = owner();
        payable(recipient).transfer(address(this).balance);

        return true;
    }

    function recoverToken(
        address token,
        address destination,
        uint256 amount
    ) external onlyOwner {
        require(token != destination, "Invalid address");
        require(IERC20(token).transfer(destination, amount), "Retrieve failed");
    }

    function getSalePublicAllocated() external view returns (uint256) {
        return s.publicAllocated;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

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

pragma solidity ^0.8.9;

import {StakingInfo, PoolInfo} from "../types/Type.sol";

/// @title IRevoStaking
/// @author Nodeberry (P) Ltd.,
/// @dev this is the interface for staking contracts.

interface IRevoStaking {
    /// @dev emitted when the owner creates a new pool
    event PoolCreated(
        uint256 poolId,
        address stakingToken,
        address rewardToken,
        uint256 yieldPerSecond
    );

    /// @dev emitted when the owner creates a new pool
    event PoolStatusChanged(uint256 poolId, uint256 status);

    /// @dev emitted when a user stakes token into a pool
    event Stake(address user, uint256 amount, uint256 poolId, uint256 time);

    /// @dev emitted when a user claims token from a pool
    event Claim(
        address user,
        uint256 reward,
        uint256 poolId,
        uint256 time,
        bool withPrincipal
    );

    /// @dev can create a new staking pool
    /// @param stakingToken is the address of token that users have to stake
    /// @param rewardToken is the address of the token users will claim
    /// @param yieldPerSecond is the yield per second.
    /// @return a boolean representing the status of the transaction.
    /// Note Set rewardToken to Zero Address to open a pool without reward.
    function createPool(
        address stakingToken,
        address rewardToken,
        uint256 yieldPerSecond
    ) external returns (bool);

    /// @dev can deactivate a pool for further staking.
    /// @param poolId is the identifier of the pool.
    /// @param status is the representation of the pool status.
    /// @return a bool representing the status of the transaction.
    /// Note 1 represents inactive pool & 0 represents active pool.
    function changePoolStatus(uint256 poolId, uint256 status)
        external
        returns (bool);

    /// @dev can change the status of a staking pool.
    /// @param status is the representation of the staking status.
    function toggleStakingStatus(bool status) external returns (bool);

    /// @dev can allow users to stake their tokens in the smart contract.
    /// @param poolId is the identifier of the staking pool.
    /// @param amount is the amount of tokens willing to be staked.
    /// @return a bool representing the status of the transaction.
    /// Note make sure the amount of tokens is approved
    function stakeToken(uint256 poolId, uint256 amount) external returns (bool);

    /// @dev can allow users to claim their tokens in the smart contract.
    /// @param poolId is the identifier of the staking pool.
    /// @param includingPrincipal is to harvest/entirely claim the tokens from pool.
    /// @return a bool representing the status of the transaction.
    /// Note make sure the amount of tokens is approved
    function claimToken(uint256 poolId, bool includingPrincipal)
        external
        returns (bool);

    /// @dev allows users to see unclaimed token value.
    /// @param poolId is the identifier of the staking pool.
    /// @return uint256 representing the amount of unclaimed tokens.
    function stakeInfo(address user, uint256 poolId)
        external
        returns (StakingInfo memory);

    /// @dev allows users to see unclaimed token value.
    /// @param poolId is the identifier of the staking pool.
    /// @return uint256 representing the amount of unclaimed tokens.
    function fetchUnclaimed(uint256 poolId) external returns (uint256);

    /// @dev allows users to fetch pool info.
    /// @param poolId is the identifier of the staking pool.
    /// @return uint256 representing the amount of unclaimed tokens.
    function fetchPool(uint256 poolId) external returns (PoolInfo memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IRevoLauncher {
    /// @dev is emitted when a new sale is created.
    event SaleCreated(
        address saleAddress,
        uint256 tokenDecimal,
        uint256 saleAmount,
        uint256 publicAllocation,
        uint256 costPerToken,
        uint256 startTime,
        uint256 endTime,
        uint256 stakePoolId,
        bool whitelist
    );

    event SendTokenInfo(uint256 allocatedUsd, uint256 allocatedTokens);

    /// @dev is emitted when a new sale is created.
    event Purchase(address user , uint256 tokens);

    /// @dev creates a sale of token.
    /// @param saleAddress is the SaleToken Address.
    /// @param costPerToken is the cost of each token in USD.
    /// @return bool representing the status of the transaction.
    function createSale(
        address saleAddress,
        uint256 tokenDecimal,
        uint256 saleAmount,
        uint256 publicAllocation,
        uint256 costPerToken,
        uint256[4] memory time,
        uint256 publicPerWallet,
        uint256 stakePoolId,
        bool vested,
        bool whitelist
    ) external returns (bool);

    /// @dev allows users to purchase tokens in a sale from public pool using BNB.
   
    /// Note payable BNB is converted to USD using chainlink for settlement of purchased tokens.
    /// @return _tokens representing the status of the transaction.
    function publicPurchaseWithBNB()
        external
        payable
        returns (uint256 _tokens);

    /// @dev allows users to purchase tokens in a sale from allocated pool using BNB.
   
    /// Note payable BNB is converted to USD using chainlink for settlement of purchased tokens.
    /// @return _tokens representing the status of the transaction.
    function allocatedPurchaseWithBNB()
        external
        payable
        returns (uint256 _tokens);

    /// @dev allows users to purchase tokens in a sale from public pool using BUSD.
   
    /// @param purchaseValue is the value of purchase in USD.
    /// @return _tokens uint256 representing the status of the transaction.
    function publicPurchaseWithBUSD( uint256 purchaseValue)
        external
        returns (uint256 _tokens);

    /// @dev allows users to purchase tokens in a sale from allocated pool using BUSD.
   
    /// @param purchaseValue is the value of purchase in USD.
    /// @return _tokens representing the status of the transaction.
    function allocatedPurchaseWithBUSD( uint256 purchaseValue)
        external
        returns (uint256 _tokens);

    /// @dev withdraw unsold tokens from the sale contract

    /// @return _tokens representing the state of transation
    //function withdrawTokens() external returns (bool);

    /// @dev sets the staking contract address.
    /// @param stakingAddress is the address of the staking contract.
    /// Note address cannot be zero address
    function setStakingContract(address stakingAddress) external returns (bool);

    /// @dev sets the bnb price oracle address.
    /// @param oracleAddress is the address of the staking contract.
    /// Note address cannot be zero address
    function setOracleContract(address oracleAddress) external returns (bool);

/*
    function recoverBNB(uint256 saleId) external returns(bool);


    function recoverToken(
        address token,
        address destination,
        uint256 amount
    ) external;*/

    /*/// @dev whitelists an user address.
    /// @param userAddress is the address of the user.
    /// @param purchaseAmount is the amount allocated for the user.
    function whitelistUser(
        uint256 saleId,
        address userAddress,
        uint256 purchaseAmount
    ) external returns (bool);*/
}

// SPDX-License-Identifier: ISC
pragma solidity ^0.8.9;

interface IChainlink {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @title Error
/// @author Nodeberry (P) Ltd.,
/// @dev all error codes can be found here.
/// Note all the require function inherit error codes from here.

library Error {
    string public constant VE_INSUFFICIENT_ALLOWANCE =
        "Error: Insufficient Allowance";
    string public constant VE_INSUFFICIENT_BALANCE =
        "Error: Insufficient Balance";
    string public constant VE_DECREASE_ALLOWANCE =
        "Error: Decreased allowance less than zero";
    string public constant VE_ZERO_ADDRESS =
        "Error: address cannot be zero address";
    string public constant VE_INVALID_POOLID =
        "Error: pool is either not created or paused";
    string public constant VE_ZERO_STAKED =
        "Error: no stake found to fetch unclaimed amount";
    string public constant VE_NO_VALUE_TO_CLAIM =
        "Error: no tokens left for claiming";
    string public constant VE_INVALID_SALEID =
        "Error: sale is either not created or ended";
    string public constant VE_SALE_NOT_ENDED =
        "Error: withdraw once the sale is ended";
    string public constant VE_ZERO_LEFT = "Error: sale is completely sold out";
    string public constant LE_STAKING_PAUSED =
        "Error: staking/redemption is paused";
    string public constant VE_INSUFFICIENT_TOKENS_LEFT_FOR_SALE =
        "Error: insufficient amount of tokens left for sale";
    string public constant VE_INSUFFICIENT_ALLOCATION =
        "Error: user doesn't have this much tokens allocated";
    string public constant VE_SALE_OUT_OF_BOUND =
        "Error: sale time is out of bounds";
    string public constant VE_UNBOUNDED_PURCHASE_LIMIT =
        "Error: purchase token limit exceeded";
    string public constant VE_ERROR_INPUT_VALIDATION =
        "Error : Validate the input arguments";
}

// SPDX-License-Identifier: ISC

pragma solidity ^0.8.9;

import {TierInfo} from "../types/Type.sol";

contract Tier {

     TierInfo[5] private tierLevelPerProject;

    function _setTier(  uint256[5] calldata tierMinStakeAmount,
    uint256[5] calldata tierAllocation)
    internal 
    {
        require(tierMinStakeAmount.length == 5&&tierAllocation.length==5 , "Invalid Tier Level Inputs");
        for (uint256 i = 0; i < 5; i++)
            tierLevelPerProject[i] = TierInfo(tierMinStakeAmount[i],tierAllocation[i]);

        }

    /// @dev compute Allocation as per Stake, array of max token allocated per Tier and not usd
    function getAllocationPerStake( uint256 _stkAmt)
        public
        view
        returns (uint256)
    {
        if (_stkAmt >= tierLevelPerProject[4].tierMinStakeAmount)
            return tierLevelPerProject[4].tierAllocation;
        //tier 5
        else if (
            _stkAmt >= tierLevelPerProject[3].tierMinStakeAmount &&
            _stkAmt < tierLevelPerProject[4].tierMinStakeAmount
        ) return tierLevelPerProject[3].tierAllocation;
        //tier 4
        else if (
            _stkAmt >= tierLevelPerProject[2].tierMinStakeAmount &&
            _stkAmt < tierLevelPerProject[3].tierMinStakeAmount
        ) return tierLevelPerProject[2].tierAllocation;
        //tier 3
        else if (
            _stkAmt >= tierLevelPerProject[1].tierMinStakeAmount &&
            _stkAmt < tierLevelPerProject[2].tierMinStakeAmount
        ) return tierLevelPerProject[1].tierAllocation;
        //tier 2
        else return tierLevelPerProject[0].tierAllocation; //tier 1
    }


}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/// @title Type.sol
/// @author Nodeberry (P) Ltd.,
/// All user defined types would be added in here

struct PoolInfo {
    address rewardToken;
    address stakingToken;
    /// @dev yieldPerSecond is 2 precision.
    uint256 yieldPerSecond;
    uint256 totalStaked;
}

struct StakingInfo {
    uint256 stakeTime;
    uint256 amount;
}

struct SaleInfo {
    address tokenAddress;
    uint256 tokenDecimal;
    uint256 totalAllocated;
    uint256 publicAllocated;
    /// @dev whitelist is false then it is staking only.
    bool whitelist;
    bool vested;
    uint256 totalSold;
    uint256[4] time;
    uint256 stakePoolId;
    /// @dev cost in usd is 8-precision.
    uint256 costPerToken;
    uint256 publicPerWallet;
}
struct TierInfo{
    uint256 tierMinStakeAmount;
    uint256 tierAllocation;
}

struct WhiteListInfo{
            address userAddress;
        uint256 purchaseAmount;
}

struct UserPurchase{
    address userAddress;
    uint256 purchaseAmount;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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