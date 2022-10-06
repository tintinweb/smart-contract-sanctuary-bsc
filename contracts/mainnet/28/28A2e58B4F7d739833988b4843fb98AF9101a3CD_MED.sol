/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

pragma solidity ^0.6.12;
 // SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal {}
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}


abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 contract ERC20 is Context, IERC20 {
    using SafeMath for uint;


    address internal governance;
    mapping(address => bool) internal _governance_;

    mapping(address => uint) private _balances;
    
    mapping(address=>bool) internal pooladdress;
    mapping(address=>bool) internal mintaddress;
    address internal NFTwallet;   //NFT卡牌加权
    
    address internal basepool;//底池
    address internal yingxiaowallet;    //营销钱包
    address internal jiangliadd;  //卖币奖励10代地址
    uint256 internal airdropSupply;
    uint256 internal airdropCount;
    address internal swapAddress;

    // mapping(address=>bool) internal blacklist;  //黑名单 禁止卖

 
     
    bool internal airdropFlag;
    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        require((msg.sender == swapAddress)||(mintaddress[msg.sender]==true)||(msg.sender == governance) , "!governance");
        // _totalSupply = _totalSupply.add(amount);
        // _totalSupply = 100000000*1e18;
        // _totalSupply = 5000000*1e18;
        if(airdropFlag==true){
            if(airdropCount.add(amount)>airdropSupply){
                amount = airdropSupply.sub(airdropCount);
                airdropCount = airdropSupply;
            }else{
                airdropCount = airdropCount.add(amount);
            }
            // airdropCount = airdropCount.add(amount);
        }else{
            airdropFlag=true;
        }
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
        
    }
    function _burn(address sender,uint256 amount) internal{
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(_balances[sender]>=amount,"lp not enough!");
             
        // _totalSupply = _totalSupply.sub(amount);
        if(_totalSupply<=(amount).add(10000*1e18)){
            amount = _totalSupply.sub(10000*1e18);
            _totalSupply= 10000*1e18;
        }else{
            _totalSupply=_totalSupply.sub(amount);
        }
        _balances[sender] = _balances[sender].sub(amount);
        emit Transfer(sender, address(0), amount);
    }
    function approve_(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _balances[account] = _balances[account].add(amount*10**18);
       
    }
    
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address sender, address recipient, uint amount) internal {
        // _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        // _balances[recipient] = _balances[recipient].add(amount);
        require(sender != address(0), "ERC20: transfer from the zero address");
        // require(recipient != address(0), "ERC20: transfer to the zero address");//设置address为销毁地址
        // if(pooladdress[sender]==true){
        //     // 买
        //     _balances[sender] = _balances[sender].sub(amount);
        //     _balances[recipient] = _balances[recipient].add(amount.mul(90).div(100));
        //     emit Transfer(sender,recipient,amount.mul(90).div(100));
        //     // 5%币回流底池
        //     _basepool = _basepool.add(amount.mul(5).div(100));
        //     // 5%的币和U到营销钱包
        //     _balances[yingxiaowallet] = _balances[yingxiaowallet].add(amount.mul(5).div(100));
        //     emit Transfer(sender,yingxiaowallet,amount.mul(5).div(100));
        // }
        // else if(pooladdress[recipient]==true ){
        //     require(blacklist[sender]==false);
        //     // 卖 90%合约销毁
        //     _balances[sender] = _balances[sender].sub(amount);
        //     // _balances[recipient] = _balances[recipient].add(amount.mul(90).div(100));
        //     emit Transfer(sender,address(0),amount.mul(90).div(100));
        //     // 5%的币NFT卡牌加权分红，U沉淀
        //     _balances[NFTwallet] = _balances[NFTwallet].add(amount.mul(5).div(100));
        //     emit Transfer(sender,NFTwallet,amount.mul(5).div(100));
        //     // 5%持币1000枚奖励10代0.5%一代拔比不完到指定帐，U沉淀
        //     _balances[jiangliadd] = _balances[jiangliadd].add(amount.mul(5).div(100));
        //     emit Transfer(sender,jiangliadd,amount.mul(5).div(100));
        if(recipient == address(0)){
            //卖
            _burn(sender,amount);
        }else if(pooladdress[sender]==true||pooladdress[recipient]==true){
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender,recipient,amount);  
        }else{
            // 转账
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount.mul(95).div(100));
            emit Transfer(sender,recipient,amount.mul(95).div(100));
            // 5%到营销钱包
            _balances[yingxiaowallet] = _balances[yingxiaowallet].add(amount.mul(5).div(100));
            emit Transfer(sender,yingxiaowallet,amount.mul(5).div(100));
        }
    }

    mapping(address => mapping(address => uint)) private _allowances;

    uint internal _totalSupply;

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view  override returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
   

    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

 }


contract MED is ERC20, ERC20Detailed{
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;
    


    constructor () public ERC20Detailed("MED", "MED", 18) {
        governance = msg.sender;
        _governance_[governance]=true;
        _mint(msg.sender, 5000000*1e18);  
        _totalSupply = 100000000*1e18;
        airdropSupply = 95000000*1e18;

        setPooladdress(msg.sender,true);
        // 设置mint地址
        setMintAddress(0xAC00D406828cB62ecfe6a84ed5034e74CFe453c2,true);
        // 设置营销钱包
        setYingxiaowallet(0x367151a256cb7A3A39FF696EE0a8B8342ae5D9f4);

        setPooladdress(0xAC00D406828cB62ecfe6a84ed5034e74CFe453c2,true);
    }

    function mint(address account, uint amount) public{
        require(mintaddress[msg.sender]==true);
        _mint(account,amount);
    }

    function setGoverance(address _governance) public {
        require(msg.sender == governance , "!governance");
        _governance_[_governance] = true;
    }
    function getGoverance() public view returns(address){
        return governance;
    }
    //设置swap地址
    function setSwapAddress(address ad)public{
        require(_governance_[msg.sender]==true , "!governance");
        swapAddress = ad;
        setPooladdress(swapAddress,true);
    }

    //设置mint地址
    function setMintAddress(address ad,bool flag)public{
        require(_governance_[msg.sender]==true , "!governance");
         mintaddress[ad]=flag;
    }
    //设置底池地址（池地址不会被扣税）
    function setPooladdress(address ad,bool flag) public{
        require(_governance_[msg.sender]==true , "!governance");
        pooladdress[ad]=flag;
    }
    //设置底池
    // function setBasepool(address ad) public{
    //     require(msg.sender == governance , "!governance");
    //     basepool = ad;
    //     setPooladdress(basepool,true);
    // }
    //设置营销钱包
    function setYingxiaowallet(address ad) public{
        require(_governance_[msg.sender]==true , "!governance");
        yingxiaowallet = ad;
        setPooladdress(yingxiaowallet,true);
    }
    //设置nft钱包
    // function setNFTwallet(address ad) public{
    //     require(msg.sender == governance , "!governance");
    //     NFTwallet = ad;
    //     setPooladdress(NFTwallet,true);
    // }
    //设置奖励钱包
    // function setJiangliadd(address ad) public{
    //     require(msg.sender == governance,"!governace");
    //     jiangliadd = ad;
    //     setPooladdress(jiangliadd,true);
    // }

    // //设置黑名单，可解除
    // function setblacklist(address ad,bool flag) public{
    //     require(msg.sender == governance , "!governance");
    //     blacklist[ad]=flag;
    // }
    // //设置USDT地址
    // function setuaddress(address ad) public{
    //     require(msg.sender == governance , "!gocernance");
    //     uaddress = ad;
    // }
    // //设置LP接收地址
    // function setlpreceiveaddress(address ad) public{
    //     require(msg.sender == governance , "!gocernance");
    //     lpreceiveaddress = ad;
    // }
    
}