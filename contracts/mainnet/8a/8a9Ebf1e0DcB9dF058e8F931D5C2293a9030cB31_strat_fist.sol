/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint a, uint b) internal pure returns (uint) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;
    using Address for address;
    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;
    uint private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory __name, string memory __symbol, uint8 __decimals) {
        _name = __name;
        _symbol = __symbol;
        _decimals = __decimals;
    }

    function name() public view override returns (string memory ) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }

    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint amount) internal virtual { }
}

interface IFstSwapChef {
    function withdraw(uint, uint) external;
    function deposit(uint, uint) external;
    function enterStaking(uint _amount) external;
    function leaveStaking(uint _amount) external;
    function pendingFonvity(uint, address) external  view returns (uint);
}

interface INode {
    function withdraw(uint, uint) external;
    function deposit(uint, uint) external;
    function userInfo(uint,address) external view returns(uint, uint);
}

interface IFstswapRouterV2 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountETH,
            uint liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function getAmountsOut(uint amountIn, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

interface IFstswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function totalSupply()external view returns (uint);
    function getReserves()external view returns (uint, uint, uint);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
 
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract strat_fist is ERC20,Ownable{
    address public constant NODE_CHEF = address(0x73B19737E30481FfBceC84D81d326266E0eEd2c5);
    address public constant FRT = address(0xF24F4042254976e92E112b62DB14FDc02F4e956F);
    address public constant FON = address(0x12a055D95855b4Ec2cd70C1A5EaDb1ED43eaeF65);
    address public constant FSTSWAP_ROUTER = 0x1B6C9c20693afDE803B27F8782156c0f892ABC2d;
    address public constant FSTSWAP_CHEF = address(0x093C639e4291fbDcC339557ACCDAFF52aaAC37d9);
    address public constant FISTFARM_CHEF = address(0x6065d163675909fE755F655D5Bf4AaB86708173A);
    address public fonTo;
    
    uint public nodePid = 54;
    uint public slippageFactor = 950;
    uint public minAmount = 1;
    using SafeMath for uint;
    IFstswapV2Pair public pair;
    address public _pair;
    uint public pid;
    uint public totalProfit;
    address public token0;
    address public token1;
    uint __reserve0;
    uint __reserve1;
    uint public totalLpAmount;
    function max(uint a, uint b) private pure returns(uint) {
        return a>b?a:b;
    }

    function min(uint a, uint b) private pure returns(uint) {
        return a>b?b:a;
    }

    
    constructor (address __pair, uint _pid) ERC20(string(abi.encodePacked(IERC20(IFstswapV2Pair(__pair).token0()).symbol(),"_",IERC20(IFstswapV2Pair(__pair).token1()).symbol()," FstSwapV2 strategy")), string(abi.encodePacked(IERC20(IFstswapV2Pair(__pair).token0()).symbol(),"_",IERC20(IFstswapV2Pair(__pair).token1()).symbol()," FstSwapV2 strategy")), IERC20(__pair).decimals()) {
        fonTo = msg.sender;
        _pair = __pair;
        pid = _pid;
        pair = IFstswapV2Pair(_pair);
        token0 = pair.token0();
        token1 = pair.token1();
        _approveMaxAll();
    }
    
    function approveMaxAll() public onlyOwner{
        _approveMaxAll();
    }

    function _approveMaxAll() private{
        IERC20(FRT).approve(NODE_CHEF, 0);
        IERC20(FRT).approve(NODE_CHEF, type(uint).max);
        IERC20(_pair).approve(FSTSWAP_CHEF, 0);
        IERC20(_pair).approve(FSTSWAP_CHEF, type(uint).max);
        IERC20(token0).approve(FSTSWAP_ROUTER, 0);
        IERC20(token0).approve(FSTSWAP_ROUTER, type(uint).max);
        IERC20(token1).approve(FSTSWAP_ROUTER, 0);
        IERC20(token1).approve(FSTSWAP_ROUTER, type(uint).max);
        IERC20(_pair).approve(FSTSWAP_ROUTER, 0);
        IERC20(_pair).approve(FSTSWAP_ROUTER, type(uint).max);
    }
    
    function getNowBalance(address addr) public view returns (uint){
        uint _reserve0;
        uint _reserve1;
        uint _blockTimestampLast;
        (_reserve0, _reserve1, _blockTimestampLast) = IFstswapV2Pair(pair).getReserves();
        if(addr == token0){
            return _reserve0.mul(totalLpAmount).div(pair.totalSupply());
        }
        if(addr == token1){
            return _reserve1.mul(totalLpAmount).div(pair.totalSupply());
        }
        return 0;
    }

    function addLiquidity(uint _token0, uint _token1) internal{
        uint _reserve0;
        uint _reserve1;
        (_reserve0, _reserve1, ) = IFstswapV2Pair(pair).getReserves();
        uint _maxToken0 = _token1.mul(_reserve0).div(_reserve1).mul(100).div(99);
        uint _maxToken1 = _token0.mul(_reserve1).div(_reserve0).mul(100).div(99);
        _token0 = min(_token0, _maxToken0);
        _token1 = min(_token1, _maxToken1);
        IFstswapRouterV2(FSTSWAP_ROUTER).addLiquidity(
            token0,
            token1,
            _token0,
            _token1,
            _token0.mul(slippageFactor).div(1000),
            _token1.mul(slippageFactor).div(1000),
            address(this),
            block.timestamp + 60
        );
        IERC20(token0).transfer(
            FISTFARM_CHEF,
            IERC20(token0).balanceOf(address(this))
        );
        IERC20(token1).transfer(
            FISTFARM_CHEF,
            IERC20(token1).balanceOf(address(this))
        );
    }

    function removeLiquidity(uint amount) internal{
        (__reserve0, __reserve1,) = IFstswapV2Pair(pair).getReserves();
        uint pairTotal = IFstswapV2Pair(pair).totalSupply();

        IFstswapRouterV2(FSTSWAP_ROUTER).removeLiquidity(
            token0,
            token1,
            amount,
            amount.mul(__reserve0).div(pairTotal).mul(slippageFactor).div(1000),
            amount.mul(__reserve1).div(pairTotal).mul(slippageFactor).div(1000),
            FISTFARM_CHEF,
            block.timestamp + 55
        );

    }
    
    function _depositAll() internal {
        IERC20 u = IERC20(_pair);   
        IFstSwapChef y = IFstSwapChef(FSTSWAP_CHEF);
        if(pid == 0){
            INode n = INode(NODE_CHEF);
            uint amount = u.balanceOf(address(this));
            y.enterStaking(amount);
            n.deposit(nodePid, amount);
        }
        else{
            y.deposit(pid, u.balanceOf(address(this)));
        }
    }
    
    function excuteAll() external{
        uint _token0 = IERC20(token0).balanceOf(msg.sender);
        uint _token1 = IERC20(token1).balanceOf(msg.sender);
        if(_token0>minAmount &&_token1>minAmount){
            excute(_token0, _token1);
        }
    }

    function enterStakingAll() external onlyOwner{
        _depositAll();
    }

    function leaveStakingAll() external{
        require(msg.sender == FISTFARM_CHEF || msg.sender == this.owner(), "unauth");
        uint lpAmount = totalLpAmount;
        totalLpAmount = totalLpAmount.sub(lpAmount);
        ERC20 u = ERC20(_pair);
        uint r = u.balanceOf(address(this));
        if (r < lpAmount) {
            IFstSwapChef y = IFstSwapChef(FSTSWAP_CHEF);
            INode n = INode(NODE_CHEF);
            uint delta = lpAmount.sub(r);
            if(pid == 0){
                n.withdraw(nodePid, delta);
                y.leaveStaking(delta);
            }else{
                y.withdraw(pid, delta);
            }
        }
        removeLiquidity(lpAmount);
        _burn(FISTFARM_CHEF, lpAmount);
    }

    function excute(uint _token0, uint _token1) public{
        IERC20(token0).transferFrom(msg.sender, address(this), _token0);
        IERC20(token1).transferFrom(msg.sender, address(this), _token1);
        IERC20 u = ERC20(_pair);
        addLiquidity(_token0, _token1);
        uint _amount =  u.balanceOf(address(this));
        _mint(FISTFARM_CHEF, _amount);
        totalLpAmount = totalLpAmount.add(_amount);
        _depositAll();
    }
    
    function withdrawToken(address tokenTmp, uint amount) external{
        require(msg.sender == FISTFARM_CHEF || msg.sender == this.owner(), "unauth");
        uint _reserve0;
        uint _reserve1;
        uint lpAmount;
        (_reserve0, _reserve1,) = IFstswapV2Pair(pair).getReserves();
        uint pairTotal = IFstswapV2Pair(pair).totalSupply();
        if(tokenTmp == token0){
            lpAmount = amount.mul(pairTotal).div(_reserve0);
        }
        if(tokenTmp == token1){
            lpAmount = amount.mul(pairTotal).div(_reserve1);
        }
        lpAmount = lpAmount.mul(102).div(100);
        if (lpAmount>totalLpAmount){
            lpAmount = totalLpAmount;
        }
        if(lpAmount != 0){
            totalLpAmount = totalLpAmount.sub(lpAmount);
            ERC20 u = ERC20(_pair);
            uint r = u.balanceOf(address(this));
            if (r < lpAmount) {
                IFstSwapChef y = IFstSwapChef(FSTSWAP_CHEF);
                uint delta = lpAmount.sub(r);
                if(pid == 0){
                    INode n = INode(NODE_CHEF);
                    n.withdraw(nodePid,delta);
                    y.leaveStaking(delta);
                }else{
                    y.withdraw(pid, delta);
                }
            }
            removeLiquidity(lpAmount);
            _burn(FISTFARM_CHEF, lpAmount);            
        }

    }

    function earn() public {
        IFstSwapChef y = IFstSwapChef(FSTSWAP_CHEF);
        INode n = INode(NODE_CHEF);
        if(pid == 0){
            y.leaveStaking(0);
            n.withdraw(nodePid, 0);
        }
        else{
            y.withdraw(pid, 0);
        }
        uint _fon = IERC20(FON).balanceOf(address(this));
        IERC20(FON).transfer(fonTo, _fon);
        totalProfit += _fon;
    }     

    function setTokenMinAmount(uint _minAmount) public onlyOwner{
        minAmount = _minAmount;
    }
    
    function setfonTo(address _fonTo) public onlyOwner{
        fonTo = _fonTo;
    }
    
    function setSlippageFactor(uint _slippageFactor) public onlyOwner{
        slippageFactor = _slippageFactor;
    }

    function setNodePid(uint _newNodePid) public onlyOwner{
        INode n = INode(NODE_CHEF);
        uint amount;
        (amount,) = n.userInfo(nodePid,address(this));
        n.withdraw(nodePid, amount);
        nodePid = _newNodePid;
        n.deposit(nodePid, amount);
    }
}