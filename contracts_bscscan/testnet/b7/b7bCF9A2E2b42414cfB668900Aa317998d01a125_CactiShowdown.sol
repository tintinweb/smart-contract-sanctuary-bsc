/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
}

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

contract CactiShowdown is Ownable {
    /* ======== VARIABLES ======== */

    IERC20 public cactiToken;
    uint feesInPercentage;
    address feeAddress;

    /* ======== EVENTS ======== */

    event Buyin(uint256 _matchId, uint256 _amountOfTokens, address _wallet);
    event Refund(uint256 _refundAmount, address _refundAddress);
    event PayedWinner(uint256 _winnersAmount, address _winnersAddress, uint256 _feesPayed);
    event UpdateCactiTokenAddress(address _cactiToken);
    event UpdateFeeAddress(address _feeAddress);
    event UpdateFeesInPercentage(uint _feesInPercentage);

    /* ======== INITIALIZATION ======== */

    constructor(IERC20 _cactiToken, uint _feesInPercentage, address _feeAddress) {
        require(address(_cactiToken) != address(0), 'CactiShowdown: CactiToken cannot be the zero address');
        require(_feeAddress != address(0), 'CactiShowdown: feeAddress cannot be the zero address');

        cactiToken = _cactiToken;
        feesInPercentage = _feesInPercentage;
        feeAddress = _feeAddress;
    }

    /* ======== MODIFIERS ======== */

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    /* ======== CALLABLE FUNCTIONS ======== */

    /**
    * @dev Buy-in for when entering a room.
    */
    function buyIn(uint256 _matchId, uint256 _amountOfTokens) external callerIsUser returns (uint256) {
        uint256 oldBalanceOfSender = cactiToken.balanceOf(msg.sender);
        require(oldBalanceOfSender >= _amountOfTokens, 'CactiShowdown: Not enough cacti tokens for the buy-in');
        // In-order to spend the msg.senders cacti tokens he needs to approve this contract to spend his tokens. 
        // We don't need to do a allowance check because the transferFrom function does this already.
        cactiToken.transferFrom(msg.sender, address(this), _amountOfTokens);
        // Check the new balance after transfering
        uint256 newBalanceOfSender = cactiToken.balanceOf(msg.sender);
        require(newBalanceOfSender == (oldBalanceOfSender - _amountOfTokens), 'CactiShowdown: Incorrect new balance');
        
        emit Buyin(_matchId, _amountOfTokens, msg.sender);
        return _matchId;
    }

    /**
    * @dev Send the funds to the winner with a small fee percentage
    * @param _winnersAmount the amount in wei
    * @param _winnersAddress the address that won the game
    */
    function sendFundsToWinner(uint256 _winnersAmount, address _winnersAddress) external onlyOwner returns (bool) {
        // Does the contract have enough cacti tokens to pay the `_winnersAddress` based on the `_winnersAmount` amount
        uint256 availableBalanceInContract = cactiToken.balanceOf(address(this));
        uint256 feesToPay = _winnersAmount / feesInPercentage;
        uint256 newAmountToWinner = _winnersAmount - feesToPay;
        require(availableBalanceInContract >= newAmountToWinner, 'CactiShowdown: Not enough cacti tokens in the contract to send');

        cactiToken.approve(address(this), _winnersAmount);
        // Send funds to the winner
        cactiToken.transferFrom(address(this), _winnersAddress, newAmountToWinner);
        // Send fees to `feeAddress`
        cactiToken.transferFrom(address(this), feeAddress, feesToPay);

        emit PayedWinner(_winnersAmount, _winnersAddress, feesToPay);
        return true;
    }

    /**
    * @dev Refunds the payed cacti's
    * @param _refundAmount the amount in wei
    * @param _refundAddress the address that will receive the refund
    */
    function refund(uint256 _refundAmount, address _refundAddress) external onlyOwner returns (bool) {
        // Does the contract have enough cacti tokens to refund the `_refundAddress`;
        uint256 availableBalanceInContract = cactiToken.balanceOf(address(this));
        require(availableBalanceInContract >= _refundAmount, 'CactiShowdown: Not enough cacti tokens in the contract to send');

        cactiToken.approve(address(this), _refundAmount);
        cactiToken.transferFrom(address(this), _refundAddress, _refundAmount);

        emit Refund(_refundAmount, _refundAddress);
        return true;
    }

    /* ======== SETTER FUNCTIONS ======== */

    /**
    * @dev Sets the new cacti token address
    */
    function setCactiTokenAddress(IERC20 _cactiToken) external onlyOwner {
        require(address(_cactiToken) != address(0), 'CactiShowdown: CactiToken cannot be the zero address');
        cactiToken = _cactiToken;

        emit UpdateCactiTokenAddress(address(_cactiToken));
    }

    /**
    * @dev Sets the fee address for the buyin
    */
    function setFeeAddress(address _feeAddress) external onlyOwner {
        require(_feeAddress != address(0), 'CactiShowdown: feeAddress cannot be the zero address');
        feeAddress = _feeAddress;

        emit UpdateFeeAddress(_feeAddress);
    }

    /**
    * @dev Sets the new fee value
    */
    function setFee(uint _feesInPercentage) external onlyOwner {
        require(_feesInPercentage <= 100, 'CactiShowdown: Fees cannot be above 100');
        feesInPercentage = _feesInPercentage;

        emit UpdateFeesInPercentage(_feesInPercentage);
    }
}