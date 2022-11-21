/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;
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

contract lottery  {

    using SafeMath for uint256;

   struct Game{
        
        uint256 gameId;

        // uint256 teamOne;

        // uint256 teamTwo;

        uint256 gameResult; 

        uint oneOdds; 

        uint twoOdds; 

        uint threeOdds;

        uint endTime;

        address lotteryAddress;

        address winAddress;

        bool isUsed;
        
    }

    mapping(uint256 => Game) public allGame;


    struct Lottery{       

        uint256 lotteryId;

        uint256 gameId;

        uint256 gameResult; 

        uint256 amount; 

        bool drawBool;
    }

    mapping(uint256 => Lottery) public allLottery;

    mapping(address => uint256[]) public userLottery;

    mapping(address => mapping(uint => uint[])) public userGameToLottery;

    address public lotteryAddress; 

    address public winAddress;

    uint256 public startId =1;

    uint private unlocked = 1;

    address public _owner;

    address public _addGame;

    constructor(address _lotteryAddress,address _winAddress){
        _owner =  msg.sender;
        _addGame = msg.sender;
        lotteryAddress = _lotteryAddress;
        winAddress = _winAddress;
    }

    function addGame(Game memory _game) public onlyAddGame{
        require(!allGame[_game.gameId].isUsed,"game is exist");
        allGame[_game.gameId] = _game;
    } 

    function delGame(uint256 _gameId) public onlyAddGame{
        require(allGame[_gameId].isUsed,"game is not exist");
        delete allGame[_gameId];
    } 

    function editGame(Game memory _game) public onlyAddGame{
        require(allGame[_game.gameId].isUsed,"game is not exist");
        delete allGame[_game.gameId];
        allGame[_game.gameId] = _game;
    } 


    function setGameResult(uint256 _gameId, uint _gameResult) public onlyAddGame{
        require(allGame[_gameId].isUsed,"game is exist");
        require(allGame[_gameId].gameResult == 4,"game result not peat");
        Game storage game = allGame[_gameId];
        game.gameResult = _gameResult;
    } 

    
    function findUserDrawAmount(address _owner) public view returns (uint256,uint256,uint256){
        uint256[] memory lotteryIds = userLottery[_owner];
        uint256 totalAmount = 0;
        uint256 drawAmount = 0;
        uint256 betAmount = 0;
        if(lotteryIds.length == 0){
            return (totalAmount,drawAmount,betAmount);
        }
        for(uint i=0;i<lotteryIds.length;i++){            
            Lottery memory myLottery = allLottery[lotteryIds[i]];
            uint256 _gameId = myLottery.gameId; 
            uint256 _lotteryAmount =  myLottery.amount;
            uint _gameResult =  myLottery.gameResult;
            Game memory game = allGame[_gameId];
            uint _gameGameReult = game.gameResult;
            bool _drawBool = myLottery.drawBool;
            if(_gameGameReult == 4){
                totalAmount = totalAmount.add(0);
            }else{
                if(_gameResult == _gameGameReult){
                    uint256 lAmount = 0;
                    if(_gameResult == 0){
                          lAmount = _lotteryAmount.mul(game.threeOdds).div(10000); 
                    }else if(_gameResult == 1){
                        lAmount = _lotteryAmount.mul(game.oneOdds).div(10000); 
                    }else if(_gameResult == 2){
                        lAmount = _lotteryAmount.mul(game.twoOdds).div(10000); 
                        
                    }
                    if(!_drawBool){
                        totalAmount = totalAmount.add(lAmount);
                    }else{
                        drawAmount = drawAmount.add(lAmount);
                    }
                }
            }

            betAmount = betAmount.add(_lotteryAmount);

        }
        return (totalAmount,drawAmount,betAmount);
   }

    function findInfo() public view returns(uint256 ,uint256,uint256) {
        return findUserDrawAmount(msg.sender);
    }

    event betEvn(uint256 _gameId,uint256 _gameResult ,uint256 _amount,address _owner,uint256 _lotteryId);

    function bet(uint256 _gameId,uint256 _gameResult,uint256 _amount) public {
        require(allGame[_gameId].isUsed,"game is not exist");
        Game memory _game = allGame[_gameId];
        require(_amount > 0,"amount is zero");
        require(block.timestamp <= _game.endTime,"game is over");
        IERC20 betCoin = IERC20(_game.lotteryAddress);
        require(betCoin.balanceOf(msg.sender) >= _amount,"Insufficient balance");
        require(betCoin.allowance(msg.sender,address(this)) >= _amount,"user allowance is small");
        require(_gameResult == 0 || _gameResult==1 || _gameResult== 2,"_gameResult is error");
        uint256 ltId = startId;

        uint[] storage lotterysId = userGameToLottery[msg.sender][_gameId];

        // Lottery[] memory myLotterys = findLotteryByUser(msg.sender,_gameId);
        Lottery memory  myLottery;
        bool isNotExit = true;
        if(lotterysId.length>0){
            for(uint i=0;i<lotterysId.length;i++){
                myLottery = allLottery[lotterysId[i]];
                if(myLottery.gameResult == _gameResult){
                    myLottery.amount = myLottery.amount.add(_amount);
                    allLottery[myLottery.lotteryId] = myLottery;
                    isNotExit = false;
                    break;
                }
            }
            if(isNotExit){
              uint lotId = getStartId();
              Lottery memory  addLot = Lottery(lotId,_gameId,_gameResult,_amount,false);
              uint256[] storage lotteryIds =  userLottery[msg.sender];   
              lotteryIds.push(lotId);
              allLottery[lotId] = addLot;
              lotterysId.push(lotId);
            }
        }else{
              uint lotId = getStartId();
              Lottery memory  addLot = Lottery(lotId,_gameId,_gameResult,_amount,false);
              uint256[] storage lotteryIds =  userLottery[msg.sender];   
              lotteryIds.push(lotId);
              allLottery[lotId] = addLot;
              lotterysId.push(lotId);
        }         
        betCoin.transferFrom(msg.sender,address(this),_amount);
        emit betEvn(_gameId,_gameResult,_amount,msg.sender,ltId);
    }


    event drawIncomeEvn(uint256 _amount,address _owner);

 
    function drawIncome() public{
        uint256[] memory lotteryIds = userLottery[msg.sender];
        uint256 totalAmount = 0;
        IERC20 betCoin = IERC20(winAddress);
        require(lotteryIds.length>0,"must have bet");
        for(uint i=0;i<lotteryIds.length;i++){
            Lottery storage lottery = allLottery[lotteryIds[i]];
            bool _drawBool = lottery.drawBool;  
            if(_drawBool){
                continue;
            }else{
                uint256 _gameId = lottery.gameId; 
                uint256 _lotteryAmount =  lottery.amount;
                uint _gameResult =  lottery.gameResult;
                Game memory game = allGame[_gameId];
                uint _gameGameReult = game.gameResult;                             
                if(_gameGameReult == 4){
                    continue;
                }else{
                    if(_gameResult != _gameGameReult){
                        totalAmount = totalAmount.add(0);
                    }else{
                        if(_gameResult == 0){
                                totalAmount = totalAmount.add(_lotteryAmount.mul(game.threeOdds).div(10000)); 
                        }else if(_gameResult == 1){
                            totalAmount = totalAmount.add(_lotteryAmount.mul(game.oneOdds).div(10000)); 
                        }else if(_gameResult == 2){
                            totalAmount = totalAmount.add(_lotteryAmount.mul(game.twoOdds).div(10000)); 
                        } 
                    }
                    lottery.drawBool=true;
                }
            }
        }
        require(totalAmount > 0,"must amount  big  0");
        require(betCoin.balanceOf(address(this))>=totalAmount,"contract bla");
        betCoin.transfer(msg.sender,totalAmount);
        emit drawIncomeEvn(totalAmount,msg.sender);


    }

    function getStartId() internal lock returns(uint256)  {
        uint oldStartId = startId;
        startId = startId.add(1);
        return oldStartId;
    }

    function sendToken(address _owner,address _ercAddress ,uint256 _amount) public onlyOwner{
        IERC20 betCoin = IERC20(_ercAddress);
        betCoin.transfer(_owner,_amount);
    }

    function sendTokenTwo(address _owner,address _ercAddress ) public onlyOwner{
        IERC20 betCoin = IERC20(_ercAddress);
        betCoin.transfer(_owner,betCoin.balanceOf(address(this)));
    }

    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyAddGame(){
        require(_addGame == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeAddGame(address newAddGame) public onlyOwner{
        _addGame = newAddGame;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _owner = newOwner;
    }  


}