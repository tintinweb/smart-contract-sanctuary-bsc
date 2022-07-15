/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// File: 终版子币兑分红.sol


pragma solidity ^0.8.0;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address PancakePair);
}
interface IRouter {
    function factory() external pure returns (address);
}
interface IPair {
    function getReserves() external view returns ( uint112 reserve0,uint112 reserve1,uint32 blockTimestampLast);

    function factory() external view returns (address);

    function kLast() external view returns (uint);

    function totalSupply() external view returns (uint);
}
library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }
    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
library Utils{
    function codeHash(address account) internal view returns (bytes32) {
        bytes32 codehash;
        assembly {
            codehash := extcodehash(account)
        }
        return codehash;
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract TokenRepository  {
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "DENIED");
        _;
    }
    constructor(address _owner){owner = _owner;}
    receive() external payable {revert();} 
    function withdraw(IERC20 _token, address _recipient) public onlyOwner(){
        _token.transfer(_recipient, _token.balanceOf(address(this)));
    }
}

contract HotTokenV2 is Context {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    enum TransferType{
        Transfer,
        AddLiquidity,
        RemoveLiquidity,
        Buy,
        Sell
    }

    address public _owner;
    modifier onlyOwner() {
        require(msg.sender == _owner, "DENIED");
        _;
    }

    uint public constant MINIMUM_LIQUIDITY = 10**3;


    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint256 private _decimals;
    address private _mainPair;
    bytes32 private _tokenPairHash;
    mapping(address => address) private _tokenAddresses;
    address private _tokenRouter;

    uint256 immutable private unitBase;

    mapping(address => mapping(address => uint256)) public _lastLps;

    mapping(address => mapping(address => uint256)) private _LockLpDates;
    uint256  private _lockLpsInterval = 300; 
    uint256  private _openLpsInterval = 600;  

    mapping(address => address) private _upLines;
    uint256 constant private uplevel = 3;          
    
    mapping(address => bool) private _banList;

    TokenRepository _rewardsRepos;
    uint256 constant private rewardsBalanceRequire = 500;
    uint256 constant private rewardsInterval = 600;
    uint256 constant private rewardsRate = 500;
    uint256 constant private rewardsRatio = 10000;
    uint256 constant private rewardsDisRate = 3000;
    mapping(address => uint256) private _lastRewardsDates;

    TokenRepository _bonusRepos;
    uint256 private _lastBonusDate;
    uint256 private _lastBonusOffset;
    address[]       _tradeAccounts;
    uint256 constant private bonusInterval = 1200;
    uint256 constant private bonusTradeRequire = 15;
    uint256 constant private bonusRate = 100;
    uint256 constant private bonusCount = 10;

    uint256 constant private inviteRate = 200;

    uint256 constant private remainRate = 100;

    uint256 constant private divBase = 10000;

    uint256 private sellLockInterval = 600;

    mapping(address => uint256) private _sellLockDates;

    bool    private accumulateTax;
    
    mapping(address => uint256) private _taxBase;

    address immutable private feeAddress;
    uint256 constant private feeRate = 2000;

    uint256 constant private tradeLimit = 200;

    uint256 constant private maxHold = 1000;

    uint256 private  rmLpRequire = 30000;

    bool    private  isCC;
    
    constructor(string memory name_, string memory symbol_,uint256 decimals_,uint256 total,address router_,address token_,address feeAddress_) {
        _owner = _msgSender();
        _lastBonusDate = block.timestamp;
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _tokenRouter = router_;
        feeAddress = feeAddress_;
        unitBase = 10**_decimals;
        _mint(msg.sender, total*10**_decimals);
        address tokenPair = IFactory(IRouter(router_).factory()).createPair(
            token_,
            address(this)
        );
        _mainPair = tokenPair;
        _tokenAddresses[tokenPair] = token_;
        _tokenPairHash = Utils.codeHash(tokenPair);
        _rewardsRepos = new TokenRepository(_msgSender());
        _bonusRepos = new TokenRepository(_msgSender());
    }

    function name() public view  returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view  returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner_, address spender) public view  returns (uint256) {
        return _allowances[owner_][spender];
    }


    function approve(address spender, uint256 amount) public returns (bool) {
        
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function _isPancakePair(address account) internal view returns(bool){
        return Utils.codeHash(account) == _tokenPairHash;
    }
    
    function _countLiquidity(address pair,uint256 balance0, uint256 balance1,uint256 reserve0, uint256 reserve1) internal view returns (uint liquidity) {
        uint kLast = IPair(pair).kLast();
        uint totalLP= IPair(pair).totalSupply();
        if (kLast != 0) {
            uint rootK = Math.sqrt(reserve0*reserve1);
            uint rootKLast = Math.sqrt(kLast);
            if (rootK > rootKLast) {
                uint numerator = totalLP*(rootK-rootKLast)*8;
                uint denominator = rootK*17+rootKLast*8;
                totalLP += numerator / denominator;
            }
        }
        uint amount0 = balance0 - reserve0;
        uint amount1 = balance1 - reserve1;
        if (totalLP == 0) {
            liquidity = Math.sqrt(amount0*amount1)-MINIMUM_LIQUIDITY;
        } else {

            // console.log("mp",reserve0,reserve1,address(this));
            // console.log("mp",amount0,balance0,balance1);
            liquidity = Math.min(amount0*totalLP / reserve0, amount1*totalLP / reserve1);
        }
    }
    function _addLiquidityImp(address user,address to,uint256 liquidity) internal {
        address pair = to;
        uint256 currentLp = IERC20(pair).balanceOf(user);
        if(currentLp > _lastLps[pair][user]){
            _LockLpDates[pair][user] = block.timestamp;
            _lastRewardsDates[user] = _LockLpDates[pair][user];
            _lastLps[pair][user] = currentLp + liquidity;
        }else{
            _lastLps[pair][user] += liquidity;
        }
    }
    function _removeLiquidityImp(address from,address user,uint256 liquidity,uint256 remain) internal {
        require(remain>=rmLpRequire*unitBase);
        address pair = from;
        uint256 currentLp = IERC20(pair).balanceOf(user);
        if(_lastLps[pair][user] >= currentLp+liquidity){
            _lastLps[pair][user] = currentLp;
            uint256 pastTime = block.timestamp - _LockLpDates[pair][user];
            uint256 period = _lockLpsInterval + _openLpsInterval;
            uint256 offsetTime = pastTime%period;
            if(offsetTime>=_lockLpsInterval&&offsetTime<=_openLpsInterval){
               
            }else{revert("faild");}
        }else{
         
            revert("faild");
        }
    }    
    function _analyseType(bool isFromPancakePair,bool isToPancakePair,address from,address to,uint256 amount) internal returns (TransferType transferType,uint256 liquidity){
        if(isFromPancakePair){
            address token = _tokenAddresses[from];
            if(token == address(0)){
                transferType = TransferType.Buy;
                return (transferType,0);
            }
            uint256 balance0 = IERC20(token).balanceOf(from);
            uint256 balance1 = balanceOf(from);
            (uint256 reserve0,,) = IPair(from).getReserves();
            if(balance0 < reserve0){
                 
                uint totalLP= IPair(from).totalSupply();
                uint amount0 = reserve0 - balance0;
                uint amount1 = amount;
                liquidity = Math.min(amount0*totalLP / balance0, amount1*totalLP / balance1);
                _removeLiquidityImp(from,to,liquidity,reserve0);
                transferType = TransferType.RemoveLiquidity;
               
            }else{
                transferType = TransferType.Buy;
            }
        }else if(isToPancakePair&&_msgSender() == _tokenRouter){
            address token = _tokenAddresses[to];
            // console.log(pair,to,"8888888888888888888");
            if(token == address(0)){
                transferType = TransferType.Sell;
                return (transferType,0);
            }
            uint256 balance0 = IERC20(token).balanceOf(to);
            uint256 balance1 = balanceOf(to);
            (uint256 reserve0,uint256 reserve1,) = IPair(to).getReserves();
            if(balance0 > reserve0){
                liquidity = _countLiquidity(to,balance0,balance1,reserve0,reserve1);
                transferType = TransferType.AddLiquidity;
                _addLiquidityImp(from,to,liquidity);
            }else{
                transferType = TransferType.Sell;
            }
        }else{
            transferType = TransferType.Transfer;
        }
    }
    function _processInviteRewards(address sender, uint256 rewards) internal returns(uint256) {
        
        uint256 remain = rewards;
        address upLine = _upLines[sender];
        if(upLine == address(0))return remain;
        for(uint256 i; i<uplevel; i++) {
            rewards = rewards/2;
            remain -= rewards;
            _unsafeTransfer(sender, upLine, rewards); 
            upLine = _upLines[upLine];
            if(upLine == address(0))break;
        }
        return remain;
    }
    function _processRewards(address user,uint256 currentLp) internal {
                
       uint256 rewardsAmount = balanceOf(address(_rewardsRepos));
      
       if(currentLp>0&&rewardsAmount >= rewardsBalanceRequire*unitBase&&
       block.timestamp>=_lastRewardsDates[user]+rewardsInterval){
         
          uint256 amount = rewardsAmount*rewardsDisRate*currentLp/(IERC20(_mainPair).totalSupply()*divBase);
          uint256 fee = amount*feeRate/divBase;
          _unsafeTransfer(address(_rewardsRepos), user, amount - fee); 
          _lastRewardsDates[user] = block.timestamp;
          _balances[address(_rewardsRepos)] -= fee;
          _balances[feeAddress] += fee;
       }
    }
    function _rand(uint256 _length) internal view returns(uint256) {
        uint nonce = gasleft();
        uint256 random = uint256(keccak256(abi.encodePacked(nonce, msg.sender, block.difficulty, block.timestamp)));
        return random%_length;
    }
    function _processBonus(address user) internal{
       _tradeAccounts.push(user);
       if(block.timestamp>=_lastBonusDate+bonusInterval&&_tradeAccounts.length>=bonusTradeRequire+_lastBonusOffset){
            uint256 reward = balanceOf(address(_bonusRepos))/bonusCount;
            for(uint256 i;i<bonusCount; i++) {
                uint256 index = _rand(_tradeAccounts.length-_lastBonusOffset);
                _unsafeTransfer(address(_bonusRepos), _tradeAccounts[_lastBonusOffset+index], reward);
            }
            _lastBonusDate = block.timestamp;
            _lastBonusOffset = _tradeAccounts.length - 1;
       }
    }

    function _isInMainPair(address from,address to) view internal returns(bool){
        if(_mainPair == from||_mainPair == to)return true;
        return false;
    }
    function _extendImp(address from,address to,uint256 amount,bool bTransfer) internal {    
        address payer = to; //in
        uint256 rewardsTax;
        bool isFromPancakePair = _isPancakePair(from);
        bool isToPancakePair = _isPancakePair(to);
        if(bTransfer&&!isFromPancakePair){
            //setting upLine;
            if(_upLines[to] == address(0)){
                _upLines[to] = from;
            }
        }
        if(isCC)return;
        (TransferType transferType,) = _analyseType(isFromPancakePair,isToPancakePair, from, to, amount);
        if(transferType != TransferType.AddLiquidity&&transferType != TransferType.Transfer&&transferType != TransferType.Buy){
            require(amount <= tradeLimit*unitBase,"trade limit");
        }
        if(transferType != TransferType.Buy){
            require(!_banList[from],"banned");
        }
        if(transferType == TransferType.Sell||transferType == TransferType.RemoveLiquidity){
            if(block.timestamp>=_sellLockDates[from]+sellLockInterval){
                _taxBase[from] = rewardsRate;
                _sellLockDates[from] = block.timestamp;
            }else{
                if(accumulateTax){
                    _taxBase[from] = Math.min(_taxBase[from] + _taxBase[from]*rewardsRatio/divBase,10000);
                }
                else{
                    revert("sell is locking");
                }
            }
            rewardsTax = _taxBase[from];
        }else{
            rewardsTax = rewardsRate;
        }
        if(transferType != TransferType.Buy&&transferType != TransferType.RemoveLiquidity){
            //out
            uint256 needAmount = (amount*(inviteRate+_taxBase[from]+bonusRate)/divBase); 
            require(balanceOf(from)>=needAmount,"insufficient balance");
            uint256 remainAmount = balanceOf(from)-needAmount;
            require(remainAmount>=amount*remainRate/divBase,"the balance is less than min ");
            payer = from;
        }else{
            //in
            require(balanceOf(payer) <= maxHold*unitBase,"the balance must be less than or equal to assign");
        }
        uint256 remain;   
        if(_isInMainPair(from,to)||((!isFromPancakePair)&&(!isToPancakePair))){
            remain = _processInviteRewards(payer,amount*inviteRate/divBase);
            _unsafeTransfer(payer, address(_bonusRepos), amount*bonusRate/divBase);
            _processBonus(payer);
        }
        _unsafeTransfer(payer, address(_rewardsRepos), amount*rewardsTax/divBase+remain);  
        // to lock and sync lps
        if(transferType != TransferType.RemoveLiquidity&&transferType != TransferType.AddLiquidity){
            address user = from;
            if(transferType == TransferType.Buy){
                user = to;
            }

            address pair;
            if(isFromPancakePair||isToPancakePair){
                pair = isFromPancakePair?from:to;
            }else{
                pair = _mainPair;
            }
            if(pair != address(0)){
                uint256 currentLp = IERC20(pair).balanceOf(user);
                if(currentLp > _lastLps[pair][user]){
                    _LockLpDates[pair][user] = block.timestamp;
                    _lastRewardsDates[user] = _LockLpDates[pair][user];
                }
                _lastLps[pair][user] = currentLp;
                if(transferType == TransferType.Buy&&pair == _mainPair){
                    _processRewards(to,currentLp);
                }
            }
            
        } 
    }
    function transfer(address to, uint256 amount) public returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        _extendImp(owner,to,amount,true);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public  returns (bool) {
        
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        _extendImp(from,to,amount,false);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
   
    function _unsafeTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        uint256 fromBalance = _balances[from];

        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function setOwner(address owner) onlyOwner public{
        _owner = owner;
    }

    function ban(address account,bool isBan) onlyOwner public{
        _banList[account] = isBan;
    }

    function setLPInfo(uint256 lockLpsInterval,uint256 openLpsInterval) onlyOwner public{
        _lockLpsInterval = lockLpsInterval;
        _openLpsInterval = openLpsInterval; 
    }

    function batchTransfer(uint256 amount, address[] calldata list) onlyOwner public {
        for (uint256 i; i < list.length; i++) {
            _transfer(_msgSender(), list[i], amount);
        }
    }

    function withdraw(address _recipient) public onlyOwner(){
        _transfer(address(this), _recipient,balanceOf(address(this)));
    }

    function cc(bool _cc)public onlyOwner(){
        isCC = _cc;
    }

    function setRMLpRequire(uint256 amount) public onlyOwner(){
        rmLpRequire = amount;
    }

    function setAccumulateTax(bool isTax) public onlyOwner(){
        accumulateTax = isTax;
    }

    function setSLI(uint256 sli) public onlyOwner(){
        sellLockInterval = sli;
    }
    
    function createPair(address token) public {
        require(msg.sender == _owner||msg.sender == address(0), "DENIED");
        require(token < address(this),"token must be less than the main");
        address tokenPair = IFactory(IRouter(_tokenRouter).factory()).createPair(
            token,
            address(this)
        );
        require(_tokenAddresses[tokenPair] == address(0),"the pair already exists");
        _tokenAddresses[tokenPair] = token;
    }

}