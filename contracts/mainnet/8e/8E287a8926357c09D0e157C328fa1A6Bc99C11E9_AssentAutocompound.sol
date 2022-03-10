// SPDX-License-Identifier: MIT

//     ___                         __ 
//    /   |  _____________  ____  / /_
//   / /| | / ___/ ___/ _ \/ __ \/ __/
//  / ___ |(__  |__  )  __/ / / / /_  
// /_/  |_/____/____/\___/_/ /_/\__/  
// 
// 2022 - Assent Protocol

pragma solidity 0.8.11;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./SafeERC20.sol";
import "./sASNTToken.sol";

interface IMasterchef {
    function deposit(uint256 _pid, uint256 _amount, address _referrer) external;

    function withdraw(uint256 _pid, uint256 _amount) external;
    
    function pendingTokens(uint256 _pid, address _user) external view returns (
            address[] memory addresses,
            string[] memory symbols,
            uint256[] memory decimals,
            uint256[] memory amounts
        );

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256, uint256, uint256, uint256);

    function emergencyWithdraw(uint256 _pid) external;
}

contract AssentAutocompound is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 lastDepositedTime;
        uint256 tokenAtLastUserAction;
        uint256 lastUserActionTime;
    }

	// ASNT token
    sASNTToken immutable public sASNT;
    IERC20 public immutable token;
    IMasterchef public immutable masterchef;
    uint256 public immutable stakingPid;

    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public whitelistedProxies;

    uint256 public lastHarvestedTime;
    address public treasury;

    uint256 internal constant MAX_PERFORMANCE_FEE = 500;
    uint256 internal constant MAX_CALL_FEE = 100;
    uint256 internal constant MAX_WITHDRAW_FEE = 200;
    uint256 internal constant MAX_WITHDRAW_FEE_PERIOD = 72 hours;
    address internal referrer = 0x000000000000000000000000000000000000dEaD;

    uint256 public performanceFee = 400;
    uint256 public callFee = 5;
    uint256 public withdrawFee = 0;
    uint256 public withdrawFeePeriod = 72 hours;
    
    bool public hadEmergencyWithdrawn = false;

    event Deposit(address indexed sender, uint256 amount, uint256 mintSupply, uint256 lastDepositedTime);
    event Withdraw(address indexed sender, uint256 currentAmount, uint256 amount);
    event Harvest(address indexed sender, uint256 performanceFee, uint256 callFee);
    event WhitelistedProxy(address indexed proxy);
    event DewhitelistedProxy(address indexed proxy);
    event SetTreasury(address indexed treasury);
    event SetPerformanceFee(uint256 performanceFee);
    event SetCallFee(uint256 callFee);
    event SetWithdrawFee(uint256 withdrawFee);
    event SetWithdrawFeePeriod(uint256 withdrawFeePeriod);
    event EmergencyWithdraw();

    constructor(
        sASNTToken _sASNT,
        IERC20 _token,
        IMasterchef _masterchef,
        uint256 _stakingPid,
        address _treasury
    ) {
        sASNT = _sASNT;
        token = _token;
        masterchef = _masterchef;
        stakingPid = _stakingPid;
        treasury = _treasury;

        IERC20(_token).approve(address(_masterchef), type(uint256).max);
    }
    
    function whitelistProxy(address _proxy) external onlyOwner {
        require(_proxy != address(0), 'zero address');
        require(!whitelistedProxies[_proxy], 'proxy already whitelisted');
        whitelistedProxies[_proxy] = true;
        emit WhitelistedProxy(_proxy);
    }
    
    function dewhitelistProxy(address _proxy) external onlyOwner {
        require(_proxy != address(0), 'zero address');
        require(whitelistedProxies[_proxy], 'proxy not whitelisted');
        whitelistedProxies[_proxy] = false;
        emit DewhitelistedProxy(_proxy);
    }

    function deposit(address _user, uint256 _amount) external whenNotPaused nonReentrant {
        require(_amount > 0, "Nothing to deposit");
        require(_user == msg.sender || whitelistedProxies[msg.sender], 'msg.sender is not allowed proxy');

        uint256 pool = tokenBalanceOf();
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 mintSupply = 0;
        if (sASNT.totalSupply() != 0) {
            mintSupply = _amount * sASNT.totalSupply() / pool;
        } else {
            mintSupply = _amount;
        }
        UserInfo storage user = userInfo[_user];

        sASNT.mint(_user, mintSupply);
        user.lastDepositedTime = block.timestamp;

        user.tokenAtLastUserAction = sASNT.balanceOf(_user) * tokenBalanceOf() / sASNT.totalSupply();
        user.lastUserActionTime = block.timestamp;

        _earn();

        emit Deposit(_user, _amount, mintSupply, block.timestamp);
    }

    function withdrawAll() external {
        withdraw(sASNT.balanceOf(msg.sender));
    }

    function harvest() external whenNotPaused nonReentrant {
        IMasterchef(masterchef).deposit(stakingPid, 0, referrer);

        uint256 bal = available();
        uint256 currentPerformanceFee = bal * performanceFee / 10000;
        token.safeTransfer(treasury, currentPerformanceFee);

        uint256 currentCallFee = bal * callFee / 10000;
        token.safeTransfer(msg.sender, currentCallFee);

        _earn();

        lastHarvestedTime = block.timestamp;

        emit Harvest(msg.sender, currentPerformanceFee, currentCallFee);
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Cannot be zero address");
        treasury = _treasury;
        emit SetTreasury(_treasury);
    }

    function setPerformanceFee(uint256 _performanceFee) external onlyOwner {
        require(_performanceFee <= MAX_PERFORMANCE_FEE, "performanceFee cannot be more than MAX_PERFORMANCE_FEE");
        performanceFee = _performanceFee;
        emit SetPerformanceFee(_performanceFee);
    }

    function setCallFee(uint256 _callFee) external onlyOwner {
        require(_callFee <= MAX_CALL_FEE, "callFee cannot be more than MAX_CALL_FEE");
        callFee = _callFee;
        emit SetCallFee(_callFee);
    }

    function setWithdrawFee(uint256 _withdrawFee) external onlyOwner {
        require(_withdrawFee <= MAX_WITHDRAW_FEE, "withdrawFee cannot be more than MAX_WITHDRAW_FEE");
        withdrawFee = _withdrawFee;
        emit SetWithdrawFee(_withdrawFee);
    }

    function setWithdrawFeePeriod(uint256 _withdrawFeePeriod) external onlyOwner {
        require(
            _withdrawFeePeriod <= MAX_WITHDRAW_FEE_PERIOD,
            "withdrawFeePeriod cannot be more than MAX_WITHDRAW_FEE_PERIOD"
        );
        withdrawFeePeriod = _withdrawFeePeriod;
        emit SetWithdrawFeePeriod(_withdrawFeePeriod);
    }

    function emergencyWithdraw() external onlyOwner {
        IMasterchef(masterchef).emergencyWithdraw(stakingPid);
        hadEmergencyWithdrawn = true;
        _pause();
        emit EmergencyWithdraw();
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        require(!hadEmergencyWithdrawn, 'cannot unpause after emergency withdraw');
        _unpause();
    }

    function calculateHarvestTokenRewards() external view returns (uint256) {
        uint256 currentCallFee = calculateTotalPendingTokenRewards() * callFee / 10000;
        return currentCallFee;
    }

    function calculateTotalPendingTokenRewards() public view returns (uint256) {
        uint256[] memory amount;
        ( , , , amount) = IMasterchef(masterchef).pendingTokens(stakingPid, address(this));
        amount[0] = amount[0] + available();

        return amount[0];
    }

    function getPricePerFullShare() external view returns (uint256) {
        return sASNT.totalSupply() == 0 ? 1e18 : tokenBalanceOf() * 1e18 / sASNT.totalSupply();
    }

    function withdraw(uint256 _amount) public nonReentrant {

        UserInfo storage user = userInfo[msg.sender];
        require(_amount > 0, "Nothing to withdraw");
        require(_amount <= sASNT.balanceOf(msg.sender), "Withdraw amount exceeds balance");

        uint256 currentAmount = tokenBalanceOf() * _amount / sASNT.totalSupply();
        sASNT.burn(msg.sender, _amount);

        uint256 bal = available();
        if (bal < currentAmount) {
            uint256 balWithdraw = currentAmount - bal;
            IMasterchef(masterchef).withdraw(stakingPid, balWithdraw);
            uint256 balAfter = available();
            uint256 diff = balAfter - bal;
            if (diff < balWithdraw) {
                currentAmount = balAfter;
            }
        }

        if (block.timestamp < user.lastDepositedTime + withdrawFeePeriod) {
            uint256 currentWithdrawFee = currentAmount * withdrawFee / 10000;
            token.safeTransfer(treasury, currentWithdrawFee);
            currentAmount = currentAmount - currentWithdrawFee;
        }

        if (sASNT.balanceOf(msg.sender) > 0) {
            user.tokenAtLastUserAction = sASNT.balanceOf(msg.sender) * tokenBalanceOf() / sASNT.totalSupply();
        } else {
            user.tokenAtLastUserAction = 0;
        }

        user.lastUserActionTime = block.timestamp;

        token.safeTransfer(msg.sender, currentAmount);

        emit Withdraw(msg.sender, currentAmount, _amount);
    }

    function available() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function tokenBalanceOf() public view returns (uint256) {
        (uint256 amount, , , ,) = IMasterchef(masterchef).userInfo(stakingPid, address(this));
        return token.balanceOf(address(this)) + amount;
    }

    function _earn() internal {
        uint256 bal = available();
        if (bal > 0) {
            IMasterchef(masterchef).deposit(stakingPid, bal, referrer);
        }
    }

    function inCaseTokensGetStuck(address _token) external onlyOwner {
        require(_token != address(token), "Token cannot be same as deposit token");

        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }

    function pendingPerUser(address _user) public view returns (uint256 pending,uint256 userShare,uint256 inUserWallet,uint256 userASNTValue,uint256 userEarnSinceLastAction) {

        UserInfo storage user = userInfo[_user];

        if (sASNT.totalSupply() > 0){
            // ratio of user sASNT holdings
            userShare = sASNT.balanceOf(_user) * 1e18 / sASNT.totalSupply();
            
            //User ASNT available value to withdrawal
            userASNTValue = sASNT.balanceOf(_user) * tokenBalanceOf() / sASNT.totalSupply();
            
            //Live pending per user in the masterchef / Only for debug
            pending = calculateTotalPendingTokenRewards() * userShare / 1e18;

            //Reward accumulated since last user action (deposit/withdrawal)
            userEarnSinceLastAction = userASNTValue - user.tokenAtLastUserAction;            
        }

        //balance in user wallet
        inUserWallet = sASNT.balanceOf(_user);     

        return (pending,userShare,inUserWallet,userASNTValue,userEarnSinceLastAction);
    }


}