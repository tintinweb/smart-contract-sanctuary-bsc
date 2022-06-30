/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

// SPDX-License-Identifier: GPL-3.0
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contracts/claim.sol


pragma solidity >=0.7.0 <0.9.0;



contract ReceiverPays is Ownable {
    event LogRoom(
        uint256 maxtUser,
        uint256 currentUser,
        uint amountBgs,
        uint amountFp,
        address sender
    );

    IERC20 public rewardsTokenBGS = IERC20(0xBCD69146f2111cDd4e4E586B29322b39963474e0);
    uint256 public decimalTokenBGS = 1;

    IERC20 public rewardsTokenFP = IERC20(0x3553574b50163c0DB7650DEe917dBc88AEa7fb37);
    uint256 public decimalTokenFP = 3;

    mapping(string => bool) usedNonces;

    function setDecimalBGS(uint256 dec) external onlyOwner{
        decimalTokenBGS = dec;
    }

    function setDecimalFP(uint256 dec) external onlyOwner{
        decimalTokenFP = dec;
    }

    function setAddressBGS(address addr) external onlyOwner{
        rewardsTokenBGS = IERC20(addr);
    }

    function setAddressFP(address addr) external onlyOwner{
        rewardsTokenFP = IERC20(addr);
    }

    struct Listing {
        uint256 maxUser;
        uint256 currentUser;
        uint amountBgs;
        uint amountFp;
	}

    mapping(address => Listing) roomData;


    function createRoom(uint256 maxUser, uint256 amount1, uint256 amount2) external {

        if(amount1 > 0){
            rewardsTokenBGS.transferFrom(
                msg.sender,
                owner(),
                amount1
            );
        }

        if(amount2 > 0){
            rewardsTokenFP.transferFrom(
                msg.sender,
                owner(),
                amount2
            );
        }

        Listing memory listing = Listing(
			maxUser,
			1,
			amount1,
            amount2
		);

        roomData[msg.sender] = listing;  

        emit LogRoom(
            maxUser,
			1,
			amount1,
            amount2,
            msg.sender
        );
    }

    function joinRoom(address master, uint256 amount1, uint256 amount2) external {
        require(roomData[master].maxUser >= roomData[master].currentUser+1);

        if(amount1 > 0){
            rewardsTokenBGS.transferFrom(
            msg.sender,
            owner(),
            amount1
            );
        }

        if(amount2 > 0){
            rewardsTokenFP.transferFrom(
                msg.sender,
                owner(),
                amount2
            );
        }

        roomData[master].currentUser = roomData[master].currentUser+1;

        emit LogRoom(
            roomData[master].maxUser,
			roomData[master].currentUser,
			amount1,
            amount2,
            msg.sender
        );
    }

    function getListing(address master) public view returns (Listing memory) {
		return roomData[master];
    }

    function refundRoom(address master, uint256 amount1, uint256 amount2) external {
        require(roomData[master].maxUser >= roomData[master].currentUser+1);

        if(amount1 > 0){
            rewardsTokenBGS.transfer(
            msg.sender,
            amount1
            );
        }

        if(amount2 > 0){
            rewardsTokenFP.transfer(
                msg.sender,
                amount2
            );
        }

        roomData[master].currentUser = roomData[master].currentUser-1;

        emit LogRoom(
            roomData[master].maxUser,
			roomData[master].currentUser,
			amount1,
            amount2,
            msg.sender
        );
    }
}