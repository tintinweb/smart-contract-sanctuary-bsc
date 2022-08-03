/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

pragma solidity 0.5.16;
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
     function transferFrom(address a,address b,uint256 am) external returns (bool success);
} 
contract Pool{
    mapping (address => address) public referrerAddress;
    address public tokenaddr=address(0x55d398326f99059fF775485246999027B3197955);
    address public owner;
    uint[] public rate=[0,20,10,5,5,5,5,5];
    address public toaddr = address(0x1A28c5068A7a772F0c50f32D85229671DF2e88B6);
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
        for (uint256 i = 1; i <= 7; i++) {
            cur = referrerAddress[cur];
            if (cur == address(0)) {
                break;
            }
            uint tam = am * rate[i] / 100;
            token(tokenaddr).transferFrom(msg.sender,cur,tam);
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