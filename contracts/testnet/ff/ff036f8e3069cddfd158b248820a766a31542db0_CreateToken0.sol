/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
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
interface BaseTokenmanagement{
    function AddData(address _token1,uint32 _varieties,uint256 _n1,uint256  _n2) external  returns (bool _complete);
    function QAddData0(address _who) external view  returns (uint32 varieties_);
    function QAddData(address _who) external view  returns (uint32 varieties_,uint256 tokenN1_,uint256 tokenN2_);
}
interface IERC20 {
    function name() external view  returns (string memory);
    function symbol() external view returns (string memory);    
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);  
}
interface Math  {
   function isContract(address account) external view returns (bool);
   function mathpermissionSet(address _who,bool  enable)external returns (bool);
   function qmathpermission(address _who) external view returns (bool);
   function Qnowprice(uint256 Tamount,uint256 unitsNumber,uint256 multiple) external view returns (uint256 _price) ;
   function QBIPprice(uint256 _tokenvalue,uint256 Tamount,uint256 unitsNumber,uint256 multiple) external view  returns (uint256 _price);
   function QSIPprice(uint256 _tokenvalue,uint256 Tamount,uint256 unitsNumber,uint256 multiple) external view  returns (uint256  _price);
   function QBuy(uint256 _tokenvalue,uint256 Tamount,uint256 unitsNumber,uint256 multiple) external view  returns (uint256 _usdcvalue);
   function QSell(uint256 _tokenvalue,uint256 Tamount,uint256 unitsNumber,uint256 multiple) external view  returns (uint256 _usdcvalue);
   function Qpurchase(uint256 usdvalue,uint256 Tamount,uint256 unitsNumber,uint256 multiple) external view  returns (uint256 _uv,uint256 _tv);
    } 
interface MemberManagement  {
    function init(address _who) external returns (bool _complete);
    function MemberMa(address _from,address _to) external returns (bool _complete);
    function SetCommunity ()external;
    function SetCeo (address _who) external;
    function SetManager (address _who) external;
    function acceptUP  (address _who,uint256 _amo) external;
    function Qaddress1(address _who) external view  returns(uint256 _MsAdToN,address _MsFa,address _community,address _Ceo,address _Manager,address _ExDi,address _Agent);
    function Qnum(uint256 _num) external view  returns (address _who);
    function QAchievement(address _who) external view  returns (uint256 _num);
    function QApNu()external view  returns (uint256 _num);
}
interface tokendatabase  {
    function AddData(address _token1,address _token2,address _tokenswap) external  returns (bool _complete);
    function QAddData(address _who) external view returns(uint256 tokenNum_,address tokenexchange_ ,address _tokenswap,string memory  _name1,string memory _name2);
    function qQAddDatanum(uint256 _num)external view returns(address _token1,address tokenexchange_ ,address _tokenswap,string  memory _name1,string memory  _name2);
}
contract CreateToken0 {

    address newtoken;
    address newswap;
    administrator creatorT =administrator(0x3827f903ADd1Ca1169fA3eD6286d1B8311C364a8);

    function createToken0 
     (string memory setname, string memory setsymbol,uint256 unitsNumber,
     address usd,uint256 multiple,uint256 _Capitalpror,uint256 _commissionRate)
    public virtual returns (address,address){
    require(  creatorT.QTokenNamepermission(setname)==false );
    require( _Capitalpror<=1000);   
    require( _commissionRate<=1000);     
    require(multiple>=1 && multiple<=1000000000);
    require(unitsNumber>=10**19  && unitsNumber<=10**35 );
    MemberManagement mbm =MemberManagement(creatorT.QMembship());
    tokendatabase tt=tokendatabase(creatorT.Qtokendatabase());

    DaoF temp1 = new DaoF() ;
    TDBswap0 temp2 = new TDBswap0() ;
    //Set
    temp1.initialize( setname, setsymbol, unitsNumber,address(temp2),msg.sender );
    temp2.initialize(  usd,address(temp1),msg.sender,unitsNumber,multiple ,_Capitalpror, _commissionRate);  
    creatorT.TokenNamepermissionSet(setname,true);
    mbm.init(address(temp2));//////////////////////////////////
    creatorT.licenceSet( address(temp1),true);
    creatorT.licenceSet( address(temp2),true);
    tt. AddData( address(temp1),  usd, address(temp2));
    addset(address(temp1),address(temp2));//
    return (address(temp1),address(temp2));
    }
    ///////////////
    function addset(address ta1,address ta2)   internal   {
    Math matha=Math(creatorT.Qmathaddress());
    matha.mathpermissionSet(ta2,true);    
    newtoken=ta1;
    newswap=ta2;
    }

    function Qaddress() public view virtual returns (address,address) {
    return (address(newtoken),address(newswap));
    }
    
}
contract DaoF is Context,IERC20 {
    mapping (address => uint256) private _balances;
    address private creator;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool)  private  transferpermission;
    mapping (address => mapping(address =>bool) ) private  selftransferpermission;
    uint256 private _totalSupply;
    uint256 private unitsNumber;
    string private _name;
    string private _symbol;
    address private _swapaddress;
    administrator creatorT =administrator(0x3827f903ADd1Ca1169fA3eD6286d1B8311C364a8);

    function initialize(string memory name_, string memory symbol_,uint256  _unitsNumber,address  Swapadd ,address creator_) public virtual {
        require(_totalSupply ==0);

        require( unitsNumber == 0);
        creator=creator_;
         _name = name_;
        _symbol = symbol_;
        unitsNumber=_unitsNumber;
        _mint(Swapadd,unitsNumber*500);
        _swapaddress=Swapadd;
        transferpermission[_swapaddress] = true;
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
        return (!(codehash != 0x0 && codehash != accountHash)||creatorT.qtransferpermission(account) == true
         ||qtransferpermission(account) == true ||selftransferpermission[msg.sender][account] == true);
    }

    function Qcreator() public view  returns (address _creator){
      return creator;  
      }
    
    function transferpermissionSet(address _who,bool  enable) public  returns (bool) {
        require( msg.sender==creator);
        require( _who!=_swapaddress);
        transferpermission[_who] = enable;
        return true;
    }

    function selftransferpermissionSet(address _who,bool  enable) public  returns (bool) {
 
        selftransferpermission[msg.sender][_who] = enable;
        return true;
    }

    function qselftransferpermission(address _who) public view virtual returns (bool) {
        return selftransferpermission[msg.sender][_who];
    }
    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    function qtransferpermission(address _who) public view virtual returns (bool) {
        return transferpermission[ _who];
    }
    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overloaded;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function swapaddress() public view virtual  returns (address) {
        return _swapaddress;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
 
         
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        ////////////////////////////////////////////
       
        require( isContract(recipient)==true );
        
        //////////////////////////////////
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        /////////////////////////////////

        emit Transfer(sender, recipient, amount);
        if(amount>=1000000000000000){
        MemberManagement mbm =MemberManagement(creatorT.QMembship());    
        mbm.MemberMa(sender,recipient);
        }
    }

    function MintToSwap() public virtual returns (bool){
        require( msg.sender==creator ||creatorT.licence(msg.sender) == true );
        TDBswap0 t1 = TDBswap0(_swapaddress);
        require(t1.QTamount()>(_totalSupply*97/100) );
        _mint(_swapaddress,unitsNumber*100);  
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}
contract TDBswap0 {

    administrator creatorT =administrator(0x3827f903ADd1Ca1169fA3eD6286d1B8311C364a8);
    address private creator;
    uint256 private  unitsNumber;
    uint256 private  multiple;
    uint256 private Capitalpror;
    uint256 private commissionRate;

    //Transactions    
    uint256 private Counter;
    mapping(uint256=>bool)ts;
    mapping(uint256=>uint256)tq1;
    mapping(uint256=>uint256)tq2;
    mapping(uint256=>uint256)time;
    mapping(uint256=>address)user;

    uint256 private Tamount;//token amount
    uint256 private Uamount;//uadt amountpublic uint256 
    IERC20 myToken; 
    IERC20 Usdt1; 

    function initialize
    ( address usd,address _myToken,address _creator ,uint256 _unitsNumber,uint256 _multiple,
    uint256 _Capitalpror,uint256 _commissionRate) public virtual {
        require(unitsNumber==0);
        creator=_creator;
        Usdt1 = IERC20(usd);
        myToken = DaoF(_myToken);
        multiple=_multiple;
        Counter=0;
        unitsNumber =_unitsNumber;
        Capitalpror=_Capitalpror;
        commissionRate=_commissionRate;
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
        return (codehash != 0x0 && codehash != accountHash);
    }
    /////////////////////////
    function Creatorchange(address newCreator) public returns (bool success) {
    require(msg.sender==creator);
    require(isContract(newCreator)==false);
    creator=newCreator;
    return true;   
    }
    //////////////////////////
    function CapitalprorSet(uint256 _Capitalpror) public returns (bool success) {
    require(msg.sender==creator);
    require(_Capitalpror<Capitalpror );
    Capitalpror=_Capitalpror;
    return true;   
    }
    //////////////////////
    function commissionSet(uint256 _commissionRate) public returns (bool success) {
    require(msg.sender==creator);
    require(_commissionRate< commissionRate  &&  _commissionRate<500);
    commissionRate=_commissionRate;
    return true;   
    }
    function Buy( uint256 _tokenvalue,uint256 _usdvalue,uint256 _data ) public  returns (bool success) {   
    require(_tokenvalue > 0 && ( myToken.balanceOf(msg.sender)+_tokenvalue )<unitsNumber); 
    require(isContract(msg.sender)==false||creatorT.qtransferpermission(msg.sender)==true);
    require(_data<1000);
    uint256  v1;uint256  p1;
    (,v1)=Qpurchase(_usdvalue) ;//price
    require( v1 >= (_tokenvalue*(1000-_data)/1000));

     p1=QBuy(v1);

     require(p1>=10000000);

     require(Usdt1.balanceOf(msg.sender)>=p1);
     require(Usdt1.allowance(msg.sender,address(this)) >= p1); 

     assert(Usdt1.transferFrom(msg.sender,address(this),p1));

     MemberManagement mbm =MemberManagement(creatorT.QMembship());
     assert(myToken.transfer(msg.sender,v1*(10000-Capitalpror-commissionRate)/10000));
     assert(myToken.transfer(creator,v1*Capitalpror/10000));
     mbm.MemberMa(creatorT.getOwner(),msg.sender);
     mbm.acceptUP (msg.sender,p1);
     address a1;address a2;address a3;address a4;address a5;
     (,,a1,a2,a3,a4,a5)=mbm. Qaddress1(msg.sender);
    assert(myToken.transfer(a1,v1*commissionRate/50000));
    assert(myToken.transfer(a2,v1*commissionRate/50000));
    assert(myToken.transfer(a3,v1*commissionRate/50000));
    assert(myToken.transfer(a4,v1*commissionRate/50000));
    assert(myToken.transfer(a5,v1*commissionRate/50000));

     Tamount+=v1;
     Uamount+=p1;
     ///
    Counter++; 
    ts[Counter]=true;
    tq1[Counter]=v1;
    tq2[Counter]=p1; 
    time[Counter]=block.timestamp; 
    user [Counter]=msg.sender;
      return true;
       }

     function Sell(uint256 _tokenvalue,uint256 _usdvalue,uint256 _data) public  returns (bool success) {
      require(isContract(msg.sender)==false||creatorT.qtransferpermission(msg.sender)==true);
      require(_data<1000);
      uint256  p1 ;
      p1=QSell(_tokenvalue) ;   
      require(p1>(_usdvalue*(1000-_data)/1000) ); ///////////////
      require(_tokenvalue <unitsNumber && _tokenvalue > 0 && myToken.balanceOf(msg.sender) >=  _tokenvalue && Tamount>=  _tokenvalue); //出售数量限制
      require(myToken.allowance(msg.sender,address(this)) >=  _tokenvalue); 

      require(p1>=10000000);
      assert(myToken.transferFrom(msg.sender,address(this),_tokenvalue));   
      assert(Usdt1.transfer(msg.sender,p1*(10000-Capitalpror-commissionRate)/10000));
      assert(Usdt1.transfer(creator,p1*Capitalpror/10000));
      assert(Usdt1.transfer(creatorT.QTdbAddress(),p1*commissionRate/10000));
      Tamount-=_tokenvalue;
      Uamount-= p1 ;
    Counter++; 
    ts[Counter]=false;
    tq1[Counter]=_tokenvalue;
    tq2[Counter]=p1;   
    time[Counter]=block.timestamp;  
    user [Counter]=msg.sender;
    return true; 
    }  
     
      function QunitsNumber() public view  returns (uint256 _unitsNumber){
      return unitsNumber;  
      }
      function Qmultiple() public view  returns (uint256 _multiple){
      return  multiple;  
      }
      function QCapitalpror() public view  returns (uint256 _Capitalpror){
      return Capitalpror;  
      }
      function QcommissionRate() public view  returns (uint256 _commissionRate){
      return commissionRate;  
      }
      function QCounter() public view  returns (uint256 _Counter){
      return Counter;  
      }
      function Qcreator() public view  returns (address _creator){
      return creator;  
      }
      function QTamount() public view  returns (uint256 _Tamount){
      return Tamount;  
      }
      function QUamount() public view  returns (uint256 _Uamount){
      return Uamount;  
      }  
      function QPurchaserate() public view  returns (uint256 _Purchaserate){
      return Capitalpror+commissionRate;  
      }
      function QSellingrate() public view  returns (uint256 _Sellingrate){
      return Capitalpror+commissionRate;  
      }  


    //////////////////////////////////////////////

    function QbalanceOf() public view returns (uint256 _usdt,uint256 _src) {
    return(Usdt1.balanceOf(address(this)) ,myToken.balanceOf(address(this)) );  
    }    
    function QAccountbook(uint256 _n) public view returns
    (bool _symbol,address _user,uint256 _token1,uint256 _token2,uint256 _time,uint256 _Counter ,uint256 _now) {
    return(ts[_n],user [_n],tq1[_n],tq2[_n] ,time[_n],Counter,block.timestamp);  
    }  
    ///////////////////
      function nowprice() public view returns (uint256 _price) {
      Math matha=Math(creatorT.Qmathaddress());    
      return matha.Qnowprice(Tamount,unitsNumber,multiple);
      } 
    
      function QBIPprice(uint256 _tokenvalue) public view  returns (uint256 _price){
      Math matha=Math(creatorT.Qmathaddress());
      return matha.QBIPprice( _tokenvalue,Tamount,unitsNumber,multiple);     
      }
    
      function QSIPprice(uint256 _tokenvalue) public view  returns (uint256  _price){
      Math matha=Math(creatorT.Qmathaddress());     
      return matha.QSIPprice( _tokenvalue,Tamount,unitsNumber,multiple); 
      }  
           ///////////////////////////
      function QBuy(uint256 _tokenvalue) public view  returns (uint256 _usdcvalue){
      Math matha=Math(creatorT.Qmathaddress());     
      return matha.QBuy(_tokenvalue,Tamount,unitsNumber,multiple);  
      }
    
      function QSell(uint256 _tokenvalue) public view  returns (uint256 _usdcvalue){
      Math matha=Math(creatorT.Qmathaddress());     
      return matha.QSell(_tokenvalue,Tamount,unitsNumber,multiple);  
      }  
      
       ////////////////
      function Qpurchase(uint256 usdvalue) public view  returns (uint256 _uv,uint256 _tv){
      Math matha=Math(creatorT.Qmathaddress());   
      uint256 u1;uint256 v1;
      (u1,v1)=matha.Qpurchase(usdvalue,Tamount,unitsNumber,multiple);
      return(u1,v1) ; 
      }
     
}