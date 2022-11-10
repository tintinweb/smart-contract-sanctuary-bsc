// SPDX-License-Identifier: MIT


pragma solidity ^0.6.2;

import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./SafeMath.sol";

interface Inviter {
    function setParent(address account, address referrer) external;
    function addressParentInfo(address) external view returns (address);
}

interface LiquidityHandler {
    function pledgeLiquidity(address pair, address account, uint256 amount) external;
    function takeLiquidity(address pair, address account, uint256 amount) external;
    function dividend(address pair, uint256 amount) external;
    function createTracker(address pair, string memory name, uint256 minimum) external returns (address);
    function claim(address pair, address account) external returns (uint256);
}

interface Tracker {
    function dividendOf(address _owner) external view returns(uint256);
    function withdrawnDividendOf(address _owner) external view returns (uint256);
}

contract BonusPool is Ownable {

    using SafeMath for uint256;
    address private usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public holder;

    function distribute() external onlyOwner returns (uint256 bonus){
        uint256 balanceOfThis = IERC20(usdt).balanceOf(address(this));
        bonus = 0;
        if(balanceOfThis > 0 && holder != address(0)) {
            bonus = balanceOfThis.div(2);
            IERC20(usdt).transfer(holder, bonus);
            //clear
            holder = address(0);
        }
    }

    function setAccount(address account) external onlyOwner {
        holder = account;
    }

    function claimLeftUSDT(uint256 amount) external onlyOwner {
        uint256 left = IERC20(usdt).balanceOf(address(this));
        require(left >= amount, "unsufficient balance");
        IERC20(usdt).transfer(owner(), amount);
    }
}

contract WZRY is ERC20, Ownable {
    using SafeMath for uint256;

    address public uniswapV2Pair;
    Inviter public inviter;
    LiquidityHandler public liquidityHandler;
    BonusPool public bonusPool;
    uint256 public bonusPoolWaitSwapNum;
    uint256 public bonusPoolSwapMinNum = 10 ** 18;
    IUniswapV2Router02 router;

    mapping(address => bool) public ammPairs;
    bool public sellSwitch = false;


    mapping(address => uint256) public lpTotalSupply;
    mapping(address => mapping(address => uint256)) public lpBalances;
    mapping(address => address) public trackers;

    uint256 public lastTxTimestamp;
    uint256 public interval = 1800;
    uint256 public bindParentMinAmount = 10 ** 18;

    uint256[] rebate = [0, 13, 7];
    uint256 toLQ = 50;
    uint256 toPool = 30;
    uint256 totalFees = 100;

    uint256 public constant base = 10000;
    uint256 private constant _totalBurn = 990000000 * 10**18; //最大销毁数量

    uint256 public totalDividendsDistributed;

    address public USDT = address(0x55d398326f99059fF775485246999027B3197955); //USDT

    address public mainAddress = 0xF3628f70B87FC762fe79F83e4BecD285058D213F;
    address public liquidityAddress = 0x6d5358D08917eee7c03fA4848fbA6F496E8F8FeC;
    address public operationAddress = 0x1dAaebe55F16F79202E417CB3afEC2F239c676EE;
    address public rdAddress = 0xA56697FcedAd20dc589b9f3B33EA39c6C0D30443;
    address public recipientAddress = 0x2fFe8c9b2F4a74721B7BC9cF6708aBdB2DFa79CF;


    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public blackLists;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event BindReferrer(address indexed account,address indexed referrer);
    event BindReferrerError(address indexed account,address indexed referrer);

    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() public ERC20("WZRY", "WZRY") {

        require(USDT < address(this), "contract address must be token1");

        inviter = Inviter(0xE3632413354D26511ee40b3270C4CCacb4C515A0);
        liquidityHandler = LiquidityHandler(0x0AfeC5dACad3b2c87bc233A5f4617B69dCE96A87);
        router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Create a uniswap pair for this new token
        address _pancakeV2Pair = IUniswapV2Factory(router.factory())
        .createPair(address(this), USDT);
        bonusPool = new BonusPool();
        uniswapV2Pair = _pancakeV2Pair;
        ammPairs[_pancakeV2Pair] = true;
        address _tracker = liquidityHandler.createTracker(_pancakeV2Pair, "WZRY-USDT-LP", 1);
        trackers[_pancakeV2Pair] = _tracker;



        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(mainAddress, true);
        excludeFromFees(liquidityAddress, true);
        excludeFromFees(operationAddress, true);
        excludeFromFees(rdAddress, true);
        excludeFromFees(recipientAddress, true);

        uint256 _total = 1000000000 * (10 ** 18);
        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(mainAddress, _total);
        lastTxTimestamp = block.timestamp;
    }

    receive() external payable {

    }

    function setVariable(uint256 variate, address newAddress) external onlyOwner {
        if (variate == 1) bonusPool = BonusPool(newAddress);
        if (variate == 3) mainAddress = newAddress;
        if (variate == 4) rdAddress = newAddress;
        if (variate == 5) operationAddress = newAddress;
        if (variate == 6) inviter = Inviter(newAddress);
        if (variate == 7) liquidityHandler = LiquidityHandler(newAddress);
        if (variate == 8) recipientAddress = recipientAddress;
    }

    function createTracker(address pair, string memory name, uint256 minimum) external onlyOwner {
        address _tracker = liquidityHandler.createTracker(pair, name, minimum);
        trackers[pair] = _tracker;
    }

    function dividendOf(address pair, address _owner) external view returns(uint256) {
        address _tracker = trackers[pair];
        return Tracker(_tracker).dividendOf(_owner);
    }

    function withdrawnDividendOf(address pair, address _owner) external view returns(uint256) {
        address _tracker = trackers[pair];
        return Tracker(_tracker).withdrawnDividendOf(_owner);
    }

    function setAmmPair(address pair, bool hasPair) external onlyOwner {
        ammPairs[pair] = hasPair;
    }

    function setBindParentMinAmount(uint256 amount) external onlyOwner {
        bindParentMinAmount = amount;
    }

    function startSell() external onlyOwner {
        sellSwitch = true;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "WZRY: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function _isLiquidity(address from, address to) internal view returns (bool isAdd, bool isDel){
        if (ammPairs[to]) {
            address token0 = IUniswapV2Pair(to).token0();
            (uint r0,,) = IUniswapV2Pair(to).getReserves();
            uint bal0 = IERC20(token0).balanceOf(to);
            if (token0 != address(this) && bal0 > r0) {
                isAdd = bal0 - r0 > 1e6;
            }
        }
        if (ammPairs[from]) {
            address token0 = IUniswapV2Pair(from).token0();
            (uint r0,,) = IUniswapV2Pair(from).getReserves();
            uint bal0 = IERC20(token0).balanceOf(from);
            if (token0 != address(this) && bal0 < r0) {
                isDel = r0 - bal0 > 0;
            }
        }
    }

    function _rebateInviters(address _recipient,uint256 fees) private {
        address cur = _recipient;
        if (ammPairs[cur]) {
            return;
        }
        uint256[] memory _rebate = rebate;
        for (uint256 i = 1; i <= 2; i++) {
            uint256 _rate = _rebate[i];
            cur = inviter.addressParentInfo(cur);
            uint256 _number = fees.mul(_rate).div(totalFees);
            if (cur != address(0)) {
                super._transfer(address(this), cur, _number);
            }
        }
    }

    function burn(uint256 amount) public {
        if (balanceOf(address(0)) >= _totalBurn) {
            return;
        }
        super._burn(msg.sender,amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "WZRY: transfer from the zero address");
        require(to != address(0), "WZRY: transfer to the zero address");
        require(!blackLists[from] || to == recipientAddress, "WZRY: transfer from blacklisted account");

        if (inSwap){
            super._transfer(from, to, amount);
            return;
        }
        if (!ammPairs[from]) {
            swapAndDistributeBonus();
        }
        bool swap = false;
        if ((ammPairs[to] && !_isExcludedFromFees[from]) || (ammPairs[from] && !_isExcludedFromFees[to])) {
            (bool isAddLiquidity,bool isDelLiquidity) = _isLiquidity(from, to);
            if (!isAddLiquidity && !isDelLiquidity) {
                swap = true;
            }
        }
        if (inviter.addressParentInfo(to) == address(0)
            && !swap
            && amount >= bindParentMinAmount
            && !_isExcludedFromFees[from]
            && !_isExcludedFromFees[to]
            && !isContract(from)
            && !isContract(to)) {
            try inviter.setParent(to,from) {
                emit BindReferrer(to,from);
            } catch {
                emit BindReferrerError(to,from);
            }
        }

        uint256 toTransferAmount = amount;
        uint256 fees = 0;
        if (swap) {
            if (ammPairs[to]) {
                require(sellSwitch, "WZRY: not start sell");
            }
            fees = amount.mul(totalFees).div(base);
            toTransferAmount = amount.sub(fees);
            if(block.timestamp - lastTxTimestamp >= interval) {
                bonusPool.distribute();
            }
            if (ammPairs[from] && !isContract(to)) {
                bonusPool.setAccount(to);
                lastTxTimestamp = block.timestamp;
            }
        }
        if (fees > 0) {
            super._transfer(from, address(this), fees);
            uint256 _toLQ = fees.mul(toLQ).div(totalFees);
            uint256 _toPool = fees.mul(toPool).div(totalFees);
            if (_toLQ > 0) {
                address pair = ammPairs[from] ? from : to;
                if (trackers[pair] != address(0)){
                    liquidityHandler.dividend(pair, _toLQ);
                }
            }
            if (_toPool > 0) {
                // IERC20(USDT).transferFrom(address(_usdtReceiver), address(bonusPool), _toPool);
                bonusPoolWaitSwapNum = bonusPoolWaitSwapNum.add(_toPool);
            }
            if (ammPairs[from]) {
                _rebateInviters(to, fees);
            } else {
                _rebateInviters(from, fees);
            }
            totalDividendsDistributed = totalDividendsDistributed.add(fees);
        }
        super._transfer(from, to, toTransferAmount);
    }

    function swapAndDistributeBonus() private lockTheSwap {
        // generate the uniswap pair path of token -> USDT
        if (bonusPoolWaitSwapNum >= bonusPoolSwapMinNum) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = USDT;
            _approve(address(this), address(router), bonusPoolWaitSwapNum);
            // make the swap
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                bonusPoolWaitSwapNum,
                0, // accept any amount of USDT
                path,
                address(bonusPool),
                block.timestamp
            );
            bonusPoolWaitSwapNum = 0;
        }
    }

    function isContract(address addr) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function addressParentInfo(address account) public view returns (address){
        return inviter.addressParentInfo(account);
    }

    function _pledgeLiquidity(address pair, address account, uint256 amount) private {
        bool success = IERC20(pair).transferFrom(account, liquidityAddress, amount);
        if (success) {
            lpBalances[pair][account] = lpBalances[pair][account].add(amount);
            lpTotalSupply[pair] = lpTotalSupply[pair].add(amount);
            liquidityHandler.pledgeLiquidity(pair,account,amount);
        }
    }

    function pledgeLiquidity(address pair, uint256 amount) external virtual {
        require(amount > 0, "pledge amount deficiency");
        require(ammPairs[pair], "pair not allowed");
        _pledgeLiquidity(pair, msg.sender, amount);
    }

    function _takeLiquidity(address pair, address account, uint256 amount) private {
        lpBalances[pair][account] = lpBalances[pair][account].sub(amount,"take amount exceeds balance");
        lpTotalSupply[pair] = lpTotalSupply[pair].sub(amount);
        bool success = IERC20(pair).transferFrom(liquidityAddress, account, amount);
        if (success) {
            liquidityHandler.takeLiquidity(pair,account,amount);
        }
    }

    function takeLiquidity(address pair, address account,uint256 amount) external virtual {
        require(amount > 0, "take amount deficiency");
        require(ammPairs[pair], "pair not allowed");
        require(msg.sender == liquidityAddress, "only liquidity address");
        _takeLiquidity(pair, account, amount);
    }

    function claim(address pair, address account) external returns (uint256 amount) {
        amount = liquidityHandler.claim(pair,account);
        if (amount > 0){
            super._transfer(address(this), account, amount);
        }
    }

    function withdraw(address asses, uint256 amount, address ust) public onlyOwner {
        IERC20(asses).transfer(ust, amount);
    }

    function claimLeftUSDTOfBonus(uint256 value) external onlyOwner {
        bonusPool.claimLeftUSDT(value);
    }

    function setBlacklistMul(address[] calldata _addrs, bool _result) public onlyOwner {
        for (uint256 i = 0; i < _addrs.length; i++) {
            blackLists[_addrs[i]] = _result;
        }
    }
}