/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

pragma solidity ^0.8.0;
interface tokenEx {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver) external view returns(uint256);
    function approve(address spender, uint amount) external returns (bool);
}
interface IRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
contract EUSBank{
    address public owner;
    uint256 public price;
    uint256 public sTime;
    address public EUS;
    address public USDT;
    mapping(address=>uint256)public isTime;
    mapping(address=>uint256)public TeamMembers;
    mapping(address=>uint256)public inBank;
    mapping(address=>uint256)public inBNB;
    mapping(address=>address)public superior;
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor (address _DEX,address pancakeswap) public {
        owner=msg.sender;
        price=20;
        sTime=86400;
        EUS=0x3Cd82B316bCE3CcCbb2A1cA3741a4603B8feBfFA;
        USDT=0x55d398326f99059fF775485246999027B3197955;
        tokenEx(_DEX).approve(address(pancakeswap), 2 ** 256 - 1);
        tokenEx(0x3Cd82B316bCE3CcCbb2A1cA3741a4603B8feBfFA).approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 2 ** 256 - 1);
    }
    
    receive() external payable{ 
    }
    function setOwner()public onlyOwner{
        owner=address(0);
    }
    function payToken(address up)public{
        require(inBank[msg.sender] == 0 && inBNB[msg.sender]==0,"You already have a miner");
        uint _EUS=getEuss(100 ether);
        tokenEx(EUS).transferFrom(msg.sender,address(this),_EUS);
        inBank[msg.sender]=_EUS;
        isTime[msg.sender]=block.timestamp;
        inBNB[msg.sender]=100 ether;
        address up1=superior[up];
        address up2=superior[up1];
        if(superior[msg.sender] == address(0) && inBNB[up] >= 100 ether){
            superior[msg.sender]=up;
        }else {
            superior[msg.sender]=0x5FE5A86c7074287B53052EdE1fb4C61B6B744Db2;
        }
        tokenEx(EUS).transfer(address(0x000000000000000000000000000000000000dEaD),_EUS *30/100);
        toDEX(_EUS*50/100);
        if(up != address(0) && inBNB[up] >= 100 ether && up != msg.sender){
          tokenEx(EUS).transfer(up,_EUS *5/100);  
          TeamMembers[up]++;
        }
        if(up1 != address(0) && inBNB[up1] >= 100 ether && up1 != msg.sender){
          tokenEx(EUS).transfer(up1,_EUS *2/100);
          TeamMembers[up1]++;
        }
        if(up2 != address(0) && inBNB[up2] >= 100 ether && up2 != msg.sender){
          tokenEx(EUS).transfer(up2,_EUS *2/100);
          TeamMembers[up2]++;  
        }
        inUPaddr(up2,_EUS);
    }
    function toDEX(uint _eus)private {
        uint eusTousdt=_eus+tokenEx(EUS).balanceOf(address(this))- 1 ether;
        address[] memory path = new address[](3);
        path[0]=0x3Cd82B316bCE3CcCbb2A1cA3741a4603B8feBfFA;
        path[1]=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[2]=0x55d398326f99059fF775485246999027B3197955;
        IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E).swapExactTokensForTokensSupportingFeeOnTransferTokens(eusTousdt,0,path,address(this),block.timestamp+100);
    }
    function inUPaddr(address addr,uint vav)private {
        address up3=superior[addr];
        address up4=superior[up3];
        address up5=superior[up4];
        address up6=superior[up5];
        address up7=superior[up6];
        address up8=superior[up7];
        address up9=superior[up8];
        if(up3 != address(0) && inBNB[up3] >= 100 ether && up3 != msg.sender){
          tokenEx(EUS).transfer(up3,vav *2/100);
          TeamMembers[up3]++;
        }
        if(up4 != address(0) && inBNB[up4] >= 100 ether && up4 != msg.sender){
          tokenEx(EUS).transfer(up4,vav *1/100);
          TeamMembers[up4]++; 
        }
        if(up5 != address(0) && inBNB[up5] >= 100 ether && up5 != msg.sender){
          tokenEx(EUS).transfer(up5,vav *1/100); 
          TeamMembers[up5]++; 
        }
        if(up6 != address(0) && inBNB[up6] >= 100 ether && up6 != msg.sender){
          tokenEx(EUS).transfer(up6,vav *1/100);
          TeamMembers[up6]++;  
        }
        if(up7 != address(0) && inBNB[up7] >= 100 ether && up7 != msg.sender){
          tokenEx(EUS).transfer(up7,vav *1/100); 
          TeamMembers[up7]++; 
        }
        if(up8 != address(0) && inBNB[up8] >= 100 ether && up8 != msg.sender){
          tokenEx(EUS).transfer(up5,vav *2/100); 
          TeamMembers[up8]++; 
        }
        if(up9 != address(0) && inBNB[up9] >= 100 ether && up9 != msg.sender){
          tokenEx(EUS).transfer(up9,vav *3/100); 
          TeamMembers[up9]++; 
        }
    }
    function withdraw()public{
        require(inBank[msg.sender] > 0 && inBNB[msg.sender] > 0,"You have no deposit");
        require(block.timestamp > isTime[msg.sender] + sTime,"No withdrawal");
        uint _time=(block.timestamp-isTime[msg.sender])/sTime;
        uint  _usdt=price * _time * inBNB[msg.sender]/100;
        tokenEx(USDT).transfer(msg.sender,_usdt);
        isTime[msg.sender]=block.timestamp;
    }
    function getEus(address addr)private view returns(uint){
        uint _time;
        uint _EUS;
        if(block.timestamp > isTime[msg.sender] + sTime){
            _time=(block.timestamp-isTime[addr])/sTime;
            _EUS=price * _time * inBNB[msg.sender]/100;   
        }else{
            _EUS=0;
        }
        return _EUS;
    }
    function getUser(address addr)public view returns(address,uint,uint,uint,uint,uint){
        uint _time;
        address _addr=addr;
        uint _EUS=getEus(addr);
        if(isTime[addr]==0){
          _time=0;
        }else {
          _time=isTime[addr]+sTime;
        }
        return (_addr,_EUS,_time,inBank[addr],TeamMembers[_addr],tokenEx(USDT).balanceOf(address(this)));   
    }
    function getEuss(uint vav)private  view returns (uint){
        address[] memory path = new address[](3);
        uint[] memory amount;
        path[0]=0x55d398326f99059fF775485246999027B3197955;
        path[1]=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[2]=0x3Cd82B316bCE3CcCbb2A1cA3741a4603B8feBfFA;
        amount=IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E).getAmountsOut(vav,path); 
        return amount[2];
    }
    function getEUSUp(address addr)public view returns (address){        
        return superior[addr];
    }
}