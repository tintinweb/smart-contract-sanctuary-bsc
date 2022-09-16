// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

/**
 * @title Staking Token (STK)
 * @author louistalent
 * @notice Implements a basic ERC20 staking token with incentive distribution.
 */

library SafeMath2 {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0, "ds-math-mul-overflow");
        c = a / b;
    }
}

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function mint(uint256 amount) external returns (bool);
}

contract Staking {
    using SafeMath2 for uint256;

    /**
     * @notice This struct is for staker.
     * @param stakingAddress The address of staker.
     * @param stakingDate The date of staking.
     * @param period The period of staking.
     * @param stakes The stake amount of staking.
     * @param rewards The reward amount of staking.
     */
    struct Staker {
        address stakeAddress;
        uint256 stakingDate;
        uint256 period;
        uint256 stakes;
        uint256 rewards;
    }

    /**
     * @notice The mapping for the info of staker who have staked according his address.
     */
    mapping(address => Staker) public stakers;

    /**
     * @notice The array of stakers.
     */
    // address[] stakerholder;

    address public marketingWalletAddress;
    address public stakeTokenAddress;

    constructor(address _stakeTokenAddress, address _marketingWalletAddress)
        public
    {
        stakeTokenAddress = _stakeTokenAddress;
        marketingWalletAddress = _marketingWalletAddress;
        ownerConstructor();
    }

    /**
     * @notice A method for staking.
     */
    function stake(uint256 _period, uint256 _stakes) public {
        require(
            stakers[msg.sender].stakingDate == 0,
            "This staking for this address already exist."
        );
        // IERC20(stakeTokenAddress)._burn(msg.sender, _stakes);
        IERC20(stakeTokenAddress).transferFrom(
            msg.sender,
            address(this),
            _stakes
        );

        creatStaker(msg.sender, _period, _stakes);
    }

    function unstake() public {
        require(
            stakers[msg.sender].stakingDate != 0,
            "This staking for this address not exist"
        );
        uint256 period = periodOf(msg.sender);
        uint256 nowDate = block.timestamp;
        uint256 stakingDate = stakingDateOf(msg.sender);
        uint256 stakeAmount = stakeOf(msg.sender);
        uint256 rewardAmount = rewardOf(msg.sender);

        if (nowDate - stakingDate < period.mul(3600).mul(24)) {
            // Unstake ready
            if (nowDate - stakingDate >= 3 * 3600 * 24) {
                //if 3days over , unstake fee is 6%

                IERC20(stakeTokenAddress).transfer(
                    msg.sender,
                    stakeAmount.mul(9400).div(1e4)
                );
                IERC20(stakeTokenAddress).transfer(
                    marketingWalletAddress,
                    stakeAmount.sub(stakeAmount.mul(9400).div(1e4))
                );
            } else {
                //if less than 3days  , early unstake fee is 36%

                IERC20(stakeTokenAddress).transfer(
                    msg.sender,
                    stakeAmount.mul(6400).div(1e4)
                );
                IERC20(stakeTokenAddress).transfer(
                    marketingWalletAddress,
                    stakeAmount.sub(stakeAmount.mul(6400).div(1e4))
                );
            }
        } else {
            // Claim ready

            IERC20(stakeTokenAddress).transfer(
                msg.sender,
                stakeAmount.add(rewardAmount)
            );
        }
        removeStaker(msg.sender);
    }

    function stakingDateOf(address _sender) public view returns (uint256) {
        require(stakers[msg.sender].stakingDate != 0, "This staker not exist");
        return stakers[_sender].stakingDate;
    }

    function testPeriod(uint256 date) public view returns(uint256){
        return date.mul(3600).mul(24);
    }

    function periodOf(address _sender) public view returns (uint256) {
        require(stakers[msg.sender].stakingDate != 0, "This staker not exist");
        return stakers[_sender].period;
    }

    function stakeOf(address _sender) public view returns (uint256) {
        require(stakers[msg.sender].stakingDate != 0, "This staker not exist");
        return stakers[_sender].stakes;
    }

    function rewardOf(address _sender) public view returns (uint256) {
        require(stakers[msg.sender].stakingDate != 0, "This staker not exist");
        return stakers[_sender].rewards;
    }

    function nowUnixTime() public view returns (uint256) {
        return block.timestamp;
    }

    function calcRewards(uint256 _period, uint256 _stakes)
        internal
        pure
        returns (uint256 _rewards)
    {
        _rewards = _stakes.mul(120).div(1e4);
        if (_period == 7) {
            // _rewards = _rewards;
        } else if (_period == 30) {
            _rewards = _rewards.mul(4).add(_stakes.mul(500).div(1e4));
        } else if (_period == 90) {
            _rewards = _rewards.mul(13).add(_stakes.mul(2000).div(1e4));
        }
    }

    function creatStaker(
        address _sender,
        uint256 _period,
        uint256 _stakes
    ) internal {
        require(
            stakers[msg.sender].stakingDate == 0,
            "This staking for this address already exist."
        );
        uint256 rewards = calcRewards(_period, _stakes);

        Staker memory newStaker = Staker(
            _sender,
            block.timestamp,
            _period,
            _stakes,
            rewards
        );
        stakers[_sender] = newStaker;
    }

    // function stakerInfoOf(
    //     address _sender
    // ) public view returns(uint _date, uint _period, uint _stakingAmount, uint _rewards) {
    //     require(
    //         stakers[msg.sender].stakingDate != 0,
    //         "This staking for this address not exist."
    //     );
    //      _date   =          stakers[_sender].stakingDate;
    //      _period =          stakers[_sender].period;
    //      _stakingAmount =   stakers[_sender].stakes;
    //      _rewards =         stakers[_sender].rewards;
    // }

    function removeStaker(address _sender) internal {
        require(
            stakers[msg.sender].stakingDate != 0,
            "This address not exist."
        );
        delete stakers[_sender];
    }

    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function ownerConstructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}