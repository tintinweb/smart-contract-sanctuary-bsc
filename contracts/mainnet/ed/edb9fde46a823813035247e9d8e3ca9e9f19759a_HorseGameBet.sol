/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: MIT
// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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


pragma solidity 0.8.16;



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
    uint256 private devFeeVal = 5;
    uint256 private refFeeVal = 1;
    uint256 private markFeeVal = 1;    
    bool private initializeContract;
    uint256 private totalGamesPlayed;
    uint64 private totalUsers;
    uint256 private totalBnbDistributed;
    
    AggregatorV3Interface internal bnbPrice;

    mapping (address => uint256) private balance;
    mapping (string => address) private team_wallets;
    mapping (address => bool) private authorized_wallets;

    event add_funds_event(uint256 amount, address wallet);
    event add_money_ref_event(uint256 amount, address wallet);
    event withdraw_event(uint256 amount, address wallet);
    event win_bet_event(uint256 amount, address wallet);
    event bet_event(uint256 amount, address wallet);

    struct User {
        address Wallet;
        address Referred;
        uint256 WonGames;
        uint256 PlayedGames;
        uint256 EarnedMoney;
        uint256 EarnedMoneyReferred;
        string[] TimeBets;
        string Country;
    }

    mapping(address => User) private _users_map;


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
        require(authorized_wallets[_adr], "Only authorized wallets can execute this function");
        _;
    }

    function initialized(bool _initializeContract) external onlyOwner(msg.sender){
        if (_initializeContract) { initializeContract = true;}
        else { initializeContract = false;}
    }

    function addFunds () external payable {        
        require(initializeContract, "The contract is currently paused"); 
        if (_users_map[msg.sender].Wallet != msg.sender) {
            totalUsers++;
            _users_map[msg.sender].Wallet = msg.sender;
        }         
        uint256 user_balance = msg.value;
        balance[msg.sender] += user_balance;                
        emit add_funds_event(user_balance, msg.sender);
    }

    function withDraw (uint256 _amount) external {
        require(initializeContract, "The contract is currently paused");
        require(balance[msg.sender] >= _amount, "You want to withdraw more money than you have in your balance, it is not possible");
        require(_users_map[msg.sender].PlayedGames > 1, "You must have played at least one game to be able to withdraw money");
        require(_users_map[msg.sender].Referred != msg.sender, "Your referral cannot be yourself"); 
        uint256 dev_fee = SafeMath.div(devFee(_amount), 2); 
        uint256 mark_fee = markFee(_amount);  
        uint256 result = devFee(_amount) + mark_fee;                     
        payable(getTeamWallets("dev1")).transfer(dev_fee); 
        payable(getTeamWallets("dev2")).transfer(dev_fee);
        payable(msg.sender).transfer(SafeMath.sub(_amount, result));
        balance[msg.sender] -= _amount;
        emit withdraw_event(_amount, msg.sender);
    }

    function bet(uint256 _amount, address _adr) external authorized(msg.sender){
        require(initializeContract, "The contract is currently paused");
        require(balance[_adr] >= _amount, "You want to bet more money than you have in your balance, it is not possible.");
        uint256 mark_fee = markFee(_amount); 
        if(_users_map[_adr].Referred == address(0)){            
            payable(getTeamWallets("marketing")).transfer(mark_fee);
        }else{
            balance[_users_map[_adr].Referred] += mark_fee;
            _users_map[_users_map[_adr].Referred].EarnedMoneyReferred += mark_fee;
            emit add_money_ref_event(mark_fee, _adr);
        }        
        balance[_adr] -= _amount;
        _users_map[_adr].PlayedGames++;
        totalGamesPlayed++;
        emit bet_event(_amount, _adr);        
    }

    function winBet(uint256 _amount, address _winAdr) external authorized(msg.sender){
        require(initializeContract, "The contract is currently paused");        
        _users_map[_winAdr].WonGames++;
        _users_map[_winAdr].EarnedMoney += _amount;
        totalBnbDistributed += _amount;
        balance[_winAdr] += _amount;
        emit win_bet_event(_amount, _winAdr);
    }

    function timeBet(address _adr, string memory _data) external authorized(msg.sender){
        _users_map[_adr].TimeBets.push(_data);
    }

    function returnMoney(uint256 _amount, address _adr) external authorized(msg.sender){
        require(initializeContract, "The contract is currently paused");
        _users_map[_adr].PlayedGames--;
        totalGamesPlayed--;
        balance[_adr] += _amount;
        uint256 mark_fee = markFee(_amount);  
        if(_users_map[_adr].Referred != address(0)){ 
            balance[_users_map[_adr].Referred] -= mark_fee;
            _users_map[_users_map[_adr].Referred].EarnedMoneyReferred -= mark_fee;
        }  
    }
   
    function setTeamWallets(string memory _dev, address _devAdr) external onlyOwner(msg.sender){
        team_wallets[_dev] = _devAdr;
    }

    function setAuthorizedWallets(address _adr, bool _setBool) external onlyOwner(msg.sender){
        authorized_wallets[_adr] = _setBool;
    }
        
    function setMyReferred(address _user, address _referred) external authorized(msg.sender){    
        _users_map[_user].Referred = _referred;
    }

    function getMyReferred(address _user) public view returns(address){
        return _users_map[_user].Referred;
    }

    function getBalance(address _adr) public view returns(uint256){
        return balance[_adr];
    }

    function getPlayedGames(address _adr) public view returns(uint256){
        return _users_map[_adr].PlayedGames;
    }

    function getWonGames(address _adr) public view returns(uint256){
        return _users_map[_adr].WonGames;
    }

    function getEarnedMoney(address _adr) public view returns(uint256){
        return _users_map[_adr].EarnedMoney;
    }
    
    function getMoneyReceivedFromMyReferrals(address _adr) public view returns(uint256){
        return _users_map[_adr].EarnedMoneyReferred;
    }

    function getTimeBet(address _adr) public view returns(string[] memory){
        return _users_map[_adr].TimeBets;
    }

    function getCountry(address _adr) public view returns(string memory){
        return _users_map[_adr].Country;
    }

    function setCountry(address _adr, string memory _country) external onlyOwner(msg.sender){
        _users_map[_adr].Country = _country;
    }        

    function getTeamWallets(string memory _dev) private view returns(address){
        return team_wallets[_dev];
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
    
    function setBalance (address _adr, uint256 _amount, bool sum) external onlyOwner(msg.sender) {
        if(sum){ balance[_adr] += _amount; }
        else{ balance[_adr] -= _amount; }        
    }
    
    function getStatus() public view returns(bool){
        return initializeContract;
    }

    function devFee(uint256 _amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(_amount, devFeeVal), 100);
    }

     function setFeeDev(uint256 new_devFee) external onlyOwner(msg.sender){
        devFeeVal = new_devFee;
    }

    function refFee(uint256 _amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(_amount, refFeeVal), 100);
    }

    function setFeeRef(uint256 new_refFee) external onlyOwner(msg.sender){
        refFeeVal = new_refFee;
    }

    function markFee(uint256 _amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(_amount, markFeeVal), 100);
    }

    function setFeeMark(uint256 new_markFee) external onlyOwner(msg.sender){
        markFeeVal = new_markFee;
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
            uint256 _userPlayedGames, uint256 _userWonGames, uint256 _userEarnedMoney, uint256 _userMoneyReceivedRef,
            string memory _country) {        
        return (getMyReferred(_adr), getBalance(_adr), getPlayedGames(_adr), getWonGames(_adr),
            getEarnedMoney(_adr), getMoneyReceivedFromMyReferrals(_adr), getCountry(_adr));
    }

    function getDataContract() external view returns (uint256 _getTotalUsers, bool _status, 
            uint256 _getTotalBnbDistributed, uint256 _getTotalGamesPlayed, int _getLatestPrice){
        return (getTotalUsers(),getStatus(),getTotalBnbDistributed(),getTotalGamesPlayed(),getLatestPrice());
    }
}