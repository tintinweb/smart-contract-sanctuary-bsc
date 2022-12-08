/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

pragma solidity ^0.5.17;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    address private owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = 0x11216C7cfad0b03e501039dc4755E06021c8E851;
    }

    function CurrentOwner() public view returns (address){
        return owner;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256);
}

contract contract1 is Ownable {

    using SafeMath for uint256;

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    //allocateTokens
    address public recAddress = 0x9ce6E96E8145FD71f13F4BD0915564cd4c41BA8E;  //NMER/COF/GOD cliam
    address public tokenAddr = 0x46FdeF9029Da5896451B6149d3951A32FEac1734;  //GOD
    uint256 public startTime = 1658937600;
    uint256 public lastTime = startTime;
    uint256 public oneDay = 60 * 60 * 24;
    // uint256 public oneDay = 60 * 30;
    uint256 public tokenAmount = 110e8;
     
    mapping(uint256 => uint256) public allocateRate;
    uint256 public num;

    event AllocateTokens(uint256 amount, uint256 _time);
     event SetToken(address indexed from, address indexed token, uint256 now);

     function getAmount(uint start, uint last) public view returns (uint256, uint256){
        require(start <= last, "s>l");
        if (now.sub(start) < oneDay) {  
            return (0, last);
        }
        uint day = now.sub(last).div(oneDay);  
        uint amount = tokenAmount.mul(day);  
        uint newTime = day.mul(oneDay).add(last);  
        return (amount, newTime);
    }
    
    function allocateTokens() public {
        (uint256 amount, uint256 curTime) = getAmount(startTime, lastTime); 
        if (amount > 0) {
            lastTime = curTime;  
            safeTransfer(tokenAddr, recAddress, amount);  
            emit AllocateTokens(amount, now);
        }
    }


      function setToken(address tokenAddress) public onlyOwner{
        require(tokenAddress != address(0),"zero address!");
        tokenAddr = tokenAddress;
        emit SetToken(msg.sender,tokenAddr, now);
    }




}