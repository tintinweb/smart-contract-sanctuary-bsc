/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


contract TokenSale is Ownable {
    modifier onlyValidAddress(address _recipient) {
        require(
            _recipient != address(0) &&
                _recipient != address(this) &&
                _recipient != address(token),
            "not valid _recipient"
        );
        _;
    }

    struct Grant {
        uint256 totalAmount;
        uint256 totalClaimed;
        uint256 startAmount;
        uint16 monthsClaimed;
        address recipient;
        bool isValued;
        uint256 vestAmount;
    }
    struct ClaimData {
        uint256 amount;
        address target;
    }

    event GrantAdded(address indexed recipient);
    event GrantTokensClaimed(address indexed recipient, uint256 amountClaimed);
    event GrantRemoved(address recipient, uint256 amount);
    event BoughtOrder(address indexed recipient, uint256 _amount);

    mapping(address => Grant) private tokenGrants;
    mapping(address => bool) private whitelistAddresses;
    uint256 internal constant SECONDS_PER_MONTH = 2592000;
    uint256 public totalVestingCount;
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public tokenUsed;
    uint256 public unlockTime;
    uint256 public transferRate;
    uint16 public vestingPercentage;
    uint16 public vestingDurationInMonths;
    uint16 public vestingCliffInMonths;
    address public saleAddress;
    address public token;
    uint256 minUsdAmount;
    uint256 maxUsdAmount;
    mapping(address => bool) public usdStableTokens;

    constructor(
        address _token,
        uint256 _transferRate,
        uint16 _vestingPercentage,
        uint16 _vestingDurationInMonths,
        uint16 _vestingCliffInMonths,
        address _saleAddress
    ) {
        require(_token != address(0));
        require(_saleAddress != address(0));
        require(
            _vestingPercentage > 0 && _vestingPercentage <= 100,
            "TokenSale: Invalid percentage"
        );
        require(
            _vestingDurationInMonths >= _vestingCliffInMonths,
            "TokenSale: Duration must be greater than Cliff"
        );
        saleAddress = _saleAddress;
        token = _token;
        vestingPercentage = _vestingPercentage;
        vestingDurationInMonths = _vestingDurationInMonths;
        vestingCliffInMonths = _vestingCliffInMonths;
        transferRate = _transferRate;
    }

    function buyToken(uint256 _amount, address tokenAddress) external {
        require(
            usdStableTokens[tokenAddress] == true,
            "TokenSale: Invalid token address"
        );
        uint256 usdAmount = transferRate * _amount;
        uint256 buyTime = currentTime();
        require(
            usdAmount >= minUsdAmount * 10**18 &&
                usdAmount <= maxUsdAmount * 10**18,
            "TokenSale: Invalid input for amount"
        );
        require(
            whitelistAddresses[address(_msgSender())] == true,
            "TokenSale: Address is not on whitelist"
        );
        require(
            saleStartTime <= buyTime && saleEndTime >= buyTime,
            "TokenSale: Not in sale period"
        );
        require(
            IERC20(token).balanceOf(address(this)) >= _amount + tokenUsed,
            "TokenSale: Insufficient funds from contract"
        );

        IERC20(tokenAddress).transferFrom(
            address(_msgSender()),
            saleAddress,
            usdAmount
        );
        addTokenGrant(_amount, address(_msgSender()));
    }

    function swapTokenFromList(ClaimData[] calldata arrayData)
        public
        onlyOwner
    {
        require(
            arrayData.length > 0,
            "TokenSale: Input array must not be empty"
        );
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < arrayData.length; i++) {
            totalAmount = totalAmount + (arrayData[i].amount / transferRate);
        }
        require(
            IERC20(token).balanceOf(address(this)) >= totalAmount + tokenUsed,
            "TokenSale: Insufficient funds from contract"
        );
        for (uint256 i = 0; i < arrayData.length; i++) {
            addTokenGrant(
                arrayData[i].amount / transferRate,
                arrayData[i].target
            );
        }
    }

    function addTokenGrant(uint256 _amount, address _recipient) private {
        uint256 vestingAmount = (_amount * vestingPercentage) / 100;
        uint256 sendAmount = _amount - vestingAmount;
        if (!tokenGrants[_recipient].isValued) {
            Grant memory grant = Grant({
                totalAmount: _amount,
                totalClaimed: 0,
                startAmount: sendAmount,
                monthsClaimed: 0,
                recipient: _recipient,
                isValued: true,
                vestAmount: _amount - sendAmount
            });
            tokenGrants[_recipient] = grant;
            emit GrantAdded(_recipient);
        } else {
            Grant storage tokenGrant = tokenGrants[_recipient];
            tokenGrant.totalAmount = tokenGrant.totalAmount + _amount;
            tokenGrant.startAmount = tokenGrant.startAmount + sendAmount;
            tokenGrant.vestAmount = tokenGrant.vestAmount + vestingAmount;
            tokenGrants[_recipient] = tokenGrant;
            emit GrantAdded(_recipient);
        }
        tokenUsed += _amount;
        emit BoughtOrder(address(_msgSender()), _amount);
    }

    function addTokenGrant(
        address _recipient,
        uint256 _totalAmount,
        uint256 _initAmount
    ) private {
        // Transfer the grant tokens under the control of the vesting contract
        //require(IBEP20(token).transferFrom(address(msg.sender), address(this), _amount), "transfer failed");
    }

    function getTokenGrants(address _recipient)
        public
        view
        returns (Grant memory)
    {
        return tokenGrants[_recipient];
    }

    function calculateGrantClaim(address _recipient)
        public
        view
        returns (uint16, uint256)
    {
        Grant storage tokenGrant = tokenGrants[_recipient];

        // For grants created with a future start date, that hasn't been reached, return 0, 0
        if (currentTime() < unlockTime) {
            return (0, 0);
        }

        // Check cliff was reached
        uint256 elapsedTime = currentTime() - (unlockTime);
        uint256 elapsedMonths = elapsedTime / (SECONDS_PER_MONTH);

        if (elapsedMonths < vestingCliffInMonths) {
            return (uint16(elapsedMonths), tokenGrant.startAmount);
        }

        // If over vesting duration, all tokens vested
        if (elapsedMonths >= vestingDurationInMonths) {
            uint256 remainingGrant = tokenGrant.totalAmount -
                tokenGrant.totalClaimed;
            return (vestingDurationInMonths, remainingGrant);
        } else {
            uint16 MonthsVested = uint16(
                elapsedMonths - tokenGrant.monthsClaimed
            );
            uint256 amountVestedPerMonth = tokenGrant.vestAmount /
                uint256(vestingDurationInMonths);
            uint256 amountVested = uint256(MonthsVested * amountVestedPerMonth);
            return (MonthsVested, amountVested + tokenGrant.startAmount);
        }
    }

    function claimVestedTokens(address _recipient) external {
        uint16 MonthsVested;
        uint256 amountVested;
        (MonthsVested, amountVested) = calculateGrantClaim(_recipient);
        require(amountVested > 0, "TokenSale: Amount vested is zero");

        Grant storage tokenGrant = tokenGrants[_recipient];
        tokenGrant.monthsClaimed = uint16(
            tokenGrant.monthsClaimed + MonthsVested
        );
        tokenGrant.totalClaimed = uint256(
            tokenGrant.totalClaimed + amountVested
        );
        tokenGrant.startAmount = 0;
        require(
            IBEP20(token).transfer(tokenGrant.recipient, amountVested),
            "no tokens"
        );
        tokenUsed -= amountVested;
        emit GrantTokensClaimed(tokenGrant.recipient, amountVested);
    }

    function removeTokenGrant(address _recipient) external onlyOwner {
        Grant storage tokenGrant = tokenGrants[_recipient];
        require(
            tokenGrant.isValued && tokenGrant.totalAmount > 0,
            "TokenSale: Invalid token grant"
        );
        address recipient = tokenGrant.recipient;
        uint256 backedAmount = tokenGrant.totalAmount - tokenGrant.totalClaimed;
        require(IBEP20(token).transfer(recipient, backedAmount));
        tokenGrant.totalAmount = 0;
        tokenGrant.monthsClaimed = 0;
        tokenGrant.totalClaimed = 0;
        tokenGrant.startAmount = 0;
        tokenGrant.vestAmount = 0;
        tokenGrant.isValued = false;
        tokenGrant.recipient = address(0);
        tokenUsed -= backedAmount;
        emit GrantRemoved(recipient, backedAmount);
    }

    function transferRemainingToken() external onlyOwner {
        require(availableAmount() > 0, "Balance is zero");
        uint256 remainingBalance = availableAmount();
        require(
            IBEP20(token).transfer(saleAddress, remainingBalance),
            "Cannot transfer remaining token"
        );
    }

    function currentTime() private view returns (uint256) {
        return block.timestamp;
    }

    function tokensVestedPerMonth(address _recipient)
        public
        view
        returns (uint256)
    {
        Grant storage tokenGrant = tokenGrants[_recipient];
        return (tokenGrant.vestAmount) / vestingDurationInMonths;
    }

    function updateTokenSupport(address tokenAddress, bool isSupported)
        external
        onlyOwner
    {
        usdStableTokens[tokenAddress] = isSupported;
    }

    function updateWhiteList(address userAddress, bool isWhiteListed)
        external
        onlyOwner
    {
        whitelistAddresses[userAddress] = isWhiteListed;
    }

    function addWhiteList(address[] memory whitelists) external onlyOwner {
        for (uint256 i = 0; i < whitelists.length; i++) {
            whitelistAddresses[whitelists[i]] = true;
        }
    }

    function checkWhiteList(address userAddress)
        external
        view
        onlyOwner
        returns (bool)
    {
        return whitelistAddresses[userAddress];
    }

    function setSalePeriod(uint256 startTime, uint256 endTime)
        external
        onlyOwner
    {
        require(
            endTime >= startTime,
            "TokenSale: endTime must be greater than startTime"
        );
        saleStartTime = startTime;
        saleEndTime = endTime;
    }

    function setUnlockTime(uint256 time) external onlyOwner {
        unlockTime = time;
    }

    function availableAmount() public view returns (uint256) {
        require(
            IERC20(token).balanceOf(address(this)) >= tokenUsed,
            "TokenSale: Insufficient funds from contract"
        );
        return (uint256)(IERC20(token).balanceOf(address(this)) - tokenUsed);
    }

    function setSaleAmount(uint256 min, uint256 max) external onlyOwner {
        minUsdAmount = min;
        maxUsdAmount = max;
    }
}