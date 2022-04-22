// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../Ownable.sol";

contract SharedPlan is Ownable {

    IERC20 public QSQToken = IERC20(0x2614F43e7DBdbC20d58180417eeD62F603aBF516);
    IERC20 public usdtToken = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    mapping (uint8 => uint256) comboMap;    // 套餐组合

    address platformAddress34 = 0x9AEA43C2F194B60691c43E0532fd5E51492870B3;
    address platformAddress46 = 0x2d702aBeD72fD06Fb266966247c850259Bdcee53;

    address public usdtAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address public QSQAddress = 0x2614F43e7DBdbC20d58180417eeD62F603aBF516;
    // IPancakeRouter02 _router = IPancakeRouter02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E)); // 正式
    IPancakeRouter02 _router = IPancakeRouter02(address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3));   // 测试网
    address public swapPairU = IPancakeFactory(_router.factory()).getPair(QSQAddress, usdtAddress); // get LP address
    IPancakePair public pancakePair = IPancakePair(swapPairU); 
    IERC20 lpAToken = IERC20(swapPairU);

    struct UserInfo {
        uint256 level;         // 用户级别
        uint256 lpLockAmount;  // LP锁仓总量
        uint256 lpReceived;    // 已领取数量
        uint256 lpLockTime;    // lp锁仓时间

        uint256 qsqAmount;      // qsq 累计收益
        uint256 receivedQSQAmount;  // qsq 已领取
    }

    mapping (address => UserInfo) userinfoMap;

    function setCombo (uint8 _key, uint256 _value) public onlyOwner {
        require(_value >= 0, "SetCombo: _value error");
        comboMap[_key] = _value * 10 ** 18;
    }

    // 购买套餐
    function buyIdentity (uint8 _key) public {
        uint256 _amount = comboMap[_key];
        require(usdtToken.balanceOf(msg.sender) >= _amount && _amount > 0, "BuyIdentity: _amount error");

        UserInfo memory userinfo = userinfoMap[msg.sender];
        require(userinfo.level == 0, "BuyIdentity: Can only be purchased once ");

        uint256 _lockTime = block.timestamp;
        // usdtToken.transferFrom(msg.sender, address(this), (_amount * 86)/100);

        // 34% 给平台
        usdtToken.transferFrom(msg.sender, platformAddress34, (_amount * 34)/100);
        // 19.8% 组LP 给用户锁仓
        uint256 addLPUsdt = (((_amount * 198)/1000) * 5 ) / 10;
        usdtToken.transferFrom(msg.sender, address(this), addLPUsdt);
        swapTokensForU(addLPUsdt, address(this));
        QSQToken.approve(address(_router), getTokenAmount(addLPUsdt));
        usdtToken.approve(address(_router), addLPUsdt);
        (uint256 amountA, uint256 amountB, uint256 liquidity) = _router.addLiquidity(
            QSQAddress, usdtAddress, getTokenAmount(addLPUsdt), addLPUsdt,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            // owner(),
            _lockTime
        );
        
        userinfo.level = _key;
        userinfo.lpLockAmount = liquidity;
        userinfo.lpLockTime = _lockTime;
        userinfoMap[msg.sender] = userinfo;
        // 46.2 兑换等值A币
        swapTokensForU((_amount * 462)/1000, platformAddress46);
    }

    function withdrawQSQ () public {
        UserInfo memory userinfo = userinfoMap[msg.sender];
        uint256 _transfer = userinfo.qsqAmount - userinfo.receivedQSQAmount;
        QSQToken.transfer(msg.sender, _transfer);
        userinfo.receivedQSQAmount += _transfer;
        userinfoMap[msg.sender] = userinfo;
    }

    function getTokenAmount(uint256 _usdtAmount) public view returns (uint256 oniAmount) {
        address token0 = pancakePair.token0();
        (uint112 _token0Amount, uint112 _token1Amount, uint32 blockTimestampLast) = pancakePair.getReserves();

        if (token0 == QSQAddress) {
            oniAmount = (_token0Amount * _usdtAmount/_token1Amount);
        } else {
            oniAmount = (_token1Amount * _usdtAmount/_token0Amount);
        }
    }

    function swapTokensForU(uint256 tokenAmount, address _to) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = QSQAddress;

        usdtToken.approve(address(_router), tokenAmount);

        // make the swap
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            _to,
            block.timestamp
        );
    }

    uint112 releaseAll = 40;    // 释放总次数
    
    function withdrawLP() public {
        UserInfo memory userinfo = userinfoMap[msg.sender];
        uint256 _release = (block.timestamp - userinfo.lpLockTime) / 7 days;
        if (_release > 40) {
            _release = 40;
        }
        uint256 _releaseAmount = ((userinfo.lpLockAmount * 25 * _release) / 1000) - userinfo.lpReceived;
        require(userinfo.lpLockAmount > 0 && userinfo.lpLockAmount > userinfo.lpReceived && _releaseAmount > 0, "withdrawLP: No lock-up quantity");
        
        if (_release == 40) {
            _releaseAmount = userinfo.lpLockAmount - userinfo.lpReceived;
        }
        userinfo.lpReceived += _releaseAmount;
        lpAToken.transfer(msg.sender, _releaseAmount);
        userinfoMap[msg.sender] = userinfo;
    }

    

    function getUserInfo() public view returns(uint256 _level, uint256 _lpLockAmount, uint256 _lpReceived, uint256 _lpLockTime) {
        UserInfo memory userinfo = userinfoMap[msg.sender];
        _level = userinfo.level;                // 用户级别
        _lpLockAmount = userinfo.lpLockAmount;  // LP锁仓总量
        _lpReceived = userinfo.lpReceived;      // 已领取数量
        _lpLockTime = userinfo.lpLockTime;      // lp锁仓时间
    }

    function getUserInfoOther(address _address) public view returns(uint256 _level, uint256 _lpLockAmount, uint256 _lpReceived, uint256 _lpLockTime) {
        UserInfo memory userinfo = userinfoMap[_address];
        _level = userinfo.level;                // 用户级别
        _lpLockAmount = userinfo.lpLockAmount;  // LP锁仓总量
        _lpReceived = userinfo.lpReceived;      // 已领取数量
        _lpLockTime = userinfo.lpLockTime;      // lp锁仓时间
    }

    function testUpdateLockTime(uint256 _lpLockTime, address _address) public onlyOwner {
        UserInfo memory userinfo = userinfoMap[_address];
        userinfo.lpLockTime = _lpLockTime;      // lp锁仓时间
        userinfoMap[msg.sender] = userinfo;
    }

    function transferToken(address _token,address _address) public onlyOwner {
        IERC20(_token).transfer(_address, IERC20(_token).balanceOf(address(this)));
    }
}



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