/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EspadaLibertadora{

        string public constant name = "EspadaLibertadora";
        string public constant symbol = "EL";
        uint8 public constant decimals = 18;

        event Transfer(address indexed from, address indexed to, uint256 tokens);
        event Approval(address indexed owner,address indexed spender, uint256 tokens);

        using SafeMath for uint256;

        mapping (address => uint) balances;
        mapping (address => mapping (address => uint)) allowed;
        uint256 totalSupply_;

        constructor(){
            totalSupply_ = 12000000;
            balances[msg.sender] = totalSupply_;
        }

        function totalSupply() public view returns(uint256){
            return totalSupply_;
        }

        // Modificar totalSupply

        function increaseTotalSupply( uint newTokenAmount) public {
            totalSupply_ += newTokenAmount;
            balances[msg.sender] += newTokenAmount; 
        }
        
        function balanceOf(address tokenOwner) public view returns (uint256){
            return balances[tokenOwner];
        }

        function allowance(address owner, address delegate) public view returns (uint256){
            return allowed[owner][delegate];
        }

        function transfer(address recipient, uint256 numToken) public returns (bool){
            // validar que el emisor tenga la cantidad de tokens a transferir
            require(numToken <= balances[msg.sender]);
            // Restamos los tokens de la cartera
            balances[msg.sender] = balances[msg.sender].sub(numToken);
            balances[recipient] = balances[recipient].add(numToken);
            // emitimos para transferir lo enviado
            emit Transfer(msg.sender, recipient ,numToken);
            return true;
        }

        function transfer_loteria(address _emisor ,address recipient, uint256 numToken) public returns (bool){
            // validar que el emisor tenga la cantidad de tokens a transferir
            require(numToken <= balances[_emisor]);
            // Restamos los tokens de la cartera
            balances[_emisor] = balances[_emisor].sub(numToken);
            balances[recipient] = balances[recipient].add(numToken);
            // emitimos para transferir lo enviado
            emit Transfer(_emisor, recipient ,numToken);
            return true;
        }

        function approve(address _delegate, uint256 numToken) public returns (bool){
            allowed[msg.sender][_delegate] = numToken;
            emit Approval(msg.sender, _delegate, numToken);
            return true;
        }

        function transferFrom(address owner, address buyer, uint256 numToken) public returns (bool){
            require(numToken <= balances[owner]);
            require(numToken <= allowed[owner][msg.sender]);
            // Quitar del propietario
            balances[owner] = balances[owner].sub(numToken);
            // quitar los tokens del contrato
            allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numToken);
            // Se lo sumamos al dueño
            balances[buyer] = balances[buyer].add(numToken);
            // Emitimos un eventos para que todos sepan de la transacción
            emit Transfer(owner, buyer, numToken);
            return false;
        }
}

library SafeMath{
    // Restas
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    // Sumas
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
      // assert(b > 0); // Solidity automatically throws when dividing by 0
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold
      return c;
    }
    
    // Multiplicacion
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}