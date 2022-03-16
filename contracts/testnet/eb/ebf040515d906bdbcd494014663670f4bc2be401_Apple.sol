// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.5.16;
import "./TransferHelper.sol";
import "./SafeMath.sol";
pragma experimental ABIEncoderV2;

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

interface IPancakeRouter02 is IPancakeRouter01 {
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

contract Apple {
    using SafeMath for uint256;
    uint256 constant private TYPE_STATIC = 1;
    uint256 constant private TYPE_DYNAMIC = 2;
    // BUSD合约地址
    address private _busdContractAddress;
    // BUSD合约精度
    uint256 private _busdContractDecimal;
    // APPLE的代币余额
    address private _appleContractAddress;
    // APPLE的代币精度
    uint256 private _appleContractDecimal;
    // 获取APPLE价格的path
    address[] private path;
    // 直推人数 - 拿到的代数
    uint256[] private _getGenByCountArray = [1, 2, 3, 4, 5, 6, 10];
    // 代数 - 拿到百分比
    uint256[] private _getPercentByGenArray = [10, 10, 5, 5, 5, 5, 5, 5, 5, 5];
    // 销毁记录
    DestroyInfo[] private _destroyRecord;
    // 地址 - 第几代 - 这代的子地址集
    mapping (address => mapping (uint256 => SubInfo[])) private _subAddressMap;
    // 地址 - 所有下级地址
    mapping (address => SubInfo[]) private _teamAddressArray;
    // 地址 - 高度 - 静态算力
    mapping (address => mapping (uint256 => HashInfo)) private _addressHeightStaticHashRateMap;
    // 地址 - 高度 - 动态算力
    mapping (address => mapping (uint256 => HashInfo)) private _addressHeightDynamicHashRateMap;
    // 地址 - 总静态算力
    mapping (address => uint256) private _addressTotalStaticHashRateMap;
    // 地址 - 总动态算力
    mapping (address => uint256) private _addressTotalDynamicHashRateMap;
    // 地址 - 购买的空间信息
    mapping (address => SpaceInfo[]) private _addressSpaceMap;
    // 地址 - 购买的空间销毁的APPLE数量
    mapping (address => SummaryInfo) private _addressBuySpaceDestroyMap;
    // 高度 - 静态单位算力收益
    mapping (uint256 => uint256) private _staticUintProfitMap;
    // 高度 - 动态单位算力收益
    mapping (uint256 => uint256) private _dynamicUintProfitMap;
    // 领取记录
    mapping (address => TakeInfo[]) private _extractRecord;
    // 开挖时间
    uint256 private _startMineTime;
    // 全网总静态算力
    uint256 internal _netTotalStaticHashRate;
    // 全网总动态算力
    uint256 internal _netTotalDynamicHashRate;
    // 地址 - 上级地址
    mapping (address => address) private _parentAddressMap;
    // 地址 - 累计已领取收益
    mapping (address => uint256) private _addressTakedProfitMap;
    // 最后计算静态和动态单位算力收益的高度
    uint256 private _lastCalculateBlockHeight;
    // 锁定空间价格?
    bool private _lockSpacePrice;
    // 购买空间的BUSD收款地址
    address private _spaceReceiveAddress;
    // 空间单价[BUSD]
    uint256 private _spacePrice;
    // 已销毁APPLE数量
    uint256 private _destroyedApple;
    // 发布者
    address private _owner;
    // 总上级地址
    address private _totalParentAddress;
    // APPLE价格-测试用
    uint256 private _testApplePrice;


    // 子地址信息
    struct SubInfo {
        address user;// 地址
        uint256 time;// 激活时间
    }
    // 算力信息
    struct HashInfo {
        bool record;// 是否记录过
        uint256 hash;// 此高度的算力
    }
    // 算力信息
    struct HashRateInfo {
        address user;// 地址
        uint256 hash;// 算力
        uint256 time;// 时间
    }
    // 购买的空间信息
    struct SpaceInfo {
        uint256 time;// 购买时间
        uint256 buyHeight;// 购买高度
        uint256 spaceAmount;// 购买空间数量
        uint256 lastTakeHeight;// 上次领取收益高度
        uint256 realHashRate;// 真实算力
    }
    // 销毁信息
    struct DestroyInfo {
        address user;// 地址
        uint256 time;// 时间
        uint256 qty;// 数量
    }
    // 购买空间和销毁的APPLE累计值
    struct SummaryInfo {
        uint256 totalSpace;
        uint256 totalDestroy;
    }
    // 领取记录
    struct TakeInfo {
        uint256 qty;// 领取APPLE数量
        uint256 price;// 领取时的APPLE价格
        uint256 time;// 领取时间
    }

    //    IPancakeRouter02 private uniswapV2Router;
    modifier onlyOwner() {
        require(msg.sender == _owner, "only publisher can operate");
        _;
    }

    constructor (address appleContractAddress, uint256 appleContractDecimal, address busdContractAddress, uint256 busdContractDecimal) public {
        _appleContractAddress = appleContractAddress;
        _appleContractDecimal = appleContractDecimal;
        _busdContractAddress = busdContractAddress;
        _busdContractDecimal = busdContractDecimal;

        path = [_appleContractAddress, _busdContractAddress];

        _spacePrice = uint256(10).power(busdContractDecimal).mul(3).div(10);

        //        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //        uniswapV2Router = _uniswapV2Router;
        _owner = msg.sender;
    }

    function startMine() public onlyOwner {
        _startMineTime = block.timestamp;
    }

    // BUSD合约地址及精度
    function getBusdInfo() public view returns (address, uint256) {
        return (_busdContractAddress, _busdContractDecimal);
    }

    // APPLE合约地址及精度
    function getAppleInfo() public view returns (address, uint256) {
        return (_appleContractAddress, _appleContractDecimal);
    }

    // 获取APPLE价格
    //    function getApplePrice(uint256 amountIn) public view returns (uint[] memory amounts) {
    //        return uniswapV2Router.getAmountsOut(amountIn, path);
    //    }

    // 某地址静态算力变更[购买空间增算力或者提取收益降静态算力]之后他所有上级重新计算动态算力
    function refreshDynamicHashRateByBuy(address user, uint256 blockHeight) internal {
        // 上级地址
        address parent = user;
        // 顶多能拿到的代数差
        uint256 maxCanGetGenD = _getGenByCountArray[_getGenByCountArray.length.sub(1)];
        // 往上一直找上级刷新动态算力
        for (uint i = 0; i < maxCanGetGenD; i++) {
            // 刷新上级地址
            parent = _parentAddressMap[parent];
            // 已经没上级了，结束
            if (parent == address(0)) return;
            // 新总动态算力
            uint256 totalDynamicHashRate = calculateDynamicHashRate(parent);
            // 此上级地址没有算力变更，跳过
            if (totalDynamicHashRate == _addressTotalDynamicHashRateMap[parent]) continue;
            // 每个上级的新增算力
            (bool sub, uint256 value) = checkSubOrAdd(_addressTotalDynamicHashRateMap[parent], totalDynamicHashRate);
            // 上级地址更新总动态算力
            _addressTotalDynamicHashRateMap[parent] = totalDynamicHashRate;
            // 上级地址的此高度的动态算力刷新
            setAddressDynamicHashRateAtHeight(parent, blockHeight, totalDynamicHashRate);
            // 全网总动态算力更新
            _netTotalDynamicHashRate = sub ? _netTotalDynamicHashRate.sub(value) : _netTotalDynamicHashRate.add(value);
        }
    }

    // 看算力是增还是减
    function checkSubOrAdd(uint256 originHashRate, uint256 newHashRate) internal pure returns (bool sub, uint256 qty) {
        if (newHashRate > originHashRate) {
            return (false, newHashRate.sub(originHashRate));
        }
        if (newHashRate < originHashRate) {
            return (true, originHashRate.sub(newHashRate));
        }
    }

    // 某地址邀请子地址后他的动态算力重算
    function refreshDynamicHashRateByInvite(address user, uint256 blockHeight) internal {
        // 新总动态算力
        uint256 totalDynamicHashRate = calculateDynamicHashRate(user);
        // 重新设置此地址的动态算力
        _addressTotalDynamicHashRateMap[user] = totalDynamicHashRate;
        // 此地址在此高度的动态算力
        setAddressDynamicHashRateAtHeight(user, blockHeight, totalDynamicHashRate);
    }

    // 计算地址的动态算力
    function calculateDynamicHashRate(address user) public view returns (uint256) {
        // 新动态算力
        uint256 totalDynamicHashRate = 0;
        // 此上级地址的直推地址个数
        uint256 directSubCount = getAddressSpecificSubCount(user, 0);
        // 没有直推，肯定没动态算力
        if (directSubCount <= 0) return totalDynamicHashRate;
        // 超过7个也没用了
        if (directSubCount > 7) directSubCount = 7;
        // 上级地址能拿到的最大代数
        uint256 maxGen = _getGenByCountArray[directSubCount.sub(1)];
        // 每代都重新计算
        for (uint256 i = 0; i < maxGen; i++) {
            // 此代地址数量
            uint256 subAddressCount = getAddressSpecificSubCount(user, i);
            // 这一代拿的比例
            uint256 percent = _getPercentByGenArray[i];
            // 每个地址计算
            for (uint256 j = 0; j < subAddressCount; j++) {
                address s = _subAddressMap[user][i][j].user;
                // 此上级地址从此地址拿到的动态算力加成
                uint256 dynamicHashRate = _addressTotalStaticHashRateMap[s].mul(percent).div(100);
                // 动态算力累加
                totalDynamicHashRate = totalDynamicHashRate.add(dynamicHashRate);
            }
        }
        return totalDynamicHashRate;
    }

    // 设置是否锁定空间价格
    function setLockSpacePrice(bool lockSpacePrice) public onlyOwner {
        _lockSpacePrice = lockSpacePrice;
    }

    // 设置没上级时的总上级地址
    function setTotalParentAddress(address totalParentAddress) public onlyOwner {
        _totalParentAddress = totalParentAddress;
    }

    // 设置空间购买的收款地址
    function setReceiveAddress(address spaceReceiveAddress) public onlyOwner {
        _spaceReceiveAddress = spaceReceiveAddress;
    }

    // 从PancakeSwap获取APPLE价格[BUSD]
    function getPriceFromPancake() public view returns (uint256) {
        //        uint[] memory s = uniswapV2Router.getAmountsOut(uint256(10).power(_appleContractDecimal), path);
        //        return s[1];
        return _testApplePrice;
    }

    // 设置APPLE价格【一个APPLE多少BUSD】
    function setApplePrice(uint256 applePrice) public {
        _testApplePrice = applePrice;
    }

    // 空间价格[BUSD]
    function getSpacePrice() public view returns (uint256) {
        return _spacePrice;
    }

    // 销毁APPLE之后刷新空间价格
    function refreshSpacePrice(uint256 destroyApple) internal {
        // 已销毁APPLE数量增加
        _destroyedApple = _destroyedApple.add(destroyApple);
        // 锁定价格了，不再走这个逻辑了
        if (_lockSpacePrice) return;
        // 加多少次0.01BUSD
        uint256 time = _destroyedApple.div(uint256(300000).mul(uint256(10).power(_appleContractDecimal)));
        // 最高不超过0.4BUSD
        if (time > 10) time = 10;
        uint256 a = time.mul(uint256(10).power(_busdContractDecimal)).div(100);
        _spacePrice = a.add(uint256(3).mul(uint256(10).power(_busdContractDecimal)).div(10));
    }

    // 转账激活
    function activeAddress(address user, uint256 qty) public {
        // 激活门槛 转0.001起激活
        uint256 activeQty = uint256(10).power(_appleContractDecimal).div(1000);
        require(_parentAddressMap[user] == address(0), "user has parent");
        // 转账
        require(TransferHelper.safeTransferFrom(_appleContractAddress, msg.sender, user, qty), "asset insufficient");
        // 低于最低激活数量，结束
        if (qty < activeQty) return;
        if (_parentAddressMap[msg.sender] == address(0) && _totalParentAddress == address(0)) return;
        // 邀请地址没有上级，则把他的上级设置为总地址
        if (_parentAddressMap[msg.sender] == address(0)) {
            addUserSpecificGenSub(_totalParentAddress, 0, msg.sender);
            _parentAddressMap[msg.sender] = _totalParentAddress;
            addUserSubAddress(_totalParentAddress, msg.sender);
        }
        // 再绑定下级
        address parent = msg.sender;
        uint256 depth = 0;
        while (parent != address(0)) {
            addUserSpecificGenSub(parent, depth, user);
            addUserSubAddress(parent, user);
            parent = _parentAddressMap[parent];
            depth = depth.add(1);
        }
        _parentAddressMap[user] = msg.sender;
    }

    // 直推数量
    function activeCount() public view returns (uint256) {
        return getAddressSpecificSubCount(msg.sender, 0);
    }

    // 总销毁概览[总销毁数量 + 销毁记录条数]
    function destroySummary() public view returns (uint256, uint256) {
        return (_destroyedApple, destroyCount());
    }

    // 购买空间
    function purchaseSpace(uint256 qty) public {
        // 购买空间总价
        uint256 totalBusd = _spacePrice.mul(qty);
        // 转账
        require(TransferHelper.safeTransferFrom(_busdContractAddress, msg.sender, _spaceReceiveAddress, totalBusd), "asset insufficient");
        // 销毁APPLE
        uint256 destroyApple = qty.mul(uint256(10).power(_appleContractDecimal));
        require(TransferHelper.burn(_appleContractAddress, destroyApple), "burn apple fail");
        // 添加销毁记录
        addDestroyRecord(msg.sender, destroyApple);
        // 刷新APPLE价格
        refreshSpacePrice(destroyApple);
        // 记录此地址购买空间销毁的APPLE总量
        _addressBuySpaceDestroyMap[msg.sender].totalDestroy = _addressBuySpaceDestroyMap[msg.sender].totalDestroy.add(destroyApple);
        _addressBuySpaceDestroyMap[msg.sender].totalSpace = _addressBuySpaceDestroyMap[msg.sender].totalSpace.add(qty);
        // 当前区块高度
        uint256 currentBlockHeight = getBlockHeight();
        // 插入购买记录
        addSpaceBuyRecord(msg.sender, currentBlockHeight, qty);
        // 计算单位收益
        calculateUnitProfit(msg.sender, qty, currentBlockHeight);
    }

    // 购买空间之后计算单位算力收益
    function calculateUnitProfit(address user, uint256 qty, uint256 currentBlockHeight) internal {
        // 补齐之前没算的单位收益高度
        if (_netTotalStaticHashRate > 0 && currentBlockHeight >= 1 && _lastCalculateBlockHeight < currentBlockHeight.sub(1)) {
            for (uint256 i = _lastCalculateBlockHeight.add(1); i < currentBlockHeight; i++) {
                _staticUintProfitMap[i] = calculateProfitPerUnit(i, TYPE_STATIC);
                _dynamicUintProfitMap[i] = calculateProfitPerUnit(i, TYPE_DYNAMIC);
            }
        }
        // 此地址的总静态算力刷新
        _addressTotalStaticHashRateMap[user] = _addressTotalStaticHashRateMap[user].add(qty);
        // 此地址在此高度的实时算力
        setAddressStaticHashRateAtHeight(user, currentBlockHeight, _addressTotalStaticHashRateMap[user]);
        // 刷新他上级地址的动态算力 和 全网的总动态算力
        refreshDynamicHashRateByBuy(user, currentBlockHeight);
        // 刷新全网的总静态算力
        _netTotalStaticHashRate = _netTotalStaticHashRate.add(qty);
        // 当前高度也重新计算单位算力产出
        _staticUintProfitMap[currentBlockHeight] = calculateProfitPerUnit(currentBlockHeight, TYPE_STATIC);
        _dynamicUintProfitMap[currentBlockHeight] = calculateProfitPerUnit(currentBlockHeight, TYPE_DYNAMIC);
        // 计算上次计算到的区块高度
        _lastCalculateBlockHeight = currentBlockHeight;
    }

    // 同步高度的单位收益，防止高度差太大用户操作失败
    function syncHeight(uint256 heightNum) public {
        uint256 currentBlockHeight = getBlockHeight();
        if (_lastCalculateBlockHeight >= currentBlockHeight) return;
        uint256 limit = _lastCalculateBlockHeight.add(heightNum);
        if (limit > currentBlockHeight) limit = currentBlockHeight;
        for (uint256 i = _lastCalculateBlockHeight.add(1); i <= limit; i++) {
            if (_netTotalStaticHashRate > 0) {
                _staticUintProfitMap[i] = calculateProfitPerUnit(i, TYPE_STATIC);
            } else {
                _staticUintProfitMap[i] = 0;
            }

            if (_netTotalDynamicHashRate > 0) {
                _dynamicUintProfitMap[i] = calculateProfitPerUnit(i, TYPE_DYNAMIC);
            } else {
                _dynamicUintProfitMap[i] = 0;
            }
        }
        _lastCalculateBlockHeight = limit;
    }

    // 全网数据[全网静态算力， 个人静态算力，旗下所有地址动态算力]
    function getNetData() public view returns (uint256, uint256, uint256) {
        // 所有下级地址
        uint256 subCount = _teamAddressArray[msg.sender].length;
        // 所有下级地址算动态算力总和
        uint256 subDynamicHashRate = 0;
        for (uint256 i = 0; i < subCount; i++) {
            address s = _teamAddressArray[msg.sender][i].user;
            subDynamicHashRate = subDynamicHashRate.add(_addressTotalDynamicHashRateMap[s]);
        }
        return (_netTotalStaticHashRate, _addressTotalStaticHashRateMap[msg.sender], subDynamicHashRate);
    }

    // 个人数据[累计购买空间， 累计购买空间销毁APPLE， 已领取APPLE数量， 可领取APPLE数量]
    function getAddressData() public view returns (uint256, uint256, uint256, uint256) {
        uint256 p = getPendingProfit(msg.sender, getBlockHeight());
        return (_addressBuySpaceDestroyMap[msg.sender].totalSpace, _addressBuySpaceDestroyMap[msg.sender].totalDestroy,
        _addressTakedProfitMap[msg.sender], p);
    }

    // 领取收益
    function takeProfit() public {
        // 当前高度
        uint256 currentBlockHeight = getBlockHeight();
        // 可领取收益
        uint256 pendingProfit = getPendingProfit(msg.sender, currentBlockHeight);
        require(pendingProfit > 0, "avail less than 0");
        // APPLE价格
        uint256 applePrice = getPriceFromPancake();
        // 此地址的总静态算力
        uint256 addressTotalStaticHashRate = _addressTotalStaticHashRateMap[msg.sender];
        // 可领取APPLE数量
        uint256 takeAmount = pendingProfit;
        // 销毁的APPLE数量
        uint256 destroyAmount = 0;
        // 静态算力是否清零
        bool clearStaticHashRate = false;
        // 超3倍
        if (pendingProfit.mul(applePrice) >= addressTotalStaticHashRate.mul(3)) {
            clearStaticHashRate = true;
            // 3倍下的APPLE数量
            uint256 maxAppleAmount = addressTotalStaticHashRate.mul(3).div(applePrice);
            takeAmount = maxAppleAmount;
            destroyAmount = pendingProfit.sub(maxAppleAmount);
        }
        // 收益给地址
        require(TransferHelper.safeTransfer(_appleContractAddress, msg.sender, takeAmount), "asset insufficient1");
        // 已领取收益累加
        _addressTakedProfitMap[msg.sender] = _addressTakedProfitMap[msg.sender].add(takeAmount);
        // 添加领取记录
        addTakeRecord(msg.sender, takeAmount, applePrice);
        // 多余的APPLE销毁
        if (destroyAmount > 0) {
            require(TransferHelper.burn(_appleContractAddress, destroyAmount), "asset insufficient2");
            // 添加销毁记录
            addDestroyRecord(msg.sender, destroyAmount);
        }
        // 补齐之前没算的单位收益高度
        if (_netTotalStaticHashRate > 0 && currentBlockHeight >= 1 && _lastCalculateBlockHeight < currentBlockHeight.sub(1)) {
            for (uint256 i = _lastCalculateBlockHeight.add(1); i < currentBlockHeight; i++) {
                _staticUintProfitMap[i] = calculateProfitPerUnit(i, TYPE_STATIC);
                _dynamicUintProfitMap[i] = calculateProfitPerUnit(i, TYPE_DYNAMIC);
            }
        }
        // 扣减算力。刷新动态算力
        takeToSubHashRate(clearStaticHashRate, msg.sender, currentBlockHeight);
    }

    // 添加提取记录
    function addTakeRecord(address user, uint256 takeAmount, uint256 applePrice) internal {
        _extractRecord[user].push(TakeInfo({
            qty: takeAmount,
            price: applePrice,
            time: block.timestamp
        }));
    }

    // 领取收益之后扣减算力，以及他上级地址的动态算力刷新
    function takeToSubHashRate(bool clearStaticHashRate, address user, uint256 currentBlockHeight) internal {
        // 地址本次扣减的静态算力
        uint256 needSubHashRate = 0;
        uint256 all = _addressSpaceMap[user].length;
        // 静态算力清零
        if (clearStaticHashRate) {
            for (uint256 i = 0; i < all; i++) {
                if (_addressSpaceMap[user][i].realHashRate == 0) continue;
                // 总扣减算力
                needSubHashRate = needSubHashRate.add(_addressSpaceMap[user][i].realHashRate);
                _addressSpaceMap[user][i].lastTakeHeight = currentBlockHeight;
                _addressSpaceMap[user][i].realHashRate = 0;
            }
        } else {// 只降1/3算力
            for (uint256 i = 0; i < all; i++) {
                if (_addressSpaceMap[user][i].realHashRate == 0) continue;
                _addressSpaceMap[user][i].lastTakeHeight = currentBlockHeight;
                // 原来的算力
                uint256 originHashRate = _addressSpaceMap[user][i].realHashRate;
                // 领取一次收益，算力降1/3
                uint256 subHashRate = originHashRate.div(3);
                // 算力扣减
                _addressSpaceMap[user][i].realHashRate = originHashRate.sub(subHashRate);
                if (_addressSpaceMap[user][i].realHashRate < 1) {
                    _addressSpaceMap[user][i].realHashRate = 0;
                    subHashRate = originHashRate;
                }
                // 总扣减算力
                needSubHashRate = needSubHashRate.add(subHashRate);
            }
        }
        // 全网总静态算力扣减
        _netTotalStaticHashRate = _netTotalStaticHashRate.sub(needSubHashRate);
        // 地址的总静态算力扣减
        _addressTotalStaticHashRateMap[user] = _addressTotalStaticHashRateMap[user].sub(needSubHashRate);
        // 此地址在此高度的实时算力
        setAddressStaticHashRateAtHeight(user, currentBlockHeight, _addressTotalStaticHashRateMap[user]);
        // 刷新他上级地址的动态算力 和 全网的总动态算力
        refreshDynamicHashRateByBuy(user, currentBlockHeight);
        // 当前高度也重新计算单位算力产出
        _staticUintProfitMap[currentBlockHeight] = calculateProfitPerUnit(currentBlockHeight, TYPE_STATIC);
        _dynamicUintProfitMap[currentBlockHeight] = calculateProfitPerUnit(currentBlockHeight, TYPE_DYNAMIC);
        // 计算上次计算到的区块高度
        _lastCalculateBlockHeight = currentBlockHeight;
    }

    function getStaticUnitProfitByHeight(uint256 blockHeight) public view returns (uint256) {
        return _staticUintProfitMap[blockHeight];
    }

    function getDynamicUnitProfitByHeight(uint256 blockHeight) public view returns (uint256) {
        return _dynamicUintProfitMap[blockHeight];
    }

    // 领取记录条数
    function takeCount() public view returns (uint256) {
        return _extractRecord[msg.sender].length;
    }

    // 领取记录
    function takeRecord(uint256 pageNum, uint256[] memory input) public view returns (uint256[] memory) {
        uint256 start = pageNum.sub(1).mul(20);
        uint256 count = input.length.div(3);
        uint256 total = _extractRecord[msg.sender].length;
        for (uint256 i = 0; i < count; i++) {
            if (start.add(i) >= total) break;
            input[i.mul(3)] = _extractRecord[msg.sender][start.add(i)].qty;
            input[i.mul(3).add(1)] = _extractRecord[msg.sender][start.add(i)].price;
            input[i.mul(3).add(2)] = _extractRecord[msg.sender][start.add(i)].time;
        }
        return input;
    }

    // 设置地址在指定高度的静态算力
    function setAddressStaticHashRateAtHeight(address user, uint256 height, uint256 hash) internal {
        _addressHeightStaticHashRateMap[user][height].hash = hash;
        _addressHeightStaticHashRateMap[user][height].record = true;
    }

    // 设置地址在指定高度的动态算力
    function setAddressDynamicHashRateAtHeight(address user, uint256 height, uint256 hash) internal {
        _addressHeightDynamicHashRateMap[user][height].hash = hash;
        _addressHeightDynamicHashRateMap[user][height].record = true;
    }

    // 地址的指定代数的子地址个数
    function getAddressSpecificSubCount(address user, uint256 i) public view returns (uint256) {
        return _subAddressMap[user][i].length;
    }

    // 地址的第几个子地址
    function getAddressSubByIndex(address user, uint256 indexes) internal view returns (address, uint256) {
        address s = _teamAddressArray[user][indexes].user;
        uint256 time = _teamAddressArray[user][indexes].time;
        return (s, time);
    }

    // 给地址的第几代添加子地址
    function addUserSpecificGenSub(address user, uint256 gen, address sub) internal {
        _subAddressMap[user][gen].push(SubInfo({
            user: sub,
            time: block.timestamp
        }));
    }

    // 给地址添加下级
    function addUserSubAddress(address user, address sub) internal {
        _teamAddressArray[user].push(SubInfo({
            user: sub,
            time: block.timestamp
        }));
    }

    // 直推激活记录[分页每页20条，page从1开始]
    function activeRecord(uint256 pageNum, address[] memory input) public view returns (address[] memory) {
        uint256 start = pageNum.sub(1).mul(20);
        uint256 count = input.length.div(2);
        uint256 total = _subAddressMap[msg.sender][0].length;
        for (uint256 i = 0; i < count; i++) {
            if (start.add(i) >= total) break;
            address s = _subAddressMap[msg.sender][0][start.add(i)].user;
            uint256 time = _subAddressMap[msg.sender][0][start.add(i)].time;
            input[i.mul(2)] = s;
            input[i.mul(2).add(1)] = address(uint160(time));
        }
        return input;
    }

    // 直推地址数量
    function directCount() public view returns (uint256) {
        return _subAddressMap[msg.sender][0].length;
    }

    // 团队有效地址-直推地址+静态算力
    function directAddress(uint256 pageNum, address[] memory input) public view returns (address[] memory) {
        uint256 start = pageNum.sub(1).mul(20);
        uint256 count = input.length.div(3);
        uint256 total = _subAddressMap[msg.sender][0].length;
        for (uint256 i = 0; i < count; i++) {
            if (start.add(i) >= total) break;
            address s = _subAddressMap[msg.sender][0][start.add(i)].user;
            uint256 time = _subAddressMap[msg.sender][0][start.add(i)].time;
            input[i.mul(3)] = s;
            input[i.mul(3).add(1)] = address(uint160(_addressTotalStaticHashRateMap[s]));
            input[i.mul(3).add(2)] = address(uint160(time));
        }
        return input;
    }

    // 团队数量
    function teamCount() public view returns (uint256) {
        return _teamAddressArray[msg.sender].length;
    }

    // 团队地址地址-旗下所有地址+动态算力
    function teamAddress(uint256 pageNum, address[] memory input) public view returns (address[] memory) {
        uint256 start = (pageNum.sub(1)).mul(20);
        uint256 count = input.length.div(3);
        uint256 total = _teamAddressArray[msg.sender].length;
        for (uint256 i = 0; i < count; i++) {
            if (start.add(i) >= total) break;
            (address s, uint256 time) = getAddressSubByIndex(msg.sender, start.add(i));
            input[i.mul(3)] = s;
            input[i.mul(3).add(1)] = address(uint160(_addressTotalDynamicHashRateMap[s]));
            input[i.mul(3).add(2)] = address(uint160(time));
        }
        return input;
    }

    // 获取地址当前总动态算力
    function getAddressCurrentDynamicHashRate() public view returns (uint256) {
        return _addressTotalDynamicHashRateMap[msg.sender];
    }

    // 获取地址当前总静态态算力
    function getAddressCurrentStaticHashRate() public view returns (uint256) {
        return _addressTotalStaticHashRateMap[msg.sender];
    }

    // 添加空间购买记录
    function addSpaceBuyRecord(address user, uint256 blockHeight, uint256 qty) internal {
        _addressSpaceMap[user].push(SpaceInfo({
            time: block.timestamp,
            buyHeight: blockHeight,
            spaceAmount: qty,
            lastTakeHeight: blockHeight,
            realHashRate: qty
        }));
    }

    // 购买空间记录
    function purchaseRecord() public view returns (SpaceInfo[] memory) {
        return _addressSpaceMap[msg.sender];
    }

    // 地址计算收益时的起始高度
    function getStartCalculateProfitBlockHeight(address user) public view returns (uint256) {
        uint256 all = _addressSpaceMap[user].length;
        uint256 startBlockHeight = uint256(10).power(16);
        for (uint256 i = 0; i < all; i++) {
            if (_addressSpaceMap[user][i].realHashRate <= 0) continue;
            if (_addressSpaceMap[user][i].lastTakeHeight >= startBlockHeight) continue;
            startBlockHeight = _addressSpaceMap[user][i].lastTakeHeight;
        }
        return startBlockHeight;
    }

    // 当前区块高度
    function getBlockHeight() public view returns (uint256) {
        return block.timestamp.sub(_startMineTime).div(600);
    }

    // 根据区块高度得到产出量
    function getTotalGenByHeight(uint256 blockHeight) public view returns (uint256) {
        uint256 d = blockHeight.div(90);
        if (d > 10) d = 10;
        return uint256(5200).sub(d.mul(310)).power(_appleContractDecimal);
    }

    // 此高度单位质押应该拿到的收益
    function calculateProfitPerUnit(uint256 blockHeight, uint256 t) internal view returns (uint256) {
        uint256 blockTotalCoin = getTotalGenByHeight(blockHeight);
        uint256 coinNumber = 0;
        if (t == TYPE_DYNAMIC) {
            if (_netTotalStaticHashRate <= 0) return 0;
            coinNumber = blockTotalCoin.mul(40).div(100);
            return coinNumber.div(_netTotalStaticHashRate);
        } else {
            if (_netTotalDynamicHashRate <= 0) return 0;
            coinNumber = blockTotalCoin.mul(60).div(100);
            return coinNumber.div(_netTotalDynamicHashRate);
        }
    }

    // 可领取收益
    function getPendingProfit(address user, uint256 currentBlockHeight) internal view returns (uint256) {
        // 开始计算收益高度
        uint256 startBlock = getStartCalculateProfitBlockHeight(user);
        // 总静态算力收益
        uint256 tS = 0;
        // 总动态算力收益
        uint256 tD = 0;
        if (startBlock >= currentBlockHeight) {
            return 0;
        }
        // 此高度的静态算力
        uint256 s = _addressHeightStaticHashRateMap[user][startBlock].hash;
        // 此高度的动态算力
        uint256 d = _addressHeightDynamicHashRateMap[user][startBlock].hash;
        // 从最低的有算力的高度开始计算收益【静态+动态】
        for (uint256 i = startBlock; i < currentBlockHeight; i++) {
            // 这个高度确实记录了静态算力，直接用
            if (_addressHeightStaticHashRateMap[user][i].record) {
                s = _addressHeightStaticHashRateMap[user][i].hash;
            }
            // 如果没有，则沿用前一次的，因为没有静态算力变动
            tS = tS.add(_staticUintProfitMap[i].mul(s));

            // 这个高度确实记录了静态算力，直接用
            if (_addressHeightDynamicHashRateMap[user][i].record) {
                d = _addressHeightDynamicHashRateMap[user][i].hash;
            }
            // 如果没有，则沿用前一次的，因为没有静态算力变动
            tD = tD.add(_dynamicUintProfitMap[i].mul(d));
        }
        return tS.add(tD);
    }

    function addDestroyRecord(address user, uint256 qty) internal {
        _destroyRecord.push(DestroyInfo({
            user: user,
            time: block.timestamp,
            qty: qty
        }));
    }

    function destroyCount() public view returns (uint256) {
        return _destroyRecord.length;
    }

    // 销毁记录
    function destroyRecord(uint256 pageNum, address[] memory input) public view returns (address[] memory) {
        uint256 start = pageNum.sub(1).mul(20);
        uint256 count = input.length.div(3);
        uint256 total = _destroyRecord.length;
        for (uint256 i = 0; i < count; i++) {
            if (start.add(i) >= total) break;
            input[i.mul(3)] = _destroyRecord[start.add(i)].user;
            input[i.mul(3).add(1)] = address(uint160(_destroyRecord[start.add(i)].time));
            input[i.mul(3).add(2)] = address(uint160(_destroyRecord[start.add(i)].qty));
        }
        return input;
    }
}