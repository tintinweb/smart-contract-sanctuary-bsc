/**
 *Submitted for verification at BscScan.com on 2022-08-31
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


contract TGH  is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _tTotal = 210000000 * 10**9;
    string private _name = "TGH";
    string private _symbol = "TGH";
    uint8 private _decimals = 9;
    address public UPairAddress;
    address[] public LPAlladdress;

    mapping(address=>bool) public isPair;

    address public teamAddress = address(0x1cb56Bc51c5f70b93a03B204dCDbd13271B35d07);
    address public nodeAddress = address(0xD167446663c9802917cA9f80eC325eFD8e64a71f);
    address public lpAddress = address(0x630414cf3897310114094c05576cF601c58De9Ef);

    uint256 public _LPFee = 50;
    uint256 private _previousLPFee = _LPFee; 
    uint256 public _teamFee = 20;
    uint256 private _previousTeamFee = _teamFee;  
    uint256 public _nodeFee = 30;
    uint256 private _previousnodeFee = _nodeFee;  
    
    uint256 public allLPPrice = 0;

    uint256 public allTeamPrice = 0;

    uint256 public allLPNode = 0;

    uint256 public maxTransferNum = 99;


    constructor() public {
        _balances[msg.sender] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
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

        if(!isPair[from]){
            require(amount <= balanceOf(from) * maxTransferNum / 100,"Transfer amount must be less than 99%");
        }

        bool isExclude;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            removeAllFee();
            isExclude = true;
        }


        uint256 toAmount = amount;
        _setAddressNew(to);
        

        uint256 teamAmount = amount.mul(_teamFee).div(1000);
        _takeOther(from,teamAmount,teamAddress);
        if(teamAmount>0){
            toAmount = toAmount.sub(teamAmount);
            allTeamPrice = allTeamPrice.add(teamAmount);
        }

        
        uint256 lpAmount = amount.mul(_LPFee).div(1000);
        _takeOther(from,lpAmount,lpAddress);
        if(lpAmount>0){
            toAmount = toAmount.sub(lpAmount);
            allLPPrice = allLPPrice.add(lpAmount);
        }

        uint256 nodeAmount = amount.mul(_nodeFee).div(1000);
        _takeOther(from,nodeAmount,nodeAddress);
        if(nodeAmount>0){
            toAmount = toAmount.sub(nodeAmount);
            allLPNode = allLPNode.add(nodeAmount);
        }

         
        
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(toAmount);

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            restoreAllFee();
            isExclude = false;
        }
        
        emit Transfer(from, to, toAmount);
    }

    function _takeOther(address sender,uint256 amount,address otaddress) private {
        _balances[otaddress] = _balances[otaddress].add(amount);
        emit Transfer(sender, otaddress, amount);
    }

    function _moveAddressNew(uint256 exis,address ad) private{
            delete LPAlladdress[exis];
            for(uint i=exis;i<LPAlladdress.length-1;i++){
                LPAlladdress[i] = LPAlladdress[i+1];
            }
            LPAlladdress[LPAlladdress.length-1] = ad; 
    }

    function getTeamPrice() public view returns(uint256){
        return allTeamPrice;
    }

    function getLPPrice() public view returns(uint256){
        return allLPPrice;
    }

    function getLPNode() public view returns(uint256){
        return allLPNode;
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
  
    function getAllLPToAddr(address[] memory addr) public view returns(uint256[] memory){
         uint256[] memory  user = new uint256[](addr.length);
         for(uint i=0;i<addr.length;i++){
             user[i] = IUniswapV2Pair(UPairAddress).balanceOf(addr[i]);
         }
        return user;
    }

  
    function setTeamAddress(address pairAddress) external onlyOwner{
        teamAddress = pairAddress;
    }

    function setNodeAddress(address pairAddress) external onlyOwner{
        nodeAddress = pairAddress;
    }

    function setLpAddress(address pairAddress) external onlyOwner{
        lpAddress = pairAddress;
    }

     function removeAllFee() private {
        if ( _teamFee==0 && _nodeFee==0 && _LPFee==0) return;
        _previousTeamFee  = _teamFee;
        _previousLPFee  = _LPFee;
        _previousnodeFee  = _nodeFee;

        _teamFee = 0;
        _LPFee = 0;
        _nodeFee = 0;
    }

     function restoreAllFee() private {
        _teamFee = _previousTeamFee;
        _LPFee = _previousLPFee;
        _nodeFee = _previousnodeFee;
    }

    function setPair(address pairAddress) external onlyOwner{
        isPair[pairAddress] = true;
        UPairAddress = pairAddress;
    }
   
    function setExcludedFalse(address exAddress) external onlyOwner{
        _isExcludedFromFee[exAddress] = false;
    }

    function setExcludedFromFee(address[] memory addr) external onlyOwner{
         for(uint i=0;i<addr.length;i++){
             _isExcludedFromFee[addr[i]] = true;
         }
    }

}