/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

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

interface IStakeContract {
    function stake(uint256 _id, uint256 _amount) external;
    function unstake(uint256 _bagLengthIndex) external;
    function unstakes(uint256[] calldata indexs) external;
    function ownerStake(address[] calldata _accounts, uint256[] calldata _ids, uint256[] calldata _amounts) external;
    function compensateRewards(address _bep20pf, uint256[] calldata _amounts, address[] calldata _users, uint256[] calldata _bagIndexs) external;
    function depositProfit(uint256[] calldata _amounts, address[] calldata _users, uint256[] calldata _bagIndexs) external;
    function depositProfitBep20(address _bep20pf, uint256[] calldata _amounts, address[] calldata _users, uint256[] calldata _bagIndexs) external;
    function config(uint256 _stakeTime, uint256 _minStake, address _takeBep20,  uint256 _percentDecimal, uint256 _panaltyPercent, uint256 _stakeFeePercent) external;
    function withdrawBEP20(address _to, IBEP20 _bep20, uint256 _amount) external;
    function withdraw(address payable _to, uint256 _amount) external;
}

contract CallStakeContractTest{
    string private hello ="Hello World";
    address private stakingContract = 0xe6392793f8143Ac533371Fa9F6cA79c503f980e7;

    function getHelloGreeting() public view returns(string memory){
        return hello;
    }
      function getStakingContract() public view returns(address){
        return stakingContract;
    }

    function setStakingContract(address _stakingContract) public{
         stakingContract = _stakingContract;
    } 

    function callOwnerStake(address[] memory _accounts, uint256[] memory _ids, uint256[] memory _amounts) public{
        IStakeContract(stakingContract).ownerStake(_accounts, _ids, _amounts);
    }

    function callCompensateRewards(address _bep20pf, uint256[] memory _amounts, address[] memory _users, uint256[] memory _bagIndexs) public{
        IStakeContract(stakingContract).compensateRewards(_bep20pf, _amounts, _users, _bagIndexs);
    }

    function stake(uint256 _id, uint256 _amount) public{
        IStakeContract(stakingContract).stake(_id, _amount);
    }
    
    function unstake(uint256 _bagLengthIndex) public{
        IStakeContract(stakingContract).unstake(_bagLengthIndex);
    }

    function unstakes(uint256[] memory indexs) public{
        IStakeContract(stakingContract).unstakes(indexs);
    }
}