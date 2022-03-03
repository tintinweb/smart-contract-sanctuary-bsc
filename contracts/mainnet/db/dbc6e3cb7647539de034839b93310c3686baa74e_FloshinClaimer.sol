/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IPancakeswapV2Pair {
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

    function permit(
        address owner, 
        address spender, 
        uint value, 
        uint deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
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
    function getReserves() external view returns (
        uint112 reserve0, 
        uint112 reserve1, 
        uint32 blockTimestampLast
    );
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IBEP20 {
    
    
    function decimals() external view returns(uint256);
    function totalSupply() external pure returns (uint256);

    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IMasterChef  {

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event SetFeeAddress(address indexed user, address indexed newAddress);
    event SetDevAddress(address indexed user, address indexed newAddress);
    event UpdateEmissionRate(address indexed user, uint256 goosePerBlock);

    function poolLength() external view returns (uint256);

    function add(uint256 _allocPoint, IBEP20 _lpToken, uint16 _depositFeeBP, bool _withUpdate, bool _isActive) external  ;

    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFeeBP, bool _withUpdate, bool _isActive) external ;

    function getMultiplier(uint256 _from, uint256 _to) external pure returns (uint256);

    function pendingCoinage(uint256 _pid, address _user) external view returns (uint256);

    function massUpdatePools() external;

    function updatePool(uint256 _pid) external;

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function safeCoinageTransfer(address _to, uint256 _amount) external;

    function dev(address _devaddr) external;

    function setFeeAddress(address _feeAddress) external;

    function updateEmissionRate(uint256 _coinagePerBlock) external;

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);    
	
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

contract FloshinClaimer is Ownable, ReentrancyGuard {


    IERC20 public floshinToken;
    uint256 private amountFloshin;
    uint public maxDollars = 250;
    uint public minDollars = 2;
    uint public percent = 4;
    

    //struct UserInfo {
    //    uint256 amount;
    //    uint256 rewardDebt;
    //}

    address masterchef = 0x36B34C4eA711DFcAB8f63dBAdbe30219292A59d5;
   
    //mapping(address => UserInfo) public userInfo;

	mapping(address => bool) private _isExcludedFromClaim;

    constructor(address _floshinToken) {
        floshinToken = IERC20(_floshinToken);
		amountFloshin = 10 * 10**18 / getTokenPriceInUSD(0xc9EAbA24483eFbdC3af6874598D5bAD4Dc4C995D, 0x1B96B92314C44b159149f7E0303511fB2Fc4774f);        
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        _transferOwnership(newOwner);
    }

    function setPercent(uint _percent, uint _minDollars, uint _maxDollars) public onlyOwner  {
        require(_percent > 1 && _minDollars > 1 && _maxDollars < 256);
        percent = _percent;
        minDollars = _minDollars;
        maxDollars = _maxDollars;
    }
    
    function canConvert(address wallet) public view returns(bool) {
        uint256 balanceFloshin = floshinToken.balanceOf(wallet);
        (uint256 balanceFloshinStaked, ) = IMasterChef(masterchef).userInfo(7,wallet);
        uint256 minBalanceHold = amountFloshin * 10**18; 
        return (balanceFloshin >= minBalanceHold || balanceFloshinStaked >= minBalanceHold) && !_isExcludedFromClaim[wallet];
    }

    function getMinfloshinNeeded() public view returns (uint) { 
        return amountFloshin; 
    }

    function claim() public  nonReentrant{ 
        uint256 balanceFloshin = floshinToken.balanceOf(msg.sender);        
        require(canConvert(msg.sender), "You need 10 usd worth Floshin in your wallet or not having claimed"); 
        uint256 minAmountAirdrop = (minDollars * amountFloshin) / 10; 
        uint256 maxAmountAirdrop = (maxDollars * amountFloshin) / 10;         
        uint256 amountAirdr = (balanceFloshin * (percent/100)); 
        if (amountAirdr >= maxAmountAirdrop) { 
            amountAirdr = maxAmountAirdrop; 
        } else if(amountAirdr <= minAmountAirdrop)  { 
            amountAirdr = minAmountAirdrop; 
        } 
        floshinToken.transfer(address(msg.sender) , amountAirdr); 
        _isExcludedFromClaim[msg.sender] = true; 
    }

    function recoverTokens(address token, uint amount) public onlyOwner {
        IERC20(token).transfer(address(msg.sender),  amount);
    }
    function recoverBNB( uint amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }
    function claimStatus(address user) public view returns(bool){
        return _isExcludedFromClaim[user];
    }

    function getTokenPriceInBNB(address pairAddress) private view returns(uint, uint){
        IPancakeswapV2Pair pair = IPancakeswapV2Pair(pairAddress);
        (uint Res0, uint Res1,) = pair.getReserves();

        uint res0 = Res0 / (10**18);
        uint res1 = Res1;
        return (1 * res1 / res0, 18); 
    }

    function getTokenPriceInUSD(address pairAddress, address pairAddressBNBInUSD) private view returns(uint){
        IPancakeswapV2Pair pair = IPancakeswapV2Pair(pairAddress);
        (uint Res0, uint Res1,) = pair.getReserves();

        uint res0 = Res0 / (10**18);
        uint res1 = Res1;

        IPancakeswapV2Pair pairBNBInUSD = IPancakeswapV2Pair(pairAddressBNBInUSD);
        (uint Res0BNBInUSD, uint Res1BNBInUSD,) = pairBNBInUSD.getReserves();

        uint res0BNBInUSD = Res0BNBInUSD;
        uint res1BNBInUSD = Res1BNBInUSD;

        return (res1 * res1BNBInUSD / res0 / res0BNBInUSD); 
    }

    function getFloshinPrice() public view returns (uint) {
        return getTokenPriceInUSD(0xc9EAbA24483eFbdC3af6874598D5bAD4Dc4C995D, 0x1B96B92314C44b159149f7E0303511fB2Fc4774f);
    }

}