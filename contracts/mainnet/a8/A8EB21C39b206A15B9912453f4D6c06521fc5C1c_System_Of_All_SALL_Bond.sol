/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

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

contract Bond {
  address _tokenContract;
  address _recipient;
  uint256 _coupon;
  uint _startDate;
  uint _couponsIssued;
  uint _couponsToIssue;
  uint _interval;

  constructor(address tokenContract_, address recipient_, uint256 coupon_, uint couponsToIssue_, uint interval_) {
    _tokenContract = tokenContract_;
    _coupon = coupon_;
    _startDate = block.timestamp;
    _couponsIssued = 0;
    _couponsToIssue = couponsToIssue_;
    _interval = interval_;
    _recipient = recipient_;
  }

  function coupon() external view returns (uint) {
    return _coupon;
  }

  function recipient() external view returns (address) {
    return _recipient;
  }

  function startDate() external view returns (uint) {
    return _startDate;
  }

  function couponsIssued() external view returns (uint) {
    return _couponsIssued;
  }

  function couponsToIssue() external view returns (uint) {
    return _couponsToIssue;
  }
  
  function withdraw() external returns (uint256) {
    uint _couponsPotentiallyEarned = (block.timestamp - _startDate) / _interval;
    uint _couponsEarned = _couponsPotentiallyEarned > _couponsToIssue ? _couponsToIssue : _couponsPotentiallyEarned;
    uint _couponsOwed = _couponsEarned - _couponsIssued;
    if (IERC20(_tokenContract).transfer(_recipient, _coupon * _couponsOwed)) {
      // happy path, transferred the owed balance to the recipient
      _couponsIssued = _couponsEarned;
      return _coupon * _couponsOwed;
    } else {
      // sad path, don't have the funds to do so... transfer the number of coupons
      // we do have enough funds for
      uint256 _availableCoupons = IERC20(_tokenContract).balanceOf(address(this)) / _coupon;
      // make sure that we actually can transfer the tokens the token contract claims we own,
      // and that we actually don't have enough for the happy path. either of these cases indicate
      // an unhappy ERC20 token
      require(
        _availableCoupons < _couponsOwed
      , "I could not transfer these coupons even though I possess them. This probably indicates a buggy ERC20 contract."
      );
      require(
        IERC20(_tokenContract).transfer(_recipient, _availableCoupons * _coupon)
      , "Could not even transfer the tokens that the contract owns. This probably indicates a buggy ERC20 contract."
      );
      _couponsIssued = _couponsIssued + _availableCoupons;
      return _coupon * _availableCoupons;
    }
  }

  function withdrawalLimit() external view returns (uint256) {
    uint _couponsPotentiallyEarned = (block.timestamp - _startDate) / _interval;
    uint _couponsEarned = _couponsPotentiallyEarned > _couponsToIssue ? _couponsToIssue : _couponsPotentiallyEarned;
    uint _couponsOwed = _couponsEarned - _couponsIssued;
    return _coupon * _couponsOwed;
  }
}

contract System_Of_All_SALL_Bond {
  address _saleTokenContract;
  address _seller;
  uint256 _salePrice;
  bool _sold;

  address _tokenContract;
  uint256 _coupon;
  uint _couponsToIssue;
  uint _interval;

  constructor(address tokenContract_, uint256 coupon_, uint couponsToIssue_, uint interval_, uint256 salePrice_, address saleTokenContract_, address seller_) {
    _saleTokenContract = saleTokenContract_;
    _sold = false;
    _salePrice = salePrice_;
    _seller = seller_;

    _tokenContract = tokenContract_;
    _coupon = coupon_;
    _couponsToIssue = couponsToIssue_;
    _interval = interval_;
  }

  function funded() internal view returns (bool) {
    return IERC20(_tokenContract).balanceOf(address(this)) >= _coupon * _couponsToIssue;
  }

  function coupon() external view returns (uint) {
    return _coupon;
  }

  function couponsToIssue() external view returns (uint) {
    return _couponsToIssue;
  }

  function buy() external returns (address) {
    require(funded(), "Contract must already be funded");
    require(!_sold, "Contract must not already be sold");
    IERC20(_saleTokenContract).transferFrom(msg.sender, address(this), _salePrice);
    Bond bond = new Bond(_tokenContract, msg.sender, _coupon, _couponsToIssue, _interval);
    require(IERC20(_tokenContract).transfer(address(bond), IERC20(_saleTokenContract).balanceOf(address(this))), "Must transfer funds to the bond");
    return address(bond);
  }
  
  function withdraw() external {
    require(msg.sender == _seller, "Only the seller can withdraw the funds");
    require(IERC20(_saleTokenContract).transfer(_seller, IERC20(_saleTokenContract).balanceOf(address(this))), "Must transfer funds back to originator of the contract");
  }
}