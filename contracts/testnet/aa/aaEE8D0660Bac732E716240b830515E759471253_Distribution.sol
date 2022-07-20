//SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Distribution is Ownable {

    IERC20 public tngToken;
    uint256 public constant DENOM = 100000; // For percentage precision upto 0.00x%

    // Token vesting 
    uint256[] public claimableTimestamp;
    mapping(uint256 => uint256) public claimablePercent;

    // Store the information of all users
    mapping(address => Account) public accounts;

    // For tracking
    uint256 public totalPendingVestingToken;    // Counter to track total required tokens
    uint256 public totalParticipants;           // Total presales participants

    event Register(address[] account, uint256[] tokenAllocation);
    event Deregister(address[] account);
    event Claim(address user, uint256 amount);
    event SetClaimable(uint256[] timestamp, uint256[] percent);

    struct Account {
        uint256 tokenAllocation;            // user's total token allocation 
        uint256 pendingTokenAllocation;     // user's pending token allocation
        uint256 claimIndex;                 // user's claimed at which index. 0 means never claim
        uint256 claimedTimestamp;           // user's last claimed timestamp. 0 means never claim
    }

	constructor(address _tngToken, uint256[] memory _claimableTimestamp, uint256[] memory _claimablePercent) {
        tngToken = IERC20(_tngToken);
        setClaimable(_claimableTimestamp, _claimablePercent);

        emit SetClaimable(_claimableTimestamp, _claimablePercent);
    }

    // Register token allocation info 
    // account : IDO address
    // tokenAllocation : IDO contribution amount in wei 
    function register(address[] memory account, uint256[] memory tokenAllocation) external onlyOwner {
        require(account.length > 0, "Account array input is empty");
        require(tokenAllocation.length > 0, "tokenAllocation array input is empty");
        require(tokenAllocation.length == account.length, "tokenAllocation length does not matched with account length");
        
        // Iterate through the inputs
        for(uint256 index = 0; index < account.length; index++) {
            // Save into account info
            Account storage userAccount = accounts[account[index]];

            // For tracking
            // Only add to the var if is a new entry
            // To update, deregister and re-register
            if(userAccount.tokenAllocation == 0) {
                totalParticipants++;

                userAccount.tokenAllocation = tokenAllocation[index];
                userAccount.pendingTokenAllocation = tokenAllocation[index];

                // For tracking purposes
                totalPendingVestingToken += tokenAllocation[index];
            }
        }

        emit Register(account, tokenAllocation);
    }

    function deRegister(address[] memory account) external onlyOwner {
        require(account.length > 0, "Account array input is empty");
        
        // Iterate through the inputs
        for(uint256 index = 0; index < account.length; index++) {
            // Save into account info
            Account storage userAccount = accounts[account[index]];

            if(userAccount.tokenAllocation > 0) {
                totalParticipants--;

                // For tracking purposes
                totalPendingVestingToken -= userAccount.pendingTokenAllocation;

                userAccount.tokenAllocation = 0;
                userAccount.pendingTokenAllocation = 0;
                userAccount.claimIndex = 0;
                userAccount.claimedTimestamp = 0;
            }
        }

        emit Deregister(account);
    }

    function claim() external {
        Account storage userAccount = accounts[_msgSender()];
        uint256 tokenAllocation = userAccount.tokenAllocation;
        require(tokenAllocation > 0, "Nothing to claim");

        uint256 claimIndex = userAccount.claimIndex;
        require(claimIndex < claimableTimestamp.length, "All tokens claimed");

        //Calculate user vesting distribution amount
        uint256 tokenQuantity = 0;
        for(uint256 index = claimIndex; index < claimableTimestamp.length; index++) {

            uint256 _claimTimestamp = claimableTimestamp[index];   
            if(block.timestamp >= _claimTimestamp) {
                claimIndex++;
                tokenQuantity = tokenQuantity + (tokenAllocation * claimablePercent[_claimTimestamp] / DENOM);
            } else {
                break;
            }
        }
        require(tokenQuantity > 0, "Nothing to claim now, please wait for next vesting");

        //Validate whether contract token balance is sufficient
        uint256 contractTokenBalance = tngToken.balanceOf(address(this));
        require(contractTokenBalance >= tokenQuantity, "Contract token quantity is not sufficient");

        //Update user details
        userAccount.claimedTimestamp = block.timestamp;
        userAccount.claimIndex = claimIndex;
        userAccount.pendingTokenAllocation = userAccount.pendingTokenAllocation - tokenQuantity;

        //For tracking
        totalPendingVestingToken -= tokenQuantity;

        //Release token
        bool status = tngToken.transfer(_msgSender(), tokenQuantity);
        require(status, "Failed to claim");

        emit Claim(_msgSender(), tokenQuantity);
    }

    // Calculate claimable tokens at current timestamp
    function getClaimableAmount(address account) external view returns(uint256) {
        Account storage userAccount = accounts[account];
        uint256 tokenAllocation = userAccount.tokenAllocation;
        uint256 claimIndex = userAccount.claimIndex;

        if(tokenAllocation == 0) return 0;
        if(claimableTimestamp.length == 0) return 0;
        if(block.timestamp < claimableTimestamp[0]) return 0;
        if(claimIndex >= claimableTimestamp.length) return 0;

        uint256 tokenQuantity = 0;
        for(uint256 index = claimIndex; index < claimableTimestamp.length; index++){

            uint256 _claimTimestamp = claimableTimestamp[index];
            if(block.timestamp >= _claimTimestamp){
                tokenQuantity = tokenQuantity + (tokenAllocation * claimablePercent[_claimTimestamp] / DENOM);
            } else {
                break;
            }
        }

        return tokenQuantity;
    }

    // Update claim percentage. Timestamp must match with _claimableTime
    function setClaimable(uint256[] memory timestamp, uint256[] memory percent) public onlyOwner {
        require(timestamp.length > 0, "Empty timestamp input");
        require(timestamp.length == percent.length, "Array size not matched");

        // set claim percentage
        for(uint256 index = 0; index < timestamp.length; index++){
            claimablePercent[timestamp[index]] = percent[index];
        }

        // set claim timestamp
        claimableTimestamp = timestamp;
    }

    function getClaimableTimestamp() external view returns (uint256[] memory){
        return claimableTimestamp;
    }

    function getClaimablePercent() external view returns (uint256[] memory){
        uint256[] memory _claimablePercent = new uint256[](claimableTimestamp.length);

        for(uint256 index = 0; index < claimableTimestamp.length; index++) {

            uint256 _claimTimestamp = claimableTimestamp[index];   
            _claimablePercent[index] = claimablePercent[_claimTimestamp];
        }

        return _claimablePercent;
    }

    function rescueToken(address _token, address _to, uint256 _amount) external onlyOwner {
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        require(_contractBalance >= _amount, "Insufficient tokens");
        IERC20(_token).transfer(_to, _amount);
    }

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