/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// SPDX-License-Identifier: MIT
// MFET - Multi Functional Environmental Token
// We are Developing New Generation Projects and Funding These Projects with Green Blockchain.

// A Sustainable World
// MFET is an ecosystem that supports sustainable projects, provides mentoring to companies in carbon footprint studies,
// provides consultancy on environmental and climate studies, and makes decisions without being dependent on an authority
// with the community it has created, thanks to the blockchain.

// MFET - Stake Contract

// Mens et Manus

/// Locked solidity version
pragma solidity 0.8.17;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
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
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
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
     * by making the `nonReentrant` function external, and make it call a
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

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /* @dev Subtracts two numbers, else returns zero */
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract MFETVault is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    /*=================================
    =            MODIFIERS            =
    =================================*/

    /// @dev Only people with profits
    modifier onlyInvestors() {
        require(myDividends() > 0);
        _;
    }

    /// @dev check origin to avoid attacks
    modifier onlyEOA() {
        require(tx.origin == _msgSender(), "should be EOA");
        _;
    }

    /*==============================
    =            EVENTS            =
    ==============================*/

    event onLeaderBoard(
        address indexed customerAddress,
        uint256 invested,
        uint256 tokens,
        uint256 soldTokens,
        uint256 timestamp
    );

    event onTokenInvest(
        address indexed customerAddress,
        uint256 tokensInvested,
        uint256 timestamp
    );

    event onTokenExit(
        address indexed customerAddress,
        uint256 tokensTransfered,
        uint256 timestamp
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 tokensInvested,
        uint256 timestamp
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 withdrawnTokens,
        uint256 timestamp
    );

    event onBalance(uint256 tokenBalance, uint256 timestamp);

    event onRewardTokenAdded(uint256 rewardAmount, uint256 timestamp);

    /// Onchain Stats!!!
    struct Stats {
        uint256 invested;
        uint256 reinvested;
        uint256 withdrawn;
        uint256 taxes;
        uint256 xInvested;
        uint256 xReinvested;
        uint256 xWithdrawn;
    }

    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/

    /// @dev 10% distribute every deposit and withdraw
    uint8 internal constant entryFee_ = 10;
    uint8 internal constant exitFee_ = 10;

    /// @dev %40 drip %40 instant %20 locked
    uint8 internal constant dripFee = 40;
    uint8 internal constant instantFee = 40;

    uint8 private payoutRate_ = 10;

    uint256 internal magnitude = 10**10;

    uint256 constant MAX_UINT = 2**256 - 1;

    /*=================================
     =            DATASETS            =
     ================================*/

    // amount of shares for each address (scaled number)
    mapping(address => uint256) private tokenBalanceLedger_;
    mapping(address => int256) private payoutsTo_;
    mapping(address => Stats) private stats;

    //on chain referral tracking
    uint256 private tokenSupply_;
    uint256 private profitPerShare_;
    uint256 internal lastBalance_;

    uint256 public totalDeposits;
    uint256 public totalWithdrawn;
    uint256 private lockedBalance;
    uint256 private totalRewards;

    uint256 public players;
    uint256 public totalTxs;
    uint256 public dividendBalance;

    uint256 public lastPayout = block.timestamp;
    uint256 public totalClaims;

    uint256 public balanceInterval = 30 seconds;
    uint256 public distributionInterval = 1 seconds;
    uint256 public minInvest = 1000 * 10**8;

    IBEP20 private cToken = IBEP20(0xe5C06Ed88c8cCE4667946FdA10ae2cb69dEaaA96);

    /*=======================================
    =            RECOVERY FUNCTIONS         =
    =======================================*/

    receive() external payable {}

    /// @dev BEP20 Token
    function recoverBEP20(
        address _token,
        uint256 _amount,
        address _to
    ) external onlyOwner {
        IBEP20(_token).transfer(_to, _amount);
    }

    /// @dev Native Token BNB
    function recoverBNB(address payable to) public onlyOwner {
        require(address(this).balance > 0, "zero native balance");
        to.transfer(address(this).balance);
    }

    /*=======================================
    =            CALCULATION FUNCTIONS      =
    =======================================*/

    /// @dev change payoutrate in limits
    function changePayoutRate(uint8 _rate) public onlyOwner {
        require(_rate >= 2 && _rate <= 100, "must between 2-100");
        payoutRate_ = _rate;
    }

    /*=======================================
    =            PUBLIC FUNCTIONS           =
    =======================================*/
    /// @dev reward investors
    function reward(uint256 _reward)
        external
        nonReentrant
        onlyEOA
        returns (uint256)
    {
        require(_reward >= minInvest, "min invest 1000 MFET");
        totalDeposits += _reward;
        cToken.transferFrom(msg.sender, address(this), _reward);
        return rewardInvestors(_reward);
    }

    /// @dev invest with tokens
    function invest(uint256 _investAmount)
        external
        onlyEOA
        nonReentrant
        returns (uint256)
    {
        require(_investAmount >= minInvest, "min invest 1000 MFET");
        totalDeposits += _investAmount;
        cToken.transferFrom(msg.sender, address(this), _investAmount);
        return investing(msg.sender, _investAmount);
    }

    /// @dev invest with tokens
    function investFor(uint256 _investAmount, address _customerAddress)
        external
        onlyEOA
        nonReentrant
        returns (uint256)
    {
        require(_investAmount >= minInvest, "min invest 1000 MFET");
        totalDeposits += _investAmount;
        cToken.transferFrom(msg.sender, address(this), _investAmount);
        return investing(_customerAddress, _investAmount);
    }

    /// @dev Converts all of caller's dividends to tokens.
    function reinvest()
        external
        onlyEOA
        nonReentrant
        onlyInvestors
        returns (uint256)
    {
        // fetch dividends
        uint256 _dividends = myDividends();
        // retrieve ref. bonus later in the code

        // pay out the dividends virtually
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);

        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint256 _tokens = investTokens(msg.sender, _dividends);

        // fire event
        emit onReinvestment(_customerAddress, _tokens, block.timestamp);

        //Stats
        stats[_customerAddress].reinvested = SafeMath.add(
            stats[_customerAddress].reinvested,
            _tokens
        );
        stats[_customerAddress].xReinvested += 1;

        emit onLeaderBoard(
            _customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            block.timestamp
        );

        //distribute
        distribute();

        return _tokens;
    }

    /// @dev Withdraws all of the callers earnings.
    function withdraw()
        external
        onlyEOA
        nonReentrant
        onlyInvestors
        returns (uint256)
    {
        // setup data
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(); // 100% of divs

        // update dividend tracker
        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);

        totalWithdrawn += _dividends;

        //stats
        stats[_customerAddress].withdrawn = SafeMath.add(
            stats[_customerAddress].withdrawn,
            _dividends
        );
        stats[_customerAddress].xWithdrawn += 1;
        totalTxs += 1;
        totalClaims += _dividends;

        cToken.transfer(msg.sender, _dividends);

        // fire event
        emit onWithdraw(_customerAddress, _dividends, block.timestamp);

        emit onLeaderBoard(
            _customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            block.timestamp
        );

        //distribute
        distribute();

        return _dividends;
    }

    function exit(uint256 _amountOfTokens)
        external
        onlyEOA
        nonReentrant
        onlyInvestors
    {
        // setup data
        address _customerAddress = msg.sender;

        require(
            _amountOfTokens <= tokenBalanceLedger_[_customerAddress],
            "More then withdrawn"
        );

        // data setup
        uint256 _undividedDividends = SafeMath.mul(_amountOfTokens, exitFee_) /
            100;

        uint256 _taxedAmount = SafeMath.sub(
            _amountOfTokens,
            _undividedDividends
        );

        // remove from supply sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _amountOfTokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );

        // update dividends tracker
        int256 _updatedPayouts = (int256)(
            profitPerShare_ * _amountOfTokens + (_taxedAmount * magnitude)
        );

        payoutsTo_[_customerAddress] -= _updatedPayouts;

        /// update stats
        stats[_customerAddress].taxes += _undividedDividends;

        //drip and buybacks
        allocateFees(_undividedDividends);

        cToken.transfer(msg.sender, _amountOfTokens);

        // fire event
        emit onTokenExit(_customerAddress, _taxedAmount, block.timestamp);

        //distribute
        distribute();
    }

    /*=====================================
    =      HELPERS AND CALCULATORS        =
    =====================================*/

    /**
     * @dev Method to view the current eth stored in the contract
     */

    /// @dev Stats of any single address
    function statsOf(address _customerAddress)
        external
        view
        returns (uint256[7] memory)
    {
        Stats memory s = stats[_customerAddress];
        uint256[7] memory statArray = [
            s.invested,
            s.reinvested,
            s.withdrawn,
            s.taxes,
            s.xInvested,
            s.xReinvested,
            s.xWithdrawn
        ];
        return statArray;
    }

    /// @dev Retrieve the profit per share amount
    function profitPerShare() external view returns (uint256) {
        return profitPerShare_;
    }

    /// contract locked tokens
    function lockedTokenBalance() external view returns (uint256) {
        return lockedBalance;
    }

    /// total rewards that contract owner distribute
    function totalTokenRewards() external view returns (uint256) {
        return totalRewards;
    }

    /// @dev Retrieve the total token supply.
    function totalSupply() external view returns (uint256) {
        return tokenSupply_;
    }

    function totalTokenBalance() public view returns (uint256) {
        return cToken.balanceOf(address(this));
    }

    /// @dev Retrieve the tokens owned by the caller.
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    /// @dev Retrieve the dividends owned by the caller.
    function myDividends() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return dividendsOf(_customerAddress);
    }

    /// @dev Retrieve the daily estimate tokens owned by the caller.
    function myDailyEstimate() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return dailyEstimate(_customerAddress);
    }

    /// @dev Retrieve the token balance of any single address.
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    /// @dev Retrieve the dividend balance of any single address.
    function dividendsOf(address _customerAddress)
        public
        view
        returns (uint256)
    {
        return
            (uint256)(
                (int256)(
                    profitPerShare_ * tokenBalanceLedger_[_customerAddress]
                ) - payoutsTo_[_customerAddress]
            ) / magnitude;
    }

    /// @dev Calculate daily estimate of swap tokens awarded
    function dailyEstimate(address _customerAddress)
        public
        view
        returns (uint256)
    {
        uint256 share = dividendBalance.mul(payoutRate_).div(100);
        return
            (tokenSupply_ > 0)
                ? share.mul(tokenBalanceLedger_[_customerAddress]).div(
                    tokenSupply_
                )
                : 0;
    }

    /// @dev get details easy to web pages
    function getDetailsOfContractAtOnce()
        external
        view
        returns (uint256[11] memory)
    {
        uint256[11] memory contractArray = [
            tokenSupply_,
            totalDeposits,
            totalWithdrawn,
            totalRewards,
            totalClaims,
            dividendBalance,
            profitPerShare_,
            players,
            totalTxs,
            lastPayout,
            minInvest
        ];
        return contractArray;
    }

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/

    /// @dev all action start here
    function investing(address _customerAddress, uint256 _investAmount)
        internal
        returns (uint256)
    {
        uint256 amount = investTokens(_customerAddress, _investAmount);

        emit onLeaderBoard(
            _customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            block.timestamp
        );

        //distribute
        distribute();

        return amount;
    }

    /// @dev Distribute undividend in and out fees across drip pools and instant divs
    function allocateFees(uint256 fee) private {
        uint256 _drip = fee.mul(dripFee).div(100); //40
        uint256 _instant = fee.mul(instantFee).div(100); //40
        uint256 _lock = fee.safeSub(_drip + _instant); //100 -80

        if (tokenSupply_ > 0) {
            //Apply divs
            profitPerShare_ = SafeMath.add(
                profitPerShare_,
                (_instant * magnitude) / tokenSupply_
            );
        }
        //Add to dividend drip pools
        dividendBalance += _drip;

        //Add locked tokens to global count
        lockedBalance += _lock;
    }

    // @dev Distribute drip pools
    function distribute() private {
        // @Bb updates balance data of contract
        if (
            block.timestamp.safeSub(lastBalance_) > balanceInterval &&
            totalTokenBalance() > 0
        ) {
            uint256 tokenAmount = totalTokenBalance();
            emit onBalance(tokenAmount, block.timestamp);
            lastBalance_ = block.timestamp;
        }

        if (
            SafeMath.safeSub(block.timestamp, lastPayout) >
            distributionInterval &&
            tokenSupply_ > 0
        ) {
            //A portion of the dividend is paid out according to the rate
            uint256 share = dividendBalance.mul(payoutRate_).div(100).div(
                24 hours
            );
            //divide the profit by seconds in the day
            uint256 profit = share * block.timestamp.safeSub(lastPayout);
            //share times the amount of time elapsed
            dividendBalance = dividendBalance.safeSub(profit);

            //Apply divs
            profitPerShare_ = SafeMath.add(
                profitPerShare_,
                (profit * magnitude) / tokenSupply_
            );

            lastPayout = block.timestamp;
        }
    }

    /// @dev Internal function to actualy invest tokens
    function investTokens(address _customerAddress, uint256 _incomingtokens)
        internal
        returns (uint256)
    {
        /* Members */
        if (stats[_customerAddress].invested == 0) {
            players += 1;
        }

        totalTxs += 1;

        // calculate the amount that will go to fee
        uint256 _undividedDividends = SafeMath.mul(_incomingtokens, entryFee_) /
            100; // 40% of drops
        uint256 _amountOfTokens = SafeMath.sub(
            _incomingtokens,
            _undividedDividends
        ); // 90% of drops (100% - 10% above)

        // fire event
        emit onTokenInvest(_customerAddress, _incomingtokens, block.timestamp);

        // yes we know that the safemath function automatically rules out the "greater then" equation.
        require(
            _amountOfTokens > 0 &&
                SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_,
            "Tokens need to be positive"
        );

        // we can't give people infinite eth
        if (tokenSupply_ > 0) {
            // add tokens to the pool
            tokenSupply_ += _amountOfTokens;
        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }

        //drip and buybacks; instant requires being called after supply is updated
        allocateFees(_undividedDividends);

        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );

        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;
        int256 _updatedPayouts = (int256)(profitPerShare_ * _amountOfTokens);
        payoutsTo_[_customerAddress] += _updatedPayouts;

        //Stats
        stats[_customerAddress].taxes += _undividedDividends;
        stats[_customerAddress].invested += _incomingtokens;
        stats[_customerAddress].xInvested += 1;

        return _amountOfTokens;
    }

    /// @dev reward internal function
    function rewardInvestors(uint256 _rewards) internal returns (uint256) {
        totalRewards += _rewards;
        emit onRewardTokenAdded(_rewards, block.timestamp);

        require(
            _rewards > 0 && SafeMath.add(_rewards, tokenSupply_) > tokenSupply_,
            "Tokens need to be positive"
        );

        // we can't give people infinite eth
        if (tokenSupply_ > 0) {
            // add tokens to the pool
            tokenSupply_ += _rewards;
        } else {
            // add tokens to the pool
            tokenSupply_ = _rewards;
        }

        // directly share rewards
        if (tokenSupply_ > 0) {
            //Apply divs
            profitPerShare_ = SafeMath.add(
                profitPerShare_,
                (_rewards * magnitude) / tokenSupply_
            );
        }

        distribute();

        return _rewards;
    }
}
// Made with love.