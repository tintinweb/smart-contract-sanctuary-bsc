/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity 0.6.12;

/**
***
***
***
***  ██╗  ██╗██╗  ██╗ █████╗  ██████╗ ███████╗   ███████╗██╗███╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗
***  ██║ ██╔╝██║  ██║██╔══██╗██╔═══██╗██╔════╝   ██╔════╝██║████╗  ██║██╔══██╗████╗  ██║██╔════╝██╔════╝
***  █████╔╝ ███████║███████║██║   ██║███████╗   █████╗  ██║██╔██╗ ██║███████║██╔██╗ ██║██║     █████╗  
***  ██╔═██╗ ██╔══██║██╔══██║██║   ██║╚════██║   ██╔══╝  ██║██║╚██╗██║██╔══██║██║╚██╗██║██║     ██╔══╝  
***  ██║  ██╗██║  ██║██║  ██║╚██████╔╝███████║██╗██║     ██║██║ ╚████║██║  ██║██║ ╚████║╚██████╗███████╗
***  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝
*** 
*** 
***   website:  https://khaos.finance
*** 
*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IStake {
    function processDividend() external;
}
interface ITeam {
    function isMember(address target) view external returns(bool);
}

contract KHAOS is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "KHAOS.FINANCE";
    string private _symbol = "KHAOS";
    
    uint8 private _decimals = 9;
    
    mapping (address => address) public _levels;
    mapping (address => uint256) public _levelRewards;
    
    mapping (address => bool) public _excludeFees;
    mapping (address => bool) public _robots;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 public _totalSupply = 1000000 * 10**9 * 10**9;

    uint256 public _spreadFee = 6;
    uint256 public _marketingFee = 2;
    uint256 public _burnFee = 1;
    uint256 public _bonusSellFee = 2;
    uint256 public _bonusBuyFee = 3;

    address public _marketingWallet;
    address public _stakeContract;
    address public _teamContract;
    address public _deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public _levelRootAddress;

    //0.5 BNB
    uint256 public _valueLimit = 5 * 10 ** 17;
    //0.001%
    uint256 public _autoSwapLimit = _totalSupply.div(100000);
    //0.5%
    uint256 public _maxTransAmount = _totalSupply.div(200);

    IUniswapV2Router02 public _uniswapRouter;
    
    address public _pairAddress;

    //to recieve BNB from uniswapV2Router when swaping
    receive() external payable {}

    constructor() public {
        address pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

        _uniswapRouter = IUniswapV2Router02(pancakeRouter);
        _pairAddress = IUniswapV2Factory(_uniswapRouter.factory()).createPair(address(this), _uniswapRouter.WETH());
        
        //root member
        _levelRootAddress = 0x62Efa4631957584153e6f3937136eE8b447d6710;
        _levels[_levelRootAddress] = address(0);
        
        _excludeFees[_msgSender()] = true;
        _excludeFees[address(this)] = true;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _baseTransfer(address sender, address recipient, uint256 amount) private returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "BEP20: transfer amount must be greater than zero");

        if(_excludeFees[sender] || _excludeFees[recipient]) {
            return _baseTransfer(sender, recipient, amount);
        }
        
        require(!_robots[sender] && !_robots[recipient], "KHAOS: You are a robot");
        require(amount <= _maxTransAmount, "KHAOS: Maximum transaction volume limit");
        
        uint256 burnAmount = 0;
        uint256 marketingAmount = 0;
        uint256 trueAmount = 0;
        uint256 bounsAmount = 0;
        uint256 spreadAmount = 0;
        
        if(sender == _pairAddress) {
            //buy
            spreadAmount = amount.mul(_spreadFee).div(100);
            burnAmount = amount.mul(_burnFee).div(100);
            bounsAmount = amount.mul(_bonusBuyFee).div(100);
            marketingAmount = amount.mul(_marketingFee).div(100);
            trueAmount = amount.sub(spreadAmount).sub(burnAmount).sub(bounsAmount).sub(marketingAmount);
        } else if(recipient == _pairAddress) {
            //sell
            burnAmount = amount.mul(_burnFee).div(100);
            bounsAmount = amount.mul(_bonusSellFee).div(100);
            marketingAmount = amount.mul(_marketingFee).div(100);
            trueAmount = amount.sub(burnAmount).sub(bounsAmount).sub(marketingAmount);
        } else {
            //transfer
            _adjustRelationship(sender, recipient);
            
            bounsAmount = amount.mul(12).div(100);
            trueAmount = amount.sub(bounsAmount);
            
            _balances[_stakeContract] = _balances[_stakeContract].add(bounsAmount);
            emit Transfer(sender, _stakeContract, bounsAmount);
            
            bounsAmount = 0;
        }

        if(burnAmount > 0) {
            //destroy tokens
            _balances[_deadAddress] = _balances[_deadAddress].add(burnAmount);
            emit Transfer(sender, _deadAddress, burnAmount);
        }
        if(bounsAmount > 0) {
            //dividend token
            uint256 stakeAmount = bounsAmount.mul(80).div(100);
            uint256 teamAmount = bounsAmount.sub(stakeAmount);
            
            _balances[_stakeContract] = _balances[_stakeContract].add(stakeAmount);
            emit Transfer(sender, _stakeContract, stakeAmount);
            
            _balances[_teamContract] = _balances[_teamContract].add(teamAmount);
            emit Transfer(sender, _teamContract, teamAmount);
        }
        if(marketingAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(marketingAmount);
            emit Transfer(sender, address(this), marketingAmount);
        }
        if(spreadAmount > 0) {
            //promotion 
            _spreadDeductProcess(sender, recipient, spreadAmount);
        }

        if(recipient == _pairAddress) {
            //Marketing exchange is only available when selling
            _marketingProcess();
            try IStake(_stakeContract).processDividend() {} catch {}
        }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(trueAmount);
        emit Transfer(sender, recipient, trueAmount);

        return true;
    }
    
    function _adjustRelationship(address from, address to) private {
        if(_levels[to] == address(0) && to != _levelRootAddress) {
            if(from == _levelRootAddress || _levels[from] != address(0)) {
                _levels[to] = from;
            }
        }
    }

    function _spreadDeductProcess(address sender, address to, uint256 spreadAmount) private {
        if(_levels[to] == address(0) || _levels[to] == _levelRootAddress) {
            _balances[_levelRootAddress] = _balances[_levelRootAddress].add(spreadAmount);
            _levelRewards[_levelRootAddress] = _levelRewards[_levelRootAddress].add(spreadAmount);
            emit Transfer(sender, _levelRootAddress, spreadAmount);
            return;
        }
        //leve1 4% -> 66
        uint256 p1Amount = spreadAmount.mul(66).div(100);
        //level 2% -> 34
        uint256 p2Amount = spreadAmount.sub(p1Amount);
        
        uint256 priceOfBNB = _getPriceOfBNB();
        while(true) {
            to = _levels[to];
            if(to == address(0) || to == _levelRootAddress) {
                break;
            }
            if(!_isCanDeduct(to, priceOfBNB)) {
                //Not qualified, skip
                continue;
            }
            if(p1Amount > 0) {
                _balances[to] = _balances[to].add(p1Amount);
                _levelRewards[to] =  _levelRewards[to].add(p1Amount);
                emit Transfer(sender, to, p1Amount);
                p1Amount = 0;
            } else if(p2Amount > 0) {
                _balances[to] = _balances[to].add(p2Amount);
                _levelRewards[to] =  _levelRewards[to].add(p2Amount);
                emit Transfer(sender, to, p2Amount);
                p2Amount = 0;
            } else {
                break;
            }
        }
        
        uint256 lastAmount = p1Amount.add(p2Amount);
        if(lastAmount > 0) {
            _balances[_levelRootAddress] = _balances[_levelRootAddress].add(lastAmount);
            _levelRewards[_levelRootAddress] = _levelRewards[_levelRootAddress].add(lastAmount);
            emit Transfer(sender, _levelRootAddress, lastAmount);
        }
    }

    //
    function _marketingProcess() private {
        uint256 contractTokenBalance = balanceOf(address(this));                
        if (contractTokenBalance >= _autoSwapLimit) {
            _swapTokensForEth(contractTokenBalance);
            uint256 bnbBalance = address(this).balance;
            if(bnbBalance > 0) {
                _transferToAddressETH(payable(_marketingWallet), bnbBalance);
            }
        }
    }
    
    function setMarketingWallet(address wallet) public onlyOwner {
        _marketingWallet = wallet;
        if(!_excludeFees[_marketingWallet]) {
            _excludeFees[_marketingWallet] = true;
        }
    }
    function setMaxTransAmount(uint256 amount) public onlyOwner {
        if(amount == 0) {
            _maxTransAmount = _totalSupply;
        } else {
            _maxTransAmount = amount;
        }
    }
    function setStakeContract(address stakeContract) public onlyOwner {
        _stakeContract = stakeContract;
        if(!_excludeFees[_stakeContract]) {
            _excludeFees[_stakeContract] = true;
        }
    }
    function setTeamContract(address teamContract) public onlyOwner {
        _teamContract = teamContract;
        if(!_excludeFees[_teamContract]) {
            _excludeFees[_teamContract] = true;
        }
    }
    function setExcludeFee(address target) public onlyOwner {
        if(_excludeFees[target]) {
            _excludeFees[target] = false;
        } else {
            _excludeFees[target] = true;
        }
    }
    function setValueLimit(uint256 limit) public onlyOwner {
        _valueLimit = limit;
    }
    function setRobotAddress(address sender, bool flag) public onlyOwner {
        _robots[sender] = flag;
    }
    function getFathers(address target) public view returns (address[] memory list) {
        uint256 count = 0;
        address old = target;
        while(true) {
            target = _levels[target];
            if(target == address(0)) {
                break;
            }
            count++;
        }
        if(count > 0) {
            target = old;
            list = new address[](count);
            uint256 index = 0;
            while(true) {
                target = _levels[target];
                if(target == address(0)) {
                    break;
                }
                list[index] = target;
                index++;
            }
        }
        return list;
    }

    function _transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function _swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapRouter.WETH();
        _approve(address(this), address(_uniswapRouter), tokenAmount);
        // make the swap
        _uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
    }

    function _getPriceOfBNB() view public returns(uint256){
        IUniswapV2Pair pair = IUniswapV2Pair(_pairAddress);
        (uint256 res0, uint256 res1,) = pair.getReserves();
        (res0, res1) = (pair.token0() == address(this)) ? (res0,res1) : (res1,res0);
        return (res1 * (10 ** 9)).div(res0);
    }
    
    function _getPriceOfBNB2(address sender) view public returns(uint256){
        uint256 priceOfBNB = _getPriceOfBNB();
        uint256 holdoldAmount = balanceOf(sender);
        uint256 value = holdoldAmount.mul(priceOfBNB).div(10 ** 9);
        return value;
    }
    
    function _isCanDeduct(address holder, uint256 priceOfBNB) view public returns(bool) {
        if(priceOfBNB == 0) {
            priceOfBNB = _getPriceOfBNB();
        }
        uint256 holdoldAmount = balanceOf(holder);
        uint256 value = holdoldAmount.mul(priceOfBNB).div(10 ** 9);
        if(value < _valueLimit) {
            bool flag = ITeam(_teamContract).isMember(holder);
            if(flag) {
                return true;
            }
            return false;
        }
        return true;
    }
}