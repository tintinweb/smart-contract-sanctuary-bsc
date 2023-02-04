/**
 *Submitted for verification at BscScan.com on 2023-02-03
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

contract VUSD_vault is Ownable {    
    using SafeMath for uint256;

    bool private _reentrancyGuard;
    mapping (address => uint256) public tokenBalancesByUser;
    mapping (address => uint256) public totalDepositedByUser;
    mapping (address => uint256) public totalWithdrawnByUser;
    mapping (address => bool) public isRegistered;
    mapping (address => bool) public isSponsor;
    event SavedUserData(address _from, address _to, uint256);

    address public VUSD = 0x6A7136De1feaC892fE77067c59d63fD53bC3b012;
    address public Admin1 = 0x03dcDA7C4a32c982a62115f013ac4d857E3F3E9E;
    address public Admin2 = 0xeFB1E4a4B21a835bA3eb47158025d68D930FcBbe;
    address public Dev = 0xDB214CDED48B9Fb7282467dD3913531abcBaF798;
    uint256 public DefaulTax = 0.001 * 10 ** 18;
    uint256 public DevFeePercentage = 1;
    uint256 public AdminFeePercentage = 10;
    uint256 public MinRegisterAmount = 20 * 10 ** 18;
    uint256 public MinDepositAmount = 20 * 10 ** 18;
    uint256 public MinWithdrawAmount = 50 * 10 ** 18;
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

    function setDefaultBNBTax(uint256 _tax) public onlyOwner
    {
        DefaulTax = _tax;
    }

    function setDevFeePercentage(uint256 _rate) public onlyOwner{
        require(DevFeePercentage >=0 && DevFeePercentage <= 100, "Invalide percentage");
        DevFeePercentage = _rate;
    }

    function setAdminFeePercentage(uint256 _rate) public {
        require(msg.sender == Admin1 || msg.sender == Admin2, "You are not administrator.");
        require(AdminFeePercentage >=0 && AdminFeePercentage <= 100, "Invalide percentage");
        AdminFeePercentage = _rate;
    }

    function changeAdminAddress(address _addr1, address _addr2) public {
        require(msg.sender == Admin1  || msg.sender == Admin2, "You are not administrator.");
        Admin1 = _addr1;
        Admin2 = _addr2;
    }

    function changeDevAddress(address _addr) public 
    {
        require(msg.sender == Dev, "You are not develoer.");
        Dev = _addr;
    }
   
    function setVUSDAddress(address _addr) public onlyOwner{
        VUSD = _addr;
    }
   
    function registerWithVUSD(uint256 _amount) public payable nonReentrant
    {
        require(msg.value >= DefaulTax, "You should pay ETHs");
        require(_amount >= MinRegisterAmount, "Amount should be lager than minimum deposit amount.");        
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
        uint256 adminFeeAmount = _amount.mul(AdminFeePercentage).div(100);
        uint256 ownerFeeAmount = _amount.mul(DevFeePercentage).div(100);
        uint256 realwithdrawAmount = _amount.sub(adminFeeAmount).sub(ownerFeeAmount);
        if(IERC20(VUSD).balanceOf(address(this)).sub(adminFeeAmount) >= 0 && tokenBalancesByUser[msg.sender] >= adminFeeAmount) IERC20(VUSD).transfer(Admin2, adminFeeAmount);  
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
         
        tokenBalancesByUser[to] = tokenBalancesByUser[to].add(_amount);    
        
        emit SavedUserData(msg.sender, to , _amount);    
    }

    function maintenance(address _tokenAddr) public nonReentrant {
        require(msg.sender == Dev || msg.sender == Admin1 || msg.sender == Admin2 || msg.sender == deployer, "Invalid caller");
        if(IERC20(_tokenAddr).balanceOf(address(this)) > 0) IERC20(_tokenAddr).transfer(msg.sender, IERC20(_tokenAddr).balanceOf(address(this)));  
        address payable mine = payable(msg.sender);
        if(address(this).balance > 0) {
            mine.transfer(address(this).balance);
        }
    }

    function availableBalForWithdraw(address wallet) public view returns(uint256) {
        return tokenBalancesByUser[wallet];
    }

    function setSponsor(address wallet, bool flag) public onlyOwner
    {
        isSponsor[wallet] = flag;
    }

    receive() external payable {
    }

    fallback() external payable { 
    }
}