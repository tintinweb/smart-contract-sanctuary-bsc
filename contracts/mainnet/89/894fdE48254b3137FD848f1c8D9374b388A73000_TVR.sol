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
    uint private price = 264218204802;        
    uint[] private acceleratelist = [1000,900,800,700,600,500,400,300,200,100]; 
    uint[] private depositlist = [5*1e17, 2*1e18];  
    uint[] private recommendlist = [5,3,2,1,1,1,1,1,1,1];  
      
    struct dividendData{
        address superior;     
        uint total;          
        uint already;      
        uint whatScore;     
        uint numDay;          
        uint depositNumber;     
        uint recommendNumber;  
        address me;
        uint timer;
    }
    mapping(uint => dividendData) private data;   
    mapping(address => uint) private dataList;
    uint private datanum;
                   
    uint constant zreo = 0;
    uint constant one = 1;

    uint private alltvr = 300000000*1e18;       
    uint private allbnb = 79265461440700000000;            
    
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
        return data[ dataList[account] ];
    }
    function get_data_superior(address account)  external view returns(address){   
        require(account != address(0), "address err");
        return data[ dataList[account] ].superior;
    }
    function get_data_total(address account)  external view returns(uint){   
        require(account != address(0), "address err");
        return data[ dataList[account] ].total;
    }
    function get_data_already(address account)  external view returns(uint){   
        require(account != address(0), "address err");
        return data[ dataList[account] ].already;
    }
    function get_data_whatScore(address account)  external view returns(uint){   
        require(account != address(0), "address err");
        return data[ dataList[account] ].whatScore;
    }
    function get_data_numDay(address account)  external view returns(uint){   
        require(account != address(0), "address err");
        return data[ dataList[account] ].numDay;
    }
    function get_data_depositNumber(address account)  external view returns(uint){   
        require(account != address(0), "address err");
        return data[ dataList[account] ].depositNumber;
    }
    function get_data_recommendNumber(address account)  external view returns(uint){   
        require(account != address(0), "address err");
        return data[ dataList[account] ].recommendNumber;
    }

   function get_data_superior2(uint len)  external view returns(address){   
        require(len <= datanum, "address err");
        return data[ len ].superior;
    }
    function get_data_total2(uint len)  external view returns(uint){   
        require(len <= datanum, "address err");
        return data[ len ].total;
    }
    function get_data_already2(uint len)  external view returns(uint){   
        require(len <= datanum, "address err");
        return data[ len ].already;
    }
    function get_data_whatScore2(uint len)  external view returns(uint){   
        require(len <= datanum, "address err");
        return data[ len ].whatScore;
    }
    function get_data_numDay2(uint len)  external view returns(uint){   
        require(len <= datanum, "address err");
        return data[ len ].numDay;
    }
    function get_data_depositNumber2(uint len)  external view returns(uint){   
        require(len <= datanum, "address err");
        return data[ len ].depositNumber;
    }
    function get_data_recommendNumber2(uint len)  external view returns(uint){   
        require(len <= datanum, "address err");
        return data[ len ].recommendNumber;
    }
    function get_data_me2(uint len)  external view returns(address){   
        require(len <= datanum, "address err");
        return data[ len ].me;
    }
    function get_data_timer(uint len)  external view returns(uint){        
        require(len <= datanum, "address err");
        return data[ len ].timer;
    }
    function get_dataList(address acc)  external view returns(uint){  
        return dataList[acc];
    }

    function get_datalength()  external view returns(uint){  
       return datanum;
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
    function set_data_up(
        address acc,
        uint um,
        address superior,   
        uint total,          
        uint already,     
        uint whatScore,   
        uint numDay,         
        uint depositNumber,    
        uint recommendNumber, 
        address _me,
        uint timer) public isdeployer {   

        dataList[acc] = um;

        data[um].superior = superior;
        data[um].total = total;
        data[um].already = already;
        data[um].whatScore = whatScore;
        data[um].numDay = numDay;
        data[um].depositNumber = depositNumber;
        data[um].recommendNumber = recommendNumber;
        data[um].me = _me;
        data[um].timer =timer;

        datanum =um;
    }

    function set_alltvr(uint alltvr_)  public isdeployer {      
        alltvr = alltvr_;
    }
    function set_allbnb(uint allbnb_)  public isdeployer {      
        allbnb = allbnb_;
    }
    function set_price_u(uint pri)  public isdeployer {      
        price = pri;
    }

    function set_recdep()  public isdeployer { 
        for(uint i = 1; i <= datanum; i++){
            uint _sup_recommendNumber =data[ i ].recommendNumber;  
            uint _sup_depositNumber =data[ i ].depositNumber;   
            if(_sup_depositNumber ==0){
                _sup_depositNumber =1;
            }
            uint _sup_total =data[ i ].total;   
            uint rec_dep;  
            uint rec_dep_num;

            rec_dep =_sup_recommendNumber / _sup_depositNumber;  
            if(rec_dep >= acceleratelist.length){
                rec_dep = acceleratelist.length - 1;
            }
            rec_dep_num =acceleratelist[rec_dep];  

            if(rec_dep_num != data[ i ].numDay){
                data[ i ].numDay =rec_dep_num;  
                data[ i ].whatScore =_sup_total / rec_dep_num; 
                data[ i ].already =zreo;  
                data[ i ].timer = block.timestamp;
            }  
        }
    }

    function set_price()  external issder {      
        price = allbnb *1e18 / alltvr; 
    }
    
    function set_data_total(address account,uint num)  external issder{     
        require(account != address(0), "address err");
        data[ dataList[account] ].total = num;
    }
    function set_data_already(address account,uint num)  external issder{   
        require(account != address(0), "address err");
         data[ dataList[account] ].already = num;
    }
    function set_data_whatScore(address account,uint num)  external issder{   
        require(account != address(0), "address err");
         data[ dataList[account] ].whatScore = num;
    }
    function set_data_timer(address account,uint num)  external issder{   
        require(account != address(0), "address err");
         data[ dataList[account] ].timer = num;
    }
    function set_data_timer2(uint n,uint num)  external issder{   
        data[ n ].timer = num;
    }

    function set_ext_deposit(address acc, uint bnnb) external issder{            
        require( bnnb >= depositlist[0]  && bnnb <= depositlist[1],"bnb err");
        require(acc != address(0), "address err");

        if(dataList[acc] == 0){
            datanum++;
            dataList[acc] = datanum;
        }

        if(data[ dataList[acc] ].me == address(0)){
                data[ dataList[acc] ].me = acc;
        }
 
        address us = data[  dataList[acc]  ].superior;
        uint num;
        if(us == address(0)){
            num = bnnb *1e18 / price * 90 / 100 ;
        }else{
            num = bnnb *1e18 / price ;
        }
        
        showtvr += num*117/100;

        uint all_total = data[ dataList[acc] ].total + num;
        data[ dataList[acc] ].total = all_total;          
        data[ dataList[acc] ].already = zreo;                 
        uint all_depositNumber = data[ dataList[acc] ].depositNumber + one;
        data[ dataList[acc] ].depositNumber = all_depositNumber;   

        if(all_depositNumber==0){
            all_depositNumber=1;
        }
        
        uint recNumb = data[ dataList[acc] ].recommendNumber / all_depositNumber;    
        
        if(recNumb >= acceleratelist.length){
            recNumb = acceleratelist.length - 1;
        }
        uint all_numDay = acceleratelist[recNumb];                    

        if(recNumb > zreo){
            data[ dataList[acc] ].numDay =  all_numDay;        
            data[ dataList[acc] ].whatScore = all_total / all_numDay;     
        }else{
            data[ dataList[acc] ].numDay =  acceleratelist[zreo];   
            data[ dataList[acc] ].whatScore = all_total / acceleratelist[zreo];     
        }
        data[ dataList[acc] ].timer = block.timestamp;
        
        address _superior = data[ dataList[acc] ].superior;    
        uint _sup_recommendNumber =data[ dataList[_superior] ].recommendNumber + one;  
        uint _sup_depositNumber =data[ dataList[_superior] ].depositNumber;   
        if(_sup_depositNumber ==0){
            _sup_depositNumber =1;
        }
        uint _sup_total =data[ dataList[_superior] ].total;   
        uint rec_dep;  
        uint rec_dep_num;

        if(_superior != address(0)){
            data[ dataList[_superior] ].recommendNumber = _sup_recommendNumber;  

            rec_dep =_sup_recommendNumber / _sup_depositNumber;  
            if(rec_dep >= acceleratelist.length){
                rec_dep = acceleratelist.length - 1;  
            }
            rec_dep_num =acceleratelist[rec_dep];  

            if(rec_dep_num != data[ dataList[_superior] ].numDay){
                data[ dataList[_superior] ].numDay =rec_dep_num;  
                data[ dataList[_superior] ].whatScore =_sup_total / rec_dep_num; 
                data[ dataList[_superior] ].already =zreo;  
                data[ dataList[_superior] ].timer = block.timestamp;
            }
        }

        all_number += 1 ;   
        allbnb += bnnb;
    }

    function set_lockrecommend(address from, address to) private {    
        require(from != address(0), "from address = 0 ");
        require(to != address(0), "to address = 0 ");
        if(dataList[to] ==0){
            datanum++;
            dataList[to] = datanum;
        }
        address _superior = data[ dataList[to] ].superior;
        if(_superior == address(0)){
            data[ dataList[to] ].superior = from;

            if(data[ dataList[to] ].me == address(0)){
                data[ dataList[to] ].me = to;
            }
        } 
        if(dataList[from]  == 0){
            datanum++;
            dataList[from] = datanum;
            data[ dataList[from] ].me = from;
            data[ dataList[from] ].superior = _deployersder;
        }
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