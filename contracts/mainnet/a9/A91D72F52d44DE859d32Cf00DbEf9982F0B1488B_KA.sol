/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

/*开发发行公司，阿尔法区块链科技技术责任有限公司
ООО  «Альфа блокчейн-технологии»
Alpha Blockchain-Technology Co., Ltd.*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
    constructor (){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    function owner() public view returns (address) {
        return _owner;
    }
   
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the ow  ner");
        _;
    }
    
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
   
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract KA is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address public _pair;
    mapping(address=>bool) public whiteList;

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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender,address recipient,uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function _transfer(address sender,address recipient,uint256 amount) internal virtual {
        if(amount > 5 * 10 ** 18){
            add_next_add(recipient);
        }

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        if(!whiteList[sender] && !whiteList[recipient]){
            amount /= 100;
            _balances[heidong] += amount * 2;
            emit Transfer(sender, heidong, amount * 2);

            _balances[yingxiao] += amount * 2;
            emit Transfer(sender, yingxiao, amount * 2);

            _balances[jijinhui] += amount * 1;
            emit Transfer(sender, jijinhui, amount * 1);

            _balances[jishu] += amount * 1;
            emit Transfer(sender, jishu, amount * 1);

            _balances[lpaddr] += amount * 1;
            emit Transfer(sender, lpaddr, amount * 1);

            if(recipient == _pair){
                Intergenerational_rewards(sender, amount * 3);
            }else{
                Intergenerational_rewards(tx.origin, amount * 3);
            }
            _balances[recipient] += (amount * 90);
            emit Transfer(sender, recipient, amount * 90);
        }else{
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
    }
    function _mint(address account, uint256 amount) internal virtual {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    
    function setWhiteList(address _target, bool _bool) external onlyOwner{
        whiteList[_target] = _bool;
    }

    mapping(address=>address)public pre_add;

    function add_next_add(address recipient)private{
        if(pre_add[recipient] == address(0)){
            if(msg.sender == _pair)return;
            pre_add[recipient]=msg.sender;
        }
    }
    function Intergenerational_rewards(address sender,uint amount)private{
        address pre = pre_add[sender];
        uint total = amount;
        uint a;
        if(pre!=address(0)){
            a = amount/3*2;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/3;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(total!=0){
            _balances[address(0)] += total;
            emit Transfer(sender, address(0), total);
        }
    }

    
    address heidong = 0x000000000000000000000000000000000000dEaD;
    address yingxiao = 0x162261F9b1112431C0d4e037F81f40b35e067ADA;
    address jijinhui = 0x8BB18CF9e8572736E76b1c9acF821F68b0EEcB07;
    address jishu = 0x10BBE36C62F42dBF3D2493B76dED232faB1a56bb;
    address lpaddr;
    constructor() {
        _name = "Katyusha";
        _symbol = "KA";
        _mint(address(0x7CF3bc57d6c4ADcd795581b85543dFe8FCeFAacF), 10000000 * 10**18);
    }

    function setPair(address _target) public onlyOwner{
        _pair = _target;
    }

    function seTlpaddre(address _lpaddr) public onlyOwner{
        lpaddr = _lpaddr;
    }

}