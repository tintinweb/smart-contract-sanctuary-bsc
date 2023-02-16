// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity 0.8.9;

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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.9;

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
interface IBEP20 {
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
     * @dev Burns the {amount} amount of tokens from account .
     */
    function burn(address account, uint256 amount) external returns(bool);


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

pragma solidity >=0.6.2;

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
 
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

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/interfaces/IBEP20.sol";
import "./InErrors.sol";

abstract contract InDeclaration is Errors {


    enum InvestmentStatus {
        PENDING, 
        APPROVED, 
        DISAPPROVED
    }

     struct Investment {
        address investor;
        bytes16 investmentID;
        uint256 investedAmount;
        uint256 startDay;
        uint256 investingDays;
        uint256 reward;
        bool hasInsurance;
        uint256 stablePrincipal;
        uint256 stableReward;
        bool isActive;
        InvestmentStatus status;

    }

    address public TREASURY;
    address public ROUTER;
    address public FLEXVIS;
    address public BUSD;
    address public WBNB;
    address public INVESTMENT_RESERVE;

    IBEP20 internal flexvis;

    mapping(address => uint256) public investmentCount; 
    mapping(address => mapping(bytes16 => Investment)) public investments; 
    mapping(address => Investment[]) public allInvestment;
    address[] public allInvestors;
    bool public isPaused = false;

     // [365 days, 1095 days, 1825 days]
    uint[] public insuredRewardDurations;

    // [70%, 200%, 400%]
    uint[] public insuredRewardPercentages;

    address[] public flexvisToUSDPath;
    

    uint public MIN_AMOUNT = 10E18;
    uint public MAX_AMOUNT = 100E18;
    uint public INVESTMENT_RESERVE_BALANCE;
    uint public thresholdPercentage = 50;

    uint public totalInvested;
    uint public totalInsuredInvested;
    uint256 public totalAccumulatedReward;
    uint256 public stableTotalInsuredAmount;
    uint256 public stableTotalInsuredReward;
    uint256 public totalRewardIssuedOut;
    uint256 public topUpFlexvisIssuedOut;   
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

abstract contract Errors {
    error InvalidDuration();
    error InsufficientInvestmentAmount();
    error InsufficientFlexvisBalance();
    error InsufficientInsuredAmount();
    error NoInvestmentFound();
    error InvestmentNotActive();
    error ContractAddressRevoked();
    error ContractPaused();
    error InvestmentAlreadyApproved();
    error InvestmentAlreadyDisApproved();
    error InvestmentHasNoInsurance();
    error InvestmentDisapproved();
    error InvestmentPending();
    error InvestmentNotApproved();
    error InvestmentAlreadyActive();
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


abstract contract InEvents{

    event InsuredInvestmentCreated(
        bytes16 indexed investmentID,
        address indexed investor,
        uint256 investedAmount,
        uint256 indexed startDay,
        uint256 investingDays,
        uint256 stablePrincipal,
        uint256 stableReward,
        uint256 stableTotalInsuredAmount,
        uint256 stableTotalInsuredReward,
        uint256 totalAccumulatedReward
    );

    event InsuredInvestmentRecreated(
        bytes16 indexed investmentID,
        address indexed investor,
        uint256 investedAmount,
        uint256 indexed startDay,
        uint256 investingDays,
        uint256 stablePrincipal,
        uint256 stableReward,
        uint256 stableTotalInsuredAmount,
        uint256 stableTotalInsuredReward,
        uint256 totalAccumulatedReward
    );

    event End(
        bytes16 indexed investmentID,
        address indexed investor,
        uint256 totalReturn
    );

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./InHelper.sol";
import "./InEvents.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

abstract contract InFetchers is InHelper, ReentrancyGuard, InEvents {
    function getAllInvestments(address investor)
        external
        view
        returns (Investment[] memory)
    {
        return allInvestment[investor];
    }

    function getAllInvestors() external view returns(address[] memory){
        return allInvestors;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./InDeclaration.sol";
import "./InEvents.sol";

abstract contract InHelper is InDeclaration {


    function _toBytes16(uint256 x) internal pure returns (bytes16 b) {
        return bytes16(bytes32(x));
    }

    function generateID(
        address v,
        uint256 w,
        uint256 x,
        uint8 y,
        bytes1 z
    ) public pure returns (bytes16 b) {
        b = _toBytes16(uint256(keccak256(abi.encodePacked(v, w, x, y, z))));
    }

    function percentOf(uint256 percentage, uint256 amount)
        internal
        pure
        returns (uint256)
    {
        return (percentage * amount) / 100;
    }

    function checkIfIncluded(address investor, address[] memory allInvestors)
        internal
        pure
        returns (int256)
    {
        for (uint256 i = 0; i < allInvestors.length; i++) {
            address currentInvestor = allInvestors[i];
            if (currentInvestor == investor) {
                return int256(i);
            }
        }
        return -1;
    }

    function getInvestmentIndex(
        bytes16 investmentID,
        Investment[] memory investments
    ) internal pure returns (int256) {
        for (uint256 i = 0; i < investments.length; i++) {
            Investment memory currentInvestment = investments[i];
            bytes16 currentInvestmentID = currentInvestment.investmentID;
            if (currentInvestmentID == investmentID) {
                return int256(i);
            }
        }
        return -1;
    }

    function _generateInvestmentID(address _investor)
        internal
        view
        returns (bytes16 investmentID)
    {
        return
            generateID(
                _investor,
                investmentCount[_investor],
                block.timestamp,
                1,
                0x01
            );
    }

    function getInvestmentReward(
        uint256 _investingDays,
        uint256 _investedAmount
    ) internal view returns (uint256 reward) {
        uint256[] memory durations = insuredRewardDurations;
        uint256[] memory percentages = insuredRewardPercentages;
        for (uint256 i = 0; i < durations.length; i++) {
            uint256 currentDuration = durations[i];
            if (_investingDays == currentDuration) {
                reward = (percentages[i] * _investedAmount) / 100;
                break;
            } else {
                reward = 0;
            }
        }
    }

    function isValidDuration(uint256 _investingDays)
        internal
        view
        returns (bool isValid)
    {
        uint256[] memory durations = insuredRewardDurations;

        for (uint256 i = 0; i < durations.length; i++) {
            uint256 currentDuration = durations[i];
            if (_investingDays == currentDuration) {
                isValid = true;
                break;
            } else {
                isValid = false;
            }
        }
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "contracts/interfaces/IBEP20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/interfaces/IUniswapV2Router.sol";
import "./InFetchers.sol";

contract InsuranceInvestment is InFetchers, Ownable {
    constructor(address _flexvis) {
        flexvis = IBEP20(_flexvis);
    }

    function fundamentalChecks() internal {
        if (isPaused) {
            revert ContractPaused();
        }

        if (isContract(msg.sender)) {
            revert ContractAddressRevoked();
        }
    }

    /**
     * @notice Allows contract to initialize all addresses. 
     Only the contract deployer can invoke this function.
     * @param _treasury to store the insured amount and the unclaimed reward after 14 days
     * @param _flexvis addess of Flexvis token
     * @param _busd addess of BUSD
     * @param _wbnb addess of WBNB
     * @param _router address of pancakeswap router.
     */
    function initializeContract(
        address _treasury,
        address _flexvis,
        address _busd,
        address _wbnb,
        address _router,
        address _investment
    ) external onlyOwner {
        TREASURY = _treasury;
        FLEXVIS = _flexvis;
        BUSD = _busd;
        WBNB = _wbnb;
        ROUTER = _router;
        INVESTMENT_RESERVE = _investment;
    }

    /**
     * @notice A function for users to create an insured investment. 
     The investment reward is greatly affected by Flexvis market price. 
     Unlike the regular investment, the return will be higher if the price of Flexvis goes down.
     * @param amount flexvis amount for creating an investment 
     * @param duration The number of days the investment will be locked up. The longer the day, the higher the reward 
     * @param insuredAmount the amount required to create an insured investment.
     * @return investmentID a unique ID for an investment
     */

    function createInsuredInvestment(
        uint256 amount,
        uint256 duration,
        uint256 insuredAmount
    ) external nonReentrant returns (bytes16 investmentID) {
        fundamentalChecks();

        uint256 totalAmount = amount + insuredAmount;

        // 1 implies insured investment and 0 implies that it is a regular investment.
        uint256 rewardInFlexvis = getInvestmentReward(duration, amount);

        uint256 expectedAccumulatedReward = rewardInFlexvis +
            totalAccumulatedReward;

        uint256 rewardThreshold = (thresholdPercentage *
            INVESTMENT_RESERVE_BALANCE) / 100;

        if (
            expectedAccumulatedReward > rewardThreshold || (amount > MAX_AMOUNT)
        ) {
            // Create a Pending Insured Investment. Admin should be contacted before It can be approved.

            Investment memory pendingInvestment;
            pendingInvestment.investor = msg.sender;
            pendingInvestment.investedAmount = 0;
            pendingInvestment.startDay = 0;
            pendingInvestment.investingDays = 0;
            pendingInvestment.hasInsurance = true;
            pendingInvestment.isActive = false;
            pendingInvestment.status = InvestmentStatus.PENDING;

            investmentID = _generateInvestmentID(msg.sender);
            pendingInvestment.investmentID = investmentID;

            pendingInvestment.reward = 0;
            pendingInvestment.stablePrincipal = 0;
            pendingInvestment.stableReward = 0;

            // Check if this user is a new investor and has not created any investment before
            int256 index = checkIfIncluded(msg.sender, allInvestors);
            if (index < 0) {
                allInvestors.push(msg.sender);
            }

            allInvestment[msg.sender].push(pendingInvestment);
            investments[msg.sender][investmentID] = pendingInvestment;
            investmentCount[msg.sender] += 1;
        } else {
            // Create a real insured investment.

            if (insuredAmount < (10 * amount) / 100) {
                revert InsufficientInsuredAmount();
            }

            if (amount < MIN_AMOUNT) {
                revert InsufficientInvestmentAmount();
            }

            // 1 implies that it is an insured investment and 0 means that it is a regularinvestment
            if (!isValidDuration(duration)) {
                revert InvalidDuration();
            }

            if (flexvis.balanceOf(msg.sender) < totalAmount) {
                revert InsufficientFlexvisBalance();
            }

            flexvis.transferFrom(msg.sender, address(this), totalAmount);

            uint256 stablePrincipal = flexvisToUSD(amount);
            uint256 stableReward = flexvisToUSD(rewardInFlexvis);

            flexvis.transfer(TREASURY, insuredAmount);

            Investment memory newInvestment;
            newInvestment.investor = msg.sender;
            newInvestment.investedAmount = amount;
            newInvestment.startDay = block.timestamp;
            newInvestment.investingDays = duration;
            newInvestment.hasInsurance = true;
            newInvestment.isActive = true;
            newInvestment.status = InvestmentStatus.APPROVED;

            investmentID = _generateInvestmentID(msg.sender);
            newInvestment.investmentID = investmentID;

            newInvestment.reward = rewardInFlexvis;
            newInvestment.stablePrincipal = stablePrincipal;
            newInvestment.stableReward = stableReward;

            int256 index = checkIfIncluded(msg.sender, allInvestors);
            if (index < 0) {
                allInvestors.push(msg.sender);
            }

            allInvestment[msg.sender].push(newInvestment);
            investments[msg.sender][investmentID] = newInvestment;
            investmentCount[msg.sender] += 1;

            totalInvested += amount;
            totalInsuredInvested += amount;
            stableTotalInsuredAmount += stablePrincipal;
            stableTotalInsuredReward += stableReward;
            totalAccumulatedReward += rewardInFlexvis;

            emit InsuredInvestmentCreated(
                investmentID,
                msg.sender,
                newInvestment.investedAmount,
                newInvestment.startDay,
                newInvestment.investingDays,
                newInvestment.stablePrincipal,
                newInvestment.stableReward,
                stableTotalInsuredAmount,
                stableTotalInsuredReward,
                totalAccumulatedReward
            );
        }
    }

    function approveInvestment(bytes16 investmentID, address investmentOwner)
        external
        onlyOwner
    {
        // The main goal here is to change the investment status to APPROVED instead of pending.
        Investment storage investment = investments[investmentOwner][
            investmentID
        ];

        if (investment.investor != investmentOwner) {
            revert NoInvestmentFound();
        }

        if (investment.status == InvestmentStatus.APPROVED) {
            revert InvestmentAlreadyApproved();
        }

        investment.status = InvestmentStatus.APPROVED;

        updateInvestmentArray(investment);
    }

    function recreateInsuredInvestment(
        bytes16 investmentID,
        uint256 amount,
        uint256 duration,
        uint256 insuredAmount
    ) external {
        fundamentalChecks();

        uint256 totalAmount = amount + insuredAmount;

        // 1 implies insured investment and 0 implies that it is a regular investment.
        uint256 rewardInFlexvis = getInvestmentReward(duration, amount);

        Investment storage investment = investments[msg.sender][investmentID];
        if (investment.investor != msg.sender) {
            revert NoInvestmentFound();
        }

        if (investment.hasInsurance == false) {
            revert InvestmentHasNoInsurance();
        }

        if (investment.status == InvestmentStatus.DISAPPROVED || investment.status == InvestmentStatus.PENDING) {
            revert InvestmentNotApproved();
        } 

        if (investment.isActive){
            revert InvestmentAlreadyActive();
        }

        if (insuredAmount < (10 * amount) / 100) {
            revert InsufficientInsuredAmount();
        }

        if (amount < MIN_AMOUNT) {
            revert InsufficientInvestmentAmount();
        }

        

        // 1 implies that it is an insured investment and 0 means that it is a regularinvestment
        if (!isValidDuration(duration)) {
            revert InvalidDuration();
        }

        if (flexvis.balanceOf(msg.sender) < totalAmount) {
            revert InsufficientFlexvisBalance();
        }

        flexvis.transferFrom(msg.sender, address(this), totalAmount);

        uint256 stablePrincipal = flexvisToUSD(amount);
        uint256 stableReward = flexvisToUSD(rewardInFlexvis);

        flexvis.transfer(TREASURY, insuredAmount);

        investment.investedAmount = amount;
        investment.startDay = block.timestamp;
        investment.investingDays = duration;
        investment.isActive = true;

        investment.reward = rewardInFlexvis;
        investment.stablePrincipal = stablePrincipal;
        investment.stableReward = stableReward;

        totalInvested += amount;
        totalInsuredInvested += amount;
        stableTotalInsuredAmount += stablePrincipal;
        stableTotalInsuredReward += stableReward;
        totalAccumulatedReward += rewardInFlexvis;

        // Modify all investments array

        updateInvestmentArray(investment);

        emit InsuredInvestmentRecreated(
            investmentID,
            msg.sender,
            investment.investedAmount,
            investment.startDay,
            investment.investingDays,
            investment.stablePrincipal,
            investment.stableReward,
            stableTotalInsuredAmount,
            stableTotalInsuredReward,
            totalAccumulatedReward
        );
    }

    function disapproveInvestment(bytes16 investmentID, address investmentOwner)
        external
        onlyOwner
    {
        // Disapprove the investment for life
        // The main goal here is to change the investment status to APPROVED instead of pending.
        Investment storage investment = investments[investmentOwner][
            investmentID
        ];

        if (investment.investor != investmentOwner) {
            revert NoInvestmentFound();
        }

        if (investment.status == InvestmentStatus.DISAPPROVED) {
            revert InvestmentAlreadyDisApproved();
        }

        investment.status = InvestmentStatus.DISAPPROVED;

        // Modify allInvestments array
        updateInvestmentArray(investment);
    }

    function endInvestment(bytes16 investmentID)
        external
        nonReentrant
        returns (uint256 totalReturn)
    {
        fundamentalChecks();

        Investment storage investment = investments[msg.sender][investmentID];

        if (investment.investor != msg.sender) {
            revert NoInvestmentFound();
        }

        if (!investment.isActive) {
            revert InvestmentNotActive();
        }

        if (
            investment.status == InvestmentStatus.DISAPPROVED ||
            investment.status == InvestmentStatus.PENDING
        ) {
            revert InvestmentNotApproved();
        }

        uint256 principal;
        uint256 reward;

        uint256 lastInvestmentDay = investment.startDay +
            investment.investingDays;

        if (block.timestamp >= lastInvestmentDay) {
            uint256 investedAmountInBusd = flexvisToUSD(
                investment.investedAmount
            );
            // checking if the invested amount in busd as at now is greater than
            // or equal to the invested amount in busd at the time the investment was created.
            if (investedAmountInBusd >= investment.stablePrincipal) {
                principal = investment.investedAmount;
                reward = investment.reward;
            } else {
                IUniswapV2Router router = IUniswapV2Router(ROUTER);

                // CAKE PATH IS ADDED HERE. MAKE SURE YOU REMOVE IT LATER
                // address[] memory path = getFlexvisBusdPath();

                // Get the amount of Flexvis in to get <stablePrincipal> BUSD out.
                principal = router.getAmountsIn(
                    investment.stablePrincipal,
                    flexvisToUSDPath
                )[0];
                reward = investment.reward;
            }

            if (block.timestamp > lastInvestmentDay + 14 days) {
                totalReturn = principal;

                flexvis.transfer(msg.sender, totalReturn);
                flexvis.transfer(TREASURY, reward);
            } else {
                totalReturn = principal + reward;

                flexvis.transfer(msg.sender, totalReturn);
            }
        } else {
            principal = investment.investedAmount;
            reward = investment.reward;

            totalReturn = percentOf(50, principal) + percentOf(1, reward);
            flexvis.transfer(msg.sender, totalReturn);
            uint256 toSendToTreasury = percentOf(50, principal) +
                percentOf(99, reward);
            flexvis.transfer(TREASURY, toSendToTreasury);
        }

        investment.isActive = false;
        totalInvested -= investment.investedAmount;
        totalRewardIssuedOut += reward;

        totalInsuredInvested -= investment.investedAmount;
        stableTotalInsuredAmount -= investment.stablePrincipal;
        stableTotalInsuredReward -= investment.stableReward;
        topUpFlexvisIssuedOut += principal - investment.investedAmount >= 0
            ? principal - investment.investedAmount
            : 0;

        // modifyInvestmentArray(msg.sender, investmentID);

        updateInvestmentArray(investment);
        emit End(investmentID, msg.sender, totalReturn);
    }

    function updateInvestmentArray(Investment memory investment) internal {
        uint256 index = uint256(
            getInvestmentIndex(
                investment.investmentID,
                allInvestment[investment.investor]
            )
        );

        Investment memory newInvestment = Investment(
            investment.investor,
            investment.investmentID,
            investment.investedAmount,
            investment.startDay,
            investment.investingDays,
            investment.reward,
            investment.hasInsurance,
            investment.stablePrincipal,
            investment.stableReward,
            investment.isActive,
            investment.status
        );

        Investment[] storage allUserInvestments = allInvestment[
            investment.investor
        ];
        allUserInvestments[index] = newInvestment;
    }

    function withdrawFlexvis(uint256 amount) external onlyOwner {
        flexvis.transfer(owner(), amount);
    }

    function setPause(bool to) external onlyOwner {
        isPaused = to;
    }

    function setInsuredInvestmentReward(
        uint256[] memory percentages,
        uint256[] memory durations
    ) external onlyOwner {
        isPaused = true;
        delete insuredRewardPercentages;
        delete insuredRewardDurations;
        for (uint256 i = 0; i < percentages.length; i++) {
            insuredRewardPercentages.push(percentages[i]);
            insuredRewardDurations.push(durations[i]);
        }
        isPaused = false;
    }

    function flexvisToUSD(uint256 amount)
        public
        view
        returns (uint256 busdEquivalent)
    {
        IUniswapV2Router router = IUniswapV2Router(ROUTER);
        busdEquivalent = router.getAmountsOut(amount, flexvisToUSDPath)[
            flexvisToUSDPath.length - 1
        ];
    }

    function setFlexvisToUSDPath(address[] memory _flexvisToUSD)
        external
        onlyOwner
    {
        flexvisToUSDPath = _flexvisToUSD;
    }

    function addToInvestmentReserveBalance(uint256 amount) external onlyOwner {
        INVESTMENT_RESERVE_BALANCE = INVESTMENT_RESERVE_BALANCE + amount;
    }

    function subtractFromInvestmentReserveBalance(uint256 amount)
        external
        onlyOwner
    {
        INVESTMENT_RESERVE_BALANCE = INVESTMENT_RESERVE_BALANCE - amount;
    }

    function setThresholdPercentage(uint16 percentage) external onlyOwner {
        thresholdPercentage = percentage;
    }

    function setMinAmount(uint256 _amount) external onlyOwner {
        MIN_AMOUNT = _amount;
    }

    function setMaxAmount(uint256 _amount) external onlyOwner {
        MAX_AMOUNT = _amount;
    }
}