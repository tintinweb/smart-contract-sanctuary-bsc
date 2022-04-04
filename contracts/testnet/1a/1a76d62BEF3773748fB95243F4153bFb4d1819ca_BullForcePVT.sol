//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./IBEP20.sol";
import "./ICanMint.sol";



contract BullForcePVT is Ownable,ICanMint {
    using SafeMath for uint256;
  mapping(address => prop) donor;
   
    uint256 public _bfAmount;
    uint256 public bnbQuantity;
    address[] public wl;
    uint256 public hardCap;
    uint256 public flagWl = 0;
    struct prop {
        bool exist;
        uint256 bnb;
        bool isclaim;
        uint256 bf;
        uint256 nextPeriod;
        uint256 _bfAmount;
    }

    // Payable address can receive Ether
    IBEP20 public token;
    uint256 public start=1;
    uint256 public max =5 * 1 ether;
    uint256 public min = 1 * 0.1 ether ;
    uint256 public vestingPercent =0;
    uint256 public vestingPeriod =0;
    uint256 public firstVesting =0;
    address public  uniswapV2Pair;
     bool public seedSaleswapping;


    // Payable constructor can receive Ether
    constructor(IBEP20 _token, uint256 bnbQ,uint256 bfAmount){
        token = _token;
      _bfAmount =bfAmount;
      bnbQuantity = bnbQ;
    
    } 


    
   function isCanMint() public override pure returns(bool){
       return true;
   }

   function setToken(IBEP20 addr) external onlyOwner{
       token = addr;
   }

    function setBFAmount(uint256 bfAmount) external onlyOwner{
        _bfAmount = bfAmount;
    }


    function setBFSwapping(bool _enabled) external onlyOwner {
        require(seedSaleswapping != _enabled,"Swapping is 'enabled'");
        seedSaleswapping =_enabled;
    }

    function getBuyerBNBAmount() public view returns (uint256) {
        return donor[_msgSender()].bnb;
    }
  
       function getBFUintForBuyer() public view returns (uint256) {
        return donor[_msgSender()]._bfAmount;
    }
     
      function getBuyerBFAmount() public view returns (uint256) {
        return donor[_msgSender()].bnb.mul(donor[_msgSender()]._bfAmount);
    }

    function getHardCap() public view returns (uint256) {
        return hardCap;
    }


    function getReceivedAmount() public view returns (uint256) {
        return donor[_msgSender()].bf;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
     function setHardCap(uint256 bnbQ) external onlyOwner {
        
       bnbQuantity = bnbQ;
  
    }
    
    function setStart(uint256 on) external onlyOwner {
        
       start = on;
  
    }

   
     function getStart() public view returns (uint256) {
        return start;
    }
    

    function setMaximum(uint256 _max) external onlyOwner{
        max = _max * 1 ether;
    }

    function setMinimum(uint256 _min) external onlyOwner{
        min = _min * 0.1 ether ;
    }

    function setVestingPercent (uint256 _percent) external onlyOwner{

        vestingPercent = _percent;

    }

    function setVestingPeriod(uint256 _day) external onlyOwner{
        vestingPeriod = _day;
    }

    function setfirstVestingPercent(uint256 _first) external onlyOwner{
        firstVesting = _first;
    }
    

       function claimRFP() public {

        require (start == 2,"Claim Not enabled");
            _claimRFP();
     
     
       }
    function _claimRFP () internal {

         uint256 totalAmount = donor[_msgSender()].bnb.mul(donor[_msgSender()]._bfAmount);
         require (donor[_msgSender()].bf < totalAmount, "You have claimed all token");
          require (donor[_msgSender()].nextPeriod < block.timestamp, "Wait for the Next Vesting Period");
            
            uint256 bf = totalAmount.mul(vestingPercent.mul(0.01 ether)).div(1 ether);
              
               if(bf>0){
                donor[_msgSender()].bf=donor[_msgSender()].bf.add(bf);

           
            bf = totalAmount.sub(donor[_msgSender()].bf)>bf? bf:totalAmount.sub(donor[_msgSender()].bf);
             
             uint256 pvtAmount = totalAmount.sub(donor[_msgSender()].bf);
               
                token.pvtDividend(_msgSender(),pvtAmount);

              token.transferFrom(token.getOwner(), _msgSender(), bf);
                          
              donor[_msgSender()].nextPeriod = block.timestamp + (vestingPeriod * 1 days);     
          
            }


    }

       function storeValue () internal {
           
            donor[_msgSender()].bnb =donor[_msgSender()].bnb.add(msg.value);
      
            uint256 bf = msg.value.mul(_bfAmount.mul(firstVesting * 0.01 ether)).div(1 ether);
           
            if(bf>0){
                
                token.transferFrom(token.getOwner(),_msgSender(),bf);
                 donor[_msgSender()].bf=donor[_msgSender()].bf.add(bf);  
                 
                     
            }
            
            donor[_msgSender()]._bfAmount = (donor[_msgSender()]._bfAmount>0)? donor[_msgSender()]._bfAmount : _bfAmount;


            donor[_msgSender()].nextPeriod = block.timestamp + (vestingPeriod * 1 days);
            
       }  

       function migratePVTForDividend(address _msgsender,uint256 _bnb) external onlyOwner {
           storeValue(_msgsender,_bnb);
      
       }

         function storeValue (address _msgSender, uint256 _bnb) internal {
           
             _bnb = _bnb * 1 ether;
           
            donor[_msgSender].bnb =donor[_msgSender].bnb.add(_bnb);
      
            uint256 bf =_bnb.mul(_bfAmount.mul(firstVesting * 0.01 ether)).div(1 ether);
           
            if(bf>0){
                
                token.transferFrom(token.getOwner(),_msgSender,bf);
                 donor[_msgSender].bf=donor[_msgSender].bf.add(bf);  
                                
            }
            
            donor[_msgSender]._bfAmount = (donor[_msgSender]._bfAmount>0)? donor[_msgSender]._bfAmount : _bfAmount;


            donor[_msgSender].nextPeriod = block.timestamp + (vestingPeriod * 1 days);
            
       }  
   
    function acceptFund() external payable {
                    _acceptFund();
                    
    } 
    function _acceptFund() internal {
        
         require(
            (donor[_msgSender()].bnb + msg.value) <= max,
            "greater than 5 bnb maximum."
        );
        require(
            (donor[_msgSender()].bnb + msg.value) >= min,
            "Amount less than 0.1 BNB minimum"
        );
        require(hardCap < bnbQuantity, "Hard Cap Filled");

             storeValue();
       
        
          hardCap +=msg.value;
    }



    function withrawFundAllBNB() public {
        require(_msgSender() == owner(), "Only Owner");
        uint256 amount = address(this).balance;
        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = owner().call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    //Function to transfer Ether from this contract to address from input

   function transferBNBToAddress(address payable _to, uint256 _amount) public {
        // Note that "to" is declared as payable
        require(_msgSender() == owner(), "Only Owner");
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

}