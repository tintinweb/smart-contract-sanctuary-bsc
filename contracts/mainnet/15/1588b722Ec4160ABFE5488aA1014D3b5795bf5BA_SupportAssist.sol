/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    mapping(address => bool) private _adminList;

    event LogOwnerChanged(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
        _setAdminship(_msgSender(), true);
    }

    modifier onlyOwner() {
        require(Owner() == _msgSender(), "!owner");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin(), "!admin");
        _;
    }

    function isAdmin() public view virtual returns (bool) {
        return _adminList[_msgSender()];
    }

    function setAdminList(address newAdmin, bool _status)
        public
        virtual
        onlyOwner
    {
        _adminList[newAdmin] = _status;
    }

    function _setAdminship(address newAdmin, bool _status) internal virtual {
        _adminList[newAdmin] = _status;
    }

    function Owner() public view virtual returns (address) {
        return _owner;
    }

    function isOwner() public view virtual returns (bool) {
        return Owner() == _msgSender();
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "!address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit LogOwnerChanged(oldOwner, newOwner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function burn(uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface UserData {
    function getIdToAddress(uint256 _id) external view returns (address);

    function getInviter(address _account) external view returns (address);

    function getUID(address _account) external view returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function amountOf(address _account) external view returns (uint256);

    function totalAmount() external view returns (uint256);

    function getOrderAt(address _account, uint256 _i)
        external
        view
        returns (uint256[7] memory data);

    function getOrderList(
        address _account,
        uint256 _start,
        uint256 _size
    ) external view returns (uint256[8][] memory data);

    ////////////////////////////////////////////////////////////////////
    function getLeafsCount(address _account) external view returns (uint256);

    function getLeafsList(
        address _account,
        uint256 _start,
        uint256 _size
    ) external view returns (address[] memory data);

    /////////////////////////////////////////////////////////////////
    function _register(address _user, address inviter)
        external
        returns (uint256);

    function _create(
        address _account,
        uint256 _ftype,
        uint256 _amount,
        uint256 _power
    ) external returns (uint256);

    function _exit(address _account, uint256 _idx) external;

    function _speed(address _account, uint256 _speedtime) external;
}

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface LPRewardAssist {
    function executeReward(uint256 reward) external returns (uint256);

    function updateReward(address account) external returns (uint256);

    function getReward(address account) external returns (uint256);

    function earned(address account) external view returns (uint256);
}

contract SupportAssist is Ownable {
    IERC20 public constant USDT =
        IERC20(0x55d398326f99059fF775485246999027B3197955);
    IUniswapV2Router02 public immutable uniswapV2Router;
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    UserData public immutable uData;
    LPRewardAssist public lpReward;
    LPRewardAssist public lpRewardMint;

    uint256 public fundTokensAtAmount = 1e18;
    uint256 public fundTokensAmount = 0;
    bool private _funding = false;
    address public fund;

    struct ConfigData {
        uint256 cycle;
        uint256 speed;
        uint256 power;
    }
    ConfigData[2] public config;
    uint256[4] public ratio = [1000, 0, 500, 500];
    uint256[2] public fhratio = [50, 50];
    uint256[2] public exitratio = [50, 50];

    event Reg(address indexed user, address indexed _inviter, uint256 id);
    event Deposit(
        address indexed user,
        uint256 _ftype,
        uint256 _amountA,
        uint256 _amountU,
        uint256 _amountLp,
        uint256 _amountPow
    );
    event Exited(
        address indexed user,
        uint256 _id,
        uint256 _amountPow,
        uint256 _amountB,
        uint256 _feeB,
        uint256 _amountU,
        uint256 _feeU
    );
    event LPReward(
        address indexed user,
        uint256 _reward,
        uint256 _income,
        uint256 _lpreward,
        uint256 _burnreward
    );

    event SwapAndLiquify(
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1,
        uint256 liquidity
    );

    constructor(
        IERC20 tokena,
        IERC20 tokenb,
        address _lpRun,
        address _data
    ) {
        tokenA = tokena;
        tokenB = tokenb;
        uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        lpReward = LPRewardAssist(_lpRun);
        uData = UserData(_data);

        setAdminList(address(tokenb), true);
        setConfig(0, 180 days, 0, 3000);
        setConfig(1, 360 days, 8640, 7000);
    }

    function setConfig(
        uint256 _idx,
        uint256 _cycle,
        uint256 _speed,
        uint256 _power
    ) public onlyAdmin {
        require(_idx < config.length, "CONTRACT: invalid _idx");
        config[_idx].cycle = _cycle;
        config[_idx].speed = _speed;
        config[_idx].power = _power;
    }

    function setRatio(uint256 _idx, uint256 _ratio) public onlyAdmin {
        require(_idx < ratio.length, "CONTRACT: invalid _idx");
        ratio[_idx] = _ratio;
    }

    function setFHRatio(uint256 _idx, uint256 _ratio) public onlyAdmin {
        require(_idx < fhratio.length, "CONTRACT: invalid _idx");
        fhratio[_idx] = _ratio;
    }

    function setExitRatio(uint256 _idx, uint256 _ratio) public onlyAdmin {
        require(_idx < exitratio.length, "CONTRACT: invalid _idx");
        exitratio[_idx] = _ratio;
    }

    function setFund(address _fund) external onlyAdmin {
        fund = _fund;
    }

    function setFundAt(uint256 _amount) external onlyAdmin {
        fundTokensAtAmount = _amount;
    }

    function setLpReward(address _addr) external onlyAdmin {
        lpReward = LPRewardAssist(_addr);
    }

    function setLpRewardMint(address _addr) external onlyAdmin {
        lpRewardMint = LPRewardAssist(_addr);
    }

    function swapPrice(address _tk) public view returns (uint256) {
        uint256 amountIn = 1e18;
        uint256 price = 0;
        address[] memory path = new address[](2);
        path[0] = address(_tk);
        path[1] = address(USDT);

        try uniswapV2Router.getAmountsOut(amountIn, path) returns (
            uint256[] memory amounts
        ) {
            price = amounts[1];
        } catch {
            price = 0;
        }
        return price;
    }

    function setInviter(address _inviter) public {
        require(uData.getUID(_inviter) > 0, "invalid inviter");
        require(uData.getUID(_msgSender()) == 0, "already set inviter");

        uint256 id = uData._register(_msgSender(), _inviter);
        emit Reg(_msgSender(), _inviter, id);
    }

    function getUSDT(uint256 amount0) public view returns (uint256) {
        uint256 price = swapPrice(address(tokenB));
        return (price * amount0) / 1e18;
    }

    function deposit(uint256 _ftype, uint256 amount0) external {
        address _account = _msgSender();
        require(uData.getUID(_account) > 0, "invalid user");
        require(amount0 > 0, "Cannot stake 0");

        lpReward.updateReward(_account);
        if (address(lpRewardMint) != address(0)) {
            lpRewardMint.updateReward(_account);
        }

        uint256 amountU = getUSDT(amount0);

        tokenA.transferFrom(_msgSender(), address(this), amount0);
        USDT.transferFrom(_msgSender(), address(this), amountU);

        uint256 lp = addLiquidity(
            address(tokenB),
            address(USDT),
            amount0,
            amountU
        );

        uint256 power = (config[_ftype].power * lp) / 1000;
        uData._create(_account, _ftype, lp, power);

        address _inviter = uData.getInviter(_account);
        if (_inviter != address(0)) {
            uint256 _speedtime = ((amountU * 2) / 1e20) * config[_ftype].speed;
            if (_speedtime > 0) {
                uData._speed(_account, _speedtime);
            }
        }

        emit Deposit(_account, _ftype, amount0, amountU, lp, power);
    }

    function exit(uint256 _id) external {
        address _account = _msgSender();
        require(uData.getUID(_account) > 0, "invalid user");

        lpReward.updateReward(_account);
        if (address(lpRewardMint) != address(0)) {
            lpRewardMint.updateReward(_account);
        }

        uint256[7] memory info = uData.getOrderAt(_account, _id);
        require(info[3] == 1, "invalid status");

        uint256 _end = config[info[0]].cycle + info[5];
        require(_end < block.timestamp - info[4], "not reach time");

        uData._exit(_account, _id);

        uint256 lpAmount = info[1];
        (uint256 amountB, uint256 amountU) = uniswapV2Router.removeLiquidity(
            address(tokenB),
            address(USDT),
            lpAmount,
            0,
            0,
            address(this),
            block.timestamp
        );

        uint256 feeB = (amountB * exitratio[0]) / 1000;
        if (feeB > 0) {
            tokenB.burn(feeB);
        }
        tokenB.transfer(_account, amountB - feeB);

        uint256 feeU = (amountU * exitratio[1]) / 1000;
        if (feeU > 0) {
            USDT.transfer(fund, feeU);
        }
        USDT.transfer(_account, amountU - feeU);
        emit Exited(
            _account,
            _id,
            info[1],
            amountB - feeB,
            feeB,
            amountU - feeU,
            feeU
        );
    }

    function getReward(address _account) public {
        require(uData.getUID(_account) > 0, "invalid user");
        uint256 _reward = lpReward.getReward(_account);
        if (_reward > 0) {
            uint256 _lp = (_reward * fhratio[0]) / 1000;
            if (_lp > 0) {
                lpReward.executeReward(_lp);
            }

            uint256 _burn = (_reward * fhratio[1]) / 1000;
            if (_burn > 0) {
                tokenB.burn(_burn);
            }

            uint256 _income = _reward - _lp - _burn;
            tokenB.transfer(_account, _income);

            emit LPReward(_account, _reward, _income, _lp, _burn);
        }
    }

    function infos(address _account)
        external
        view
        returns (uint256[7] memory data)
    {
        data[0] = uData.getUID(_account);
        data[1] = uint256(uint160(uData.getInviter(_account)));
        data[2] = uData.getLeafsCount(_account);
        data[3] = uData.amountOf(_account);
        data[4] = uData.balanceOf(_account);
        data[5] = uData.totalSupply();
        data[6] = lpReward.earned(_account);
        return data;
    }

    ///////////////////////////////////////////////////////
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) external onlyAdmin returns (uint256) {
        return amount;
    }

    function _afterTokenTransfer(
        address sender,
        address recipient,
        uint256 _fromtype,
        uint256 amount,
        uint256 actual,
        uint256 _fee
    ) external onlyAdmin returns (uint256) {
        if (_fromtype > 0) {
            uint256 lprate = ratio[0];
            uint256 daorate = ratio[1];
            if (_fromtype != 1) {
                lprate = ratio[2];
                daorate = ratio[3];
            }

            uint256 _lp = (lprate * _fee) / 1000;
            if (_lp > 0) {
                lpReward.executeReward(_lp);
            }

            uint256 _fund = Math.min((daorate * _fee) / 1000, _fee - _lp);
            if (_fund > 0) {
                fundTokensAmount += _fund;
            }
        }

        if (_fromtype == 0) {
            if (fund != address(0) && fund != address(this)) {
                bool canfund = fundTokensAmount > fundTokensAtAmount &&
                    tokenB.balanceOf(address(this)) >= fundTokensAmount;
                if (!_funding && canfund) {
                    _funding = true;

                    uint256 fundamount = fundTokensAmount;
                    fundTokensAmount = 0;
                    tokenB.transfer(fund, fundamount);
                    _funding = false;
                }
            }
        }
        return 0;
    }

    ///////////////////////////////////////////////////////
    function swapAndLiquify(
        address token0,
        address token1,
        uint256 amount0
    ) internal returns (uint256) {
        uint256 half = amount0 / 2;
        uint256 otherHalf = amount0 - half;

        uint256[] memory amounts = swapTokenForTokenFee(
            token0,
            token1,
            address(this),
            half
        );

        uint256 liquidity = addLiquidity(token0, token1, otherHalf, amounts[1]);
        emit SwapAndLiquify(token0, token1, otherHalf, amounts[1], liquidity);
        return liquidity;
    }

    function addLiquidity(
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1
    ) internal returns (uint256) {
        IERC20(token0).approve(address(uniswapV2Router), amount0);
        IERC20(token1).approve(address(uniswapV2Router), amount1);

        uint256 amountA = 0;
        uint256 amountB = 0;
        uint256 liquidity = 0;
        (amountA, amountB, liquidity) = uniswapV2Router.addLiquidity(
            address(token0),
            address(token1),
            amount0,
            amount1,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );

        return liquidity;
    }

    function swapTokenForTokenFee(
        address token0,
        address token1,
        address receiver,
        uint256 tAmount
    ) internal returns (uint256[] memory amounts) {
        IERC20(token0).approve(address(uniswapV2Router), tAmount);
        uint256 initialBalance = IERC20(token1).balanceOf(receiver);

        address[] memory path = new address[](2);
        path[0] = address(token0);
        path[1] = address(token1);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tAmount,
            0, // accept any amount of token
            path,
            receiver,
            block.timestamp
        );

        uint256 iAmount = IERC20(token1).balanceOf(receiver) - initialBalance;

        amounts = new uint256[](2);
        amounts[0] = tAmount;
        amounts[1] = iAmount;
    }

    function withdraw(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyOwner returns (uint256) {
        require(_to != address(0), "ERC20: transfer from the zero address");

        uint256 val = Math.min(
            _amount,
            IERC20(_token).balanceOf(address(this))
        );
        if (val > 0) {
            IERC20(_token).transfer(_to, val);
        }
        return val;
    }

    function withdrawBNB(address _to, uint256 _amount)
        external
        onlyOwner
        returns (uint256)
    {
        require(_to != address(0), "ERC20: transfer from the zero address");

        uint256 val = Math.min(_amount, address(this).balance);
        if (val > 0) {
            payable(_to).transfer(val);
        }
        return val;
    }
}