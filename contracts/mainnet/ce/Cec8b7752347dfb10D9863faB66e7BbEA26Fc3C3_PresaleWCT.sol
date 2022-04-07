/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// File: IBEP20.sol



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
     * IMPORTANT:  Beware that changingan allowance with this method brings the risk
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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: PresaleWCT.sol


pragma solidity ^0.8.0;




contract PresaleWCT is Ownable {
    using SafeMath for uint256;

    IBEP20 public WCTTokenAddress;
    IBEP20 public TCTTokenAddress;
    
    //starterdeck addressed
    IBEP20 public WASTokenAddress;                // contract address of WAS token
    IBEP20 public WCMSTokenAddress;               // contract address of WCMS token
    IBEP20 public WCNSTokenAddress;               // contract address of WCNS token
    IBEP20 public WMRSTokenAddress;               // contract address of WMRS token
    IBEP20 public WUSTokenAddress;                // contract address of WUS token

    IBEP20 public USDTAddress;
    
    // struct for Unlock with period and percent.
    struct UnlockPeriod {
        uint256 minDays;
        uint256 feePercent;
    }

    // Array of UnlockPeriod struct
    UnlockPeriod[] public unlockPeriod;

    mapping(address => bool) public whitelistedAddresses;

    uint256 public unitSwapTCT;

    uint256 public unitSwapWCT;

    uint256 public unitWCT;

    uint256 public unitUSDT;
    
    bool public TCT2WCT;

    // struct for Locked amount info
    struct LockedInfo{
        uint256 totalAirdrop;   // Total amount = lockAmount + unlockAmount
        uint256 unlockedAmount;   // Unlocked amount
    }

    mapping(address => LockedInfo) public lockedBalances;

    bool public unlockStatus;

    uint256 public unlockTime;

    bool public presaleStatus;

    // Events
    event WhitelistBuy(address indexed receiver, uint256 amountUSDT, uint256 amountWCT);

    event BillionairesBuy(address indexed buyer, uint256 amountUSDT, uint256 amountWCT);

    event StarterDeckBuy(address indexed buyer, uint256 amountUSDT, uint256 amountWCT);

    event TCTSwap(address indexed buyer, uint256 amountWCT, uint256 amountTCT);

    event UnlockWCT(address indexed buyer, uint256 amount);

    // admin Events
    event AirDrop(address indexed receiver, uint256 amount);

    event AdminWithdrawTCT(address indexed receiver, uint256 amount);

    event AdminWithdrawUSDT(address indexed receiver, uint256 amount);

    event AdminDepositWCT(uint256 amount);

    event AdminWithdrawWCT(address indexed receiver, uint256 amount);

    event SetUnlockPeriods(uint256 _index, uint256 _minDays, uint256 _feePercent);

    event AddUnlockPeriods(uint256 _index, uint256 _minDays, uint256 _feePercent);
    
    event RemoveUnlockPeriods(uint256 _index, uint256 _minDays, uint256 _feePercent);

    constructor(
        ) {
        
        WCTTokenAddress = IBEP20(0x531eBDb4337c038BdE84EF83080070A7c8214637);
        TCTTokenAddress = IBEP20(0xb036f689bd98B4Bd3BD648FA09A23e54d839A859);
        USDTAddress = IBEP20(0x55d398326f99059fF775485246999027B3197955);

        WASTokenAddress = IBEP20(0x06D8e34c4D2eA294cBEBF8F459a9687EBeb80aa0);
        WCMSTokenAddress = IBEP20(0xabB56A04BF6E174383A5ef897573e44B6c4B7bC1);
        WCNSTokenAddress = IBEP20(0xf36a695000F8a0a3faa28d044a894E62328A5e15);
        WMRSTokenAddress = IBEP20(0xaf471Dc597F303cbB11e24b6D9B83663d33232ca);
        WUSTokenAddress = IBEP20(0xd6ac22b7616377F06a8D736Ed5d0e2897F430553);

        unitSwapTCT = 100 * 1000;
        unitSwapWCT = 1000;

        unitWCT = 250 * 1000;
        unitUSDT = 100;

        initUnlockPeriods();
    }

    /**
        Create init Array for unlockPeriod
     */
    function initUnlockPeriods() private {
        UnlockPeriod memory unlockPeriod1 = UnlockPeriod({
            minDays: 0,
            feePercent: 20
        });
        unlockPeriod.push(unlockPeriod1);

        UnlockPeriod memory unlockPeriod2 = UnlockPeriod({
            minDays: 21,
            feePercent: 40
        });
        unlockPeriod.push(unlockPeriod2);

        UnlockPeriod memory unlockPeriod3 = UnlockPeriod({
            minDays: 42,
            feePercent: 60
        });
        unlockPeriod.push(unlockPeriod3);
        
        UnlockPeriod memory unlockPeriod4 = UnlockPeriod({
            minDays: 63,
            feePercent: 80
        });
        unlockPeriod.push(unlockPeriod4);

        UnlockPeriod memory unlockPeriod5 = UnlockPeriod({
            minDays: 84,
            feePercent: 100
        });
        unlockPeriod.push(unlockPeriod5);
    }

    /**
        Set _indexed element of unlockPeriod Array
     */
    function setUnlockPeriods(uint256 _index, uint256 _minDays, uint256 _feePercent) external onlyOwner {
        require(_index < unlockPeriod.length, "setUnlockPeriods: range out");
        // require(_minDays > 0, "setUnlockPeriods: minDays is 0");
        require(_feePercent <= 100, "setUnlockPeriods: feePercent > 100");
        if (_index == 0) {
            require(_minDays < unlockPeriod[1].minDays, "setUnlockPeriods: minDays is error");
            require(_feePercent < unlockPeriod[1].feePercent, "setUnlockPeriods: feePercent is error");
        } else if (_index == unlockPeriod.length - 1) {
            require(_minDays > unlockPeriod[_index - 1].minDays, "setUnlockPeriods: minDays is error");
            require(_feePercent > unlockPeriod[_index - 1].feePercent, "setUnlockPeriods: feePercent is error");
        } else {
            require(_minDays > unlockPeriod[_index - 1].minDays && _minDays < unlockPeriod[_index + 1].minDays, "setUnlockPeriods: minDays is error");
            require(_feePercent > unlockPeriod[_index - 1].feePercent && _feePercent < unlockPeriod[_index + 1].feePercent, "setUnlockPeriods: feePercent is error");
        }
        unlockPeriod[_index].feePercent = _feePercent;
        unlockPeriod[_index].minDays = _minDays;
        emit SetUnlockPeriods(_index, _minDays, _feePercent);
    }

    /**
        Add new element to unlockPeriod
     */
    function addUnlockPeriods(uint256 _minDays, uint256 _feePercent) external onlyOwner {
        // require(_minDays > 0, "addUnlockPeriods: minDays is 0");
        require(_feePercent <= 100, "addUnlockPeriods: feePercent > 100");
        require(_minDays > unlockPeriod[unlockPeriod.length - 1].minDays, "addUnlockPeriods: minDays is error");
        require(_feePercent > unlockPeriod[unlockPeriod.length - 1].feePercent, "addUnlockPeriods: feePercent is error");
        UnlockPeriod memory unlockPeriodData = UnlockPeriod({
            minDays: _minDays,
            feePercent: _feePercent
        });
        unlockPeriod.push(unlockPeriodData);
        emit AddUnlockPeriods(unlockPeriod.length, _minDays, _feePercent);
    }

    /**
        Remove one specified element.
     */
    function removeUnlockPeriods(uint256 _index) external onlyOwner {
        require(_index < unlockPeriod.length, "removeUnlockPeriods: range out");
        uint256 _minDays = unlockPeriod[_index].minDays;
        uint256 _feePercent = unlockPeriod[_index].feePercent;
        for (uint256 i = _index; i < unlockPeriod.length - 1; i++) {
            unlockPeriod[i] = unlockPeriod[i+1];
        }
        unlockPeriod.pop();
        emit RemoveUnlockPeriods(_index, _minDays, _feePercent);
    }

    /**
        Start Unlock status
     */
    function adminSetUnlockStatus(bool status) public onlyOwner{
        if(unlockStatus == status){
            return;
        }
        unlockStatus = status;
        if(unlockStatus == true){
            unlockTime = block.timestamp;
        }
    }

    /**
        Start PreSale status
     */
    function adminSetPresaleStatus(bool status) public onlyOwner{
        if(presaleStatus == status){
            return;
        }
        presaleStatus = status;
    }

    /**
        Functions for Set Token Addresses by only Admin
     */
    function adminSetWCTTokenAddress(IBEP20 WCTTokenAddress_) public onlyOwner {
        WCTTokenAddress = WCTTokenAddress_;
    }

    function adminSetTCTTokenAddress(IBEP20 TCTTokenAddress_) public onlyOwner {
        TCTTokenAddress = TCTTokenAddress_;
    }

    function adminSetUSDTTokenAddress(IBEP20 USDTAddress_) public onlyOwner {
        USDTAddress = USDTAddress_;
    }

    function adminSetWASTokenAddress(IBEP20 WASTokenAddress_) public onlyOwner {
        WASTokenAddress = WASTokenAddress_;
    }

    function adminSetWCMSTokenAddress(IBEP20 WCMSTokenAddress_) public onlyOwner {
        WCMSTokenAddress = WCMSTokenAddress_;
    }

    function adminSetWCNSTokenAddress(IBEP20 WCNSTokenAddress_) public onlyOwner {
        WCNSTokenAddress = WCNSTokenAddress_;
    }

    function adminSetWMRSTokenAddress(IBEP20 WMRSTokenAddress_) public onlyOwner {
        WMRSTokenAddress = WMRSTokenAddress_;
    }

    function adminSetWUSTokenAddress(IBEP20 WUSTokenAddress_) public onlyOwner {
        WUSTokenAddress = WUSTokenAddress_;
    }

    function adminSetTCT2WCT(bool tct2wct_) public onlyOwner {
        if(TCT2WCT != tct2wct_){
            TCT2WCT = tct2wct_;
        }
    }

    /**
        Set unit values by only Admin
     */
    function adminSetSwapTCT2WCT(uint256 unitSwapTCT_, uint256 unitSwapWCT_)  public onlyOwner {
        require(unitSwapTCT_ > 0 && unitSwapWCT_ > 0, "adminSetSwapTCT2WCT: invalid input param");
        unitSwapTCT = unitSwapTCT_;
        unitSwapWCT = unitSwapWCT_;
    }

    function adminSetSwapUSDT2WCT(uint256 unitUSDT_, uint256 unitWCT_)  public onlyOwner {
        require(unitUSDT_ > 0 && unitWCT_ > 0, "adminSetSwapTCT2WCT: invalid input param");
        unitUSDT = unitUSDT_;
        unitWCT = unitWCT_;
    }

    /**
        Add Whitelist by only owner
     */
    function adminAddWhitelist(address _address) public onlyOwner {
        whitelistedAddresses[_address] = true;
    }

    /**
        Add Whitelist array
     */
    function adminAddWhitelistArray(address[] calldata addresses) public onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            if(whitelistedAddresses[addresses[i]] == false){
                adminAddWhitelist(addresses[i]);
            }
        }
    }

    /**
        Remove Whitelist by only owner
     */
    function adminRemoveWhitelist(address _address) public onlyOwner {
        whitelistedAddresses[_address] = false;
    }

    /**
        Remove Whitelist array
     */
    function adminRemoveWhitelistArray(address[] calldata addresses) public onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            if(whitelistedAddresses[addresses[i]] == true){
                adminRemoveWhitelist(addresses[i]);
            }
        }
    }

    /**
        Verify address is in whitelist or not
     */
    function verifyWhitelistAddress(address _whiteListedAddress) public view returns (bool) {
        return whitelistedAddresses[_whiteListedAddress];
    }

    /**
        Calculate current unlock amount
     */
    function _unlockAmount(address buyer) internal view returns (uint256){
        if(unlockStatus == false){
            return 0;
        }
        uint256 duration = block.timestamp - unlockTime;
        for(uint256 i = unlockPeriod.length - 1; i >= 0; i--) {
            if(duration >= unlockPeriod[i].minDays.mul(3600 * 24)){
            // if(duration >= unlockPeriod[i].minDays.mul(5)){
                return lockedBalances[buyer].totalAirdrop * unlockPeriod[i].feePercent / 100;
            }
        }
        return 0;
    }

    /**
        Unlock WCT after each 3 weeks
     */
    function unlockWCT(address buyer) external {
        require(unlockStatus, "unlockWCT: Unlock is not available now.");
        uint256 unlock = _unlockAmount(buyer);
        uint256 amount = unlock - lockedBalances[buyer].unlockedAmount;
        require(amount > 0, "unlockWCT: No tokens to unlock.");
        require(WCTTokenAddress.balanceOf(address(this)) > amount, "unlockWCT: insufficient tokens.");
        
        lockedBalances[buyer].unlockedAmount = unlock;
        
        WCTTokenAddress.transfer(buyer, amount);
        emit UnlockWCT(buyer, amount);
    }
    
    /**
        Get UnlockedAmount information of specify address
     */
    function userBalances(address buyer) external view returns (uint256, uint256, uint256){
        uint256 pendingUnlock = _unlockAmount(buyer) - lockedBalances[buyer].unlockedAmount;
        return (lockedBalances[buyer].totalAirdrop, lockedBalances[buyer].unlockedAmount, pendingUnlock);
    }

    function _addBalance(address receiver, uint256 amountWCT) internal {
        require(receiver != address(0) && amountWCT > 0, "_addBalance: invalid input");
        lockedBalances[receiver].totalAirdrop += amountWCT;
    }

    function _resetBalance(address receiver) internal {
        require(receiver != address(0), "_resetBalance: invalid input");
        lockedBalances[receiver].totalAirdrop = 0;
    }

    function _USDT2WCT(uint256 amountUSDT) internal view returns (uint256){
        return amountUSDT * unitWCT / unitUSDT;
    }

    function _TCT2WCT(uint256 amountTCT) internal view returns (uint256){
        return amountTCT * unitSwapWCT / unitSwapTCT;
    }

    /**
        Swap from TCT Token to WCT.
     */
    function SwapWithTCT(address buyer, uint256 amountTCT) public {
        require(TCT2WCT == true, "SwapWithTCT: Convert TCT to WCT not enabled");
        require(presaleStatus == true, "SwapWithTCT: PreSale not available");
        require(amountTCT <= TCTTokenAddress.balanceOf(buyer), "SwapWithTCT: insufficient TCT Token.");

        uint256 amountWCT = _TCT2WCT(amountTCT);
        _addBalance(buyer, amountWCT);

        TCTTokenAddress.transferFrom(buyer, address(this), amountTCT);
        
        emit TCTSwap(buyer, amountWCT, amountTCT);
    }

    /**
        Buy token by Whitelist member
     */
    function buyForWhitelist(uint256 amountUSDT) public {
        require(presaleStatus == true, "buyForWhitelist: PreSale not available");
        require(amountUSDT > 0, "buyForWhitelist: invalid amount of USDT");
        require(verifyWhitelistAddress(msg.sender), "buyForWhitelist: not whitelisted user");
        require(USDTAddress.balanceOf(msg.sender) >= amountUSDT, "buyForWhitelist: insufficient tokens amount");

        uint256 amountWCT = _USDT2WCT(amountUSDT);
        _addBalance(msg.sender, amountWCT);

        USDTAddress.transferFrom(msg.sender, address(this), amountUSDT);

        emit WhitelistBuy(msg.sender, amountUSDT, amountWCT);
    }

    /**
        Buy WCT tokens with USDT if buyer has starterDecks.
     */
    function buyForStarterDeck(address buyer, uint256 amountUSDT) external {
        require(presaleStatus == true, "buyForStarterDeck: PreSale not available");
        uint256 amountWASToken = WASTokenAddress.balanceOf(buyer);
        uint256 amountWCMSToken = WCMSTokenAddress.balanceOf(buyer);
        uint256 amountWCNSToken = WCNSTokenAddress.balanceOf(buyer);
        uint256 amountWMRSToken = WMRSTokenAddress.balanceOf(buyer);
        uint256 amountWUSToken = WUSTokenAddress.balanceOf(buyer);

        uint256 couterDeck = amountWASToken + amountWCMSToken + amountWCNSToken + amountWMRSToken + amountWUSToken;
        uint256 maxUSDT = unitUSDT * couterDeck * (10 ** 18);

        require(amountUSDT > 0 && amountUSDT <= maxUSDT, "buyForStarterDeck: insufficient deck tokens to buy wct");
        require(USDTAddress.balanceOf(buyer) >= amountUSDT, "buyForStarterDeck: insufficient USDT tokens.");

        uint256 amountWCT = _USDT2WCT(amountUSDT);
        _addBalance(msg.sender, amountWCT);

        USDTAddress.transferFrom(buyer, address(this), amountUSDT);
        
        emit StarterDeckBuy(buyer, amountUSDT, amountWCT);
    }

    /**
        Buy WCT tokens if has over billion TCT tokens
     */
    function buyForBillionaires(address buyer, uint256 amountUSDT) external {
        require(presaleStatus == true, "buyForBillionaires: PreSale not available");
        require(amountUSDT > 0, "buyForBillionaires: invalid amount of USDT");
        require(amountUSDT <= USDTAddress.balanceOf(buyer), "buyForBillionaires: insufficient amount of USDT");

        uint256 amountWCT = _USDT2WCT(amountUSDT);
        _addBalance(msg.sender, amountWCT);

        USDTAddress.transferFrom(buyer, address(this), amountUSDT);

        emit BillionairesBuy(buyer, amountUSDT, amountWCT);
    }

    /**
        Admin withdraw about USDT
     */
    function adminWithdrawUSDT(address receiver, uint256 amount) external onlyOwner {
        require(amount > 0, "adminWithdrawUSDT: insufficient amount");
        require(amount <= USDTAddress.balanceOf(address(this)), "adminWithdrawUSDT: insufficient amount");

        USDTAddress.transfer(receiver, amount);

        emit AdminWithdrawUSDT(receiver, amount);
    }

    /**
        Admin withdraw about swapTCT
     */
    function adminWithdrawTCT(address receiver, uint256 amount) external onlyOwner {
        require(amount <= TCTTokenAddress.balanceOf(address(this)), "adminWithdrawTCT: insufficient amount");

        TCTTokenAddress.transfer(receiver, amount);

        emit AdminWithdrawTCT(receiver, amount);
    }

    /**
        Admin deposit wct
     */
    function adminDepositWCT(uint256 amount) external onlyOwner {
        require(amount <= WCTTokenAddress.balanceOf(address(msg.sender)), "adminDepositWCT: insufficient amount");

        WCTTokenAddress.transferFrom(msg.sender, address(this), amount);

        emit AdminDepositWCT(amount);
    }

    /**
        Admin withdraw wct
     */
    function adminWithdrawWCT(address receiver, uint256 amount) external onlyOwner {
        require(amount <= WCTTokenAddress.balanceOf(address(this)), "adminWithdrawWCT: insufficient amount");

        WCTTokenAddress.transfer(receiver, amount);

        emit AdminWithdrawWCT(receiver, amount);
    }

    /**
        Admin force WCT tokens to lockedBalance of specific address
     */
    function _airdrop(address receiver, uint256 amountWCT) internal {
        require(amountWCT > 0, "admin Airdrop: invalid amount");

        _addBalance(receiver, amountWCT);
        
        emit AirDrop(receiver, amountWCT);
    }

    /**
        Admin force WCT tokens to lockedBalance of specific address
     */
    function adminAirdrop(address[] calldata receivers, uint256[] calldata amounts) external onlyOwner {
        require(receivers.length == amounts.length, "admin Airdrop: mismatching count of address and amount");
        for(uint i = 0; i < receivers.length; i ++){
            require(receivers[i] != address(0) && amounts[i] > 0, "admin Airdrop: invalid address or amount");
        }

        for(uint i = 0; i < receivers.length; i ++){
            _airdrop(receivers[i], amounts[i]);
        }
    }

    /**
        Admin force reset lockedBalance of specific address
     */
    function adminReset(address[] calldata receivers) external onlyOwner {
        for(uint i = 0; i < receivers.length; i ++){
            require(receivers[i] != address(0), "admin Reset: invalid address");
        }

        for(uint i = 0; i < receivers.length; i ++){
            _resetBalance(receivers[i]);
        }
    }
}