/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor ()  { }

  function _msgSender() internal view returns (address payable) {
    return payable( msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}
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
contract Ownable is Context {
  address public _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
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
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Ca
   n only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}



contract TokenVesting is Ownable {


    address public token;
    uint256 public total_amount;

    constructor(address _token)  {
       token = _token;
    }

  
    struct VestingSchedule{
        // Total number of token release.
        uint256 amountTotal;
        // Time for which relase will there.
        uint256 releaseDate;
    }


    bytes [] private vestingSchedulesIds;
    mapping(address => VestingSchedule) private vestingSchedules;

    function toBytes(address a) public pure returns (bytes memory) {
        return abi.encodePacked(a);
    }

    function createVestingSchedule(uint256 _amount) public onlyOwner{
        require(_amount > 0, "TokenVesting: amount must be > 0");
        require(IERC20(token).balanceOf(address(this)) >= _amount, "Insifficient fund for vesting.");
        vestingSchedules[owner()] = VestingSchedule(
            _amount,
            block.timestamp + 30 days
        );
        vestingSchedulesIds.push(toBytes(owner()));
    }

    // Declare a function to release 10% of the total token supply to a specified address
    function releaseTokens(address vestingScheduleId, address _to, uint256 relase_amount) public onlyOwner{
       
       VestingSchedule storage vestingSchedule = vestingSchedules[vestingScheduleId];
       
        // Check that the current block timestamp is greater than the release date
        require(block.timestamp < vestingSchedule.releaseDate, "Time is over for this vesting session.");
        require(vestingSchedule.amountTotal >= relase_amount + total_amount, "Token is insufficient.");
            // address payable beneficiaryPayable = payable(_to);
            total_amount += relase_amount;
            // Transfer the tokens to the specified address
            IERC20(token).transfer(_to, relase_amount);
    }


    function withdraw(uint256 amount)
        public
        onlyOwner{
          IERC20(token).transfer(owner(), amount);
    }

    function getBalance() public view returns (uint256) {
        // Call the balanceOf function of the other token contract
        uint256 bal = IERC20(token).balanceOf(address(this));
        return bal;
    }

    function gettotal_amount() public view returns (uint256) {
      return total_amount;
    }
}