/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;


abstract contract OwnableMulti {
    mapping(address => bool) private _owners;

 
    constructor() {
        _owners[msg.sender] = true;
    }


    function isOwner(address _address) public view virtual returns (bool) {
        return _owners[_address];
    }

  
    modifier onlyOwner() {
        require(_owners[msg.sender], "Ownable: caller is not an owner");
        _;
    }

    function addOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        _owners[_newOwner] = true;
    }
}




interface IERC20 {
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}




contract DragonEgg is OwnableMulti {
    uint256 private _issuedSupply;
    uint256 private _outstandingSupply;
    uint256 private _decimals;
    string private _symbol;

  

    mapping(address => uint256) private _balances;
    event Issued(address account, uint256 amount);
    

    constructor(string memory __symbol, uint256 __decimals) {
        _symbol = __symbol;
        _decimals = __decimals;
        _issuedSupply = 0;
        _outstandingSupply = 0;
    }

   
    function issue(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "zero address");
        _issuedSupply = _issuedSupply + amount;
        _outstandingSupply = _outstandingSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Issued(account, amount);
    }


    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function issuedSupply() public view returns (uint256) {
        return _issuedSupply;
    }

    function outstandingSupply() public view returns (uint256) {
        return _outstandingSupply;
    }
}



contract BuyDragonEgg {

  
    string public Version = "27/07/2022";
    address public investToken;
    address public treasury;
    DragonEgg public egg;

    uint256 public totalraised;
    uint256 public totalissued;
    uint256 public startTime;
    uint256 public duration;
    uint256 public endTime;

    bool public saleEnabled;
	bool public isExtended;
    
    uint256 public mininvest;
    uint256 public maxinvest;
    uint256 public numWhitelisted = 0;
    uint256 public numInvested = 0;



    struct DragonInfo {
        uint256 amountInvested; 
        bool claimed; 
    }
    
 
    mapping(address => bool) public whitelisted;
    mapping(address => DragonInfo) public dragonInfoMap;

    mapping(address => bool) public isOwner;
    address[] public whitelists;

        
       modifier onlyTeam() {
        require(isOwner[msg.sender], "Request Not From A CoreTeam Member");
        _;
    }

    constructor(
        address _investToken,
        uint256 _minInvest,
        uint256 _maxinvest,
        address _treasury
    ) {

        investToken = _investToken;
        mininvest = _minInvest;
        maxinvest = _maxinvest;
        treasury = _treasury;
        egg = new DragonEgg("pMDG", 18);
        saleEnabled = true;
		isExtended = false;
        isOwner[msg.sender] = true;
         startTime = block.timestamp;
         duration = 259200;
         endTime = startTime + duration;
  
    }

   function getWhitelists() public view returns (address[] memory) {
        return whitelists;
    }

    function addTeamMember(address _address)  external onlyTeam{
     isOwner[_address] = true;
    }

    function removeTeamMember(address _address)  external onlyTeam{
     isOwner[_address] = false;

    }
   
    function updateStartTime(  
         uint256 _startTime,
         uint256 _duration) external onlyTeam {
         startTime = _startTime;
         duration = _duration;
         require(duration < 8 days, "duration too long");
         endTime = startTime + duration;
    }


    function addWhitelist(address _address) external onlyTeam {
        require(!whitelisted[_address], "already whitelisted");
        if(!whitelisted[_address])
            numWhitelisted = numWhitelisted + 1;
        whitelisted[_address] = true;
    }


    function removeWhitelist(address _address) external onlyTeam {
       DragonInfo storage dragon = dragonInfoMap[_address];
       require( dragon.amountInvested == 0, "Already Entered Whitelist");
       whitelisted[_address] = false;
    }

  

   function DragonEggPurchase(uint256 investAmount) public {
        require(saleEnabled, "Purchase Disabled");
        require(block.timestamp >= startTime, "Public Presale Event Not Yet Started!");
        require(endTime >= block.timestamp, "Public Presale Event Ended.");
        require(investAmount >= mininvest && investAmount <= maxinvest , "Not a Valid Amount To Invest!");
        DragonInfo storage dragon = dragonInfoMap[msg.sender];
        require(dragon.amountInvested == 0, "Already Participated In the Public PreSale!");
        require(
            investAmount == 100000000 
         || investAmount == 200000000
         || investAmount == 300000000 
         || investAmount == 400000000
         || investAmount == 500000000 
         || investAmount == 600000000 
         || investAmount == 700000000 
         || investAmount == 800000000 
         || investAmount == 900000000 
         || investAmount == 1000000000 
         || investAmount == 1100000000 
         || investAmount == 1200000000 
         || investAmount == 1300000000 
         || investAmount == 1500000000 
         || investAmount == 1650000000
         || investAmount == 1700000000 
         || investAmount == 1800000000 
         || investAmount == 1900000000 
         || investAmount == 2000000000 
         || investAmount == 2100000000 
         || investAmount == 2200000000 
         || investAmount == 2300000000 
         || investAmount == 2400000000 
         || investAmount == 2500000000 
           ,"Invalid Amount Range From $100 to $2500" );

        whitelists.push(msg.sender);
        uint256 issueAmount = investAmount * 1000000000000;
        totalraised = totalraised + investAmount;
        totalissued =  totalissued + issueAmount;
        egg.issue(msg.sender, issueAmount);

        if (dragon.amountInvested == 0){
            numInvested = numInvested + 1;
        }   

        dragon.amountInvested = dragon.amountInvested + investAmount;
        require(
            IERC20(investToken).transferFrom(
                msg.sender, 
                treasury,
                investAmount
            ),
            "Amount Transfer To Treasury Failed!"
        ); 
        emit DragonEggPruchased(msg.sender, investAmount);
    }


 
    function setstartTime(uint256 _startTime) public onlyTeam {
        require(block.timestamp <= startTime, "too late, sale has started");
        require(!saleEnabled, "sale has already started");
        startTime = _startTime;
        endTime = _startTime + duration;
    }



    function toggleSale() public onlyTeam {
        if(block.timestamp > endTime ) {
            saleEnabled = false;
            emit SaleEnabled(false, block.timestamp);
        } else {
            saleEnabled = true;
            emit SaleEnabled(true, block.timestamp);
        }
    }

	function extendSale() public onlyTeam {
		require(!isExtended, 'cannot extend a second time');
		isExtended = true;
		endTime = endTime + 86400;
	}


    event SaleEnabled(bool enabled, uint256 time);
    event DragonEggPruchased(address dragon, uint256 amount);
    event Redeem(address dragon, uint256 amount);

}