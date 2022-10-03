/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

// File: PresaleContract.sol


pragma solidity ^0.8.4;




contract PresaleContract is Ownable, ReentrancyGuard {
    struct SupportedTokenInfo {
        string name;
        address contractAddress;
    }

    /* ========== STATE VARIABLES ========== */
    mapping(string => IERC20) private supportedTokenContracts;
    mapping(uint256 => string) private supportedTokenNames;
    mapping(uint256 => address) private supportedTokenAddresses;
    mapping(address => uint256[]) private lockedBalances;
    mapping(address => uint256[]) private unlockedBalances;

    uint256[] private tokenReleaseRounds;
    uint256[] private roundLengths;
    uint256[] private timestampStarts;
    uint256 private decimals = 18;

    uint256 private totalSupportedTokens;
    uint256[] private talSupplies;
    uint256 private totalLockedTokens;
    uint256 private oneMonth = 2635200;

    IERC20 private talContract;

    /* ========== CONSTRUCTOR ========== */
    constructor(
        address _talAddress,
        uint256[] memory _tokenReleaseRounds,
        uint256[] memory _roundLengths
    ) {
        totalSupportedTokens = 0;
        talContract = IERC20(_talAddress);
        tokenReleaseRounds = _tokenReleaseRounds;
        roundLengths = _roundLengths;
        talSupplies = new uint256[](tokenReleaseRounds.length);
    }

    /* ========== VIEWS ========== */
    function totalTalSupplies() external view returns (uint256[] memory) {
        return talSupplies;
    }

    function getRoundLengths() external view returns (uint256[] memory) {
        return roundLengths;
    }

    function allSupportedTokenInfo()
        external
        view
        returns (SupportedTokenInfo[] memory)
    {
        SupportedTokenInfo[] memory tokenInfo = new SupportedTokenInfo[](
            totalSupportedTokens
        );

        for (uint256 i = 0; i < totalSupportedTokens; i++) {
            tokenInfo[i].name = supportedTokenNames[i];
            tokenInfo[i].contractAddress = supportedTokenAddresses[i];
        }

        return tokenInfo;
    }

    function getTotalLockedTokens() external view returns (uint256) {
        return totalLockedTokens;
    }

    function getLockedTokensAccount(address _account)
        external
        view
        returns (uint256[] memory)
    {
        return lockedBalances[_account];
    }

    function getUnlockedTokensAccount(address _account)
        external
        view
        returns (uint256[] memory)
    {
        return unlockedBalances[_account];
    }

    function getCurrentLockedRound() external view returns (uint256) {
        if (timestampStarts.length == 0) return 0;

        uint256 totalRounds = tokenReleaseRounds.length;
        uint256 currentRound = 1;

        for (uint256 i = 1; i < totalRounds + 1; i++) {
            uint256 roundTimestamp = timestampStarts[i - 1] +
                tokenReleaseRounds[i - 1];

            if (roundTimestamp >= block.timestamp) {
                currentRound = i;
                break;
            }

            if (i == totalRounds) currentRound = totalRounds;
        }

        return currentRound;
    }

    function getCurrentRound() external view returns (uint256) {
        if (timestampStarts.length == 0) return 0;

        uint256 totalRounds = roundLengths.length;
        uint256 currentRound = 1;

        for (uint256 i = 1; i < totalRounds + 1; i++) {
            uint256 roundTimestamp = timestampStarts[0] + roundLengths[i - 1];

            if (roundTimestamp >= block.timestamp) {
                currentRound = i;
                break;
            }

            if (i == totalRounds) currentRound = totalRounds;
        }

        return currentRound;
    }

    function getCurrentLockedMonth(uint256 round)
        external
        view
        returns (uint256)
    {
        if (timestampStarts.length == 0 || timestampStarts[round - 1] <= 0)
            return 0;

        uint256 currentRound = this.getCurrentRound();

        if (round > currentRound) return 0;

        uint256 currentReleaseMonth = (block.timestamp -
            timestampStarts[round - 1]) / oneMonth;

        uint256 maxMonths = tokenReleaseRounds[round - 1] / oneMonth;

        if (currentReleaseMonth > maxMonths) return maxMonths;

        return currentReleaseMonth;
    }

    function getRoundIsFinished(uint256 round) external view returns (bool) {
        require(round > 0, "Invalid round");

        if (timestampStarts[0] + roundLengths[round - 1] <= block.timestamp)
            return true;

        return false;
    }

    function getRounds() external view returns (uint256[] memory) {
        return tokenReleaseRounds;
    }

    function getAvailableUnlockedTokens(address account, uint256 round)
        external
        view
        returns (uint256)
    {
        if (timestampStarts.length == 0) return 0;
        if (lockedBalances[account].length == 0) return 0;

        uint256 currentRound = this.getCurrentRound();

        if (
            round > currentRound ||
            totalLockedTokens <= 0 ||
            lockedBalances[account][round - 1] <= 0
        ) return 0;

        uint256 _amountTAL = lockedBalances[account][round - 1];
        uint256 maxMonths = tokenReleaseRounds[round - 1] / oneMonth;
        uint256 currentReleaseMonths = this.getCurrentLockedMonth(round);

        uint256 currentLockedRound = this.getCurrentLockedRound();

        if (round >= currentLockedRound && currentReleaseMonths < maxMonths) {
            uint256 totalRoundTokens = lockedBalances[account][round - 1];
            uint256 releasedMonths = 0;

            if (unlockedBalances[account].length > 0)
                totalRoundTokens += unlockedBalances[account][round - 1];

            uint256 eachReleasedTokens = totalRoundTokens / maxMonths;

            if (unlockedBalances[account].length > 0)
                releasedMonths =
                    unlockedBalances[account][round - 1] /
                    eachReleasedTokens;

            if (
                currentReleaseMonths >= 1 &&
                currentReleaseMonths > releasedMonths
            ) {
                _amountTAL =
                    eachReleasedTokens *
                    (currentReleaseMonths - releasedMonths);
            } else return 0;
        }

        return _amountTAL;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    function buyTALTokenByBNB(
        uint256 _amountTAL,
        uint256 round,
        uint256 initialPaidPercentage
    )
        external
        payable
        nonReentrant
        isStarted
        checkRoundTalSupply(_amountTAL, round)
    {
        require(_amountTAL > 0, "Amount TAL must be more than 0");
        require(msg.value > 0, "Invalid buyer supply");
        require(
            initialPaidPercentage <= 100 && initialPaidPercentage >= 0,
            "Invalid initial paid percentage"
        );

        bool isFinished = this.getRoundIsFinished(round);

        require(isFinished == false, "The round is finished");

        talSupplies[round - 1] = talSupplies[round - 1] - _amountTAL;

        payable(owner()).transfer(msg.value);

        bool isLocked = true;

        if (block.timestamp >= timestampStarts[roundLengths.length - 1]) {
            talContract.transfer(msg.sender, _amountTAL);

            isLocked = false;
        } else {
            uint256 initialPaidTokens = (_amountTAL * initialPaidPercentage) /
                100;

            increaseLockedBalance(
                msg.sender,
                round - 1,
                _amountTAL - initialPaidTokens
            );
            totalLockedTokens += _amountTAL - initialPaidTokens;

            if (initialPaidTokens > 0)
                talContract.transfer(msg.sender, initialPaidTokens);
        }

        emit BuyTALTokenByBNB(msg.sender, _amountTAL, msg.value, isLocked);
    }

    function increaseLockedBalance(
        address _account,
        uint256 position,
        uint256 _amount
    ) private {
        if (
            lockedBalances[_account].length > 0 &&
            lockedBalances[_account].length - 1 >= position
        ) lockedBalances[_account][position] += _amount;
        else {
            uint256[] memory newLockedBalances = new uint256[](
                tokenReleaseRounds.length
            );

            if (lockedBalances[_account].length == 0) {
                lockedBalances[_account] = new uint256[](
                    tokenReleaseRounds.length
                );
                lockedBalances[_account] = [0, 0, 0, 0, 0];
            }

            for (uint256 i = 0; i < tokenReleaseRounds.length; i++) {
                if (position == i)
                    newLockedBalances[i] =
                        lockedBalances[_account][i] +
                        _amount;
                else newLockedBalances[i] = lockedBalances[_account][i];
            }

            lockedBalances[_account] = newLockedBalances;
        }
    }

    function increaseUnlockedBalance(
        address _account,
        uint256 position,
        uint256 _amount
    ) private {
        if (
            unlockedBalances[_account].length > 0 &&
            unlockedBalances[_account].length - 1 >= position
        ) unlockedBalances[_account][position] += _amount;
        else {
            uint256[] memory newUnlockedBalances = new uint256[](
                tokenReleaseRounds.length
            );

            if (unlockedBalances[_account].length == 0) {
                unlockedBalances[_account] = new uint256[](
                    tokenReleaseRounds.length
                );
                unlockedBalances[_account] = [0, 0, 0, 0, 0];
            }

            for (uint256 i = 0; i < tokenReleaseRounds.length; i++) {
                if (position == i)
                    newUnlockedBalances[i] =
                        unlockedBalances[_account][i] +
                        _amount;
                else newUnlockedBalances[i] = unlockedBalances[_account][i];
            }

            unlockedBalances[_account] = newUnlockedBalances;
        }
    }

    function buyTALTokenBySupportedToken(
        uint256 _amountTAL,
        uint256 _amountSupportedToken,
        string memory _supportedTokenName,
        uint256 round,
        uint256 initialPaidPercentage
    ) external nonReentrant isStarted checkRoundTalSupply(_amountTAL, round) {
        require(_amountTAL > 0, "Amount TAL must be more than 0");
        require(
            _amountSupportedToken > 0,
            "Amount supported token must be more than 0"
        );
        require(
            initialPaidPercentage <= 100 && initialPaidPercentage >= 0,
            "Invalid initial paid percentage"
        );

        bool isFinished = this.getRoundIsFinished(round);

        require(isFinished == false, "The round is finished");

        checkIsTokenSupported(_supportedTokenName);

        IERC20 supportedTokenContract = supportedTokenContracts[
            _supportedTokenName
        ];

        talSupplies[round - 1] = talSupplies[round - 1] - _amountTAL;

        supportedTokenContract.transferFrom(
            msg.sender,
            owner(),
            _amountSupportedToken
        );

        bool isLocked = true;

        if (block.timestamp >= timestampStarts[roundLengths.length - 1]) {
            talContract.transfer(msg.sender, _amountTAL);
            isLocked = false;
        } else {
            uint256 initialPaidTokens = (_amountTAL * initialPaidPercentage) /
                100;

            increaseLockedBalance(
                msg.sender,
                round - 1,
                _amountTAL - initialPaidTokens
            );
            totalLockedTokens += _amountTAL - initialPaidTokens;

            if (initialPaidTokens > 0)
                talContract.transfer(msg.sender, initialPaidTokens);
        }

        emit BuyTALTokenBySupportedToken(
            msg.sender,
            _amountTAL,
            _amountSupportedToken,
            isLocked
        );
    }

    function buyTALTokenByCash(
        uint256 _amountTAL,
        uint256 round,
        uint256 initialPaidPercentage,
        address receiver,
        bool checkRoundFinished
    ) external nonReentrant isStarted checkRoundTalSupply(_amountTAL, round) {
        require(_amountTAL > 0, "Amount TAL must be more than 0");
        require(
            initialPaidPercentage <= 100 && initialPaidPercentage >= 0,
            "Invalid initial paid percentage"
        );

        bool isFinished = this.getRoundIsFinished(round);

        if (checkRoundFinished == true)
            require(isFinished == false, "The round is finished");

        talSupplies[round - 1] = talSupplies[round - 1] - _amountTAL;

        bool isLocked = true;

        if (block.timestamp >= timestampStarts[roundLengths.length - 1]) {
            talContract.transfer(receiver, _amountTAL);
            isLocked = false;
        } else {
            uint256 initialPaidTokens = (_amountTAL * initialPaidPercentage) /
                100;

            increaseLockedBalance(
                receiver,
                round - 1,
                _amountTAL - initialPaidTokens
            );
            totalLockedTokens += _amountTAL - initialPaidTokens;

            if (initialPaidTokens > 0)
                talContract.transfer(receiver, initialPaidTokens);
        }

        emit BuyTALTokenByCash(receiver, _amountTAL, isLocked);
    }

    function withdrawUnlockedTokens(uint256 round)
        external
        nonReentrant
        isStarted
    {
        uint256 currentSellRound = this.getCurrentRound();

        require(round <= currentSellRound, "This round has not activated yet");
        require(totalLockedTokens > 0, "Not enough tokens in contract");
        require(
            lockedBalances[msg.sender][round - 1] > 0,
            "All locked tokens were released in this round"
        );

        uint256 _amountTAL = lockedBalances[msg.sender][round - 1];

        uint256 maxMonths = tokenReleaseRounds[round - 1] / oneMonth;
        uint256 currentReleaseMonths = this.getCurrentLockedMonth(round);

        uint256 currentLockedRound = this.getCurrentLockedRound();

        if (round >= currentLockedRound && currentReleaseMonths < maxMonths) {
            uint256 totalRoundTokens = lockedBalances[msg.sender][round - 1];

            if (unlockedBalances[msg.sender].length > 0)
                totalRoundTokens += unlockedBalances[msg.sender][round - 1];

            uint256 eachReleasedTokens = totalRoundTokens / maxMonths;

            uint256 releasedMonths = 0;

            if (unlockedBalances[msg.sender].length > 0)
                releasedMonths =
                    unlockedBalances[msg.sender][round - 1] /
                    eachReleasedTokens;

            require(
                currentReleaseMonths > 0,
                "No released tokens now in this month"
            );

            require(
                currentReleaseMonths > releasedMonths,
                "No released tokens now in this month"
            );

            _amountTAL =
                eachReleasedTokens *
                (currentReleaseMonths - releasedMonths);
        }

        totalLockedTokens = totalLockedTokens - _amountTAL;
        lockedBalances[msg.sender][round - 1] =
            lockedBalances[msg.sender][round - 1] -
            _amountTAL;

        increaseUnlockedBalance(msg.sender, round - 1, _amountTAL);

        talContract.transfer(msg.sender, _amountTAL);

        emit GetUnlockedTokens(msg.sender, _amountTAL);
    }

    /* ========== OWNER FUNCTIONS ========== */
    function start() external onlyOwner {
        require(timestampStarts.length == 0, "Presale started");

        uint256 currentTimestamp = block.timestamp;

        timestampStarts.push(currentTimestamp);

        for (uint256 i = 0; i < roundLengths.length - 1; i++) {
            timestampStarts.push(currentTimestamp + roundLengths[i]);
        }
    }

    function addSupportedToken(string memory _tokenName, address _tokenAddress)
        external
        onlyOwner
    {
        supportedTokenContracts[_tokenName] = IERC20(_tokenAddress);
        supportedTokenNames[totalSupportedTokens] = _tokenName;
        supportedTokenAddresses[totalSupportedTokens] = _tokenAddress;
        totalSupportedTokens = totalSupportedTokens + 1;
    }

    function removeSupportedToken(string memory _tokenName) external onlyOwner {
        uint256 tokenNameIndex = checkIsTokenSupported(_tokenName);

        delete supportedTokenNames[tokenNameIndex];
        delete supportedTokenAddresses[tokenNameIndex];
        delete supportedTokenContracts[_tokenName];
    }

    function fundContractBalance(uint256 _amount, uint256 _round)
        external
        onlyOwner
    {
        require(_amount > 0, "Invalid fund");

        if (_round == 0) talSupplies.push(_amount);
        else talSupplies[_round - 1] += _amount;

        talContract.transferFrom(msg.sender, address(this), _amount);
    }

    function withdrawTALToken(address receiver, uint256 _round)
        external
        onlyOwner
    {
        require(talSupplies.length > 0, "TAL supply is 0");
        require(
            _round <= tokenReleaseRounds.length && _round > 0,
            "Round is not existed"
        );
        require(talSupplies[_round - 1] > 0, "Round supply is 0");

        uint256 totalCurrentSupply = talSupplies[_round - 1];

        talSupplies[_round - 1] = 0;

        talContract.transfer(receiver, totalCurrentSupply);
    }

    /* ========== UTIL FUNCTIONS ========== */
    function checkIsTokenSupported(string memory _supportedTokenName)
        internal
        returns (uint256)
    {
        bool isTokenSupported = false;
        uint256 tokenNameIndex = 0;

        for (uint256 i = 0; i < totalSupportedTokens; i++) {
            bytes32 str1Hash = keccak256(abi.encode(supportedTokenNames[i]));
            bytes32 str2Hash = keccak256(abi.encode(_supportedTokenName));

            if (str1Hash == str2Hash) {
                isTokenSupported = true;
                tokenNameIndex = i;
                break;
            }
        }

        require(isTokenSupported, "The supported token is not supported");

        return tokenNameIndex;
    }

    /* ========== MODIFIERS ========== */
    modifier isStarted() {
        require(timestampStarts.length > 0, "The round has not started yet");

        _;
    }

    modifier checkRoundTalSupply(uint256 _amount, uint256 _round) {
        require(_round <= tokenReleaseRounds.length, "Round is not existed");
        require(_round > 0, "Round is not equal to 0");

        uint256 roundSupply = talSupplies[_round - 1];

        require(roundSupply >= _amount, "The round supply is not enough");

        _;
    }

    /* ========== EVENTS ========== */
    event BuyTALTokenByBNB(
        address indexed buyer,
        uint256 talAmount,
        uint256 bnbAmount,
        bool isLocked
    );
    event BuyTALTokenBySupportedToken(
        address indexed buyer,
        uint256 talAmount,
        uint256 supportedTokenAmount,
        bool isLocked
    );
    event BuyTALTokenByCash(
        address indexed buyer,
        uint256 talAmount,
        bool isLocked
    );

    event GetUnlockedTokens(address indexed receiver, uint256 talAmount);
}