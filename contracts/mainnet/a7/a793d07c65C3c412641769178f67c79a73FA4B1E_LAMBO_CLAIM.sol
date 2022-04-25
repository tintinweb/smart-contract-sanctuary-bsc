/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: Unlicensed
// LAMBO PROTOCOL COPYRIGHT (C) 2022
pragma solidity ^0.8.0;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

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

interface IPancakeSwapPair {
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

interface IPancakeSwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

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

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IPancakeSwapFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

contract Ownable {
    address private _owner;
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface _LAMBO_CLAIM {
    function setLamboData(uint256 initBlock) external;

    function addFee(uint256 epoch, uint256 gon) external;

    function setMin(
        uint256 epoch,
        address _address1,
        uint256 gon1,
        address _address2,
        uint256 gon2
    ) external;

    function getLastRewardEpoch() external view returns (uint256);

    function swapReward() external;
}

interface _LAMBO {
    function getGonsPerFragment() external view returns (uint256);
}

contract LAMBO_CLAIM is Ownable, _LAMBO_CLAIM {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    uint256 internal constant DECIMALS = 10;
    uint256 constant MAX_UINT256 = ~uint256(0);
    uint8 constant RATE_DECIMALS = 7;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 10**6 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    address SHIB = 0x2859e4544C4bB03966803b044A93563Bd2D0DD4D;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IERC20 SHIBContract = IERC20(SHIB);
    uint256 public _initBlock;
    //uint256 public numberOfBlocksPerRewardsCycle = 86400; //3 days
    uint256 public numberOfBlocksPerRewardsCycle = 200; //10 minutes
    uint256 public lastRewardEpoch = 0;
    IPancakeSwapRouter public router;
    mapping(uint256 => uint256) private _BNBRewards;
    mapping(uint256 => uint256) private _SHIBRewards;
    mapping(address => uint256) private _lastRewardEpoch;
    mapping(address => mapping(uint256 => uint256)) private _lastBalance;
    mapping(address => mapping(uint256 => bool)) private _balanceFluctuations;
    mapping(address => mapping(uint256 => uint256)) private _minBalance;
    mapping(uint256 => uint256) private totalAutoBNBAndSHIB;

    uint256 public constant autoBNBFee = 25;
    uint256 public constant autoSHIBFee = 25;

    _LAMBO lamboContract;

    modifier onlyLamboContract() {
        require(msg.sender == address(lamboContract), "Only lambo contract");
        _;
    }

    modifier lamboContractOrAdmin() {
        require(
            msg.sender == address(lamboContract) || isOwner(),
            "Only lambo contract and Owner"
        );
        _;
    }

    constructor() Ownable() {
        //0xD99D1c33F9fC3444f8101754aBC46c52416550D1 testnet router
        //0x10ED43C718714eb63d5aA57B78B54704E256024E bsc router
        router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }

    function setLamboContract(address _contract) external onlyOwner {
        require(_contract != address(0x0));
        lamboContract = _LAMBO(_contract);
    }

    function getLastRewardEpoch() external view override returns (uint256) {
        return lastRewardEpoch;
    }

    function getLamboContract() external view returns (address) {
        return address(lamboContract);
    }

    function getTotalAutoBNBAndSHIB(uint256 epoch)
        external
        view
        returns (uint256)
    {
        return totalAutoBNBAndSHIB[epoch];
    }

    function swapReward() external override {
        if (currentRewardsEpoch() > lastRewardEpoch + 1) {
            uint256 epoch = lastRewardEpoch + 1;
            uint256 a = totalAutoBNBAndSHIB[epoch];

            if (a > 0) {
                uint256 _totalBnb = sellToken(a);
                uint256 _a1 = _totalBnb.mul(autoSHIBFee).div(
                    autoSHIBFee.add(autoBNBFee)
                );
                uint256 amountBNB = _totalBnb.sub(_a1);
                uint256 amountSHIB = 0;
                if (_a1 > 0) {
                    amountSHIB = buySHIB(_a1);
                }
                _BNBRewards[epoch] = amountBNB;
                _SHIBRewards[epoch] = amountSHIB;
            }
            lastRewardEpoch = epoch;
        }
    }

    function setLamboData(uint256 initBlock)
        external
        override
        onlyLamboContract
    {
        _initBlock = initBlock;
    }

    function addFee(uint256 epoch, uint256 gon)
        external
        override
        onlyLamboContract
    {
        require(epoch <= currentRewardsEpoch(), "Epoch has not yet happened");
        totalAutoBNBAndSHIB[epoch] = totalAutoBNBAndSHIB[epoch].add(gon);
    }

    function setMin(
        uint256 epoch,
        address _address1,
        uint256 gon1,
        address _address2,
        uint256 gon2
    ) external override onlyLamboContract {
        require(epoch <= currentRewardsEpoch(), "Epoch has not yet happened");
        if (!_balanceFluctuations[_address1][epoch]) {
            _balanceFluctuations[_address1][epoch] = true;
            _minBalance[_address1][epoch] = gon1;
        } else {
            if (gon1 < _minBalance[_address1][epoch]) {
                _minBalance[_address1][epoch] = gon1;
            }
        }
        if (!_balanceFluctuations[_address2][epoch]) {
            _balanceFluctuations[_address2][epoch] = true;
            _minBalance[_address2][epoch] = gon2;
        } else {
            if (gon2 < _minBalance[_address2][epoch]) {
                _minBalance[_address2][epoch] = gon2;
            }
        }

        _lastBalance[_address1][epoch] = gon1;
        _lastBalance[_address2][epoch] = gon2;
    }

    function currentRewardsEpoch() public view returns (uint256) {
        return
            1 +
            (block.number + 1 - _initBlock).div(numberOfBlocksPerRewardsCycle);
    }

    function lastTenRewardBalance(address _address)
        public
        view
        returns (uint256, uint256)
    {
        uint256 bnbBalance = 0;
        uint256 shibBalance = 0;
        (bnbBalance, shibBalance, , ) = _lastTenRewardBalance(_address);
        return (bnbBalance, shibBalance);
    }

    function _lastTenRewardBalance(address _address)
        internal
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 bnbBalance = 0;
        uint256 shibBalance = 0;
        uint256 lastBalance = _lastBalance[_address][
            _lastRewardEpoch[_address]
        ];
        uint256 fromEpoch = _lastRewardEpoch[_address] + 1;
        uint256 toEpoch = lastRewardEpoch;
        if (toEpoch - _lastRewardEpoch[_address] > 10) {
            toEpoch = _lastRewardEpoch[_address] + 10;
        }
        for (uint256 i = fromEpoch; i < toEpoch + 1; i++) {
            uint256 minBalance = lastBalance;
            if (_balanceFluctuations[_address][i]) {
                minBalance = _minBalance[_address][i];
                lastBalance = _lastBalance[_address][i];
            }
            if (_BNBRewards[i] > 0) {
                uint256 gonsPerBNB = TOTAL_GONS.div(_BNBRewards[i]);
                uint256 gonsPerSHIB = TOTAL_GONS.div(_SHIBRewards[i]);
                bnbBalance = bnbBalance.add(minBalance.div(gonsPerBNB));
                shibBalance = shibBalance.add(minBalance.div(gonsPerSHIB));
            }
        }
        return (bnbBalance, shibBalance, toEpoch, lastBalance);
    }

    function claimLastTenReward() public {
        (
            uint256 bnbBalance,
            uint256 shibBalance,
            uint256 toEpoch,
            uint256 lastBalance
        ) = _lastTenRewardBalance(msg.sender);
        if (!_balanceFluctuations[msg.sender][toEpoch]) {
            _lastBalance[msg.sender][toEpoch] = lastBalance;
        }
        _lastRewardEpoch[msg.sender] = toEpoch;
        if (bnbBalance > 0) {
            payable(msg.sender).transfer(bnbBalance);
        }
        if (shibBalance > 0) {
            SHIBContract.transfer(msg.sender, shibBalance);
        }
    }

    function getLastBalance(address _address, uint256 _epoch)
        public
        view
        returns (uint256)
    {
        uint256 _gonsPerFragment = lamboContract.getGonsPerFragment();
        return _lastBalance[_address][_epoch].div(_gonsPerFragment);
    }

    function getMinBalance(address _address, uint256 _epoch)
        public
        view
        returns (uint256)
    {
        uint256 _gonsPerFragment = lamboContract.getGonsPerFragment();
        return _minBalance[_address][_epoch].div(_gonsPerFragment);
    }

    function getBalanceFluctuations(address _address, uint256 _epoch)
        public
        view
        returns (bool)
    {
        return _balanceFluctuations[_address][_epoch];
    }

    function getLastRewardEpochOfAddress(address _address)
        public
        view
        returns (uint256)
    {
        return _lastRewardEpoch[_address];
    }

    function getBNBReward(uint256 epoch) public view returns (uint256) {
        return _BNBRewards[epoch];
    }

    function getSHIBReward(uint256 epoch) public view returns (uint256) {
        return _SHIBRewards[epoch];
    }

    function buySHIB(uint256 amount) internal returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = SHIB;
        uint256 SHIBBalanceBefore = SHIBContract.balanceOf(address(this));
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, address(this), block.timestamp);
        uint256 SHIBBalanceAfter = SHIBContract.balanceOf(address(this));
        return SHIBBalanceAfter.sub(SHIBBalanceBefore);
    }

    function sellToken(uint256 amountToSwap) internal returns (uint256) {
        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        return address(this).balance.sub(balanceBefore);
    }
}