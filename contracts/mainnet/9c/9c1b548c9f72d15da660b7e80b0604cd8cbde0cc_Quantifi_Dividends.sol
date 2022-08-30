/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

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

// File: quantifi/IERC20.sol


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
// File: quantifi/dividends.sol


pragma solidity 0.8.10;



contract QNTFI{
    function getWeightAt(address who, uint timestamp) public view returns(uint weight){}
    function getTotalStakes() public view returns(uint _totalStakes){}
}

contract Quantifi_Dividends is Ownable {
    address public QNTFI_ADDRESS; // address of governance token
    address public QIT_ADDRESS; // address of QIT contract (e.g. fund deposit contract)
    uint public numDividends; // tracker for the number of dividends that have been issued
    uint public lastDividendTimestamp; // tracker of when the previous dividend was created, to ensure adequate spacing between dividends
    address public paymentToken; // address of payment token (BSC USDT))
    uint public roundOneLength; // length of time in 1st dividend claim round
    uint public roundTwoLength; // length of time in 2nd dividend claim round
    uint public minTimeBetweenDividends; // minimum spacing between dividend rounds

    // Create a structure to represent a single Dividend
    struct Dividend {
        // how much, when, totalStakedValue
        uint totalStakes;
        uint timestamp;
        uint dividendAmount;
        // 1st round of dividend claims
        uint roundOneTotalClaimed;
        uint roundOneWeight;
        mapping(address => uint) roundOneClaim;
        // 2nd round of dividend claims
        uint roundTwoTotalClaimed;
        mapping (address => uint) roundTwoClaim;
        uint finished;
    }
    // our main variable is an array of Dividend structs
    mapping (uint => Dividend) public dividends;

    constructor(address _paymentToken, address _QNTFI, address _QIT){
        paymentToken = _paymentToken;
        QNTFI_ADDRESS = _QNTFI;
        QIT_ADDRESS = _QIT;
        roundOneLength = 7 days;
        roundTwoLength = 7 days;
        minTimeBetweenDividends = 90 days;
    }

    // make a new dividend
    function newDividend() public {

        // require having funds and sufficient time having past since last dividend
        uint thisBalance = IERC20(paymentToken).balanceOf(address(this));
        require(thisBalance>0,"No funds available to create a dividend");
        require(block.timestamp > (lastDividendTimestamp + minTimeBetweenDividends),"Insufficient time has past since previous dividend");
        
        // create a new dividend
        uint totalStakes_ = QNTFI(QNTFI_ADDRESS).getTotalStakes();
        dividends[numDividends].totalStakes = totalStakes_;
        dividends[numDividends].timestamp = block.timestamp;
        dividends[numDividends].dividendAmount = thisBalance;

        // increment our counters
        numDividends+=1;
        lastDividendTimestamp = block.timestamp;
    }
    // user claim a dividend
    function claimDividend() public {

        // get variables
        uint divNumber = numDividends-1;
        uint divTimestamp = dividends[divNumber].timestamp;

        //checks
        require(divTimestamp>0 && dividends[divNumber].finished == 0,"No dividends are available to claim");
        uint callerWeight = QNTFI(QNTFI_ADDRESS).getWeightAt(msg.sender,dividends[divNumber].timestamp);
        require(callerWeight > 0,"You were not eligible to receive this dividend");

        // check if we are in round 1 or round 2
        if ((block.timestamp - divTimestamp)<roundOneLength){

            // check not already claimed
            require(dividends[divNumber].roundOneClaim[msg.sender]==0,"You have already claimed this dividend");

            // calculate dividend owed to msg.sender
            uint owed = dividends[divNumber].dividendAmount * callerWeight / dividends[divNumber].totalStakes;
            dividends[divNumber].roundOneWeight+=callerWeight;
            dividends[divNumber].roundOneTotalClaimed+=owed;
            dividends[divNumber].roundOneClaim[msg.sender]=1;

            // transfer dividend to msg.sender
            IERC20(paymentToken).transfer(msg.sender,owed);
        } else if ((block.timestamp - divTimestamp-roundOneLength)<roundTwoLength){

            // check claimed in round 1 but not yet in round 2
            require(dividends[divNumber].roundOneClaim[msg.sender]>0,"You needed to claim in round 1 to be eligible to claim in round 2");
            require(dividends[divNumber].roundTwoClaim[msg.sender]==0,"You ahve already claimed your round 2 dividend");

            // calculate the dividend owed to msg.sender
            uint owed = (dividends[divNumber].dividendAmount - dividends[divNumber].roundOneTotalClaimed) * callerWeight / dividends[divNumber].roundOneWeight;
            dividends[divNumber].roundTwoTotalClaimed+=owed;
            dividends[divNumber].roundTwoClaim[msg.sender]=1;

            // transfer dividend to msg.sender
            IERC20(paymentToken).transfer(msg.sender,owed);
        }
    }

    // finish a dividend
    function finishDividend() external {

        //checks
        uint divNumber = numDividends-1;
        require(block.timestamp>(dividends[divNumber].timestamp + roundOneLength + roundTwoLength),"Dividend claim window is still open");
        require(dividends[divNumber].finished==0,"Current divident has already been finished");

        // calculate what is remaining unclaimed and set the dividend as finished
        uint unclaimed = dividends[divNumber].dividendAmount - dividends[divNumber].roundOneTotalClaimed - dividends[divNumber].roundTwoTotalClaimed;
        dividends[divNumber].finished = 1;

        // transfer the remaining funds to the Fund Contract
        IERC20(paymentToken).transfer(QIT_ADDRESS,unclaimed);
    }


    // owner functions 
    function updateRoundOneLength(uint numDays) external onlyOwner {
        roundOneLength = numDays * 1 days;
    }

    function updateRoundTwoLength(uint numDays) external onlyOwner {
        roundTwoLength = numDays * 1 days;
    }

    function updateMinTimeBetweenDividends(uint numDays) external onlyOwner{
        minTimeBetweenDividends = numDays * 1 days;
    }

    function setQITAddress(address _addr) external onlyOwner {
        QIT_ADDRESS = _addr;
    } 
}