/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;



contract Refund {
    using SafeMath for uint256;

    address minerAddress = 0x562CAc4368fF3e7ac25935C8cB7d10d842faC5A2;
    IAvariceBUSDMiner public avariceBUSDMiner = IAvariceBUSDMiner(minerAddress);
    IERC20 public BUSDToken = IERC20(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56));

    function refundAmount(address userAddress) public view returns (uint256 result_) {
        (uint256 _initialDeposit,,,,,,,,,,,) = avariceBUSDMiner.getUserInfo(userAddress);
        uint256 minerBalance = BUSDToken.balanceOf(minerAddress);
        uint256 refundContractBalance = BUSDToken.balanceOf(address(this));
        result_ = _initialDeposit.mul(refundContractBalance).div(minerBalance);
    }

    function withdraw() public {
        address userAddress = address(msg.sender);
        uint256 amount = this.refundAmount(userAddress);
        BUSDToken.transfer(userAddress,amount);
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IAvariceBUSDMiner {
    function getUserInfo(address _adr)
        external
        view
        returns (
            uint256 _initialDeposit,
            uint256 _userDeposit,
            uint256 _miners,
            uint256 _claimedEggs,
            uint256 _lastHatch,
            address _referrer,
            uint256 _referrals,
            uint256 _totalWithdrawn,
            uint256 _referralEggRewards,
            uint256 _dailyCompoundBonus,
            uint256 _minerCompoundCount,
            uint256 _lastWithdrawTime
        );
}