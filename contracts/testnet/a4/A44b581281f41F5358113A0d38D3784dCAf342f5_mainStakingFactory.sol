/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor ()  { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor ()  {
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
   * Can only be called by the current owner.
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
interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint256);

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

interface BNBForBNB{
    function createBNBForBNB(address ownerAddress, uint256 _apy, uint256 _earlyUstakeFee, address _rewardingTokenWallet, uint256 _lockPeriod, uint256 _maxReward, uint256 _earlyRewardUstakeFee, bool autoCompund, bool _earlyUstake) external returns (address);
    function transferOwnership(address newOwner) external;
    }

interface BNBForTOKEN{
    function createBNBForToken(address ownerAddress, uint256 _apy, uint256 _earlyUstakeFee, IBEP20 _rewardingToken, address _rewardingTokenWallet, uint256 _lockPeriod, uint256 _maxReward, uint256 _earlyRewardUstakeFee, bool autoCompund, bool _earlyUstake) external returns (address);
    function transferOwnership(address newOwner) external;
    }

interface TOKENForBNB{
    function createTokenForBNB(address ownerAddress, uint256 _apy, uint256 _earlyUstakeFee, IBEP20 _stakingToken, address _rewardingTokenWallet, uint256 _lockPeriod, uint256 _maxReward, uint256 _earlyRewardUstakeFee, bool autoCompund, bool _earlyUstake) external returns (address);
    function transferOwnership(address newOwner) external;
    }

interface TOKENForTOKEN {
    function createTokenForToken(address ownerAddress, uint256 _apy, uint256 _earlyUstakeFee, IBEP20 _stakingToken, IBEP20 _rewardingToken, address _rewardingTokenWallet, uint256 _lockPeriod, uint256 _maxReward, uint256 _earlyRewardUstakeFee, bool autoCompund, bool _earlyUstake)  external returns (address);
    function transferOwnership(address newOwner) external;
    }

contract mainStakingFactory is Ownable{

    BNBForBNB public bnbForBnb;
    BNBForTOKEN public bnbForToken;
    TOKENForBNB public tokenForBnb;
    TOKENForTOKEN public tokenForToken;

    struct structBnbForBnb{
        uint256 _apy;
        address _rewardingTokenWallet;
        address ownerAddress;
        uint256 _earlyUnstakeFee;
        uint256 _lockPeriod;
        uint256 _maxReward;
        uint256 _earlyRewardUstakeFee;
        bool _autoCompund;
        bool _earlyUstake;
    }

    struct structBnbForToken{
        uint256 _apy;
        uint256 _lockPeriod;
        address _rewardingTokenWallet;
        uint256 _earlyUnstakeFee;
        uint256 _maxReward;
        uint256 _earlyRewardUstakeFee;
        IBEP20 _rewardingToken;
        address ownerAddress;
        bool _autoCompund;
        bool _earlyUstake;
    }

    struct structTokenForBnb{
        address ownerAddress;
        uint256 _apy;
        uint256 _lockPeriod;
        address _rewardingTokenWallet;
        uint256 _earlyUnstakeFee;
        uint256 _maxReward;
        uint256 _earlyRewardUstakeFee;
        IBEP20 _stakeToken;
        bool _autoCompund;
        bool _earlyUstake;
    }

    struct structTokenForToken{
        uint256 _apy;
        address ownerAddress;
        uint256 _earlyUnstakeFee;
        IBEP20 _stakingToken;
        IBEP20 _rewardingToken;
        address _rewardingTokenWallet;
        uint256 _lockPeriod;
        uint256 _maxReward;
        uint256 _earlyRewardUstakeFee;
        bool _autoCompund;
        bool _earlyUstake;
    }


    constructor(
        address _bnbForBnb,
        address _bnbForToken,
        address _tokenForBnb,
        address _tokenForToken
    ){
        bnbForBnb = BNBForBNB(_bnbForBnb);
        bnbForToken = BNBForTOKEN(_bnbForToken);
        tokenForBnb = TOKENForBNB(_tokenForBnb);
        tokenForToken = TOKENForTOKEN(_tokenForToken);
    }

    function  createBnbForBnb(structBnbForBnb memory _values) public returns (address){
       address addres = bnbForBnb.createBNBForBNB(_values.ownerAddress, _values._apy, _values._earlyUnstakeFee, _values._rewardingTokenWallet, _values._lockPeriod, _values._maxReward, _values._earlyRewardUstakeFee, _values._autoCompund, _values._earlyUstake);
       return addres;
    }

    function  createBnbForToken(structBnbForToken memory _values) public {
        bnbForToken.createBNBForToken(_values.ownerAddress, _values._apy, _values._earlyUnstakeFee, _values._rewardingToken, _values._rewardingTokenWallet, _values._lockPeriod, _values._maxReward, _values._earlyRewardUstakeFee, _values._autoCompund, _values._earlyUstake);
    }

    function  createTokenForBnb(structTokenForBnb memory _values) public {
        tokenForBnb.createTokenForBNB(_values.ownerAddress, _values._apy, _values._earlyUnstakeFee, _values._stakeToken, _values._rewardingTokenWallet, _values._lockPeriod, _values._maxReward, _values._earlyRewardUstakeFee, _values._autoCompund, _values._earlyUstake);
    }

    function  createTokenForToken(structTokenForToken memory _values) public{
        tokenForToken.createTokenForToken(_values.ownerAddress, _values._apy, _values._earlyUnstakeFee, _values._stakingToken, _values._rewardingToken, _values._rewardingTokenWallet, _values._lockPeriod, _values._maxReward, _values._earlyRewardUstakeFee, _values._autoCompund, _values._earlyUstake);
    }

    function transferOwnerShipBnbForBnb(address _address) public onlyOwner {
        bnbForBnb.transferOwnership(_address);
    }

    function transferOwnerShipBnbForToken(address _address) public onlyOwner {
        bnbForToken.transferOwnership(_address);
    }


    function transferOwnerShipTokenForBnb(address _address) public onlyOwner {
        tokenForBnb.transferOwnership(_address);
    }

    function transferOwnerShipTokenForToken(address _address) public onlyOwner {
        tokenForToken.transferOwnership(_address);
    }

}