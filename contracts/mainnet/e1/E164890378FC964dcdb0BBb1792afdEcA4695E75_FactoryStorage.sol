// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/*
  ______                     ______                                 
 /      \                   /      \                                
|  ▓▓▓▓▓▓\ ______   ______ |  ▓▓▓▓▓▓\__   __   __  ______   ______  
| ▓▓__| ▓▓/      \ /      \| ▓▓___\▓▓  \ |  \ |  \|      \ /      \ 
| ▓▓    ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓    \| ▓▓ | ▓▓ | ▓▓ \▓▓▓▓▓▓\  ▓▓▓▓▓▓\
| ▓▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓    ▓▓_\▓▓▓▓▓▓\ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓
| ▓▓  | ▓▓ ▓▓__/ ▓▓ ▓▓▓▓▓▓▓▓  \__| ▓▓ ▓▓_/ ▓▓_/ ▓▓  ▓▓▓▓▓▓▓ ▓▓__/ ▓▓
| ▓▓  | ▓▓ ▓▓    ▓▓\▓▓     \\▓▓    ▓▓\▓▓   ▓▓   ▓▓\▓▓    ▓▓ ▓▓    ▓▓
 \▓▓   \▓▓ ▓▓▓▓▓▓▓  \▓▓▓▓▓▓▓ \▓▓▓▓▓▓  \▓▓▓▓▓\▓▓▓▓  \▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓ 
         | ▓▓                                             | ▓▓      
         | ▓▓                                             | ▓▓      
          \▓▓                                              \▓▓         
 * App:             https://ApeSwap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * Discord:         https://ApeSwap.click/discord
 * Reddit:          https://reddit.com/r/ApeSwap
 * Instagram:       https://instagram.com/ApeSwap.finance
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "@ape.swap/contracts/contracts/v0.8/access/PendingOwnable.sol";
import "./interfaces/IFactoryStorage.sol";
import "./interfaces/ICustomBill.sol";

contract FactoryStorage is IFactoryStorage, PendingOwnable {
    /* ======== STATE VARIABLES ======== */
    BillDetails[] public billDetails;

    address public billFactory;

    mapping(address => uint256) public indexOfBill;

    /* ======== EVENTS ======== */

    event BillCreation(address treasury, address bill, address nftAddress);
    event FactoryChanged(address newFactory);

    /* ======== OWNER FUNCTIONS ======== */

    /**
        @notice pushes bill details to array
        @param _billCreationDetails ICustomBill.BillCreationDetails
        @param _customBill address
        @param _billNFT address
        @return _treasury address
        @return _bill address
     */
    function pushBill(
        ICustomBill.BillCreationDetails memory _billCreationDetails,
        address _customTreasury,
        address _customBill,
        address _billNFT
    ) external override returns (address _treasury, address _bill) {
        require(billFactory == msg.sender, "Not Factory");

        indexOfBill[_customBill] = billDetails.length;

        billDetails.push(BillDetails({
            payoutToken: _billCreationDetails.payoutToken,
            principalToken: _billCreationDetails.principalToken,
            treasuryAddress: _customTreasury,
            billAddress: _customBill,
            billNft: _billNFT,
            tierCeilings: _billCreationDetails.tierCeilings,
            fees: _billCreationDetails.fees
    }));

        emit BillCreation(_customTreasury, _customBill, _billNFT);
        return (_customTreasury, _customBill);
    }

    /**
        @notice returns total bills
     */
    function totalBills() public view override returns(uint) {
        return  billDetails.length;
    }

    /**
     * @notice get BillDetails at index
     * @param _index Index of BillDetails to look up
     */
    function getBillDetails(uint256 _index) external view override returns (BillDetails memory) {
        require(_index < totalBills(), "index out of bounds");
        return billDetails[_index];
    }

    function billFees(uint256 _billId) external view returns (uint256[] memory, uint256[] memory) {
        BillDetails memory bill = billDetails[_billId];
        uint256 length = bill.tierCeilings.length;
        uint256[] memory _tierCeilings = new uint[](length);
        uint256[] memory _fees = new uint[](length);
        for (uint256 i = 0; i < length; i++) {
            _tierCeilings[i] = bill.tierCeilings[i];
            _fees[i] = bill.fees[i];
        }
        return (_tierCeilings, _fees);
    }

    /**
        @notice changes factory address
        @param _factory address
     */
    function setFactoryAddress(address _factory) external onlyOwner {
        billFactory = _factory;
        emit FactoryChanged(billFactory);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface IVestingCurve {
    /**
     * @notice Returns the vested token amount given the inputs below.
     * @param totalPayout Total payout vested once the vestingTerm is up
     * @param vestingTerm Length of time in seconds that tokens are vesting for
     * @param startTimestamp The timestamp of when vesting starts
     * @param checkTimestamp The timestamp to calculate vested tokens
     *
     * Requirements
     * - If checkTimestamp is less than startTimestamp, return 0
     * - If checkTimestamp is greater than startTimestamp + vestingTerm, return totalPayout
     */
    function getVestedPayoutAtTime(
        uint256 totalPayout,
        uint256 vestingTerm,
        uint256 startTimestamp,
        uint256 checkTimestamp
    ) external pure returns (uint256 vestedPayout_);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "./ICustomBill.sol";

interface IFactoryStorage {
    struct BillDetails {
        address payoutToken;
        address principalToken;
        address treasuryAddress;
        address billAddress;
        address billNft;
        uint256[] tierCeilings;
        uint256[] fees;
    }

    function totalBills() external view returns(uint);

    function getBillDetails(uint256 index) external returns (BillDetails memory);

    function pushBill(
        ICustomBill.BillCreationDetails calldata _billCreationDetails,
        address _customTreasury,
        address billAddress,
        address billNft
    ) external returns (address _treasury, address _bill);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface ICustomTreasury {
    function deposit(
        address _principalTokenAddress,
        uint256 _amountPrincipalToken,
        uint256 _amountPayoutToken
    ) external;

    function deposit_FeeInPayout(
        address _principalTokenAddress,
        uint256 _amountPrincipalToken,
        uint256 _amountPayoutToken,
        uint256 _feePayoutToken,
        address _feeReceiver
    ) external;

    function initialize(address _payoutToken, address _initialOwner, address _payoutAddress) external;

    function valueOfToken(address _principalTokenAddress, uint256 _amount)
        external
        view
        returns (uint256 value_);

   function payoutToken()
        external
        view
        returns (address token);
    
    function sendPayoutTokens(uint _amountPayoutToken) external;

    function billContract(address _billContract) external returns (bool _isEnabled);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "./ICustomTreasury.sol";
import "./IVestingCurve.sol";

interface ICustomBill {
    /// @notice Info for bill holder
    /// @param payout Total payout value
    /// @param payoutClaimed Amount of payout claimed
    /// @param vesting Seconds left until vesting is complete
    /// @param vestingTerm Length of vesting in seconds
    /// @param vestingStartTimestamp Timestamp at start of vesting
    /// @param lastClaimTimestamp Last timestamp interaction
    /// @param truePricePaid Price paid (principal tokens per payout token) in ten-millionths - 4000000 = 0.4
    struct Bill {
        uint256 payout; 
        uint256 payoutClaimed;
        uint256 vesting;
        uint256 vestingTerm; 
        uint256 vestingStartTimestamp;
        uint256 lastClaimTimestamp; 
        uint256 truePricePaid; 
    }

    struct BillCreationDetails {
        address payoutToken;
        address principalToken;
        address initialOwner;
        IVestingCurve vestingCurve;
        uint256[] tierCeilings;
        uint256[] fees;
        bool feeInPayout;
    }

    struct BillTerms {
        uint256 controlVariable;
        uint256 vestingTerm;
        uint256 minimumPrice;
        uint256 maxPayout;
        uint256 maxDebt;
        uint256 maxTotalPayout;
        uint256 initialDebt;
    }

    /// @notice Important accounts related to a CustomBill 
    /// @param feeTo Account which receives the bill fees
    /// @param DAO Account used to change the treasury address
    /// @param billNft BillNFT contract which mints the NFTs
    struct BillAccounts {
        address feeTo;
        address DAO;
        address billNft;
    }

    function initialize(
        ICustomTreasury _customTreasury,
        BillCreationDetails memory _billCreationDetails,
        BillTerms memory _billTerms,
        BillAccounts memory _billAccounts
    ) external;

    function customTreasury() external returns (ICustomTreasury);

    function claim(uint256 billId) external returns (uint256);

    function pendingVesting(uint256 billId) external view returns (uint256);

    function pendingPayout(uint256 billId) external view returns (uint256);

    function vestingPeriod(uint256 billId) external view returns (uint256 vestingStart_, uint256 vestingEnd_);

    function vestingPayout(uint256 billId) external view returns (uint256 vestingPayout_);

    function vestedPayoutAtTime(uint256 billId, uint256 timestamp) external view returns (uint256 vestedPayout_);

    function claimablePayout(uint256 billId) external view returns (uint256 claimablePayout_);

    function payoutToken() external view returns (IERC20MetadataUpgradeable);
    
    function principalToken() external view returns (IERC20MetadataUpgradeable);

    function getBillInfo(uint256 billId) external view returns (Bill memory);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PendingOwnable is Ownable {
    address private _pendingOwner;

    event SetPendingOwner(address indexed pendingOwner);

    constructor() Ownable() {}

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev This function is disabled to in place of setPendingOwner()
     */
    function transferOwnership(
        address /*newOwner*/
    ) public view override onlyOwner {
        revert("PendingOwnable: MUST setPendingOwner()");
    }

    /**
     * @dev Sets an account as the pending owner (`newPendingOwner`).
     * Can only be called by the current owner.
     */
    function setPendingOwner(address newPendingOwner) public virtual onlyOwner {
        _pendingOwner = newPendingOwner;
        emit SetPendingOwner(_pendingOwner);
    }

    /**
     * @dev Transfers ownership to the pending owner
     * Can only be called by the pending owner.
     */
    function acceptOwnership() public virtual {
        require(msg.sender == _pendingOwner, "PendingOwnable: MUST be pendingOwner");
        _pendingOwner = address(0);
        _transferOwnership(msg.sender);
    }
}