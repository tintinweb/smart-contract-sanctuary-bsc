/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

pragma solidity ^0.4.26;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract NUOVALIRAGAME {
    
    using SafeMath for uint256;
    address lire = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
	address projectFee = 0x91A6a27c1439176F7EC9B0ef24CBeA628C122cC6;
    
    uint public totalGames; 
    uint256 public totalTokenPlayed;
    
    uint private constant PROJECT_FEE       = 10;	
    uint private constant PERCENT_DIVIDER   = 1000;
    uint private constant PRICE_DIVIDER     = 1 ether; 
    
    mapping(address => User) private users;
    
    struct User {
		uint gamesPlayed;
		uint random;
        uint256 inPlay;
		uint valoreMano;
		uint valoreCarta;
        uint bancoRandom;
		uint bancoMano;
		uint bancoCarta;
		uint256 totalPlayed;
    }
    
    
    function playGame(uint256 _amount) public payable {

    require(_amount <= ERC20(lire).balanceOf(address(msg.sender)) && user.inPlay == 0);
	
	ERC20(lire).transferFrom(address(msg.sender), address(this), _amount);
	
	uint256 fee =  _amount.mul(PROJECT_FEE).div(PERCENT_DIVIDER);
        
    ERC20(lire).transfer(projectFee, fee);
	
    User storage user = users[msg.sender];    		

        user.gamesPlayed++;
        user.totalPlayed += _amount;
		totalGames++;
        totalTokenPlayed += _amount;
		user.inPlay = _amount;
		user.random = getRandomNumber(msg.sender);		
		user.valoreMano = user.random.mul(10);
		
		if (user.valoreMano == 100 || user.valoreMano == 80 || user.valoreMano == 90) {
				    user.valoreMano = getMatta(msg.sender);
				
				
		if (user.valoreMano == 100) {
				    ERC20(lire).transfer(address(msg.sender), user.inPlay.mul(2));
                    user.valoreMano = 0;
					user.inPlay = 0;
					user.random = 0;
				}
				
		else {
				    user.valoreMano = 5;
				}}
     }
    
    function siCarta() public {		
	
        User storage user = users[msg.sender];

        require(user.valoreMano < 75 && user.inPlay != 0, "Devi prima iniziare una nuova partita");

        user.random = getRandomNumber(msg.sender);		
		user.valoreCarta = user.random.mul(10);
		
		if (user.valoreCarta == 100|| user.valoreCarta == 80 || user.valoreCarta == 90) {
				    user.valoreCarta = getMatta(msg.sender);
				
				
		if (user.valoreCarta == 100) {
				    ERC20(lire).transfer(address(msg.sender), user.inPlay.mul(2));
					user.valoreMano = 0;
					user.inPlay = 0;
					user.random = 0;
				}
				
		else {
				    (user.valoreCarta = 5);
				}}
				
		user.valoreMano += user.valoreCarta;
		
		if (user.valoreMano > 75) {
				    user.valoreMano = 0;
                    user.valoreCarta = 0;
					user.inPlay = 0;
					user.random = 0;
				}
		
    }  
    
    function noCarta() public {

        User storage user = users[msg.sender];
        
		require(user.valoreMano <= 75 && user.inPlay != 0, "Devi prima iniziare una nuova partita");
		
		user.bancoRandom = getRandomNumber(msg.sender);		
		user.bancoMano = user.bancoRandom.mul(10);
		
		if (user.bancoMano == 100 || user.bancoMano == 80 || user.bancoMano == 90) {
				    user.bancoMano = getMatta(msg.sender);
				
				
		if (user.bancoMano == 100) {
				    user.bancoMano = 0;
                    user.valoreMano = 0;
                    user.valoreCarta = 0;
					user.inPlay = 0;
					user.random = 0;
				}
				
		else {
				    (user.bancoMano = 5);
				}}
				
		if (user.bancoMano >= 60 && user.bancoMano <= 75 && user.valoreMano <= 75 && user.bancoMano < user.valoreMano && user.valoreMano != 0) {
				ERC20(lire).transfer(address(msg.sender), user.inPlay.mul(2));
				user.valoreMano = 0;
				user.bancoMano = 0;
                user.valoreCarta = 0;
				user.inPlay = 0;
				user.random = 0;
				}
				
		if (user.bancoMano >= 60 && user.bancoMano <= 75 && user.valoreMano <= 75 && user.bancoMano > user.valoreMano && user.valoreMano != 0) {
				user.valoreMano = 0;
				user.bancoMano = 0;
                user.valoreCarta = 0;
				user.inPlay = 0;
				user.random = 0;
				}
				
		if (user.bancoMano < 60 && user.valoreMano <= 75  && user.valoreMano != 0) {
				bancoPlay();    
				}          
    }     
	
	function bancoPlay() private {

        User storage user = users[msg.sender];
	
        user.bancoRandom = getRandomNumber(msg.sender);		
		user.bancoCarta = user.bancoRandom.mul(10);
		
		if (user.bancoCarta == 100 || user.bancoCarta == 80 || user.bancoCarta == 90 && user.bancoMano != 0) {
				    user.bancoCarta = getMatta(msg.sender);
				
				
		if (user.bancoCarta == 100) {
				    user.valoreMano = 0;
                    user.valoreCarta = 0;
                    user.bancoMano = 0;
                    user.bancoCarta = 0;
					user.bancoRandom = 0;
					user.inPlay = 0;
					user.random = 0;
				}
				
		else {
				    (user.bancoCarta = 5);
				}}
				
		user.bancoMano += user.bancoCarta;
		
		if (user.bancoMano < 60 && user.bancoMano != 0) {
					bancoPlay();
				}
				
		if (user.bancoMano > 75 && user.bancoMano != 0) {
					ERC20(lire).transfer(address(msg.sender), user.inPlay.mul(2));
				    user.valoreMano = 0;
					user.bancoMano = 0;
                    user.valoreCarta = 0;
                    user.bancoCarta = 0;
					user.bancoRandom = 0;
					user.inPlay = 0;
					user.random = 0;
				}
		
		if (user.bancoMano <= 75 && user.valoreMano <= 75 && user.valoreMano > user.bancoMano && user.bancoMano != 0) {
					ERC20(lire).transfer(address(msg.sender), user.inPlay.mul(2));
				    user.valoreMano = 0;
					user.bancoMano = 0;
                    user.valoreCarta = 0;
                    user.bancoCarta = 0;
					user.inPlay = 0;
					user.random = 0;
					user.bancoRandom = 0;
				}

        if (user.bancoMano <= 75 && user.valoreMano <= 75 && user.valoreMano <= user.bancoMano && user.bancoMano != 0) {
				    user.valoreMano = 0;
					user.bancoMano = 0;
                    user.valoreCarta = 0;
                    user.bancoCarta = 0;
					user.inPlay = 0;
					user.random = 0;
					user.bancoRandom = 0;
				}
		
    }  

	function getRandomNumber(address _addr) private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,_addr))) % 10;
	}	

	function getMatta(address _addr) private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,_addr))) % 11;
	}

    function getMyData1(address _addr) public view returns(uint, uint, uint256, uint, uint) {
		return (users[_addr].gamesPlayed, users[_addr].random, users[_addr].inPlay, users[_addr].valoreMano, users[_addr].valoreCarta);
    }

	function getMyData2(address _addr) public view returns(uint, uint, uint, uint256) {
		return (users[_addr].bancoRandom, users[_addr].bancoMano, users[_addr].bancoCarta, users[_addr].totalPlayed);
    }  
}