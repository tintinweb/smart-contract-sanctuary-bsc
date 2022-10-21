// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

contract TVR is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;    
    mapping(address => mapping(address => uint256)) private _allowances;  
    uint256 private _totalSupply;    
    string private _name;          
    string private _symbol;        

    address private _deployersder;  
    address private sder;          
    bool private onOff = true;       
    uint private price = 1*1e18;        
    uint[] private acceleratelist = [1000,900,800,700,600,500,400,300,200,100]; 
    uint[] private depositlist = [5*1e16, 2*1e17];  
    uint[] private recommendlist = [5,3,2,1,1,1,1,1,1,1];  
      
    struct dividendData{
       address superior;     
       uint total;          
       uint already;      
       uint whatScore;     
       uint numDay;          
       uint depositNumber;     
       uint recommendNumber;    
    }
    mapping(address => dividendData) private data;    
    address[] private dataList;                      

    uint constant zreo = 0;
    uint constant one = 1;

    uint private alltvr = 300000000*1e18;       
    uint private allbnb = 2*1e17;            
    
    uint private all_number;    
    uint public showtvr;

    modifier isdeployer(){       
        require( _deployersder == _msgSender() , "no msgSender");
        _;
    }
    modifier issder(){        
        require( sder == _msgSender() , "no sder");
        _;
    }

    function get_sder() external view returns(address){   
        return sder;
    }
    function get_onOff()  external view returns(bool) {  
        return onOff;
    }
    function get_price()  external view returns(uint) {   
        return price;
    }
    function get_acceleratelist() external view returns(uint[] memory){   
        return acceleratelist;
    }
    function get_depositlist()  external view returns(uint[] memory) {   
        return  depositlist;
    }

    function get_recommendlist()  external view returns(uint[] memory){   
        return recommendlist;
    }
    
    function get_data(address account)  external view returns(dividendData memory){   
        require(account != address(0), "address err");
        return data[account];
    }
    function get_data_superior(address account)  external view returns(address){   
        require(account != address(0), "address err");
        return data[account].superior;
    }
    function get_data_total(address account)  external view returns(uint){   
        require(account != address(0), "address err");
        return data[account].total;
    }
    function get_data_already(address account)  external view returns(uint){   
        require(account != address(0), "address err");
        return data[account].already;
    }
    function get_data_whatScore(address account)  external view returns(uint){   
        require(account != address(0), "address err");
        return data[account].whatScore;
    }
    function get_data_numDay(address account)  external view returns(uint){   
        require(account != address(0), "address err");
        return data[account].numDay;
    }
    function get_data_depositNumber(address account)  external view returns(uint){   
        require(account != address(0), "address err");
        return data[account].depositNumber;
    }
    function get_data_recommendNumber(address account)  external view returns(uint){   
        require(account != address(0), "address err");
        return data[account].recommendNumber;
    }
    
    function get_dataList()  external view returns(address[] memory){   
       return dataList;
    }
    function get_datalength()  external view returns(uint){  
       return dataList.length;
    }
     function get_all_number()  external view returns(uint){  
       return all_number;
    }
     function get_alltvr()  external view returns(uint){   
       return alltvr;
    }
     function get_allbnb()  external view returns(uint){   
       return allbnb;
    }

    function set_sder(address account) public isdeployer {   
        sder = account;
    }
    function set_onOff(bool bl) public isdeployer {  
        onOff = bl;
    }
   function set_acceleratelist(uint[] calldata ac) public isdeployer {   
        acceleratelist = ac;
    }
   function set_depositlist(uint[] calldata de) public isdeployer {   
        depositlist = de;
    }
    function set_recommendlist(uint[] calldata re) public isdeployer {   
        recommendlist = re;
    }

    function set_alltvr(uint alltvr_)  public isdeployer {      
        alltvr = alltvr_;
    }
    function set_allbnb(uint allbnb_)  public isdeployer {      
        allbnb = allbnb_;
    }

    function set_data_total(address account,uint num)  external issder{     
        require(account != address(0), "address err");
        data[account].total = num;
    }
    function set_data_already(address account,uint num)  external issder{   
        require(account != address(0), "address err");
         data[account].already = num;
    }
    function set_data_whatScore(address account,uint num)  external issder{   
        require(account != address(0), "address err");
         data[account].whatScore = num;
    }
  
    function calculatePrice () private {            
         price = allbnb / alltvr;
    }

    function set_ext_deposit(address acc, uint bnnb) external issder{    
        require( bnnb >= depositlist[0]  && bnnb <= depositlist[1], "bnb err");
        require(acc != address(0), "address err");

        allbnb += bnnb;      
        calculatePrice();    

        address us = data[acc].superior;
        uint num;
        if(us == address(0)){
            num = bnnb / price * 90 / 100;
        }else{
            num = bnnb / price;
        }
        
        showtvr += num*117/100;

        uint all_total = data[acc].total + num;
        data[acc].total = all_total;          
        data[acc].already = zreo;                 
        uint all_depositNumber = data[acc].depositNumber + one;
        data[acc].depositNumber = all_depositNumber;   

        if(all_depositNumber==0){
            all_depositNumber=1;
        }
        
        uint recNumb = data[acc].recommendNumber / all_depositNumber;    
        
        if(recNumb >= acceleratelist.length){
        recNumb = acceleratelist.length - 1;
        }
        uint all_numDay = acceleratelist[recNumb];                    

        if(recNumb > zreo){
            data[acc].numDay =  all_numDay;        
            data[acc].whatScore = all_total / all_numDay;     
        }else{
            data[acc].numDay =  acceleratelist[zreo];   
            data[acc].whatScore = all_total / acceleratelist[zreo];     
        }
        
        address _superior = data[acc].superior;     
        if(_superior != address(0)){
            data[_superior].recommendNumber = data[_superior].recommendNumber + one;   
        }

        all_number += 1 ;      

        for(uint i = 0; i < dataList.length; i++){                      
            if(acc == dataList[i] && dataList[i] != address(0)){
                 return;
            }
        }
        dataList.push(acc);
    }

    function set_lockrecommend(address from, address to) private {    
        require(from != address(0), "from address = 0 ");
        require(to != address(0), "to address = 0 ");
        address _superior = data[to].superior;
        require(_superior == address(0), "superior != 0 ");     
        data[to].superior = from;
    }

    constructor(address account, string memory name_, string memory symbol_, uint  totalSupply_) {   
        _deployersder = account;
        _name = name_;                     
        _symbol = symbol_;                 
        _totalSupply = totalSupply_;         
        _balances[account] = totalSupply_;   
        
        emit Transfer(address(0), account, totalSupply_);   
    }

    function name() public view virtual override returns (string memory) {      
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {   
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {           
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {      
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {    
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {    
        address owner = _msgSender();     
        _transfer(owner, to, amount);     

        if(onOff == true){
            set_lockrecommend(owner,to);  
        }
        return true;
    }

    function _transfer(    
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");   
        require(to != address(0), "ERC20: transfer to the zero address");     
        uint256 fromBalance = _balances[from];     
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");    
            _balances[from] = fromBalance - amount;   
            _balances[to] += amount;     
        
        emit Transfer(from, to, amount);  
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {    
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {    
        address owner = _msgSender();        
        _approve(owner, spender, amount);    
        return true;
    }

    function _approve(     
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");       
        require(spender != address(0), "ERC20: approve to the zero address");       
        require(balanceOf(owner) >= amount, "ERC20: balanceOf(owner) < amount");     
             _allowances[owner][spender] = amount;      
        emit Approval(owner, spender, amount);         
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {    
        address owner = _msgSender();          
        require(balanceOf(owner) >= allowance(owner, spender) + addedValue, "ERC20: balanceOf(owner) < allowance(owner, spender) + addedValue");   
            _approve(owner, spender, allowance(owner, spender) + addedValue);    
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {    
        address owner = _msgSender();         
        uint256 currentAllowance = allowance(owner, spender);       
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");   
        unchecked {     
            _approve(owner, spender, currentAllowance - subtractedValue);      
        }
        return true;
    }

    function _spendAllowance(   
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);     
        if (currentAllowance != type(uint256).max) {      
            require(currentAllowance >= amount, "ERC20: insufficient allowance");       
            unchecked {
                _approve(owner, spender, currentAllowance - amount);              
            }
        }
    }

    function transferFrom(                       
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();                
        _spendAllowance(from, spender, amount);       
        _transfer(from, to, amount);               
        return true;
    }

}