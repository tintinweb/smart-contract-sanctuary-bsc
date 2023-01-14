/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

contract Calu{
    mapping(address=>bool) public whites;
    address admin = msg.sender;

    modifier isAdmin(){
        require(msg.sender == admin,"not error");
        _;
    }
    function cal(uint keepTime ,uint userBalance,address addr)public view returns(uint){        
        if (keepTime == 0) keepTime =block.timestamp;
        uint timeRate = (block.timestamp - keepTime)/900;
        uint addToken = userBalance*2/10000*timeRate;
        return addToken;
    }

}