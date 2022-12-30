/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

/** 
*
*
*   █▀ █▀█ ▄▀█ ▄▀█ █▀█   █▀▀ ▄▀█ █▀▄▀█ █▀▀ █▀
*   ▄█ █▀▀ █▀█ █▀█ █▀▄   █▄█ █▀█ █ ▀ █ ██▄ ▄█
* 
* Horse Game Bet is a horse racing betting game with deck cards.
* Online game of up to 4 players (minimum 2 to start).
* Betting with BNB. Minimum bet $5, maximum $100.
* Earn 3% with referrals.
* Visit our website for more details: https://horsegame.bet
* Developed by Spaar Games: https://spaar-games.com
*
*
**/
// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// File: HorseGameBet.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;



library SafeMath {
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
}

/*
* Developed by spaar-games.com
*/
contract HorseGameBet {
    using SafeMath for uint256;
    
    address payable private _owner;
    uint256 private devFeeVal = 7; // 7%
    uint256 private refFeeVal = 3; // 3%
    uint256 private markFeeVal = 3; // 3%
    bool private initializeContract;
    uint256 private totalGamesPlayed;
    uint64 private totalUsers;
    uint256 private totalBnbDistributed;
    
    AggregatorV3Interface internal bnbPrice;

    mapping (address => uint256) private balance;

    event add_funds_event(uint256 amount, address wallet);
    event add_money_ref_event(uint256 amount, address wallet);
    event withdraw_event(uint256 amount, address wallet);
    event win_bet_event(uint256 amount, address wallet);
    event bet_event(uint256 amount, address wallet);

    struct User {
        address wallet;
        address referred;
        uint256 wonGames;
        uint256 playedGames;
        uint256 earnedMoney;
        uint256 earnedMoneyReferred;
        string[] timeBets;
    }

    mapping(address => User) private _users_map;

    address public devs = 0x55761cf6F83Ad20b8fB871c66bFb27Ddc72ec8E9;
    address private marketing = 0x3f0BBDc4D00e46Be6d38a71926147c902Bc32E1c;
    address private authorized_transactions_wallet = 0x96209062C2CAad8BD6B1fBDF67067C5E79F12BFa;


    constructor() {
        _owner = payable(msg.sender);
        initializeContract = false;
        bnbPrice = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE); 
    }

    modifier onlyOwner(address _adr) {
        require(_adr == _owner, "Only the owner can execute this function.");
        _;
    }

    modifier authorized(address _adr){
        require(_adr == authorized_transactions_wallet, "Only authorized wallet can execute this function");
        _;
    }

    function initialized(bool _initializeContract) external onlyOwner(msg.sender){
        if (_initializeContract) { initializeContract = true;}
        else { initializeContract = false;}
    }

    function addFunds () external payable {        
        require(initializeContract, "The contract is currently paused"); 
        if (_users_map[msg.sender].wallet != msg.sender) {
            totalUsers++;
            _users_map[msg.sender].wallet = msg.sender;
        }         
        uint256 user_balance = msg.value;
        uint256 dev_fee = devFee(msg.value); 
        payable(devs).transfer(dev_fee);
        balance[msg.sender] += user_balance;                
        emit add_funds_event(user_balance, msg.sender);
    }

    function withDraw (uint256 _amount) external {
        require(initializeContract, "The contract is currently paused");
        require(balance[msg.sender] >= _amount, "You want to withdraw more money than you have in your balance, it is not possible");
        require(_users_map[msg.sender].playedGames > 1, "You must have played at least one game to be able to withdraw money");
        require(_users_map[msg.sender].referred != msg.sender, "Your referral cannot be yourself"); 
        uint256 mark_fee = markFee(_amount);  
        uint256 result = devFee(_amount) + mark_fee;                     
        payable(msg.sender).transfer(SafeMath.sub(_amount, result));
        balance[msg.sender] -= _amount;
        emit withdraw_event(_amount, msg.sender);
    }

    function bet(uint256 _amount, address _adr) external {
        require(initializeContract, "The contract is currently paused");
        require(_adr == msg.sender);
        require(balance[_adr] >= _amount, "You want to bet more money than you have in your balance, it is not possible.");
        uint256 mark_fee = markFee(_amount); 
        if(_users_map[_adr].referred == address(0)){            
            payable(marketing).transfer(mark_fee);
        }else{
            balance[_users_map[_adr].referred] += mark_fee;
            _users_map[_users_map[_adr].referred].earnedMoneyReferred += mark_fee;
            emit add_money_ref_event(mark_fee, _adr);
        }        
        balance[_adr] -= _amount;
        _users_map[_adr].playedGames++;
        totalGamesPlayed++;
        emit bet_event(_amount, _adr);        
    }

    function winBet(uint256 _amount, address _winAdr) external authorized(msg.sender){
        require(initializeContract, "The contract is currently paused");        
        _users_map[_winAdr].wonGames++;
        _users_map[_winAdr].earnedMoney += _amount;
        totalBnbDistributed += _amount;
        balance[_winAdr] += _amount;
        emit win_bet_event(_amount, _winAdr);
    }

    function timeBet(address _adr, string memory _data) external authorized(msg.sender){
        _users_map[_adr].timeBets.push(_data);
    }

    function returnMoney(uint256 _amount, address _adr) external authorized(msg.sender){
        require(initializeContract, "The contract is currently paused");
        _users_map[_adr].playedGames--;
        totalGamesPlayed--;
        balance[_adr] += _amount;
        uint256 mark_fee = markFee(_amount);  
        if(_users_map[_adr].referred != address(0)){ 
            balance[_users_map[_adr].referred] -= mark_fee;
            _users_map[_users_map[_adr].referred].earnedMoneyReferred -= mark_fee;
        }  
    }   
        
    function setMyReferred(address _user, address _referred) external authorized(msg.sender){    
        _users_map[_user].referred = _referred;
    }

    function getMyReferred(address _user) public view returns(address){
        return _users_map[_user].referred;
    }

    function getBalance(address _adr) public view returns(uint256){
        return balance[_adr];
    }

    function getPlayedGames(address _adr) public view returns(uint256){
        return _users_map[_adr].playedGames;
    }

    function getWonGames(address _adr) public view returns(uint256){
        return _users_map[_adr].wonGames;
    }

    function getEarnedMoney(address _adr) public view returns(uint256){
        return _users_map[_adr].earnedMoney;
    }
    
    function getMoneyReceivedFromMyReferrals(address _adr) public view returns(uint256){
        return _users_map[_adr].earnedMoneyReferred;
    }

    function getTimeBet(address _adr) public view returns(string[] memory){
        return _users_map[_adr].timeBets;
    }      
    
    function getTotalUsers() public view returns(uint256){
        return totalUsers;
    }

    function getTotalBnbDistributed() public view returns(uint256){
        return totalBnbDistributed;
    }

    function getTotalGamesPlayed() public view returns(uint256){
        return totalGamesPlayed;
    }
       
    function getStatus() public view returns(bool){
        return initializeContract;
    }

    function devFee(uint256 _amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(_amount, devFeeVal), 100);
    }

    function refFee(uint256 _amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(_amount, refFeeVal), 100);
    }
    
    function markFee(uint256 _amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(_amount, markFeeVal), 100);
    }   
   
    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = bnbPrice.latestRoundData();        
        return price * 1e10;
    }

    function getUserData(address _adr) external view returns (address _userRefferral, uint256 _userBalance,
            uint256 _userPlayedGames, uint256 _userWonGames, uint256 _userEarnedMoney, uint256 _userMoneyReceivedRef) 
    {        
        return (getMyReferred(_adr), getBalance(_adr), getPlayedGames(_adr), getWonGames(_adr),
            getEarnedMoney(_adr), getMoneyReceivedFromMyReferrals(_adr));
    }

    function getDataContract() external view returns (uint256 _getTotalUsers, bool _status, 
            uint256 _getTotalBnbDistributed, uint256 _getTotalGamesPlayed, int _getLatestPrice){
        return (getTotalUsers(),getStatus(),getTotalBnbDistributed(),getTotalGamesPlayed(),getLatestPrice());
    }    
}