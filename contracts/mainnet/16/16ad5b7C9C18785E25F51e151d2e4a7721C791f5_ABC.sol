/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-17
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
        assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

 
    interface Erc20Token {//konwnsec//ERC20 接口
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
         Erc20Token   public ABC = Erc20Token(0x9F6E25BbCefC1d5ed1FA7711BdF184dd8C72e782);
        address public _owner;
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


contract ABC is Base{

    struct InvestInfo {
        uint256 id; // 
        address selfaddress; // 
        uint256 produceABC; //  
        uint256 pledgeABCTZ; //  
        uint256 pledgeABC; // 

        uint256 Ptime; // 结算时间
        address superior; // 上级
    }
  
     mapping(uint256 => InvestInfo) public _playerMap; 
    uint256 lilv = 3000; // 


    uint256 oneday = 1 days; // 
    mapping(address => uint256) public _playerAddrMap; 
    uint256 public _playerCount;

    function registry(address playerAddr,address superior) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount; 
            _playerMap[_playerCount].id = _playerCount; 
            _playerMap[_playerCount].superior = superior; 
            _playerMap[_playerCount].selfaddress = msg.sender; 
        }
    }

    function pledge(uint256 quantity,address superior) public {
        registry(msg.sender,superior);
        ABC.transferFrom(msg.sender,address(this), quantity);

        uint256 id = _playerAddrMap[msg.sender];
        if(block.timestamp.sub(_playerMap[id].Ptime)>oneday&&_playerMap[id].produceABC > 0){
            settleStaticABC();
        }
        uint256  investment = quantity.mul(3);
        _playerMap[id].pledgeABC = _playerMap[id].pledgeABC.add(investment); 
        _playerMap[id].produceABC = _playerMap[id].produceABC.add(investment);
        _playerMap[id].pledgeABCTZ = _playerMap[id].pledgeABCTZ.add(investment);

        introducePrize(  quantity.div(10),_playerMap[id].superior,6);
        _playerMap[id].Ptime = block.timestamp;
    }

    function settleStaticABC() public {
        uint256 id = _playerAddrMap[msg.sender];
        InvestInfo memory investList = _playerMap[id];
        uint256 staticaAmount = 0;
        uint256 lsrewardABC = investList.pledgeABCTZ;
        uint256 daynum = block.timestamp.sub(investList.Ptime);
        require(daynum > oneday, " time field" ); 
        require(lsrewardABC > 0, " rewardABC field" ); 
        uint256 dayd = lsrewardABC.mul(lilv).div(1000000);
        staticaAmount = daynum.div(oneday).mul(dayd);    
 
        require(staticaAmount > 0, " Amount field" );
        
        if( _playerMap[id].produceABC >staticaAmount){
            ABC.transfer(address(msg.sender), staticaAmount);
            _playerMap[id].produceABC =  _playerMap[id].produceABC.sub(staticaAmount);

        }else
        {
            ABC.transfer(address(msg.sender), _playerMap[id].produceABC);
            _playerMap[id].pledgeABCTZ = 0;
            _playerMap[id].produceABC =  0;
        }
 
       _playerMap[id].Ptime = block.timestamp;
    }

  function setlilv(uint256 newLilv) public onlyOwner {
        lilv = newLilv; 
    }

 
    function binding(address superior) public {

    }

 
    function introducePrize(uint256 quantity,address superior,uint256 round) internal {
        uint256 id = _playerAddrMap[superior];
        if(round>0&&id>0){
            if(_playerMap[id].produceABC > 0){
 
                        if( round == 5){
                            quantity = quantity.div(2);
                        }




        if( _playerMap[id].produceABC >quantity){
            ABC.transfer(_playerMap[id].selfaddress, quantity);
            _playerMap[id].produceABC =  _playerMap[id].produceABC.sub(quantity);

        }else
        {
            ABC.transfer(_playerMap[id].selfaddress, _playerMap[id].produceABC);
            _playerMap[id].produceABC =  0;
            _playerMap[id].pledgeABCTZ = 0;
        }

                introducePrize( quantity,_playerMap[id].superior,round.sub(1));
            }
        }
    }

    function tbABC() public  onlyOwner {
        uint256 Balance = ABC.balanceOf(address(this));
         ABC.transfer(msg.sender, Balance);
    }
    constructor()public {
        _owner = msg.sender; 
    }
}