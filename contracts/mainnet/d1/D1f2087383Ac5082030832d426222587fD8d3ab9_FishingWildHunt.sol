/**
 *Submitted for verification at BscScan.com on 2022-07-14
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
        require(!frozenList[sender] || !frozenList[recipient], "is frozen");
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

    uint256 public _liquidityFee;
    uint256 bonusFee = 3;
    uint256 backFee = 1;
    uint256 marketFee = 1;
    address holdAddress = 0x0000000000000000000000000000000000000001;
    address backAddress = 0x27B0038a0BB3bA951f3f24b5cf3804a3f1BA24ED;
    address marketAddress = 0x12B04C735420B6C57430C49D00A74474D716bB1D;
    constructor() {
        _name = "FI";
        _symbol = "FI";
		owner_bool[0x37fCB3823f6f8Cc03BEE1C7804D6bEaDEe1034B7] = true;
        owner_bool[0xF508ECD0CB46Ffaa78eCD6c348dB9967890b13Fd] = true;
        owner_bool[0xa1C55f4f79997f981AC620b937B95b1545c98203] = true;
        owner_bool[0x31599Df6da143077e7429FfefD3d9baad0830760] = true;
        owner_bool[0x8434938cFb1941bda104E1e4a71586d98594e3FF] = true;
        owner_bool[0xe5916454470f5a03af0961ccAB295a4481D9f1F1] = true;
        owner_bool[0xe78C54df4A7C28074552D66d38118B52854b48A3] = true;
        owner_bool[0x9Ca68cC0998F03D8BE1831f831bA76883879B080] = true;
        owner_bool[0x05517bf128f1590c96ceA8a91f1e3E52D1946403] = true;
        owner_bool[0x848586Aa47c97e38d683b4018E310d0b90A3dE5d] = true;
        owner_bool[0x590fB662d995734BDe455f8a186AA6999407f586] = true;
        owner_bool[0x20F391f64F25b519F68F2b5C04EA4207a61093b6] = true;
        owner_bool[0x4cDA498C4afe1329D05dfaC527655422fAF58392] = true;
        owner_bool[0xF9668F88CCeA91D1DD0Ac3fC68E22B7eC0B4F307] = true;
        owner_bool[0x27B0038a0BB3bA951f3f24b5cf3804a3f1BA24ED] = true;
        owner_bool[0x12B04C735420B6C57430C49D00A74474D716bB1D] = true;
        _mint(msg.sender, 10000000000 * 10**18);
		_liquidityFee = bonusFee + backFee + marketFee;
    }

    function setPair(address _target) public onlyOwner{
        _pair = _target;
    }

    function setFrozen(address _target, bool _bool) external onlyOwner{
        frozenList[_target] = _bool;
    }
	
	//修改分红费率
    function setBonusFee(uint256 _target) public onlyOwner{
        bonusFee = _target;
        _liquidityFee = bonusFee + backFee + marketFee;
    }
	
	
}