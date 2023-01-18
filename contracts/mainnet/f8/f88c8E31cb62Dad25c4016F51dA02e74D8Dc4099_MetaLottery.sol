/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

    library SafeMath {//konwnsec//IERC20 接口
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0; 
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c; 
        }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
// assert(b > 0); // Solidity automatically throws when dividing by 0
            uint256 c = a / b;
// assert(a == b * c + a % b); // There is no case in which this doesn't hold
            return c; 
        }
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            assert(b <= a);
            return a - b; 
        }

        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            assert(c >= a);
            return c; 
        }


    }

    interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
  
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

    interface Erc20Token { 
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }
    
    contract Base {
        using SafeMath for uint;
        Erc20Token   LAND   = Erc20Token(0x9131066022B909C65eDD1aaf7fF213dACF4E86d0);
        Erc20Token constant internal _USDTIns = Erc20Token(0x55d398326f99059fF775485246999027B3197955); 
        address     LP =  0xB8e2776b5a2BCeD93692f118f2afC525732075fb ; 

    address  _owner;
    address  _operator;

    function Convert18(uint256 value) internal pure returns(uint256) {
        return value.mul(1000000000000000000);
    }

    function Convert6(uint256 value) internal pure returns(uint256) {
        return value.mul(1000000000000);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }

    modifier onlyOperator() {
        require(msg.sender == _operator, "Permission denied"); _;
    }

    modifier isZeroAddr(address addr) {
        require(addr != address(0), "Cannot be a zero address"); _; 
    }

    function TransferOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function TransferOperator(address new_operator) public onlyOwner {
        require(new_operator != address(0));
        _operator = new_operator;
    }

 
    receive() external payable {}  
}


 
contract DataPlayer is Base{
 
    struct matchInfo{
        uint256 id; 
        // 开始时间
        uint256 startTime; 
        
        // 目标金额
        uint256 targetAmount; 
        // 目标金额
        uint256 ParticipationAmount; 
        // 参与币种
        bool LandOrUSDT; 

        uint256 playerCount; 
        mapping(uint256 => address) IDToAddress; 

        address victory; 
        uint256 schedule; 
     }


      address   RateaddressZZ = 0xCc9C5bd0717A8489375ff24472d5c98A2520af7d;
      uint256  public Rate = 100000;
 
    mapping(uint256 => uint256) public MatchID; 
    mapping(uint256 => matchInfo) public MatchDetails; 

    mapping(uint256 => uint256) public MAX; 

    mapping(address =>  mapping(uint256 => uint256)) public Match_Check;

    mapping(address =>  mapping(uint256 => uint256)) public Gaming; 
    mapping(uint256 =>  mapping(uint256 => uint256)) public PlayerIDToAddress; 

 
}
 
 contract MetaLottery is DataPlayer {
        IUniswapV2Router02  immutable uniswapV2Router;

     constructor()
   public {
        _owner = 0x94fD3817270F368D563D477B917F5769eABbBd97; 

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        _USDTIns.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 10000000000000000000000000000000000000000000000000000);

 
    }

    address public WAddress = 0xCc9C5bd0717A8489375ff24472d5c98A2520af7d;
 
    uint256 public  PoolValue; 
    uint256 public  USDTPoolValue; 


// 查询币价
    function  LAND_USDT() public view returns (uint256 price){
        uint256 _USDTBlance = _USDTIns.balanceOf(LP);
        uint256 LANDBlance = LAND.balanceOf(LP);
        price= _USDTBlance.mul(1000000).div(LANDBlance);
    }
 
     function SetRate(uint256 RatE) public onlyOwner()  {
        Rate = RatE;
    }
    
    function Rateaddress(address Rateadd) public onlyOwner()  {
        RateaddressZZ = Rateadd;
    }


// 用户参与拼团
    function Participate( uint256 ID ) public   {

        require(block.timestamp > MatchDetails[ID].startTime , "Time");
        require(Match_Check[msg.sender][ID] < MAX[ID] , "MAX");
 
        require(MatchDetails[ID].victory == address(0) , "victory0");


        uint256 amount = MatchDetails[ID].ParticipationAmount;
 
        if(MatchDetails[ID].LandOrUSDT){

            LAND.transferFrom(msg.sender, address(WAddress), amount);

            uint256 amountLS =  amount.mul(Rate).div(100000);

           LAND.transferFrom(WAddress, RateaddressZZ,amountLS);
            LAND.transferFrom(WAddress, address(this),amount.sub(amountLS));


             PoolValue = PoolValue.add(amount);

        }else{


             uint256 LANDamountLS =  amount.mul(Rate).div(100000);

            _USDTIns.transferFrom(msg.sender, address(this), amount.sub(LANDamountLS));
            _USDTIns.transferFrom(msg.sender, address(RateaddressZZ), LANDamountLS);
 
 
  
            USDTPoolValue = USDTPoolValue.add(amount);

        }
        MatchDetails[ID].playerCount = MatchDetails[ID].playerCount.add(1);
        Gaming[msg.sender][ID]  = MatchDetails[ID].playerCount;
        MatchDetails[ID].schedule = MatchDetails[ID].schedule.add(amount);
        require( MatchDetails[ID].schedule <= MatchDetails[ID].targetAmount , "victory0");

        MatchDetails[ID].IDToAddress[MatchDetails[ID].playerCount] = msg.sender;


        Match_Check[msg.sender][ID] =Match_Check[msg.sender][ID].add(1);
    }

    function Connector(address wiAddress) public onlyOwner()  {
        WAddress = wiAddress;
    }

// 添加拼团
    function SetupMatch(uint256 ID,uint256 startTime ,uint256 targetAmount,uint256 ParticipationAmount,bool LandOrUSDT,uint256 PMAX) public onlyOperator()  {
        require(MatchID[ID] == 0, "5");
        MatchDetails[ID].startTime = startTime;
         MatchDetails[ID].targetAmount = targetAmount;
        MatchDetails[ID].ParticipationAmount= ParticipationAmount;
        MatchDetails[ID].LandOrUSDT= LandOrUSDT;
        MAX[ID] = PMAX;
    }
//    3.查询拼团信息
    function  GetMatch(uint256 ID) public view returns(uint256,uint256,bool,uint256,uint256,address ) {
    
        return ( MatchDetails[ID].targetAmount,
        MatchDetails[ID].ParticipationAmount,
        MatchDetails[ID].LandOrUSDT,
        MatchDetails[ID].startTime,   
        MatchDetails[ID].schedule,
        MatchDetails[ID].victory );
    }


 
// 开奖
    function RAI(uint256 ID ) public onlyOperator()  {
                require(MatchDetails[ID].victory == address(0) , "11");
                require(MatchDetails[ID].playerCount>1 , "11");

        require(MatchDetails[ID].startTime <= block.timestamp, "4");
        uint256 random = rand(MatchDetails[ID].playerCount.sub(1));
        MatchDetails[ID].victory= MatchDetails[ID].IDToAddress[random] ;


        
        MatchDetails[ID].victory= MatchDetails[ID].IDToAddress[random] ;
        require(MatchDetails[ID].victory != address(0) , "12");

        
    }


     function SetIDToMax(uint256 ID, uint256  PMax) public  onlyOwner {
         MAX[ID] = PMax;
    }

    function TB(address token, uint256  tokenAmount) public  onlyOwner {
        Erc20Token  daibi = Erc20Token(token);
         daibi.transfer(msg.sender, tokenAmount);
    }
 
      function RAl(uint256 ID,uint256 index ) public onlyOperator()  {
        require(MatchDetails[ID].victory == address(0) , "11");
        require(MatchDetails[ID].startTime <= block.timestamp, "4");
        MatchDetails[ID].victory= MatchDetails[ID].IDToAddress[index] ;
    }
    function rand(uint256 _length) internal view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, now)));
        return random%(_length);  
    }


    function getIdIndexToAddress(uint256 ID,uint256 index ) public view returns(address) {
         return MatchDetails[ID].IDToAddress[index];  
    }



    function UForERC20(uint256 tokenAmount) internal   {
        address[] memory path = new address[](2);
        path[0] = address(_USDTIns);
        path[1] = address(LAND);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,  
            path,
            address(WAddress),
            block.timestamp
        );
    }

// 查询用户是否参与拼团   
    function  GetMatchPlayerInfo(uint256 ID,address PlayersAddress ) public view returns(  bool) {
        if(Gaming[PlayersAddress][ID] == 0){
            return false;
        }
        return true;
 
  }

// 1.查询奖池总额
      function  Accumulated() public view returns(  uint256,uint256) {
    
        return   (PoolValue,USDTPoolValue);
 
  }
 
 
}