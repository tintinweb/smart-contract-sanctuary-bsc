// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.7;

import "./OwnableUpgradeable.sol";
import "./ERC20Upgradeable.sol";
import "./SafeERC20Upgradeable.sol";
import "./Initializable.sol";

interface IRewardPool {
    function notifyRewardAmount(uint256 amount) external;
    function transferOwnership(address owner) external;
}

interface IUniswapRouter {
    function swapExactTokensForTokens(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract FeeBatch is Initializable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public wNative;
    IERC20Upgradeable public govToken;
    address public treasury;
    address public rewardPool;
    address public unirouter;

    // Fee constants
    uint constant public MAX_FEE = 1000;
    uint public treasuryFee;
    uint public rewardPoolFee;

    address[] public wNativeToGovTokenRoute;

    bool public routerInitialized;
    bool public rewardPoolInitialized;


    event NewRewardPool(address oldRewardPool, address newRewardPool);
    event NewTreasury(address oldTreasury, address newTreasury);
    event NewUnirouter(address oldUnirouter, address newUnirouter);
    event NewGovTokenRoute(address[] oldRoute, address[] newRoute);

    function initialize(
        address _govToken,
        address _wNative,
        address _treasury, 
        address _rewardPool, 
        address _unirouter 
    ) public initializer {
        __Ownable_init();

        govToken = IERC20Upgradeable(_govToken);
        wNative  = IERC20Upgradeable(_wNative);
        treasury = _treasury;

        treasuryFee = 140;
        rewardPoolFee = MAX_FEE - treasuryFee;

        if (_unirouter != address(0x0)) {
            _initRouter(_unirouter);
        }
        if(_rewardPool != address(0x0)) {
           rewardPool = _rewardPool;
           rewardPoolInitialized = true;
        }
        
        wNativeToGovTokenRoute = [_wNative, _govToken];
    }

    // Main function. Divides Dyos's profits.
    function harvest() public {
        uint256 wNativeBal = wNative.balanceOf(address(this));

        if (routerInitialized) {
            uint256 treasuryHalf = wNativeBal * treasuryFee / MAX_FEE / 2;
            wNative.safeTransfer(treasury, treasuryHalf);
            IUniswapRouter(unirouter).swapExactTokensForTokens(treasuryHalf, 0, wNativeToGovTokenRoute, treasury, block.timestamp);
        } else {
            uint256 treasuryAmount = wNativeBal * treasuryFee / MAX_FEE;
            wNative.safeTransfer(treasury, treasuryAmount);
        }
        if(rewardPoolInitialized) {
            uint256 rewardPoolAmount = wNativeBal * rewardPoolFee / MAX_FEE;
            wNative.safeTransfer(rewardPool, rewardPoolAmount);
            IRewardPool(rewardPool).notifyRewardAmount(rewardPoolAmount);
        }
        else{
            uint256 rewardPoolAmount = wNativeBal * rewardPoolFee / MAX_FEE;
            wNative.safeTransfer(treasury, rewardPoolAmount);
        }
    }

    function changeTreasuryFee(uint256 _treasuryFee) external onlyOwner {
        treasuryFee = _treasuryFee;
    } 

    // Manage the contract
    function setRewardPool(address _rewardPool) external onlyOwner {
        emit NewRewardPool(rewardPool, _rewardPool);
        rewardPool = _rewardPool;
        rewardPoolInitialized = true;
    }

    function setTreasury(address _treasury) external onlyOwner {
        emit NewTreasury(treasury, _treasury);
        treasury = _treasury;
    }

    function initRouter(address _unirouter) public onlyOwner {
        _initRouter(_unirouter);
    }

    function _initRouter(address _unirouter) internal {
        unirouter = _unirouter;
        wNative.safeApprove(unirouter, type(uint).max);
        routerInitialized = true;
    }

    function setUnirouter(address _unirouter) external onlyOwner {
        require(routerInitialized, "!initialized");

        emit NewUnirouter(unirouter, _unirouter);

        wNative.safeApprove(_unirouter, type(uint).max);
        wNative.safeApprove(unirouter, 0);
        
        unirouter = _unirouter;
    }

    function setNativeToGovTokenRoute(address[] memory _route) external onlyOwner {
        require(_route[0] == address(wNative), "!wNative");
        require(_route[_route.length - 1] == address(govToken), "!dyos");

        emit NewGovTokenRoute(wNativeToGovTokenRoute, _route);
        wNativeToGovTokenRoute = _route;
    }

    function setTreasuryFee(uint256 _fee) public onlyOwner {
        require(_fee <= MAX_FEE, "!cap");

        treasuryFee = _fee;
        rewardPoolFee = MAX_FEE - treasuryFee;
    }
    
    // Rescue locked funds sent by mistake
    function inCaseTokensGetStuck(address _token, address _recipient) external onlyOwner {
        require(_token != address(wNative), "!safe");

        uint256 amount = IERC20Upgradeable(_token).balanceOf(address(this));
        IERC20Upgradeable(_token).safeTransfer(_recipient, amount);
    }

    function transferRewardPoolOwnership(address _newOwner) external onlyOwner {
        IRewardPool(rewardPool).transferOwnership(_newOwner);
    }

    receive() external payable {}
}