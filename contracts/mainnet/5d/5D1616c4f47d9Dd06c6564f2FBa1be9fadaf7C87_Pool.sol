/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

pragma solidity 0.5.16;
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
     function transferFrom(address a,address b,uint256 am) external returns (bool success);
} 
contract Pool{
    mapping (address => address) public referrerAddress;
    mapping (address => uint256) public investAmount;
    address public tokenaddr=address(0x55d398326f99059fF775485246999027B3197955);
    address public owner;
    uint[] public rate=[0,67,34,17,17,17,17,17];
    address public toaddr = address(0x9260c0c45977A70C5394CA2c74c8bc8026B63903);
    constructor() public {
      owner = msg.sender;
    }
    function setToken(address a) public {
      require(msg.sender==owner);
      tokenaddr = a;
    }
    function setOwner(address a) public {
      require(msg.sender==owner);
      owner = a;
    }
     function setReferrer(address a,address b) public {
        require(msg.sender==owner);
        referrerAddress[a] = b;
    }
    function setRate(uint256 i,uint256 x) public  {
        require(msg.sender==owner);
        rate[i] = x;
    }
    function setToaddr(address a) public {
        require(msg.sender==owner);
        toaddr = a;
    }
    function tokenTransfer(address t,uint256 am) public  returns (bool success){
        require(msg.sender==owner);
        return token(tokenaddr).transfer(t,am);
    }
    function invest(uint256 am) public  returns (bool success){
        uint256 leftam=am;
        address cur=msg.sender;
        investAmount[msg.sender]+=am;
        for (uint256 i = 1; i <= 7; i++) {
            cur = referrerAddress[cur];
            if (cur == address(0)) {
                break;
            }
            uint tam = am * rate[i] / 1000;
            if(investAmount[cur]<200*10**18){
                token(tokenaddr).transferFrom(msg.sender,toaddr,tam);
            }else{
                token(tokenaddr).transferFrom(msg.sender,cur,tam);
            }
            leftam = leftam - tam;
        }
        return  token(tokenaddr).transferFrom(msg.sender,toaddr,leftam);
    }
    function setreferrerAddress(address readdr) external {
        require(msg.sender != readdr, 'error');
        if (referrerAddress[msg.sender] == address(0)) {
            referrerAddress[msg.sender] = readdr;
        }
    }
    
}