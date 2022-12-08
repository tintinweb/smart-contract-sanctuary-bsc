/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

pragma solidity =0.8.2;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function getOwner() external view returns (address);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IStakingRewardsSameTokenFixedAPY {
    function acceptOwnership() external;

    function stake(uint256 amount) external;

    function updateRewardAmount(uint256 reward) external;

    function getReward() external;

    function rewardDuration() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function weightedStakeDate(address account) external view returns (uint256);

    function transferOwnership(address transferOwner) external;
}

interface INBU {
    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Ownable {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: Caller is not the owner");
        _;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}

contract TestStorage is Ownable {
    event Rescue(address indexed to, uint256 amount);
    event RescueToken(
        address indexed to,
        address indexed token,
        uint256 amount
    );
}

contract TestProxy is TestStorage {
    address public target;

    event SetTarget(address indexed newTarget);

    constructor(address _newTarget) TestStorage() {
        _setTarget(_newTarget);
    }

    fallback() external payable {
        if (gasleft() <= 2300) {
            revert();
        }

        address target_ = target;
        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(
                gas(),
                target_,
                add(data, 0x20),
                mload(data),
                0,
                0
            )
            let size := returndatasize()
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    function setTarget(address _newTarget) external onlyOwner {
        _setTarget(_newTarget);
    }

    function _setTarget(address _newTarget) internal {
        target = _newTarget;
        emit SetTarget(_newTarget);
    }
}

contract GETNBU is TestStorage {
    address public target;
    IStakingRewardsSameTokenFixedAPY public StakingRewardsSameTokenFixedAPY;
    INBU public NBU;
    uint256 public AMOUNT;

    function initialize(
        address newStakingRewardsSameTokenFixedAPY,
        address newNBU
    ) external onlyOwner {
        StakingRewardsSameTokenFixedAPY = IStakingRewardsSameTokenFixedAPY(
            newStakingRewardsSameTokenFixedAPY
        );
        NBU = INBU(newNBU);

        AMOUNT = 1 ether;
        INBU(NBU).approve(
            address(StakingRewardsSameTokenFixedAPY),
            type(uint256).max
        );
    }

    function updateStakingRewardsSameTokenFixedAPY(
        address newStakingRewardsSameTokenFixedAPY
    ) external onlyOwner {
        StakingRewardsSameTokenFixedAPY = IStakingRewardsSameTokenFixedAPY(
            newStakingRewardsSameTokenFixedAPY
        );
    }

    function updateNBU(address newNBU) external onlyOwner {
        NBU = INBU(newNBU);
    }

    function withdraw(
        address to,
        IBEP20 tokenAddress,
        uint256 amount
    ) external onlyOwner {
        tokenAddress.transfer(to, amount);
    }

    function transferStakingOwnership(address newOwner) external onlyOwner {
        StakingRewardsSameTokenFixedAPY.transferOwnership(newOwner);
    }

    function acceptOwnership() external onlyOwner {
        StakingRewardsSameTokenFixedAPY.acceptOwnership();
    }

    function stake() external onlyOwner {
        StakingRewardsSameTokenFixedAPY.stake(AMOUNT);
    }

    function liquidityAmount()
        public
        view
        returns (uint256 BalanceThis, uint256 NewrewardAmount)
    {
        BalanceThis = INBU(NBU).balanceOf(
            address(StakingRewardsSameTokenFixedAPY)
        );
        NewrewardAmount =
            (BalanceThis *
                (100 * StakingRewardsSameTokenFixedAPY.rewardDuration())) /
            (StakingRewardsSameTokenFixedAPY.balanceOf(address(this)) *
                (block.timestamp -
                    StakingRewardsSameTokenFixedAPY.weightedStakeDate(
                        address(this)
                    )));
    }

    function updateRewardAndGetLiquidity() external onlyOwner {
        (, uint256 newRewardAmount) = liquidityAmount();
        StakingRewardsSameTokenFixedAPY.updateRewardAmount(newRewardAmount);
        StakingRewardsSameTokenFixedAPY.getReward();
        StakingRewardsSameTokenFixedAPY.updateRewardAmount(0);
    }
}