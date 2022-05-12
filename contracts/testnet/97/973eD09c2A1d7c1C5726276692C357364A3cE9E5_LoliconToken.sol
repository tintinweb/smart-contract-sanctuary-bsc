/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 *  pancake interface
 */
 
interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IPancakeRouter {
     function WETH() external pure returns (address);
     function factory() external pure returns (address);
} 

interface IPancakePair{
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IPinkAntiBot {
  function setTokenOwner(address owner) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external;
}

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    address internal _owner;
    address internal _taxwallet;
    uint256 internal _TaxToLP = 0;      // prosentase
    uint256 internal _TaxBurn = 0;      // prosentase
    uint256 internal _TaxPercent = 100; // prosentase

    /* tambahan untuk buy dan sell fee =============================== */
    uint256 internal _sellFee = 0;
    uint256 internal _buyFee = 0; 
    /* =============================================================== */

    uint256 internal _totalSupply;

    address public immutable pairAddress;
    bool public pinkAntiBotStatus = false;
    IPinkAntiBot internal pinkAntiBot;

    mapping(address => bool) internal _isExcludedFromSellFee;
    mapping(address => bool) internal _isExcludedFromBuyFee;

    /* 4 HERE ====================================== */
    mapping(address => uint256) internal _blacklist;
    mapping(address => uint256) internal _airdropsEvents;
    uint256 public LastEventID = 0;
    uint8 public LastMSR = 0;
    /* END:4 HERE ================================== */

    constructor() {

        // Initiate PinkAntiBot instance from its address
        pinkAntiBot = IPinkAntiBot(0xbb06F5C7689eA93d9DeACCf4aF8546C4Fe0Bf1E5); // test net
        //pinkAntiBot = IPinkAntiBot(0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002); // Main Net 

        pinkAntiBot.setTokenOwner(msg.sender);

        //IPancakeRouter _router = IPancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //for test
        IPancakeRouter _router = IPancakeRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // testnet !
        //IPancakeRouter _router = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);   // main net !
            
        pairAddress = IPancakeFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        // set the rest of the contract variables
        //routerAddress = address(_router);        
    }

    function getReserves() external view returns (uint256 Token0,uint256 Token1,uint32 blockTimestampLast){
        return IPancakePair(pairAddress).getReserves();
    }

    function excludeFromFee(address account, bool vBuyFee, bool vSellFee) external onlyOwner{
        _isExcludedFromBuyFee[account] = vBuyFee;
        _isExcludedFromSellFee[account] = vSellFee;
    }

    function isExcludedFromFee(address account) public view returns (bool BuyFee, bool SellFee) {
        return (_isExcludedFromBuyFee[account], _isExcludedFromBuyFee[account]);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "!PMK");
        _;
    }

    function name() public view virtual override returns (string memory) {
        return "Lolicon Coin";
    }
    
    function symbol() public view virtual override returns (string memory) {
        return "LOLI";
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public  virtual returns (bool) {
        _approve( _msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "< 0 dec allow");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }    

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount); 
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = allowance(from, _msgSender());
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "no allowance");
            unchecked {
                _approve(from, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(from, to, amount);
        return true;
    }

    function calcFee(address account, uint256 pbiaya) internal {
        if( pbiaya == 0 ) { return; }

        /* hitung prosentase */
        uint256 ltmp = 0;

        if(_TaxBurn > 0) {
            unchecked{
                ltmp = (pbiaya/100) * _TaxBurn;
                /* bakar */
                _totalSupply -= ltmp;
            }

            emit Transfer(account, address(0), ltmp);
        }

        if(_TaxToLP > 0){
            unchecked{
                ltmp = (pbiaya/100) * _TaxToLP;
                /* LP */
                 _balances[pairAddress] += ltmp;
            }

            emit Transfer(account, pairAddress, ltmp);
        }

        if(_TaxPercent > 0){
            address _tmp = _owner;
            if(_taxwallet != address(0)) {
                _tmp = _taxwallet;
            }

            ltmp = (pbiaya/100) * _TaxPercent;
            unchecked{
                _balances[_tmp] += ltmp;
            }
            emit Transfer(account, _tmp, ltmp);
        }
    }

    function setPinkAntibot(bool value) external onlyOwner {
        pinkAntiBotStatus = value;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0) && to != address(0), "0 addr");
        /* 4 -------- */
        require(!isBlocked(from),"blocked");
        /* END: 4-----*/
        require(_balances[from] >= amount, ">balance");

        if (pinkAntiBotStatus){
            pinkAntiBot.onPreTransferCheck(from, to, amount);
        }

        unchecked {
            _balances[from] -= amount;
        }

        uint256 _biaya = 0;

        /* check pembelian */
        if(from == pairAddress){
            if ((_buyFee > 0) && (!_isExcludedFromBuyFee[to])){
                unchecked {
                    _biaya = (amount/100) * _buyFee;
                }
            } 

        } else
        /* check penjualan */
        if(to == pairAddress){
            if ((_sellFee > 0) && (!_isExcludedFromSellFee[from])){
                unchecked {
                    _biaya = (amount/100) * _sellFee;
                }
            } 
        }

        unchecked {
            _balances[to] += amount - _biaya;
        }

        emit Transfer(from, to, amount - _biaya);
        calcFee(from, _biaya);
    }

    function burn(uint256 amount) external virtual {
        address account = msg.sender;

        require(_balances[account] >= amount, ">balance");
        unchecked {
            _balances[account] -= amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0) && spender != address(0),"0 addr");        

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function SetTaxes(uint256 vbuyFee, uint256 vsellFee) external onlyOwner {
        require(vbuyFee < 11 && vsellFee < 11);
        _buyFee = vbuyFee;
        _sellFee = vsellFee;
    }

    function GetTaxInfo() external view returns (uint256 buyFee,uint256 sellFee){
        return (_buyFee,_sellFee);
    }

    function taxAllocation() external view returns (uint256 Wallet, uint256 LP, uint256 deflation){
        return (_TaxPercent, _TaxToLP, _TaxBurn);
    }

    function setTaxAllocation(uint256 Wallet, uint256 LP, uint256 deflation) external onlyOwner {
        require(Wallet+LP+deflation == 100,"!= 100");
        _TaxPercent = Wallet;
        _TaxToLP = LP;
        _TaxBurn = deflation;
    }

    function GetWallet() external view returns (address rowner, address vTaxWallet) {
        return (_owner, _taxwallet);
    }
    
    function SetWallet(address vowner, address vTaxWallet) external onlyOwner {
        if(vowner != _owner){
            _owner = vowner;
            pinkAntiBot.setTokenOwner(_owner);
        }
        _taxwallet = vTaxWallet;
    }

/* 4 HERE =============================================================== */
    function _isClaimed(address _wallet, uint256 _eventId) internal view returns(bool){
        return _eventId == _airdropsEvents[_wallet];
    }

    function AirDrop(address[] memory _recipients, uint256 amount,uint256 _eventId) external onlyOwner  returns (uint8) {
        address owner = _msgSender();
        require(LastEventID <= _eventId,"Invalid EventID !");
        require(_balances[owner] >= (amount * _recipients.length),"<balance");
        require(!isBlocked(owner),"Blocked !");

        LastEventID = _eventId;
        LastMSR = 0;

        for (uint8 i = 0; i < _recipients.length; i++){

            /*require(!_isClaimed(_recipients[i], _eventId),"Claimed!");
                require(transfer(_recipients[i],amount),"tf failed !"); */

            if(!_isClaimed(_recipients[i], _eventId)) {
                if(transfer(_recipients[i],amount)){
                _airdropsEvents[_recipients[i]] = _eventId;
                LastMSR++;
                }
            }
        }

        return LastMSR;
    }

    function blockWallets(address[] memory _wallets, uint256 Days, uint256 Hours, uint256 Minutes) external onlyOwner {
        uint8 i = 0;
        uint256 tmp = 0;

        if((Days != 0) || (Hours != 0) || (Minutes != 0)){
            tmp = block.timestamp + (Days * 1 days);
            tmp = tmp + (Hours * 1 hours);
            tmp = tmp + (Minutes * 1 minutes);
        }

        for (i; i < _wallets.length; i++){
            _blacklist[_wallets[i]] = tmp;
        }
        
    }

    function getBlockTime(address _wallet) external view returns (uint256) {
        return _blacklist[_wallet];
    }

    function isBlocked(address _wallet) internal view returns (bool){

        uint256 n = block.timestamp;
        return _blacklist[_wallet] >= n;
    }

    function multiTransfer(address[] memory _wallets, uint256 amount) external {
        
        address owner = _msgSender();
        require(_balances[owner] >= (amount * _wallets.length),"<balance");
        require(!isBlocked(owner),"Blocked !");

        LastMSR = 0;
        for (uint8 i = 0; i < _wallets.length; i++){
            if(transfer(_wallets[i],amount)) {
                LastMSR++;
            }
        }
    } 

   /* END:4 HERE =============================================================== */


}

contract LoliconToken is ERC20 {
    constructor () ERC20() {
        _owner = msg.sender;
        _isExcludedFromSellFee[_owner] = true;
        _isExcludedFromBuyFee[_owner] = true;

        unchecked{
            _totalSupply = 100000000 * 10 ** 18;
            _balances[_owner] = _totalSupply;
        }

        emit Transfer(address(0), _owner, _totalSupply);        
    }

}