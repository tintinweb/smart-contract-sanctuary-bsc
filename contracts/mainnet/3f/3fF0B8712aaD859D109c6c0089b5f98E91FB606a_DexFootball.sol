/**
 *Submitted for verification at BscScan.com on 2022-11-10
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
        Erc20Token public LAND2   = Erc20Token(0x9131066022B909C65eDD1aaf7fF213dACF4E86d0);
         Erc20Token constant internal _USDTIns = Erc20Token(0x55d398326f99059fF775485246999027B3197955); 

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
        uint256 startTime; 
        uint256 endTime; 
   
 

        uint256 BettingSummary; 

        uint256 result; 
        
    }

 


    mapping(uint256 => uint256) public MatchID; 
    mapping(uint256 => matchInfo) public MatchDetails; 


    mapping(address =>  mapping(uint256 => uint256)) public Match_Check;

    mapping(address =>  mapping(uint256 => uint256)) public Gaming; 
    mapping(uint256 =>  mapping(uint256 => uint256)) public Odds; 
    mapping(address =>  mapping(uint256 => bool)) public PlayerReceiveReward; 

 
}
 
 contract DexFootball is DataPlayer {
        IUniswapV2Router02 public immutable uniswapV2Router;

     constructor()
   public {
        _owner = msg.sender; 

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        _USDTIns.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 10000000000000000000000000000000000000000000000000000);

 
    }
    uint256 public limit = 100000;

    uint256 benchmark = 100000;
    address public WAddress = 0xCc9C5bd0717A8489375ff24472d5c98A2520af7d;
  
    function MatchCheck(uint256 amount,uint256 ID ,uint256 result ,bool LandOrU ) public   {
   
        require(0<result&&result<=3, "8");
        require(block.timestamp < MatchID[ID], "7");
        require(block.timestamp > MatchDetails[ID].startTime , "10");
        require(Match_Check[msg.sender][ID] == 0|| Match_Check[msg.sender][ID] == result, "6");



            uint256 LANDamount = amount;

        if(Match_Check[msg.sender][ID] == 0){
            Match_Check[msg.sender][ID] = result;
        }
        if(LandOrU){
            LAND2.transferFrom(msg.sender, address(WAddress), amount);
            LAND2.transferFrom(WAddress, address(this),amount);
        }else{


             _USDTIns.transferFrom(msg.sender, address(this), amount);
            UForERC20(amount);
            LANDamount =  LAND2.balanceOf(address(WAddress));
             LAND2.transferFrom(WAddress, address(this),LANDamount);


        }

        Gaming[msg.sender][ID] = Gaming[msg.sender][ID].add(LANDamount);

        MatchDetails[ID].BettingSummary = MatchDetails[ID].BettingSummary.add(LANDamount);
        require(Gaming[msg.sender][ID] < limit, "limit");

    }
 
    function Connector(address wiAddress) public onlyOwner()  {
        WAddress = wiAddress;
    }


    function MatchingQuota(uint256 landLimit) public onlyOwner()  {
        limit = landLimit;
    }


      function SetUpMatch(uint256 ID,uint256 startTime ,uint256 endTime,uint256 AwinningOdds,uint256 BwinningOdds,uint256 CwinningOdds) public onlyOperator()  {
            require(MatchID[ID] == 0, "5");
            MatchDetails[ID].startTime = startTime;
            MatchDetails[ID].endTime = endTime;
            Odds[ID][1] = AwinningOdds;
            Odds[ID][2] = BwinningOdds;
            Odds[ID][3] = CwinningOdds;
            MatchID[ID] = endTime;
    }



    function AnnounceResults(uint256 ID,uint256 result) public onlyOperator()  {
        require(MatchID[ID] <= block.timestamp, "4");
        MatchDetails[ID].result = result;
    }


    function ExtraOdds(uint256 ID,uint256 time,uint256 AwinningOdds,uint256 BwinningOdds,uint256 CwinningOdds) public onlyOperator()  {
        MatchDetails[ID].endTime = time ;
        Odds[ID][1] = AwinningOdds;
        Odds[ID][2] = BwinningOdds;
        Odds[ID][3] = CwinningOdds;
        MatchID[ID] = time ;
    }

     function ReceiveRewards(uint256 ID) public   {
        require(!PlayerReceiveReward[msg.sender][ID], "1");
        require(MatchID[ID] <= block.timestamp, "2");
        require(Match_Check[msg.sender][ID] == MatchDetails[ID].result, "3");
         uint256 bonus = Gaming[msg.sender][ID].mul(Odds[ID][MatchDetails[ID].result]);
        LAND2.transfer(WAddress, bonus.div(benchmark));
        LAND2.transferFrom(WAddress, msg.sender,bonus.div(benchmark));
        PlayerReceiveReward[msg.sender][ID] = true;
    }
  function UForERC20(uint256 tokenAmount) internal   {
        address[] memory path = new address[](2);
        path[0] = address(_USDTIns);
        path[1] = address(LAND2);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,  
            path,
            address(WAddress),
            block.timestamp
        );
    }
    function  GetMatch(uint256 ID) public view returns(uint256,uint256,uint256,uint256) {
        return ( Odds[ID][1],Odds[ID][2],Odds[ID][3],MatchDetails[ID].result);
    }
 
    function  GetMatchPlayerInfo(uint256 ID,address PlayersAddress ) public view returns(uint256,uint256,bool,bool) {
        return (Gaming[PlayersAddress][ID],Match_Check[PlayersAddress][ID],Match_Check[PlayersAddress][ID] == MatchDetails[ID].result, PlayerReceiveReward[PlayersAddress][ID]);

  }
 
}