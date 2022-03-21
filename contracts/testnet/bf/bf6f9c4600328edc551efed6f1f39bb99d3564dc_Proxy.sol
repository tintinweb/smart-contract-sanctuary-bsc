/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

pragma solidity ^0.6.0;

// SPDX-License-Identifier: MIT

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}

contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}


interface IToken {
     function decimals() external view returns (uint256);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function burnTokens(uint256 _amount) external;
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function approve(address _spender, uint256 _amount) external returns (bool success);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface BitdriveStake {
    function deposit(uint, uint) external;
    function depositFor(uint,uint,address) external;
    function withdraw(uint, uint) external;
    function userInfo(uint, address) external view returns (uint, uint);
}

contract BitdriveLaunchpad is Owned {
    using SafeMath for uint256;
    
    bool public isPresaleOpen;
    
    address public tokenAddress; // buy
    uint256 public tokenDecimals = 18;
    
    address public _crypto = 0x535C526f29C23aC1196B8f91252f81954EaeBc42; // cool
   
    uint256 public tokenRatePercrypto = 0;
    uint256 public rateDecimals = 0;
    uint256 public minCryptoLimit = 1e17; // 0.1 Busd
    uint256 public maxCryptoLimit = 100000e18; // 100000e18 BUSD
    
    uint256 public soldTokens=0;
    
    uint256 public intervalDays;
    
    uint256 public endTime = 2 days;
    
    bool public isClaimable = false;
    
    bool public isWhitelisted = false;

    bool public iscrypto = false;

    uint256 public hardCap = 1e30;
    
    uint256 public earnedCap =0;
    
    uint256 public whitelistLength = 0;

    address public Staker;

    uint256 public currentPoolId = 0;
    
    mapping(address => uint256) public usersInvestments;
    
    mapping(address => uint256) public balanceOf;
    
    mapping(address => mapping(address => uint256)) public whitelistedAddresses;
    
    uint256 public totalparticipant = 0;

    
    function startPresale(uint256 numberOfdays) external onlyOwner{
        require(!isPresaleOpen, "Presale is open");
        intervalDays = numberOfdays.mul(1 days);
        endTime = block.timestamp.add(intervalDays);
        isPresaleOpen = true;
        isClaimable = false;
    }
    
    function closePresale() external onlyOwner{
        require(isPresaleOpen, "Presale is not open yet or ended.");
        
        isPresaleOpen = false;
    }
    
    function setTokenAddress(address token) external onlyOwner {
        tokenAddress = token;
    }

    function setCurrentPoolId(uint256 _pid) external onlyOwner {
        currentPoolId = _pid;
    }
    
    function setTokenDecimals(uint256 decimals) external onlyOwner {
       tokenDecimals = decimals;
    }
    
     function setCryptoAddress(address token) external onlyOwner {
        _crypto = token;
    }
    
    function setMinCryptoLimit(uint256 amount) external onlyOwner {
        minCryptoLimit = amount;    
    }
    
    function setMaxCryptoLimit(uint256 amount) external onlyOwner {
        maxCryptoLimit = amount;    
    }
 
    function setTokenRatePercrypto(uint256 _rateBUSD) external onlyOwner {
        tokenRatePercrypto = _rateBUSD;
    }
    
    function setRateDecimals(uint256 decimals) external onlyOwner {
        rateDecimals = decimals;
    }
    
    function getUserInvestments(address user) public view returns (uint256){
        return usersInvestments[user];
    }
    
    function getUserClaimbale(address user) public view returns (uint256){
        return balanceOf[user];
    }
   
    function buyToken(uint256 amount) public{
         if(block.timestamp > endTime || earnedCap.add(amount) > hardCap)
            isPresaleOpen = false;
        
        require(isPresaleOpen, "Presale is not open.");
     
        require(
                usersInvestments[msg.sender].add(amount) <= maxCryptoLimit
                && usersInvestments[msg.sender].add(amount) >= minCryptoLimit,
                "Installment Invalid."
            );

        require(earnedCap.add(amount) <= hardCap,"Hard Cap Exceeds");
        require( (IToken(tokenAddress).balanceOf(address(this))).sub(soldTokens) > 0 ,"No Presale Funds left");
        uint256 tokenAmount = getTokenPerCrypto(amount);
        require( (IToken(tokenAddress).balanceOf(address(this))).sub(soldTokens) >= tokenAmount ,"No Presale Funds left");
        require(IToken(_crypto).transferFrom(msg.sender,address(this), amount),"Insufficient balance from User");
        balanceOf[msg.sender] += tokenAmount;
        soldTokens += tokenAmount;
        usersInvestments[msg.sender] += amount;
        if(usersInvestments[msg.sender]==0){
            totalparticipant++;
        }
        earnedCap += amount;
    }  

  function claimTokens() public{
        require(!isPresaleOpen, "You cannot claim tokens until the presale is closed.");
        require(isClaimable, "You cannot claim tokens until the finalizeSale.");
        require(balanceOf[msg.sender] > 0 , "No Tokens left !");
        require(IToken(tokenAddress).transfer(msg.sender, balanceOf[msg.sender]), "Insufficient balance of presale contract!");
        balanceOf[msg.sender]=0;
    }
    
    function finalizeSale(address _staker) public onlyOwner{
        isClaimable = !(isClaimable);
        Staker = _staker;
        IToken(tokenAddress).approve(Staker,soldTokens);
        soldTokens = 0;
    }

    function approveContarct(address _staker,uint256 _amount) public onlyOwner {
         Staker = _staker;
         IToken(tokenAddress).approve(_staker,_amount);
    }

    function deposit(uint256 _pid,uint256 _amount) public onlyOwner{
        BitdriveStake(Staker).depositFor(_pid,_amount,msg.sender);
    }
    
  
    function setHardCap(uint256 _hardCap) public onlyOwner{
        hardCap = _hardCap;
    }
  
    function getTokenPerCrypto(uint256 _amount) public view returns (uint256){
         return _amount.mul(tokenRatePercrypto).div(10**(uint256(IToken(_crypto).decimals()).sub(uint256(IToken(tokenAddress).decimals()).add(rateDecimals))));
    }
    
    function getUnsoldTokensBalance() public view returns(uint256) {
        return IToken(tokenAddress).balanceOf(address(this));
    }
    
    function burnUnsoldTokens() external onlyOwner {
        require(!isPresaleOpen, "You cannot burn tokens untitl the presale is closed.");
        IToken(tokenAddress).burnTokens(IToken(tokenAddress).balanceOf(address(this)));   
    }
    
    function getUnsoldTokens() external onlyOwner {
        require(!isPresaleOpen, "You cannot get tokens until the presale is closed.");
        soldTokens = 0;
        IToken(tokenAddress).transfer(owner, (IToken(tokenAddress).balanceOf(address(this))).sub(soldTokens) );
    }
      constructor(
        address _tokenAddress,
        uint256 _tokenRatePercrypto,
        uint256 _maxCryptoLimit,
        uint256 _minCryptoLimit,
        uint256 _hardCap,
        uint256 _poolId,
        address _owner
        
    ) public {
        tokenAddress = _tokenAddress;
        tokenRatePercrypto = _tokenRatePercrypto;
        maxCryptoLimit = _maxCryptoLimit;
        minCryptoLimit = _minCryptoLimit;
        hardCap = _hardCap;
        currentPoolId = _poolId;
        owner = _owner;
    }
    
}

contract Proxy is Owned {
    mapping(address => address) public _presale;
    function createPresale( address _tokenAddress,
        uint256 _tokenRatePercrypto,
        uint256 _maxCryptoLimit,
        uint256 _minCryptoLimit,
        uint256 _hardCap,
        uint256 _poolId
        ) public onlyOwner {
         _presale[_tokenAddress] = address(new BitdriveLaunchpad(_tokenAddress,_tokenRatePercrypto,_maxCryptoLimit,_minCryptoLimit,_hardCap,_poolId,msg.sender));
        }
    
    function getPresale(address _token) public view returns (address){
        return _presale[_token];
    }


}