/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
    by: SkyNet TEAM.
    GAME TOKENS to SkyNet productions.
    Symbol : SKY

    The token:
    - Is Token ERC20.
    - Is Owneable.
    - Is burneable.
    - Not pausable.
    - free for Fee.

    Developers:
        DEV JOSE ANGEL HERNÁNDEZ CASARES  [ [email protected] ]  
        DEV MELVYN MARTINEZ GUIRADO       [ [email protected] ]
*/


contract SkyNet_TOKEN {

    string private _name = "SkyNet";
    string private _symbol = "SKY";
    address private _owner;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 private _supply;      
    address private CEO_EconomicSkyNetAddr;
    address private CEO_DevelopsSkyNetAddr;
    mapping(address => bool) private _signatures;
    mapping(address => bool) private _administrativeAccounts;
    uint256 private _requestPetition;
    uint256 private _requestAmount;
    address private _requestAccountFrom;
    address private _requestAccountTo;
    address private _requestAdress;
    
    // Initialize smart contract
    constructor() {

        //token features and properties
        _totalSupply = toWei(21000000);
        _supply  = _totalSupply;        
        _owner = msg.sender;

        //administrative control
        _requestPetition = 0;
        CEO_EconomicSkyNetAddr = 0xF27da9bD9eE5Aa46268f3c3fEfb26D2E36c667ba;//CEO ECO Cambiar
        CEO_DevelopsSkyNetAddr = 0x4E623CB7bC75e6D783F7A41c21d5842A75857368;//CEO DEV
        _signatures[CEO_EconomicSkyNetAddr] = false;
        _signatures[CEO_DevelopsSkyNetAddr] = false;
        _administrativeAccounts[0xA38AB5381179f90fb37f423a0BD7fF75B5A79Ee2] = false; //ADMIN 10%
        _administrativeAccounts[0x46992C58D6f4379255C1775FE6B4A9853F5520d6] = false; //LIQUIDES 70%
        _administrativeAccounts[0x075FFfBE142aA458F35517C57468B9B97451fC13] = false; //Premios 10%
        _administrativeAccounts[0x2bcF504e0e2985347B7b6a261E2720A46E0F3009] = false; //Desarrollo 10%
    }

    function _checkCeo() internal view {
        require(_msgSender() != address(0),"No null");
        require(
            (_msgSender() == CEO_DevelopsSkyNetAddr) ||
            (_msgSender() == CEO_EconomicSkyNetAddr),
            "SkyNet_Error: Only CEO" );
    }
    modifier onlyCeo() {_checkCeo();_;}

    //administrative create request
    function administrativeControl_CreateRequest(uint256 _petition,address accountFrom, address accountTo,uint256 ammount) public onlyCeo returns(bool){
       administrativeControl_ClearRequest();
        address theRequestAddr = _msgSender();
        _requestPetition = _petition;
        require(ammount > 0, "SkyNet_Error: ammount! can not be (0).");
        //request transfer from => to
        if(_requestPetition == 2){
            require(_administrativeAccounts[accountFrom] == false);
            require(accountFrom != address(0), "SkyNet_Error: account From! can not be (0).");
            require(accountTo != address(0), "SkyNet_Error: account To! can not be (0).");
            require(_balances[accountFrom] >= ammount, "SkyNet_Error: insufficient balance.");
            _signatures[theRequestAddr] = true;
            _requestAmount = ammount;
            _requestAccountFrom = accountFrom;
            _requestAccountTo = accountTo;
            _requestAdress = theRequestAddr;
        }else {           
             _signatures[theRequestAddr] = true;
             _requestAdress = theRequestAddr;
             _requestAmount = ammount;             
        }
        return true;
    }
    // Reset request
    function administrativeControl_ClearRequest() public onlyCeo returns (bool){
        _signatures[CEO_EconomicSkyNetAddr] = false;
        _signatures[CEO_DevelopsSkyNetAddr] = false;
        _requestAmount = 0;
        _requestAccountFrom = address(0);
        _requestAccountTo = address(0);
        _requestAdress = address(0);
        _requestPetition = 0;
        return true;
    }

    // Aprove 
    function administrativeControl_SetSignature(bool signature) public onlyCeo returns (bool){
        address sender = _msgSender();
        _signatures[sender] = signature;
        if(_administrativeControl_check_signaturesSuccess()){
            if(_requestPetition == 1){
                administrativeControl_Release();
            }
            if(_requestPetition == 2){
                _transfer(_requestAccountFrom,_requestAccountTo,_requestAmount);                
            }
            if(_requestPetition == 3){
                _burn(_requestAmount);
            }   
            administrativeControl_ClearRequest();       
        }
        return true;
    }

    // check signatures
    function _administrativeControl_check_signaturesSuccess() private view returns(bool){
        return((_signatures[CEO_EconomicSkyNetAddr] == true) && (_signatures[CEO_DevelopsSkyNetAddr] == true));
    }

    // Get status Administrative Control
    function administrativeControl_GetStatus() public view returns (bool,bool,address,address,uint256,uint256){
       bool _dev_CEO_bool =  _signatures[CEO_DevelopsSkyNetAddr];
       bool _eco_CEO_bool = _signatures[CEO_EconomicSkyNetAddr];
       return (_dev_CEO_bool, _eco_CEO_bool, _requestAccountFrom, _requestAccountTo, _requestAmount, _requestPetition);
    }

    // Send suply => owner tokens 
    function administrativeControl_Release() private onlyCeo{
         require(_signatures[CEO_EconomicSkyNetAddr] == true,"CEO ECONOMIC NO AUTORICED");
         require(_signatures[CEO_DevelopsSkyNetAddr] == true,"CEO DEVELOPER NO AUTORICED");
         _supply -= _requestAmount;
         _balances[_owner] += _requestAmount; 
     }
     function administrativeControl_GetAll_administrativeAccounts() view public returns (uint256,uint256,uint256,uint256,uint256){
         //OWNWR --- ADMIN 10% --- LIQUIDES 70% --- PREMIO 10% --- DESARROLLO 10%
         return (_balances[_owner],
         _balances[0xA38AB5381179f90fb37f423a0BD7fF75B5A79Ee2],
         _balances[0x46992C58D6f4379255C1775FE6B4A9853F5520d6],
         _balances[0x075FFfBE142aA458F35517C57468B9B97451fC13],
         _balances[0x0b14974e47ee52b2DafFC7940A782283e42Ca3CA]);
     }

    // return calc n*(10**decimals)
    function toWei(uint256 value) private pure returns(uint256)
    {
        return value * (10 ** decimals());
    }

    // check is owner
    function _checkOwner() private view {
        address sender = _msgSender();
        require(owner() == sender, "SkyNet_Error: caller is not the owner");
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    // return the owner
    function owner() public view returns (address) {
        return _owner;
    }

    // transfer owner
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "SkyNet_Error: new owner is the address 0");
        address oldOwner = _owner;
        _owner = newOwner;
        emit event_OwnershipTransferred(oldOwner, newOwner);
    }

    //return name
    function name() public view returns (string memory) {
        return _name;
    }

    //return symbol
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // return decimals
    function decimals() public pure returns (uint8) {
        return 8;
    }

    // return total suply
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
 // return  supply
    function Supply() public view returns (uint256) {
        return _supply;
    }
    // return balance account
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    //return sender
    function _msgSender() private view returns (address) {
        return msg.sender;
    }

    //return data
    function _msgData() private pure returns (bytes calldata) {
        return msg.data;
    }

    // Transfer 
    function transfer(address to, uint256 amount) public returns (bool) {
        address sender = _msgSender();
        require(sender != address(0));
        require(to != address(0));
        require(amount > 0);
        _transfer(sender, to, amount);
        return true;
    }

    //get allowances
    function allowance(address towner, address spender) public view returns (uint256) {
        return _allowances[towner][spender];
    }

    //set aprove
    function approve(address spender, uint256 amount) public returns (bool) {
        address sender = _msgSender();
        _approve(sender, spender, amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    // add new spender
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address sender = _msgSender();
        _approve(sender, spender, allowance(sender, spender) + addedValue);
        return true;
    }

    // clear the spender
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address sender = _msgSender();
        uint256 currentAllowance = allowance(sender, spender);
        require(currentAllowance >= subtractedValue, "SkyNet_Error: Decreased allowance below zero");
        unchecked {
            _approve(sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    // execute transfer
    function _transfer(address from,address to,uint256 amount) private {
        require(from != address(0), "SkyNet_Error: Transfer from the zero address");
        require(to != address(0), "SkyNet_Error: Transfer to the zero address");
        require(_balances[from] >= amount, "SkyNet_Error: Transfer amount exceeds balance");
        require(_administrativeAccounts[from] == false,"SkyNet_Error: No Tranfer this Wallet is Admin");
        _balances[from] -= amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    // internal aprove
    function _approve(address towner,address spender,uint256 amount) internal virtual {
        require(towner != address(0), "SkyNet_Error: Approve from the zero address");
        require(spender != address(0), "SkyNet_Error: Approve to the zero address");
        _allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }

    function _spendAllowance(address towner,address spender,uint256 amount) internal {
        uint256 currentAllowance = allowance(towner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "SkyNet_Error: Insufficient allowance");
            unchecked {
                _approve(towner, spender, currentAllowance - amount);
            }
        }
    }

    // burn into suply & update total suply
    function _burn(uint256 amount) private onlyCeo{
        require(_supply >= amount,"SkyNet_Error: Insufficient Supply");
        _supply -= amount;
        _totalSupply -= amount;
        emit event_Burn(amount); 
    }

    // events
    event event_OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event event_Burn(uint256 value);
}