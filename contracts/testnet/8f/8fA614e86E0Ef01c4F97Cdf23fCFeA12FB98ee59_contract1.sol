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

contract contract1 is Ownable {

    using SafeMath for uint256;

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    //nMER-ocean
    address public recAddress = 0x5131002C316b5464a61c7E4376A5bf37345c270b;  //nMER-ocean
    address public tokenAddr = 0x495D6fb7aF5a4B1c32B53e07B1db0999F9Aeb1cD;  //COF
    uint256 public startTime = 1647964800;
    uint256 public lastTime = startTime;
    uint256 public oneDay = 60 * 60 * 24;
    uint256 public nintyDay = 60 * 60 * 24 * 60;
    mapping(uint256 => uint256) public allocateRate;

    event AllocateTokens(uint256 amount, uint256 _time);
     event Remaining(address indexed from, address indexed token, uint256 amount, uint256 time);
    constructor() public {
        allocateRate[0] = 180e8;
        allocateRate[1] = 189.323982e8;
        allocateRate[2] = 199.1309453e8;
        allocateRate[3] = 209.4459084e8;
        allocateRate[4] = 220.2951855e8;
        allocateRate[5] = 231.7064541e8;
        allocateRate[6] = 243.7088252e8;
        allocateRate[7] = 256.332918e8;
        allocateRate[8] = 269.6109375e8;
        allocateRate[9] = 283.5767571e8;
        allocateRate[10] = 298.2660048e8;
        allocateRate[11] = 313.716154e8;
        allocateRate[12] = 329.9666194e8;
        allocateRate[13] = 347.0588573e8;
        allocateRate[14] = 365.0364714e8;
        allocateRate[15] = 383.9453241e8;
        allocateRate[16] = 403.8336535e8;
        allocateRate[17] = 424.7521964e8;
        allocateRate[18] = 446.7543177e8;
        allocateRate[19] = 469.8961467e8;
        allocateRate[20] = 494.2367201e8;
        allocateRate[21] = 519.8381328e8;
        allocateRate[22] = 546.765696e8;
        allocateRate[23] = 575.0881044e8;
        allocateRate[24] = 604.8776107e8;
        allocateRate[25] = 636.2102105e8;
        allocateRate[26] = 669.1658358e8;
        allocateRate[27] = 703.8285591e8;
        allocateRate[28] = 740.2868081e8;
        allocateRate[29] = 778.6335907e8;
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