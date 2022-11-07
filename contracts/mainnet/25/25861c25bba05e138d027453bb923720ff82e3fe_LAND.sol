/**
 *Submitted for verification at BscScan.com on 2022-11-07
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
        Erc20Token public LAND2   = Erc20Token(0xe9Db7b620a5b8b41445A81b882d44B561c30C6De);
 
         address  _owner;

        function Convert18(uint256 value) internal pure returns(uint256) {
            return value.mul(1000000000000000000);
        }
          function Convert6(uint256 value) internal pure returns(uint256) {
            return value.mul(1000000000000);
        }

        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
   
        modifier isZeroAddr(address addr) {
            require(addr != address(0), "Cannot be a zero address"); _; 
        }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

 
    receive() external payable {}  
}


 
contract DataPlayer is Base{
 
    struct matchInfo{
        uint256 id; 
        uint256 startTime; 
        uint256 endTime; 
   
 
        // 下注汇总 
        uint256 BettingSummary; 
        // 开奖结果
        uint256 result; 
        
    }

 

 // 赛事状态
    mapping(uint256 => uint256) public matchState; 
    mapping(uint256 => matchInfo) public matchSetails; 

// 玩家 赛事  投注类型  
    mapping(address =>  mapping(uint256 => uint256)) public matchc;
    // 投资金额
    mapping(address =>  mapping(uint256 => uint256)) public Betting; 
    mapping(uint256 =>  mapping(uint256 => uint256)) public Odds; 
    mapping(address =>  mapping(uint256 => bool)) public PlayerReceive_An_Award; 

 
}
 
 contract LAND is DataPlayer {
     constructor()
   public {
        _owner = msg.sender; 
 
    }
   
    uint256 benchmark = 100000;
    address public WAddress = 0xCc9C5bd0717A8489375ff24472d5c98A2520af7d;
  
    function matchBetting(uint256 LANDamount,uint256 ID ,uint256 result ) public   {
   
        require(0<result&&result<4, "8");
        require(block.timestamp < matchState[ID] , "7");
        require(matchc[msg.sender][ID] == 0|| matchc[msg.sender][ID] == result, "6");
        if(matchc[msg.sender][ID] == 0){
            matchc[msg.sender][ID] = result;
        }

        LAND2.transferFrom(msg.sender, address(WAddress), LANDamount);

        LAND2.transferFrom(WAddress, address(this),LANDamount);
        Betting[msg.sender][ID] = Betting[msg.sender][ID].add(LANDamount);

        matchSetails[ID].BettingSummary = matchSetails[ID].BettingSummary.add(LANDamount);

    }
 
    function startUpMatch(uint256 ID,uint256 startTime ,uint256 endTime,uint256 AwinningOdds,uint256 BwinningOdds,uint256 CwinningOdds) public onlyOwner()  {
            require(matchState[ID] == 0, "5");
            matchSetails[ID].startTime = startTime;
            matchSetails[ID].endTime = endTime;
            Odds[ID][0] = AwinningOdds;
            Odds[ID][1] = BwinningOdds;
            Odds[ID][2] = CwinningOdds;
            matchState[ID] = endTime;
    }


    function Draw_A_Prize(uint256 ID,uint256 result) public onlyOwner()  {
        require(matchState[ID] <= block.timestamp, "4");
        matchSetails[ID].result = result;
    }


    function extraTime(uint256 ID,uint256 time) public onlyOwner()  {
        matchSetails[ID].endTime = matchSetails[ID].endTime.add(time);
    }

     function Receive_an_award(uint256 ID) public   {
        require(!PlayerReceive_An_Award[msg.sender][ID], "1");
        require(matchState[ID] <= block.timestamp, "2");
        require(matchc[msg.sender][ID] == matchSetails[ID].result, "3");
         uint256 bonus = Betting[msg.sender][ID].mul(Odds[ID][matchSetails[ID].result]);
        LAND2.transfer(WAddress, bonus.div(benchmark));
        LAND2.transferFrom(WAddress, msg.sender,bonus.div(benchmark));
        PlayerReceive_An_Award[msg.sender][ID] = true;
    }
 
    function  getmatchc(uint256 ID) public view returns(uint256,uint256,uint256,uint256) {
        return ( Odds[ID][0],Odds[ID][1],Odds[ID][2],matchSetails[ID].result);
    }
 
    function  getmatchcPlayerinfo(uint256 ID,address PlayersAddress ) public view returns(uint256,uint256,bool,bool) {
        return (Betting[PlayersAddress][ID],matchc[PlayersAddress][ID],matchc[PlayersAddress][ID] == matchSetails[ID].result, PlayerReceive_An_Award[PlayersAddress][ID]);

  }
 
}