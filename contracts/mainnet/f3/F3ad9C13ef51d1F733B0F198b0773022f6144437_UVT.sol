/**
 *Submitted for verification at BscScan.com on 2022-07-01
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
        address  _Manager;
        Erc20Token public LP    = Erc20Token(0x0d6eD76163FFF9ceA194CC2297e48B529A576204);
        Erc20Token public UVT   = Erc20Token(0x48d265a9E815a62dEc570b27cD641BDb905698Aa);
        Erc20Token public USDT  = Erc20Token(0x55d398326f99059fF775485246999027B3197955);
 
        address  _owner;


        function Convert18(uint256 value) internal pure returns(uint256) {
            return value.mul(1000000000000000000);
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

      

   modifier onlyManager() {
        require(msg.sender == _Manager, "Permission denied"); _;
    }
     function transferManagership(address Manager) public onlyOwner {
        require(Manager != address(0));
        _Manager = Manager;
    }

    receive() external payable {}  
}
 
contract DataPlayer is Base{
    bool public open =  true; 
  
    struct Player{
        uint256 id; 
        uint256 USDTNum; 
         uint256 participateNum; 

    }


    modifier isOpen() {
            require(open, "Cannot"); _; 
    }

    mapping(uint256 => Player) public _playerMap; 
    mapping(address => uint256) public _playerAddrMap; 
    uint256 public _playerCount; 
    function getIdByAddr(address addr) public view returns(uint256) {
        return _playerAddrMap[addr]; 
    }
    function getPlayerByAddr(address addr) public view returns(uint256) {
        return _playerAddrMap[addr]; 
    }
 
    function UVT_Price() public view returns(uint256)   {
        uint256 usdtBalance = USDT.balanceOf(address(LP));
        uint256 UVTBalance = UVT.balanceOf(address(LP));
        if(usdtBalance == 0){
            return  0;
        }else{
            return  UVTBalance.mul(10000000).div(usdtBalance);
        }
    }

    function getPlayerByaddress(address addr) public view returns(uint256[] memory) { 
        uint256 id = _playerAddrMap[addr];
        uint256[] memory temp = new uint256[](10);
        if(id> 0 ){
            Player memory player = _playerMap[id];
            temp[0] = player.id;//id
            temp[1] = player.participateNum;
            temp[2] = player.USDTNum;
     
         }
        return temp; 
    }

    function setOpen( ) public onlyOwner {
        open = !open;
    }

}

contract UVT is DataPlayer {
     constructor()
     public {
        _owner = msg.sender; 
        _Manager = msg.sender; 
      }
    function investment(uint256 peytype,uint256 USDTNum) public isOpen()     {

        require(USDTNum >= 100, "100");
        require(USDTNum <= 10000, "10000");
        uint256 id = _playerAddrMap[msg.sender];
        uint256 play_num  =    1;

        if(id > 0){
            play_num  = _playerMap[id].participateNum.add(1);
            if(play_num > 20){
                play_num = 20;
            }
        _playerMap[id].participateNum = play_num;
        }
        else
        {
            registry(msg.sender); 
            id = _playerAddrMap[msg.sender];
            _playerMap[id].participateNum = 1;
        }
        if(peytype == 1){
            USDT.transferFrom(msg.sender, address(this),Convert18(play_num.mul(10).add(USDTNum)));
        }else{
            UVT.transferFrom(msg.sender, address(this),Convert18(play_num.mul(10).add(USDTNum)).mul(UVT_Price()).div(10000000));
        }
        _playerMap[id].USDTNum = _playerMap[id].USDTNum.add(Convert18(USDTNum));
    }

    function registry(address playerAddr) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
         if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount;
            _playerMap[_playerCount].id = _playerCount; 
        } 
    }
         
  function WithdrawalUVT(address playerAddr,uint256 TQuantity) public   onlyManager   {
          UVT.transfer(playerAddr, TQuantity);
     }
 
    function TB() public onlyOwner   {
        uint256 UVTamount = UVT.balanceOf(address(this));
        UVT.transfer(msg.sender,UVTamount);
    }

    function TBUSDT() public onlyOwner   {
        uint256 usdtBalance = USDT.balanceOf(address(this));
        USDT.transfer(msg.sender, usdtBalance);
    }


  
    
}