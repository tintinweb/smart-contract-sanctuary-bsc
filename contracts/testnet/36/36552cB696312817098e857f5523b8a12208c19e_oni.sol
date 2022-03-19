// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../Ownable.sol";

interface IPancakeRouter01 {
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
}

interface IPancakeRouter02 is IPancakeRouter01 {
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

interface IPancakeFactory {
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

contract oni is Ownable {

    IERC20 public usdtToken;
    IERC20 public oniToken;
    

    constructor (IERC20 _usdtToken, IERC20 _oniToken, address _usdtAddress, address _oniAddress) public {
        usdtToken = _usdtToken;
        oniToken = _oniToken;
        usdtAddress = _usdtAddress;
        oniAddress = _oniAddress;
    }
    
    

    address platformAddress = 0xFF3fd35480024D0134D4Dc1FCC67F158765DB998;

    struct UserInfo {
        uint8 rank;     //  用户等级
        address parentAddress; // 推荐人地址
        bool upgradeReminder;   // 升级提醒
        uint8 rankReminder;     // 提醒等级
    }

    mapping (address => uint8) recommends;      // 推荐数量

    mapping (address => UserInfo) userRaise;    // 记录用户关系

    mapping (address => uint256) personalGains; // 自身利益

    mapping (address => uint256) oniIDOAmounts;

    event SetRank(address indexed user, address _address, uint8 _rank);

    function getUserInfo (address _address) public view returns (uint8 _rank, address _parentAddress, bool _upgradeReminder, uint8 _rankReminder, uint8 _recommendNumber, uint256 _personalGain, uint256 _oniAmount) {
        _rank = userRaise[_address].rank;
        _parentAddress = userRaise[_address].parentAddress;
        _upgradeReminder = userRaise[_address].upgradeReminder;
        _rankReminder = userRaise[_address].rankReminder;
        _recommendNumber = recommends[_address];
        _personalGain = personalGains[_address];
        _oniAmount = oniIDOAmounts[_address];
    }

    function setRank(address _address, uint8 _rank) public onlyOwner {
        UserInfo memory userinfo = userRaise[_address];
        userinfo.rank = _rank;
        userRaise[_address] = userinfo;
        emit SetRank(msg.sender, _address, _rank);
    }

    address public usdtAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address public oniAddress = 0xB61313e8039FdDdfd529E78F676bC17EefD14FC7;
    // IPancakeRouter02 _router = IPancakeRouter02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E)); // 正式
    IPancakeRouter02 _router = IPancakeRouter02(address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3));   // 测试网
    address public swapPairU = IPancakeFactory(_router.factory()).getPair(oniAddress, usdtAddress); // get LP address
    IPancakePair public pancakePair = IPancakePair(swapPairU); 

    function getLPToken0Amount() public view returns (uint256 token0Amount, uint256 token1Amount, uint256 oniAmount) {
        address token0 = pancakePair.token0();
        (uint112 _token0Amount, uint112 _token1Amount, uint32 blockTimestampLast) = pancakePair.getReserves();

        if (token0 == oniAddress) {
            oniAmount = (_token0Amount/_token1Amount);
        } else {
            oniAmount = (_token1Amount/_token0Amount);
        }

        token0Amount = _token0Amount;
        token1Amount = _token1Amount;
    }

    function getTokenAmount(uint256 _usdtAmount) public view returns (uint256 oniAmount) {
        address token0 = pancakePair.token0();
        (uint112 _token0Amount, uint112 _token1Amount, uint32 blockTimestampLast) = pancakePair.getReserves();

        if (token0 == oniAddress) {
            oniAmount = (_token0Amount * _usdtAmount/_token1Amount);
        } else {
            oniAmount = (_token1Amount * _usdtAmount/_token0Amount);
        }
    }


    function participate (address _parent) public {
        uint256 amount = 1 * 10**18;
        require(usdtToken.balanceOf(msg.sender) >= amount, "Insufficient usdt balance");

        UserInfo memory userinfo = userRaise[msg.sender];

        address token0 = pancakePair.token0();

        // 拨给上一级 100U
        if (userinfo.rank == 0) {
            UserInfo memory parentUserinfo = userRaise[_parent];
            // 地址不能为空
            require(_parent != address(0x0000000000000000000000000000000000000000), "The referrer's address is invalid");
            // 上级必须已激活
            require(parentUserinfo.rank > 0, "The referrer's address is invalid");
            userinfo.parentAddress = _parent;
            // 推荐人不能是自己
            require(address(msg.sender) != _parent, "Participate: The recommender cannot be yourself");
            // 升1级. 
            require(recommends[msg.sender] == 0, "Unable to establish relationship");

            // 增加用户推荐人数量
            recommends[_parent] += 1;
            // 给推荐人发放奖励
            usdtToken.transferFrom(msg.sender, _parent, (amount * 5)/10);
            personalGains[_parent] += (amount * 5)/10;

            (uint256 token0Amount, uint256 token1Amount, uint256 blockTimestampLast) = pancakePair.getReserves();
            // 转给底池 20%
            usdtToken.transferFrom(msg.sender, swapPairU, (amount * 2)/10);

            // 20%U的代币给用户自己
            uint256 _oniAmount = getTokenAmount((amount * 2)/10);
            oniToken.transfer(msg.sender, _oniAmount);
            oniIDOAmounts[msg.sender] = _oniAmount;

            // 30% 组LP
            uint256 uamountAll = (amount * 3)/10;
            // 获得代币兑换USDT的数量。通过代币与U组合添加进入流动池
            usdtToken.transferFrom(msg.sender, address(this), uamountAll);

            oniToken.approve(address(_router), getTokenAmount((amount * 3)/10));
            usdtToken.approve(address(_router), uamountAll);

            // add the liquidity
            _router.addLiquidity(
                oniAddress,
                usdtAddress,
                getTokenAmount((amount * 3)/10),
                uamountAll,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                platformAddress,
                // owner(),
                block.timestamp
            );
        } else {
            // 判断直推数量是否大于等于3人
            require(recommends[msg.sender] >= 3, "The number of referrals is not up to the standard");
            uint256 i = 0;
            address superiorAddress = userinfo.parentAddress;
            // 寻找推荐人,发放奖励
            while (true) {
                ++i;
                UserInfo memory _parentUserinfo = userRaise[superiorAddress];
                
                if (superiorAddress == address(0x0000000000000000000000000000000000000000)) {
                    usdtToken.transferFrom(msg.sender, platformAddress, (amount * 5)/10);
                    break;
                }

                if (i < (userinfo.rank +1)) {
                    superiorAddress = _parentUserinfo.parentAddress;
                    continue;
                }

                if (_parentUserinfo.rank < (userinfo.rank + 1) && i == (userinfo.rank + 1)) { // 触发等级提醒
                    _parentUserinfo.upgradeReminder = true;
                    _parentUserinfo.rankReminder = userinfo.rank + 1;
                    userRaise[superiorAddress] = _parentUserinfo;

                    superiorAddress = _parentUserinfo.parentAddress;
                    continue;
                }

                if (_parentUserinfo.rank >= (userinfo.rank + 1)) {
                    // 发放奖励
                    usdtToken.transferFrom(msg.sender, superiorAddress, (amount * 5)/10);
                    personalGains[superiorAddress] = (amount * 5)/10;
                    break;
                }
                
                superiorAddress = _parentUserinfo.parentAddress;
            }
            
            usdtToken.transferFrom(msg.sender, swapPairU, (amount * 5)/10);
        }

        // 用户升级
        userinfo.rank += 1;
        userinfo.upgradeReminder = false;
        userRaise[msg.sender] = userinfo;
    }
}