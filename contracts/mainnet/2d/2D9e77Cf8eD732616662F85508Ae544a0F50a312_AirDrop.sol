/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

pragma solidity 0.6.12;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address _to, uint _value) external returns (bool);
    function transferFrom(address _from, address _to, uint _value) external returns (bool);
}

contract AirDrop {

    IERC20 public c_erc20 = IERC20(0x4e041E2B45b6F33E22Ae2f1e7be0Ac503f452436);
   
    address public fundAddress = 0x17Cf7a9Cf84B6383CB0f186A4BAB7520f4eFc39c;
    uint256 public startReleaseTime = block.timestamp; 
    uint256 public interval = 30*24*60*60;

    uint256 public totalIntervalNum = 25;
    uint256 public withdrawnAmount;
    uint256 public totalAmount = 500000*10**18;

    function getRelease() external {
        require(block.timestamp > startReleaseTime, "release time error");
        uint256 num = (block.timestamp - startReleaseTime)/interval;
        num++;
        if (num > totalIntervalNum) {
            num = totalIntervalNum;
        }
        num = totalAmount*num/totalIntervalNum;

        require(num > withdrawnAmount, "no release");
        num -= withdrawnAmount;
        c_erc20.transfer(fundAddress, num);
        withdrawnAmount += num;
    }

    function userInfo() external view returns(uint256, uint256) {
        if (block.timestamp <= startReleaseTime) {
            return (0, withdrawnAmount);
        }
        uint256 num = (block.timestamp - startReleaseTime)/interval;
        num++;
        if (num > totalIntervalNum) {
            num = totalIntervalNum;
        }

        num = totalAmount*num/totalIntervalNum;
        num -= withdrawnAmount;
        
        return (num, withdrawnAmount);
    }
}