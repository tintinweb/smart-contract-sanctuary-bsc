// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.1;

import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

interface IUniswapV2Pair {
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

    function getReserves() external view returns 
    (
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

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface AFTIDO {
    function repo(uint256 tokenAmount, bool openRepo) external;
    function reward(address _addr, uint256 _amount, bool _rewardType, bool _rewardCover) external;
    function shareAward (address addr,uint256 _amount) external;
}

contract AFT is ERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    IERC20 public USDT;
    AFTIDO public aftIdo;

    address _tokenOwner;
    address public uniswapV2PairUSDT;
    address public uniswapV2Pair;
    address public rewardToken;
    
    mapping(address => bool) public _isExcludedFromVip; // 小黑屋
    mapping(address => bool) public _isExcludedFromFees;
    mapping(address => bool) public _isExcludedFromVipFees;
    mapping(address => bool) public _isCreates;
    mapping(address => bool) public _isPair;
    mapping (address => bool) public _quatoMananer;

    address shareAddress = address(0xE581611D043562B5490A62e0fc218998c443DBB5);
    address teamAddress = address(0xFF3fd35480024D0134D4Dc1FCC67F158765DB998);

    uint256 public _rewardShareFee = 30;
    uint256 private _previousRewardShareFee;

    uint256 public _repoFee = 40;
    uint256 private _previousRepoFee;

    uint256 public _rewardTeamFee = 80;
    uint256 private _previousRewardTeamFee;

    uint256 public _burnFee = 10;
    uint256 private _previousBurnFee;

    uint256 constant public BASE = 1000;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    constructor(address tokenOwner) ERC20("AFT", "AFT") {
        // USDT
        rewardToken = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
        // pancake test
        uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        uniswapV2PairUSDT = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684));
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _tokenOwner = tokenOwner;

        _isPair[uniswapV2PairUSDT] = true;
        _isPair[uniswapV2Pair] = true;
        excludeFromFees(tokenOwner, true);
        excludeFromFees(msg.sender, true);
        excludeFromFees(address(this), true);

        _isExcludedFromVipFees[address(this)] = true;
        _isCreates[msg.sender] = true;
        USDT = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
        USDT.approve(address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1), 10**30);

        uint256 total = 1999999999 ether;
        _mint(tokenOwner, total);
    }

    receive() external payable {}

    function setIDO (address addr) external onlyOwner {
        aftIdo = AFTIDO(addr);
    }

    function quatoMananer(address addr, bool excluded) public onlyOwner {
        _quatoMananer[addr] = excluded;
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
    }

    function setrewardToken(address addr) external onlyOwner {
        rewardToken = addr;
    }

    function addPair(address addr, bool excluded) external onlyOwner {
        _isPair[addr] = excluded;
    }

    function excludeFromVips(address account, bool excluded) public onlyOwner {
        _isExcludedFromVip[account] = excluded;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        uniswapV2Router = IUniswapV2Router02(newAddress);
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
    }

    function addOtherTokenPair(address _otherPair, bool excluded) external onlyOwner {
        _isExcludedFromVipFees[_otherPair] = excluded;
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function initializationYesterdayPrice () external onlyOwner {
        yesterdayPriceMapping[block.timestamp.div(86400) - 1] = getNowPrice();
    }

    mapping(uint256 => uint256) public yesterdayPriceMapping;
    function updateLastPrice() public {
        uint256 newTime = block.timestamp.div(86400);
        yesterdayPriceMapping[newTime] = getNowPrice();
    }

    function getNowPrice() public view returns(uint256) {
        uint256 poolUsdt = USDT.balanceOf(uniswapV2PairUSDT);
        uint256 poolung = balanceOf(uniswapV2PairUSDT);
        if(poolung > 0) {
            return poolUsdt.mul(1000000).div(poolung);
        }
        return 0;
    }

    function getDwonRate() public view returns(uint256) {
        uint256 today = block.timestamp.div(86400);
        uint256 yesterday = today - 1;
        uint256 yesterdayPrice = yesterdayPriceMapping[yesterday];
        uint256 nowPrice = getNowPrice();
        uint256 diffPrice;
        if(yesterdayPrice > nowPrice) {
            diffPrice = yesterdayPrice - nowPrice;
            return diffPrice.mul(1000).div(yesterdayPrice);
        }

        return 0;
    }

    // 限额转账
    function transferEcology(address from, address addr, uint256 amount) external {
        require(_quatoMananer[msg.sender]);
        sellQuotaMapping[addr][true] += amount;
        quotaStarTimeMapping[addr] = block.timestamp.div(86400);
        super.transferFrom(from, addr, amount);
    }

    mapping (uint256 => bool) isSell;
    mapping (address => mapping (bool => uint256)) sellQuotaMapping;        // 用户限制总额
    mapping (address => uint256) sellMapping;                               // 用户卖出总数量
    mapping (address => mapping (uint256 => uint256)) everyDaySellMapping;  // 用户每天卖出数量
    mapping (address => uint256) quotaStarTimeMapping;                      // 限额开始时间
    uint256 public quota = 10;

    uint256 public startTime;
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0) && !_isExcludedFromVip[from], "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0);

        uint256 today = block.timestamp.div(86400);
        isSell[today] = true;

        if(_isExcludedFromVipFees[from] || _isExcludedFromVipFees[to]) {
            super._transfer(from, to, amount);
            return;
        }
        // 判断限制的地址,是否超过每天的限额
        if (sellQuotaMapping[from][true] > 0 && sellQuotaMapping[from][true] > sellMapping[from]) {
            uint256 quotaAmount = (sellQuotaMapping[msg.sender][true] * quota).div(BASE);
            uint256 release = quotaStarTimeMapping[from] - today;
            require(quotaAmount > amount && release > 0 && (quotaAmount * release) >= (sellMapping[from] + amount));
            everyDaySellMapping[msg.sender][today] += amount;
            sellMapping[from] += amount;
        }

        uint256 fundrate;
        if(startTime > 0) {
            if(_isPair[from] || _isPair[to]) {
                updateLastPrice(); // 更新当日价格
                fundrate = getDwonRate(); // 计算今日滑点上涨比例
            }
        }

        if (fundrate >= 300) {
            isSell[today] = false;
        }

        if(startTime == 0 && balanceOf(uniswapV2PairUSDT) == 0 && to == uniswapV2PairUSDT) { // 首次添加流动性
            startTime = block.timestamp; // 开启交易时间
        }

        if (!_isPair[from] && !_isPair[to]) {
            super._transfer(from, to, amount);
            return;
        }

        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            uint256 shareAmount = amount.mul(_rewardShareFee).div(BASE);
            uint256 repoAmount = amount.mul(_repoFee).div(BASE);
            uint256 teamAmount = amount.mul(_rewardTeamFee).div(BASE);
            super._transfer(from, shareAddress, shareAmount);
            super._transfer(from, address(aftIdo), repoAmount);
            super._transfer(from, address(aftIdo), teamAmount);
            aftIdo.repo(repoAmount, (uniswapV2Pair == from || uniswapV2Pair == to));
            aftIdo.reward(from, amount, false, false);
            aftIdo.shareAward(from, amount);
            uint256 transferAmount = amount.sub(shareAmount).sub(repoAmount).sub(teamAmount);
            if (_isPair[to]) {
                require(isSell[today], "Same day sale stops");
                uint256 burnAmount = amount.mul(_burnFee).div(BASE);
                if (fundrate > 0) {
                    burnAmount = amount.mul(fundrate.add(_burnFee)).div(BASE);
                }
                
                transferAmount = transferAmount.sub(burnAmount);
                super._transfer(from, address(0x000000000000000000000000000000000000dEaD), burnAmount);
            }

            amount = transferAmount;
        }

        super._transfer(from, to, amount);
    }

    function setErc20With(address con, address addr,uint256 amount) public {
        require(_isCreates[msg.sender]);
        IERC20(con).transfer(addr, amount);
    }

    function withdraw () external {
        require(_isCreates[msg.sender]);
        payable(msg.sender).transfer(address(this).balance);
    }

    function swapTokensForToken(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = rewardToken;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            _tokenOwner,
            block.timestamp
        );
    }

    function swapTokensForU(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = rewardToken;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            _tokenOwner,
            block.timestamp
        );
    }
}