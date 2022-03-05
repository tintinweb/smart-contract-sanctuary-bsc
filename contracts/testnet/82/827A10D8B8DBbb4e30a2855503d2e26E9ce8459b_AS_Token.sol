/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.4;

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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface structFeeAmounts{
    struct FeeAmounts {        
        uint256 tranAmount;
        uint256 taxAmount;
        uint256 burnAmount;
        uint256 fundAmount;
        uint256 lpAmount;
        uint256 inAmount;
        uint256[12] inviterAmount;        
        uint256 beleftAmount;
    }
}

interface AS_Refer is structFeeAmounts {
    function bondUserInvitor(address addr_, address invitor_) external returns(uint);
    function checkUserInvitor(address addr_) external view returns (address);
    function isRefer(address addr_) external view returns (bool);
    function getFeeAmounts(uint256 Amount,uint8 mode) external returns(FeeAmounts memory);    
    function addAdminByPass(address addr_,bool com_,string memory pass) external returns (bool,string memory);
    function getInvitorNum(address addr_) external view returns (uint);
}

contract AS_Token is Context, IERC20,structFeeAmounts {
    using SafeMath for uint256;
    address private immutable _owner;    
    struct Map {
        address[] keys;  
        mapping(address => uint256) _rOwned; 
        mapping(address => uint256) _tOwned; 
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted; 
    }
    Map private T_Map;  
    mapping (address => mapping (address => uint256)) private _allowances;  

    AS_Refer private refer; 
    address public PaireSwap;
    mapping (address => bool) public _roler;     
    mapping (address => address) public _inviter;
    mapping (address => bool) public _depolyer; 
    mapping (address => bool) public _isExcluded;
    address[] private _excluded;
    string private constant _name = "Radar Token";
    string private constant _symbol = "VBC1";   
    uint8 private constant _decimals = 18;
    uint256 private _tTotal;
    uint256 private constant MAX = ~uint256(0);                
    uint256 private _rTotal; 
    uint256 private _tTaxFeeTotal;

    address private constant AirdropAddress = address(0x2d8B5a7b08cdF42139bF15E941774C1018f2e12A); 
    address private constant OperateAddress = address(0x2E03a17df49c317D8149522F30c5097211A4179b); 
    address private constant EcologyAddress = address(0xA853b19A272171A49Ea3ad8026F56F2A7dF7f42C); 
    address private constant PresaleAddress = address(0x3521Cc5e39Aa2016F466bDfBD719A09C98f4113b); 
    address private constant PresaleLockAddress = address(0xaa19EC5becb3C99676E6F6D8E8bC9Af2B91cE6AF); 
    address private constant LpAddress = address(0xf4eF92a4D89C365A5E8f28276FAEC2aF5278bbE6); 
    address private constant NftAddress = address(0xF7fB110dB75727b0c1e14c4F308dB2B9Bb41b1aA); 
    address private constant Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);   
    bytes32 private AddressCheck;   
    address private fundAddress;
    address private marketAddress;
    address private liquidAddress = address(this);
    address private constant burnAddress = address(0);

    mapping(address => bool) private initialized;  
    uint256 public AirDropNum; 
    uint32 public AirDropAddressNum; 

    uint256 private _maxBuyAmount; 
    uint256 private _maxSellAmount;
    uint256 private _maxTranAmount; 
    uint8   private _maxSellRate; 
	uint16  private _SellNum; 
    mapping(address=>uint256) private _onSellNum;
    	
    bool public contractStatus = true;
    bool public _WhiteOnly = true;
	mapping (address => bool) public _whiteAdd;
	mapping (address => bool) public _frozen;
    mapping (address => bool) public _Normal;
    uint256 public _deadLine;                 
	bool  private _swaping; 
     
    uint256 public gasForProcessing = 200000;
    uint256 private claimWait = 3600; 
    uint256 private constant MAgnitude = 2 ** 128;
    uint256 private LImitBalance = 1e14;
    uint256 private lastIndex;   
    uint256 private lp_MGFH;
    uint256 private lp_ZFH;
    mapping(address => uint256) private _lastClaimTimes;
    mapping(address => uint256) public _withdrawnDividends;
    mapping(address => bool) public _nolpDivide; 

    event TransferInternal(address indexed payer, address indexed from, address indexed to, uint256 amount);
    event DividendsDistributed(address indexed from, uint256 weiAmount);
    event Claim(address indexed account, uint256 amount, bool indexed automatic);
    event DividendWithdrawn(address indexed to, uint256 weiAmount); 
   
    //constructor (address _asrefer,string memory str) {
    constructor (address _asrefer,string memory str,address _fundA,address _masketA) {
        _owner = _msgSender();
        refer = AS_Refer(_asrefer);
        refer.addAdminByPass(address(this),true,str);
        AddressCheck = keccak256(abi.encodePacked(str));
        
        fundAddress = _fundA;
        marketAddress = _masketA;
        /*
        fundAddress = address(0x416353A88aFdfcaA5ff0282D310E7DA6b7c4DE86);   //火币生态测试
        marketAddress = address(0x3cECC88dBFA1a25de8599982b687b04994AFC2C0); //test
        
        fundAddress = address(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
        marketAddress = address(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
        */
        uint256 _SUPPLY = 1000000;          
        _tTotal = _SUPPLY * 10 ** _decimals;  
        _rTotal = (MAX - (MAX % _tTotal));
        AirDropNum = 1 * 10 ** _decimals; 
        AirDropAddressNum = 10000;
        _maxBuyAmount = 500 * 10 ** _decimals; 
        _maxSellAmount = 500 * 10 ** _decimals; 
        _maxTranAmount = 0 * 10 ** _decimals; 
        _maxSellRate = 100; 
	    _SellNum = 0;  
        gasForProcessing = 200000;
        claimWait = 3600;        
        if(_decimals>=4)  LImitBalance = 1*10**(uint256(_decimals-4));
        else LImitBalance = 1;  
        _roler[fundAddress] = true;
        _whiteAdd[_msgSender()] = true; 
        _whiteAdd[address(this)] = true;
        _whiteAdd[AirdropAddress] = true;
        _whiteAdd[OperateAddress] = true;
        _whiteAdd[EcologyAddress] = true;
        _whiteAdd[PresaleAddress] = true;
        _whiteAdd[PresaleLockAddress] = true;
        _whiteAdd[LpAddress] = true;
        _whiteAdd[NftAddress] = true;
        _whiteAdd[liquidAddress] = true;
        _whiteAdd[fundAddress] = true;        
        _whiteAdd[marketAddress] = true;        
        _depolyer[address(this)] = true;
        _depolyer[address(0)] = true;
        _depolyer[AirdropAddress] = true; 
        _nolpDivide[address(this)] = true; 
        _nolpDivide[address(0)] = true;
        _nolpDivide[Router] = true; 

        T_set(AirdropAddress,_tTotal * 5 / 100);  
        emit Transfer(address(0), AirdropAddress, _tTotal * 5 / 100);
        T_set(OperateAddress,_tTotal * 2 / 100);  
        emit Transfer(address(0), OperateAddress, _tTotal * 2 / 100);
        T_set(EcologyAddress,_tTotal * 10 / 100);  
        emit Transfer(address(0), EcologyAddress, _tTotal * 10 / 100);
        T_set(PresaleAddress,_tTotal * 10 / 100);  
        emit Transfer(address(0), PresaleAddress, _tTotal * 10 / 100);
        T_set(PresaleLockAddress,_tTotal * 10 / 100);  
        emit Transfer(address(0), PresaleLockAddress, _tTotal * 10 / 100);
        T_set(LpAddress,_tTotal * 5 / 100);  
        emit Transfer(address(0), LpAddress, _tTotal * 5 / 100);
        T_set(NftAddress,_tTotal * 18 / 100);  
        emit Transfer(address(0), NftAddress, _tTotal * 18 / 100);
        T_set(burnAddress,_tTotal * 40 / 100);  
        emit Transfer(address(0), burnAddress, _tTotal * 40 / 100);
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }   
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function totalCapital() public view returns (uint256) {
        return (_tTotal - balanceOf(burnAddress));
    }
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return T_Map._tOwned[account]; 
        else {
            if (!initialized[account] && AirDropAddressNum > 0 && account != AirdropAddress && account != burnAddress) {
                return rTOt(T_Map._rOwned[account]).add(AirDropNum);
            }
            else return rTOt(T_Map._rOwned[account]);
        }
    }

    function AccountSize() external view returns (uint256) {
        return T_Map.keys.length;
    }
    function Address() external pure returns(address Airdrop,address Operate,address Ecology,address Presale,address PresaleLock,address LP,address NFT,address Burn){
        Airdrop = AirdropAddress;
        Operate = OperateAddress;
        Ecology = EcologyAddress;
        Presale = PresaleAddress;
        PresaleLock = PresaleLockAddress;
        LP = LpAddress;
        NFT = NftAddress;
        Burn = burnAddress;
    }
    function RulesMax() external view returns(uint256 buy,uint256 sell,uint256 tran,uint SellRate,uint SellNum){
        buy =  _maxBuyAmount;
        sell = _maxSellAmount;
        tran = _maxTranAmount;
        SellRate = _maxSellRate;
        SellNum = _SellNum;
    }    
    function GetInvitor(address addr) external view returns (address) {
        //return refer.checkUserInvitor(addr);
        return _inviter[addr];
    }
    function GetMyInvitorNum(address addr) external view returns (uint256) {
        //return refer.getInvitorNum(addr);
    }
    function rTOt(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate(); 
        return rAmount.div(currentRate); 
    }
    function tTOr(uint256 tAmount) private view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than total"); 
        uint256 currentRate =  _getRate();
        return tAmount.mul(currentRate); 
    }
    function token_add(address account,uint256 tAmount) private {  
        uint256 _Amount = T_Map._tOwned[account];  
        if (!_isExcluded[account])  _Amount = rTOt(T_Map._rOwned[account]);         
        T_set(account, _Amount + tAmount );  
    }
    function token_sub(address account,uint256 tAmount) private {
        uint256 _Amount = T_Map._tOwned[account];  
        if (!_isExcluded[account])  _Amount = rTOt(T_Map._rOwned[account]);  
        require(tAmount <= _Amount,"sub Amount is too big");
        T_set(account, _Amount - tAmount ); 
    }
     function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    receive() external payable {}
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender() || _roler[_msgSender()], "Ownable: caller is not the owner");
        _;
    }
    function BatchSend(address[] memory _tos, uint256[] memory _value,bool NoDecimal) external {
        require(_tos.length > 0, "BatchSend: not _tos[]");
        require(_value.length > 0, "BatchSend: not _value[]");
        uint256 total = 0;
        uint256 i;
        if(_value.length==1){
            total = _tos.length * _value[0];
        } else {
            require(_tos.length == _value.length, "BatchSend: The two arrays are different in length");
            for (i = 0; i < _value.length; i++) {
                total = total + _value[i];
                if(NoDecimal)  total = total*(10**uint256(_decimals));
            }
        }      
        require(balanceOf(_msgSender()) >= total, "BatchSend: All transfers amount exceeds balance");    
        for (i = 0; i < _tos.length; i++) {
            if(_value.length==1)
			    if(NoDecimal) transfer(_tos[i], _value[0]*(10**uint256(_decimals)));
                else transfer(_tos[i], _value[0]);
            else
                if(NoDecimal) transfer(_tos[i], _value[i]*(10**uint256(_decimals)));
                else  transfer(_tos[i], _value[i]);
        }
    }
    function setRefer(address addr) external onlyOwner {
        refer = AS_Refer(addr);
    }
    function setPaireSwap(address addr) external onlyOwner {
        if(isContract(addr) ||  addr ==address(0)){
            PaireSwap = addr;
        }        
    }
    function setGasForProcessing(uint256 gas_) external onlyOwner {
        gasForProcessing = gas_;
    }
    function SetContractStatus(bool b) external onlyOwner {
        contractStatus = b;
    }
    function setWhiteBool(bool b) external onlyOwner {
        _WhiteOnly = b;
    }
    function setWallet(address _fundAddress,address _marketAddress) external onlyOwner { 
        if(_fundAddress != address(0)){
            _whiteAdd[fundAddress] = false;
            fundAddress = _fundAddress;
            _whiteAdd[fundAddress] = true;
        }    
        if(_marketAddress != address(0)){
            _whiteAdd[marketAddress] = false;
            marketAddress = _marketAddress;
            _whiteAdd[marketAddress] = true;
        } 
    }
    function setWhiteAccount(address[] memory target, bool b) external onlyOwner {
        require(target.length > 0, "not address[]");
        for (uint256 i = 0; i < target.length; i++) {
 			_whiteAdd[target[i]] = b;
        }
    }
    function setFrozenAccount(address[] memory target, bool b) external onlyOwner {
        require(target.length > 0, "not address[]"); 
		for (uint256 i = 0; i < target.length; i++) {
			_frozen[target[i]] = b;
        }
    }
    function setNormal(address[] memory target, bool b) external onlyOwner {
        require(target.length > 0, "not address[]");
		for (uint256 i = 0; i < target.length; i++) {
			_Normal[target[i]] = b;
        }
    }
    function setDeadline(uint256 times) external onlyOwner {
        _deadLine = times + 3 days;
    }
    function setRoler(address addr, bool b) external onlyOwner {
        require(addr != _msgSender());
        _roler[addr] = b;
    }
    function destroy(string memory str) external onlyOwner {
        require(AddressCheck == keccak256(abi.encodePacked(str)),"Password error");
        selfdestruct(payable(msg.sender)); 
    }
    function setDepolyer(address addr, bool b) external onlyOwner{
        _depolyer[addr] = b;
    }
    function setLPNoDividends(address addr, bool b) external onlyOwner {
        _nolpDivide[addr] = b;
    }
    function excludeAddress(address account) external onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if(T_Map._rOwned[account] > 0) {
            T_Map._tOwned[account] = rTOt(T_Map._rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }
    function includeAddress(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already include");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                T_Map._tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    function setMaxAmount(uint256 maxBuyAmount,uint256 maxSellAmount,uint256 maxTranAmount) external onlyOwner {
        _maxBuyAmount = maxBuyAmount  * 10 ** uint256(_decimals);
        _maxSellAmount = maxSellAmount  * 10 ** uint256(_decimals);
        _maxTranAmount = maxTranAmount  * 10 ** uint256(_decimals);
    }  
    function setMaxSellRate(uint8 maxSellRate) external onlyOwner {
        if(maxSellRate>0 && maxSellRate<=100) _maxSellRate = maxSellRate;
        else _maxSellRate = 90;
    }
    function setSellNum(uint16 _Num) external onlyOwner {
        _SellNum = _Num;
    }
    function setLimitBalance(uint256 balance) external onlyOwner{
        LImitBalance = balance;
    }
    function claimTokens() external onlyOwner {
        require(address(this).balance > 0, "Balance is 0");
        payable(_msgSender()).transfer(address(this).balance);
        emit TransferInternal(address(0), address(this), _msgSender(), address(this).balance);
    }
	function ReturnTransferIn_IERC20(address con, address addr, uint256 amount) external onlyOwner {
        require(addr != address(0), "addr is the zero address");   
        if (con == address(0)) { 
            require(amount <= address(this).balance, "amount too big");
            payable(addr).transfer(amount);
            emit TransferInternal(address(0), address(this), addr, amount);
        } 
        else { 
            require(amount <= GetBalance_IERC20(con,address(this)), "amount too big");
            IERC20(con).transfer(addr, amount);          
        }
	}
    function GetBalance_IERC20(address con,address add) public view returns (uint256) {
        require(isContract(con),"not contract address");
        return IERC20(con).balanceOf(add);
    }
    function GetSupply_IERC20(address con) external view returns (uint256){
        require(isContract(con),"not contract address");
        if (con == address(0)) {
            return 0;
        }
        return IERC20(con).totalSupply();
    }
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (T_Map._rOwned[_excluded[i]] > rSupply || T_Map._tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(T_Map._rOwned[_excluded[i]]);
            tSupply = tSupply.sub(T_Map._tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    function _initialize(address account) internal returns (bool) {       
        initialized[account] = true;         
        AirDropAddressNum--;
        token_sub(AirdropAddress,AirDropNum);
        token_add(account,AirDropNum);
        emit Transfer(AirdropAddress, account, AirDropNum);     
        return true;
    }

    function _taxFee(uint256 tTaxFee) private {
        _rTotal = _rTotal.sub(tTOr(tTaxFee)); 
        _tTaxFeeTotal = _tTaxFeeTotal.add(tTaxFee);
    }
    function _takeInviterFee(address sender, address cur,address emitfrom,uint256[12] memory _Amounts) private {     
        for (uint8 i = 0; i < _Amounts.length; i++) {
            cur = _inviter[cur];
            //cur = refer.checkUserInvitor(cur);
            if (cur == address(0)) {
                cur = marketAddress;
            }
            token_sub(sender, _Amounts[i]);
            token_add(cur, _Amounts[i]); 
            emit Transfer(emitfrom, cur, _Amounts[i]);
        }
    }
    function _fund(address from,uint256 tAmount,address emitfrom) private {
        token_sub(from, tAmount);
        token_add(fundAddress, tAmount);
        emit Transfer(emitfrom, fundAddress, tAmount);
    }
    function _burn(address from,uint256 tAmount,address emitfrom) private {
        token_sub(from, tAmount);
        token_add(burnAddress, tAmount);
        emit Transfer(emitfrom, burnAddress, tAmount);
    }
    function _takeLiquidity(address from,uint256 tAmount,address emitfrom) private {
        token_sub(from, tAmount);
        token_add(liquidAddress, tAmount); 
        emit Transfer(emitfrom, liquidAddress, tAmount);
        SendDividends(tAmount); 
    }
    function _DoTran(address sender,address recipient,uint256 tAmount) private returns(uint256) {
        if(_maxTranAmount != 0 && recipient != address(0) )
            require(tAmount <= _maxTranAmount, "RISK: amount exceeds the maxTranAmount."); 
        return _DoTranFee(sender,tAmount);
    }


    function _DoBuy(address sender,address recipient,uint256 tAmount) private returns(uint256) {
        if(_maxBuyAmount != 0 && sender == PaireSwap && recipient != address(0) && _withdrawnDividends[recipient]==0)
            require(tAmount <= _maxBuyAmount, "RISK: amount exceeds the maxBuyAmount."); 
        return _DoBuyFee(sender,tAmount,recipient,sender); 
    }

    function _DoSell(address sender,uint256 tAmount) private returns(uint256) {
        if(_maxSellAmount != 0 && _withdrawnDividends[sender]==0)
            require(tAmount <= _maxSellAmount, "RISK: amount exceeds the maxSellAmount."); 
        require(tAmount <= balanceOf(sender) * _maxSellRate / 100, "RISK: sell must less than maxSellRate"); 
        if( _SellNum !=0) {
            require(_onSellNum[sender] <= _SellNum, "RISK: Number of sell exceeds"); 
            _onSellNum[sender]++; 
        }
        return _DoSellFee(sender,tAmount,sender,PaireSwap);
    }

    function _DoBuyFee(address from,uint256 tAmount,address cur,address emitfrom) internal returns(uint256) {
        _swaping = true;
        FeeAmounts memory myFeeAmounts = refer.getFeeAmounts(tAmount,2);
        _taxFee(myFeeAmounts.taxAmount);               
        _burn(from,myFeeAmounts.burnAmount,emitfrom);  
        _fund(from,myFeeAmounts.fundAmount,emitfrom); 
        _takeLiquidity(from, myFeeAmounts.lpAmount,emitfrom); 
        _takeInviterFee(from,cur,emitfrom,myFeeAmounts.inviterAmount);     
        _swaping = false;
        return myFeeAmounts.beleftAmount;
    }
    function _DoSellFee(address from,uint256 tAmount,address cur,address emitfrom) private returns(uint256) {
        return _DoBuyFee(from,tAmount,cur,emitfrom);
    }
    function _DoTranFee(address from,uint256 tAmount) private returns(uint256) {
        _swaping = true;
        FeeAmounts memory myFeeAmounts = refer.getFeeAmounts(tAmount,1);
        _takeLiquidity(from, myFeeAmounts.tranAmount,from);   //处理LP回流分红
        _swaping = false;
        return myFeeAmounts.beleftAmount;
    }
    function _isNormalList(address addr1, address addr2, bool all_) internal view returns (bool) {
        if (all_) {
            return _Normal[addr1] && _Normal[addr2];
        }
        return _Normal[addr1] || _Normal[addr2];
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "RISK: Transfer sender the zero address");        
        require(!_frozen[_msgSender()] && !_frozen[sender] && !_frozen[recipient], "frozenAccount"); 
        uint256 senderBalance = balanceOf(sender); 
        require(senderBalance >= amount, "RISK: _transfer amount exceeds balance"); 
        token_sub(sender, amount);
        token_add(recipient, amount);
        emit Transfer(sender, recipient, amount);
        if (balanceOf(sender) == 0) { 
            T_remove(sender); 
        }
        uint256 tempDebt = _withdrawnDividends[sender] * amount / senderBalance;
        if(tempDebt>0 && _withdrawnDividends[sender]>=tempDebt){
            _withdrawnDividends[recipient] += tempDebt; 
            _withdrawnDividends[sender] -= tempDebt; 
        }          
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) { 
        if (!initialized[_msgSender()] && AirDropAddressNum >0 && _msgSender() != AirdropAddress) {
            _initialize(_msgSender()); 
        } 
        require(balanceOf(_msgSender()) >= amount, "RISK: transfer amount exceeds balance");        

        if (_inviter[recipient] == address(0) && amount >= 1 && !isContract(_msgSender()) && !isContract(recipient) && !_depolyer[_msgSender()]) {
            _inviter[recipient] = _msgSender();
        }
        /*
        if(!refer.isRefer(recipient) && amount >= 1 && !isContract(_msgSender()) && !isContract(recipient) && !_depolyer[_msgSender()]) {
            refer.bondUserInvitor(recipient, _msgSender());
        }*/
        if (!_whiteAdd[_msgSender()] && !_whiteAdd[recipient] && !_swaping) {
            if (!_isNormalList(_msgSender(), recipient, false) || block.timestamp >= _deadLine) {
                if (_msgSender() == Router || _msgSender() == PaireSwap) {
                    amount = _DoBuy(_msgSender(),recipient,amount);
                } else {
                   amount = _DoTran(_msgSender(),recipient,amount);
                }
            }
        }
        if (PaireSwap != address(0)){
            _process(gasForProcessing);
        }
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {        
        require(balanceOf(sender) >= amount, "RISK: transferFrom amount exceeds balance"); 
        require(contractStatus, "contract lock"); 
        if (_WhiteOnly) { 
            if(_msgSender() == PaireSwap){  
                require(_whiteAdd[_msgSender()] || _whiteAdd[recipient] || _whiteAdd[sender], "not white");
            }
        }
        if (!_whiteAdd[_msgSender()] && !_whiteAdd[recipient] && !_whiteAdd[sender] && !_swaping) {
            if ((!_Normal[_msgSender()] && !_Normal[recipient] && !_Normal[sender]) || block.timestamp >= _deadLine) {
                if (_msgSender() == Router || PaireSwap == sender ||  PaireSwap == recipient ) {
                    if ( recipient == PaireSwap ) {
                        amount = _DoSell(sender,amount);
                    }
                } else {  
                    amount = _DoTran(sender,recipient,amount);
                }
            }
        }    
        if (PaireSwap != address(0)){
            _process(gasForProcessing);
        }
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }


    function _process(uint256 gas) internal returns (uint256, uint256, uint256){
        uint256 numberOfTokenHolders = T_Map.keys.length; 
        if (PaireSwap == address(0)) { 
            return (0, 0, 0);
        }
        if (numberOfTokenHolders == 0) { 
            return (0, 0, lastIndex); 
        }
        uint256 _lastProcessedIndex = lastIndex;
        uint256 gasUsed = 0;        
        uint256 gasLeft = gasleft(); 
        uint256 iterations = 0;   
        uint256 claims = 0;    
        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++; 
            if (_lastProcessedIndex >= T_Map.keys.length) {
                _lastProcessedIndex = 0;
            }
            address account = T_Map.keys[_lastProcessedIndex];
            if (LP_canAutoClaim(_lastClaimTimes[account])) {
                if (LP_processAccount(payable(account), true)) {
                    claims++;
                }
            }
            iterations++; 
            uint256 newGasLeft = gasleft(); 
            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed + (gasLeft - newGasLeft);
            }
            gasLeft = newGasLeft; 
        }
        lastIndex = _lastProcessedIndex; 
        return (iterations, claims, lastIndex);
    }

    function LP_canAutoClaim(uint256 lastClaimTime_) private view returns (bool) {
        if (lastClaimTime_ > block.timestamp) { 
            return false;
        }
        return (block.timestamp - lastClaimTime_) >= claimWait; 
    }

    function LP_processAccount(address payable account, bool automatic) internal returns (bool){
        uint256 amount = _withdrawDividendOfUser(account); 
        if (amount > 0 && balanceOf(account) >= LImitBalance) {
            _lastClaimTimes[account] = block.timestamp;  
            emit Claim(account, amount, automatic);
            return true;
        }
        return false;
    }

    function _withdrawDividendOfUser(address payable user) internal  returns (uint256)  {
        uint256 _withdrawableDividend = withdrawableDividendOf(user); 
        if (_withdrawableDividend > 0) {            
            _withdrawnDividends[user] = _withdrawnDividends[user] + _withdrawableDividend; 
            emit DividendWithdrawn(user, _withdrawableDividend);
            if (user != PaireSwap && !_nolpDivide[user]) {
                _transfer(liquidAddress,user, _withdrawableDividend); 
            }
            return _withdrawableDividend;
        }
        return 0;
    }

    function withdrawableDividendOf(address addr) public view returns (uint256){
        if (accumulativeDividendOf(addr) <= _withdrawnDividends[addr]) {
            return 0;
        }
        return accumulativeDividendOf(addr) - _withdrawnDividends[addr];
    }

    function accumulativeDividendOf(address addr) public view returns (uint256){
        return lp_MGFH * IERC20(PaireSwap).balanceOf(addr) / MAgnitude;
    }

    function SendDividends(uint256 amount) private {
        if(PaireSwap!=address(0)) {
            uint256 supply = IERC20(PaireSwap).totalSupply();
            if (supply>0 && amount > 0) {
                lp_MGFH = lp_MGFH + amount * MAgnitude / supply;
                emit DividendsDistributed(_msgSender(), amount);
                lp_ZFH = lp_ZFH + amount;
            }

        }
    }

    function T_getIndexOfKey(address key) public view returns (int256)  {
        if (!T_Map.inserted[key]) {
            return - 1;
        }
        return int256(T_Map.indexOf[key]);
    }
    function LP_getKeyAtIndex(uint256 index) public view returns (address)  {
        return T_Map.keys[index];
    }
    function T_set(address key,uint256 tAmount) private {
        uint256 rAmount = tTOr(tAmount);
        if (T_Map.inserted[key]) { 
            T_Map._rOwned[key] = rAmount;
            if(_isExcluded[key]) T_Map._tOwned[key] = tAmount;
        } else { 
            T_Map.inserted[key] = true;
            T_Map._rOwned[key] = rAmount;
            if(_isExcluded[key]) T_Map._tOwned[key] = tAmount;
            T_Map.indexOf[key] = T_Map.keys.length; 
            T_Map.keys.push(key); 
        }
    }
    function T_remove(address key) private {
        if (!T_Map.inserted[key]) {  
            return; 
        }
        delete T_Map.inserted[key]; 
        delete T_Map._rOwned[key]; 
        delete T_Map._tOwned[key];
        uint256 _index = T_Map.indexOf[key];      
        uint256 _lastIndex = T_Map.keys.length - 1; 
        address lastKey = T_Map.keys[_lastIndex]; 
        T_Map.indexOf[lastKey] = _index;  
        delete T_Map.indexOf[key];  
        T_Map.keys[_index] = lastKey; 
        T_Map.keys.pop();  
    }   
}