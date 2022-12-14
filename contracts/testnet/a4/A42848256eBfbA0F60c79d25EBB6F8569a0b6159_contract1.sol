/**
 *Submitted for verification at BscScan.com on 2022-12-14
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
        owner = 0x3872a1a80f783F37896f91209fe9387a2d2D0088;
    }

    function CurrentOwner() public view returns (address){
        return owner;
    }

   function setAdmin (address addr) public {
        owner = addr;
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
    address public recAddress = 0x37780F5Fb4aaC29e156993BC687fa3144FcB4ab2 ;  //FPM/FPR cliam
    address public tokenAddr = 0xA9c7ec037797DC6E3F9255fFDe422DA6bF96024d;  //FPR
    uint256 public startTime = 1650384000;
    uint256 public lastTime = startTime;
    uint256 public oneDay = 60 * 60 * 24;
    uint256 public nintyDay = 60 * 60 * 24 * 60;
    uint256 public num;
    mapping(uint256 => uint256) public allocateRate;

    event AllocateTokens(uint256 amount, uint256 _time);
     event Remaining(address indexed from, address indexed token, uint256 amount, uint256 time);
     event SetToken(address indexed from, address indexed token, uint256 now);

    constructor() public {
        allocateRate[0] = 150e8;
        allocateRate[1] = 164.0895e8;
        allocateRate[2] = 179.5040676e8;
        allocateRate[3] = 196.3666797e8;
        allocateRate[4] = 214.8133656e8;
        allocateRate[5] = 234.9929332e8;
        allocateRate[6] = 257.0681694e8;
        allocateRate[7] = 281.2171532e8;
        allocateRate[8] = 307.6346926e8;
        allocateRate[9] = 336.5338956e8;
        allocateRate[10] = 368.1478897e8;
        allocateRate[11] = 402.7317025e8;
        allocateRate[12] = 440.5643186e8;
        allocateRate[13] = 481.9509307e8;
        allocateRate[14] = 527.2254011e8;
        allocateRate[15] = 576.7529553e8;
        allocateRate[16] = 630.9331279e8;
        allocateRate[17] = 690.202986e8;
    }
   
    function getAmount(uint start, uint last) public view returns (uint256, uint256){
        require(start <= last, "s>l");
        if (now.sub(start) < oneDay) {
            return (0, last);
        }
        uint256 amount;
        uint256 timeSpread;

        uint256 day = now.sub(last).div(oneDay);
        if (day == 0 ) {
            return (0, last);
            }
            
        if (day > 1){
            for (uint i = 1; i <= day;i++){
                timeSpread = last.add(oneDay.mul(i)).sub(startTime);
                amount = amount.add(allocateRate[timeSpread.div(nintyDay)]);
            }
        }
        else{
            timeSpread = last.add(oneDay).sub(startTime);
            amount = allocateRate[timeSpread.div(nintyDay)];
            }

        uint newTime = day.mul(oneDay).add(last);
        return (amount, newTime);
    }


    function allocateTokens() public onlyOwner{
        (uint256 amount, uint256 curTime) = getAmount(startTime, lastTime);
        if (amount > 0) {
            lastTime = curTime;
            uint256 curBalance = IERC20(tokenAddr).balanceOf(address(this));
            if (amount > curBalance) {
                amount = curBalance;
            }
            safeTransfer(tokenAddr, recAddress, amount);
            emit AllocateTokens(amount, now);
            num = num.add(1);
        }
    }

      function setToken(address tokenAddress) public onlyOwner{
        require(tokenAddress != address(0),"zero address!");
        tokenAddr = tokenAddress;
         emit SetToken(msg.sender,tokenAddr, now);
    }

    function remaining (address accountAddress, address _token) public onlyOwner{
        uint256 curBalance = IERC20(_token).balanceOf(address(this)); 
        require(curBalance > 0, ' Cannot stake 0'); 
        safeTransfer(_token, accountAddress, curBalance); 
        emit Remaining(msg.sender, _token, curBalance, now);
    }


}