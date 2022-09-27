// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import {IFireCatNFT} from "../src/interfaces/IFireCatNFT.sol";
import {IFireCatNFTStake} from "../src/interfaces/IFireCatNFTStake.sol";
import {IFireCatGate} from "../src/interfaces/IFireCatGate.sol";
import {IFireCatVault} from "../src/interfaces/IFireCatVault.sol";
import {IFireCatIssuePool} from "../src/interfaces/IFireCatIssuePool.sol";
import {FireCatTrigger} from "./FireCatTrigger.sol";
import {ModifyControl} from "../src/utils/ModifyControl.sol";

/**
 * @title FireCat's FireCatVault contract
 * @notice main: stake, claim, exitFunds
 * @author FireCat Finance
 */
contract FireCatVault is IFireCatVault, FireCatTrigger, ModifyControl {
    using SafeMath for uint256;

    function initialize(
        address cakeToken_, 
        address swapRouter_, 
        address fireCatNFT_, 
        address fireCatNFTStake_, 
        address fireCatIssuePool_,
        address fireCatRegistry_,
        address fireCatReserves_,
        address fireCatRecommend_
    ) initializer public {
        stakeToken = cakeToken_;
        cakeToken = IERC20(cakeToken_);
        swapRouter = swapRouter_;
        fireCatNFT = fireCatNFT_;
        fireCatNFTStake = fireCatNFTStake_;
        fireCatIssuePool = fireCatIssuePool_;
        fireCatRegistry = fireCatRegistry_;
        fireCatReserves = fireCatReserves_;
        fireCatRecommend = fireCatRecommend_;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);   
    }

    /// @inheritdoc IFireCatVault
    function isQualified(address user_) public view returns (bool) {
        return IFireCatNFTStake(fireCatNFTStake).isStaked(user_);
    }
    
    /// @inheritdoc IFireCatVault
    function tokenIdOf(address user_) public view returns (uint256) {
        return IFireCatNFTStake(fireCatNFTStake).stakedOf(user_);
    }

    /// @inheritdoc IFireCatVault
    function migrateIn(uint256 tokenId_, uint256 amount_) external onlyRole(FIRECAT_GATE) returns(uint256) {
        require(cakeToken.balanceOf(msg.sender) >= amount_, "VAULT:E01");
        uint256 actualAddAmount = _stake(tokenId_, amount_, msg.sender);  // fireCatNFTStake Stake Cake to this vault
        IFireCatIssuePool(fireCatIssuePool).stake(tokenId_, actualAddAmount);
        return actualAddAmount;
    }

    /// @inheritdoc IFireCatVault
    function migrateOut(uint256 tokenId_, uint256 amount_) external renewPool onlyRole(FIRECAT_GATE) returns (uint256) {
        require(staked[tokenId_] >= amount_, "VAULT:E04");
        address tokenOwner = IFireCatNFT(fireCatNFT).ownerOf(tokenId_);
        _getReward(tokenOwner, tokenId_);  // claim reward to user

        uint256 actualClaimedAmount = _getReward(tokenOwner, tokenId_);
        uint256 actualSubAmount = _withdraw(msg.sender, tokenId_, amount_);  // withdraw to fireCatNFTStake contract 
        IFireCatIssuePool(fireCatIssuePool).withdrawn(tokenId_, actualSubAmount);
        totalInvest = totalFunds.sub(actualClaimedAmount).sub(actualSubAmount);
        return actualSubAmount;
    }

    /// @inheritdoc IFireCatVault
    function claimTokens(address token, address to, uint256 amount) external nonReentrant onlyRole(SAFE_ADMIN) {
        if (amount > 0) {
            if (token == address(0)) {
                (bool res,) = to.call{value : amount}("");
                require(res, "VAULT:E03");
            } else {
                withdraw(token, to, amount);
            }
        }
    }

    /// @inheritdoc IFireCatVault
    function stake(uint256 amount_) external beforeStake isBanned(msg.sender) nonReentrant {
        require(isQualified(msg.sender), "VAULT:E00");
        // require(amount_ >= 10 ** 18, "VAULT:E01");
        require(cakeToken.balanceOf(msg.sender) >= amount_, "VAULT:E01");

        uint256 tokenId_ = tokenIdOf(msg.sender);
        uint256 actualAddAmount = _stake(tokenId_, amount_, msg.sender);
        IFireCatIssuePool(fireCatIssuePool).stake(tokenId_, actualAddAmount);
    }

    /// @inheritdoc IFireCatVault
    function claim(uint256 tokenId_) external beforeClaim isBanned(msg.sender) nonReentrant {
        address tokenOwner = IFireCatNFT(fireCatNFT).ownerOf(tokenId_);
        if (tokenOwner == fireCatNFTStake) {
            // nft staked in fireCatNFTStake
            uint256 stakedTokenId = IFireCatNFTStake(fireCatNFTStake).stakedOf(msg.sender);
            require(stakedTokenId == tokenId_, "VAULT:E02");
        } else {
            // nft not staked in fireCatNFTStake, someone own the nft
            require(msg.sender == tokenOwner, "VAULT:E02");
        }

        _claim(tokenId_, msg.sender);
        
    }

    /// @inheritdoc IFireCatVault
    function exitFunds(uint256 tokenId_, address user_) external nonReentrant onlyRole(FIRECAT_GATE) returns(uint256) {
        address tokenOwner = IFireCatNFT(fireCatNFT).ownerOf(tokenId_);
        require(user_ == tokenOwner, "VAULT:E02");

        uint256 actualSubAmount = _exitFunds(tokenId_, user_);
        IFireCatIssuePool(fireCatIssuePool).withdrawn(tokenId_, actualSubAmount);
        return actualSubAmount;
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;


/**
* @notice IFireCatNFTStake
*/
interface IFireCatNFTStake {
    /**
    * @dev the state of NFT action.
    */
    enum State {
        locked,
        unstakeable,
        stakeable,
        claimable
    }

    /**
    * @notice the total staked amount.
    * @return totalStaked
    */
    function totalStaked() external view returns (uint256);
    
    /**
    * @notice fetch the staked tokenId of user.
    * @param user_ address
    * @return tokenId
    */
    function stakedOf(address user_) external view returns (uint256);

    /**
    * @notice fetch the max stake number of user.
    * @dev fetch token level from NFT contract.
    * @param user_ address
    * @return stakeMaxNum
    */
    function stakeMaxNumOf(address user_) external view returns (uint256);
    
    /**
    * @notice check whether the user has staked.
    * @param user_ address
    * @return isStaked
    */
    function isStaked(address user_) external view returns (bool);

    /**
    * @notice fetch the staking state of user.
    * @param user_ address
    * @return isStaked
    */
    function stateOf(address user_) external view returns (State);

    /**
    * @notice set the stake max number of token level.
    * @param tokenLevel_ uint256
    * @param maxNum_ uint256
    */
    function setStakeMaxNum(uint256 tokenLevel_, uint256 maxNum_) external;

    /**
    * @notice set the nft fireCatPool address.
    * @param pool_ address
    */
    function setPool(address pool_) external;

    /**
    * @notice set the registryProxy address.
    * @param registryProxy_ address
    */
    function setRegistryProxy(address registryProxy_) external;

    /**
    * @notice The interface of IERC721 withdrawn.
    * @dev Trasfer token to admin.
    * @param tokenId_ uint256.
    */
    function sweep(uint256 tokenId_) external;


    /**
    * @notice The interface of IERC20 withdrawn.
    * @dev Trasfer token to admin.
    * @param token address.
    * @param amount uint256.
    * @return actualSubAmount.
    */
    function withdrawRemaining(address token, uint256 amount) external returns (uint256);

    /**
    * @notice the interface of stake.
    * @dev firstly, check the state of user.
    * @param tokenId_ uint256
    * @return isStaked
    */
    function stake(uint256 tokenId_) external returns (bool);

    /**
    * @notice the interface of claim.
    * @dev firstly, check the state of user.
    * @return tokenId
    */
    function claim() external returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

/**
* @notice IFireCatGate
*/
interface IFireCatGate {

    /**
    * @notice check the vault address of version.
    * @param version uint256
    * @return vault
    */
    function vaultOf(uint256 version) external view returns (address);

    /**
    * @notice check the totalStaked of user, fetch data from all vault.
    * @param tokenId_ uint256
    * @return totalVaultStaked
    */
    function vaultStakedOf(uint256 tokenId_) external view returns(uint256);

    /**
    * @notice the interface of migrate, fetch data from vaultFrom, stake data to vaultTo
    * @param tokenId uint256
    * @param vaultFrom address
    * @param vaultTo address
    */   
    function migrate(uint256 tokenId, address vaultFrom, address vaultTo) external;

    /**
    * @notice the stake switch, default is false
    * @param isMigrateOn_ bool
    */   
    function setMigrateOn(bool isMigrateOn_) external;

    /**
    * @notice the stake switch, default is false
    * @param isDestroyOn_ bool
    */    
    function setDestroyOn(bool isDestroyOn_) external;

    /**
    * @notice set vault list.
    * @param vaultVersions_ uint256[]
    * @param vaultAddress_ address[]
    */
    function setVault(uint256[] calldata vaultVersions_, address[] calldata vaultAddress_) external;

    /**
    * @notice set the fireCat treasury contract.
    * @dev set to fireCatTreasury.
    * @param fireCatTreasury_ address.
    */
    function setFireCatTreasury(address fireCatTreasury_) external;

    /**
    * @notice the interface of destroy
    * @param tokenId uint256
    */   
    function destroy(uint256 tokenId) external;

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

/**
* @notice IFireCatGate
*/
interface IFireCatVault {
    /**
    * @notice check user's stake qualified.
    * @dev access data from fireCatGate
    * @param user_ address.
    * @return actualSubAmount
    */
    function isQualified(address user_) external view returns (bool);
    
    /**
    * @notice The tokenId of stake in gate contract.
    * @dev access data from fireCatGate.
    * @param user_ address.
    */
    function tokenIdOf(address user_) external view returns (uint256);

    /**
    * @notice The interface of stake token migrate in.
    * @dev Trasfer token to vault.
    * @param tokenId_ address.
    * @param amount_ uint256.
    */
    function migrateIn(uint256 tokenId_, uint256 amount_) external returns(uint256);

    /**
    * @notice The interface of stake token migrate out.
    * @dev Trasfer token to msg.sender.
    * @param tokenId_ address.
    * @param amount_ uint256.
    */
    function migrateOut(uint256 tokenId_, uint256 amount_) external returns (uint256);

    /**
    * @notice The interface of token withdrawn.
    * @dev Trasfer token to to_address.
    * @param token address.
    * @param to address.
    * @param amount uint256.
    */
    function claimTokens(address token, address to, uint256 amount) external;

    /**
    * @notice the interface of stake
    * @param amount_ uint256.
    */
    function stake(uint256 amount_) external;

    /**
    * @notice the interface of claim
    * @param tokenId_ uint256.
    */    
    function claim(uint256 tokenId_) external;

    /**
    * @notice the interface of exitFunds
    * @param tokenId_ uint256.
    * @param user_ address..
    * @return actualSubAmount
    */
    function exitFunds(uint256 tokenId_, address user_) external returns(uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

/**
* @notice IFireCatIssuePool
*/
interface IFireCatIssuePool {
    /**
    * @notice the total earnings amount
    * @return totalEarnings
    */
    function totalEarnings() external view returns (uint256);

    /**
    * @dev Rewards per token
    * @return Returns the reward amount for staked tokens
    */
    function rewardPerToken() external view returns (uint256);

    /**
    * @dev View user revenue
    * @param tokenId_ uint256
    * @return Returns the revenue the user has already earned
    */
    function earned(uint256 tokenId_) external view returns (uint256);

    /**
    * @dev Rewards that users can already claim
    * @param account_ User address
    * @return Returns the reward that the user has moderated
    */
    function userAward(address account_) external view returns (uint256);
    /**
    * @notice check the claim of user.
    * @param user_ address
    * @return availableClaim, claimed, locked
    */
    function reviewOf(address user_) external view returns (uint256, uint256, uint256);

    /**
    * @dev User earned reward, received reward
    * @param tokenId_ uint256
    * @return User data
    */
    function issueUserData(uint256 tokenId_) external view returns (uint256, uint256);

    /**
    * @notice set harvest rewardRate.
    * @param startingTime_ uint256
    * @param rewardRate_ uint256
    */
    function setRewardRate(uint256 startingTime_, uint256 rewardRate_) external;

    /**
    * @notice set reward LockTime.
    * @param newLockTime_ uint256
    */
    function setLockTime(uint256 newLockTime_) external;

    /**
    * @notice The interface of token withdrawn.
    * @dev Trasfer token to to_address.
    * @param token address.
    * @param to address.
    * @param amount uint256.
    */
    function claimTokens(address token, address to, uint256 amount) external;

    /**
    * @notice topUp the reward amount.
    * @param addAmount uint256
    * @return actualAddAmount
    */
    function topUp(uint256 addAmount) external returns (uint256);

    /**
    * @notice the interface of stake
    * @param tokenId_ uint256
    * @param amount_ uint256
    */
    function stake(uint256 tokenId_, uint256 amount_) external;
    
    /**
    * @notice the interface of withdrawn
    * @param tokenId_ uint256
    * @param amount_ uint256
    */
    function withdrawn(uint256 tokenId_, uint256 amount_) external;
    /**
    * @notice the interface of harvest
    * @param tokenId_ uint256
    */
    function harvest(uint256 tokenId_) external;

    /**
    * @notice the interface of claim
    */
    function claim() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import {ISmartChefInitializable} from "../src/interfaces/ISmartChefInitializable.sol";
import {IPancakeRouter02} from "../src/interfaces/IPancakeRouter02.sol";
import {IFireCatRegistryProxy} from "../src/interfaces/IFireCatRegistryProxy.sol";
import {IFireCatReserves} from "../src/interfaces/IFireCatReserves.sol";
import {IFireCatRecommend} from "../src/interfaces/IFireCatRecommend.sol";
import {IFireCatTrigger} from "../src/interfaces/IFireCatTrigger.sol";
import {FireCatAccessControl} from "../src/utils/FireCatAccessControl.sol";
import {FireCatTransfer} from "../src/utils/FireCatTransfer.sol";
import {FireCatTriggerStorage} from "../src/storages/FireCatTriggerStorage.sol";

/**
 * @title FireCat's FireCatTrigger contract
 * @notice main: redeemFunds, reinvest
 * @author FireCat Finance
 */
contract FireCatTrigger is IFireCatTrigger, FireCatTriggerStorage, FireCatTransfer, FireCatAccessControl {
    using SafeMath for uint256;

    event Staked(address indexed user_, uint256 tokenId_, uint256 actualAddAmount_, uint256 totalStakedNew);
    event Claimed(address indexed user_, uint256 tokenId_, uint256 actualClaimedAmount, uint256 totalClaimedNew);
    event Withdrawn(address indexed user_, uint256 tokenId_, uint256 actualSubAmount, uint256 totalStakedNew);
    event Swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    event SetPath(address rewardToken_, address[] swapPath_);
    event SetMiningPool(address user_, uint256[] weightsArray_, address[] smartChefArray_);
    event SetExitFeeFactor(address user_, uint256 exitFeeFactor_);
    event SetReservesShareFactor(address user_, uint256 reservesShareFactor_);
    event SetInviterShareFactor(address user_, uint256 inviterShareFactor_);

    modifier renewPool(){
        _redeemFunds();
        _;
        _reinvest();
    }

    /// @inheritdoc IFireCatTrigger
    function totalEarnings() public view returns (uint256) {
        // rewardPerToken * totalStaked
        return rewardPerTokenStored.mul(totalStaked).div(1e18);
    }
    
    /// @inheritdoc IFireCatTrigger
    function rewardOf(uint256 tokenId_) public view returns (uint256) {
        return (rewardPerTokenStored.sub(userOwnRewardPerToken[tokenId_])).mul(staked[tokenId_]).div(1e18);
    }

    /**
    * @notice update rewardPerToken.
    * @return rewardPerToken
    */
    function _updateRewardPerToken() internal view returns (uint256) {
        // (totalFunds - totalInvest) / totalStaked + rewardPerTokenStored
        if (totalStaked == 0 ) {
            return 0;
        }
        return (totalFunds.sub(totalInvest)).mul(1e18).div(totalStaked).add(rewardPerTokenStored);
    }

    /**
    * @notice check the last reward of user.
    * @param tokenId_ uint256
    * @return reward
    */
    function _updateRewardOf(uint256 tokenId_) internal view returns (uint256) {
        // (rewardPerToken - userOwnRewardPerToken[tokenId_]) * staked[tokenId_]
        uint256 newRewardPerToken_ = _updateRewardPerToken();
        return (newRewardPerToken_.sub(userOwnRewardPerToken[tokenId_])).mul(staked[tokenId_]).div(1e18);
    }

    function _updateRate(uint256 tokenId_) internal {
        uint256 _rewardPerToken = _updateRewardPerToken();
        rewardPerTokenStored = _rewardPerToken;
        userOwnRewardPerToken[tokenId_] = _rewardPerToken;
    }
    
    function _addStake(address from_, uint256 tokenId_, uint256 amount_) internal returns (uint256) {
        uint256 actualAddAmount = doTransferIn(address(cakeToken), from_, amount_);
        uint256 totalStakedNew = totalStaked.add(actualAddAmount);
        require(totalStakedNew > totalStaked, "VAULT:E08");
        totalStaked = totalStakedNew;
        staked[tokenId_] = staked[tokenId_].add(actualAddAmount);
        emit Staked(from_, tokenId_, actualAddAmount, totalStakedNew);
        return actualAddAmount;
    }

    function _withdraw(address to_, uint256 tokenId_, uint256 amount_) internal returns (uint256) {
        uint256 actualSubAmount = doTransferOut(address(cakeToken), to_, amount_);
        uint256 totalStakedNew = totalStaked.sub(actualSubAmount);
        require(totalStakedNew < totalStaked, "VAULT:E08");
        totalStaked = totalStakedNew;
        staked[tokenId_] = staked[tokenId_].sub(actualSubAmount);
        emit Withdrawn(to_, tokenId_, actualSubAmount, totalStakedNew);
        return actualSubAmount;
    }

    function _claimInternal(address to_, uint256 tokenId_, uint256 amount_) internal returns (uint256) {
        uint256 actualClaimedAmount = doTransferOut(address(cakeToken), to_, amount_);
        uint256 totalClaimedNew = totalClaimed.add(actualClaimedAmount);
        require(totalClaimedNew > totalClaimed, "VAULT:E08");
        totalClaimed = totalClaimedNew;
        claimed[tokenId_] = claimed[tokenId_].add(actualClaimedAmount);
        emit Claimed(to_, tokenId_, actualClaimedAmount, totalClaimedNew);
        return actualClaimedAmount;
    }

    function _getReward(address user_, uint256 tokenId_) internal returns (uint256) {
        if (totalFunds > 0) {
            uint256 reward = _updateRewardOf(tokenId_);
            _updateRate(tokenId_);
            
            if (reward > 0) {
                // reserves contracat reward
                uint256 reservesReward = reward.mul(reservesShareFactor).div(1e9);
                cakeToken.approve(fireCatReserves, reservesReward);
                uint256 actualReservesClaimed = IFireCatReserves(fireCatReserves).addReserves(user_, reservesReward);

                // inviter reward
                address inviterAddress = IFireCatRegistryProxy(fireCatRegistry).getInviter(user_);
                // (reward - actualReservesClaimed) * inviterShareFactor / 1e9;
                uint256 inviterReward = (reward.sub(actualReservesClaimed)).mul(inviterShareFactor).div(1e9);
                cakeToken.approve(fireCatRecommend, inviterReward);
                uint256 actualInviterClaimed = IFireCatRecommend(fireCatRecommend).addReward(inviterAddress, inviterReward);

                // uesr reward
                uint256 userReward = reward - actualReservesClaimed - actualInviterClaimed;
                uint256 actualUserClaimed = _claimInternal(user_, tokenId_, userReward);
                
                return actualInviterClaimed + actualReservesClaimed + actualUserClaimed;
            }
        }
        return 0;
    }

    function _swap(address tokenIn, uint256 amountIn_) internal returns (uint256) {
        if (amountIn_ == 0) {
            return 0;
        }

        address[] memory path = swapPath[tokenIn];
        address tokenOut = path[path.length - 1];

        // Calculate the amount of exchange result.  [swapIn, swapOut]
        uint256[] memory amounts = IPancakeRouter02(swapRouter).getAmountsOut(amountIn_, path);

        IERC20(tokenIn).approve(swapRouter, amountIn_);
        uint256[] memory SwapResult = IPancakeRouter02(swapRouter).swapExactTokensForTokens(
            amountIn_,  // the amount of input tokens.
            amounts[1],  // The minimum amount tokens to receive.
            path,  // An array of token addresses. path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity.
            address(this),  // Address of recipient.
            block.timestamp  // Unix timestamp deadline by which the transaction must confirm.
        );

        uint256 actualIn = SwapResult[0];
        uint256 actualOut = SwapResult[1];
        require(actualIn > 0 && actualOut > 0, "VAULT:E07");
        emit Swap(tokenIn, tokenOut, actualIn, actualOut);
        return actualOut;
    }

    function _redeemFunds() internal {
        if (totalInvest == 0 ) {
            // last invest funds is zero, no funds withdraw from smartChef.
            totalFunds = 0;
        } else {
            require(smartChefArray.length > 0, "VAULT:E06");
            uint256 prevBalance = cakeToken.balanceOf(address(this));
            
            for (uint256 i = 0; i < smartChefArray.length; ++i) {
                uint256 weight = weightsArray[i];
                smartChef = ISmartChefInitializable(smartChefArray[i]);
                address rewardToken = smartChef.rewardToken();

                if (weight > 0) {
                    (uint256 stakedAmount,) = smartChef.userInfo(address(this));  // fetch last staked amount
                    uint256 prevRewardBalance = IERC20(rewardToken).balanceOf(address(this));
                    smartChef.withdraw(stakedAmount);  // withdraw all cake and rewardToken.
                    uint256 afterRewardBalance = IERC20(rewardToken).balanceOf(address(this));

                    uint256 actualRewardBalance = afterRewardBalance - prevRewardBalance;
                    _swap(rewardToken, actualRewardBalance);
                }
            
            }

            uint256 afterBalance = cakeToken.balanceOf(address(this));
            totalFunds = afterBalance.sub(prevBalance);
        }
        
    }

    function _reinvest() internal {
        require(smartChefArray.length > 0, "VAULT:E06");
        uint256 prevBalance = cakeToken.balanceOf(address(this));
        uint256 length = smartChefArray.length;
        
        for (uint256 i = 0; i < length; ++i) {
            uint256 weight = weightsArray[i];
            smartChef = ISmartChefInitializable(smartChefArray[i]);

            if (weight > 0) {
                uint256 investAmount = totalInvest.mul(weight).div(100);
                cakeToken.approve(smartChefArray[i], investAmount);
                smartChef.deposit(investAmount);
            }
        
        }

        uint256 afterBalance = cakeToken.balanceOf(address(this));
        totalInvest = prevBalance.sub(afterBalance);    // actualInvestAmount
    }

    function _stake(uint256 tokenId_, uint256 amount_, address user_) internal renewPool returns (uint256) {        
        uint256 actualAddAmount;
        if (totalFunds == 0) {
            actualAddAmount = _addStake(user_, tokenId_, amount_);
            totalInvest = actualAddAmount;
        } else {
            uint256 actualClaimedAmount = _getReward(user_, tokenId_);
            actualAddAmount = _addStake(user_, tokenId_, amount_);
            totalInvest = totalFunds.sub(actualClaimedAmount).add(actualAddAmount);
        }
        return actualAddAmount;
    }

    function _claim(uint256 tokenId_, address user_) internal renewPool returns (uint256) {
        uint256 actualClaimedAmount = _getReward(user_, tokenId_);
        require(actualClaimedAmount > 0, "VAULT:E05");
        totalInvest = totalFunds.sub(actualClaimedAmount);
        return actualClaimedAmount;
    }

    function _exitFunds(uint256 tokenId_, address user_) internal renewPool returns (uint256) {
        uint256 actualClaimedAmount = _getReward(user_, tokenId_);

        // add tax to reserves contract
        uint256 reservesWithdraw =  staked[tokenId_].mul(exitFeeFacotr).div(1e9);
        cakeToken.approve(fireCatReserves, reservesWithdraw);
        uint256 actualReservesAmount = IFireCatReserves(fireCatReserves).addReserves(user_, reservesWithdraw);

        // withdraw to user
        uint256 userWithdraw = staked[tokenId_] - actualReservesAmount;
        uint256 actualUserAmount = doTransferOut(address(cakeToken), user_, userWithdraw);

        // clean totalStaked, staked
        uint256 totalWithdraw = actualReservesAmount + actualUserAmount;
        uint256 totalStakedNew = totalStaked.sub(totalWithdraw);
        require(totalStakedNew < totalStaked, "VAULT:E08");
        totalStaked = totalStakedNew;
        staked[tokenId_] = 0;

        totalInvest = totalFunds.sub(actualClaimedAmount).sub(totalWithdraw);
        emit Withdrawn(user_, tokenId_, totalWithdraw, totalStakedNew);
        return totalWithdraw;
    }

    /// @inheritdoc IFireCatTrigger
    function setPath(address rewardToken_, address[] calldata swapPath_) external nonReentrant onlyRole(DATA_ADMIN) {
        swapPath[rewardToken_] = swapPath_;
        emit SetPath(rewardToken_, swapPath_);
    }

    /// @inheritdoc IFireCatTrigger
    function setExitFeeFactor(uint256 exitFeeFactor_) external nonReentrant onlyRole(DATA_ADMIN) {
        // decimals: 1e9
        exitFeeFacotr = exitFeeFactor_;
        emit SetExitFeeFactor(msg.sender, exitFeeFactor_);
    }

    /// @inheritdoc IFireCatTrigger
    function setReservesShareFactor(uint256 reservesShareFactor_) external nonReentrant onlyRole(DATA_ADMIN) {
        // decimals: 1e9
        reservesShareFactor = reservesShareFactor_;
        emit SetReservesShareFactor(msg.sender, reservesShareFactor_);
    }

    /// @inheritdoc IFireCatTrigger
    function setInviterShareFactor(uint256 inviterShareFactor_) external nonReentrant onlyRole(DATA_ADMIN) {
        // decimals: 1e9
        inviterShareFactor = inviterShareFactor_;
        emit SetInviterShareFactor(msg.sender, inviterShareFactor_);
    }

    /// @inheritdoc IFireCatTrigger
    function setMiningPool(
        uint256[] calldata weightsArray_, 
        address[] calldata smartChefArray_
    ) external nonReentrant onlyRole(DATA_ADMIN) {
        require(weightsArray_.length == smartChefArray_.length, "VAULT:E09");
        weightsArray = weightsArray_;
        smartChefArray = smartChefArray_;
        emit SetMiningPool(msg.sender, weightsArray_, smartChefArray_);
    }

    /// @inheritdoc IFireCatTrigger
    function updatePool() external renewPool nonReentrant onlyRole(DATA_ADMIN) {
        require(totalFunds > 0, "VAULT:E10");
        _updateRate(0);
        totalInvest = totalFunds;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {FireCatAccessControl} from "./FireCatAccessControl.sol";


contract ModifyControl is FireCatAccessControl{
    event SetStakeOn(bool isStakeOn_);
    event SetClaimOn(bool isClaimOn_);
    
    mapping(address => bool) public blackList;

     /**
    * @dev switch on/off the stake function.
    */
    bool public isStakeOn = true;

    /**
    * @dev switch on/off the claim function.
    */
    bool public isClaimOn = true;

    modifier beforeStake() {
        require(isStakeOn, "stake is not on");
        _;
    }

    modifier beforeClaim() {
        require(isClaimOn, "claim is not on");
        _;
    }

    modifier isBanned(address user_) {
        require(!blackList[user_], "user is blocked");
        _;
    }

    /**
    * @notice the stake switch, default is false
    * @param isStakeOn_ bool
    */    
    function setStakeOn(bool isStakeOn_) external onlyRole(DATA_ADMIN) {
        isStakeOn = isStakeOn_;
        emit SetStakeOn(isStakeOn_);
    }

    /**
    * @notice the claim switch, default is false
    * @param isClaimOn_ bool
    */
    function setClaimOn(bool isClaimOn_) external onlyRole(DATA_ADMIN) {
        isClaimOn = isClaimOn_;
        emit SetClaimOn(isClaimOn_);
    }

    /**
    * @notice set black list.
    * @param blackList_ address[]
    * @param blocked_ bool
    */
    function setBlackList(address[] calldata blackList_, bool blocked_) external onlyRole(DATA_ADMIN) {
        for (uint256 i = 0; i < blackList_.length; ++i) {
            blackList[blackList_[i]] = blocked_;
        }
    }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

/**
 * @title ISmartChefInitializable contract interface
 */
interface ISmartChefInitializable {
    /**
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function deposit(uint256 _amount) external;

    /**
     * @notice return user staked and rewardDebt
     * @param user_: user_address
     */
    function userInfo(address user_) external returns(uint256, uint256);
    
    /**
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function withdraw(uint256 _amount) external;

    /**
     * @notice Withdraw staked tokens without caring about rewards rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external;

    /**
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) external view returns (uint256);

    /**
     * @notice Return user limit is set or zero.
     */
    function hasUserLimit() external view returns (bool);

    /**
     * @notice Get reward tokens
     */
    function rewardToken() external view returns (address);

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
 * @title FireCatRegistryProxy contract interface
 */
interface IFireCatRegistryProxy {
    /// IFireCatRegistryProxy

    /**
    * @notice user registration available switch.
    * @dev only owner.
    * @param switchOn_ switch side.
    */
    function setSwitchOn(bool switchOn_) external;

    /**
    * @notice user registration.
    * @dev set config to storage.
    * @param inviter_ inviter_address.
    */
    function userRegistration(address inviter_) external;

    /**
    * @notice user registration status.
    * @dev fetch data from storage.
    * @param user_ user_address.
     * @return status bool
    */
    function isRegistered(address user_) external view returns (bool);

    /**
    * @notice user's inviter.
    * @dev fetch data from storage.
    * @param user_ user_address.
     * @return inviter address
    */
    function getInviter(address user_) external view returns (address);

    /**
    * @notice inviter's users list.
    * @dev fetch data from storage.
    * @param inviter_ inviter_address.
     * @return users address list.
    */
    function getUsers(address inviter_) external view returns (address[] memory);

    /**
    * @notice num of total users.
    * @dev fetch data from storage.
     * @return uint256.
    */
    function getTotalUsers() external view returns (uint256);

    /**
    * @notice array of all users.
    * @dev fetch data from storage.
     * @return array of addresses.
    */
    function getUserArray() external view returns (address[] memory);
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
    * @param token address.
    * @param to address.
    * @param amount uint256.
    * @return actualSubAmount.
    */
    function withdrawRemaining(address token, address to, uint256 amount) external returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
* @notice IFireCatRecommend
*/
interface IFireCatRecommend {
    
    /**
    * @notice check reward by address.
    * @dev Fetch reward from _userReward.
    * @param user address.
    * @return reserves.
    */
    function rewardOf(address user) external view returns (uint256);

    /**
    * @notice the claimed amount of user.
    * @param user address
    * @return claimedAmount
    */
    function claimedOf(address user) external view returns (uint256);

    /**
    * @notice add reward amount, call from fireCatVault
    * @param user address
    * @param addAmount uint256
    * @return actualAddAmount
    */
    function addReward(address user, uint256 addAmount) external returns (uint256);

    /**
    * @notice The interface of reward withdrawn.
    * @dev Trasfer reward Token to owner.
    * @param amount uint256.
    * @return actualSubAmount.
    */
    function withdrawReward(uint256 amount) external returns (uint);

    /**
    * @notice The interface of IERC20 withdrawn, not include reward token.
    * @dev Trasfer token to owner.
    * @param amount uint256.
    * @return actualSubAmount.
    */
    function withdrawRemaining(address token, address to, uint256 amount) external returns (uint);

    /**
    * @notice the interface of claim
    */  
    function claim() external returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

/**
* @notice IFireCatTrigger
*/
interface IFireCatTrigger {
    /**
    * @notice the total earnings amount, depend on totalFunds and totalInvest
    * @return totalEarnings
    */
    function totalEarnings() external view returns (uint256);


    /**
    * @notice check the last reward of user.
    * @param tokenId_ uint256
    * @return reward
    */
    function rewardOf(uint256 tokenId_) external view returns (uint256);

     /**
    * @notice set the swap path.
    * @param rewardToken_ address
    * @param swapPath_ address[]
    */
    function setPath(address rewardToken_, address[] calldata swapPath_) external;

    /**
    * @notice set the exit funds fee facotr.
    * @param exitFeeFactor_ uint256
    */
    function setExitFeeFactor(uint256 exitFeeFactor_) external;

    /**
    * @notice set the reserves contract reward facotr.
    * @param reservesShareFactor_ uint256
    */
    function setReservesShareFactor(uint256 reservesShareFactor_) external;

    /**
    * @notice set the inviter share reward facotr.
    * @param inviterShareFactor_ uint256
    */
    function setInviterShareFactor(uint256 inviterShareFactor_) external;

    /**
    * @notice set the mining pools.
    * @param weightsArray_ uint256[]
    * @param smartChefArray_ address[]
    */
    function setMiningPool(uint256[] calldata weightsArray_, address[] calldata smartChefArray_) external;

    /**
    * @notice update the mining pools.
    */
    function updatePool() external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";


abstract contract FireCatAccessControl is AccessControlUpgradeable {
    // market administrator
    bytes32 public constant SAFE_ADMIN = bytes32(keccak256(abi.encodePacked("Safe_Admin")));

    // data administrator
    bytes32 public constant DATA_ADMIN = bytes32(keccak256(abi.encodePacked("Data_Admin")));

    // fireCatVault contract
    bytes32 public constant FIRECAT_VAULT = bytes32(keccak256(abi.encodePacked("FireCat_Vault")));

    // fireCatGate contract
    bytes32 public constant FIRECAT_GATE = bytes32(keccak256(abi.encodePacked("FireCat_Gate")));
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts-upgradeable/contracts/security/ReentrancyGuardUpgradeable.sol";

contract FireCatTransfer is ReentrancyGuardUpgradeable {
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
    function withdraw(address token, address to, uint256 amount) internal returns (uint) {
        require(token != address(0), "TOKEN_CANT_BE_ZERO");
        require(IERC20(token).balanceOf(address(this)) >= amount, "NOT_ENOUGH_TOKEN");
        IERC20(token).approve(to, amount);
        uint256 actualSubAmount = doTransferOut(token, to, amount);
        emit Withdraw(to, token, actualSubAmount);
        return actualSubAmount;
    }

    function burn(address token_, address sender_, uint256 amount_) internal returns (uint) {
        require(token_ != address(0), "TOKEN_CANT_BE_ZERO");
        uint balanceBefore = IERC20(token_).balanceOf(sender_);
        IERC20(token_).transferFrom(sender_, address(1), amount_);

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
        uint balanceAfter = IERC20(token_).balanceOf(sender_);
        require(balanceAfter <= balanceBefore, "TOKEN_TRANSFER_IN_OVERFLOW");
        return balanceBefore - balanceAfter;  // underflow already checked abov
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ISmartChefInitializable} from "../interfaces/ISmartChefInitializable.sol";

/**
 * @title FireCat's FireCatTriggerStorage contract
 * @notice main: 
 * @author FireCat Finance
 */
contract FireCatTriggerStorage {
    IERC20 cakeToken;
    ISmartChefInitializable smartChef;
    
    address public fireCatRegistry;
    address public fireCatNFT;
    address public fireCatIssuePool;
    address public fireCatNFTStake;
    address public fireCatReserves;
    address public fireCatRecommend;
    address public swapRouter;

    uint256 public totalFunds;  // redeem funds from mining pools
    uint256 public totalInvest;  // reinvest funds to mining pools

    address public stakeToken;
    uint256 public totalStaked;  // cake total staked amount
    uint256 public totalClaimed;
    uint256 public rewardPerTokenStored;
    mapping(uint256 => uint256) public staked;
    mapping(uint256 => uint256) public claimed;
    mapping(uint256 => uint256) public userOwnRewardPerToken;

    // fee or share factor config
    uint256 public exitFeeFacotr;
    uint256 public reservesShareFactor;
    uint256 public inviterShareFactor;

    // mining pools config 
    uint256[] public weightsArray;
    address[] public smartChefArray;

    // swap router
    mapping(address => address[]) public swapPath;
    

    
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(account),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
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
interface IERC165Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}