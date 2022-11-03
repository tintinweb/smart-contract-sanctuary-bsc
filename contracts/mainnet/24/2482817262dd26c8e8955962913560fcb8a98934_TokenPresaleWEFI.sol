/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface ITokenVestingWEFI {
    function createVestingSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        uint256 _amount
    ) external;
}

contract TokenPresaleWEFI is Ownable, ReentrancyGuard {
    IERC20 public immutable tokenAddress;
    uint256 public tokenPriceInWei;
    uint8 private constant _tokenDecimals = 18;

    struct ReferrerInfo {
        uint256 headPromoterReferralCode;
        uint8 headPromoterCommissionPercentage;
        uint8 referrerCommissionPercentage;
        uint8 referralBonusPercentage;
    }

    mapping(uint256 => ReferrerInfo) private _referrerInfoList;
    mapping(uint256 => bool) private _whitelist;
    mapping(address => uint256) private _referralAddressToCode;
    mapping(uint256 => address) private _referralCodeToAddress;
    uint256 private _referralCodeCount = 10000;
    mapping(address => uint256) private _totalReferrerCommissionAmount;
    address private _topFirstReferrer;
    address private _topSecondReferrer;
    address private _topThirdReferrer;

    ITokenVestingWEFI public vestingContractAddress;
    uint256 private _buyerVestingCliff;
    uint256 private _buyerVestingStart;
    uint256 private _buyerVestingDuration;
    uint256 private _buyerVestingSlicePeriodSeconds;
    uint256 private _referrerAndHeadPromoterVestingCliff;
    uint256 private _referrerAndHeadPromoterVestingStart;
    uint256 private _referrerAndHeadPromoterVestingDuration;
    uint256 private _referrerAndHeadPromoterVestingSlicePeriodSeconds;

    event TokenSold(address, uint256);
    event TokenPriceChanged(uint256, uint256);
    event ReferralCodeGenerated(address, uint256);
    event ReferrerCommissionSent(address, uint256);
    event HeadPromoterCommissionSent(address, uint256);
    event BuyerVestingScheduleChanged(uint256, uint256, uint256, uint256);
    event ReferrerVestingScheduleChanged(uint256, uint256, uint256, uint256);
    event VestingContractAddressChanged(address, address);
    event ResetTopThreeReferrers(uint256);
    event ReferrerWhitelisted(uint256, uint256, uint8, uint8, uint8);
    event ReferrerBlacklisted(uint256);

    constructor(
        address _tokenAddress,
        uint256 _tokenPriceInWei,
        address _vestingContractAddress
    ) {
        require(
            _tokenAddress != address(0x0),
            "TokenPresaleWEFI: token contract address must not be null"
        );
        require(
            _vestingContractAddress != address(0x0),
            "TokenPresaleWEFI: vesting contract address must not be null"
        );
        tokenAddress = IERC20(_tokenAddress);
        tokenPriceInWei = _tokenPriceInWei;

        vestingContractAddress = ITokenVestingWEFI(_vestingContractAddress);
        _buyerVestingCliff = _buyerVestingStart = _buyerVestingDuration = _buyerVestingSlicePeriodSeconds = 1;
        _referrerAndHeadPromoterVestingCliff = _referrerAndHeadPromoterVestingStart = _referrerAndHeadPromoterVestingDuration = _referrerAndHeadPromoterVestingSlicePeriodSeconds = 1;
    }

    function generateReferralCode(address accountAddress)
        public
        returns (bool)
    {
        require(
            _referralAddressToCode[accountAddress] == 0,
            "TokenPresaleWEFI: referral code already generated"
        );

        _referralCodeCount += 7;
        _referralAddressToCode[accountAddress] = _referralCodeCount;
        _referralCodeToAddress[_referralCodeCount] = accountAddress;

        emit ReferralCodeGenerated(accountAddress, _referralCodeCount);
        return true;
    }

    function showReferralCode(address referrer)
        external
        view
        returns (uint256)
    {
        return _referralAddressToCode[referrer];
    }

    function changeTokenPrice(uint256 newPrice)
        external
        onlyOwner
        returns (bool)
    {
        require(
            newPrice > 0,
            "TokenPresaleWEFI: token price must be greater than 0 wei"
        );

        uint256 oldPrice = tokenPriceInWei;
        tokenPriceInWei = newPrice;

        emit TokenPriceChanged(oldPrice, newPrice);
        return true;
    }

    function changeVestingContractAddress(address newContractAddress)
        external
        onlyOwner
        returns (bool)
    {
        require(
            newContractAddress != address(0),
            "TokenPresaleWEFI: new contract address is the zero address"
        );
        address oldContractAddress = address(vestingContractAddress);
        vestingContractAddress = ITokenVestingWEFI(newContractAddress);

        emit VestingContractAddressChanged(
            oldContractAddress,
            newContractAddress
        );
        return true;
    }

    function changeBuyerVestingSchedule(
        uint256 buyerVestingCliff_,
        uint256 buyerVestingStart_,
        uint256 buyerVestingDuration_,
        uint256 buyerVestingSlicePeriodSeconds_
    ) external onlyOwner returns (bool) {
        _buyerVestingCliff = buyerVestingCliff_;
        _buyerVestingStart = buyerVestingStart_;
        _buyerVestingDuration = buyerVestingDuration_;
        _buyerVestingSlicePeriodSeconds = buyerVestingSlicePeriodSeconds_;

        emit BuyerVestingScheduleChanged(
            _buyerVestingCliff,
            _buyerVestingStart,
            _buyerVestingDuration,
            _buyerVestingSlicePeriodSeconds
        );
        return true;
    }

    function changeReferrerAndHeadPromoterVestingSchedule(
        uint256 referrerAndHeadPromoterVestingCliff_,
        uint256 referrerAndHeadPromoterVestingStart_,
        uint256 referrerAndHeadPromoterVestingDuration_,
        uint256 referrerAndHeadPromoterVestingSlicePeriodSeconds_
    ) external onlyOwner returns (bool) {
        _referrerAndHeadPromoterVestingCliff = referrerAndHeadPromoterVestingCliff_;
        _referrerAndHeadPromoterVestingStart = referrerAndHeadPromoterVestingStart_;
        _referrerAndHeadPromoterVestingDuration = referrerAndHeadPromoterVestingDuration_;
        _referrerAndHeadPromoterVestingSlicePeriodSeconds = referrerAndHeadPromoterVestingSlicePeriodSeconds_;

        emit ReferrerVestingScheduleChanged(
            _referrerAndHeadPromoterVestingCliff,
            _referrerAndHeadPromoterVestingStart,
            _referrerAndHeadPromoterVestingDuration,
            _referrerAndHeadPromoterVestingSlicePeriodSeconds
        );
        return true;
    }

    function getBuyerVestingSchedule()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _buyerVestingCliff,
            _buyerVestingStart,
            _buyerVestingDuration,
            _buyerVestingSlicePeriodSeconds
        );
    }

    function getReferrerAndHeadPromoterVestingSchedule()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _referrerAndHeadPromoterVestingCliff,
            _referrerAndHeadPromoterVestingStart,
            _referrerAndHeadPromoterVestingDuration,
            _referrerAndHeadPromoterVestingSlicePeriodSeconds
        );
    }

    function includeInWhitelist(
        uint256 referrerReferralCode,
        uint256 headPromoterReferralCode,
        uint8 headPromoterCommissionPercentage,
        uint8 referrerCommissionPercentage,
        uint8 referralBonusPercentage
    ) external onlyOwner returns (bool) {
        if (headPromoterReferralCode != 0) {
            require(
                _referralCodeToAddress[headPromoterReferralCode] != address(0),
                "TokenPresaleWEFI: head promoter referral code does not exist"
            );
            require(
                headPromoterCommissionPercentage != 0,
                "TokenPresaleWEFI: head promoter referral code exists hence its commssion percentage must not be null"
            );
        }
        if (headPromoterCommissionPercentage != 0) {
            require(
                headPromoterReferralCode != 0,
                "TokenPresaleWEFI: head promoter commission percentage exists hence its referral code must not be null"
            );
        }

        require(
            _referralCodeToAddress[referrerReferralCode] != address(0),
            "TokenPresaleWEFI: referrer referral code does not exist"
        );
        require(
            referrerReferralCode != headPromoterReferralCode,
            "TokenPresaleWEFI: referrer and head promoter referral code must not be same"
        );
        require(
            referrerReferralCode != 0 && referrerCommissionPercentage != 0,
            "TokenPresaleWEFI: referral code and commission percentage must not be null"
        );

        ReferrerInfo storage referrerInfo = _referrerInfoList[
            referrerReferralCode
        ];
        referrerInfo.headPromoterReferralCode = headPromoterReferralCode;
        referrerInfo
            .headPromoterCommissionPercentage = headPromoterCommissionPercentage;
        referrerInfo
            .referrerCommissionPercentage = referrerCommissionPercentage;
        referrerInfo.referralBonusPercentage = referralBonusPercentage;
        _whitelist[referrerReferralCode] = true;

        emit ReferrerWhitelisted(
            referrerReferralCode,
            headPromoterReferralCode,
            headPromoterCommissionPercentage,
            referrerCommissionPercentage,
            referralBonusPercentage
        );
        return true;
    }

    function excludeFromWhitelist(uint256 referralCode)
        external
        onlyOwner
        returns (bool)
    {
        ReferrerInfo storage referrerInfo = _referrerInfoList[referralCode];
        referrerInfo.headPromoterReferralCode = 0;
        referrerInfo.headPromoterCommissionPercentage = 0;
        referrerInfo.referrerCommissionPercentage = 0;
        referrerInfo.referralBonusPercentage = 0;
        _whitelist[referralCode] = false;

        emit ReferrerBlacklisted(referralCode);
        return true;
    }

    function getReferrerInfo(uint256 referralCode)
        external
        view
        returns (
            bool,
            uint256,
            uint8,
            uint8,
            uint8,
            uint256
        )
    {
        ReferrerInfo memory referrerInfo = _referrerInfoList[referralCode];
        uint256 totalCommissionEarned = _totalReferrerCommissionAmount[
            _referralCodeToAddress[referralCode]
        ];

        return (
            _whitelist[referralCode],
            referrerInfo.headPromoterReferralCode,
            referrerInfo.headPromoterCommissionPercentage,
            referrerInfo.referrerCommissionPercentage,
            referrerInfo.referralBonusPercentage,
            totalCommissionEarned
        );
    }

    function buyToken(uint256 referralCode)
        external
        payable
        nonReentrant
        returns (bool)
    {
        _buyToken(referralCode);

        return true;
    }

    function _buyToken(uint256 referralCode) private {
        require(
            msg.value >= 1 wei,
            "TokenPresaleWEFI: sent BNB amount must be greater than 0 wei"
        );
        address buyer = _msgSender();
        if (_referralAddressToCode[buyer] == 0) {
            generateReferralCode(buyer);
        }
        uint256 contractTokenBalance = getContractTokenBalance();
        uint256 buyableTokens = _buyableTokens();

        if (referralCode != 0 && _whitelist[referralCode]) {
            require(
                _referralAddressToCode[buyer] != referralCode,
                "TokenPresaleWEFI: buyer could not use his own referral code"
            );
            uint256 headPromoterCommissionedTokens = 0;
            uint256 referrerCommissionedTokens = 0;

            ReferrerInfo memory referrerInfo = _referrerInfoList[referralCode];
            address headPromoterAddress = _referralCodeToAddress[
                referrerInfo.headPromoterReferralCode
            ];
            address referrerAddress = _referralCodeToAddress[referralCode];
            uint8 headPromoterCommissionPercentage = referrerInfo
                .headPromoterCommissionPercentage;
            uint8 referrerCommissionPercentage = referrerInfo
                .referrerCommissionPercentage;
            uint8 referralBonusPercentage = referrerInfo
                .referralBonusPercentage;

            headPromoterCommissionedTokens = ((buyableTokens *
                headPromoterCommissionPercentage) / 100);
            referrerCommissionedTokens = ((buyableTokens *
                referrerCommissionPercentage) / 100);
            buyableTokens += ((buyableTokens * referralBonusPercentage) / 100);
            require(
                contractTokenBalance >=
                    (buyableTokens +
                        headPromoterCommissionedTokens +
                        referrerCommissionedTokens),
                "TokenPresaleWEFI: buyable/commissioned token amount exceeds presale contract balance"
            );
            if (headPromoterCommissionedTokens > 0) {
                _sendToHeadPromoterVesting(
                    headPromoterAddress,
                    headPromoterCommissionedTokens
                );
            }
            _sendToReferrerVesting(referrerAddress, referrerCommissionedTokens);
        } else {
            require(
                contractTokenBalance >= (buyableTokens),
                "TokenPresaleWEFI: buyable token amount exceeds presale contract balance"
            );
        }
        _sendToBuyerVesting(buyer, buyableTokens);
    }

    function _buyableTokens() private view returns (uint256) {
        uint256 buyableTokens = (msg.value * 10**_tokenDecimals) /
            tokenPriceInWei;

        return buyableTokens;
    }

    function _sendToBuyerVesting(address beneficiary, uint256 amount) private {
        if (_buyerVestingCliff == 1 && _buyerVestingDuration == 1) {
            require(
                tokenAddress.transfer(beneficiary, amount),
                "TokenPresaleWEFI: token WEFI transfer to buyer not succeeded"
            );
        } else {
            require(
                tokenAddress.approve(address(vestingContractAddress), amount),
                "TokenPresaleWEFI: token WEFI approve to vesting contract not succeeded"
            );
            vestingContractAddress.createVestingSchedule(
                beneficiary,
                _buyerVestingStart,
                _buyerVestingCliff,
                _buyerVestingDuration,
                _buyerVestingSlicePeriodSeconds,
                amount
            );
        }

        emit TokenSold(beneficiary, amount);
    }

    function _sendToReferrerVesting(address beneficiary, uint256 amount)
        private
    {
        if (
            _referrerAndHeadPromoterVestingCliff == 1 &&
            _referrerAndHeadPromoterVestingDuration == 1
        ) {
            require(
                tokenAddress.transfer(beneficiary, amount),
                "TokenPresaleWEFI: token WEFI transfer to referrer not succeeded"
            );
        } else {
            require(
                tokenAddress.approve(address(vestingContractAddress), amount),
                "TokenPresaleWEFI: token WEFI approve to vesting contract not succeeded"
            );
            vestingContractAddress.createVestingSchedule(
                beneficiary,
                _referrerAndHeadPromoterVestingStart,
                _referrerAndHeadPromoterVestingCliff,
                _referrerAndHeadPromoterVestingDuration,
                _referrerAndHeadPromoterVestingSlicePeriodSeconds,
                amount
            );
        }

        _totalReferrerCommissionAmount[beneficiary] += amount;
        _checkIfTop(beneficiary);

        emit ReferrerCommissionSent(beneficiary, amount);
    }

    function _sendToHeadPromoterVesting(address beneficiary, uint256 amount)
        private
    {
        if (
            _referrerAndHeadPromoterVestingCliff == 1 &&
            _referrerAndHeadPromoterVestingDuration == 1
        ) {
            require(
                tokenAddress.transfer(beneficiary, amount),
                "TokenPresaleWEFI: token WEFI transfer to head promoter not succeeded"
            );
        } else {
            require(
                tokenAddress.approve(address(vestingContractAddress), amount),
                "TokenPresaleWEFI: token WEFI approve to vesting contract not succeeded"
            );
            vestingContractAddress.createVestingSchedule(
                beneficiary,
                _referrerAndHeadPromoterVestingStart,
                _referrerAndHeadPromoterVestingCliff,
                _referrerAndHeadPromoterVestingDuration,
                _referrerAndHeadPromoterVestingSlicePeriodSeconds,
                amount
            );
        }

        emit HeadPromoterCommissionSent(beneficiary, amount);
    }

    function _checkIfTop(address beneficiary) private {
        if (
            _totalReferrerCommissionAmount[beneficiary] >
            _totalReferrerCommissionAmount[_topThirdReferrer] &&
            _totalReferrerCommissionAmount[beneficiary] <
            _totalReferrerCommissionAmount[_topSecondReferrer] &&
            beneficiary != _topThirdReferrer
        ) {
            _topThirdReferrer = beneficiary;
        } else if (
            _totalReferrerCommissionAmount[beneficiary] >=
            _totalReferrerCommissionAmount[_topSecondReferrer] &&
            _totalReferrerCommissionAmount[beneficiary] <
            _totalReferrerCommissionAmount[_topFirstReferrer] &&
            beneficiary != _topSecondReferrer
        ) {
            _topThirdReferrer = _topSecondReferrer;
            _topSecondReferrer = beneficiary;
        } else if (
            _totalReferrerCommissionAmount[beneficiary] >=
            _totalReferrerCommissionAmount[_topFirstReferrer] &&
            beneficiary != _topFirstReferrer
        ) {
            if (_topSecondReferrer != beneficiary) {
                _topThirdReferrer = _topSecondReferrer;
            }
            _topSecondReferrer = _topFirstReferrer;
            _topFirstReferrer = beneficiary;
        }
    }

    function getTopThreeReferrers()
        external
        view
        returns (
            address,
            uint256,
            address,
            uint256,
            address,
            uint256
        )
    {
        return (
            _topFirstReferrer,
            _totalReferrerCommissionAmount[_topFirstReferrer],
            _topSecondReferrer,
            _totalReferrerCommissionAmount[_topSecondReferrer],
            _topThirdReferrer,
            _totalReferrerCommissionAmount[_topThirdReferrer]
        );
    }

    function resetTopThreeReferrers() external onlyOwner returns (bool) {
        _totalReferrerCommissionAmount[
            _topFirstReferrer
        ] = _totalReferrerCommissionAmount[
            _topSecondReferrer
        ] = _totalReferrerCommissionAmount[_topThirdReferrer] = 0;
        _topFirstReferrer = _topSecondReferrer = _topThirdReferrer = address(0);

        emit ResetTopThreeReferrers(block.timestamp);
        return true;
    }

    function getContractBnbBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdrawBnbBalance() external onlyOwner returns (bool) {
        require(
            payable(owner()).send(address(this).balance),
            "Failed to send BNB"
        );

        return true;
    }

    function getContractTokenBalance() public view returns (uint256) {
        return tokenAddress.balanceOf(address(this));
    }

    function withdrawContractTokenBalance(uint256 amount)
        external
        onlyOwner
        returns (bool)
    {
        require(
            getContractTokenBalance() >= amount,
            "TokenVestingWEFI: not enough withdrawable funds"
        );
        require(
            tokenAddress.transfer(owner(), amount),
            "TokenPresaleWEFI: token WEFI transfer to owner not succeeded"
        );

        return true;
    }

    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    fallback() external payable {
        _buyToken(0);
    }

    receive() external payable {
        _buyToken(0);
    }
}