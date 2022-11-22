/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: GPL-3.0
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: contracts/PoolUSDTBSC.sol


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


contract USDT_pool is Ownable {

    IBEP20 public USDTContract = IBEP20(0x55d398326f99059fF775485246999027B3197955);

    mapping(address => uint) private deposits;
    mapping(address => uint) private balances;
    mapping(address => uint) private withdraws;

    event Deposit(address from, uint amount, uint timestamp);
    event WithdrawByOwner(address recipient, uint amount);
    event WithdrawOwnerByUser(address recipient, uint percent, uint amount);


    function deposit(uint _amount) external {
        require(getAllowance() >= _amount);
        USDTContract.transferFrom(msg.sender, address(this), _amount);
        deposits[msg.sender] += _amount;
        balances[msg.sender] += _amount;

        emit Deposit(msg.sender, _amount, block.timestamp);
    }


    function withdrawByOwner(address _to, uint _amount) external onlyOwner {
        require(totalBalanceUSDT() >= _amount, "USDT isn't enough on balance contract!");
        USDTContract.transfer(_to, _amount);

        emit WithdrawByOwner(_to, _amount);
    }


    function withdrawOwnerByUser(address _to, uint _percent) external onlyOwner {
        require(getDepositUser(_to) > 0, "This user didn't make a deposit!");
        uint _value = getDepositUser(_to) * _percent / 100;
        if(getBalanceUser(_to) >= _value) {
            require(totalBalanceUSDT() >= _value, "Not enough usdt on contract");
            balances[_to] -= _value;
            withdraws[_to] += _value;
            USDTContract.transfer(_to, _value);

            emit WithdrawOwnerByUser(_to, _percent, _value);
        } else {
            require(totalBalanceUSDT() >= _value, "Not enough usdt on contract");
            balances[_to] = 0;
            withdraws[_to] += _value;
            USDTContract.transfer(_to, _value);

            emit WithdrawOwnerByUser(_to, _percent, _value);
        }
    }


    function getBalanceUser(address _user) public view returns(uint) {
        return balances[_user];
    }


    function getDepositUser(address _user) public view returns(uint) {
        return deposits[_user];
    }


    function getWithdrawUser(address _user) public view returns(uint) {
        return withdraws[_user];
    }


    function totalBalanceUSDT() public view returns(uint) {
        return USDTContract.balanceOf(address(this));
    }


    function getAllowance() public view returns(uint) {
        return USDTContract.allowance(msg.sender, address(this));
    }


    function withdrawEthByOwner() external onlyOwner {
        uint balanceThis = address(this).balance;
        require(balanceThis > 0, "Not enought money");
        address owner = owner();
        payable(owner).transfer(balanceThis);
    }


    function renounceOwnership() public view override onlyOwner {
        revert();
    }

    receive() external payable {}

    fallback() external {
        revert();
    }
}