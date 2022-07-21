pragma solidity ^0.8.7;
import './Ownable.sol';

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 depositTime;
    }
interface IStaking {
    function getUserInfo(address user) external returns(UserInfo memory result);
    function clearUserDepositTime(address user) external;
}

contract airdrop is Ownable{
    address public poolAddress  = 0x939239913823C20a241bC3D6c39F45De91dcc544;
    receive() external payable {
    }

    uint period = 86400 * 30;
    function getAirdrop() external {
        UserInfo memory userInfo = IStaking(poolAddress).getUserInfo(msg.sender);
        require(userInfo.depositTime>19081679,"error");
        uint diff = block.timestamp - userInfo.depositTime;
        require(diff>period,"not reach the period");
        IStaking(poolAddress).clearUserDepositTime(msg.sender);
        _sendAirdrop(payable(msg.sender));
    }
    function _sendAirdrop(address payable user) internal{
        user.transfer(7*1e18);
    }
    function setPoolAddress(address _pool) external onlyOwner{
        poolAddress = _pool;
    }
    function setPeriod(uint _period) external onlyOwner{
        period = _period;
    }

    function checkAirdrop(uint depositTime) public view returns (bool) {
        uint diff = block.timestamp - depositTime;
        return diff>period;
    }
    function withdrawBNB(uint256 amount) external onlyOwner{
        payable(owner()).transfer(amount);
    }
    
}