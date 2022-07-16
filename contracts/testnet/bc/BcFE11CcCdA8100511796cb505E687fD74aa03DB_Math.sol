/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface  administrator {
    function getOwner() external view returns (address); 
    function licenceSet(address _who,bool  enable) external  returns (bool) ;
    function TokenNamepermissionSet(string memory  _name,bool _state) external  returns (bool);
    function transferpermissionSet(address _who,bool  enable) external  returns (bool);
    function Qmathaddress() external view  returns (address _mathaddress);
    function Qusdaddress() external view  returns (address _usdaddress);
    function QBaseTokenmanagement() external view returns (address _BaseTokenmanagement);
    function Qtokendatabase() external view  returns (address _tokendatabase);
    function QMembship() external view  returns (address _Membship);
    function qtransferpermission(address _who) external view returns (bool);
    function licence(address _who) external view  returns (bool);
    function QDaoAddress() external view  returns (address _DaoAddress) ;
    function QTdbAddress() external view returns (address _TdbAddress);
    function Qcommission() external view returns (uint  ommissionRate_);
    function QTokenNamepermission(string memory _name) external view returns (bool _state);
}
contract Acurve {
    address private  owner;
    uint256 private t0=0;
    uint256 t1=10000000000;
    mapping (uint256 => uint256) private price00;
    ///////////////
    constructor()  {
    owner = msg.sender;
    price00[0]=t1;     
    }

    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
        /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
    function Set(uint256 i1) public isOwner  returns (bool zs) {
    uint p1=t0+i1;
     for (uint i = t0; i < p1; i++) { 
        t0++;
        price00[t0]=price00[t0-1]*103/100;
    }
    return true;
    }
    function Qpointprice(uint256 i) public view returns (uint256 _price) {

    return price00[i];
    }  
    
    function queryN() public view returns (uint256 _t0,uint256 _t1) {

    return (t0,t1);
    }
    
}
contract Math  {
    mapping (address => bool) admin;  
    address  owner;
    Acurve Acu1 =Acurve(0x7Dd520E26FE89872848f6862922ab8CbDA52350A);
    administrator creatorT =administrator(0x44770B1fB49615fC137aA9Cb077471c405eE893f);
    mapping (address => bool)  private  mathpermission;
    constructor ()  {
      owner = msg.sender;  
      admin[owner]=true;
      mathpermissionSet(address(this),true);
    }
    function SetAdmin (address _admin,bool _yn) public {
    assert(admin[msg.sender]==true);
    admin[_admin]=_yn;
    }
    function isContract(address account) public view returns (bool) {    
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (!(codehash != 0x0 && codehash != accountHash)||mathpermission[account] == true);
    }
    function mathpermissionSet(address _who,bool  enable) public  returns (bool) {
        require( creatorT.licence(msg.sender) == true || admin[msg.sender]==true);
        mathpermission[_who] = enable;
        return true;
    }

    function qmathpermission(address _who) public view virtual returns (bool) {
        return mathpermission[ _who];
    }
   function Rounding(uint256 _m,uint256 unitsNumber) internal pure  returns (uint256 down,uint256 up) { 
    
    uint256  t1= _m/unitsNumber ;
    uint256  t2=(_m+unitsNumber-1)/unitsNumber ;
    return (t1,t2);
    }
   function ShowPrice(uint256 _m,uint256 unitsNumber) internal view  returns (uint256 price) { 
    uint256  p1 ;    uint256  p2 ;   uint256  p12 ;   uint256  s1 ;    uint256  s2 ; 

    (s1,s2)=Rounding( _m, unitsNumber);
    p1= Acu1.Qpointprice(s1);
    p2= Acu1.Qpointprice(s2);
    if(s1!=s2){
     uint remainder;
     remainder=(_m-s1*unitsNumber)*1000000000000000/unitsNumber ;
     p12=p1+(p2-p1)*remainder/1000000000000000;
    }else{p12=p2;}
    
    return p12;
    }

   function BPs(uint256 _m,uint256 _change,uint256 unitsNumber) internal view  returns (uint256 Intervalprice){
    require(_change<unitsNumber);
    require(_change>0);
    uint priceold;
    uint pricenew;
    uint priceIn;

    priceold=ShowPrice( _m, unitsNumber);
    pricenew=ShowPrice( _m+_change, unitsNumber); 

    uint256  s1 ;    uint256  s2 ; uint256  s3 ;    uint256  s4 ; 

    (s1,s2)=Rounding( _m, unitsNumber);
    (s3,s4)=Rounding( _m+_change, unitsNumber);
    //
    if((s3+s4-s1-s2)<2){
    priceIn=(priceold+pricenew)/2;  
    } else{
    priceIn=(
        (Acu1.Qpointprice(s2)+priceold)/2*(s2*unitsNumber-_m)
        +
        (pricenew+Acu1.Qpointprice(s2))/2*(_m+_change-s2*unitsNumber)
        )/_change;   
    }
    priceIn++;
    return priceIn;    
    } 

   function SPs(uint256 _m,uint256 _change,uint256 unitsNumber) internal view   returns (uint256 Intervalprice){ 
    require(_change<unitsNumber);
    require(_change<=_m && _change>0 );
    uint priceold;
    uint pricenew;
    uint priceIn;
    
    uint256  s1 ;    uint256  s2 ; uint256  s3 ;    uint256  s4 ; 

    (s1,s2)=Rounding( _m, unitsNumber);
    (s3,s4)=Rounding( _m-_change, unitsNumber);
    
    priceold=ShowPrice( _m, unitsNumber);
    pricenew=ShowPrice( _m-_change, unitsNumber); 
    
    if((s1+s2-s3-s4)<2){
    priceIn=(priceold+pricenew)/2;  
    } else
    {

    priceIn=(
        (Acu1.Qpointprice(s1)+priceold)/2*(_m-s1*unitsNumber)
        +
        (pricenew+Acu1.Qpointprice(s1))/2*(s1*unitsNumber-(_m-_change))
        )/_change;   
    }
     priceIn--; 
    return priceIn;    
    }      

   function Qnowprice(uint256 Tamount,uint256 unitsNumber,uint256 multiple) public view returns (uint256 _price) {
    require(isContract(msg.sender)==true);   
    if( Tamount==0)
    {return ( ShowPrice(1,unitsNumber)*multiple/1000 );}
    else{    return( ShowPrice(Tamount,unitsNumber)*multiple/1000 ); }
    } 

   function QBIPprice(uint256 _tokenvalue,uint256 Tamount,uint256 unitsNumber,uint256 multiple) public view  returns (uint256 _price){
      require(isContract(msg.sender)==true);
      return(BPs(Tamount,_tokenvalue,unitsNumber)*multiple/1000);  
      }

   function QSIPprice(uint256 _tokenvalue,uint256 Tamount,uint256 unitsNumber,uint256 multiple) public view  returns (uint256  _price){
      require(isContract(msg.sender)==true);
      return (SPs(Tamount,_tokenvalue,unitsNumber)*multiple/1000) ;  
      }  

   function QBuy(uint256 _tokenvalue,uint256 Tamount,uint256 unitsNumber,uint256 multiple) public view  returns (uint256 _usdcvalue){
      require(isContract(msg.sender)==true);
      return(_tokenvalue*BPs(Tamount,_tokenvalue,unitsNumber)*multiple/1000/1000000000000000);  
      }

   function QSell(uint256 _tokenvalue,uint256 Tamount,uint256 unitsNumber,uint256 multiple) public view  returns (uint256 _usdcvalue){
      require(isContract(msg.sender)==true);
      return (_tokenvalue*SPs(Tamount,_tokenvalue,unitsNumber)*multiple/1000/1000000000000000) ;  
      }  

   function Qpurchase(uint256 usdvalue,uint256 Tamount,uint256 unitsNumber,uint256 multiple) 
   public view  returns (uint256 _uv,uint256 _tv){
      require(isContract(msg.sender)==true);
      uint256 uv1=0;uint256 tv1=0;
      uv1=QBuy( (unitsNumber-1),Tamount,unitsNumber,multiple);
      
      if(usdvalue>=uv1) {
      tv1=unitsNumber-1;
      
      }
      
      else{

      tv1 = usdvalue *1000000000000000/QBIPprice(unitsNumber-1,Tamount,unitsNumber,multiple);
      uv1=QBuy(tv1,Tamount,unitsNumber,multiple);  

       if((usdvalue-uv1)>usdvalue/1000 && usdvalue>uv1){  
      tv1 = tv1*(100000000+(unitsNumber-tv1)*10000*146/(unitsNumber-1))/100000000 ; 
      uv1=QBuy(tv1,Tamount,unitsNumber,multiple);

        if((usdvalue-uv1)>usdvalue/1000 && usdvalue>uv1){
        tv1 = tv1*(100000000+(usdvalue-uv1)*100000000*97/usdvalue/100)/100000000; 
        uv1=QBuy(tv1,Tamount,unitsNumber,multiple);

            } 
        }

      }
      return(uv1,tv1);     
      }

    
    }