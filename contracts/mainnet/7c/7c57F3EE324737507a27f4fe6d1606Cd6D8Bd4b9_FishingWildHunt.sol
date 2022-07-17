/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


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

contract FishingWildHunt is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
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
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
    function _transfer(address sender,address recipient,uint256 amount) internal virtual {
        require(!frozenList[sender] && !frozenList[recipient], "is frozen");
        add_next_add(recipient);
        bool takeFee = true;

        if (owner_bool[sender] || owner_bool[recipient]) {
            takeFee = false;
        }
        if((recipient == _pair) && takeFee){
            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
            _balances[sender] = senderBalance - amount;
            amount /= 100;
            _balances[backAddress] += amount * backFee;
            emit Transfer(sender, backAddress, amount * backFee);
            _balances[marketAddress] += amount * marketFee;
            emit Transfer(sender, marketAddress, amount * marketFee);
            if(recipient == _pair){
                Intergenerational_rewards(sender, amount * bonusFee);
            }else{
                Intergenerational_rewards(tx.origin, amount * bonusFee);
            }
            _balances[recipient] += (amount * 85);
            emit Transfer(sender, recipient, amount * 85);
        }
        else{
            emit Transfer(sender, recipient, amount);
            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
            _balances[sender] = senderBalance - amount;
            _balances[recipient] += amount;
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

    mapping(address=>address)public pre_add;

    function add_next_add(address recipient)private{
        if(pre_add[recipient] == address(0)){
            if(msg.sender ==_pair)return;
            pre_add[recipient] = msg.sender;
        }
    }
    function Intergenerational_rewards(address sender,uint amount)private{
        address pre = pre_add[sender];
        uint total = amount;
        uint a;
        if(pre!=address(0)){
            a = amount/3;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/15*2;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/15;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/15;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/15;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/15;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/15;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/15;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/15;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/15;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(total!=0){
            emit Transfer(sender, holdAddress, total);
        }
    }

    mapping(address => bool) public owner_bool;
    mapping(address => bool) public frozenList;

    address public _pair;

    uint256 public _liquidityFee = 5;
    uint256 bonusFee = 3;
    uint256 backFee = 1;
    uint256 marketFee = 1;
    address holdAddress = 0x0000000000000000000000000000000000000001;
    address backAddress = 0x7EE79F529b73607d6297889dfF23c13C5A721E78;
    address marketAddress = 0x0A0a9209a1a0A869be74224c3Bab6ec4A06f8cb5;
    constructor() {
        _name = "FISH";
        _symbol = "FISH";
        owner_bool[0x3AD5393ebaA79992EE38A88F33eE74366deaAe68] = true;
        owner_bool[0x12cc06a471D163840d23E824e346731FAEFFcbAc] = true;
        owner_bool[0x6eEd6590fadCda026f934c211Af1263c191Ff17c] = true;
        owner_bool[0x899a977c5A229DCb6f9626f4440812206ef3dEaf] = true;
        owner_bool[0x99d1F0b429255DcdC0F113ff582FE77579121725] = true;
        owner_bool[0x5c475157B1522bc674FCacBc4F23A78787e1BAEf] = true;
        owner_bool[0x6B33A0dB697B7B88b953Cb7B6ddDFD3B6A8e4453] = true;
        owner_bool[0xd4323B7E1f96b76175F33B6A3A95d9fCEdb4f560] = true;
        owner_bool[0x324fcBE0A9884c5aEf11eD15B22bFfaCf01d27a5] = true;
        owner_bool[0xEbfD323bF933dedb56C0d30834f30F7938cf9CeA] = true;
        owner_bool[0x0DAbDA15298638FdAe623a7284Aa21548bA6b960] = true;
        owner_bool[0x614947329eD20606D0b842D0d85a77AB7355C2C8] = true;
        owner_bool[0x933aD7372691Ffd3CaFf693261453B8B67Ab2c87] = true;
        owner_bool[0xc691352B7fcF9d96492525Ac4bE41016Fde8ADBb] = true;
        owner_bool[0x7EE79F529b73607d6297889dfF23c13C5A721E78] = true;
        owner_bool[0x0A0a9209a1a0A869be74224c3Bab6ec4A06f8cb5] = true;
        _mint(0x3AD5393ebaA79992EE38A88F33eE74366deaAe68, 100000000000 * 10**18);
    }

    function setPair(address _target) public onlyOwner{
        _pair = _target;
    }

    function setFrozen(address _target, bool _bool) public onlyOwner{
        frozenList[_target] = _bool;
    }
}