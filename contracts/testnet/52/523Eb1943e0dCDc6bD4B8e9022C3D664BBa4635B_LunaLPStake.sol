/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Pair {
    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);
}


interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}


contract LunaLPStake is Ownable {
    address constant private destroyAddress = address(0x000000000000000000000000000000000000dEaD);

    address constant public usdtToken = address(0xe5213623818B6DC70144F37aE585ca465e290cA8);
    address constant public ungToken = address(0xe8b2BdAfe0D42F4dd98Fe55Bb0E9830270DAa45e);
    address constant public lunaToken = address(0x28a86cd1253a2E1956eFbC353A48CE4312012609);
    address constant public lunaDaoToken = address(0x93703a21A22A1Da8fE2aCB1226f9f122b8231718);
    address public lunaUngLp;  // luna->ung 的 LP

    uint256 private timeInterval = 10;   //一天等于多少秒，测试阶段用600，正式上线用86400

    uint8 constant private lunaDecimals = 18;
    IUniswapV2Router02 constant public uniswapV2Router = IUniswapV2Router02(0xcaa594A2Ac434e36e5D10a41aEe4a932EB52363B);

    address private mgrAddress; // 管理地址
    address private sysAddress; // 系统操作地址


    struct UserInfo {
        uint256 lpTotal; //总质押
        uint256 lpUnStaked; //已赎回
        uint256 lpCanUnStake; //当前可赎回

        uint256 usdtAmt; // 算力，折合USDT数量
        uint256 lunaDAOReleased; // 已释放LunaDAO数量
        uint256 lunaDAOWithdrawed; // 已提现LunaDAO
    }


    struct StakeInfo {
        address user;   // 质押的用户
        uint16 stakeDays; // 质押天数
        uint256 lpAmt; // LP数量
        uint256 usdtAmt; // 折合USDT数量
        uint256 time; // 质押时间
        uint256 roundTime; // 整数时间，即计时时间，填明天凌晨时间
        uint256 lunaDAOReleased; // 已释放LunaDAO数量
        bool isUnStake; // 释放已经赎回
    }
    StakeInfo[] public stakeInfos;   // 质押信息-每次质押

    mapping (address => int256[]) public stakeUserIdx;  // 用户的质押索引（用户质押信息对应stakeInfos中的位置）
    mapping (address => int256[]) public stakeUserIdxActive;  // 用户的释放中的质押索引（用户质押信息对应stakeInfos中的位置，更新了userPowerReleased才移除）

    mapping (address => uint256) private userLpTotal;  // 用户当前总质押LP
    mapping (address => uint256) private userLpUnStaked;  // 用户已赎回LP

    mapping (address => uint256) private userPowerTotal;  // 用户总算力，以U为单位

    mapping (address => uint256) private userLunaDAOReleased;  // 用户已释放LunaDAO
    mapping (address => uint256) private userLunaDAOWithdrawed;  // 用户已提现LunaDAO

    mapping (uint256 => uint256) public rewardLunaDAOInfoForDayAmt90; // 开始时间（整数时间）=> 每U释放LunaDAO数量
    mapping (uint256 => bool) public rewardLunaDAOInfoForDayIsOver90; // 开始时间（整数时间）=> 是否释放完成
    mapping (uint256 => uint256) public rewardLunaDAOInfoForDayAmt180; // 开始时间（整数时间）=> 每U释放LunaDAO数量
    mapping (uint256 => bool) public rewardLunaDAOInfoForDayIsOver180; // 开始时间（整数时间）=> 是否释放完成
    mapping (uint256 => uint256) public rewardLunaDAOInfoForDayAmt360; // 开始时间（整数时间）=> 每U释放LunaDAO数量
    mapping (uint256 => bool) public rewardLunaDAOInfoForDayIsOver360; // 开始时间（整数时间）=> 是否释放完成

    uint256 public rountDateTime; //当前整数时间


    constructor(address mgrAddress_, address sysAddress_, uint256 rountDateTime_) {
        lunaUngLp = IUniswapV2Factory(uniswapV2Router.factory()).getPair(lunaToken, ungToken);

        mgrAddress = mgrAddress_;
        sysAddress = sysAddress_;
        rountDateTime = rountDateTime_;
    }

    event UnStakeLunaLPEvent(address to, uint256 amountLp);

    function unStakeLunaLP() external returns (bool) {
        uint256 canUnStakeNum = getAndSetCanUnStakeNum(_msgSender());
        require(canUnStakeNum > 0, "unStakeLunaLP: Can UnStake Num is zero.");
        require(canUnStakeNum <= IERC20(lunaUngLp).balanceOf(address(this)), "unStakeLunaLP: system balance not enough.");

        userLpUnStaked[_msgSender()] += canUnStakeNum;

        IERC20(lunaUngLp).transfer(_msgSender(), canUnStakeNum);

        emit UnStakeLunaLPEvent(_msgSender(), canUnStakeNum);

        return true;
    }

    function getAndSetCanUnStakeNum(address user) private returns(uint256 waitUnStake) {
        int256 maxIdx = int256(stakeUserIdxActive[user].length - 1);
        for(int256 i; i <= maxIdx; i++) { // 这里特意用int256
            StakeInfo storage di = stakeInfos[uint256(stakeUserIdxActive[user][uint256(i)])];
            if (!di.isUnStake && block.timestamp > di.time + (di.stakeDays * timeInterval)) {
                waitUnStake += di.lpAmt;

                di.isUnStake = true;
            }
        }
    }

    event StakeLunaLPEvent(address from, uint256 amountLp, uint256 amountLpToUSDT);

    function stakeLunaLP (uint256 amountLp, uint amountUsdt, uint16 daysStake) external returns (bool) {
        require(_msgSender() == tx.origin, "stakeLunaLP: Can't From Contract.");

        require(daysStake == 90 || daysStake == 180 || daysStake == 360, "stakeLunaLP: Only 90 180 360 days supported.");

        uint256 lpToUSDTPrice = getCurLPPrice();
        uint256 amountLpToUSDT = amountLp * lpToUSDTPrice / 1e9; // LP数量折算成USDT
        require(amountLpToUSDT >= 100 * 1e18, "stakeLunaLP: LP amount is too small");  // 最低100U
        require(amountLpToUSDT * 101 / 100 >= amountUsdt, "stakeLunaLP: USDT amount is too big");

        TransferHelper.safeTransferFrom(lunaUngLp, _msgSender(), address(this), amountLp);

        StakeInfo memory di = StakeInfo({
            user: _msgSender(), 
            stakeDays: daysStake,
            lpAmt: amountLp, 
            usdtAmt: amountUsdt, 
            time: block.timestamp, 
            roundTime: getRoundTime(block.timestamp), 
            lunaDAOReleased: 0,
            isUnStake: false});

        stakeInfos.push(di);

        userPowerTotal[_msgSender()] = userPowerTotal[_msgSender()] + amountUsdt;
        userLpTotal[_msgSender()] = userLpTotal[_msgSender()] + amountLp;

        stakeUserIdx[_msgSender()].push(int256(stakeInfos.length - 1));  // 存储各用户在数组中的index
        stakeUserIdxActive[_msgSender()].push(int256(stakeInfos.length - 1));  // 存储各用户在数组中的index

        if (stakeUserIdxActive[_msgSender()].length > 1) {   //大于1表示排除当前这个
            releaseLunaDao(_msgSender(), 0, int256(stakeUserIdxActive[_msgSender()].length - 2));
        }

        emit StakeLunaLPEvent(_msgSender(), amountLp, amountUsdt);

        return true;
    }

    // maxIdx表示最后一个处理的，填0时，就直接取Length-1，像在destroyLuna方法中调用的就要减一，即刚销毁的不用算
    function releaseLunaDao(address user, int256 fromIdx, int256 maxIdx) private {
        if (maxIdx == -1 || maxIdx >= int256(stakeUserIdxActive[user].length)) {
            maxIdx = int256(stakeUserIdxActive[user].length - 1);
        }
        if (fromIdx < 0) {
            fromIdx = 0;
        }

        for(int256 i = fromIdx; i <= maxIdx; i++) { // 这里特意用int256
            StakeInfo storage di = stakeInfos[uint256(stakeUserIdxActive[user][uint256(i)])];

            uint256 shouldRelease;
            if (di.stakeDays == 90) {
                shouldRelease = di.usdtAmt * rewardLunaDAOInfoForDayAmt90[di.roundTime] / 1e18;  // 除以18次方是因为后台设置的是一个USDT对应的LunaDAO数量
            } else if (di.stakeDays == 180) {
                shouldRelease = di.usdtAmt * rewardLunaDAOInfoForDayAmt180[di.roundTime] / 1e18;  
            } else {
                shouldRelease = di.usdtAmt * rewardLunaDAOInfoForDayAmt360[di.roundTime] / 1e18;  
            }

            if (di.lunaDAOReleased < shouldRelease) {
                userLunaDAOReleased[user] += shouldRelease - di.lunaDAOReleased;
                di.lunaDAOReleased = shouldRelease;
            }

            if(di.isUnStake) { // 已经赎回
                if (
                    (di.stakeDays == 90 && rewardLunaDAOInfoForDayIsOver90[di.roundTime])
                    ||
                    (di.stakeDays == 180 && rewardLunaDAOInfoForDayIsOver180[di.roundTime])
                    ||
                    (di.stakeDays == 360 && rewardLunaDAOInfoForDayIsOver360[di.roundTime])
                ) {
                    stakeUserIdxActive[user][uint256(i)] = stakeUserIdxActive[user][stakeUserIdxActive[user].length - 1];
                    stakeUserIdxActive[user].pop();
                    i --;
                    maxIdx --;
                }
            }
        }
    }


    function getUserInfo(address user) public view returns(UserInfo memory userInfo) {
        require(user != address(0), "getUserInfo: Zero Address.");
        
        if (stakeUserIdx[user].length == 0) {
            return userInfo;
        }
        

        int256 maxIdx = int256(stakeUserIdxActive[user].length - 1);
        uint256 waitRealeased;
        uint256 waitUnStake;

        for(int256 i; i <= maxIdx; i++) { // 这里特意用int256
            StakeInfo storage di = stakeInfos[uint256(stakeUserIdxActive[user][uint256(i)])];
            
            uint256 shouldRelease;
            if (di.stakeDays == 90) {
                shouldRelease = di.usdtAmt * rewardLunaDAOInfoForDayAmt90[di.roundTime] / 1e18;  // 除以18次方是因为后台设置的是一个USDT对应的LunaDAO数量
            } else if (di.stakeDays == 180) {
                shouldRelease = di.usdtAmt * rewardLunaDAOInfoForDayAmt180[di.roundTime] / 1e18;  
            } else {
                shouldRelease = di.usdtAmt * rewardLunaDAOInfoForDayAmt360[di.roundTime] / 1e18;  
            }


            if (di.lunaDAOReleased < shouldRelease) {
                waitRealeased += shouldRelease - di.lunaDAOReleased;
            }

            if (!di.isUnStake && block.timestamp > di.time + (di.stakeDays * timeInterval)) {
                waitUnStake += di.lpAmt;
            }
        }

        userInfo.lpTotal = userLpTotal[user];
        userInfo.lpUnStaked = userLpUnStaked[user];
        userInfo.lpCanUnStake = waitUnStake;

        userInfo.usdtAmt = userPowerTotal[user];
        userInfo.lunaDAOReleased = userLunaDAOReleased[user] + waitRealeased;
        userInfo.lunaDAOWithdrawed = userLunaDAOWithdrawed[user];
    }


    function getRoundTime(uint256 time) public returns(uint256) {
        if (time < rountDateTime) {
            return rountDateTime;
        }

        uint256 _days =  (time - rountDateTime) / 86400;
        if ((time - rountDateTime) % 86400 > 0) {
            _days += 1;
        }

        rountDateTime += _days * 86400;

        return rountDateTime;
    }

    function setMgrAddress(address mgrAddress_) public onlyOwner {
        mgrAddress = mgrAddress_;
    } 

    function setSysAddress(address sysAddress_) public onlyOwner {
        sysAddress = sysAddress_;
    }
    
    function setRewardLunaDAOInfoForDayAmt90(uint256[] memory times, uint256[] memory lunaDAOAmtPerUsdts) public returns(bool) {
        require(_msgSender() == sysAddress, "setRewardLunaDAOInfoForDayAmt: Not SYS Address.");

        for(uint256 i = 0; i < times.length; i++) {
            rewardLunaDAOInfoForDayAmt90[times[i]] = lunaDAOAmtPerUsdts[i];
        }

        return true;
    }


    function setRewardLunaDAOInfoForDayIsOver90(uint256[] memory times, bool isOver) public returns(bool) {
        require(_msgSender() == sysAddress, "setRewardLunaDAOInfoForDayIsOver: Not SYS Address.");

        for(uint256 i = 0; i < times.length; i++) {
            rewardLunaDAOInfoForDayIsOver90[times[i]] = isOver;
        }

        return true;
    }

    function setRewardLunaDAOInfoForDayAmt180(uint256[] memory times, uint256[] memory lunaDAOAmtPerUsdts) public returns(bool) {
        require(_msgSender() == sysAddress, "setRewardLunaDAOInfoForDayAmt: Not SYS Address.");

        for(uint256 i = 0; i < times.length; i++) {
            rewardLunaDAOInfoForDayAmt180[times[i]] = lunaDAOAmtPerUsdts[i];
        }

        return true;
    }


    function setRewardLunaDAOInfoForDayIsOver180(uint256[] memory times, bool isOver) public returns(bool) {
        require(_msgSender() == sysAddress, "setRewardLunaDAOInfoForDayIsOver: Not SYS Address.");

        for(uint256 i = 0; i < times.length; i++) {
            rewardLunaDAOInfoForDayIsOver180[times[i]] = isOver;
        }

        return true;
    }


    function setRewardLunaDAOInfoForDayAmt360(uint256[] memory times, uint256[] memory lunaDAOAmtPerUsdts) public returns(bool) {
        require(_msgSender() == sysAddress, "setRewardLunaDAOInfoForDayAmt: Not SYS Address.");

        for(uint256 i = 0; i < times.length; i++) {
            rewardLunaDAOInfoForDayAmt360[times[i]] = lunaDAOAmtPerUsdts[i];
        }

        return true;
    }


    function setRewardLunaDAOInfoForDayIsOver360(uint256[] memory times, bool isOver) public returns(bool) {
        require(_msgSender() == sysAddress, "setRewardLunaDAOInfoForDayIsOver: Not SYS Address.");

        for(uint256 i = 0; i < times.length; i++) {
            rewardLunaDAOInfoForDayIsOver360[times[i]] = isOver;
        }

        return true;
    }

    function getCurLPPrice() public view returns (uint256) {  // 计算一个LP价值多少U
        // LP 总量
        uint256 lpTotal = IERC20(lunaUngLp).totalSupply();
        // LP 中UNG的数量
        uint256 ungInLpAmt = IERC20(ungToken).balanceOf(lunaUngLp);

        // UNG价格
        address[] memory path = new address[](2);
        path[0] = ungToken;
        path[1] = usdtToken;
        uint[] memory amounts = uniswapV2Router.getAmountsOut(10 ** lunaDecimals, path);
        if (amounts[0] == 0) {
            return 0;
        }

        uint256 lpTotalValue = 2 * ungInLpAmt * amounts[1] * 1e9 / amounts[0];

        return lpTotalValue / lpTotal;
    }


    function getStakeUserIdxLen(address user) public view returns(uint256) {
        return stakeUserIdx[user].length;
    }

    
    function getStakeUserIdxActiveLen(address user) public view returns(uint256) {
        return stakeUserIdxActive[user].length;
    }


    function userWithdrawFund() public returns (bool){
        releaseLunaDao(_msgSender(), 0, -1);
        
        uint256 canWithdrawLunaDao = userLunaDAOReleased[_msgSender()] - userLunaDAOWithdrawed[_msgSender()];
        require(canWithdrawLunaDao > 0, "balance not enough");
        require(canWithdrawLunaDao <= IERC20(lunaDaoToken).balanceOf(address(this)), "system balance not enough");

        userLunaDAOWithdrawed[_msgSender()] += canWithdrawLunaDao;

        IERC20(lunaDaoToken).transfer(_msgSender(), canWithdrawLunaDao);

        return true;
    }

    function userReleaseReward(int256 fromIdx, int256 maxIdx) public returns (bool){
        releaseLunaDao(_msgSender(), fromIdx, maxIdx);

        return true;
    }


    function rescueToken(address tokenAddress, uint256 tokens) public returns (bool success) {
        require(_msgSender() == mgrAddress, "rescueToken: Not Mgr Address.");
        return IERC20(tokenAddress).transfer(_msgSender(), tokens);
    } 
}