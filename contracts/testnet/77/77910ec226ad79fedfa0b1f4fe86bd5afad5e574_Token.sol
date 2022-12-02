// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.6.12;
import "./ITRC20.sol";
import "./SafeMath.sol";
import "./Context.sol";
import "./Ownable.sol";

contract Token is Context, ITRC20, Ownable {
    using SafeMath for uint256; //使用安全类型
	
    mapping (address => uint256) private _rOwned; 
    mapping (address => uint256) private _tOwned;
	
	
    mapping (address => mapping (address => uint256)) private _allowances;
  
  //免手续费账户MAP
    mapping (address => bool) public _isExcludedFee;
	//不参与模式账户 MAP
    mapping (address => bool) public _isNotSwapPair;
	//限制交易MAP
    mapping (address => bool) public _isSwapLmt;
	//角色组
    mapping (address => bool) public _roler;
	//关系链，用mapping实现关系链记录，key-value（类型 key address,value address）  当前账户为key 上级为value
    mapping (address => address) public inviter;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000 * 10**6; //发行总量
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public  _tTaxFeeTotal; //手续费

    string private _name = "TigerHaiTao";  //币全称
    string private _symbol = "TGPHT";  //币简称
    uint8  private _decimals = 6;  //精度

    uint256 private _taxFee = 2; //交易手续费  _taxFee+_elseFee=14%
    uint256 private _previousTaxFee = _taxFee; //上一次设置的手续费，是个历史记录

    uint256 private _elseFee = 12;
    uint256 private _previousElseFee = _elseFee;

   //二级分销，第一代2%，二代1%
    uint8[] public inviteRate = [20, 10];
    //黑洞地址
    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
	//代币地址
    address public mainAddres = address(0x41b12B9c1F55E62E00124f23a5425c1a0e3C71f9);
	//营销地址
    address public marketAddress = address(0x41b12B9c1F55E62E00124f23a5425c1a0e3C71f9);
	//基金会地址
    address public fundAddress = address(0x41b12B9c1F55E62E00124f23a5425c1a0e3C71f9);
	//流动性地址 分红
    address public liquidAddress = address(0x41b12B9c1F55E62E00124f23a5425c1a0e3C71f9);



    constructor () public {
	    /**
		免手续费状态启用
		_isExcludedFee[mainAddres] = true;
		等于hm.put("mainAddres",true) -->(HashMap<String,Boolean> hm=new HashMap<>())
		*/
		_isExcludedFee[mainAddres] = true;
        _isExcludedFee[fundAddress] = true;
        _isExcludedFee[marketAddress] = true;

		//合约发布者
        _isExcludedFee[address(this)] = true;

        _rOwned[mainAddres] = _rTotal;
        emit Transfer(address(0), mainAddres, _tTotal);
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
    //获取发行总量
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

   // 获取用户的积分余额
    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
		// 内联汇编程序由 assembly { ... } 来标记
        assembly {
		//地址 account 的代码大小
		//获取地址关联代码长度。 合约地址长度大于0， 外部账户地址为0
            size := extcodesize(account)
        }
        return size > 0;
    }
    //Token划转
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee) {
            removeAllFee(); //清除手续费
        }
        _transferStandard(sender, recipient, amount, takeFee);
        if(!takeFee) {
            restoreAllFee();//还原上一次手续费
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rTaxFee, uint256 tTransferAmount, uint256 tTaxFee, uint256 tElseFee)
             = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        emit Transfer(sender, recipient, tTransferAmount);

     //如果没有手续费，不往下走
        if (!takeFee) {
            return;
        }

      //双重销毁
      //销毁主钱包的一部分，条件：黑洞持有数量要小于发行量90%
      
        if (balanceOf(burnAddress) < 90000000000 * 10 ** 18 
            && balanceOf(mainAddres) > tAmount) {
            _rOwned[mainAddres] = _rOwned[mainAddres].sub(rAmount);
			//递减
            _takeBurn(mainAddres, tAmount);
        }
        
        _takeInviterFee(sender, recipient, tAmount); // 3% 市场推广
        _takeLiquidity(sender, tElseFee * 2 / _elseFee); // 2% 回流
        _takeBurn(sender, tElseFee * 5 / _elseFee); // 5% 黑洞 销毁
        _takeMarket(sender, tElseFee / _elseFee);   // 1% 市场营销
        _takeFund(sender, tElseFee / _elseFee);     // 1% 基金会
        _reflectFee(rTaxFee, tTaxFee);        //通缩
    }
   //发放市场推广奖励
    function _takeInviterFee(
        address sender, address recipient, uint256 tAmount
    ) private {
        uint256 currentRate =  _getRate();

        address cur = sender;
		//判断 发送人是合约地址与参与交易模式   （isNotSwapPair[sender]默认为false,!isNotSwapPair=true）
        if (isContract(sender) && !_isNotSwapPair[sender]) {
            cur = recipient;//从接收人地址开始往上查找
        } 
        
		//inviteRate.length   inviteRate数组长度级分销，inviteRate.length=2 2级分销，inviteRate.length=10 10级分销
        for (uint8 i = 0; i < inviteRate.length; i++) {
            uint8 rate = inviteRate[i];//获取分销比例
            cur = inviter[cur];//获取上级
            if (cur == address(0)) { //如何上级为空
                cur = burnAddress; //黑洞
            }
			
            uint256 curTAmount = tAmount.mul(rate).div(1000);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[cur] = _rOwned[cur].add(curRAmount);
            emit Transfer(sender, cur, curTAmount);
        }
    }

/**
  https://blog.csdn.net/sanqima/article/details/121143680?utm_medium=distribute.pc_aggpage_search_result.none-task-blog-2~aggregatepage~first_rank_ecpm_v1~rank_v31_ecpm-1-121143680.pc_agg_new_rank&utm_term=increaseallowance&spm=1000.2123.3001.4430
  
    totalSupply()： token的总量
	balanceOf() ：某个地址上的余额
    transfer() ： 发送token
    allowance() ：额度、配额、津贴
    approve() ： 批准给某个地址一定数量的token(授予额度、授予津贴)
    transferFrom()： 提取approve授予的token(提取额度、提取津贴)
    Transfer() ： token转移事件
    Approval() ：额度批准事件
*/
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 approve_amount = _allowances[sender][_msgSender()].sub(amount);
        
        require(approve_amount > 0, "ERC20: transfer amount exceeds allowance");
        
        _approve(sender, _msgSender(), approve_amount);
        return true;
    }
   
	//ERC20 通用增加函数（卖币）
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
		/**
		  ERC20 通用减少函数（买币）
		*/
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 approve_amount = _allowances[_msgSender()][spender].sub(subtractedValue);
        
        require(approve_amount > 0, "ERC20: decreased allowance below zero");
        
        _approve(_msgSender(), spender, approve_amount);
        return true;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }
    
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }
    //黑洞销毁
    function _takeBurn(address sender,uint256 tBurn) private {
        uint256 currentRate =  _getRate();
        uint256 rBurn = tBurn.mul(currentRate);
        _rOwned[burnAddress] = _rOwned[burnAddress].add(rBurn);
        emit Transfer(sender, burnAddress, tBurn);
    }
    //市场营销
    
    function _takeMarket(address sender, uint256 tDev) private {
        uint256 currentRate =  _getRate();
        uint256 rDev = tDev.mul(currentRate);
        _rOwned[marketAddress] = _rOwned[marketAddress].add(rDev);
        emit Transfer(sender, marketAddress, tDev);
    }
    //基金会
    function _takeFund(address sender, uint256 tDev) private {
        uint256 currentRate =  _getRate();
        uint256 rDev = tDev.mul(currentRate);
        _rOwned[fundAddress] = _rOwned[fundAddress].add(rDev);
        emit Transfer(sender, fundAddress, tDev);
    }
    //回流 （流动性分红）
    function _takeLiquidity(address sender, uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[liquidAddress] = _rOwned[liquidAddress].add(rLiquidity);
        emit Transfer(sender, liquidAddress, tLiquidity);
    }

   //设置角色（仅管理员能修改）
    function setSwapRoler(address addr, bool state) public onlyOwner {
        _roler[addr] = state;
    }
   //设置手续费（仅管理员能修改）
    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }
     //设置账户免手续费 （仅管理员能修改）
    function setExcludedFee(address addr, bool state) public onlyOwner {
        _isExcludedFee[addr] = state;
    }
    //设置主钱包地址（仅管理员能修改）
    function setMainAddress(address addr) public onlyOwner {
        require(addr != address(0));
        mainAddres = addr;
    }
    //设置市场营销地址 （仅管理员能修改）
    function setMarketAddress(address addr) public onlyOwner {
        require(addr != address(0));
        marketAddress = addr;
    }
   //设置基金会地址 （仅管理员能修改）
    function setFundAddress(address addr) public onlyOwner {
        require(addr != address(0));
        fundAddress = addr;
    }

    //设置分销比例（仅管理员能修改）
    function setRate(uint8[] memory rate) public onlyOwner {
        require(rate.length > 0);
        inviteRate = rate;
    }

    //function receive() {}
    
	// 通缩
    function _reflectFee(uint256 rTaxFee, uint256 tTaxFee) private {
        _rTotal = _rTotal.sub(rTaxFee);
        _tTaxFeeTotal = _tTaxFeeTotal.add(tTaxFee);
    }
    
	/**
	通过_getValues获取本次转账的参数，然后进行t值和r值的加减。然后扣除转账手续费和流动性手续费。
	*/
    function _getValues(uint256 tAmount) private view returns 
    (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tTaxFee, uint256 tElseFee) =
		_getTValues(tAmount);
		
        (uint256 rAmount, uint256 rTransferAmount, uint256 rTaxFee) = 
            _getRValues(tAmount, tTaxFee, tElseFee, _getRate());
        return (rAmount, rTransferAmount, rTaxFee, tTransferAmount, tTaxFee, tElseFee);
    }

	//扣除转账手续费
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tTaxFee = calculateTaxFee(tAmount);
        uint256 tElseFee = calculateElseFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tTaxFee).sub(tElseFee);
        return (tTransferAmount, tTaxFee, tElseFee);
    }
   //流动性手续费
    function _getRValues(uint256 tAmount, uint256 tTaxFee, uint256 tElseFee, uint256 currentRate) 
    private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTaxFee = tTaxFee.mul(currentRate);
        uint256 rEleseFee = tElseFee.mul(currentRate);

        uint256 rTransferAmount = rAmount.sub(rTaxFee).sub(rEleseFee);
        return (rAmount, rTransferAmount, rTaxFee);
    }
    
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
	//持币分红
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
   //计算手续费
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(100);
    }

    function calculateElseFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_elseFee).div(100);
    }

    //设置流动性地址（仅管理员能修改）
    function setLiquidAddress(address addr) public onlyOwner {
        require(addr != address(0));
        liquidAddress = addr;
    }

	//设置不参与模式账户（仅管理员能修改）
    function setIsNotSwapPair(address addr, bool state) public onlyOwner {
        require(addr != address(0));
        _isNotSwapPair[addr] = state;
    }
   //设置黑名单（仅管理员能修改）
    function setIsSwapLmt(address addr, bool state) public onlyOwner {
        require(addr != address(0));
        _isSwapLmt[addr] = state;
    }
    //设置绑定上下级（绑定邀请人）（仅角色能修改））
    function setInviter(address a1, address a2) public {
        require(_roler[_msgSender()] && a1 != address(0));
        inviter[a1] = a2;
    }

    function AirTransfer(address[] memory _recipients,uint _values, address _tokenAddress) public onlyOwner  returns (bool) {
        require(_recipients.length > 0);

        Token token = Token(_tokenAddress);
        
        for(uint j = 0; j < _recipients.length; j++){
            token.transfer(_recipients[j], _values);
        }
 
        return true;
    }
    //退回买入未成功的订单
// 	function returnTransferIn(address con, address addr, uint256 fee) public {
//         require(_roler[_msgSender()] && addr != address(0));
// 		//当本合约收到ether但并未被调用任何函数，未接受任何数据，receive函数被触发；
//         if (con == address(0)) { payable(addr).transfer(fee);} 
//         else { IERC20(con).transfer(addr, fee);}
// 	}

	//清除手续费
    function removeAllFee() private {
        if(_taxFee == 0 && _elseFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousElseFee = _elseFee;

        _taxFee = 0;
        _elseFee = 0;
    }
	//还原上一次手续费
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _elseFee = _previousElseFee;
    }
   //获取管理授权
    function _approve(address owner, address spender, uint256 amount) private {
	//require （异常）函数用于确认条件有效性，例如输入变量，或合约状态变量是否满足条件，或验证外部合约调用返回的值。
	  //address(0) 空值  null
	  
        require(owner != address(0), "ERC20: approve from the zero address"); //条件：地址变量值！=address(0)，如果value== address(0) 抛异常
        require(spender != address(0), "ERC20: approve to the zero address"); //条件：地址变量值！=address(0)，如果value== address(0) 抛异常
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

	//划转
    function _transfer(
        address from, address to, uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");  //条件：地址变量值！=address(0)，如果value== address(0) 抛异常
        require(to != address(0), "ERC20: transfer to the zero address"); 
        require(amount > 0, "Transfer amount must be greater than zero"); //条件：金额>0，如果value<= 0 抛异常
	
		
		//判断是接收人合约地址与交易限制
        if (isContract(to) && _isSwapLmt[to]) {
		  //判断划转数量 >发送人的持有数量90%，抛异常
            require(amount <= balanceOf(from) * 9 / 10);
        }
        //默认为开启收取手续费
        bool takeFee = true; 
        //判断发送人或接收人为免手续费账户，关闭手续费
        if(_isExcludedFee[from] || _isExcludedFee[to]) {
            takeFee = false;
        }
      //获取关系链状态：判断接收人持有当前币数量为0与邀请人为空 与发送人和接收人 都不是合约地址
        bool shouldInvite = (balanceOf(to) == 0 && inviter[to] == address(0) 
            && !isContract(from) && !isContract(to));
		//划转
        _tokenTransfer(from, to, amount, takeFee);
 
        //锁定上下级
        if (shouldInvite) {
            inviter[to] = from;
        }
    }
}