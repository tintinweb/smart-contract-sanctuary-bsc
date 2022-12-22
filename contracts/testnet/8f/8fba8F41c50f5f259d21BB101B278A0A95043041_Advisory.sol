//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

// Import Ownable from the OpenZeppelin Contracts library
import "@openzeppelin/contracts/access/Ownable.sol";

interface IBEP20 {
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

contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

contract Advisory is Ownable, Initializable {
    event DistributionWalletInfo( 
        address indexed account, 
        uint amount, 
        uint time
    );

    event Claim( 
        address indexed claimer, 
        uint amount
    );

    event SetClaimPeriod( 
        uint claimPeriod
    );

    event SetSubClaimPerMonth( 
        uint subsequentClaim
    );

    event RevokeDistributionWallet( 
        address indexed account, 
        uint amount, 
        uint time
    );

    event Failcase( 
        address indexed tokenAdd, 
        uint amount, 
        uint time
    );

    mapping(address => userStruct) public user;

    struct userStruct {
        uint balance;
        uint totalClaimed;
        uint initiated;
        uint lastClaim;
    }

    IBEP20 public token;
    uint public subsequentClaim;

    uint public claimPeriod;
    uint[2] public total; //0- total allocated, 1- total claimed

    receive() external payable {
        revert("No receive calls");
    }

    function initialize(address tokenAdd, uint allocation, uint subsequentClaims, uint _claimPeriod) external initializer {
        require(tokenAdd != address(0), "BEP20: tokenAddress is zero address");
        require(_claimPeriod > 0, "Advisory : claimPeriod > 0");
        require(subsequentClaims > 0,"Advisory : subsequentClaims > 0");

        token = IBEP20(tokenAdd);
        claimPeriod = _claimPeriod;
        subsequentClaim = subsequentClaims;
        require(IBEP20(token).transferFrom(msg.sender, address(this), allocation), "Advisory : TranferFrom failure");
    }

    function setClaimPeriod( uint subSequentPeriod) external onlyOwner {
        claimPeriod = (subSequentPeriod != 0) ? subSequentPeriod : claimPeriod;
        emit SetClaimPeriod( claimPeriod );
    }

    function setSubClaimPerMonth( uint subClaim) external onlyOwner {
        subsequentClaim = subClaim;
        emit SetSubClaimPerMonth( subsequentClaim );
    }

    function addDistributionWallet( address[] memory account, uint[] memory amount, uint[] memory startTime) external onlyOwner {
        require(account.length < 30,"Advisory : length < 30");
        require((account.length == amount.length) && (startTime.length == amount.length),"Advisory : length mismatch");
        uint currentTime = block.timestamp;

        for(uint i=0; i< account.length; i++) {
            require((total[0] + amount[i]) <= token.balanceOf(address(this)), "Advisory : insufficient balance to allocate");
            require(startTime[i] > currentTime, "start time should be > current time");

            userStruct storage userStorage = user[account[i]];
            userStorage.balance += amount[i];
            total[0] += amount[i];
            
            if(userStorage.initiated == 0) {
                userStorage.initiated = startTime[i];
                userStorage.lastClaim = startTime[i];
            }
            
            emit DistributionWalletInfo( 
                account[i], 
                amount[i], 
                block.timestamp
            );
        }
    }

    function revokeDistributionWallet(address[] memory account) external onlyOwner {
        require(account.length < 30,"Advisory : length < 30");

        for(uint i=0; i< account.length; i++) {  
            userStruct memory user_ = user[account[i]];   
            require(user_.totalClaimed < user_.balance, "Advisory : user claimed all funds or user may not be added");
            uint amountToRevoke = user_.balance - user_.totalClaimed;
            delete user[account[i]];
            total[0] -= amountToRevoke;
            if(amountToRevoke > 0) {
                require(token.balanceOf(address(this)) >= amountToRevoke, "Advisory : insufficient balance to revoke");
                require(token.transfer(owner(),amountToRevoke),"Advisory : revoke transfer failed");
                emit RevokeDistributionWallet( 
                    account[i], 
                    amountToRevoke, 
                    block.timestamp
                );
            }
        }
    }

    function claim() external {
        userStruct storage user_ = user[msg.sender];
        require(user_.balance > 0, "Advisory : user not exist");
        require(user_.totalClaimed < user_.balance, "Advisory : total claim < total balance");
        require((user_.lastClaim > 0) && ((user_.lastClaim + claimPeriod) <= block.timestamp), "Advisory : lastClaim < block.timestamp");
        
        uint totDays;
        uint lastClaimTimestamp = user_.lastClaim;
        uint claimAmount;

        totDays = (block.timestamp - lastClaimTimestamp) / claimPeriod;
        user_.lastClaim += claimPeriod * totDays;
        
        claimAmount = (user_.balance * (subsequentClaim * totDays)) / 100e18;
        uint subClaimAmount = (user_.balance * subsequentClaim) / 100e18;

        if((user_.totalClaimed + claimAmount + subClaimAmount) > user_.balance) {
            claimAmount = user_.balance - user_.totalClaimed; 
        }

        user_.totalClaimed += claimAmount;
        total[1] += claimAmount;
        require(token.transfer(msg.sender, claimAmount), "Advisory : Tranfer failure");
        emit Claim(
            msg.sender,
            claimAmount
        );
    }

    function rewardInfo( address account) external view returns (uint reward){
        userStruct memory user_ = user[account];

        if((user_.totalClaimed > user_.balance) || (user_.balance == 0) || ((user_.lastClaim + claimPeriod) > block.timestamp)) {
            return 0;
        }
        
        uint totDays;
        uint lastClaimTimestamp = user_.lastClaim;
        uint claimAmount;

        totDays = (block.timestamp - lastClaimTimestamp) / claimPeriod;
        
        claimAmount = (user_.balance * (subsequentClaim * totDays)) / 100e18;
        uint subClaimAmount = (user_.balance * subsequentClaim) / 100e18;

        if((user_.totalClaimed + claimAmount + subClaimAmount) > user_.balance) {
            claimAmount = user_.balance - user_.totalClaimed; 
        }

        return claimAmount;
    }

    function failcase( address tokenAdd, uint amount) external onlyOwner{
        require(tokenAdd != address(0), "BEP20: tokenAddress is zero address");
        address self = address(this);
        // if(tokenAdd == address(0)) {
        //     require(self.balance >= amount, "Advisory : insufficient balance");
        //     require(payable(owner()).send(amount), "Advisory : transfer failed");
        // } else {
            require(IBEP20(tokenAdd).balanceOf(self) >= amount, "Advisory : insufficient balance");
            if(tokenAdd == address(token)){
                if(total[0] > total[1]) {
                    uint unClaimed = total[0] - total[1];
                    if(IBEP20(tokenAdd).balanceOf(self) > unClaimed) {
                        uint claimable = IBEP20(tokenAdd).balanceOf(self) - unClaimed;
                        if(amount > claimable) {
                            amount = 0;
                        }
                    } else {
                        amount = 0;
                    }
                }
                   require(amount > 0, "no available tokens to claim");
            }
            require(IBEP20(tokenAdd).transfer(owner(),amount), "Advisory : transfer failed");

            emit Failcase( 
                tokenAdd, 
                amount, 
                block.timestamp
            );
       // }
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