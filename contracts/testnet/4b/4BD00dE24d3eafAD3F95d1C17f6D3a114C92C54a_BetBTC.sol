/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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



contract BetBTC {
    AggregatorV3Interface internal priceFeed;

    uint public timeEnd;
    uint256 public counter;
    uint256 public resultBet;// 0: > and 1: <
    int public cryptoPrice;// set the target price
    uint256 public commission; // init 20%
    address public owner;
    uint256 public totalOfsmaller;
    uint256 public tolalOflarger;
    bool public status;// fasle is running, true is orvertime
    struct User  {
        address  Account;
        uint256  Amount;
        uint time;   
    }

  
    mapping(uint256=>User[]) public Users; //To save list user
    mapping(address=>bool) public _checkWithdraw; // checking withraw
    //BSC: 0x5741306c21795FdCBb9b265Ea0255F499DFe515C

    constructor (AggregatorV3Interface _priceFeed){
        owner=msg.sender;
        status=false;
        commission=20;
        resultBet=10;
        priceFeed = AggregatorV3Interface(_priceFeed); // Rinkeby testnet: 0xECe365B379E1dD183B20fc5f022230C044d51404
    }
    modifier Onlyowner(){
        require(msg.sender==owner,"You are not owner");
        _;
    }
    modifier Checkstate(){
        require(status,"Game in running");
        _;
    }
 
    modifier CheckWithdraw(){
        require(_checkWithdraw[msg.sender]==false,"You was withdrawn");
        _;
    }
    // check withdraw
    function getwithdraw() public view returns(bool){
        return _checkWithdraw[msg.sender];
    }

    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }
    function CompairePrice() public view  returns(uint){
        int price=getLatestPrice();
        if(price> cryptoPrice){
            return 0;
        }if (price<cryptoPrice)
        {
            return 1;
        }else{
            return 2;
        }
        
    }

    //------------------------------------------------------------------------------
    
    function Placebet(uint256 bet) public payable{
        require(msg.value>=0,"Must be larger 0");
        //require(block.timestamp<timeEnd,"Time is expired ");
        Users[bet].push(User(msg.sender,msg.value,block.timestamp));
        //_checkUser[msg.sender]=bet;
        counter+=1;
        UpdateBetValue(bet,msg.value);

    }

    function SetReult() public Onlyowner{
        require(status==false,"Reseted");
        resultBet=CompairePrice();
        status=true;
        timeEnd=0;
        
    }
    function UpdateBetValue(uint256 valueBet, uint256 amount) public {
        if(valueBet==0){
          tolalOflarger =tolalOflarger+amount;
        }else if(valueBet==1){
          totalOfsmaller=totalOfsmaller+amount;
        }
    }

    // init game
    function SetTartget(uint _timeEnd, int _cryptoPrice) public Onlyowner{
        timeEnd=_timeEnd;
        cryptoPrice=_cryptoPrice*10**8;
        status=false;
        ResetUser();
       
    }
 

    function BalanceOf() public view returns(uint256){
        return address(this).balance;
    }
    // Get list user with the value is placed 
    function GetUsers(uint256 value) public view returns(User[] memory){
        
       return Users[value];
    }
   
   // Get corresponding balance of user(msg.sender) which the msg.sender can withdraw
    function ValueOfWiner(address winer, uint256 _resultBet) public view  returns(uint){
        uint256 valueOfwiner=0;
        if(_resultBet==0){
           uint256 _real_profit=totalOfsmaller-(totalOfsmaller*commission)/100;
          for(uint i=0;i<Users[_resultBet].length;i++){
            if(Users[_resultBet][i].Account==winer ){
                uint256 currentValueOfWiner=Users[_resultBet][i].Amount+(Users[_resultBet][i].Amount*_real_profit)/tolalOflarger;
                valueOfwiner=valueOfwiner+currentValueOfWiner;
            }
          }
        }else if(_resultBet==1){
            uint256 _real_profit_sl=tolalOflarger-(tolalOflarger*commission)/100;
            for(uint i=0;i<Users[_resultBet].length;i++){
                if(Users[_resultBet][i].Account==winer){
                    uint256 currentValueOfWiner=Users[_resultBet][i].Amount+(Users[_resultBet][i].Amount*_real_profit_sl)/totalOfsmaller;
                    valueOfwiner=valueOfwiner+currentValueOfWiner;
                }
            }
    
        }
      return valueOfwiner;
    }

   function ResetUser() public Onlyowner{
        for(uint i=0;i<Users[0].length;i++){
           address _address= Users[0][i].Account;
            _checkWithdraw[_address]=false;
        }
         for(uint i=0;i<Users[1].length;i++){
           address _address= Users[1][i].Account;
            _checkWithdraw[_address]=false;
        }
        _checkWithdraw[owner]=false;
         delete Users[1];
         delete Users[0];
         tolalOflarger=0;
         totalOfsmaller=0;
         resultBet=10;
   }

    function withdraw()public CheckWithdraw {
        uint winer=ValueOfWiner(msg.sender,resultBet);
        uint256 ownerfrofit=0;
        if(msg.sender==owner)
        {
               if(resultBet==0){
                ownerfrofit= winer+ totalOfsmaller*commission/100;
                }else if(resultBet==1){
                    ownerfrofit= winer+ tolalOflarger*commission/100;
                }
            payable(msg.sender).transfer(ownerfrofit);
            _checkWithdraw[msg.sender]=true;

        }else 
        {
             require(winer>0,"Require is larger 0");
             payable(msg.sender).transfer(winer);
             _checkWithdraw[msg.sender]=true;
             
        }
        
    }
  
}