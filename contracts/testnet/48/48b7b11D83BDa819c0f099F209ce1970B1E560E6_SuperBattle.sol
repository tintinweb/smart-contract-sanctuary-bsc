/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    

}

interface IRandomNumberGenerator {
    /**
     * Requests randomness from a user-provided seed
     */
    function generatorRandomNumber() external;


    /**
     * Views random result
     */
    function viewRandomResult() external view returns (uint256[] memory);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}



contract SuperBattle is Context, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    IERC20 public immutable _battleToken;
    IRandomNumberGenerator internal _randomNumberGenerator;
    uint256 public _startTime;
    uint256 public _singleBetPrice = 5 * 10 ** 18;
    uint256 public _singleBetMaxNumbers = 3;
    uint256 public _prize = 500 * 10 ** 18;
    uint256[] public _numbers = [0,1,2,3,4,5,6,7,8,9];
    // uint256 public _periodCycleTime = 1 days;
    uint256 public _periodCycleTime = 5 minutes;
    
    uint256 public _gameCloseTimeRange = 1 minutes;
    uint256 public _lastPeriodOpenTime;
    uint256 public _currentPeriod;
    uint256 public _currentPeriodBonusPool;
    
    address public _drawManager;
    mapping(uint256 => Game) public _gameHistory;
    mapping(address => mapping(uint256 => BettingRecord[])) public _playerBetRecord;
    
    
    event Claim(address indexed player,uint256 indexed period,uint256 amount);
    event BuyTicket(address indexed player,uint256 indexed period);
    event DrawOut(Game game);
    
    struct Game{
        uint256 period;
        bool isOpen;
        uint256 firstNumber;
        uint256 secondNumber;
        uint256 thirdNumber;
        uint256 createTime;
        uint256 drawOutTime;
        uint256 totalPrize;
        Status status;
    }
    struct BettingRecord{
        uint256 period;
        uint256 firstNumber;
        uint256 secondNumber;
        uint256 thirdNumber;
        bool isWin;
        uint256 createTime;
        bool isClaim;
        uint256 claimTime;
    }
    
    enum Status {
        Pending,
        Open,
        Close
    }
    
    modifier onlyDrawOutManager() {
        require(_drawManager == _msgSender(), "DrawOutManager: caller is not the DrawOutManager");
        _;
    }
    
    constructor (IERC20 token,uint256 startTime){
        _battleToken = token;
        _startTime = startTime;
        _lastPeriodOpenTime = startTime;
        _currentPeriod = 1;
        _gameHistory[_currentPeriod] = Game(_currentPeriod,false,0,0,0,block.timestamp,0,0,Status.Pending);
    }
    
    function buyTicket(uint256 amount,uint256[] memory selectNumbers) external{
        
        require(amount == _singleBetPrice,"please input the right amount!");
        require(_startTime <= block.timestamp,"doesn't open");
        require(selectNumbers.length == _singleBetMaxNumbers,"illegal betting!");
        Game storage lastGame = _gameHistory[_currentPeriod];
        require(!lastGame.isOpen,"please buy next period!");
        _playerBetRecord[_msgSender()][_currentPeriod].push(BettingRecord(_currentPeriod,
        selectNumbers[0],selectNumbers[1],selectNumbers[2],
        false,block.timestamp,false,0));
        
        _battleToken.transferFrom(address(_msgSender()),address(this),amount);
        _currentPeriodBonusPool += amount;
        lastGame.totalPrize = _currentPeriodBonusPool;
        emit BuyTicket(address(_msgSender()),_currentPeriod);
    }
    
    function drawOut() external onlyDrawOutManager{
        require(_startTime <= block.timestamp,"doesn't open");
        require(block.timestamp.sub(_lastPeriodOpenTime) >= _periodCycleTime,"illegal draw out time!");
        require(address(_randomNumberGenerator) != address(0),"error random generator");
        
        Game storage lastGame = _gameHistory[_currentPeriod];
        require(lastGame.status == Status.Close,"error Status");
        
        if(lastGame.period == _currentPeriod){
            uint256[] memory randomNumbers = _randomNumberGenerator.viewRandomResult();
            for(uint i = 0; i < _singleBetMaxNumbers; i ++){
                bytes memory info = abi.encodePacked(block.difficulty,block.timestamp,randomNumbers[i],_numbers.length);
                bytes32 hash = keccak256(info);
                uint index = uint(hash)  % _numbers.length;
                if(i == 0){
                    lastGame.firstNumber = _numbers[index];
                }
                if(i == 1){
                    lastGame.secondNumber = _numbers[index];
                }
                if(i == 2){
                    lastGame.thirdNumber = _numbers[index];
                }
            }
            lastGame.isOpen = true;
            lastGame.drawOutTime = block.timestamp;
            lastGame.totalPrize = _currentPeriodBonusPool;
            lastGame.status = Status.Open;
            _currentPeriod ++;
            _gameHistory[_currentPeriod] = Game(_currentPeriod,false,0,0,0,block.timestamp,0,0,Status.Pending);
            _lastPeriodOpenTime = block.timestamp;
            _currentPeriodBonusPool = 0;
            emit DrawOut(lastGame);
        }
    }
    
    function closeGame(uint256 period) external onlyDrawOutManager(){
        require(block.timestamp.sub(_lastPeriodOpenTime) >= _periodCycleTime.sub(_gameCloseTimeRange),"error close time");
        require(address(_randomNumberGenerator) != address(0),"error random generator");
        Game storage game = _gameHistory[period];
        require(game.status == Status.Pending,"current game is not pending status");
        _randomNumberGenerator.generatorRandomNumber();
        game.status = Status.Close;
    }
    
    function claimPrize(uint256 period) external{
        require(period > 0 && period < _currentPeriod,"illegal period!");
        Game storage lastGame = _gameHistory[period];
        require(lastGame.isOpen,"this period didn't  draw out!");
        BettingRecord[] storage playerRecord = _playerBetRecord[address(_msgSender())][period];
        uint256 myTotalPrize = 0;
        if(playerRecord.length > 0){
            for(uint i = 0; i < playerRecord.length; i ++){
                BettingRecord storage record = playerRecord[i];
                
                if(record.period == period && 
                    isWin(record,lastGame) && !record.isClaim){
                        
                    myTotalPrize = myTotalPrize.add(_prize);
                }
            }
        }
        require(myTotalPrize > 0,"your prize is less than 0!");
        require(_battleToken.balanceOf(address(this)) >= myTotalPrize,"bonus pool balance is insufficient!");
        _battleToken.transfer(address(_msgSender()),myTotalPrize);
        for(uint k = 0; k < playerRecord.length; k ++){
            BettingRecord storage recordUpdate = playerRecord[k];
                if(recordUpdate.period == period && isWin(recordUpdate,lastGame) ){
                    recordUpdate.isClaim = true;
                    recordUpdate.claimTime = block.timestamp;
                }
        }
        emit Claim(address(_msgSender()),period,myTotalPrize);
    }
    
    function isWin(BettingRecord memory record,Game memory game) private pure returns (bool){
        
        return record.firstNumber == game.firstNumber && 
        record.secondNumber == game.secondNumber && 
        record.thirdNumber == game.thirdNumber;
    }
    
    function setDrawManager(address manager) external onlyOwner{
        _drawManager = manager;
    }
    
    function setRandomNumberGenerator(address generator) external onlyOwner {
        _randomNumberGenerator = IRandomNumberGenerator(generator);
    }
    function setGamePrizeNumber(uint256 period,uint256[] memory setNumbers) external onlyOwner{
        Game storage lastGame = _gameHistory[period];
        lastGame.firstNumber = setNumbers[0];
        lastGame.secondNumber = setNumbers[1];
        lastGame.thirdNumber = setNumbers[2];
    }
    
    function getGame(uint256 period) external view returns (Game memory){
        return _gameHistory[period];
    }
    
    function getPlayerBettingRecord(address player,uint256 period) external view returns (BettingRecord[] memory){
        
        BettingRecord[] storage playerRecord = _playerBetRecord[player][period];
        return playerRecord;
    }
    
    function getGamePrizePoolBalance(uint256 period) external view returns (uint256){
        return _gameHistory[period].totalPrize;
    }
    
     
    receive() external payable {}
}