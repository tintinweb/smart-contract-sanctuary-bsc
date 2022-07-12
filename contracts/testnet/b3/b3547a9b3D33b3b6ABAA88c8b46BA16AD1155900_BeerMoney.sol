// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./security/ReEntrancyGuard.sol";
import "./factory/FactoryStakeNft.sol";
import "./helpers/StakeableNFT.sol";
import "./helpers/TransformAmount.sol";

contract BeerMoney is
    ReEntrancyGuard,
    FactoryStakeNft,
    StakeableNFT,
    TransformAmount
{
    // @dev Add functionality like "burn" to the _stake afunction
    function stakeNft(uint256 _StakeId, uint256 _tokenId) external noReentrant {
        // @dev get the stake
        TypeStake storage stake = _Stake[_StakeId];

        // @dev check if the stake is active
        require(stake.status, "Stake Nft: not available");

        // @dev is owner of the nft
        require(
            _msgSender() == IERC721(stake.addressNft).ownerOf(_tokenId),
            "Stake Nft: Sender must be owner"
        );

        // tokenID permission check
        require(
            stake.min >= _tokenId && stake.max <= _tokenId,
            "Stake Nft: tokenId out of range"
        );

        // @dev verifica si el sc puede operar todos los nft del sender
        require(
            IERC721(stake.addressNft).isApprovedForAll(
                _msgSender(),
                address(this)
            ),
            "Stake Nft: not approved"
        );

        // @dev tranfer the token to the contract
        IERC721(stake.addressNft).transferFrom(
            _msgSender(),
            address(this),
            _tokenId
        );

        // @dev add the reward to the stake contract
        _stake(
            _tokenId,
            stake.addressNft,
            stake.addressTokenReward,
            stake.decimalsTokenReward,
            getDays(stake.day),
            stake.rewardTotal
        );
    }

    // /**
    //  * @notice
    //  * Withdraw NFT Sender
    //  * Required that sender, send a ID of array Stakeholder
    //  */
    function withdrawNFTStake(uint256 index) external noReentrant {
        // @dev get the stake
        (
            address addressNft,
            address addressTokenReward,
            uint256 decimalsTokenReward,
            uint256 reward,
            uint256 idNft
        ) = _withdrawStake(index);

        // @dev transfer the token to the sender
        IERC721(addressNft).transferFrom(address(this), _msgSender(), idNft);

        uint256 rewardTotal = transformAmountToTokenDecimal(
            reward,
            decimalsTokenReward
        );

        // @dev transfer the token to the sender
        IERC20(addressTokenReward).transfer(_msgSender(), rewardTotal);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
pragma solidity 0.8.9;

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../security/Administered.sol";

contract FactoryStakeNft is Administered {
    struct TypeStake {
        address addressNft;
        address addressTokenReward;
        uint256 decimalsTokenReward;
        uint256 rewardTotal;
        uint256 day;
        uint256 min;
        uint256 max;
        bool status;
    }

    mapping(uint256 => TypeStake) public _Stake;
    uint256 public _stakeCount;

    constructor() {
        _stakeCount = 0;
    }

    // @dev  register staking types
    function registerStake(
        address _addressNft,
        address _addressTokenReward,
        uint256 _decimalsTokenReward,
        uint256 _rewardTotal,
        uint256 _day,
        uint256 _min,
        uint256 _max,
        bool _status
    ) external onlyUser {
        _Stake[_stakeCount] = TypeStake(
            _addressNft,
            _addressTokenReward,
            _decimalsTokenReward,
            _rewardTotal,
            _day,
            _min,
            _max,
            _status
        );
        _stakeCount++;
    }

    // @dev we return all registered staking types
    function stakeList() external view returns (TypeStake[] memory) {
        unchecked {
            TypeStake[] memory stakes = new TypeStake[](_stakeCount);
            for (uint256 i = 0; i < _stakeCount; i++) {
                TypeStake storage s = _Stake[i];
                stakes[i] = s;
            }
            return stakes;
        }
    }

    // @dev we deactivate establishment
    function EditStaked(uint256 _id, bool _active) external onlyUser {
        _Stake[_id].status = _active;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @notice Stakeable is a contract who is ment to be inherited by other contract that wants Staking capabilities
 */
contract StakeableNFT is Context {
    using SafeMath for uint256;

    /**
     * @notice Constructor since this contract is not ment to be used without inheritance
     * push once to stakeholders for it to work proplerly
     */
    constructor() {
        // This push is needed so we avoid index 0 causing bug of index-1
        stakeholders.push();
    }

    /**
     * @notice
     * A stake struct is used to represent the way we store stakes,
     * A Stake will contain the users address, the amount staked and a timestamp,
     * Since which is when the stake was made
     */
    struct Stake {
        address user;
        uint256 idNft;
        address addressNft;
        address addressTokenReward;
        uint256 decimalsTokenReward;
        uint256 sinceBlock;
        uint256 untilBlock;
        uint256 rewardTotal;
        // This claimable field is new and used to tell how big of a reward is currently available
        uint256 claimable;
    }

    /**
     * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }
    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */
    struct StakingSummary {
        uint256 total_amount;
        Stake[] stakes;
    }

    /**
     * @notice
     *   This is a array where we store all Stakes that are performed on the Contract
     *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
     */
    Stakeholder[] internal stakeholders;
    /**
     * @notice
     * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */
    mapping(address => uint256) internal stakes;
    /**
     * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */

    event Staked(
        address indexed user,
        uint256 _idNft,
        address _addressNft,
        address _addressTokenReward,
        uint256 _decimalsTokenReward,
        uint256 _untilBlock,
        uint256 indexed _rewardTotal
    );

    // ---------- STAKES ----------

    /**
     * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array
     */
    function _addStakeholder(address staker) internal returns (uint256) {
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex;
    }

    /**
     * @notice
     * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID
     */

    function _stake(
        uint256 _idNft,
        address _addressNft,
        address _addressTokenReward,
        uint256 _decimalsTokenReward,
        uint256 _untilBlock,
        uint256 _rewardTotal
    ) internal {
        // Mappings in solidity creates all values, but empty, so we can just check the address
        uint256 index = stakes[_msgSender()];
        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 sinceBlock = block.timestamp;
        // See if the staker already has a staked index or if its the first time
        if (index == 0) {
            // This stakeholder stakes for the first time
            // We need to add him to the stakeHolders and also map it into the Index of the stakes
            // The index returned will be the index of the stakeholder in the stakeholders array
            index = _addStakeholder(_msgSender());
        }

        uint256 timeToDistribute = sinceBlock + _untilBlock;

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.
        stakeholders[index].address_stakes.push(
            Stake(
                _msgSender(),
                _idNft,
                _addressNft,
                _addressTokenReward,
                _decimalsTokenReward,
                sinceBlock,
                timeToDistribute,
                _rewardTotal,
                0
            )
        );
        // Emit an event that the stake has occured
        emit Staked(
            _msgSender(),
            _idNft,
            _addressNft,
            _addressTokenReward,
            _decimalsTokenReward,
            _untilBlock,
            _rewardTotal
        );
    }

    /**
     * @notice A method to the aggregated stakes from all stakeholders.
     * @return uint256 The aggregated stakes from all stakeholders.
     */
    function _totalStakes() internal view returns (uint256) {
        uint256 __totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            __totalStakes =
                __totalStakes +
                stakeholders[s].address_stakes.length;
        }

        return __totalStakes;
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
     */
    function _withdrawStake(uint256 index)
        internal
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256
        )
    {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[_msgSender()];
        Stake memory current_stake = stakeholders[user_index].address_stakes[
            index
        ];

        // @dev time to distribute is the time the stake is valid until
        require(
            block.timestamp >= current_stake.untilBlock,
            "WithdrawStake: You cannot withdraw, it is still in its authorized blocking time"
        );

        // Calculate available Reward first before we start modifying data
        uint256 reward = current_stake.rewardTotal;

        // Remove by subtracting the money unstaked
        delete stakeholders[user_index].address_stakes[index];

        // return the amount to mint
        return (
            current_stake.addressNft,
            current_stake.addressTokenReward,
            current_stake.decimalsTokenReward,
            reward,
            current_stake.idNft
        );
    }

    /**
     * @notice
     * hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function hasStake(address _staker)
        public
        view
        returns (StakingSummary memory)
    {
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount;
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(
            0,
            stakeholders[stakes[_staker]].address_stakes
        );

        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = summary.stakes[s].rewardTotal;
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].rewardTotal;
        }
        // Assign calculate amount to summary
        summary.total_amount = totalStakeAmount;
        return summary;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../security/Administered.sol";

contract TransformAmount is Administered {
    // @dev SafeMath library
    using SafeMath for uint256;

    // @dev
    address public vaultAddress = address(0);

    constructor() {
        // @dev set the vault address
        vaultAddress = _msgSender();
    }

    // @dev transforma los montos a 18 decimales
    function transformAmountTo18Decimal(uint256 _amount, uint256 _decimal)
        internal
        pure
        returns (uint256)
    {
        if (_decimal == 18) {
            return _amount;
        } else if (_decimal == 8) {
            return _amount.mul(10**10);
        } else if (_decimal == 6) {
            return _amount.mul(10**12);
        }
        return 0;
    }

    // @dev tranformas las decimales del token
    function transformAmountToTokenDecimal(uint256 _amount, uint256 decimal)
        internal
        pure
        returns (uint256)
    {
        if (decimal == 18) {
            return _amount;
        } else if (decimal == 8) {
            return _amount.div(10**10);
        } else if (decimal == 6) {
            return _amount.div(10**12);
        }
        return 0;
    }

    // @dev fee calculation for token
    function calculateFee(uint256 amount, uint256 _fee)
        internal
        pure
        returns (uint256 fee)
    {
        return (amount.mul(_fee)).div(10000);
    }

    // // @dev we get the blocking days of a staking type
    function getDays(uint256 _day) public pure returns (uint256) {
        return _day * 1 days;
    }

    // @dev Token purchase limit changes
    function setVaultAddress(address _address)
        external
        onlyUser
        returns (bool)
    {
        vaultAddress = _address;
        return true;
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
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Administered
 * @notice Implements Admin and User roles.
 */
contract Administered is AccessControl {
    bytes32 public constant USER_ROLE = keccak256("USER");

    /// @dev Add `root` to the admin role as a member.
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setRoleAdmin(USER_ROLE, DEFAULT_ADMIN_ROLE);
    }

    /// @dev Restricted to members of the admin role.
    modifier onlyAdmin() {
        require(isAdmin(_msgSender()), "Restricted to admins.");
        _;
    }
    /// @dev Restricted to members of the user role.
    modifier onlyUser() {
        require(isUser(_msgSender()), "Restricted to users.");
        _;
    }

    /// @dev Return `true` if the account belongs to the admin role.
    function isAdmin(address account) public view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @dev Return `true` if the account belongs to the user role.
    function isUser(address account) public view virtual returns (bool) {
        return hasRole(USER_ROLE, account);
    }

    /// @dev Add an account to the user role. Restricted to admins.
    function addUser(address account) public virtual onlyAdmin {
        grantRole(USER_ROLE, account);
    }

    /// @dev Add an account to the admin role. Restricted to admins.
    function addAdmin(address account) public virtual onlyAdmin {
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @dev Remove an account from the user role. Restricted to admins.
    function removeUser(address account) public virtual onlyAdmin {
        revokeRole(USER_ROLE, account);
    }

    /// @dev Remove oneself from the admin role.
    function renounceAdmin() public virtual {
        renounceRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
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
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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

import "./IERC165.sol";

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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}