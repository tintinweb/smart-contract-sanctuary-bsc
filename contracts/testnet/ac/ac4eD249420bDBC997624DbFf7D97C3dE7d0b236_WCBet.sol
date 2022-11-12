/**
 *Submitted for verification at BscScan.com on 2022-11-11
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

// File: WCBet.sol


pragma solidity ^0.8.0;


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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

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

contract WCBet is Ownable, ReentrancyGuard {
    struct Match {
        uint256 league;
        string host;
        string guest;
        uint256 start;
        uint256[3] wdl;
        uint256[7][7] exactScore; // 0-0 -> 6-6
        uint256[4] sumScore; // 0, 1-2, 3-4, 4-6, 7+ 
        uint256[2] parityScore; // even/odd
        uint256 hostScore;
        uint256 guestScore;
        bool ended;
    }

    /*
    wdl:    bet0 > bet1 => host win
            bet0 == bet1 => draw
            bet0 < bet1 => guest win
    exact: bet0 (host score), bet1 (guest score)
    sum:    bet0 = 0 -> 0-1 score
            bet0 = 1 -> 2-3 score
            bet0 = 2 -> 4-6 score
            bet0 = 3 -> 7+ score
    parity: bet0 = 0 -> even
            bet0 = 1-> odd
    */
    struct Bet {
        uint256 bet; // 0 - wdl, 1 - exact, 2 - sum, 3 - parity
        uint256 bet0;
        uint256 bet1;
        uint256 amount;
    }

    uint256 lastMatchId;
    mapping(uint256 => Match) public matchs;

    // address -> matchId -> bet -> Bet
    mapping(address => mapping(uint256 => mapping(uint256 => Bet))) public bets;
    // address -> matchId 
    mapping(address => mapping(uint256 => bool)) public claimed;

    event SetMatch(uint256 matchId, uint256 league, string host, string guest, uint256 start);
    event UpdateMatchScore(uint256 matchId, uint256 host, uint256 guest);
    event UserBet(
        address indexed user, 
        uint256 indexed matchId, 
        uint256 indexed  bet, 
        uint256 bet0, 
        uint256 bet1, 
        uint256 amount
    );
    event Claim(address indexed user, uint256 indexed matchId);

    modifier validMatchId(uint256 _matchId) {
        require(_matchId < lastMatchId, "Invalid match ID");
        _;
    }

    modifier onlyMatchNotStart(uint256 _matchId) {
        require(matchs[_matchId].start > block.timestamp, "Match is STARTED");
        _;
    }

    modifier onlyMatchNotEnded(uint256 _matchId) {
        require(!matchs[_matchId].ended, "Match is ENDED");
        _;
    }

    modifier onlyMatchEnded(uint256 _matchId) {
        require(matchs[_matchId].ended, "Match is NOT ENDED");
        _;
    }
    
    function _setMatch(
        uint256 _matchId,
        uint256 _league,
        string memory _host, 
        string memory _guest,
        uint256 _start,
        uint256[3] memory _wdl,
        uint256[7][7] memory _exactScore,
        uint256[4] memory _sumScore,
        uint256[2] memory _parityScore
    ) private onlyOwner {
        Match storage m = matchs[_matchId];
        m.league = _league;
        m.host = _host;
        m.guest = _guest;
        m.start = _start;
        m.wdl = _wdl;
        m.exactScore = _exactScore;
        m.sumScore = _sumScore;
        m.parityScore = _parityScore;
        emit SetMatch(_matchId, _league, _host, _guest, _start);
    }

    function addMatch(
        uint256 _league,
        string memory _host, 
        string memory _guest, 
        uint256 _start,
        uint256[3] memory _wdl,
        uint256[7][7] memory _exactScore,
        uint256[4] memory _sumScore,
        uint256[2] memory _parityScore
    ) external onlyOwner {
        _setMatch(lastMatchId, _league, _host, _guest, _start, _wdl, _exactScore, _sumScore, _parityScore);
        lastMatchId++;
    }

    function updateMatch(
        uint256 _matchId,
        uint256 _league,
        string memory _host, 
        string memory _guest, 
        uint256 _start,
        uint256[3] memory _wdl,
        uint256[7][7] memory _exactScore,
        uint256[4] memory _sumScore,
        uint256[2] memory _parityScore
    ) external onlyOwner onlyMatchNotEnded(_matchId) {
        _setMatch(_matchId, _league, _host, _guest, _start, _wdl, _exactScore, _sumScore, _parityScore);
    }

    function getMatch(uint256 _matchId) public view returns (Match memory) {
        return matchs[_matchId];
    }

    function updateMatchScore(
        uint256 _matchId, 
        uint256 _host, 
        uint256 _guest
    ) external onlyOwner {
        Match storage m = matchs[_matchId];
        m.hostScore = _host;
        m.guestScore = _guest;
        m.ended = true;
        emit UpdateMatchScore(_matchId, _host, _guest);
    }

    function bet(
        uint256 _matchId,
        uint256 _bet, // 0 - wdl, 1 - exact, 2 - sum, 3 - parity
        uint256 _bet0,
        uint256 _bet1,
        uint256 _amount
    ) external validMatchId(_matchId) onlyMatchNotStart(_matchId) onlyMatchNotEnded(_matchId) nonReentrant {
        require(_bet < 4, "Invalid Bet type");
        if(_bet == 1) {
            require(_bet0 < 7 && _bet1 < 7, "Invalid: Bet exact score in 0 -> 6");
        }
        if(_bet == 2) {
            require(_bet0 < 4, "Invalid: Bet total score in 0 -> 3");
        }
        if(_bet == 3) {
            require(_bet0 < 2, "Invalid: Bet even/odd score in 0 -> 1");
        }
        (bool sent,) = address(this).call{value: _amount}("");
        require(sent, "Transfer bet amount failed");
        Bet storage b = bets[msg.sender][_matchId][_bet];
        b.bet0 = _bet0;
        b.bet1 = _bet1;
        b.bet = _bet;
        b.amount += _amount;
        emit UserBet(msg.sender, _matchId, _bet, _bet0, _bet1, _amount);
    }

    function _calculateBet(uint256 _matchId, Bet memory _bet) private view returns(uint256) {
        Match memory m = matchs[_matchId];
        bool isWinner;
        uint256 rate;
        if(_bet.bet == 0) { // WDL
            uint256 result = m.hostScore > m.guestScore ? 0 : m.hostScore == m.guestScore ? 1 : 2;
            if(_bet.bet0 > _bet.bet1 && result == 0) { // host win
                isWinner = true;
                rate = m.wdl[0];
            }
            if(_bet.bet0 == _bet.bet1 && result == 1) { // draw
                isWinner = true;
                rate = m.wdl[1];
            }
            if(_bet.bet0 < _bet.bet1 && result == 2) { // guest win
                isWinner = true;
                rate = m.wdl[2];
            }
        }
        if(_bet.bet == 1) { // exact score
            if(_bet.bet0 == m.hostScore && _bet.bet1 == m.guestScore) {
                isWinner = true;
                rate = m.exactScore[_bet.bet0][_bet.bet1];
            }
        }
        uint256 sumScore = m.hostScore + m.guestScore;
        if(_bet.bet == 2) { // sum score
            if(_bet.bet0 == 0 && sumScore >= 0 && sumScore < 2) { // 0-1 score
                isWinner = true;
                rate = m.sumScore[0];
            }
            if(_bet.bet0 == 1 && sumScore > 1 && sumScore < 4) { // 2-3 score
                isWinner = true;
                rate = m.sumScore[1];
            }
            if(_bet.bet0 == 2 && sumScore > 3 && sumScore < 7) { // 4-6 score
                isWinner = true;
                rate = m.sumScore[2];
            }
            if(_bet.bet0 == 3 && sumScore > 6) { // 7+ score
                isWinner = true;
                rate = m.sumScore[3];
            }
        }
        if(_bet.bet == 3) { // parity score
            if(_bet.bet0 == 0 && sumScore % 2 == 0) { // even
                isWinner = true;
                rate = m.parityScore[0];
            }
            if(_bet.bet0 == 1 && sumScore % 2 == 1) { // odd
                isWinner = true;
                rate = m.parityScore[1];
            }
        }

        return isWinner ? _bet.amount + (_bet.amount * rate) / 1000 : 0;
    }

    function pendingReward(uint256 _matchId) public view validMatchId(_matchId) onlyMatchEnded(_matchId) returns(uint256) {
        require(!claimed[msg.sender][_matchId], "Claimed");
        uint256 amount;
        Bet memory b;
        for(uint256 i=0; i<4; i++) {
            b = bets[msg.sender][_matchId][i];
            if(b.amount != 0) {
                amount += _calculateBet(_matchId, b);
            }
        }
        return amount;
    }

    function claim(uint256 _matchId) external validMatchId(_matchId) onlyMatchEnded(_matchId) {
        require(!claimed[msg.sender][_matchId], "Claimed");
        uint256 amount = pendingReward(_matchId);
        claimed[msg.sender][_matchId] = true;
        require(amount > 0, "Lose or Claimed");
        if(amount > 0) {
            require(address(this).balance >= amount, "Not enough token in pool to claim");
            (bool sent,) = msg.sender.call{value: amount}("");
            require(sent, "Transfer claim amount failed");
            emit Claim(msg.sender, _matchId);
        }
    }
}