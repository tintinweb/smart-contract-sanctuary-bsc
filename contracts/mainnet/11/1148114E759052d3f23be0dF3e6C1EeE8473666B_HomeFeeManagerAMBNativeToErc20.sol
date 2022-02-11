/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

// File: contracts/upgradeable_contracts/Sacrifice.sol

pragma solidity 0.4.24;

contract Sacrifice {
    constructor(address _recipient) public payable {
        selfdestruct(_recipient);
    }
}

// File: contracts/libraries/Address.sol

pragma solidity 0.4.24;


/**
 * @title Address
 * @dev Helper methods for Address type.
 */
library Address {
    /**
    * @dev Try to send native tokens to the address. If it fails, it will force the transfer by creating a selfdestruct contract
    * @param _receiver address that will receive the native tokens
    * @param _value the amount of native tokens to send
    */
    function safeSendValue(address _receiver, uint256 _value) internal {
        if (!_receiver.send(_value)) {
            (new Sacrifice).value(_value)(_receiver);
        }
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: contracts/upgradeable_contracts/BaseMediatorFeeManager.sol

pragma solidity 0.4.24;



/**
* @title BaseMediatorFeeManager
* @dev Base fee manager to handle fees for AMB mediators.
*/
contract BaseMediatorFeeManager is Ownable {
    using SafeMath for uint256;

    event FeeUpdated(uint256 fee);

    // This is not a real fee value but a relative value used to calculate the fee percentage.
    // 1 ether = 100% of the value.
    uint256 internal constant MAX_FEE = 1 ether;
    uint256 internal constant MAX_REWARD_ACCOUNTS = 50;

    uint256 public fee;
    address[] internal rewardAccounts;
    address internal mediatorContract;

    modifier validFee(uint256 _fee) {
        require(_fee < MAX_FEE);
        /* solcov ignore next */
        _;
    }

    /**
    * @dev Stores the initial parameters of the fee manager.
    * @param _owner address of the owner of the fee manager contract.
    * @param _fee the fee percentage amount.
    * @param _rewardAccountList list of addresses that will receive the fee rewards.
    */
    constructor(address _owner, uint256 _fee, address[] _rewardAccountList, address _mediatorContract) public {
        require(_rewardAccountList.length > 0 && _rewardAccountList.length <= MAX_REWARD_ACCOUNTS);
        _transferOwnership(_owner);
        _setFee(_fee);
        mediatorContract = _mediatorContract;

        for (uint256 i = 0; i < _rewardAccountList.length; i++) {
            require(isValidAccount(_rewardAccountList[i]));
        }
        rewardAccounts = _rewardAccountList;
    }

    /**
    * @dev Calculates the fee amount to be subtracted from the value.
    * @param _value the base value from which fees are calculated
    */
    function calculateFee(uint256 _value) external view returns (uint256) {
        return _value.mul(fee).div(MAX_FEE);
    }

    /**
    * @dev Stores the fee percentage amount for the mediator operations.
    * @param _fee the fee percentage
    */
    function _setFee(uint256 _fee) internal validFee(_fee) {
        fee = _fee;
        emit FeeUpdated(_fee);
    }

    /**
    * @dev Sets the fee percentage amount for the mediator operations. Only the owner can call this method.
    * @param _fee the fee percentage
    */
    function setFee(uint256 _fee) external onlyOwner {
        _setFee(_fee);
    }

    function isValidAccount(address _account) internal returns (bool) {
        return _account != address(0) && _account != mediatorContract;
    }

    /**
    * @dev Adds a new account to the list of accounts to receive rewards for the operations.
    * Only the owner can call this method.
    * @param _account new reward account
    */
    function addRewardAccount(address _account) external onlyOwner {
        require(isValidAccount(_account));
        require(!isRewardAccount(_account));
        require(rewardAccounts.length.add(1) < MAX_REWARD_ACCOUNTS);
        rewardAccounts.push(_account);
    }

    /**
    * @dev Removes an account from the list of accounts to receive rewards for the operations.
    * Only the owner can call this method.
    * finds the element, swaps it with the last element, and then deletes it;
    * @param _account to be removed
    * return boolean whether the element was found and deleted
    */
    function removeRewardAccount(address _account) external onlyOwner returns (bool) {
        uint256 numOfAccounts = rewardAccountsCount();
        for (uint256 i = 0; i < numOfAccounts; i++) {
            if (rewardAccounts[i] == _account) {
                rewardAccounts[i] = rewardAccounts[numOfAccounts - 1];
                delete rewardAccounts[numOfAccounts - 1];
                rewardAccounts.length--;
                return true;
            }
        }
        // If account is not found and removed, the transactions is reverted
        revert();
    }

    /**
    * @dev Tells the amount of accounts in the list of reward accounts.
    * @return amount of accounts.
    */
    function rewardAccountsCount() public view returns (uint256) {
        return rewardAccounts.length;
    }

    /**
    * @dev Tells if the account is part of the list of reward accounts.
    * @param _account to check if is part of the list.
    * @return true if the account is in the list
    */
    function isRewardAccount(address _account) internal view returns (bool) {
        for (uint256 i = 0; i < rewardAccountsCount(); i++) {
            if (rewardAccounts[i] == _account) {
                return true;
            }
        }
        return false;
    }

    /**
    * @dev Tells the list of accounts that receives rewards for the operations.
    * @return the list of reward accounts
    */
    function rewardAccountsList() public view returns (address[]) {
        return rewardAccounts;
    }

    /**
    * @dev ERC677 transfer callback function, received fee is distributed.
    * @param _value amount of transferred tokens
    */
    function onTokenTransfer(address, uint256 _value, bytes) external returns (bool) {
        distributeFee(_value);
        return true;
    }

    /**
    * @dev Distributes the provided amount of fees proportionally to the list of reward accounts.
    * In case the fees cannot be equally distributed, the remaining difference will be distributed to an account
    * in a semi-random way.
    * @param _fee total amount to be distributed to the list of reward accounts.
    */
    function distributeFee(uint256 _fee) internal {
        uint256 numOfAccounts = rewardAccountsCount();
        uint256 feePerAccount = _fee.div(numOfAccounts);
        uint256 randomAccountIndex;
        uint256 diff = _fee.sub(feePerAccount.mul(numOfAccounts));
        if (diff > 0) {
            randomAccountIndex = random(numOfAccounts);
        }

        for (uint256 i = 0; i < numOfAccounts; i++) {
            uint256 feeToDistribute = feePerAccount;
            if (diff > 0 && randomAccountIndex == i) {
                feeToDistribute = feeToDistribute.add(diff);
            }
            onFeeDistribution(rewardAccounts[i], feeToDistribute);
        }
    }

    /**
    * @dev Calculates a random number based on the block number.
    * @param _count the max value for the random number.
    * @return a number between 0 and _count.
    */
    function random(uint256 _count) internal view returns (uint256) {
        return uint256(blockhash(block.number.sub(1))) % _count;
    }

    /* solcov ignore next */
    function onFeeDistribution(address _rewardAddress, uint256 _fee) internal;
}

// File: contracts/upgradeable_contracts/amb_native_to_erc20/HomeFeeManagerAMBNativeToErc20.sol

pragma solidity 0.4.24;



/**
* @title HomeFeeManagerAMBNativeToErc20
* @dev Implements the logic to distribute fees from the native to erc20 mediator contract operations.
* The fees are distributed in the form of native tokens to the list of reward accounts.
*/
contract HomeFeeManagerAMBNativeToErc20 is BaseMediatorFeeManager {
    /**
    * @dev Stores the initial parameters of the fee manager.
    * @param _owner address of the owner of the fee manager contract.
    * @param _fee the fee percentage amount.
    * @param _rewardAccountList list of addresses that will receive the fee rewards.
    */
    constructor(address _owner, uint256 _fee, address[] _rewardAccountList, address _mediatorContract)
        public
        BaseMediatorFeeManager(_owner, _fee, _rewardAccountList, _mediatorContract)
    {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
    * @dev Fallback method to receive the fees.
    */
    function() public payable {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
    * @dev Transfer the fee as native tokens to the reward account.
    * @param _rewardAddress address that will receive the native tokens.
    * @param _fee amount of native tokens to be distribute.
    */
    function onFeeDistribution(address _rewardAddress, uint256 _fee) internal {
        Address.safeSendValue(_rewardAddress, _fee);
    }
}