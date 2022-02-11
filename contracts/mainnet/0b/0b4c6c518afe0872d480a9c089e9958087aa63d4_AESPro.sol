/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

pragma solidity ^0.6.12;

/**
 * @title FFF Game
**/

//SPDX-License-Identifier: MIT

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address receiver) external returns(uint256);
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value) external;
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
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

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract Util {
    uint usdtWei = 1e18;
    
    //动态奖励
    function getRecommendScaleByAmountAndTim() internal pure returns(uint){
        return 10;
    }

    //用户等级
    function getDynLevel(uint myPerformance,uint dynHash,uint hashratePerformance) internal view returns(uint) {
        if (myPerformance < 1 * usdtWei || hashratePerformance < 1 * usdtWei) {
            return 0;
        }
        if (dynHash >= 300000 * usdtWei && hashratePerformance >= 6000000 * usdtWei) {
            return 4;
        }
        else if (dynHash >= 60000 * usdtWei && hashratePerformance >= 1800000 * usdtWei) {
            return 3;
        }
        else if (dynHash >= 15000 * usdtWei && hashratePerformance >= 300000 * usdtWei) {
            return 2;
        }
        else if (myPerformance >= 2000 * usdtWei && hashratePerformance >= 10000 * usdtWei) {
            return 1;
        }
        
        return 0;
    }
    
    function compareStr(string memory _str, string memory str) internal pure returns(bool) {
        if (keccak256(abi.encodePacked(_str)) == keccak256(abi.encodePacked(str))) {
            return true;
        }
        return false;
    }
    
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole is Context, Ownable {
    using Roles for Roles.Role;

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelist(_msgSender());
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelist(_msgSender()) || isOwner(), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function addWhitelist(address account) public onlyWhitelistAdmin {
        _addWhitelist(account);
    }

    function removeWhitelist(address account) public onlyOwner {
        _whitelistAdmins.remove(account);
    }
    
    function isWhitelist(address account) private view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function _addWhitelist(address account) internal {
        _whitelistAdmins.add(account);
    }

}

contract CoinTokenWrapper {
    
    using SafeMath for *;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    function stake(uint256 amount) internal {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
    }

    function withdraw(uint256 amount) internal {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
    }

    function reduce(address account,uint256 amount) internal {
        uint balance = balanceOf(account);
        if(balance <= 0 || amount <= 0){
            return;
        }
        //1、根据金本位动态减少收益
        //2、用户投入时给根据本金放大三倍，获得三倍算力
        //3、每次收益以金本位进行结算（F5）

        //如果收益大于总算力，则收益为总收益
        if(amount >= balance){
            amount = balance;
        }
        
        //动态减少算力
        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
    }

}

contract AESPro is Util, WhitelistAdminRole,CoinTokenWrapper {

    string constant private name = "AES";

    struct User{
        uint id;
        string referrer;
        uint dynamicLevel;
        uint allInvest;
        uint limitAmount;
        uint earnAmount;

        uint allDynamicAmount;
        uint hisDynamicAmount;
        
        uint hisBnbDynamicAmount;
        uint allBnbDynamicAmount;

        //FFF挖矿总奖励
        uint hisTokenAward;

	    //我的直推业绩
        uint performance;   
	    //链商体业绩
        uint nodePerformance;   
    	uint staticFlag;
	    //算力总业绩
    	uint hashratePerformance;
         //vip未分红奖金
        uint256 vipBonus;   
	    //vip累计分红
        uint256 vipTotalBonus;
	    //检查点
        uint checkpoint;
    }
    
    struct UserGlobal {
        uint id;
        address userAddress;
        string inviteCode;
        string referrer;
    }
    
    uint startTime;
    uint endTime;
    uint investMoney;
    uint totalU;
    uint totalB;
    uint residueMoney;
    uint uid = 0;
    uint rid = 1;
    uint period = 1 days;
    uint bnbWei = 1e18;
    uint bigRid = 1;
    
    mapping (uint => mapping(address => User)) userRoundMapping;
    mapping(address => UserGlobal) userMapping;
    mapping (string => address) addressMapping;
    mapping (uint => address) indexMapping;
    IUniswapV2Router02 public immutable uniswapV2Router;
    
    //==============================================================================
    address usdtAddr = address(0x6e42eAE3317a19Eb4B5115B0bcE388BBf21CB917);
    address marketAddr = address(0x69325cdFb6c7B68880B6a3c76891131C70331A04);
    
    IERC20 usdtToken = IERC20(usdtAddr);
    
    address miningTokenAddr = address(0xF64a4Ae72A599f58d0f928c551bE1E40cb51eC27);
    IERC20 miningToken = IERC20(miningTokenAddr);
    
    modifier isHuman() {
        address addr = msg.sender;
        uint codeLength;
        
        assembly {codeLength := extcodesize(addr)}
        require(codeLength == 0, "sorry humans only");
        require(tx.origin == msg.sender, "sorry, human only");
        _;
    }

    event LogInvestIn(address indexed who, uint indexed uid, uint amount, uint time, string inviteCode, string referrer);
    event LogWithdrawProfit(address indexed who, uint indexed uid, uint amount, uint time);
    event LogPullUpPrices(address user,uint256 amt);
    event UserLevel(address indexed user,uint256 p, uint256 level);

    //==============================================================================
    // Constructor
    //==============================================================================
    constructor () public {
        startTime = now;
        endTime = startTime.add(period);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
    }

    receive() external payable{
    }
    
    function getBNBPrice(uint amt) public view returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = usdtAddr;
        path[1] = uniswapV2Router.WETH();
        uint256[] memory result = uniswapV2Router.getAmountsOut(amt, path);
        return result[1];
    }

    function getTokenPrice(address token1,address token2, uint amt) public view returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = token1;
        path[1] = token2;
        uint256[] memory result = uniswapV2Router.getAmountsOut(amt, path);
        return result[1];
    }

    function statisticOfDay() private {
        if(getTimeLeft() != 0){
            return;
        }
        
        //update time
        startTime = endTime;
        endTime = startTime.add(period);
        
        settlementBonus();
    }

    function getTimeLeft() private view returns(uint256)
    {
        // grab time
        uint256 _now = now;

        if (_now < endTime)
            if (_now > startTime)
                return( endTime.sub(_now));
            else
                return( (startTime).sub(_now));
        else
            return(0);
    }

    
    //投资
    function investIn(string memory inviteCode,string memory referrer,uint256 value)
        public
        updateReward(msg.sender)
        checkStart
        isHuman()
        payable
    {
        // require(value >= 100*usdtWei, "The minimum bet is 100 USDT");
        require(value >= 1*usdtWei, "The minimum bet is 100 USDT");
        require(value == value.div(usdtWei).mul(usdtWei), "invalid msg value");
        usdtToken.transferFrom(msg.sender,address(this),value);
        
        //扣除BNB的价格
        // uint256 realBnbPrice = getBNBPrice(1 * usdtWei);
        uint256 bnbValue = msg.value;
        // require(bnbValue >= realBnbPrice, "The minimum bet is 100 USDT BNB");

        uint256 doubleValueHash = value * 2;
        uint newLimitAmount = doubleValueHash.mul(3);   //钱包放大三倍
        
        UserGlobal storage userGlobal = userMapping[msg.sender];
        if (userGlobal.id == 0) {
            require(!compareStr(inviteCode, ""), "empty invite code");
            address referrerAddr = getUserAddressByCode(referrer);
            require(uint(referrerAddr) != 0, "referer not exist");
            require(referrerAddr != msg.sender, "referrer can't be self");
            require(!isUsed(inviteCode), "invite code is used");

            registerUser(msg.sender, inviteCode, referrer);
        }
        
        //是否是新用户
        User storage user = userRoundMapping[rid][msg.sender];
        if (user.id != 0) {            
            user.allInvest = user.allInvest.add(doubleValueHash);
            user.limitAmount = user.limitAmount.add(newLimitAmount);    //钱包放大三倍
        } else {
            user.id = userGlobal.id;
            user.allInvest = doubleValueHash;
            user.limitAmount = newLimitAmount;  //钱包放大三倍
            user.referrer = userGlobal.referrer;
        }
        
        investMoney = investMoney.add(doubleValueHash);
        totalU = value.add(value);
        totalB = totalB.add(bnbValue);

        //USDT买入FFF后销毁
        //autoBuy(value);
        
        //分配动态奖金
        statisticOfDay();

        //抽水
        marketIncentives(bnbValue);

        //用户动态奖励自动分红BNB
        tjUserDynamicTree(userGlobal.referrer,doubleValueHash,bnbValue,value);
        
        //三倍算力挖矿
        super.stake(newLimitAmount);
        emit LogInvestIn(msg.sender, userGlobal.id, doubleValueHash, now, userGlobal.inviteCode, userGlobal.referrer);
    }

    //自动购买
    function autoBuy(uint amount) internal {
        IERC20 usdt = IERC20(usdtAddr);
        IERC20 fff = IERC20(miningTokenAddr);
        
        uint256 usdtAmount = amount;
        
        address[] memory path = new address[](2);
        path[0] = address(usdt);
        path[1] = address(fff);
        
        usdt.approve(address(uniswapV2Router), usdtAmount);
        
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    //抽水
    function marketIncentives(uint256 money) private {
        uint miningAmount = money.mul(10).div(100);
        address(uint160(marketAddr)).transfer(miningAmount);
    }
    
    //统计用户节点
    function tjUserDynamicTree(string memory referrer, uint doubleValueHash, uint bnbValue,uint usdtValue) private {
        string memory tmpReferrer = referrer;
        
        //计算代数收益
        uint recommendSc = getRecommendScaleByAmountAndTim();
        //收益BNB
        uint tmpDynamicBNBAmount = bnbValue.mul(90).div(100).mul(recommendSc).div(100);
        //收益USDT
        uint tmpDynamicUsdtValue = usdtValue.mul(90).div(100).mul(recommendSc).div(100);
        
        for (uint i = 1; i <= 20; i++) {
            if (compareStr(tmpReferrer, "")) {
                break;
            }
            address tmpUserAddr = addressMapping[tmpReferrer];
            User storage calUser = userRoundMapping[rid][tmpUserAddr];
            if (calUser.id == 0) {
                break;
            }
            
            //如果上级已空点则无收益
            if(calUser.earnAmount >= calUser.limitAmount){
                tmpReferrer = calUser.referrer;
                continue;
            }

            //统计网体总算力
            calUser.hashratePerformance = calUser.hashratePerformance.add(doubleValueHash);
            
            //统计2代内的网体总业绩
            if(i == 1){
                calUser.performance = calUser.performance.add(doubleValueHash);
            }else if(i == 2){
                calUser.nodePerformance = calUser.nodePerformance.add(doubleValueHash);
            }

            if(i <= 10){
                calUser.earnAmount = calUser.earnAmount.add(tmpDynamicUsdtValue);
                
                uint tmpDynamicAmount = tmpDynamicBNBAmount;
                //出局判断
                if (calUser.earnAmount >= calUser.limitAmount) {
                    calUser.staticFlag = calUser.staticFlag.add(1);

                    //修正收益
                    uint correction = calUser.earnAmount.sub(calUser.limitAmount);
                    if(correction > 0){
                        uint correctionBnb = getBNBPrice(correction);
                        tmpDynamicAmount = tmpDynamicAmount.sub(correctionBnb);
                        calUser.earnAmount = calUser.limitAmount;
                    }
                }
                
                //累计用户USDT收益
                calUser.hisDynamicAmount = calUser.hisDynamicAmount.add(tmpDynamicUsdtValue);
                //累计用户BNB收益
                calUser.hisBnbDynamicAmount = calUser.hisBnbDynamicAmount.add(tmpDynamicAmount);
                calUser.allBnbDynamicAmount = calUser.allBnbDynamicAmount.add(tmpDynamicAmount);
            }
            
            tmpReferrer = calUser.referrer;
        }
    }

    //提现BNB
    function withdrawBnb() updateReward(msg.sender) public
    {
        User storage user = userRoundMapping[rid][msg.sender];
        require(user.id > 0, "user not exist");
        
	    statisticOfDay();

        uint resultMoney = user.allBnbDynamicAmount;
        if (resultMoney > 0) {
            //提BNB
            msg.sender.transfer(resultMoney);
            user.allBnbDynamicAmount = 0;
            emit LogWithdrawProfit(msg.sender, user.id, resultMoney, now);
        }

        //矿工升级
        upDynamicLevel();
    }
    
    function isUsed(string memory code) public view returns(bool) {
        address user = getUserAddressByCode(code);
        return uint(user) != 0;
    }

    function getUserAddressByCode(string memory code) public view returns(address) {
        return addressMapping[code];
    }
    
    function getMiningInfo(address _user) public view returns(uint[44] memory ct,string memory inviteCode, string memory referrer) {
        User memory userInfo = userRoundMapping[rid][_user];
        
        uint256 earned = earned(_user);
        
        ct[0] = totalSupply();
        ct[1] = turnover;
        ct[2] = periodFinish;
        ct[3] = bigRid;
        ct[4] = 0;
        ct[5] = earned;
        ct[6] = status;
        ct[7] = bonusPool;
        
        ct[8] = vipTodayBonus[0];
        ct[9] = vipTodayBonus[1];
        ct[10] = vipTodayBonus[2];
        ct[11] = vipTodayBonus[3];
        
        ct[12] = vipHisBonus[0];
        ct[13] = vipHisBonus[1];
        ct[14] = vipHisBonus[2];
        ct[15] = vipHisBonus[3];
        
        ct[16] = vipLength[0];
        ct[17] = vipLength[1];
        ct[18] = vipLength[2];
        ct[19] = vipLength[3];
        
        ct[20] = unWithdrawBonus(_user);
        ct[21] = 0;
        ct[22] = 0;
        
        ct[23] = userInfo.vipBonus;
        ct[24] = userInfo.vipTotalBonus;
        ct[25] = userInfo.checkpoint;
        
        //Game INFO
        ct[26] = endTime;
        ct[27] = getTimeLeft();
        ct[28] = investMoney;
        ct[29] = residueMoney;
        ct[30] = 0;
        
        //USER INFO
        ct[31] = userInfo.allInvest;
        ct[32] = userInfo.limitAmount;
        ct[33] = userInfo.earnAmount;
        ct[34] = userInfo.allDynamicAmount;
        ct[35] = userInfo.hisDynamicAmount;
        ct[36] = userInfo.staticFlag;
        ct[37] = userInfo.allBnbDynamicAmount;
        ct[38] = userInfo.hisBnbDynamicAmount;
        ct[39] = userInfo.performance;
        ct[40] = userInfo.nodePerformance;
        ct[41] = userInfo.hashratePerformance;
        ct[42] = userInfo.hisTokenAward;
    	ct[43] = userInfo.dynamicLevel;
        
        inviteCode = userMapping[_user].inviteCode;
        referrer = userMapping[_user].referrer;
        
        return (
            ct,
            inviteCode,
            referrer
        );
    }
    
    function activeGame(uint time) external onlyWhitelistAdmin
    {
        require(time > now, "invalid game start time");
        startTime = time;
        endTime = startTime.add(period);
    }
    
    function registerUserInfo(address user, string calldata inviteCode, string calldata referrer) external onlyOwner {
        registerUser(user, inviteCode, referrer);
    }
    
    function registerUser(address user, string memory inviteCode, string memory referrer) private {
        UserGlobal storage userGlobal = userMapping[user];
        uid++;
        userGlobal.id = uid;
        userGlobal.userAddress = user;
        userGlobal.inviteCode = inviteCode;
        userGlobal.referrer = referrer;
        
        addressMapping[inviteCode] = user;
        indexMapping[uid] = user;
    }
    
    //------------------------------挖矿逻辑
    uint256 turnover;
    uint256 bonusPool;

    //为0则是头矿，为1则是正常
    uint256 status = 0;  
    //utc+8 2021-03-12 19:41:05
    uint256 public starttime = 1615549265; 
    //挖矿完成时间
    uint256 public periodFinish = 0;    
    //奖励比例
    uint256 public rewardRate = 0;  
    //最后更新时间
    uint256 public lastUpdateTime;
    //每个存储的令牌奖励
    uint256 public rewardPerTokenStored;    
    //每支付一个代币的用户奖励
    mapping(address => uint256) public userRewardPerTokenPaid;  
    //用户奖励
    mapping(address => uint256) public rewards; 
    
    //---------------------------------global vip
    struct Bonus {
        uint256 vip1AvgBonus;
        uint256 vip2AvgBonus;
        uint256 vip3AvgBonus;
        uint256 vip4AvgBonus;
    }
    
    //分红次数
    uint256 public shareBonusCount = 1;
    //礼物表
    mapping (uint => Bonus) public gifts;

    //uid -> 1
    mapping (uint => uint) vip1s;
    mapping (uint => uint) vip2s;
    mapping (uint => uint) vip3s;
    mapping (uint => uint) vip4s;

    //动态奖金比例
    uint256[] bonusRate = [25,12,8,5];
    //vip今日奖金
    uint256[] public vipTodayBonus = [0,0,0,0];
    //vip历史奖金
    uint256[] public vipHisBonus = [0,0,0,0];
    //vip人数
    uint256[] public vipLength = [0,0,0,0];
    
    event RewardAdded(uint256 reward);
    event RewardPaid(address indexed user, uint256 reward);
    
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
    
    function lastTimeRewardApplicable() public view returns (uint256) {
        return SafeMath.min(block.timestamp, periodFinish);
    }
    
    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }
    
    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }
    
    //提取F5
    function getReward() public updateReward(msg.sender) {
        User storage user = userRoundMapping[rid][msg.sender];
        require(user.id > 0, "user not exist");

        statisticOfDay();
        
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            //奖励清空
            rewards[msg.sender] = 0;

            uint avgReward = reward.mul(50).div(100);
            
            //结算静态挖矿收益
            uint staticReward = avgReward;
            closeReward(staticReward);
            emit RewardPaid(msg.sender, staticReward);
            
            //vip奖金池
            uint dynReward = avgReward;
            bonusPool = bonusPool.add(dynReward);
            
            //动态分红累加
            for(uint i = 0;i<bonusRate.length;i++){
                uint amt = reward.mul(bonusRate[i]).div(100);
                vipTodayBonus[i] = vipTodayBonus[i].add(amt);
                vipHisBonus[i] = vipHisBonus[i].add(amt);
            }

            
        }
    }

    function closeReward(uint staticReward) internal {
        User storage calUser = userRoundMapping[rid][msg.sender];
        // if(calUser.earnAmount >= calUser.limitAmount){
        //     return;
        // }
        
        //查询F5的USDT价格
        uint f5UsdtValue = getTokenPrice(miningTokenAddr,usdtAddr,staticReward);
        //累计USDT收益
        calUser.earnAmount = calUser.earnAmount.add(f5UsdtValue);
        
        //三倍出局判断
        uint tmpDynamicAmount = staticReward;
        if (calUser.earnAmount >= calUser.limitAmount) {
            calUser.staticFlag = calUser.staticFlag.add(1);

            //修正收益
            uint correction = calUser.earnAmount.sub(calUser.limitAmount);
            if(correction > 0){
                uint correctionToken = getTokenPrice(usdtAddr,miningTokenAddr,correction);
                tmpDynamicAmount = tmpDynamicAmount.sub(correctionToken);
                f5UsdtValue = f5UsdtValue.sub(correction);
                calUser.earnAmount = calUser.limitAmount;
            }
        }

        //累计F5静态收益
        calUser.hisTokenAward = calUser.hisTokenAward.add(tmpDynamicAmount);
        //F5结算奖励
        miningToken.transfer(msg.sender, tmpDynamicAmount);
        //动态减少算力
        super.reduce(msg.sender,f5UsdtValue);
    }

    //提取分红奖金
    function getBonus() public updateReward(msg.sender) {
        User storage user = userRoundMapping[rid][msg.sender];
        require(user.id > 0, "user not exist");
        
        statisticOfDay();
        useStatisticalBonusInner();
        
        if(user.vipBonus > 0){
            uint dynReward = user.vipBonus;
            //调用三倍出局
            closeReward(dynReward);
            //奖励清空
            user.vipBonus = 0;
            //流通量
            turnover = turnover.add(dynReward);
            emit RewardPaid(msg.sender, dynReward);
        }
        
        //矿工升级
        upDynamicLevel();
    }

    //更新用户等级
    function upDynamicLevel() private
    {
        User storage calUser = userRoundMapping[rid][msg.sender];
        
        uint dynamicLevel = calUser.dynamicLevel;
        uint newDynLevel = getDynLevel(calUser.performance,balanceOf(msg.sender),calUser.hashratePerformance);
        if(newDynLevel != 0 && dynamicLevel != newDynLevel){
            
            //update checkpoint
            if(calUser.checkpoint == 0){
               calUser.checkpoint = shareBonusCount; 
            }
            
             //领取分红
            useStatisticalBonusInner();
            
            //up level
            calUser.dynamicLevel = newDynLevel;
                
            //移除原有&加新用户
            doRemoveVip(calUser.id,dynamicLevel);
            doAddVip(calUser.id,newDynLevel);
            emit UserLevel(msg.sender,calUser.hashratePerformance,newDynLevel);
        }
    }

    //结算24小时分红奖金
    function settlementBonus() public {
        //今日总奖金 / vip人数 = 平均分红奖金
        for(uint i = 0;i<vipTodayBonus.length;i++){
            uint todayBonus = vipTodayBonus[i];
            if(todayBonus == 0){
                break;
            }
            
            uint length = vipLength[i];
            if(length == 0){
                length = 1;
            }
            
            uint256 avgBonus = todayBonus.div(length);
            if(i == 0){
                gifts[shareBonusCount].vip1AvgBonus = avgBonus;
            }else if(i == 1){
                gifts[shareBonusCount].vip2AvgBonus = avgBonus;
            }else if(i == 2){
                gifts[shareBonusCount].vip3AvgBonus = avgBonus;
            }else if(i == 3){
                gifts[shareBonusCount].vip4AvgBonus = avgBonus;
            }
            
            //清理今日奖金
            vipTodayBonus[i] = 0;
        }
        shareBonusCount++;
    }
    
    //领取分红
    function useStatisticalBonusInner() private {
        User storage user = userRoundMapping[rid][msg.sender];
        uint totalAmt = unWithdrawBonus(msg.sender);
        if(totalAmt > 0){
            user.vipBonus = user.vipBonus.add(totalAmt);
            user.vipTotalBonus = user.vipTotalBonus.add(totalAmt);
        }
        //must update checkpoint
        user.checkpoint = shareBonusCount;
    }
    
    //未领取分红
    function unWithdrawBonus(address _add) public view returns(uint) {
        User storage user = userRoundMapping[rid][_add];
        if(user.id == 0){
            return 0;
        }
        
        uint level = user.dynamicLevel;
        uint checkpoint = user.checkpoint;
        
        uint totalAmt = 0;
        for(uint i = checkpoint;i<shareBonusCount;i++){
            if(level == 1){
                totalAmt = totalAmt.add(gifts[i].vip1AvgBonus);
            }else if(level == 2){
                totalAmt = totalAmt.add(gifts[i].vip2AvgBonus);
            }else if(level == 3){
                totalAmt = totalAmt.add(gifts[i].vip3AvgBonus);
            }else if(level == 4){
                totalAmt = totalAmt.add(gifts[i].vip4AvgBonus);
            }
        }
        return totalAmt;
    }
    
    modifier checkStart(){
        require(block.timestamp > starttime,"not start");
        _;
    }
    
    function notifyRewardAmount()
        external
        onlyWhitelistAdmin
        updateReward(address(0))
    {
        uint256 reward = 19500000 * 1e18;
        uint256 INIT_DURATION = 6770 days;
        
        rewardRate = reward.div(INIT_DURATION);
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(INIT_DURATION);
        emit RewardAdded(reward);
    }

    function setMiningToken(address _add) external onlyWhitelistAdmin
    {
        miningTokenAddr = address(_add);
        miningToken = IERC20(miningTokenAddr);
    }

    function saveStuckedToken(address _token, address _to,uint amt) external onlyWhitelistAdmin {
        IERC20(_token).transfer(_to, amt);
    }

    function saveStuckedToken2(address _token, address _to) external onlyWhitelistAdmin {
        IERC20(_token).transfer(_to, IERC20(_token).balanceOf(address(this)));
    }
    
    function sweep() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

        //添加合伙人
    function doAddVip(uint _uid,uint _level) public
    {
        uint8 flag = 1;
        if(_level == 1){
            vip1s[_uid] = flag;
        }else if(_level == 2){
            vip2s[_uid] = flag;
        }else if(_level == 3){
            vip3s[_uid] = flag;
        }else if(_level == 4){
            vip4s[_uid] = flag;
        }
        
        uint _index = _level - 1;
        vipLength[_index] = vipLength[_index].add(1);
    }
    
    //移除合伙人
    function doRemoveVip(uint _uid,uint _level) public
    {
        if(doContainsVip(_uid,_level)){
            uint8 flag = 0;
            if(_level == 1){
                vip1s[_uid] = flag;
            }else if(_level == 2){
                vip2s[_uid] = flag;
            }else if(_level == 3){
                vip3s[_uid] = flag;
            }else if(_level == 4){
                vip4s[_uid] = flag;
            }
            
            uint _index = _level - 1;
            vipLength[_index] = vipLength[_index].sub(1);
        }
    }
    
    //包含合伙人
    function doContainsVip(uint _uid,uint _level) public view returns (bool)
    {
        uint8 flag = 1;
        if(_level == 1){
            return vip1s[_uid] == flag;
        }else if(_level == 2){
            return vip2s[_uid] == flag;
        }else if(_level == 3){
            return vip3s[_uid] == flag;
        }else if(_level == 4){
            return vip4s[_uid] == flag;
        }
        return false;
    }
    
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    
    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
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
        require(c / a == b, "mul overflow");

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "div zero"); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "lower sub bigger");
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "overflow");

        return c;
    }

}