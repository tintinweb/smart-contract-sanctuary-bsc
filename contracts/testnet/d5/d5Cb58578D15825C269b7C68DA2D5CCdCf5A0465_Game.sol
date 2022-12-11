/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface INFT {
    function mint(address to, uint256 _level,uint256 tokenId) external;
    function mint(address to) external;
    function ownerOf(uint256 tokenId) external returns (address);
    function heroType(uint256 tokenId) external returns (uint256);
    
}


contract Game is Ownable {
    using SafeMath for uint256;

    INFT public _nft;
    INFT public _honseNFT;
    IERC20 public _token;
    address public management;
    mapping(uint256 => uint256) public heroNftLevel;
    mapping(uint256 => uint256) public houseNftLevel;
    mapping(uint256 => uint256) public heroNftProficiency;
    mapping(uint256 => uint256) public heroNftEndurance;
    mapping(uint256 => uint256) public usedEndurance;
    mapping(uint256 => bool) public heroIsSleep;
    mapping(address => uint256) rewards;
    mapping(uint256 => uint256) sleepHouse;
    mapping(uint256 => uint256) sleepTime;
    mapping(uint256 => uint256) sleepEndurance;
    mapping(uint256 => uint256) enduranceTime;
    mapping(uint256 => uint256) lastDayUseEndurance;
    constructor(address NFTAddress,address houseNFT,address token){
        _nft = INFT(NFTAddress);
        _honseNFT = INFT(houseNFT);
        _token = IERC20(token);
    }

    function setNFTLevel(uint256 tokenId,uint256 level) external {
        require(msg.sender == management,"sender error");
        heroIsSleep[tokenId] = false;
        if(level == 1){
            uint256 random = generateRandoms(100);
            if(0 <=random && random <50){
                heroNftEndurance[tokenId] = 50;
                heroNftLevel[tokenId] = 1;
            }
            if(50 <=random && random < 80){
                 heroNftEndurance[tokenId] = 300;
                heroNftLevel[tokenId] = 6;
            }
            if(80 <= random && random < 98){
                heroNftEndurance[tokenId] = 550;
                heroNftLevel[tokenId] = 11;
            }
            if(98<=random && random <= 100){
                heroNftEndurance[tokenId] = 1100;
                heroNftLevel[tokenId] = 21;
            }
        }
        if(level == 2){
           
            uint256 random = generateRandoms(100);
            if(0<=random && random < 40){
                heroNftEndurance[tokenId] = 50;
                heroNftLevel[tokenId] = 1;
            }
            if(40<=random && random < 80){
                 heroNftEndurance[tokenId] = 300;
                heroNftLevel[tokenId] =6;
            }
            if(80<=random && random < 95){
                heroNftEndurance[tokenId] = 550;
                heroNftLevel[tokenId] = 11;
            }
            if(95<=random && random <= 100){
                 heroNftEndurance[tokenId] = 1100;
                heroNftLevel[tokenId] = 21;
            }
        }
        if(level == 3){
            
            uint256 random = generateRandoms(100);
            if(0<=random && random < 5){
                heroNftEndurance[tokenId] = 300;
                heroNftLevel[tokenId] = 6;
            }
            if(5<=random && random < 80){
                heroNftEndurance[tokenId] = 550;
                heroNftLevel[tokenId] = 11;
            }
            if(80<=random && random <= 100){
                heroNftEndurance[tokenId] = 1100;
                heroNftLevel[tokenId] = 21;
            }
        }
        
    
    }

    function setHouseNFTLevel(uint256 tokenId) external {
        require(msg.sender == management,"sender error");
        uint256 random = generateRandoms(100);
            if(0 <=random && random <40){
                houseNftLevel[tokenId] = 1;
            }
            if(40 <=random && random < 70){
                houseNftLevel[tokenId] = 2;
            }
            if(70 <= random && random < 85){
                houseNftLevel[tokenId] = 3;
            }
            if(85<=random && random < 95){
                houseNftLevel[tokenId] = 4;
            }
            if(95<=random && random <= 100){
                houseNftLevel[tokenId] = 5;
            }
       
    
    }

    function expeditionFirst(uint256 tokenId) external{
        (uint256 endurance,uint256 time,bool flag,uint256 sleep2) =getHeroEndurance(tokenId);
        if(flag){
            sleepEndurance[tokenId] = sleep2;
             lastDayUseEndurance[tokenId] = 0;
        }
        enduranceTime[tokenId] = time;
        require(endurance >= 50,"Endurance error");
        require(!heroIsSleep[tokenId],"hero is sleeping");
         require(_nft.ownerOf(tokenId) == msg.sender,"owner error");
        heroNftProficiency[tokenId] += 5;
         heroNftEndurance[tokenId] = endurance;
        lastDayUseEndurance[tokenId] += 150;
        heroNftEndurance[tokenId] -= 150;
         uint256 heroType = _nft.heroType(tokenId);
        uint256 amount = 2*10**14*heroNftLevel[tokenId];
        if(heroType == 1){
            amount  = amount*10;  
       }
       if(heroType == 2){
           amount  = amount * 12;  
       }
       if(heroType == 3){
            amount  = amount*15;  
       }
       rewards[msg.sender] += amount;
       

    }

    

    function expeditionSecond(uint256 tokenId) external {
         (uint256 endurance,uint256 time,bool flag,uint256 sleep2) =getHeroEndurance(tokenId);
         if(flag){
            sleepEndurance[tokenId] = sleep2;
             lastDayUseEndurance[tokenId] = 0;
        }
        enduranceTime[tokenId] = time;
        require(endurance>= 150,"Endurance error");
        require(!heroIsSleep[tokenId],"hero is sleeping");
        require(_nft.ownerOf(tokenId) == msg.sender,"owner error");
        heroNftProficiency[tokenId] += 5;
      heroNftEndurance[tokenId] = endurance;
        lastDayUseEndurance[tokenId] += 150;
        heroNftEndurance[tokenId] -= 150;
         uint256 heroType = _nft.heroType(tokenId);
        uint256 amount = 3*10**14*heroNftLevel[tokenId];
        if(heroType == 1){
            amount  = amount*10;  
       }
       if(heroType == 2){
           amount  = amount * 12;  
       }
       if(heroType == 3){
            amount  = amount*15;  
       }
        rewards[msg.sender] += amount;

    }

    function expeditionThird(uint256 tokenId) external {
         (uint256 endurance,uint256 time,bool flag,uint256 sleep2) =getHeroEndurance(tokenId);
         if(flag){
            sleepEndurance[tokenId] = sleep2;
             lastDayUseEndurance[tokenId] = 0;
        }
        enduranceTime[tokenId] = time;
        require(endurance >= 500,"Endurance error");
        require(!heroIsSleep[tokenId],"hero is sleeping");
         require(_nft.ownerOf(tokenId) == msg.sender,"owner error");
        heroNftProficiency[tokenId] += 5;
        heroNftEndurance[tokenId] = endurance;
        lastDayUseEndurance[tokenId] += 500;
        heroNftEndurance[tokenId] -= 500;
         uint256 heroType = _nft.heroType(tokenId);
        uint256 amount = 5*10**14*heroNftLevel[tokenId];
        if(heroType == 1){
            amount  = amount*10;  
       }
       if(heroType == 2){
           amount  = amount * 12;  
       }
       if(heroType == 3){
            amount  = amount*15;  
       }
        rewards[msg.sender] += amount;

    }

    function expeditionForth(uint256 tokenId) external {
         (uint256 endurance,uint256 time,bool flag,uint256 sleep2) =getHeroEndurance(tokenId);
         if(flag){
            sleepEndurance[tokenId] = sleep2;
            lastDayUseEndurance[tokenId] = 0;

        }
        enduranceTime[tokenId] = time;
        require(endurance >= 1000,"Endurance error");
        require(!heroIsSleep[tokenId],"hero is sleeping");
        require(_nft.ownerOf(tokenId) == msg.sender,"owner error");
        heroNftProficiency[tokenId] += 5;
        heroNftEndurance[tokenId] = endurance;
        lastDayUseEndurance[tokenId] += 1000;
        heroNftEndurance[tokenId] -= 1000;
        uint256 heroType = _nft.heroType(tokenId);
        uint256 amount = 7*10**14*heroNftLevel[tokenId];
        if(heroType == 1){
            amount  = amount*10;  
       }
       if(heroType == 2){
           amount  = amount * 12;  
       }
       if(heroType == 3){
            amount  = amount*15;  
       }
        rewards[msg.sender] += amount;

    }


    function generateRandoms(uint256 maxValue) public view returns (uint256  result) {
        uint256 randomHash = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.coinbase, gasleft())));
        result = randomHash % maxValue;
    }

    function getHeroEndurance(uint256 tokenId) public view returns (uint256  result,uint256 time,bool flag,uint256 sleep2) {
        uint256 lastTime = enduranceTime[tokenId];
        uint256 pirr = block.timestamp-lastTime;
        if(pirr>86400){
            if(lastDayUseEndurance[tokenId] > heroNftLevel[tokenId]*50){
                return ((heroNftLevel[tokenId]*50 + sleepEndurance[tokenId]-lastDayUseEndurance[tokenId]),lastTime+86400,true,(sleepEndurance[tokenId]+(heroNftLevel[tokenId]*50)-lastDayUseEndurance[tokenId]));
            }
            return ((heroNftLevel[tokenId]*50 + sleepEndurance[tokenId]),lastTime+86400,true,sleepEndurance[tokenId]);
        }else{
            return  (heroNftEndurance[tokenId],lastTime,false,0);
        }

        
    }


     function sleep(uint256 tokenId,uint256 houseId) external{
         require(!heroIsSleep[tokenId],"hero is already sleep");
         require(_nft.ownerOf(tokenId) == msg.sender,"owner error");
         require(_honseNFT.ownerOf(houseId) == msg.sender,"owner error");
         heroIsSleep[tokenId] = true;
         sleepHouse[tokenId] = houseId;
         sleepTime[tokenId] = block.timestamp;   
    }

    function wake(uint256 tokenId) external{
         require(heroIsSleep[tokenId],"hero is already wake");
         require(_nft.ownerOf(tokenId) == msg.sender,"owner error");
         heroIsSleep[tokenId] =false;
         uint256 houseId = sleepHouse[tokenId];
         uint256 fenge = block.timestamp - sleepTime[tokenId];
         uint256 munute = fenge/60;
         uint256 house = houseNftLevel[houseId];
         uint256 addEndurance;
         if(house == 1){
             addEndurance = munute;
             if(munute > 300){
                 addEndurance = 300;
             }
         }
         if(house == 2){
             addEndurance = munute;
             if(munute > 420){
                 addEndurance = 420;
             }
         }
         if(house == 3){
             addEndurance = munute;
             if(munute > 600){
                 addEndurance = 600;
             }
         }
         if(house == 4){
             addEndurance = munute*2;
             if(munute > 1800){
                 addEndurance = 1800;
             }
         }

         if(house == 5){
             addEndurance = munute*3;
             if(munute > 3600){
                 addEndurance = 3600;
             }
         }
         sleepEndurance[tokenId] +=  addEndurance;


    }

    function claimRewards() external{
         payable(msg.sender).transfer(rewards[msg.sender]);
         rewards[msg.sender] = 0;  
    }


    function upgradeHero(uint256 tokenId) external {
       require(_nft.ownerOf(tokenId) == msg.sender,"owner error");
       uint256 heroType = _nft.heroType(tokenId);
       uint256 first = heroNftEndurance[tokenId]/50 - 1;
       uint256 second;
       if(heroType == 1){
            second =  heroNftProficiency[tokenId]/200;
       }
       if(heroType == 2){
            second =  heroNftProficiency[tokenId]/500;
       }
       if(heroType == 3){
            second =  heroNftProficiency[tokenId]/1000;
       }
       require(second>first,"user's Proficiency not enough");
         uint256 amount;
         if(heroNftLevel[tokenId]<11){
             amount = 100*10*18;
         }
         
         if(11<=heroNftLevel[tokenId]&&heroNftLevel[tokenId]<11){
             amount = 200*10*18;
         }
         if(21<=heroNftLevel[tokenId]){
             amount = 300*10*18;
         }
         _token.transferFrom(msg.sender,address(this),amount);
         heroNftLevel[tokenId] +=1;
         heroNftEndurance[tokenId] = heroNftLevel[tokenId]*50;
       
    }


    function setPresale(address _presale) public onlyOwner {
        management = _presale;
    }

    function claimToken(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    function claimBalance(address receiveAddress) external onlyOwner{
        payable(receiveAddress).transfer(address(this).balance);
    }




 
   


   
}