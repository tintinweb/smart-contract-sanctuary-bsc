/**
 *Submitted for verification at BscScan.com on 2022-12-12
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

contract contract3 is Ownable {

    using SafeMath for uint256;

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    //LP
    address public recAddress = 0x0DEd161bDa0056C049e2240A9F211c0F76f89D0e; //LP
    address public tokenAddr = 0x495D6fb7aF5a4B1c32B53e07B1db0999F9Aeb1cD; ///COF
    uint256 public startTime = 1647964800;
    uint256 public lastTime = startTime;
    uint256 public oneDay = 60 * 60 * 24;
    uint256 public nintyDay = 60 * 60 * 24 * 90;
    mapping(uint256 => uint256) public allocateRate;

    event AllocateTokens(uint256 amount, uint256 _time);
     event Remaining(address indexed from, address indexed token, uint256 amount, uint256 time);
    constructor() public {
        allocateRate[0] = 90e8;
        allocateRate[1] = 103.257e8;
        allocateRate[2] = 118.4667561e8;
        allocateRate[3] = 135.9169093e8;
        allocateRate[4] = 155.93747e8;
        allocateRate[5] = 178.9070593e8;
        allocateRate[6] = 205.2600692e8;
        allocateRate[7] = 235.4948774e8;
        allocateRate[8] = 270.1832728e8;
        allocateRate[9] = 309.9812689e8;
        allocateRate[10] = 355.6415098e8;
        allocateRate[11] = 408.0275042e8;
        allocateRate[12] = 468.1299556e8;
        allocateRate[13] = 537.085498e8;
        allocateRate[14] = 616.1981919e8;
        allocateRate[15] = 706.9641855e8;
        allocateRate[16] = 811.1000101e8;
        allocateRate[17] = 930.5750416e8;
        allocateRate[18] = 1067.648745e8;
        allocateRate[19] = 1224.913405e8;
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
        }
    }

     function setToken(address tokenAddress) public onlyOwner{
        require(tokenAddress != address(0),"zero address!");
        tokenAddr = tokenAddress;
    }

    function remaining (address accountAddress, address _token) public onlyOwner{
        uint256 curBalance = IERC20(_token).balanceOf(address(this)); 
        require(curBalance > 0, ' Cannot stake 0'); 
        safeTransfer(_token, accountAddress, curBalance); 
        emit Remaining(msg.sender, _token, curBalance, now);
    }


}