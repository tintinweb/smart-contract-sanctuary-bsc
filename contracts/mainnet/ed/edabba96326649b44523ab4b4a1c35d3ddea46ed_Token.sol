/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface IUniswapV2Factory {
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

interface ISmartVault {
    function transfer(uint256 amount) external;
}

interface IConfig {

    function getInterestFee() external view returns (uint256);

    function getBonusFee() external view returns (uint256 [] memory);

    function getBonusThreshold() external view returns (uint256);

    function getBackflowFee() external view returns (uint256);

    function getBackflowLimit() external view returns (uint256);

    function getBackflowAddress() external view returns (address);

    function getBonusAddress() external view returns (address);

    function getBurnFee() external view returns (uint256);

    function getAppointFee() external view returns (uint256);

    function getFundFee() external view returns (uint256);

    function getNftFee() external view returns (uint256);

    function getAppointAddress() external view returns (address);

    function getFundAddress() external view returns (address);

    function getNftAddress() external view returns (address);

    function getDeflationFee() external view returns (uint256);

    function getDeflationAddress() external view returns (address);

    function getWhiteList(address account) external view returns (bool);

    function getBlackList(address account) external view returns (bool);

    function getRegisterList(address account) external view returns (bool);

    function getTeamList(address account) external view returns (address);
}

contract Owner {
    address private _owner;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnerSet(address(0), _owner);
    }

    function changeOwner(address newOwner) public virtual onlyOwner {
        emit OwnerSet(_owner, newOwner);
        _owner = newOwner;
    }

    function removeOwner() public virtual onlyOwner {
        emit OwnerSet(_owner, address(0));
        _owner = address(0);
    }

    function getOwner() external view returns (address) {
        return _owner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

abstract contract ERC20 is IERC20 {
    using SafeMath for uint256;

    string private _name;

    string private _symbol;

    uint8 private _decimals;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    constructor (string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _userMint(address account, uint256 amount) internal {
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _totalSupplyMint(uint256 amount) internal {
        _totalSupply = _totalSupply.add(amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        if (value > 0) {
            _totalSupply = _totalSupply.sub(value);
            _balances[account] = _balances[account].sub(value);
            emit Transfer(account, address(0), value);
        }
    }

    function burn(uint256 value) public returns (bool) {
        _burn(msg.sender, value);
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

contract Token is ERC20, Owner {
    using SafeMath for uint256;

    event Interest(address indexed account, uint256 balance, uint256 sBlock, uint256 eBlock, uint256 count, uint256 value);

    event SwapAndLiquify( uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

    mapping(address => uint256) _interestNode;
    mapping(address => bool) _notInterest;

    IUniswapV2Router02 public uniswapV2Router;
    address public usdtToken;
    address public uniswapV2Pair;
    bool private _swapping;
    
    ISmartVault private _SmartVault;
    IConfig private _Config;

    uint256 private _interestTime = 15 minutes;

    uint256 [] private _bonusFee = [300, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50];
    uint256 private _bonusThreshold = 1000;
    uint256 private _backflowFee = 500;
    
    uint256 private _burnFee = 250;
    uint256 private _appointFee = 250;
    uint256 private _fundFee = 580;
    uint256 private _nftFee = 500;

    address private _backflowAddress = 0x58cbc1032963eAd2AC174DCFb09B7934243470E0;
    address private _bonusAddress = 0xA29899666c253DbD28C2eA7F5395fc09E0112998;
    address private _appointAddress = 0x843A7F4875fBc8d6f0b1E80C381095B60167a9e3;
    address private _fundAddress = 0xA7237cC3150c802D8812Fa8A83d71c374CC32c60;
    address private _nftAddress = 0xBA84608d1CAF94d8b6642C4EA11b2DEC899299e8;
    address private _deflationAddress = 0x3A5445a73C260bA0C95C2a3Ef40CD09422B0c39a;

    bool public swapSwitch = true;
    bool public interestSwitch = true;

    constructor () ERC20("SunFlower", "SF", 18) {

        uint256 _totalSupply_ = 250000000 * (10 ** uint256(decimals()));

        address recipient = 0x7ea015E886f52fF8b6f5A38675BD922ed266A623;
        _mint(recipient, _totalSupply_);

        //测试用
        address test = msg.sender;
        _mint(test, 1000000 * (10 ** uint256(decimals())));

        _interestNode[address(0)] = block.timestamp;
        _interestNode[recipient] = _interestNode[address(0)];
        _interestNode[test] = _interestNode[address(0)];

        _notInterest[_backflowAddress] = true;
        _notInterest[_bonusAddress] = true;
        _notInterest[_appointAddress] = true;
        _notInterest[_fundAddress] = true;
        _notInterest[_nftAddress] = true;
        _notInterest[_deflationAddress] = true;

        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdtToken = 0x55d398326f99059fF775485246999027B3197955;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            address(usdtToken)
        );
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function setSmartVault(address contractAddress_) external onlyOwner returns (bool) {
        _SmartVault = ISmartVault(contractAddress_);
        return true;
    }

    function setConfig(address contractAddress_) external onlyOwner returns (bool) {
        _Config = IConfig(contractAddress_);
        return true;
    }

    function setSwapSwitch(bool noOrOff) public onlyOwner returns (bool) {
        swapSwitch = noOrOff;
        return true;
    }

    function setInterestSwitch(bool noOrOff) public onlyOwner returns (bool) {
        interestSwitch = noOrOff;
        return true;
    }

    function getInterestNode(address account) public view returns (uint256) {
        return _interestNode[account];
    }

    function totalSupply() public view override returns (uint256) {
        uint256 _totalSupply_ = super.totalSupply().sub(super.balanceOf(address(this))).sub(super.balanceOf(address(uniswapV2Pair)));
        (uint256 currentTotalSupply, ) = getInterest(address(0), _totalSupply_);
        return currentTotalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        (uint256 currentBalance, ) = getInterest(account, super.balanceOf(account));
        return currentBalance;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!_Config.getBlackList(sender), "account in the blacklist");
        require(!_Config.getBlackList(recipient), "account in the blacklist");

        if (!_swapping && balanceOf(address(this)) > 0 && !isContract(sender) && swapSwitch) {
            _swapAndLiquify();
        }

        if (interestSwitch) {
            _totalSupplyInterest();
            _mintInterest(sender);
            _mintInterest(recipient);
        }

        if (!_swapping && !_Config.getWhiteList(sender) && !_Config.getWhiteList(recipient)) {

            if (sender == uniswapV2Pair) {

                uint256 bonusTotal = _bonus(sender, recipient, amount);

                uint256 backflowAmount = amount.mul(_backflowFee).div(10000);
                if (backflowAmount > 0) { super._transfer(sender, address(this), backflowAmount); }

                amount = amount.sub(bonusTotal).sub(backflowAmount);
            } else if (recipient == uniswapV2Pair) {

                uint256 brunAmount = amount.mul(_burnFee).div(10000);
                if (brunAmount > 0) { _burn(sender, brunAmount); }

                uint256 appointAmount = amount.mul(_appointFee).div(10000);
                if (appointAmount > 0) { super._transfer(sender, _appointAddress, appointAmount); }

                uint256 fundAmount = amount.mul(_fundFee).div(10000);
                if (fundAmount > 0) { super._transfer(sender, _appointAddress, fundAmount); }

                uint256 nftAmount = amount.mul(_nftFee).div(10000);
                if (nftAmount > 0) { super._transfer(sender, _nftAddress, nftAmount); }

                amount = amount.sub(brunAmount).sub(appointAmount).sub(fundAmount).sub(nftAmount);
            } else {

                uint256 deflationAmount = amount.mul(_Config.getDeflationFee()).div(10000);
                if (deflationAmount > 0) { super._transfer(sender, _deflationAddress, deflationAmount); }

                amount = amount.sub(deflationAmount);
            }
        }

        super._transfer(sender, recipient, amount);
    }

    function _bonus(address sender, address recipient, uint256 value) private returns (uint256) {
        address member = sender == uniswapV2Pair ? recipient : sender;
        address remember;
        uint256 bonus;
        uint256 bonusTotal;
        for(uint i=0;i<_bonusFee.length;i++) {
            remember = _Config.getTeamList(member);
            member = remember == address(0) ? _bonusAddress : remember;
            bonus = value.mul(_bonusFee[i]).div(10000);
            bonusTotal += bonus;
            super._transfer(sender, member, bonus);
        }

        return bonusTotal;
    }

    function getInterest(address account, uint256 value) public view returns (uint256, uint256) {
        uint256 count;
        uint256 currentValue = value;
        if (!_notInterest[account]) {
            if (_interestNode[account] > 0 && !isContract(account)){
                uint256 afterSec = block.timestamp.sub(_interestNode[account]);
                while(afterSec >= _interestTime) {
                    currentValue = currentValue.add(currentValue.mul(_interestTime).mul(_Config.getInterestFee()).div(10000).div(86400));
                    afterSec = afterSec.sub(_interestTime); 
                    count ++;
                }
            }
        }
        return (currentValue, count);
    }

    function _mintInterest(address account) internal {
        if (!isContract(account) && !_notInterest[account]) {
            if (_interestNode[account] == 0) {
                _interestNode[account] = block.timestamp;
            } else {
                uint256 protoBalance = super.balanceOf(account);
                (uint256 currentBalance, uint256 count) = getInterest(account, protoBalance);
                uint256 interest = currentBalance.sub(protoBalance);
                if (interest > 0) {
                    _interestNode[account] = _interestNode[account].add(count.mul(_interestTime));
                    emit Interest(account, super.balanceOf(account), _interestNode[account], block.timestamp, count, interest);

                    _userMint(account, interest);
                }
            }
        }
    }

    function _totalSupplyInterest() internal {
        uint256 protoValue = super.totalSupply();
        (uint256 currentValue, uint256 count) = getInterest(address(0), protoValue);
        uint256 interest = currentValue.sub(protoValue);
        if (interest > 0) {
            _interestNode[address(0)] = _interestNode[address(0)].add(count.mul(_interestTime));

            _totalSupplyMint(interest);
        }
    }

    function _swapAndLiquify() internal lockTheSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = IERC20(usdtToken).balanceOf(address(_SmartVault));

        _swapTokensForToken(half, address(this), address(usdtToken), address(_SmartVault));

        uint256 newBalance = IERC20(usdtToken).balanceOf(address(_SmartVault)).sub(initialBalance);

        _addLiquidity(newBalance, otherHalf);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function _swapTokensForToken(
        uint256 tokenAmount,
        address path0,
        address path1,
        address to
    ) private {
        address[] memory path = new address[](2);
        path[0] = path0;
        path[1] = path1;

        IERC20(path[0]).approve(address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function _addLiquidity(uint256 usdtAmount, uint256 tokenAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        _SmartVault.transfer(usdtAmount);

        IERC20(usdtToken).approve(address(uniswapV2Router), usdtAmount);

        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(usdtToken),
            address(this),
            usdtAmount,
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            _backflowAddress,
            block.timestamp
        );
    }

    modifier lockTheSwap() {
        _swapping = true;
        _;
        _swapping = false;
    }
}