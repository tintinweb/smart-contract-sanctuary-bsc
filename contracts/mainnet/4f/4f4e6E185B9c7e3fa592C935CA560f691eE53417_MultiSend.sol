/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;
/*
    * Author: Julio Vinachi
    * v1.0.3
*/
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MultiSend {
	address private owner;
	bool private active = true;

	modifier isOwner() {
		require(msg.sender == owner,"No estas autorizado");
        _;
	}
	modifier isActive() {
		require(active == true,"La Funcinalidad no esta Activa");
        _;
	}

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

	constructor() {
		owner = msg.sender;
	}


    function toActive() public isOwner returns(bool){
        active = true;
        return (active == true);
    }

    function toInactive() public isOwner returns(bool){
        active = false;
        return (active == false);
    }

	function miltipleWithdraw(address payable[] memory _destinatarios, uint256[] memory _cantidades) public payable isOwner {
		require(_cantidades.length == _destinatarios.length,"destinatarios y cantidades no coinciden");
		uint256 total = 0;

		for(uint256 i=0; i< _cantidades.length; i++){
			total += _cantidades[i];
		}

		require( total == msg.value, "El Valor no coincide con el total" );

		for(uint256 i=0; i< _destinatarios.length;i++) {
			uint256 reciverAmount = _cantidades[i] * 1 wei;
			_destinatarios[i].transfer(reciverAmount);
		}		
	}

	function TokenCustomMultipleSend(IERC20 tokenCustom,address payable[] memory _destinatarios, uint256[] memory _cantidades) public payable isActive {
		// Nota Hay que poseer el aproval antes de poder mover los tokens		
		require(_cantidades.length == _destinatarios.length,"destinatarios y cantidades no coinciden");


        uint256 total = 0;

		for(uint256 i=0; i< _cantidades.length; i++){
            total += _cantidades[i];            
		}
		
        uint256 cantidadAprovada = tokenCustom.allowance(msg.sender, address(this));
        
        require(cantidadAprovada >= total,"No tienes la aprovacion para la cantidad que deseas mover.");


		for(uint256 i=0; i< _destinatarios.length;i++) {
			uint256 reciverAmount = _cantidades[i];
	    	tokenCustom.transferFrom(payable(msg.sender),_destinatarios[i], reciverAmount);
		}		
	}

}