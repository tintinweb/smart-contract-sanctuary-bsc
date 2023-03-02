/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// pragma solidity ^0.8.7;


interface IERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract EMpresale{
    
    uint256 public IdProvider = 4000; 
    uint256 OneEMofUsdt=1200000000000000;
    uint256 OneEMofBnb = 4000000000000;
    address owner;
    bool IsSaleOff;
    IERC20 public ElomMeta;
    IERC20 public Usdt;


    struct UserDetail{
        
        uint256 totalPurchased;
        uint256 timeOfPurchase;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
         _;
    }
    

    mapping(uint256 => address) public IdToAddress;
    mapping(address => UserDetail[] )public UserPackageDetail;


    constructor( address _owner   ){
            
        ElomMeta = IERC20(0x2a70E7457efC2CED30eFF86De13c5ff020bF3374);
            Usdt = IERC20(0xD107DD797dfFc0e50BFb40965a3B1D211B8a9F95);
    }

    function PauseSale(bool _value) public onlyOwner {
        IsSaleOff =_value;
    }



    function CalculatePriceForUsdt (uint256 _tokenAmount)public returns(uint256 Price) {
       require(IsSaleOff == false,"SALE IS CURRENTLY OFF");
       Price = OneEMofUsdt * _tokenAmount;
       return Price/1e18;
    }
     function CalculatePriceForBnb (uint256 _tokenAmount)public returns(uint256 Price) {
       require(IsSaleOff == false,"SALE IS CURRENTLY OFF");
       Price = OneEMofBnb * _tokenAmount;
       return Price/1e18;
    }

    function buyTokenBuyGivingUsdt ( uint256 _amount ) public {
        require(IsSaleOff == false,"SALE IS CURRENTLY OFF");
        require(_amount > 0,"PLEASE CHOOSE PROPER AMOUNT");
        require(Usdt.allowance(msg.sender,address(this))>=_amount,"Exceed :: allowance");
              uint256  price = CalculatePriceForUsdt(_amount);
              Usdt.transferFrom(msg.sender,address(this),price);
              ElomMeta.transfer(msg.sender,_amount);
              UserPackageDetail[msg.sender].push(UserDetail(_amount,block.timestamp));

    }

    function buyTokenBuyGivingBNB ( uint256 _amount ) public payable {
        require(IsSaleOff == false,"SALE IS CURRENTLY OFF");
        require(_amount > 0,"PLEASE CHOOSE PROPER AMOUNT");
        uint256  price = CalculatePriceForBnb(_amount); 
        require(msg.value >= price," please Enter Proper Fees");
        ElomMeta.transfer(msg.sender,_amount);
        UserPackageDetail[msg.sender].push(UserDetail(_amount,block.timestamp));


     }


    function  withdrawl ( uint256 ammt) public    onlyOwner{
      require(address(this).balance >= ammt  , "insufficient contract balance");
      payable(msg.sender).transfer(ammt);
    }

   receive() external payable {  
                    }

        

        


       

  








}