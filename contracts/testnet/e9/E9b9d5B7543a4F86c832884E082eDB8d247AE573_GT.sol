/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
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


contract GT  is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _tTotal = 91000000 * 10**8;
    string private _name = "GT";
    string private _symbol = "GT";
    uint8 private _decimals = 8;
    mapping(address=>bool) public isPair;

    uint256 private _allLP = 0;


    address public UPairAddress;
    address[] public LPAlladdress;


    uint256 public _sellLpFee = 4;//lp
    uint256 private _previousSellLpFee = _sellLpFee;
    uint256 public _gNodeFee = 1;//chuangshi
    uint256 private _previousGNodeFee = _gNodeFee;
    uint256 public _teamFee = 1;//shizhi
    uint256 private _previousTeamFee = _teamFee;

    uint256 public _buyFee = 1;
    uint256 private _previousBuyFee = _buyFee;


    address public LpAddress = address(0x1692368255405D40CfE6Eb6F181545521e77Bff6);
    address public gNodeAddress = address(0x9a3A34b4e780b2Dc47e210977c2b6aF7C4d13f9d);
    address public teamAddress = address(0xa2c428077A28fC2F17B7344fbdc2A4F9F087aa7F);
    address public buyAddress = address(0x1719e01BDCA00Af04e86438F2206b95eD9f83515);
    address public investAddress;

    mapping(address => bool) private _isInvest;
    //chuangshi
    address public poolAddress = address(0x229060A2AF146A89Ffb05da92A90AD5FBB46c103);
    //dichi
    address public comAddress = address(0x846A963b34Fae81784bb746a5Ba25B28F308C14D);
    //shequ
    address public mintAddress = address(0x28237Dd136cAF0030e8aE42E46d0A16461583601);
    //jijinhui
    address public buildAddress = address(0xb44cb6941C48A5Bc6Aa18909F021d9b3256C7e98);
    //jishu
    address public itAddress = address(0x2F0706A588275d0B61FfB9587291FD685ec10163);
    //wakuang
    address public wkAddress = address(0xb0bF3142F23367b7CCB4a63AE92a1f5c19ac8B3B);
    constructor() public {
         _balances[msg.sender] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isInvest[poolAddress] = true;
        _isInvest[comAddress] = true;
        _isInvest[mintAddress] = true;
        _isInvest[buildAddress] = true;
        _isInvest[itAddress] = true;
        _isInvest[wkAddress] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tTotal;
    }
  
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
  
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            removeAllFee();
        }
        uint256 toAmount = amount;

        //sell transfer
        if(!isPair[from]){
            if(from != investAddress && !_isInvest[to]){
                require(amount <= balanceOf(from) * 999 / 1000,"Transfer amount must be less than 99.9%");
            }
        }
        

        //sell transfer
        if(!isPair[from]){
            //sell
            if(isPair[to]){
                
                //if invest
                if(from != investAddress && !_isInvest[to]){

                    uint256 LpAmount = amount.mul(_sellLpFee).div(100);
                    _takeLp(from,LpAmount);
                    if(LpAmount>0){
                        toAmount = toAmount.sub(LpAmount);
                        _allLP = _allLP.add(LpAmount);
                    }

                    uint256 gNodeAmount = amount.mul(_gNodeFee).div(100);
                    _takeOther(from,gNodeAmount,gNodeAddress);
                    if(gNodeAmount>0){
                        toAmount = toAmount.sub(gNodeAmount);
                    }

                    uint256 teamAmount = amount.mul(_teamFee).div(100);
                    _takeOther(from,teamAmount,teamAddress);
                    if(teamAmount>0){
                        toAmount = toAmount.sub(teamAmount);
                    }
                }
            }
        }else{
            //buy
            if(to != investAddress && !_isInvest[from]){
                uint256 buyAmount = amount.mul(_buyFee).div(100);
                _takeOther(from,buyAmount,buyAddress);
                if(buyAmount>0){
                    toAmount = toAmount.sub(buyAmount);
                }
            }

        }

        _setAddressNew(to);

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(toAmount);
        
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            restoreAllFee();
        }
        emit Transfer(from, to, toAmount);
    }

    
    function _moveAddressNew(uint256 exis,address ad) private{
        delete LPAlladdress[exis];
        for(uint i=exis;i<LPAlladdress.length-1;i++){
            LPAlladdress[i] = LPAlladdress[i+1];
        }
        LPAlladdress[LPAlladdress.length-1] = ad; 
}

function _setAddressNew(address ad) private{
    uint256 isAddressExis = 0;
    bool isNew;
    for(uint i=0;i<LPAlladdress.length;i++){
        if(LPAlladdress[i]==ad){
            isAddressExis = i;
            isNew = true;
        }
    }
    if(isNew){
        if(LPAlladdress.length>=50){
            _moveAddressNew(isAddressExis,ad);
        }
    }else{
        if(LPAlladdress.length<50){
            LPAlladdress.push(ad);
        }else{
            _moveAddressNew(isAddressExis,ad);
        }
    }
}
function getAddress() public view  returns(address[] memory){
    return LPAlladdress;
}
function getOneLp(address addr) public view returns(uint256){
     uint256  user = IUniswapV2Pair(UPairAddress).balanceOf(addr);
    return user;
}


function getAllLP() public view returns(uint256){
   return _allLP;
}



function getAllLPToAddr(address[] memory addr) public view returns(uint256[] memory){
     uint256[] memory  user = new uint256[](addr.length);
     for(uint i=0;i<addr.length;i++){
         user[i] = IUniswapV2Pair(UPairAddress).balanceOf(addr[i]);
     }
    return user;
}


function isExcludedFromFee(address account) public view returns (bool) {
    return _isExcludedFromFee[account];
}
function setExcludedFromFee(address exAddress) external onlyOwner{
    _isExcludedFromFee[exAddress] = true;
}
function setInvest(address exAddress) external onlyOwner{
    investAddress = exAddress;
}

//guolvEX
function setInvestExtra(address exAddress) external onlyOwner{
    investAddress = exAddress;
}
//guolvIs
function setInvestToDes(address exAddress,bool isExclude) external onlyOwner{
    _isInvest[exAddress] = isExclude;
}

//setLP
function setLpAddress(address newLpAddress) external onlyOwner{
    LpAddress = newLpAddress;
}


function _takeLp(address sender,uint256 LpAmount) private {      
    _balances[LpAddress] = _balances[LpAddress].add(LpAmount);
    emit Transfer(sender, LpAddress, LpAmount);
}

function _takeOther(address sender,uint256 amount,address otaddress) private {
    _balances[otaddress] = _balances[otaddress].add(amount);
    emit Transfer(sender, otaddress, amount);
}
function removeAllFee() private {
    if (_sellLpFee==0 &&_gNodeFee==0 && _teamFee==0&& _buyFee==0) return;
    _previousSellLpFee  = _sellLpFee;
    _previousGNodeFee  = _gNodeFee;
    _previousTeamFee  = _teamFee;
    _previousBuyFee = _buyFee;

    _sellLpFee = 0;
    _gNodeFee = 0;
    _teamFee = 0;
    _buyFee = 0;
}



function restoreAllFee() private {
    _sellLpFee = _previousSellLpFee;
    _gNodeFee = _previousGNodeFee;
    _teamFee = _previousTeamFee;
    _buyFee = _previousBuyFee;
}
function setPair(address pairAddress) public onlyOwner{
    isPair[pairAddress] = true;
    UPairAddress = pairAddress;
}

}