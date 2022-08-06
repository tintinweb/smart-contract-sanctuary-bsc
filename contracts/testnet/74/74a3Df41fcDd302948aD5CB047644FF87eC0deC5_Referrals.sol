// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";




contract Referrals is Ownable {


  address public prediction;  

  struct Referrer {
    uint8 percent;
    uint256 balance;
  }

  modifier onlyPrediction {
    require(msg.sender == prediction, "It's function only for prediction contract");
    _;
  }

  /// @notice mapping return referrer for referral
  mapping (address => address) public referrerForReferral;

  /// @notice storage info about referrer 
  mapping (address => Referrer) public referrerInfo;


  constructor() {
    prediction = msg.sender;
  }


  /// @notice return referrer address for referral
  /// @param referral address referral
  /// @return add referrer
  function getReferrer(address referral) external view returns(address) {
      return referrerForReferral[referral];
  }

  /// @notice return referrer info
  /// @param referrer address referrer
  /// @return referrer info
  function getReferrerInfo(address referrer) external view returns(Referrer memory) {
    return referrerInfo[referrer];
  }

  /// @notice create instance referrer
  /// @param referrer referrer address
  function createReferrer(address referrer) external onlyPrediction{
    referrerInfo[referrer].percent = 1;

    emit ReferrerCreated(referrer, 1);
  }

  /// @notice add reward for bets referrals to balance referrer
  /// @param _referrer referrer address
  /// @param _betReward reward for bets referrals 
  function addBalanceReferrer(address _referrer, uint256 _betReward) external onlyPrediction {
    require(referrerInfo[_referrer].percent != 0, "This not referrer" );
    referrerInfo[_referrer].balance += _betReward;

    emit ReferrerBalanceChanged(_referrer, referrerInfo[_referrer].balance);
  }        

  /// @notice add referral for referrer
  /// @param _referral referral address
  /// @param _referrer referrer address 
  function addReferrerForReferral(address _referral, address _referrer) external onlyPrediction {
    referrerForReferral[_referral] = _referrer;

    emit ReferralAdded(_referral, _referrer);
  }

  /// @notice claim reward per bets referrals
  /// @param referrer referrer address
  function claimRewardsForReferrals(address referrer) external onlyPrediction {
    
    emit ReferrerBalanceClaimed(referrer, referrerInfo[referrer].balance);
    
    referrerInfo[referrer].balance = 0;

    
  }

  /// @notice change percent for bet referrals
  /// @param referrer referrer address
  /// @param newPercent new percent for bet referrals 
  function createOrChangeReferrerPercent(address referrer, uint8 newPercent) public onlyOwner {
    referrerInfo[referrer].percent = newPercent;
    emit ReferrerPercentChanged(referrer, newPercent);
  }



  /// @notice For changing prediction address
  /// @param newPrediction a parameter new prediction contract
  function changePredictionAddress(address newPrediction) public onlyOwner {
    
    emit PredictionAddressChanged(prediction, newPrediction);
    prediction = newPrediction;
    
  }




/*------------------------------------------------------------------------------------------EVENTS-----------------------------------------------------------------------------------*/
  /// @notice event emit when referrer balance was changed
  /// @param referrer address referrer
  /// @param balanceReferrer referrer balance for referral bets
  event ReferrerBalanceChanged(address indexed referrer, uint256 balanceReferrer);
  
  /// @notice event emit when referrer was created
  /// @param referrer address referrer
  /// @param standardPercent standard percent in referral program for referrer
  event ReferrerCreated(address indexed referrer, uint8 standardPercent);

  /// @notice event emit when prediction address was changed
  /// @param oldPredictionAddress address for old prediction contract
  /// @param newPredictionAddress address for new prediction contract
  event PredictionAddressChanged(address indexed oldPredictionAddress, address indexed newPredictionAddress);

  /// @notice event emit when percent for referrer was changed
  /// @param referrer address referrer
  /// @param newPercent new percent in referral program for referrer
  event ReferrerPercentChanged(address indexed referrer, uint8 newPercent);

  /// @notice event emit when referrer claim reward for bets referraals
  /// @param referrer address referrer
  event ReferrerBalanceClaimed(address indexed referrer, uint256 balance);

  /// @notice event emit when referral add to referrers
  /// @param referral address referral
  /// @param referrer address referrer
  event ReferralAdded(address indexed referral, address indexed referrer);
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