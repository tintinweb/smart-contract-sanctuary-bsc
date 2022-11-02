/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
    function renounceOwnership() public virtual authorized {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}
interface IDEXRouter {
    function factory() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IDEXPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
interface IWithdraw {
    function authWithdrawDo(uint256 amount,address to)external;
    function transfer(uint256 tType,uint256 amount)external;
}

contract GSS is IBEP20, Auth {
    using SafeMath for uint256;
    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowances;

    address public tokenRewardAddress = 0xB355604e3df719fb146b59589a55a1300AED9899;
    address public gtLpReceiveAddress = 0x93603de10fB914f5612CC5b6599383370A08E3ba;
    IWithdraw withdrawAddress = IWithdraw(0x3EcEb5aE54fB5f6FD97352c83611D29F08f7aE53);

    uint256 public tokenRate = 10;
    uint256 public lpRate = 20;

    IBEP20 public USDT = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IBEP20 public GT = IBEP20(0x68F44Fd6fEF749c67fcc890faD4752bca7C1FE27);

    address constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public lastRewardTime = 1667318400;
    uint256 public benchmarkTime = 1667318400;
    bool sendFlag = true;
    address[] nftAddress = [
        0x3fDB633FbD4079f265929A71B497c7Fd237e2b06,
        0x60E907d9ec88E69C62FA8dde9fb43D6d4CaFa861,
        0xA533B9AcD8c75Ef15860E4EA3CC61cBC88c7a1B2
    ];
    string public _name = "Gold Saints";
    string public _symbol = "GSS";
    uint8 public _decimals = 18;
    uint256 public _totalSupply = 10_000_000 * (10 ** _decimals);

    uint256 daySeconds = 86400;
    uint256 daySendAmount = 555 * 10 ** _decimals;
    uint256 public totalSendNum = 0;

    uint256 public toLiquidityAmount = 300 * 10 ** _decimals;

    IDEXRouter public router;
    address public pair;
    bool public swapAndLiquifyEnabled = true;
    bool public autoDistribution = true;

    bool inSwapAndLiquify;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    mapping (address => bool) private _isExcludedFee;

    event SwapAndLiquify(uint256 gssAmount, uint256 exchangeUsdt, uint256 halfGtAmount);

    constructor() Auth(msg.sender){
        owner = msg.sender;

        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(address(USDT),address(this));
        _allowances[address(this)][address(router)] = uint256(2**256-1);
        GT.approve(address(router),uint256(2**256-1));
        USDT.approve(address(router),uint256(2**256-1));

        _isExcludedFee[address(this)] = true;
        _isExcludedFee[owner] = true;
        _isExcludedFee[address(withdrawAddress)] = true;
        
        _balances[address(withdrawAddress)] = _totalSupply;
        emit Transfer(address(0),address(withdrawAddress),_totalSupply);
        
    }
    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function distribution()public lockTheSwap{
        if(!sendFlag){
            return;
        }
        uint256 nowTime = block.timestamp;

        if(lastRewardTime + daySeconds > nowTime){
            return;
        }
        uint256 rewardCount = nowTime.sub(lastRewardTime).div(daySeconds);
        uint256 tmpTotalSend = daySendAmount.mul(rewardCount);

        withdrawAddress.authWithdrawDo(tmpTotalSend,address(this));
        if(_balances[address(this)] < tmpTotalSend){
            return;
        }
        _balances[address(this)] = _balances[address(this)].sub(tmpTotalSend);

        totalSendNum = totalSendNum.add(rewardCount);
        lastRewardTime = benchmarkTime.add(daySeconds.mul(totalSendNum));
        
        if(totalSendNum >= 360){
            sendFlag = false;
        }
        uint256 perReward = tmpTotalSend.div(nftAddress.length);
        for(uint256 i ; i < nftAddress.length; i++){
            _balances[nftAddress[i]] = _balances[nftAddress[i]].add(perReward);
            emit Transfer(address(this), nftAddress[i], perReward);
        }
    }
    function getNftAddress()external view authorized returns(address[] memory nftAddresss){
        nftAddresss = nftAddress;
    }
    function addNftAddress(address _new)external authorized{
        nftAddress.push(_new);
    }
    function withdrawDo(uint256 amount,address to)external authorized{
        uint256 balance = balanceOf(address(this));
        if(balance < amount){
            amount = balance;
        }
        _baseTransferFrom(address(this),to,amount);
    }

    function _transferFrom(address _from, address _to, uint _value) private returns (bool) {
        require(_value > 0, "Transfer amount must be greater than zero");

        if(autoDistribution && !inSwapAndLiquify){
           distribution(); 
        }
        if(inSwapAndLiquify || _isExcludedFee[_from] || _isExcludedFee[_to] || (_from != pair && _to != pair)){
            return _baseTransferFrom(_from,_to,_value);
        }
        uint256 contractTokenBalance = balanceOf(address(this));

        bool overMinTokenBalance = contractTokenBalance >= toLiquidityAmount;
        if (overMinTokenBalance && !inSwapAndLiquify && _to == pair && swapAndLiquifyEnabled) {
            swapAndLiquify(toLiquidityAmount);
        }

        _balances[_from] = _balances[_from].sub(_value);
        uint256 originValue = _value;
        if(tokenRate > 0){
            uint256 tokenAmount = originValue.mul(tokenRate).div(1000);
            _balances[tokenRewardAddress] = _balances[tokenRewardAddress].add(tokenAmount);
            emit Transfer(_from, tokenRewardAddress, tokenAmount);
            _value = _value.sub(tokenAmount);
        }
        if(lpRate > 0){
            uint256 lpAmount = originValue.mul(lpRate).div(1000);
            _balances[address(this)] = _balances[address(this)].add(lpAmount);
            emit Transfer(_from, address(this), lpAmount);
            _value = _value.sub(lpAmount);
        }
        
        _balances[_to] = _balances[_to].add(_value);
        isBurn(_to,_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function _baseTransferFrom(address _from, address _to, uint _value) private returns (bool) {
        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        isBurn(_to,_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function isBurn(address _to,uint256 _value)internal{
        if(_to == address(0)){
            _totalSupply = _totalSupply.sub(_value);
        }
    }

    function setAutoDistribution(bool _new)external authorized{
        autoDistribution = _new;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 originUSDTBalance = USDT.balanceOf(address(this));
        swapTokens(contractTokenBalance,0);
        uint256 diffUSDT = USDT.balanceOf(address(this)).sub(originUSDTBalance);
        uint256 halfUSDT = diffUSDT.div(2);
        uint256 originGTBalance = GT.balanceOf(address(this));
        swapTokens(halfUSDT,1);
        uint256 diffGT = GT.balanceOf(address(this)).sub(originGTBalance);
        addLiquidity(halfUSDT, diffGT);
        emit SwapAndLiquify(contractTokenBalance, diffUSDT, diffGT);
    }
    function swapTokens(uint256 tokenAmount,uint256 toType) private {
        address[] memory path = new address[](2);
        uint256 originBalance = 0;
        if(toType == 0){
            path[0] = address(this);
            path[1] = address(USDT);
            originBalance = USDT.balanceOf(address(withdrawAddress));
        }else{
            path[0] = address(USDT);
            path[1] = address(GT);
            originBalance = GT.balanceOf(address(withdrawAddress));
        }

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(withdrawAddress),
            block.timestamp.add(30)
        );
        uint256 sendAmount = 0;
        if(toType == 0){
            sendAmount = USDT.balanceOf(address(withdrawAddress)).sub(originBalance);
        }else{
            sendAmount = GT.balanceOf(address(withdrawAddress)).sub(originBalance);
        }
        withdrawAddress.transfer(toType,sendAmount);
    }
    function addLiquidity(uint256 usdtAmount, uint256 gtAmount) private {
        router.addLiquidity (
            address(USDT),
            address(GT),
            usdtAmount,
            gtAmount,
            0,
            0,
            gtLpReceiveAddress,
            block.timestamp.add(30)
        );
    }
    function getU() external authorized{
        USDT.transfer(msg.sender,USDT.balanceOf(address(this)));
    }

    function setExclude(address _address,bool flag) public onlyOwner {
        _isExcludedFee[_address] = flag;
    }
    function setGtLpReceiveAddress(address _new)external authorized{
        gtLpReceiveAddress = _new;
    }
    function setRate(uint256 _tokenRate,uint256 _lpRate)external authorized{
        tokenRate = _tokenRate;
        lpRate = _lpRate;
    }
    function setTokenReawrdAddress(address _new)external authorized{
        tokenRewardAddress = _new;
    }
    function setGtAddress(IBEP20 _new)external authorized{
        GT = _new;
    }
    function setUSDTAddress(IBEP20 _new)external authorized{
        USDT = _new;
    }
    
    function setSwapAndLiquifyEnabled(bool _new) external authorized{
        swapAndLiquifyEnabled = _new;
    }
    function setToLiquidityAmount(uint256 _new) external authorized{
        toLiquidityAmount = _new * 10 ** _decimals;
    }
}

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}