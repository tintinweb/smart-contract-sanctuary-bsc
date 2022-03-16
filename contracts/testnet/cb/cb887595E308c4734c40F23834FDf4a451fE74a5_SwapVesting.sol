/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// File: contracts/interfaces/IBEP20.sol



pragma solidity ^0.8.0;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// File: contracts/interfaces/IDerobo.sol


pragma solidity ^0.8.0;

/// @title Derobo
/// @author FormalCrypto


// Vesting smart contract interface.
interface IVesting {
    function addTokens(address _user, uint256 _value) external returns (bool);
}

/// @notice Upgraded BEP20 token with a whitelisted swap performed by a dedicated user.
interface IDerobo is IBEP20 {

    /*///////////////////////////////////////////////////////////////
                    OWNER'S FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Adds an address that is allowed to use the swap function.
     * @param _swapper The address of the new swapper.
     */
    function setSwapper(address _swapper) external;

    /**
     * @dev Adds addresses that are allowed to swap ROBO tokens.
     * @param _addresses An array of addresses.
     */
    function addToWhiteList(address[] calldata _addresses) external;

    /**
     * @dev Removes addresses that are allowed to swap ROBO tokens.
     * @param _addresses An array of addresses.
     */
    function removeFromWhiteList(address[] calldata _addresses) external;

    /**
     * @dev Adds an address of the vesting smart contract.
     * @param _swapVesting The address of the vesting smart contract.
     */
    function setSwapVesting(IVesting _swapVesting) external;

    /*///////////////////////////////////////////////////////////////
                    PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Mints new tokens to the vesting smart contract as an exchange of ERC20 ROBO tokens on Ethereum for BEP20 DEROBO tokens on BSC.
     * @param _account The address of the receiver.
     * @param _amount The amount of tokens to mint.
     */
    function swap(address _account, uint256 _amount) external;

    /**
     * @dev See BEP20 _burn.
     * @param _amount The amount of tokens to be burned.
     */
    function burn(uint256 _amount) external;

    /**
     * @dev see BEP20 _burnFrom.
     * @param _account The address to burn from.
     * @param _amount The amount of tokens to be burned.
     */
    function burnFrom(address _account, uint256 _amount) external;
}
// File: contracts/SwapVesting.sol


pragma solidity ^0.8.0;

/// @title VestingForRoboSwap
/// @author FormalCrypto


/**
 * @title SafeCall
 * @dev Wrappers around IDerobo operations that throw on failure.
 */
library SafeCall {
    function safeTransfer(IDerobo token, address to, uint256 value) internal {
        require(token.transfer(to, value), "SafeCall: transfer failed");
    }

    function safeTransferFrom(
        IDerobo token,
        address from,
        address to,
        uint256 value
    )
    internal
    {
        require(token.transferFrom(from, to, value), "SafeCall: transferFrom failed");
    }
}

/// @notice Smart contract for vesting the DEROBO tokens that are received in exchange for ROBO tokens in Ethereum.
contract SwapVesting {
    
    /*///////////////////////////////////////////////////////////////
                    Global STATE
    //////////////////////////////////////////////////////////////*/

    using SafeCall for IDerobo;

    IDerobo public token;

    struct User {
        uint256 deposit;
        uint256 balance;
        uint256 releaseTime;
        uint256 step;
    }
    
    // One step period.
    uint256 public constant RELEASE_STEP = 30 days;

    // The number of all steps.
    uint256 public numberOfSteps;

    // The percentage of funds available at a particular step.
    uint256 public stepPercent;

    // Time to unlock.
    uint256 public untilReleased;
    
    mapping(address => User) private users;

    constructor(IDerobo _token, uint256 _untilReleased, uint256 _steps) {
        token = _token;
        numberOfSteps = _steps;
        untilReleased = _untilReleased * 1 days;

        // Count in 0.001% for better accuracy.
        stepPercent = 100000 / numberOfSteps;
    }

    /*///////////////////////////////////////////////////////////////
                    EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Adds a new deposit.
     * @notice Called only by the token contract.
     * @param _user The user's address.
     * @param _value The amount of tokens.
     */
    function addTokens(address _user, uint256 _value) external returns (bool) {//видна пользователям
        require(_value > 0, "The number must be greater than zero");
        require(msg.sender == address(token), "The function should only be called by the contract of the token");
        token.safeTransferFrom(address(token), address(this), _value);
        users[_user].deposit += _value; //обновлять или прибавлять?
        users[_user].balance += _value;
        users[_user].step = 0;//если будет повторно добавлен
        users[_user].releaseTime = block.timestamp + untilReleased;
    }

    /**
     * @dev Sends the user all of their currently unlocked tokens, if there are any.
     */
    function getTokens() external {
        require(users[msg.sender].balance > 0, "The balance must be greater than zero");
        uint256 currentStep = getCurrentStep(msg.sender);
        require(currentStep > users[msg.sender].step, "The current step must be greater than the previous user's withdrawal step");
        uint256 payment = getPayment();
        users[msg.sender].balance = users[msg.sender].balance - payment;
        token.safeTransfer(msg.sender, payment);
        users[msg.sender].step = currentStep;
    }

    /*///////////////////////////////////////////////////////////////
                    VIEWERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Returns user's current step.
     * @param _user The user's address.
     */
    function getCurrentStep(address _user) public view returns (uint256) {
        require(users[_user].deposit > 0, "The deposit must be greater than zero");
        uint256 step;
        if (users[_user].releaseTime <= block.timestamp) {
            step = (block.timestamp - users[_user].releaseTime) / RELEASE_STEP;
            step = step >= numberOfSteps ? numberOfSteps : step + 1;
        } else step = 0;
        return step;
    }
    
    /**
     * @dev Returns the number of tokens the user can withdraw at the moment.
     */
    function getPayment() public view returns(uint256) {
        uint256 _payment;
        uint256 currentStep = getCurrentStep(msg.sender);
        if (currentStep == numberOfSteps) {
            _payment = users[msg.sender].balance;
        } else {
            _payment = _valueFromPercent(users[msg.sender].deposit, stepPercent * (currentStep - users[msg.sender].step));
        }
        return (_payment);
    }

    /**
     * @dev Returns user's deposited amount, balance, previous withdrawal step and unix timestamp of unlocking funds.
     * @param _user The user's address.
     */
    function getUser(address _user) public view returns(uint256, uint256, uint256, uint256) {
        return (users[_user].deposit, users[_user].balance, users[_user].step, users[_user].releaseTime);
    }

    /*///////////////////////////////////////////////////////////////
                    INTERNAL  HELPERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Returns the amount equal to the specified percentage of the value but counts in 0.001%.
     * @notice 1% - 1000, 10% - 10000, 50% - 50000
     * @param _value The amount to get percent from.
     * @param _percent The required percentage.
     */
    function _valueFromPercent(uint256 _value, uint256 _percent) internal pure returns (uint256 amount) {
        uint256 _amount = _value * _percent / 100000;
        return (_amount);
    }
}