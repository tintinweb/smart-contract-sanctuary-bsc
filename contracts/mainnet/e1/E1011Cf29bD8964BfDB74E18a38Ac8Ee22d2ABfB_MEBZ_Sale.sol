// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
interface IErc20Contract {
    function transferSale(address recipient, uint256 amount)
        external
        returns (bool);
}

contract MEBZ_Sale {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter public saleCounter;
    uint256 public _saleAmountCap = uint256(90000000 * 1 ether);
    uint256 public _minimumPurchaseBNBAmount = 0.14 ether; // 0.000084 BNB per token
    uint256 public _maximumPurchaseBNBAmount = 7 ether;

    uint256 public _bnbAmountCap = 7560 ether;
    uint256 public _tokenValuePerBNB = 11905;

    uint256 public _saleDateStarts = 1658102400; //July_18_2022
    uint256 public _saleDateEnds = 1659312000; //August_1_2022

    //Token Vesting Status
    bool public openVesting1=false;

    bool public _isSaleOpen=false; //Sale Sale Status

    address payable public _admin; //Administrator
    address payable public _whitelistManager; //Whitelist Manager
    address public _erc20Contract; //MTBZ Token Smart Contract

    uint256 public _totalAddressesPurchaseAmount; //Total Purchased Amount

    uint256 public _startPurchaseAddressIndex; //Puchaser Counter
    uint256 public _purchaseAddressesNumber; //Index of Purchaser
    mapping(uint256 => address) public _purchaseAddresses; //Map of Purchasers
    mapping(address => bool) public _purchaseAddressesStatus; //Status if whitelisted
    mapping(address => uint256) public _purchaseAddressesBNBAmount; //Map of BNB Purchased per Address

    mapping(address => uint256) public _purchaseAddressesAwardedTotalErc20CoinAmount; //Map of Token Purchased per Address
    mapping(address => uint256) public _purchaseAddressesClaimableErc20CoinAmount; //Map of Claimable Token Purchased per Address

    struct vest {
        uint256 id;
        address walletAddress;
        uint256 createdAt; 
        uint256 claimedAt;
        uint256 tokenAmount;
        bool isClaimed;
    }

    uint256 vestCounter;

    //Map of Vestings
    mapping(address => vest) public vestings1;

    constructor() {
        _admin = payable(msg.sender);
        _whitelistManager = payable(msg.sender);
    }

    // Modifier
    modifier onlyAdmin() {
        require(_admin == msg.sender);
        _;
    }
    modifier isWhiteListManager() {
        require(_admin == msg.sender || _whitelistManager == msg.sender);
        _;
    }

    event Purchase(address indexed _from, uint256 _value);

    // Transfer owernship
    function transferOwnership(address payable admin) public onlyAdmin {
        require(admin != address(0), "Zero address");
        _admin = admin;
    }

    // Transfer Whitelist Manager Ownership
    function transferWhiteListOwnership(address payable acct)
        public
        isWhiteListManager
    {
        require(acct != address(0), "Zero address");
        _whitelistManager = acct;
    }

    // Add purchase addresses and whitelist thems
    function addPurchaseAddress(address[] calldata purchaseAddresses)
        external
        isWhiteListManager
    {
        uint256 purchaseAddressesNumber = _purchaseAddressesNumber;
        for (uint256 i = 0; i < purchaseAddresses.length; i++) {
            if (!_purchaseAddressesStatus[purchaseAddresses[i]]) {
                _purchaseAddresses[purchaseAddressesNumber] = purchaseAddresses[i];
                _purchaseAddressesStatus[purchaseAddresses[i]] = true;
                purchaseAddressesNumber++;
            }
        }
        _purchaseAddressesNumber = purchaseAddressesNumber;
    }

    // Remove Address from whitelist
    function removePurchaseAddress(address walletAddress)
        external
        isWhiteListManager
    {
        _purchaseAddressesStatus[walletAddress] = false;
    }

    // Remove purchase addresses and unwhitelist them
    // number - number of addresses to process at once
    function removeAllPurchaseAddress(uint256 number)
        external
        isWhiteListManager
    {
        require(
            block.timestamp < _saleDateStarts,
            "Sale already started"
        );
        uint256 i = _startPurchaseAddressIndex;
        uint256 last = i + number;
        if (last > _purchaseAddressesNumber) last = _purchaseAddressesNumber;
        for (; i < last; i++) {
            _purchaseAddressesStatus[_purchaseAddresses[i]] = false;
            _purchaseAddresses[i] = address(0);
        }
        _startPurchaseAddressIndex = i;
    }

    // Receive BNB purchase
    function _purchase() external payable {
        require(_isSaleOpen, "Sale is not yet open!");
        require(block.timestamp >= _saleDateStarts && block.timestamp <= _saleDateEnds, "Purchase rejected, sale has either not yet started or not yet over");
        require(_totalAddressesPurchaseAmount < _bnbAmountCap,"Purchase rejected, already reached the cap amount");
        require(msg.value >= _minimumPurchaseBNBAmount,"Purchase rejected, it is lesser than minimum amount");
        require(msg.value <= _maximumPurchaseBNBAmount,"Purchase rejected, it is more than maximum amount");
        require(_purchaseAddressesBNBAmount[msg.sender].add(msg.value) <=_maximumPurchaseBNBAmount,"Purchase rejected, every address cannot purchase more than maximum purchase limit");

        if (_totalAddressesPurchaseAmount.add(msg.value) > _bnbAmountCap) {
            if (_purchaseAddressesBNBAmount[msg.sender] == 0) {

                uint256 _id = saleCounter.current();
                address _walletAddress = msg.sender;
                uint256 _createdAt = block.timestamp;
                uint256 _claimedAt;
                uint256 _tokenAmount = 0;
                bool _isClaimed = false;

                vest memory newVest = vest(_id,_walletAddress,_createdAt,_claimedAt,_tokenAmount,_isClaimed);
                vestings1[msg.sender] = newVest;
                saleCounter.increment();
            }

            // If total purchase + purchase greater than bnb cap amount
            uint256 value = _bnbAmountCap.sub(_totalAddressesPurchaseAmount);
            _purchaseAddressesBNBAmount[msg.sender] = _purchaseAddressesBNBAmount[msg.sender].add(value);
            _totalAddressesPurchaseAmount = _totalAddressesPurchaseAmount.add(value);
            payable(msg.sender).transfer(msg.value.sub(value)); // Transfer back extra BNB

            _purchaseAddressesAwardedTotalErc20CoinAmount[msg.sender] = _purchaseAddressesAwardedTotalErc20CoinAmount[msg.sender].add(
                value.mul(_tokenValuePerBNB));
            
            _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].add(
                value.mul(_tokenValuePerBNB));

            _saleAmountCap = _saleAmountCap.sub(value.mul(_tokenValuePerBNB));
            emit Purchase(msg.sender, value);
        } else {
            if (_purchaseAddressesBNBAmount[msg.sender] == 0) {

                uint256 _id = saleCounter.current();
                address _walletAddress = msg.sender;
                uint256 _createdAt = block.timestamp;
                uint256 _claimedAt;
                uint256 _tokenAmount = 0;
                bool _isClaimed = false;

                vest memory newVest = vest(_id,_walletAddress,_createdAt,_claimedAt,_tokenAmount,_isClaimed);
                vestings1[msg.sender] = newVest;
                saleCounter.increment();
            }

            _purchaseAddressesBNBAmount[msg.sender] = _purchaseAddressesBNBAmount[msg.sender].add(msg.value);
            _totalAddressesPurchaseAmount = _totalAddressesPurchaseAmount.add(msg.value);
            _purchaseAddressesAwardedTotalErc20CoinAmount[msg.sender] = _purchaseAddressesAwardedTotalErc20CoinAmount[msg.sender].add(
                msg.value.mul(_tokenValuePerBNB));
            _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].add(
                msg.value.mul(_tokenValuePerBNB));

            _saleAmountCap = _saleAmountCap.sub(msg.value.mul(_tokenValuePerBNB));
            emit Purchase(msg.sender, msg.value);
        }
    }

    //Claim 1st Vesting
    function claimVesting1() external returns (vest memory) {
        require(openVesting1, "Claiming is not yet open!");
        require(!vestings1[msg.sender].isClaimed, "Token already claimed!");
        require(vestings1[msg.sender].walletAddress == msg.sender,"Claimant does not match");
        require(_purchaseAddressesClaimableErc20CoinAmount[msg.sender] >0, "No token to withdraw!");

        uint256 _tokenAmount = _purchaseAddressesBNBAmount[msg.sender].mul(_tokenValuePerBNB);
        _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].sub(
            _tokenAmount
        );

        vestings1[msg.sender].claimedAt = block.timestamp;
        vestings1[msg.sender].tokenAmount = _tokenAmount;
        vestings1[msg.sender].isClaimed = true;

        IErc20Contract erc20Contract = IErc20Contract(_erc20Contract);
        erc20Contract.transferSale(msg.sender, _tokenAmount);

        return vestings1[msg.sender];
    }

    //Retreive address vestings
    function getVestingDetails() public view returns( vest memory v1){
        return (vestings1[msg.sender]);
    }

    // Setters

    // Set Sale Sale Status
    function _setIsSaleOpen() external onlyAdmin {
        _isSaleOpen = !_isSaleOpen;
    }

    //Set Start of Sale 
    function _setSaleDateStarts(uint256 newDate) external onlyAdmin {
        _saleDateStarts = newDate;
    }

    //Set End of Sale 
    function _setSaleDateEnds(uint256 newDate) external onlyAdmin {
        _saleDateEnds = newDate;
    }

    //Set MTBZ Token Contract Address
    function _setTokenContractAddress(address contractAddress)
        external
        onlyAdmin
    {
        _erc20Contract = contractAddress;
    }

    //Set Vesting Status
    function _setVestingStatus1() external onlyAdmin {
        openVesting1 = !openVesting1;
    }
   
    //Fetch Data
    function getWhitelisted() public view returns (address[] memory) {
        address[] memory result = new address[](_purchaseAddressesNumber);
        for (uint256 i = 0; i < _purchaseAddressesNumber; i++) {
            address listed = _purchaseAddresses[i];
            result[i] = listed;
        }
        return result;
    }
    
    // Allow admin to withdraw all the deposited BNB
    function withdrawAll() external onlyAdmin {
        _admin.transfer(address(this).balance);
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}