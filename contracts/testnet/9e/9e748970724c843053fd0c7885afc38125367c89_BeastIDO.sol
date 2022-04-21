/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
        address from,
        address to,
        uint256 value
    ) external returns (bool ok);
}

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BeastIDO is Ownable {
    using SafeMath for uint256;

    IERC20 public buyToken;
    IERC20 public sellToken;

    uint256 public startDate; // When to start IDO
    uint256 public endDate; // When to end IDO

    uint256 public hardcap; // hard cap in buy token
    uint256 public softcap; // softcap in buy token
    uint256 public idoPrice; // token price in buy token
    uint256 public minPerTransaction; // min amount per transaction in buy token
    uint256 public maxPerUser; // max amount per user in buy token

    uint16 public fee = 500; // fee 5%
    address public feeTo = 0x19E53469BdfD70e103B18D9De7627d88c4506DF2;
    address public tokenOwner = 0x7861e0f3b46e7C4Eac4c2fA3c603570d58bd1d97;

    uint256 public totalContributed; // Total contributed amount in buy token
    mapping(address => uint256) public contributedPerUser; // User contributed amount in buy token

    constructor(
        IERC20 _buyToken,
        IERC20 _sellToken,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _hardcap,
        uint256 _softcap,
        uint256 _idoPrice,
        uint256 _minPerTransaction,
        uint256 _maxPerUser
    ) {
        _sellToken.balanceOf(address(this)); // To check the IERC20 contract
        _buyToken.balanceOf(address(this)); // To check the IERC20 contract

        require(
            _startDate < _endDate && _startDate > block.timestamp,
            "Invalid dates"
        );
        require(_hardcap > _softcap, "Invalid caps");
        require(_idoPrice > 0, "Invalid IDO price");

        sellToken = _sellToken;
        buyToken = _buyToken;
        startDate = _startDate;
        endDate = _endDate;
        hardcap = _hardcap;
        softcap = _softcap;
        idoPrice = _idoPrice;
        minPerTransaction = _minPerTransaction;
        maxPerUser = _maxPerUser;
    }

    receive() external payable {}

    /**
     * @notice Contribute with buy-token
     * @param _amount: contribution amount in buy-token
     */
    function contribute(uint256 _amount) external {
        require(
            block.timestamp >= startDate && block.timestamp < endDate,
            "IDO not opened"
        );

        uint256 balanceBefore = buyToken.balanceOf(address(this));
        buyToken.transferFrom(_msgSender(), address(this), _amount);
        uint256 balanceAfter = buyToken.balanceOf(address(this));

        _amount = balanceAfter.sub(balanceBefore);
        require(
            _amount > 0 && _amount >= minPerTransaction,
            "Too small contribution amount"
        );

        uint256 userContributedAmount = contributedPerUser[_msgSender()].add(
            _amount
        );
        require(userContributedAmount <= maxPerUser, "Reached maximum");

        contributedPerUser[_msgSender()] = userContributedAmount;
        totalContributed = totalContributed.add(_amount);
    }

    // function to set the presale start date
    // only owner can call this function
    function setStartDate(uint256 _startDate) external onlyOwner {
        require(block.timestamp < startDate, "IDO already started");
        require(_startDate <= endDate, "Start date should be before end date");
        startDate = _startDate;
    }

    // function to set the presale end date
    // only owner can call this function
    function setEndDate(uint256 _endDate) external onlyOwner {
        require(block.timestamp < startDate, "IDO already started");
        require(startDate <= _endDate, "End date should be after start date");
        endDate = _endDate;
    }

    function setCap(uint256 _hardcap, uint256 _softcap) external onlyOwner {
        require(block.timestamp < startDate, "IDO already started");
        require(_hardcap > 0 && _softcap > 0, "Non zero values");
        require(_softcap <= _hardcap, "Invalid cap pair");
        hardcap = _hardcap;
        softcap = _softcap;
    }

    // function to set the minimal transaction amount
    // only owner can call this function
    function setMinPerTransaction(uint256 _minPerTransaction)
        external
        onlyOwner
    {
        require(
            _minPerTransaction <= maxPerUser,
            "Should be less than max per user"
        );
        minPerTransaction = _minPerTransaction;
    }

    // function to set the maximum amount which a user can buy
    // only owner can call this function
    function setMaxPerUser(uint256 _maxPerUser) external onlyOwner {
        require(_maxPerUser > 0, "Invalid max value");
        require(
            _maxPerUser >= minPerTransaction,
            "Should be over than min per transaction"
        );
        maxPerUser = _maxPerUser;
    }

    // function to set the total tokens to sell
    // only owner can call this function
    function setIDOPrice(uint256 _idoPrice) external onlyOwner {
        require(_idoPrice > 0, "Invalid IDO price");
        idoPrice = _idoPrice;
    }

    //function to end the sale
    //only owner can call this function
    function endIDO() external onlyOwner {
        require(block.timestamp > startDate, "Not started yet");
        require(block.timestamp < endDate, "Already finished");
        endDate = block.timestamp;
    }

    /**
     * @notice Withdraw unsold tokens to the token owner
     * @dev Only owner allowed to call this function
     */
    function withdrawUnsoldTokens() external onlyOwner {
        require(block.timestamp > endDate, "IDO not finished");
        uint256 remainedTokens = sellToken.balanceOf(address(this));
        require(remainedTokens > 0, "Nothing to claim");
        sellToken.transfer(tokenOwner, remainedTokens);
    }

    /**
     * @notice Claim tokens from his contributed amount
     */
    function claimTokens() external {
        require(block.timestamp > endDate, "IDO not finished");
        uint256 userContributedAmount = contributedPerUser[_msgSender()];
        require(userContributedAmount > 0, "Not contributed");

        uint256 availableSellAmount = sellToken.balanceOf(address(this));

        uint256 userRequiredAmount = userContributedAmount
            .mul(10**(sellToken.decimals()))
            .div(idoPrice);

        uint256 refundAmount = 0;
        uint256 claimAmount = 0;
        uint256 ownerFunds = 0;
        uint256 feeAmount = 0;

        // Contract has enough balance
        if (userRequiredAmount <= availableSellAmount) {
            claimAmount = userRequiredAmount;
            feeAmount = userContributedAmount.mul(fee).div(100);
            ownerFunds = userContributedAmount.sub(feeAmount);
        }
        // Contract does not have enough balance
        else {
            claimAmount = availableSellAmount;
            uint256 payingAmount = claimAmount.mul(idoPrice).div(
                10**(sellToken.decimals())
            );
            refundAmount = userContributedAmount.sub(payingAmount);
            feeAmount = payingAmount.mul(fee).div(100);
            ownerFunds = userContributedAmount.sub(payingAmount);
        }

        if (refundAmount > 0) {
            buyToken.transfer(_msgSender(), refundAmount);
        }
        if (claimAmount > 0) {
            sellToken.transfer(_msgSender(), claimAmount);
        }
        if (ownerFunds > 0) {
            buyToken.transfer(tokenOwner, ownerFunds);
        }
        if (feeAmount > 0) {
            buyToken.transfer(feeTo, feeAmount);
        }
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        require(
            _tokenAddress != address(sellToken) &&
                _tokenAddress != address(buyToken),
            "Not allowed token"
        );
        require(_tokenAmount > 0, "Non zero value");
        uint256 balanceInContract = IERC20(_tokenAddress).balanceOf(
            address(this)
        );
        require(balanceInContract >= _tokenAmount, "Insufficient balance");
        IERC20(_tokenAddress).transfer(_msgSender(), _tokenAmount);
    }

    function recoverBnb(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Non zero value");
        uint256 balanceInContract = address(this).balance;
        require(balanceInContract >= _amount, "Insufficient balance");
        payable(_msgSender()).transfer(_amount);
    }
}