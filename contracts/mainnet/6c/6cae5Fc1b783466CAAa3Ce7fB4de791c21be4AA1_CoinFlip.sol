/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

// SPDX-License-Identifier: UNLICENCED
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: @openzeppelin/contracts/utils/Context.sol


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

// File: Games/CoinFlip/coinFlip.sol





pragma solidity ^0.8.7;

contract CoinFlip is Ownable {

    address public gameToken = 0xd51237A6F3219d186f0C8d8Dd957b1Bcb3Ce5d48;
    address public lotteryAddress = 0xDF7ca526F053a661684a6FE41d53aC758351e051;
    
    uint256 public amountToSendAt = 100000000000000000000;
    uint256 public feesCollected = 0;
    uint256 public quickBetAmount = 10000000000000000000;
    uint256 public FeeDivisor = 0;

    event win (address player, uint256 amount);
    event loss (address player, uint256 amount);

    function setGameToken(address _token) external onlyOwner {
        gameToken = _token;
    }

    function setAmountToSendAt(uint256 amount) external onlyOwner {
        amountToSendAt = amount;
    }
    
    function setFeeDivisor(uint256 newDivisor) external onlyOwner {
        require(newDivisor <= 100,"must be between 0 and 100 %");
        FeeDivisor = newDivisor;
    }

    function setQuickBetAmount(uint256 amount) external onlyOwner {
        quickBetAmount = amount;
    }

    function setLotteryAddress(address newLottery) external onlyOwner{
        lotteryAddress = newLottery;
    }

    // betting functions

    function potAmount() external view returns (uint256) {
        return IERC20(gameToken).balanceOf(address(this)) - feesCollected;
    }

    function maxBetAllowed() public view returns (uint256){
        return IERC20(gameToken).balanceOf(address(this)) - feesCollected / 4;
    }

    function quickBetHeads() external returns (bool isHeads, bool isWinner){
        (isHeads, isWinner) = flipTheCoin(quickBetAmount, true);
        
    }

    function BetHeads(uint256 amount) external returns (bool isHeads, bool isWinner){
        (isHeads, isWinner) = flipTheCoin(amount, true);
    }

    function quickBetTails() external returns (bool isHeads, bool isWinner){
        (isHeads, isWinner) = flipTheCoin(quickBetAmount, false);
    }

    function BetTails(uint256 amount) external returns (bool isHeads, bool isWinner){
        (isHeads, isWinner) = flipTheCoin(amount, false);
    }

    function flipTheCoin(uint256 _betAmount, bool chooseHeads) internal returns (bool isHeads, bool isWinner) {
        require(_betAmount <= maxBetAllowed(), "your bet is above the limit");
        require(IERC20(gameToken).balanceOf(msg.sender) >= _betAmount, "Insufficient balance");
        require(IERC20(gameToken).allowance(msg.sender, address(this)) >= _betAmount,"please approve contract on GameToken");
        uint256 result = rng();
        if(result == 0) isHeads = true;
        if(chooseHeads == isHeads) isWinner = true;

        if(isWinner) {
            IERC20(gameToken).transfer(msg.sender, _betAmount*2);
            emit win(msg.sender,_betAmount);
        }
        if(!isWinner) {
            if(FeeDivisor == 0) IERC20(gameToken).transferFrom(msg.sender, address(this), _betAmount);
            else sendFees(_betAmount);
            emit loss(msg.sender, _betAmount);
        }

    }

    function sendFees(uint256 amount) internal {
        uint256 amountToLottery = amount * FeeDivisor / 100;
        feesCollected += amountToLottery;
        amount -= amountToLottery;
        if(feesCollected >= amountToSendAt) IERC20(gameToken).transferFrom(msg.sender, lotteryAddress, amountToLottery);
        IERC20(gameToken).transferFrom(msg.sender, address(this), amount);
    }

    function rng() internal view returns(uint256) {
    uint256 seed = block.timestamp * block.difficulty + block.gaslimit + gasleft(); 
    uint256 value = uint256(keccak256(abi.encodePacked(seed))) % 2;
    return value;
  }

  // to receive Eth From Router when Swapping
    receive() external payable {}

  function withdrawBNB() external onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }

  function withdrawlToken(address _tokenAddress) external onlyOwner {
            uint256 _tokenAmount = IERC20(_tokenAddress).balanceOf(address(this));
            IERC20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);
            feesCollected = 0;
        }

}