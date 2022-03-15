/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// SPDX-License-Identifier: GPL-v3.0
pragma solidity >=0.4.0;
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}




pragma solidity ^0.6.0;

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}




pragma solidity >=0.4.0;

contract Context {

    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity >=0.4.0;

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity >=0.6.2;

interface IReferral {
    struct RefDetail {
        address upline;
        uint16 pos;
        uint256 bonusLeft;
        uint256 bonusRight;
    }
/**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);

    function getRefDetail(address _user) external view returns  (RefDetail memory);

    function updateBonus(address _user,uint256 _bonusLeft,uint256 _bonusRight) external;
}

pragma solidity >=0.5.16;

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

pragma solidity >=0.6.6;
interface IPancakeRouter{
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}


pragma solidity >=0.6.2;
pragma experimental ABIEncoderV2;

contract TLDMint is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    IPancakeRouter public pancakeRouter;

    // xos->usdt
    address[][] public path = [[0x4BacB027E0bf98025d8EC91493F6512b9F0FA0dc,0x55d398326f99059fF775485246999027B3197955],[0x55d398326f99059fF775485246999027B3197955,0x4BacB027E0bf98025d8EC91493F6512b9F0FA0dc]];

    // Info of each user.
    struct UserInfo {
        uint256 amount;  //amount value in token
        uint256 amountUSD;    
        uint256[] amountDetail;
        uint256[] amountDetailUSD;
        uint256[] createDates;
        uint256[] priceToken;
        uint256 dailyReward; 
        uint256 lastClaim;
        bool isPromo;
        uint256 promoEnd;
        uint256 promoDailyReward;
        uint256 pendingReward;
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;           // Address of LP token contract.
        IBEP20 rewardToken;
        uint256 totalStaked;
        uint256 totalStakedUSD;
        uint256 lastTimeReward;
    }

    struct Promo {
        uint256 start;
        uint256 end;
        uint256 reward;
        uint256 minAmount;
        uint256 duration;
    }

    uint256 public minDepo = 20000000000000000000; //usdt20

    IBEP20 public rewardToken;
    IBEP20 public usdtToken;

    uint256 public totalStakedAmount;

    uint256 public totalStakedAmountInXOS;
    // Info of each pool.
    PoolInfo[] public poolInfo;

    Promo public promo;
    //all user
    address[] public users;
    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfo;
    
    IReferral public referral;
    // Referral commission rate: 20%.
    uint16 public referralCommissionRate = 1000;
    uint16 public bonusPairingRate = 10;
    // daily reward: 1%.
    uint256 public dailyReward = 100;
    // contract length in day
    uint256 public contractLength = 365; 
    uint16 public referralRate = 10;

    mapping(address=>uint256) public sales;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event ReferralCommissionPaid(address indexed user, address indexed referrer, uint256 commissionAmount);

    mapping(address => bool) public smartChef;

    modifier onlyMasterChef() {
        require(smartChef[msg.sender] == true, "Only MasterChef can call this function");
        _;
    }

    constructor(IBEP20 _salsa,IBEP20 _rewardToken,IReferral _referral, address _pancakeRouter,IBEP20 _usdtToken) public {
        rewardToken = _rewardToken;
        referral = _referral;
        totalStakedAmount = 0;
        totalStakedAmountInXOS = 0;
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        usdtToken = _usdtToken;
        // staking pool
        poolInfo.push(PoolInfo({
            lpToken: _salsa,
            rewardToken: _rewardToken,
            totalStaked: 0,
            totalStakedUSD: 0,
            lastTimeReward:0
        }));
    }

    function addSmartChef(address _smartChef) external onlyOwner {
        smartChef[_smartChef] = true;
    }

    function setPromo(uint256 _start,uint256 _end,uint256 _reward,uint256 _minAmount,uint256 _duration) external onlyOwner {
        require(_end>_start,"End Date must be after Start Date");
        require(_reward>0,"Reward must be greated than 0");
        require(_minAmount>0,"Amount must be greated than 0");
        require(_duration>0,"Duration must be greated than 0");
        promo.start=_start;
        promo.end=_end;
        promo.reward=_reward;
        promo.minAmount=_minAmount;
        promo.duration=_duration;
    }

    function getAmountOuts(uint256 amount,address[] memory _path) public view returns (uint){
        uint256 totalOut = pancakeRouter.getAmountsOut(amount,_path)[1];
        return totalOut;
    }

    function removeUser(address _user) public onlyOwner{
        UserInfo storage user = userInfo[_user];
        PoolInfo storage pool = poolInfo[0];
        pool.totalStakedUSD = pool.totalStakedUSD - user.amountUSD;
        pool.totalStaked = pool.totalStaked - user.amount;
        user.amount=0;
        user.amountUSD=0;
        user.amountDetail=[0];
        user.amountDetailUSD=[0];
        user.createDates=[0];
        user.priceToken=[0];
        user.dailyReward=0;
        user.lastClaim=0;
        user.isPromo=false;
        user.promoEnd=0;
        user.promoDailyReward=0;
        user.pendingReward=0;
        
        for(uint i=0;i<users.length;i++){
            if(users[i]==_user)
                delete users[i];
        }
    }
    
    function setTotalStakedAmount(uint256 _totalStakedAmount,uint256 _totalStakedUSD) public onlyOwner{
        totalStakedAmount = _totalStakedAmount;
        PoolInfo storage pool = poolInfo[0];
        pool.totalStakedUSD = _totalStakedUSD;
        pool.totalStaked = _totalStakedAmount;
    }

    function setPancakeRouter(address _pancakeRouter) public onlyOwner{
        pancakeRouter = IPancakeRouter(_pancakeRouter);
    }

    function emergencyTokenWithdraw(IBEP20 token,uint256 _amount,address _to) public onlyOwner {
        require(_amount < token.balanceOf(address(this)), 'not enough token');
        token.safeTransfer(address(_to), _amount);
    }

    function LPWithdraw(uint256 _pid,uint256 _amount) public onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        require(_amount < pool.lpToken.balanceOf(address(this)), 'not enough token');
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
    }
    
    function setDailyReward(uint256 _dailyReward) public onlyOwner{
        dailyReward = _dailyReward;
    }
    
    function setContractLength(uint16 _contractLength) public onlyOwner{
        contractLength = _contractLength;
    }

    // Update the referral contract address by the owner
    function setReferralAddress(IReferral _referral) external onlyOwner {
        referral = _referral;
    }
    
    
    // Update referral rate level 1
    function setReferralRate(uint16 _referralRate) public onlyOwner {
        referralRate = _referralRate;
    }
    
    function stopReward(uint256 _pid) public onlyOwner {
        poolInfo[_pid].lastTimeReward = block.timestamp;
    }

    function getUserByAddress(address _user) public view returns (UserInfo memory) {
        return userInfo[_user];
    }

    function addUsers(address _user) internal{
        if(userInfo[_user].amount==0){
             users.push(_user);
        }   
    }

    function getAllUsers() public view returns (address[] memory){
        return users;
    }

    //return totalAmountCanRemove
    function getTotalAmountCanRemove(address _user) public view returns (uint256){
        UserInfo storage user = userInfo[_user];
        uint256[] storage contractdate = user.createDates;
        uint256 totalAmount = 0;
        for(uint i=0; i<contractdate.length; i++){
            uint256 end = contractdate[i] + contractLength*86400;
            if(block.timestamp >= end){
                totalAmount = totalAmount + user.amountDetail[i];
            }
        }
        return totalAmount;
    }

    // View function to see pending Reward on frontend.
    function pendingReward(uint256 _pid,address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        PoolInfo storage pool = poolInfo[_pid];
        // per daily
        uint256 rew = 0;
        if(pool.lastTimeReward==0 && !user.isPromo){
            rew = (user.amount*(block.timestamp - user.lastClaim)*user.dailyReward)/8640000/1000000;
        //promo
        }else if(pool.lastTimeReward==0 && user.isPromo){
            if(block.timestamp>user.promoEnd)
                rew = ((user.amount*(user.promoEnd - user.lastClaim)*user.promoDailyReward)+(user.amount*(block.timestamp - user.promoEnd)*user.dailyReward))/8640000/1000000;
            else
                rew = (user.amount*(block.timestamp - user.lastClaim)*user.promoDailyReward)/8640000/1000000;
        }else{
            rew = (user.amount*(pool.lastTimeReward - user.lastClaim)*user.dailyReward)/8640000/1000000;
        }
        return rew*10000;
    }
    
    function getLPPrice(address lp) public view returns (uint256){
        uint256 totalSupply = IPancakePair(lp).totalSupply();
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IPancakePair(lp).getReserves();
        uint256 price = reserve1*2/totalSupply; 
        return price;
    }
    
    //update sales
    function updateSales(address _user,uint256 _amount) internal{
        address _refer = referral.getReferrer(_user);
        while(_refer != address(0)){
            sales[_refer] = sales[_refer] + _amount;
            _refer = referral.getReferrer(_refer);
        }
    }

    function getPriceToken(uint256 _pid) public view returns (uint){
        uint256 price = pancakeRouter.getAmountsOut(1,path[_pid])[1];
        return price;
    }

    function harvest(uint256 _pid) public {
        harv(_pid,msg.sender);
    }

    function harv(uint256 _pid,address buyer) internal {
        UserInfo storage user = userInfo[buyer];

        if (user.amount > 0 && pendingReward(_pid,buyer)>0) {
            uint256 pending = pendingReward(_pid,buyer);
                if(pending > 0) {
                    rewardToken.safeTransfer(address(buyer), pending.mul(8).div(10));
                    payReferralCommission(buyer, pending);
                    user.lastClaim = block.timestamp;
                    user.dailyReward = dailyReward;
                }
        }
        if(user.isPromo && block.timestamp>user.promoEnd){
            //reset promo
            user.isPromo = false;
            user.promoEnd = 0;
            user.promoDailyReward = 0;
        }
    }

    function addUser(address _user, address _referrer,uint256 _amount) public onlyOwner{
        depo(0,_amount,_referrer,_user);
    }

    function deposit(uint256 _pid,uint256 _amount, address _referrer) public {
        depo(_pid,_amount,_referrer,msg.sender);
    }

    function payPairing(address _user,uint256 _amount) internal{
        address refUser = referral.getReferrer(_user);
        IReferral.RefDetail memory refDetailUser = referral.getRefDetail(_user);
        IReferral.RefDetail memory refDetailUpline = referral.getRefDetail(refUser);
        if(refDetailUser.pos==1){
                if(refDetailUpline.bonusRight>0 && refDetailUpline.bonusRight<=_amount){
                    //pay bonus pairing
                    uint256 bonusPairing = _amount*bonusPairingRate/100;
                    rewardToken.safeTransfer(address(refUser), bonusPairing);
                    //update paring
                    uint256 bonusRight = refDetailUpline.bonusRight - _amount;
                    referral.updateBonus(address(refUser),0,bonusRight);
                }else if(refDetailUpline.bonusRight==0){
                    referral.updateBonus(address(refUser),_amount,0);
                }else{
                    //pay bonus pairing
                    uint256 bonusPairing = refDetailUpline.bonusRight*bonusPairingRate/100;
                    rewardToken.safeTransfer(address(refUser), bonusPairing);
                    //update paring
                    uint256 bonusLeft = _amount - refDetailUpline.bonusRight;
                    referral.updateBonus(address(refUser),bonusLeft,0);
                }
        }else{
                if(refDetailUpline.bonusLeft>0 && refDetailUpline.bonusLeft<=_amount){
                    //pay bonus pairing
                    uint256 bonusPairing = _amount*bonusPairingRate/100;
                    rewardToken.safeTransfer(address(refUser), bonusPairing);
                    //update paring
                    uint256 bonusLeft = refDetailUpline.bonusLeft - _amount;
                    referral.updateBonus(address(refUser),0,bonusLeft);
                }else if(refDetailUpline.bonusLeft==0){
                    referral.updateBonus(address(refUser),0,_amount);
                }else{
                    //pay bonus pairing
                    uint256 bonusPairing = refDetailUpline.bonusLeft*bonusPairingRate/100;
                    rewardToken.safeTransfer(address(refUser), bonusPairing);
                    //update paring
                    uint256 bonusRight = _amount - refDetailUpline.bonusLeft;
                    referral.updateBonus(address(refUser),0,bonusRight);
                }
        }
    }

    function depo(uint256 _pid,uint256 _amount, address _referrer,address _user) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_user];

        if (_amount > 0 && address(referral) != address(0) && _referrer != address(0) && _referrer != _user) {
            referral.recordReferral(_user, _referrer);
            //pay bonus pairing
            payPairing(_user,_amount);
            address refUser = referral.getReferrer(_user);
            while(refUser != address(0)){
                payPairing(refUser,_amount);
                refUser = referral.getReferrer(refUser);
            }
        }
        if (user.amount > 0) {
            harv(_pid,_user);
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(_user), address(this), _amount);
            uint256 price = getPriceToken(_pid);
            //check promo
            if(block.timestamp>=promo.start && block.timestamp<=promo.end && _amount>promo.minAmount && user.amountUSD==0){
                user.isPromo = true;
                user.promoEnd = block.timestamp + promo.duration;
                user.promoDailyReward = promo.reward;
            }
            addUsers(address(_user));
            user.amountUSD = user.amountUSD.add(_amount);
            uint256 tokenAmount = _amount/price;
            user.amount = user.amount + tokenAmount;
            user.lastClaim = block.timestamp;
            user.amountDetailUSD.push(_amount);
            user.amountDetail.push(tokenAmount);
            user.createDates.push(block.timestamp);
            user.priceToken.push(price);
            if(user.dailyReward==0)
                user.dailyReward = dailyReward;

            //update pool info
            pool.totalStaked = pool.totalStaked + tokenAmount;
            pool.totalStakedUSD = pool.totalStakedUSD.add(_amount);
            updateSales(address(_user),_amount);
        }
        emit Deposit(_user, _amount);
    }
    
    function withdraw(uint256 _pid,uint256 _amount) public {
        if(_amount<=getTotalAmountCanRemove(msg.sender)){
            PoolInfo storage pool = poolInfo[_pid];
            UserInfo storage user = userInfo[msg.sender];
            require(user.amount >= _amount, "withdraw: not good");
            harvest(_pid);
            if(_amount > 0) {
                pool.lpToken.safeTransfer(address(msg.sender), _amount);
                //remove amount in array
                uint256 removeAmount = 0;
                uint256 totalWasRemove = _amount;
                uint256 totalWasRemoveUSD = 0;

                //calculate percent remove
                uint256 percentRemove = _amount*100/user.amount;
                uint256 totalRemoved = user.amount*percentRemove/100;
                user.amount = user.amount - totalRemoved;

                for(uint i=0; i<user.createDates.length; i++){
                    uint256 end = user.createDates[i] + contractLength*86400;
                    if(block.timestamp >= end && removeAmount<_amount && totalWasRemove>0){
                        totalWasRemove = totalWasRemove - user.amountDetail[i];
                        if(totalWasRemove>=0){
                            user.amountUSD = user.amountUSD -user.amountDetailUSD[i];
                            totalWasRemoveUSD = totalWasRemoveUSD+user.amountDetailUSD[i];
                            removeAmount = removeAmount + user.amountDetail[i];
                            user.amount = user.amount-user.amountDetail[i];
                            //remove array
                            delete user.amountDetail[i];
                            delete user.amountDetailUSD[i];
                            delete user.createDates[i];
                        }else{
                            //update array
                            uint256 lastremove = _amount-removeAmount;
                            user.amountDetail[i] = user.amountDetail[i] - lastremove;
                            uint256 amtUSD = user.amountUSD;
                            user.amountUSD = user.amountUSD * (1-lastremove/user.amount);
                            totalWasRemoveUSD = totalWasRemoveUSD+(amtUSD-user.amountUSD); 
                            removeAmount = removeAmount + lastremove;
                            user.amount = user.amount-lastremove;
                        }
                    }
                }
                if(user.amount == 0){
                    user.dailyReward = 0;
                }
                totalStakedAmount = totalStakedAmount.sub(_amount);
                totalStakedAmountInXOS = totalStakedAmountInXOS - totalRemoved;
                pool.totalStaked = pool.totalStaked - _amount;
                pool.totalStakedUSD = pool.totalStakedUSD - totalWasRemoveUSD;
            }
    
            emit Withdraw(msg.sender, _amount);
        }
    }

    function getTotalStakedAmount(uint256 _pid) public view returns (uint256){
        PoolInfo storage pool = poolInfo[_pid];
        return pool.totalStaked;
    }
    
    // Pay referral commission to the referrer who referred this user.
    function payReferralCommission(address _user, uint256 _pending) internal {
        uint256 commissionAmount = _pending.mul(referralRate).div(100);
        address _referral = referral.getReferrer(_user);
        if(address(_referral) != address(0) && commissionAmount>0){
            //pay to referral
            rewardToken.safeTransfer(_referral, commissionAmount);
            emit ReferralCommissionPaid(_user, _referral, commissionAmount);
        }
    }
    
}