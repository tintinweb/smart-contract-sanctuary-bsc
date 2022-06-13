/**
 *Submitted for verification at BscScan.com on 2022-06-13
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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IDEXRouter {
    function factory() external pure returns (address);
    
}
interface IPancakePair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function allowance(address owner, address spender) external view returns (uint);
}
contract JHT is IBEP20, Auth {
    using SafeMath for uint256;
    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowances;

    bool inSwapAndLiquify;
    
    string public tName;
    string public tSymbol;
    uint8 public tDecimals;
    uint256 public tTotalSupply;
    uint256 public burnTotal;
    address public batchSendAddress;
    address private treasuryAddress;
    uint256 public burnedTotal;
    uint256 public rewardTotal;
    uint256 public backTotal;
    bool stopType = false;

    IDEXRouter public router;
    address public pair;
    address constant USDTAddress = 0x55d398326f99059fF775485246999027B3197955;
    IBEP20 public USDT;
    address constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public jdtPoolAddress;
    IBEP20 public jdtAddress;
    address public rewardAddress = 0x3c43713Cb97431861b1a503105EEB8ad658236a6;
    address public reward1Address = 0x919415fE511992B76D2dc594980638183E1E7efE;
    address public backJdtAddress = 0x4Bac4B0D472755FC0240Ef34cdaCA25d6Eb58dB2;
    uint256 public buyRate = 50;
    uint256 public buyRewardRate = 20;
    uint256 public buyJdtRate = 30;

    uint256 public sellRate = 100;
    uint256 public sellBurnRate = 30;
    uint256 public sellRewardRate = 20;
    uint256 public sellJdtRate = 50;

    uint256 public addLpRate = 100;
    uint256 public removeLpRate = 50;

    mapping (address => bool) private _isExcluded;

    address[] private addressIndices;
    mapping (address => bool) private _existsAddress;

    enum TypeArr{
        None,
        Sell,
        AddLp,
        Buy,
        RemoveLp
    }
    event Type(TypeArr fType);
    event BackInfo(address indexed from,TypeArr fType,uint256 rewardAmount,uint256 backAmount);
    modifier lockTheSwap{
        inSwapAndLiquify = true; 
        _; 
        inSwapAndLiquify = false;
    }
    
    constructor() Auth(msg.sender){
        owner = msg.sender;
        tName = "JHT";
        tSymbol = "JHT";
        tDecimals = 4;  
        tTotalSupply = 1_000_000 * (10 ** tDecimals);
        burnTotal = 900_000 * (10 ** tDecimals);
        _balances[owner] = tTotalSupply;
        rewardAddress = msg.sender;
        treasuryAddress = msg.sender;
        batchSendAddress = msg.sender;
        _addAddress(treasuryAddress);
        
        _isExcluded[msg.sender] = true;
        _isExcluded[treasuryAddress] = true;
        
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(USDTAddress,address(this));
        _allowances[address(this)][address(router)] = uint256(2**256-1);
        USDT = IBEP20(USDTAddress);

        emit Transfer(address(0), msg.sender, tTotalSupply);
    }
    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return tTotalSupply; }
    function decimals() external view override returns (uint8) { return tDecimals; }
    function symbol() external view override returns (string memory) { return tSymbol; }
    function name() external view override returns (string memory) { return tName; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != tTotalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }
    function setExcluded(address account, bool excluded) public onlyOwner {
        _isExcluded[account] = excluded;
    }
    function _addAddress(address _user) private {
        if(!_existsAddress[_user]){
            _existsAddress[_user] = true;
            addressIndices.push(_user);
        }
    }
    function isExcluded(address account) public view returns(bool) {
        return _isExcluded[account];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender,spender,amount);
        return true;
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

    function _transferFrom(address _from, address _to, uint _value) private returns (bool) {
        if(_value == 0 || stopType || inSwapAndLiquify || (_from != pair && _to != pair) || _to == address(0) || _isExcluded[_from] || _isExcluded[_to]){ 
            return _originTransferFrom(_from, _to, _value); 
        }
        uint256 rewardAmount = 0;
        uint256 otherRewardAmount = 0;
        uint256 jdtAmount = 0;
        uint256 burnAmount = 0;
        address realFromAddress = _from;
        TypeArr tmpFlag = _getType(_from,_to);
        {
            uint256 jdtRate = 0;
            if(tmpFlag == TypeArr.Sell && sellRate > 0){
                jdtRate = sellJdtRate;
                if(sellRewardRate > 0){
                    otherRewardAmount = _value.mul(sellRewardRate).div(1000);
                    _balances[reward1Address] = _balances[reward1Address].add(otherRewardAmount);
                    rewardTotal = rewardTotal.add(otherRewardAmount);
                    emit Transfer(_from, reward1Address, otherRewardAmount);
                }
                if(sellBurnRate > 0){
                    burnAmount = _value.mul(sellBurnRate).div(1000);
                    _balances[address(0)] = _balances[address(0)].add(burnAmount);
                    _isBurn(address(0),burnAmount);
                    emit Transfer(_from, address(0), burnAmount);
                }
            }else if(tmpFlag == TypeArr.AddLp && addLpRate > 0){
                jdtRate = addLpRate;
            }else if(tmpFlag == TypeArr.Buy && buyRate > 0){
                jdtRate = buyJdtRate;
                realFromAddress = _to;
                if(buyRewardRate > 0){
                    rewardAmount = _value.mul(buyRewardRate).div(1000);
                    _balances[rewardAddress] = _balances[rewardAddress].add(rewardAmount);
                    rewardTotal = rewardTotal.add(rewardAmount);
                    emit Transfer(_from, rewardAddress, rewardAmount);
                }
            }else if(tmpFlag == TypeArr.RemoveLp && removeLpRate > 0){
                jdtRate = removeLpRate;
                realFromAddress = _to;
            }
            
            if(jdtRate > 0){
                jdtAmount = _value.mul(jdtRate).div(1000);
                _balances[backJdtAddress] = _balances[backJdtAddress].add(jdtAmount);
                backTotal = backTotal.add(jdtAmount);
                emit Transfer(_from, backJdtAddress, jdtAmount);
            }
        }

        emit BackInfo(realFromAddress,tmpFlag,rewardAmount,jdtAmount);
        
        _balances[_from] = _balances[_from].sub(_value,"Insufficient Balance");
        _value = _value.sub(rewardAmount).sub(jdtAmount).sub(otherRewardAmount).sub(burnAmount);
        _balances[_to] = _balances[_to].add(_value);
        _addAddress(_to);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function _getType(address _from, address _to) private returns (TypeArr flag){
        flag = TypeArr.None;
        if(_to == pair){
            flag = TypeArr.Sell;
            uint256 pairUsdtBalance = USDT.balanceOf(pair);
            (uint reserve0, uint reserve1, ) = IPancakePair(pair).getReserves();
            if(address(this) == IPancakePair(pair).token1() && pairUsdtBalance != reserve0){
                flag = TypeArr.AddLp;
            }
            if(address(this) == IPancakePair(pair).token0() && pairUsdtBalance != reserve1){
                flag = TypeArr.AddLp;
            }
        }
        if(_from == pair){
            flag = TypeArr.RemoveLp;
            uint256 pairUsdtBalance = USDT.balanceOf(pair);
            (uint reserve0, uint reserve1, ) = IPancakePair(pair).getReserves();
            if(USDTAddress == IPancakePair(pair).token0() && pairUsdtBalance > reserve0){
                flag = TypeArr.Buy;
            }
            if(USDTAddress == IPancakePair(pair).token1() && pairUsdtBalance > reserve1){
                flag = TypeArr.Buy;
            }
        }
        emit Type(flag);
    }
    function getPrice()external view returns(uint256 rate,uint256 diffDecimals){
        (uint reserve0, uint reserve1, ) = IPancakePair(pair).getReserves();
        rate = USDTAddress == IPancakePair(pair).token0() ? reserve0.div(reserve1) : reserve1.div(reserve0);
        diffDecimals = uint256(18).sub(tDecimals);
    }

    function _originTransferFrom(address _from, address _to, uint _value) private returns (bool) {
        _balances[_from] = _balances[_from].sub(_value,"Insufficient Balance");
        _balances[_to] = _balances[_to].add(_value);
        _isBurn(_to,_value);
        emit Transfer(_from, _to, _value);
        _addAddress(_to);
        return true;
    }
    function _isBurn(address _to, uint brunVal) private{
        if(_to == address(0)){
            burnedTotal = burnedTotal.add(brunVal);
            if(burnedTotal > burnTotal){
                uint256 diff = burnedTotal.sub(burnTotal);
                brunVal = brunVal.sub(diff);
                burnedTotal = burnTotal;
            }
            tTotalSupply = tTotalSupply.sub(brunVal);
        }
    }
    function info() external view returns(
        uint256 addressCount,
        uint256 holdAmount,
        uint256 burnAmount,
        uint256 circulationAmount,
        uint256 pairUsdtAmount
    ){
        addressCount = addressIndices.length;    
        for (uint256 i=0; i < addressCount; i++) {
            circulationAmount = circulationAmount.add(_balances[addressIndices[i]]);
        }
        circulationAmount = circulationAmount.sub(_balances[treasuryAddress]);
        holdAmount = circulationAmount.sub(_balances[pair]);
        burnAmount = burnedTotal;
        pairUsdtAmount = USDT.balanceOf(pair);
    }

    function getUserList(uint8 page) external view returns(
        address[10] memory userlist , 
        uint256[10] memory balanceList,
        uint256 total,
        uint256 ibegin,
        uint256 iend
    ) {
        total = addressIndices.length;
        if(total / 10 <= page) {
            ibegin = (total / 10) * 10;
            iend   = total;
        } else {
            ibegin = page * 10;
            iend   = (page + 1) * 10;
        }
        for(uint256 i = ibegin; i < iend; i ++ ) {
            userlist[i - ibegin] = addressIndices[i];
            balanceList[i - ibegin] = _balances[addressIndices[i]];
        }
    }

    function transferBatch(address[] memory toAddr, uint256[] memory value) public{
        require(msg.sender == batchSendAddress,"Forbidden");
        require(toAddr.length == value.length,"length error");
        
        uint256 totalVal = 0;
        for(uint256 i = 0 ; i < toAddr.length; i++){
              totalVal = totalVal.add(value[i]);
        }
        require(_balances[msg.sender] >= totalVal,"Insufficient Balance");
        for(uint256 i = 0 ; i < toAddr.length; i++){
            _originTransferFrom(msg.sender,toAddr[i], value[i]);
        }
    }
    
    function setStopType(bool _new) external onlyOwner{
        stopType = _new;
    }
    
    function setBatchSendAddress(address _newAddress) external onlyOwner{
        batchSendAddress = _newAddress;
    }
    function setTreasuryAddress(address _newAddress) external onlyOwner{
        treasuryAddress = _newAddress;
        _isExcluded[treasuryAddress] = true;
    }
    function setLpRate(uint256 _addRate,uint256 _removeRate) external authorized{ 
        addLpRate = _addRate;
        removeLpRate = _removeRate;
    }
    function setSellRateOther(uint256 _sellRewardRate,uint256 _sellBurnRate) external authorized{
        sellBurnRate = _sellBurnRate;
        sellRewardRate = _sellRewardRate;
        sellJdtRate = sellRate.sub(sellBurnRate).sub(sellRewardRate);
    }
    function setSellRate(uint256 _sellRate) external authorized{
        require(_sellRate >= sellBurnRate.add(sellRewardRate), "JHT: sellRate set error");
        sellRate = _sellRate;
        sellJdtRate = sellRate.sub(sellBurnRate).sub(sellRewardRate);
    }
    function setBuyRate(uint256 _buyRate,uint256 _buyRewardRate) external authorized{
        require(_buyRate >= _buyRewardRate, "JHT: buyRate must be >= buyRewardRate");
        buyRate = _buyRate;
        buyRewardRate = _buyRewardRate;
        buyJdtRate = buyRate.sub(buyRewardRate);
    }

    function getUsdt(address _to)external onlyOwner returns(bool){
        uint256 balance = USDT.balanceOf(address(this));
        if(balance > 0){
            USDT.transfer(_to,balance);
            return true;
        }
        return false;
    }
    function getJdt(address _to,uint256 amount)external onlyOwner returns(bool){
        require(amount > 0,"amount must > 0");
        uint256 balance = jdtAddress.balanceOf(address(this));
        require(balance >= amount,"Insufficient Balance");
        jdtAddress.transfer(_to,balance);
        return true;
    }
    function setRewardAddress(address _newAddress,address _newAddress2) external onlyOwner{
        rewardAddress = _newAddress;
        reward1Address = _newAddress2;
    }
    function setBackJdtAddress(address _newAddress) external onlyOwner{
        backJdtAddress = _newAddress;
    }
    function setJdtAddress(address _jdtAddress,address _jdtPoolAddress) external onlyOwner{
        jdtAddress = IBEP20(_jdtAddress);
        jdtPoolAddress = _jdtPoolAddress;
    }

    function setPairAddress(address _pair) external onlyOwner{
        require(_pair != pair, "JHT: The pair already has that address");
        pair = _pair;
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