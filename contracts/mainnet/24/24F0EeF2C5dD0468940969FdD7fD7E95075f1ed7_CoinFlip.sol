// SPDX-License-Identifier: Unlicensed
/**
 * CoinFlip
 * 
 * Juego de casino para apostar a cara o cruz. Se usa el timestamp del bloque de la blockchain
 * para simular un número random entre 0 y 1. Si el timestamp del bloque es un número par el
 * usuario gana el 190% del dinero invertido, si es un número impar pierde los ethers jugados.
 *
 * Al desplegar el contrato es necesario transferirle fondos para que pueda pagar el premio si
 * el usuario gana.
 *
 * Versión modificada para interfaz web
 * 
**/

import "./SafeMath.sol";
import "./Ownable.sol";

pragma solidity ^0.8.4;

interface IRandom {
   
    function random() external returns (uint256);
}

contract CoinFlip is Ownable {
	using SafeMath for uint256;

    uint payPercentage = 97;

	IRandom public randomNumber;
	
	// Maximum amount to bet in WEIs
	uint public MaxAmountToBet; 
    uint public MinAmountToBet;

	event BetPlayer(
		address addr,
        uint bet,
        uint prize,
        bool winner
    );
	
	struct Game {
		address addr;
		uint blocknumber;
		uint blocktimestamp;
        uint bet;
		uint prize;
        bool winner;
    }
	
	Game[] lastPlayedGames;
	
	Game newGame;
    
    
    constructor(uint256 max, uint256 min, address _random) {
        MaxAmountToBet = max;
        MinAmountToBet = min;
		randomNumber = IRandom(_random);
    }
    
	function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    
    function Play(bool bet) payable public  {
		require(tx.origin == msg.sender, "Players cannot be a contract");
		require(!isContract(msg.sender), "Players cannot be a contract");
        require(msg.value >= MinAmountToBet, "Bet value  is Invalid");
        require(msg.value <= MaxAmountToBet, "Bet value  is Invalid");
		
			try randomNumber.random() returns (uint256 numberRan) {
                bool win = false;

				if(bet && numberRan % 2 == 0){
					win = true;
				}else if(!bet && numberRan % 2 == 1){
					win = true;
				}

				if (win) {
					
					if (address(this).balance < (msg.value * ((100 + payPercentage) / 100))) {
						// No tenemos suficientes fondos para pagar el premio, así que transferimos todo lo que tenemos
						payable(msg.sender).transfer(address(this).balance);
						
						newGame = Game({
							addr: msg.sender,
							blocknumber: block.number,
							blocktimestamp: block.timestamp,
							bet: msg.value,
							prize: address(this).balance,
							winner: true
						});
						lastPlayedGames.push(newGame);
						emit BetPlayer(msg.sender,msg.value,address(this).balance,true);
						
					} else {
						uint _prize = msg.value * (100 + payPercentage) / 100;
						payable(msg.sender).transfer(_prize);
						
						newGame = Game({
							addr: msg.sender,
							blocknumber: block.number,
							blocktimestamp: block.timestamp,
							bet: msg.value,
							prize: _prize,
							winner: true
						});
						lastPlayedGames.push(newGame);
						emit BetPlayer(msg.sender,msg.value,_prize,true);
						
					}
				} else {
					
					newGame = Game({
						addr: msg.sender,
						blocknumber: block.number,
						blocktimestamp: block.timestamp,
						bet: msg.value,
						prize: 0,
						winner: false
					});
					lastPlayedGames.push(newGame);
					emit BetPlayer(msg.sender,msg.value,0,false);
					
				}
            }
            catch {

            }
            

            
		
    }
	
	function getGameCount() public view returns(uint) {
		return lastPlayedGames.length;
	}

	function getGameEntry(uint index) public view returns(address addr, uint blocknumber, uint blocktimestamp, uint bet, uint prize, bool winner) {
		return (lastPlayedGames[index].addr, lastPlayedGames[index].blocknumber, lastPlayedGames[index].blocktimestamp, lastPlayedGames[index].bet, lastPlayedGames[index].prize, lastPlayedGames[index].winner);
	}
	
    
	function withdrawFunds(uint amount) public onlyOwner {
        payable(owner()).transfer(amount);
    }

    function depositFunds() public onlyOwner payable {
        //payable(owner()).transfer(amount);
    }

	function setMaxAmountToBet(uint amount) public onlyOwner returns (uint) {
        require(amount >= 1*10**16, "MaxAmount is invalid");
        require(amount > MinAmountToBet, "MaxAmount is invalid");
		MaxAmountToBet = amount;
        return MaxAmountToBet;
    }

    function setMinAmountToBet(uint amount) public onlyOwner returns (uint) {
        require(amount >= 1*10**16, "MinAmount is invalid");
        require(amount < MaxAmountToBet, "MinAmount is invalid");
		MinAmountToBet = amount;
        return MinAmountToBet;
    }
	
	
    
    
}