/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;



contract Refund {
    using SafeMath for uint256;

    address minerAddress = 0xD38da3a5174A3fff35b2d059e9c78035CCb43f9D;
    // IAvariceBUSDMiner avariceBUSDMiner = IAvariceBUSDMiner(minerAddress);
    IERC20 public BUSDToken = IERC20(address(0xf4B162d8a35A70F167c4A98d233F307E81a8bc95));

    function refundAmount(address userAddress) public view returns (uint256 result_) {
        // (uint256 _initialDeposit,,,,,,,,,,,) = avariceBUSDMiner.getUserInfo(userAddress);
        (uint256 _initialDeposit,
            uint256 _userDeposit,
            uint256 _miners,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            ) = IAvariceBUSDMiner(minerAddress).getUserInfo(userAddress);
        uint256 deposit =_initialDeposit;
        uint256 minerBalance = BUSDToken.balanceOf(minerAddress);
        uint256 refundContractBalance = BUSDToken.balanceOf(address(this));
        uint256 totalRefundAmount = minerBalance.mul(105).div(100);
        result_ = deposit.div(totalRefundAmount).mul(refundContractBalance);
    }

    function getMinerBalance() public view returns(uint256) {
        return BUSDToken.balanceOf(minerAddress);
    }

    function getRefundBalance() public view returns (uint256) {
        return BUSDToken.balanceOf(address(this));
    }
    function getDeposit(address userAddress) public view returns (uint256) {
        (uint256 _initialDeposit,
            uint256 _userDeposit,
            uint256 _miners,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            ) = IAvariceBUSDMiner(minerAddress).getUserInfo(userAddress);
            return _initialDeposit;
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