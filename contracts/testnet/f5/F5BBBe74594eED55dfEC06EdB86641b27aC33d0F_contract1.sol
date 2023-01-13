/**
 *Submitted for verification at BscScan.com on 2023-01-13
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



interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256);
}

contract contract1 {

    using SafeMath for uint256;

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    //allocateTokens
    address public recAddress = 0xa6e24C352180507394A6A2f2D6D2F261AA95e1C2;  //OPCB cliam
    address public tokenAddr = 0xd16c0311Ca91Db105b89e899038422f1C855a4eC;  //OPCB
    uint256 public startTime = 1673577600;
    uint256 public lastTime = startTime;
    uint256 public oneDay = 60 * 10;
    uint256 public nintyDay =  60 * 60 * 1;
    uint256 public Date ;
    // uint256 public oneDay = 60 * 60 * 24;
    // uint256 public nintyDay =  60 * 60 * 24 * 360;

    mapping(uint256 => uint256) public allocateRate;
    uint256 public num ;

    event AllocateTokens(uint256 amount, uint256 _time);

    constructor() public {
        allocateRate[0] = 531e8;
        allocateRate[1] = 477.9e8;
        allocateRate[2] = 430.11e8;
        allocateRate[3] = 387.099e8;
        allocateRate[4] = 348.3891e8;
        allocateRate[5] = 313.55019e8;
        allocateRate[6] = 282.195171e8;
        allocateRate[7] = 253.9756539e8;
        allocateRate[8] = 228.5780885e8;
        allocateRate[9] = 205.7202797e8;
        allocateRate[10] = 185.1482517e8;
        allocateRate[11] = 166.6334265e8;
        allocateRate[12] = 149.9700839e8;
        allocateRate[13] = 134.9730755e8;
        allocateRate[14] = 121.4757679e8;
        allocateRate[15] = 109.3281911e8;
        allocateRate[16] = 98.39537203e8;
        allocateRate[17] = 88.55583483e8;
        allocateRate[18] = 79.70025134e8;
        allocateRate[19] = 71.73022621e8;
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


    function allocateTokens() public {
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
            Date = now;
        }
    }


}