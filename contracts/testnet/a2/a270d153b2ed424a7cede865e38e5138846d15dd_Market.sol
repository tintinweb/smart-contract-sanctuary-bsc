/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

// SPDX-License-Identifier: MIT

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

// File: contracts/interface/IWeb3BetsFO.sol



pragma solidity ^0.8.4;

interface IWeb3BetsFO{
    function holdAddr() external view returns(address);

    function ecoAddr() external view returns(address);

    function scAddr() external view returns(address);

    function hVig() external view returns(uint256);

    function eVig() external view returns(uint256);

    function aVig() external view returns(uint256);

    function vig() external view returns(uint256);

    function minStake() external view returns(uint256);

    function isBlack(address _addr) external view returns(bool);
    
    function getEvents() external view returns(bytes32[] memory);

    function getMarkets(bytes32 _event) external view returns(address[] memory);
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

// File: contracts/interface/IMarket.sol



pragma solidity ^0.8.4;


interface IMarket{
    struct MarketBet {
        address better;
        address affiliate;
        uint256 stake;
        uint256 matched;
        uint256 odds;
        uint256 side;
    }
    function status() external view returns (uint256);

    function getBalance(address _user) external view returns(uint256);

    function getUserBets(address _user) external view returns(MarketBet[] memory);

    function withdraw(address _address) external returns(bool);

    function cancelPending(bytes32 _bet) external;

    function settleBet(bytes32 _bet) external;
    /*
    @dev 1: side A is winner, 2: side B is winer
    */
    function settle(uint256 _winningSide) external returns(bool);

    function cancelMarket() external returns(bool);

    function start() external;

    function addBet(
        address _better,
        address _affiliate,
        uint256 _stake,
        uint256 _odds,
        uint256 _side,
        bool instant
    ) external returns(bytes32);

}
// File: contracts/Market.sol



pragma solidity ^0.8.4;




contract Market is IMarket, ReentrancyGuard {
    address private factory;
    /*
    @dev status of a market, 0: active, 1: sideA wins, 2: side B wins, 3: canceled, 4: stop
    */
    uint256 public override status = 0;
    /*
    @dev stores the hash of all bets
    */
    bytes32[] private pairs;
    /*
    @dev stores the hash of all bets
    */
    bytes32[] private bets;
    /*
    @dev stores the hash of all pending bets
    */
    bytes32[] private pendingBets;
    struct MarketPair {
        bytes32 betHashA;
        bytes32 betHashB;
        uint256 amountA;
        uint256 amountB;
        bool settled;
    }
    mapping(address => uint256) private bal;
    mapping(bytes32 => MarketBet) private betsInfo;
    mapping(address => bytes32[]) private userBets;
    mapping(bytes32 => MarketPair) private pairsInfo;
    mapping(bytes32 => bytes32[]) private betPairs;
    IERC20 immutable private token;
    IWeb3BetsFO immutable private app = IWeb3BetsFO(factory);

    modifier onlyFactory() {
        require(
            msg.sender == factory,
            "M1"
        );
        _;
    }

    event BetCreated(
        address better,
        address marketAddr,
        bytes32 hash,
        uint256 stake,
        uint256 odds,
        uint256 side
    );

    event PairCreated(
        bytes32 betHashA,
        bytes32 betHashB,
        uint256 amountA,
        uint256 amountB
    );

    constructor() {
        factory = msg.sender;
        token = IERC20(IWeb3BetsFO(factory).scAddr());
    }

    function getBalance(address _user) external view override returns(uint256) {
        return bal[_user];
    }

    function getUserBets(address _user) external view override returns(MarketBet[] memory) {
        MarketBet[] memory _userBets;
        bytes32[] memory _bets = userBets[_user];
        for(uint i = 0; i < bets.length; i++){
            _userBets[i] = betsInfo[_bets[i]];
        }
        return _userBets;
    }

    function withdraw(address _addr) public override nonReentrant returns(bool) {
        uint256 availAmount = bal[_addr];
        require(token.balanceOf(address(this)) > availAmount && availAmount > 0, "M2");
        require(token.transfer(_addr, availAmount), "M3");
        bal[_addr] -= availAmount;
        return true;
    } 
 
    function cancelPending(bytes32 _bet) external override nonReentrant {
        MarketBet memory bet = betsInfo[_bet];
        require(msg.sender == bet.better, "M4");
        uint remStake = bet.stake - bet.matched;
        bal[bet.better] = remStake;
        betsInfo[_bet].matched = bet.stake;
        // remove from pending bets
        for(uint i = 0; i < pendingBets.length; i++){
            if(pendingBets[i] == _bet) {
                delete pendingBets[i];
            }
        }
    }

    function settleBet(bytes32 _bet) external override {
        bytes32[] memory _pairs = betPairs[_bet];
        for(uint i = 0; i < _pairs.length; i++){
            _settlePair(_pairs[i]);
        }
        if(bal[msg.sender] > 0){
            withdraw(msg.sender);
        }
    }

    function settle(uint256 _winningSide)
        external
        override
        onlyFactory
        returns(bool)
    {
        require ((status == 0 || status == 4) && (_winningSide == 1 || _winningSide == 2), "M5");
        status = _winningSide;
        for(uint i = 0; i < pairs.length; i++){
            _settlePair(pairs[i]);
        }
        return true;
    }

    function cancelMarket() external override onlyFactory returns(bool) 
    { 
        require(status == 0 || status == 4, "M6");
        for(uint i = 0; i < pairs.length; i++){
            _cancelPair(pairs[i]);
        }
        status = 3;
        return true;
    }

    function start() external override onlyFactory {
        require(status == 0, "M7");
        status = 4;
        return;
    }

    function addBet(
        address _better,
        address _affiliate,
        uint256 _stake,
        uint256 _odds,
        uint256 _side,
        bool _instant
    ) 
    external
    override
    returns(bytes32)
    {
        require(!app.isBlack(msg.sender) && status == 0, "M8");
        require(_side == 1 || _side == 2, "M9");
        require(token.allowance(msg.sender, address(this)) >= _stake && _stake >= app.minStake(), "M10");
        require(token.transferFrom(msg.sender, address(this), _stake), "M11");
        bytes32 betHash = _createBet(_better, _affiliate, _stake, 0, (_odds * 100) / (_odds - 100), _side);
        // _odds is the odds the better inputed which represents the min odds they want to receive
        // (_odds * 100) / (_odds - 100) is the complement of _odds, it represents the max odds the better offer to pay
        if(pendingBets.length > 0){
            uint _remStake = _stake;
            while(_remStake >= app.minStake()){
                uint selectedIndex = 0;
                uint256 maxOdds = 0;
                for(uint i = 0; i < pendingBets.length; i++){
                    bytes32 pBet = pendingBets[i];
                    if(_side == betsInfo[pBet].side){
                        continue;
                    }
                    if(betsInfo[pBet].odds>maxOdds){
                        maxOdds = betsInfo[pBet].odds;
                        selectedIndex = i;
                    }
                }
                if(maxOdds > _odds || _instant) {
                    bytes32 selectedHash = pendingBets[selectedIndex];
                    MarketBet memory selectedBet = betsInfo[selectedHash];
                    uint offeredStake = (selectedBet.stake - selectedBet.matched) / (_odds - 100);
                    offeredStake *= 100;
                    uint betterAmount;
                    uint makerAmount;
                    bytes32 pairHash;
                    if(offeredStake <= _stake) {
                        betterAmount = offeredStake;
                        makerAmount = offeredStake * (_odds - 100);
                        makerAmount /= 100;
                        if(_side == 1){
                            pairHash = _createPair(betHash,selectedHash,betterAmount,makerAmount);
                            emit PairCreated(betHash,selectedHash,betterAmount,makerAmount);
                        }
                        else if(_side == 2){
                            pairHash = _createPair(selectedHash,betHash,makerAmount,betterAmount);
                            emit PairCreated(selectedHash,betHash,makerAmount,betterAmount);
                        }
                    }
                    else {
                        betterAmount = _stake;
                        makerAmount = _stake * (_odds - 100);
                        makerAmount /= 100;
                        if(_side == 1){
                            pairHash = _createPair(betHash,selectedHash,betterAmount,makerAmount);
                            emit PairCreated(betHash,selectedHash,betterAmount,makerAmount);
                        }
                        else if(_side == 2){
                            pairHash = _createPair(selectedHash,betHash,makerAmount,betterAmount);
                            emit PairCreated(selectedHash,betHash,makerAmount,betterAmount);
                        }
                    }
                    betPairs[betHash].push(pairHash);
                    betPairs[selectedHash].push(pairHash);
                    betsInfo[betHash].matched += betterAmount;
                    betsInfo[selectedHash].matched += makerAmount;
                    if(betsInfo[selectedHash].stake - betsInfo[selectedHash].matched == 0) {
                        delete pendingBets[selectedIndex];
                    }
                    _remStake -= betterAmount;
                }
                else {
                    pendingBets.push(betHash);
                    break;
                }
            }
        }
        else {
            pendingBets.push(betHash);
        }
        emit BetCreated(msg.sender, address(this), betHash, _stake, _odds, _side);
        return betHash;
    }

    function _cancelPair(bytes32 _pair) private {
        address betterA = betsInfo[pairsInfo[_pair].betHashA].better;
        address betterB = betsInfo[pairsInfo[_pair].betHashB].better;
        bal[betterA] += pairsInfo[_pair].amountA;
        bal[betterB] += pairsInfo[_pair].amountB;
        pairsInfo[_pair].settled = true;
        return;
    }
    
    function _settlePair(bytes32 _pair) private nonReentrant {
        require(!pairsInfo[_pair].settled, "M12");
        address winner;
        address affiliate;
        uint256 winAmount;
        uint256 vigAmount;
        if(status == 1){
            winner = betsInfo[pairsInfo[_pair].betHashA].better;
            winAmount = pairsInfo[_pair].amountA + (pairsInfo[_pair].amountB * (100 - app.vig()) / 100);
            vigAmount = pairsInfo[_pair].amountB * app.vig() / 100;
            affiliate = betsInfo[pairsInfo[_pair].betHashA].affiliate;
        }
        else if(status == 2){
            winner = betsInfo[pairsInfo[_pair].betHashB].better;
            winAmount = pairsInfo[_pair].amountB + (pairsInfo[_pair].amountA * (100 - app.vig()) / 100);
            vigAmount = pairsInfo[_pair].amountA * app.vig() / 100;
            affiliate = betsInfo[pairsInfo[_pair].betHashB].affiliate;
        }
        else{
            revert("M13");
        }
        if(affiliate == address(0x0)){
            affiliate = app.ecoAddr();
        }
        bal[winner] += winAmount;
        bal[app.holdAddr()] += vigAmount * app.hVig() / 100;
        bal[app.ecoAddr()] += vigAmount * app.eVig() / 100;
        bal[affiliate] += vigAmount * app.aVig() / 100;
        pairsInfo[_pair].settled = true;
        return;
    }

    function _createBet(
        address _better,
        address _affiliate,
        uint256 _stake,
        uint256 _matched,
        uint256 _odds,
        uint256 _side
    )
    private
    returns(bytes32)
    {
        bytes32 betHash;
        uint i = 0;
        while(i >= 0){
            betHash = keccak256(abi.encodePacked(
                _better,
                address(this),
                bets.length + 1 + i,
                block.timestamp,
                block.difficulty
            ));
            if(betsInfo[betHash].stake == 0){
                break;
            }
            i++;
        }
        betsInfo[betHash] = MarketBet(_better, _affiliate, _stake, _matched, _odds, _side);
        bets.push(betHash);
        userBets[_better].push(betHash);
        return betHash;
    }

    function _createPair(
        bytes32 _betHashA,
        bytes32 _betHashB,
        uint256 _amountA,
        uint256 _amountB
    ) 
    private
    returns(bytes32)
    {
        bytes32 pairHash;
        uint i = 0;
        while(i >= 0){
            pairHash = keccak256(abi.encodePacked(
                _betHashA,
                _betHashB,
                pairs.length + 1 + i,
                block.timestamp,
                block.difficulty
            ));
            if(pairsInfo[pairHash].amountA == 0){
                break;
            }
            i++;
        }
        pairsInfo[pairHash] = MarketPair(_betHashA, _betHashB, _amountA, _amountB, false);
        pairs.push(pairHash);
        return pairHash;
    }
    
}
// File: contracts/Web3BetsFO.sol



pragma solidity ^0.8.4;


/// @author Victor Okoro
/// @title Web3Bets Contract for FixedOdds decentralized betting exchange
/// @notice Contains Web3Bets ecosystem's variables and functions
/// @custom:security contact [email protected]

contract Web3BetsFO is IWeb3BetsFO {
    uint256 private scDecimals = 18;
    address public contractOwner;
    address public override holdAddr = 0x602f6f6C93aC99008B9bc58ab8Ee61e7713aD43d;
    address public override ecoAddr = 0xBffe45D497Bde6f9809200f736084106d1d079df;
    address public override scAddr = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    uint256 public override vig = 10;
    uint256 public override hVig = 50;
    uint256 public override eVig = 50;
    uint256 public override aVig = 25;
    uint256 public override minStake = 1 * 10 ** scDecimals;
    bytes32[] private events;
    mapping(bytes32 => bytes32) private eventsMap;
    mapping(bytes32 => address[]) private eventMarkets;
    mapping(address => address) private admins;
    mapping(address => address) private eventAdmins;
    mapping(address => address) private black;

    modifier onlyOwner {
        require(msg.sender == contractOwner,"E1");
        _;
    }

    modifier onlySystemAdmin {
        require(
            admins[msg.sender] != address(0) || msg.sender == contractOwner,
            "E2"
        );
        _;
    }

    modifier onlyEventAdmin {
        require(
            eventAdmins[msg.sender] != address(0) || msg.sender == contractOwner,
            "E3"
        );
        _;
    }

    event MarketCreated(bytes32 eventHash, address marketAddress);

    event EventCreated(bytes32 eventHash);

    constructor() {
        contractOwner = msg.sender;
    }

    function isBlack(address _addr) external view override returns(bool){
        if(black[_addr] == address(0)) {
            return false;
        }
        else {
            return true;
        }
    }

    function getEvents() external view override returns(bytes32[] memory){
        return events;
    }

    function getMarkets(bytes32 _event) external view override returns(address[] memory){
        return eventMarkets[_event];
    }

    function createEvent() external onlyEventAdmin returns(bytes32){
        bytes32 eventHash;
        uint i = 0;
        while(i >= 0){
            eventHash = keccak256(abi.encodePacked(
                msg.sender,
                events.length + 1 + i,
                block.timestamp,
                block.difficulty
            ));
            if(eventsMap[eventHash] != eventHash){
                break;
            }
            i++;
        }
        eventsMap[eventHash] = eventHash;
        events.push(eventHash);

        emit EventCreated(eventHash);
        return eventHash;
    }

    function createMarket(bytes32 _event) external onlyEventAdmin returns(address) {
        Market market = new Market();
        eventMarkets[_event].push(address(market));

        emit MarketCreated(_event, address(market));
        return address(market);
    }

    function startEvent(bytes32 _event) external onlyEventAdmin {
        address[] memory markets = eventMarkets[_event];
        for(uint i = 0; i < markets.length; i++){
            IMarket market = IMarket(markets[i]);
            market.start();
        }
        return;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        contractOwner = newOwner;
        return;
    }
    
    function setAddrs(
        address _holdAddr,
        address _ecoAddr,
        address _scAddr,
        uint256 _scDecimals
    ) 
        external onlySystemAdmin 
    {
        holdAddr = _holdAddr;
        ecoAddr = _ecoAddr;
        scAddr = _scAddr;
        scDecimals = _scDecimals;
        return;
    }

    function setVig(uint256 _percent, uint _unitMinStake) external onlySystemAdmin {
        require(
            _percent < 100,
            "E4"
        );
        vig = _percent;
        minStake = _unitMinStake * 10 ** scDecimals;
        return;
    }

    function setVigShare(
        uint256 _hVig,
        uint256 _eVig,
        uint256 _aVig
    ) external onlySystemAdmin {
        require(
            _hVig <= 100 && _eVig <= 100 && _aVig <= 100,
            "E5"
        );
        require(
            _hVig + _eVig + _aVig == 100,
            "E6"
        );

        hVig = _hVig;
        eVig = _eVig;
        aVig = _aVig;
        return;
    }
    
    function addSystemAdmin(address _addr)
        external
        onlyOwner
    {
        require(admins[_addr] == address(0), "E7");
        admins[_addr] = _addr;
        return;
    }

    function deleteSystemAdmin(address _systemAdmin)
        external
        onlyOwner
    {
        require (admins[_systemAdmin] != address(0), "E8");
        
        delete admins[_systemAdmin];
        return;
    }
    
    function addEventAdmin(address _addr)
        external
        onlySystemAdmin
    {
        require(eventAdmins[_addr] == address(0), "E9");

        eventAdmins[_addr] = _addr;
        return;
    }

    function deleteEventAdmin(address _eventOwner)
        external
        onlySystemAdmin 
    {
        require (eventAdmins[_eventOwner] != address(0), "E10");
        delete eventAdmins[_eventOwner];
        return;
    }
    
    function addBlacked(address _addr)
        external
        onlySystemAdmin
    {
        require(black[_addr] == address(0), "E11");
        black[_addr] = _addr;
        return;
    }

    function removeBlacked(address _addr) 
        external 
        onlySystemAdmin 
    {
        require (black[_addr] != address(0), "E12");
        delete black[_addr];
        return;
    }

}