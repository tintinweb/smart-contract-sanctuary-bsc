/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



interface IERC20 {
    function name() external view returns(string memory);

    function symbol() external view returns(string memory);

    function decimals() external pure returns(uint); // 0

    function totalSupply() external view returns(uint);

    function balanceOf(address account) external view returns(uint);

    function transfer(address to, uint amount) external;

    function allowance(address _owner, address spender) external view returns(uint);

    function approve(address spender, uint amount) external;

    function transferFrom(address sender, address recipient, uint amount) external;

    event Transfer(address indexed from, address indexed to, uint amount);

    event Approve(address indexed owner, address indexed to, uint amount);
}





contract MShop {
    IERC20 public token;
    address payable public owner;
    event Bought(uint _amount, address indexed _buyer);
    event Sold(uint _amount, address indexed _seller);
    uint public startTime;
    constructor() {
        token = IERC20(address(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee));
        owner = payable(msg.sender);
        startTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner!");
        _;
    }

    struct Invest {
        uint timeInvest;
        uint amount;
    }

    struct Partner {
        address user;
        uint investmentAmount;
        address referal;
        Invest[] arrayOfInvest;  
        address[] refsons1Lvl;   
        address[] refsons2Lvl;  
        address[] refsons3Lvl;  
        address[] refsons4Lvl;  
        address[] refsons5Lvl; 
        uint referalProfitTime;
        uint pendingReferalProfit;
    }

    uint profit_for10 = uint(20);
    uint maxInvestment = uint(1000000000000000000);
    uint timerRange = uint(1); 
    uint taxRate= uint(5);
    mapping(address => Partner) public partners;

    //Pool[] pools;

    function addPartner(uint _amount,address _user,address _referal) private{

        //Partner[] storage partnerArray;

        Partner storage partner = partners[_user];
        //pools[pool_id] = Pool(pool_id,_name,uint(0),uint(0),_max);
        partner.user=_user;
        partner.referal=_referal;
        partner.investmentAmount=_amount;
        partner.arrayOfInvest.push(Invest(block.timestamp,_amount));
        partner.referalProfitTime=block.timestamp;
        partner.pendingReferalProfit=0;
    }
	
    function addPartnerInvest(uint _amount,address _user) private{

        //Partner[] storage partnerArray;

        Partner storage partner = partners[_user];
        //pools[pool_id] = Pool(pool_id,_name,uint(0),uint(0),_max);
        partner.investmentAmount+=_amount;
        partner.arrayOfInvest.push(Invest(block.timestamp,_amount));
        partner.referalProfitTime=block.timestamp;
    }


    // interface
    function getBalance()  public view returns (uint){
        uint _allBalance;
        _allBalance = partners[msg.sender].investmentAmount+getProfitFromInvest(msg.sender);
        return (_allBalance);
    }

    function getMyProfitFromReferals() public view returns (uint){
        Partner storage partner = partners[msg.sender];
        uint _profit = partner.pendingReferalProfit+getaAllProfitFromUsers(msg.sender);
        return (_profit);
    }     

    function getMyReferalsCount() public view returns (uint,uint,uint,uint,uint){
        return (partners[msg.sender].refsons1Lvl.length,partners[msg.sender].refsons2Lvl.length,partners[msg.sender].refsons3Lvl.length,
                partners[msg.sender].refsons4Lvl.length,partners[msg.sender].refsons5Lvl.length);
    }


    //end interface


    function getProfitFromInvest(address _user)  public view returns (uint){
        Partner storage partner = partners[ _user];
        Invest[] memory arrayInv = partner.arrayOfInvest; 

        uint length = arrayInv.length;
        uint _amount = 0;
        uint _am;
        uint time_max;
        uint time_was;
        uint time_pr;
        uint profit;
        for(uint i = 0; i < length; i++) {
           _am=arrayInv[i].amount; 
           time_max =  240 * timerRange;
           time_was = block.timestamp-arrayInv[i].timeInvest;
           time_pr = time_was*100/time_max;
           if (time_pr>100) time_pr=100;
           profit= _am * time_pr * profit_for10 /100 /100;
           _amount+=profit;
        }
        return (_amount);

    }

    function getProfitFromInvestReferal(address _user,uint _time)  public  view returns (uint){
        Partner storage partner = partners[ _user];
        Invest[] memory arrayInv = partner.arrayOfInvest; 

        uint length = arrayInv.length;
        uint _amount = 0;
        uint _am;
        uint time_max;
        uint time_was;
        uint time_pr;
        uint profit;
        for(uint i = 0; i < length; i++) {
          if (_time<arrayInv[i].timeInvest+(240 * timerRange)){
           _am=arrayInv[i].amount; 
           time_max =  240 * timerRange;
           time_was = block.timestamp-arrayInv[i].timeInvest;
           if (arrayInv[i].timeInvest>_time && _time+time_max<block.timestamp){
               if (_time+time_max>arrayInv[i].timeInvest) time_was = _time+time_max-arrayInv[i].timeInvest;
               else time_was = 0;
           }
           
           //time_was = _time+time_max-arrayInv[i].timeInvest;
           
           if (arrayInv[i].timeInvest<_time) { 
               if (block.timestamp>arrayInv[i].timeInvest+time_max){
                   time_was = (arrayInv[i].timeInvest+time_max)-_time;
               }
               else time_was = block.timestamp-_time;
               
           }
           time_pr = time_was*100/time_max;
           if (time_pr>100) time_pr=100;
           profit= _am * time_pr * profit_for10 /100 /100;
           
           _amount+=profit;
          }
        }
        

        return (_amount);
        
    }


    function getArrayOfInvest(address _user)  public view returns (Invest[] memory){
       Partner storage partner = partners[ _user];
       return (partner.arrayOfInvest);

    }

    function getMaxInvest() public view returns (uint){
        uint _maxInvest_mult= (block.timestamp-startTime) / (720 * timerRange);
        uint _maxInvest = 2**(_maxInvest_mult+1)*maxInvestment;
        return (_maxInvest);

    }

    
    function getRefFather(address _user)  public view returns (address){
       if (_user==address(0)) return (address(0));
       return (partners[ _user].referal);

    }   

    function sumAllProfit(address[] memory _array,uint _time)  private view returns(uint){
        uint _profit =0;
        for(uint i =0; i < _array.length; i++){
            _profit+=getProfitFromInvestReferal(_array[i],_time);
        } 
        return (_profit);

    }


    function getaAllProfitFromUsers(address _user)  private view returns(uint){
       uint _profit =0;
       _profit+=sumAllProfit(partners[ _user].refsons1Lvl,partners[ _user].referalProfitTime)*5/100;
       _profit+=sumAllProfit(partners[ _user].refsons2Lvl,partners[ _user].referalProfitTime)*2/100;
       _profit+=sumAllProfit(partners[ _user].refsons3Lvl,partners[ _user].referalProfitTime)*15/1000;
       _profit+=sumAllProfit(partners[ _user].refsons4Lvl,partners[ _user].referalProfitTime)/100;
       _profit+=sumAllProfit(partners[ _user].refsons5Lvl,partners[ _user].referalProfitTime)*5/1000;
       return (_profit);
    }   


    function addPendingProfit(address _user) private returns(uint) {
       //1lvl
       address referal=getRefFather(_user);
       if (referal!=address(0)) partners[referal].pendingReferalProfit+=getProfitFromInvestReferal(_user,partners[referal].referalProfitTime)*5/100;
       //2lvl
       referal=getRefFather(referal);
       if (referal!=address(0)) partners[referal].pendingReferalProfit+=getProfitFromInvestReferal(_user,partners[referal].referalProfitTime)*2/100;
       //3lvl
       referal=getRefFather(referal);
       if (referal!=address(0)) partners[referal].pendingReferalProfit+=getProfitFromInvestReferal(_user,partners[referal].referalProfitTime)*15/1000;
       //4lvl
       referal=getRefFather(referal);
       if (referal!=address(0)) partners[referal].pendingReferalProfit+=getProfitFromInvestReferal(_user,partners[referal].referalProfitTime)/100;
       //5lvl
       referal=getRefFather(referal);
       if (referal!=address(0)) partners[referal].pendingReferalProfit+=getProfitFromInvestReferal(_user,partners[referal].referalProfitTime)*5/1000;
       return (partners[getRefFather(_user)].pendingReferalProfit);
    }



    function buyInvestment2(uint _amountToSell, address _referal) external {




        Partner storage partner = partners[msg.sender];
        require(partner.arrayOfInvest.length==0,"You have investment!");
        uint commission;
		commission=_amountToSell*taxRate/100;
        
        uint endAmount = _amountToSell + commission;


        require(
            endAmount > 0 &&
            token.balanceOf(msg.sender) >= endAmount,
            "incorrect amount!"
        );
        token.approve(address(this), endAmount);
        //uint allowance = token.allowance(msg.sender, address(this));
        //require(allowance >= endAmount, "check allowance!");

        token.transferFrom(msg.sender, address(this), endAmount);
        uint _amount = _amountToSell;
        uint _amountAll =partner.investmentAmount + _amount;
        uint _change = uint(0);
        uint _maxInvest_mult= (block.timestamp-startTime) / (720 * timerRange);
        uint _maxInvest = 2**(_maxInvest_mult+1)*maxInvestment;
        if (_amountAll>_maxInvest){
            _change = _amountAll-_maxInvest;
            _amountAll = _maxInvest;

        }
        if (partner.user==address(0)){
            token.transferFrom(address(this), _referal, (_amount*10/100));
            token.transferFrom(address(this), owner, commission);
            addPartner(_amountAll,msg.sender,_referal);
            partners[_referal].refsons1Lvl.push(msg.sender);
            partners[getRefFather(_referal)].refsons2Lvl.push(msg.sender);
            partners[getRefFather(getRefFather(_referal))].refsons3Lvl.push(msg.sender);
            partners[getRefFather(getRefFather(getRefFather(_referal)))].refsons4Lvl.push(msg.sender);
            partners[getRefFather(getRefFather(getRefFather(getRefFather(_referal))))].refsons5Lvl.push(msg.sender);
        } 
        else{
          if (_amountAll-partner.investmentAmount>0){ 
          addPartnerInvest(_amountAll-partner.investmentAmount,msg.sender);
          token.transferFrom(address(this), owner, commission);
          }
        }

        //token.transferFrom(address(this), owner, commission);

        //payable(msg.sender).transfer(_amountToSell);
        emit Sold(_amountToSell, msg.sender);
    }

    function buyInvestmentSelf(uint _amountToSell) external  {

        address _referal = address(0);
        Partner storage partner = partners[msg.sender];
        require(partner.arrayOfInvest.length==0,"You have investment!");
        uint commission;
		commission=_amountToSell*taxRate/100;
        
        uint endAmount = _amountToSell + commission;
        require(
            endAmount > 0 &&
            token.balanceOf(msg.sender) >= endAmount,
            "incorrect amount!"
        );

        token.approve(address(this), endAmount);
        //uint allowance = token.allowance(msg.sender, address(this));
        //require(allowance >= endAmount, "check allowance!");

        token.transferFrom(msg.sender, address(this), endAmount);
        uint _amount = _amountToSell;
        uint _amountAll =partner.investmentAmount + _amount;
        uint _change = uint(0);
        uint _maxInvest_mult= (block.timestamp-startTime) / (720 * timerRange);
        uint _maxInvest = 2**(_maxInvest_mult+1)*maxInvestment;
        if (_amountAll>_maxInvest){
            _change = _amountAll-_maxInvest;
            _amountAll = _maxInvest;

        }
        if (partner.user==address(0)){
            token.transferFrom(address(this), _referal, (_amount*10/100));
            token.transferFrom(address(this), owner, commission);
            addPartner(_amountAll,msg.sender,_referal);
            partners[_referal].refsons1Lvl.push(msg.sender);
            partners[getRefFather(_referal)].refsons2Lvl.push(msg.sender);
            partners[getRefFather(getRefFather(_referal))].refsons3Lvl.push(msg.sender);
            partners[getRefFather(getRefFather(getRefFather(_referal)))].refsons4Lvl.push(msg.sender);
            partners[getRefFather(getRefFather(getRefFather(getRefFather(_referal))))].refsons5Lvl.push(msg.sender);
        } 
        else{
          if (_amountAll-partner.investmentAmount>0){ 
          addPartnerInvest(_amountAll-partner.investmentAmount,msg.sender);
          token.transferFrom(address(this), owner, commission);
          }
        }

        //token.transferFrom(address(this), owner, commission);

        //payable(msg.sender).transfer(_amountToSell);
        emit Sold(_amountToSell, msg.sender);
    }


    function buyInvestment_private(uint _amountToSell, address _referal) private {


        Partner storage partner = partners[msg.sender];
        require(partner.arrayOfInvest.length==0,"You have investment!");
        uint commission;
		commission=_amountToSell*taxRate/100;
        
        uint _amount = _amountToSell;
        uint _amountAll =partner.investmentAmount + _amount;
        uint _change = uint(0);
        uint _maxInvest_mult= (block.timestamp-startTime) / (720 * timerRange);
        uint _maxInvest = 2**(_maxInvest_mult+1)*maxInvestment;
        if (_amountAll>_maxInvest){
            _change = _amountAll-_maxInvest;
            _amountAll = _maxInvest;

        }
        if (partner.user==address(0)){
            token.transferFrom(address(this), _referal, (_amount*10/100));
            token.transferFrom(address(this), owner, commission);
            addPartner(_amountAll,msg.sender,_referal);
            partners[_referal].refsons1Lvl.push(msg.sender);
            partners[getRefFather(_referal)].refsons2Lvl.push(msg.sender);
            partners[getRefFather(getRefFather(_referal))].refsons3Lvl.push(msg.sender);
            partners[getRefFather(getRefFather(getRefFather(_referal)))].refsons4Lvl.push(msg.sender);
            partners[getRefFather(getRefFather(getRefFather(getRefFather(_referal))))].refsons5Lvl.push(msg.sender);
        } 
        else{
          if (_amountAll-partner.investmentAmount>0){ 
          addPartnerInvest(_amountAll-partner.investmentAmount,msg.sender);
          token.transferFrom(address(this), owner, commission);
          }
        }

        //token.transferFrom(address(this), owner, commission);

        //payable(msg.sender).transfer(_amountToSell);
        emit Sold(_amountToSell, msg.sender);
    }

    event Windraw(uint geted);

    function withdrawProfit(uint _amountToSell) external  returns(uint){
        Partner storage partner = partners[msg.sender];
        Invest[] memory arrayInv = partner.arrayOfInvest; 

        uint length = arrayInv.length;
        uint _amount = 0;
        uint lastTime;
        for(uint i = 0; i < length; i++) {
           _amount+=arrayInv[i].amount;
           lastTime=arrayInv[i].timeInvest;
        }
        require(block.timestamp>lastTime+(240 * timerRange),"Time not ended!");
        require(_amountToSell>=_amount,"Amount < Deposit"); 
        uint commission;
		commission=_amountToSell*taxRate/100;
        
        uint endAmount = _amountToSell + commission;
        require(
            endAmount > 0 &&
            token.balanceOf(msg.sender) >= endAmount,
            "incorrect amount!"
        );

        token.approve(address(this), endAmount);
        //uint allowance = token.allowance(msg.sender, address(this));
        //require(allowance >= endAmount, "check allowance!");
        token.transferFrom(msg.sender, address(this), endAmount);
        uint summ = addPendingProfit(msg.sender);
        partner.investmentAmount = uint(0);
        uint _profit=getProfitFromInvest(msg.sender);
        for(uint i =0; i < arrayInv.length; i++){
        partner.arrayOfInvest.pop();
        }
        _profit+=getaAllProfitFromUsers(msg.sender);  
        _profit+=partner.pendingReferalProfit;
        if (_profit+_amount>_amount*150/100) _profit=_amount*150/100;
        else _profit=_profit+_amount;
        partner.pendingReferalProfit=0;  
        buyInvestment_private(_amountToSell, partner.referal);
        emit Windraw(_profit);
        token.transferFrom(address(this), msg.sender, _profit);
        return(summ);
    }
	
		

}