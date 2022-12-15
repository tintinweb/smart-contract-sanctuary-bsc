/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Sources flattened with hardhat v2.12.2 https://hardhat.org

// File common/IDAOInvestors.sol

// License-Identifier: MIT
pragma solidity ^0.8.17;

interface IDAOInvestors {
    function vestingDeposit(
        uint256 amount,
        address investor,
        uint256 vestingDuration,
        uint256 vestingStartDate
    ) external;
}


// File @openzeppelin/contracts/token/ERC20/[email protected]

// License-Identifier: MIT
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


// File common/IMFToken.sol

// License-Identifier: MIT
pragma solidity ^0.8.17;

interface IMFToken is IERC20 {
    function mint(address to, uint256 amount) external;
}


// File common/IMFSwap.sol

// License-Identifier: MIT
pragma solidity ^0.8.17;

interface IMFSwap {
    function swap(uint256 _amount, address _investor) external;
}


// File @openzeppelin/contracts/utils/[email protected]

// License-Identifier: MIT
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


// File @openzeppelin/contracts/access/[email protected]

// License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File common/BaseDAO.sol

// License-Identifier: MIT
pragma solidity ^0.8.17;




abstract contract BaseDAO is Ownable {
    uint256 constant decimals = 10 ** 2;

    function getProgress(
        uint256 _startDate,
        uint256 _duration
    ) internal view returns (uint256) {
        if (_startDate > block.timestamp) return 0;

        uint256 dateDiff = block.timestamp - _startDate;
        if (dateDiff > _duration) {
            return 100 * decimals;
        }

        uint256 progress = (dateDiff * decimals) / _duration;
        return progress;
    }
}


// File contracts/investorsDAO.sol

// License-Identifier: MIT
pragma solidity ^0.8.17;
contract InvestorsDAO is BaseDAO, IDAOInvestors {
    struct Vesting {
        uint256 amount;
        uint256 startDate;
        uint256 duration;
        uint256 amountWithdrawn;
    }

    struct Investor {
        uint256 fixedAmount;
        uint256 startLockIndex;
        Vesting[] vestings;
    }

    uint256 public index;
    uint256 public totalLock;
    address[] public treasuries;

    mapping(address => Investor) public investors;
    mapping(uint256 => uint256) public lockAmounts;
    mapping(uint256 => uint256) public revenueAmounts;

    IMFToken public immutable mf;

    event Deposit(
        address indexed investor,
        uint256 amount,
        uint256 indexed index
    );

    event Withdraw(address indexed investor, uint256 amount);
    event SendProfit(address indexed investor, uint256 amout);

    constructor(address[] memory _treasuries, address _mf) {
        treasuries = _treasuries;
        mf = IMFToken(_mf);
    }

    function _unsafe_inc(uint256 x) internal pure returns (uint256) {
        unchecked {
            return x + 1;
        }
    }

    function updateVestingWithdrawnReadyAmount(
        address _investor
    ) private returns (uint256) {
        Investor memory investor = investors[_investor];
        if (investor.vestings.length == 0) return 0;

        uint256 vestingAmount;
        for (uint256 i = 0; i < investor.vestings.length; i = _unsafe_inc(i)) {
            uint256 progress = getProgress(
                investor.vestings[i].startDate,
                investor.vestings[i].duration
            );

            if (progress > 0) {
                uint256 thisVestingAvailableAmount = (investor
                    .vestings[i]
                    .amount * progress) /
                    decimals -
                    investor.vestings[i].amountWithdrawn;

                vestingAmount += thisVestingAvailableAmount;
                investors[_investor]
                    .vestings[i]
                    .amountWithdrawn += thisVestingAvailableAmount;
            }
        }

        return investor.fixedAmount + vestingAmount;
    }

    function makeDaoProfit() public {
        uint256 usdtAmount;

        for (uint256 i = 0; i < treasuries.length; i = _unsafe_inc(i)) {
            address treasury = treasuries[i];
            uint256 balance = mf.allowance(treasury, address(this));

            if (balance > 0) {
                mf.transferFrom(treasury, address(this), balance);
                usdtAmount += balance;
            }
        }

        if (usdtAmount > 0) {
            revenueAmounts[index] = usdtAmount;
            lockAmounts[index] = totalLock;
            index = _unsafe_inc(index);
        }
    }

    function getTotalInvestmentAmount(
        address _investor
    ) public view returns (uint256) {
        uint256 availableVestingSum;
        Investor memory investor = investors[_investor];

        for (uint256 i = 0; i < investor.vestings.length; i = _unsafe_inc(i)) {
            availableVestingSum +=
                investor.vestings[i].amount -
                investor.vestings[i].amountWithdrawn;
        }
        return availableVestingSum + investor.fixedAmount;
    }

    function deposit(uint256 _amount) external {
        address _investor = msg.sender;
        Investor storage investor = investors[_investor];
        mf.transferFrom(_investor, address(this), _amount);

        if (investor.fixedAmount != 0) {
            sendProfit(_investor);
        }

        investor.startLockIndex = index;
        investor.fixedAmount += _amount;
        totalLock += _amount;

        emit Deposit(_investor, getTotalInvestmentAmount(_investor), index);
    }

    function vestingDeposit(
        uint256 _amount,
        address _investor,
        uint256 _vestingDuration,
        uint256 _vestingStartDate
    ) external {
        Investor storage investor = investors[_investor];

        mf.transferFrom(msg.sender, address(this), _amount);

        if (investor.fixedAmount != 0) {
            sendProfit(_investor);
        }

        totalLock += _amount;
        investor.startLockIndex = index;
        investor.vestings.push(
            Vesting(_amount, _vestingStartDate, _vestingDuration, 0)
        );

        emit Deposit(_investor, getTotalInvestmentAmount(msg.sender), index);
    }

    function sendProfit(address _investor) public {
        Investor memory investor = investors[_investor];

        uint256 totalRevenue;
        uint256 totalInvestment = getTotalInvestmentAmount(_investor);

        for (
            uint256 i = investor.startLockIndex;
            i < index;
            i = _unsafe_inc(i)
        ) {
            totalRevenue +=
                (totalInvestment * revenueAmounts[i]) /
                lockAmounts[i];
        }

        investors[_investor].startLockIndex = index;
        mf.transfer(_investor, totalRevenue);

        emit SendProfit(_investor, totalRevenue);
    }

    function withdraw() external {
        address _investor = msg.sender;

        Investor storage investor = investors[_investor];
        uint256 fixedAmount = investor.fixedAmount;
        uint256 withdrawVestingResult = updateVestingWithdrawnReadyAmount(
            _investor
        );

        sendProfit(_investor);
        totalLock -= fixedAmount + withdrawVestingResult;

        mf.transfer(_investor, fixedAmount + withdrawVestingResult);
        investor.fixedAmount = 0;

        emit Withdraw(_investor, fixedAmount + withdrawVestingResult);
    }

    function setTreasury(address[] calldata _treasuries) external onlyOwner {
        treasuries = _treasuries;
    }
}