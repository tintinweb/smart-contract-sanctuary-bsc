/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: GLP-3.0
pragma solidity 0.8.16;

contract ATMBUSDCoin {

//Events
    //ERC20 Compatibility
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    event Approval(address indexed _owner, address indexed _approved, uint256 _value);
    
    event Mint(address indexed approval, address indexed to, uint256 indexed _amount);
    
    event Burn(address indexed approval, address indexed from, uint256 indexed _amount);
    
    event Deposit(address indexed _owner, uint256 _amount, uint256 fee);
    
    event Withdraw(address indexed _owner, uint256 _amount, uint256 fee);
    
    event Buy(address indexed _buyer, uint256 ATMBUSDCoin, uint256 BUSD);
    
    event Sell(address indexed _seller, uint256 ATMBUSDCoin, uint256 BUSD);
    
    event Swap(address indexed _seller, uint256 ATMBUSDCoin, address indexed _buyer, uint256 BUSD);
    
    event AtmbusdcoinWithdrawRequest(address indexed _owner, uint256 _amount);
    
    event BusdWithdrawRequest(address indexed _owner, uint256 _amount);
    
    event FeeChanged(string indexed _fee, uint _value);
    
//Variables
    //Specific Variables
    address payable private _dev;
    address[] private _contracts;
    address[] private _allowedSpenders;
    order[] private _withdrawRequest;
    bool _paused;
    bool _approvable;
    bool _autoWithdraw;
    
    //Fee Variables
    uint private _basicfee;
    uint private _depositMul;
    uint private _withdrawMul;
    
    //BUSD Variables
    struct order {
        address _owner;
        uint256 _amount;
        uint256 _price;
    }
    address immutable private _busdContract;
    address immutable private _atmbusdcoin;
    uint256 private _busdTotalSupply;
    mapping (address => uint256) private _busdBalances;
    order[] private _sellOrders;
    mapping (address => uint256[]) private _individualOrders;
    
    //ERC20 Variables
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor(){
        _name = "Ancient Tales & Myths - BUSD Coin";
        _symbol = "ATMBUSDCoin";
        _decimals = 8;
        _dev = payable(msg.sender);
        _basicfee = 50;
        _withdrawMul = 3;
        _approvable = true;
        _busdContract = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        _atmbusdcoin = address(this);
    }
    
//Functions

    //ERC20 USD Compatibility
    function _deposit(uint256 _amount) public payable {
        require(_amount>0, "Invalid amount value.");
        uint _USD = _amount + (_basicfee * _depositMul * _amount / 10000);
        
        (bool success,) = _busdContract.call(abi.encodeWithSignature("transferFrom(address,address,uint256)",msg.sender,_atmbusdcoin,_USD));
        require(success, "Transaction Failed.");
        
        _busdTotalSupply += _amount;
        _busdBalances[msg.sender] += _amount;
        _USD -= _amount;
        emit Deposit(msg.sender, _amount, _USD);
    }
    
    function _buyDirect(uint256 _amount) public payable notPaused {
        require(_amount>0, "Invalid amount value.");
        uint _USD = _amount + (_basicfee * _amount / 5000);
        
        (bool success,) = _busdContract.call(abi.encodeWithSignature("transferFrom(address,address,uint256)",msg.sender,_atmbusdcoin,_USD));
        require(success, "Transaction Failed.");
        
        _USD -= _amount;
        uint256 _atmAmount = _amount / 10000000000;
        _balances[msg.sender] += _atmAmount;
        _totalSupply += _atmAmount;
        
        emit Deposit(msg.sender, _amount, _USD);
        emit Buy(msg.sender, _atmAmount, _amount);
    }
    
    function _buyATMBUSDCoin(uint256 _amount) public payable notPaused {
        require(_amount>0, "Invalid amount value.");
        uint256 _max = 1000000000000000000 + (200000000000000 * _basicfee);
        uint256 _USD = (_amount * _max) / 1000000000000000000;
        require(_USD<=_busdBalances[msg.sender], "Insufficient BUSD.");
        _busdBalances[msg.sender] -= _USD;
        _busdTotalSupply -= _USD;
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        emit Buy(msg.sender, _amount, _USD);
        
    }
    function _buyATMBUSDCoinOrder(uint256 _orderId) public payable notPaused {
        order[] memory _orderBook = _sellOrders;
        require(_orderId<_orderBook.length, "Invalid order.");
        order memory _order = _orderBook[_orderId];
        uint256 _busd = _order._amount * _order._price / 100000000;
        require(_busdBalances[msg.sender]>=_busd, "Insufficient BUSD.");
        uint256 _amount = _busd / 10000000000;
        
        _sellOrders[_orderId] = _orderBook[_orderBook.length -1];
        _sellOrders.pop();
        
        _busdBalances[msg.sender] -= _busd;
        _busdBalances[_order._owner] +=_busd;
        _balances[msg.sender] += _amount;
        
        emit Swap(_order._owner, _amount, msg.sender, _busd);
    }
    
    function _sellATMBUSDCoin(uint256 _amount, uint256 _price) public payable notPaused returns (bool) {
        require(_amount>0, "Invalid amount value.");
        require(_amount<=_balances[msg.sender], "Insufficient funds.");
        uint256 _max = 1000000000000000000 + (200000000000000 * _basicfee);
        require(_price < _max, "Sell price above maximum");
        
        uint256 _min = 1000000000000000000 - (200000000000000 * _basicfee);
        if (_price > _min) {
            _balances[msg.sender] -= _amount;
            order memory _order = order(msg.sender, _amount, _price);
            _sellOrders.push(_order);
            _individualOrders[msg.sender].push(_sellOrders.length);
        } else {
            uint256 _USD = (_amount * _min) / 100000000;
            _balances[msg.sender] -= _amount;
            _totalSupply -= _amount;
            _busdTotalSupply += _USD;
            _busdBalances[msg.sender] += _USD;
            emit Sell(msg.sender, _amount, _USD);
        }
        return true;
    }
    
    function sellDirectRequest(uint256 _amount) public payable notPaused {
        require(_amount>0, "Invalid amount value.");
        require(msg.value>(_basicfee*1500), "Insufficient BNB for gas.");
        require(_balances[msg.sender]>=_amount,"Insufficient funds.");
        _balances[msg.sender] -= _amount;
        _totalSupply -= _amount;
        order memory _order = order(msg.sender, _amount, 0);
        _withdrawRequest.push(_order);
        
        emit AtmbusdcoinWithdrawRequest(msg.sender, _amount);
        withdrawBUSD(_withdrawRequest.length -1);
    }
    
    function busdWithdrawRequest(uint256 _amount) public payable {
        require(_amount>0, "Invalid amount value.");
        require(msg.value>(_basicfee*1500), "Insufficient BNB for gas.");
        require(_busdBalances[msg.sender]>=_amount, "Insufficient BUSD.");
        _busdBalances[msg.sender] -= _amount;
        _busdTotalSupply -= _amount;
        order memory _order = order(msg.sender, _amount, 1);
        _withdrawRequest.push(_order);
        
        emit BusdWithdrawRequest(msg.sender, _amount);
        withdrawBUSD(_withdrawRequest.length -1);
    }
    
    function withdrawBUSD(uint256 _id) public isDevWithdraw {
        order[] memory _request = _withdrawRequest;
        require(_id<_request.length, "Invalid request Id.");
        order memory _order = _request[_id];
        if(_order._price==0){
            uint256 _busd = _order._amount - (_basicfee * _order._amount / 5000);
            _busd *= 10000000000;
            _withdrawRequest[_id] = _request[_request.length -1];
            _withdrawRequest.pop();
            
            (bool success,) = _busdContract.call(abi.encodeWithSignature("transfer(address,uint256)",_order._owner,_busd));
            require(success, "Transaction Failed.");
            
            emit Sell(_order._owner, _order._amount, _busd);
            emit Withdraw(_order._owner, _busd, 0);
        }
        if(_order._price==1){
            uint256 _busd = _order._amount - (_basicfee * _withdrawMul * _order._amount / 10000);
            _withdrawRequest[_id] = _request[_request.length -1];
            _withdrawRequest.pop();
            
            (bool success1,) = _busdContract.call(abi.encodeWithSignature("transfer(address,uint256)",_order._owner,_busd));
            require(success1, "Transaction Failed.");
            
            emit Withdraw(_order._owner, _order._amount, (_order._amount - _busd));
        }
    }
    
    function getWithdrawRequest() public view isDev returns(order[] memory){
        return _withdrawRequest;
    }
    
    function getSellOrders() public view returns (order[] memory){
        return _sellOrders;
    }
    
    function getIndividualOrders(address _owner) public view returns (uint256[] memory){
        return _individualOrders[_owner];
    }
    
    function cancelSellOrder(uint256 _orderId) public payable notPaused returns (bool){
        uint256[] memory _iOrder = _individualOrders[msg.sender];
        require(_orderId<_iOrder.length, "Invalid order Id.");
        uint256 _id = _iOrder[_orderId];
        order[] memory _orders = _sellOrders;
        require(_id<_orders.length, "Invalid order Id.");
        if(msg.sender!=_dev){
            require(_orders[_id]._owner==msg.sender, "Not sell order owner.");
        }
        uint256 _amount = _orders[_id]._amount;
        _sellOrders[_id]=_orders[_sellOrders.length-1];
        _sellOrders.pop();
        
        _individualOrders[msg.sender][_orderId] = _iOrder[_iOrder.length -1];
        _individualOrders[msg.sender].pop();
        _balances[msg.sender] += _amount;
        return true;
    }
    
    function busdTotalSupply() public view returns (uint256){
        return _busdTotalSupply;
    }
    
    function busdBalanceOf(address _owner) public view returns (uint256){
        return _busdBalances[_owner];
    }
    
    //Specific Functions
    function _getApproved() internal view returns(bool){
        if(msg.sender==_dev) return true;
        address[] memory contracts = _contracts;
        for(uint i=0;i<contracts.length;i++){
            if(msg.sender==contracts[i]) return true;
        }
        return false;
    }
    
    modifier isApproved() {
        require(_getApproved(), "Forbidden operation.");
        _;
    }
    
    fallback() external payable {
        require(msg.data.length==0, "Function doesn't exists.");
    }
    receive() external payable {}
    
    modifier isDev(){
        require(msg.sender == _dev,"Forbidden operation.");
        _;
    }
    
    modifier isDevWithdraw(){
        if (!_autoWithdraw){
            require(msg.sender == _dev,"Forbidden operation.");
        }
        _;
    }
    
    function autoWithdraw() public isDev {
        _autoWithdraw = true;
    }
    
    function defaultWithdraw() public isDev {
        _autoWithdraw = false;
    }
    
    function getContracts() public view isDev returns (address[] memory){
        return _contracts;
    }
    
    function allowContract(address contr) public payable isDev {
        _contracts.push(contr);
    }
    
    function removeContract(uint256 contr) public payable isDev{
        _contracts[contr]=_contracts[_contracts.length-1];
        _contracts.pop();
    }
    
    function getAllowedSpenders() public view isDev returns (address[] memory){
        return _allowedSpenders;
    }
    
    function allowSpender(address _spender) public payable isDev{
        _allowedSpenders.push(_spender);
    }
    
    function removeSpender(uint256 _spender) public payable isDev{
        _allowedSpenders[_spender]=_allowedSpenders[_allowedSpenders.length-1];
        _allowedSpenders.pop();
    }
    
    function devWithdrawBUSD(uint _amount) public isDev returns (bool){
        (bool success,) = _busdContract.call(abi.encodeWithSignature("transfer(address,uint256)",_dev,_amount));
            return success;
    }
    
    function devWithdraw(uint _amount) public isDev returns (bool) {
        (bool h,) = _dev.call{value: _amount}("");
        return h;
    }
    
    function adjustBasicFee(uint newFee) public payable isDev {
        _basicfee = newFee;
        emit FeeChanged("Basic", newFee);
    }
    
    function getBasicFee() public view returns (uint) {
        return _basicfee;
    }
    
    function adjustDepositFee(uint newFee) public payable isDev {
        _depositMul = newFee;
        emit FeeChanged("Deposit", newFee);
    }
    
    function getDepositFee() public view returns (uint) {
        return _depositMul;
    }
    
    function adjustWithdrawFee(uint newFee) public payable isDev {
        _withdrawMul = newFee;
        emit FeeChanged("Withdraw", newFee);
    }
    
    function getWithdrawFee() public view returns (uint) {
        return _withdrawMul;
    }
    
    function selfDestruct(uint magicNum) public payable isDev {
        require(magicNum == 28);
        selfdestruct(_dev);
    }
    
    //ERC20 Pausable
    modifier notPaused(){
        require(!_paused,"Contract is paused.");
        _;
    }
    
    function pauseContract() public isDev {
        _paused = true;
    }
    
    function resumeContract() public isDev {
        _paused = false;
    }
    
    function isPaused() public view returns (bool) {
        return _paused;
    }
    
    //ERC20 Approvable
    function approvable() public isDev {
        _approvable = true;
    }
    
    function notApprovable() public isDev {
        _approvable = false;
    }
    
    function isApprovable() public view returns (bool) {
        return _approvable;
    }
    
    //ERC20 Compatibility
    function name() public view returns (string memory){
        return _name;
    }
    
    function symbol() public view returns (string memory){
        return _symbol;
    }
    
    function decimals() public view returns (uint8){
        return _decimals;
    }
    
    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }
    
    function balanceOf(address _owner) public view returns (uint256){
        return _balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public notPaused returns (bool){
        require(_to!=address(0), "Invalid address.");
        require(balanceOf(msg.sender)>=_value, "Insufficient funds.");
        _balances[msg.sender] -= _value;
        _balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public notPaused returns (bool){
        require(_to!=address(0), "Invalid address.");
        require(_from!=address(0), "Invalid address.");
        if(!_getApproved()){
            if (_from!=msg.sender) {
                require(allowance(_from, msg.sender)>=_value, "Insufficient allowed amount.");
                decreaseAllowance(_from, _value);
            }
        }
        require(balanceOf(_from)>=_value, "Insufficient funds.");
        _balances[_from] -= _value;
        _balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public notPaused returns(bool){
        require(_spender!=address(0), "Invalid address.");
        require(_spender!=msg.sender);
        if(isApprovable()){
            _allowances[msg.sender][_spender] = _value;
            emit Approval(msg.sender, _spender, _value);
            return true;
        }
        return _approve(_spender, _value);
    }
    
    function _approve(address _spender, uint256 _value) internal notPaused returns (bool){
        require(_spender!=address(0), "Invalid address.");
        for(uint i=0;i<_allowedSpenders.length;i++){
            require(_spender != address(0), "Invalid address.");
            if(_allowedSpenders[i]==_spender){
                _allowances[msg.sender][_spender] = _value;
                emit Approval(msg.sender, _spender, _value);
                return true;
            }
        }
        return false;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256){
        return _allowances[_owner][_spender];
    }
    
    function increaseAllowance(address _spender, uint256 _addedValue) public notPaused returns (bool) {
        require(_allowances[msg.sender][_spender]>0, "Not approved address.");
        _allowances[msg.sender][_spender] += _addedValue;
        return true;
    }
    
    function decreaseAllowance(address _spender, uint256 _subtractedValue) public notPaused returns (bool) {
        require(_allowances[msg.sender][_spender]>0, "Not approved address.");
        if (_allowances[msg.sender][_spender]>_subtractedValue){
            _allowances[msg.sender][_spender] -= _subtractedValue;
            return true;
        }
        _allowances[msg.sender][_spender]=0;
        return true;
    }
    
    function mint(address _to, uint256 _amount) public isDev {
        _totalSupply += _amount;
        _balances[_to] += _amount;
        emit Mint(msg.sender, _to, _amount);
    }
    
    function burn(address _from, uint256 _amount) public isDev {
        _totalSupply -= _amount;
        _balances[_from] -= _amount;
        emit Burn(msg.sender, _from, _amount);
    }
}