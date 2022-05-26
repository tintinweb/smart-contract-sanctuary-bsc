//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./parts/Withdrawable.sol";

interface ILegendaryFox is IERC20 {
    function legendaryTotalIncome(address address_) external view returns (uint256);

    function epicTotalIncomePerAddress(address address_) external view returns (uint256);

    function legendaryForClaim(address address_) external view returns (uint256);

    function epicForClaim(address address_) external view returns (uint256);

    function resetClaimableFor(address address_) external;
}

interface InvestmentsNFT is IERC721 {
    function totalToken() external view returns (uint256);
}

interface FarmsNFT is IERC721 {
    function farmsBalanceOf(address address_) external view returns (uint256);

    function increment(uint256 amount) external;

    function decrement(uint256 amount) external;
}

contract Game is Withdrawable {
    using SafeMath for uint256;

    address private _contractOwner;

    mapping(address => uint256) private _tFoxClaimTime;
    mapping(address => uint256) private _mFoxClaimTime;

    mapping(address => uint256) private _internalBalance;

    uint256 private _farmsCount;
    uint256 private _tFoxFarmsCount;
    uint256 private _mFoxFarmsCount;

    uint256 private _tFoxBR = 7;
    uint256 private _mFoxBR = 210;
    uint256 private _goldCoefficient = 20;
    uint256 private _silverCoefficient = 15;
    uint256 private _bronzeCoefficient = 15;
    uint256 private _withdrawFee = 15;

    ILegendaryFox private _coinContract;
    InvestmentsNFT private _epicNFTContract;
    InvestmentsNFT private _legendaryNFTContract;
    FarmsNFT private _tinyFarmsContract;
    FarmsNFT private _megaFarmsContract;
    IERC721 private _goldNFTContract;
    IERC721 private _silverNFTContract;
    IERC721 private _bronzeNFTContract;

    constructor (
        ILegendaryFox coinContract,
        InvestmentsNFT legendaryNFTContract,
        InvestmentsNFT epicNFTContract,
        FarmsNFT tinyFarmsContract,
        FarmsNFT megaFarmsContract,
        IERC721 goldNFTContract,
        IERC721 silverNFTContract,
        IERC721 bronzeNFTContract
    ) {
        _contractOwner = msg.sender;

        _coinContract = coinContract;

        _legendaryNFTContract = legendaryNFTContract;
        _epicNFTContract = epicNFTContract;

        _tinyFarmsContract = tinyFarmsContract;
        _megaFarmsContract = megaFarmsContract;

        _goldNFTContract = goldNFTContract;
        _silverNFTContract = silverNFTContract;
        _bronzeNFTContract = bronzeNFTContract;
    }

    function lastClaimTime(address address_) public view returns (uint256) {
        if (_tFoxClaimTime[address_] > 0) {
            return _tFoxClaimTime[address_];
        }

        return 0;
    }

    function _sPriceForIndex(uint256 idx_) private pure returns (uint256) {
        if (idx_ > 0 && idx_ <= 5) {
            return 20;
        } else if (idx_ > 5 && idx_ <= 10) {
            return 22;
        } else if (idx_ > 10 && idx_ <= 15) {
            return 24;
        } else if (idx_ > 15 && idx_ <= 20) {
            return 26;
        } else if (idx_ > 20 && idx_ <= 25) {
            return 28;
        } else if (idx_ > 25 && idx_ <= 30) {
            return 30;
        } else if (idx_ > 30 && idx_ <= 35) {
            return 32;
        } else if (idx_ > 35 && idx_ <= 40) {
            return 34;
        } else if (idx_ > 40 && idx_ <= 45) {
            return 36;
        } else if (idx_ > 45 && idx_ <= 50) {
            return 38;
        } else if (idx_ > 50 && idx_ <= 55) {
            return 40;
        } else if (idx_ > 55 && idx_ <= 60) {
            return 42;
        } else if (idx_ > 60 && idx_ <= 65) {
            return 44;
        } else if (idx_ > 65 && idx_ <= 70) {
            return 46;
        } else if (idx_ > 70 && idx_ <= 75) {
            return 48;
        } else {
            return 50;
        }
    }

    function _bPriceForIndex(uint256 idx_) private pure returns (uint256) {
        return idx_ * 10 + 10;
    }

    function _bsPriceForIndex(uint256 idx_) private pure returns (uint256) {
        if (idx_ == 1) {
            return 20;
        } else if (idx_ == 2) {
            return 22;
        } else if (idx_ == 3) {
            return 24;
        } else if (idx_ == 4) {
            return 26;
        } else if (idx_ == 5) {
            return 28;
        } else if (idx_ == 6) {
            return 30;
        } else if (idx_ == 7) {
            return 32;
        } else if (idx_ == 8) {
            return 34;
        } else if (idx_ == 9) {
            return 36;
        } else if (idx_ == 10) {
            return 38;
        } else {
            return 40;
        }
    }

    function _sPrice(address address_, uint256 amount_) public view returns (uint256){
        uint256 price = 0;

        uint256 currentBalance = _tinyFarmsContract.farmsBalanceOf(address_);

        for (uint256 i = currentBalance + 1; i < (currentBalance + amount_ + 1); i++) {
            price += _sPriceForIndex(i);
        }

        return price * (10 ** 8);
    }

    function createTinyFarm(uint256 amount_) public {
        uint256 amount = _sPrice(msg.sender, amount_);

        require(_internalBalance[msg.sender] >= amount, "Insufficient balance");

        _internalBalance[msg.sender] -= amount;

        if (_tinyFarmsContract.farmsBalanceOf(msg.sender) == 0) {
            _tFoxClaimTime[msg.sender] = block.timestamp;
        }

        _tinyFarmsContract.increment(amount_);

        _tFoxFarmsCount += amount_;
        _farmsCount += amount_;

        _distributeCoins(amount);
    }

    function farmsCount() public view returns (uint256) {
        return _farmsCount;
    }

    function tFoxFarmsCount() public view returns (uint256) {
        return _tFoxFarmsCount;
    }

    function mFoxFarmsCount() public view returns (uint256) {
        return _mFoxFarmsCount;
    }

    function _distributeCoins(uint256 amount_) private {
        uint256 gameBalance = _coinContract.balanceOf(address(this));

        if (gameBalance > 0 && gameBalance >= amount_) {
            _coinContract.transfer(address(_coinContract), amount_);
        }
    }

    function createMegaFarm() public {
        uint256 bNC = _megaFarmsContract.farmsBalanceOf(msg.sender);
        uint256 idx = _megaFarmsContract.farmsBalanceOf(msg.sender) + 1;
        uint256 coinAmount = _bPriceForIndex(idx) * (10 ** 8);
        uint256 tFoxAmount = _bsPriceForIndex(idx);

        require(_internalBalance[msg.sender] >= coinAmount, "Insufficient balance");
        require(_tinyFarmsContract.farmsBalanceOf(msg.sender) >= tFoxAmount, "Insufficient balance of Tiny Fox Farms");

        _internalBalance[msg.sender] -= coinAmount;

        if (bNC == 0) {
            _mFoxClaimTime[msg.sender] = block.timestamp;
        }

        _tinyFarmsContract.decrement(tFoxAmount);
        _megaFarmsContract.increment(1);

        _tFoxFarmsCount -= tFoxAmount;
        _mFoxFarmsCount += 1;
        _farmsCount -= (tFoxAmount - 1);

        _distributeCoins(coinAmount);
    }

    function rechargeBalance(uint256 amount_) public {
        uint256 coinBalance = _coinContract.balanceOf(msg.sender);
        uint256 amount = amount_;

        require(coinBalance >= amount, "Insufficient amount of LFOX tokens when replenishing the internal balance");

        uint256 allowForTransfer = _coinContract.allowance(msg.sender, address(this));
        require(allowForTransfer >= amount, "Error, there was no approve");

        _coinContract.transferFrom(msg.sender, address(this), amount);

        _internalBalance[msg.sender] += amount;
    }

    function withdrawBalance(uint256 amount_, bool all) public {
        if (all == false) {
            require(amount_ > 0, "Enter a value greater than 0");
        }
        require(_internalBalance[msg.sender] > 0, "Insufficient balance on the internal balance for withdrawing");

        uint256 amount;

        if (all == true) {
            amount = _internalBalance[msg.sender];
        }
        uint256 fee = amount.div(100).mul(_withdrawFee);
        uint256 actualAmount = amount - fee;

        _internalBalance[msg.sender] -= amount;

        _coinContract.transfer(msg.sender, actualAmount);
        _distributeCoins(fee);
    }

    function tFoxWorkingTime(address address_) public view returns (uint256) {
        uint256 time = block.timestamp.sub(_tFoxClaimTime[address_]);

        if (time > 259200) {
            time = 259200;
        }

        if (_tinyFarmsContract.farmsBalanceOf(msg.sender) == 0) {
            return 0;
        }

        return time;
    }

    function mFoxWorkingTime(address address_) public view returns (uint256) {
        uint256 time = block.timestamp.sub(_mFoxClaimTime[address_]);

        if (time > 259200) {
            time = 259200;
        }

        if (_megaFarmsContract.farmsBalanceOf(msg.sender) == 0) {
            return 0;
        }

        return time;
    }

    function epicClaimValue(address address_) public view returns (uint256) {
        return _coinContract.epicForClaim(address_);
    }

    function legendaryClaimValue(address address_) public view returns (uint256) {
        return _coinContract.legendaryForClaim(address_);
    }

    function _goldClaim(
        uint256 NFTCount,
        uint256 countFarms,
        uint256 mFoxBR,
        uint256 workingTime
    ) private view returns (uint256) {
        uint256 value = 0;

        if (NFTCount > 2) {
            NFTCount = 2;
        }

        uint256 factor = NFTCount.mul(5);

        uint256 higherRate = 0;
        if (countFarms > factor) {
            higherRate = factor;
        } else {
            higherRate = countFarms;
        }

        if (higherRate > 0) {
            uint256 mFoxClaim = mFoxBR.mul(workingTime);
            mFoxClaim = mFoxClaim.mul(higherRate);
            uint256 hPercent = mFoxClaim.div(100);
            value = hPercent.mul(_goldCoefficient);
        }

        return value;
    }

    function _silverClaim(
        uint256 NFTCount,
        uint256 goldNFTCount,
        uint256 countFarms,
        uint256 mFoxBR,
        uint256 workingTime
    ) private view returns (uint256) {
        uint256 value = 0;
        uint256 maxNFT = (10 - goldNFTCount.mul(5));

        if (maxNFT > 0) {
            if (NFTCount > maxNFT) {
                NFTCount = maxNFT;
            }

            if (goldNFTCount > 0) {
                countFarms = countFarms - maxNFT;
            }

            uint256 higherRate = 0;
            if (countFarms > NFTCount) {
                higherRate = NFTCount;
            } else {
                higherRate = countFarms;
            }

            if (higherRate > 0) {
                uint256 mFoxClaim = mFoxBR.mul(workingTime);
                mFoxClaim = mFoxClaim.mul(higherRate);
                uint256 hPercent = mFoxClaim.div(100);
                value = hPercent.mul(_silverCoefficient);
            }
        }

        return value;
    }

    function _bronzeClaim(address address_, uint256 tFoxClaim) private view returns (uint256) {
        uint256 value = 0;

        uint256 tFoxCount = _tinyFarmsContract.farmsBalanceOf(address_);
        uint256 nftCount = _bronzeNFTContract.balanceOf(address_);

        uint256 higherRate = nftCount.mul(2);

        if (higherRate > tFoxCount) {
            higherRate = tFoxCount;
        }

        if (higherRate > 0) {
            uint256 hClaim = tFoxClaim.mul(higherRate);
            uint256 hPercent = hClaim.div(100);
            value = hPercent.mul(_bronzeCoefficient);
        }

        return value;
    }

    function _mFoxClaimValue(address address_) private view returns (uint256) {
        uint256 value = 0;
        uint256 bNC = _megaFarmsContract.farmsBalanceOf(address_);

        if (bNC > 0) {
            uint256 mFoxBR = _mFoxBR.mul(10 ** 8).div(864000);
            uint256 mFoxWorkingTime_ = mFoxWorkingTime(address_);
            uint256 mFoxClaim = mFoxBR.mul(mFoxWorkingTime_);
            mFoxClaim = mFoxClaim.mul(bNC);

            value += mFoxClaim;

            uint256 goldCount = _goldNFTContract.balanceOf(address_);
            uint256 silverCount = _silverNFTContract.balanceOf(address_);

            if (goldCount >= 2) {
                value += _goldClaim(goldCount, bNC, mFoxBR, mFoxWorkingTime_);
            } else if (goldCount == 1 && silverCount > 0) {
                value += _goldClaim(goldCount, bNC, mFoxBR, mFoxWorkingTime_);
                value += _silverClaim(silverCount, 1, bNC, mFoxBR, mFoxWorkingTime_);
            } else if (goldCount == 0 && silverCount > 0) {
                value += _silverClaim(silverCount, 0, bNC, mFoxBR, mFoxWorkingTime_);
            }
        }

        return value;
    }

    function _tFoxClaimValue(address address_) private view returns (uint256) {
        uint256 value = 0;
        uint256 tFoxClaim = _tFoxBR.mul(10 ** 8).div(864000);
        uint256 tFoxWorkingTime_ = tFoxWorkingTime(address_);
        tFoxClaim = tFoxClaim.mul(tFoxWorkingTime_);

        uint256 subClaim = tFoxClaim.mul(_tinyFarmsContract.farmsBalanceOf(address_));

        if (_bronzeNFTContract.balanceOf(address_) > 0) {
            value = subClaim + _bronzeClaim(address_, tFoxClaim);
        } else {
            value = subClaim;
        }

        return value;
    }

    function claimValue(address address_) public view returns (uint256) {
        uint256 value = 0;

        value += _tFoxClaimValue(address_);

        value += _mFoxClaimValue(address_);

        value += epicClaimValue(address_);
        value += legendaryClaimValue(address_);

        return value;
    }

    function internalBalance(address address_) public view returns (uint256) {
        return _internalBalance[address_];
    }

    function claim() public {
        uint256 forClaim = claimValue(msg.sender);
        require(forClaim > 0, "There is nothing to claim");

        _internalBalance[msg.sender] += forClaim;
        _tFoxClaimTime[msg.sender] = block.timestamp;
        _mFoxClaimTime[msg.sender] = block.timestamp;
        _coinContract.resetClaimableFor(msg.sender);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Distributable.sol";

contract Withdrawable is Distributable {

    address internal constant withdrawWalletAddress = 0x69e07DbffFDDF108da0B24b0351a11f383a11E9b;

    function withdrawCoins(IERC20 coinAddress) public onlyAllowed {
        IERC20 coin = coinAddress;
        uint256 balance = coin.balanceOf(address(this));

        if (balance > 0) {
            coin.transfer(withdrawWalletAddress, balance);
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

pragma solidity ^0.8.13;

contract Distributable {

    address public constant teamAddress = 0x02DCe9c40968F6CB627Bd295e13a5c994e8a4a48;
    address public constant devAddress = 0xb386aBd1795A2D70F186989ef4C39d0d4E9BD658;
    address public constant marketingAddress = 0x0E5158FC2E69b691fbcFdbBa81064FEFF0C7F850;
    address public constant transitAddress = 0x2386D4318DA517b93D2E5cf902121F44162Fd48F;
    address public constant treasureAddress = 0xf9EC2F8733C828FC490A105Ea2B1767D804e6588;

    modifier onlyAllowed() {
        require(allowedForWithdraw(msg.sender), "Not allowed for withdraw");
        _;
    }

    function allowedForWithdraw(address operator) public pure virtual returns (bool) {
        return operator == teamAddress ||
        operator == devAddress ||
        operator == transitAddress ||
        operator == marketingAddress;
    }
}