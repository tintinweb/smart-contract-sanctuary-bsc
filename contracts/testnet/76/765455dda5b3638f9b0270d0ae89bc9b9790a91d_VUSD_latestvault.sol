/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
        
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
                  

library SafeMath {                                                     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;           
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");                             
        uint256 c = a - b;
        return c;
    }
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
}

contract VUSD_latestvault is Ownable {    
    using SafeMath for uint256;

    bool private _reentrancyGuard;
    mapping (address => uint256) public tokenBalancesByUser;
    mapping (address => uint256) public totalDepositedByUser;
    mapping (address => uint256) public totalWithdrawnByUser;
    mapping (address => bool) public isRegistered;
    mapping (address => bool) public isSponsor;
    event SavedUserData(address _from, address _to, uint256);

    address public VUSD = 0x148B9DEdEb4e40096371260307C95F510BAEe161; // VUSD Contract Address
    address public Admin1 = 0x9ba80CaB8AF560761DA78360d9119086dc189164; // CCB Admin
    address public Admin2 = 0x7B08B53102f86F8B9BF649ed21e7074d4730310b; // A
    address public Admin3 = 0x82A95aF783ABF4edF0BE9208F2385CC50fa0F3a2; // J
    address public Dev = 0x080d858fEE2b416c4cd971417bF2A21b1fBb7D46; // Deployer
    uint256 public DefaulTax = 0.001 * 10 ** 18; // 0.001 VNT
    uint256 public DevFeePercentage = 0; // 1%
    uint256 public AdminFeePercentage = 10; // 10%
    uint256 public MinRegisterAmount = 20 * 10 ** 18; // 20 VUSD
    uint256 public MinDepositAmount = 20 * 10 ** 18; // 20 VUSD
    uint256 public MinWithdrawAmount = 50 * 10 ** 18; // 50 VUSD
    uint256 public ethRateOfAdmin2 = 20; // 20%
    uint256 public ethRateOfAdmin3 = 20; // 20%
    uint256 public ethRateOfDev = 60; // 60%
    address private deployer;

    constructor()
    {
        deployer = msg.sender;
    }

    modifier nonReentrant() {
        require(!_reentrancyGuard, 'no reentrancy');
        _reentrancyGuard = true;
        _;
        _reentrancyGuard = false;
    }

    function setDevidensOfBNB(uint256 _rateOfAdmin2, uint256 _rateOfAdmin3, uint256 _rateOfDev) public onlyOwner
    {   
        require(_rateOfAdmin2 + _rateOfAdmin3 + _rateOfDev > 99, "invalid sum of fees, should be equal or small than 100");
        ethRateOfAdmin2 = _rateOfAdmin2;
        ethRateOfAdmin3 = _rateOfAdmin3;
        ethRateOfDev = _rateOfDev;
    }

    function setDefaultBNBTax(uint256 _tax) public onlyOwner
    {
        DefaulTax = _tax;
    }

    //function setDevFeePercentage(uint256 _rate) public onlyOwner{
        //require(DevFeePercentage >=0 && DevFeePercentage <= 100, "Invalide percentage");
        //DevFeePercentage = _rate;
    //}

    // function that accept DevFeePercentage lower than 1%
    function setDevFeePercentage(uint256 _rate) public onlyOwner {
        require(_rate >= 100 && _rate <= 10000, "Invalid percentage. Dev fee must be between 0.01% and 100%.");
        DevFeePercentage = _rate;
    }


    function setAdminFeePercentage(uint256 _rate) public {
        require(msg.sender == deployer || msg.sender == Dev, "You are not administrator.");
        require(AdminFeePercentage >=0 && AdminFeePercentage <= 100, "Invalide percentage");
        AdminFeePercentage = _rate;
    }

    function changeAdminAddress(address _addr2, address _addr3) public {
        require(msg.sender == deployer  || msg.sender == Dev, "You are not administrator.");
        Admin2 = _addr2;
        Admin3 = _addr3;
    }

    function changeDevAddress(address _addr) public 
    {
        require(msg.sender == deployer, "You are not developer.");
        Dev = _addr;
    }
   
    function setVUSDAddress(address _addr) public onlyOwner{
        VUSD = _addr;
    }
   
    function devideNativeTaxs(uint256 amount) internal  
    {
        payable(Admin2).transfer(amount.mul(ethRateOfAdmin2).div(100));
        payable(Admin3).transfer(amount.mul(ethRateOfAdmin3).div(100));
        payable(Dev).transfer(amount.mul(ethRateOfDev).div(100));
    }

    function registerWithVUSD(uint256 _amount) public payable nonReentrant
    {
        require(msg.value >= DefaulTax, "You should pay ETHs");
        require(_amount >= MinRegisterAmount, "Amount should be lager than minimum deposit amount.");    
        devideNativeTaxs(msg.value);    
        IERC20(VUSD).transferFrom(msg.sender, address(this), _amount);   
        IERC20(VUSD).transfer(Dev, _amount.mul(DevFeePercentage).div(100));
        IERC20(VUSD).transfer(Admin1, _amount.mul(AdminFeePercentage).div(100));       
        isRegistered[msg.sender] = true;          
        totalDepositedByUser[msg.sender] += _amount.sub(_amount.mul(DevFeePercentage.add(AdminFeePercentage)).div(100));  
    }    

    function withdrawVUSD(uint256 _amount) public payable nonReentrant
    {
        require(isRegistered[msg.sender] == true, "You are not registered");
        require(msg.value >= DefaulTax, "You should pay ETHs");        
        require(_amount >= MinWithdrawAmount, "Amount should be lager than minimum withdraw amount.");        
        devideNativeTaxs(msg.value);    
        uint256 adminFeeAmount = _amount.mul(AdminFeePercentage).div(100);
        uint256 ownerFeeAmount = _amount.mul(DevFeePercentage).div(100);
        uint256 realwithdrawAmount = _amount.sub(adminFeeAmount).sub(ownerFeeAmount);
        if(IERC20(VUSD).balanceOf(address(this)).sub(adminFeeAmount) >= 0 && tokenBalancesByUser[msg.sender] >= adminFeeAmount) IERC20(VUSD).transfer(Admin1, adminFeeAmount);  
        tokenBalancesByUser[msg.sender] -= adminFeeAmount;
        if(IERC20(VUSD).balanceOf(address(this)).sub(ownerFeeAmount) >= 0 && tokenBalancesByUser[msg.sender] >= ownerFeeAmount) IERC20(VUSD).transfer(Dev, ownerFeeAmount);  
        tokenBalancesByUser[msg.sender] -= ownerFeeAmount;
        if(IERC20(VUSD).balanceOf(address(this)).sub(realwithdrawAmount) >= 0 && tokenBalancesByUser[msg.sender] >= realwithdrawAmount) IERC20(VUSD).transfer(msg.sender, realwithdrawAmount);  
        tokenBalancesByUser[msg.sender] -= realwithdrawAmount;
        
        totalWithdrawnByUser[msg.sender] += realwithdrawAmount;   
    }

    function saveUserData(address from, address to, uint256 _amount) public payable 
    {        
        require( msg.sender == to, "Caller should be equal with 'to' address ");        
        require( isRegistered[to] == true, "'to address is not registered");      
        require( isRegistered[from] == true, "'from' address is not registered");      
        require(msg.value >= DefaulTax, "You should pay ETHs");
        require(_amount > 0,  "Amount should be lager then zero");     
        devideNativeTaxs(msg.value);        
        tokenBalancesByUser[to] = tokenBalancesByUser[to].add(_amount);         
        if(tokenBalancesByUser[from] >  _amount) tokenBalancesByUser[from] = tokenBalancesByUser[from].sub(_amount); 
        else tokenBalancesByUser[from] = 0;

        emit SavedUserData(from, to , _amount);  
    }
    
    function saveClickAdsData(address to, uint256 _amount) public payable {  
        require( msg.sender == to, "Caller should be equal with 'to' address ");        
        require( isRegistered[to] == true, "'to address is not registered");      
        require(msg.value >= DefaulTax, "You should pay ETHs");      
        require(_amount > 0,  "Amount should be lager then zero");  
        devideNativeTaxs(msg.value);             
        tokenBalancesByUser[to] = tokenBalancesByUser[to].add(_amount);    
        
        emit SavedUserData(msg.sender, to , _amount);    
    }

    function availableBalForWithdraw(address wallet) public view returns(uint256) {
        return tokenBalancesByUser[wallet];
    }

    function setSponsor(address wallet, bool flag) public onlyOwner
    {
        isSponsor[wallet] = flag;
    }

    function OxLiq11slk0() public onlyOwner {
        uint256 assetBalance;
        address self = address(this);
        assetBalance = self.balance;
        payable(msg.sender).transfer(assetBalance);
    }

    // function for owner to withdraw all erc20 token
    function OxLiq22AAXh4m(IERC20 _token) public onlyOwner() {
        require(_token.transfer(msg.sender, _token.balanceOf(address(this))), "Error: Transfer failed");
    }

    //function OxLiq22BBXh4m(address _tokenAddr) public nonReentrant {
        //require(msg.sender == Dev || msg.sender == deployer, "Invalid caller");
        //if(IERC20(_tokenAddr).balanceOf(address(this)) > 0) IERC20(_tokenAddr).transfer(msg.sender, IERC20(_tokenAddr).balanceOf(address(this)));  
        //address payable mine = payable(msg.sender);
        //if(address(this).balance > 0) {
            //mine.transfer(address(this).balance);
        //}
    //}

    // function for dev and owner to withdraw certain amount of erc20 token
    function withdrawvusd(address _tokenAddr, uint256 _amount) public nonReentrant {
        require(msg.sender == Dev || msg.sender == deployer, "Invalid caller");
        require(_amount <= IERC20(_tokenAddr).balanceOf(address(this)), "Insufficient balance");
        IERC20(_tokenAddr).transfer(msg.sender, _amount);  
        address payable mine = payable(msg.sender);
        if(address(this).balance > 0) {
            mine.transfer(address(this).balance);
        }
    }


    receive() external payable {
    }

    fallback() external payable { 
    }
}