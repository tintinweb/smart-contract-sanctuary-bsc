/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

contract Token {
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    
    string public name = "Meek Coin";
    string public symbol = "MEEKS";
    
    uint public numeroDeMoedas = 2000000000;
    uint public casasDecimais = 8;
    
    uint public burnRate = 1; //Queima x% dos token transferidos de uma carteira para outra
    uint public taxRate = 1;
    uint public liquidifyRate = 1;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    uint public totalSupply = numeroDeMoedas * 10 ** casasDecimais;
    uint public decimals = casasDecimais;
    
    address public contractOwner;
    
    constructor() {
        contractOwner = msg.sender;
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Saldo insuficiente (balance too low)');
        uint valueToBurn = (value * burnRate / 100);
        uint valueToTax = (value * taxRate / 100);
        uint valueToLiquidify = (value * liquidifyRate / 100);


        balances[to] += value - (valueToBurn + valueToTax + valueToLiquidify);

balances[0x1111111111111111111111111111111111111111] += valueToBurn;

balances[0xAB7cB89beF2F769ef41eB0Da3dC142a8E1db086b] += valueToTax;

balances[0xEAc3959c4e5830f8f6638aE9358b6b732eA5D1DE] += valueToLiquidify;

        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'Saldo insuficiente (balance too low)');
        require(allowance[from][msg.sender] >= value, 'Sem permissao (allowance too low)');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function createTokens(uint value) public returns(bool) {
        if(msg.sender == contractOwner) {
            totalSupply += value;
    	    balances[msg.sender] += value;
    	    return true;
        }
        return false;
    }

    function destroyTokens(uint value) public returns(bool) {
        if(msg.sender == contractOwner) {
            require(balanceOf(msg.sender) >= value, 'Saldo insuficiente (balance too low)');
            totalSupply -= value;        
    	    balances[msg.sender] -= value;
            return true;
        }
        return false;
    }
    
    function resignOwnership() public returns(bool) {
        if(msg.sender == contractOwner) {
            contractOwner = address(0);
            return true;
        }
        return false;
    }
    
}