/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

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
}

interface IFnyStaking {
    function stake(uint256 _amount, address _recipient) external returns (bool);

    function claim(address _recipient) external;

    function unstake(uint256 _amount, bool _trigger) external;
}

contract FnyStakingHelper {
    address public immutable staking;
    address public immutable CLAM;

    constructor(address _staking, address _CLAM) {
        require(_staking != address(0));
        staking = _staking;
        require(_CLAM != address(0));
        CLAM = _CLAM;
    }

    function stake(uint256 _amount, address _recipient) external {
        IERC20(CLAM).transferFrom(msg.sender, address(this), _amount);
        IERC20(CLAM).approve(staking, _amount);
        IFnyStaking(staking).stake(_amount, _recipient);
        IFnyStaking(staking).claim(_recipient);
    }
}