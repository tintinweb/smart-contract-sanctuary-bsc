// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./library/Governance.sol";
import "./interfaces/IGeneralNFTReward.sol";
import "./interfaces/IPosiTreasury.sol";

/**
 * A contract to update reward for NFT pool every 7 days
 */
contract InsuranceFundV2 is Governance {
    IGeneralNFTReward public generalNFTReward = IGeneralNFTReward(0xce0A236e240906600fe652BFFbA67b8D26387445);
    IERC20 public posi = IERC20(0x3C7142552250B10252A214ecccA332368D66c350);
    IPosiTreasury public treasury = IPosiTreasury(0x67579323E7aD5FCA683971d036Fe40A4F77A19ef);
    bool public needWaitForTime;

    function approve() public {
        posi.approve(address(generalNFTReward), type(uint256).max);
    }

    // set new rewards distributing in 7 days for GeneralNFTRewards
    function notifyReward(uint256 amount) external onlyGovernance {
        if(needWaitForTime)
            require(block.timestamp >= generalNFTReward._periodFinish(), "Not time to reset");
        uint256 _balanceBefore = posi.balanceOf(address(this));
        if(_balanceBefore < amount){
            treasury.mint(address(this), amount);
            uint256 _balanceAfter = posi.balanceOf(address(this));
            amount = _balanceAfter - _balanceBefore;
        }
        generalNFTReward.notifyReward(amount);
    }

    function changeNeedWaitForTime(bool needWait) external onlyGovernance {
        needWaitForTime = needWait;
    }

    // change GeneralNFTRewards
    function changeGeneralNFTGovernance(address governance) external onlyGovernance {
        generalNFTReward.setGovernance(governance);
    }
    function setTeamRewardRate( uint256 teamRewardRate ) external onlyGovernance {
        generalNFTReward.setTeamRewardRate( teamRewardRate);
    }
    function setPoolRewardRate( uint256  poolRewardRate ) external onlyGovernance {
        generalNFTReward.setPoolRewardRate( poolRewardRate);
    }
    function setHarvestInterval( uint256  harvestInterval ) external onlyGovernance {
        generalNFTReward.setHarvestInterval( harvestInterval);
    }
    function setRewardPool( address  rewardPool ) external onlyGovernance {
        generalNFTReward.setRewardPool(rewardPool);
    }
    function setTeamWallet( address teamwallet ) external onlyGovernance {
        generalNFTReward.setTeamWallet( teamwallet);
    }
    function setWithDrawPunishTime( uint256  punishTime ) external onlyGovernance {
        generalNFTReward.setWithDrawPunishTime( punishTime);
    }
    function setMaxStakedDego(uint256 amount) external onlyGovernance {
        generalNFTReward.setMaxStakedDego( amount);
    }

    function changeRewardToken( address newAddress ) external onlyGovernance {
        generalNFTReward.changeRewardToken( newAddress);
    }

    function changeNftToken( address newAddress ) external onlyGovernance {
        generalNFTReward.changeNftToken( newAddress);
    }

    function changeFactory( address newAddress ) external onlyGovernance {
        generalNFTReward.changeFactory( newAddress);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <=0.8.4;

contract Governance {
    address public _governance;

    constructor() public {
        _governance = tx.origin;
    }

    event GovernanceTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyGovernance() {
        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance) public onlyGovernance {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }
}

pragma solidity ^0.8.0;

interface IGeneralNFTReward {
    function _periodFinish() external view returns (uint256);
    function notifyReward(uint256 reward) external;
    function setGovernance(address governance) external;
    function setTeamRewardRate( uint256 teamRewardRate ) external;
    function setPoolRewardRate( uint256  poolRewardRate ) external;
    function setHarvestInterval( uint256  harvestInterval ) external;
    function setRewardPool( address  rewardPool ) external;
    function setTeamWallet( address teamwallet ) external;
    function setWithDrawPunishTime( uint256  punishTime ) external;
    function setMaxStakedDego(uint256 amount) external;
    function changeRewardToken(address _newToken) external;
    function changeNftToken(address _newContract) external;
    function changeFactory(address _newFactory) external;
}

pragma solidity ^0.8.0;

interface IPosiTreasury {
    function mint(address recipient, uint256 amount) external;
}