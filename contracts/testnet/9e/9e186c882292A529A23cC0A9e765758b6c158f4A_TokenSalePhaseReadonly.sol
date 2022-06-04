// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
 * @title Token Sale Phase Contract
 * @author Michal Wojcik
 * @notice Handle state about project fundraising stage
 */
contract TokenSalePhase is Ownable {

    uint private _stageStartTimestamp; // When sale starts
    uint private _stageEndTimestamp; // When sale ends
    uint private _totalSaleTokensAmount; // Total supply of sale stage
    uint private _spentPerUserLimit; // Limit in ERC-20 price token

    uint private _tokensBoughtAmount; // For current sale stage state

    mapping(address => Investor) internal _investorsMapping;

    IERC20 private immutable _priceToken; // Price for 1 token
    uint private immutable _pricePerToken; // ERC-20 token for buy Project's one

    struct Investor {
        bool isWhitelisted;
        uint boughtTokensAmount;
    }

    event TokensBought(address indexed investor, uint tokensAmount);
    event UserWhitelisted(address indexed investor, bool isWhitelisted);
    event UsersWhitelisted(address[] investors);

    event StageStartTimeChanged(uint stageStartTimestamp);
    event StageEndTimestampChanged(uint stageEndTimestamp);
    event TotalSaleTokensAmountChanged(uint totalSaleTokensAmount);
    event SpentPerUserLimitChanged(uint spentPerUserLimit);

    /*
     * @param priceTokenAddress - address of ERC-20 interfaced token for fundraise stage
     * @param stageStartTimestamp - timestamp when sale stage start
     * @param stageEndTimestamp - timestamp when sale stage end
     * @param pricePerToken - how many ERC-20 fundraising tokens needs to be paid for project one (WEI)
     * @param totalSaleTokensAmount - how many tokens will be avaliable at this sale stage
     * @param spentPerUserLimit - how many ERC-20 fundraising tokens user can spend per account
     */
    constructor(address priceTokenAddress, uint stageStartTimestamp, uint stageEndTimestamp, uint pricePerToken, uint totalSaleTokensAmount, uint spentPerUserLimit) {
        _priceToken = IERC20(priceTokenAddress);
        _pricePerToken = pricePerToken;

        updateStageStartTimestamp(stageStartTimestamp);
        updateStageEndTimestamp(stageEndTimestamp);
        updateTotalSaleTokensAmount(totalSaleTokensAmount);
        updateSpentPerUserLimit(spentPerUserLimit);
    }

    /*
     * @notice Function to buy tokens for defined ERC-20 fundraising token
     * @param tokensAmount - amount of tokens to buy
     * @dev {TokensBought} will be emitted
     */
    function buyTokens(uint tokensAmount) external {
        require(tokensAmount > 0, "Invalid tokens amount");
        require(block.timestamp > _stageStartTimestamp, "Stage is not started");
        require(block.timestamp < _stageEndTimestamp, "Stage is already closed.");

        uint pricePerToken = _pricePerToken;
        Investor memory investor = _investorsMapping[msg.sender];
        require(investor.isWhitelisted, "Investor is not whitelisted");

        require(((investor.boughtTokensAmount + tokensAmount) * pricePerToken) <= _spentPerUserLimit, "Spent limit exceeded.");

        uint price = tokensAmount * pricePerToken;

        emit TokensBought(msg.sender, tokensAmount);

        require(_priceToken.transferFrom(msg.sender, owner(), price), "ERC20: Transfer failed");

        _investorsMapping[msg.sender].boughtTokensAmount += tokensAmount;
        _tokensBoughtAmount += tokensAmount;
    }

    /*
     * @notice Function for extend/reduce whitelist by one described wallet
     * @param investor - user wallet address
     * @param isWhitelisted - described if user need to be whitelisted or no
     * @dev {UserWhitelisted} will be emitted
     * @dev Warning! Only owner can call this function
     */
    function extendWhitelist(address investor, bool isWhitelisted) external onlyOwner() {
        emit UserWhitelisted(investor, isWhitelisted);
        _investorsMapping[investor].isWhitelisted = isWhitelisted;
    }

    /*
     * @notice Function extend whitelist by list of wallet addresses
     * @param investors - list of users wallet addresses
     * @dev {UsersWhitelisted} will be emitted
     * @dev Warning! Only owner can call this function
     */
    function extendWhitelistRange(address[] memory investors) external onlyOwner() {
        for(uint i = 0; i < investors.length; i++){
            _investorsMapping[investors[i]].isWhitelisted = true;
        }
        emit UsersWhitelisted(investors);
    }

    /*
     * @notice Function updates stage start time
     * @param stageStartTimestamp - new stage start time
     * @dev {StageStartTimeChanged} will be emitted
     * @dev Warning! Only owner can call this function
     */
    function updateStageStartTimestamp(uint stageStartTimestamp) public onlyOwner() {
        _stageStartTimestamp = stageStartTimestamp;
        emit StageStartTimeChanged(stageStartTimestamp);
    }

    /*
     * @notice Function updates stage end time
     * @param stageEndTimestamp - new stage end time
     * @dev {StageEndTimestampChanged} will be emitted
     * @dev Warning! Only owner can call this function
     */
    function updateStageEndTimestamp(uint stageEndTimestamp) public onlyOwner() {
        _stageEndTimestamp = stageEndTimestamp;
        emit StageEndTimestampChanged(stageEndTimestamp);
    }

    /*
     * @notice Function updates the total amount of tokens to buy at the current stage
     * @param totalSaleTokensAmount - new total stage tokens amount
     * @dev {TotalSaleTokensAmountChanged} will be emitted
     * @dev Warning! Only owner can call this function
     */
    function updateTotalSaleTokensAmount(uint totalSaleTokensAmount) public onlyOwner() {
        _totalSaleTokensAmount = totalSaleTokensAmount;
        emit TotalSaleTokensAmountChanged(totalSaleTokensAmount);
    }

    /*
     * @notice Function updates limitation of sale stage spend per user wallet
     * @param spentPerUserLimit - new limitation value
     * @dev {SpentPerUserLimitChanged} will be emitted
     * @dev Warning! Only owner can call this function
     */
    function updateSpentPerUserLimit(uint spentPerUserLimit) public onlyOwner() {
        _spentPerUserLimit = spentPerUserLimit;
        emit SpentPerUserLimitChanged(spentPerUserLimit);
    }

    // GETTERS

    /*
     * @notice Function returns current sale stage information for given user
     * @param investorAddress - address of sale stage investor
     * @returns stageStartTimestamp - timestamp of stage start time
     * @returns stageEndTimestamp - timestamp of stage end time
     * @returns spentPerUserLimit - limitation of sale stage spend per user wallet
     * @returns totalSaleTokensAmount - total amount of tokens to buy at current stage
     * @returns tokensBoughtAmount - total number of tokens bought by all investors in current stage
     * @returns isUserWhitelisted - information if given user is whitelisted on current sale stage
     * @returns usersBoughtTokensAmount - total number of tokens bought by given user in current stage
     * @returns pricePerToken - price in ERC-20 fundraising token to pay for each one project token
     */
    function getTokenSalePhaseInfo(address investorAddress) public view returns (
        uint stageStartTimestamp,
        uint stageEndTimestamp,
        uint spentPerUserLimit,
        uint totalSaleTokensAmount,
        uint tokensBoughtAmount,
        bool isUserWhitelisted,
        uint usersBoughtTokensAmount,
        uint pricePerToken,
        address priceTokenAddress
    ) {
        stageStartTimestamp = _stageStartTimestamp;
        stageEndTimestamp = _stageEndTimestamp;
        spentPerUserLimit = _spentPerUserLimit;
        totalSaleTokensAmount = _totalSaleTokensAmount;
        tokensBoughtAmount = _tokensBoughtAmount;
        Investor memory investor = _investorsMapping[investorAddress];
        isUserWhitelisted = investor.isWhitelisted;
        usersBoughtTokensAmount = investor.boughtTokensAmount;
        pricePerToken = _pricePerToken;
        priceTokenAddress = address(_priceToken);
    }

     /*
     * @notice Function returns current sale stage information for caller's wallet address
     * @returns stageStartTimestamp - timestamp of stage start time
     * @returns stageEndTimestamp - timestamp of stage end time
     * @returns spentPerUserLimit - limitation of sale stage spend per user wallet
     * @returns totalSaleTokensAmount - total amount of tokens to buy at current stage
     * @returns tokensBoughtAmount - total number of tokens bought by all investors in current stage
     * @returns isUserWhitelisted - information if given user is whitelisted on current sale stage
     * @returns usersBoughtTokensAmount - total number of tokens bought by given user in current stage
     * @returns pricePerToken - price in ERC-20 fundraising token to pay for each one project token
     */
    function getTokenSalePhaseInfo() external view returns(
        uint stageStartTimestamp,
        uint stageEndTimestamp,
        uint spentPerUserLimit,
        uint totalSaleTokensAmount,
        uint tokensBoughtAmount,
        bool isUserWhitelisted,
        uint usersBoughtTokensAmount,
        uint pricePerToken,
        address priceTokenAddress
    ) {
         return getTokenSalePhaseInfo(msg.sender);
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./TokenSalePhase.sol";

/*
 * @title Token Sale Phase Readonly Contract
 * @author Michal Wojcik
 * @notice Contract for handling state of off-chain sale stages
 */
contract TokenSalePhaseReadonly is TokenSalePhase {

    event ResultsUploaded();

    /*
     * @param priceTokenAddress - address of ERC-20 interfaced token for fundraise stage
     * @param stageStartTimestamp - timestamp when sale stage start
     * @param stageEndTimestamp - timestamp when sale stage end
     * @param pricePerToken - how many ERC-20 fundraising tokens needs to be paid for project one (WEI)
     * @param totalSaleTokensAmount - how many tokens will be avaliable at this sale stage
     * @param spentPerUserLimit - how many ERC-20 fundraising tokens user can spend per account
     */
    constructor(address priceTokenAddress,uint stageStartTimestamp, uint stageEndTimestamp,uint pricePerToken, uint totalSaleTokensAmount, uint spentPerUserLimit)
         TokenSalePhase(priceTokenAddress,stageStartTimestamp, stageEndTimestamp, pricePerToken,totalSaleTokensAmount,spentPerUserLimit  ) {
    }

    /*
     * @notice Function for uploading sale stage data
     * @param investors - list of addresses contributing in current stage
     * @param boughtTokens - list of amount of tokens bought by given addresses
     * @dev {ResultsUploaded} will be emitted
     * @dev Warning! Only owner can call this function
     */
    function uploadResults(address[] calldata investors, uint[] calldata boughtTokens) external onlyOwner() {
        require(investors.length == boughtTokens.length, "Incorrect results to upload");

        for(uint i = 0; i < investors.length; i++) {
            _investorsMapping[investors[i]] = Investor(true, boughtTokens[i]);
        }

        emit ResultsUploaded();
    }
}