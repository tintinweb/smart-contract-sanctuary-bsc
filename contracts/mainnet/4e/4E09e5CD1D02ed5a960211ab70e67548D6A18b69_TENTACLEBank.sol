/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity =0.8.17;

interface tokenEx {
    function transfer(address receiver, uint256 amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver) external view returns(uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function destroy(uint256 _value) external returns(bool);
}

interface IRouter {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}

contract TENTACLEBank{
    address public owner;
    uint256 public price;
    uint256 public sTime;
    address public TENTACLE;
    address public USDT = address(0x55d398326f99059fF775485246999027B3197955);
    address private uniswapV2Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    mapping(address=>uint256)public isTime;
    mapping(address=>uint256)public TeamMembers;
    mapping(address=>uint256)public sUSDT;
    mapping(address=>uint256)public sTENTACLE;
    mapping(address=>uint256)public inBNB;
    mapping(address=>address)public superior;
    mapping(address=>bool)public useInvitationCode;

    modifier onlyOwner() {
        require(owner  ==  msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    constructor () {
        owner = msg.sender;
        price = 10;
        sTime = 86400; //1 DAY
        TENTACLE = address(0x2f8e8Ec80355aCFEe8CcBBA40d895Db61759df3D);//token
        inBNB[TENTACLE] = 10 ether;
        isTime[TENTACLE] = block.timestamp;
    }
    
    receive() external payable{ 
    }

    function setOld(address addr,address up,uint256 _time) external onlyOwner{
        isTime[addr] = _time;
        inBNB[addr] = 10 ether;
        superior[addr] = up;
    }

    function setOwner() external onlyOwner{
        owner = address(0);
    }
    
    function payToken(address up) external {
        require(inBNB[msg.sender] == 0,"You already have a miner");
        require(inBNB[up] == 10 ether,"Up not miner");
        uint256 _TENTACLEss = getTENTACLEs();
        uint256 _TENTACLE = _TENTACLEss * 97 / 100;
        tokenEx(TENTACLE).transferFrom(msg.sender,address(this),_TENTACLEss);
        isTime[msg.sender] = block.timestamp;
        inBNB[msg.sender] = 10 ether;
        address up1 = superior[up];
        address up2 = superior[up1];
        if(superior[msg.sender] == address(0) && inBNB[up] >= 10 ether){
            if(useInvitationCode[up]){
                useInvitationCode[msg.sender] = true;
            }
            superior[msg.sender] = up;
        }else {
            superior[msg.sender] = TENTACLE;
        }
        uint256 V = _TENTACLE * 30 / 100;
        tokenEx(TENTACLE).destroy(V);
        toDEX(_TENTACLE - V);
        if(up != address(0) && inBNB[up] >= 10 ether && up != msg.sender){
            tokenEx(USDT).transfer(up,5 * 1e17);
            TeamMembers[up] ++;
            sTENTACLE[up] += 5 * 1e17;
        }
        if(up1 != address(0) && inBNB[up1] >= 10 ether && up1 != msg.sender){
            tokenEx(USDT).transfer(up1,2 * 1e17);
            TeamMembers[up1] ++;
            sTENTACLE[up1] += 2 * 1e17;
        }
        if(up2 != address(0) && inBNB[up2] >= 10 ether && up2 != msg.sender){
            tokenEx(USDT).transfer(up2,2 * 1e17);
            TeamMembers[up2] ++;
            sTENTACLE[up2] += 2 * 1e17;  
        }
        inUPaddr(up2);
    }

    function toDEX(uint256 _V) public {
        address[] memory path = new address[](2);
        path[0] = TENTACLE;
        path[1] = USDT;
        IRouter(uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(_V , 0 , path , address(this) , block.timestamp + 100);
    }

    function inUPaddr(address addr) private {
        address up3 = superior[addr];
        address up4 = superior[up3];
        address up5 = superior[up4];
        address up6 = superior[up5];
        address up7 = superior[up6];
        address up8 = superior[up7];
        address up9 = superior[up8];
        if(up3 != address(0) && inBNB[up3] >= 10 ether && up3 != msg.sender){
          tokenEx(USDT).transfer(up3,2 * 1e17);
          TeamMembers[up3] ++;
          sTENTACLE[up3] += 2 * 1e17;
        }
        if(up4 != address(0) && inBNB[up4] >= 10 ether && up4 != msg.sender){
          tokenEx(USDT).transfer(up4,1 * 1e17);
          TeamMembers[up4] ++; 
          sTENTACLE[up4] += 1 * 1e17;
        }
        if(up5 != address(0) && inBNB[up5] >= 10 ether && up5 != msg.sender){
          tokenEx(USDT).transfer(up5,1 * 1e17); 
          TeamMembers[up5] ++; 
          sTENTACLE[up5] += 1 * 1e17;
        }
        if(up6 != address(0) && inBNB[up6] >= 10 ether && up6 != msg.sender){
          tokenEx(USDT).transfer(up6,1 * 1e17);
          TeamMembers[up6] ++;
          sTENTACLE[up6] += 1 * 1e17;  
        }
        if(up7 != address(0) && inBNB[up7] >= 10 ether && up7 != msg.sender){
          tokenEx(USDT).transfer(up7,1 * 1e17); 
          TeamMembers[up7] ++; 
          sTENTACLE[up7] += 1 * 1e17;
        }
        if(up8 != address(0) && inBNB[up8] >= 10 ether && up8 != msg.sender){
          tokenEx(USDT).transfer(up5,2 * 1e17); 
          TeamMembers[up8] ++; 
          sTENTACLE[up8] += 2 * 1e17;
        }
        if(up9 != address(0) && inBNB[up9] >= 10 ether && up9 != msg.sender){
          tokenEx(USDT).transfer(up9,3 * 1e17); 
          TeamMembers[up9] ++;
          sTENTACLE[up9] += 3 * 1e17; 
        }
    }

    function withdraw() external {
        require(inBNB[msg.sender] > 0,"You have no deposit");
        require(block.timestamp > isTime[msg.sender] + sTime,"No withdrawal");
        uint256 _time = (block.timestamp - isTime[msg.sender]) / sTime;
        uint256  _usdt = price * _time * inBNB[msg.sender] / 100;
        if(useInvitationCode[msg.sender]){
            require(sUSDT[msg.sender] + _usdt <= 200 ether);
        }else{
            require(sUSDT[msg.sender] + _usdt <= 100 ether);
        }
        
        tokenEx(USDT).transfer(msg.sender,_usdt);
        isTime[msg.sender] = block.timestamp;
        sUSDT[msg.sender] += _usdt;
    }

    function getTENTACLE(address addr) private view returns(uint256){
        uint256 _time;
        uint256 _TENTACLE;
        if(block.timestamp > isTime[msg.sender] + sTime){
            _time = (block.timestamp - isTime[addr]) / sTime;
            _TENTACLE = price * _time * inBNB[msg.sender] / 100;   
        }else{
            _TENTACLE = 0;
        }
        return _TENTACLE;
    }
    function getUser(address addr) external view returns(address,uint256,uint256,uint256,uint256,uint256,uint256){
        uint256 _time;
        address _addr = addr;
        uint256 _TENTACLE = getTENTACLE(addr);
        if(useInvitationCode[addr]){
            if(sUSDT[addr] > 200 ether){
                _TENTACLE = 0;
            }
        }else{
            if(sUSDT[addr] > 100 ether){
                _TENTACLE = 0;
            }
        }
        
        if(isTime[addr] == 0){
          _time = 0;
        }else {
          _time = isTime[addr] + sTime;
        }
        return (_addr,_TENTACLE,_time,sUSDT[_addr],sTENTACLE[_addr],TeamMembers[_addr],tokenEx(USDT).balanceOf(address(this)));   
    }

    function getTENTACLEs() public view returns (uint256){
        address[] memory path = new address[](2);
        uint256[] memory amount;
        path[0] = USDT;
        path[1] = TENTACLE;
        amount = IRouter(uniswapV2Router).getAmountsOut(10 ether,path); 
        return amount[1];
    }

    function getBNBTENTACLEs() public view returns (uint256){
        address[] memory path = new address[](3);
        uint256[] memory amount;
        path[0] = USDT;
        path[1] = USDT;
        path[2] = TENTACLE;
        amount = IRouter(uniswapV2Router).getAmountsOut(10 ether,path); 
        return amount[2];
    }

    function getTENTACLEUp(address addr) external view returns (address){        
        return superior[addr];
    }

    function addUseInvitationCode(address[] memory _addr) external onlyOwner {
        for(uint8 i = 0;i < _addr.length;i++){
            useInvitationCode[_addr[i]] = true;
        }
    }

    function removeUseInvitationCode(address[] memory _addr) external onlyOwner {
        for(uint8 i = 0;i < _addr.length;i++){
            useInvitationCode[_addr[i]] = false;
        }
    }

}