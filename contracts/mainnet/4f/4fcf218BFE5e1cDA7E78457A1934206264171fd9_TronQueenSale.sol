/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

pragma solidity ^0.5.16;


contract TronQueenSale {
    
    event Sell(address indexed user, uint256 amount, uint8 saleType);

	mapping (address => uint) internal usersPresale;
	mapping (address => uint) internal usersSale;
    
	address payable public adminWallet;
    address payable public marketingAddress;
    address payable public owner;
    address payable public devAddress;
    address payable public roiContract;
    address payable public liquidityWallet;
    address payable public tronqueenWallet;
    
    address public babyQueen;
    
    bool public preSaleLock = false;
    bool public saleLock = true;
    uint public presalePrice = 1;
    uint public salePrice = 3;
    
    uint public totalSoldoutPresale;
    uint public totalSoldoutSale;

	constructor(address payable marketingAddr, 
	            address payable _owner,  
	            address payable adminAddr, 
	            address payable devAddr,
	            address payable roi,
                address payable tronqueen,
	            address payable liquidity,
	            address tokenAddress) public {        
		marketingAddress = marketingAddr;
        owner = _owner;
        devAddress = devAddr;
        adminWallet=adminAddr;
        roiContract = roi;
        tronqueenWallet = tronqueen;
        liquidityWallet = liquidity;
        babyQueen = tokenAddress;
	}

	function buyPresale() public payable {
	    
	    require(babyQueen != address(0) && !preSaleLock);
	    
        uint _amount = msg.value * 1000 / presalePrice;
        
		require(usersPresale[msg.sender] + _amount <= 10000 * 10**18);
		
		usersPresale[msg.sender] += _amount;
        
        BEP20(babyQueen).transferFrom(owner, msg.sender, _amount);
        
        distributeCommission(msg.value);
        
        totalSoldoutPresale += _amount;
        
		emit Sell(msg.sender, _amount, 0);
	}

	function buySale() public payable {
	    
	    require(babyQueen != address(0) && !saleLock);
	    
	    uint _amount = msg.value * 1000 / salePrice;
	    
		require(usersSale[msg.sender] + _amount <= 100000 * 10**18);
		
        usersSale[msg.sender] += _amount;
        
        BEP20(babyQueen).transferFrom(owner, msg.sender, _amount);
        
        distributeCommission(msg.value);
        
        totalSoldoutSale += _amount;
        
		emit Sell(msg.sender, _amount, 1);
	}
	
    function distributeCommission(uint _amount) private {
        devAddress.transfer(_amount*25/1000);
        owner.transfer(_amount*25/1000);
        adminWallet.transfer(_amount*25/1000);
        tronqueenWallet.transfer(_amount*25/1000);
        marketingAddress.transfer(_amount*5/100);
        roiContract.transfer(_amount*10/100);
        liquidityWallet.transfer(_amount - (4*(_amount*25/1000) + (_amount*5/100) + (_amount*10/100)));
    }
    
    function getUserPresale(address _addr) external view returns(uint) {
        return usersPresale[_addr];
    }
    
    function getUserSale(address _addr) external view returns(uint) {
        return usersSale[_addr];
    }

    function getData(address _addr) external view returns(uint256[] memory){
        uint[] memory d = new uint[](4);
        d[0] = usersPresale[_addr];
        d[1] = usersSale[_addr];
        d[2] = totalSoldoutPresale;
        d[3] = totalSoldoutSale;
        return d;
    }
    
   modifier onlyDev {
      require(msg.sender == devAddress);
      _;
   }
    
    function setToken(address _addr) external onlyDev {
        babyQueen = _addr;
    }
    
    function setPresalePrice(uint _price) external onlyDev {
        presalePrice = _price;
    }
    
    function setSalePrice(uint _price) external onlyDev {
        salePrice = _price;
    }
    
    function setPresaleLock(bool _val) external onlyDev {
        preSaleLock = _val;
    }
    
    function setSaleLock(bool _val) external onlyDev {
        saleLock = _val;
    }
}

interface BEP20 {
    function transferFrom(address from, address to, uint value) external returns (bool); 
}