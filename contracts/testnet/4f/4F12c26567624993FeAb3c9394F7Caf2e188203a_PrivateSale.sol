// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IErc20Contract {
    function transferPrivateSale(address recipient, uint256 amount) external returns (bool);
}

contract PrivateSale {

    using SafeMath for uint256;

    uint256 public _privateSaleAmountCap = uint256(12500000 * 1 ether);
    uint256 public _minimumPurchaseBNBAmount = 5 ether;
    uint256 public _maximumPurchaseBNBAmount = 50 ether;

    uint256 public _bnbAmountCap = 406.8375 ether; 
    uint256 public _tokenValuePerBNB = 30725;

    uint256 public _privateSaleDateStarts = 1650412800; //April_20_2022
    uint256 public _privateSaleDateEnds = 1651276800; //April_30_2022

    //Token Vesting Status
    bool public openVesting1 = false;
    bool public openVesting2 = false;
    bool public openVesting3 = false;
    bool public openVesting4 = false;
    bool public openVesting5 = false;
    bool public openVesting6 = false;
    bool public openVesting7 = false;
    bool public openVesting8 = false;
    bool public openVesting9 = false;
    bool public openVesting10 = false;

    bool public _isPrivateSaleOpen = false; //Private Sale Status

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
    mapping(address => vest) public vestings2;
    mapping(address => vest) public vestings3;
    mapping(address => vest) public vestings4;
    mapping(address => vest) public vestings5;
    mapping(address => vest) public vestings6;
    mapping(address => vest) public vestings7;
    mapping(address => vest) public vestings8;
    mapping(address => vest) public vestings9;
    mapping(address => vest) public vestings10;

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
    function transferWhiteListOwnership(address acct)
        public
        isWhiteListManager
    {
        require(acct != address(0), "Zero address");
        _whitelistManager = payable(acct);
    }

    // Add purchase addresses and whitelist them
    function addPurchaseAddress(address[] calldata purchaseAddresses)
        external
        isWhiteListManager
    {
        uint256 purchaseAddressesNumber = _purchaseAddressesNumber;
        for (uint256 i = 0; i < purchaseAddresses.length; i++) {
            if (!_purchaseAddressesStatus[purchaseAddresses[i]]) {
                _purchaseAddresses[purchaseAddressesNumber] = purchaseAddresses[
                    i
                ];
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
            block.timestamp < _privateSaleDateStarts,
            "Privatesale already started"
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
        require(_isPrivateSaleOpen, "Privatesale is not yet open!");
        require(block.timestamp >= _privateSaleDateStarts && block.timestamp <= _privateSaleDateEnds,"Purchase rejected, presale has either not yet started or not yet overed");
        require(_purchaseAddressesStatus[msg.sender],"Purchase rejected, purchase address is not yet whitelisted");
        require(_totalAddressesPurchaseAmount < _bnbAmountCap,"Purchase rejected, already reached the cap amount");
        require(msg.value >= _minimumPurchaseBNBAmount,"Purchase rejected, it is lesser than minimum amount");
        require(msg.value <= _maximumPurchaseBNBAmount,"Purchase rejected, it is more than maximum amount");
        require(_purchaseAddressesBNBAmount[msg.sender].add(msg.value) <=_maximumPurchaseBNBAmount,"Purchase rejected, every address cannot purchase more than 50 bnb");

        if (_totalAddressesPurchaseAmount.add(msg.value) > _bnbAmountCap) {
            if (_purchaseAddressesBNBAmount[msg.sender] == 0) {
                uint256 _id = vestCounter;
                address _walletAddress = msg.sender;
                uint256 _createdAt = block.timestamp;
                uint256 _claimedAt;
                uint256 _tokenAmount = 0;
                bool _isClaimed = false;

                vest memory newVest = vest(_id,_walletAddress,_createdAt,_claimedAt,_tokenAmount,_isClaimed);

                vestings1[msg.sender] = newVest;
                vestings2[msg.sender] = newVest;
                vestings3[msg.sender] = newVest;
                vestings4[msg.sender] = newVest;
                vestings5[msg.sender] = newVest;
                vestings6[msg.sender] = newVest;
                vestings7[msg.sender] = newVest;
                vestings8[msg.sender] = newVest;
                vestings9[msg.sender] = newVest;
                vestings10[msg.sender] = newVest;

                vestCounter++;
            }

            // If total purchase + purchase greater than bnb cap amount
            uint256 value = _bnbAmountCap.sub(_totalAddressesPurchaseAmount);
            _purchaseAddressesBNBAmount[msg.sender] = _purchaseAddressesBNBAmount[msg.sender].add(value);
            _totalAddressesPurchaseAmount = _totalAddressesPurchaseAmount.add(value);
            payable(msg.sender).transfer(msg.value.sub(value)); // Transfer back extra BNB

            _purchaseAddressesAwardedTotalErc20CoinAmount[msg.sender] = _purchaseAddressesAwardedTotalErc20CoinAmount[msg.sender].add(
                value.mul(_tokenValuePerBNB)
            );
            _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].add(
                value.mul(_tokenValuePerBNB)
            );

            _privateSaleAmountCap = _privateSaleAmountCap.sub(value.mul(_tokenValuePerBNB));
            emit Purchase(msg.sender, value);

        } else {
            if (_purchaseAddressesBNBAmount[msg.sender] == 0) {
                uint256 _id = vestCounter;
                address _walletAddress = msg.sender;
                uint256 _createdAt = block.timestamp;
                uint256 _claimedAt;
                uint256 _tokenAmount = 0;
                bool _isClaimed = false;

                vest memory newVest = vest(_id,_walletAddress,_createdAt,_claimedAt,_tokenAmount,_isClaimed);

                vestings1[msg.sender] = newVest;
                vestings2[msg.sender] = newVest;
                vestings3[msg.sender] = newVest;
                vestings4[msg.sender] = newVest;
                vestings5[msg.sender] = newVest;
                vestings6[msg.sender] = newVest;
                vestings7[msg.sender] = newVest;
                vestings8[msg.sender] = newVest;
                vestings9[msg.sender] = newVest;
                vestings10[msg.sender] = newVest;

                vestCounter++;
            }

            _purchaseAddressesBNBAmount[msg.sender] = _purchaseAddressesBNBAmount[msg.sender].add(msg.value);
            _totalAddressesPurchaseAmount = _totalAddressesPurchaseAmount.add(msg.value);
            _purchaseAddressesAwardedTotalErc20CoinAmount[msg.sender] = _purchaseAddressesAwardedTotalErc20CoinAmount[msg.sender].add(
                msg.value.mul(_tokenValuePerBNB)
            );
            _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].add(
                msg.value.mul(_tokenValuePerBNB)
            );

            _privateSaleAmountCap = _privateSaleAmountCap.sub(msg.value.mul(_tokenValuePerBNB));

            emit Purchase(msg.sender, msg.value);
        }
    }

    //Claim 1st Vesting
    function claimVesting1() external returns (vest memory) {
        require(openVesting1, "Claiming is not yet open!");
        require(_purchaseAddressesStatus[msg.sender],"Purchase rejected, wallet address is not yet whitelisted");
        require(!vestings1[msg.sender].isClaimed, "Token already claimed!");
        require(vestings1[msg.sender].walletAddress == msg.sender,"Claimant does not match");

        uint256 _tokenAmount = _purchaseAddressesBNBAmount[msg.sender].mul( _tokenValuePerBNB);
        _tokenAmount = _tokenAmount.div(10);
        _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].sub(_tokenAmount);

        vestings1[msg.sender].claimedAt = block.timestamp;
        vestings1[msg.sender].tokenAmount = _tokenAmount;
        vestings1[msg.sender].isClaimed = true;

        IErc20Contract erc20Contract = IErc20Contract(_erc20Contract);
        erc20Contract.transferPrivateSale(msg.sender, _tokenAmount);

        return vestings1[msg.sender];
    }

    //Claim 2nd Vesting
    function claimVesting2() external returns (vest memory) {
        require(openVesting2, "Claiming is not yet open!");
        require(_purchaseAddressesStatus[msg.sender],"Purchase rejected, wallet address is not yet whitelisted");
        require(!vestings2[msg.sender].isClaimed, "Token already claimed!");
        require(vestings2[msg.sender].walletAddress == msg.sender,"Claimant does not match");

        uint256 _tokenAmount = _purchaseAddressesBNBAmount[msg.sender].mul(_tokenValuePerBNB);
        _tokenAmount = _tokenAmount.div(10);
        _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].sub(_tokenAmount);

        vestings2[msg.sender].claimedAt = block.timestamp;
        vestings2[msg.sender].tokenAmount = _tokenAmount;
        vestings2[msg.sender].isClaimed = true;

        IErc20Contract erc20Contract = IErc20Contract(_erc20Contract);
        erc20Contract.transferPrivateSale(msg.sender, _tokenAmount);

        return vestings2[msg.sender];
    }

    //Claim 3rd Vesting
    function claimVesting3() external returns (vest memory) {
        require(openVesting3, "Claiming is not yet open!");
        require(_purchaseAddressesStatus[msg.sender],"Purchase rejected, wallet address is not yet whitelisted");
        require(!vestings3[msg.sender].isClaimed, "Token already claimed!");
        require(vestings3[msg.sender].walletAddress == msg.sender,"Claimant does not match");

        uint256 _tokenAmount = _purchaseAddressesBNBAmount[msg.sender].mul(_tokenValuePerBNB);
        _tokenAmount = _tokenAmount.div(10);
        _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].sub(_tokenAmount);

        vestings3[msg.sender].claimedAt = block.timestamp;
        vestings3[msg.sender].tokenAmount = _tokenAmount;
        vestings3[msg.sender].isClaimed = true;

        IErc20Contract erc20Contract = IErc20Contract(_erc20Contract);
        erc20Contract.transferPrivateSale(msg.sender, _tokenAmount);

        return vestings3[msg.sender];
    }

    //Claim 4th Vesting
    function claimVesting4() external returns (vest memory) {
        require(openVesting4, "Claiming is not yet open!");
        require(_purchaseAddressesStatus[msg.sender],"Purchase rejected, wallet address is not yet whitelisted");
        require(!vestings4[msg.sender].isClaimed, "Token already claimed!");
        require(vestings4[msg.sender].walletAddress == msg.sender,"Claimant does not match");

        uint256 _tokenAmount = _purchaseAddressesBNBAmount[msg.sender].mul(_tokenValuePerBNB);
        _tokenAmount = _tokenAmount.div(10);
        _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].sub(_tokenAmount);

        vestings4[msg.sender].claimedAt = block.timestamp;
        vestings4[msg.sender].tokenAmount = _tokenAmount;
        vestings4[msg.sender].isClaimed = true;

        IErc20Contract erc20Contract = IErc20Contract(_erc20Contract);
        erc20Contract.transferPrivateSale(msg.sender, _tokenAmount);

        return vestings4[msg.sender];
    }

    //Claim 5th Vesting
    function claimVesting5() external returns (vest memory) {
        require(openVesting5, "Claiming is not yet open!");
        require(_purchaseAddressesStatus[msg.sender],"Purchase rejected, wallet address is not yet whitelisted");
        require(!vestings5[msg.sender].isClaimed, "Token already claimed!");
        require(vestings5[msg.sender].walletAddress == msg.sender,"Claimant does not match");

        uint256 _tokenAmount = _purchaseAddressesBNBAmount[msg.sender].mul(_tokenValuePerBNB);
        _tokenAmount = _tokenAmount.div(10);
        _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].sub(_tokenAmount);

        vestings5[msg.sender].claimedAt = block.timestamp;
        vestings5[msg.sender].tokenAmount = _tokenAmount;
        vestings5[msg.sender].isClaimed = true;

        IErc20Contract erc20Contract = IErc20Contract(_erc20Contract);
        erc20Contract.transferPrivateSale(msg.sender, _tokenAmount);

        return vestings5[msg.sender];
    }

    //Claim 6th Vesting
    function claimVesting6() external returns (vest memory) {
        require(openVesting6, "Claiming is not yet open!");
        require(_purchaseAddressesStatus[msg.sender],"Purchase rejected, wallet address is not yet whitelisted");
        require(!vestings6[msg.sender].isClaimed, "Token already claimed!");
        require(vestings6[msg.sender].walletAddress == msg.sender,"Claimant does not match");

        require(!vestings6[msg.sender].isClaimed, "Token already claimed!");

        uint256 _tokenAmount = _purchaseAddressesBNBAmount[msg.sender].mul(_tokenValuePerBNB);
        _tokenAmount = _tokenAmount.div(10);
        _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].sub(_tokenAmount);

        vestings6[msg.sender].claimedAt = block.timestamp;
        vestings6[msg.sender].tokenAmount = _tokenAmount;
        vestings6[msg.sender].isClaimed = true;

        IErc20Contract erc20Contract = IErc20Contract(_erc20Contract);
        erc20Contract.transferPrivateSale(msg.sender, _tokenAmount);

        return vestings6[msg.sender];
    }

    //Claim 8th Vesting
    function claimVesting7() external returns (vest memory) {
        require(openVesting7, "Claiming is not yet open!");
        require(_purchaseAddressesStatus[msg.sender],"Purchase rejected, wallet address is not yet whitelisted");
        require(!vestings7[msg.sender].isClaimed, "Token already claimed!");
        require(vestings7[msg.sender].walletAddress == msg.sender,"Claimant does not match");

        uint256 _tokenAmount = _purchaseAddressesBNBAmount[msg.sender].mul(_tokenValuePerBNB);
        _tokenAmount = _tokenAmount.div(10);
        _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].sub(_tokenAmount);

        vestings7[msg.sender].claimedAt = block.timestamp;
        vestings7[msg.sender].tokenAmount = _tokenAmount;
        vestings7[msg.sender].isClaimed = true;

        IErc20Contract erc20Contract = IErc20Contract(_erc20Contract);
        erc20Contract.transferPrivateSale(msg.sender, _tokenAmount);

        return vestings7[msg.sender];
    }

    function claimVesting8() external returns (vest memory) {
        require(openVesting8, "Claiming is not yet open!");
        require(_purchaseAddressesStatus[msg.sender],"Purchase rejected, wallet address is not yet whitelisted");
        require(!vestings8[msg.sender].isClaimed, "Token already claimed!");
        require(vestings8[msg.sender].walletAddress == msg.sender,"Claimant does not match");

        uint256 _tokenAmount = _purchaseAddressesBNBAmount[msg.sender].mul(_tokenValuePerBNB);
        _tokenAmount = _tokenAmount.div(10);
        _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].sub(_tokenAmount);

        vestings8[msg.sender].claimedAt = block.timestamp;
        vestings8[msg.sender].tokenAmount = _tokenAmount;
        vestings8[msg.sender].isClaimed = true;

        IErc20Contract erc20Contract = IErc20Contract(_erc20Contract);
        erc20Contract.transferPrivateSale(msg.sender, _tokenAmount);

        return vestings8[msg.sender];
    }

    //Claim 9th Vesting
    function claimVesting9() external returns (vest memory) {
        require(openVesting9, "Claiming is not yet open!");
        require(_purchaseAddressesStatus[msg.sender],"Purchase rejected, wallet address is not yet whitelisted");
        require(!vestings9[msg.sender].isClaimed, "Token already claimed!");
        require(vestings9[msg.sender].walletAddress == msg.sender,"Claimant does not match");

        uint256 _tokenAmount = _purchaseAddressesBNBAmount[msg.sender].mul(_tokenValuePerBNB);
        _tokenAmount = _tokenAmount.div(10);
        _purchaseAddressesClaimableErc20CoinAmount[ msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].sub(_tokenAmount);

        vestings9[msg.sender].claimedAt = block.timestamp;
        vestings9[msg.sender].tokenAmount = _tokenAmount;
        vestings9[msg.sender].isClaimed = true;

        IErc20Contract erc20Contract = IErc20Contract(_erc20Contract);
        erc20Contract.transferPrivateSale(msg.sender, _tokenAmount);

        return vestings9[msg.sender];
    }

    //Claim 10th Vesting
    function claimVesting10() external returns (vest memory) {
        require(openVesting10, "Claiming is not yet open!");
        require(_purchaseAddressesStatus[msg.sender],"Purchase rejected, wallet address is not yet whitelisted");
        require(!vestings10[msg.sender].isClaimed, "Token already claimed!");
        require(vestings10[msg.sender].walletAddress == msg.sender,"Claimant does not match");

        uint256 _tokenAmount = _purchaseAddressesBNBAmount[msg.sender].mul(
            _tokenValuePerBNB
        );
        _tokenAmount = _tokenAmount.div(10);
        _purchaseAddressesClaimableErc20CoinAmount[msg.sender] = _purchaseAddressesClaimableErc20CoinAmount[msg.sender].sub(_tokenAmount);

        vestings10[msg.sender].claimedAt = block.timestamp;
        vestings10[msg.sender].tokenAmount = _tokenAmount;
        vestings10[msg.sender].isClaimed = true;

        IErc20Contract erc20Contract = IErc20Contract(_erc20Contract);
        erc20Contract.transferPrivateSale(msg.sender, _tokenAmount);

        return vestings10[msg.sender];
    }

    //Retreive address vestings
    function getVestingDetails() public view returns( vest memory v1,vest memory v2,vest memory v3,vest memory v4,vest memory v5,vest memory v6,vest memory v7,vest memory v8,vest memory v9,vest memory v10){

        return (vestings1[msg.sender],vestings2[msg.sender],vestings3[msg.sender],vestings4[msg.sender],vestings5[msg.sender],vestings6[msg.sender],vestings7[msg.sender],vestings8[msg.sender],vestings9[msg.sender],vestings10[msg.sender]);
    }

    // Setters

    //Set MTBZ Token Contract Address
    function _setTokenContractAddress(address contractAddress)
        external
        onlyAdmin
    {
        _erc20Contract = contractAddress;
    }

    // Set Private Sale Status
    function _setIsPrivateSaleOpen() external onlyAdmin {
        _isPrivateSaleOpen = !_isPrivateSaleOpen;
    }

    //Set Start of PrivateSale 
    function _setPrivateSaleDateStarts(uint256 newDate) external onlyAdmin {
        _privateSaleDateStarts = newDate;
    }

    //Set End of PrivateSale 
    function _setPrivateSaleDateEnds(uint256 newDate) external onlyAdmin {
        _privateSaleDateEnds = newDate;
    }

    //Set Vesting Status
    function _setVestingStatus1() external onlyAdmin { //Set Vesting1 Status
        openVesting1 = !openVesting1;
    }

    function _setVestingStatus2() external onlyAdmin { //Set Vesting2 Status
        openVesting2 = !openVesting2;
    }

    function _setVestingStatus3() external onlyAdmin { //Set Vesting3 Status
        openVesting3 = !openVesting3;
    }

    function _setVestingStatus4() external onlyAdmin { //Set Vesting4 Status
        openVesting4 = !openVesting4;
    }

    function _setVestingStatus5() external onlyAdmin { //Set Vesting5 Status
        openVesting5 = !openVesting5;
    }

    function _setVestingStatus6() external onlyAdmin { //Set Vesting6 Status
        openVesting6 = !openVesting6;
    }

    function _setVestingStatus7() external onlyAdmin { //Set Vesting7 Status
        openVesting7 = !openVesting7;
    }

    function _setVestingStatus8() external onlyAdmin { //Set Vesting8 Status
        openVesting8 = !openVesting8;
    }

    function _setVestingStatus9() external onlyAdmin { //Set Vesting9 Status
        openVesting9 = !openVesting9;
    }

    function _setVestingStatus10() external onlyAdmin { //Set Vesting10 Status
        openVesting10 = !openVesting10;
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