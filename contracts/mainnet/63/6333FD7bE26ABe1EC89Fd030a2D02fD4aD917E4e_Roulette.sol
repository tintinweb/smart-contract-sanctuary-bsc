/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IBEP20 {
    function decimals() external view returns (uint256);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);

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

interface IOwnable {
    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner_) external;
}

contract Ownable is IOwnable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyOwnerOrigin() {
        require(_owner == tx.origin, "Ownable: tx.origin is not the owner");
        _;
    }

    function renounceOwnership() public virtual override onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner_)
        public
        virtual
        override
        onlyOwner
    {
        require(
            newOwner_ != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner_);
        _owner = newOwner_;
    }
}

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

interface IHouse {
    function payout(
        address recipient_,
        uint256 amount_,
        address token_
    ) external;

    function addGame(address newGame_) external;

    function allowToken(address token_) external;
}

interface IRandomNumberGenerator {
    function requestRandomNumber(uint256 userProvidedSeed_, uint256 mod_) external view returns (uint256);

    function addGame(address game_) external;
}

interface IPriceCalculator {
    function getUSDValue(address token_, uint256 amount_) external view returns (uint256);
}

contract Roulette is Ownable, ReentrancyGuard {
    /* [OFP]: Only for Frontend Purposes */
    
    struct ProvidedToken {
        uint256 decimals;
        string symbol;
        string name;
    }

    struct TokenProviderInfo {
        mapping(address => uint256) providedTokens; // Amount of provided tokens based on a token address.
        mapping(address => uint256) riskable;       // The user's amount's slice of a given token he provided he's willing to lose
                                                    // everytime a bet is placed.
                                                      /* EXAMPLE:
                                                         providedTokens[$GAMBLE] = 150
                                                         riskable[$GAMBLE] = 12
                                                         amount he's risking at every bet = 12 $GAMBLE! */
    }

    mapping(address => TokenProviderInfo) private providerInfo; // Info of each user that provided tokens to the House.
    mapping(address => uint256) public tokenWinAmount;          // Amount of tokens that have been won based on a token address. [OFP]
    mapping(address => uint256) public houseTotalRiskable;      // Total amount of a token the house can risk.

    address public gambleToken;     // Native token address.
    address public houseAddress;    // House address.
    address public feeAddress;      // Address that receives win fees.
    address public ustFundAddress;  // Address of the UST Depeg Event victims fund. Find out more here: https://docs.smartgamble.money.
    address public priceCalc;       // Address of the price calculator contract.
    address public randomAddress;   // Address of random number generator.
    uint256 private seed = 0;

    address[] public tokens;    // List of tokens that are allowed to be provided to the house.
    address[] public providers; // Users that provided tokens to the House.
    address[] public whitelist; // Whitelisted users.

    uint256 public lastWin; // The block number of the last win.

    uint256 public winFee = 200;        // Fee % applied on every win. (default: 2%)
    uint256 public winFeeNative = 50;   // Fee % applied on every win made betting our native token. (default: 0.5%)
    uint256 public txFee = 50;          // Fee % applied on every gamble and sent to a UST Depeg Event victims fund. (default: 0.5%)
    uint256 public withdrawFee = 200;   // Fee % applied everytime a token provider withdraws from the House. (default: 0.5%)
    uint256 public referrerFee = 1000;  // Fee % sent to the selected referrer applied on every won bet fee.
                                        // Subtracted from the win fee, not from the gambler's bet. (default: 10%)

    uint256 public constant MAX_WIN_FEE = 400;          // Max fee % appliable on every win. (hard coded to 4%)
    uint256 public constant MAX_WIN_FEE_NATIVE = 100;   // Max fee % appliable on every win made betting with the
                                                        // native token. (hard coded to 1%)
    uint256 public constant MAX_TX_FEE = 100;           // Max fee % appliable on every gamble. (hard coded to 1%)
    uint256 public constant MAX_WITHDRAW_FEE = 400;     // Max fee % appliable on provider's withdrawals. (hard coded to 4%)
    uint256 public constant MAX_REFERRER_FEE = 2500;    // Max fee % sendable to the selected referrer. (hard coded to 25%)

    modifier noContracts() {
        require(
            tx.origin == msg.sender,
            "Roulette::noContracts: Caller cannot be a contract"
        );
        _;
    }

    modifier noUnbetableTokens(address token_) {
        require(
            houseTotalRiskable[token_] > 0,
            "Roulette::noUnbetableTokens: Not enough reserves in the House to gamble with such token"
        );
        _;
    }

    modifier noUnallowedTokens(address token_) {
        bool allowed = false;

        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i] == token_) {
                allowed = true;
                break;
            }
        }

        require(
            allowed,
            "Roulette::noUnallowedTokens: This token cannot be provided or betted (yet)"
        );
        _;
    }

    event Provide(address indexed user, address indexed token, uint256 amount, uint256 risk);
    event Withdraw(address indexed user, address indexed token, uint256 amount);
    event Gamble(uint256 indexed winAmount, uint256 indexed randomNumber);
    event SetHouseAddress(address oldAddress, address newAddress);
    event SetFeeAddress(address oldAddress, address newAddress);
    event SetUstFundAddress(address oldAddress, address newAddress);
    event SetRandomAddress(address oldAddress, address newAddress);
    event SetGambleAddress(address oldAddress, address newAddress);
    event SetPriceCalcAddress(address oldAddress, address newAddress);
    event SetFees(uint256 oldWinFee, uint256 newWinFee, uint256 oldWinFeeNative, uint256 newWinFeeNative, uint256 oldTxFee, uint256 newTxFee, uint256 oldWithdrawFee, uint256 newWithdrawFee, uint256 oldReferrerFee, uint256 newReferrerFee);

    constructor(
        address _gamble,
        address _house,
        address _fee,
        address _ustFund,
        address _random,
        address _priceCalc
    ) {
        require(
            _house != address(0) && _random != address(0) && _fee != address(0) && _ustFund != address(0),
            "Roulette::constructor: House, random, fee and the UST victims fund addresses cannot be the zero address"
        );
        gambleToken = _gamble;
        houseAddress = _house;
        feeAddress = _fee;
        ustFundAddress = _ustFund;
        randomAddress = _random;
        priceCalc = _priceCalc;

        IHouse(houseAddress).addGame(address(this));
        IRandomNumberGenerator(randomAddress).addGame(address(this));
    }

    // Provide funds to the House (become a Provider). Whenever a player wins or loses, Providers' shares get respectively
    // pumped or dumped depending on the amount of tokens they're risking.
    function provideTokensToHouse(address token_, uint256 amount_, uint256 riskPerc_) external nonReentrant noUnallowedTokens(token_) {
        require(amount_ >= 10000, "Roulette::provideTokensToHouse: Amount too small");
        require(riskPerc_ > 0 && riskPerc_ <= 10000, "Roulette::provideTokensToHouse: Risk cannot be 0% or higher than 100%");
        
        IBEP20(token_).transferFrom(msg.sender, houseAddress, amount_);

        providerInfo[msg.sender].providedTokens[token_] += amount_;
        providerInfo[msg.sender].riskable[token_] += ((amount_ * riskPerc_) / 10000);
        houseTotalRiskable[token_] += ((amount_ * riskPerc_) / 10000);

        bool newProvider = true;
        for (uint i = 0; i < providers.length; i++) {
            if (providers[i] == msg.sender) {
                newProvider = false;
                break;
            }
        }
        if (newProvider) {
            providers.push(msg.sender);
        }

        emit Provide(msg.sender, token_, amount_, riskPerc_);
    }

    // Used by Providers to withdraw their funds from the House.
    function withdrawTokensFromHouse(address token_, uint256 amount_) external nonReentrant {
        require(amount_ <= providerInfo[msg.sender].providedTokens[token_], "Roulette::withdrawTokensFromHouse: You cannot withdraw more than you deposited");

        if (providerInfo[msg.sender].providedTokens[token_] - amount_ <= 30000) {
            amount_ = providerInfo[msg.sender].providedTokens[token_];
        }

        uint256 q = (providerInfo[msg.sender].providedTokens[token_] * 1e18) / amount_;
        providerInfo[msg.sender].providedTokens[token_] -= amount_;
        houseTotalRiskable[token_] -= ((providerInfo[msg.sender].riskable[token_] * 1e18) / q);
        providerInfo[msg.sender].riskable[token_] -= ((providerInfo[msg.sender].riskable[token_] * 1e18) / q);

        uint256 withdrawFeeAmount = (amount_ * withdrawFee) / 10000;
        IHouse(houseAddress).payout(msg.sender, amount_ - withdrawFeeAmount, token_);
        IHouse(houseAddress).payout(feeAddress, withdrawFeeAmount, token_);

        emit Withdraw(msg.sender, token_, amount_);
    }

    // Called whenever a player wins or loses to recalculate the Providers' shares in the House.
    function updateProviders(address token_, uint256 amount_, uint256 providersRewOrProvidersLoss_) private {
        uint256 houseTotalRiskableBackup = houseTotalRiskable[token_];
        if (providersRewOrProvidersLoss_ == 0) { // Providers share increases, based on their riskable amount.
            for (uint i = 0; i < providers.length; i++) {
                uint256 q = (providerInfo[providers[i]].riskable[token_] * 1e18) / ((amount_ * 1e18) / ((houseTotalRiskable[token_] * 1e18) / providerInfo[providers[i]].riskable[token_]));
                uint256 provideBackup = providerInfo[providers[i]].providedTokens[token_];
                providerInfo[providers[i]].providedTokens[token_] += ((providerInfo[providers[i]].riskable[token_] * 1e18) / q);
                houseTotalRiskableBackup += ((providerInfo[providers[i]].riskable[token_] * 1e36) / q) / ((provideBackup * 1e18) / providerInfo[providers[i]].riskable[token_]);
                providerInfo[providers[i]].riskable[token_] += ((providerInfo[providers[i]].riskable[token_] * 1e36) / q) / ((provideBackup * 1e18) / providerInfo[providers[i]].riskable[token_]);
            }
        } else if (providersRewOrProvidersLoss_ == 1) { // Providers lose a share of their tokens in the House, based on their riskable amount.
            if (amount_ > houseTotalRiskable[token_]) {
                amount_ = houseTotalRiskable[token_];
            }
            for (uint i = 0; i < providers.length; i++) {
                if (providerInfo[providers[i]].riskable[token_] > 0) {
                    uint256 q = (amount_ * 1e18) / ((houseTotalRiskable[token_] * 1e18) / providerInfo[providers[i]].riskable[token_]);
                    uint256 r = (q * 1e18) / ((providerInfo[providers[i]].providedTokens[token_] * 1e18) / providerInfo[providers[i]].riskable[token_]);
                    // PROVIDED
                    if (providerInfo[providers[i]].providedTokens[token_] > q) {
                        providerInfo[providers[i]].providedTokens[token_] -= q;
                    } else {
                        providerInfo[providers[i]].providedTokens[token_] = 0;
                    }
                    // TOTAL RISKABLE
                    if (houseTotalRiskableBackup > r) {
                        houseTotalRiskableBackup -= r;
                    } else {
                        houseTotalRiskableBackup = 0;
                    }
                    // RISKABLE
                    if (providerInfo[providers[i]].riskable[token_] > r) {
                        providerInfo[providers[i]].riskable[token_] -= r;
                    } else {
                        providerInfo[providers[i]].riskable[token_] = 0;
                    }        
                }
            }
        }
        houseTotalRiskable[token_] = houseTotalRiskableBackup;
    }

    // The GAMBLE function! Receives, as parameters: an array of uint256 where every index from 0 to 36 represents a
    // number on the Roulette, and the value represents the bet the player put on every number; an address that
    // represents the token the player is gambling with. Bets like RED, BLACK, 1st 12, etc.. are "adjusted" by the frontend.
    //
    // EXAMPLE: Let's say a player bets 36 BUSD on ODD. When the frontend has to communicate it to the contract it
    // effectively just passes an array that has 'bet/18' (so 2) in every odd index in the array and 0 in the others (and
    // the BUSD address in token_). When the random number is called, if amount_[randomNumber] value is greater than 0
    // the player wins that amount multiplied by 36. Then, say the random number is an odd number, we said the bet is
    // 2 for every odd index in the array, so the win is 2 * 36 = 72. The win for red, black, odd and even is 1:1. And,
    // in fact, the player betted 36 and won 72. Pretty ez!
    //
    function gamble(uint256[] calldata amount_, address token_, address referrer_)
        external
        nonReentrant
        noContracts
        noUnbetableTokens(token_)
    {
        uint256 totalBet = 0;
        uint256 maxWinPossible = 0;

        for (uint i = 0; i <= 36; i++) {
            if (amount_[i] * 36 > maxWinPossible) {
                maxWinPossible = amount_[i] * 36;
            }

            totalBet += amount_[i];
        }

        require(IBEP20(token_).allowance(msg.sender, address(this)) >= totalBet, "Roulette::gamble: Allowance too low");
        require(totalBet >= 10000, "Roulette::gamble: Amount too small");

        if (maxWinPossible >= totalBet) {
            maxWinPossible -= totalBet;
            require(
                maxWinPossible <= houseTotalRiskable[token_],
                "Roulette::gamble: Max possible winnings higher than max House risk"
            );
        }

        require(
            totalBet <= IBEP20(token_).balanceOf(msg.sender),
            "Roulette::gamble: Not enough tokens"
        );

        uint256 txFeeAmount = (totalBet * txFee) / 10000;
        totalBet -= txFeeAmount;

        seed += (totalBet + maxWinPossible);
        uint256 randomNumber = IRandomNumberGenerator(randomAddress).requestRandomNumber(seed, 37);
        seed += randomNumber;

        if (amount_[randomNumber] > 0) {
            uint256 q = (txFeeAmount * 1e18) / (((totalBet + txFeeAmount) * 1e18) / amount_[randomNumber]);
            uint256 winAmount = (amount_[randomNumber] - q) * 36;
            uint256 winFeeAmount;
            uint256 referrerFeeAmount;
            
            if (token_ == gambleToken) {
                winFeeAmount = (winAmount * winFeeNative) / 10000;
            } else {
                winFeeAmount = (winAmount * winFee) / 10000;
            }

            if (isReferrer(referrer_)) {
                referrerFeeAmount = (winFeeAmount * referrerFee) / 10000;
                IHouse(houseAddress).payout(referrer_, referrerFeeAmount, token_);
            } else {
                referrerFeeAmount = 0;
            }

            if ((winAmount - winFeeAmount) > (totalBet + txFeeAmount)) { // If the win is higher than how much the player betted, providers lose a share in the House based on their riskable amount.
                IHouse(houseAddress).payout(msg.sender, (winAmount - winFeeAmount) - (totalBet + txFeeAmount), token_);
            } else if ((winAmount - winFeeAmount) < (totalBet + txFeeAmount)) { // If the win does not get a net reward to the player cause his total bet was higher, providers get a bump to their share, based on their riskable amount.
                IBEP20(token_).transferFrom(msg.sender, houseAddress, (totalBet + txFeeAmount) - (winAmount - winFeeAmount));
            }
            IHouse(houseAddress).payout(feeAddress, winFeeAmount - referrerFeeAmount, token_);
            IHouse(houseAddress).payout(ustFundAddress, txFeeAmount, token_);

            if (winAmount > totalBet) {
                updateProviders(token_, winAmount - totalBet, 1);
            } else if (winAmount < totalBet) {
                updateProviders(token_, totalBet - winAmount, 0);
            }

            lastWin = block.number;

            emit Gamble(winAmount - winFeeAmount, randomNumber);
        } else {
            // If the player loses, the whole bet (minus the tiny tx fee) goes to provider's shares in the House.
            IBEP20(token_).transferFrom(msg.sender, houseAddress, totalBet);
            IBEP20(token_).transferFrom(msg.sender, ustFundAddress, txFeeAmount);
            updateProviders(token_, totalBet, 0);

            emit Gamble(0, randomNumber);
        }
    }

    // Only callable by the owner. Adds a specific token to the list of tokens that can be provided (and then gambled).
    function allowToken(address token_) public onlyOwner {
        require (token_ != address(0));

        bool alreadyAdded = false;
        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i] == token_) {
                alreadyAdded = true;
                break;
            }
        }

        if (!alreadyAdded) {
            tokens.push(token_);
            IHouse(houseAddress).allowToken(token_);
        }
    }

    // Only callable by the owner. Allows a list of tokens.
    function allowTokenList(address[] calldata tokens_) external onlyOwner {
        for (uint i = 0; i < tokens_.length; i++) {
            allowToken(tokens_[i]);
        }
    }

    // Only callable by the owner. Adds a user to the whitelist (allowing them to be a referrer).
    function whitelistUser(address user_) public onlyOwner {
        require (user_ != address(0));

        bool alreadyAdded = false;
        for (uint i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == user_) {
                alreadyAdded = true;
                break;
            }
        }

        if (!alreadyAdded) {
            whitelist.push(user_);
        }
    }

    // Only callable by the owner. Whitelists a list of users.
    function whitelistUserList(address[] calldata users_) external onlyOwner {
        for (uint i = 0; i < users_.length; i++) {
            whitelistUser(users_[i]);
        }
    }

    // Checks if a user is whitelisted (so if they're allowed to be a referrer).
    function isReferrer(address user_) public view returns (bool) {
        if (user_ == address(0)) {
            return false;
        }
        
        for (uint i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == user_) {
                return true;
            }
        }

        return false;
    }

    // Only callable by the owner. Changes the House contract address.
    function setHouseAddress(address newHouseAddress_) external onlyOwner {
        require(
            newHouseAddress_ != address(0),
            "Roulette::setHouseAddress: House address cannot be the zero address"
        );
        emit SetHouseAddress(houseAddress, newHouseAddress_);

        houseAddress = newHouseAddress_;

        IHouse(houseAddress).addGame(address(this));
    }

    // Only callable by the owner. Changes address of the account that receives fees.
    function setFeeAddress(address newFeeAddress_) external onlyOwner {
        require(
            newFeeAddress_ != address(0),
            "Roulette::setFeeddress: Fee address cannot be the zero address"
        );

        emit SetFeeAddress(feeAddress, newFeeAddress_);

        feeAddress = newFeeAddress_;
    }

    // Only callable by the owner. Changes the UST Depeg Event victims fund address.
    function setUstFundAddress(address newUstFundAddress_) external onlyOwner {
        require(
            newUstFundAddress_ != address(0),
            "Roulette::setUstFundAddress: The UST Depeg Event victims fund address cannot be the zero address"
        );

        emit SetUstFundAddress(ustFundAddress, newUstFundAddress_);

        ustFundAddress = newUstFundAddress_;
    }

    // Only callable by the owner. Changes the RandomNumberGenerator contract address.
    function setRandomAddress(address newRandomAddress_) external onlyOwner {
        require(
            newRandomAddress_ != address(0),
            "Roulette::setRandomAddress: Random number generator address cannot be the zero address"
        );
        emit SetRandomAddress(randomAddress, newRandomAddress_);

        randomAddress = newRandomAddress_;

        IRandomNumberGenerator(randomAddress).addGame(address(this));
    }

    // Only callable by the owner. Changes address of the gamble native token.
    function setGambleAddress(address newGambleAddress_) external onlyOwner {
        emit SetGambleAddress(gambleToken, newGambleAddress_);

        gambleToken = newGambleAddress_;
    }

    // Only callable by the owner. Changes fees.
    function setFees(uint256 winFee_, uint256 winFeeNative_, uint256 txFee_, uint256 withdrawFee_, uint referrerFee_) external onlyOwner {
        require(
            winFee_ <= MAX_WIN_FEE && winFeeNative_ <= MAX_WIN_FEE_NATIVE && txFee_ <= MAX_TX_FEE && withdrawFee_ <= MAX_WITHDRAW_FEE && referrerFee_ <= MAX_REFERRER_FEE,
            "Roulette::setFees: Fees cannot be greater than their hard coded maximum value"
        );
        emit SetFees(winFee, winFee_, winFeeNative, winFeeNative_, txFee, txFee_, withdrawFee, withdrawFee_, referrerFee, referrerFee_);

        winFee = winFee_;
        winFeeNative = winFeeNative_;
        txFee = txFee_;
        withdrawFee = withdrawFee_;
        referrerFee = referrerFee_;
    }

    // Retrieves information about tokens Providers.
    function tokenProviderInfo(address user_, address token_) external view returns (uint256 provided, uint256 riskable) {
        return (providerInfo[user_].providedTokens[token_], providerInfo[user_].riskable[token_]);
    }


    /* [OFP] */
    // Returns the total wins in USD for the Roulette game, to be prompted on the frontend.
    function totalGlobalWinsUSDLocal(bool human_) external view returns (uint256 totalWins) {
        uint256 total = 0;
        for (uint i = 0; i < tokens.length; i++) {
            total += IPriceCalculator(priceCalc).getUSDValue(tokens[i],tokenWinAmount[tokens[i]]);
        }
        if (human_) {
            return total / 1e18;
        }
        return total;
    }

    // Returns the total providers' riskables in USD for the Roulette game, to be prompted on the frontend.
    function totalHouseRiskableUSDLocal(bool human_) external view returns (uint256 totalRiskable) {
        uint256 total = 0;
        for (uint i = 0; i < tokens.length; i++) {
            total += IPriceCalculator(priceCalc).getUSDValue(tokens[i],houseTotalRiskable[tokens[i]]);
        }
        if (human_) {
            return total / 1e18;
        }
        return total;
    }

    // Returns the address of an allowed token from its symbol.
    function getAllowedTokenAddressFromSymbol(string memory symbol_) external view returns (address allowedToken) {
        for (uint i = 0; i < tokens.length; i++) {
            if (keccak256(bytes(IBEP20(tokens[i]).symbol())) == keccak256(bytes(symbol_))) {
                return tokens[i];
            }
        }
        return address(0);
    }

    // Returns the allowed token addresses array.
    function getTokens() external view returns (address[] memory allowedTokens) {
        return tokens;
    }

    // Returns the tokens provided from msg.sender.
    function getUserProvidedTokens(address caller_) external view returns (address[] memory providedTokens) {
        uint256 size = 0;
        for (uint i = 0; i < tokens.length; i++) {
            if (providerInfo[caller_].providedTokens[tokens[i]] > 0) {
                size++;
            }
        }
        address[] memory provideds = new address[](size);
        uint256 index = 0;
        for (uint i = 0; i < tokens.length; i++) {
            if (providerInfo[caller_].providedTokens[tokens[i]] > 0) {
                provideds[index] = tokens[i];
                index++;
            }
        }
        return provideds;
    }
    
    // Only callable by the owner. Changes the PriceCalculator contract address.
    function setPriceCalcAddress(address newPriceCalcAddress_) external onlyOwner {
        require(
            newPriceCalcAddress_ != address(0),
            "Roulette::setPriceCalcAddress: Price calculator address cannot be the zero address"
        );
        emit SetPriceCalcAddress(priceCalc, newPriceCalcAddress_);

        priceCalc = newPriceCalcAddress_;
    }
    /* [OFP] */
}