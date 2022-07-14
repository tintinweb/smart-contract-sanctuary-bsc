/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXPair {
    function sync() external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
    function WBNB() external pure returns (address);

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

interface ITreasury {
    function claimRewards(address _recipient, uint _amount) external;
}

contract LiquidityHelper is Ownable {
    using SafeMath for uint256;

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    address public IlluminatiToken;
    address public MysteryBox;
    address public BaseToken;
    address public Treasury;
    bool public isReverse;
    IDEXRouter public router;
    IDEXPair public pairContract;

    uint public amountSwapToDead;
    uint public maxTokenSwapBack;
    uint public maxTokenSwapDead;

    bool public inSwap;

    constructor(address _IlluminatiToken, address _Treasury, address _pairContract) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IlluminatiToken = _IlluminatiToken;
        Treasury = _Treasury;
        setPairContract(address(router), _pairContract);
        maxTokenSwapBack = 50000 * 1e18;
        maxTokenSwapDead = 5000 * 1e18;
    }

    modifier onlyToken() {
        require(msg.sender == IlluminatiToken, "Only Called By Token");
        _;
    }

    modifier onlyMysteryBox() {
        require(msg.sender == MysteryBox, "Only Called By MysteryBox");
        _;
    }

    function settingMaxToken(uint _maxTokenSwapBack, uint _maxTokenSwapDead) external onlyOwner {
        require(_maxTokenSwapBack > 0, "Invalid maxTokenSwapBack");
        require(_maxTokenSwapDead > 0, "Invalid maxTokenSwapDead");
        maxTokenSwapBack = _maxTokenSwapBack;
        maxTokenSwapDead = _maxTokenSwapDead;
    }

    function swapAndLiquifyFromBox(uint256 _amountToSwap) external onlyMysteryBox {
        amountSwapToDead = amountSwapToDead.add(_amountToSwap);
        if(inSwap) {
            return;
        }
        inSwap = true;
        _swapAndLiquifyFromBox();
        uint _tokenBalance = IERC20(IlluminatiToken).balanceOf(address(this));
        if(_tokenBalance > 0) {
            _swapAndLiquify(_tokenBalance);
        }
        inSwap = false;
    }

    function _swapAndLiquifyFromBox() internal {
        uint baseTokenBalance = IERC20(BaseToken).balanceOf(address(this));
        uint _amountSwap = amountSwapToDead >= maxTokenSwapDead ? maxTokenSwapDead : amountSwapToDead;
        uint _amountLiquify = baseTokenBalance.sub(amountSwapToDead);
        if(_amountSwap > 0 && _amountSwap <= baseTokenBalance) {
            _swapBUSDForTokens(_amountSwap, DEAD);
            amountSwapToDead = amountSwapToDead.sub(_amountSwap);
        }
        if(_amountLiquify > 0) {
            (uint reserve0, uint reserve1,) = pairContract.getReserves();
            uint exactTokenBAmount = _quote(_amountLiquify, reserve0, reserve1);
            ITreasury(Treasury).claimRewards(address(this), exactTokenBAmount);

            _addLiquidity(exactTokenBAmount, _amountLiquify);
        }
    }

    function swapAndLiquify(uint256 amountToken) external onlyToken {
        if(inSwap) {
            return;
        }
        inSwap = true;
        uint _tokenBalance = IERC20(IlluminatiToken).balanceOf(address(this));
        amountToken = _tokenBalance <= maxTokenSwapBack ? _tokenBalance : maxTokenSwapBack;
        _swapAndLiquify(amountToken);
        uint256 initialBalance = IERC20(BaseToken).balanceOf(address(this));
        if(initialBalance > 0) {
            _swapAndLiquifyFromBox();
        }
        inSwap = false;
    }

    function _swapAndLiquify(uint256 amountToken) internal {
        uint256 half = amountToken.div(2);
        uint256 otherHalf = amountToken.sub(half);

        uint256 initialBalance = IERC20(BaseToken).balanceOf(address(this));

        _swapTokensForBUSD(half, address(this));

        uint256 newBalance = IERC20(BaseToken).balanceOf(address(this)).sub(initialBalance);

        _addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function _quote(uint amountA, uint reserveA, uint reserveB) internal view returns (uint amountB) {
        require(amountA > 0, "LiquidityHelper: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "LiquidityHelper: INSUFFICIENT_LIQUIDITY");
        if(isReverse) {
            amountB = amountA.mul(reserveA) / reserveB;
        } else {
            amountB = amountA.mul(reserveB) / reserveA;
        }
    }

    function _swapBUSDForTokens(uint256 tokenAmount, address _recipient) internal {
        address[] memory path = new address[](2);
        path[0] = BaseToken;
        path[1] = IlluminatiToken;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            _recipient,
            block.timestamp
        );
    }

    function _swapTokensForBUSD(uint256 tokenAmount, address _recipient) internal {
        address[] memory path = new address[](2);
        path[0] = IlluminatiToken;
        path[1] = BaseToken;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            _recipient,
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 busdAmount) internal {
        router.addLiquidity(
            BaseToken,
            IlluminatiToken,
            busdAmount,
            tokenAmount,
            0,
            0,
            Treasury,
            block.timestamp
        );
    }

    function setPairContract(address _router, address _pair) public onlyOwner {
        router = IDEXRouter(_router);
        pairContract = IDEXPair(_pair);
        address token0 = IDEXPair(_pair).token0();
        address token1 = IDEXPair(_pair).token1();
        if(token0 == IlluminatiToken) {
            BaseToken = token1;
            isReverse = true;
        } else if(token1 == IlluminatiToken) {
            BaseToken = token0;
            isReverse = false;
        } else {
            revert("Invalid Pair");
        }
        IERC20(BaseToken).approve(address(router), uint256(-1));
        IERC20(BaseToken).approve(address(pairContract), uint256(-1));
        IERC20(BaseToken).approve(address(this), uint256(-1));
        IERC20(IlluminatiToken).approve(address(router), uint256(-1));
        IERC20(IlluminatiToken).approve(address(pairContract), uint256(-1));
    }

    function setTreasury(address _Treasury) external onlyOwner {
        require(_Treasury != address(0) && Treasury != _Treasury, "Address Not Valid");
        Treasury = _Treasury;
    }

    function setMysteryBox(address _MysteryBox) external onlyOwner {
        require(_MysteryBox != address(0) && MysteryBox != _MysteryBox, "Address Not Valid");
        MysteryBox = _MysteryBox;
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function clearStuckBalance(address _receiver) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    function rescueToken(address tokenAddress, uint256 amount) public onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(msg.sender, amount);
    }

    receive() external payable {}

    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event SwapAndLiquifyBusd(uint256 tokensSwapped, uint256 busdReceived, uint256 tokensIntoLiqudity);
}