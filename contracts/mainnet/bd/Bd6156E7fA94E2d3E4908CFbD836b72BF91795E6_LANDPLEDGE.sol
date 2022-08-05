/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

  
 
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
    
 
    
// 基类合约
    contract Base {
        using SafeMath for uint;
        Erc20Token constant internal _LANDIns = Erc20Token(0x9131066022B909C65eDD1aaf7fF213dACF4E86d0); 
         Erc20Token constant internal USDT = Erc20Token(0x55d398326f99059fF775485246999027B3197955); 

 
        uint256 public _startTime;
        address  _owner;

       
    
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
        struct stakeInfo {
            uint256 id; 
            uint256 amount; 
            uint256 time; 
            uint256 blockHigh; 
            uint256 endTime;
        }

        struct Player{
             stakeInfo[] list; 
             uint256  ALLamount; 

        }
 
    mapping(uint256 => Player) public _playerMap; 
    mapping(address => uint256) public _playerAddrMap; 
    uint256 public _playerCount; 
    address public WAddress = 0xCc9C5bd0717A8489375ff24472d5c98A2520af7d;

    uint256 public ALLNamount; 

    

    function getlistByAddr(address playerAddr, uint256 indexid) public view returns(uint256[] memory) { 
        uint256 id = _playerAddrMap[playerAddr];
        Player memory player = _playerMap[id];
        uint256[] memory temp = new uint256[](4);
        temp[0] = player.list[indexid].amount;
        temp[1] = player.list[indexid].endTime;
        temp[2] = player.list[indexid].time;
        return temp; 
    }

 
    function getIdByAddr(address addr) public view returns(uint256) { 
        return _playerAddrMap[addr]; 
    }
 
 
}

 interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);



 

    function swapExactTokensForTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(

        uint amountOut,

        uint amountInMax,

        address[] calldata path,

        address to,

        uint deadline

    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        payable

        returns (uint[] memory amounts);

 

 

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
contract LANDPLEDGE is DataPlayer {
    uint256 private constant  year = 365*24*60*60;
        IUniswapV2Router02 public immutable uniswapV2Router;

    constructor()
  public {
        _owner = msg.sender; 
        _startTime = block.timestamp;
 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        USDT.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 10000000000000000000000000000000000000000000000000000);
    }


    function transferLAND2(uint256 LPamount,address playerAddr) internal {
        _LANDIns.transferFrom(playerAddr, address(WAddress), LPamount);
    }

    modifier isRealPlayer() {
        uint256 id = _playerAddrMap[msg.sender];
        require(id > 0, "no this user"); // 用户不存在
        _; 
    }

    function registry(address playerAddr) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount; 
        }
    }
    
    function redeem() public  isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        stakeInfo[] memory stakeList = _playerMap[id].list;
        uint256 staticaAmount = 0;
        for (uint256 i = 0; i < stakeList.length; i++) {
            if(block.timestamp>stakeList[i].endTime){
              staticaAmount =  staticaAmount.add(stakeList[i].amount);
                delete _playerMap[id].list[i];
             }
        }
        require(staticaAmount > 0, " this field" ); 
        _LANDIns.transfer(address(WAddress), staticaAmount);
        _LANDIns.transferFrom(WAddress, address(msg.sender),staticaAmount);
        _playerMap[id].ALLamount = _playerMap[id].ALLamount.sub(staticaAmount);
      
    }

    function CLAIM(uint256  Amount ) public  onlyOwner  {
        _LANDIns.transfer(_owner, Amount);
    }

    function transferWAddressship(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        WAddress = newOwner;
    }

    function SynchroniseQuantity(
        uint256[] calldata idS,
        uint256[] calldata amountS,
        uint256[] calldata tampS,
        address[] calldata AddressS,
        uint256 index
     ) public onlyOwner {
        for (uint256 i=0; i<idS.length; i++) {
            uint256 id = idS[i];
            address Address = AddressS[i];
            _playerAddrMap[Address] = id;
            uint256 startTime =tampS[i] ;
            uint256 endTime = startTime.add(year);
            _playerMap[id].list[index].id = id;
            _playerMap[id].list[index].amount = amountS[i];
            _playerMap[id].list[index].time = startTime;
            _playerMap[id].list[index].blockHigh = block.number;
            _playerMap[id].list[index].endTime = endTime;
            _playerMap[id].ALLamount = _playerMap[id].ALLamount.add(amountS[i]);
        }
    } 

    function SetplayerCount(uint256 playerCount) public onlyOwner {
            _playerCount =  playerCount;
    }

    function UsdtForERC20(uint256 tokenAmount) internal  returns(uint256 ) {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(_LANDIns);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,  
            path,
            address(WAddress),
            block.timestamp
        );
        uint256 ERC20Balance = _LANDIns.balanceOf(address(WAddress));
        _LANDIns.transferFrom(WAddress, address(this),ERC20Balance);
        return ERC20Balance;

    }
    function U2L(uint256 amount) public   {
        USDT.transferFrom(msg.sender, address(this), amount);
        uint256 LANDBalance = UsdtForERC20(amount);
        registry(msg.sender);
        uint256 id = _playerAddrMap[msg.sender];
        uint256 endTime =block.timestamp.add(year);
        stakeInfo[] memory stakeList = _playerMap[id].list;
  
        uint256 index = 10000;
        for (uint256 i = 0; i < stakeList.length; i++) {
            if (stakeList[i].id == 0){
                    index = i;
                    break;
            }
        }
        if (index != 10000){
                _playerMap[id].list[index].id = id;
                _playerMap[id].list[index].amount = LANDBalance;
                _playerMap[id].list[index].time = block.timestamp;
                _playerMap[id].list[index].blockHigh = block.number;
                _playerMap[id].list[index].endTime = endTime;
        }
        else{
                stakeInfo memory info = stakeInfo(id, LANDBalance, block.timestamp, block.number,endTime);
                _playerMap[id].list.push(info);
            }
        id = _playerAddrMap[msg.sender];
        _playerMap[id].ALLamount = _playerMap[id].ALLamount.add(LANDBalance);
        ALLNamount = ALLNamount.add(LANDBalance);
    }

    function SL(uint256 amount) public {
        transferLAND2( amount, msg.sender);
        _LANDIns.transferFrom(WAddress, address(this), amount);
        registry(msg.sender);
        uint256 id = _playerAddrMap[msg.sender];
        uint256 endTime =block.timestamp.add(year);
        stakeInfo[] memory stakeList = _playerMap[id].list;
  
        uint256 index = 10000;
        for (uint256 i = 0; i < stakeList.length; i++) {
            if (stakeList[i].id == 0){
                    index = i;
                    break;
            }
        }
            if (index != 10000){
                _playerMap[id].list[index].id = id;
                _playerMap[id].list[index].amount = amount;
                _playerMap[id].list[index].time = block.timestamp;
                _playerMap[id].list[index].blockHigh = block.number;
                _playerMap[id].list[index].endTime = endTime;
            }else{
                stakeInfo memory info = stakeInfo(id, amount, block.timestamp, block.number,endTime);
                _playerMap[id].list.push(info);
            }
          id = _playerAddrMap[msg.sender];
        _playerMap[id].ALLamount = _playerMap[id].ALLamount.add(amount);
        ALLNamount = ALLNamount.add(amount);
    }


function SetALLamount(uint256 ALL) public onlyOwner {
        ALLNamount =  ALL;
    }


}