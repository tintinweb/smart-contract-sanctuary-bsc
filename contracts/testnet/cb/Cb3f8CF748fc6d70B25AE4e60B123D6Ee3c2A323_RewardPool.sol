// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
interface IRewardPool {
    struct whitelist {
        address player;
        uint256 amount;
    }

    function setWhitelist(whitelist[] memory) external;

    function claim() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
interface Itransfer {
    function transfer(address to, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: MIT
import "./IRewardPool.sol";
import "./Itransfer.sol";
pragma solidity ^0.8.9;
contract RewardPool is IRewardPool{
    address public manager; //one who set whitelist
    address public usdt;    //target token address
    mapping(address => uint256) public balanceOf;   //record book of available claim usdt amount
    constructor(address _manager, address _usdt) {
        manager = _manager;
        usdt = _usdt;
    }
    modifier onlyManager() {
        require(msg.sender == manager, "RewardPool: you are not manager.");
        _;
    }
    /**
     *@dev manager calls to set whitelist,about the format of inputs array, see IRewardPool.sol.
     */
    function setWhitelist(whitelist[] memory _whitelist) external onlyManager{
        for(uint256 i = 0; i < _whitelist.length; i++){
            balanceOf[_whitelist[i].player] += _whitelist[i].amount;
        }
    }
    /**
     *@dev player calls to claim reward, once clears accounting. 
     */
    function claim() external {
        uint256 balance = balanceOf[msg.sender];
        require(balance > 0, "RewardPool_claim: you haven't balance to claim.");
        balanceOf[msg.sender] = 0;
        Itransfer(usdt).transfer(msg.sender, balance);
    }

    function resetManager(address newManager) external onlyManager{
        require(newManager != address(0), "trans_USDT_setManager: invalid manager.");
        manager = newManager;
    }

    function resetToken(address newToken) external onlyManager{
        require(newToken != address(0), "RewardPool_resetToken: invalid token address.");
        usdt = newToken;
    }
}