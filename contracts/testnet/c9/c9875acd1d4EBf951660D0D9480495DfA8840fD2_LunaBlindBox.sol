/**
 *Submitted for verification at BscScan.com on 2022-07-04
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

interface GetWarp {
    function withdraw() external ;
}

interface IUniswapV2Router01 {
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

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

     function approve(address spender, uint256 amount) external returns (bool);
}

contract LunaBlindBox is Ownable {
    address constant public usdtToken = address(0xe5213623818B6DC70144F37aE585ca465e290cA8);
    address constant public lunaDaoToken = address(0x93703a21A22A1Da8fE2aCB1226f9f122b8231718);
    address constant public uniswapV2Pair = address(0xEDF393201736c58E6ca85eb76470815840218e0B);
    address constant private destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    uint256 constant public secondsPerDay = 180;  // 测试时，用180，表示3分钟代表一天，线上用 86400
    IUniswapV2Router02 constant public uniswapV2Router = IUniswapV2Router02(0xcaa594A2Ac434e36e5D10a41aEe4a932EB52363B);

    uint16[] public inviteRewardConfig = [400,60,60,60,60,60,25,25,25,25,25,25,25,25,25,25,25,25];  // 推荐关系奖励配置  第一代40%，第2-6代6%，7-18代2.5%
    uint16[] public powerChanceConfig = [990,970,940,900,850,790,720,640];  // 算力概率配置

    
    struct BuyInfo {
        address user;   // 购买盲盒的用户
        uint256 usdtAmt; // 购买盲盒时USDT数量
        uint256 lunaDAOAmt; // 购买盲盒时Luna数量
        uint256 power; // 购买盲盒时获得算力
        uint256 time; // 购买盲盒时间
        uint256 roundTime; // 整数时间，即计时时间，填明天凌晨时间
        uint256 lunaDAOReleased; // 已释放LunaDAO数量
    }

    BuyInfo[] public buyInfos; // 所有购买盲盒信息

    uint256 public sysPowerTotal; // 系统总算力，以U为单位
    uint256 public sysPowerReleased; // 系统已释放算力，以U为单位

    mapping (uint256 => uint256) public rewardLunaDAOInfoForDayAmt; // 开始时间（整数时间）=> 每U释放LunaDAO数量
    mapping (uint256 => uint256) public rewardLunaDAOInfoForDayPowerAmt; // 开始时间（整数时间）=> 每U释放Power数量
    mapping (uint256 => bool) public rewardLunaDAOInfoForDayIsOver; // 开始时间（整数时间）=> 是否释放完成

    uint256 public rountDateTime; //当前整数时间

    mapping (address => uint256) private buyUserPowerTotal;     // 用户总算力，以U为单位
    mapping (address => uint256) private buyUserPowerReleased;  // 用户已释放算力，以U为单位
    mapping (address => uint256) private buyUserLunaDAOReleased;  // 用户已释放算力，以LunaDAO为单位
    mapping (address => uint256) private buyUserLunaDAOReleasedByInvite;  // 用户通过分享释放的算力，以LunaDAO为单位
    mapping (address => uint256) private buyUserLunaDAOWithdrawed;  // 用户已提现算力，以LunaDAO为单位

    mapping (address => int256[]) private buyUserIdx;  // 用户的购买索引（对应buyUser、buyUsdtAmt、buyPower、buyTime）
    mapping (address => int256[]) private buyUserIdxActive;  // 用户的购买索引，如果已经释放完成，则从此数组移除

    mapping (address => address) public inviteMap; // 推荐关系
    address[] public inviteKeys;  //推荐关系的key，即本人


    GetWarp public warp;    
    
    uint8 constant private lunaDaoDecimals = 18;   

    bool public isLunaDaoDestroy;  // 开盲盒时的LunaDAO是否销毁

    address private mgrAddress; // 管理地址
    address private sysAddress; // 系统操作地址

    constructor(address mgrAddress_, address sysAddress_, uint256 rountDateTime_) {
        isLunaDaoDestroy = true;
        mgrAddress = mgrAddress_;
        sysAddress = sysAddress_;
        rountDateTime = rountDateTime_;

        IERC20(usdtToken).approve(address(uniswapV2Router), 10 ** 50);
    }


    function approveUsdtForRouter() public onlyOwner {
        IERC20(usdtToken).approve(address(uniswapV2Router), 10 ** 50);
    }

    function setRootFather(address self) public onlyOwner {  // 管理员设置根级用户
        inviteMap[self] = destroyAddress;
        inviteKeys.push(self);
    }

    function setFather(address father) public returns (bool) {
        require(father != address(0), "setFather: father can't be zero.");
        require(inviteMap[_msgSender()] == address(0), "setFather: Father already exists.");
        require(!isContract(father), "setFather: Father is a contract.");
        require(inviteMap[father] != address(0), "setFather: Father don't have father.");

        inviteMap[_msgSender()] = father;
        inviteKeys.push(_msgSender());

        return true;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function getForefathers(address self, uint num) internal view returns(address[] memory fathers){
        fathers = new address[](num);
        address parent  = self;
        for( uint i = 0; i < num; i++){
            parent = inviteMap[parent];
            if(parent == destroyAddress) break;
            fathers[i] = parent;
        }
    }

    event BuyBlindBox(address from, uint256 amountUsdt, uint8 powerMultiple);

    function buyBlindBox (
        uint amountLunaDao,
        uint amountUsdt
    ) external {
        require(_msgSender() == tx.origin, "BuyBlindBox: Can't From Contract.");
        require(inviteMap[_msgSender()] != address(0), "BuyBlindBox: Don't have Father.");
        require(amountUsdt % (100 * 10 ** 18) == 0, "BuyBlindBox: USDT amount must be an integral multiple of 100");

        uint256 tokenToUSDTPrice = getCurPrice();
        uint256 amountLunaDaoToUSDT = amountLunaDao * tokenToUSDTPrice / 1e9 * 110 / 100; // 如果充值的LunaDAO数量误差小于10%，允许购买算力
        require(amountLunaDaoToUSDT >= amountUsdt, "BuyBlindBox: LunaDao amount is too small");

        // LunaDao销毁
        if (isLunaDaoDestroy) {
            TransferHelper.safeTransferFrom(lunaDaoToken, _msgSender(), destroyAddress, amountLunaDao);
        } else {
            TransferHelper.safeTransferFrom(lunaDaoToken, _msgSender(), address(this), amountLunaDao);
        }
        

        // USDT 先转到当前地址
        TransferHelper.safeTransferFrom(usdtToken, _msgSender(), address(this), amountUsdt);

        // USDT 换LunaDao
        uint256 initialBalance = IERC20(lunaDaoToken).balanceOf(address(this));
        swapTokensForOther(amountUsdt);
        uint256 lunaSwapped = IERC20(lunaDaoToken).balanceOf(address(this)) - initialBalance;

        // 奖励父级
        address[] memory farthers = getForefathers(_msgSender(), inviteRewardConfig.length);
        uint len = farthers.length;
        for(uint i = 0; i < len; i++){
            address parent = farthers[i];
            if(parent == address(0) || parent == destroyAddress) break;

            // 分配的LunaDAO数量
            uint256 reward = inviteRewardConfig[i] * lunaSwapped / 1000;

            releaseLunaDaoByInvite(parent, reward, tokenToUSDTPrice);
            
        }

        // 盲盒随机数
        uint256 random = genRandom();
        uint8 powerMultiple = 2;  // 默认2倍
        for(uint8 i = 0; i < 8; i++) {
            if (random >= powerChanceConfig[i]) {
                powerMultiple = 8 - i + 2;   // 最高10倍
                break;
            }
        }

        // 用户总算力增加
        buyUserPowerTotal[_msgSender()] += 2 * amountUsdt * powerMultiple;  // 因为USDT和LunaDAO都是18位小数，这里直接乘以2 再乘以 倍数即可
        // 系统总算力增加
        sysPowerTotal += 2 * amountUsdt * powerMultiple;

        // 存储兑换信息
        BuyInfo memory bi = BuyInfo({
            user: _msgSender(), 
            usdtAmt: amountUsdt, 
            lunaDAOAmt: amountLunaDao, 
            power: 2 * amountUsdt * powerMultiple,
            time: block.timestamp, 
            roundTime: getRoundTime(block.timestamp), 
            lunaDAOReleased: 0
        });
        buyInfos.push(bi);

        buyUserIdx[_msgSender()].push(int256(buyInfos.length) - 1);  // 存储各用户在数组中的index
        buyUserIdxActive[_msgSender()].push(int256(buyInfos.length) - 1);  // 存储各用户在数组中的index

        emit BuyBlindBox(_msgSender(), amountUsdt, powerMultiple);
    }

    function getRoundTime(uint256 time) public view returns(uint256) {
        if (time < rountDateTime) {
            return rountDateTime;
        }

        uint256 _days =  (time - rountDateTime) / secondsPerDay;
        if ((time - rountDateTime) % secondsPerDay > 0) {
            _days += 1;
        }

        return rountDateTime + _days * 86400;

        //return rountDateTime;
    }

    // maxIdx表示最后一个处理的，填0时，就直接取Length-1，像在destroyLuna方法中调用的就要减一，即刚销毁的不用算
    function releaseLunaDao(address user, int256 fromIdx, int256 maxIdx) private {
        if (maxIdx == -1 || maxIdx >= int256(buyUserIdxActive[user].length)) {
            maxIdx = int256(buyUserIdxActive[user].length) - 1;
        }
        if (fromIdx < 0) {
            fromIdx = 0;
        }

        for(int256 i = fromIdx; i <= maxIdx; i++) { // 这里特意用int256

            // 这个判断，要放到这个循环里面，因为可能到某一个，就满足这个条件了
            if (buyUserPowerReleased[user] >= buyUserPowerTotal[user]) {  // 没有投资的，这里也直接返回了
                return;
            }

            BuyInfo storage di = buyInfos[uint256(buyUserIdxActive[user][uint256(i)])];

            uint256 shouldRelease = di.power * rewardLunaDAOInfoForDayAmt[di.roundTime] / 1e18;  // 除以18次方是因为后台设置的是一个USDT对应的LunaDAO数量
            if (di.lunaDAOReleased < shouldRelease) {
                buyUserLunaDAOReleased[user] += shouldRelease - di.lunaDAOReleased;
                di.lunaDAOReleased = shouldRelease;
                buyUserPowerReleased[user] += di.power * rewardLunaDAOInfoForDayPowerAmt[di.roundTime] / 1e18;

                sysPowerReleased += di.power * rewardLunaDAOInfoForDayPowerAmt[di.roundTime] / 1e18;
            }

            if(rewardLunaDAOInfoForDayIsOver[di.roundTime]) { // 已经完成
                buyUserIdxActive[user][uint256(i)] = buyUserIdxActive[user][buyUserIdxActive[user].length - 1];
                buyUserIdxActive[user].pop();
                i --;
                maxIdx --;
            }
        }
    }

    function releaseLunaDaoByInvite(address user, uint256 rewardLunaDaoAmt, uint256 tokenToUSDTPrice) private {
        if (buyUserPowerReleased[user] >= buyUserPowerTotal[user]) {  // 没有投资的，这里也直接返回了
            return;
        }

        // 折算成USDT的数量
        uint256 rewardUsdt = rewardLunaDaoAmt * tokenToUSDTPrice / 1e9;

        // 释放算力
        if (buyUserPowerReleased[user] + rewardUsdt >= buyUserPowerTotal[user]) {
            
            uint256 curRelease = buyUserPowerTotal[user] - buyUserPowerReleased[user];

            // 系统已释放算力
            sysPowerReleased += curRelease;
            
            buyUserPowerReleased[user] =  buyUserPowerTotal[user];

            // LunaDAO数量
            buyUserLunaDAOReleased[user] += curRelease * 1e9 / tokenToUSDTPrice;  //因为USDT的价格

            buyUserLunaDAOReleasedByInvite[user] += curRelease * 1e9 / tokenToUSDTPrice;
        } else {
            // 系统已释放算力
            sysPowerReleased += rewardUsdt;

            buyUserPowerReleased[user] += rewardUsdt;

            // LunaDAO数量
            buyUserLunaDAOReleased[user] += rewardLunaDaoAmt;

            buyUserLunaDAOReleasedByInvite[user] += rewardLunaDaoAmt;
        }
    }

    function setRewardLunaDAOInfoForDayAmt(uint256[] memory times, uint256[] memory lunaDAOAmtPerUsdts, uint256[] memory powerAmtPerUsdts) public returns(bool) {
        require(_msgSender() == sysAddress, "setRewardLunaDAOInfoForDayAmt: Not SYS Address.");

        for(uint256 i = 0; i < times.length; i++) {
            rewardLunaDAOInfoForDayAmt[times[i]] = lunaDAOAmtPerUsdts[i];
            rewardLunaDAOInfoForDayPowerAmt[times[i]] = powerAmtPerUsdts[i];
        }

        return true;
    }


    function setRewardLunaDAOInfoForDayIsOver(uint256[] memory times, bool isOver) public returns(bool) {
        require(_msgSender() == sysAddress, "setRewardLunaDAOInfoForDayIsOver: Not SYS Address.");

        for(uint256 i = 0; i < times.length; i++) {
            rewardLunaDAOInfoForDayIsOver[times[i]] = isOver;
        }

        return true;
    }

    function setInviteRewardConfig(uint16[] memory inviteRewardConfig_) public onlyOwner {
        inviteRewardConfig = inviteRewardConfig_;
    }

    function setPowerChanceConfig(uint16[] memory powerChanceConfig_) public onlyOwner {
        powerChanceConfig = powerChanceConfig_;
    }

    function setIsLunaDaoDestroy(bool isLunaDaoDestroy_) public onlyOwner {
        isLunaDaoDestroy = isLunaDaoDestroy_;
    }

    function setMgrAddress(address mgrAddress_) public onlyOwner {
        mgrAddress = mgrAddress_;
    } 

    function setSysAddress(address sysAddress_) public onlyOwner {
        sysAddress = sysAddress_;
    } 
    

    function getBuyInfos(address user) public view returns(BuyInfo[] memory _buyInfos) {        
        int256[] memory idxs = buyUserIdx[user];
        if (idxs.length > 0) {
            // 初始化数组大小
            _buyInfos = new BuyInfo[](idxs.length);

            for(int256 i = 0; i < int256(idxs.length); i++){
                _buyInfos[uint256(i)] = buyInfos[uint256(idxs[uint256(i)])];
            }
        }

        return _buyInfos;
    }

    function buyUserSummary(address user) public view returns(
            uint256 _buyUserPowerTotal, 
            //uint256 _buyUserPowerReleased,
            uint256 _buyUserLunaDAOReleased,
            uint256 _buyUserLunaDAOReleasedByInvite,
            uint256 _buyUserLunaDAOWithdrawed,
            uint256 _latestPowerMultiple,
            uint256 _sysPowerTotal) {

        uint256 latestPowerMultiple;
        int256[] memory idxs = buyUserIdx[user];
        if (idxs.length > 0) {
            latestPowerMultiple = buyInfos[uint256(idxs[idxs.length - 1])].power / buyInfos[uint256(idxs[idxs.length - 1])].usdtAmt / 2;
        }

        int256 maxIdx = int256(buyUserIdxActive[user].length) - 1;
        uint256 waitRealeased;

        for(int256 i; i <= maxIdx; i++) { // 这里特意用int256
            BuyInfo memory di = buyInfos[uint256(buyUserIdxActive[user][uint256(i)])];
            uint256 shouldRelease = di.power * rewardLunaDAOInfoForDayAmt[di.roundTime] / 1e18;  // 除以18次方是因为后台设置的是一个USDT对应的LunaDAO数量
            if (di.lunaDAOReleased < shouldRelease) {
                waitRealeased += shouldRelease - di.lunaDAOReleased;
            }
        }

        // buyUserPowerReleased[user],  
        return (buyUserPowerTotal[user], buyUserLunaDAOReleased[user] + waitRealeased, 
            buyUserLunaDAOReleasedByInvite[user], buyUserLunaDAOWithdrawed[user], latestPowerMultiple, sysPowerTotal);
    }

    function changeSwapWarp(GetWarp _warp) public onlyOwner {
        warp = _warp;
    }

    function swapTokensForOther(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> usdt
		address[] memory path = new address[](2);
        path[0] = usdtToken;
        path[1] = lunaDaoToken;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(warp),
            block.timestamp
        );
        warp.withdraw();
    }

    function getCurPrice() public view returns (uint) {
        (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        if (reserve0 == 0 || reserve1 == 0) {
            return 0;
        }
        address[] memory path = new address[](2);
        path[0] = lunaDaoToken;
        path[1] = usdtToken;
        uint[] memory amounts = uniswapV2Router.getAmountsOut(10 ** lunaDaoDecimals, path);
        if (amounts[0] == 0) {
            return 0;
        }
        return amounts[1] * 1e9 / amounts[0];
    }

    function genRandom() public view returns (uint256 random) {        
        random = uint256(keccak256(abi.encodePacked(
                (block.timestamp) + (block.difficulty) 
                + (uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp) 
                + block.gaslimit + (uint256(keccak256(abi.encodePacked(_msgSender())))) / (block.timestamp) + block.number
            ))) % 1000;
    }

    function userWithdrawFund() public returns (bool){
        releaseLunaDao(_msgSender(), 0, -1);

        uint256 canWithdrawLunaDao = buyUserLunaDAOReleased[_msgSender()] - buyUserLunaDAOWithdrawed[_msgSender()];
        require(canWithdrawLunaDao > 0, "balance not enough");
        require(canWithdrawLunaDao <= IERC20(lunaDaoToken).balanceOf(address(this)), "system balance not enough");

        buyUserLunaDAOWithdrawed[_msgSender()] += canWithdrawLunaDao;

        IERC20(lunaDaoToken).transfer(_msgSender(), canWithdrawLunaDao);

        return true;
    }

    function userReleaseReward(int256 fromIdx, int256 maxIdx) public returns (bool){
        releaseLunaDao(_msgSender(), fromIdx, maxIdx);

        return true;
    }


    function rescueToken(address tokenAddress, uint256 tokens) public returns (bool success) {
        require(_msgSender() == mgrAddress, "SetReleaseInfoBySys: Not Mgr Address.");
        return IERC20(tokenAddress).transfer(_msgSender(), tokens);
    }
}