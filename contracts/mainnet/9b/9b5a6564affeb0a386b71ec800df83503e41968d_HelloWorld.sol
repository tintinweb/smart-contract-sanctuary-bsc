/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

pragma solidity 0.5.2;

contract HelloWorld{
	
	string public text;
	uint public number;
	address public userAddress;
	bool public answer;
	mapping (address => uint) public hasInterected;

	//função para setar texto
	function setText (string memory MyText) public{

		text = MyText;
	
	}
	//função para setar numeros
	function setNumber(uint MyNumber) public {
		number = MyNumber;
	}
	//função para capturar o endereço de interação no contrato
	function setAddress()public{
		userAddress = msg.sender;
	}
	// função para capturar respostas de true ou falso
	function setAnswer(bool TrueOrFalse) public{
		answer = TrueOrFalse;
	}
	
}