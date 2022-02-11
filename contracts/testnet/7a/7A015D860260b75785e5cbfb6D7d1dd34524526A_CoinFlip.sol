/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

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

pragma solidity ^0.4.10;

contract CoinFlip {
    address owner;
    uint payPercentage = 90;
	
	// Maximum amount to bet in WEIs
	uint public MaxAmountToBet = 200000000000000000; // = 0.2 Ether
	
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
    
    event Status(
		string _msg, 
		address user, 
		uint amount,
		bool winner
	);
    
    function CoinFlip() payable {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert();
        } else {
            _;
        }
    }
    
    function Play() payable {
		
		if (msg.value > MaxAmountToBet) {
			revert();
		} else {
			if ((block.timestamp % 2) == 0) {
				
				if (this.balance < (msg.value * ((100 + payPercentage) / 100))) {
					// No tenemos suficientes fondos para pagar el premio, así que transferimos todo lo que tenemos
					msg.sender.transfer(this.balance);
					Status('Congratulations, you win! Sorry, we didn\'t have enought money, we will deposit everything we have!', msg.sender, msg.value, true);
					
					newGame = Game({
						addr: msg.sender,
						blocknumber: block.number,
						blocktimestamp: block.timestamp,
						bet: msg.value,
						prize: this.balance,
						winner: true
					});
					lastPlayedGames.push(newGame);
					
				} else {
					uint _prize = msg.value * (100 + payPercentage) / 100;
					Status('Congratulations, you win!', msg.sender, _prize, true);
					msg.sender.transfer(_prize);
					
					newGame = Game({
						addr: msg.sender,
						blocknumber: block.number,
						blocktimestamp: block.timestamp,
						bet: msg.value,
						prize: _prize,
						winner: true
					});
					lastPlayedGames.push(newGame);
					
				}
			} else {
				Status('Sorry, you loose!', msg.sender, msg.value, false);
				
				newGame = Game({
					addr: msg.sender,
					blocknumber: block.number,
					blocktimestamp: block.timestamp,
					bet: msg.value,
					prize: 0,
					winner: false
				});
				lastPlayedGames.push(newGame);
				
			}
		}
    }
	
	function getGameCount() public constant returns(uint) {
		return lastPlayedGames.length;
	}

	function getGameEntry(uint index) public constant returns(address addr, uint blocknumber, uint blocktimestamp, uint bet, uint prize, bool winner) {
		return (lastPlayedGames[index].addr, lastPlayedGames[index].blocknumber, lastPlayedGames[index].blocktimestamp, lastPlayedGames[index].bet, lastPlayedGames[index].prize, lastPlayedGames[index].winner);
	}
	
	
	function depositFunds(uint amount) onlyOwner payable {
        if (owner.send(amount)) {
            Status('User has deposit some money!', msg.sender, msg.value, true);
        }
    }
    
	function withdrawFunds(uint amount) onlyOwner {
        if (owner.send(amount)) {
            Status('User withdraw some money!', msg.sender, amount, true);
        }
    }
	
	function setMaxAmountToBet(uint amount) onlyOwner returns (uint) {
		MaxAmountToBet = amount;
        return MaxAmountToBet;
    }
	
	function getMaxAmountToBet(uint amount) constant returns (uint) {
        return MaxAmountToBet;
    }
	
    
    function Kill() onlyOwner {
        Status('Contract was killed, contract balance will be send to the owner!', msg.sender, this.balance, true);
        selfdestruct(owner);
    }
}