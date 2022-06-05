/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BEP20 {

    uint256 initialSupply = 500000000;
    uint256 fee;
    uint256 burnAmount;
    uint256 public totalSupply;
	uint256 public totalMintSupply;
    uint8   public decimals = 6;
    string  public name;
    string  public symbol;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);
    event Mint(address indexed from, uint256 _value);
    address owner;
    address feeCollector;
   
    string tokenName = 'AhmetToken';
    string tokenSymbol = 'AHMT'; 
    address tokenA;
    uint256 priceA;
    uint256 priceBicot;
    uint256 public phaseBalance = 500000;
    uint8 public phaseNumber = 1;
    bool flag;

    constructor() {
        // Update total supply with the decimal amount
        totalSupply = initialSupply * 10 ** uint256(decimals);
        // Give the creator all initial tokens
        balanceOf[msg.sender] = totalSupply;
        // Set the name for display purposes
        name = tokenName;
        // Set the symbol for display purposes
        symbol = tokenSymbol;
        //Set owner of the token
        owner = msg.sender;
    }

    struct Order {
        uint256 balance;
        uint    orderPhasenum; 
    }
    mapping (address => Order) public orders;



    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //Burada Faz numarası belirlenir. Ön satış işleminin ilk ayağıdır.
    function setPhase(uint8 _phaseNumber) public{
        require(msg.sender == owner, 'Not Authorized.');
        phaseNumber = _phaseNumber;
    }

    // Faz numarası ile verilecek olan BICOT miktarı burada belirlenir.
    function setPhaseBalance(uint256 _phaseBalance) public{
        require(msg.sender == owner, 'Not Authorized.');
        phaseBalance = _phaseBalance;
    }

    /** 
    * Ön satış fonksiyonu tokenPreOrder fonksiyonu.
    * Eğer daha önce aynı faz numarası ile kayıt olduysanız tekrar kayıt olamazsınız.
    * Eğer daha önce içeride bekleyen bir BICOT tutarınız var ve çekmediniz tekrar alım yaptınız
    * -Bu miktar eklenerek devam eder.
    */
    function tokenPreOrder(address _buyer) external returns(bool){
        require(preOrderPhasenumCheck(_buyer) == true, "A pre-order has already been created.");
        require(phaseNumber !=0,"Stage number should not be 0.");
        Order memory order;
        order.balance = orders[_buyer].balance + phaseBalance;
        order.orderPhasenum = phaseNumber;
        orders[_buyer] = order;
        return true;
    }

    /** Daha önce aynı ön çekiliş hakki ile bir siparis olusturdu ise değer False döner 
    * False dönen bir değer ise tokenPreOrder tarafından işleme alınmaz.
    */
    function preOrderPhasenumCheck(address _buyer) public view returns(bool){
        if(orders[_buyer].orderPhasenum != phaseNumber){
            return true;
        }
        return false;
    }




    //transfer order to wallet
    /** 
    1- bakiye sıfırdan büyükse,
    */
    function transferOrderToWallet(address _buyer) public returns(bool _success){
        require(orders[_buyer].balance >0,"Your current balance is 0");
        Callee c = Callee(tokenA);
        bool trans;
        trans = c.transferFrom(msg.sender, owner, priceA);
        require(trans == true, 'Invalid payment');
        balanceOf[msg.sender] += priceBicot;
        balanceOf[owner] -= priceBicot;
        uint previousBalances = balanceOf[msg.sender] + balanceOf[owner];
		assert(balanceOf[msg.sender] + balanceOf[owner] == previousBalances);
        return true;
    }
    
    // Yakma fonksiyonu
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    /** Transfer Fonksiyonları */

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0), "To cannot be empty.");
        require(balanceOf[_from] >= _value, 'Insufficient balance.');
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
		
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
		
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(msg.sender, _to, _value);
        return true;
    }

   function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        _transfer(msg.sender, feeCollector, fee);
        burn(burnAmount);
        return true;
    }


//* ESKİ DATALAR**/// 

    function ordersCheck() external view returns(uint256 balance, uint stage){
        return (orders[msg.sender].balance, orders[msg.sender].orderPhasenum);
    }

     //function for setting mint parameters
    function setMintParams(uint256 _amountIn, uint256 _amountOut, address _token) public returns (bool success) {
        require(msg.sender == owner, 'Not Authorized.');
        tokenA = _token;
        priceA = _amountIn;
        priceBicot = _amountOut;
        return true;
    }
}

abstract contract Callee{
    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success);
    function transfer(address _to, uint256 _value) virtual public returns (bool success);
}