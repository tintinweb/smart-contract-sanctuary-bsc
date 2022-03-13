/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/*
 ____        __                 __                  __                  ___        __                    
/\  _`\     /\ \__             /\ \                /\ \                /\_ \      /\ \                   
\ \,\L\_\   \ \ ,_\     __     \ \ \/'\       __   \ \ \___      ___   \//\ \     \_\ \      __    _ __  
 \/_\__ \    \ \ \/   /'__`\    \ \ , <     /'__`\  \ \  _ `\   / __`\   \ \ \    /'_` \   /'__`\ /\`'__\
   /\ \L\ \   \ \ \_ /\ \L\.\_   \ \ \\`\  /\  __/   \ \ \ \ \ /\ \L\ \   \_\ \_ /\ \L\ \ /\  __/ \ \ \/ 
   \ `\____\   \ \__\\ \__/.\_\   \ \_\ \_\\ \____\   \ \_\ \_\\ \____/   /\____\\ \___,_\\ \____\ \ \_\ 
    \/_____/    \/__/ \/__/\/_/    \/_/\/_/ \/____/    \/_/\/_/ \/___/    \/____/ \/__,_ / \/____/  \/_/ 
 ______    ____       ______      __  __      __  __     
/\__  _\  /\  _`\    /\  _  \    /\ \/\ \    /\ \/\ \    
\/_/\ \/  \ \ \L\ \  \ \ \L\ \   \ \ `\\ \   \ \ \/'/'   
   \ \ \   \ \  _ <'  \ \  __ \   \ \ , ` \   \ \ , <    
    \ \ \   \ \ \L\ \  \ \ \/\ \   \ \ \`\ \   \ \ \\`\  
     \ \_\   \ \____/   \ \_\ \_\   \ \_\ \_\   \ \_\ \_\
      \/_/    \/___/     \/_/\/_/    \/_/\/_/    \/_/\/_/
      @tokenbank.exchange Stakeholder to Defi Games NFTs and Web3 Development Platform 
*/

interface NFTTOKEN { function getRateItem(uint256 itemId) external returns (uint256); }
interface IERC721 { function transferFrom(address from, address to, uint256 tokenId) external; }
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

contract Ownable is Context {
  address public _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function ownerAddress() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

/*
                                        ██████████████    
                                  ██████████        ██    
                              ████████              ██    
                          ██████                  ████    
                        ██████      ████          ██      
                      ████        ████████      ████      
                    ████        ████░░░░████    ████      
          ████████████          ████░░░░████  ████        
        ████    ▒▒██              ████████    ████        
        ██    ▒▒██                  ████    ████          
      ████  ▒▒██          ████            ████            
      ██▒▒  ▒▒██        ████▒▒██          ████            
    ████▒▒▒▒██        ████▒▒██▒▒        ████              
    ████████████    ████▒▒██▒▒        ████                
            ░░    ████▒▒██▒▒        ████                  
      ░░░░        ██▒▒██▒▒        ████                    
    ▒▒▒▒░░        ▒▒██▒▒        ██▒▒██                    
  ░░▒▒▒▒▒▒░░                ████  ▒▒██                    
        ▒▒░░          ░░████▒▒    ▒▒██                    
      ▒▒▒▒▒▒░░    ░░  ▒▒██▒▒      ▒▒██                    
    ▒▒▒▒▒▒▒▒░░░░▒▒░░  ▒▒██▒▒▒▒██████                      
  ░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░▒▒████████                          
  ▒▒      ▒▒▒▒▒▒░░▒▒░░  ████                              
        ▒▒▒▒▒▒  ▒▒▒▒                                      
        ▒▒░░    ▒▒░░                                      
*/
contract StakeHolderTBANK is ReentrancyGuard, Ownable {

  using SafeMath for uint;

  address public immutable _Tbank;
  address public immutable _Busd;
  address public _NftToken;
  

  uint256 public _totalPoolNft;
  uint256 public _totalPool;
  uint256 public _totalPayedTBANK;
  uint256 public _totalPayedBUSD;

  struct StakeContract {
    uint256   balance;      //owner TBANK send
    uint256   endLock;      //avaiable to receive 15 days
    uint256   tbankPays;    //ballance TBANK to claim 
    uint256   busdPays;     //ballance BUSD to claim 
    uint256   nftRate;     //ballance BUSD to claim 
    bool      inGame;
  }
  mapping(address => StakeContract) _pool;
  address[] internal _wallets;

  mapping(uint => address) _nftsPool;

  //start
  constructor() {
    _Busd = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    _Tbank = 0x9c14eFdC39f68A00F53B2237ab7D5b9Bcf8E43Cc;
    _NftToken = 0xade700eaDD83DD10C69F0036860a026daA1f4639;
  //_Tbank = 0x833b5Cb9A2Cffb1587BbefE53A451D0989FBA714;
  }
  
  //receiver
  receive() external payable {}

  //Stakeholder sending TBANK MINIMUN 10.000 TBANK
  function sendToStake(uint amount) external nonReentrant {
    
    require (amount >= 10000 * (10**18),"Minimun amount to Stake not valid.");
    IERC20(_Tbank).transferFrom(msg.sender, address(this), amount);

    uint preEndLock = _pool[msg.sender].endLock;
    uint preTbankpays = _pool[msg.sender].tbankPays;
    uint preBusdPays = _pool[msg.sender].busdPays;
    uint preNftRate = _pool[msg.sender].nftRate;
    bool inGame = _pool[msg.sender].inGame;

      if (!inGame) {
        inGame = true;
        _wallets.push(msg.sender);
      }
      if (preEndLock == 0) preEndLock = block.timestamp + 15 minutes;

      _totalPool = _totalPool.add(amount);

      _pool[msg.sender] = StakeContract (
        _pool[msg.sender].balance.add(amount),
        preEndLock,
        preTbankpays,
        preBusdPays,
        preNftRate,
        inGame
      );

  }

  //Stakeholder sending TBANK MINIMUN 10.000 TBANK
  function rescueStake(uint amount) external nonReentrant {
    
    require (amount >= 10000 * (10**18),"Minimun rescue amount not valid.");
    bool inGame = _pool[msg.sender].inGame;
    require (inGame, "You are not holder");
    uint preBalance = _pool[msg.sender].balance;
    require (preBalance >= 10000 * (10**18),"Minimun rescue amount not valid.");
    uint preEndLock = _pool[msg.sender].endLock;
    require(block.timestamp >= preEndLock, 'too early');

    uint preNftRate = _pool[msg.sender].nftRate;
    uint preTbankpays = _pool[msg.sender].tbankPays;
    uint preBusdPays = _pool[msg.sender].busdPays;

        if (preBalance.sub(amount) < 10000 * (10**18)) preEndLock = 0;

      _totalPool = _totalPool.sub(amount);

      _pool[msg.sender] = StakeContract (
        _pool[msg.sender].balance.sub(amount),
        preEndLock,
        preTbankpays,
        preBusdPays,
        preNftRate,
        inGame
      );

    IERC20(_Tbank).transferFrom(address(this), msg.sender, amount);

  }



    function sendNFTToStake(uint tokenId) external nonReentrant {
    
    IERC721(_NftToken).transferFrom(msg.sender, address(this), tokenId);
    _nftsPool[tokenId] = msg.sender; //oenwer

    uint preBalance = _pool[msg.sender].balance;
    uint preEndLock = _pool[msg.sender].endLock;
    uint preTbankpays = _pool[msg.sender].tbankPays;
    uint preBusdPays = _pool[msg.sender].busdPays;
    uint preNftRate = _pool[msg.sender].nftRate;
    bool inGame = _pool[msg.sender].inGame;

    uint nftRary = NFTTOKEN(_NftToken).getRateItem(tokenId);

      if (!inGame) {
        inGame = true;
        _wallets.push(msg.sender);
      }
      if (preEndLock == 0) preEndLock = block.timestamp + 15 minutes;

      _totalPoolNft = _totalPoolNft.add(nftRary);

      _pool[msg.sender] = StakeContract (
        preBalance,
        preEndLock,
        preTbankpays,
        preBusdPays,
        preNftRate,
        inGame
      );

  }

  //Stakeholder sending TBANK MINIMUN 10.000 TBANK
  function rescueNFTStake(uint tokenId) external nonReentrant {
    
    require (_nftsPool[tokenId] == msg.sender,"You are not NFT owner ");
    bool inGame = _pool[msg.sender].inGame;
    require (inGame, "You are not holder");
    uint preEndLock = _pool[msg.sender].endLock;
    require(block.timestamp >= preEndLock, 'too early');

    uint preBalance = _pool[msg.sender].balance;
    uint preNftRate = _pool[msg.sender].nftRate;
    uint preTbankpays = _pool[msg.sender].tbankPays;
    uint preBusdPays = _pool[msg.sender].busdPays;

    uint nftRary = NFTTOKEN(_NftToken).getRateItem(tokenId);

      if (preNftRate.sub(nftRary) == 0) preEndLock = 0;

      _totalPoolNft = _totalPoolNft.sub(nftRary);

      _pool[msg.sender] = StakeContract (
        preBalance,
        preEndLock,
        preTbankpays,
        preBusdPays,
        _pool[msg.sender].nftRate.sub(nftRary),
        inGame
      );

    IERC721(_NftToken).transferFrom(address(this), msg.sender, tokenId);

  }




  function calcFraction(uint256 holdProjection, uint256 contractBalanceProjection) public pure returns (uint) {
                  //500000
    uint holds = holdProjection * (10**18);
                            //600000
    uint contractBalance = contractBalanceProjection * (10**18);
                        //    600 - 500 = 100
    uint totalToDistribute = contractBalance.sub(holds); // = 100.000.000000000000000000

    holds = holds.div(10**18); // transformo 200.000.000000000000000000 = 200.000 inteiro
    uint fraction = totalToDistribute.div(holds); 

    return fraction;
  }

  function distributeRewards(uint256 whatToken) external onlyOwner nonReentrant {

    uint holdsTotalPool = _totalPool;
    uint holdsTotalNFT = _totalPoolNft;
    

    uint contractBalance;
    uint totalToDistribute;

    if (whatToken == 1) {
      contractBalance = IERC20(_Tbank).balanceOf(address(this));
      totalToDistribute = contractBalance.sub(holdsTotalPool).sub(_totalPayedTBANK); 
     _totalPayedTBANK = _totalPayedTBANK.add(totalToDistribute);
    }

    if (whatToken == 2) {
      contractBalance = IERC20(_Busd).balanceOf(address(this));
      totalToDistribute = contractBalance.sub(holdsTotalPool).sub(_totalPayedBUSD); 
     _totalPayedBUSD = _totalPayedBUSD.add(totalToDistribute);
    }

    holdsTotalPool = holdsTotalPool.div(10**18); // transformo 200.000.000000000000000000 = 200.000 inteiro

    //aqui se o total que eu peguei for Tbank ou BUSD eu tranformo em 100% 
    uint totalCalc = totalToDistribute;
    // divido 60% stake tbank e 40% stake NFT 
    totalCalc = totalCalc.div(10); // 10 cotas
    uint totalToDistributeStake = totalCalc.mul(6); //6 cotas 60% 
    uint totalToDistributeStakeNFT = totalCalc.mul(4); //4 cotas 40% 
    
    uint fractionStake = totalToDistributeStake.div(holdsTotalPool);
    uint fractionStakeNFT = totalToDistributeStakeNFT.div(holdsTotalNFT);

    uint amountCoins;
    uint amountCoinsExt;
    
          //for next distribuit cada unidade de fracao p cada balanco retirado 18 casas decimais
          for(uint256 i; i < _wallets.length; i++){
              if(_pool[_wallets[i]].balance >= 10000 * (10**18)) {

                  //stakeholders
                  amountCoins = 0;
                  amountCoins = _pool[_wallets[i]].balance.div(10**18);
                  amountCoins = amountCoins.mul(fractionStake);

                  //nftholders
                  amountCoinsExt = 0;
                  amountCoinsExt = _pool[_wallets[i]].balance.div(10**18);
                  amountCoinsExt = amountCoinsExt.mul(fractionStakeNFT);
                  if (amountCoinsExt > 0) amountCoins = amountCoins.add(amountCoinsExt);

                  if (whatToken == 1) _pool[_wallets[i]].tbankPays = _pool[_wallets[i]].tbankPays.add(amountCoins);
                  if (whatToken == 2) _pool[_wallets[i]].busdPays = _pool[_wallets[i]].busdPays.add(amountCoins);
              }
            }

  }


  function claimRewards(uint256 whatToken) external nonReentrant {

    uint256 sendAmount;

      if (whatToken == 1 && _pool[msg.sender].tbankPays > 0 ) {
         sendAmount = _pool[msg.sender].tbankPays;
        _pool[msg.sender].tbankPays = 0;
        IERC20(_Tbank).transfer(msg.sender, sendAmount);
        sendAmount = 0;
      }

      if (whatToken == 2 && _pool[msg.sender].busdPays > 0 ) {
         sendAmount = _pool[msg.sender].busdPays;
        _pool[msg.sender].busdPays = 0;
        IERC20(_Busd).transfer(msg.sender, sendAmount);
        sendAmount = 0;
      }

  }


  function getPool (address holder) public view returns (StakeContract memory) { return _pool[holder]; }
  function getMyPool () public view returns (StakeContract memory) {  return _pool[msg.sender]; }

  function getBusdBalance (address holder) public view returns (uint) { return _pool[holder].busdPays;  }
  function getTbankBalance (address holder) public view returns (uint) { return _pool[holder].busdPays;  }

  function getTotalHolders () public view returns (uint) { return _wallets.length; }
  function getTotalPool () public view returns (uint) { return _totalPool; }
  function getTotalPoolNft () public view returns (uint) { return _totalPoolNft; }
  function getPayedTbank () public view returns (uint) { return _totalPayedTBANK; }
  function getPayedbusd () public view returns (uint) { return _totalPayedBUSD; }

  function getTotalBusdBalance () public view returns (uint) { return IERC20(_Busd).balanceOf(address(this));  }
  function getTotalTbankBalance () public view returns (uint) { return IERC20(_Tbank).balanceOf(address(this));  }

  function withdraw() external onlyOwner { payable(_owner).transfer(address(this).balance); }


}