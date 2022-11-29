/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

library SafeMath {
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() public {
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
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract IMAidrop is Ownable {
    using SafeMath for uint256;

    bool public active;

    IERC20 public internetMoney;
    uint256 public internetMoneyDecimal;

    uint256 public airdropAmount;
    uint256 public imUSDValue;
    uint256 public imUSDValueDecimals;

    uint256 public cryptoUSDValue;
    uint256 public cryptoUSDValueDecimals;

    mapping(address => bool) public addressVerified;
    mapping(bytes32 => address) private mobileLinkedAddress;

    uint256 public extraBonusPercentage;

    // Stats
    uint256 public totalAirdropAmountInTokens;
    uint256 public totalAirdropAmountInCrypto;

    uint256 public totalClaimedAirdropAmountInTokens;

    uint256 public referrerAmount;

    struct Referrer {
        uint256 claimedIndex;
        uint256 referrerClaimedEarnings;
        uint256 referrerTotalEarnings;
        uint256[] referralAmounts;
        uint256[] referralTimestamps;
    }

    event Airdrop(address indexed to, bool indexed referred, uint256 airdropAmount, uint256 ethValue);

    event ClaimRewards(address indexed from, uint256 rewardAmount);

    event SetAirdropAmount(uint256 newAirDropAmount);

    event SetCryptoUSDValue(uint256 newCryptoUSDValue);

    event SetIMUSDValue(uint256 newIMUSDValue);

    event SetInternetMoneyDecimal(uint256 newInternetMoneyDecimal);

    mapping(address => Referrer) public referrerDetails;

    mapping(address => bool) private aidropPerformer;
    mapping(address => bool) private mobileLinkedDataAccess;

    uint256 public airdropCount;
    uint256 public maxLimitAirdropCount;

    constructor(
        address _internetMoney,
        uint256 _internetMoneyDecimal,
        uint256 _maxLimitReferralCount,
        uint256 _extraBonusPercentage,
        uint256 _IM_USDValue,
        uint256 _cryptoUSDValue
    ) public {
        internetMoney = IERC20(_internetMoney);
        airdropAmount = 45000000 * (10**_internetMoneyDecimal);
        referrerAmount = 45000000 * (10**_internetMoneyDecimal);
        imUSDValue = _IM_USDValue;
        imUSDValueDecimals = 100;
        cryptoUSDValue = _cryptoUSDValue;
        cryptoUSDValueDecimals = 100;
        maxLimitAirdropCount = _maxLimitReferralCount;
        internetMoneyDecimal = _internetMoneyDecimal;
        extraBonusPercentage = _extraBonusPercentage;
        active = true;
    }

    receive() external payable {}

    modifier checkLimit() {
        require(airdropCount + 1 <= maxLimitAirdropCount, "Airdrop: Max Limit Reached");
        _;
    }

    modifier onlyAidropPerformer(address performer) {
        require(aidropPerformer[performer] || owner() == performer, "Airdrop: Permission Failed!");
        _;
    }

    modifier notPaused() {
        require(address(internetMoney) != address(0), "Airdrop: Internet Money Token not assigned");
        require(active, "Airdrop: Paused!");
        _;
    }

    modifier validReferrer(address _referrerAddress) {
        require(_referrerAddress == address(0) || addressVerified[_referrerAddress], "Airdrop: Not a valid referrer");
        _;
    }

    modifier eligibility(bytes32 _hash, address _to) {
        require(!addressVerified[_to] && mobileLinkedAddress[_hash]==address(0), "Airdrop: NOT Eligible!");
        _;
    }

    modifier checkBalance(uint256 calAirdropAmount, uint256 calCryptoAmount) {
        require(
            internetMoney.balanceOf(address(this)) >= calAirdropAmount,
            "Airdrop: Insufficient Token Balance in Treasury!"
        );
        require(address(this).balance >= calCryptoAmount, "Airdrop: Insufficient Crypto Balance in Treasury!");
        _;
    }

    function performAirdrop(
        address _to,
        address _referrerAddress,
        bytes32 _hash,
        uint256 calAirdropAmount,
        uint256 calCryptoAmount
    )
        external
        onlyAidropPerformer(msg.sender)
        checkLimit
        notPaused
        validReferrer(_referrerAddress)
        eligibility(_hash, _to)
        checkBalance(calAirdropAmount, calCryptoAmount)
    {
        require(_to != address(0), "Airdrop: _to cannot be zero address");

        uint256 referredBonus = 0;
        uint256 referredAirdropAmount = 0;

        if (_referrerAddress!=address(0)) {
            referrerDetails[_referrerAddress].referralAmounts.push(calAirdropAmount);
            referrerDetails[_referrerAddress].referralTimestamps.push(block.timestamp);
            referredAirdropAmount = calAirdropAmount < referrerAmount ? 
            calAirdropAmount
            : referrerAmount;
            referrerDetails[_referrerAddress].referrerTotalEarnings += referredAirdropAmount;
            referredBonus = extraBonusPercentage;
        }

        calAirdropAmount = calAirdropAmount.mul(100 + referredBonus).div(100);

        addressVerified[_to] = true;
        mobileLinkedAddress[_hash] = _to;

        totalAirdropAmountInTokens += calAirdropAmount + referredAirdropAmount;
        totalAirdropAmountInCrypto += calCryptoAmount;
        totalClaimedAirdropAmountInTokens += calAirdropAmount;

        airdropCount += 1;

        require(internetMoney.transfer(_to, calAirdropAmount), "Airdrop: Failed to transfer tokens");
        payable(_to).transfer(calCryptoAmount);

        emit Airdrop(_to, _referrerAddress!=address(0), calAirdropAmount, calCryptoAmount);
    }

    function setAirdropAmount(uint256 _amount) external onlyOwner {
        airdropAmount = _amount.mul(10**internetMoneyDecimal);

        emit SetAirdropAmount(airdropAmount);
    }

    function setMaxLimitAirdropCount(uint256 _maxLimitAirdropCount) external onlyOwner {
        require(
            maxLimitAirdropCount < _maxLimitAirdropCount,
            "Airdrop: Max Limit should be greater than current Limit"
        );

        maxLimitAirdropCount = _maxLimitAirdropCount;
    }

    function setExtraBonusPercentage(uint256 _percentage) external onlyOwner {
        require(_percentage <= 100, "Airdrop: Invalid Percentage - Greater than 100");
        extraBonusPercentage = _percentage;
    }

    function setAidropPerformer(address _performer, bool _status) external onlyOwner {
        aidropPerformer[_performer] = _status;
    }

    function setMobileLinkedDataAccess(address _signer, bool _status) external onlyOwner {
        mobileLinkedDataAccess[_signer] = _status;
    }

    function setReferrerAmount(uint256 _referrerAmount) external onlyOwner {
        referrerAmount = _referrerAmount.mul(10**internetMoneyDecimal);
    }

    // cryptoUSDValue units in Cents
    function set_CryptoUSDValue(uint256 _usdValueInCents) external onlyOwner {
        cryptoUSDValue = _usdValueInCents;

        emit SetCryptoUSDValue(_usdValueInCents);
    }

    function set_IM_USDValue(uint256 _usdValueInCents) external onlyOwner {
        imUSDValue = _usdValueInCents;

        emit SetIMUSDValue(_usdValueInCents);
    }

    function setInternetMoneyToken(address _tokenAddress) external onlyOwner {
        internetMoney = IERC20(_tokenAddress);
    }

    function setInternetMoneyDecimal(uint256 _decimal) external onlyOwner {
        internetMoneyDecimal = _decimal;

        emit SetInternetMoneyDecimal(_decimal);
    }

    function pauseAirdrop(bool _status) external onlyOwner {
        active = _status;
    }

    function checkMobileNumber(bytes32 _hash) external view returns (bool) {
        return mobileLinkedAddress[_hash]!=address(0);
    }

    function getReferrerDetails(address _referrerAddress)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256[] memory,
            uint256[] memory
        )
    {
        return (
            referrerDetails[_referrerAddress].claimedIndex,
            referrerDetails[_referrerAddress].referrerClaimedEarnings,
            referrerDetails[_referrerAddress].referrerTotalEarnings,
            referrerDetails[_referrerAddress].referralAmounts,
            referrerDetails[_referrerAddress].referralTimestamps
        );
    }

    function getReferralEarningsOf(address _referrerAddress) public view returns (uint256) {
        return
            referrerDetails[_referrerAddress].referrerTotalEarnings -
            referrerDetails[_referrerAddress].referrerClaimedEarnings;
    }

    function claimEarnings(address _referrerAddress) validReferrer(_referrerAddress) external {
        uint256 claimAmount = getReferralEarningsOf(_referrerAddress);

        require(
            claimAmount > 0 && claimAmount <= internetMoney.balanceOf(address(this)),
            "Airdrop: No More Rewards Earned to claim"
        );

        referrerDetails[_referrerAddress].referrerClaimedEarnings += claimAmount;
        referrerDetails[_referrerAddress].claimedIndex = referrerDetails[_referrerAddress].referralAmounts.length;
        totalClaimedAirdropAmountInTokens += claimAmount;

        require(internetMoney.transfer(_referrerAddress, claimAmount), "Airdrop: Failed to transfer tokens");

        emit ClaimRewards(_referrerAddress, claimAmount);
    }

    function cryptoBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getAmountDetails()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            uint256
        )
    {
        return (
            airdropAmount,
            imUSDValue,
            imUSDValueDecimals,
            cryptoUSDValue,
            cryptoUSDValueDecimals,
            address(internetMoney),
            internetMoneyDecimal,
            referrerAmount
        );
    }

    function withdrawCrypto(address _toAddress) external onlyOwner {
        require(_toAddress != address(0), "Airdrop: recipient address cannot be zero address");
        payable(_toAddress).transfer(address(this).balance);
    }

    function withdrawToken(address _tokenAddress, address _toAddress) external onlyOwner {
        require(
            IERC20(_tokenAddress).transfer(_toAddress, IERC20(_tokenAddress).balanceOf(address(this))),
            "Airdrop: Failed to transfer tokens"
        );
    }

    function isLimitReached() external view returns (bool) {
        return airdropCount > maxLimitAirdropCount;
    }

    function getTotalYetToBeClaimedTokenBalance() external view returns (uint256) {
        return totalAirdropAmountInTokens - totalClaimedAirdropAmountInTokens;
    }

    function getMessageHash(
        bytes32 _hash 
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_hash));
    }

    function verifyMessage(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) private pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer;
    }

    function getCheckMobileHashWithSignature (bytes32 mobileHash, uint8 _v, bytes32 _r, bytes32 _s) external view returns(address){
        address signer = verifyMessage(getMessageHash(mobileHash), _v, _r, _s);
        require(owner() == signer || mobileLinkedDataAccess[signer], "Airdrop: Access Denied!");
        return mobileLinkedAddress[mobileHash];
    }
}