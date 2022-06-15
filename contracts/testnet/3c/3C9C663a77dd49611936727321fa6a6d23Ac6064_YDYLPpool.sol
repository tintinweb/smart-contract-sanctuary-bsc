/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value
        );
        require(token.approve(spender, newAllowance));
    }
}

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

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

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool wasInitializing = initializing;
        initializing = true;
        initialized = true;

        _;

        initializing = wasInitializing;
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        uint256 cs;
        assembly {
            cs := extcodesize(address)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

contract LPTokenWrapper is Initializable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Detailed;

    ERC20Detailed internal y;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function initialize(address _y) internal initializer {
        y = ERC20Detailed(_y); //
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount, uint256 feeAmount) internal {
        _totalSupply = _totalSupply.add(amount.sub(feeAmount));
        _balances[msg.sender] = _balances[msg.sender].add(
            amount.sub(feeAmount)
        );
        y.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount, uint256 feeAmount) internal {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        y.transfer(msg.sender, amount.sub(feeAmount));
    }
}

contract YDYLPpool is LPTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // mainnet
    // IPancakeRouter01 public PancakeRouter01 =
    //     IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // IERC20 private token = IERC20(0x55d398326f99059fF775485246999027B3197955);

    // testnet
    IPancakeRouter01 public PancakeRouter01 =
        IPancakeRouter01(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    IERC20 private token = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);

    bool private flag = false;                   
    uint256 private totalRewards = 0;            
    uint256 private precision = 1e18;

    uint256 private starttime;
    uint256 private stoptime;
    uint256 private lastUpdateTime;              
    uint256 private rewardPerTokenStored;   

    address public deployer;
    address public feeAddress;

    uint256 public fee = 300;
    uint256 public rRate = 50;
    uint256 public invRate = 200;
    uint256 public percentRate = 1000;

    address public pair;

    // uint256 public minInvitationLimit = 200e18;
    uint256 public minInvitationLimit = 10e18;

    mapping(address => uint256) private userRewardPerTokenPaid; 
    mapping(address => uint256) private rewards;        

    mapping(address => address) internal _parents;
    mapping(address => address[]) _mychilders;
    mapping(address => uint256) _invitereward;

    mapping(address => uint256) rewardPerTokenStoredByInvite;  
    mapping(address => uint256) private userRewardPerTokenPaidByInvite; 
    mapping(address => uint256) private rewardsByInvite;

    mapping(address => uint256) public investAmount;

    event StartPool(uint256 starttime, uint256 stoptime);
    event BindingParents(address indexed user, address inviter);
    event Staked(address indexed user, uint256 amount, uint256 feeAmount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    function setFeeAddress(address _feeAddress) public {
        require(msg.sender == deployer, "sender must deployer");

        feeAddress = _feeAddress;
    }

    function setDeployer(address _deployer) public {
        require(msg.sender == deployer, "sender must deployer");

        deployer = _deployer;
    }

    function setFee(uint256 _fee) public {
        require(msg.sender == deployer, "sender must deployer");

        fee = _fee;
    }

    function setRRate(uint256 _rRate) public {
        require(msg.sender == deployer, "sender must deployer");

        rRate = _rRate;
    }

    function setInvRate(uint256 _invRate) public {
        require(msg.sender == deployer, "sender must deployer");

        invRate = _invRate;
    }

    function setMinInvitationLimit(uint256 _minInvitationLimit) public {
        require(msg.sender == deployer, "sender must deployer");

        minInvitationLimit = _minInvitationLimit;
    }

    modifier updateReward(address account) {
        address parent = _parents[account];

        if(block.timestamp > starttime){
            rewardPerTokenStored = rewardPerToken();

            if (parent != address(0)) {
                rewardPerTokenStoredByInvite[parent] = rewardPerTokenByInvite(parent);
            }
            
            flag = true;
        
            lastUpdateTime = lastTimeRewardApplicable();
            if (account != address(0)) {
         
                rewards[account] = earned(account);
       
                userRewardPerTokenPaid[account] = rewardPerTokenStored;

                if (parent != address(0)) {
                    rewardsByInvite[parent] = earnedInvite(parent);
                    
                    userRewardPerTokenPaidByInvite[parent] = rewardPerTokenStoredByInvite[parent];
                }
            }
        }
        _;
    }

    constructor(
        address _y,
        uint256 _starttime,
        uint256 _stoptime
    ) public {
        deployer = msg.sender;
        pair = _y;

        super.initialize(_y);
        starttime = _starttime;
        stoptime = _stoptime;
        emit StartPool(starttime, stoptime);
    }

    function setPool(uint256 _starttime, uint256 _stoptime) public {
        require(msg.sender == deployer, "sender must deployer");

        starttime = _starttime;
        stoptime = _stoptime;
        emit StartPool(starttime, stoptime);
    }

    function stake(uint256 amount) public updateReward(msg.sender) checkStop {
        require(amount > 0, "The number must be greater than 0");

        super.stake(amount, 0);

        investAmount[msg.sender] = investAmount[msg.sender].add(amount.mul(getETHPx()).div(1e18));

        address parent = _parents[msg.sender];
        if (parent != address(0)) _invitereward[parent] = _invitereward[parent].add(amount.div(5));

        emit Staked(msg.sender, amount, 0);
    }

    function getReward() public updateReward(msg.sender)  checkStart{
        uint256 reward = earned(msg.sender).add(earnedInvite(msg.sender));
        if (reward > 0) {
            rewards[msg.sender] = 0;

            rewardsByInvite[msg.sender] = 0;
            
            // uint256 projectfee = reward.mul(fee).div(100);
            
            // token.safeTransfer(feeAddress, projectfee);
            
            // token.safeTransfer(msg.sender, reward.sub(projectfee));

            token.safeTransfer(msg.sender, reward);
            
            emit RewardPaid(msg.sender, reward);
            totalRewards = totalRewards.add(reward);
        }
    }

    function exit() public updateReward(msg.sender) {
        uint256 amount = balanceOf(msg.sender);
        require(amount > 0, "Cannot withdraw 0");

        super.withdraw(amount, amount.mul(fee).div(1000));

        investAmount[msg.sender] = 0;

        address parent = _parents[msg.sender];
        if (parent != address(0)) _invitereward[parent] = _invitereward[parent].sub(amount.mul(invRate).div(percentRate));

        emit Withdrawn(msg.sender, amount);
    }

    function earned(address account) public view returns (uint256) {
        if(block.timestamp < starttime){
            return 0;
        }
        return
        balanceOf(account)
        .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
        .div(precision)
        .add(rewards[account]);
    }

    function earnedInvite(address account) public view returns (uint256) {
        if(block.timestamp < starttime){
            return 0;
        }
        return
        rewardPerTokenByInvite(account).sub(userRewardPerTokenPaidByInvite[account])
        .add(rewardsByInvite[account]);
    }

    function rewardPerTokenByInvite(address account) internal view returns (uint256) {
        uint256 lastTime = 0 ;
        if(flag){
            lastTime = lastUpdateTime;
        }else{
            lastTime = starttime;
        }

        uint256 rewardRate = _invitereward[account].mul(getETHPx()).div(1e18);

        return
        rewardPerTokenStoredByInvite[account].add(
            lastTimeRewardApplicable()
            .sub(lastTime)
            .mul(rewardRate)
            .div(86400)
        );
    }

    function lastTimeRewardApplicable() internal view returns (uint256) {
        return SafeMath.min(block.timestamp, stoptime);
    }


    function rewardPerToken() internal view returns (uint256) {
        if (totalSupply() == 0) {               
            return rewardPerTokenStored;
        }
        uint256 lastTime = 0 ;
        if(flag){
            lastTime = lastUpdateTime;
        }else{
            lastTime = starttime;
        }

        uint256 rewardRate = totalSupply().mul(getETHPx()).div(1e18).mul(rRate).div(percentRate);

        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable()
            .sub(lastTime)
            .mul(rewardRate)
            .mul(precision)
            .div(totalSupply())
            .div(86400)
        );
    }

    modifier checkStart() {
        require(block.timestamp > starttime, "not start");
        _;
    }

    modifier checkStop() {
        require(block.timestamp < stoptime, "already stop");
        _;
    }

    function getPoolInfo()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (starttime, stoptime, totalSupply());
    }

    function getETHPx() public view returns (uint256) {
        uint256 totalSupply = IPancakePair(pair).totalSupply();
        (uint256 r0, uint256 r1, ) = IPancakePair(pair).getReserves();
        uint256 px0 = r0.mul(1e18).div(getp2());
        uint256 px1 = r1;
        return px0.add(px1).mul(1e18).div(totalSupply);
    }

    function getp2() public view returns (uint256) {
        uint256[] memory amounts;
        address[] memory path = new address[](2);
        path[0] = IPancakePair(pair).token0();
        path[1] = IPancakePair(pair).token1();
        amounts = PancakeRouter01.getAmountsIn(1e18, path);
        if (amounts.length > 0) {
            return amounts[0];
        } else {
            return 0;
        }
    }

    function bindParent(address parent) public {
        require(investAmount[parent] >= minInvitationLimit, "parent less invest amount");
        require(_parents[msg.sender] == address(0), "Already bind");
        require(parent != address(0), "ERROR parent");
        require(parent != msg.sender, "error parent");
        // require(_parents[parent] != address(0));
        _parents[msg.sender] = parent;
        _mychilders[parent].push(msg.sender);
        emit BindingParents(msg.sender, parent);
    }

    function setParentByAdmin(address user, address parent) public {
        require(_parents[user] == address(0), "Already bind");
        require(msg.sender == deployer);
        _parents[user] = parent;
        _mychilders[parent].push(user);
    }

    function getMyChilders(address user)
        public
        view
        returns (address[] memory)
    {
        return _mychilders[user];
    }

    function getParent(address user) public view returns (address) {
        return _parents[user];
    }

    function getInviteReward(address user) public view returns (uint256) {
        return _invitereward[user];
    }

    function clearPot(address tokenAddr) public {
        if (msg.sender == deployer) {
            IERC20(tokenAddr).safeTransfer(msg.sender, token.balanceOf(address(this)));
        }
    }
}