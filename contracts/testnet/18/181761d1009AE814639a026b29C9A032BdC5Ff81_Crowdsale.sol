// SPDX-License-Identifer: MIT License

// ************************************************************************************ //
// ***   P A N D A   S I E G E                                                      *** //
// ***                                                                              *** //
// ***   Author: Devon Nathan                                                       *** //
// ***   Description: Presale  Contract for Panda Siege                             *** //
// ***   Usage: This contract is for the presale,                                   *** //
// ***          Investor will deposit BNB, and in return                            *** //
// ***          PST will be claimed                                                 *** //
// ***   Parameters: _token           // the token address of PST                   *** //
// ***               _totalMonths     // the count of months for vesting            *** //
// ***               _sale            // what 1 BNB is equivalent to PST            *** //
// ***                                                                              *** //
// ************************************************************************************ //

pragma solidity ^0.8.0;

import  "@openzeppelin/contracts/access/Ownable.sol";
import  "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Crowdsale is Ownable {

    uint256 public PSTAvailable;
    uint256 public minInvestment = 10**17;
    uint256 public maxInvestment = 10**19;
    uint256 public rate; 
    uint256 public totalMonths;
    uint256 public payoutCounter;
    uint256 public startDate;
    bool public refund;
    uint256 public oneMonth = (30 * 24 * 60 * 60);
    bool internal locked;


    IERC20 public token; // PST address

    // Investor variables
    struct Investor {
        address payable _address;
        uint256 BNBAmount;
        uint256 TotalPSTBought;
        uint256 monthlyPayout;
        uint256 payoutCounter; // Update this after every withdraw
        bool exists;
    }

    address[] public investorAddresses; // Array of investor addresses
    mapping(address => Investor) public addressToInvestors; // Mapping of array to structs


    constructor(IERC20 _token, uint256 _totalMonths, uint256 _rate) {
        token = _token;
        totalMonths = _totalMonths;
        rate = _rate;
        startDate = block.timestamp;
        refund = false;
    }

    
    modifier noReentrant() {
        require(!locked, 'No reentrancy');
        locked = true;
        _;
        locked = false;
    }
    

    function setRate(uint256 _rate) external onlyOwner { rate = _rate; }
    function setRefund() external onlyOwner { refund = !refund; }
    function setStartDate(uint256 _startDate) external onlyOwner { startDate = _startDate; }

    function setInvestmentLimits(uint256 _min, uint256 _max) external onlyOwner { // Function to set the max and min investments
        minInvestment = _min;
        maxInvestment = _max; 
    }

    function updatePST() public onlyOwner {
        require(PSTAvailable == 0);
        PSTAvailable = token.balanceOf(address(this));
    }

    function invest() payable public { // Function for investors to put in money

        payoutCounter = getCurrentMonth();

        require(msg.value <= PSTAvailable, "There is not enough PST left. Please transfer less"); // Require enough to compensate the individual
        require(payoutCounter < totalMonths, 'Crowdsale is over for this period.');
        uint256 investment = addressToInvestors[msg.sender].BNBAmount + msg.value;
        require(investment >= minInvestment, "Amount must be higher than the minimum transaction"); // Require investment to be above/below certain threshold
        require(investment <= maxInvestment, "Maximum investment is 10 BNB per person.");
        uint256 PSTBought = msg.value * rate;


        uint256 monthlyPayout = PSTBought / (totalMonths - payoutCounter);
        PSTAvailable -= PSTBought;


        // Add/Update Investor 
        if(addressToInvestors[msg.sender].exists == true){ // Update struct if exists
            addressToInvestors[msg.sender].BNBAmount += msg.value;
            addressToInvestors[msg.sender].TotalPSTBought += PSTBought;
            addressToInvestors[msg.sender].monthlyPayout += monthlyPayout;
        } else { // Add new investor if struct doesn't exist
            Investor memory investor = Investor(payable(msg.sender), msg.value, PSTBought, monthlyPayout, payoutCounter, true);
            investorAddresses.push(payable(msg.sender));
            addressToInvestors[msg.sender] = investor;
        }        
    }


    function userWithdraw() public noReentrant {

        payoutCounter = getCurrentMonth();

        require(addressToInvestors[msg.sender].TotalPSTBought > 0, 'You do not have any PST bought.');
        require(addressToInvestors[msg.sender].payoutCounter < payoutCounter, 'You cannot withdraw yet. Please wait another month.');
        
        uint256 PSTPayoutAvailable = addressToInvestors[msg.sender].monthlyPayout * (payoutCounter - addressToInvestors[msg.sender].payoutCounter);
        addressToInvestors[msg.sender].TotalPSTBought -= PSTPayoutAvailable;
        addressToInvestors[msg.sender].payoutCounter = payoutCounter;
        token.approve(msg.sender, PSTPayoutAvailable);
        token.transfer(msg.sender, PSTPayoutAvailable);
    }

    function getCurrentMonth() public view returns(uint256) {
        uint256 count = (block.timestamp - startDate) / oneMonth;
        if (count > totalMonths) {
            count = totalMonths;
        }
        return count;
    }


    function withdrawBNB() external onlyOwner {
        address payable owner = payable(owner()); 
        owner.transfer(address(this).balance); 
    }

    function refundBNB() external {
        require(refund, "Nothing to Refund");
        address payable user = payable(msg.sender); 
        uint256 amount = addressToInvestors[msg.sender].BNBAmount;
        addressToInvestors[msg.sender].BNBAmount = 0;
        user.transfer(amount); 
    }

    function withdrawPST() external onlyOwner {
        uint256 amount = PSTAvailable;
        PSTAvailable = 0;

        address payable owner = payable(owner()); 
        token.approve(owner, amount);
        token.transfer(owner, amount);
    }
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}