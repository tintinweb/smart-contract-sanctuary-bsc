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
import "./ERC20.sol";

pragma solidity ^0.8.4;

interface IRandom {
   
    function random() external returns (uint256);
}

contract CoinFlip is Ownable {
	using SafeMath for uint256;

    uint payPercentage = 97;

	IRandom public randomNumber;
	ERC20 public rewardToken;
	
	// Maximum amount to bet in WEIs
	uint256 public MaxAmountToBet; 
    uint256 public MinAmountToBet;

	event BetPlayer(
		address addr,
        uint256 bet,
        uint256 prize,
        bool winner
    );
	
	struct Game {
		address addr;
		uint blocknumber;
		uint blocktimestamp;
        uint256 bet;
		uint256 prize;
        bool winner;
    }
	
	Game[] lastPlayedGames;
	
	Game newGame;
    
    
    constructor(uint256 max, uint256 min,address _tokenComa, address _random) {
        MaxAmountToBet = max;
        MinAmountToBet = min;
		rewardToken = ERC20(_tokenComa);
		randomNumber = IRandom(_random);
    }
    
	function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    
    function Play(bool bet, uint256 _amount) payable public  {
		require(tx.origin == msg.sender, "Players cannot be a contract");
		require(!isContract(msg.sender), "Players cannot be a contract");
        require(_amount >= MinAmountToBet, "Bet value  is Invalid");
        require(_amount <= MaxAmountToBet, "Bet value  is Invalid");

		rewardToken.transferFrom(address(msg.sender),address(this),_amount);
		
			try randomNumber.random() returns (uint256 numberRan) {
                bool win = false;

				if(bet && numberRan % 2 == 0){
					win = true;
				}else if(!bet && numberRan % 2 == 1){
					win = true;
				}

				if (win) {
					uint256 cuBalance = rewardToken.balanceOf(address(this));
					if (rewardToken.balanceOf(address(this)) < (_amount * ((100 + payPercentage) / 100))) {
						// No tenemos suficientes fondos para pagar el premio, así que transferimos todo lo que tenemos
						//payable(msg.sender).transfer(address(this).balance);
						rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
						
						newGame = Game({
							addr: msg.sender,
							blocknumber: block.number,
							blocktimestamp: block.timestamp,
							bet: _amount,
							prize: cuBalance,
							winner: true
						});
						lastPlayedGames.push(newGame);
						emit BetPlayer(msg.sender,_amount,cuBalance,true);
						
					} else {
						uint256 _prize = _amount * (100 + payPercentage) / 100;
						rewardToken.transfer(msg.sender, _prize);
						//payable(msg.sender).transfer(_prize);
						
						newGame = Game({
							addr: msg.sender,
							blocknumber: block.number,
							blocktimestamp: block.timestamp,
							bet: _amount,
							prize: _prize,
							winner: true
						});
						lastPlayedGames.push(newGame);
						emit BetPlayer(msg.sender,_amount,_prize,true);
						
					}
				} else {
					
					newGame = Game({
						addr: msg.sender,
						blocknumber: block.number,
						blocktimestamp: block.timestamp,
						bet: _amount,
						prize: 0,
						winner: false
					});
					lastPlayedGames.push(newGame);
					emit BetPlayer(msg.sender,_amount,0,false);
					
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

	function setMaxAmountToBet(uint256 amount) public onlyOwner returns (uint) {
        require(amount >= 1*10**16, "MaxAmount is invalid");
        require(amount > MinAmountToBet, "MaxAmount is invalid");
		MaxAmountToBet = amount;
        return MaxAmountToBet;
    }

    function setMinAmountToBet(uint256 amount) public onlyOwner returns (uint) {
        require(amount >= 1*10**16, "MinAmount is invalid");
        require(amount < MaxAmountToBet, "MinAmount is invalid");
		MinAmountToBet = amount;
        return MinAmountToBet;
    }
	
	
    
    
}